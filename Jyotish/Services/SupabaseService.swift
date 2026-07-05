import Foundation

struct SupabaseConfig {
    let url: URL
    let publishableKey: String

    static var current: SupabaseConfig? {
        let info = Bundle.main.infoDictionary ?? [:]
        let env = ProcessInfo.processInfo.environment
        let rawURL = clean(info["SUPABASE_URL"] as? String)
            ?? clean(env["SUPABASE_URL"])
        let rawKey = clean(info["SUPABASE_ANON_OR_PUBLISHABLE_KEY"] as? String)
            ?? clean(info["SUPABASE_PUBLISHABLE_KEY"] as? String)
            ?? clean(env["SUPABASE_ANON_OR_PUBLISHABLE_KEY"])
            ?? clean(env["SUPABASE_PUBLISHABLE_KEY"])
        guard let rawURL, let url = URL(string: rawURL), let rawKey else { return nil }
        return SupabaseConfig(url: url, publishableKey: rawKey)
    }

    private static func clean(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty,
              !trimmed.contains("$("),
              !trimmed.hasPrefix("YOUR_") else { return nil }
        return trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

enum SupabaseError: LocalizedError {
    case notConfigured
    case missingSession
    case badResponse(Int, String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase is not configured."
        case .missingSession:
            return "Supabase session is missing."
        case let .badResponse(status, body):
            return "Supabase request failed (\(status)): \(body)"
        }
    }
}

final class SupabaseSessionStore {
    private let defaults = UserDefaults.standard
    private let sessionKey = "jyotish.supabase.session"

    func load() -> SupabaseSession? {
        guard let data = defaults.data(forKey: sessionKey) else { return nil }
        return try? JSONDecoder().decode(SupabaseSession.self, from: data)
    }

    func save(_ session: SupabaseSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        defaults.set(data, forKey: sessionKey)
    }

    func clear() {
        defaults.removeObject(forKey: sessionKey)
    }
}

struct SupabaseSession: Codable {
    var accessToken: String
    var refreshToken: String
    var userID: UUID

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }

    enum UserKeys: String, CodingKey { case id }

    init(accessToken: String, refreshToken: String, userID: UUID) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userID = userID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let user = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        userID = try user.decode(UUID.self, forKey: .id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        var user = container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        try user.encode(userID, forKey: .id)
    }
}

final class SupabaseAuthService: AuthService {
    private let config: SupabaseConfig
    private let sessionStore: SupabaseSessionStore
    private let urlSession: URLSession

    init(config: SupabaseConfig, sessionStore: SupabaseSessionStore, urlSession: URLSession = .shared) {
        self.config = config
        self.sessionStore = sessionStore
        self.urlSession = urlSession
    }

    var currentSession: SupabaseSession? { sessionStore.load() }

    func signInDemo(name: String) async throws -> UserAccount {
        if let session = sessionStore.load() {
            return UserAccount(id: session.userID, email: nil, displayName: name, isDemo: false)
        }

        var request = authRequest(path: "/auth/v1/signup")
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "data": ["display_name": name]
        ])

        let session: SupabaseSession = try await send(request)
        sessionStore.save(session)
        return UserAccount(id: session.userID, email: nil, displayName: name, isDemo: false)
    }

    func signOut() async throws {
        guard let session = sessionStore.load() else { return }
        var request = authRequest(path: "/auth/v1/logout", bearer: session.accessToken)
        request.httpMethod = "POST"
        _ = try? await urlSession.data(for: request)
        sessionStore.clear()
    }

    private func authRequest(path: String, bearer: String? = nil) -> URLRequest {
        var request = URLRequest(url: endpoint(path))
        request.setValue(config.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer ?? config.publishableKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.badResponse(0, "") }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseError.badResponse(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func endpoint(_ path: String) -> URL {
        URL(string: path.trimmingCharacters(in: CharacterSet(charactersIn: "/")), relativeTo: config.url)!
    }
}

final class SupabaseDataStore: RemoteDataStore {
    private let config: SupabaseConfig
    private let sessionStore: SupabaseSessionStore
    private let urlSession: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(config: SupabaseConfig, sessionStore: SupabaseSessionStore, urlSession: URLSession = .shared) {
        self.config = config
        self.sessionStore = sessionStore
        self.urlSession = urlSession
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load(for account: UserAccount) async throws -> Household? {
        guard let session = sessionStore.load() else { throw SupabaseError.missingSession }
        var request = restRequest(path: "/rest/v1/households", session: session)
        request.url = URL(string: request.url!.absoluteString + "?user_id=eq.\(account.id.uuidString)&select=payload")!

        let rows: [HouseholdRow] = try await send(request)
        return rows.first?.payload
    }

    func save(_ household: Household, for account: UserAccount) async throws {
        guard let session = sessionStore.load() else { throw SupabaseError.missingSession }
        var saved = household
        saved.account = account
        let row = HouseholdRow(userID: account.id, payload: saved)

        var request = restRequest(path: "/rest/v1/households", session: session)
        request.httpMethod = "POST"
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([row])
        _ = try await sendEmpty(request)
    }

    private func restRequest(path: String, session: SupabaseSession) -> URLRequest {
        var request = URLRequest(url: endpoint(path))
        request.setValue(config.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.badResponse(0, "") }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseError.badResponse(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return try decoder.decode(T.self, from: data)
    }

    private func sendEmpty(_ request: URLRequest) async throws {
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.badResponse(0, "") }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseError.badResponse(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
    }

    private func endpoint(_ path: String) -> URL {
        URL(string: path.trimmingCharacters(in: CharacterSet(charactersIn: "/")), relativeTo: config.url)!
    }
}

private struct HouseholdRow: Codable {
    var userID: UUID
    var payload: Household

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case payload
    }
}
