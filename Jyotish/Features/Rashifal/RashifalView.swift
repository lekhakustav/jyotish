import SwiftUI

struct RashifalView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var period: RashifalPeriod = .daily
    @State private var selectedRashi: Rashi?

    private var rashi: Rashi {
        selectedRashi ?? app.selfMember?.kundali?.moonRashi ?? .mesh
    }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SacredHeader(devanagari: "राशिफल", title: app.t("rashifal.title"))
                        .padding(.top, 8)

                    periodPicker

                    rashiPicker

                    RashifalCard(rashi: rashi, period: period)
                        .id("\(rashi.rawValue)-\(period.rawValue)-\(app.language.rawValue)")
                        .fadeRise()
                }
                .padding(.bottom, 96)
            }
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 6) {
            ForEach(RashifalPeriod.allCases) { pd in
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { period = pd }
                } label: {
                    Text(app.t(pd.l10nKey))
                        .font(.system(size: 14, weight: period == pd ? .semibold : .regular))
                        .foregroundStyle(period == pd ? Color(hex: 0xFFFBF0) : p.inkSecondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(period == pd ? p.saffron : .clear))
                }
            }
        }
        .padding(4)
        .background(Capsule().fill(p.bgSunken))
        .overlay(Capsule().strokeBorder(p.templeGold.opacity(0.2), lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private var rashiPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Rashi.allCases) { r in
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { selectedRashi = r }
                    } label: {
                        VStack(spacing: 5) {
                            RashiSeal(rashi: r, size: 48)
                                .overlay(Circle().strokeBorder(
                                    rashi == r ? p.saffron : .clear, lineWidth: 2))
                            Text(app.language == .ne ? r.nameNE : r.shortEN)
                                .font(.system(size: 11, weight: rashi == r ? .semibold : .regular))
                                .foregroundStyle(rashi == r ? p.sindoor : p.inkSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

struct RashifalCard: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    let rashi: Rashi
    let period: RashifalPeriod

    var body: some View {
        let r = RashifalEngine.generate(rashi: rashi, period: period, date: Date(), lang: app.language)
        let ne = app.language == .ne
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Sunburst().frame(width: 96, height: 96)
                    RashiSeal(rashi: rashi, size: 64)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(ne ? rashi.nameNE : rashi.shortEN)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(p.inkPrimary)
                    Text(app.t(period.l10nKey))
                        .font(.system(size: 14))
                        .foregroundStyle(p.templeGold)
                }
                Spacer()
            }

            Text(r.text)
                .font(.system(size: 17, design: .serif))
                .foregroundStyle(p.inkPrimary.opacity(0.92))
                .lineSpacing(5)

            OrnamentDivider()

            VStack(spacing: 8) {
                ForEach(RashifalEngine.domains, id: \.self) { d in
                    HStack {
                        Text(app.t(d)).font(.system(size: 15)).foregroundStyle(p.inkSecondary)
                        Spacer()
                        DiyaScore(score: r.scores[d] ?? 3)
                    }
                }
            }

            OrnamentDivider()

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: app.t("rashifal.lucky.color"), value: r.luckyColor)
                InfoRow(label: app.t("rashifal.lucky.number"), value: app.digits(r.luckyNumber))
                InfoRow(label: app.t("rashifal.lucky.day"), value: r.luckyDay)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "hands.and.sparkles.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(p.marigold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.t("rashifal.upaya"))
                        .font(.system(size: 12, weight: .semibold))
                        .kerning(1)
                        .foregroundStyle(p.templeGold)
                    Text(r.upaya)
                        .font(.system(size: 15, design: .serif))
                        .italic()
                        .foregroundStyle(p.inkPrimary.opacity(0.9))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(p.marigold.opacity(0.12)))
        }
        .padding(18)
        .sacredCard(tika: true)
        .padding(.horizontal, 20)
    }
}
