import Foundation

enum Language: String, Codable, CaseIterable {
    case en, ne
    var displayName: String { self == .en ? "English" : "नेपाली" }
}

enum L10n {
    /// key → (english, nepali)
    static let table: [String: (en: String, ne: String)] = [
        // Greetings / general
        "greet.morning": ("Shubha Prabhat", "शुभ प्रभात"),
        "greet.afternoon": ("Namaste", "नमस्ते"),
        "greet.evening": ("Shubha Sandhya", "शुभ सन्ध्या"),
        "greet.night": ("Shubha Ratri", "शुभ रात्री"),
        "app.name": ("Jyotish", "ज्योतिष"),
        "app.tagline": ("Your family's pandit, in your pocket", "तपाईंको परिवारको पण्डित, तपाईंकै हातमा"),
        "common.save": ("Save", "सुरक्षित गर्नुहोस्"),
        "common.cancel": ("Cancel", "रद्द गर्नुहोस्"),
        "common.done": ("Done", "भयो"),
        "common.today": ("Today", "आज"),
        "common.add": ("Add", "थप्नुहोस्"),
        "common.delete": ("Delete", "हटाउनुहोस्"),
        "common.you": ("You", "तपाईं"),
        "common.readMore": ("Read more", "थप पढ्नुहोस्"),
        "blessing.saved": ("Shubha hos", "शुभ होस्"),
        // Tabs
        "tab.home": ("Home", "गृह"),
        "tab.rashifal": ("Rashifal", "राशिफल"),
        "tab.patro": ("Patro", "पात्रो"),
        "tab.family": ("Parivar", "परिवार"),
        "tab.pandit": ("Pandit", "पण्डित"),
        // Welcome / onboarding
        "welcome.continue": ("Continue with account (demo)", "खाता सहित अगाडि बढ्नुहोस् (डेमो)"),
        "profile.title": ("Birth Details", "जन्म विवरण"),
        "profile.subtitle": ("Pandit-ji needs these to draw the kundali",
                             "कुण्डली बनाउन पण्डितजीलाई यी विवरण चाहिन्छ"),
        "profile.name": ("Full name", "पूरा नाम"),
        "profile.gender": ("Gender", "लिङ्ग"),
        "profile.male": ("Male", "पुरुष"),
        "profile.female": ("Female", "महिला"),
        "profile.other": ("Other", "अन्य"),
        "profile.dob": ("Date of birth", "जन्म मिति"),
        "profile.tob": ("Time of birth", "जन्म समय"),
        "profile.timeUnknown": ("Time unknown (uses 6:00 AM)", "समय थाहा छैन (बिहान ६:०० प्रयोग हुन्छ)"),
        "profile.place": ("Place of birth", "जन्म स्थान"),
        "profile.compute": ("Create my kundali", "मेरो कुण्डली बनाउनुहोस्"),
        "profile.gate.title": ("Birth details needed", "जन्म विवरण आवश्यक छ"),
        "profile.gate.body": ("Please complete the birth profile first, so Pandit-ji can compute the kundali.",
                              "कृपया पहिले जन्म विवरण भर्नुहोस्, अनि पण्डितजीले कुण्डली बनाउन सक्नुहुन्छ।"),
        // Paged birth flow
        "flow.continue": ("Continue", "अगाडि बढ्नुहोस्"),
        "flow.relation.q": ("Who are you adding?", "कसलाई थप्दै हुनुहुन्छ?"),
        "flow.name.q": ("What is your name?", "तपाईंको नाम के हो?"),
        "flow.name.q.family": ("What is their name?", "उहाँको नाम के हो?"),
        "flow.gender.q": ("Gender", "लिङ्ग"),
        "flow.dob.q": ("Date of birth", "जन्म मिति"),
        "flow.dob.sub": ("The day the stars were arranged", "ताराहरू मिलेको त्यो दिन"),
        "flow.tob.q": ("Time of birth", "जन्म समय"),
        "flow.tob.sub": ("Even an approximate time helps the lagna", "अन्दाजी समयले पनि लग्न निकाल्न मद्दत गर्छ"),
        "flow.place.q": ("Place of birth", "जन्म स्थान"),
        "flow.drawing": ("Drawing the kundali…", "कुण्डली बनाउँदै…"),
        // Home
        "home.upcoming": ("Upcoming", "आगामी"),
        "home.noEvents": ("No events yet — add one in Patro", "अहिलेसम्म कुनै कार्यक्रम छैन — पात्रोमा थप्नुहोस्"),
        "home.mahadasha": ("Mahadasha", "महादशा"),
        "home.antardasha": ("Antardasha", "अन्तर्दशा"),
        "home.openPatro": ("Open Patro", "पात्रो खोल्नुहोस्"),
        "home.askPandit": ("Ask Pandit-ji", "पण्डितजीलाई सोध्नुहोस्"),
        // Rashifal
        "rashifal.title": ("Rashifal", "राशिफल"),
        "rashifal.daily": ("Daily", "दैनिक"),
        "rashifal.weekly": ("Weekly", "साप्ताहिक"),
        "rashifal.monthly": ("Monthly", "मासिक"),
        "rashifal.yearly": ("Yearly", "वार्षिक"),
        "rashifal.lucky.color": ("Lucky color", "शुभ रंग"),
        "rashifal.lucky.number": ("Lucky number", "शुभ अंक"),
        "rashifal.lucky.day": ("Lucky day", "शुभ वार"),
        "rashifal.upaya": ("Upaya", "उपाय"),
        "rashifal.career": ("Career", "पेशा"),
        "rashifal.family": ("Family", "परिवार"),
        "rashifal.health": ("Health", "स्वास्थ्य"),
        "rashifal.wealth": ("Wealth", "धन"),
        "rashifal.love": ("Love", "प्रेम"),
        // Patro
        "patro.title": ("Nepali Patro", "नेपाली पात्रो"),
        "patro.jumpToDate": ("Go to date", "मिति छान्नुहोस्"),
        "patro.month": ("Month", "महिना"),
        "patro.year": ("Year", "वर्ष"),
        "patro.day": ("Day", "गते"),
        "patro.addEvent": ("Add event", "कार्यक्रम थप्नुहोस्"),
        "patro.eventTitle": ("Event title", "कार्यक्रमको नाम"),
        "patro.eventNote": ("Note (optional)", "टिप्पणी (वैकल्पिक)"),
        "patro.repeatYearly": ("Repeat every year (birthdays)", "हरेक वर्ष दोहोर्याउनुहोस् (जन्मदिन)"),
        "patro.events": ("Events", "कार्यक्रमहरू"),
        "patro.panchanga": ("Panchanga", "पञ्चाङ्ग"),
        "patro.tithi": ("Tithi", "तिथि"),
        "patro.nakshatra": ("Nakshatra", "नक्षत्र"),
        "patro.yoga": ("Yoga", "योग"),
        "patro.karana": ("Karana", "करण"),
        // Family
        "family.title": ("Parivar", "परिवार"),
        "family.add": ("Add family member", "परिवार सदस्य थप्नुहोस्"),
        "family.relation": ("Relation", "नाता"),
        "family.kundali": ("Kundali", "कुण्डली"),
        "family.lagna": ("Lagna", "लग्न"),
        "family.rashi": ("Rashi", "राशि"),
        "family.nakshatra": ("Nakshatra", "नक्षत्र"),
        "family.dashaTimeline": ("Mahadasha timeline", "महादशा समयरेखा"),
        "family.personality": ("Reading", "फलादेश"),
        "family.guna": ("Guna & Lucky things", "गुण र शुभ वस्तुहरू"),
        "family.gemstone": ("Gemstone", "रत्न"),
        "family.deity": ("Deity", "इष्टदेव"),
        "family.mantra": ("Mantra", "मन्त्र"),
        "family.element": ("Element", "तत्व"),
        "family.lord": ("Ruling planet", "स्वामी ग्रह"),
        // Chat
        "chat.title": ("Pandit-ji", "पण्डितजी"),
        "chat.placeholder": ("Ask Pandit-ji…", "पण्डितजीलाई सोध्नुहोस्…"),
        "chat.chip.color": ("Which color suits my room?", "मेरो कोठाका लागि कुन रंग शुभ?"),
        "chat.chip.city": ("Which city is best for me?", "मेरा लागि कुन शहर राम्रो?"),
        "chat.chip.vastu": ("Vastu for the main door", "मूल ढोकाको वास्तु"),
        "chat.chip.dasha": ("How is my dasha now?", "मेरो दशा अहिले कस्तो छ?"),
        "chat.listening": ("Listening…", "सुन्दै…"),
        "chat.speak": ("Speak replies", "उत्तर बोल्ने"),
        "chat.history": ("History", "इतिहास"),
        "chat.noHistory": ("No questions yet", "अहिलेसम्म प्रश्न छैन"),
        // Settings
        "settings.title": ("Settings", "सेटिङ"),
        "settings.language": ("Language", "भाषा"),
        "settings.theme": ("Appearance", "रूप"),
        "settings.theme.system": ("System", "प्रणाली"),
        "settings.theme.light": ("Prabhat (Light)", "प्रभात (उज्यालो)"),
        "settings.theme.dark": ("Ratri (Dark)", "रात्री (अँध्यारो)"),
        "settings.editProfile": ("Edit birth profile", "जन्म विवरण सम्पादन"),
        "settings.signOut": ("Sign out", "साइन आउट"),
    ]

    static func t(_ key: String, _ lang: Language) -> String {
        guard let pair = table[key] else { return key }
        return lang == .ne ? pair.ne : pair.en
    }

    private static let neDigits = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"]
    /// 2083 → "२०८३" when Nepali.
    static func digits(_ n: Int, _ lang: Language) -> String {
        guard lang == .ne else { return String(n) }
        return String(n).map { ch -> String in
            if let d = ch.wholeNumberValue { return neDigits[d] }
            return String(ch)
        }.joined()
    }

    static let weekdaysEN = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let weekdaysNE = ["आइत", "सोम", "मङ्गल", "बुध", "बिही", "शुक्र", "शनि"]
    static let weekdaysFullEN = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let weekdaysFullNE = ["आइतबार", "सोमबार", "मङ्गलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"]
}
