import Foundation

// MARK: - Muhurta planning

/// High-level household intents supported by the on-device Muhurta planner.
/// Results are planning candidates based on Panchanga limbs, not a replacement
/// for a ceremony-specific sankalpa from a human Pandit.
enum MuhurtaPurpose: String, Codable, CaseIterable, Identifiable {
    case general, marriage, grihaPravesh, vehicle, travel, business, education, puja, naming

    var id: String { rawValue }

    static func detect(in query: String) -> MuhurtaPurpose {
        let q = query.lowercased()
        let matches: [(MuhurtaPurpose, [String])] = [
            (.marriage, ["marriage", "wedding", "vivah", "विवाह", "बिहे"]),
            (.grihaPravesh, ["griha", "house entry", "new home", "गृहप्रवेश", "घर सर्ने"]),
            (.vehicle, ["vehicle", "car", "bike", "गाडी", "मोटरसाइकल"]),
            (.travel, ["travel", "trip", "journey", "यात्रा", "विदेश"]),
            (.business, ["business", "shop", "company", "काम सुरु", "व्यापार", "पसल"]),
            (.education, ["study", "exam", "school", "education", "पढाइ", "परीक्षा"]),
            (.puja, ["puja", "pooja", "havan", " पूजा", "पूजा", "हवन"]),
            (.naming, ["naming", "naamkaran", "baby name", "नामकरण", "न्वारान"]),
        ]
        return matches.first(where: { $0.1.contains(where: q.contains) })?.0 ?? .general
    }

    func name(_ language: Language) -> String {
        let names: [MuhurtaPurpose: (String, String)] = [
            .general: ("important work", "महत्त्वपूर्ण काम"),
            .marriage: ("marriage", "विवाह"),
            .grihaPravesh: ("griha pravesh", "गृहप्रवेश"),
            .vehicle: ("vehicle purchase", "सवारी खरिद"),
            .travel: ("travel", "यात्रा"),
            .business: ("business start", "व्यापार आरम्भ"),
            .education: ("study or exam", "पढाइ वा परीक्षा"),
            .puja: ("puja", "पूजा"),
            .naming: ("naamkaran", "नामकरण"),
        ]
        let pair = names[self]!
        return language == .ne ? pair.1 : pair.0
    }
}

struct MuhurtaCandidate: Equatable {
    var date: Date
    var bsDate: NepaliDate
    var purpose: MuhurtaPurpose
    var score: Int
    var reasons: [String]
    var caution: String
}

enum MuhurtaEngine {
    private static let broadlySupportiveNakshatras: Set<Nakshatra> = [
        .rohini, .mrigashira, .punarvasu, .pushya, .uttaraPhalguni, .hasta,
        .chitra, .anuradha, .uttaraAshadha, .shravana, .dhanishta,
        .shatabhisha, .uttaraBhadrapada, .revati,
    ]
    private static let supportiveYogas: Set<Int> = [1, 2, 3, 4, 6, 7, 10, 11, 13, 15, 19, 20, 21, 22, 23, 24, 25]
    private static let difficultYogas: Set<Int> = [5, 8, 9, 12, 14, 16, 18, 26]

