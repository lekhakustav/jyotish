import SwiftUI

// Extreme-minimal chat: pandit speaks as flat serif prose on the canvas,
// the user's words sit in a single quiet tint. Voice in, voice out.
struct ChatView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var voice = VoiceAgent()
    @State private var draft = ""
    @State private var showHistory = ProcessInfo.processInfo.arguments.contains("-chatShelf")
    @State private var isSending = false
    @State private var pendingAction: PanditAction?
    @State private var showComparison = false
    @State private var kundliPath: [UUID] = []
    @State private var notice: String?
    @State private var followsLatestAnswer = true
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack(path: $kundliPath) {
            ZStack(alignment: .leading) {
                p.bgCanvas.ignoresSafeArea()
                VStack(spacing: 0) {
                    header

                    ScrollViewReader { proxy in
                        ZStack(alignment: .bottomTrailing) {
                            ScrollView {
                                VStack(spacing: 20) {
                                    if app.chat.isEmpty { welcome }
                                    ForEach(app.chat) { msg in
                                        bubble(msg)
                                            .id(msg.id)
                                            .transition(.opacity.combined(with: .offset(y: 8)))
                                    }
                                }
                                .padding(.horizontal, LayoutMetrics.screenGutter)
                                .padding(.bottom, 12)
                            }
                            .simultaneousGesture(DragGesture(minimumDistance: 5).onChanged { _ in
                                followsLatestAnswer = false
                            })
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.9), value: app.chat.count)
                            .onChange(of: app.chat.count) {
                                guard followsLatestAnswer, let last = app.chat.last else { return }
                                withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.9)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: app.chatTypingMessageID) { _, typingID in
                                guard followsLatestAnswer, typingID == nil, let last = app.chat.last else { return }
                                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: app.chat.last?.text) { _, _ in
                                guard followsLatestAnswer, app.chatTypingMessageID != nil,
                                      let last = app.chat.last else { return }
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }

                            if !followsLatestAnswer, let last = app.chat.last {
                                Button {
                                    Haptics.tap()
                                    followsLatestAnswer = true
                                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                } label: {
                                    Image(systemName: "arrow.down")
                                        .scaledFont(size: 15, weight: .semibold)
                                        .foregroundStyle(p.onAccent)
                                        .frame(width: 42, height: 42)
                                        .background(Circle().fill(p.saffron))
                                        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                                }
                                .accessibilityLabel(app.language == .ne ? "नयाँ उत्तरमा जानुहोस्" : "Jump to latest answer")
                                .padding(14)
                            }
                        }
                    }

                    if !app.chat.isEmpty { followUpsRow }
                    inputBar
                }
                if showHistory { historyDrawer }
            }
            .navigationDestination(for: UUID.self) { id in
                MemberDetailView(memberID: id)
                    .environmentObject(app)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .statusBarFade()
        .onDisappear { voice.stopSpeaking() }
        .task {
            if let prompt = app.consumePendingPanditPrompt() {
                send(prompt)
            }
        }
        .sheet(item: $pendingAction) { action in
            AgentActionConfirmationSheet(action: action) { title, date in
                confirm(action, title: title, date: date)
            }
        }
        .sheet(isPresented: $showComparison) {
            CompatibilityPromptSheet(members: app.family) { first, second in
                showComparison = false
                send(app.language == .ne
                     ? "\(first.displayName(.ne)) र \(second.displayName(.ne))को कुण्डली मिलान गर्नुहोस्"
                     : "Compare \(first.name) and \(second.name) compatibility")
            }
        }
        .alert(app.t("chat.action.result"),
               isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button(app.t("common.done")) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button {
                Haptics.tap()
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { showHistory = true }
            } label: {
                Image(systemName: "sidebar.left")
                    .scaledFont(size: 19, weight: .light)
                    .foregroundStyle(p.inkSecondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel(app.t("chat.history"))

            Text(app.t("chat.title"))
                .scaledFont(size: 34, weight: .bold, design: .serif)
                .foregroundStyle(p.inkPrimary)
            Spacer()
            Button {
                Haptics.tap()
                app.newChatConversation()
            } label: {
                Image(systemName: "square.and.pencil")
                    .scaledFont(size: 18, weight: .light)
                    .foregroundStyle(p.inkSecondary)
                    .frame(width: 44, height: 48)
            }
            .accessibilityLabel(app.t("chat.newConversation"))
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .scaledFont(size: 19, weight: .light)
                    .foregroundStyle(p.inkSecondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel(app.t("common.close"))
        }
        .padding(.horizontal, LayoutMetrics.screenGutter)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text(welcomeText)
                    .scaledFont(size: 20, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .lineSpacing(4)
                Text(app.t("chat.welcome.hint"))
                    .scaledFont(size: 14)
                    .foregroundStyle(p.inkSecondary)
                    .lineSpacing(3)
            }
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 10) {
                    ForEach(PanditStarter.all) { starter in
                        PanditStarterCard(starter: starter) {
                            send(starter.prompt(language: app.language))
                        }
                        .frame(minHeight: 72)
                    }
                }
            }
            .frame(height: 236)
        }
        .padding(.top, 12)
    }

    private var welcomeText: String {
        guard let member = app.selfMember,
              !member.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return app.t("chat.welcome.generic")
        }
        let name = member.displayName(app.language).trimmingCharacters(in: .whitespacesAndNewlines)
        guard
              !name.isEmpty else { return app.t("chat.welcome.generic") }
        return String(format: app.t("chat.welcome"), name)
    }

    private func bubble(_ msg: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
                    if msg.text.isEmpty && app.chatTypingMessageID == msg.id {
                        TypingIndicator()
                            .padding(.vertical, 6)
                    } else if app.chatTypingMessageID == msg.id {
                        HStack(alignment: .bottom, spacing: 5) {
                            PanditRichText(text: msg.text)
                            Circle().fill(p.saffron.opacity(0.7)).frame(width: 5, height: 5)
                        }
                    } else {
                        PanditRichText(text: msg.text)
                    }
                }
                if !msg.isUser { Spacer(minLength: 56) }
            }
            if !msg.isUser, !msg.text.isEmpty, app.chatTypingMessageID != msg.id,
               let member = kundliMember(for: msg), let chart = member.kundali {
                VStack(alignment: .leading, spacing: 12) {
                    Hairline()
                    Text(app.language == .ne
                         ? "उत्तरमा प्रयोग गरिएको \(member.displayName(.ne))को कुण्डली"
                         : "Kundli used for \(member.name)'s answer")
                        .scaledFont(size: 13, weight: .semibold)
                        .foregroundStyle(p.inkSecondary)
                    KundaliChartView(chart: chart)
                        .frame(maxWidth: 280)
                    Button {
                        Haptics.tap()
                        openKundli(member.id)
                    } label: {
                        Label(app.t("chat.action.seeKundli"), systemImage: "arrow.up.right")
                            .scaledFont(size: 14, weight: .semibold)
                            .foregroundStyle(p.sindoor)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(SpringPressStyle())
                }
                .accessibilityLabel(app.t("chat.action.seeKundli"))
            }
            if !msg.isUser, !msg.text.isEmpty, app.chatTypingMessageID != msg.id,
               let actions = msg.actions, !actions.isEmpty {
                actionRow(actions, message: msg)
            }
        }
    }

    private func kundliMember(for message: ChatMessage) -> FamilyMember? {
        guard let id = message.actions?.first(where: { $0.kind == .seeKundli })?.memberID else { return nil }
        return app.family.first(where: { $0.id == id && $0.kundali != nil })
    }

    private func actionRow(_ actions: [PanditAction], message: ChatMessage) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    if action.kind == .share {
                        ShareLink(item: PanditTextFormatter.plain(message.text)) {
                            actionLabel(action.kind)
                        }
                    } else {
                        Button { handle(action, message: message) } label: { actionLabel(action.kind) }
                    }
                }
            }
        }
    }

    private func actionLabel(_ kind: PanditActionKind) -> some View {
        Label(app.t("chat.action.\(kind.rawValue)"), systemImage: actionIcon(kind))
            .scaledFont(size: 13, weight: .medium)
            .foregroundStyle(p.sindoor)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(minHeight: 44)
            .background(Capsule().fill(p.bgElevated))
    }

    private func actionIcon(_ kind: PanditActionKind) -> String {
        switch kind {
        case .openPatro: return "calendar"
        case .addToPatro: return "calendar.badge.plus"
        case .remind: return "bell"
        case .compare: return "person.2"
        case .listen: return "speaker.wave.2"
        case .seeKundli: return "square.grid.3x3"
        case .share: return "square.and.arrow.up"
        }
    }

    private func handle(_ action: PanditAction, message: ChatMessage) {
        Haptics.tap()
        switch action.kind {
        case .addToPatro, .remind:
            pendingAction = action
        case .openPatro:
            leaveChat { app.open(.patro) }
        case .seeKundli:
            openKundli(action.memberID)
        case .compare:
            guard app.family.count >= 2 else {
                notice = app.t("chat.compare.needTwo")
                return
            }
            showComparison = true
        case .listen:
            voice.speakNow(PanditTextFormatter.plain(message.text), lang: app.language)
        case .share:
            break
        }
    }

    private func openKundli(_ memberID: UUID?) {
        guard let memberID,
              app.family.contains(where: { $0.id == memberID && $0.kundali != nil }) else { return }
        kundliPath = [memberID]
    }

    private func confirm(_ action: PanditAction, title: String, date: Date) {
        pendingAction = nil
        if action.kind == .addToPatro {
            notice = app.t(app.addPanditEvent(title: title, date: date)
                           ? "chat.action.added" : "chat.action.duplicate")
        } else {
            Task {
                do {
                    try await app.schedulePanditReminder(title: title, date: date)
                    notice = app.t("chat.action.reminderSet")
                } catch {
                    notice = app.t("chat.action.reminderFailed")
                }
            }
        }
    }

    private func leaveChat(action: @escaping @MainActor () -> Void) {
        dismiss()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            action()
        }
    }

    private var followUpsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(followUpPrompts, id: \.self) { prompt in
                    Button {
                        Haptics.tap()
                        send(prompt)
                    } label: {
                        Text(prompt)
                            .scaledFont(size: 13)
                            .foregroundStyle(p.sindoor)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Capsule().fill(p.bgElevated))
                            .frame(minHeight: 44)
                    }
                }
            }
            .padding(.horizontal, LayoutMetrics.screenGutter)
        }
        .padding(.vertical, 8)
    }

    private var followUpPrompts: [String] {
        let base = followUpKeys.map(app.t)
        guard let answer = app.chat.last(where: { !$0.isUser })?.text,
              let normalized = finalQuestion(in: answer) else { return base }
        return [normalized] + Array(base.filter { $0 != normalized }.prefix(2))
    }

    private func finalQuestion(in answer: String) -> String? {
        guard let end = answer.lastIndex(of: "?") else { return nil }
        let before = answer[..<end]
        let start = before.lastIndex(where: { $0 == "." || $0 == "!" || $0 == "\n" })
            .map { answer.index(after: $0) } ?? answer.startIndex
        let question = answer[start...end].trimmingCharacters(in: .whitespacesAndNewlines)
        return question.count <= 120 ? question : nil
    }

    private var followUpKeys: [String] {
        let question = app.chat.last(where: \.isUser)?.text.lowercased() ?? ""
        if ["muhur", "sait", "साइत", "मुहूर्त", "date", "time"].contains(where: question.contains) {
            if MuhurtaPurpose.detect(in: question) == .general {
                return ["chat.followup.pujaTime", "chat.followup.travelTime", "chat.followup.homeTime"]
            }
            return ["chat.followup.anotherDate", "chat.followup.howChosen"]
        }
        if ["family", "compat", "compare", "परिवार", "तुलना"].contains(where: question.contains) {
            return ["chat.followup.compare", "chat.followup.why"]
        }
        if ["vrat", "puja", "festival", "व्रत", "पूजा", "चाड"].contains(where: question.contains) {
            return ["chat.followup.vrat", "chat.followup.mantra"]
        }
        if ["kundli", "dasha", "today", "कुण्डली", "दशा", "आज"].contains(where: question.contains) {
            return ["chat.followup.dasha", "chat.followup.next"]
        }
        return ["chat.followup.why", "chat.followup.next"]
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
                    .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: voice.isListening)
            }
            .disabled(voice.unavailable)
            .opacity(voice.unavailable ? 0.35 : 1)
            .accessibilityLabel(app.t(voice.isListening ? "chat.stopListening" : "chat.askByVoice"))

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
                .disabled(isSending)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel(app.t("common.send"))
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: draft.isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func send(_ text: String) {
        guard !isSending else { return }
        followsLatestAnswer = true
        isSending = true
        Task {
            let reply = await app.sendChat(text)
            isSending = false
            guard let reply else { return }
            voice.speak(reply.text, lang: app.language)
        }
    }

    private var historyDrawer: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { showHistory = false }
                }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(app.t("chat.history"))
                        .scaledFont(size: 24, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Spacer()
                    Button {
                        Haptics.tap()
                        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { showHistory = false }
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 16, weight: .medium)
                            .foregroundStyle(p.inkSecondary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(app.t("common.close"))
                }
                Button {
                    Haptics.tap()
                    app.newChatConversation()
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { showHistory = false }
                } label: {
                    Label(app.t("chat.newConversation"), systemImage: "square.and.pencil")
                        .scaledFont(size: 15, weight: .semibold)
                        .foregroundStyle(p.onAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 48)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(p.saffron))
                }
                .buttonStyle(SpringPressStyle())
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(app.chatConversations) { conversation in
                            HStack(spacing: 8) {
                                Button {
                                    Haptics.tap()
                                    app.selectChatConversation(conversation.id)
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { showHistory = false }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(conversation.title)
                                            .scaledFont(size: 15, weight: conversation.id == app.selectedChatConversationID ? .semibold : .regular)
                                            .foregroundStyle(p.inkPrimary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        Text(conversation.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                            .scaledFont(size: 13)
                                            .foregroundStyle(p.inkSecondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                }
                                Button {
                                    Haptics.tap()
                                    app.deleteChatConversation(conversation.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .scaledFont(size: 14)
                                        .foregroundStyle(p.inkSecondary)
                                        .frame(width: 44, height: 44)
                                }
                                .accessibilityLabel(app.t("chat.deleteConversation"))
                            }
                            Hairline()
                        }
                        if app.chatConversations.isEmpty {
                            Text(app.t("chat.noHistory"))
                                .scaledFont(size: 15)
                                .foregroundStyle(p.inkSecondary)
                                .padding(.top, 8)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .frame(width: 326)
            .frame(maxHeight: .infinity)
            .background(p.bgElevated)
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
    }
}

/// The model may use lightweight Markdown for emphasis. Convert it before
/// SwiftUI renders the answer so users never see implementation markers such
/// as `**text**`. Newlines are preserved for readable, structured replies.
private struct PanditRichText: View {
    @Environment(\.palette) private var p
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(PanditMarkdown.blocks(text).enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading(let value, let level):
                    Text(PanditTextFormatter.attributed(value))
                        .scaledFont(size: level == 1 ? 24 : 20, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .padding(.top, level == 1 ? 4 : 2)
                case .paragraph(let value):
                    Text(PanditTextFormatter.attributed(value))
                        .scaledFont(size: 16, design: .serif)
                        .foregroundStyle(p.inkPrimary.opacity(0.92))
                        .lineSpacing(6)
                case .list(let items, let numbered):
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .firstTextBaseline, spacing: 9) {
                                Text(numbered ? "\(index + 1)." : "•")
                                    .scaledFont(size: 15, weight: .bold)
                                    .foregroundStyle(p.saffron)
                                Text(PanditTextFormatter.attributed(item))
                                    .scaledFont(size: 16, design: .serif)
                                    .foregroundStyle(p.inkPrimary.opacity(0.92))
                                    .lineSpacing(5)
                            }
                        }
                    }
                case .table(let rows):
                    ScrollView(.horizontal, showsIndicators: false) {
                        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                                GridRow {
                                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                                        Text(PanditTextFormatter.attributed(cell))
                                            .scaledFont(size: 14, weight: rowIndex == 0 ? .semibold : .regular)
                                            .foregroundStyle(p.inkPrimary)
                                            .padding(.horizontal, 12).padding(.vertical, 10)
                                            .frame(minWidth: 110, maxWidth: 190, alignment: .leading)
                                    }
                                }
                                .background(rowIndex == 0 ? p.marigold.opacity(0.18) : p.bgElevated)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(p.templeGold.opacity(0.25)))
                    }
                case .divider:
                    Hairline()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }
}

