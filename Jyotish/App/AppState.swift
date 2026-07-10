import AuthenticationServices
import SwiftUI

enum EmailSignUpOutcome {
    case success, emailAlreadyExists, failure
}

@MainActor
final class AppState: ObservableObject {
    @Published var account: UserAccount?
    @Published var family: [FamilyMember] = []
    @Published var events: [PatroEvent] = []
    @Published var chat: [ChatMessage] = []
    @Published var chatTypingMessageID: UUID?
    @Published var language: Language = .en
    @Published var theme: ThemeChoice = .system
    @Published var syncStatus: String?
    /// True while any sign-in/sign-up provider flow is in flight — drives the
    /// loading spinner on whichever button was tapped.
    @Published var isAuthenticating = false
    /// Transient tab selection — lets Home blocks deep-link into their tabs.
    @Published var selectedTab: AppTab = {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-tab"), i + 1 < args.count, let n = Int(args[i + 1]) {
            return AppTab.fromLaunchIndex(n)
        }
        return .home
    }()
    @Published var pushedDestination: AppDestination?
    @Published var modalDestination: AppDestination?

    // Service seam. Supabase is used when configured; otherwise the app remains local-first.
    let auth: AuthService
    private let sessionStore = SupabaseSessionStore()
    private let store: DataStore = LocalDataStore()
    private let remoteStore: RemoteDataStore?
    private let agent: AgentService?
    private var remotePersistTask: Task<Void, Never>?

    init() {
        var restoredSupabaseAccount: UserAccount?
        agent = Self.makeAgentService(sessionStore: sessionStore)
        if let config = SupabaseConfig.current {
            let supabaseAuth = SupabaseAuthService(config: config, sessionStore: sessionStore)
            auth = supabaseAuth
            remoteStore = SupabaseDataStore(config: config, sessionStore: sessionStore)
            if let session = supabaseAuth.currentSession {
                restoredSupabaseAccount = UserAccount(id: session.userID, email: nil, displayName: "", isDemo: false)
            }
        } else {
            auth = DummyAuthService()
            remoteStore = nil
        }
        if let saved = store.load() {
            account = saved.account
            family = saved.family
            events = saved.events
            chat = saved.chat
            language = saved.language
            theme = saved.theme
        }
        if let restoredSupabaseAccount {
            if account?.id == restoredSupabaseAccount.id, var cached = account {
                cached.isDemo = false
                account = cached
            } else {
                account = restoredSupabaseAccount
            }
            Task { await loadRemoteHousehold() }
        }
        seedIfRequested()
    }

    private static func makeAgentService(sessionStore: SupabaseSessionStore) -> AgentService? {
        let info = Bundle.main.infoDictionary ?? [:]
        let endpoint = (info["JYOTISH_AGENT_ENDPOINT_URL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let base = (info["JYOTISH_AGENT_BASE_URL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let raw = endpoint?.isEmpty == false ? endpoint : base
        guard let raw, !raw.isEmpty, let url = URL(string: raw) else { return nil }
        return HTTPAgentService(endpointURL: url,
                                apiKey: SupabaseConfig.current?.publishableKey,
                                authorizationToken: { sessionStore.load()?.accessToken })
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
        let household = Household(account: account, family: family, events: events,
                                  chat: chat, language: language, theme: theme)
        store.save(household)
        guard let account, let remoteStore else { return }
        remotePersistTask?.cancel()
        remotePersistTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 750_000_000)
            guard !Task.isCancelled else { return }
            do {
                try await remoteStore.save(household, for: account)
                await MainActor.run { self?.syncStatus = nil }
            } catch {
                await MainActor.run { self?.syncStatus = error.localizedDescription }
            }
        }
    }

    // ── Mutations ────────────────────────────────────────────────────────────
    func signInApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String, mode: AuthMode) {
        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            syncStatus = "Apple sign-in did not return an identity token."
            return
        }
        let fullName = PersonNameComponentsFormatter.localizedString(
            from: credential.fullName ?? PersonNameComponents(), style: .default
        ).trimmingCharacters(in: .whitespaces)
        isAuthenticating = true
        Task {
            do {
                let acct = try await auth.signInWithApple(idToken: idToken, rawNonce: rawNonce,
                                                           fullName: fullName.isEmpty ? nil : fullName, mode: mode)
                await completeSignIn(acct)
            } catch {
                syncStatus = error.localizedDescription
            }
            isAuthenticating = false
        }
    }

    func signInGoogle(mode: AuthMode) {
        isAuthenticating = true
        Task {
            do {
                let acct = try await auth.signInWithGoogle(mode: mode)
                await completeSignIn(acct)
            } catch {
                syncStatus = error.localizedDescription
            }
            isAuthenticating = false
        }
    }

    func signUpEmail(email: String, password: String) async -> EmailSignUpOutcome {
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let acct = try await auth.signUpEmail(email: email, password: password)
            await completeSignIn(acct)
            return .success
        } catch {
            syncStatus = error.localizedDescription
            if case SupabaseError.authError("user_already_exists", _) = error {
                return .emailAlreadyExists
            }
            return .failure
        }
    }

    func signInEmail(email: String, password: String) async -> Bool {
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let acct = try await auth.signInEmail(email: email, password: password)
            await completeSignIn(acct)
            return true
        } catch {
            syncStatus = error.localizedDescription
            return false
        }
    }

    func signOut() {
        Task { try? await auth.signOut() }
        account = nil
        family = []
        events = []
        chat = []
        persist()
    }

    /// Fetches the account's saved household (if any) before publishing `account`,
    /// so `isLoggedIn` and `hasBirthProfile` flip together — otherwise RootView
    /// briefly shows the birth-details flow before the real profile arrives.
    private func completeSignIn(_ acct: UserAccount) async {
        guard let remoteStore else {
            account = acct
            persist()
            return
        }
        do {
            if let remote = try await remoteStore.load(for: acct) {
                account = remote.account ?? acct
                family = remote.family
                events = remote.events
                chat = remote.chat
                language = remote.language
                theme = remote.theme
                store.save(remote)
            } else {
                account = acct
            }
            syncStatus = nil
        } catch {
            account = acct
            syncStatus = error.localizedDescription
        }
        persist()
    }

    private func loadRemoteHousehold() async {
        guard let account, let remoteStore else { return }
        do {
            if let remote = try await remoteStore.load(for: account) {
                self.account = remote.account ?? account
                family = remote.family
                events = remote.events
                chat = remote.chat
                language = remote.language
                theme = remote.theme
                store.save(remote)
            }
            syncStatus = nil
        } catch {
            syncStatus = error.localizedDescription
        }
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

    /// Returns false when the same dated item already exists, so an accidental
    /// second tap never creates duplicate Patro entries.
    @discardableResult
    func addPanditEvent(title: String, date: Date) -> Bool {
        let event = PanditActionResolver.event(title: title, date: date)
        guard !event.title.isEmpty else { return false }
        guard !events.contains(where: { $0.title.localizedCaseInsensitiveCompare(event.title) == .orderedSame
            && $0.bsDate == event.bsDate
        }) else { return false }
        addEvent(event)
        return true
    }

    func schedulePanditReminder(title: String, date: Date) async throws {
        try await ReminderService.schedule(title: title, date: date, language: language)
    }

    func open(_ destination: AppDestination) {
        switch destination.presentationStyle {
        case .tab:
            selectedTab = AppTab.allCases.first { $0.destination == destination } ?? .home
        case .pushed:
            pushedDestination = destination
        case .modal:
            modalDestination = destination
        }
    }

    func sendChat(_ text: String) async -> ChatMessage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        chat.append(ChatMessage(isUser: true, text: trimmed))
        let plan = PanditToolPlanner.plan(query: trimmed,
                                          family: family,
                                          events: events,
                                          language: language)
        let localAnswer = plan.answer
        persist()

        let pendingID = UUID()
        chatTypingMessageID = pendingID
        chat.append(ChatMessage(id: pendingID, isUser: false, text: "", actions: plan.actions))

        let context = AgentChatRequest.make(message: trimmed,
                                            localFallbackReply: localAnswer,
                                            family: family,
                                            events: events,
                                            chat: chat,
                                            language: language,
                                            selfMember: selfMember,
                                            toolEvidence: plan.evidence)
        let answer: String
        do {
            if let agent {
                answer = try await agent.streamReply(to: trimmed, context: context) { delta in
                    self.appendAssistantDelta(delta, messageID: pendingID)
                }
            } else {
                answer = localAnswer
                await streamLocalFallback(localAnswer, messageID: pendingID)
            }
            syncStatus = nil
        } catch {
            answer = localAnswer
            syncStatus = "Pandit backend unavailable; using local reading."
            replaceAssistantMessage(answer, actions: plan.actions, messageID: pendingID)
        }
        let reply = ChatMessage(id: pendingID, isUser: false, text: answer, actions: plan.actions)
        replaceAssistantMessage(answer, actions: plan.actions, messageID: pendingID)
        chatTypingMessageID = nil
        persist()
        return reply
    }

    private func appendAssistantDelta(_ delta: String, messageID: UUID) {
        guard let index = chat.firstIndex(where: { $0.id == messageID }) else { return }
        chat[index].text += delta
    }

    private func replaceAssistantMessage(_ text: String,
                                         actions: [PanditAction]? = nil,
                                         messageID: UUID) {
        guard let index = chat.firstIndex(where: { $0.id == messageID }) else { return }
        chat[index].text = text
        if let actions { chat[index].actions = actions }
    }

    private func streamLocalFallback(_ text: String, messageID: UUID) async {
        for character in text {
            appendAssistantDelta(String(character), messageID: messageID)
            try? await Task.sleep(nanoseconds: 12_000_000)
        }
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
