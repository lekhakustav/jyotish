import AppKit
import Foundation

struct Shot {
    let source: String
    let output: String
    let title: String
    let subtitle: String
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceDir = root.appendingPathComponent("screenshots/appstore-nepali-native-2026-07-07")
let outputDir = root.appendingPathComponent("screenshots/appstore-nepali-formatted-2026-07-07")
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let shots: [Shot] = [
    Shot(source: "01-home-native.png", output: "01-home-appstore.png", title: "दैनिक ज्योतिष, मन्दिर र पात्रो", subtitle: "घर, राशि र आजको पञ्चाङ्ग एउटै ठाउँमा।"),
    Shot(source: "02-rashifal-daily-native.png", output: "02-rashifal-daily-appstore.png", title: "आजको राशिफल नेपालीमा", subtitle: "राशि अनुसार शुभ रंग, अंक र उपाय।"),
    Shot(source: "03-rashifal-weekly-native.png", output: "03-rashifal-weekly-appstore.png", title: "साप्ताहिक दिशा र उपाय", subtitle: "परिवार, स्वास्थ्य, धन र प्रेमको संकेत।"),
    Shot(source: "04-rashifal-singha-native.png", output: "04-rashifal-singha-appstore.png", title: "१२ राशिका फलादेश", subtitle: "हरेक राशिका लागि स्पष्ट, उपयोगी सुझाव।"),
    Shot(source: "05-family-native.png", output: "05-family-appstore.png", title: "परिवारको कुण्डली साथमा", subtitle: "आफू र परिवारका जन्म विवरण सुरक्षित राख्नुहोस्।"),
    Shot(source: "06-family-kundali-native.png", output: "06-kundali-appstore.png", title: "कुण्डली र फलादेश", subtitle: "लग्न, राशि, नक्षत्र र ग्रह स्थिति सजिलै हेर्नुहोस्।"),
    Shot(source: "07-family-dasha-native.png", output: "07-dasha-appstore.png", title: "महादशा समयरेखा", subtitle: "जीवनका चरणहरू नेपाली वर्षमा बुझ्नुहोस्।"),
    Shot(source: "08-patro-month-native.png", output: "08-patro-month-appstore.png", title: "नेपाली पात्रो", subtitle: "तिथि, पर्व र पारिवारिक कार्यक्रमहरू।"),
    Shot(source: "09-patro-day-native.png", output: "09-patro-day-appstore.png", title: "दिनको पञ्चाङ्ग", subtitle: "तिथि, नक्षत्र, योग र करण एकै दृश्यमा।"),
    Shot(source: "10-pandit-chat-empty-native.png", output: "10-pandit-chat-appstore.png", title: "पण्डितजीसँग सोध्नुहोस्", subtitle: "वास्तु, रंग, शहर र दशाबारे नेपालीमा कुरा गर्नुहोस्।"),
    Shot(source: "11-pandit-chat-answer-native.png", output: "11-pandit-answer-appstore.png", title: "व्यक्तिगत उत्तरहरू", subtitle: "कुण्डली सन्दर्भसँग मिलेको सरल ज्योतिष सुझाव।"),
    Shot(source: "12-settings-native.png", output: "12-settings-appstore.png", title: "नेपाली अनुभव", subtitle: "भाषा र रूप आफ्नो परिवारका लागि मिलाउनुहोस्।"),
]

let canvasSize = NSSize(width: 1290, height: 2796)
let background = NSColor(calibratedRed: 0.988, green: 0.965, blue: 0.914, alpha: 1)
let sindoor = NSColor(calibratedRed: 0.72, green: 0.20, blue: 0.13, alpha: 1)
let ink = NSColor(calibratedRed: 0.19, green: 0.10, blue: 0.075, alpha: 1)
let muted = NSColor(calibratedRed: 0.45, green: 0.35, blue: 0.29, alpha: 1)
let phoneShadow = NSShadow()
phoneShadow.shadowColor = NSColor.black.withAlphaComponent(0.20)
phoneShadow.shadowBlurRadius = 38
phoneShadow.shadowOffset = NSSize(width: 0, height: -18)

func drawText(_ text: String, in rect: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor, alignment: NSTextAlignment = .center) {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    style.lineBreakMode = .byWordWrapping
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style,
        .kern: 0
    ]
    NSString(string: text).draw(in: rect, withAttributes: attrs)
}

func roundedPath(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

for shot in shots {
    let inputURL = sourceDir.appendingPathComponent(shot.source)
    guard let sourceImage = NSImage(contentsOf: inputURL) else {
        fputs("Missing image: \(inputURL.path)\n", stderr)
        exit(1)
    }

    let image = NSImage(size: canvasSize)
    image.lockFocus()

    background.setFill()
    NSRect(origin: .zero, size: canvasSize).fill()

    drawText("Jyotish baje", in: NSRect(x: 120, y: 2560, width: 1050, height: 80), size: 44, weight: .semibold, color: sindoor)
    drawText(shot.title, in: NSRect(x: 110, y: 2378, width: 1070, height: 150), size: 82, weight: .bold, color: ink)
    drawText(shot.subtitle, in: NSRect(x: 170, y: 2278, width: 950, height: 86), size: 38, weight: .medium, color: muted)

    let phoneRect = NSRect(x: 150, y: 150, width: 990, height: 2152)
    NSGraphicsContext.current?.saveGraphicsState()
    phoneShadow.set()
    NSColor.black.withAlphaComponent(0.08).setFill()
    roundedPath(phoneRect.insetBy(dx: -18, dy: -18), radius: 96).fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    NSColor.white.setFill()
    roundedPath(phoneRect, radius: 78).fill()

    NSGraphicsContext.current?.saveGraphicsState()
    roundedPath(phoneRect, radius: 78).addClip()
    sourceImage.draw(in: phoneRect, from: NSRect(origin: .zero, size: sourceImage.size), operation: .copy, fraction: 1)
    NSGraphicsContext.current?.restoreGraphicsState()

    NSColor(calibratedWhite: 1, alpha: 0.9).setStroke()
    let stroke = roundedPath(phoneRect, radius: 78)
    stroke.lineWidth = 6
    stroke.stroke()

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fputs("Failed to render \(shot.output)\n", stderr)
        exit(1)
    }
    try png.write(to: outputDir.appendingPathComponent(shot.output))
}

print(outputDir.path)
