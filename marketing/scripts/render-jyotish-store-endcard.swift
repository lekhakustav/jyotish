#!/usr/bin/env swift

import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 3 || arguments.count == 4 else {
    FileHandle.standardError.write(
        Data("Usage: render-jyotish-store-endcard.swift OUTPUT_PNG LOGO_PNG [transparent]\n".utf8)
    )
    exit(2)
}

let outputPath = arguments[1]
let logoPath = arguments[2]
let transparentBackground = arguments.count == 4 && arguments[3] == "transparent"
let canvasSize = NSSize(width: 720, height: 1280)

guard let logo = NSImage(contentsOfFile: logoPath) else {
    FileHandle.standardError.write(Data("Could not load logo: \(logoPath)\n".utf8))
    exit(3)
}

func color(_ red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat(red) / 255,
        green: CGFloat(green) / 255,
        blue: CGFloat(blue) / 255,
        alpha: alpha
    )
}

func drawCentered(
    _ text: String,
    top: CGFloat,
    font: NSFont,
    foreground: NSColor,
    canvasHeight: CGFloat
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let lineHeight = font.pointSize * 1.35
    let rect = NSRect(
        x: 40,
        y: canvasHeight - top - lineHeight,
        width: 640,
        height: lineHeight
    )
    (text as NSString).draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: foreground,
            .paragraphStyle: paragraph,
        ]
    )
}

let image = NSImage(size: canvasSize)
image.lockFocus()

if !transparentBackground {
    color(250, 246, 239).setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: canvasSize)).fill()
}

let logoRect = NSRect(x: 210, y: 820, width: 300, height: 300)
logo.draw(
    in: logoRect,
    from: .zero,
    operation: .sourceOver,
    fraction: 1,
    respectFlipped: true,
    hints: [.interpolation: NSImageInterpolation.high]
)

let titleFont =
    NSFont(name: "AvenirNext-Bold", size: 74)
    ?? NSFont.systemFont(ofSize: 74, weight: .bold)

drawCentered(
    "Jyotish Baje",
    top: 445,
    font: titleFont,
    foreground: color(30, 24, 20),
    canvasHeight: canvasSize.height
)
drawCentered(
    "AI-powered Jyotish App",
    top: 555,
    font: .systemFont(ofSize: 30, weight: .medium),
    foreground: color(110, 100, 92),
    canvasHeight: canvasSize.height
)
drawCentered(
    "Coming soon",
    top: 660,
    font: .systemFont(ofSize: 22, weight: .regular),
    foreground: color(150, 140, 132),
    canvasHeight: canvasSize.height
)

// Apple mark, drawn in near-black ink, no button chrome.
func drawAppleGlyph(center: NSPoint, pointSize: CGFloat, fill: NSColor) {
    guard let symbol = NSImage(
        systemSymbolName: "apple.logo",
        accessibilityDescription: nil
    ) else { return }
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
    guard let tinted = symbol.withSymbolConfiguration(config) else { return }
    let size = tinted.size
    let rect = NSRect(
        x: center.x - size.width / 2,
        y: center.y - size.height / 2,
        width: size.width,
        height: size.height
    )
    fill.set()
    tinted.isTemplate = true
    tinted.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
}

// Simplified four-color Play triangle mark, no button chrome.
func drawPlayGlyph(center: NSPoint, size: CGFloat) {
    let half = size / 2
    let top = NSPoint(x: center.x - half * 0.6, y: center.y + half)
    let bottom = NSPoint(x: center.x - half * 0.6, y: center.y - half)
    let right = NSPoint(x: center.x + half, y: center.y)
    let leftMid = NSPoint(x: center.x - half * 0.6, y: center.y)

    func quadrant(_ p1: NSPoint, _ p2: NSPoint, _ p3: NSPoint, _ fill: NSColor) {
        let path = NSBezierPath()
        path.move(to: p1)
        path.line(to: p2)
        path.line(to: p3)
        path.close()
        fill.setFill()
        path.fill()
    }

    quadrant(top, leftMid, right, color(0, 172, 193))
    quadrant(leftMid, bottom, right, color(56, 142, 60))
    quadrant(top, leftMid, NSPoint(x: leftMid.x, y: top.y), color(255, 193, 7))
    let redPoint = NSPoint(x: right.x, y: right.y + (top.y - right.y) * 0.02)
    quadrant(top, redPoint, right, color(229, 57, 53))
}

let markY: CGFloat = 490
drawAppleGlyph(
    center: NSPoint(x: canvasSize.width / 2 - 70, y: markY),
    pointSize: 56,
    fill: color(30, 24, 20)
)
drawPlayGlyph(
    center: NSPoint(x: canvasSize.width / 2 + 70, y: markY),
    size: 52
)

image.unlockFocus()

guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData),
    let pngData = bitmap.representation(using: .png, properties: [:])
else {
    FileHandle.standardError.write(Data("Could not encode end card PNG\n".utf8))
    exit(4)
}

let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try pngData.write(to: outputURL, options: .atomic)
print(outputPath)
