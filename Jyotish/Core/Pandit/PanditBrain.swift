import Foundation

/// Pandit-ji: rule-based bilingual chatbot with access to every engine —
/// kundali, dasha, gochar, rashifal, vastu, cities, colors. docs/04 §6.
struct PanditBrain {
    let family: [FamilyMember]
    let lang: Language

    // ── Member resolution: "my son", "छोरा", a member's name… ───────────────
    private func resolveMember(in query: String) -> FamilyMember? {
        let q = query.lowercased()
        // by name first
        if let byName = family.first(where: { !$0.name.isEmpty && q.contains($0.name.lowercased()) }) {
            return byName
        }
        let relationWords: [(Relation, [String])] = [
            (.son, ["son", "छोरा"]), (.daughter, ["daughter", "छोरी"]),
            (.husband, ["husband", "श्रीमान्", "लोग्ने"]), (.wife, ["wife", "श्रीमती", "स्वास्नी"]),
            (.father, ["father", "dad", "बुबा", "बा"]), (.mother, ["mother", "mom", "आमा"]),
            (.grandson, ["grandson", "नाति"]), (.granddaughter, ["granddaughter", "नातिनी"]),
            (.brother, ["brother", "भाइ", "दाजु"]), (.sister, ["sister", "बहिनी", "दिदी"]),
        ]
        for (relation, words) in relationWords where words.contains(where: { q.contains($0) }) {
            if let m = family.first(where: { $0.relation == relation }) { return m }
        }
        return family.first(where: { $0.relation == .selfMember })
    }

    private func memberLabel(_ m: FamilyMember) -> String {
        m.relation == .selfMember
            ? (lang == .ne ? "तपाईं" : "you")
            : "\(m.relation.possessive(lang)) \(m.displayName(lang))"
    }

    private func gate(_ m: FamilyMember) -> String {
        lang == .ne
        ? "\(memberLabel(m))को जन्म विवरण अझै भरिएको छैन। परिवार ट्याबमा गएर जन्म मिति, समय र स्थान भर्नुभयो भने म कुण्डली हेरेर भन्न सक्छु।"
        : "I don't yet have the birth details for \(memberLabel(m)). Please fill in the date, time and place of birth in the Parivar tab, and I will read the kundali properly."
    }

    // ── The reply ────────────────────────────────────────────────────────────
    func reply(to query: String) -> String {
        let q = query.lowercased()
        let ne = lang == .ne

        // Greetings
        if ["namaste", "नमस्ते", "hello", "hi ", "hey"].contains(where: { q.hasPrefix($0) || q == $0.trimmingCharacters(in: .whitespaces) }) {
            return ne
            ? "नमस्ते, म तपाईंको पण्डित हुँ। राशिफल, कुण्डली, दशा, वास्तु, शुभ रंग वा शुभ शहर — जे सोध्नुहोस्।"
            : "Namaste — I am your family pandit. Ask me about rashifal, kundali, dasha, vastu, lucky colors, or which city suits you."
        }

        // Vastu (before member resolution — house questions aren't about a chart)
        if q.contains("vastu") || q.contains("वास्तु") {
            if let specific = VastuKnowledge.answer(for: q, lang: lang) { return specific }
            return VastuKnowledge.overview(lang: lang)
        }
        if let vastuHit = VastuKnowledge.answer(for: q, lang: lang),
           q.contains("direction") || q.contains("दिशा") || q.contains("where") || q.contains("कहाँ") || q.contains("room") || q.contains("कोठा") || q.contains("घर") {
            return vastuHit
        }

        let member = resolveMember(in: q)

        // Color questions
        if q.contains("color") || q.contains("colour") || q.contains("रंग") || q.contains("रङ") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            let g = Interpreter.guna[k.moonRashi.rawValue]
            let colors = (ne ? g.colorsNE : g.colorsEN).joined(separator: ", ")
            // room-specific: blend vastu wisdom in
            let roomNote = VastuKnowledge.answer(for: q, lang: lang).map { "\n\n\($0)" } ?? ""
            return ne
            ? "\(memberLabel(m))को राशि \(k.moonRashi.nameNE) हो, स्वामी ग्रह \(k.moonRashi.lord.nameNE)। शुभ रंगहरू: \(colors)। यी रंगले मन शान्त र भाग्य अनुकूल राख्छ। \(g.dayNE)का दिन यी रंग विशेष फलदायी हुन्छ।\(roomNote)"
            : "\(memberLabel(m).capitalized) has \(k.moonRashi.shortEN) rashi, ruled by \(k.moonRashi.lord.nameEN). The auspicious colors are \(colors) — they calm the mind and invite fortune, especially on \(g.dayEN).\(roomNote)"
        }

