import SwiftUI

struct PatroView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var shown: NepaliDate = BikramSambat.today()
    @State private var selectedDay: NepaliDate?
    @State private var monthDelta = 1 // last navigation direction, drives the slide
    @State private var showDatePicker = false

    private var ne: Bool { app.language == .ne }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(app.t("patro.title"))
                        .scaledFont(size: 34, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    monthHeader
                    VStack(spacing: 12) {
                        weekdayRow
                        monthGrid
                    }
                    .id("\(shown.year)-\(shown.month)")
                    .transition(.asymmetric(
                        insertion: .move(edge: monthDelta > 0 ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: monthDelta > 0 ? .leading : .trailing).combined(with: .opacity)))
                }
                .padding(.bottom, 96)
            }
        }
        .statusBarFade()
        .sheet(item: Binding(
            get: { selectedDay.map { DaySelection(date: $0) } },
            set: { selectedDay = $0?.date })) { sel in
            DayDetailSheet(bs: sel.date)
        }
        .sheet(isPresented: $showDatePicker) {
            PatroDatePickerSheet(shown: $shown)
        }
    }

    private struct DaySelection: Identifiable {
        let date: NepaliDate
        var id: String { "\(date.year)-\(date.month)-\(date.day)" }
    }

    private var monthHeader: some View {
        HStack {
            Button { move(-1) } label: {
                Image(systemName: "chevron.left")
                    .scaledFont(size: 18, weight: .medium)
                    .foregroundStyle(p.saffron)
                    .frame(width: 48, height: 48)
            }
            Spacer()
            Button {
                Haptics.tap()
                showDatePicker = true
            } label: {
                Text("\(shown.monthName(ne: ne)) \(app.digits(shown.year))")
                    .scaledFont(size: 24, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(p.bgSunken))
            }
            .buttonStyle(SpringPressStyle())
            .accessibilityLabel(app.t("patro.jumpToDate"))
            Spacer()
            Button { move(1) } label: {
                Image(systemName: "chevron.right")
                    .scaledFont(size: 18, weight: .medium)
                    .foregroundStyle(p.saffron)
                    .frame(width: 48, height: 48)
            }
        }
        .padding(.horizontal, 12)
    }

    private func move(_ delta: Int) {
        var y = shown.year, m = shown.month + delta
        if m < 1 { m = 12; y -= 1 }
        if m > 12 { m = 1; y += 1 }
        guard y >= BikramSambat.firstYear, y < BikramSambat.firstYear + BikramSambat.table.count else { return }
        Haptics.tap()
        monthDelta = delta
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            shown = NepaliDate(year: y, month: m, day: 1)
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(ne ? L10n.weekdaysNE[i] : L10n.weekdaysEN[i])
                    .scaledFont(size: 12, weight: .semibold)
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
            ForEach(-firstWeekday..<0, id: \.self) { _ in Color.clear.frame(height: 72) }
            ForEach(1...days, id: \.self) { d in
                let bs = NepaliDate(year: shown.year, month: shown.month, day: d)
                let ad = BikramSambat.toAD(bs)
                let pan = Panchanga.forDay(ad)
                let isToday = bs == today
                let isSat = (firstWeekday + d - 1) % 7 == 6
                let hasEvent = app.events.contains { $0.occurs(on: bs) }
                Button {
                    Haptics.tap()
                    selectedDay = bs
                } label: {
                    // Fixed sizes inside the rigid grid (calendar cells don't scale,
                    // matching Apple Calendar) — but never below the 11pt HIG floor.
                    VStack(spacing: 1) {
                        Text(app.digits(d))
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(isSat ? p.sindoor : p.inkPrimary)
                        Text(pan.tithiName(ne: ne))
                            .font(.system(size: isToday ? 9.5 : 11))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(p.inkSecondary)
                        Circle().fill(hasEvent ? p.marigold : .clear).frame(width: 4, height: 4)
                    }
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isToday ? p.bgSunken : .clear))
                }
                .accessibilityLabel("\(app.digits(d)) \(bs.monthName(ne: ne)), \(pan.tithiName(ne: ne))\(hasEvent ? ", \(app.t("patro.events"))" : "")")
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct PatroDatePickerSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    @Binding var shown: NepaliDate
    @State private var year: Int
    @State private var month: Int
    @State private var day: Int

    init(shown: Binding<NepaliDate>) {
        _shown = shown
        _year = State(initialValue: shown.wrappedValue.year)
        _month = State(initialValue: shown.wrappedValue.month)
        _day = State(initialValue: shown.wrappedValue.day)
    }

    private var ne: Bool { app.language == .ne }
    private var years: [Int] {
        Array(BikramSambat.firstYear..<(BikramSambat.firstYear + BikramSambat.table.count))
    }
    private var maxDay: Int { BikramSambat.daysInMonth(year: year, month: month) }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text(app.t("patro.jumpToDate"))
                    .scaledFont(size: 24, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .padding(.top, 14)

                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 8) {
                        Text(app.t("patro.month"))
                            .scaledFont(size: 12, weight: .medium)
                            .foregroundStyle(p.inkSecondary)
                        Picker(app.t("patro.month"), selection: $month) {
                            ForEach(1...12, id: \.self) { m in
                                Text(NepaliDate(year: year, month: m, day: 1).monthName(ne: ne)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 190)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))

                    VStack(spacing: 8) {
                        Text(app.t("patro.day"))
                            .scaledFont(size: 12, weight: .medium)
                            .foregroundStyle(p.inkSecondary)
                        Picker(app.t("patro.day"), selection: $day) {
                            ForEach(1...maxDay, id: \.self) { d in
                                Text(app.digits(d)).tag(d)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 190)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))

                    VStack(spacing: 8) {
                        Text(app.t("patro.year"))
                            .scaledFont(size: 12, weight: .medium)
                            .foregroundStyle(p.inkSecondary)
                        Picker(app.t("patro.year"), selection: $year) {
                            ForEach(years, id: \.self) { y in
                                Text(app.digits(y)).tag(y)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 190)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))
                }
                .onChange(of: month) { clampDay() }
                .onChange(of: year) { clampDay() }

                PrimaryButton(title: app.t("common.done"), icon: "checkmark") {
                    shown = NepaliDate(year: year, month: month, day: min(day, maxDay))
                    dismiss()
                }
                .padding(.bottom, 14)
            }
            .padding(.horizontal, 20)
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDetents([.height(400)])
    }

    private func clampDay() {
        day = min(day, maxDay)
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
                            .scaledFont(size: 30, weight: .bold, design: .serif)
                            .foregroundStyle(p.inkPrimary)
                        Text(ad.formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(app.locale)))
                            .scaledFont(size: 14)
                            .foregroundStyle(p.inkSecondary)
                    }
                    .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: app.t("patro.panchanga"))
                        InfoRow(label: app.t("patro.tithi"),
                                value: "\(pan.tithiName(ne: ne)) (\(pan.pakshaName(ne: ne)))")
                        Hairline()
                        InfoRow(label: app.t("patro.nakshatra"),
                                value: ne ? pan.nakshatra.nameNE : pan.nakshatra.nameEN)
                        Hairline()
                        InfoRow(label: app.t("patro.yoga"), value: Panchanga.yogaNamesEN[pan.yogaIndex])
                        Hairline()
                        InfoRow(label: app.t("patro.karana"), value: Panchanga.karanaNamesEN[pan.karanaIndex])
                    }

                    if !dayEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: app.t("patro.events"))
                            ForEach(Array(dayEvents.enumerated()), id: \.element.id) { i, e in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(e.title)
                                            .scaledFont(size: 17, weight: .medium, design: .serif)
                                            .foregroundStyle(p.inkPrimary)
                                        if !e.note.isEmpty {
                                            Text(e.note).scaledFont(size: 13).foregroundStyle(p.inkSecondary)
                                        }
                                    }
                                    Spacer()
                                    Button { app.removeEvent(e) } label: {
                                        Image(systemName: "trash")
                                            .scaledFont(size: 14)
                                            .foregroundStyle(p.sindoor.opacity(0.7))
                                            .frame(width: 44, height: 44)
                                    }
                                    .accessibilityLabel(app.t("common.delete"))
                                }
                                .padding(.vertical, 8)
                                if i < dayEvents.count - 1 { Hairline() }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(text: app.t("patro.addEvent"))
                        TextField(app.t("patro.eventTitle"), text: $newTitle)
                            .scaledFont(size: 17, design: .serif)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))
                        TextField(app.t("patro.eventNote"), text: $newNote)
                            .scaledFont(size: 15)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(p.bgSunken))
                        Toggle(app.t("patro.repeatYearly"), isOn: $repeats)
                            .scaledFont(size: 15)
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
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
