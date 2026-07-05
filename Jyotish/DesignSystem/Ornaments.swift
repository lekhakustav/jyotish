import SwiftUI

// Code-drawn ornament per docs/01 §4. Every ornament is decorative: hidden from a11y.

/// Concentric petal-ring mandala, drawn with Canvas. Watermark behind heroes.
struct MandalaView: View {
    @Environment(\.palette) private var p
    var rotates = false
    @State private var angle = 0.0
    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2
            let gold = p.templeGold
            for (ring, petals, opacity) in [(0.32, 8, 0.30), (0.55, 16, 0.24), (0.78, 32, 0.18)] {
                let radius = r * ring
                var path = Path()
                for i in 0..<petals {
                    let a0 = Double(i) / Double(petals) * 2 * .pi
                    let a1 = Double(i + 1) / Double(petals) * 2 * .pi
                    let mid = (a0 + a1) / 2
                    let inner = CGPoint(x: c.x + cos(a0) * radius, y: c.y + sin(a0) * radius)
                    let tip = CGPoint(x: c.x + cos(mid) * radius * 1.22, y: c.y + sin(mid) * radius * 1.22)
                    let end = CGPoint(x: c.x + cos(a1) * radius, y: c.y + sin(a1) * radius)
                    path.move(to: inner)
                    path.addQuadCurve(to: tip, control: CGPoint(x: c.x + cos(a0) * radius * 1.18, y: c.y + sin(a0) * radius * 1.18))
                    path.addQuadCurve(to: end, control: CGPoint(x: c.x + cos(a1) * radius * 1.18, y: c.y + sin(a1) * radius * 1.18))
                }
                path.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
                ctx.stroke(path, with: .color(gold.opacity(opacity)), lineWidth: 0.75)
            }
            ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r * 0.1, y: c.y - r * 0.1, width: r * 0.2, height: r * 0.2)),
                       with: .color(gold.opacity(0.35)), lineWidth: 0.75)
        }
        .rotationEffect(.degrees(angle))
        .onAppear {
            guard rotates, !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 360).repeatForever(autoreverses: false)) { angle = 360 }
        }
        .accessibilityHidden(true)
    }
}

/// A softly flickering diya flame (two blended teardrops).
struct DiyaFlame: View {
    @Environment(\.palette) private var p
    @State private var flicker = false
    var size: CGFloat = 26
    var body: some View {
        ZStack {
            FlameShape().fill(p.saffron.opacity(0.85))
                .frame(width: size * 0.62, height: size)
            FlameShape().fill(p.marigold)
                .frame(width: size * 0.34, height: size * 0.6)
                .offset(y: size * 0.14)
        }
        .scaleEffect(y: flicker ? 1.06 : 0.96, anchor: .bottom)
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: flicker)
        .onAppear { if !UIAccessibility.isReduceMotionEnabled { flicker = true } }
        .accessibilityHidden(true)
    }
}

struct FlameShape: Shape {
    func path(in r: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: r.midX, y: r.minY))
        path.addCurve(to: CGPoint(x: r.midX, y: r.maxY),
                      control1: CGPoint(x: r.maxX + r.width * 0.15, y: r.height * 0.55),
                      control2: CGPoint(x: r.maxX, y: r.maxY))
        path.addCurve(to: CGPoint(x: r.midX, y: r.minY),
                      control1: CGPoint(x: r.minX, y: r.maxY),
                      control2: CGPoint(x: r.minX - r.width * 0.15, y: r.height * 0.55))
        return path
    }
}

