import SwiftUI

enum JyotishFeatureID: String, CaseIterable, Identifiable {
    case panchang, lifePhase, muhurta
    case marriageMuhurat, housePurchaseMuhurat, vehicleMuhurat, businessMuhurat
    case grihaPraveshMuhurat, namingMuhurat, newJobMuhurat, surgeryMuhurat, travelMuhurat
    case dosha, sadeSati, remedies, kundliMatching, relationshipGuidance

    var id: String { rawValue }
}

struct JyotishFeature: Identifiable, Equatable {
    var id: JyotishFeatureID
    var icon: String
    var nameEN: String
    var nameNE: String
    var descriptionEN: String
    var descriptionNE: String
    var promptEN: String
    var promptNE: String
    var isSocial = false

    func name(_ language: Language) -> String { language == .ne ? nameNE : nameEN }
    func description(_ language: Language) -> String { language == .ne ? descriptionNE : descriptionEN }

    func prompt(_ language: Language, person: FamilyMember? = nil) -> String {
        guard let person else { return language == .ne ? promptNE : promptEN }
        switch id {
        case .kundliMatching:
            return language == .ne
                ? "मेरो र \(person.name)को कुण्डली प्रयोग गरेर ३६ गुणको पूर्ण अष्टकूट मिलान तयार गर्नुहोस्। वर्ण, वश्य, तारा, योनि, ग्रह मैत्री, गण, भकूट, नाडी, मंगल दोष, बलियो पक्ष, संवेदनशील पक्ष, उपाय र स्पष्ट गर्नुपर्ने कुराहरू देखाउनुहोस्।"
                : "Using my kundli and \(person.name)'s kundli, prepare a complete 36-point Ashtakoota report. Cover Varna, Vashya, Tara, Yoni, Graha Maitri, Gana, Bhakoot, Nadi, Mangal Dosha balance, strengths, tensions, remedies, and questions we should discuss."
        case .relationshipGuidance:
            return language == .ne
                ? "मेरो र \(person.name)को कुण्डली, नक्षत्र, राशि स्वामी र आजको गोचर हेरेर हाम्रो सम्बन्धमा के सहज छ, कहाँ संघर्ष आउन सक्छ, र आज के गर्ने वा नगर्ने भनेर विस्तृत रिपोर्ट दिनुहोस्।"
                : "Using my kundli, \(person.name)'s kundli, our nakshatras, rashi lords, and today's transits, prepare a detailed relationship report: what flows, where struggles may arise, and today's clear dos and don'ts."
        default:
            return language == .ne ? promptNE : promptEN
        }
    }
}