    static func find(purpose: MuhurtaPurpose,
                     from start: Date = Date(),
                     days: Int = 30,
                     place: BirthPlace = .kathmandu,
                     language: Language) -> [MuhurtaCandidate] {
        let calendar = calendar(for: place)
        let startDay = calendar.startOfDay(for: start)
        let candidates = (0..<max(1, days)).compactMap { offset -> MuhurtaCandidate? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDay) else { return nil }
            let panchanga = Panchanga.forDay(date, place: place)
            return evaluate(date: date, panchanga: panchanga, purpose: purpose, language: language)
        }
        return Array(candidates.sorted {
            if $0.score == $1.score { return $0.date < $1.date }
            return $0.score > $1.score
        }.prefix(3))
    }

    static func evaluate(date: Date,
                         panchanga: Panchanga,
                         purpose: MuhurtaPurpose,
                         language: Language) -> MuhurtaCandidate {
        let ne = language == .ne
        var score = 42
        var reasons: [String] = []

        let tithi = panchanga.tithiInPaksha
        let supportiveTithis = tithis(for: purpose)
        if supportiveTithis.contains(tithi) {
            score += 22
            reasons.append(ne
                ? "\(panchanga.tithiName(ne: true)) तिथि \(purpose.name(.ne))का लागि सहयोगी छ।"
                : "\(panchanga.tithiName(ne: false)) tithi supports \(purpose.name(.en)).")
        } else if [4, 9, 14, 15].contains(tithi) {
            score -= 22
        }

        let supportiveWeekdays = weekdays(for: purpose)
        if supportiveWeekdays.contains(panchanga.weekday) {
            score += 14
            let weekday = ne ? L10n.weekdaysFullNE[panchanga.weekday - 1] : L10n.weekdaysFullEN[panchanga.weekday - 1]
            reasons.append(ne ? "\(weekday) यस कामका लागि अनुकूल वार हो।" : "\(weekday) is supportive for this purpose.")
        }

        if broadlySupportiveNakshatras.contains(panchanga.nakshatra) {
            score += 18
            reasons.append(ne
                ? "\(panchanga.nakshatra.nameNE) नक्षत्र स्थिर र उपयोगी कामलाई साथ दिन्छ।"
                : "\(panchanga.nakshatra.nameEN) nakshatra supports steady, constructive work.")
        } else if [.ashlesha, .magha, .jyeshtha, .mula].contains(panchanga.nakshatra) {
            score -= 12
        }

        if supportiveYogas.contains(panchanga.yogaIndex) {
            score += 12
            reasons.append(ne
                ? "\(panchanga.yogaName(ne: true)) योगले दिनलाई बल दिन्छ।"
                : "\(panchanga.yogaName(ne: false)) yoga strengthens the day.")
        } else if difficultYogas.contains(panchanga.yogaIndex) {
            score -= 12
        }

        if !panchanga.isShukla && panchanga.tithiInPaksha == 15 { score -= 25 }
        score = min(100, max(0, score))
        if reasons.isEmpty {
            reasons.append(ne
                ? "दिन मध्यम छ; अर्को विकल्पसँग तुलना गर्नु राम्रो हुन्छ।"
                : "The day is mixed; compare it with another candidate before deciding.")
        }
        let caution = ne
            ? "यो पात्रो-आधारित प्रारम्भिक छनोट हो। विवाह वा संस्कारको ठ्याक्कै समय अनुभवी पण्डितसँग पुष्टि गर्नुहोस्।"
            : "This is a Panchanga-based planning candidate. Confirm the exact time for marriage or formal samskara with an experienced Pandit."
        return MuhurtaCandidate(date: date,
                                bsDate: BikramSambat.toBS(date),
                                purpose: purpose,
                                score: score,
                                reasons: Array(reasons.prefix(3)),
                                caution: caution)
    }

    private static func tithis(for purpose: MuhurtaPurpose) -> Set<Int> {
        switch purpose {
        case .marriage: return [2, 3, 5, 7, 10, 11, 13]
        case .grihaPravesh, .vehicle: return [2, 3, 5, 7, 10, 11, 13]
        case .travel: return [2, 3, 5, 7, 10, 11]
        case .business, .education: return [2, 3, 5, 7, 10, 11, 13]
        case .puja: return [2, 3, 5, 7, 10, 11, 13, 15]
        case .naming: return [2, 3, 5, 7, 10, 11, 13]
        case .general: return [2, 3, 5, 7, 10, 11, 13]
        }
    }

    private static func weekdays(for purpose: MuhurtaPurpose) -> Set<Int> {
        switch purpose {
        case .marriage: return [2, 4, 5, 6]
        case .grihaPravesh, .vehicle, .naming: return [2, 4, 5, 6]
        case .travel: return [2, 3, 4, 5, 6]
        case .business, .education: return [4, 5, 6]
        case .puja: return [1, 2, 4, 5, 6]
        case .general: return [2, 4, 5, 6]
        }
    }

    private static func calendar(for place: BirthPlace) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: Int(place.utcOffsetHours * 3600)) ?? .current
        return calendar
    }
}

