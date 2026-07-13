import Foundation

struct CompatibilityFactor: Equatable, Identifiable {
    var id: String
    var name: String
    var score: Double
    var maximum: Double
    var meaning: String
    var guidance: String
}

struct CompatibilityReading: Equatable {
    /// Familiar percentage retained for compact UI and notification copy.
    var score: Int
    /// Formal Ashtakoota total. Eight transparent factors add to 36.
    var gunaScore: Double
    var factors: [CompatibilityFactor]
    var summary: String
    var strengths: [String]
    var cautions: [String]
    var firstManglik: Bool
    var secondManglik: Bool
    var manglikNote: String
    var uncertainty: String?
}

struct DailyRelationshipInsight: Equatable {
    var title: String
    var summary: String
    var support: String
    var struggle: String
    var doItem: String
    var dontItem: String
    var prompt: String
}

/// Ashtakoota is designed for marriage matching. The app uses the full eight
/// factors only in detailed reports. Daily family/friend guidance reuses the
/// non-marital chart signals (Moon, nakshatra rhythm, rashi lords and current
/// Chandra bala) without presenting a marriage verdict or a deterministic fate.
enum CompatibilityEngine {
    private enum Gana: Int { case deva, manushya, rakshasa }
    private enum Nadi: Int { case aadi, madhya, antya }
    private enum Vashya: Int { case chatushpada, manava, jalachara, vanachara, keeta }
    private enum Yoni: String {
        case horse, elephant, sheep, serpent, dog, cat, rat, cow, buffalo, tiger, deer, monkey, mongoose, lion
    }

