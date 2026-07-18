#!/usr/bin/env swift

import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    FileHandle.standardError.write(
        Data("Usage: render-jyotish-store-endcard.swift OUTPUT_PNG LOGO_PNG\n".utf8)
    )
    exit(2)
}

let outputPath = arguments[1]
let logoPath = arguments[2]
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

color(250, 246, 239).setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: canvasSize)).fill()

let logoRect = NSRect(x: 225, y: 860, width: 270, height: 270)
logo.draw(
    in: logoRect,
    from: .zero,
    operation: .sourceOver,
    fraction: 1,
    respectFlipped: true,
    hints: [.interpolation: NSImageInterpolation.high]
)

drawCentered(
    "Jyotish Baje",
    top: 470,
    font: .systemFont(ofSize: 52, weight: .semibold),
    foreground: color(38, 31, 27),
    canvasHeight: canvasSize.height
)
drawCentered(
    "Understand each other better.",
    top: 550,
    font: .systemFont(ofSize: 30, weight: .regular),
    foreground: color(102, 92, 85),
    canvasHeight: canvasSize.height
)
drawCentered(
    "Coming soon to",
    top: 705,
    font: .systemFont(ofSize: 26, weight: .medium),
    foreground: color(138, 61, 47),
    canvasHeight: canvasSize.height
)

let buttonColor = color(38, 31, 27)
let appStoreRect = NSRect(x: 82, y: 426, width: 260, height: 84)
let googlePlayRect = NSRect(x: 378, y: 426, width: 260, height: 84)
buttonColor.setFill()
NSBezierPath(roundedRect: appStoreRect, xRadius: 18, yRadius: 18).fill()
NSBezierPath(roundedRect: googlePlayRect, xRadius: 18, yRadius: 18).fill()

func drawButton(_ text: String, rect: NSRect, size: CGFloat) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    (text as NSString).draw(
        in: NSRect(x: rect.minX, y: rect.minY + 22, width: rect.width, height: 42),
        withAttributes: [
            .font: NSFont.systemFont(ofSize: size, weight: .semibold),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraph,
        ]
    )
}

drawButton("App Store", rect: appStoreRect, size: 30)
drawButton("Google Play", rect: googlePlayRect, size: 28)

drawCentered(
    "iOS  •  Android",
    top: 905,
    font: .systemFont(ofSize: 23, weight: .regular),
    foreground: color(138, 129, 122),
    canvasHeight: canvasSize.height
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
