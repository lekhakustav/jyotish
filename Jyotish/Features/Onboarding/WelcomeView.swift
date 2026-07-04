import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            // Dawn wash + mandala as overlays of the background color so their
            // size never inflates the layout beyond the screen.
            Color.clear
                .overlay(
                    LinearGradient(colors: [p.saffron.opacity(0.15), .clear],
                                   startPoint: .top, endPoint: .center))
                .overlay(
                    MandalaView(rotates: true)
                        .frame(width: 460, height: 460)
                        .offset(y: -170)
                        .opacity(0.9))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                DiyaFlame(size: 44).fadeRise()
                Text("ज्योतिष")
                    .scaledFont(size: 56, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .fadeRise(delay: 0.05)
                Text("JYOTISH")
                    .scaledFont(size: 15, weight: .semibold)
                    .kerning(6)
                    .foregroundStyle(p.templeGold)
                    .padding(.top, 4)
                    .fadeRise(delay: 0.1)
                OrnamentDivider()
                    .frame(width: 180)
                    .padding(.vertical, 18)
                    .fadeRise(delay: 0.15)
                Text(app.t("app.tagline"))
                    .scaledFont(size: 18, design: .serif)
                    .italic()
                    .foregroundStyle(p.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fadeRise(delay: 0.2)
                Spacer()

                VStack(spacing: 14) {
                    PrimaryButton(title: app.t("welcome.continue"), icon: "person.crop.circle") {
                        app.signInDemo()
                    }
                    Text(app.t("welcome.note"))
                        .scaledFont(size: 13)
                        .foregroundStyle(p.inkSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                    // Language picker up front — grandparents choose Nepali immediately.
                    HStack(spacing: 0) {
                        ForEach(Language.allCases, id: \.self) { l in
                            Button {
                                app.setLanguage(l)
                            } label: {
                                Text(l.displayName)
                                    .scaledFont(size: 15, weight: app.language == l ? .semibold : .regular)
                                    .foregroundStyle(app.language == l ? p.sindoor : p.inkSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(
                                        Capsule().fill(app.language == l ? p.marigold.opacity(0.25) : .clear))
                            }
                        }
                    }
                    .padding(4)
                    .background(Capsule().fill(p.bgSunken))
                    .overlay(Capsule().strokeBorder(p.templeGold.opacity(0.25), lineWidth: 1))
                    .frame(width: 240)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .fadeRise(delay: 0.25)
            }
        }
    }
}