enum JyotishFeatureCatalog {
    static let all: [JyotishFeature] = [
        JyotishFeature(id: .panchang, icon: "calendar",
                       nameEN: "Today's Panchang", nameNE: "आजको पञ्चाङ्ग",
                       descriptionEN: "Tithi, nakshatra, yoga, karana, rise and set times, Rahu Kaal, Gulika, Yamaganda, Abhijit and observances for your place.",
                       descriptionNE: "तिथि, नक्षत्र, योग, करण, उदय–अस्त, राहुकाल, गुलिक, यमगण्ड, अभिजित र स्थानअनुसारका व्रत।",
                       promptEN: "Explain today's full Panchang for my saved birthplace: Tithi, Nakshatra, Yoga, Karana, sunrise, sunset, moonrise, moonset, Rahu Kaal, Gulika Kaal, Yamaganda, Abhijit Muhurat, and observances. Tell me how to use the day.",
                       promptNE: "मेरो सुरक्षित जन्मस्थानअनुसार आजको पूर्ण पञ्चाङ्ग—तिथि, नक्षत्र, योग, करण, सूर्योदय, सूर्यास्त, चन्द्रोदय, चन्द्रास्त, राहुकाल, गुलिककाल, यमगण्ड, अभिजित मुहूर्त र व्रत—बुझाएर आजको दिन कसरी उपयोग गर्ने भन्नुहोस्।"),
        JyotishFeature(id: .lifePhase, icon: "clock.arrow.2.circlepath",
                       nameEN: "Life Phase", nameNE: "जीवन चरण",
                       descriptionEN: "Understand your Mahadasha, Antardasha, current themes, and the next major transition.",
                       descriptionNE: "महादशा, अन्तर्दशा, हालका विषय र अर्को ठूलो परिवर्तन बुझ्नुहोस्।",
                       promptEN: "Read my Vimshottari Mahadasha and Antardasha. Explain my current life phase and next major phase across career, marriage, money, education, children, and health, with dates and uncertainty.",
                       promptNE: "मेरो विम्शोत्तरी महादशा र अन्तर्दशा हेरेर हालको जीवन चरण र अर्को ठूलो चरणलाई पेशा, विवाह, धन, शिक्षा, सन्तान र स्वास्थ्यमा मितिसहित बुझाउनुहोस्।"),
        JyotishFeature(id: .muhurta, icon: "calendar.badge.clock",
                       nameEN: "Muhurat Finder", nameNE: "मुहूर्त खोजी",
                       descriptionEN: "Find Panchanga-based candidate dates for an important decision or ceremony.",
                       descriptionNE: "महत्त्वपूर्ण निर्णय वा संस्कारका लागि पञ्चाङ्गमा आधारित मिति खोज्नुहोस्।",
                       promptEN: "Help me find a shubh Muhurat. Ask what I am planning, the place, and any date constraints before calculating candidates.",
                       promptNE: "मलाई शुभ मुहूर्त खोज्न मद्दत गर्नुहोस्। मिति निकाल्नुअघि काम, स्थान र मितिको सीमा सोध्नुहोस्।"),
        muhurat(.marriageMuhurat, "heart.circle", "Marriage Muhurat", "विवाह मुहूर्त", "marriage", "विवाह"),
        muhurat(.housePurchaseMuhurat, "house.circle", "Buying a house", "घर खरिद", "buying a house", "घर खरिद"),
        muhurat(.vehicleMuhurat, "car.circle", "Buying a vehicle", "सवारी खरिद", "buying a vehicle", "सवारी खरिद"),
        muhurat(.businessMuhurat, "building.2.crop.circle", "Opening a business", "व्यापार आरम्भ", "opening a business", "व्यापार आरम्भ"),
        muhurat(.grihaPraveshMuhurat, "door.left.hand.open", "Griha Pravesh", "गृहप्रवेश", "Griha Pravesh", "गृहप्रवेश"),
        muhurat(.namingMuhurat, "character.book.closed", "Naming ceremony", "नामकरण", "a naming ceremony", "नामकरण"),
        muhurat(.newJobMuhurat, "briefcase.circle", "Starting a new job", "नयाँ जागिर", "starting a new job", "नयाँ जागिर सुरु"),
        muhurat(.surgeryMuhurat, "cross.case.circle", "Surgery timing", "शल्यक्रिया समय", "an optional surgery date", "वैकल्पिक शल्यक्रिया मिति"),
        muhurat(.travelMuhurat, "airplane.circle", "Travel Muhurat", "यात्रा मुहूर्त", "travel", "यात्रा"),
        JyotishFeature(id: .dosha, icon: "circle.hexagongrid",
                       nameEN: "Dosha Check", nameNE: "दोष जाँच",
                       descriptionEN: "Check Mangal Dosha, Kaal Sarp, Pitra indicators, Sade Sati, Dhaiya, and Guru Chandal with severity and remedies.",
                       descriptionNE: "मंगल दोष, कालसर्प, पितृ संकेत, साढेसाती, ढैया र गुरु चाण्डालको तीव्रता र उपाय जाँच्नुहोस्।",
                       promptEN: "Analyze my kundli for Mangal Dosha, Kaal Sarp Yoga, Pitra Dosha indicators, Shani Sade Sati, Dhaiya, and Guru Chandal Yoga. Explain evidence, severity, effects, exceptions, and low-cost remedies without fear.",
                       promptNE: "मेरो कुण्डलीमा मंगल दोष, कालसर्प योग, पितृ दोषका संकेत, शनि साढेसाती, ढैया र गुरु चाण्डाल योग जाँचेर प्रमाण, तीव्रता, प्रभाव, अपवाद र डररहित सरल उपाय दिनुहोस्।"),
        JyotishFeature(id: .sadeSati, icon: "circle.lefthalf.filled.inverse",
                       nameEN: "Sade Sati & Dhaiya", nameNE: "साढेसाती र ढैया",
                       descriptionEN: "See your current Shani phase, its practical themes, timing, and steady remedies.",
                       descriptionNE: "हालको शनि चरण, व्यवहारिक विषय, समय र सरल उपाय हेर्नुहोस्।",
                       promptEN: "Check my current Shani Sade Sati or Dhaiya phase. Explain the phase, dates, practical effects, what to do, what not to fear, and simple remedies.",
                       promptNE: "मेरो हालको शनि साढेसाती वा ढैया चरण जाँचेर चरण, मिति, व्यवहारिक प्रभाव, गर्नुपर्ने, नडराउनुपर्ने र सरल उपाय बुझाउनुहोस्।"),
        JyotishFeature(id: .remedies, icon: "hands.and.sparkles",
                       nameEN: "Personal Upaya", nameNE: "व्यक्तिगत उपाय",
                       descriptionEN: "Personalized mantra, temple, daan, fasting, charity, colors, foods, gemstones and yantra guidance.",
                       descriptionNE: "मन्त्र, मन्दिर, दान, उपवास, सेवा, रंग, भोजन, रत्न र यन्त्रका व्यक्तिगत सुझाव।",
                       promptEN: "Prepare a safe, low-cost Upaya plan from my kundli. Include mantra, temple or home practice, daan, charity, fasting safety, colors, foods, gemstones, and yantra, with cautions and no guaranteed claims.",
                       promptNE: "मेरो कुण्डलीबाट सुरक्षित र कम खर्चिलो उपाय योजना बनाउनुहोस्। मन्त्र, मन्दिर वा घरको साधना, दान, सेवा, उपवास सुरक्षा, रंग, भोजन, रत्न र यन्त्रलाई सावधानीसहित समावेश गर्नुहोस्।"),
        JyotishFeature(id: .kundliMatching, icon: "person.2.circle",
                       nameEN: "Kundli Matching", nameNE: "कुण्डली मिलान",
                       descriptionEN: "A detailed 36-point Ashtakoota and Manglik report using both saved kundlis.",
                       descriptionNE: "दुवै कुण्डलीबाट ३६ गुण अष्टकूट र माङ्गलिक मिलानको विस्तृत रिपोर्ट।",
                       promptEN: "Prepare a complete Kundli matching report.", promptNE: "पूर्ण कुण्डली मिलान रिपोर्ट बनाउनुहोस्।",
                       isSocial: true),
        JyotishFeature(id: .relationshipGuidance, icon: "heart.text.square",
                       nameEN: "Relationship Guidance", nameNE: "सम्बन्ध मार्गदर्शन",
                       descriptionEN: "Navigate the daily strengths and struggles in a family, friendship, or romantic relationship.",
                       descriptionNE: "परिवार, मित्रता वा प्रेम सम्बन्धका दैनिक बलियो पक्ष र संघर्ष सम्हाल्नुहोस्।",
                       promptEN: "Prepare a relationship guidance report.", promptNE: "सम्बन्ध मार्गदर्शन रिपोर्ट बनाउनुहोस्।",
                       isSocial: true),
    ]

