import type { AppIconName } from "@/ornaments";
import { displayName } from "@/l10n";
import type { FamilyMember, Language } from "@/types";

export type JyotishFeatureID =
  | "panchang" | "lifePhase" | "muhurta"
  | "marriageMuhurat" | "housePurchaseMuhurat" | "vehicleMuhurat" | "businessMuhurat"
  | "grihaPraveshMuhurat" | "namingMuhurat" | "newJobMuhurat" | "surgeryMuhurat" | "travelMuhurat"
  | "dosha" | "sadeSati" | "remedies" | "kundliMatching" | "relationshipGuidance";

export type JyotishFeature = {
  id: JyotishFeatureID;
  icon: AppIconName;
  name: Record<Language, string>;
  description: Record<Language, string>;
  prompt: Record<Language, string>;
  social?: boolean;
};

const muhurat = (id: JyotishFeatureID, en: string, ne: string, purposeEN: string, purposeNE: string): JyotishFeature => ({
  id,
  icon: "calendar",
  name: { en, ne },
  description: { en: `Find the strongest Panchanga-based candidate dates for ${purposeEN}.`, ne: `${purposeNE}का लागि सहयोगी पञ्चाङ्ग-आधारित मिति खोज्नुहोस्।` },
  prompt: {
    en: `Find the best Muhurat candidates for ${purposeEN}. Use my saved place, ask for constraints, compare dates, explain Tithi, Nakshatra, Yoga and Karana, and clearly state uncertainty.`,
    ne: `${purposeNE}का लागि उत्तम मुहूर्त मिति खोज्नुहोस्। सुरक्षित स्थान, मितिको सीमा, तिथि, नक्षत्र, योग र करण तुलना गरी अनिश्चितता स्पष्ट गर्नुहोस्।`
  }
});

export const jyotishFeatures: JyotishFeature[] = [
  { id: "panchang", icon: "calendar", name: { en: "Today's Panchang", ne: "आजको पञ्चाङ्ग" }, description: { en: "Tithi, nakshatra, yoga, karana, rise and set times, Rahu Kaal, Gulika, Yamaganda, Abhijit and observances for your place.", ne: "तिथि, नक्षत्र, योग, करण, उदय–अस्त, राहुकाल, गुलिक, यमगण्ड, अभिजित र स्थानअनुसारका व्रत।" }, prompt: { en: "Explain today's full Panchang for my saved place and tell me how to use the day.", ne: "मेरो सुरक्षित स्थानअनुसार आजको पूर्ण पञ्चाङ्ग बुझाएर दिन कसरी उपयोग गर्ने भन्नुहोस्।" } },
  { id: "lifePhase", icon: "clock", name: { en: "Dashas & Life Phase", ne: "दशा र जीवन चरण" }, description: { en: "Your Vimshottari Mahadasha, Antardasha, current themes, exact transition dates, and next major phase.", ne: "विम्शोत्तरी महादशा, अन्तर्दशा, हालका विषय, परिवर्तन मिति र अर्को ठूलो चरण।" }, prompt: { en: "Prepare my complete Vimshottari Dasha and life-phase report with dates.", ne: "मितिसहित मेरो पूर्ण विम्शोत्तरी दशा र जीवन चरण रिपोर्ट बनाउनुहोस्।" } },
  { id: "muhurta", icon: "calendar", name: { en: "Muhurat Finder", ne: "मुहूर्त खोजी" }, description: { en: "Find Panchanga-based candidate dates for an important decision or ceremony.", ne: "महत्त्वपूर्ण निर्णय वा संस्कारका लागि पञ्चाङ्गमा आधारित मिति खोज्नुहोस्।" }, prompt: { en: "Help me find a shubh Muhurat. Ask what I am planning, the place, and date constraints before calculating candidates.", ne: "शुभ मुहूर्त खोज्न काम, स्थान र मितिको सीमा सोधेर सहयोग गर्नुहोस्।" } },
  muhurat("marriageMuhurat", "Marriage Muhurat", "विवाह मुहूर्त", "marriage", "विवाह"),
  muhurat("housePurchaseMuhurat", "Buying a house", "घर खरिद", "buying a house", "घर खरिद"),
  muhurat("vehicleMuhurat", "Buying a vehicle", "सवारी खरिद", "buying a vehicle", "सवारी खरिद"),
  muhurat("businessMuhurat", "Opening a business", "व्यापार आरम्भ", "opening a business", "व्यापार आरम्भ"),
  muhurat("grihaPraveshMuhurat", "Griha Pravesh", "गृहप्रवेश", "Griha Pravesh", "गृहप्रवेश"),
  muhurat("namingMuhurat", "Naming ceremony", "नामकरण", "a naming ceremony", "नामकरण"),
  muhurat("newJobMuhurat", "Starting a new job", "नयाँ जागिर", "starting a new job", "नयाँ जागिर सुरु"),
  muhurat("surgeryMuhurat", "Surgery timing", "शल्यक्रिया समय", "an optional surgery date", "वैकल्पिक शल्यक्रिया मिति"),
  muhurat("travelMuhurat", "Travel Muhurat", "यात्रा मुहूर्त", "travel", "यात्रा"),
  { id: "dosha", icon: "moon", name: { en: "Dosha Check", ne: "दोष जाँच" }, description: { en: "Check Mangal, Kaal Sarp, Pitra indicators, Sade Sati, Dhaiya, and Guru Chandal with evidence, severity, and remedies.", ne: "मंगल, कालसर्प, पितृ संकेत, साढेसाती, ढैया र गुरु चाण्डालको प्रमाण, तीव्रता र उपाय।" }, prompt: { en: "Analyze my Kundli for major Doshas, evidence, severity, exceptions and low-cost remedies without fear.", ne: "मेरो कुण्डलीका प्रमुख दोष प्रमाण, तीव्रता, अपवाद र डररहित कम खर्चिला उपायसहित जाँच्नुहोस्।" } },
  { id: "sadeSati", icon: "moon", name: { en: "Sade Sati & Dhaiya", ne: "साढेसाती र ढैया" }, description: { en: "See your current Shani phase, practical themes, timing, and steady remedies.", ne: "हालको शनि चरण, व्यवहारिक विषय, समय र सरल उपाय।" }, prompt: { en: "Check my current Shani Sade Sati or Dhaiya phase with dates, practical effects and simple remedies.", ne: "मेरो शनि साढेसाती वा ढैया चरण मिति, व्यवहारिक प्रभाव र सरल उपायसहित जाँच्नुहोस्।" } },
  { id: "remedies", icon: "sparkle", name: { en: "Personal Upaya", ne: "व्यक्तिगत उपाय" }, description: { en: "Personalized mantra, temple, daan, fasting, charity, colors, foods, gemstones and yantra guidance.", ne: "मन्त्र, मन्दिर, दान, उपवास, सेवा, रंग, भोजन, रत्न र यन्त्रका व्यक्तिगत सुझाव।" }, prompt: { en: "Prepare a safe, low-cost Upaya plan from my Kundli, with cautions and no guaranteed claims.", ne: "मेरो कुण्डलीबाट सावधानी र दाबीबिना सुरक्षित, कम खर्चिलो उपाय योजना बनाउनुहोस्।" } },
  { id: "kundliMatching", icon: "family", social: true, name: { en: "Kundli Matching", ne: "कुण्डली मिलान" }, description: { en: "A detailed 36-point Ashtakoota and Manglik report using both saved Kundlis.", ne: "दुवै कुण्डलीबाट ३६ गुण अष्टकूट र माङ्गलिक मिलानको विस्तृत रिपोर्ट।" }, prompt: { en: "Prepare a complete Kundli matching report.", ne: "पूर्ण कुण्डली मिलान रिपोर्ट बनाउनुहोस्।" } },
  { id: "relationshipGuidance", icon: "family", social: true, name: { en: "Relationship Guidance", ne: "सम्बन्ध मार्गदर्शन" }, description: { en: "Navigate strengths and struggles in a family, friendship, or romantic relationship.", ne: "परिवार, मित्रता वा प्रेम सम्बन्धका बलियो पक्ष र संघर्ष सम्हाल्नुहोस्।" }, prompt: { en: "Prepare a relationship guidance report.", ne: "सम्बन्ध मार्गदर्शन रिपोर्ट बनाउनुहोस्।" } }
];

