import Foundation
import Speech
import AVFoundation

/// Voice for Pandit-ji: speech-to-text for asking questions, text-to-speech
/// for the replies. Fully on-device APIs; degrades gracefully when the
/// recognizer or a voice is unavailable (e.g. some simulators).
@MainActor
final class VoiceAgent: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var transcript = ""
    @Published var speaksReplies = false
    @Published var unavailable = false

    private let synthesizer = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    /// Nepali speech recognition isn't shipped on iOS; Hindi shares the
    /// Devanagari script and understands enough for short questions.
    private func recognizer(for lang: Language) -> SFSpeechRecognizer? {
        let ids = lang == .ne ? ["ne-NP", "hi-IN", "en-IN"] : ["en-IN", "en-US"]
        for id in ids {
            if let r = SFSpeechRecognizer(locale: Locale(identifier: id)), r.isAvailable { return r }
        }
        return SFSpeechRecognizer()
    }

    func toggleListening(lang: Language, onFinal: @escaping (String) -> Void) {
        isListening ? finishListening(onFinal: onFinal) : startListening(lang: lang)
    }

    private func startListening(lang: Language) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard status == .authorized else { self?.unavailable = true; return }
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        guard granted else { self?.unavailable = true; return }
                        self?.beginRecognition(lang: lang)
                    }
                }
            }
        }
    }

    private func beginRecognition(lang: Language) {
        guard let recognizer = recognizer(for: lang), recognizer.isAvailable else {
            unavailable = true
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.request = request

            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()

            transcript = ""
            isListening = true
            Haptics.tap()

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result { self?.transcript = result.bestTranscription.formattedString }
                    if error != nil { self?.teardown() }
                }
            }
        } catch {
            unavailable = true
            teardown()
        }
    }

    private func finishListening(onFinal: @escaping (String) -> Void) {
        let text = transcript
        teardown()
        Haptics.tap()
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onFinal(text)
        }
    }

    private func teardown() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
    }

    /// Speak a Pandit reply. Nepali TTS voice isn't shipped; the Hindi voice
    /// reads Devanagari naturally and is the accepted fallback.
    func speak(_ text: String, lang: Language) {
        guard speaksReplies else { return }
        stopSpeaking()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
        let utterance = AVSpeechUtterance(string: text)
        let ids = lang == .ne ? ["ne-NP", "hi-IN", "en-IN"] : ["en-IN", "en-GB", "en-US"]
        utterance.voice = ids.lazy.compactMap { AVSpeechSynthesisVoice(language: $0) }.first
        utterance.rate = 0.47
        utterance.pitchMultiplier = 0.95
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
    }
}
