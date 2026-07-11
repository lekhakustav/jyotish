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
    /// A restrained open loop and its matching question are generated from the
    /// same transit scores as the reading, so the Pandit invitation stays
    /// specific without inventing a warning that the rashifal does not support.
    var panditTeaser: String
    var panditCTA: String
    var panditPrompt: String
}

/// Generates rashifal from *real* gochar (transits) — deterministic per
/// (rashi, period, date) so the same day always reads the same. docs/03 §6.
enum RashifalEngine {
    private struct CacheKey: Hashable {
        var rashi: Rashi
        var period: RashifalPeriod
        var periodStamp: Int
        var language: Language
    }

    private static var cache: [CacheKey: Rashifal] = [:]
    private static let cacheLock = NSLock()
    private static var cacheHits = 0
    private static var cacheMisses = 0

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
        generate(rashi: rashi, period: period, date: date, lang: lang, julianDay: nil)
    }

    static func generate(rashi: Rashi,
                         period: RashifalPeriod,
                         date: Date,
                         lang: Language,
                         julianDay suppliedJD: Double?) -> Rashifal {
        let comps = Calendar.nepali.dateComponents([.year, .month, .day, .weekOfYear], from: date)
        let periodStamp: Int
        switch period {
        case .daily: periodStamp = comps.year! * 10000 + comps.month! * 100 + comps.day!
        case .weekly: periodStamp = comps.year! * 100 + comps.weekOfYear!
        case .monthly: periodStamp = comps.year! * 100 + comps.month!
        case .yearly: periodStamp = comps.year!
        }
        let key = CacheKey(rashi: rashi, period: period, periodStamp: periodStamp, language: lang)
        if let cached = cachedValue(for: key) { return cached }

        var rng = Seeded(UInt64(periodStamp) &* 12 &+ UInt64(rashi.rawValue))

        // ── Real transits ────────────────────────────────────────────────────
        let jd = suppliedJD ?? Ephemeris.julianDay(date)
        let moonNow = Ephemeris.rashi(of: Ephemeris.sidereal(.moon, jd: jd))
        func transitHouse(_ planet: Planet) -> Int {
            (Ephemeris.rashi(of: Ephemeris.sidereal(planet, jd: jd)).rawValue - rashi.rawValue + 12) % 12 + 1
        }
        let jupiterHouse = transitHouse(.jupiter)
        let venusHouse = transitHouse(.venus)
        let mercuryHouse = transitHouse(.mercury)
        let marsHouse = transitHouse(.mars)
        let saturnHouse = transitHouse(.saturn)
        let saturnRashi = Ephemeris.rashi(of: Ephemeris.sidereal(.saturn, jd: jd))
        let chandra = Interpreter.chandraBala(natal: rashi, transitMoon: moonNow)
        let sadheSati = Interpreter.sadheSatiPhase(natal: rashi, transitSaturn: saturnRashi)

        // ── Domain scores from distinct transit evidence ────────────────────
        // Stars are not random decoration. Each life area weighs the grahas
        // and houses that actually relate to it, then maps the result onto a
        // deliberately conservative scale where 5 means exceptional support.
        func effect(_ house: Int, favorable: Set<Int>, difficult: Set<Int>) -> Double {
            if favorable.contains(house) { return 1 }
            if difficult.contains(house) { return -1 }
            return 0
        }
        func stars(_ raw: Double) -> Int {
            switch raw {
            case ..<1.85: return 1
            case ..<2.65: return 2
            case ..<3.45: return 3
            case ..<4.25: return 4
            default: return 5
            }
        }

        let moon = chandra.favorable ? 0.55 : -0.45
        let sadePenalty = sadheSati == nil ? 0.0 : (sadheSati == 2 ? -0.75 : -0.45)
        let rawScores: [String: Double] = [
            "rashifal.career": 3
                + 0.75 * effect(jupiterHouse, favorable: [2, 5, 7, 9, 10, 11], difficult: [3, 6, 8, 12])
                + 0.55 * effect(saturnHouse, favorable: [3, 6, 10, 11], difficult: [1, 4, 8, 12])
                + 0.40 * effect(mercuryHouse, favorable: [2, 3, 6, 10, 11], difficult: [8, 12])
                + 0.25 * moon,
            "rashifal.family": 3
                + 0.65 * effect(venusHouse, favorable: [1, 2, 4, 5, 7, 9, 11], difficult: [6, 8, 12])
                + 0.40 * effect(jupiterHouse, favorable: [2, 4, 5, 7, 9, 11], difficult: [6, 8, 12])
                + 0.45 * moon + 0.35 * sadePenalty,
            "rashifal.health": 3
                + 0.75 * moon
                + 0.40 * effect(marsHouse, favorable: [3, 6, 10, 11], difficult: [1, 4, 8, 12])
                + 0.35 * effect(saturnHouse, favorable: [3, 6, 11], difficult: [1, 4, 8, 12])
                + sadePenalty,
            "rashifal.wealth": 3
                + 0.80 * effect(jupiterHouse, favorable: [2, 5, 9, 11], difficult: [6, 8, 12])
                + 0.50 * effect(venusHouse, favorable: [2, 5, 9, 11], difficult: [6, 8, 12])
                + 0.40 * effect(mercuryHouse, favorable: [2, 6, 10, 11], difficult: [8, 12]),
            "rashifal.love": 3
                + 0.90 * effect(venusHouse, favorable: [1, 5, 7, 9, 11], difficult: [6, 8, 12])
                + 0.35 * moon
                + 0.35 * effect(marsHouse, favorable: [3, 5, 11], difficult: [4, 7, 8, 12]),
        ]
        var scores = rawScores.mapValues(stars)
        // A page full of perfect marks communicates no information. Even in
        // the rare case of universally supportive transits, retain the weakest
        // relative domain as a four so five stars stays meaningful.
        if scores.values.allSatisfy({ $0 == 5 }),
           let weakest = rawScores.min(by: { $0.value < $1.value })?.key {
            scores[weakest] = 4
        }

        let jupiterBoost = effect(jupiterHouse, favorable: [2, 5, 7, 9, 11], difficult: []) > 0 ? 1 : 0
        let venusBoost = effect(venusHouse, favorable: [1, 4, 5, 7, 11], difficult: []) > 0 ? 1 : 0

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
        let panditInvitation = panditInvitation(scores: scores, period: period, ne: ne)
        let result = Rashifal(rashi: rashi, period: period,
                              text: lines.joined(separator: " "),
                              scores: scores, upaya: upaya,
                              luckyColor: colors[Int(rng.next() % UInt64(colors.count))],
                              luckyNumber: g.numbers[Int(rng.next() % UInt64(g.numbers.count))],
                              luckyDay: ne ? g.dayNE : g.dayEN,
                              panditTeaser: panditInvitation.teaser,
                              panditCTA: panditInvitation.cta,
                              panditPrompt: panditInvitation.prompt)
        store(result, for: key)
        return result
    }

    private static func panditInvitation(scores: [String: Int],
                                          period: RashifalPeriod,
                                          ne: Bool) -> (teaser: String, cta: String, prompt: String) {
        let weakest = scores.min { lhs, rhs in
            lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value < rhs.value
        } ?? ("rashifal.health", 3)
        let strongest = scores.max { lhs, rhs in
            lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value < rhs.value
        } ?? ("rashifal.career", 3)
        let chosen = weakest.value <= 2 ? weakest : strongest
        let domainEN: [String: String] = [
            "rashifal.career": "career", "rashifal.family": "family",
            "rashifal.health": "health", "rashifal.wealth": "money",
            "rashifal.love": "love life",
        ]
        let domainNE: [String: String] = [
            "rashifal.career": "पेशा", "rashifal.family": "परिवार",
            "rashifal.health": "स्वास्थ्य", "rashifal.wealth": "धन",
            "rashifal.love": "प्रेम जीवन",
        ]
        let area = ne ? (domainNE[chosen.key] ?? "जीवन") : (domainEN[chosen.key] ?? "life")
        let cautious = weakest.value <= 2
        if ne {
            let teaser = cautious
                ? "तपाईंको \(area) पक्षमा ध्यान दिनुपर्ने एउटा संकेत अझै बाँकी छ।"
                : "तपाईंको \(area) पक्षमा उपयोग गर्न मिल्ने एउटा विशेष अवसर छ।"
            let cta = cautious
                ? "\(area) कसरी सम्हाल्ने भनेर पण्डितजीलाई सोध्नुहोस्"
                : "\(area) को अवसरबारे पण्डितजीलाई सोध्नुहोस्"
            let prompt = "मेरो \(period.rawValue) राशिफलमा \(area) को अंक \(L10n.digits(chosen.value, .ne))/५ छ। यसले मेरो कुण्डली र हालको दशासँग मिलेर के संकेत गर्छ, र मैले के गर्नुपर्छ?"
            return (teaser, cta, prompt)
        }
        let teaser = cautious
            ? "There is one signal in your \(area) outlook worth looking at more closely."
            : "There is one useful opening in your \(area) outlook that the summary cannot fully show."
        let cta = cautious
            ? "Ask Pandit-ji how to handle your \(area) outlook"
            : "Ask Pandit-ji about your \(area) opportunity"
        let prompt = "My \(period.rawValue) rashifal gives \(area) \(chosen.value)/5. How does that connect with my kundli and current dasha, and what should I do?"
        return (teaser, cta, prompt)
    }

    private static func cachedValue(for key: CacheKey) -> Rashifal? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let value = cache[key] {
            cacheHits += 1
            return value
        }
        cacheMisses += 1
        return nil
    }

    private static func store(_ value: Rashifal, for key: CacheKey) {
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
