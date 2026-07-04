import SwiftUI

@main
struct JyotishApp: App {
    @StateObject private var app = AppState()
    @Environment(\.colorScheme) private var systemScheme

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
        }
    }
}

/// Applies theme choice → palette + color scheme, then routes by session state.
struct RootView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var systemScheme

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
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: app.isLoggedIn)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: app.hasBirthProfile)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    // QA-only: `-tab 2` launch argument opens a specific tab for screenshot passes.
    @State private var selection: Int = {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-tab"), i + 1 < args.count, let n = Int(args[i + 1]) { return n }
        return 0
    }()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label(app.t("tab.home"), systemImage: "house.fill") }.tag(0)
            RashifalView()
                .tabItem { Label(app.t("tab.rashifal"), systemImage: "sparkles") }.tag(1)
            PatroView()
                .tabItem { Label(app.t("tab.patro"), systemImage: "calendar") }.tag(2)
            FamilyView()
                .tabItem { Label(app.t("tab.family"), systemImage: "person.3.fill") }.tag(3)
            ChatView()
                .tabItem { Label(app.t("tab.pandit"), systemImage: "bubble.left.and.bubble.right.fill") }.tag(4)
        }
        .tint(p.saffron)
    }
}
