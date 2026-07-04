import Foundation

// The service seam. v1 runs on the Dummy/Local implementations; when Supabase
// arrives only the wiring in AppState.init changes. See docs/02-ARCHITECTURE.md.

protocol AuthService {
    func signInDemo(name: String) async throws -> UserAccount
    func signOut() async throws
}

protocol DataStore {
    func load() -> Household?
    func save(_ household: Household)
}

struct DummyAuthService: AuthService {
    func signInDemo(name: String) async throws -> UserAccount {
        UserAccount(email: nil, displayName: name, isDemo: true)
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
