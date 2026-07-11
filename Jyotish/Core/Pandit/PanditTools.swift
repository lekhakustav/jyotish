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

// MARK: - Intent planning and structured answers

enum PanditIntent: String, Codable, Equatable {
    case daily, muhurta, compatibility, panchang, kundliDasha
    case family, remedy, devotional, event, reminder, general
}

struct PanditToolEvidence: Codable, Equatable {
    var tool: String
    var summary: String
    var facts: [String]
    var uncertainty: String?
}

struct PanditToolPlan: Equatable {
    var intent: PanditIntent
    var answer: String
    var evidence: [PanditToolEvidence]
    var actions: [PanditAction]
}

enum PanditAnswerContract {
    /// A stale or misconfigured remote model must never remove the clear shape
    /// promised by the app. The local deterministic answer is used whenever a
    /// remote response omits one of these user-facing sections.
    static func isSatisfied(by answer: String, language: Language) -> Bool {
        let required = language == .ne
            ? ["सीधा उत्तर", "बाजेले यसो भन्नुको कारण", "अब के गर्ने", "वैकल्पिक साधना"]
            : ["Direct answer", "Why Baje says this", "What to do", "Optional practice"]
        return required.allSatisfy(answer.localizedCaseInsensitiveContains)
    }

    static func completed(_ answer: String, fallback: String, language: Language) -> String {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback }
        guard !isSatisfied(by: trimmed, language: language) else { return trimmed }
        let heading = language == .ne ? "## प्रमाणित एप मार्गदर्शन" : "## Verified app guidance"
        return "\(trimmed)\n\n\(heading)\n\(fallback)"
    }
}

private struct StructuredPanditAnswer {
    var direct: String
    var why: [String]
    var action: String
    var practice: String
    var uncertainty: String?

    func render(_ language: Language) -> String {
        let ne = language == .ne
        var sections = [
            "**\(ne ? "सीधा उत्तर" : "Direct answer")**\n\(direct)",
            "**\(ne ? "बाजेले यसो भन्नुको कारण" : "Why Baje says this")**\n\(why.map { "• \($0)" }.joined(separator: "\n"))",
            "**\(ne ? "अब के गर्ने" : "What to do")**\n\(action)",
            "**\(ne ? "वैकल्पिक साधना" : "Optional practice")**\n\(practice)",
        ]
        if let uncertainty, !uncertainty.isEmpty {
            sections.append("**\(ne ? "अनिश्चितता" : "Uncertainty")**\n\(uncertainty)")
        }
        return sections.joined(separator: "\n\n")
    }
}

/// Converts ordinary household questions into deterministic tool calls. The
/// future remote model receives this evidence and interprets it; it does not
/// get to invent the astrology or the available actions.
enum PanditToolPlanner {
    static func plan(query: String,
                     family: [FamilyMember],
                     events: [PatroEvent],
                     language: Language,
                     now: Date = Date()) -> PanditToolPlan {
        let q = query.lowercased()
        let intent = detectIntent(q)
        let selfMember = family.first { $0.relation == .selfMember }
        let place = selfMember?.birth?.place ?? .kathmandu

        switch intent {
        case .muhurta:
            return muhurtaPlan(query: query, place: place, language: language, now: now)
        case .compatibility:
            return compatibilityPlan(query: query, family: family, language: language)
        case .panchang:
            return panchangPlan(place: place, language: language, now: now)
        case .devotional:
            return devotionalPlan(place: place, language: language, now: now)
        case .daily:
            return dailyPlan(member: resolveMember(in: q, family: family) ?? selfMember,
                             family: family, language: language, now: now)
        case .kundliDasha, .family, .remedy, .general:
            return chartPlan(intent: intent,
                             query: query,
                             member: resolveMember(in: q, family: family) ?? selfMember,
                             family: family,
                             language: language)
        case .event:
            let answer = StructuredPanditAnswer(
                direct: language == .ne ? "म पात्रोमा कार्यक्रम थप्न तयार छु।" : "I am ready to add an event to your Patro.",
                why: [language == .ne ? "कार्यक्रम परिवारको एउटै पात्रोमा सुरक्षित हुन्छ।" : "The event will be saved in the household Patro."],
                action: language == .ne ? "तलको ‘पात्रोमा थप्नुहोस्’ थिचेर मिति र नाम पुष्टि गर्नुहोस्।" : "Tap Add to Patro below and confirm the date and title.",
                practice: language == .ne ? "कार्यक्रमको दिन परिवारका लागि सानो शुभकामना राख्न सक्नुहुन्छ।" : "You can include a short family blessing for the day.",
                uncertainty: nil)
            return PanditToolPlan(intent: .event,
                                  answer: answer.render(language),
                                  evidence: [PanditToolEvidence(tool: "patro.events", summary: "Household event store", facts: [], uncertainty: nil)],
                                  actions: commonActions(prefix: [PanditAction(kind: .addToPatro)]))
        case .reminder:
            let answer = StructuredPanditAnswer(
                direct: language == .ne ? "म तपाईंलाई स्थानीय रिमाइन्डर राख्न मद्दत गर्छु।" : "I can help set a private local reminder.",
                why: [language == .ne ? "रिमाइन्डर यही उपकरणमा रहन्छ।" : "The reminder stays on this device."],
                action: language == .ne ? "तल ‘सम्झाइदिनुहोस्’ थिचेर मिति पुष्टि गर्नुहोस्।" : "Tap Remind me below and confirm the date.",
                practice: language == .ne ? "रिमाइन्डरलाई उपयोगी कामसँग जोड्नुहोस्, डर वा दबाबसँग होइन।" : "Tie reminders to a useful action, never fear or pressure.",
                uncertainty: nil)
            return PanditToolPlan(intent: .reminder,
                                  answer: answer.render(language),
                                  evidence: [PanditToolEvidence(tool: "local.reminder", summary: "Local notification", facts: [], uncertainty: nil)],
                                  actions: commonActions(prefix: [PanditAction(kind: .remind)]))
        }
    }