    static func compare(_ first: FamilyMember,
                        _ second: FamilyMember,
                        language: Language) -> CompatibilityReading? {
        guard let a = first.kundali, let b = second.kundali else { return nil }
        let ne = language == .ne

        let rawFactors: [(String, String, Double, Double, String, String)] = [
            ("varna", ne ? "वर्ण (मूल्य शैली)" : "Varna (values style)",
             varnaScore(first: first, a: a, second: second, b: b), 1,
             ne ? "परम्परागत रूपमा अहं र मूल्यको ताल। यहाँ जात होइन, केवल चन्द्र राशिको प्रतीकात्मक शैली हो।"
                : "Traditionally the ego-and-values fit. Here it is a Moon-sign style, never a caste label.",
             ne ? "एकअर्काको सम्मान र निर्णयको आधार स्पष्ट गर्नुहोस्।" : "Make each person's values and decision basis explicit."),
            ("vashya", ne ? "वश्य" : "Vashya", vashyaScore(a, b), 2,
             ne ? "दैनिक सहकार्य, प्रभाव र स्वतन्त्रताको ताल।" : "The rhythm of cooperation, influence, and autonomy.",
             ne ? "नियन्त्रणको सट्टा भूमिका र सीमामा सहमति गर्नुहोस्।" : "Agree on roles and boundaries instead of trying to control."),
            ("tara", ne ? "तारा" : "Tara", taraScore(a.moonNakshatra, b.moonNakshatra), 3,
             ne ? "दुवै दिशाबाट नक्षत्रको सहयोग, स्वास्थ्य र भाग्यको लय।" : "Bidirectional nakshatra support, wellbeing, and fortune rhythm.",
             ne ? "दबाबमा एकअर्काको गति मिलाउन समय दिनुहोस्।" : "Allow time to match each other's pace under pressure."),
            ("yoni", ne ? "योनि" : "Yoni", yoniScore(a.moonNakshatra, b.moonNakshatra), 4,
             ne ? "वैवाहिक मिलानमा आकर्षण, निकटता र सहज प्रतिक्रिया।" : "In marriage matching, attraction, intimacy, and instinctive response.",
             ne ? "निकटतामा स्पष्ट सहमति र सहजता प्राथमिक राख्नुहोस्।" : "Prioritize clear consent and comfort in intimacy."),
            ("maitri", ne ? "ग्रह मैत्री" : "Graha Maitri", maitriScore(a.moonRashi.lord, b.moonRashi.lord), 5,
             ne ? "राशि स्वामीमार्फत मानसिक ताल, संवाद र मित्रता।" : "Mental fit, communication, and friendship through the rashi lords.",
             ne ? "निर्णय शैली फरक भए पनि कारण सुन्नुहोस्।" : "Listen for the reason behind a different decision style."),
            ("gana", ne ? "गण" : "Gana", ganaScore(a.moonNakshatra, b.moonNakshatra), 6,
             ne ? "स्वभाव, प्रतिक्रिया र सामाजिक व्यवहारको ताल।" : "Temperament, reactions, and social behavior.",
             ne ? "शान्त, व्यावहारिक वा तीव्र स्वभावलाई दोष नबनाउनुहोस्।" : "Do not turn calm, practical, or intense temperaments into blame."),
            ("bhakoot", ne ? "भकूट" : "Bhakoot", bhakootScore(a.moonRashi, b.moonRashi), 7,
             ne ? "भावनात्मक बन्धन, साझा लक्ष्य, परिवार र स्रोतको ताल।" : "Emotional bonding, shared goals, family, and resources.",
             ne ? "पैसा, परिवार र भविष्यको अपेक्षा पहिले नै बोल्नुहोस्।" : "Discuss money, family, and future expectations early."),
            ("nadi", ne ? "नाडी" : "Nadi", nadiScore(a.moonNakshatra, b.moonNakshatra), 8,
             ne ? "परम्परागत रूपमा स्वास्थ्य, वंश र जीवनशक्तिको वर्गीकरण। चिकित्सा वा आनुवंशिक परीक्षण होइन।"
                : "Traditionally a vitality, health, and lineage category. It is not medical or genetic testing.",
             ne ? "स्वास्थ्य वा सन्तानको निर्णय वास्तविक चिकित्सकीय सल्लाहबाट गर्नुहोस्।"
                : "Use real medical advice for health or family-planning decisions."),
        ]
        let factors = rawFactors.map {
            CompatibilityFactor(id: $0.0, name: $0.1, score: $0.2,
                                maximum: $0.3, meaning: $0.4, guidance: $0.5)
        }
        let guna = factors.reduce(0) { $0 + $1.score }
        let percentage = Int((guna / 36 * 100).rounded())
        let strengths = factors.filter { $0.score / $0.maximum >= 0.72 }
            .sorted { $0.maximum > $1.maximum }
            .prefix(3).map { "\($0.name): \($0.meaning)" }
        let cautions = factors.filter { $0.score / $0.maximum <= 0.34 }
            .sorted { $0.maximum > $1.maximum }
            .prefix(3).map { "\($0.name): \($0.guidance)" }

        let summary: String
        switch guna {
        case 29...:
            summary = ne ? "अष्टकूट आधार बलियो छ; सम्बन्धलाई व्यवहार र संवादले अझै आकार दिन्छ।"
                         : "The Ashtakoota foundation is strong; behavior and communication still shape the relationship."
        case 21..<29:
            summary = ne ? "राम्रो आधार छ, केही संवेदनशील पक्षमा सचेत समझदारी चाहिन्छ।"
                         : "There is a good foundation with a few areas needing conscious understanding."
        case 17..<21:
            summary = ne ? "मिश्रित मिलान छ; बलियो पक्षसँगै कमजोर पक्षलाई खुलेर सम्हाल्नुहोस्।"
                         : "The match is mixed; work openly with both its strengths and tensions."
        default:
            summary = ne ? "चार्टमा महत्त्वपूर्ण भिन्नता छन्; यसलाई निर्णय होइन, गहिरो संवादको संकेत मान्नुहोस्।"
                         : "The charts show meaningful differences; use this as a prompt for deeper conversation, not a verdict."
        }
        let firstManglik = isManglik(a)
        let secondManglik = isManglik(b)
        let manglikNote: String
        if firstManglik == secondManglik {
            manglikNote = ne
                ? (firstManglik ? "दुवैमा मंगल दोषको संकेत छ; परम्परागत रूपमा यसलाई सन्तुलित मानिन्छ।" : "दुवैमा प्रमुख मंगल दोषको संकेत भेटिएन।")
                : (firstManglik ? "Both charts show a Mangal Dosha indicator; tradition usually treats that as balanced." : "Neither chart shows the primary Mangal Dosha indicator.")
        } else {
            manglikNote = ne ? "एक चार्टमा मंगल दोषको संकेत छ र अर्कोमा छैन; औपचारिक विवाहअघि विस्तृत समीक्षा गर्नुहोस्।"
                             : "One chart shows a Mangal Dosha indicator and the other does not; review it carefully before a formal marriage decision."
        }
        let uncertainty = [first.birth, second.birth].contains { $0?.timeKnown == false }
            ? (ne ? "कम्तीमा एक जनाको जन्म समय अज्ञात छ; लग्न र मंगल दोषको घर-आधारित भाग सीमित हुन सक्छ।"
                  : "At least one birth time is unknown, so Lagna- and house-based Mangal analysis may be limited.")
            : (ne ? "अष्टकूट परम्परागत विश्वास प्रणाली हो; सम्बन्धको सुरक्षा, सहमति वा भविष्यको प्रमाण होइन।"
                  : "Ashtakoota is a traditional belief system, not proof of safety, consent, or a relationship's future.")

        return CompatibilityReading(score: percentage, gunaScore: guna, factors: factors,
                                    summary: summary, strengths: Array(strengths),
                                    cautions: Array(cautions), firstManglik: firstManglik,
                                    secondManglik: secondManglik, manglikNote: manglikNote,
                                    uncertainty: uncertainty)
    }

