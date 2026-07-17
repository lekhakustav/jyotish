import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

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
    case authError(code: String, message: String)
    case accountNotFound

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase is not configured."
        case .missingSession:
            return "Supabase session is missing."
        case let .badResponse(status, body):
            return "Supabase request failed (\(status)): \(body)"
        case let .authError(code, message):
            switch code {
            case "user_already_exists":
                return "This email is already registered — try signing in instead."
            case "invalid_credentials":
                return "Incorrect email or password."
            default:
                return message
            }
        case .accountNotFound:
            return "No account found for this sign-in — please create an account first."
        }
    }
}

/// Supabase's GoTrue auth endpoints (signup, token) all return this shape on failure.
private struct SupabaseAuthErrorBody: Decodable {
    let errorCode: String
    let msg: String
    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case msg
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
    var email: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }

    enum UserKeys: String, CodingKey { case id, email, createdAt = "created_at" }

    init(accessToken: String, refreshToken: String, userID: UUID, email: String? = nil, createdAt: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userID = userID
        self.email = email
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let user = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        userID = try user.decode(UUID.self, forKey: .id)
        email = try user.decodeIfPresent(String.self, forKey: .email)
        createdAt = try user.decodeIfPresent(String.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        var user = container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        try user.encode(userID, forKey: .id)
        try user.encodeIfPresent(email, forKey: .email)
        try user.encodeIfPresent(createdAt, forKey: .createdAt)
    }

    /// True if this Supabase user was created within the last few seconds —
    /// i.e. this exact OAuth exchange just created the account rather than
    /// resolving to an existing one.
    var isLikelyNewUser: Bool {
        guard let createdAt else { return false }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: createdAt) else { return false }
        return abs(date.timeIntervalSinceNow) < 10
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

    func signInWithApple(idToken: String, rawNonce: String, fullName: String?, mode: AuthMode) async throws -> UserAccount {
        var request = authRequest(path: "/auth/v1/token?grant_type=id_token")
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "provider": "apple",
            "id_token": idToken,
            "nonce": rawNonce,
        ])

        let session: SupabaseSession = try await send(request)
        if mode == .signIn && session.isLikelyNewUser {
            sessionStore.clear()
            throw SupabaseError.accountNotFound
        }
        sessionStore.save(session)
        return UserAccount(id: session.userID, email: session.email, displayName: fullName ?? "", isDemo: false)
    }

    func signInWithGoogle(mode: AuthMode) async throws -> UserAccount {
        let redirectTo = "jyotishbaje://auth-callback"
        var components = URLComponents(url: endpoint("/auth/v1/authorize"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "provider", value: "google"),
            URLQueryItem(name: "redirect_to", value: redirectTo),
            URLQueryItem(name: "apikey", value: config.publishableKey),
        ]

        let callbackURL = try await GoogleSignInCoordinator().signIn(authorizeURL: components.url!, callbackScheme: "jyotishbaje")
        let params = Self.parseFragment(callbackURL.fragment ?? "")
        guard let accessToken = params["access_token"], let refreshToken = params["refresh_token"] else {
            throw SupabaseError.badResponse(0, "Missing tokens in OAuth redirect")
        }

        let userRequest = authRequest(path: "/auth/v1/user", bearer: accessToken)
        let user: SupabaseUserResponse = try await send(userRequest)
        let session = SupabaseSession(accessToken: accessToken, refreshToken: refreshToken,
                                      userID: user.id, email: user.email, createdAt: user.createdAt)
        print("[GoogleAuth] resolved user id=\(user.id) createdAt=\(user.createdAt ?? "nil") isLikelyNewUser=\(session.isLikelyNewUser) mode=\(mode)")
        if mode == .signIn && session.isLikelyNewUser {
            throw SupabaseError.accountNotFound
        }
        sessionStore.save(session)
        return UserAccount(id: session.userID, email: session.email, displayName: "", isDemo: false)
    }

    func signUpEmail(email: String, password: String) async throws -> UserAccount {
        var request = authRequest(path: "/auth/v1/signup")
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])

        let session: SupabaseSession = try await send(request)
        sessionStore.save(session)
        return UserAccount(id: session.userID, email: session.email, displayName: "", isDemo: false)
    }

    func signInEmail(email: String, password: String) async throws -> UserAccount {
        var request = authRequest(path: "/auth/v1/token?grant_type=password")
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])

        let session: SupabaseSession = try await send(request)
        sessionStore.save(session)
        return UserAccount(id: session.userID, email: session.email, displayName: "", isDemo: false)
    }

    private static func parseFragment(_ fragment: String) -> [String: String] {
        Dictionary(uniqueKeysWithValues: fragment.split(separator: "&").compactMap { pair -> (String, String)? in
            let parts = pair.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { return nil }
            return (String(parts[0]), String(parts[1]).removingPercentEncoding ?? String(parts[1]))
        })
    }

    func signOut() async throws {
        guard let session = sessionStore.load() else { return }
        var request = authRequest(path: "/auth/v1/logout", bearer: session.accessToken)
        request.httpMethod = "POST"
        _ = try? await urlSession.data(for: request)
        sessionStore.clear()
    }

    /// Server-side account deletion (Guideline 5.1.1(v)): the delete-account
    /// Edge Function wipes household and analytics rows, then the auth user.
    func deleteAccount() async throws {
        guard let session = sessionStore.load() else { throw SupabaseError.missingSession }
        var request = authRequest(path: "/functions/v1/delete-account", bearer: session.accessToken)
        request.httpMethod = "POST"
        request.httpBody = Data("{}".utf8)
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw SupabaseError.badResponse(status, String(data: data, encoding: .utf8) ?? "")
        }
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
            if let authError = try? JSONDecoder().decode(SupabaseAuthErrorBody.self, from: data) {
                throw SupabaseError.authError(code: authError.errorCode, message: authError.msg)
            }
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
        request.url = URL(string: request.url!.absoluteString + "?user_id=eq.\(account.id.uuidString)&select=user_id,payload")!

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

private struct SupabaseUserResponse: Decodable {
    var id: UUID
    var email: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case createdAt = "created_at"
    }
}

/// Drives Google's browser-based OAuth flow (Supabase's Google provider is
/// already configured server-side — no native Google SDK needed). The system
/// browser sheet handles login; we only capture the final redirect.
@MainActor
final class GoogleSignInCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    // Must be retained for the life of the flow — ASWebAuthenticationSession
    // doesn't keep itself alive, and a deallocated session crashes the app
    // when the system tries to present or complete it.
    private var session: ASWebAuthenticationSession?

    func signIn(authorizeURL: URL, callbackScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: authorizeURL, callbackURLScheme: callbackScheme) { callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: error ?? URLError(.badServerResponse))
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            self.session = session
            session.start()
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

/// Sign in with Apple replay-attack mitigation: a random nonce is hashed and sent to
/// Apple in the authorization request, then the raw nonce is sent to Supabase alongside
/// the identity token so it can verify the token was issued for this exact request.
enum AppleSignInNonce {
    static func random(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(status == errSecSuccess, "Unable to generate secure nonce")
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
