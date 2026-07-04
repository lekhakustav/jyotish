import SwiftUI

struct MemberDetailView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let memberID: UUID

    private var member: FamilyMember? { app.family.first { $0.id == memberID } }
    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            if let m = member {
                if let k = m.kundali {
                    content(m, k)
                } else {
                    gate(m)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func gate(_ m: FamilyMember) -> some View {
        VStack(spacing: 16) {
            MandalaView().frame(width: 200, height: 200).opacity(0.6)
            Text(app.t("profile.gate.title"))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(p.inkPrimary)
            Text(app.t("profile.gate.body"))
                .font(.system(size: 16))
                .foregroundStyle(p.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func content(_ m: FamilyMember, _ k: Kundali) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Identity hero
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        MandalaView(rotates: true).frame(width: 190, height: 190).opacity(0.7)
                        RashiSeal(rashi: k.moonRashi, size: 84)
                    }
                    Text(m.name)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(p.inkPrimary)
                    Text(m.relation == .selfMember
                         ? app.t("common.you")
                         : m.relation.possessive(app.language))
                        .font(.system(size: 15))
                        .foregroundStyle(p.templeGold)
                }
                .frame(maxWidth: .infinity)
                .fadeRise()

                // Chart triad
                HStack(spacing: 10) {
                    triad(app.t("family.lagna"), ne ? k.lagna.nameNE : k.lagna.shortEN)
                    triad(app.t("family.rashi"), ne ? k.moonRashi.nameNE : k.moonRashi.shortEN)
                    triad(app.t("family.nakshatra"), ne ? k.moonNakshatra.nameNE : k.moonNakshatra.nameEN)
                }
                .padding(.horizontal, 20)
                .fadeRise(delay: 0.05)

                // Kundali chart
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: app.t("family.kundali"))
                    KundaliChartView(chart: k)
                        .padding(8)
                }
                .padding(16)
                .sacredCard(tika: true)
                .padding(.horizontal, 20)
                .fadeRise(delay: 0.1)

                // Reading
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: app.t("family.personality"))
                    Text(Interpreter.reading(for: k, lang: app.language))
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(p.inkPrimary.opacity(0.92))
                        .lineSpacing(5)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .sacredCard()
                .padding(.horizontal, 20)
                .fadeRise(delay: 0.15)

                // Dasha timeline
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: app.t("family.dashaTimeline"))
                    let now = Ephemeris.julianDay(Date())
                    ForEach(Vimshottari.mahadashas(for: k)) { d in
                        HStack {
                            Circle()
                                .fill(now >= d.start && now < d.end ? p.saffron : p.templeGold.opacity(0.35))
                                .frame(width: 8, height: 8)
                            Text(ne ? d.lord.nameNE : d.lord.nameEN)
                                .font(.system(size: 16, weight: now >= d.start && now < d.end ? .semibold : .regular, design: .serif))
                                .foregroundStyle(now >= d.start && now < d.end ? p.sindoor : p.inkPrimary)
                            Spacer()
                            Text("\(Vimshottari.date(fromJD: d.start).formatted(.dateTime.year().locale(app.locale))) – \(Vimshottari.date(fromJD: d.end).formatted(.dateTime.year().locale(app.locale)))")
                                .font(.system(size: 13))
                                .foregroundStyle(p.inkSecondary)
                        }
                    }
                }
                .padding(16)
                .sacredCard()
                .padding(.horizontal, 20)
                .fadeRise(delay: 0.2)

                // Guna & lucky things
                let g = Interpreter.guna[k.moonRashi.rawValue]
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: app.t("family.guna"))
                    InfoRow(label: app.t("family.element"), value: ne ? g.elementNE : g.elementEN)
                    InfoRow(label: app.t("family.lord"), value: ne ? k.moonRashi.lord.nameNE : k.moonRashi.lord.nameEN)
                    InfoRow(label: app.t("family.gemstone"), value: ne ? g.gemstoneNE : g.gemstoneEN)
                    InfoRow(label: app.t("rashifal.lucky.color"), value: (ne ? g.colorsNE : g.colorsEN).joined(separator: ", "))
                    InfoRow(label: app.t("rashifal.lucky.number"), value: g.numbers.map { app.digits($0) }.joined(separator: ", "))
                    InfoRow(label: app.t("rashifal.lucky.day"), value: ne ? g.dayNE : g.dayEN)
                    InfoRow(label: app.t("family.deity"), value: ne ? g.deityNE : g.deityEN)
                    InfoRow(label: app.t("family.mantra"), value: g.mantra)
                }
                .padding(16)
                .sacredCard()
                .padding(.horizontal, 20)
                .fadeRise(delay: 0.25)

                if m.relation != .selfMember {
                    Button {
                        app.removeMember(m)
                        dismiss()
                    } label: {
                        Text(app.t("common.delete"))
                            .font(.system(size: 15))
                            .foregroundStyle(p.sindoor.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
            }
            .padding(.bottom, 96)
        }
    }

    private func triad(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .kerning(1)
                .foregroundStyle(p.inkSecondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(p.sindoor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .sacredCard(radius: 14)
    }
}