// MARK: - Compatibility

struct CompatibilityReading: Equatable {
    var score: Int
    var summary: String
    var strengths: [String]
    var cautions: [String]
    var uncertainty: String?
}

/// A transparent preliminary relationship reading. It deliberately does not
/// claim to be a formal 36-guna Ashtakoota report; each score comes from a
/// visible chart factor already computed by the app.
enum CompatibilityEngine {
    static func compare(_ first: FamilyMember,
                        _ second: FamilyMember,
                        language: Language) -> CompatibilityReading? {
        guard let a = first.kundali, let b = second.kundali else { return nil }
        let ne = language == .ne

        let element = elementScore(a.moonRashi, b.moonRashi)
        let lords = lordScore(a.moonRashi.lord, b.moonRashi.lord)
        let tara = taraScore(a.moonNakshatra, b.moonNakshatra)
        let bhakoot = bhakootScore(a.moonRashi, b.moonRashi)
        let score = Int((Double(element + lords + tara + bhakoot) / 20.0 * 100.0).rounded())

        var strengths: [String] = []
        var cautions: [String] = []
        appendFactor(element,
                     good: ne ? "राशि तत्वले स्वभाव मिलाउन सहयोग गर्छ।" : "The rashi elements support a natural temperament fit.",
                     caution: ne ? "राशि तत्व फरक भएकाले दिनचर्या र भावनामा सम्झौता चाहिन्छ।" : "Different rashi elements call for compromise in routines and emotions.",
                     strengths: &strengths, cautions: &cautions)
        appendFactor(lords,
                     good: ne ? "दुवै राशिका स्वामी ग्रहबीच मैत्री छ।" : "The two rashi lords have a supportive relationship.",
                     caution: ne ? "स्वामी ग्रहको स्वभाव फरक छ; निर्णय शैली खुला रूपमा बोल्नुहोस्।" : "The rashi lords differ; discuss decision styles openly.",
                     strengths: &strengths, cautions: &cautions)
        appendFactor(tara,
                     good: ne ? "नक्षत्र ताराबलले आपसी सहयोग देखाउँछ।" : "Nakshatra tara balance supports mutual encouragement.",
                     caution: ne ? "नक्षत्र लय फरक छ; दबाबको बेला धैर्य उपयोगी हुन्छ।" : "The nakshatra rhythm differs; patience helps under pressure.",
                     strengths: &strengths, cautions: &cautions)
        appendFactor(bhakoot,
                     good: ne ? "चन्द्र राशिको दूरी साझा लक्ष्यका लागि सहयोगी छ।" : "The Moon-sign distance supports shared goals.",
                     caution: ne ? "चन्द्र राशिको दूरी संवेदनशील छ; परिवार र पैसाबारे स्पष्टता राख्नुहोस्।" : "The Moon-sign distance is sensitive; be explicit about family and money.",
                     strengths: &strengths, cautions: &cautions)

        let summary: String
        switch score {
        case 75...:
            summary = ne ? "सम्बन्धको प्रारम्भिक ज्योतिषीय आधार बलियो देखिन्छ।" : "The preliminary astrological foundation looks strong."
        case 55..<75:
            summary = ne ? "सम्बन्धमा राम्रो आधार छ, केही क्षेत्रमा सचेत समझदारी चाहिन्छ।" : "There is a good foundation with a few areas needing conscious understanding."
        default:
            summary = ne ? "यो सम्बन्धमा फरक स्वभाव छन्; निर्णय अघि विस्तृत मिलान उपयोगी हुन्छ।" : "The charts show meaningful differences; a fuller match is useful before a major decision."
        }
        let uncertain = [first.birth, second.birth].contains { $0?.timeKnown == false }
            ? (ne
                ? "कम्तीमा एक जनाको जन्म समय अज्ञात छ; लग्न-आधारित मिलान समावेश गरिएको छैन।"
                : "At least one birth time is unknown, so Lagna-based matching is excluded.")
            : nil
        return CompatibilityReading(score: score,
                                    summary: summary,
                                    strengths: strengths,
                                    cautions: cautions,
                                    uncertainty: uncertain)
    }

