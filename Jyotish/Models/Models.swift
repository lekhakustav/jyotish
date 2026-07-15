import Foundation

enum Gender: String, Codable, CaseIterable { case male, female, other }

enum Relation: String, Codable, CaseIterable, Identifiable {
    case selfMember, husband, wife, boyfriend, girlfriend, partner, fiance, fiancee,
         friend, colleague, mentor,
         son, daughter, father, mother,
         grandson, granddaughter, grandfather, grandmother, brother, sister,
         // Father's side
         kaka, kaki, thuloBaa, thuloAma, phupu, phupaju,
         // Mother's side
         mama, maiju, saniAma, thuliAma,
         // In-laws
         sasura, sasu, jethaju, devar, jethani, devrani, nanad,
         saala, saali, bhinaju, bhauju, buhari, jwaai,
         // Extended
         bhatija, bhatiji, bhanja, bhanji, cousin
    var id: String { rawValue }
    var labelEN: String {
        switch self {
        case .selfMember: return "Myself"
        case .husband: return "Husband"; case .wife: return "Wife"
        case .boyfriend: return "Boyfriend"; case .girlfriend: return "Girlfriend"
        case .partner: return "Partner"
        case .fiance: return "Fiancé"; case .fiancee: return "Fiancée"
        case .friend: return "Friend"; case .colleague: return "Colleague"
        case .mentor: return "Mentor"
        case .son: return "Son"; case .daughter: return "Daughter"
        case .father: return "Father"; case .mother: return "Mother"
        case .grandson: return "Grandson"; case .granddaughter: return "Granddaughter"
        case .grandfather: return "Grandfather"; case .grandmother: return "Grandmother"
        case .brother: return "Brother"; case .sister: return "Sister"
        case .kaka: return "Kaka (Father's younger brother)"
        case .kaki: return "Kaki (Kaka's wife)"
        case .thuloBaa: return "Thulo Baa (Father's elder brother)"
        case .thuloAma: return "Thulo Aama (Thulo Baa's wife)"
        case .phupu: return "Phupu (Father's sister)"
        case .phupaju: return "Phupaju (Phupu's husband)"
        case .mama: return "Mama (Mother's brother)"
        case .maiju: return "Maiju (Mama's wife)"
        case .saniAma: return "Sani Aama (Mother's younger sister)"
        case .thuliAma: return "Thuli Aama (Mother's elder sister)"
        case .sasura: return "Sasura (Father-in-law)"
        case .sasu: return "Sasu (Mother-in-law)"
        case .jethaju: return "Jethaju (Husband's elder brother)"
        case .devar: return "Devar (Husband's younger brother)"
        case .jethani: return "Jethani (Husband's elder brother's wife)"
        case .devrani: return "Devrani (Husband's younger brother's wife)"
        case .nanad: return "Nanad (Husband's sister)"
        case .saala: return "Saala (Wife's brother)"
        case .saali: return "Saali (Wife's sister)"
        case .bhinaju: return "Bhinaju (Sister's husband)"
        case .bhauju: return "Bhauju (Brother's wife)"
        case .buhari: return "Buhari (Son's wife)"
        case .jwaai: return "Jwaai (Daughter's husband)"
        case .bhatija: return "Bhatija (Brother's son)"
        case .bhatiji: return "Bhatiji (Brother's daughter)"
        case .bhanja: return "Bhanja (Sister's son)"
        case .bhanji: return "Bhanji (Sister's daughter)"
        case .cousin: return "Cousin"
        }
    }
    var labelNE: String {
        switch self {
        case .selfMember: return "म आफैं"
        case .husband: return "श्रीमान्"; case .wife: return "श्रीमती"
        case .boyfriend: return "प्रेमी"; case .girlfriend: return "प्रेमिका"
        case .partner: return "जीवनसाथी"
        case .fiance: return "मंगेतर"; case .fiancee: return "मंगेतर"
        case .friend: return "साथी"; case .colleague: return "सहकर्मी"
        case .mentor: return "मार्गदर्शक"
        case .son: return "छोरा"; case .daughter: return "छोरी"
        case .father: return "बुबा"; case .mother: return "आमा"
        case .grandson: return "नाति"; case .granddaughter: return "नातिनी"
        case .grandfather: return "हजुरबुबा"; case .grandmother: return "हजुरआमा"
        case .brother: return "दाजुभाइ"; case .sister: return "दिदीबहिनी"
        case .kaka: return "काका"
        case .kaki: return "काकी"
        case .thuloBaa: return "ठूलो बुबा"
        case .thuloAma: return "ठूलो आमा"
        case .phupu: return "फुपू"
        case .phupaju: return "फुपाजू"
        case .mama: return "मामा"
        case .maiju: return "माइजू"
        case .saniAma: return "सानी आमा"
        case .thuliAma: return "ठूली आमा"
        case .sasura: return "ससुरा"
        case .sasu: return "सासू"
        case .jethaju: return "जेठाजू"
        case .devar: return "देवर"
        case .jethani: return "जेठानी"
        case .devrani: return "देवरानी"
        case .nanad: return "ननद"
        case .saala: return "साला"
        case .saali: return "साली"
        case .bhinaju: return "भिनाजू"
        case .bhauju: return "भाउजू"
        case .buhari: return "बुहारी"
        case .jwaai: return "ज्वाइँ"
        case .bhatija: return "भतिजा"
        case .bhatiji: return "भतिजी"
        case .bhanja: return "भाञ्जा"
        case .bhanji: return "भाञ्जी"
        case .cousin: return "चचेरे भाइबहिनी"
        }
    }
    /// "Your son" / "तपाईंको छोरा"
    func possessive(_ lang: Language) -> String {
        if self == .selfMember { return lang == .ne ? "तपाईं" : "You" }
        return lang == .ne ? "तपाईंको \(labelNE)" : "your \(labelEN.lowercased())"
    }