    private static func detectIntent(_ q: String) -> PanditIntent {
        if contains(q, ["muhurat", "muhurta", "auspicious time", "good time", "shubh time", "good date", "when should", "शुभ समय", "शुभ दिन", "शुभ साइत", "साइत", "कहिले"]) { return .muhurta }
        if contains(q, ["compatib", "matchmaking", "match kundli", "guna", "मिलान", "गुण", "जोडी", "विवाह मिल्छ"]) { return .compatibility }
        if contains(q, ["add event", "save date", "add to patro", "कार्यक्रम थप", "पात्रोमा राख"]) { return .event }
        if contains(q, ["remind", "reminder", "याद दिला", "सम्झाइ"]) { return .reminder }
        if contains(q, ["panchang", "panchanga", "tithi", "nakshatra", "पञ्चाङ्ग", "तिथि", "नक्षत्र", "पात्रो"]) { return .panchang }
        if contains(q, ["festival", "vrat", "fast", "puja", "pooja", "aarti", "mantra", "पर्व", "व्रत", "पूजा", "आरती", "मन्त्र", "चाड"]) { return .devotional }
        if contains(q, ["today", "my day", "daily", "आज", "आजको दिन", "राशिफल"]) { return .daily }
        if contains(q, ["kundli", "kundali", "dasha", "rashi", "lagna", "कुण्डली", "दशा", "राशि", "लग्न"]) { return .kundliDasha }
        if contains(q, ["son", "daughter", "child", "family", "छोरा", "छोरी", "बच्चा", "परिवार"]) { return .family }
        if contains(q, ["remedy", "upaya", "gem", "color", "vastu", "उपाय", "रत्न", "रंग", "रङ", "वास्तु"]) { return .remedy }
        return .general
    }

    private static func contains(_ query: String, _ terms: [String]) -> Bool {
        terms.contains(where: query.contains)
    }

