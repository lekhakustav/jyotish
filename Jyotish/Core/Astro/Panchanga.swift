import Foundation

/// The five limbs of a Vedic day: tithi, vara, nakshatra, yoga, karana.
struct Panchanga {
    var tithiIndex: Int      // 0…29 across both pakshas
    var nakshatra: Nakshatra
    var yogaIndex: Int       // 0…26
    var karanaIndex: Int     // 0…10 (name table)
    var weekday: Int         // 1=Sunday … 7=Saturday (Calendar convention)
    var moonRashi: Rashi

    var isShukla: Bool { tithiIndex < 15 }
    /// 1…15 within the paksha (15 = Purnima or Aausi).
    var tithiInPaksha: Int { tithiIndex % 15 + 1 }

    static let tithiNamesEN = ["Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
        "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi",
        "Trayodashi", "Chaturdashi", "Purnima"]
    static let tithiNamesNE = ["प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी",
        "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी", "एकादशी", "द्वादशी",
        "त्रयोदशी", "चतुर्दशी", "पूर्णिमा"]

    static let yogaNamesEN = ["Vishkambha", "Priti", "Ayushman", "Saubhagya", "Shobhana",
        "Atiganda", "Sukarma", "Dhriti", "Shula", "Ganda", "Vriddhi", "Dhruva", "Vyaghata",
        "Harshana", "Vajra", "Siddhi", "Vyatipata", "Variyana", "Parigha", "Shiva", "Siddha",
        "Sadhya", "Shubha", "Shukla", "Brahma", "Indra", "Vaidhriti"]
    static let yogaNamesNE = ["विष्कम्भ", "प्रीति", "आयुष्मान", "सौभाग्य", "शोभन",
        "अतिगण्ड", "सुकर्मा", "धृति", "शूल", "गण्ड", "वृद्धि", "ध्रुव", "व्याघात",
        "हर्षण", "वज्र", "सिद्धि", "व्यतीपात", "वरीयान", "परिघ", "शिव", "सिद्ध",
        "साध्य", "शुभ", "शुक्ल", "ब्रह्म", "इन्द्र", "वैधृति"]

    static let karanaNamesEN = ["Bava", "Balava", "Kaulava", "Taitila", "Garaja", "Vanija",
        "Vishti", "Shakuni", "Chatushpada", "Naga", "Kimstughna"]
    static let karanaNamesNE = ["बव", "बालव", "कौलव", "तैतिल", "गर", "वणिज",
        "विष्टि", "शकुनि", "चतुष्पद", "नाग", "किंस्तुघ्न"]

    func tithiName(ne: Bool) -> String {
        let idx = tithiIndex % 15
        if idx == 14 { // 15th tithi: Purnima in shukla, Aunsi (new moon) in krishna
            return isShukla ? (ne ? "पूर्णिमा" : "Purnima") : (ne ? "औंसी" : "Aunsi")
        }
        return ne ? Self.tithiNamesNE[idx] : Self.tithiNamesEN[idx]
    }

    func pakshaName(ne: Bool) -> String {
        isShukla ? (ne ? "शुक्ल पक्ष" : "Shukla Paksha") : (ne ? "कृष्ण पक्ष" : "Krishna Paksha")
    }

    func yogaName(ne: Bool) -> String {
        ne ? Self.yogaNamesNE[yogaIndex] : Self.yogaNamesEN[yogaIndex]
    }

    func karanaName(ne: Bool) -> String {
        ne ? Self.karanaNamesNE[karanaIndex] : Self.karanaNamesEN[karanaIndex]
    }

    /// Compute the panchanga at a given instant.
    static func at(jd: Double, weekday: Int) -> Panchanga {
        let sun = Ephemeris.sunTropical(jd: jd)      // tithi/yoga: ayanamsa cancels / convention
        let moonT = Ephemeris.moonTropical(jd: jd)
        let moonS = Ephemeris.sidereal(.moon, jd: jd)
        let sunS = Ephemeris.sidereal(.sun, jd: jd)
        let diff = Ephemeris.norm360(moonT - sun)
        let tithi = min(29, Int(diff / 12))
        let yoga = min(26, Int(Ephemeris.norm360(sunS + moonS) / (360.0 / 27.0)))
        // Karana: half tithi. 60 half-tithis; 1st and last 3 are the fixed karanas.
        let half = Int(diff / 6) // 0..59
        let karana: Int
        switch half {
        case 0: karana = 10                    // Kimstughna
        case 57: karana = 7                    // Shakuni
        case 58: karana = 8                    // Chatushpada
        case 59: karana = 9                    // Naga
        default: karana = (half - 1) % 7       // rotating 7
        }
        let nak = Ephemeris.nakshatra(of: moonS).nakshatra
        return Panchanga(tithiIndex: tithi, nakshatra: nak, yogaIndex: yoga,
                         karanaIndex: karana, weekday: weekday,
                         moonRashi: Ephemeris.rashi(of: moonS))
    }

    /// Panchanga for a civil date in Nepal (evaluated near sunrise, 05:45 NPT).
    static func forDay(_ date: Date, calendar: Calendar = .nepali) -> Panchanga {
        forDay(date, place: .kathmandu, calendar: calendar)
    }

    /// Panchanga for the chosen place, evaluated at the existing 05:45 local
    /// sunrise fallback. Keeping place in the cache key prevents Nepal results
    /// from being reused for a household abroad.
    static func forDay(_ date: Date,
                       place: BirthPlace,
                       calendar: Calendar = Calendar(identifier: .gregorian)) -> Panchanga {
        var cal = calendar
        cal.timeZone = TimeZone(secondsFromGMT: Int(place.utcOffsetHours * 3600)) ?? .current
        let comps = cal.dateComponents([.year, .month, .day, .weekday], from: date)
        let key = CacheKey(year: comps.year!, month: comps.month!, day: comps.day!,
                           utcOffsetMinutes: Int(place.utcOffsetHours * 60))
        if let cached = cachedValue(for: key) { return cached }
        let jd = Ephemeris.julianDay(year: comps.year!, month: comps.month!, day: comps.day!,
                                     hourUT: 5.75 - place.utcOffsetHours)
        let result = at(jd: jd, weekday: comps.weekday ?? 1)
        store(result, for: key)
        return result
    }

    private struct CacheKey: Hashable {
        var year: Int
        var month: Int
        var day: Int
        var utcOffsetMinutes: Int
    }

    private static var cache: [CacheKey: Panchanga] = [:]
    private static let cacheLock = NSLock()
    private static var cacheHits = 0
    private static var cacheMisses = 0

    private static func cachedValue(for key: CacheKey) -> Panchanga? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let value = cache[key] {
            cacheHits += 1
            return value
        }
        cacheMisses += 1
        return nil
    }

    private static func store(_ value: Panchanga, for key: CacheKey) {
        cacheLock.lock()
        cache[key] = value
        if cache.count > 512 {
            cache.remove(at: cache.startIndex)
        }
        cacheLock.unlock()
    }

    static func resetCacheForTesting() {
        cacheLock.lock()
        cache.removeAll()
        cacheHits = 0
        cacheMisses = 0
        cacheLock.unlock()
    }

    static var cacheSnapshotForTesting: (entries: Int, hits: Int, misses: Int) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return (cache.count, cacheHits, cacheMisses)
    }
}

extension Calendar {
    static var nepali: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kathmandu") ?? .current
        return cal
    }
}
