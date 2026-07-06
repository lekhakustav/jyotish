import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                Text("ज्योतिष")
                    .scaledFont(size: 56, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .fadeRise(delay: 0.05)
                Text("Jyotish")
                    .scaledFont(size: 15, weight: .semibold)
                    .foregroundStyle(p.inkSecondary)
                    .padding(.top, 4)
                    .fadeRise(delay: 0.1)
                Text(app.t("app.tagline"))
                    .scaledFont(size: 18, design: .serif)
                    .italic()
                    .foregroundStyle(p.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                    .fadeRise(delay: 0.15)
                Spacer()

                VStack(spacing: 14) {
                    PrimaryButton(title: app.t("welcome.continue"), icon: "person.crop.circle") {
                        app.signInDemo()
                    }
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
                    .frame(width: 240)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .fadeRise(delay: 0.2)
            }
        }
    }
}
