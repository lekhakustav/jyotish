import SwiftUI

// Extreme-minimal home: no cards, no dividers between sections — typography,
// whitespace and one hairline carry the whole hierarchy (docs/01 §v3).
struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showSettings = false

    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    header.fadeRise()
                    tithiHero.fadeRise(delay: 0.05)
                    rashifalBlock.fadeRise(delay: 0.1)
                    if hasRelatives { familyRow.fadeRise(delay: 0.15) }
                    if hasUpcoming { upcoming.fadeRise(delay: 0.2) }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 112)
            }
            Button {
                Haptics.tap()
                app.open(.pandit)
            } label: {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .scaledFont(size: 22, weight: .medium)
                    .foregroundStyle(Color(hex: 0x3B1F14))
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(p.saffron))
                    .shadow(color: p.saffron.opacity(0.22), radius: 12, y: 5)
            }
            .accessibilityLabel(app.t("home.askPandit"))
            .padding(.trailing, 22)
            .padding(.bottom, 24)
        }
        .statusBarFade()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var header: some View {
        HStack {
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
        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(app.digits(bs.day)) \(bs.monthName(ne: ne))")
                    .scaledFont(size: 44, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                VStack(alignment: .leading, spacing: 5) {
                    Text(pan.tithiName(ne: ne))
                    Text(pan.pakshaName(ne: ne))
                    Text(ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)
                }
                .scaledFont(size: 16, design: .serif)
                .foregroundStyle(p.sindoor)
            }
            Button {
                Haptics.tap()
                app.open(.patro)
            } label: {
                HStack(spacing: 8) {
                    Text(app.t("home.openPatro"))
                    Image(systemName: "chevron.right")
                }
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(p.saffron)
            }
            .buttonStyle(SpringPressStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Personal rashifal, flat: rashi mark + two lines + the dasha in one quiet line.
    private var rashifalBlock: some View {
        Group {
            if let k = app.selfMember?.kundali {
                let r = RashifalEngine.generate(rashi: k.moonRashi, period: .daily, date: Date(), lang: app.language)
                Button { app.open(.rashifal) } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            RashiIcon(rashi: k.moonRashi, size: 44)
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
                                .scaledFont(size: 12)
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