    static let homeIDs: [JyotishFeatureID] = [.panchang, .muhurta, .dosha, .remedies, .kundliMatching]
    static var home: [JyotishFeature] { homeIDs.compactMap(feature) }
    static func feature(_ id: JyotishFeatureID) -> JyotishFeature? { all.first { $0.id == id } }

    private static func muhurat(_ id: JyotishFeatureID, _ icon: String,
                                _ en: String, _ ne: String,
                                _ purposeEN: String, _ purposeNE: String) -> JyotishFeature {
        JyotishFeature(id: id, icon: icon, nameEN: en, nameNE: ne,
                       descriptionEN: "Find the strongest Panchanga-based candidate dates for \(purposeEN).",
                       descriptionNE: "\(purposeNE)का लागि सहयोगी पञ्चाङ्ग-आधारित मिति खोज्नुहोस्।",
                       promptEN: "Find the best Muhurat candidates for \(purposeEN). Use my saved place, ask for constraints, compare dates, explain Tithi, Nakshatra, Yoga and Karana, and clearly state uncertainty.",
                       promptNE: "\(purposeNE)का लागि उत्तम मुहूर्त मिति खोज्नुहोस्। सुरक्षित स्थान, मितिको सीमा, तिथि, नक्षत्र, योग र करण तुलना गरी अनिश्चितता स्पष्ट गर्नुहोस्।")
    }
}

