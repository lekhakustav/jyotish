import Foundation

struct AgentChatRequest: Encodable {
    var language: String
    var message: String
    var nowISO: String
    var selfMemberID: UUID?
    var family: [AgentFamilyMember]
    var events: [AgentEvent]
    var chatHistory: [AgentChatMessage]
    var localFallbackReply: String
}

struct AgentFamilyMember: Encodable {
    var id: UUID
    var name: String
    var gender: String
    var relationEN: String
    var relationNE: String
    var birth: BirthData?
    var kundali: AgentKundali?
    var readingEN: String?
    var readingNE: String?
    var currentDashaEN: String?
    var currentDashaNE: String?
    var dailyRashifal: String?
}

struct AgentKundali: Encodable {
    var lagnaEN: String
    var lagnaNE: String
    var moonRashiEN: String
    var moonRashiNE: String
    var sunRashiEN: String
    var sunRashiNE: String
    var moonNakshatraEN: String
    var moonNakshatraNE: String
    var moonNakshatraPada: Int
    var birthJulianDay: Double
    var planetRashiEN: [String: String]
    var planetRashiNE: [String: String]
}

struct AgentEvent: Encodable {
    var title: String
    var note: String
    var bsDate: String
    var repeatsYearly: Bool
}

struct AgentChatMessage: Encodable {
    var role: String
    var text: String
    var timestampISO: String
}

struct AgentChatResponse: Decodable {
    var reply: String
    var usedLocalFallback: Bool?
}

protocol AgentService {
    func reply(to message: String, context: AgentChatRequest) async throws -> String
}

enum AgentServiceError: Error {
    case invalidBaseURL
    case emptyReply
    case badStatus(Int, String)
}

struct HTTPAgentService: AgentService {
    let baseURL: URL
    var session: URLSession = .shared

    func reply(to message: String, context: AgentChatRequest) async throws -> String {
        let endpoint = baseURL.appending(path: "/api/jyotish-agent/chat")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.agentEncoder.encode(context)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AgentServiceError.badStatus(-1, "Missing HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AgentServiceError.badStatus(http.statusCode, body)
        }
        let decoded = try JSONDecoder().decode(AgentChatResponse.self, from: data)
        let reply = decoded.reply.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reply.isEmpty else { throw AgentServiceError.emptyReply }
        return reply
    }
}

extension AgentChatRequest {
    static func make(message: String,
                     localFallbackReply: String,
                     family: [FamilyMember],
                     events: [PatroEvent],
                     chat: [ChatMessage],
                     language: Language,
                     selfMember: FamilyMember?) -> AgentChatRequest {
        AgentChatRequest(
            language: language.rawValue,
            message: message,
            nowISO: ISO8601DateFormatter.agentFormatter.string(from: Date()),
            selfMemberID: selfMember?.id,
            family: family.map { AgentFamilyMember.make(from: $0, language: language) },
            events: events.map(AgentEvent.make),
            chatHistory: chat.suffix(16).map(AgentChatMessage.make),
            localFallbackReply: localFallbackReply
        )
    }
}

extension AgentFamilyMember {
    static func make(from member: FamilyMember, language: Language) -> AgentFamilyMember {
        var agentKundali: AgentKundali?
        var readingEN: String?
        var readingNE: String?
        var dashaEN: String?
        var dashaNE: String?
        var rashifal: String?

        if let kundali = member.kundali {
            agentKundali = AgentKundali.make(from: kundali)
            readingEN = Interpreter.reading(for: kundali, lang: .en)
            readingNE = Interpreter.reading(for: kundali, lang: .ne)
            if let current = Vimshottari.current(for: kundali, at: Ephemeris.julianDay(Date())) {
                dashaEN = "\(current.maha.lord.nameEN) mahadasha, \(current.antar.lord.nameEN) antardasha"
                dashaNE = "\(current.maha.lord.nameNE) महादशा, \(current.antar.lord.nameNE) अन्तर्दशा"
            }
            let daily = RashifalEngine.generate(rashi: kundali.moonRashi,
                                                period: .daily,
                                                date: Date(),
                                                lang: language)
            rashifal = daily.text
        }

        return AgentFamilyMember(
            id: member.id,
            name: member.name,
            gender: member.gender.rawValue,
            relationEN: member.relation.labelEN,
            relationNE: member.relation.labelNE,
            birth: member.birth,
            kundali: agentKundali,
            readingEN: readingEN,
            readingNE: readingNE,
            currentDashaEN: dashaEN,
            currentDashaNE: dashaNE,
            dailyRashifal: rashifal
        )
    }
}

extension AgentKundali {
    static func make(from kundali: Kundali) -> AgentKundali {
        var planetRashiEN: [String: String] = [:]
        var planetRashiNE: [String: String] = [:]
        for planet in Planet.allCases {
            let rashi = kundali.rashi(of: planet)
            planetRashiEN[planet.nameEN] = rashi.nameEN
            planetRashiNE[planet.nameNE] = rashi.nameNE
        }
        return AgentKundali(
            lagnaEN: kundali.lagna.nameEN,
            lagnaNE: kundali.lagna.nameNE,
            moonRashiEN: kundali.moonRashi.nameEN,
            moonRashiNE: kundali.moonRashi.nameNE,
            sunRashiEN: kundali.sunRashi.nameEN,
            sunRashiNE: kundali.sunRashi.nameNE,
            moonNakshatraEN: kundali.moonNakshatra.nameEN,
            moonNakshatraNE: kundali.moonNakshatra.nameNE,
            moonNakshatraPada: kundali.moonNakshatraPada,
            birthJulianDay: kundali.birthJD,
            planetRashiEN: planetRashiEN,
            planetRashiNE: planetRashiNE
        )
    }
}

extension AgentEvent {
    static func make(from event: PatroEvent) -> AgentEvent {
        AgentEvent(
            title: event.title,
            note: event.note,
            bsDate: "\(event.bsDate.year)-\(event.bsDate.month)-\(event.bsDate.day)",
            repeatsYearly: event.repeatsYearly
        )
    }
}

extension AgentChatMessage {
    static func make(from message: ChatMessage) -> AgentChatMessage {
        AgentChatMessage(
            role: message.isUser ? "user" : "assistant",
            text: message.text,
            timestampISO: ISO8601DateFormatter.agentFormatter.string(from: message.timestamp)
        )
    }
}

extension JSONEncoder {
    static var agentEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension ISO8601DateFormatter {
    static let agentFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
