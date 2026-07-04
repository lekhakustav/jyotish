import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showSettings = false

    private var greetingKey: String {
        let h = Calendar.nepali.component(.hour, from: Date())
        if h < 12 { return "greet.morning" }
        if h < 17 { return "greet.afternoon" }
        return "greet.evening"
    }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header.fadeRise()
                    TithiCard().fadeRise(delay: 0.05)
                    if let me = app.selfMember, let k = me.kundali {
                        PersonalRashifalCard(kundali: k).fadeRise(delay: 0.1)
                        DashaStrip(kundali: k).fadeRise(delay: 0.15)
                    }
                    familyRow.fadeRise(delay: 0.2)
                    upcoming.fadeRise(delay: 0.25)
                }
                .padding(.bottom, 96)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            DiyaFlame(size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(app.t(greetingKey))
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(p.templeGold)
                Text(app.selfMember?.name ?? app.t("common.you"))
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(p.inkPrimary)
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(p.inkSecondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel(app.t("settings.title"))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var familyRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: app.t("home.family")).padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(app.family) { m in
                        VStack(spacing: 6) {
                            if let k = m.kundali {
                                RashiSeal(rashi: k.moonRashi, size: 52)
                            } else {
                                Circle().strokeBorder(p.templeGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .frame(width: 52, height: 52)
                                    .overlay(Image(systemName: "person").foregroundStyle(p.inkSecondary))
                            }
                            Text(m.relation == .selfMember ? app.t("common.you") : m.name)
                                .font(.system(size: 12))
                                .foregroundStyle(p.inkSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 64)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: app.t("home.upcoming")).padding(.horizontal, 20)
            let items = Array(app.upcomingEvents().prefix(3))
            if items.isEmpty {
                Text(app.t("home.noEvents"))
                    .font(.system(size: 15))
                    .foregroundStyle(p.inkSecondary)
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(items, id: \.event.id) { item in
                        HStack(spacing: 12) {
                            VStack(spacing: 0) {
                                Text(app.digits(item.bs.day))
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundStyle(p.sindoor)
                                Text(item.bs.monthName(ne: app.language == .ne))
                                    .font(.system(size: 11))
                                    .foregroundStyle(p.inkSecondary)
                            }
                            .frame(width: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.event.title)
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundStyle(p.inkPrimary)
                                if !item.event.note.isEmpty {
                                    Text(item.event.note).font(.system(size: 13)).foregroundStyle(p.inkSecondary)
                                }
                            }
                            Spacer()
                            if item.event.repeatsYearly {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .font(.system(size: 12)).foregroundStyle(p.templeGold)
                            }
                        }
                        .padding(14)
                        .sacredCard(radius: 14)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

/// Today's tithi — the sindoor-tika card.
struct TithiCard: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    var body: some View {
        let bs = BikramSambat.today()
        let pan = Panchanga.forDay(Date())
        let ne = app.language == .ne
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: app.t("home.todayTithi"))
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(app.digits(bs.day)) \(bs.monthName(ne: ne))")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(p.inkPrimary)
                Text(app.digits(bs.year))
                    .font(.system(size: 20, design: .serif))
                    .foregroundStyle(p.inkSecondary)
            }
            HStack(spacing: 8) {
                Text(pan.tithiName(ne: ne))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(p.sindoor)
                Text("·").foregroundStyle(p.templeGold)
                Text(pan.pakshaName(ne: ne))
                    .font(.system(size: 15))
                    .foregroundStyle(p.inkSecondary)
                Text("·").foregroundStyle(p.templeGold)
                Text(ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)
                    .font(.system(size: 15))
                    .foregroundStyle(p.inkSecondary)
            }
            OrnamentDivider()
            Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(app.locale)))
                .font(.system(size: 13))
                .foregroundStyle(p.inkSecondary.opacity(0.8))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sacredCard(tika: true)
        .padding(.horizontal, 20)
    }
}

/// Today's personal rashifal, condensed.
struct PersonalRashifalCard: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    let kundali: Kundali

    var body: some View {
        let r = RashifalEngine.generate(rashi: kundali.moonRashi, period: .daily,
                                        date: Date(), lang: app.language)
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Sunburst().frame(width: 74, height: 74)
                    RashiSeal(rashi: kundali.moonRashi, size: 50)
                }
                VStack(alignment: .leading, spacing: 3) {
                    SectionLabel(text: app.t("home.yourDay"))
                    Text(app.language == .ne ? kundali.moonRashi.nameNE : kundali.moonRashi.shortEN)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(p.inkPrimary)
                }
                Spacer()
                DiyaScore(score: r.scores.values.reduce(0, +) / max(1, r.scores.count))
            }
            Text(r.text)
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(p.inkPrimary.opacity(0.9))
                .lineSpacing(4)
                .lineLimit(3)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sacredCard(tika: true)
        .padding(.horizontal, 20)
    }
}

/// Current mahadasha / antardasha chips.
struct DashaStrip: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    let kundali: Kundali

    var body: some View {
        Group {
            if let cur = Vimshottari.current(for: kundali, at: Ephemeris.julianDay(Date())) {
                HStack(spacing: 12) {
                    chip(label: app.t("home.mahadasha"),
                         planet: cur.maha.lord,
                         until: Vimshottari.date(fromJD: cur.maha.end))
                    chip(label: app.t("home.antardasha"),
                         planet: cur.antar.lord,
                         until: Vimshottari.date(fromJD: cur.antar.end))
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func chip(label: String, planet: Planet, until: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionLabel(text: label)
            Text(app.language == .ne ? planet.nameNE : planet.nameEN)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(p.sindoor)
            Text(until.formatted(.dateTime.year().month(.abbreviated).locale(app.locale)))
                .font(.system(size: 12))
                .foregroundStyle(p.inkSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sacredCard(radius: 14)
    }
}
