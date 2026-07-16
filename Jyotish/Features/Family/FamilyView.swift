import SwiftUI

/// Reports a tree node's horizontal center, in the shared "familyTree"
/// coordinate space, so connector lines can target the exact rendered
/// position instead of assuming the row is evenly spread across full width.
private struct TreeNodeXKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private extension View {
    func reportTreeX(_ key: String) -> some View {
        background(GeometryReader { g in
            Color.clear.preference(key: TreeNodeXKey.self, value: [key: g.frame(in: .named("familyTree")).midX])
        })
    }
}

struct FamilyView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showAdd = false
    @State private var showMyQR = ProcessInfo.processInfo.arguments.contains("-showMyQR")
    @State private var showScanner = false
    @State private var nodeX: [String: CGFloat] = [:]
    @State private var path: [UUID] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                p.bgCanvas.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(app.t("family.title"))
                                .scaledFont(size: 34, weight: .bold, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Spacer()
                            addButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        Text(app.language == .ne
                             ? "आफ्नो कुण्डली निजी रूपमा राख्नुहोस् र आफूले रोजेको व्यक्तिसँग मात्र QR मार्फत साझा गर्नुहोस्।"
                             : "Keep your Kundli private and share it by QR only with people you choose.")
                            .scaledFont(size: 15, design: .serif)
                            .foregroundStyle(p.inkSecondary)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                        qrActions
                            .padding(.horizontal, 20)
                        if hasRelatives {
                            familyTree.fadeRise()
                        }
                        memberList.fadeRise(delay: 0.1)
                    }
                    .padding(.bottom, 96)
                }
            }
            .statusBarFade()
            .sheet(isPresented: $showAdd) { AddMemberSheet() }
            .sheet(isPresented: $showMyQR) { FamilyQRCodeSheet() }
            .sheet(isPresented: $showScanner) { FamilyQRScannerSheet() }
            .navigationDestination(for: UUID.self) { id in
                if let m = app.family.first(where: { $0.id == id }) {
                    MemberDetailView(memberID: m.id)
                }
            }
            .onAppear { openRequestedMember(app.requestedFamilyMemberID) }
            .onChange(of: app.requestedFamilyMemberID) { _, id in openRequestedMember(id) }
        }
    }

    private func openRequestedMember(_ id: UUID?) {
        guard let id, app.family.contains(where: { $0.id == id }) else { return }
        path = [id]
    }

    private var hasRelatives: Bool {
        app.family.contains { $0.relation != .selfMember }
    }

    private var addButton: some View {
        Button { showAdd = true } label: {
            Image(systemName: "plus.circle.fill")
                .scaledFont(size: 28)
                .foregroundStyle(p.saffron)
                .frame(width: 48, height: 48)
        }
        .accessibilityLabel(app.t("family.add"))
    }

    private var qrActions: some View {
        HStack(spacing: 10) {
            qrAction(title: app.language == .ne ? "कुण्डली QR स्क्यान" : "Scan Kundli QR",
                     icon: "qrcode.viewfinder") {
                AppAnalytics.track("parivar_qr_scanner_opened")
                showScanner = true
            }
            qrAction(title: app.language == .ne ? "मेरो कुण्डली साझा" : "Share My Kundli",
                     icon: "qrcode") {
                AppAnalytics.track("parivar_qr_shown")
                showMyQR = true
            }
        }
    }

    private func qrAction(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Label(title, systemImage: icon)
                .scaledFont(size: 14, weight: .semibold)
                .foregroundStyle(p.saffron)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 14).fill(p.bgSunken))
        }
        .buttonStyle(SpringPressStyle())
    }

    /// A top-to-bottom family tree so parent/child placement is obvious and
    /// connector lines never cross the name labels.
    private var familyTree: some View {
        let parents = app.family.filter { [.father, .mother, .grandfather, .grandmother].contains($0.relation) }
        let partners = app.family.filter { [.husband, .wife, .boyfriend, .girlfriend,
                                            .partner, .fiance, .fiancee].contains($0.relation) }
        let siblings = app.family.filter { [.brother, .sister, .friend, .colleague, .mentor].contains($0.relation) }
        let children = app.family.filter { [.son, .daughter].contains($0.relation) }
        let grandchildren = app.family.filter { [.grandson, .granddaughter].contains($0.relation) }

        let parentXs = (0..<parents.count).compactMap { nodeX["parent-\($0)"] }
        let childXs = (0..<children.count).compactMap { nodeX["child-\($0)"] }
        let grandchildXs = (0..<grandchildren.count).compactMap { nodeX["grandchild-\($0)"] }
        let selfX = nodeX["self"].map { [$0] } ?? []

        return VStack(spacing: 10) {
            if !parents.isEmpty {
                treeRow(parents, keyPrefix: "parent")
                TreeBranch(upperX: parentXs, lowerX: selfX)
                    .frame(height: 34)
            }

            VStack(spacing: 12) {
                familyNode(for: app.selfMember, relation: app.t("common.you"), size: 72)
                    .reportTreeX("self")
                if !partners.isEmpty || !siblings.isEmpty {
                    treeRow(partners + siblings, keyPrefix: "partner", size: 58)
                }
            }

            if !children.isEmpty {
                TreeBranch(upperX: selfX, lowerX: childXs)
                    .frame(height: 38)
                treeRow(children, keyPrefix: "child")
            }

            if !grandchildren.isEmpty {
                TreeBranch(upperX: children.isEmpty ? selfX : childXs, lowerX: grandchildXs)
                    .frame(height: 38)
                treeRow(grandchildren, keyPrefix: "grandchild", size: 60)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
        .coordinateSpace(name: "familyTree")
        .onPreferenceChange(TreeNodeXKey.self) { nodeX = $0 }
    }

    private func treeRow(_ members: [FamilyMember], keyPrefix: String, size: CGFloat = 64) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Array(members.enumerated()), id: \.element.id) { i, m in
                    NavigationLink(value: m.id) {
                        familyNode(for: m, relation: relationText(for: m), size: size)
                            .reportTreeX("\(keyPrefix)-\(i)")
                    }
                    .buttonStyle(SpringPressStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
    }

    private func relationText(for member: FamilyMember) -> String {
        app.language == .ne ? member.relation.labelNE : member.relation.labelEN
    }

    private func familyNode(for member: FamilyMember?, relation: String, size: CGFloat) -> some View {
        VStack(spacing: 5) {
            Image(systemName: relationSymbol(for: member))
                .scaledFont(size: size * 0.3, weight: .light)
                .foregroundStyle(p.saffron)
                .frame(width: size, height: size)
                .background(Circle().fill(p.bgSunken))
            VStack(spacing: 1) {
                Text(member?.displayName(app.language) ?? app.t("common.you"))
                    .scaledFont(size: 13, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(relation)
                    .scaledFont(size: 13)
                    .foregroundStyle(p.inkSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(width: size + 34)
        .contentShape(Rectangle())
    }

    private func relationSymbol(for member: FamilyMember?) -> String {
        switch member?.relation {
        case .son, .daughter, .grandson, .granddaughter,
             .bhatija, .bhatiji, .bhanja, .bhanji:
            return "figure.child"
        case .husband, .wife, .boyfriend, .girlfriend, .partner, .fiance, .fiancee:
            return "person.2"
        case .father, .mother, .grandfather, .grandmother,
             .kaka, .kaki, .thuloBaa, .thuloAma, .phupu, .phupaju,
             .mama, .maiju, .saniAma, .thuliAma, .sasura, .sasu:
            return "person.fill"
        case .brother, .sister, .friend, .colleague, .mentor,
             .jethaju, .devar, .jethani, .devrani, .nanad,
             .saala, .saali, .bhinaju, .bhauju, .buhari, .jwaai, .cousin:
            return "person"
        case .selfMember, nil:
            return "person.crop.circle"
        }
    }

    private var memberList: some View {
        VStack(spacing: 0) {
            ForEach(Array(app.family.enumerated()), id: \.element.id) { i, m in
                NavigationLink(value: m.id) {
                    HStack(spacing: 14) {
                        if let k = m.kundali {
                            RashiSeal(rashi: k.moonRashi, size: 46)
                        } else {
                            Circle().strokeBorder(p.templeGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .frame(width: 46, height: 46)
                                .overlay(Image(systemName: "person").foregroundStyle(p.inkSecondary))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(m.displayName(app.language))
                                .scaledFont(size: 18, weight: .semibold, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Text(m.relation == .selfMember
                                 ? app.t("common.you")
                                 : (app.language == .ne ? m.relation.labelNE : m.relation.labelEN))
                                .scaledFont(size: 13)
                                .foregroundStyle(p.inkSecondary)
                        }
                        Spacer()
                        if m.kundali != nil {
                            Label(app.t("family.seeKundli"), systemImage: "square.grid.3x3")
                                .scaledFont(size: 13, weight: .semibold)
                                .foregroundStyle(p.sindoor)
                                .padding(.horizontal, 11)
                                .frame(minHeight: 40)
                                .background(Capsule().fill(p.bgSunken))
                        }
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(SpringPressStyle())
                if i < app.family.count - 1 { Hairline() }
            }
        }
        .padding(.horizontal, 24)
    }
}

/// Draws connectors from the measured centers of the row above to the
/// measured centers of the row below, so lines always meet the node they
/// point at rather than an assumed even split of the available width.
private struct TreeBranch: View {
    @Environment(\.palette) private var p
    let upperX: [CGFloat]
    let lowerX: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let originX = geo.frame(in: .named("familyTree")).minX
            let upper = upperX.map { $0 - originX }
            let lower = lowerX.map { $0 - originX }
            Path { path in
                let h = geo.size.height
                let midY = h * 0.48

                for x in upper {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: midY))
                }
                let bridge = upper + lower
                if let minX = bridge.min(), let maxX = bridge.max(), bridge.count > 1 {
                    path.move(to: CGPoint(x: minX, y: midY))
                    path.addLine(to: CGPoint(x: maxX, y: midY))
                }
                for x in lower {
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: h))
                }
            }
            .stroke(p.templeGold.opacity(0.34), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        }
        .accessibilityHidden(true)
    }
}

/// Adding a family member uses the same paged flow, prefixed with a relation step.
struct AddMemberSheet: View {
    var body: some View {
        BirthFlowView(mode: .familyMember)
            .presentationDragIndicator(.visible)
    }
}