    static func dailyInsight(_ first: FamilyMember,
                             _ second: FamilyMember,
                             date: Date = Date(),
                             language: Language) -> DailyRelationshipInsight? {
        guard let a = first.kundali, let b = second.kundali,
              let reading = compare(first, second, language: language) else { return nil }
        let ne = language == .ne
        let jd = Ephemeris.julianDay(date)
        let transitMoon = Ephemeris.rashi(of: Ephemeris.sidereal(.moon, jd: jd))
        let firstMoon = Interpreter.chandraBala(natal: a.moonRashi, transitMoon: transitMoon)
        let secondMoon = Interpreter.chandraBala(natal: b.moonRashi, transitMoon: transitMoon)
        let strongest = reading.factors.max { ($0.score / $0.maximum) < ($1.score / $1.maximum) }
        let weakest = reading.factors.min { ($0.score / $0.maximum) < ($1.score / $1.maximum) }
        let bothOpen = firstMoon.favorable && secondMoon.favorable
        let neitherOpen = !firstMoon.favorable && !secondMoon.favorable

        let summary: String
        if bothOpen {
            summary = ne ? "आज दुवैको चन्द्रबलले सहज संवाद र सानो मेलमिलापलाई साथ दिन्छ।"
                         : "Today both Moon rhythms support an easier conversation and a small act of repair."
        } else if neitherOpen {
            summary = ne ? "आज दुवै संवेदनशील हुन सक्छन्; सही कुरा पनि नरम समयमा भन्नु राम्रो हुन्छ।"
                         : "Both may be more sensitive today; even the right point needs gentle timing."
        } else {
            summary = ne ? "आज एक जना अघि बढ्न चाहन्छ र अर्कोले समय खोज्न सक्छ; गति मिलाउनु मुख्य हो।"
                         : "One may want movement while the other needs space today; matching pace matters most."
        }
        let support = strongest.map { ne ? "बलियो पक्ष — \($0.name): \($0.meaning)" : "Support — \($0.name): \($0.meaning)" }
            ?? (ne ? "आज साझा धैर्य बलियो पक्ष हो।" : "Shared patience is today's support.")
        let struggle = weakest.map { ne ? "सम्हाल्ने पक्ष — \($0.name): \($0.guidance)" : "Watch — \($0.name): \($0.guidance)" }
            ?? (ne ? "पुरानो विवाद नदोहोर्याउनुहोस्।" : "Avoid replaying an old argument.")
        let romantic = second.relation.isRomantic
        let doItem = ne
            ? (romantic ? "मन पढ्ने प्रयास नगरी चाहना स्पष्ट रूपमा भन्नुहोस्।" : "सल्लाह दिनुअघि उनीलाई अहिले के चाहिन्छ भनेर सोध्नुहोस्।")
            : (romantic ? "State the need clearly instead of asking them to read your mind." : "Ask what they need before offering advice.")
        let dontItem = ne
            ? (neitherOpen ? "आजै निष्कर्ष वा अन्तिम निर्णयमा नपुग्नुहोस्।" : "जित्नका लागि उनीहरूको पुरानो कमजोरी नउठाउनुहोस्।")
            : (neitherOpen ? "Do not force a final conclusion today." : "Do not use an old vulnerability to win the moment.")
        let prompt = ne
            ? "मेरो र \(second.name)को कुण्डली, अष्टकूटका सान्दर्भिक पक्ष र आजको चन्द्र गोचर हेरेर हाम्रो सम्बन्धको बलियो पक्ष, अहिलेको तनाव, गर्नुपर्ने र नगर्नुपर्ने कुरा सहित विस्तृत रिपोर्ट दिनुहोस्।"
            : "Using my kundli, \(second.name)'s kundli, the relevant Ashtakoota factors, and today's Moon transit, prepare a detailed relationship report with our strengths, current tension, and clear dos and don'ts."
        return DailyRelationshipInsight(title: ne ? "\(second.name)सँगको सम्बन्ध" : "With \(second.name)",
                                        summary: summary, support: support, struggle: struggle,
                                        doItem: doItem, dontItem: dontItem, prompt: prompt)
    }

