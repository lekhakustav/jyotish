import SwiftUI

// The paged birth flow — one decision per screen (docs/01 craft rule 1),
// ending in the kundali ceremony + reveal (rule 2). Used for the user's own
// profile (RootView, Settings) and, with a relation step, for family members.

enum BirthFlowMode: Equatable {
    case selfProfile
    case familyMember
}

/// Thin wrapper kept for RootView / Settings call sites.
struct ProfileSetupView: View {
    let editing: FamilyMember?
    var body: some View {
        BirthFlowView(mode: .selfProfile, prefill: editing)
    }
}

struct BirthFlowView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let mode: BirthFlowMode
    var prefill: FamilyMember? = nil

    private enum Step: Int, CaseIterable {
        case relation, name, gender, dob, tob, place, ceremony
    }

    @State private var step: Step
    @State private var goingForward = true

    @State private var relation: Relation = .son
    @State private var name = ""
    @State private var gender: Gender = .female
    @State private var dob = Calendar.nepali.date(from: DateComponents(year: 1975, month: 1, day: 1)) ?? Date()
    @State private var timeKnown = true
    @State private var tob = Calendar.nepali.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
    @State private var place = BirthPlace.kathmandu

    @State private var revealed: Kundali?
    @FocusState private var nameFocused: Bool

    init(mode: BirthFlowMode, prefill: FamilyMember? = nil) {
        self.mode = mode
        self.prefill = prefill
        _step = State(initialValue: mode == .familyMember ? .relation : .name)
    }

    private var steps: [Step] {
        mode == .familyMember
            ? [.relation, .name, .gender, .dob, .tob, .place]
            : [.name, .gender, .dob, .tob, .place]
    }
    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()

            if step == .ceremony {
                ceremony
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    topBar
                    stepContent
                        .id(step)
                        .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)))
                    Spacer(minLength: 0)
                    PrimaryButton(title: isLast ? app.t("profile.compute") : app.t("flow.continue"),
                                  icon: isLast ? "sparkles" : nil) { advance() }
                        .disabled(!stepValid)
                        .opacity(stepValid ? 1 : 0.45)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: step)
        .onAppear { load() }
    }

    // ── Chrome ───────────────────────────────────────────────────────────────
    private var isLast: Bool { step == steps.last }

    private var topBar: some View {
        ZStack {
            HStack {
                if let idx = steps.firstIndex(of: step), idx > 0 {
                    Button {
                        Haptics.tap()
                        goingForward = false
                        step = steps[idx - 1]
                    } label: {
                        Image(systemName: "chevron.left")
                            .scaledFont(size: 17, weight: .medium)
                            .foregroundStyle(p.inkSecondary)
                            .frame(width: 48, height: 48)
                    }
                    .accessibilityLabel(app.t("common.back"))
                }
                Spacer()
                // Presented as a sheet when adding family — needs explicit dismiss.
                if mode == .familyMember { SheetCloseButton() }
            }
            HStack(spacing: 8) {
                ForEach(steps, id: \.rawValue) { s in
                    Image(systemName: "diamond.fill")
                        .scaledFont(size: 6)
                        .foregroundStyle(stepIndex(s) <= stepIndex(step)
                                         ? p.saffron : p.templeGold.opacity(0.3))
                }
            }
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    private func stepIndex(_ s: Step) -> Int { steps.firstIndex(of: s) ?? 0 }

    private func question(_ devanagari: String, _ title: String, _ subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(devanagari)
                .scaledFont(size: 15, design: .serif)
                .foregroundStyle(p.templeGold)
                .accessibilityHidden(true)
            Text(title)
                .scaledFont(size: 30, weight: .bold, design: .serif)
                .foregroundStyle(p.inkPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .scaledFont(size: 15)
                    .foregroundStyle(p.inkSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ── Steps ────────────────────────────────────────────────────────────────
    @ViewBuilder private var stepContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            switch step {
            case .relation:
                question("नाता", app.t("flow.relation.q"))
                relationGrid
            case .name:
                question("नाम", app.t(mode == .familyMember ? "flow.name.q.family" : "flow.name.q"),
                          mode == .selfProfile ? app.t("flow.name.sub") : nil)
                nameField
            case .gender:
                question("लिङ्ग", app.t("flow.gender.q"))
                genderCards
            case .dob:
                question("जन्म मिति", app.t("flow.dob.q"), app.t("flow.dob.sub"))
                DatePicker("", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .environment(\.calendar, Calendar.nepali)
            case .tob:
                question("जन्म समय", app.t("flow.tob.q"), app.t("flow.tob.sub"))
                VStack(spacing: 16) {
                    if timeKnown {
                        DatePicker("", selection: $tob, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                    }
                    Toggle(app.t("profile.timeUnknown"), isOn: Binding(
                        get: { !timeKnown }, set: { timeKnown = !$0 }))
                        .scaledFont(size: 15)
                        .tint(p.saffron)
                        .foregroundStyle(p.inkSecondary)
                        .padding(.horizontal, 4)
                }
            case .place:
                question("जन्म स्थान", app.t("flow.place.q"), app.t("flow.place.sub"))
                placeList
            case .ceremony:
                EmptyView()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    private var nameField: some View {
        TextField(app.t("profile.name"), text: $name)
            .scaledFont(size: 26, weight: .medium, design: .serif)
            .foregroundStyle(p.inkPrimary)
            .focused($nameFocused)
            .submitLabel(.continue)
            .onSubmit { if stepValid { advance() } }
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) {
                Rectangle().fill(p.templeGold.opacity(nameFocused ? 0.7 : 0.3)).frame(height: 1)
            }
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { nameFocused = true } }
    }

    private var genderCards: some View {
        VStack(spacing: 0) {
            genderCard(.female, label: app.t("profile.female"))
            Hairline()
            genderCard(.male, label: app.t("profile.male"))
            Hairline()
            genderCard(.other, label: app.t("profile.other"))
        }
    }

    private func genderCard(_ g: Gender, label: String) -> some View {
        Button {
            Haptics.tap()
            gender = g
        } label: {
            HStack {
                Text(label)
                    .scaledFont(size: 19, weight: gender == g ? .semibold : .regular, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Spacer()
                Image(systemName: gender == g ? "checkmark.circle.fill" : "circle")
                    .scaledFont(size: 20, weight: .light)
                    .foregroundStyle(gender == g ? p.saffron : p.templeGold.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .frame(height: 58)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(gender == g ? p.marigold.opacity(0.14) : .clear))
        }
    }

    private var relationSections: [(titleKey: String, relations: [Relation])] {
        [
            ("flow.relation.immediate", [.husband, .wife, .son, .daughter, .father, .mother,
                                          .brother, .sister, .grandfather, .grandmother,
                                          .grandson, .granddaughter]),
            ("flow.relation.paternal", [.kaka, .kaki, .thuloBaa, .thuloAma, .phupu, .phupaju]),
            ("flow.relation.maternal", [.mama, .maiju, .saniAma, .thuliAma]),
            ("flow.relation.inlaws", [.sasura, .sasu, .jethaju, .devar, .jethani, .devrani,
                                       .nanad, .saala, .saali, .bhinaju, .bhauju, .buhari, .jwaai]),
            ("flow.relation.extended", [.bhatija, .bhatiji, .bhanja, .bhanji, .cousin]),
        ]
    }

    private var relationGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(relationSections, id: \.titleKey) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t(section.titleKey))
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                            ForEach(section.relations) { r in
                                Button { Haptics.tap(); relation = r } label: {
                                    Text(ne ? r.labelNE : r.labelEN)
                                        .scaledFont(size: 15, weight: relation == r ? .semibold : .regular, design: .serif)
                                        .foregroundStyle(relation == r ? p.sindoor : p.inkPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.75)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 6)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(relation == r ? p.marigold.opacity(0.16) : .clear))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .scrollIndicators(.hidden)
    }

    private var placeList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(BirthPlace.presets, id: \.self) { pl in
                    Button { Haptics.tap(); place = pl } label: {
                        HStack {
                            Text(ne ? pl.nameNE : pl.name)
                                .scaledFont(size: 17, weight: place == pl ? .semibold : .regular, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Spacer()
                            if place == pl {
                                Image(systemName: "checkmark")
                                    .scaledFont(size: 14, weight: .semibold)
                                    .foregroundStyle(p.saffron)
                            }
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 52)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(place == pl ? p.marigold.opacity(0.14) : .clear))
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    // ── Ceremony & reveal ────────────────────────────────────────────────────
    private var ceremony: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                MandalaView(rotates: true).frame(width: 260, height: 260)
                if let k = revealed {
                    RashiSeal(rashi: k.moonRashi, size: 92)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                } else {
                    RashiIcon(rashi: .mesh, size: 54)
                        .opacity(0.55)
                }
            }
            if let k = revealed {
                VStack(spacing: 8) {
                    Text(ne ? k.moonRashi.nameNE : k.moonRashi.shortEN)
                        .scaledFont(size: 34, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Text("\(ne ? k.moonNakshatra.nameNE : k.moonNakshatra.nameEN) · \(app.t("family.lagna")) \(ne ? k.lagna.nameNE : k.lagna.shortEN)")
                        .scaledFont(size: 16)
                        .foregroundStyle(p.inkSecondary)
                    Text(app.t("blessing.saved"))
                        .scaledFont(size: 18, design: .serif)
                        .foregroundStyle(p.templeGold)
                        .padding(.top, 6)
                }
                .transition(.opacity.combined(with: .offset(y: 10)))
            } else {
                VStack(spacing: 6) {
                    Text(app.t("flow.drawing"))
                        .scaledFont(size: 18, design: .serif)
                        .italic()
                        .foregroundStyle(p.inkSecondary)
                    Text(app.t("flow.drawing.sub"))
                        .scaledFont(size: 14)
                        .foregroundStyle(p.inkSecondary.opacity(0.7))
                }
            }
            Spacer()
            if revealed != nil {
                PrimaryButton(title: app.t("common.done"), icon: "hands.and.sparkles.fill") { finish() }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.8), value: revealed)
    }

    // ── Logic ────────────────────────────────────────────────────────────────
    private var stepValid: Bool {
        switch step {
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private func advance() {
        guard let idx = steps.firstIndex(of: step) else { return }
        goingForward = true
        if idx < steps.count - 1 {
            step = steps[idx + 1]
        } else {
            nameFocused = false
            step = .ceremony
            // Let the mandala breathe before the reveal — ceremony, not a spinner.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { revealed = Kundali.compute(from: birthData) }
                Haptics.success()
            }
        }
    }

    private var birthData: BirthData {
        let cal = Calendar.nepali
        let d = cal.dateComponents([.year, .month, .day], from: dob)
        let t = cal.dateComponents([.hour, .minute], from: tob)
        return BirthData(year: d.year ?? 1975, month: d.month ?? 1, day: d.day ?? 1,
                         hour: timeKnown ? (t.hour ?? 6) : 6,
                         minute: timeKnown ? (t.minute ?? 0) : 0,
                         timeKnown: timeKnown, place: place)
    }

    private func finish() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        switch mode {
        case .selfProfile:
            app.saveSelf(name: trimmed, gender: gender, birth: birthData)
        case .familyMember:
            app.addMember(FamilyMember(name: trimmed, gender: gender,
                                       relation: relation, birth: birthData))
        }
        dismiss()
    }

    private func load() {
        let existing = prefill ?? (mode == .selfProfile ? app.selfMember : nil)
        guard let m = existing else {
            // No family member yet (fresh sign-up) — Apple hands us the real
            // name on first authorization, so start the name field with it.
            if mode == .selfProfile, let accountName = app.account?.displayName, !accountName.isEmpty {
                name = accountName
            }
            return
        }
        name = m.name
        gender = m.gender
        relation = m.relation
        if let b = m.birth {
            var c = DateComponents(); c.year = b.year; c.month = b.month; c.day = b.day
            dob = Calendar.nepali.date(from: c) ?? dob
            var t = DateComponents(); t.hour = b.hour; t.minute = b.minute
            tob = Calendar.nepali.date(from: t) ?? tob
            timeKnown = b.timeKnown
            place = b.place
        }
    }
}
