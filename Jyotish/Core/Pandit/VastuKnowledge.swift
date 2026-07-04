import Foundation

/// Ghar-vastu knowledge base: rooms, directions, colors, remedies.
enum VastuKnowledge {
    struct Entry { let keywords: [String]; let en: String; let ne: String }

    static let entries: [Entry] = [
        Entry(keywords: ["main door", "entrance", "मूल ढोका", "ढोका", "door"],
              en: "The main door is the mouth of the house — best facing north or east so morning light enters first. Keep it clean and well-lit, mark it with a Swastik or Om, and hang a small toran of mango leaves or marigold. Avoid a mirror directly opposite the entrance, and never store shoes blocking the doorway.",
              ne: "मूल ढोका घरको मुख हो — उत्तर वा पूर्व फर्केको उत्तम मानिन्छ, जसले बिहानको घाम भित्र ल्याउँछ। सफा र उज्यालो राख्नुहोस्, स्वस्तिक वा ॐ अंकित गर्नुहोस्, र आँप वा सयपत्रीको तोरण झुण्ड्याउनुहोस्। ढोकाको ठीक अगाडि ऐना नराख्नुहोस्।"),
        Entry(keywords: ["kitchen", "भान्सा", "भान्छा", "cooking"],
              en: "The kitchen belongs to Agni — the southeast corner is ideal, cooking while facing east. Keep water (tap, filter) in the northeast of the kitchen, away from the stove, since fire and water quarrel. Warm colors — saffron, light red, cream — bless this room.",
              ne: "भान्सा अग्निको स्थान हो — दक्षिण-पूर्व कुना उत्तम, पकाउँदा पूर्व फर्केर पकाउनुहोस्। पानी (धारा, फिल्टर) चुलोबाट टाढा उत्तर-पूर्वमा राख्नुहोस्; अग्नि र जल मिल्दैनन्। केसरी, हल्का रातो, क्रीम रंग यस कोठाका लागि शुभ।"),
        Entry(keywords: ["bedroom", "सुत्ने कोठा", "शयनकक्ष", "sleep", "bed"],
              en: "For the master bedroom, southwest brings stability; sleep with the head toward south or east — never north, which disturbs rest. Choose calm earthen tones. A child's bedroom does well in the west; a growing student benefits from studying facing east or north.",
              ne: "मुख्य शयनकक्ष दक्षिण-पश्चिममा भए स्थिरता आउँछ; टाउको दक्षिण वा पूर्वतिर राखेर सुत्नुहोस् — उत्तरतिर कहिल्यै नराख्नुहोस्। शान्त माटो रंग रोज्नुहोस्। बालबालिकाको कोठा पश्चिममा राम्रो; पढ्दा पूर्व वा उत्तर फर्केर पढ्दा लाभ हुन्छ।"),
        Entry(keywords: ["puja", "pooja", "mandir", "पूजा", "मन्दिर", "prayer", "shrine"],
              en: "The puja room is the heart of the home — northeast (Ishan kona) is its sacred seat. Face east while praying, keep the space above ground level, and never place it under a staircase or beside a bathroom. White, light yellow and gold suit this space.",
              ne: "पूजा कोठा घरको मुटु हो — ईशान कुना (उत्तर-पूर्व) यसको पवित्र स्थान हो। पूजा गर्दा पूर्व फर्कनुहोस्, भर्याङमुनि वा बाथरूमछेउ कहिल्यै नराख्नुहोस्। सेतो, हल्का पहेंलो र सुनौलो रंग शुभ।"),
        Entry(keywords: ["living", "बैठक", "drawing", "guest"],
              en: "The living room welcomes the world — north or east placement invites prosperity. Seat the family head facing east or north. Keep the center of the house (Brahmasthan) open and uncluttered; light colors and fresh flowers keep the energy sweet.",
              ne: "बैठक कोठाले संसारलाई स्वागत गर्छ — उत्तर वा पूर्वमा भए समृद्धि आउँछ। घरमूलीलाई पूर्व वा उत्तर फर्केर बस्ने ठाउँ दिनुहोस्। घरको बीच भाग (ब्रह्मस्थान) खुला राख्नुहोस्; हल्का रंग र ताजा फूलले ऊर्जा मिठो राख्छ।"),
        Entry(keywords: ["bathroom", "toilet", "शौचालय", "बाथरूम"],
              en: "Bathrooms sit best in the northwest or west. Keep the door closed, fix leaking taps quickly (dripping water drains wealth), and add a small bowl of rock salt to absorb heaviness.",
              ne: "बाथरूम उत्तर-पश्चिम वा पश्चिममा उत्तम। ढोका बन्द राख्नुहोस्, चुहिने धारा तुरुन्त बनाउनुहोस् (चुहिने पानीले धन बगाउँछ), र ढुङ्गे नुनको सानो कचौरा राख्नुहोस्।"),
        Entry(keywords: ["study", "पढ्ने", "office", "काम गर्ने", "desk", "work"],
              en: "A study or home office thrives in the west or southwest with the desk facing east or north — the directions of Saraswati and growth. Keep books in the southwest, a green plant on the desk, and the wall ahead light green or cream.",
              ne: "पढ्ने कोठा वा गृह-कार्यालय पश्चिम वा दक्षिण-पश्चिममा राम्रो; टेबल पूर्व वा उत्तर फर्काउनुहोस् — सरस्वती र प्रगतिको दिशा। किताब दक्षिण-पश्चिममा राख्नुहोस्, टेबलमा हरियो बिरुवा राख्नुहोस्।"),
        Entry(keywords: ["water", "tank", "well", "पानी", "ट्यांकी", "boring"],
              en: "Underground water — wells, borings — belongs to the northeast; overhead tanks to the southwest. Never place a water source in the southeast (Agni's corner).",
              ne: "जमिनमुनिको पानी — इनार, बोरिङ — उत्तर-पूर्वमा; माथिल्लो ट्यांकी दक्षिण-पश्चिममा। दक्षिण-पूर्व (अग्नि कुना)मा पानीको स्रोत कहिल्यै नराख्नुहोस्।"),
        Entry(keywords: ["stairs", "staircase", "भर्याङ"],
              en: "Staircases climb best in the south, southwest or west, turning clockwise as they rise. Avoid a staircase in the northeast — it presses on the most sacred corner.",
              ne: "भर्याङ दक्षिण, दक्षिण-पश्चिम वा पश्चिममा उत्तम, घडीको दिशामा घुम्दै उक्लिने। उत्तर-पूर्वमा भर्याङ नराख्नुहोस् — त्यो सबैभन्दा पवित्र कुना हो।"),
        Entry(keywords: ["plant", "tree", "tulsi", "तुलसी", "garden", "बगैंचा"],
              en: "A Tulsi plant in the northeast or east courtyard purifies the whole home — water it each morning. Heavy trees belong to the southwest; avoid thorny plants near the entrance (except protective cactus on a boundary).",
              ne: "उत्तर-पूर्व वा पूर्व आँगनमा तुलसीको मोठले पूरै घर शुद्ध राख्छ — बिहान जल चढाउनुहोस्। ठूला रूख दक्षिण-पश्चिममा; ढोका नजिक काँडेदार बिरुवा नराख्नुहोस्।"),
    ]

    static func answer(for query: String, lang: Language) -> String? {
        let q = query.lowercased()
        guard let hit = entries.first(where: { $0.keywords.contains { q.contains($0.lowercased()) } }) else { return nil }
        return lang == .ne ? hit.ne : hit.en
    }

    static func overview(lang: Language) -> String {
        lang == .ne
        ? "वास्तुमा घरका आठ दिशा र ब्रह्मस्थानको सन्तुलन हेरिन्छ — मलाई मूल ढोका, भान्सा, शयनकक्ष, पूजा कोठा, बैठक, बाथरूम, पढ्ने कोठा, पानी, भर्याङ वा तुलसीबारे सोध्नुहोस्।"
        : "Vastu balances the eight directions and the sacred center of the home — ask me about the main door, kitchen, bedroom, puja room, living room, bathroom, study, water placement, staircase, or Tulsi."
    }
}
