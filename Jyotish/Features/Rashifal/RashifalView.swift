import SwiftUI

// Extreme-minimal rashifal: seal, prose, quiet score lines. No cards, no
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
                    SacredHeader(devanagari: "राशिफल", title: app.t("rashifal.title"))
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
                                .overlay(Circle().strokeBorder(
                                    rashi == r ? p.saffron : .clear, lineWidth: 2))
                            Text(app.language == .ne ? r.nameNE : r.shortEN)
                                .scaledFont(size: 11, weight: rashi == r ? .semibold : .regular)
                                .foregroundStyle(rashi == r ? p.sindoor : p.inkSecondary)
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

            Text("\(app.t("rashifal.lucky.color")) \(r.luckyColor) · \(app.t("rashifal.lucky.number")) \(app.digits(r.luckyNumber)) · \(r.luckyDay)")
                .scaledFont(size: 14)
                .foregroundStyle(p.inkSecondary)

            VStack(alignment: .leading, spacing: 10) {
                Hairline()
                Text(r.upaya)
                    .scaledFont(size: 15, design: .serif)
                    .italic()
                    .foregroundStyle(p.inkPrimary.opacity(0.85))
            }
        }
        .padding(.horizontal, 24)
    }
}