/// Simple zodiac-style rashi mark. The mark is intentionally unframed so rashi
/// rows do not look like monograms inside double seals.
struct RashiIcon: View {
    @Environment(\.palette) private var p
    let rashi: Rashi
    var size: CGFloat = 56
    var body: some View {
        Canvas { ctx, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: size * 0.12, dy: size * 0.12)
            ctx.stroke(Self.path(for: rashi, in: rect),
                       with: .color(p.sindoor),
                       style: StrokeStyle(lineWidth: max(1.6, size * 0.055), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private static func path(for rashi: Rashi, in r: CGRect) -> Path {
        var path = Path()
        let x = r.minX, y = r.minY, w = r.width, h = r.height
        switch rashi {
        case .mesh:
            path.move(to: CGPoint(x: x + w * 0.5, y: y + h * 0.88))
            path.addCurve(to: CGPoint(x: x + w * 0.1, y: y + h * 0.14),
                          control1: CGPoint(x: x + w * 0.45, y: y + h * 0.36),
                          control2: CGPoint(x: x + w * 0.22, y: y + h * 0.08))
            path.move(to: CGPoint(x: x + w * 0.5, y: y + h * 0.88))
            path.addCurve(to: CGPoint(x: x + w * 0.9, y: y + h * 0.14),
                          control1: CGPoint(x: x + w * 0.55, y: y + h * 0.36),
                          control2: CGPoint(x: x + w * 0.78, y: y + h * 0.08))
        case .vrish:
            path.addEllipse(in: CGRect(x: x + w * 0.28, y: y + h * 0.38, width: w * 0.44, height: h * 0.44))
            path.move(to: CGPoint(x: x + w * 0.32, y: y + h * 0.44))
            path.addCurve(to: CGPoint(x: x + w * 0.08, y: y + h * 0.18),
                          control1: CGPoint(x: x + w * 0.18, y: y + h * 0.38),
                          control2: CGPoint(x: x + w * 0.08, y: y + h * 0.3))
            path.move(to: CGPoint(x: x + w * 0.68, y: y + h * 0.44))
            path.addCurve(to: CGPoint(x: x + w * 0.92, y: y + h * 0.18),
                          control1: CGPoint(x: x + w * 0.82, y: y + h * 0.38),
                          control2: CGPoint(x: x + w * 0.92, y: y + h * 0.3))
        case .mithun:
            path.move(to: CGPoint(x: x + w * 0.22, y: y + h * 0.2))
            path.addLine(to: CGPoint(x: x + w * 0.78, y: y + h * 0.2))
            path.move(to: CGPoint(x: x + w * 0.32, y: y + h * 0.22))
            path.addLine(to: CGPoint(x: x + w * 0.32, y: y + h * 0.78))
            path.move(to: CGPoint(x: x + w * 0.68, y: y + h * 0.22))
            path.addLine(to: CGPoint(x: x + w * 0.68, y: y + h * 0.78))
            path.move(to: CGPoint(x: x + w * 0.22, y: y + h * 0.8))
            path.addLine(to: CGPoint(x: x + w * 0.78, y: y + h * 0.8))
        case .karkat:
            path.addEllipse(in: CGRect(x: x + w * 0.12, y: y + h * 0.18, width: w * 0.34, height: h * 0.34))
            path.addEllipse(in: CGRect(x: x + w * 0.54, y: y + h * 0.48, width: w * 0.34, height: h * 0.34))
            path.move(to: CGPoint(x: x + w * 0.44, y: y + h * 0.35))
            path.addLine(to: CGPoint(x: x + w * 0.86, y: y + h * 0.35))
            path.move(to: CGPoint(x: x + w * 0.14, y: y + h * 0.65))
            path.addLine(to: CGPoint(x: x + w * 0.56, y: y + h * 0.65))
        case .simha:
            path.move(to: CGPoint(x: x + w * 0.28, y: y + h * 0.68))
            path.addCurve(to: CGPoint(x: x + w * 0.42, y: y + h * 0.2),
                          control1: CGPoint(x: x + w * 0.1, y: y + h * 0.48),
                          control2: CGPoint(x: x + w * 0.2, y: y + h * 0.18))
            path.addCurve(to: CGPoint(x: x + w * 0.66, y: y + h * 0.52),
                          control1: CGPoint(x: x + w * 0.76, y: y + h * 0.2),
                          control2: CGPoint(x: x + w * 0.66, y: y + h * 0.44))
            path.addCurve(to: CGPoint(x: x + w * 0.9, y: y + h * 0.74),
                          control1: CGPoint(x: x + w * 0.66, y: y + h * 0.72),
                          control2: CGPoint(x: x + w * 0.84, y: y + h * 0.78))
        case .kanya:
            path.move(to: CGPoint(x: x + w * 0.12, y: y + h * 0.72))
            path.addCurve(to: CGPoint(x: x + w * 0.28, y: y + h * 0.28),
                          control1: CGPoint(x: x + w * 0.16, y: y + h * 0.44),
                          control2: CGPoint(x: x + w * 0.2, y: y + h * 0.28))
            path.addCurve(to: CGPoint(x: x + w * 0.44, y: y + h * 0.72),
                          control1: CGPoint(x: x + w * 0.38, y: y + h * 0.28),
                          control2: CGPoint(x: x + w * 0.36, y: y + h * 0.6))
            path.addCurve(to: CGPoint(x: x + w * 0.62, y: y + h * 0.28),
                          control1: CGPoint(x: x + w * 0.5, y: y + h * 0.5),
                          control2: CGPoint(x: x + w * 0.52, y: y + h * 0.28))
            path.addCurve(to: CGPoint(x: x + w * 0.82, y: y + h * 0.74),
                          control1: CGPoint(x: x + w * 0.72, y: y + h * 0.28),
                          control2: CGPoint(x: x + w * 0.72, y: y + h * 0.72))
            path.addCurve(to: CGPoint(x: x + w * 0.58, y: y + h * 0.78),
                          control1: CGPoint(x: x + w * 0.76, y: y + h * 0.96),
                          control2: CGPoint(x: x + w * 0.58, y: y + h * 0.92))
        case .tula:
            path.move(to: CGPoint(x: x + w * 0.14, y: y + h * 0.72))
            path.addLine(to: CGPoint(x: x + w * 0.86, y: y + h * 0.72))
            path.move(to: CGPoint(x: x + w * 0.2, y: y + h * 0.56))
            path.addLine(to: CGPoint(x: x + w * 0.38, y: y + h * 0.56))
            path.addCurve(to: CGPoint(x: x + w * 0.62, y: y + h * 0.56),
                          control1: CGPoint(x: x + w * 0.38, y: y + h * 0.26),
                          control2: CGPoint(x: x + w * 0.62, y: y + h * 0.26))
            path.addLine(to: CGPoint(x: x + w * 0.8, y: y + h * 0.56))
        case .vrischik:
            path.move(to: CGPoint(x: x + w * 0.1, y: y + h * 0.72))
            path.addCurve(to: CGPoint(x: x + w * 0.28, y: y + h * 0.28),
                          control1: CGPoint(x: x + w * 0.14, y: y + h * 0.44),
                          control2: CGPoint(x: x + w * 0.2, y: y + h * 0.28))
            path.addCurve(to: CGPoint(x: x + w * 0.46, y: y + h * 0.72),
                          control1: CGPoint(x: x + w * 0.38, y: y + h * 0.28),
                          control2: CGPoint(x: x + w * 0.38, y: y + h * 0.6))
            path.addCurve(to: CGPoint(x: x + w * 0.64, y: y + h * 0.28),
                          control1: CGPoint(x: x + w * 0.52, y: y + h * 0.5),
                          control2: CGPoint(x: x + w * 0.54, y: y + h * 0.28))
            path.addLine(to: CGPoint(x: x + w * 0.64, y: y + h * 0.72))
            path.addLine(to: CGPoint(x: x + w * 0.88, y: y + h * 0.72))
            path.move(to: CGPoint(x: x + w * 0.78, y: y + h * 0.62))
            path.addLine(to: CGPoint(x: x + w * 0.88, y: y + h * 0.72))
            path.addLine(to: CGPoint(x: x + w * 0.78, y: y + h * 0.82))
        case .dhanu:
            path.move(to: CGPoint(x: x + w * 0.2, y: y + h * 0.8))
            path.addLine(to: CGPoint(x: x + w * 0.82, y: y + h * 0.18))
            path.move(to: CGPoint(x: x + w * 0.54, y: y + h * 0.18))
            path.addLine(to: CGPoint(x: x + w * 0.82, y: y + h * 0.18))
            path.addLine(to: CGPoint(x: x + w * 0.82, y: y + h * 0.46))
            path.move(to: CGPoint(x: x + w * 0.36, y: y + h * 0.48))
            path.addLine(to: CGPoint(x: x + w * 0.54, y: y + h * 0.66))
        case .makar:
            path.move(to: CGPoint(x: x + w * 0.14, y: y + h * 0.3))
            path.addLine(to: CGPoint(x: x + w * 0.36, y: y + h * 0.72))
            path.addLine(to: CGPoint(x: x + w * 0.52, y: y + h * 0.34))
            path.addCurve(to: CGPoint(x: x + w * 0.82, y: y + h * 0.68),
                          control1: CGPoint(x: x + w * 0.72, y: y + h * 0.14),
                          control2: CGPoint(x: x + w * 0.96, y: y + h * 0.46))
            path.addCurve(to: CGPoint(x: x + w * 0.56, y: y + h * 0.76),
                          control1: CGPoint(x: x + w * 0.72, y: y + h * 0.86),
                          control2: CGPoint(x: x + w * 0.58, y: y + h * 0.86))
        case .kumbha:
            path.move(to: CGPoint(x: x + w * 0.12, y: y + h * 0.38))
            path.addCurve(to: CGPoint(x: x + w * 0.88, y: y + h * 0.38),
                          control1: CGPoint(x: x + w * 0.32, y: y + h * 0.18),
                          control2: CGPoint(x: x + w * 0.68, y: y + h * 0.58))
            path.move(to: CGPoint(x: x + w * 0.12, y: y + h * 0.66))
            path.addCurve(to: CGPoint(x: x + w * 0.88, y: y + h * 0.66),
                          control1: CGPoint(x: x + w * 0.32, y: y + h * 0.46),
                          control2: CGPoint(x: x + w * 0.68, y: y + h * 0.86))
        case .meen:
            path.move(to: CGPoint(x: x + w * 0.24, y: y + h * 0.18))
            path.addCurve(to: CGPoint(x: x + w * 0.24, y: y + h * 0.82),
                          control1: CGPoint(x: x + w * 0.48, y: y + h * 0.34),
                          control2: CGPoint(x: x + w * 0.48, y: y + h * 0.66))
            path.move(to: CGPoint(x: x + w * 0.76, y: y + h * 0.18))
            path.addCurve(to: CGPoint(x: x + w * 0.76, y: y + h * 0.82),
                          control1: CGPoint(x: x + w * 0.52, y: y + h * 0.34),
                          control2: CGPoint(x: x + w * 0.52, y: y + h * 0.66))
            path.move(to: CGPoint(x: x + w * 0.2, y: y + h * 0.5))
            path.addLine(to: CGPoint(x: x + w * 0.8, y: y + h * 0.5))
        }
        return path
    }
}

/// Backward-compatible call site for older screens; visually it is now the
/// unframed rashi mark requested in the product critique.
struct RashiSeal: View {
    let rashi: Rashi
    var size: CGFloat = 56
    var body: some View {
        RashiIcon(rashi: rashi, size: size)
    }
}

/// The classic North-Indian diamond kundali chart, houses numbered from lagna.
struct KundaliChartView: View {
    @Environment(\.palette) private var p
    let chart: Kundali
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Path { path in
                    let r = CGRect(x: 0, y: 0, width: s, height: s)
                    path.addRect(r)
                    path.move(to: .zero); path.addLine(to: CGPoint(x: s, y: s))
                    path.move(to: CGPoint(x: s, y: 0)); path.addLine(to: CGPoint(x: 0, y: s))
                    path.move(to: CGPoint(x: s / 2, y: 0)); path.addLine(to: CGPoint(x: s, y: s / 2))
                    path.addLine(to: CGPoint(x: s / 2, y: s)); path.addLine(to: CGPoint(x: 0, y: s / 2))
                    path.closeSubpath()
                }
                .stroke(p.templeGold.opacity(0.7), lineWidth: 1.2)
                ForEach(0..<12, id: \.self) { house in
                    let pos = Self.houseCenters[house]
                    let sign = (chart.lagna.rawValue + house) % 12
                    VStack(spacing: 2) {
                        Text("\(sign + 1)")
                            .font(.system(size: s * 0.032, design: .serif))
                            .foregroundStyle(p.inkSecondary.opacity(0.8))
                        Text(chart.planetsInHouse(house).map(\.abbrev).joined(separator: " "))
                            .font(.system(size: s * 0.045, weight: .semibold, design: .serif))
                            .foregroundStyle(p.sindoor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: s * 0.22)
                    }
                    .position(x: pos.x * s, y: pos.y * s)
                }
            }
            .background(RoundedRectangle(cornerRadius: 4).fill(p.bgElevated))
        }
        .aspectRatio(1, contentMode: .fit)
    }
    // House 1 top-center diamond, then counter-clockwise (North-Indian convention).
    static let houseCenters: [CGPoint] = [
        .init(x: 0.5, y: 0.25), .init(x: 0.25, y: 0.10), .init(x: 0.10, y: 0.25),
        .init(x: 0.25, y: 0.5), .init(x: 0.10, y: 0.75), .init(x: 0.25, y: 0.90),
        .init(x: 0.5, y: 0.75), .init(x: 0.75, y: 0.90), .init(x: 0.90, y: 0.75),
        .init(x: 0.75, y: 0.5), .init(x: 0.90, y: 0.25), .init(x: 0.75, y: 0.10),
    ]
}
