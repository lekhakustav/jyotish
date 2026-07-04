import SwiftUI

// The "Pratah / Sacred Dawn" palette. See docs/01-DESIGN-SYSTEM.md — the only
// place raw hex values are allowed in the entire app.
enum ThemeChoice: String, Codable, CaseIterable { case system, light, dark }

struct Palette {
    let bgCanvas, bgElevated, bgSunken: Color
    let inkPrimary, inkSecondary: Color
    let saffron, marigold, sindoor, templeGold: Color
    let peepalGreen, lotusPink, nightBlue: Color

    static let prabhat = Palette( // light — auspicious morning
        bgCanvas: Color(hex: 0xFAF3E3), bgElevated: Color(hex: 0xFFFBF0), bgSunken: Color(hex: 0xF1E6CE),
        inkPrimary: Color(hex: 0x3B1F14), inkSecondary: Color(hex: 0x7A5C48),
        saffron: Color(hex: 0xE8801A), marigold: Color(hex: 0xF2A93B), sindoor: Color(hex: 0xB9331F),
        templeGold: Color(hex: 0xB8860B), peepalGreen: Color(hex: 0x4F7942),
        lotusPink: Color(hex: 0xD96C8A), nightBlue: Color(hex: 0x27334D))

    static let ratri = Palette( // dark — night lamp
        bgCanvas: Color(hex: 0x171009), bgElevated: Color(hex: 0x231809), bgSunken: Color(hex: 0x100B06),
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

// Card treatment: gilded edge + warm shadow (docs/01 §5).
struct SacredCard: ViewModifier {
    @Environment(\.palette) private var p
    var radius: CGFloat = 20
    var tika = false // sindoor dot on top — for the most important cards
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(p.bgElevated))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(p.templeGold.opacity(0.16), lineWidth: 1))
            .overlay(alignment: .top) {
                if tika {
                    Circle().fill(p.sindoor).frame(width: 7, height: 7).offset(y: -3.5)
                }
            }
            .shadow(color: p.saffron.opacity(0.06), radius: 18, y: 8)
    }
}

extension View {
    func sacredCard(radius: CGFloat = 20, tika: Bool = false) -> some View {
        modifier(SacredCard(radius: radius, tika: tika))
    }
}