        // City / place questions
        if q.contains("city") || q.contains("place to live") || q.contains("shift") || q.contains("move") || q.contains("शहर") || q.contains("बसाइँ") || q.contains("कता बस") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            let prefix = ne ? "\(memberLabel(m))का लागि — " : "For \(memberLabel(m)) — "
            return prefix + CityMatcher.answer(rashi: k.moonRashi, lang: lang)
        }

        // Dasha questions
        if q.contains("dasha") || q.contains("दशा") || q.contains("साढेसाती") || q.contains("sadhe") || q.contains("sade") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            let jd = Ephemeris.julianDay(Date())
            var out: [String] = []
            if let cur = Vimshottari.current(for: k, at: jd) {
                let df = DateFormatter(); df.dateStyle = .medium
                df.locale = Locale(identifier: ne ? "ne_NP" : "en_US")
                let end = df.string(from: Vimshottari.date(fromJD: cur.maha.end))
                out.append(ne
                ? "\(memberLabel(m))को अहिले \(cur.maha.lord.nameNE)को महादशा (\(end) सम्म) र \(cur.antar.lord.nameNE)को अन्तर्दशा चलिरहेको छ।"
                : "\(memberLabel(m).capitalized) is currently in the mahadasha of \(cur.maha.lord.nameEN) (until \(end)), with the antardasha of \(cur.antar.lord.nameEN).")
            }
            let saturnNow = Ephemeris.rashi(of: Ephemeris.sidereal(.saturn, jd: jd))
            if let phase = Interpreter.sadheSatiPhase(natal: k.moonRashi, transitSaturn: saturnNow) {
                out.append(ne
                ? "साढेसातीको चरण \(L10n.digits(phase, .ne)) पनि चलेको छ — शनिवार दान गर्नुहोस्, हनुमान चालीसा पाठ गर्नुहोस्, धैर्य नै औषधि हो।"
                : "Sadhe Sati (phase \(phase)) is also running — give charity on Saturdays, recite Hanuman Chalisa, and let patience be the medicine.")
            } else {
                out.append(ne ? "साढेसाती अहिले छैन — निश्चिन्त रहनुहोस्" : "There is no Sadhe Sati at present — rest easy")
            }
            return out.joined(separator: " ")
        }

        // Kundali / rashi / nakshatra questions
        if q.contains("kundali") || q.contains("कुण्डली") || q.contains("nakshatra") || q.contains("नक्षत्र") || q.contains("rashi") || q.contains("राशि") || q.contains("lagna") || q.contains("लग्न") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            return (ne ? "\(memberLabel(m))को चिना यस्तो छ: " : "Here is the chart of \(memberLabel(m)): ")
                + Interpreter.reading(for: k, lang: lang)
        }

        // Rashifal / "how is my day"
        if q.contains("rashifal") || q.contains("राशिफल") || q.contains("horoscope") || q.contains("today") || q.contains("आज") || q.contains("day") || q.contains("दिन") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            let r = RashifalEngine.generate(rashi: k.moonRashi, period: .daily, date: Date(), lang: lang)
            return (ne ? "\(memberLabel(m))को आजको राशिफल (\(k.moonRashi.nameNE)): " : "Today's rashifal for \(memberLabel(m)) (\(k.moonRashi.shortEN)): ")
                + r.text + " " + (ne ? "उपाय: " : "Upaya: ") + r.upaya
        }

        // Gemstone
        if q.contains("gem") || q.contains("stone") || q.contains("रत्न") || q.contains("पत्थर") {
            guard let m = member, let k = m.kundali else { return gate(member ?? placeholderSelf) }
            let g = Interpreter.guna[k.moonRashi.rawValue]
            return ne
            ? "\(memberLabel(m))को राशि अनुसार \(g.gemstoneNE) धारण गर्नु शुभ हुन्छ — \(g.dayNE)का दिन, शुद्ध भई पहिरनुहोस्। धारण अघि अनुभवी ज्योतिषीसँग पुष्टि गर्नु उत्तम।"
            : "By rashi, \(g.gemstoneEN) suits \(memberLabel(m)) — wear it first on a \(g.dayEN) after a bath and a short prayer. Do confirm with an experienced jyotishi before wearing any gem."
        }

        // Fallback — warm, and advertises capabilities
        return ne
        ? "राम्रो प्रश्न। म कुण्डली, दशा, राशिफल, वास्तु, शुभ रंग, रत्न र शुभ शहरबारे भन्न सक्छु। जस्तै: “मेरो छोराको कोठाका लागि कुन रंग?” वा “मेरो दशा कस्तो छ?” भनेर सोध्नुहोस्।"
        : "A good question. I can read kundali, dasha, rashifal, vastu, lucky colors, gemstones and favorable cities. Try asking, for example: “Which color for my son's room?” or “How is my dasha now?”"
    }

    private var placeholderSelf: FamilyMember {
        family.first(where: { $0.relation == .selfMember })
            ?? FamilyMember(name: "", gender: .other, relation: .selfMember)
    }
}
