import Foundation

enum Gender: String, Codable, CaseIterable { case male, female, other }

enum Relation: String, Codable, CaseIterable, Identifiable {
    case selfMember, husband, wife, son, daughter, father, mother,
         grandson, granddaughter, grandfather, grandmother, brother, sister
    var id: String { rawValue }
    var labelEN: String {
        switch self {
        case .selfMember: return "Myself"
        case .husband: return "Husband"; case .wife: return "Wife"
        case .son: return "Son"; case .daughter: return "Daughter"
        case .father: return "Father"; case .mother: return "Mother"
        case .grandson: return "Grandson"; case .granddaughter: return "Granddaughter"
        case .grandfather: return "Grandfather"; case .grandmother: return "Grandmother"
        case .brother: return "Brother"; case .sister: return "Sister"
        }
    }
    var labelNE: String {
        switch self {
        case .selfMember: return "म आफैं"
        case .husband: return "श्रीमान्"; case .wife: return "श्रीमती"
        case .son: return "छोरा"; case .daughter: return "छोरी"
        case .father: return "बुबा"; case .mother: return "आमा"
        case .grandson: return "नाति"; case .granddaughter: return "नातिनी"
        case .grandfather: return "हजुरबुबा"; case .grandmother: return "हजुरआमा"
        case .brother: return "दाजुभाइ"; case .sister: return "दिदीबहिनी"
        }
    }
    /// "Your son" / "तपाईंको छोरा"
    func possessive(_ lang: Language) -> String {
        if self == .selfMember { return lang == .ne ? "तपाईं" : "You" }
        return lang == .ne ? "तपाईंको \(labelNE)" : "your \(labelEN.lowercased())"
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

    mutating func recompute() {
        if let birth { kundali = Kundali.compute(from: birth) }
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
}

/// Everything one account owns — mirrors the future Supabase schema 1:1.
struct Household: Codable {
    var schemaVersion: Int = 1
    var account: UserAccount?
    var family: [FamilyMember] = []
    var events: [PatroEvent] = []
    var chat: [ChatMessage] = []
    var language: Language = .en
    var theme: ThemeChoice = .system
}
