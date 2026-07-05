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

    var body: some View {
        NavigationStack {
            TabView(selection: $app.selectedTab) {
                HomeView()
                    .tabItem { Image(systemName: "house.fill") }
                    .tag(AppTab.home)
                    .accessibilityLabel(app.t("tab.home"))
                RashifalView()
                    .tabItem { Image(systemName: "sparkles") }
                    .tag(AppTab.rashifal)
                    .accessibilityLabel(app.t("tab.rashifal"))
                FamilyView()
                    .tabItem { Image(systemName: "person.3.fill") }
                    .tag(AppTab.family)
                    .accessibilityLabel(app.t("tab.family"))
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