    private static func appendFactor(_ score: Int,
                                     good: String,
                                     caution: String,
                                     strengths: inout [String],
                                     cautions: inout [String]) {
        if score >= 4 { strengths.append(good) }
        if score <= 2 { cautions.append(caution) }
    }

    private static func elementScore(_ a: Rashi, _ b: Rashi) -> Int {
        let ea = element(a), eb = element(b)
        if ea == eb { return 5 }
        if Set([ea, eb]) == Set([0, 2]) || Set([ea, eb]) == Set([1, 3]) { return 4 }
        return 2
    }

    /// 0 fire, 1 earth, 2 air, 3 water.
    private static func element(_ rashi: Rashi) -> Int {
        switch rashi.rawValue % 4 {
        case 0: return 0
        case 1: return 1
        case 2: return 2
        default: return 3
        }
    }

    private static func lordScore(_ a: Planet, _ b: Planet) -> Int {
        if a == b { return 5 }
        let friends: [Planet: Set<Planet>] = [
            .sun: [.moon, .mars, .jupiter],
            .moon: [.sun, .mercury],
            .mars: [.sun, .moon, .jupiter],
            .mercury: [.sun, .venus],
            .jupiter: [.sun, .moon, .mars],
            .venus: [.mercury, .saturn],
            .saturn: [.mercury, .venus],
        ]
        let mutual = friends[a]?.contains(b) == true && friends[b]?.contains(a) == true
        let oneWay = friends[a]?.contains(b) == true || friends[b]?.contains(a) == true
        return mutual ? 5 : (oneWay ? 4 : 2)
    }

    private static func taraScore(_ a: Nakshatra, _ b: Nakshatra) -> Int {
        func supportive(from start: Int, to end: Int) -> Bool {
            let count = (end - start + 27) % 27 + 1
            return [2, 4, 6, 8, 9].contains((count - 1) % 9 + 1)
        }
        let ab = supportive(from: a.rawValue, to: b.rawValue)
        let ba = supportive(from: b.rawValue, to: a.rawValue)
        return ab && ba ? 5 : ((ab || ba) ? 3 : 1)
    }

    private static func bhakootScore(_ a: Rashi, _ b: Rashi) -> Int {
        let distanceAB = (b.rawValue - a.rawValue + 12) % 12 + 1
        let distanceBA = (a.rawValue - b.rawValue + 12) % 12 + 1
        let pair = Set([distanceAB, distanceBA])
        if pair == Set([2, 12]) || pair == Set([5, 9]) || pair == Set([6, 8]) { return 1 }
        return 5
    }
}

// MARK: - Vrat, festival, and devotional guidance

struct DevotionalGuidance: Equatable {
    var title: String
    var meaning: String
    var practice: String
    var deity: String
}

enum DevotionalKnowledge {
    static func forDay(_ date: Date = Date(),
                       place: BirthPlace = .kathmandu,
                       language: Language) -> DevotionalGuidance {
        guidance(for: Panchanga.forDay(date, place: place), language: language)
    }

