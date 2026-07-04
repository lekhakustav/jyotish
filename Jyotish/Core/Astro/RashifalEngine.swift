import Foundation

enum RashifalPeriod: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, yearly
    var id: String { rawValue }
    var l10nKey: String { "rashifal.\(rawValue)" }
}

struct Rashifal {
    var rashi: Rashi
    var period: RashifalPeriod
    var text: String
    var scores: [String: Int]   // domain key → 1…5
    var upaya: String
    var luckyColor: String
    var luckyNumber: Int
    var luckyDay: String
}

/// Generates rashifal from *real* gochar (transits) — deterministic per
/// (rashi, period, date) so the same day always reads the same. docs/03 §6.
enum RashifalEngine {

    /// Simple seeded PRNG (splitmix64) — stable across launches.
    struct Seeded: RandomNumberGenerator {
        var state: UInt64
        init(_ seed: UInt64) { state = seed &+ 0x9E3779B97F4A7C15 }
        mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
    }

    static let domains = ["rashifal.career", "rashifal.family", "rashifal.health",
                          "rashifal.wealth", "rashifal.love"]

    static func generate(rashi: Rashi, period: RashifalPeriod, date: Date, lang: Language) -> Rashifal {
        let cal = Calendar.nepali
        let comps = cal.dateComponents([.year, .month, .day, .weekOfYear], from: date)
        let periodStamp: Int
        switch period {
        case .daily: periodStamp = comps.year! * 10000 + comps.month! * 100 + comps.day!
        case .weekly: periodStamp = comps.year! * 100 + comps.weekOfYear!
        case .monthly: periodStamp = comps.year! * 100 + comps.month!
        case .yearly: periodStamp = comps.year!
        }
        var rng = Seeded(UInt64(periodStamp) &* 12 &+ UInt64(rashi.rawValue))

        // ── Real transits ────────────────────────────────────────────────────
        let jd = Ephemeris.julianDay(date)
        let moonNow = Ephemeris.rashi(of: Ephemeris.sidereal(.moon, jd: jd))
        let jupiterHouse = (Ephemeris.rashi(of: Ephemeris.sidereal(.jupiter, jd: jd)).rawValue - rashi.rawValue + 12) % 12 + 1
        let venusHouse = (Ephemeris.rashi(of: Ephemeris.sidereal(.venus, jd: jd)).rawValue - rashi.rawValue + 12) % 12 + 1
        let saturnRashi = Ephemeris.rashi(of: Ephemeris.sidereal(.saturn, jd: jd))
        let chandra = Interpreter.chandraBala(natal: rashi, transitMoon: moonNow)
        let sadheSati = Interpreter.sadheSatiPhase(natal: rashi, transitSaturn: saturnRashi)

        // ── Domain scores from transit weights ──────────────────────────────
        func clamp(_ x: Int) -> Int { max(1, min(5, x)) }
        var base = chandra.favorable ? 4 : 3
        if sadheSati != nil { base -= 1 }
        let jupiterBoost = [2, 5, 7, 9, 11].contains(jupiterHouse) ? 1 : 0
        let venusBoost = [1, 4, 5, 7, 11].contains(venusHouse) ? 1 : 0
        var scores: [String: Int] = [:]
        scores["rashifal.career"] = clamp(base + jupiterBoost + Int(rng.next() % 2) - ([10, 8].contains(chandra.house) ? 1 : 0))
        scores["rashifal.family"] = clamp(base + venusBoost + Int(rng.next() % 2))
        scores["rashifal.health"] = clamp(base + (chandra.favorable ? 1 : 0) - (sadheSati == 2 ? 1 : 0) + Int(rng.next() % 2))
        scores["rashifal.wealth"] = clamp(base + jupiterBoost + venusBoost - 1 + Int(rng.next() % 2))
        scores["rashifal.love"] = clamp(base + venusBoost + Int(rng.next() % 2))

        // ── Sentences ────────────────────────────────────────────────────────
        let ne = lang == .ne
        var lines: [String] = []
        lines.append(opening(chandra: chandra, ne: ne, rng: &rng))
        if jupiterBoost > 0 {
            lines.append(ne
                ? "बृहस्पति तपाईंको \(L10n.digits(jupiterHouse, .ne)) औं भावबाट आशीर्वाद दिइरहनुभएको छ — ज्ञान, सन्तान र भाग्यको ढोका खुल्दैछ।"
                : "Jupiter blesses your house \(jupiterHouse) — doors of wisdom, children and fortune stand open.")
        }
        if let phase = sadheSati {
            lines.append(ne
                ? "शनिको साढेसाती (चरण \(L10n.digits(phase, .ne))) चलिरहेको छ — धैर्य, अनुशासन र शनिवारको दान नै रक्षा-कवच हो।"
                : "Shani's Sadhe Sati (phase \(phase)) walks with you — patience, discipline and Saturday charity are your armor.")
        } else if venusBoost > 0 {
            lines.append(ne
                ? "शुक्रको स्थिति सम्बन्ध र कलामा मिठास थप्दैछ।"
                : "Venus sweetens relationships and the arts in this period.")
        }
        lines.append(domainLine(scores: scores, ne: ne, rng: &rng))

        let g = Interpreter.guna[rashi.rawValue]
        let upayaOptions = ne
            ? ["\(g.deityNE)को दर्शन गरी \(g.mantra) जप गर्नुहोस्।",
               "\(g.dayNE)का दिन \(g.colorsNE[0]) वस्त्र धारण गर्नुहोस्।",
               "बिहान तामाको भाँडाबाट सूर्यलाई जल अर्पण गर्नुहोस्।",
               "गाईलाई हरियो घाँस खुवाउनुहोस् र ज्येष्ठजनको आशीर्वाद लिनुहोस्।"]
            : ["Offer prayers to \(g.deityEN) and recite \(g.mantra).",
               "Wear \(g.colorsEN[0].lowercased()) on \(g.dayEN) for added grace.",
               "Offer water to Surya at sunrise from a copper vessel.",
               "Feed green grass to a cow and seek an elder's blessing."]
        let upaya = upayaOptions[Int(rng.next() % UInt64(upayaOptions.count))]
        let colors = ne ? g.colorsNE : g.colorsEN
        return Rashifal(rashi: rashi, period: period,
                        text: lines.joined(separator: " "),
                        scores: scores, upaya: upaya,
                        luckyColor: colors[Int(rng.next() % UInt64(colors.count))],
                        luckyNumber: g.numbers[Int(rng.next() % UInt64(g.numbers.count))],
                        luckyDay: ne ? g.dayNE : g.dayEN)
    }

