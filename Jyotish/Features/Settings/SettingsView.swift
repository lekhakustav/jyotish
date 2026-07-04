import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @State private var editingProfile = false

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(app.t("settings.title"))
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(p.inkPrimary)
                        .padding(.top, 24)

                    // Language
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("settings.language"))
                        HStack(spacing: 0) {
                            ForEach(Language.allCases, id: \.self) { l in
                                Button { app.setLanguage(l) } label: {
                                    Text(l.displayName)
                                        .font(.system(size: 16, weight: app.language == l ? .semibold : .regular))
                                        .foregroundStyle(app.language == l ? p.sindoor : p.inkSecondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Capsule().fill(app.language == l ? p.marigold.opacity(0.25) : .clear))
                                }
                            }
                        }
                        .padding(4)
                        .background(Capsule().fill(p.bgSunken))
                        .overlay(Capsule().strokeBorder(p.templeGold.opacity(0.25), lineWidth: 1))
                    }

                    // Theme
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("settings.theme"))
                        VStack(spacing: 8) {
                            themeRow(.system, label: app.t("settings.theme.system"), icon: "circle.lefthalf.filled")
                            themeRow(.light, label: app.t("settings.theme.light"), icon: "sun.max.fill")
                            themeRow(.dark, label: app.t("settings.theme.dark"), icon: "moon.stars.fill")
                        }
                    }

                    // Profile
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("profile.title"))
                        Button { editingProfile = true } label: {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundStyle(p.saffron)
                                Text(app.t("settings.editProfile"))
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundStyle(p.inkPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(p.templeGold)
                            }
                            .padding(14)
                            .sacredCard(radius: 14)
                        }
                    }

                    Button {
                        dismiss()
                        app.signOut()
                    } label: {
                        Text(app.t("settings.signOut"))
                            .font(.system(size: 16))
                            .foregroundStyle(p.sindoor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .sacredCard(radius: 14)
                    }

                    VStack(spacing: 10) {
                        OrnamentDivider().frame(width: 160)
                        Text(app.t("settings.about"))
                            .font(.system(size: 13, design: .serif))
                            .italic()
                            .foregroundStyle(p.inkSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $editingProfile) {
            ProfileSetupView(editing: app.selfMember)
        }
    }

    private func themeRow(_ choice: ThemeChoice, label: String, icon: String) -> some View {
        Button { app.setTheme(choice) } label: {
            HStack {
                Image(systemName: icon).foregroundStyle(p.marigold).frame(width: 28)
                Text(label)
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(p.inkPrimary)
                Spacer()
                if app.theme == choice {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(p.saffron)
                }
            }
            .padding(14)
            .sacredCard(radius: 14)
        }
    }
}
