import SwiftUI

// Extreme-minimal home: no cards, no dividers between sections — typography,
// whitespace and one hairline carry the whole hierarchy (docs/01 §v3).
struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showSettings = ProcessInfo.processInfo.arguments.contains("-settings")
    @State private var showTemple = false

    private var ne: Bool { app.language == .ne }
    @State private var temple = Temple.ofToday()

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    header.fadeRise()
                    rashifalBlock.fadeRise(delay: 0.04)
                    panditDiscovery.fadeRise(delay: 0.08)
                    VStack(alignment: .leading, spacing: 18) {
                        tithiHero
                        templeOfDay
                    }
                    .fadeRise(delay: 0.12)
                    if hasRelatives { familyRow.fadeRise(delay: 0.2) }
                    if hasUpcoming { upcoming.fadeRise(delay: 0.25) }
                }
                .padding(.horizontal, LayoutMetrics.screenGutter)
                .padding(.bottom, 24)
            }
        }
        .statusBarFade()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showTemple) { TempleDetailSheet(temple: temple) }
        .task { temple = await Temple.fetchToday() }
    }

    /// Three high-interest questions are visible at once. More specific entry
    /// points remain vertically discoverable, while the generic composer stays
    /// fixed below the scrolling template area.
    private var panditDiscovery: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(app.t("home.panditAI"))
                .scaledFont(size: 19, weight: .semibold, design: .serif)
                .foregroundStyle(p.inkPrimary)

            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 6) {
                    ForEach(PanditStarter.all) { starter in
                        PanditStarterCard(starter: starter, quiet: true) {
                            app.openPandit(prompt: starter.prompt(language: app.language))
                        }
                        .frame(minHeight: 58)
                    }
                }
            }
            .frame(height: 186)

            Button {
                Haptics.tap()
                app.openPandit()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .scaledFont(size: 18, weight: .medium)
                    Text(app.t("home.panditAskAnything"))
                        .scaledFont(size: 16, weight: .semibold, design: .serif)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .scaledFont(size: 13, weight: .semibold)
                }
                .foregroundStyle(p.onAccent)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(p.saffron))
            }
            .buttonStyle(SpringPressStyle())
            .accessibilityLabel(app.t("home.askPandit"))
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(app.t(greetingKey))
                    .scaledFont(size: 16, weight: .medium, design: .serif)
                    .foregroundStyle(p.templeGold)
                if let name = app.selfMember?.name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(name)
                        .scaledFont(size: 26, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .scaledFont(size: 19, weight: .light)
                    .foregroundStyle(p.inkSecondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel(app.t("settings.title"))
        }
        .padding(.top, 8)
    }

    private var greetingKey: String {
        let hour = Calendar.nepali.component(.hour, from: Date())
        if hour < 12 { return "greet.morning" }
        if hour < 18 { return "greet.afternoon" }
        if hour < 22 { return "greet.evening" }
        return "greet.night"
    }

    /// The BS date, now a quiet secondary line — the horoscope is the hero
    /// people open the app for (docs ask). Whole block still opens the Patro.
    private var tithiHero: some View {
        let bs = BikramSambat.today()
        let pan = Panchanga.forDay(Date())
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(app.digits(bs.day)) \(bs.monthName(ne: ne))")
                    .scaledFont(size: 20, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Text("·")
                    .foregroundStyle(p.inkSecondary)
                Text("\(pan.tithiName(ne: ne)) · \(pan.pakshaName(ne: ne))")
                    .scaledFont(size: 14, weight: .medium, design: .serif)
                    .foregroundStyle(p.inkSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Button {
                Haptics.tap()
                app.open(.patro)
            } label: {
                HStack(spacing: 6) {
                    Text(app.t("home.openPatro"))
                        .scaledFont(size: 15, weight: .semibold, design: .serif)
                    Image(systemName: "chevron.right")
                        .scaledFont(size: 13, weight: .semibold)
                }
                .foregroundStyle(p.saffron)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(SpringPressStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Personal rashifal is the reason most people open the app, so it leads
    /// the page: rashi mark, a hook line that pulls you into the full reading,
    /// then the dasha in one quiet line.
    private var rashifalBlock: some View {
        Group {
            if let k = app.selfMember?.kundali {
                let r = RashifalEngine.generate(rashi: k.moonRashi, period: .daily, date: Date(), lang: app.language)
                Button { app.open(.rashifal) } label: {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            RashiIcon(rashi: k.moonRashi, size: 52)
                            Text(ne ? k.moonRashi.nameNE : k.moonRashi.shortEN)
                                .scaledFont(size: 22, weight: .semibold, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Spacer()
                            YantraScore(score: r.scores.values.reduce(0, +) / max(1, r.scores.count))
                        }
                        Text(hookLine(from: r.text))
                            .scaledFont(size: 18, weight: .medium, design: .serif)
                            .foregroundStyle(p.inkPrimary.opacity(0.92))
                            .lineSpacing(5)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 4) {
                            Text(app.t("common.readMore"))
                            Image(systemName: "chevron.right")
                        }
                        .scaledFont(size: 15, weight: .semibold)
                        .foregroundStyle(p.sindoor)
                        if let cur = Vimshottari.current(for: k, at: Ephemeris.julianDay(Date())) {
                            Text("\(app.t("home.mahadasha")) \(ne ? cur.maha.lord.nameNE : cur.maha.lord.nameEN) · \(app.t("home.antardasha")) \(ne ? cur.antar.lord.nameNE : cur.antar.lord.nameEN)")
                                .scaledFont(size: 13)
                                .foregroundStyle(p.inkSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(SpringPressStyle())
            }
        }
    }

    /// The opening sentence of the reading, alone, reads as a hook (docs ask
    /// for a first line that "makes people want to tap in to learn more").
    private func hookLine(from text: String) -> String {
        let terminator: Character = ne ? "।" : "."
        if let idx = text.firstIndex(of: terminator) {
            return String(text[...idx])
        }
        return text
    }

    /// A single well-known temple, rotating daily — tapping opens a short
    /// devotional detail page.
    private var templeOfDay: some View {
        Button {
            Haptics.tap()
            showTemple = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if let url = temple.imageURL {
                    GeometryReader { proxy in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Rectangle().fill(p.bgSunken)
                            }
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .background(p.bgSunken)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                Text(temple.selectionReason(ne: ne))
                    .scaledFont(size: 14, weight: .medium, design: .serif)
                    .foregroundStyle(p.templeGold)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                Text(ne ? temple.nameNE : temple.nameEN)
                    .scaledFont(size: 21, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Text(ne ? temple.blurbNE : temple.blurbEN)
                    .scaledFont(size: 14, design: .serif)
                    .foregroundStyle(p.inkSecondary)
                    .lineSpacing(3)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SpringPressStyle())
    }

    private var familyRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(app.family.filter { $0.relation != .selfMember }) { m in
                    Button { app.open(.family) } label: {
                        VStack(spacing: 5) {
                            if let k = m.kundali {
                                RashiIcon(rashi: k.moonRashi, size: 50)
                            } else {
                                Circle().strokeBorder(p.templeGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "person").foregroundStyle(p.inkSecondary))
                            }
                            Text(m.name)
                                .scaledFont(size: 13)
                                .foregroundStyle(p.inkSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 62)
                    }
                    .buttonStyle(SpringPressStyle())
                    .accessibilityLabel(m.name)
                }
            }
        }
        .padding(.horizontal, -24)
        .contentMargins(.horizontal, 24, for: .scrollContent)
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel(text: app.t("home.upcoming"))
            let items = Array(app.upcomingEvents().prefix(3))
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.event.id) { i, item in
                    Button { app.open(.patro) } label: {
                        HStack(spacing: 14) {
                            Text("\(app.digits(item.bs.day)) \(item.bs.monthName(ne: ne))")
                                .scaledFont(size: 15, weight: .semibold, design: .serif)
                                .foregroundStyle(p.sindoor)
                                .frame(width: 96, alignment: .leading)
                            Text(item.event.title)
                                .scaledFont(size: 16, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(SpringPressStyle())
                    if i < items.count - 1 { Hairline() }
                }
            }
        }
    }

    private var hasRelatives: Bool {
        app.family.contains { $0.relation != .selfMember }
    }

    private var hasUpcoming: Bool {
        !app.upcomingEvents().isEmpty
    }
}

/// Placeholder devotional detail page for the temple-of-the-day tap-through.
private struct TempleDetailSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    let temple: Temple
    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 18)
                if let url = temple.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fit)
                        default:
                            MandalaView().padding(30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 300)
                    .background(p.bgSunken)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                } else {
                    MandalaView().frame(width: 120, height: 120)
                }
                Text(ne ? temple.nameNE : temple.nameEN)
                    .scaledFont(size: 26, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .multilineTextAlignment(.center)
                Text(ne ? temple.blurbNE : temple.blurbEN)
                    .scaledFont(size: 17, design: .serif)
                    .foregroundStyle(p.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                Spacer(minLength: 24)
                }
                .padding(.horizontal, LayoutMetrics.sheetGutter)
                .padding(.top, 44)
                .padding(.bottom, 30)
            }
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDetents([.large])
    }
}
