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

/// Circular "wax seal" for a rashi glyph, ringed in gold. The app's signature token.
struct RashiSeal: View {
    @Environment(\.palette) private var p
    let rashi: Rashi
    var size: CGFloat = 56
    var body: some View {
        ZStack {
            Circle().fill(
                RadialGradient(colors: [p.marigold.opacity(0.35), p.bgElevated],
                               center: .center, startRadius: 1, endRadius: size / 2))
            Circle().strokeBorder(p.templeGold.opacity(0.55), lineWidth: 1.2)
            Circle().strokeBorder(p.templeGold.opacity(0.3), lineWidth: 0.8)
                .padding(3)
            Text(rashi.glyph)
                .font(.system(size: size * 0.42, design: .serif))
                .foregroundStyle(p.sindoor)
        }
        .frame(width: size, height: size)
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