    private static func muhurtaPlan(query: String,
                                    place: BirthPlace,
                                    language: Language,
                                    now: Date) -> PanditToolPlan {
        let purpose = MuhurtaPurpose.detect(in: query)
        if purpose == .general {
            let sections = StructuredPanditAnswer(
                direct: language == .ne
                    ? "अवश्य। पहिले तपाईं के योजना बनाउँदै हुनुहुन्छ भनेर छान्नुहोस्।"
                    : "Of course. First, choose what you are planning.",
                why: [language == .ne
                    ? "पूजा, यात्रा, गृहप्रवेश र विवाहका लागि उपयुक्त तिथि, नक्षत्र र वार फरक हुन्छन्।"
                    : "Puja, travel, house entry, and marriage use different tithi, nakshatra, and weekday factors."],
                action: language == .ne
                    ? "तलको विकल्पबाट काम छान्नुहोस्, त्यसपछि म मिति खोज्छु।"
                    : "Choose an option below, then I will find suitable dates.",
                practice: language == .ne
                    ? "निर्णयअघि परिवारसँग आवश्यक स्थान र समयबारे छोटो सल्लाह गर्नुहोस्।"
                    : "Before choosing, briefly confirm the place and practical timing with your family.",
                uncertainty: language == .ne
                    ? "कामको प्रकार नबताई निश्चित साइत दिनु उचित हुँदैन।"
                    : "A specific Muhurta should not be offered until the purpose is known.")
            return PanditToolPlan(
                intent: .muhurta,
                answer: sections.render(language),
                evidence: [PanditToolEvidence(
                    tool: "find_muhurta.requirements",
                    summary: "purpose required",
                    facts: [],
                    uncertainty: language == .ne ? "कामको प्रकार आवश्यक छ।" : "The purpose is required.")],
                actions: commonActions(prefix: []))
        }
        let candidates = MuhurtaEngine.find(purpose: purpose, from: now, days: 30, place: place, language: language)
        guard let best = candidates.first else {
            return chartPlan(intent: .general, query: query, member: nil, family: [], language: language)
        }
        let date = dateLabel(best.date, language: language)
        let bs = "\(L10n.digits(best.bsDate.day, language)) \(best.bsDate.monthName(ne: language == .ne))"
        let direct = language == .ne
            ? "\(purpose.name(.ne))का लागि प्रारम्भिक रूपमा \(date) (\(bs)) सबैभन्दा सहयोगी देखिन्छ।"
            : "\(date) (\(bs) BS) is the strongest preliminary candidate for \(purpose.name(.en))."
        let devotional = DevotionalKnowledge.forDay(best.date, place: place, language: language)
        let sections = StructuredPanditAnswer(
            direct: direct,
            why: best.reasons,
            action: language == .ne ? "म यो मिति पात्रोमा राख्न वा रिमाइन्डर बनाउन सक्छु।" : "I can add this date to Patro or set a reminder.",
            practice: devotional.practice,
            uncertainty: best.caution)
        let title = language == .ne ? "\(purpose.name(.ne)) साइत" : "\(purpose.name(.en).capitalized) Muhurta"
        let evidence = PanditToolEvidence(
            tool: "find_muhurta",
            summary: "\(best.score)/100",
            facts: best.reasons + ["date=\(ISO8601DateFormatter().string(from: best.date))", "place=\(place.name)"],
            uncertainty: best.caution)
        return PanditToolPlan(
            intent: .muhurta,
            answer: sections.render(language),
            evidence: [evidence],
            actions: commonActions(prefix: [
                PanditAction(kind: .addToPatro, date: best.date, title: title),
                PanditAction(kind: .remind, date: best.date, title: title),
                PanditAction(kind: .openPatro),
            ]))
    }

    private static func compatibilityPlan(query: String,
                                          family: [FamilyMember],
                                          language: Language) -> PanditToolPlan {
        let named = family.filter { member in
            !member.name.isEmpty && query.lowercased().contains(member.name.lowercased())
        }
        let pair: [FamilyMember]
        if named.count >= 2 {
            pair = Array(named.prefix(2))
        } else {
            pair = Array(family.filter(\.hasBirthData).prefix(2))
        }
        guard pair.count == 2,
              let reading = CompatibilityEngine.compare(pair[0], pair[1], language: language) else {
            let sections = StructuredPanditAnswer(
                direct: language == .ne ? "मिलानका लागि दुई जनाको जन्म विवरण चाहिन्छ।" : "I need birth details for two people to compare them.",
                why: [language == .ne ? "मिलान चन्द्र राशि, नक्षत्र र स्वामी ग्रहबाट सुरु हुन्छ।" : "The preliminary match uses Moon signs, nakshatras, and rashi lords."],
                action: language == .ne ? "परिवारमा दुवै व्यक्ति थपेर फेरि सोध्नुहोस्।" : "Add both people to Parivar, then ask again.",
                practice: language == .ne ? "निर्णयमा संवाद र परिवारको सहमति पनि महत्त्वपूर्ण हुन्छ।" : "Conversation and family consent matter alongside astrology.",
                uncertainty: language == .ne ? "यो औपचारिक ३६ गुण मिलान होइन।" : "This is not a formal 36-guna report.")
            return PanditToolPlan(intent: .compatibility,
                                  answer: sections.render(language),
                                  evidence: [],
                                  actions: commonActions(prefix: [PanditAction(kind: .compare)]))
        }
        let why = Array((reading.strengths + reading.cautions).prefix(4))
        let sections = StructuredPanditAnswer(
            direct: "\(pair[0].name) + \(pair[1].name): \(reading.summary)",
            why: why.isEmpty ? [language == .ne ? "चार देखिने कुण्डली कारक तुलना गरिएको छ।" : "Four visible chart factors were compared."] : why,
            action: language == .ne ? "बलियो र संवेदनशील दुवै क्षेत्रमा खुला कुरा गर्नुहोस्।" : "Discuss both the strong and sensitive areas openly.",
            practice: language == .ne ? "ठूलो निर्णयअघि दुवै परिवारको शान्त सहमतिका लागि प्रार्थना गर्नुहोस्।" : "Before a major decision, make space for calm agreement between both families.",
            uncertainty: reading.uncertainty ?? (language == .ne ? "यो प्रारम्भिक तुलना हो; औपचारिक विवाह मिलान होइन।" : "This is a preliminary comparison, not formal marriage matching."))
        let evidence = PanditToolEvidence(tool: "compare_kundli",
                                          summary: "\(reading.score)/100",
                                          facts: why,
                                          uncertainty: reading.uncertainty)
        return PanditToolPlan(intent: .compatibility,
                              answer: sections.render(language),
                              evidence: [evidence],
                              actions: commonActions(prefix: [
                                PanditAction(kind: .compare),
                                PanditAction(kind: .seeKundli, memberID: pair[0].id),
                              ]))
    }

