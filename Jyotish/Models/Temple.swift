import Foundation

/// A small rotating set of well-known Nepali temples for the home page's daily
/// spotlight. Deterministic per day (day-of-year modulo count) so the pick
/// stays stable across app launches on the same day.
struct Temple: Identifiable {
    let id: String
    let nameEN: String
    let nameNE: String
    let blurbEN: String
    let blurbNE: String

    static let all: [Temple] = [
        Temple(id: "pashupatinath", nameEN: "Pashupatinath Temple", nameNE: "पशुपतिनाथ मन्दिर",
               blurbEN: "One of the holiest Shiva shrines in the world, on the banks of the Bagmati in Kathmandu.",
               blurbNE: "काठमाडौंको बागमती किनारमा रहेको, संसारकै पवित्र शिव मन्दिरहरूमध्ये एक।"),
        Temple(id: "swayambhunath", nameEN: "Swayambhunath", nameNE: "स्वयम्भूनाथ",
               blurbEN: "The 'Monkey Temple' stupa crowning a Kathmandu hilltop, said to be self-arisen and among the oldest religious sites in the valley.",
               blurbNE: "काठमाडौं उपत्यकाको डाँडामा रहेको स्वयम्भू स्तूप, उपत्यकाकै सबैभन्दा पुरानो धार्मिक स्थलमध्ये एक।"),
        Temple(id: "boudhanath", nameEN: "Boudhanath Stupa", nameNE: "बौद्धनाथ स्तूप",
               blurbEN: "One of the largest spherical stupas in the world, a spiritual heart for Kathmandu's Buddhist community.",
               blurbNE: "संसारकै ठूला गोलाकार स्तूपहरूमध्ये एक, काठमाडौंको बौद्ध समुदायको आध्यात्मिक केन्द्र।"),
        Temple(id: "dakshinkali", nameEN: "Dakshinkali Temple", nameNE: "दक्षिणकाली मन्दिर",
               blurbEN: "A revered shrine to goddess Kali tucked in a forested gorge south of Kathmandu.",
               blurbNE: "काठमाडौं दक्षिणको वनले घेरिएको उपत्यकामा रहेको देवी कालीको प्रसिद्ध मन्दिर।"),
        Temple(id: "muktinath", nameEN: "Muktinath Temple", nameNE: "मुक्तिनाथ मन्दिर",
               blurbEN: "A high-Himalayan shrine sacred to both Hindus and Buddhists, believed to grant moksha to pilgrims.",
               blurbNE: "हिन्दू र बौद्ध दुवैका लागि पवित्र, मोक्षदायी मानिने हिमाली मन्दिर।"),
        Temple(id: "changunarayan", nameEN: "Changu Narayan Temple", nameNE: "चाँगुनारायण मन्दिर",
               blurbEN: "Nepal's oldest surviving Hindu temple, a UNESCO site dedicated to Lord Vishnu near Bhaktapur.",
               blurbNE: "भक्तपुर नजिकै रहेको, भगवान विष्णुलाई समर्पित नेपालकै सबैभन्दा पुरानो मन्दिर।"),
        Temple(id: "manakamana", nameEN: "Manakamana Temple", nameNE: "मनकामना मन्दिर",
               blurbEN: "A hilltop shrine to goddess Bhagwati famed for granting the heartfelt wishes of devotees.",
               blurbNE: "भक्तहरूको इच्छा पूरा गर्ने भनी प्रसिद्ध, डाँडामा रहेको भगवती मन्दिर।"),
        Temple(id: "janakimandir", nameEN: "Janaki Mandir", nameNE: "जानकी मन्दिर",
               blurbEN: "A striking white marble temple in Janakpur marking the birthplace of Goddess Sita.",
               blurbNE: "जनकपुरमा रहेको, देवी सीताको जन्मस्थान चिनाउने सेतो संगमरमरको भव्य मन्दिर।"),
    ]

    static func ofToday() -> Temple {
        let dayOfYear = Calendar.nepali.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayOfYear % all.count]
    }
}