private enum PanditMarkdown {
    enum Block { case heading(String, Int), paragraph(String), list([String], Bool), table([[String]]), divider }

    static func blocks(_ text: String) -> [Block] {
        let lines = text.components(separatedBy: .newlines)
        var result: [Block] = [], paragraph: [String] = []
        var index = 0
        func flushParagraph() {
            let value = paragraph.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty { result.append(.paragraph(value)) }
            paragraph = []
        }
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { flushParagraph(); index += 1; continue }
            if line == "---" || line == "***" { flushParagraph(); result.append(.divider); index += 1; continue }
            if line.hasPrefix("### ") { flushParagraph(); result.append(.heading(String(line.dropFirst(4)), 3)); index += 1; continue }
            if line.hasPrefix("## ") { flushParagraph(); result.append(.heading(String(line.dropFirst(3)), 2)); index += 1; continue }
            if line.hasPrefix("# ") { flushParagraph(); result.append(.heading(String(line.dropFirst(2)), 1)); index += 1; continue }
            if line.hasPrefix("**"), line.hasSuffix("**"), line.count > 4 {
                flushParagraph(); result.append(.heading(String(line.dropFirst(2).dropLast(2)), 2)); index += 1; continue
            }
            if line.contains("|"), index + 1 < lines.count, isTableDivider(lines[index + 1]) {
                flushParagraph()
                var rows = [tableCells(line)]
                index += 2
                while index < lines.count, lines[index].contains("|"), !lines[index].trimmingCharacters(in: .whitespaces).isEmpty {
                    rows.append(tableCells(lines[index])); index += 1
                }
                result.append(.table(rows)); continue
            }
            if isBullet(line) {
                flushParagraph(); var items: [String] = []
                while index < lines.count, isBullet(lines[index].trimmingCharacters(in: .whitespaces)) {
                    items.append(String(lines[index].trimmingCharacters(in: .whitespaces).dropFirst(2))); index += 1
                }
                result.append(.list(items, false)); continue
            }
            if numberedItem(line) != nil {
                flushParagraph(); var items: [String] = []
                while index < lines.count, let item = numberedItem(lines[index].trimmingCharacters(in: .whitespaces)) {
                    items.append(item); index += 1
                }
                result.append(.list(items, true)); continue
            }
            paragraph.append(line); index += 1
        }
        flushParagraph()
        return result
    }

    private static func isBullet(_ line: String) -> Bool { line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("• ") }
    private static func numberedItem(_ line: String) -> String? {
        guard let dot = line.firstIndex(of: "."), dot < line.index(line.startIndex, offsetBy: min(3, line.count)),
              line[..<dot].allSatisfy(\.isNumber) else { return nil }
        return String(line[line.index(after: dot)...]).trimmingCharacters(in: .whitespaces)
    }
    private static func isTableDivider(_ line: String) -> Bool {
        let clean = line.replacingOccurrences(of: "|", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "")
        return clean.trimmingCharacters(in: .whitespaces).isEmpty && line.contains("-")
    }
    private static func tableCells(_ line: String) -> [String] {
        line.trimmingCharacters(in: CharacterSet(charactersIn: "| ")).split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

enum PanditTextFormatter {
    static func attributed(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        )
        var formatted = (try? AttributedString(markdown: text, options: options))
            ?? AttributedString(text)

        // Markdown deliberately preserves unmatched markers. Remote answers can
        // contain a valid bold heading followed by a stray opening marker, so
        // remove only tokens that remain visible after the normal parser runs.
        while let marker = formatted.range(of: "**") {
            formatted.removeSubrange(marker)
        }
        return formatted
    }

    static func plain(_ text: String) -> String {
        String(attributed(text).characters)
    }
}

