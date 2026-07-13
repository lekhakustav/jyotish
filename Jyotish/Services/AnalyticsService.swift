import Foundation
import OSLog

struct AnalyticsEvent: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var occurredAt = Date()
    var sessionID: UUID
    var installID: UUID
    var properties: [String: String]
}

protocol AnalyticsRemoteSink: Sendable {
    func upload(_ events: [AnalyticsEvent]) async throws
}

/// Privacy-conscious product analytics. Every event is durable offline first;
/// authenticated Supabase upload is best-effort and never blocks interaction.
actor AppAnalytics {
    static let shared = AppAnalytics()
    private static let sessionID = UUID()
    private static let installID: UUID = {
        let key = "jyotish.analytics.installID"
        if let raw = UserDefaults.standard.string(forKey: key), let id = UUID(uuidString: raw) { return id }
        let id = UUID()
        UserDefaults.standard.set(id.uuidString, forKey: key)
        return id
    }()

    private let logger = Logger(subsystem: "com.sodhera.jyotishbaje", category: "analytics")
    private let encoder: JSONEncoder
    private let logURL: URL
    private let pendingURL: URL
    private var pending: [AnalyticsEvent]
    private var sink: AnalyticsRemoteSink?
    private var flushTask: Task<Void, Never>?

    init(baseDirectory: URL? = nil) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let root = baseDirectory ?? FileManager.default.urls(for: .applicationSupportDirectory,
                                                              in: .userDomainMask).first!
            .appendingPathComponent("JyotishBaje", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        logURL = root.appendingPathComponent("analytics-events.jsonl")
        pendingURL = root.appendingPathComponent("analytics-pending.json")
        if let data = try? Data(contentsOf: pendingURL) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            pending = (try? decoder.decode([AnalyticsEvent].self, from: data)) ?? []
        } else {
            pending = []
        }
    }

    nonisolated static func track(_ name: String,
                                  properties: [String: String] = [:]) {
        let event = AnalyticsEvent(name: sanitizeName(name), sessionID: sessionID,
                                   installID: installID, properties: sanitize(properties))
        Task { await shared.record(event) }
    }

    nonisolated static func tap(file: StaticString, function: StaticString, line: UInt) {
        track("ui_tap", properties: [
            "source": "\(file):\(line)",
            "function": String(describing: function)
        ])
    }

    nonisolated static func configure(_ sink: AnalyticsRemoteSink) {
        Task { await shared.setSink(sink) }
    }

    nonisolated static func flushNow() {
        Task { await shared.flush() }
    }

    func queuedCountForTesting() -> Int { pending.count }
    func recordForTesting(_ event: AnalyticsEvent) { record(event) }
    func localLogURLForTesting() -> URL { logURL }

    private func setSink(_ sink: AnalyticsRemoteSink) {
        self.sink = sink
        scheduleFlush(delayNanoseconds: 100_000_000)
    }

    private func record(_ event: AnalyticsEvent) {
        logger.info("event=\(event.name, privacy: .public) properties=\(event.properties.description, privacy: .private(mask: .hash))")
        appendToLocalLog(event)
        pending.append(event)
        if pending.count > 2_000 { pending.removeFirst(pending.count - 2_000) }
        persistPending()
        scheduleFlush(delayNanoseconds: 2_000_000_000)
    }

    private func appendToLocalLog(_ event: AnalyticsEvent) {
        rotateLogIfNeeded()
        guard var data = try? encoder.encode(event) else { return }
        data.append(0x0A)
        if FileManager.default.fileExists(atPath: logURL.path),
           let handle = try? FileHandle(forWritingTo: logURL) {
            defer { try? handle.close() }
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            try? data.write(to: logURL, options: .atomic)
        }
    }

    private func rotateLogIfNeeded() {
        let size = (try? FileManager.default.attributesOfItem(atPath: logURL.path)[.size] as? NSNumber)?.intValue ?? 0
        guard size > 5 * 1_024 * 1_024 else { return }
        let archive = logURL.deletingPathExtension().appendingPathExtension("previous.jsonl")
        try? FileManager.default.removeItem(at: archive)
        try? FileManager.default.moveItem(at: logURL, to: archive)
    }

    private func persistPending() {
        guard let data = try? encoder.encode(pending) else { return }
        try? data.write(to: pendingURL, options: .atomic)
    }

    private func scheduleFlush(delayNanoseconds: UInt64) {
        guard sink != nil else { return }
        flushTask?.cancel()
        flushTask = Task {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            guard !Task.isCancelled else { return }
            await flush()
        }
    }

    private func flush() async {
        flushTask = nil
        guard let sink, !pending.isEmpty else { return }
        let batch = Array(pending.prefix(100))
        do {
            try await sink.upload(batch)
            let ids = Set(batch.map(\.id))
            pending.removeAll { ids.contains($0.id) }
            persistPending()
            if !pending.isEmpty { scheduleFlush(delayNanoseconds: 200_000_000) }
        } catch {
            logger.error("analytics upload retained for retry: \(error.localizedDescription, privacy: .public)")
        }
    }

    private nonisolated static func sanitizeName(_ value: String) -> String {
        let cleaned = value.lowercased().map { $0.isLetter || $0.isNumber || $0 == "_" ? $0 : "_" }
        return String(cleaned.prefix(64))
    }

    private nonisolated static func sanitize(_ properties: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: properties.prefix(24).map { key, value in
            (String(key.prefix(48)), String(value.prefix(160)))
        })
    }
}

final class SupabaseAnalyticsSink: AnalyticsRemoteSink, @unchecked Sendable {
    private let config: SupabaseConfig
    private let sessionStore: SupabaseSessionStore
    private let session: URLSession
    private let encoder: JSONEncoder

    init(config: SupabaseConfig, sessionStore: SupabaseSessionStore,
         session: URLSession = .shared) {
        self.config = config
        self.sessionStore = sessionStore
        self.session = session
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func upload(_ events: [AnalyticsEvent]) async throws {
        guard let auth = sessionStore.load() else { throw SupabaseError.missingSession }
        let rows = events.map { AnalyticsUploadRow(userID: auth.userID, event: $0) }
        var request = URLRequest(url: URL(string: "/rest/v1/analytics_events", relativeTo: config.url)!)
        request.httpMethod = "POST"
        request.setValue(config.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(auth.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode(rows)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw SupabaseError.badResponse(status, String(data: data, encoding: .utf8) ?? "")
        }
    }
}

private struct AnalyticsUploadRow: Encodable {
    var userID: UUID
    var eventID: UUID
    var sessionID: UUID
    var installID: UUID
    var eventName: String
    var properties: [String: String]
    var occurredAt: Date

    init(userID: UUID, event: AnalyticsEvent) {
        self.userID = userID
        eventID = event.id
        sessionID = event.sessionID
        installID = event.installID
        eventName = event.name
        properties = event.properties
        occurredAt = event.occurredAt
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id", eventID = "event_id", sessionID = "session_id"
        case installID = "install_id", eventName = "event_name", properties
        case occurredAt = "occurred_at"
    }
}
