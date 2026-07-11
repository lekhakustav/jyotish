import SwiftUI

enum AuthMode: Identifiable, Hashable {
    case signIn, signUp
    var id: Self { self }
}

struct WelcomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var authMode: AuthMode?

    var body: some View {
        NavigationStack {
            ZStack {
                p.bgCanvas.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                        .padding(.bottom, 20)
                        .fadeRise()
                    Text("ज्योतिष बाजे")
                        .scaledFont(size: 56, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .fadeRise(delay: 0.05)
                    Text(app.t("app.tagline"))
                        .scaledFont(size: 18, design: .serif)
                        .italic()
                        .foregroundStyle(p.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.horizontal, 40)
                        .fadeRise(delay: 0.1)
                    Spacer()

                    VStack(spacing: 14) {
                        PrimaryButton(title: app.t("welcome.createAccount"), icon: "sparkles") {
                            authMode = .signUp
                        }
                        SecondaryButton(title: app.t("welcome.signIn"), icon: "person.crop.circle") {
                            authMode = .signIn
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
                                        .frame(height: 48)
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
                    .fadeRise(delay: 0.15)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $authMode) { mode in
                AuthMethodView(mode: mode)
            }
        }
    }
}