private struct AgentActionConfirmationSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let action: PanditAction
    let onConfirm: (String, Date) -> Void
    @State private var title: String
    @State private var date: Date

    init(action: PanditAction, onConfirm: @escaping (String, Date) -> Void) {
        self.action = action
        self.onConfirm = onConfirm
        _title = State(initialValue: action.title ?? "")
        _date = State(initialValue: action.date ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(app.t("chat.action.eventTitle"), text: $title)
                DatePicker(app.t("chat.action.date"), selection: $date, displayedComponents: [.date])
            }
            .scrollContentBackground(.hidden)
            .background(p.bgCanvas)
            .navigationTitle(app.t("chat.action.details"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(app.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(app.t("common.done")) {
                        onConfirm(title, date)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if title.isEmpty {
                title = app.t(action.kind == .remind
                              ? "chat.action.defaultReminder" : "chat.action.defaultEvent")
            }
        }
        .presentationDetents([.medium])
    }
}

private struct CompatibilityPromptSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let members: [FamilyMember]
    let onCompare: (FamilyMember, FamilyMember) -> Void
    @State private var firstID: UUID
    @State private var secondID: UUID

    init(members: [FamilyMember], onCompare: @escaping (FamilyMember, FamilyMember) -> Void) {
        self.members = members
        self.onCompare = onCompare
        _firstID = State(initialValue: members.first?.id ?? UUID())
        _secondID = State(initialValue: members.dropFirst().first?.id ?? UUID())
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker(app.t("chat.compare.first"), selection: $firstID) {
                    ForEach(members) { Text($0.displayName(app.language)).tag($0.id) }
                }
                Picker(app.t("chat.compare.second"), selection: $secondID) {
                    ForEach(members) { Text($0.displayName(app.language)).tag($0.id) }
                }
            }
            .scrollContentBackground(.hidden)
            .background(p.bgCanvas)
            .navigationTitle(app.t("chat.compare.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(app.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(app.t("chat.compare.go")) {
                        guard let first = members.first(where: { $0.id == firstID }),
                              let second = members.first(where: { $0.id == secondID }) else { return }
                        onCompare(first, second)
                    }
                    .disabled(firstID == secondID)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct TypingIndicator: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(p.inkSecondary.opacity(index == phase ? 0.9 : 0.35))
                    .frame(width: 6, height: 6)
                    .scaleEffect(index == phase ? 1.15 : 1)
            }
        }
        .accessibilityLabel(app.t("chat.typing"))
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 260_000_000)
                phase = (phase + 1) % 3
            }
        }
    }
}