    static func isManglik(_ kundali: Kundali) -> Bool {
        [1, 2, 4, 7, 8, 12].contains(kundali.house(of: .mars) + 1)
    }

    private static func varnaScore(first: FamilyMember, a: Kundali,
                                   second: FamilyMember, b: Kundali) -> Double {
        func rank(_ rashi: Rashi) -> Int {
            switch rashi.rawValue % 4 {
            case 3: return 4 // water, Brahmin
            case 0: return 3 // fire, Kshatriya
            case 1: return 2 // earth, Vaishya
            default: return 1 // air, Shudra
            }
        }
        let ra = rank(a.moonRashi), rb = rank(b.moonRashi)
        if first.gender == .male && second.gender == .female { return ra >= rb ? 1 : 0 }
        if first.gender == .female && second.gender == .male { return rb >= ra ? 1 : 0 }
        return abs(ra - rb) <= 1 ? 1 : 0.5
    }

    private static func vashyaScore(_ a: Kundali, _ b: Kundali) -> Double {
        let va = vashya(a), vb = vashya(b)
        if va == vb { return 2 }
        let supportive: Set<Set<Int>> = [
            Set([Vashya.chatushpada.rawValue, Vashya.manava.rawValue]),
            Set([Vashya.manava.rawValue, Vashya.jalachara.rawValue]),
            Set([Vashya.chatushpada.rawValue, Vashya.vanachara.rawValue]),
        ]
        return supportive.contains(Set([va.rawValue, vb.rawValue])) ? 1.5 : 0.5
    }

    private static func vashya(_ kundali: Kundali) -> Vashya {
        switch kundali.moonRashi {
        case .mesh, .vrish: return .chatushpada
        case .mithun, .kanya, .tula, .kumbha: return .manava
        case .karkat, .meen: return .jalachara
        case .simha: return .vanachara
        case .vrischik: return .keeta
        case .dhanu:
            let degree = (kundali.longitudes[Planet.moon.rawValue] ?? 0).truncatingRemainder(dividingBy: 30)
            return degree < 15 ? .manava : .chatushpada
        case .makar:
            let degree = (kundali.longitudes[Planet.moon.rawValue] ?? 0).truncatingRemainder(dividingBy: 30)
            return degree < 15 ? .chatushpada : .jalachara
        }
    }

    private static func taraScore(_ a: Nakshatra, _ b: Nakshatra) -> Double {
        func supportive(from start: Int, to end: Int) -> Bool {
            let count = (end - start + 27) % 27 + 1
            return [2, 4, 6, 8, 9].contains((count - 1) % 9 + 1)
        }
        return (supportive(from: a.rawValue, to: b.rawValue) ? 1.5 : 0)
            + (supportive(from: b.rawValue, to: a.rawValue) ? 1.5 : 0)
    }

