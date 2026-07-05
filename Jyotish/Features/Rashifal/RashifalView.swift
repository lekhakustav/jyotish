import SwiftUI

// Extreme-minimal rashifal: rashi mark, prose, quiet score lines. No cards, no
// dividers except one hairline before the upaya (docs/01 §v3).
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
                VStack(alignment: .leading, spacing: 28) {
                    Text(app.t("rashifal.title"))
                        .scaledFont(size: 34, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    periodPicker

                    rashiPicker

                    reading
                        .id("\(rashi.rawValue)-\(period.rawValue)-\(app.language.rawValue)")
                        .transition(.opacity.combined(with: .offset(y: 10)))
                }
                .padding(.bottom, 96)
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: rashi)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: period)
        }
        .statusBarFade()
    }

    private var periodPicker: some View {
        HStack(spacing: 6) {
            ForEach(RashifalPeriod.allCases) { pd in
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { period = pd }
                } label: {
                    Text(app.t(pd.l10nKey))
                        .scaledFont(size: 14, weight: period == pd ? .semibold : .regular)
                        .foregroundStyle(period == pd ? Color(hex: 0x3B1F14) : p.inkSecondary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(period == pd ? p.saffron : .clear))
                }
            }
        }
        .padding(4)
        .background(Capsule().fill(p.bgSunken))
        .padding(.horizontal, 24)
    }

    private var rashiPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Rashi.allCases) { r in
                    Button {
                        Haptics.tap()
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { selectedRashi = r }
                    } label: {
                        VStack(spacing: 5) {
                            RashiSeal(rashi: r, size: 48)
                            Text(app.language == .ne ? r.nameNE : r.shortEN)
                                .scaledFont(size: 11, weight: rashi == r ? .semibold : .regular)
                                .foregroundStyle(rashi == r ? p.sindoor : p.inkSecondary)
                        }
                        .padding(.bottom, 4)
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(rashi == r ? p.saffron : .clear)
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
    }

    private var reading: some View {
        let r = RashifalEngine.generate(rashi: rashi, period: period, date: Date(), lang: app.language)
        let ne = app.language == .ne
        return VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 14) {
                RashiSeal(rashi: rashi, size: 58)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ne ? rashi.nameNE : rashi.shortEN)
                        .scaledFont(size: 26, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Text(app.t(period.l10nKey))
                        .scaledFont(size: 14)
                        .foregroundStyle(p.templeGold)
                }
                Spacer()
            }

            Text(r.text)
                .scaledFont(size: 17, design: .serif)
                .foregroundStyle(p.inkPrimary.opacity(0.92))
                .lineSpacing(6)

            VStack(spacing: 10) {
                ForEach(RashifalEngine.domains, id: \.self) { d in
                    HStack {
                        Text(app.t(d)).scaledFont(size: 15).foregroundStyle(p.inkSecondary)
                        Spacer()
                        DiyaScore(score: r.scores[d] ?? 3)
                    }
                }
            }

            HStack(spacing: 10) {
                LuckyFact(label: app.t("rashifal.lucky.color"), value: r.luckyColor, systemImage: "paintpalette")
                LuckyFact(label: app.t("rashifal.lucky.number"), value: app.digits(r.luckyNumber), systemImage: "number")
                LuckyFact(label: app.t("rashifal.lucky.day"), value: r.luckyDay, systemImage: "calendar")
            }

            VStack(alignment: .leading, spacing: 10) {
                Hairline()
                Text(r.upaya)
                    .scaledFont(size: 15, design: .serif)
                    .italic()
                    .foregroundStyle(p.inkPrimary.opacity(0.85))
            }

            Button {
                Haptics.tap()
                app.open(.pandit)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text(app.t("home.askPandit"))
                }
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(p.saffron)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            .buttonStyle(SpringPressStyle())
        }
        .padding(.horizontal, 24)
    }
}

private struct LuckyFact: View {
    @Environment(\.palette) private var p
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(p.saffron)
            Text(label)
                .scaledFont(size: 11)
                .foregroundStyle(p.inkSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .scaledFont(size: 14, weight: .semibold, design: .serif)
                .foregroundStyle(p.inkPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(p.bgSunken))
    }
}