    private static func panchangPlan(place: BirthPlace,
                                     language: Language,
                                     now: Date) -> PanditToolPlan {
        let pan = Panchanga.forDay(now, place: place)
        let ne = language == .ne
        let direct = ne
            ? "आज \(pan.tithiName(ne: true)), \(pan.pakshaName(ne: true)) र \(pan.nakshatra.nameNE) नक्षत्र छ।"
            : "Today is \(pan.tithiName(ne: false)), \(pan.pakshaName(ne: false)), under \(pan.nakshatra.nameEN) nakshatra."
        let devotional = DevotionalKnowledge.guidance(for: pan, language: language)
        let facts = [
            ne ? "योग: \(pan.yogaName(ne: true))" : "Yoga: \(pan.yogaName(ne: false))",
            ne ? "करण: \(pan.karanaName(ne: true))" : "Karana: \(pan.karanaName(ne: false))",
            ne ? "स्थान: \(place.nameNE)" : "Place: \(place.name)",
        ]
        let sections = StructuredPanditAnswer(
            direct: direct,
            why: facts,
            action: ne ? "पूरा दिन वा अर्को मिति हेर्न पात्रो खोल्नुहोस्।" : "Open Patro for the full day or another date.",
            practice: devotional.practice,
            uncertainty: nil)
        return PanditToolPlan(intent: .panchang,
                              answer: sections.render(language),
                              evidence: [PanditToolEvidence(tool: "get_panchang", summary: direct, facts: facts, uncertainty: nil)],
                              actions: commonActions(prefix: [PanditAction(kind: .openPatro)]))
    }

    private static func devotionalPlan(place: BirthPlace,
                                        language: Language,
                                        now: Date) -> PanditToolPlan {
        let guide = DevotionalKnowledge.forDay(now, place: place, language: language)
        let sections = StructuredPanditAnswer(
            direct: "\(guide.title): \(guide.meaning)",
            why: [language == .ne ? "आजको तिथि र स्थानअनुसार यो साधना सान्दर्भिक छ।" : "This practice is relevant to today's tithi and place."],
            action: language == .ne ? "स्वास्थ्य र परिवारको अवस्थाअनुसार सरल रूपमा पालन गर्नुहोस्।" : "Observe it simply, according to your health and household circumstances.",
            practice: guide.practice,
            uncertainty: language == .ne ? "क्षेत्रीय परम्परा फरक हुन सक्छ।" : "Regional traditions may differ.")
        return PanditToolPlan(intent: .devotional,
                              answer: sections.render(language),
                              evidence: [PanditToolEvidence(tool: "get_vrat_festival", summary: guide.title, facts: [guide.meaning, guide.practice], uncertainty: nil)],
                              actions: commonActions(prefix: [PanditAction(kind: .openPatro)]))
    }