    private static func yoniScore(_ a: Nakshatra, _ b: Nakshatra) -> Double {
        let ya = yoni(a), yb = yoni(b)
        if ya == yb { return 4 }
        let enemies: Set<Set<String>> = [
            Set([Yoni.horse.rawValue, Yoni.buffalo.rawValue]),
            Set([Yoni.elephant.rawValue, Yoni.lion.rawValue]),
            Set([Yoni.sheep.rawValue, Yoni.monkey.rawValue]),
            Set([Yoni.serpent.rawValue, Yoni.mongoose.rawValue]),
            Set([Yoni.dog.rawValue, Yoni.deer.rawValue]),
            Set([Yoni.cat.rawValue, Yoni.rat.rawValue]),
            Set([Yoni.cow.rawValue, Yoni.tiger.rawValue]),
        ]
        if enemies.contains(Set([ya.rawValue, yb.rawValue])) { return 0 }
        return 2
    }

    private static func yoni(_ nakshatra: Nakshatra) -> Yoni {
        let values: [Yoni] = [
            .horse, .elephant, .sheep, .serpent, .serpent, .dog, .cat, .sheep, .cat,
            .rat, .rat, .cow, .buffalo, .tiger, .buffalo, .tiger, .deer, .deer,
            .dog, .monkey, .mongoose, .monkey, .lion, .horse, .lion, .cow, .elephant,
        ]
        return values[nakshatra.rawValue]
    }

    private static func maitriScore(_ a: Planet, _ b: Planet) -> Double {
        if a == b { return 5 }
        let friends: [Planet: Set<Planet>] = [
            .sun: [.moon, .mars, .jupiter], .moon: [.sun, .mercury],
            .mars: [.sun, .moon, .jupiter], .mercury: [.sun, .venus],
            .jupiter: [.sun, .moon, .mars], .venus: [.mercury, .saturn],
            .saturn: [.mercury, .venus],
        ]
        let enemies: [Planet: Set<Planet>] = [
            .sun: [.venus, .saturn], .moon: [], .mars: [.mercury],
            .mercury: [.moon], .jupiter: [.mercury, .venus],
            .venus: [.sun, .moon], .saturn: [.sun, .moon, .mars],
        ]
        let mutualFriend = friends[a]?.contains(b) == true && friends[b]?.contains(a) == true
        if mutualFriend { return 5 }
        let oneFriend = friends[a]?.contains(b) == true || friends[b]?.contains(a) == true
        if oneFriend { return 4 }
        let enemy = enemies[a]?.contains(b) == true || enemies[b]?.contains(a) == true
        return enemy ? 0.5 : 3
    }

    private static func ganaScore(_ a: Nakshatra, _ b: Nakshatra) -> Double {
        let ga = gana(a), gb = gana(b)
        if ga == gb { return 6 }
        let pair = Set([ga.rawValue, gb.rawValue])
        if pair == Set([Gana.deva.rawValue, Gana.manushya.rawValue]) { return 5 }
        if pair == Set([Gana.manushya.rawValue, Gana.rakshasa.rawValue]) { return 1 }
        return 0
    }

    private static func gana(_ nakshatra: Nakshatra) -> Gana {
        let deva: Set<Nakshatra> = [.ashwini, .mrigashira, .punarvasu, .pushya, .hasta,
                                    .swati, .anuradha, .shravana, .revati]
        let manushya: Set<Nakshatra> = [.bharani, .rohini, .ardra, .purvaPhalguni,
                                        .uttaraPhalguni, .purvaAshadha, .uttaraAshadha,
                                        .purvaBhadrapada, .uttaraBhadrapada]
        if deva.contains(nakshatra) { return .deva }
        if manushya.contains(nakshatra) { return .manushya }
        return .rakshasa
    }

    private static func bhakootScore(_ a: Rashi, _ b: Rashi) -> Double {
        let ab = (b.rawValue - a.rawValue + 12) % 12 + 1
        let ba = (a.rawValue - b.rawValue + 12) % 12 + 1
        let pair = Set([ab, ba])
        return pair == Set([2, 12]) || pair == Set([5, 9]) || pair == Set([6, 8]) ? 0 : 7
    }

    private static func nadiScore(_ a: Nakshatra, _ b: Nakshatra) -> Double {
        nadi(a) == nadi(b) ? 0 : 8
    }

