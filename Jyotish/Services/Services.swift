import Foundation

// The service seam. The app runs on Dummy/Local when Supabase is absent and
// SupabaseAuthService/SupabaseDataStore when client config is present.

protocol AuthService {
    func signInWithApple(idToken: String, rawNonce: String, fullName: String?, mode: AuthMode) async throws -> UserAccount
    func signInWithGoogle(mode: AuthMode) async throws -> UserAccount
    func signUpEmail(email: String, password: String) async throws -> UserAccount
    func signInEmail(email: String, password: String) async throws -> UserAccount
    func signOut() async throws
}

protocol DataStore {
    func load() -> Household?
    func save(_ household: Household)
}

protocol RemoteDataStore {
    func load(for account: UserAccount) async throws -> Household?
    func save(_ household: Household, for account: UserAccount) async throws
}

struct DummyAuthService: AuthService {
    func signInWithApple(idToken: String, rawNonce: String, fullName: String?, mode: AuthMode) async throws -> UserAccount {
        UserAccount(email: nil, displayName: fullName ?? "", isDemo: true)
    }
    func signInWithGoogle(mode: AuthMode) async throws -> UserAccount {
        UserAccount(email: nil, displayName: "", isDemo: true)
    }
    func signUpEmail(email: String, password: String) async throws -> UserAccount {
        UserAccount(email: email, displayName: "", isDemo: true)
    }
    func signInEmail(email: String, password: String) async throws -> UserAccount {
        UserAccount(email: email, displayName: "", isDemo: true)
    }
    func signOut() async throws {}
}

/// Atomic JSON persistence in Documents/household.json.
final class LocalDataStore: DataStore {
    private var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("household.json")
    }
    func load() -> Household? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Household.self, from: data)
    }
    func save(_ household: Household) {
        guard let data = try? JSONEncoder().encode(household) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
