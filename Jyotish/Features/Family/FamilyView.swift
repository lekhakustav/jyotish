import SwiftUI

struct FamilyView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
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
            .navigationDestination(for: UUID.self) { id in
                if let m = app.family.first(where: { $0.id == id }) {
                    MemberDetailView(memberID: m.id)
                }
            }
        }
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

    /// A top-to-bottom family tree so parent/child placement is obvious and
    /// connector lines never cross the name labels.
    private var familyTree: some View {
        let parents = app.family.filter { [.father, .mother, .grandfather, .grandmother].contains($0.relation) }
        let partners = app.family.filter { [.husband, .wife].contains($0.relation) }
        let siblings = app.family.filter { [.brother, .sister].contains($0.relation) }
        let children = app.family.filter { [.son, .daughter].contains($0.relation) }
        let grandchildren = app.family.filter { [.grandson, .granddaughter].contains($0.relation) }

        return VStack(spacing: 10) {
            if !parents.isEmpty {
                treeRow(parents)
                TreeBranch(count: parents.count, lowerCount: 1)
                    .frame(height: 34)
                    .padding(.horizontal, 54)
            }

            VStack(spacing: 12) {
                familyNode(for: app.selfMember, relation: app.t("common.you"), size: 72)
                if !partners.isEmpty || !siblings.isEmpty {
                    treeRow(partners + siblings, size: 58)
                }
            }

            if !children.isEmpty {
                TreeBranch(count: 1, lowerCount: children.count)
                    .frame(height: 38)
                    .padding(.horizontal, 54)
                treeRow(children)
            }

            if !grandchildren.isEmpty {
                TreeBranch(count: max(1, children.count), lowerCount: grandchildren.count)
                    .frame(height: 38)
                    .padding(.horizontal, 54)
                treeRow(grandchildren, size: 60)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    private func treeRow(_ members: [FamilyMember], size: CGFloat = 64) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(members) { m in
                    NavigationLink(value: m.id) {
                        familyNode(for: m, relation: relationText(for: m), size: size)
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
                Text(member?.name ?? app.t("common.you"))
                    .scaledFont(size: 12, weight: .semibold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(relation)
                    .scaledFont(size: 10)
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
        case .son, .daughter, .grandson, .granddaughter:
            return "figure.child"
        case .husband, .wife:
            return "person.2"
        case .father, .mother, .grandfather, .grandmother:
            return "person.fill"
        case .brother, .sister:
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
                            Text(m.name)
                                .scaledFont(size: 18, weight: .semibold, design: .serif)
                                .foregroundStyle(p.inkPrimary)
                            Text(m.relation == .selfMember
                                 ? app.t("common.you")
                                 : (app.language == .ne ? m.relation.labelNE : m.relation.labelEN))
                                .scaledFont(size: 13)
                                .foregroundStyle(p.inkSecondary)
                        }
                        Spacer()
                        if let k = m.kundali {
                            Text(app.language == .ne ? k.moonRashi.nameNE : k.moonRashi.shortEN)
                                .scaledFont(size: 13, design: .serif)
                                .foregroundStyle(p.sindoor)
                        }
                        Image(systemName: "chevron.right")
                            .scaledFont(size: 13)
                            .foregroundStyle(p.inkSecondary.opacity(0.6))
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

private struct TreeBranch: View {
    @Environment(\.palette) private var p
    let count: Int
    let lowerCount: Int

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                let upper = points(count: count, width: w)
                let lower = points(count: lowerCount, width: w)
                let midY = h * 0.48

                for x in upper {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: midY))
                }
                if let first = lower.first, let last = lower.last {
                    path.move(to: CGPoint(x: first, y: midY))
                    path.addLine(to: CGPoint(x: last, y: midY))
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

    private func points(count: Int, width: CGFloat) -> [CGFloat] {
        guard count > 1 else { return [width / 2] }
        let step = width / CGFloat(count)
        return (0..<count).map { step * (CGFloat($0) + 0.5) }
    }
}

/// Adding a family member uses the same paged flow, prefixed with a relation step.
struct AddMemberSheet: View {
    var body: some View {
        BirthFlowView(mode: .familyMember)
            .presentationDragIndicator(.visible)
    }
}