    private static func nadi(_ nakshatra: Nakshatra) -> Nadi {
        let aadi: Set<Nakshatra> = [.ashwini, .ardra, .punarvasu, .uttaraPhalguni, .hasta,
                                    .jyeshtha, .mula, .shatabhisha, .purvaBhadrapada]
        let madhya: Set<Nakshatra> = [.bharani, .mrigashira, .pushya, .purvaPhalguni, .chitra,
                                      .anuradha, .purvaAshadha, .dhanishta, .uttaraBhadrapada]
        if aadi.contains(nakshatra) { return .aadi }
        if madhya.contains(nakshatra) { return .madhya }
        return .antya
    }
}

enum DoshaSeverity: Int, Codable, Comparable {
    case mild = 1, moderate = 2, strong = 3
    static func < (lhs: DoshaSeverity, rhs: DoshaSeverity) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct DoshaFinding: Equatable, Identifiable {
    var id: String
    var title: String
    var severity: DoshaSeverity
    var effect: String
    var evidence: String
    var remedies: [String]
}

enum DoshaEngine {
    static func analyze(_ member: FamilyMember,
                        at date: Date = Date(),
                        language: Language) -> [DoshaFinding] {
        guard let k = member.kundali else { return [] }
        let ne = language == .ne
        var findings: [DoshaFinding] = []

        let marsHouse = k.house(of: .mars) + 1
        if [1, 2, 4, 7, 8, 12].contains(marsHouse) {
            findings.append(DoshaFinding(
                id: "mangal", title: ne ? "मंगल दोष" : "Mangal Dosha",
                severity: [7, 8].contains(marsHouse) ? .strong : .moderate,
                effect: ne ? "सम्बन्धमा तीव्र प्रतिक्रिया, अधैर्य वा शक्ति-संघर्ष सम्हाल्न सचेतता चाहिन्छ।"
                           : "Relationships may need conscious handling of intensity, impatience, or power struggles.",
                evidence: ne ? "मंगल \(L10n.digits(marsHouse, .ne)) औं भावमा छ।" : "Mars is in house \(marsHouse).",
                remedies: ne ? ["मंगलबार संयमित सेवा वा दान गर्नुहोस्।", "हनुमान चालीसा वा आफ्नो परम्पराको मंगल शान्ति अभ्यास गर्नुहोस्।"]
                             : ["Practice disciplined service or charity on Tuesday.", "Recite Hanuman Chalisa or follow your tradition's Mangal-shanti practice."]))
        }

        if allClassicalPlanetsWithinOneNodeArc(k) {
            findings.append(DoshaFinding(
                id: "kaal-sarp", title: ne ? "काल सर्प योग संकेत" : "Kaal Sarp Yoga indicator",
                severity: .strong,
                effect: ne ? "जीवनका विषयहरूमा दबाब, एकाग्रता वा चरम उतारचढावको अनुभूति हुन सक्छ।"
                           : "Life themes may feel concentrated, pressured, or prone to sharper swings.",
                evidence: ne ? "सात शास्त्रीय ग्रह राहु–केतुको एउटै अर्धवृत्तभित्र छन्।"
                             : "All seven classical planets fall within one Rahu–Ketu half of the chart.",
                remedies: ne ? ["नाग वा शिव परम्पराको पूजा श्रद्धा र सरलतासाथ गर्नुहोस्।", "डरमा आधारित महँगो पूजा नगर्नुहोस्; अनुभवी पण्डितसँग चार्ट पुष्टि गर्नुहोस्।"]
                             : ["Observe a simple Naga or Shiva practice according to your tradition.", "Avoid fear-based expensive rituals; have an experienced Pandit verify the full chart."]))
        }

        if close(k, .sun, .rahu, orb: 12) || close(k, .sun, .ketu, orb: 12) {
            findings.append(DoshaFinding(
                id: "pitra", title: ne ? "पितृ दोषको संकेत" : "Pitra Dosha indicator",
                severity: .moderate,
                effect: ne ? "वंश, अधिकार, बुबा वा अपूरो पारिवारिक जिम्मेवारीका विषय संवेदनशील हुन सक्छन्।"
                           : "Ancestry, authority, father figures, or unfinished family duties may feel sensitive.",
                evidence: ne ? "सूर्य चन्द्रनोडसँग नजिक छ; यो संकेत हो, अन्तिम निदान होइन।"
                             : "Surya is close to a lunar node; this is an indicator, not a final diagnosis.",
                remedies: ne ? ["अमावस्यामा पूर्वजको सम्झना, दान वा तर्पण आफ्नो परम्पराअनुसार गर्नुहोस्।", "जीवित ज्येष्ठजनप्रतिको जिम्मेवारी व्यवहारमा पूरा गर्नुहोस्।"]
                             : ["Honor ancestors with remembrance, daan, or tarpan according to your tradition.", "Fulfil practical responsibilities toward living elders."]))
        }

        let transitSaturn = Ephemeris.rashi(of: Ephemeris.sidereal(.saturn, jd: Ephemeris.julianDay(date)))
        if let phase = Interpreter.sadheSatiPhase(natal: k.moonRashi, transitSaturn: transitSaturn) {
            findings.append(DoshaFinding(
                id: "sadhe-sati", title: ne ? "शनि साढेसाती" : "Shani Sade Sati",
                severity: phase == 2 ? .strong : .moderate,
                effect: ne ? "जिम्मेवारी, ढिलाइ, सीमाना र भावनात्मक परिपक्वताको चरण।"
                           : "A phase emphasizing responsibility, delays, boundaries, and emotional maturity.",
                evidence: ne ? "हाल चरण \(L10n.digits(phase, .ne)) चलिरहेको छ।" : "The current transit is phase \(phase).",
                remedies: ne ? ["शनिबार श्रम, सेवा वा आवश्यक व्यक्तिलाई दान गर्नुहोस्।", "ढिलाइलाई भय होइन, संरचना र अनुशासनले सम्हाल्नुहोस्।"]
                             : ["Offer service, labor, or useful charity on Saturday.", "Meet delays with structure and discipline rather than fear."]))
        } else {
            let distance = (transitSaturn.rawValue - k.moonRashi.rawValue + 12) % 12 + 1
            if [4, 8].contains(distance) {
                findings.append(DoshaFinding(
                    id: "dhaiya", title: ne ? "शनि ढैया" : "Shani Dhaiya",
                    severity: .moderate,
                    effect: ne ? "घर, मन वा आकस्मिक जिम्मेवारीमा धैर्य र संरचना चाहिन सक्छ।"
                               : "Home, emotional balance, or unexpected responsibilities may need patience and structure.",
                    evidence: ne ? "गोचर शनि चन्द्र राशिबाट \(L10n.digits(distance, .ne)) औं स्थानमा छ।"
                                 : "Transit Saturn is \(distance) signs from the natal Moon.",
                    remedies: ne ? ["शनिबार सरल दान र नियमित सेवा गर्नुहोस्।"] : ["Keep a simple Saturday charity or service practice."]))
            }
        }

        if close(k, .jupiter, .rahu, orb: 12) || close(k, .jupiter, .ketu, orb: 12) {
            findings.append(DoshaFinding(
                id: "guru-chandal", title: ne ? "गुरु चाण्डाल योग संकेत" : "Guru Chandal Yoga indicator",
                severity: .moderate,
                effect: ne ? "विश्वास, गुरु, शिक्षा वा नैतिक निर्णयमा असामान्य प्रश्न र भ्रम दुवै आउन सक्छ।"
                           : "Belief, teachers, education, or ethical judgment may bring both unconventional insight and confusion.",
                evidence: ne ? "बृहस्पति चन्द्रनोडसँग \(L10n.digits(12, .ne))° भित्र छ।"
                             : "Brihaspati is within a 12° orb of a lunar node.",
                remedies: ne ? ["गुरु वा शिक्षक छान्दा आचरण र प्रमाण जाँच्नुहोस्।", "बिहीबार शिक्षा, पुस्तक वा भोजन दान गर्नुहोस्।"]
                             : ["Judge teachers by conduct and evidence.", "Donate education, books, or food on Thursday."]))
        }
        return findings.sorted { $0.severity > $1.severity }
    }

