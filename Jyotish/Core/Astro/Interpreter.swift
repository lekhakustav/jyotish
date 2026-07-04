import Foundation

/// The pandit's book of meanings: rashi natures, lucky correspondences,
/// transit judgements (chandra bala, sadhe sati), house significations.
enum Interpreter {

    struct RashiGuna {
        let elementEN: String, elementNE: String
        let gemstoneEN: String, gemstoneNE: String
        let colorsEN: [String], colorsNE: [String]
        let numbers: [Int]
        let dayEN: String, dayNE: String
        let deityEN: String, deityNE: String
        let mantra: String
        let natureEN: String, natureNE: String
    }

    static let guna: [RashiGuna] = [
        // Mesh
        .init(elementEN: "Fire", elementNE: "अग्नि", gemstoneEN: "Red Coral", gemstoneNE: "रातो मूगा",
              colorsEN: ["Red", "Saffron"], colorsNE: ["रातो", "केसरी"], numbers: [9, 1],
              dayEN: "Tuesday", dayNE: "मङ्गलबार", deityEN: "Hanuman", deityNE: "हनुमान",
              mantra: "ॐ अं अङ्गारकाय नमः",
              natureEN: "Courageous and pioneering — a natural leader who acts first and inspires others. Guard against haste and a quick temper.",
              natureNE: "साहसी र अग्रगामी — स्वाभाविक नेतृत्व गर्ने। हतार र रिसबाट भने जोगिनुहोस्।"),
        // Vrish
        .init(elementEN: "Earth", elementNE: "पृथ्वी", gemstoneEN: "Diamond / Opal", gemstoneNE: "हीरा / ओपल",
              colorsEN: ["White", "Cream", "Green"], colorsNE: ["सेतो", "क्रीम", "हरियो"], numbers: [6, 2],
              dayEN: "Friday", dayNE: "शुक्रबार", deityEN: "Lakshmi", deityNE: "लक्ष्मी",
              mantra: "ॐ शुं शुक्राय नमः",
              natureEN: "Steady, loyal and fond of beauty and comfort. Builds wealth patiently. Watch for stubbornness.",
              natureNE: "स्थिर, वफादार र सौन्दर्यप्रेमी। धैर्यपूर्वक सम्पत्ति जोड्ने। जिद्दीपनबाट सचेत रहनुहोस्।"),
        // Mithun
        .init(elementEN: "Air", elementNE: "वायु", gemstoneEN: "Emerald", gemstoneNE: "पन्ना",
              colorsEN: ["Green", "Light Yellow"], colorsNE: ["हरियो", "हल्का पहेंलो"], numbers: [5, 3],
              dayEN: "Wednesday", dayNE: "बुधबार", deityEN: "Saraswati", deityNE: "सरस्वती",
              mantra: "ॐ बुं बुधाय नमः",
              natureEN: "Witty, curious and expressive — a gifted communicator. Learn to finish what you start.",
              natureNE: "हाजिरजवाफ, जिज्ञासु र अभिव्यक्तिशील। सुरु गरेको काम पूरा गर्न सिक्नुहोस्।"),
        // Karkat
        .init(elementEN: "Water", elementNE: "जल", gemstoneEN: "Pearl", gemstoneNE: "मोती",
              colorsEN: ["White", "Silver", "Sea Blue"], colorsNE: ["सेतो", "चाँदी", "समुद्री नीलो"], numbers: [2, 7],
              dayEN: "Monday", dayNE: "सोमबार", deityEN: "Shiva", deityNE: "शिव",
              mantra: "ॐ सों सोमाय नमः",
              natureEN: "Tender-hearted and deeply devoted to family — the home is your temple. Protect your sensitive heart.",
              natureNE: "कोमल हृदयको र परिवारप्रति समर्पित — घर नै तपाईंको मन्दिर हो। संवेदनशील मनको ख्याल राख्नुहोस्।"),
        // Simha
        .init(elementEN: "Fire", elementNE: "अग्नि", gemstoneEN: "Ruby", gemstoneNE: "माणिक",
              colorsEN: ["Gold", "Orange", "Copper"], colorsNE: ["सुनौलो", "सुन्तला", "तामा"], numbers: [1, 4],
              dayEN: "Sunday", dayNE: "आइतबार", deityEN: "Surya", deityNE: "सूर्य",
              mantra: "ॐ ह्रां ह्रीं ह्रौं सः सूर्याय नमः",
              natureEN: "Regal, generous and warm like the midday sun. Born to lead — soften pride with humility.",
              natureNE: "राजसी, उदार र घामजस्तै न्यानो। नेतृत्वका लागि जन्मेको — अभिमानलाई विनम्रताले नरम बनाउनुहोस्।"),
        // Kanya
        .init(elementEN: "Earth", elementNE: "पृथ्वी", gemstoneEN: "Emerald", gemstoneNE: "पन्ना",
              colorsEN: ["Green", "White"], colorsNE: ["हरियो", "सेतो"], numbers: [5, 6],
              dayEN: "Wednesday", dayNE: "बुधबार", deityEN: "Ganesh", deityNE: "गणेश",
              mantra: "ॐ गं गणपतये नमः",
              natureEN: "Precise, service-minded and quietly brilliant. Healing hands. Do not let worry cloud your gifts.",
              natureNE: "सूक्ष्म, सेवाभावी र शान्त प्रतिभाशाली। चिन्ताले प्रतिभा नछोपोस्।"),
        // Tula
        .init(elementEN: "Air", elementNE: "वायु", gemstoneEN: "Diamond", gemstoneNE: "हीरा",
              colorsEN: ["White", "Light Blue", "Pink"], colorsNE: ["सेतो", "हल्का नीलो", "गुलाबी"], numbers: [6, 9],
              dayEN: "Friday", dayNE: "शुक्रबार", deityEN: "Lakshmi", deityNE: "लक्ष्मी",
              mantra: "ॐ शुं शुक्राय नमः",
              natureEN: "Graceful peace-maker with a fine eye for harmony and justice. Decide with the heart once the mind has weighed.",
              natureNE: "सन्तुलन र न्यायप्रेमी, शान्ति स्थापना गर्ने। मनले तौलेपछि हृदयले निर्णय गर्नुहोस्।"),
        // Vrischik
        .init(elementEN: "Water", elementNE: "जल", gemstoneEN: "Red Coral", gemstoneNE: "रातो मूगा",
              colorsEN: ["Deep Red", "Maroon"], colorsNE: ["गाढा रातो", "मरून"], numbers: [9, 8],
              dayEN: "Tuesday", dayNE: "मङ्गलबार", deityEN: "Hanuman", deityNE: "हनुमान",
              mantra: "ॐ अं अङ्गारकाय नमः",
              natureEN: "Intense, magnetic and unbreakably determined. Deep intuition. Transform, never merely react.",
              natureNE: "तीव्र, आकर्षक र अटल संकल्पको। गहिरो अन्तर्ज्ञान छ। प्रतिक्रिया होइन, रूपान्तरण गर्नुहोस्।"),
        // Dhanu
        .init(elementEN: "Fire", elementNE: "अग्नि", gemstoneEN: "Yellow Sapphire", gemstoneNE: "पुखराज",
              colorsEN: ["Yellow", "Saffron"], colorsNE: ["पहेंलो", "केसरी"], numbers: [3, 9],
              dayEN: "Thursday", dayNE: "बिहीबार", deityEN: "Vishnu", deityNE: "विष्णु",
              mantra: "ॐ बृं बृहस्पतये नमः",
              natureEN: "Optimistic seeker of truth — a teacher and traveler at heart. Aim the arrow before you release it.",
              natureNE: "आशावादी सत्यखोजी — मनैदेखि शिक्षक र यात्री। वाण छोड्नु अघि निशाना ठीक पार्नुहोस्।"),
        // Makar
        .init(elementEN: "Earth", elementNE: "पृथ्वी", gemstoneEN: "Blue Sapphire", gemstoneNE: "नीलम",
              colorsEN: ["Dark Blue", "Black", "Grey"], colorsNE: ["गाढा नीलो", "कालो", "खैरो"], numbers: [8, 6],
              dayEN: "Saturday", dayNE: "शनिबार", deityEN: "Shani Dev", deityNE: "शनि देव",
              mantra: "ॐ शं शनैश्चराय नमः",
              natureEN: "Disciplined mountain-climber — patient, responsible, built for the long game. Rest is also duty.",
              natureNE: "अनुशासित र धैर्यवान् — लामो यात्राका लागि बनेको। आराम पनि कर्तव्य हो।"),
        // Kumbha
        .init(elementEN: "Air", elementNE: "वायु", gemstoneEN: "Blue Sapphire", gemstoneNE: "नीलम",
              colorsEN: ["Blue", "Violet"], colorsNE: ["नीलो", "बैजनी"], numbers: [8, 4],
              dayEN: "Saturday", dayNE: "शनिबार", deityEN: "Shani Dev", deityNE: "शनि देव",
              mantra: "ॐ शं शनैश्चराय नमः",
              natureEN: "Visionary humanitarian — sees tomorrow before others do. Keep one foot on today's ground.",
              natureNE: "दूरदर्शी र परोपकारी — अरूभन्दा पहिले भोलि देख्ने। एक खुट्टा आजको धरातलमा राख्नुहोस्।"),
        // Meen
        .init(elementEN: "Water", elementNE: "जल", gemstoneEN: "Yellow Sapphire", gemstoneNE: "पुखराज",
              colorsEN: ["Yellow", "Sea Green"], colorsNE: ["पहेंलो", "समुद्री हरियो"], numbers: [3, 7],
              dayEN: "Thursday", dayNE: "बिहीबार", deityEN: "Vishnu", deityNE: "विष्णु",
              mantra: "ॐ बृं बृहस्पतये नमः",
              natureEN: "Compassionate dreamer swimming between two worlds — art and spirit flow through you. Anchor with daily practice.",
              natureNE: "करुणामयी स्वप्नद्रष्टा — कला र अध्यात्म तपाईंभित्र बग्छ। दैनिक साधनाले स्थिर रहनुहोस्।"),
    ]