    static func guidance(for panchanga: Panchanga, language: Language) -> DevotionalGuidance {
        let ne = language == .ne
        switch (panchanga.isShukla, panchanga.tithiInPaksha) {
        case (_, 11):
            return DevotionalGuidance(
                title: ne ? "एकादशी व्रत" : "Ekadashi Vrat",
                meaning: ne ? "मन, भोजन र वाणीलाई सरल बनाउँदै विष्णु स्मरण गर्ने दिन।" : "A day to simplify food, speech, and the mind while remembering Vishnu.",
                practice: ne ? "स्वास्थ्यअनुसार व्रत वा सात्त्विक भोजन गर्नुहोस् र ‘ॐ नमो नारायणाय’ जप्नुहोस्।" : "Fast only as health allows, or take simple sattvic food and recite Om Namo Narayanaya.",
                deity: ne ? "भगवान् विष्णु" : "Lord Vishnu")
        case (_, 13):
            return DevotionalGuidance(
                title: ne ? "प्रदोष साधना" : "Pradosh Practice",
                meaning: ne ? "साँझ शिव स्मरण, क्षमा र मनको भार हलुका गर्ने समय।" : "An evening for Shiva remembrance, forgiveness, and releasing mental weight.",
                practice: ne ? "साँझ दीप बालेर ‘ॐ नमः शिवाय’ जप्नुहोस्।" : "Light a lamp in the evening and recite Om Namah Shivaya.",
                deity: ne ? "भगवान् शिव" : "Lord Shiva")
        case (false, 4):
            return DevotionalGuidance(
                title: ne ? "सङ्कष्टी चतुर्थी" : "Sankashti Chaturthi",
                meaning: ne ? "अवरोध हटाउने बुद्धि र धैर्यका लागि गणेश स्मरण।" : "Remember Ganesha for patience and wisdom in overcoming obstacles.",
                practice: ne ? "गणेशलाई दूबो वा फूल चढाएर ‘ॐ गं गणपतये नमः’ जप्नुहोस्।" : "Offer durva or a flower to Ganesha and recite Om Gam Ganapataye Namah.",
                deity: ne ? "श्री गणेश" : "Shri Ganesha")
        case (false, 14):
            return DevotionalGuidance(
                title: ne ? "मासिक शिवरात्रि" : "Masik Shivaratri",
                meaning: ne ? "मौन, आत्मचिन्तन र शिव आराधनाको रात्रि।" : "A night for quiet reflection and Shiva worship.",
                practice: ne ? "सम्भव भए साँझ जल अर्पण गरी छोटो शिव ध्यान गर्नुहोस्।" : "If practical, offer water in the evening and sit for a short Shiva meditation.",
                deity: ne ? "भगवान् शिव" : "Lord Shiva")
        case (true, 15):
            return DevotionalGuidance(
                title: ne ? "पूर्णिमा" : "Purnima",
                meaning: ne ? "कृतज्ञता, गुरु स्मरण र पूर्णताको चन्द्र दिन।" : "A lunar day of gratitude, teachers, and completion.",
                practice: ne ? "चन्द्र दर्शनपछि परिवारसँग प्रार्थना वा दान गर्नुहोस्।" : "After Moon sighting, pray with the family or make a modest donation.",
                deity: ne ? "चन्द्रदेव र गुरु" : "Chandra and Guru")
        case (false, 15):
            return DevotionalGuidance(
                title: ne ? "औंसी" : "Aunsi",
                meaning: ne ? "पितृ स्मरण, विश्राम र घर शुद्ध गर्ने दिन।" : "A day for remembering ancestors, rest, and cleansing the home.",
                practice: ne ? "पितृका नाममा दीप बाल्नुहोस् वा आवश्यक व्यक्तिलाई भोजन दिनुहोस्।" : "Light a lamp in memory of ancestors or offer food to someone in need.",
                deity: ne ? "पितृदेव" : "Ancestors")
        default:
            return DevotionalGuidance(
                title: ne ? "आजको सरल साधना" : "A simple practice for today",
                meaning: ne ? "नियमित सानो साधना नै ठूलो आध्यात्मिक आधार बन्छ।" : "A small regular practice creates a durable spiritual foundation.",
                practice: ne ? "एक दीप बालेर तीन मिनेट शान्त बस्नुहोस्।" : "Light one lamp and sit quietly for three minutes.",
                deity: ne ? "इष्टदेव" : "Your ishta devata")
        }
    }
}
