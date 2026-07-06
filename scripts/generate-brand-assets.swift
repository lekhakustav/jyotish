#!/usr/bin/env swift
import AppKit

struct BrandAsset {
    let path: String
    let size: CGFloat
    let transparent: Bool
}

let assets = [
    BrandAsset(path: "assets/brand/jyotish-baje-logo-1024.png", size: 1024, transparent: false),
    BrandAsset(path: "assets/brand/jyotish-baje-swastika-logo-transparent.png", size: 1254, transparent: true),
    BrandAsset(path: "Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png", size: 1024, transparent: false),
    BrandAsset(path: "Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png", size: 1024, transparent: true),
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

for asset in assets {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(asset.size),
        pixelsHigh: Int(asset.size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Could not create bitmap for \(asset.path)")
    }
    rep.size = NSSize(width: asset.size, height: asset.size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawLogo(size: asset.size, transparent: asset.transparent)
    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("Could not render \(asset.path)")
    }
    try png.write(to: root.appendingPathComponent(asset.path))
}

func drawLogo(size: CGFloat, transparent: Bool) {
    let scale = size / 1024
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let background = NSColor(calibratedRed: 0xFC / 255, green: 0xF7 / 255, blue: 0xED / 255, alpha: 1)
    let sindoor = NSColor(calibratedRed: 0xB9 / 255, green: 0x33 / 255, blue: 0x1F / 255, alpha: 1)
    let templeGold = NSColor(calibratedRed: 0xB8 / 255, green: 0x86 / 255, blue: 0x0B / 255, alpha: 1)

    if transparent {
        NSColor.clear.setFill()
    } else {
        background.setFill()
    }
    rect.fill()

    let c = CGPoint(x: size / 2, y: size / 2)
    let arm = 226 * scale
    let bend = 236 * scale
    let stroke = 112 * scale
    let terminalInset = 18 * scale

    let path = NSBezierPath()
    path.lineWidth = stroke
    path.lineCapStyle = .round
    path.lineJoinStyle = .round

    path.move(to: c)
    path.line(to: CGPoint(x: c.x, y: c.y + arm))
    path.line(to: CGPoint(x: c.x + bend, y: c.y + arm))
    path.curve(to: CGPoint(x: c.x + bend + terminalInset, y: c.y + arm + terminalInset),
               controlPoint1: CGPoint(x: c.x + bend + terminalInset * 0.75, y: c.y + arm),
               controlPoint2: CGPoint(x: c.x + bend + terminalInset, y: c.y + arm + terminalInset * 0.25))

    path.move(to: c)
    path.line(to: CGPoint(x: c.x + arm, y: c.y))
    path.line(to: CGPoint(x: c.x + arm, y: c.y - bend))
    path.curve(to: CGPoint(x: c.x + arm + terminalInset, y: c.y - bend - terminalInset),
               controlPoint1: CGPoint(x: c.x + arm, y: c.y - bend - terminalInset * 0.75),
               controlPoint2: CGPoint(x: c.x + arm + terminalInset * 0.25, y: c.y - bend - terminalInset))

    path.move(to: c)
    path.line(to: CGPoint(x: c.x, y: c.y - arm))
    path.line(to: CGPoint(x: c.x - bend, y: c.y - arm))
    path.curve(to: CGPoint(x: c.x - bend - terminalInset, y: c.y - arm - terminalInset),
               controlPoint1: CGPoint(x: c.x - bend - terminalInset * 0.75, y: c.y - arm),
               controlPoint2: CGPoint(x: c.x - bend - terminalInset, y: c.y - arm - terminalInset * 0.25))

    path.move(to: c)
    path.line(to: CGPoint(x: c.x - arm, y: c.y))
    path.line(to: CGPoint(x: c.x - arm, y: c.y + bend))
    path.curve(to: CGPoint(x: c.x - arm - terminalInset, y: c.y + bend + terminalInset),
               controlPoint1: CGPoint(x: c.x - arm, y: c.y + bend + terminalInset * 0.75),
               controlPoint2: CGPoint(x: c.x - arm - terminalInset * 0.25, y: c.y + bend + terminalInset))

    templeGold.withAlphaComponent(0.9).setStroke()
    path.lineWidth = stroke + 20 * scale
    path.stroke()
    sindoor.setStroke()
    path.lineWidth = stroke
    path.stroke()

    let dotRadius = 26 * scale
    for point in [
        CGPoint(x: c.x - 116 * scale, y: c.y + 116 * scale),
        CGPoint(x: c.x + 116 * scale, y: c.y + 116 * scale),
        CGPoint(x: c.x - 116 * scale, y: c.y - 116 * scale),
        CGPoint(x: c.x + 116 * scale, y: c.y - 116 * scale),
    ] {
        let dot = CGRect(x: point.x - dotRadius, y: point.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
        templeGold.setFill()
        NSBezierPath(ovalIn: dot.insetBy(dx: -8 * scale, dy: -8 * scale)).fill()
        sindoor.setFill()
        NSBezierPath(ovalIn: dot).fill()
    }
}
