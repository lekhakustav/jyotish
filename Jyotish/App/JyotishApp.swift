import SwiftUI

@main
struct JyotishApp: App {
    @UIApplicationDelegateAdaptor(JyotishAppDelegate.self) private var appDelegate
    @StateObject private var app = AppState()
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.scenePhase) private var scenePhase

    init() {
        AppRuntime.configureCaches()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .onChange(of: scenePhase) { _, phase in
                    AppAnalytics.track("app_lifecycle", properties: ["phase": String(describing: phase)])
                    if phase != .active { AppAnalytics.flushNow() }
                }
        }
    }
}

enum AppRuntime {
    static func configureCaches() {
        URLCache.shared = URLCache(memoryCapacity: 64 * 1024 * 1024,
                                   diskCapacity: 256 * 1024 * 1024,
                                   diskPath: "jyotish-url-cache")
    }
}

/// Applies theme choice → palette + color scheme, then routes by session state.
struct RootView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isDark: Bool {
        switch app.theme {
        case .system: return systemScheme == .dark
        case .light: return false
        case .dark: return true
        }
    }

    var body: some View {
        Group {
            if !app.isLoggedIn {
                WelcomeView()
            } else if !app.hasBirthProfile {
                ProfileSetupView(editing: nil)
            } else {
                MainTabView()
            }
        }
        .environment(\.palette, isDark ? .ratri : .prabhat)
        .preferredColorScheme(app.theme == .system ? nil : (isDark ? .dark : .light))
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: app.isLoggedIn)
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: app.hasBirthProfile)
        .onReceive(NotificationCenter.default.publisher(for: .engagementNotificationTapped)) { note in
            guard app.isLoggedIn, let userInfo = note.object as? [AnyHashable: Any],
                  let raw = userInfo["destination"] as? String,
                  let destination = AppDestination(rawValue: raw) else { return }
            let prompt = (userInfo["prompt"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            AppAnalytics.track("notification_opened", properties: ["destination": destination.rawValue,
                                                                    "has_prompt": prompt == nil ? "false" : "true"])
            if destination == .pandit {
                app.openPandit(prompt: prompt)
            } else {
                app.open(destination)
            }
        }
        .onAppear {
            AppAnalytics.track("screen_view", properties: ["screen": rootScreenName])
        }
        .onChange(of: app.isLoggedIn) { _, _ in
            AppAnalytics.track("screen_view", properties: ["screen": rootScreenName])
        }
        .onChange(of: app.hasBirthProfile) { _, _ in
            AppAnalytics.track("screen_view", properties: ["screen": rootScreenName])
        }
    }

    private var rootScreenName: String {
        if !app.isLoggedIn { return "welcome" }
        if !app.hasBirthProfile { return "profile_setup" }
        return "main"
    }
}

struct MainTabView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    var body: some View {
        NavigationStack {
            TabView(selection: $app.selectedTab) {
                FamilyView()
                    .tabItem { Label(app.t("tab.family"), systemImage: "qrcode") }
                    .tag(AppTab.family)
                    .accessibilityLabel(app.t("tab.family"))
                RashifalView()
                    .tabItem { Label(app.t("tab.rashifal"), systemImage: "sparkles") }
                    .tag(AppTab.rashifal)
                    .accessibilityLabel(app.t("tab.rashifal"))
                HomeView()
                    .tabItem { Label(app.t("tab.home"), systemImage: "building.columns.fill") }
                    .tag(AppTab.home)
                    .accessibilityLabel(app.t("tab.home"))
            }
            .navigationDestination(isPresented: Binding(
                get: { app.pushedDestination != nil },
                set: { if !$0 { app.pushedDestination = nil } })) {
                switch app.pushedDestination {
                case .patro:
                    PatroView()
                default:
                    EmptyView()
                }
            }
        }
        .tint(p.saffron)
        .onChange(of: app.selectedTab) { _, tab in
            AppAnalytics.track("screen_view", properties: ["screen": tab.destination.rawValue])
        }
        .onChange(of: app.pushedDestination) { _, destination in
            if let destination { AppAnalytics.track("screen_view", properties: ["screen": destination.rawValue]) }
        }
        .onChange(of: app.modalDestination) { _, destination in
            if let destination { AppAnalytics.track("screen_view", properties: ["screen": destination.rawValue]) }
        }
        .fullScreenCover(item: $app.modalDestination) { destination in
            switch destination {
            case .pandit:
                ChatView()
            default:
                EmptyView()
            }
        }
    }
}