    private static func close(_ k: Kundali, _ a: Planet, _ b: Planet, orb: Double) -> Bool {
        guard let x = k.longitudes[a.rawValue], let y = k.longitudes[b.rawValue] else { return false }
        let d = abs(x - y).truncatingRemainder(dividingBy: 360)
        return min(d, 360 - d) <= orb
    }

    private static func allClassicalPlanetsWithinOneNodeArc(_ k: Kundali) -> Bool {
        guard let rahu = k.longitudes[Planet.rahu.rawValue],
              let ketu = k.longitudes[Planet.ketu.rawValue] else { return false }
        let classical: [Planet] = [.sun, .moon, .mars, .mercury, .jupiter, .venus, .saturn]
        let values = classical.compactMap { k.longitudes[$0.rawValue] }
        guard values.count == classical.count else { return false }
        return values.allSatisfy { inClockwiseArc($0, from: rahu, to: ketu) }
            || values.allSatisfy { inClockwiseArc($0, from: ketu, to: rahu) }
    }

    private static func inClockwiseArc(_ value: Double, from start: Double, to end: Double) -> Bool {
        let span = Ephemeris.norm360(end - start)
        let offset = Ephemeris.norm360(value - start)
        return offset <= span
    }
}

struct PersonalRemedy: Equatable, Identifiable {
    var id: String
    var category: String
    var suggestion: String
    var caution: String?
}

enum RemedyEngine {
    static func suggestions(for member: FamilyMember,
                            language: Language) -> [PersonalRemedy] {
        guard let k = member.kundali else { return [] }
        let ne = language == .ne
        let guna = Interpreter.guna[k.moonRashi.rawValue]
        let color = ne ? guna.colorsNE[0] : guna.colorsEN[0].lowercased()
        return [
            PersonalRemedy(id: "mantra", category: ne ? "मन्त्र" : "Mantra",
                           suggestion: ne ? "शान्त मनले \(guna.mantra) जप गर्नुहोस्।" : "Recite \(guna.mantra) with a calm, steady mind."),
            PersonalRemedy(id: "temple", category: ne ? "मन्दिर" : "Temple",
                           suggestion: ne ? "\(guna.deityNE)को दर्शन वा घरमै सरल प्रार्थना गर्नुहोस्।" : "Visit a \(guna.deityEN) temple or keep a simple home prayer."),
            PersonalRemedy(id: "daan", category: ne ? "दान" : "Daan",
                           suggestion: ne ? "\(guna.dayNE) आवश्यक व्यक्तिलाई भोजन, समय वा उपयोगी सामग्री दिनुहोस्।" : "On \(guna.dayEN), give food, time, or something useful to a person in need."),
            PersonalRemedy(id: "fast", category: ne ? "उपवास" : "Fasting",
                           suggestion: ne ? "स्वास्थ्यले अनुमति दिए हल्का सात्त्विक भोजन वा संयम अपनाउनुहोस्।" : "If your health allows, keep a light sattvic meal or a simple restraint.",
                           caution: ne ? "गर्भावस्था, औषधि वा स्वास्थ्य समस्यामा चिकित्सकको सल्लाह बिना उपवास नगर्नुहोस्।" : "Do not fast without medical advice during pregnancy, medication use, or illness."),
            PersonalRemedy(id: "color", category: ne ? "रंग र भोजन" : "Color & food",
                           suggestion: ne ? "\(color) रंग र सरल ताजा भोजनलाई प्रतीकात्मक सम्झनाको रूपमा प्रयोग गर्नुहोस्।" : "Use \(color) and simple fresh food as a symbolic reminder, not a cure."),
            PersonalRemedy(id: "gem", category: ne ? "रत्न" : "Gemstone",
                           suggestion: ne ? "रत्न लगाउनुअघि पूरा चार्ट, बजेट र धातु अनुभवी पण्डितसँग जाँच्नुहोस्।" : "Before wearing a gemstone, have the full chart, metal, and budget reviewed by an experienced Pandit.",
                           caution: ne ? "एपले महँगो रत्न स्वतः सिफारिस गर्दैन।" : "The app does not automatically prescribe an expensive gemstone."),
            PersonalRemedy(id: "yantra", category: ne ? "यन्त्र" : "Yantra",
                           suggestion: ne ? "यन्त्रलाई श्रद्धा र ध्यानको साधन मान्नुहोस्, निश्चित परिणामको ग्यारेन्टी होइन।" : "Use a yantra as a focus for devotion, never as a guaranteed outcome."),
        ]
    }
}