    private static func dailyPlan(member: FamilyMember?,
                                  family: [FamilyMember],
                                  language: Language,
                                  now: Date) -> PanditToolPlan {
        guard let member, let kundali = member.kundali else {
            return chartPlan(intent: .daily, query: language == .ne ? "आज" : "today", member: member, family: family, language: language)
        }
        let r = RashifalEngine.generate(rashi: kundali.moonRashi, period: .daily, date: now, lang: language)
        let strongest = r.scores.max(by: { $0.value < $1.value })?.key ?? "rashifal.family"
        let why = [
            language == .ne ? "चन्द्र राशि: \(kundali.moonRashi.nameNE)" : "Moon rashi: \(kundali.moonRashi.shortEN)",
            language == .ne ? "आज बलियो क्षेत्र: \(L10n.t(strongest, .ne))" : "Strongest area today: \(L10n.t(strongest, .en))",
        ]
        let uncertainty = member.birth?.timeKnown == false
            ? (language == .ne ? "जन्म समय अज्ञात भएकाले लग्न-आधारित भाग समावेश छैन।" : "Birth time is unknown, so Lagna-based guidance is excluded.")
            : nil
        let sections = StructuredPanditAnswer(
            direct: r.text,
            why: why,
            action: language == .ne ? "आज सबैभन्दा बलियो क्षेत्रलाई प्राथमिकता दिनुहोस्।" : "Prioritize the strongest area today.",
            practice: r.upaya,
            uncertainty: uncertainty)
        return PanditToolPlan(intent: .daily,
                              answer: sections.render(language),
                              evidence: [PanditToolEvidence(tool: "get_daily_guidance", summary: r.text, facts: why, uncertainty: uncertainty)],
                              actions: commonActions(prefix: [
                                PanditAction(kind: .seeKundli, memberID: member.id),
                                PanditAction(kind: .openPatro),
                              ]))
    }

    private static func chartPlan(intent: PanditIntent,
                                  query: String,
                                  member: FamilyMember?,
                                  family: [FamilyMember],
                                  language: Language) -> PanditToolPlan {
        let brain = PanditBrain(family: family, lang: language)
        let direct = brain.reply(to: query)
        let hasChart = member?.kundali != nil
        let why = hasChart
            ? [language == .ne ? "परिवारमा सुरक्षित जन्म विवरण र गणना गरिएको कुण्डली प्रयोग गरिएको छ।" : "The saved birth details and computed household kundli were used."]
            : [language == .ne ? "ठ्याक्कै कुण्डली उत्तरका लागि जन्म विवरण आवश्यक हुन्छ।" : "Exact chart guidance needs birth details."]
        let uncertainty = member?.birth?.timeKnown == false
            ? (language == .ne ? "जन्म समय अज्ञात भएकाले लग्नसम्बन्धी दाबी नरम राखिएको छ।" : "Birth time is unknown, so Lagna claims are softened.")
            : nil
        let sections = StructuredPanditAnswer(
            direct: direct,
            why: why,
            action: language == .ne ? "तपाईं चाहनुहुन्छ भने म यही प्रश्नलाई दिन, परिवार वा मितिमा केन्द्रित गर्न सक्छु।" : "If you like, I can narrow this to a day, family member, or date.",
            practice: DevotionalKnowledge.forDay(language: language).practice,
            uncertainty: uncertainty)
        var prefix: [PanditAction] = []
        if hasChart { prefix.append(PanditAction(kind: .seeKundli, memberID: member?.id)) }
        if intent == .family { prefix.append(PanditAction(kind: .compare)) }
        return PanditToolPlan(intent: intent,
                              answer: sections.render(language),
                              evidence: [PanditToolEvidence(tool: "get_kundli_context", summary: direct, facts: why, uncertainty: uncertainty)],
                              actions: commonActions(prefix: prefix))
    }

    private static func commonActions(prefix: [PanditAction]) -> [PanditAction] {
        prefix + [PanditAction(kind: .listen), PanditAction(kind: .share)]
    }

    private static func resolveMember(in query: String, family: [FamilyMember]) -> FamilyMember? {
        if let named = family.first(where: { !($0.name.isEmpty) && query.contains($0.name.lowercased()) }) {
            return named
        }
        let relations: [(Relation, [String])] = [
            (.son, ["son", "छोरा"]), (.daughter, ["daughter", "छोरी"]),
            (.husband, ["husband", "श्रीमान्"]), (.wife, ["wife", "श्रीमती"]),
            (.father, ["father", "बुबा"]), (.mother, ["mother", "आमा"]),
        ]
        for (relation, words) in relations where words.contains(where: query.contains) {
            if let member = family.first(where: { $0.relation == relation }) { return member }
        }
        return family.first { $0.relation == .selfMember }
    }

    private static func dateLabel(_ date: Date, language: Language) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: language == .ne ? "ne_NP" : "en_US")
        return formatter.string(from: date)
    }
}
