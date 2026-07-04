import SwiftUI

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
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(p.templeGold)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
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
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.system(size: 19, weight: .semibold, design: .serif))
            }
            .foregroundStyle(Color(hex: 0xFFFBF0))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [p.saffron, p.saffron.opacity(0.88)],
                                         startPoint: .top, endPoint: .bottom)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(p.templeGold.opacity(0.4), lineWidth: 1))
            .shadow(color: p.saffron.opacity(0.35), radius: 12, y: 5)
        }
    }
}

/// Section label: small caps feel, gold diamond prefix.
struct SectionLabel: View {
    @Environment(\.palette) private var p
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 6))
                .foregroundStyle(p.templeGold)
                .accessibilityHidden(true)
            Text(text.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .kerning(1.2)
                .foregroundStyle(p.inkSecondary)
        }
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
                    .font(.system(size: 11))
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
            Text(label).font(.system(size: 15)).foregroundStyle(p.inkSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .serif))
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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9).delay(delay)) { shown = true }
            }
    }
}

extension View {
    func fadeRise(delay: Double = 0) -> some View { modifier(FadeRise(delay: delay)) }
}
