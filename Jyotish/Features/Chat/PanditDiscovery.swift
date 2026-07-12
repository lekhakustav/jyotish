import SwiftUI

/// Human goals shown before astrology terminology. The visible title teaches
/// users what Jyotish Baje can help with; the richer prompt gives the planner the
/// context it needs to create an immediate personalised result.
struct PanditStarter: Identifiable, Equatable {
    let id: String
    let icon: String
    let titleKey: String
    let promptKey: String

    static let all: [PanditStarter] = [
        PanditStarter(id: "love",
                      icon: "heart",
                      titleKey: "pandit.starter.love.title",
                      promptKey: "pandit.starter.love.prompt"),
        PanditStarter(id: "career",
                      icon: "briefcase",
                      titleKey: "pandit.starter.career.title",
                      promptKey: "pandit.starter.career.prompt"),
        PanditStarter(id: "health",
                      icon: "figure.mind.and.body",
                      titleKey: "pandit.starter.health.title",
                      promptKey: "pandit.starter.health.prompt"),
        PanditStarter(id: "future",
                      icon: "moon.stars",
                      titleKey: "pandit.starter.future.title",
                      promptKey: "pandit.starter.future.prompt"),
        PanditStarter(id: "family",
                      icon: "person.2",
                      titleKey: "pandit.starter.family.title",
                      promptKey: "pandit.starter.family.prompt"),
        PanditStarter(id: "today",
                      icon: "sun.max",
                      titleKey: "pandit.starter.today.title",
                      promptKey: "pandit.starter.today.prompt"),
        PanditStarter(id: "muhurta",
                      icon: "calendar.badge.clock",
                      titleKey: "pandit.starter.muhurta.title",
                      promptKey: "pandit.starter.muhurta.prompt"),
    ]

    func title(language: Language) -> String { L10n.t(titleKey, language) }
    func prompt(language: Language) -> String { L10n.t(promptKey, language) }
}

/// Shared between Home and the empty chat state so the same promise always
/// produces the same one-tap question.
struct PanditStarterCard: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    let starter: PanditStarter
    var quiet = false
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: starter.icon)
                    .scaledFont(size: 17, weight: .medium)
                    .foregroundStyle(p.saffron)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(p.bgCanvas))
                Text(starter.title(language: app.language))
                    .scaledFont(size: 15, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .scaledFont(size: 13, weight: .semibold)
                    .foregroundStyle(p.inkSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(quiet ? p.bgCanvas : p.bgElevated))
            .overlay {
                if !quiet {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(p.templeGold.opacity(0.22), lineWidth: 1)
                }
            }
        }
        .buttonStyle(SpringPressStyle())
    }
}
