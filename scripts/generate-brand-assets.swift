#!/usr/bin/env swift
import AppKit
import ImageIO
import UniformTypeIdentifiers

struct BrandAsset {
    let path: String
    let size: CGFloat
    let transparent: Bool
    let padding: CGFloat
}

let sourcePath = "assets/brand/jyotish-baje-logo-imagegen-transparent.png"
let sourceCopyPath = "assets/brand/jyotish-baje-swastika-logo-transparent.png"
let assets = [
    BrandAsset(path: "assets/brand/jyotish-baje-logo-1024.png", size: 1024, transparent: false, padding: 90),
    BrandAsset(path: "Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png", size: 1024, transparent: false, padding: 90),
    BrandAsset(path: "Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png", size: 1024, transparent: true, padding: 72),
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceURL = root.appendingPathComponent(sourcePath)
let sourceCopyURL = root.appendingPathComponent(sourceCopyPath)
let background = NSColor(calibratedRed: 0xFC / 255, green: 0xF7 / 255, blue: 0xED / 255, alpha: 1)

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
    fatalError("Missing source logo at \(sourcePath)")
}
guard let sourceCGImage = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fatalError("Could not decode source logo at \(sourcePath)")
}

try FileManager.default.createDirectory(
    at: sourceCopyURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try FileManager.default.copyItemReplacingExisting(at: sourceURL, to: sourceCopyURL)

for asset in assets {
    let outputURL = root.appendingPathComponent(asset.path)
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try render(sourceImage: sourceCGImage, asset: asset, outputURL: outputURL)
}

func render(sourceImage: CGImage, asset: BrandAsset, outputURL: URL) throws {
    let pixelSize = Int(asset.size)
    guard let context = CGContext(
        data: nil,
        width: pixelSize,
        height: pixelSize,
        bitsPerComponent: 8,
        bytesPerRow: pixelSize * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        fatalError("Could not create bitmap context for \(asset.path)")
    }
    context.interpolationQuality = .high
    context.setFillColor(asset.transparent ? NSColor.clear.cgColor : background.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: asset.size, height: asset.size))

    let drawRect = CGRect(
        x: asset.padding,
        y: asset.padding,
        width: asset.size - asset.padding * 2,
        height: asset.size - asset.padding * 2
    )
    context.draw(sourceImage, in: drawRect)

    guard let renderedImage = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("Could not render \(asset.path)")
    }
    CGImageDestinationAddImage(destination, renderedImage, nil)
    if !CGImageDestinationFinalize(destination) {
        fatalError("Could not write \(asset.path)")
    }
}

extension FileManager {
    func copyItemReplacingExisting(at source: URL, to destination: URL) throws {
        if fileExists(atPath: destination.path) {
            try removeItem(at: destination)
        }
        try copyItem(at: source, to: destination)
    }
}
