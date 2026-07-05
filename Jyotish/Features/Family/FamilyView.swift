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
                        SacredHeader(devanagari: "परिवार", title: app.t("family.title"),
                                     trailing: AnyView(addButton))
                            .padding(.top, 8)
                        if hasRelatives {
                            constellation.fadeRise()
                        }
                        memberList.fadeRise(delay: 0.1)
                    }
                    .padding(.bottom, 96)
                }
            }
            .statusBarFade()
            .sheet(isPresented: $showAdd) { AddMemberSheet() }
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

    /// The auto family tree: user's seal centered, relatives orbiting with gold connectors.
    private var constellation: some View {
        let others = app.family.filter { $0.relation != .selfMember }
        return GeometryReader { geo in
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius: CGFloat = 105
            // connector lines
            Path { path in
                for i in others.indices {
                    let a = angle(i, count: others.count)
                    path.move(to: c)
                    path.addLine(to: CGPoint(x: c.x + cos(a) * radius, y: c.y + sin(a) * radius))
                }
            }
            .stroke(p.templeGold.opacity(0.28), lineWidth: 1)

            // center: the user
            seal(for: app.selfMember, label: app.t("common.you"), size: 66)
                .position(c)

            ForEach(Array(others.enumerated()), id: \.element.id) { i, m in
                let a = angle(i, count: others.count)
                NavigationLink(value: m.id) {
                    seal(for: m, label: m.relation == .selfMember ? m.name : (app.language == .ne ? m.relation.labelNE : m.relation.labelEN), size: 52)
                }
                .position(x: c.x + cos(a) * radius, y: c.y + sin(a) * radius)
            }
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .navigationDestination(for: UUID.self) { id in
            if let m = app.family.first(where: { $0.id == id }) {
                MemberDetailView(memberID: m.id)
            }
        }
    }

    private func angle(_ i: Int, count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        return CGFloat(i) / CGFloat(count) * 2 * .pi - .pi / 2
    }

    private func seal(for m: FamilyMember?, label: String, size: CGFloat) -> some View {
        VStack(spacing: 4) {
            if let k = m?.kundali {
                RashiSeal(rashi: k.moonRashi, size: size)
            } else {
                Circle().strokeBorder(p.templeGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: size, height: size)
                    .overlay(Image(systemName: "person").foregroundStyle(p.inkSecondary))
            }
            Text(label)
                .scaledFont(size: 11, weight: .medium)
                .foregroundStyle(p.inkSecondary)
                .lineLimit(1)
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

/// Adding a family member uses the same paged flow, prefixed with a relation step.
struct AddMemberSheet: View {
    var body: some View {
        BirthFlowView(mode: .familyMember)
            .presentationDragIndicator(.visible)
    }
}
