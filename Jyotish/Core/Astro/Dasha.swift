import Foundation

/// Vimshottari mahadasha / antardasha, from the Moon's natal nakshatra.
struct DashaPeriod: Identifiable, Equatable {
    let id = UUID()
    var lord: Planet
    var start: Double  // JD
    var end: Double

    static func == (a: DashaPeriod, b: DashaPeriod) -> Bool {
        a.lord == b.lord && a.start == b.start && a.end == b.end
    }
}

enum Vimshottari {
    static let order: [Planet] = [.ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury]
    static let years: [Planet: Double] = [.ketu: 7, .venus: 20, .sun: 6, .moon: 10, .mars: 7,
                                          .rahu: 18, .jupiter: 16, .saturn: 19, .mercury: 17]
    static let solarYearDays = 365.25

    /// Full 120-year mahadasha timeline from birth.
    static func mahadashas(for kundali: Kundali) -> [DashaPeriod] {
        let startLord = kundali.moonNakshatra.lord
        let startIdx = order.firstIndex(of: startLord)!
        let balanceYears = years[startLord]! * (1 - kundali.moonNakshatraFraction)
        var periods: [DashaPeriod] = []
        var cursor = kundali.birthJD
        for i in 0..<9 {
            let lord = order[(startIdx + i) % 9]
            let span = (i == 0 ? balanceYears : years[lord]!) * solarYearDays
            periods.append(DashaPeriod(lord: lord, start: cursor, end: cursor + span))
            cursor += span
        }
        return periods
    }

    /// Antardashas within one mahadasha (sequence starts with the mahadasha lord).
    /// For the truncated first mahadasha the proportions still follow the full-length rule,
    /// clipped to the balance — the traditional computation.
    static func antardashas(in maha: DashaPeriod, kundali: Kundali) -> [DashaPeriod] {
        let fullSpan = years[maha.lord]! * solarYearDays
        let fullStart = maha.end - fullSpan // reconstruct nominal start (handles clipped first period)
        let startIdx = order.firstIndex(of: maha.lord)!
        var result: [DashaPeriod] = []
        var cursor = fullStart
        for i in 0..<9 {
            let lord = order[(startIdx + i) % 9]
            let span = fullSpan * years[lord]! / 120
            let p = DashaPeriod(lord: lord, start: max(cursor, maha.start), end: min(cursor + span, maha.end))
            if p.end > p.start { result.append(p) }
            cursor += span
        }
        return result
    }

    static func current(for kundali: Kundali, at jd: Double) -> (maha: DashaPeriod, antar: DashaPeriod)? {
        let mahas = mahadashas(for: kundali)
        guard let maha = mahas.first(where: { jd >= $0.start && jd < $0.end }) else { return nil }
        let antars = antardashas(in: maha, kundali: kundali)
        guard let antar = antars.first(where: { jd >= $0.start && jd < $0.end }) ?? antars.last else { return nil }
        return (maha, antar)
    }

    static func date(fromJD jd: Double) -> Date {
        Date(timeIntervalSince1970: (jd - 2440587.5) * 86400)
    }
}
