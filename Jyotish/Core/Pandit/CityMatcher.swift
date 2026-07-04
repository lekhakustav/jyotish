import Foundation

/// Rashi → cities database ("astro-cartography lite"), reasons included.
enum CityMatcher {
    struct Match { let cities: [String]; let citiesNE: [String]; let reasonEN: String; let reasonNE: String }

    static let byRashi: [Match] = [
        // Mesh — fire, leadership, pace
        Match(cities: ["Kathmandu", "Delhi", "New York"], citiesNE: ["काठमाडौं", "दिल्ली", "न्यूयोर्क"],
              reasonEN: "Mars-ruled Mesh thrives where decisions move fast and courage is rewarded — capitals and commercial hubs feed your fire.",
              reasonNE: "मंगलको मेषलाई छिटो निर्णय हुने र साहसको कदर हुने ठाउँ फाप्छ — राजधानी र व्यापारिक केन्द्रले तपाईंको जोश बढाउँछ।"),
        // Vrish — comfort, land, beauty
        Match(cities: ["Pokhara", "Chitwan", "Kyoto"], citiesNE: ["पोखरा", "चितवन", "क्योटो"],
              reasonEN: "Venus-ruled Vrish blossoms amid lakes, gardens and settled comfort — fertile valleys and beautiful, stable towns suit you.",
              reasonNE: "शुक्रको वृषलाई ताल, बगैंचा र स्थिर सुविधा भएको ठाउँ फाप्छ — उर्वर उपत्यका र सुन्दर शहर तपाईंका लागि शुभ।"),
        // Mithun — communication, trade
        Match(cities: ["Lalitpur", "Bangalore", "London"], citiesNE: ["ललितपुर", "बैंगलोर", "लन्डन"],
              reasonEN: "Mercury's Mithun needs conversation, learning and trade — cities of craft, media and markets keep your quick mind fed.",
              reasonNE: "बुधको मिथुनलाई संवाद, सिकाइ र व्यापार चाहिन्छ — कला, सञ्चार र बजारका शहरले तपाईंको तेज दिमागलाई पोषण दिन्छ।"),
        // Karkat — water, home, care
        Match(cities: ["Pokhara", "Janakpur", "Varanasi"], citiesNE: ["पोखरा", "जनकपुर", "वाराणसी"],
              reasonEN: "Moon-ruled Karkat is happiest near water and rooted community — lakeside towns and sacred river cities steady your heart.",
              reasonNE: "चन्द्रमाको कर्कटलाई पानी नजिक र आत्मीय समुदाय भएको ठाउँ फाप्छ — तालछेउका शहर र पवित्र नदी-नगरले मन शान्त राख्छ।"),
        // Simha — status, stage
        Match(cities: ["Kathmandu", "Mumbai", "Dubai"], citiesNE: ["काठमाडौं", "मुम्बई", "दुबई"],
              reasonEN: "Surya's Simha needs a stage worthy of its light — grand cities of ambition and recognition let you shine fully.",
              reasonNE: "सूर्यको सिंहलाई आफ्नो प्रकाश सुहाउने मञ्च चाहिन्छ — महत्वाकांक्षा र सम्मानका ठूला शहरमा तपाईं चम्किनुहुन्छ।"),
        // Kanya — order, service, health
        Match(cities: ["Dharan", "Pune", "Zurich"], citiesNE: ["धरान", "पुणे", "जुरिख"],
              reasonEN: "Mercury's Kanya flourishes in clean, organized, learning-minded places — university towns and well-kept cities match your precision.",
              reasonNE: "बुधको कन्यालाई सफा, व्यवस्थित र शैक्षिक ठाउँ फाप्छ — विश्वविद्यालय भएका र सुव्यवस्थित शहर तपाईंको स्वभाव मिल्छ।"),
        // Tula — balance, art, society
        Match(cities: ["Bhaktapur", "Jaipur", "Paris"], citiesNE: ["भक्तपुर", "जयपुर", "पेरिस"],
              reasonEN: "Venus-ruled Tula belongs where art, architecture and society are refined — heritage cities of beauty balance your scales.",
              reasonNE: "शुक्रको तुलालाई कला, वास्तु र सुसंस्कृत समाज भएको ठाउँ फाप्छ — सुन्दर सम्पदा-शहरले तपाईंको तराजु सन्तुलित राख्छ।"),
        // Vrischik — depth, transformation
        Match(cities: ["Gorkha", "Varanasi", "Istanbul"], citiesNE: ["गोरखा", "वाराणसी", "इस्तानबुल"],
              reasonEN: "Mars-ruled Vrischik seeks depth and history — ancient, intense places of transformation mirror your inner strength.",
              reasonNE: "मंगलको वृश्चिकले गहिराइ र इतिहास खोज्छ — प्राचीन र रूपान्तरणकारी ठाउँले तपाईंको आन्तरिक शक्ति झल्काउँछ।"),
        // Dhanu — dharma, travel, teaching
        Match(cities: ["Lumbini", "Rishikesh", "Singapore"], citiesNE: ["लुम्बिनी", "ऋषिकेश", "सिंगापुर"],
              reasonEN: "Jupiter's Dhanu grows near temples, teachers and open horizons — pilgrimage towns and international crossroads expand you.",
              reasonNE: "बृहस्पतिको धनु मन्दिर, गुरु र खुला क्षितिज नजिक फस्टाउँछ — तीर्थस्थल र अन्तर्राष्ट्रिय सङ्गमले तपाईंलाई फराकिलो बनाउँछ।"),
        // Makar — discipline, mountains, industry
        Match(cities: ["Jumla", "Hetauda", "Tokyo"], citiesNE: ["जुम्ला", "हेटौंडा", "टोकियो"],
              reasonEN: "Shani's Makar respects mountains, industry and earned achievement — high country and hard-working cities honor your climb.",
              reasonNE: "शनिको मकरलाई पहाड, उद्योग र मेहनतको कदर हुने ठाउँ फाप्छ — उच्च भूमि र परिश्रमी शहरले तपाईंको यात्रा सम्मान गर्छ।"),
        // Kumbha — future, community
        Match(cities: ["Butwal", "Bangalore", "Amsterdam"], citiesNE: ["बुटवल", "बैंगलोर", "एम्स्टर्डम"],
              reasonEN: "Shani's Kumbha belongs to forward-looking, communal places — growing tech towns and open-minded cities share your vision.",
              reasonNE: "शनिको कुम्भलाई भविष्यमुखी र सामुदायिक ठाउँ फाप्छ — बढ्दा प्रविधि-शहर र खुला विचारका नगर तपाईंसँग मिल्छन्।"),
        // Meen — water, spirit, art
        Match(cities: ["Janakpur", "Haridwar", "Bali"], citiesNE: ["जनकपुर", "हरिद्वार", "बाली"],
              reasonEN: "Jupiter's Meen dissolves gently into sacred waters and artistic air — temple towns and island calm nourish your soul.",
              reasonNE: "बृहस्पतिको मीन पवित्र जल र कलात्मक वातावरणमा फस्टाउँछ — मन्दिर-नगर र टापुको शान्तिले आत्मालाई पोषण दिन्छ।"),
    ]

    static func answer(rashi: Rashi, lang: Language) -> String {
        let m = byRashi[rashi.rawValue]
        let cities = (lang == .ne ? m.citiesNE : m.cities).joined(separator: ", ")
        return lang == .ne
        ? "\(rashi.nameNE) राशिका लागि शुभ स्थानहरू: \(cities)। \(m.reasonNE)"
        : "Favorable places for \(rashi.shortEN) rashi: \(cities). \(m.reasonEN)"
    }
}