export const homeFeatureIDs: JyotishFeatureID[] = ["panchang", "lifePhase", "muhurta", "dosha", "kundliMatching"];

export function featureByID(id: JyotishFeatureID) {
  return jyotishFeatures.find((feature) => feature.id === id);
}

export function promptForFeature(feature: JyotishFeature, language: Language, person?: FamilyMember): string {
  if (!person || !feature.social) return feature.prompt[language];
  const name = displayName(person.name, language);
  if (feature.id === "kundliMatching") return language === "ne"
    ? `मेरो र ${name}को कुण्डली प्रयोग गरेर ३६ गुणको पूर्ण अष्टकूट मिलान तयार गर्नुहोस्। वर्ण, वश्य, तारा, योनि, ग्रह मैत्री, गण, भकूट, नाडी, मंगल दोष, बलियो पक्ष, संवेदनशील पक्ष र उपाय देखाउनुहोस्।`
    : `Using my Kundli and ${person.name}'s Kundli, prepare a complete 36-point Ashtakoota report covering every Koota, Manglik balance, strengths, tensions, remedies, and discussion points.`;
  return language === "ne"
    ? `मेरो र ${name}को कुण्डली, नक्षत्र र राशि स्वामी हेरेर सम्बन्धमा के सहज छ, कहाँ संघर्ष आउन सक्छ, र स्पष्ट गर्नुपर्ने र नगर्नुपर्ने कुरा दिनुहोस्।`
    : `Using my Kundli and ${person.name}'s Kundli, nakshatras and rashi lords, prepare a relationship report: what flows, where struggles may arise, and clear dos and don'ts.`;
}

export function parseFeatureSource(sourceKey?: string): { featureID: JyotishFeatureID; memberID?: string } | undefined {
  if (!sourceKey?.startsWith("feature:")) return undefined;
  const [, rawFeature, rawMember] = sourceKey.split(":");
  const feature = jyotishFeatures.find((candidate) => candidate.id === rawFeature);
  if (!feature) return undefined;
  return { featureID: feature.id, ...(rawMember && rawMember !== "self" ? { memberID: rawMember } : {}) };
}
