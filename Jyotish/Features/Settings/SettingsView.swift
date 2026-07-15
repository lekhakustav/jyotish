import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var editingProfile = false
    @State private var notificationError: String?

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(app.t("settings.title"))
                        .scaledFont(size: 30, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .padding(.top, 24)

                    // Language
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("settings.language"))
                        HStack(spacing: 0) {
                            ForEach(Language.allCases, id: \.self) { l in
                                Button { app.setLanguage(l) } label: {
                                    Text(l.displayName)
                                        .scaledFont(size: 16, weight: app.language == l ? .semibold : .regular)
                                        .foregroundStyle(app.language == l ? p.sindoor : p.inkSecondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Capsule().fill(app.language == l ? p.marigold.opacity(0.25) : .clear))
                                }
                            }
                        }
                        .padding(4)
                        .background(Capsule().fill(p.bgSunken))
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
                                    .scaledFont(size: 16, design: .serif)
                                    .foregroundStyle(p.inkPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .scaledFont(size: 13)
                                    .foregroundStyle(p.templeGold)
                            }
                            .padding(.vertical, 12)
                        }
                    }

                    notificationSettings

                    // Legal
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("settings.legal"))
                        legalRow(app.t("settings.privacyPolicy"), icon: "hand.raised.fill",
                                 url: "https://www.orecci.com/jyotish/privacy-policy.html")
                        legalRow(app.t("settings.termsOfService"), icon: "doc.text.fill",
                                 url: "https://www.orecci.com/jyotish/terms-of-service.html")
                    }

                    Button {
                        dismiss()
                        app.signOut()
                    } label: {
                        Text(app.t("settings.signOut"))
                            .scaledFont(size: 16)
                            .foregroundStyle(p.sindoor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal, LayoutMetrics.sheetGutter)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $editingProfile) {
            ProfileSetupView(editing: app.selfMember)
        }
        .alert(app.t("settings.notifications"),
               isPresented: Binding(get: { notificationError != nil },
                                    set: { if !$0 { notificationError = nil } })) {
            Button(app.t("common.done")) { notificationError = nil }
        } message: {
            Text(notificationError ?? "")
        }
    }

    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(text: app.t("settings.notifications"))
            Toggle(app.t("settings.notifications.daily"), isOn: Binding(
                get: { app.engagementPreferences.enabled },
                set: { enabled in
                    Task {
                        do {
                            try await app.setEngagementNotificationsEnabled(enabled)
                        } catch {
                            notificationError = app.t("settings.notifications.denied")
                        }
                    }
                }))
                .scaledFont(size: 16, design: .serif)
                .tint(p.saffron)

            if app.engagementPreferences.enabled {
                Hairline()
                HStack {
                    Text(app.t("settings.notifications.wake"))
                        .scaledFont(size: 15, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Spacer()
                    Picker(app.t("settings.notifications.wake"), selection: Binding(
                        get: { app.engagementPreferences.wakeHour },
                        set: app.setNotificationWakeHour)) {
                        ForEach(5...10, id: \.self) { hour in
                            Text("\(app.digits(hour)):00").tag(hour)
                        }
                    }
                    .labelsHidden()
                }
                HStack {
                    Text(app.t("settings.notifications.frequency"))
                        .scaledFont(size: 15, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Spacer()
                    Picker(app.t("settings.notifications.frequency"), selection: Binding(
                        get: { app.engagementPreferences.dailyCount },
                        set: app.setNotificationDailyCount)) {
                        ForEach(2...4, id: \.self) { count in
                            Text(app.digits(count)).tag(count)
                        }
                    }
                    .labelsHidden()
                }
                Toggle(app.t("settings.notifications.family"), isOn: Binding(
                    get: { app.engagementPreferences.familyInsights },
                    set: app.setFamilyNotifications))
                    .scaledFont(size: 15, design: .serif)
                    .tint(p.saffron)
                Toggle(app.t("settings.notifications.calendar"), isOn: Binding(
                    get: { app.engagementPreferences.calendarReminders },
                    set: app.setCalendarNotifications))
                    .scaledFont(size: 15, design: .serif)
                    .tint(p.saffron)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.9),
                   value: app.engagementPreferences.enabled)
    }

    private func legalRow(_ label: String, icon: String, url: String) -> some View {
        Button {
            if let link = URL(string: url) { UIApplication.shared.open(link) }
        } label: {
            HStack {
                Image(systemName: icon).foregroundStyle(p.saffron).frame(width: 28)
                Text(label)
                    .scaledFont(size: 16, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .scaledFont(size: 13)
                    .foregroundStyle(p.templeGold)
            }
            .padding(.vertical, 12)
        }
    }

    private func themeRow(_ choice: ThemeChoice, label: String, icon: String) -> some View {
        Button { app.setTheme(choice) } label: {
            HStack {
                Image(systemName: icon).foregroundStyle(p.marigold).frame(width: 28)
                Text(label)
                    .scaledFont(size: 16, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                Spacer()
                if app.theme == choice {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(p.saffron)
                }
            }
            .padding(.vertical, 12)
        }
    }
}