struct FeatureLaunchSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss
    let feature: JyotishFeature
    @State private var selectedMemberID: UUID?

    private var relatives: [FamilyMember] {
        app.family.filter { $0.relation != .selfMember && $0.hasBirthData }
    }
    private var selectedMember: FamilyMember? {
        relatives.first { $0.id == selectedMemberID } ?? relatives.first
    }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Image(systemName: feature.icon)
                        .scaledFont(size: 30, weight: .light)
                        .foregroundStyle(p.saffron)
                        .frame(width: 62, height: 62)
                        .background(Circle().fill(p.bgSunken))
                    Text(feature.name(app.language))
                        .scaledFont(size: 28, weight: .bold, design: .serif)
                        .foregroundStyle(p.inkPrimary)
                    Text(feature.description(app.language))
                        .scaledFont(size: 17, design: .serif)
                        .foregroundStyle(p.inkSecondary)
                        .lineSpacing(5)

                    if feature.isSocial && !relatives.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: app.language == .ne ? "व्यक्ति छान्नुहोस्" : "Choose a person")
                            ForEach(relatives) { member in
                                Button { selectedMemberID = member.id } label: {
                                    HStack(spacing: 12) {
                                        if let kundali = member.kundali {
                                            RashiSeal(rashi: kundali.moonRashi, size: 40)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(member.name)
                                                .scaledFont(size: 17, weight: .semibold, design: .serif)
                                            Text(app.language == .ne ? member.relation.labelNE : member.relation.labelEN)
                                                .scaledFont(size: 13)
                                                .foregroundStyle(p.inkSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: selectedMember?.id == member.id ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedMember?.id == member.id ? p.saffron : p.templeGold.opacity(0.4))
                                    }
                                    .foregroundStyle(p.inkPrimary)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(SpringPressStyle())
                                Hairline()
                            }
                        }
                    }

                    if feature.isSocial && relatives.isEmpty {
                        Text(app.language == .ne
                             ? "यो रिपोर्टका लागि परिवार, साथी वा पार्टनरको जन्म विवरण थप्नुहोस्।"
                             : "Add a family member, friend, or partner with birth details to create this report.")
                            .scaledFont(size: 15, design: .serif)
                            .foregroundStyle(p.inkSecondary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(p.bgSunken))
                        PrimaryButton(title: app.language == .ne ? "व्यक्ति थप्नुहोस्" : "Add a person", icon: "person.badge.plus") {
                            dismiss()
                            DispatchQueue.main.async { app.open(.family) }
                        }
                    } else {
                        PrimaryButton(title: app.language == .ne ? "ज्योतिष बाजेसँग रिपोर्ट बनाउनुहोस्" : "Prepare with Jyotish Baje",
                                      icon: "sparkles") {
                            let prompt = feature.prompt(app.language, person: selectedMember)
                            dismiss()
                            DispatchQueue.main.async { app.openPandit(prompt: prompt, sourceKey: "feature:\(feature.id.rawValue):\(selectedMember?.id.uuidString ?? "self")") }
                        }
                    }
                }
                .padding(.horizontal, LayoutMetrics.sheetGutter)
                .padding(.top, 48)
                .padding(.bottom, 30)
            }
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .onAppear { selectedMemberID = relatives.first?.id }
        .presentationDetents([.large])
    }
}

struct FeatureCatalogSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var selected: JyotishFeature?

    var body: some View {
        NavigationStack {
            ZStack {
                p.bgCanvas.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(JyotishFeatureCatalog.all) { feature in
                            Button { selected = feature } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: feature.icon)
                                        .scaledFont(size: 20, weight: .light)
                                        .foregroundStyle(p.saffron)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(p.bgSunken))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(feature.name(app.language))
                                            .scaledFont(size: 18, weight: .semibold, design: .serif)
                                            .foregroundStyle(p.inkPrimary)
                                        Text(feature.description(app.language))
                                            .scaledFont(size: 13)
                                            .foregroundStyle(p.inkSecondary)
                                            .lineLimit(2)
                                    }
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .scaledFont(size: 13, weight: .semibold)
                                        .foregroundStyle(p.inkSecondary)
                                }
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(SpringPressStyle())
                            Hairline()
                        }
                    }
                    .padding(.horizontal, LayoutMetrics.screenGutter)
                }
            }
            .navigationTitle(app.language == .ne ? "लोकप्रिय सुविधाहरू" : "Popular features")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { SheetCloseButton() } }
        }
        .sheet(item: $selected) { FeatureLaunchSheet(feature: $0) }
        .presentationDetents([.large])
    }
}
