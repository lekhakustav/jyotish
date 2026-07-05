import SwiftUI

// The "Pratah / Sacred Dawn" palette. See docs/01-DESIGN-SYSTEM.md — the only
// place raw hex values are allowed in the entire app.
enum ThemeChoice: String, Codable, CaseIterable { case system, light, dark }

struct Palette {
    let bgCanvas, bgElevated, bgSunken: Color
    let inkPrimary, inkSecondary: Color
    let saffron, marigold, sindoor, templeGold: Color
    let peepalGreen, lotusPink, nightBlue: Color

    static let prabhat = Palette( // light — plain sacred paper
        bgCanvas: Color(hex: 0xFCF7ED), bgElevated: Color(hex: 0xFFFDF7), bgSunken: Color(hex: 0xF4ECDD),
        inkPrimary: Color(hex: 0x3B1F14), inkSecondary: Color(hex: 0x7A5C48),
        saffron: Color(hex: 0xE8801A), marigold: Color(hex: 0xF2A93B), sindoor: Color(hex: 0xB9331F),
        templeGold: Color(hex: 0xB8860B), peepalGreen: Color(hex: 0x4F7942),
        lotusPink: Color(hex: 0xD96C8A), nightBlue: Color(hex: 0x27334D))

    static let ratri = Palette( // dark — plain night paper
        bgCanvas: Color(hex: 0x17120C), bgElevated: Color(hex: 0x1F1710), bgSunken: Color(hex: 0x100B06),
        inkPrimary: Color(hex: 0xF4E7CE), inkSecondary: Color(hex: 0xC4A886),
        saffron: Color(hex: 0xF49B3A), marigold: Color(hex: 0xFFC15E), sindoor: Color(hex: 0xE05A41),
        templeGold: Color(hex: 0xD9A93F), peepalGreen: Color(hex: 0x7FA86B),
        lotusPink: Color(hex: 0xE68BA4), nightBlue: Color(hex: 0x8FA3C8))
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255, opacity: 1)
    }
}

private struct PaletteKey: EnvironmentKey { static let defaultValue = Palette.prabhat }
extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

// Surface treatment, extreme-minimal edition. Kept for call-site compatibility:
// it intentionally draws no container. Use explicit fills only for structural
// controls such as text fields, calendar cells, charts, and user chat bubbles.
struct SacredCard: ViewModifier {
    var radius: CGFloat = 20
    var tika = false // retained for call-site compatibility; no longer drawn
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func sacredCard(radius: CGFloat = 20, tika: Bool = false) -> some View {
        modifier(SacredCard(radius: radius, tika: tika))
    }
}
