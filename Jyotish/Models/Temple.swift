import Foundation

/// A single day's temple spotlight for the home page. When a specific AD date
/// has a hand-curated entry (image + blurb) in `scheduled`, that entry is used;
/// otherwise the day falls back to the older evergreen rotation.
struct Temple: Identifiable {
    let id: String
    let nameEN: String
    let nameNE: String
    let blurbEN: String
    let blurbNE: String
    var imageURL: URL? = nil

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
        Temple(id: "gokarneshwar", nameEN: "Gokarneshwar Mahadev Temple", nameNE: "गोकर्णेश्वर महादेव मन्दिर",
               blurbEN: "A riverside Shiva shrine in Kathmandu associated with ancestor remembrance on the dark moon.",
               blurbNE: "औंसीमा पितृस्मरणसँग जोडिएको काठमाडौंको नदीकिनारको शिव मन्दिर।"),
        Temple(id: "changu_narayan", nameEN: "Changu Narayan Temple", nameNE: "चाँगुनारायण मन्दिर",
               blurbEN: "An ancient hilltop Vishnu temple near Bhaktapur, carrying the promise of a fresh lunar beginning.",
               blurbNE: "भक्तपुर नजिकैको प्राचीन डाँडामाथिको विष्णु मन्दिर, नयाँ चन्द्र पक्षको शुभ सुरुवातसँग जोडिएको।"),
        Temple(id: "guhyeshwari", nameEN: "Guhyeshwari Shakti Peeth", nameNE: "गुह्येश्वरी शक्तिपीठ",
               blurbEN: "A sacred Shakti shrine in a monsoon-green grove near Pashupatinath.",
               blurbNE: "पशुपतिनाथ नजिकै हरियो वनले घेरिएको पवित्र शक्तिपीठ।"),
    ]

    /// Hand-curated batch for BS 2083-03-22 through 2083-03-27 (AD 2026-07-06
    /// through 2026-07-11), keyed by AD date string. Images are hosted in the
    /// `temple-of-day` Supabase bucket (docs/11-TEMPLE-ART-ASSETS.md).
    private static let scheduled: [String: Temple] = [
        "2026-07-06": Temple(id: "pashupatinath", nameEN: "Pashupatinath Temple", nameNE: "पशुपतिनाथ मन्दिर",
            blurbEN: "One of the holiest Shiva shrines in the world, on the banks of the Bagmati — today's Monday, the weekly Shiva day, brings devotees to its ghats.",
            blurbNE: "काठमाडौंको बागमती किनारमा रहेको, संसारकै पवित्र शिव मन्दिरहरूमध्ये एक — आज सोमबार, साप्ताहिक शिवको दिन भएकाले भक्तहरूको घुइँचो लाग्छ।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-06_pashupatinath.png")),
        "2026-07-07": Temple(id: "gorkha_kalika", nameEN: "Gorkha Kalika Temple", nameNE: "गोर्खा कालिका मन्दिर",
            blurbEN: "A hilltop shrine to goddess Kalika above Gorkha Durbar, revered as the Shah kings' family deity and a seat tied to the unification of Nepal.",
            blurbNE: "गोर्खा दरबारमाथि रहेको देवी कालिकाको मन्दिर, शाह वंशका कुलदेवी मानिने र नेपाल एकीकरणसँग गाँसिएको ऐतिहासिक स्थल।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-07_gorkha-kalika.png")),
        "2026-07-08": Temple(id: "dakshinkali", nameEN: "Dakshinkali Temple", nameNE: "दक्षिणकाली मन्दिर",
            blurbEN: "A revered shrine to goddess Kali in a forested gorge south of Kathmandu — Ashtami, a Devi tithi, is one of its busiest days.",
            blurbNE: "काठमाडौं दक्षिणको वनले घेरिएको उपत्यकामा रहेको देवी कालीको मन्दिर — अष्टमी देवी तिथि भएकाले आज विशेष भीड हुन्छ।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-08_dakshinkali.png")),
        "2026-07-09": Temple(id: "taleju", nameEN: "Taleju Bhawani Temple", nameNE: "तलेजु भवानी मन्दिर",
            blurbEN: "The Malla kings' royal Durga shrine inside Kathmandu's old palace complex, opened to the public only a few days a year.",
            blurbNE: "काठमाडौं दरबार क्षेत्रभित्र रहेको मल्लकालीन कुलदेवी तलेजु भवानीको मन्दिर, वर्षको केही दिनमात्र सर्वसाधारणका लागि खुला हुने।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-09_taleju-bhawani.png")),
        "2026-07-10": Temple(id: "budhanilkantha", nameEN: "Budhanilkantha Temple", nameNE: "बूढानीलकण्ठ मन्दिर",
            blurbEN: "A colossal stone Vishnu reclining on a bed of serpent coils in a pond on Kathmandu's northern rim — Ekadashi, the Vishnu vrata day, anchors here.",
            blurbNE: "काठमाडौंको उत्तरी छेउको पोखरीमा नागशय्यामा पल्टिएका विशाल ढुङ्गे विष्णुको मन्दिर — एकादशी, विष्णुको व्रत दिन, यहीं मनाइन्छ।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-10_budhanilkantha.png")),
        "2026-07-11": Temple(id: "budhanilkantha", nameEN: "Budhanilkantha Temple", nameNE: "बूढानीलकण्ठ मन्दिर",
            blurbEN: "The same reclining Narayana shrine keeps today's Yogini Ekadashi vrata, a second Vishnu fast day back-to-back on the calendar.",
            blurbNE: "योगिनी एकादशी व्रतका लागि आज पनि उही शयन नारायण मन्दिरमा भक्तहरूको बत्ति बल्छ।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-11_budhanilkantha-yogini-ekadashi.png")),
        "2026-07-12": Temple(id: "pashupatinath", nameEN: "Pashupatinath Temple", nameNE: "पशुपतिनाथ मन्दिर",
            blurbEN: "Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the Nepal Shiva anchor.",
            blurbNE: "प्रदोष त्रयोदशी वरिपरि मनाइने शिव व्रत हो; पशुपतिनाथ नेपालको शिव आराधनाको मुख्य धाम हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-12_pashupatinath-pradosh.png")),
        "2026-07-13": Temple(id: "pashupatinath", nameEN: "Pashupatinath Temple", nameNE: "पशुपतिनाथ मन्दिर",
            blurbEN: "Monday is the weekly Shiva day, so Pashupatinath anchors this Chaturdashi day.",
            blurbNE: "सोमबार साप्ताहिक शिव आराधनाको दिन भएकाले चतुर्दशीमा पशुपतिनाथ रोजिएको हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-13_pashupatinath-bhanu-jayanti.png")),
        "2026-07-14": Temple(id: "gokarneshwar", nameEN: "Gokarneshwar Mahadev Temple", nameNE: "गोकर्णेश्वर महादेव मन्दिर",
            blurbEN: "Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar.",
            blurbNE: "औंसी पितृस्मरण र शिव आराधनाको अँध्यारो चन्द्र दिन हो; गोकर्णेश्वर यसको धाम हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-14_gokarneshwar-aunsi.png")),
        "2026-07-15": Temple(id: "changu_narayan", nameEN: "Changu Narayan Temple", nameNE: "चाँगुनारायण मन्दिर",
            blurbEN: "Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity.",
            blurbNE: "प्रतिपदाले नयाँ चन्द्र पक्ष खोल्छ; शुभ निरन्तरताका लागि चाँगुनारायण रोजिएको हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-15_changu-narayan-pratipada.png")),
        "2026-07-16": Temple(id: "manakamana", nameEN: "Manakamana Temple", nameNE: "मनकामना मन्दिर",
            blurbEN: "Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish and prayer logic.",
            blurbNE: "द्वितीया शान्त पारिवारिक सङ्कल्पको दिन भएकाले मनकामना यसको उपयुक्त धाम हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-16_manakamana-dwitiya.png")),
        "2026-07-17": Temple(id: "guhyeshwari", nameEN: "Guhyeshwari Shakti Peeth", nameNE: "गुह्येश्वरी शक्तिपीठ",
            blurbEN: "Tritiya leans toward Gauri and Devi vrata logic; Guhyeshwari is the Shakti anchor.",
            blurbNE: "तृतीया गौरी र देवी व्रतसँग जोडिन्छ; गुह्येश्वरी शक्तिको मुख्य धाम हो।",
            imageURL: URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/2083/2026-07-17_guhyeshwari-tritiya.png")),
    ]

    private static let publicManifestURL = URL(string: "https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/manifest.json")

    private static let scheduleFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Kathmandu")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    static func ofToday() -> Temple {
        let key = scheduleFormatter.string(from: Date())
        if let t = scheduled[key] { return t }
        let dayOfYear = Calendar.nepali.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayOfYear % all.count]
    }

    /// Fetches the daily asset published by the server-side maintainer. The
    /// baked-in schedule remains the offline fallback for cold starts and
    /// network failures.
    static func fetchToday() async -> Temple {
        let fallback = ofToday()
        guard let publicManifestURL,
              let (data, _) = try? await URLSession.shared.data(from: publicManifestURL),
              let manifest = try? JSONDecoder().decode(TempleManifest.self, from: data),
              let item = manifest.items.first(where: { $0.adDate == scheduleFormatter.string(from: Date()) }) else {
            return fallback
        }
        let catalog = all.first(where: { $0.id == item.templeId }) ?? fallback
        return Temple(id: item.templeId,
                      nameEN: item.nameEN ?? item.templeName ?? catalog.nameEN,
                      nameNE: item.nameNE ?? catalog.nameNE,
                      blurbEN: item.blurbEN ?? catalog.blurbEN,
                      blurbNE: item.blurbNE ?? catalog.blurbNE,
                      imageURL: item.publicURL ?? catalog.imageURL)
    }
}

private struct TempleManifest: Decodable {
    let items: [TempleManifestItem]
}

private struct TempleManifestItem: Decodable {
    let adDate: String
    let templeId: String
    let templeName: String?
    let nameEN: String?
    let nameNE: String?
    let blurbEN: String?
    let blurbNE: String?
    let publicURL: URL?

    enum CodingKeys: String, CodingKey {
        case adDate
        case templeId
        case templeName
        case nameEN
        case nameNE
        case blurbEN
        case blurbNE
        case publicURL = "publicUrl"
    }
}
