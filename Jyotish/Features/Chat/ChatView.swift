import SwiftUI

// Extreme-minimal chat: pandit speaks as flat serif prose on the canvas,
// the user's words sit in a single quiet tint. Voice in, voice out.
struct ChatView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @StateObject private var voice = VoiceAgent()
    @State private var draft = ""
    @FocusState private var focused: Bool

    private let chips = ["chat.chip.color", "chat.chip.city", "chat.chip.vastu", "chat.chip.dasha"]

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            if app.chat.isEmpty { welcome }
                            ForEach(app.chat) { msg in
                                bubble(msg)
                                    .id(msg.id)
                                    .transition(.opacity.combined(with: .offset(y: 8)))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.9), value: app.chat.count)
                    .onChange(of: app.chat.count) {
                        if let last = app.chat.last {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                chipsRow
                inputBar
            }
        }
        .statusBarFade()
        .onDisappear { voice.stopSpeaking() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("पण्डितजी")
                    .scaledFont(size: 15, design: .serif)
                    .foregroundStyle(p.templeGold)
                    .accessibilityHidden(true)
                Text(app.t("chat.title"))
                    .scaledFont(size: 34, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
            }
            Spacer()
            Button {
                Haptics.tap()
                voice.speaksReplies.toggle()
                if !voice.speaksReplies { voice.stopSpeaking() }
            } label: {
                Image(systemName: voice.speaksReplies ? "speaker.wave.2" : "speaker.slash")
                    .scaledFont(size: 19, weight: .light)
                    .foregroundStyle(voice.speaksReplies ? p.saffron : p.inkSecondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel(app.t("chat.speak"))
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            DiyaFlame(size: 36)
            Text(PanditBrain(family: app.family, lang: app.language).reply(to: "namaste"))
                .scaledFont(size: 16, design: .serif)
                .foregroundStyle(p.inkPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 12)
        }
        .padding(.top, 16)
    }

    private func bubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 56) }
            if msg.isUser {
                Text(msg.text)
                    .scaledFont(size: 16)
                    .foregroundStyle(p.inkPrimary)
                    .lineSpacing(4)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(p.marigold.opacity(0.2)))
            } else {
                // Pandit speaks directly on the canvas — no container at all.
                Text(msg.text)
                    .scaledFont(size: 16, design: .serif)
                    .foregroundStyle(p.inkPrimary.opacity(0.92))
                    .lineSpacing(6)
            }
            if !msg.isUser { Spacer(minLength: 56) }
        }
    }

    private var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { key in
                    Button {
                        Haptics.tap()
                        send(app.t(key))
                    } label: {
                        Text(app.t(key))
                            .scaledFont(size: 13)
                            .foregroundStyle(p.sindoor)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Capsule().fill(p.bgElevated))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 8)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(voice.isListening ? app.t("chat.listening") : app.t("chat.placeholder"),
                      text: voice.isListening ? $voice.transcript : $draft, axis: .vertical)
                .scaledFont(size: 16)
                .focused($focused)
                .lineLimit(1...4)
                .padding(.horizontal, 16).padding(.vertical, 11)
                .background(RoundedRectangle(cornerRadius: 22).fill(p.bgSunken))

            Button {
                focused = false
                voice.toggleListening(lang: app.language) { text in send(text) }
            } label: {
                Image(systemName: voice.isListening ? "stop.circle.fill" : "mic.fill")
                    .scaledFont(size: 22)
                    .foregroundStyle(voice.isListening ? p.sindoor : p.saffron)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(p.bgElevated))
                    .scaleEffect(voice.isListening ? 1.08 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: voice.isListening)
            }
            .disabled(voice.unavailable)
            .opacity(voice.unavailable ? 0.35 : 1)
            .accessibilityLabel(voice.isListening ? "Stop listening" : "Ask by voice")

            if !draft.trimmingCharacters(in: .whitespaces).isEmpty {
                Button {
                    let text = draft
                    draft = ""
                    send(text)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .scaledFont(size: 36)
                        .foregroundStyle(p.saffron)
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Send")
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: draft.isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func send(_ text: String) {
        app.sendChat(text)
        if let reply = app.chat.last, !reply.isUser {
            voice.speak(reply.text, lang: app.language)
        }
    }
}
