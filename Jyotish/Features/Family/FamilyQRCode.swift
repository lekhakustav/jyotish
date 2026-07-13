import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct FamilySharePayload: Codable, Equatable {
    var version = 1
    var name: String
    var gender: Gender
    var birth: BirthData

    init(member: FamilyMember) throws {
        guard let birth = member.birth else { throw FamilyShareError.missingBirthData }
        name = member.name
        gender = member.gender
        self.birth = birth
    }

    func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        let value = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return "jyotishbaje://family/add?payload=\(value)"
    }

    static func decode(_ raw: String) throws -> FamilySharePayload {
        guard let components = URLComponents(string: raw),
              components.scheme == "jyotishbaje",
              components.host == "family",
              components.path == "/add",
              let value = components.queryItems?.first(where: { $0.name == "payload" })?.value else {
            throw FamilyShareError.invalidCode
        }
        var base64 = value.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64) else { throw FamilyShareError.invalidCode }
        let payload = try JSONDecoder().decode(FamilySharePayload.self, from: data)
        guard payload.version == 1, !payload.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw FamilyShareError.unsupportedVersion
        }
        return payload
    }
}

enum FamilyShareError: LocalizedError {
    case missingBirthData, invalidCode, unsupportedVersion

    var errorDescription: String? {
        switch self {
        case .missingBirthData: return "A complete birth profile is required to make a family QR code."
        case .invalidCode: return "This is not a valid Jyotish Parivar QR code."
        case .unsupportedVersion: return "This Parivar code was created by an unsupported app version."
        }
    }
}

struct FamilyQRCodeSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer(minLength: 32)
                Text(app.language == .ne ? "मेरो परिवार QR" : "My Parivar QR")
                    .scaledFont(size: 28, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                if let member = app.selfMember,
                   let payload = try? FamilySharePayload(member: member),
                   let string = try? payload.encodedString(),
                   let image = QRCodeRenderer.image(from: string) {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260, maxHeight: 260)
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 22).fill(.white))
                        .accessibilityLabel(app.language == .ne ? "मेरो जन्म विवरण थप्ने QR कोड" : "QR code for adding my birth profile")
                    Text(member.name)
                        .scaledFont(size: 21, weight: .semibold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Text(app.language == .ne
                         ? "यो कोडले तपाईंको नाम र जन्म विवरण साझा गर्छ। विश्वास गर्ने व्यक्तिलाई मात्र देखाउनुहोस्।"
                         : "This code shares your name and birth details. Show it only to someone you trust.")
                        .scaledFont(size: 14, design: .serif)
                        .foregroundStyle(p.inkSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    ShareLink(item: string) {
                        Label(app.language == .ne ? "कोड साझा गर्नुहोस्" : "Share code", systemImage: "square.and.arrow.up")
                            .scaledFont(size: 16, weight: .semibold)
                            .foregroundStyle(p.saffron)
                            .frame(minHeight: 48)
                    }
                } else {
                    Text(app.language == .ne ? "पहिले आफ्नो पूरा जन्म विवरण सुरक्षित गर्नुहोस्।" : "Save your complete birth profile first.")
                        .scaledFont(size: 17, design: .serif)
                        .foregroundStyle(p.inkSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, LayoutMetrics.sheetGutter)
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDetents([.large])
    }
}

private enum QRCodeRenderer {
    static func image(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

struct FamilyQRScannerSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @State private var rawCode = ""
    @State private var payload: FamilySharePayload?
    @State private var relation: Relation = .friend
    @State private var error: String?

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(app.language == .ne ? "परिवार QR स्क्यान" : "Scan Parivar QR")
                        .scaledFont(size: 28, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .padding(.top, 42)

                    if let payload {
                        importForm(payload)
                    } else {
                        QRCodeScannerView { scanned in
                            rawCode = scanned
                            decode()
                        }
                        .frame(height: 330)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(alignment: .bottom) {
                            Text(app.language == .ne ? "Jyotish Parivar QR लाई फ्रेमभित्र राख्नुहोस्" : "Place a Jyotish Parivar QR inside the frame")
                                .scaledFont(size: 13, weight: .medium)
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.black.opacity(0.55), in: Capsule())
                                .padding(12)
                        }
                        TextField(app.language == .ne ? "वा साझा कोड टाँस्नुहोस्" : "Or paste a shared code", text: $rawCode)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .scaledFont(size: 14)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))
                        Button(app.language == .ne ? "कोड खोल्नुहोस्" : "Open code") { decode() }
                            .buttonStyle(.bordered)
                            .tint(p.saffron)
                    }

                    if let error {
                        Text(error)
                            .scaledFont(size: 14)
                            .foregroundStyle(p.sindoor)
                    }
                }
                .padding(.horizontal, LayoutMetrics.sheetGutter)
                .padding(.bottom, 30)
            }
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDetents([.large])
    }

    private func importForm(_ payload: FamilySharePayload) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(payload.name, systemImage: "person.crop.circle.badge.checkmark")
                .scaledFont(size: 22, weight: .semibold, design: .serif)
                .foregroundStyle(p.inkPrimary)
            Text(app.language == .ne ? "तपाईंको नाता छान्नुहोस्" : "Choose how you know this person")
                .scaledFont(size: 15, weight: .semibold)
                .foregroundStyle(p.inkSecondary)
            Picker(app.language == .ne ? "नाता" : "Relationship", selection: $relation) {
                ForEach(Relation.allCases.filter { $0 != .selfMember }) { value in
                    Text(app.language == .ne ? value.labelNE : value.labelEN).tag(value)
                }
            }
            .pickerStyle(.navigationLink)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(p.bgSunken))
            Text(app.language == .ne
                 ? "नाम र जन्म विवरण तपाईंको निजी परिवार खातामा सुरक्षित हुनेछ।"
                 : "Their name and birth details will be saved in your private household.")
                .scaledFont(size: 14, design: .serif)
                .foregroundStyle(p.inkSecondary)
            PrimaryButton(title: app.language == .ne ? "परिवारमा थप्नुहोस्" : "Add to Parivar", icon: "person.badge.plus") {
                let added = app.addSharedMember(name: payload.name, gender: payload.gender,
                                                relation: relation, birth: payload.birth)
                if added { dismiss() }
                else { error = app.language == .ne ? "यो व्यक्ति पहिले नै परिवारमा छ।" : "This person is already in Parivar." }
            }
            Button(app.language == .ne ? "अर्को कोड स्क्यान" : "Scan another code") {
                self.payload = nil
                rawCode = ""
                error = nil
            }
            .foregroundStyle(p.saffron)
        }
    }

    private func decode() {
        do {
            payload = try FamilySharePayload.decode(rawCode.trimmingCharacters(in: .whitespacesAndNewlines))
            error = nil
            Haptics.success()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

private struct QRCodeScannerView: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onCode = onCode
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

private final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?
    private let session = AVCaptureSession()
    private var preview: AVCaptureVideoPreviewLayer?
    private var delivered = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            DispatchQueue.main.async { self?.configure() }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        self.preview = preview
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in self?.session.startRunning() }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !delivered,
              let code = metadataObjects.compactMap({ ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue }).first else { return }
        delivered = true
        session.stopRunning()
        onCode?(code)
    }
}