    /// Chandra bala — transit Moon's house from natal moon rashi (1-based).
    /// Houses 1,3,6,7,10,11 are favorable by tradition.
    static func chandraBala(natal: Rashi, transitMoon: Rashi) -> (house: Int, favorable: Bool) {
        let house = (transitMoon.rawValue - natal.rawValue + 12) % 12 + 1
        return (house, [1, 3, 6, 7, 10, 11].contains(house))
    }

    /// Sadhe Sati — Saturn transiting the 12th, 1st or 2nd from natal moon rashi.
    /// Returns the phase (1,2,3) or nil.
    static func sadheSatiPhase(natal: Rashi, transitSaturn: Rashi) -> Int? {
        let diff = (transitSaturn.rawValue - natal.rawValue + 12) % 12
        switch diff {
        case 11: return 1 // rising
        case 0: return 2  // peak
        case 1: return 3  // setting
        default: return nil
        }
    }

    /// One-line signification of a planet in a whole-sign house (concise sutra).
    static func planetInHouse(_ planet: Planet, house: Int, lang: Language) -> String {
        let housesEN = ["self and vitality", "wealth and speech", "courage and siblings",
                        "home and mother", "children and wisdom", "health and service",
                        "partnership", "longevity and depth", "dharma and fortune",
                        "karma and career", "gains and community", "moksha and rest"]
        let housesNE = ["आत्म र स्वास्थ्य", "धन र वाणी", "साहस र सहोदर", "घर र माता",
                        "सन्तान र विद्या", "रोग र सेवा", "जीवनसाथी", "आयु र गहिराइ",
                        "धर्म र भाग्य", "कर्म र पेशा", "लाभ र मित्र", "मोक्ष र विश्राम"]
        if lang == .ne {
            return "\(planet.nameNE) \(L10n.digits(house + 1, .ne)) औं भावमा — \(housesNE[house]) मा प्रभाव।"
        }
        return "\(planet.nameEN) in house \(house + 1) — shapes \(housesEN[house])."
    }

    /// Warm personality reading for a member, from moon rashi + nakshatra + lagna.
    static func reading(for kundali: Kundali, lang: Language) -> String {
        let g = guna[kundali.moonRashi.rawValue]
        let nak = kundali.moonNakshatra
        if lang == .ne {
            return "\(kundali.moonRashi.nameNE) राशि, \(nak.nameNE) नक्षत्र (पद \(L10n.digits(kundali.moonNakshatraPada, .ne))), \(kundali.lagna.nameNE) लग्न। \(g.natureNE) स्वामी ग्रह \(kundali.moonRashi.lord.nameNE) हुनुहुन्छ; \(g.dayNE) विशेष शुभ रहन्छ।"
        }
        return "Moon in \(kundali.moonRashi.shortEN) rashi, \(nak.nameEN) nakshatra (pada \(kundali.moonNakshatraPada)), with \(kundali.lagna.shortEN) rising. \(g.natureEN) The ruling planet is \(kundali.moonRashi.lord.nameEN), and \(g.dayEN) carries special blessing."
    }
}
