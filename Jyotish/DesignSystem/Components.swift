import SwiftUI

// ── Apple-basics layer: Dynamic Type, haptics, status-bar protection ────────

/// Dynamic-Type-aware font: scales with the user's text size setting.
/// Always use this instead of `.font(.system(size:))` for text (docs/01 §3).
struct ScaledFontModifier: ViewModifier {
    @ScaledMetric private var scaled: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design
    init(size: CGFloat, weight: Font.Weight, design: Font.Design, relativeTo style: Font.TextStyle) {
        _scaled = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
        self.design = design
    }
    func body(content: Content) -> some View {
        content.font(.system(size: scaled, weight: weight, design: design))
    }
}

extension View {
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular,
                    design: Font.Design = .default,
                    relativeTo style: Font.TextStyle = .body) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, design: design, relativeTo: style))
    }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

/// Gentle press-down scale for primary actions.
struct SpringPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Canvas-colored fade pinned behind the status bar so scrolling content
/// never collides with the clock (HIG: content clarity at screen edges).
struct StatusBarFade: ViewModifier {
    @Environment(\.palette) private var p
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            LinearGradient(stops: [
                .init(color: p.bgCanvas, location: 0),
                .init(color: p.bgCanvas.opacity(0.85), location: 0.55),
                .init(color: p.bgCanvas.opacity(0), location: 1),
            ], startPoint: .top, endPoint: .bottom)
            .frame(height: 64)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func statusBarFade() -> some View { modifier(StatusBarFade()) }
}

/// Explicit dismiss affordance for sheets (HIG: never rely on drag alone).
struct SheetCloseButton: View {
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark.circle.fill")
                .scaledFont(size: 26)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(p.inkSecondary.opacity(0.6))
                .frame(width: 48, height: 48)
        }
        .accessibilityLabel("Close")
    }
}

/// Screen header with the Devanagari echo line (docs/01 §3).
struct SacredHeader: View {
    @Environment(\.palette) private var p
    let devanagari: String
    let title: String
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(devanagari)
                    .scaledFont(size: 15, design: .serif)
                    .foregroundStyle(p.templeGold)
                    .accessibilityHidden(true)
                Text(title)
                    .scaledFont(size: 34, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
            }
            Spacer()
            trailing
        }
        .padding(.horizontal, 20)
    }
}

/// 56pt saffron primary button, cream serif label.
struct PrimaryButton: View {
    @Environment(\.palette) private var p
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).scaledFont(size: 19, weight: .semibold, design: .serif)
            }
            // Dark umber, not cream: cream-on-saffron fails the 3:1 large-text
            // contrast minimum; umber passes at ~4.4:1 in both themes.
            .foregroundStyle(Color(hex: 0x3B1F14))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(p.saffron))
        }
        .buttonStyle(SpringPressStyle())
    }
}

/// Section label: quiet secondary text, without decorative tracking.
struct SectionLabel: View {
    @Environment(\.palette) private var p
    let text: String
    var body: some View {
        Text(text.uppercased())
            .scaledFont(size: 12, weight: .medium)
            .foregroundStyle(p.inkSecondary.opacity(0.75))
    }
}

/// The only divider allowed: a bare gold hairline (extreme minimalism).
struct Hairline: View {
    @Environment(\.palette) private var p
    var body: some View {
        Rectangle().fill(p.templeGold.opacity(0.18)).frame(height: 1)
            .accessibilityHidden(true)
    }
}

/// 1–5 score as tiny diya flames.
struct DiyaScore: View {
    @Environment(\.palette) private var p
    let score: Int
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: "flame.fill")
                    .scaledFont(size: 11)
                    .foregroundStyle(i < score ? p.marigold : p.inkSecondary.opacity(0.25))
            }
        }
        .accessibilityLabel("\(score) of 5")
    }
}

/// A key–value row used in guna/panchanga tables.
struct InfoRow: View {
    @Environment(\.palette) private var p
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).scaledFont(size: 15).foregroundStyle(p.inkSecondary)
            Spacer()
            Text(value)
                .scaledFont(size: 16, weight: .medium, design: .serif)
                .foregroundStyle(p.inkPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Fade-rise entrance used for hero content (docs/01 §6).
struct FadeRise: ViewModifier {
    var delay: Double = 0
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 8)
            .onAppear {
                if UIAccessibility.isReduceMotionEnabled {
                    shown = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9).delay(delay)) { shown = true }
                }
            }
    }
}

extension View {
    func fadeRise(delay: Double = 0) -> some View { modifier(FadeRise(delay: delay)) }
}
