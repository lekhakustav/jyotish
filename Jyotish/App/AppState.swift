import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var account: UserAccount?
    @Published var family: [FamilyMember] = []
    @Published var events: [PatroEvent] = []
    @Published var chat: [ChatMessage] = []
    @Published var language: Language = .en
    @Published var theme: ThemeChoice = .system

    // Service seam — swap for Supabase implementations later (docs/02).
    let auth: AuthService = DummyAuthService()
    private let store: DataStore = LocalDataStore()

    init() {
        if let saved = store.load() {
            account = saved.account
            family = saved.family
            events = saved.events
            chat = saved.chat
            language = saved.language
            theme = saved.theme
        }
        seedIfRequested()
    }

    /// QA-only: `-demoSeed` launch argument creates a ready-made household so
    /// every screen can be exercised on a fresh simulator. `-lang ne` forces Nepali.
    private func seedIfRequested() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-lang"), let i = args.firstIndex(of: "-lang"), i + 1 < args.count,
           let l = Language(rawValue: args[i + 1]) {
            language = l
        }
        guard args.contains("-demoSeed"), account == nil else { return }
        account = UserAccount(displayName: "Sita Sharma", isDemo: true)
        var me = FamilyMember(name: "Sita Sharma", gender: .female, relation: .selfMember,
                              birth: BirthData(year: 1962, month: 3, day: 15, hour: 7, minute: 30,
                                               timeKnown: true, place: .kathmandu))
        me.recompute()
        var son = FamilyMember(name: "Aarav", gender: .male, relation: .son,
                               birth: BirthData(year: 1990, month: 6, day: 15, hour: 8, minute: 30,
                                                timeKnown: true, place: .kathmandu))
        son.recompute()
        var daughter = FamilyMember(name: "Priya", gender: .female, relation: .daughter,
                                    birth: BirthData(year: 1993, month: 11, day: 2, hour: 14, minute: 10,
                                                     timeKnown: true, place: BirthPlace.presets[1]))
        daughter.recompute()
        family = [me, son, daughter]
        let today = BikramSambat.today()
        events = [
            PatroEvent(title: "Aarav's birthday", note: "Ashirwad + kheer", bsDate: NepaliDate(year: today.year, month: today.month, day: min(28, today.day + 3)), repeatsYearly: true),
            PatroEvent(title: "Satyanarayan Puja", note: "", bsDate: NepaliDate(year: today.year, month: today.month, day: min(30, today.day + 9))),
        ]
        persist()
    }

    var isLoggedIn: Bool { account != nil }
    var selfMember: FamilyMember? { family.first { $0.relation == .selfMember } }
    var hasBirthProfile: Bool { selfMember?.hasBirthData == true }

    func t(_ key: String) -> String { L10n.t(key, language) }
    func digits(_ n: Int) -> String { L10n.digits(n, language) }
    /// Locale for date formatting — Nepali month/weekday names when language is NE.
    var locale: Locale { Locale(identifier: language == .ne ? "ne_NP" : "en_US") }

    private func persist() {
        store.save(Household(account: account, family: family, events: events,
                             chat: chat, language: language, theme: theme))
    }

    // ── Mutations ────────────────────────────────────────────────────────────
    func signInDemo() {
        Task {
            if let acct = try? await auth.signInDemo(name: "") {
                account = acct
                persist()
            }
        }
    }

    func signOut() {
        account = nil
        persist()
    }

    func saveSelf(name: String, gender: Gender, birth: BirthData) {
        var member = selfMember ?? FamilyMember(name: name, gender: gender, relation: .selfMember)
        member.name = name
        member.gender = gender
        member.birth = birth
        member.recompute()
        if let i = family.firstIndex(where: { $0.relation == .selfMember }) {
            family[i] = member
        } else {
            family.insert(member, at: 0)
        }
        if var acct = account { acct.displayName = name; account = acct }
        persist()
    }

    func addMember(_ member: FamilyMember) {
        var m = member
        m.recompute()
        family.append(m)
        persist()
    }

    func removeMember(_ member: FamilyMember) {
        family.removeAll { $0.id == member.id }
        persist()
    }

    func addEvent(_ event: PatroEvent) { events.append(event); persist() }
    func removeEvent(_ event: PatroEvent) { events.removeAll { $0.id == event.id }; persist() }

    func sendChat(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        chat.append(ChatMessage(isUser: true, text: trimmed))
        let brain = PanditBrain(family: family, lang: language)
        let answer = brain.reply(to: trimmed)
        chat.append(ChatMessage(isUser: false, text: answer))
        persist()
    }

    func setLanguage(_ l: Language) { language = l; persist() }
    func setTheme(_ t: ThemeChoice) { theme = t; persist() }

    /// Events coming up in the next `days` days, resolved to AD dates.
    func upcomingEvents(days: Int = 45) -> [(event: PatroEvent, date: Date, bs: NepaliDate)] {
        let cal = Calendar.nepali
        let today = cal.startOfDay(for: Date())
        var out: [(PatroEvent, Date, NepaliDate)] = []
        for offset in 0..<days {
            guard let day = cal.date(byAdding: .day, value: offset, to: today) else { continue }
            let bs = BikramSambat.toBS(day)
            for e in events where e.occurs(on: bs) {
                out.append((e, day, bs))
            }
        }
        return out
    }
}
