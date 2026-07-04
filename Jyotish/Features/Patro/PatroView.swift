import SwiftUI

struct PatroView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var shown: NepaliDate = BikramSambat.today()
    @State private var selectedDay: NepaliDate?

    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SacredHeader(devanagari: "पात्रो", title: app.t("patro.title"))
                        .padding(.top, 8)
                    todayBox
                    monthHeader
                    weekdayRow
                    monthGrid
                }
                .padding(.bottom, 96)
            }
        }
        .sheet(item: Binding(
            get: { selectedDay.map { DaySelection(date: $0) } },
            set: { selectedDay = $0?.date })) { sel in
            DayDetailSheet(bs: sel.date)
        }
    }

    private struct DaySelection: Identifiable {
        let date: NepaliDate
        var id: String { "\(date.year)-\(date.month)-\(date.day)" }
    }

    private var todayBox: some View {
        let today = BikramSambat.today()
        let pan = Panchanga.forDay(Date())
        return HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text(app.digits(today.day))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(p.sindoor)
                Text(today.monthName(ne: ne))
                    .font(.system(size: 13))
                    .foregroundStyle(p.inkSecondary)
            }
            .frame(width: 76)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(p.marigold.opacity(0.15)))
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: app.t("common.today"))
                Text(pan.tithiName(ne: ne))
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(p.inkPrimary)
                Text("\(pan.pakshaName(ne: ne)) · \(ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)")
                    .font(.system(size: 14))
                    .foregroundStyle(p.inkSecondary)
            }
            Spacer()
        }
        .padding(14)
        .sacredCard(tika: true)
        .padding(.horizontal, 20)
    }

    private var monthHeader: some View {
        HStack {
            Button { move(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(p.saffron)
                    .frame(width: 48, height: 48)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("\(shown.monthName(ne: ne)) \(app.digits(shown.year))")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(p.inkPrimary)
                Text(adRangeLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(p.inkSecondary)
            }
            Spacer()
            Button { move(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(p.saffron)
                    .frame(width: 48, height: 48)
            }
        }
        .padding(.horizontal, 12)
    }

    private var adRangeLabel: String {
        let start = BikramSambat.toAD(NepaliDate(year: shown.year, month: shown.month, day: 1))
        let days = BikramSambat.daysInMonth(year: shown.year, month: shown.month)
        let end = BikramSambat.toAD(NepaliDate(year: shown.year, month: shown.month, day: days))
        let f = DateFormatter(); f.dateFormat = "MMM yyyy"; f.locale = app.locale
        let f2 = DateFormatter(); f2.dateFormat = "MMM"; f2.locale = app.locale
        let a = f2.string(from: start), b = f.string(from: end)
        return a == f2.string(from: end) ? b : "\(a) – \(b)"
    }

    private func move(_ delta: Int) {
        var y = shown.year, m = shown.month + delta
        if m < 1 { m = 12; y -= 1 }
        if m > 12 { m = 1; y += 1 }
        guard y >= BikramSambat.firstYear, y < BikramSambat.firstYear + BikramSambat.table.count else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            shown = NepaliDate(year: y, month: m, day: 1)
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(ne ? L10n.weekdaysNE[i] : L10n.weekdaysEN[i])
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(i == 6 ? p.sindoor : p.inkSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    private var monthGrid: some View {
        let days = BikramSambat.daysInMonth(year: shown.year, month: shown.month)
        let firstAD = BikramSambat.toAD(NepaliDate(year: shown.year, month: shown.month, day: 1))
        let firstWeekday = Calendar.nepali.component(.weekday, from: firstAD) - 1 // 0=Sun
        let today = BikramSambat.today()
        let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: cols, spacing: 4) {
            // Negative ids: must not collide with day numbers or LazyVGrid scrambles rows.
            ForEach(-firstWeekday..<0, id: \.self) { _ in Color.clear.frame(height: 64) }
            ForEach(1...days, id: \.self) { d in
                let bs = NepaliDate(year: shown.year, month: shown.month, day: d)
                let ad = BikramSambat.toAD(bs)
                let pan = Panchanga.forDay(ad)
                let isToday = bs == today
                let isSat = (firstWeekday + d - 1) % 7 == 6
                let hasEvent = app.events.contains { $0.occurs(on: bs) }
                Button { selectedDay = bs } label: {
                    VStack(spacing: 1) {
                        Text(app.digits(d))
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(isSat ? p.sindoor : p.inkPrimary)
                        Text(pan.tithiName(ne: ne))
                            .font(.system(size: 8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(p.inkSecondary)
                        Text("\(Calendar.nepali.component(.day, from: ad))")
                            .font(.system(size: 9))
                            .foregroundStyle(p.inkSecondary.opacity(0.7))
                        Circle().fill(hasEvent ? p.marigold : .clear).frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isToday ? p.marigold.opacity(0.18) : p.bgElevated))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isToday ? p.saffron : p.templeGold.opacity(0.15),
                                          lineWidth: isToday ? 1.6 : 1))
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

/// Day sheet: full panchanga + events + add-event form.
struct DayDetailSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let bs: NepaliDate

    @State private var newTitle = ""
    @State private var newNote = ""
    @State private var repeats = false

    private var ne: Bool { app.language == .ne }

    var body: some View {
        let ad = BikramSambat.toAD(bs)
        let pan = Panchanga.forDay(ad)
        let dayEvents = app.events.filter { $0.occurs(on: bs) }

        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(app.digits(bs.day)) \(bs.monthName(ne: ne)) \(app.digits(bs.year))")
                            .font(.system(size: 30, weight: .bold, design: .serif))
                            .foregroundStyle(p.inkPrimary)
                        Text(ad.formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(app.locale)))
                            .font(.system(size: 14))
                            .foregroundStyle(p.inkSecondary)
                    }
                    .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("patro.panchanga"))
                        InfoRow(label: app.t("patro.tithi"),
                                value: "\(pan.tithiName(ne: ne)) (\(pan.pakshaName(ne: ne)))")
                        InfoRow(label: app.t("patro.nakshatra"),
                                value: ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)
                        InfoRow(label: app.t("patro.yoga"), value: Panchanga.yogaNamesEN[pan.yogaIndex])
                        InfoRow(label: app.t("patro.karana"), value: Panchanga.karanaNamesEN[pan.karanaIndex])
                    }
                    .padding(16)
                    .sacredCard(radius: 16)

                    if !dayEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: app.t("patro.events"))
                            ForEach(dayEvents) { e in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(e.title)
                                            .font(.system(size: 17, weight: .medium, design: .serif))
                                            .foregroundStyle(p.inkPrimary)
                                        if !e.note.isEmpty {
                                            Text(e.note).font(.system(size: 13)).foregroundStyle(p.inkSecondary)
                                        }
                                    }
                                    Spacer()
                                    Button { app.removeEvent(e) } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                            .foregroundStyle(p.sindoor.opacity(0.7))
                                            .frame(width: 44, height: 44)
                                    }
                                    .accessibilityLabel(app.t("common.delete"))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .sacredCard(radius: 12)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(text: app.t("patro.addEvent"))
                        TextField(app.t("patro.eventTitle"), text: $newTitle)
                            .font(.system(size: 17, design: .serif))
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(p.bgElevated))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(p.templeGold.opacity(0.3), lineWidth: 1))
                        TextField(app.t("patro.eventNote"), text: $newNote)
                            .font(.system(size: 15))
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(p.bgElevated))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(p.templeGold.opacity(0.3), lineWidth: 1))
                        Toggle(app.t("patro.repeatYearly"), isOn: $repeats)
                            .font(.system(size: 15))
                            .tint(p.saffron)
                            .foregroundStyle(p.inkSecondary)
                        PrimaryButton(title: app.t("common.add"), icon: "plus") {
                            let t = newTitle.trimmingCharacters(in: .whitespaces)
                            guard !t.isEmpty else { return }
                            app.addEvent(PatroEvent(title: t, note: newNote, bsDate: bs, repeatsYearly: repeats))
                            newTitle = ""; newNote = ""; repeats = false
                        }
                        .opacity(newTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
