import SwiftUI

// Extreme-minimal home: no cards, no dividers between sections — typography,
// whitespace and one hairline carry the whole hierarchy (docs/01 §v3).
struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showSettings = false

    private var ne: Bool { app.language == .ne }
    private var greetingKey: String {
        let h = Calendar.nepali.component(.hour, from: Date())
        if h < 12 { return "greet.morning" }
        if h < 17 { return "greet.afternoon" }
        return "greet.evening"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                p.bgCanvas.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        header.fadeRise()
                        tithiHero.fadeRise(delay: 0.05)
                        rashifalBlock.fadeRise(delay: 0.1)
                        familyRow.fadeRise(delay: 0.15)
                        aartiRow.fadeRise(delay: 0.2)
                        upcoming.fadeRise(delay: 0.25)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 96)
                }
            }
            .statusBarFade()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            DiyaFlame(size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(app.t(greetingKey))
                    .scaledFont(size: 14, design: .serif)
                    .foregroundStyle(p.templeGold)
                Text(app.selfMember?.name ?? app.t("common.you"))
                    .scaledFont(size: 28, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
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

    /// The BS date as pure typography — the whole block opens the Patro.
    private var tithiHero: some View {
        let bs = BikramSambat.today()
        let pan = Panchanga.forDay(Date())
        return Button {
            app.selectedTab = 2
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(app.digits(bs.day)) \(bs.monthName(ne: ne))")
                        .scaledFont(size: 44, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Text(app.digits(bs.year))
                        .scaledFont(size: 22, design: .serif)
                        .foregroundStyle(p.inkSecondary)
                }
                Text("\(pan.tithiName(ne: ne)) · \(pan.pakshaName(ne: ne)) · \(ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)")
                    .scaledFont(size: 16, design: .serif)
                    .foregroundStyle(p.sindoor)
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(app.locale)))
                    .scaledFont(size: 13)
                    .foregroundStyle(p.inkSecondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(SpringPressStyle())
    }

    /// Personal rashifal, flat: seal + two lines + the dasha in one quiet line.
    private var rashifalBlock: some View {
        Group {
            if let k = app.selfMember?.kundali {
                let r = RashifalEngine.generate(rashi: k.moonRashi, period: .daily, date: Date(), lang: app.language)
                Button { app.selectedTab = 1 } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            RashiSeal(rashi: k.moonRashi, size: 44)
                            Text(ne ? k.moonRashi.nameNE : k.moonRashi.shortEN)
                                .scaledFont(size: 21, weight: .semibold, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Spacer()
                            DiyaScore(score: r.scores.values.reduce(0, +) / max(1, r.scores.count))
                        }
                        Text(r.text)
                            .scaledFont(size: 16, design: .serif)
                            .foregroundStyle(p.inkPrimary.opacity(0.88))
                            .lineSpacing(4)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 4) {
                            Text(app.t("common.readMore"))
                            Image(systemName: "chevron.right")
                        }
                        .scaledFont(size: 14, weight: .medium)
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

    private var familyRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(app.family) { m in
                    Button { app.selectedTab = 3 } label: {
                        VStack(spacing: 5) {
                            if let k = m.kundali {
                                RashiSeal(rashi: k.moonRashi, size: 50)
                            } else {
                                Circle().strokeBorder(p.templeGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "person").foregroundStyle(p.inkSecondary))
                            }
                            Text(m.relation == .selfMember ? app.t("common.you") : m.name)
                                .scaledFont(size: 12)
                                .foregroundStyle(p.inkSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 62)
                    }
                    .buttonStyle(SpringPressStyle())
                    .accessibilityLabel(m.relation == .selfMember ? app.t("common.you") : m.name)
                }
            }
        }
        .padding(.horizontal, -24)
        .contentMargins(.horizontal, 24, for: .scrollContent)
    }

    /// Popular aartis — a quiet doorway; the library arrives later.
    private var aartiRow: some View {
        NavigationLink {
            AartiView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "flame")
                    .scaledFont(size: 18, weight: .light)
                    .foregroundStyle(p.saffron)
                Text(app.t("home.aarti"))
                    .scaledFont(size: 19, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .scaledFont(size: 14)
                    .foregroundStyle(p.inkSecondary.opacity(0.6))
            }
        }
        .buttonStyle(SpringPressStyle())
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel(text: app.t("home.upcoming"))
            let items = Array(app.upcomingEvents().prefix(3))
            if items.isEmpty {
                Text(app.t("home.noEvents"))
                    .scaledFont(size: 15)
                    .foregroundStyle(p.inkSecondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.event.id) { i, item in
                        Button { app.selectedTab = 2 } label: {
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
    }
}

/// Popular aartis — placeholder library (content arrives later).
struct AartiView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    private let aartis: [(en: String, ne: String)] = [
        ("Om Jai Jagdish Hare", "ॐ जय जगदीश हरे"),
        ("Ganesh Aarti", "गणेश आरती"),
        ("Shiva Aarti", "शिव आरती"),
        ("Durga Aarti", "दुर्गा आरती"),
        ("Lakshmi Aarti", "लक्ष्मी आरती"),
        ("Krishna Aarti", "कृष्ण आरती"),
        ("Saraswati Aarti", "सरस्वती आरती"),
    ]

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SacredHeader(devanagari: "आरती", title: app.t("aarti.title"))
                        .padding(.horizontal, -20) // SacredHeader carries its own gutter
                        .padding(.top, 8)
                    VStack(spacing: 0) {
                        ForEach(Array(aartis.enumerated()), id: \.offset) { i, aarti in
                            HStack(spacing: 14) {
                                DiyaFlame(size: 18)
                                Text(app.language == .ne ? aarti.ne : aarti.en)
                                    .scaledFont(size: 18, design: .serif)
                                    .foregroundStyle(p.inkPrimary)
                                Spacer()
                                Text(app.t("aarti.soon"))
                                    .scaledFont(size: 12)
                                    .foregroundStyle(p.inkSecondary.opacity(0.7))
                            }
                            .padding(.vertical, 16)
                            if i < aartis.count - 1 { Hairline() }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 96)
            }
        }
        .statusBarFade()
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
