import Foundation

// ── Supabase-ready stubs ─────────────────────────────────────────────────────
// Not used in v1. When the Supabase project exists:
//   1. Fill SupabaseConfig.
//   2. Implement the two services below (REST or supabase-swift SDK).
//   3. In AppState.init swap DummyAuthService/LocalDataStore for these.
//
// Table schema (mirrors Household/Codable models 1:1, all rows keyed by user_id):
//   profiles(user_id uuid pk, display_name text, email text)
//   family_members(id uuid pk, user_id uuid, name text, gender text, relation text,
//                  birth jsonb, kundali jsonb)
//   events(id uuid pk, user_id uuid, title text, note text, bs_date jsonb, repeats_yearly bool)
//   chat_messages(id uuid pk, user_id uuid, is_user bool, text text, created_at timestamptz)
//   settings(user_id uuid pk, language text, theme text)

struct SupabaseConfig {
    static let url = URL(string: "https://YOUR-PROJECT.supabase.co")!
    static let anonKey = "YOUR-ANON-KEY"
    static var isConfigured: Bool { anonKey != "YOUR-ANON-KEY" }
}

struct SupabaseAuthService: AuthService {
    func signInDemo(name: String) async throws -> UserAccount {
        // TODO(supabase): supabase.auth.signInWithOTP / signInWithPassword
        throw NSError(domain: "supabase", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Supabase not configured"])
    }
    func signOut() async throws {
        // TODO(supabase): supabase.auth.signOut()
    }
}

final class SupabaseDataStore: DataStore {
    func load() -> Household? {
        // TODO(supabase): fetch all tables for auth.uid(), assemble Household
        nil
    }
    func save(_ household: Household) {
        // TODO(supabase): upsert changed rows; consider per-entity saves instead
    }
}