    private static func opening(chandra: (house: Int, favorable: Bool), ne: Bool, rng: inout Seeded) -> String {
        let goodEN = ["Chandra rides in your house \(chandra.house) — the mind is clear and the heart light.",
                      "The Moon's position in house \(chandra.house) brings ease and good news your way.",
                      "With Chandra bala in your favor (house \(chandra.house)), beginnings made now take root well."]
        let goodNE = ["चन्द्रमा तपाईंको \(L10n.digits(chandra.house, .ne)) औं भावमा — मन प्रसन्न र हृदय हलुका रहनेछ।",
                      "चन्द्रमाको स्थितिले सहजता र शुभ समाचार ल्याउँदैछ।",
                      "चन्द्रबल तपाईंको पक्षमा छ — अहिले थालेका काम राम्ररी फल्नेछन्।"]
        let mixEN = ["Chandra sits in house \(chandra.house) — go gently today; steady steps beat quick leaps.",
                     "The Moon asks for patience from house \(chandra.house); finish old work before starting new.",
                     "A reflective period — house \(chandra.house) Chandra favors rest, prayer and tying loose ends."]
        let mixNE = ["चन्द्रमा \(L10n.digits(chandra.house, .ne)) औं भावमा — आज बिस्तारै अघि बढ्नुहोस्; स्थिर पाइला नै उत्तम।",
                     "चन्द्रमाले धैर्य माग्दैछ; नयाँ थाल्नु अघि पुराना काम सक्नुहोस्।",
                     "मनन गर्ने समय — विश्राम, पूजा र बाँकी काम मिलाउन शुभ।"]
        let pool = chandra.favorable ? (ne ? goodNE : goodEN) : (ne ? mixNE : mixEN)
        return pool[Int(rng.next() % UInt64(pool.count))]
    }

    private static func domainLine(scores: [String: Int], ne: Bool, rng: inout Seeded) -> String {
        let best = scores.max { $0.value < $1.value }!.key
        let map: [String: (en: String, ne: String)] = [
            "rashifal.career": ("Career shines brightest — accept the responsibility that finds you.",
                                "पेशा सबैभन्दा उज्यालो छ — आइपर्ने जिम्मेवारी स्वीकार गर्नुहोस्।"),
            "rashifal.family": ("Family is your fortune now — a shared meal heals much.",
                                "परिवार नै अहिलेको भाग्य हो — सँगै खाना खाँदा धेरै कुरा जुड्छ।"),
            "rashifal.health": ("The body responds well — morning walks and light food multiply strength.",
                                "शरीरले साथ दिँदैछ — बिहानको हिँडाइ र हल्का खानाले बल बढाउँछ।"),
            "rashifal.wealth": ("Wealth flows steadily — save first, spend after, and Lakshmi stays.",
                                "धनको आगमन स्थिर छ — पहिले बचत, अनि खर्च; लक्ष्मी टिक्नुहुन्छ।"),
            "rashifal.love": ("Hearts open easily now — speak the kind word you have been saving.",
                              "मनहरू सजिलै खुल्नेछन् — जोगाएर राखेको मीठो वचन भन्नुहोस्।"),
        ]
        let pair = map[best]!
        return ne ? pair.ne : pair.en
    }
}