    var isRomantic: Bool {
        [.husband, .wife, .boyfriend, .girlfriend, .partner, .fiance, .fiancee].contains(self)
    }

    var isSocialPeer: Bool {
        [.friend, .colleague, .mentor, .boyfriend, .girlfriend, .partner, .fiance, .fiancee].contains(self)
    }
}

struct FamilyMember: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var gender: Gender
    var relation: Relation
    var birth: BirthData?
    var kundali: Kundali?

    var hasBirthData: Bool { birth != nil && kundali != nil }

    /// Keeps the saved identity untouched while ensuring Nepali surfaces do not
    /// mix Latin-script names into Devanagari sentences.
    func displayName(_ language: Language) -> String {
        language == .ne ? NepaliNameTransliterator.transliterate(name) : name
    }

    mutating func recompute() {
        if let birth { kundali = Kundali.compute(from: birth) }
    }
}

enum NepaliNameTransliterator {
    private static let known: [String: String] = [
        "aarav": "आरव", "priya": "प्रिया", "sita": "सीता", "sharma": "शर्मा",
        "maya": "माया", "ram": "राम", "rama": "रमा",
        "gita": "गीता", "geeta": "गीता", "krishna": "कृष्ण", "hari": "हरि",
        "laxmi": "लक्ष्मी", "lakshmi": "लक्ष्मी", "sarita": "सरिता",
        "sunita": "सुनिता", "anita": "अनिता", "rita": "रीता", "nita": "नीता",
        "roshan": "रोशन", "suman": "सुमन", "bikash": "विकास", "vikas": "विकास",
        "dipak": "दीपक", "deepak": "दीपक", "rajesh": "राजेश", "ramesh": "रमेश",
        "suresh": "सुरेश", "mahesh": "महेश", "ganesh": "गणेश", "dinesh": "दिनेश",
        "anil": "अनिल", "sunil": "सुनील", "manish": "मनीष", "nisha": "निशा",
        "asha": "आशा", "usha": "उषा", "pooja": "पूजा", "puja": "पूजा",
        "anjali": "अञ्जली", "sanjay": "सञ्जय", "bijay": "विजय", "vijay": "विजय"
    ]

    static func transliterate(_ value: String) -> String {
        guard value.range(of: "[A-Za-z]", options: .regularExpression) != nil else { return value }
        return value.split(separator: " ", omittingEmptySubsequences: false).map { part in
            let word = String(part)
            let stripped = word.trimmingCharacters(in: .punctuationCharacters)
            let punctuationPrefix = String(word.prefix { $0.isPunctuation })
            let punctuationSuffix = String(word.reversed().prefix { $0.isPunctuation }.reversed())
            let key = stripped.lowercased()
            if let exact = known[key] { return punctuationPrefix + exact + punctuationSuffix }

            var phonetic = key
            let replacements = [("aa", "ā"), ("ee", "ī"), ("ii", "ī"),
                                ("oo", "ū"), ("uu", "ū"), ("sh", "ś")]
            for (source, target) in replacements {
                phonetic = phonetic.replacingOccurrences(of: source, with: target)
            }
            var transformed = phonetic.applyingTransform(
                StringTransform(rawValue: "Latin-Devanagari"), reverse: false
            ) ?? stripped
            while transformed.last == "्" { transformed.removeLast() }
            return punctuationPrefix + transformed + punctuationSuffix
        }.joined(separator: " ")
    }
}

/// The account holder. Their chart lives in the `selfMember` family entry.
struct UserAccount: Codable, Equatable {
    var id: UUID = UUID()
    var email: String?
    var displayName: String
    var isDemo: Bool = true
}

struct PatroEvent: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var bsDate: NepaliDate
    var repeatsYearly: Bool = false

    func occurs(on date: NepaliDate) -> Bool {
        if repeatsYearly { return bsDate.month == date.month && bsDate.day == date.day }
        return bsDate == date
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var isUser: Bool
    var text: String
    var timestamp: Date = Date()
    /// Optional keeps existing local/Supabase household JSON backwards
    /// compatible while new replies can expose confirmed, typed actions.
    var actions: [PanditAction]?
}

/// A restorable Jyotish Baje thread. Conversations are kept inside the household
/// aggregate, so the same shelf works offline and follows the user through the
/// existing Supabase sync path.
struct ChatConversation: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var messages: [ChatMessage] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var sourceKey: String?

    mutating func append(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = message.timestamp
    }
}

struct EngagementPreferences: Codable, Equatable {
    var enabled = false
    var wakeHour = 7
    var dailyCount = 4
    var familyInsights = true
    var calendarReminders = true
}

enum PanditActionKind: String, Codable, Equatable {
    case openPatro, addToPatro, remind, compare, listen, seeKundli, share
}

struct PanditAction: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var kind: PanditActionKind
    var date: Date?
    var title: String?
    var memberID: UUID?
}

/// Everything one account owns; synced as one user-owned Supabase household row.
struct Household: Codable {
    var schemaVersion: Int = 2
    var account: UserAccount?
    var family: [FamilyMember] = []
    var events: [PatroEvent] = []
    var chat: [ChatMessage] = []
    /// Optional for backwards-compatible decoding of schema-v1 payloads.
    var conversations: [ChatConversation]?
    /// Optional keeps schema-v1/v2 Supabase payloads decodable.
    var engagementPreferences: EngagementPreferences?
    var language: Language = .en
    var theme: ThemeChoice = .system
}
