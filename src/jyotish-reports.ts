import { nakshatrasEN, nakshatrasNE, panchangaFor, rashiMeta } from "@/astro";
import { featureByID, type JyotishFeatureID } from "@/features";
import { displayName } from "@/l10n";
import type { FamilyMember, Kundali, Language } from "@/types";

const DASHA_ORDER = ["Ketu", "Venus", "Sun", "Moon", "Mars", "Rahu", "Jupiter", "Saturn", "Mercury"] as const;
const DASHA_NE = ["केतु", "शुक्र", "सूर्य", "चन्द्र", "मंगल", "राहु", "बृहस्पति", "शनि", "बुध"] as const;
const DASHA_YEARS = [7, 20, 6, 10, 7, 18, 16, 19, 17] as const;
const DAY_MS = 86_400_000;
const UNIX_JD = 2_440_587.5;

type DashaPeriod = { index: number; startJD: number; endJD: number };
export type FeatureToolReport = {
  answer: string;
  evidence: {
    tool: string;
    feature: JyotishFeatureID;
    generatedAt: string;
    facts: Record<string, string | number | boolean | null>;
    uncertainty: string;
  };
};

function jdNow(now: Date) { return now.getTime() / DAY_MS + UNIX_JD; }
function dateFromJD(jd: number) { return new Date((jd - UNIX_JD) * DAY_MS); }
function dateLabel(jd: number, language: Language) {
  return new Intl.DateTimeFormat(language === "ne" ? "ne-NP" : "en-GB", { day: "numeric", month: "long", year: "numeric" }).format(dateFromJD(jd));
}
function lordName(index: number, language: Language) { return language === "ne" ? DASHA_NE[index] : DASHA_ORDER[index]; }

export function vimshottariSnapshot(kundali: Kundali, now = new Date()) {
  const first = kundali.moonNakshatraIndex % 9;
  const periods: DashaPeriod[] = [];
  let cursor = kundali.birthJD;
  for (let offset = 0; offset < 18; offset += 1) {
    const index = (first + offset) % 9;
    const years = offset === 0 ? DASHA_YEARS[index] * (1 - kundali.moonNakshatraFraction) : DASHA_YEARS[index];
    const period = { index, startJD: cursor, endJD: cursor + years * 365.25 };
    periods.push(period);
    cursor = period.endJD;
  }
  const today = jdNow(now);
  const maha = periods.find((period) => today >= period.startJD && today < period.endJD) ?? periods.at(-1)!;
  const next = periods[periods.indexOf(maha) + 1];
  const fullStart = maha.endJD - DASHA_YEARS[maha.index] * 365.25;
  let antarCursor = fullStart;
  let antar: DashaPeriod = { index: maha.index, startJD: maha.startJD, endJD: maha.endJD };
  for (let offset = 0; offset < 9; offset += 1) {
    const index = (maha.index + offset) % 9;
    const endJD = antarCursor + DASHA_YEARS[maha.index] * 365.25 * DASHA_YEARS[index] / 120;
    if (today >= antarCursor && today < endJD) antar = { index, startJD: Math.max(antarCursor, maha.startJD), endJD: Math.min(endJD, maha.endJD) };
    antarCursor = endJD;
  }
  return { maha, antar, next, periods };
}

const lordThemes: Record<(typeof DASHA_ORDER)[number], { en: string; ne: string }> = {
  Ketu: { en: "simplification, detachment, research, and inner correction", ne: "सरलीकरण, वैराग्य, अनुसन्धान र भित्री सुधार" },
  Venus: { en: "relationships, agreements, comfort, creativity, and values", ne: "सम्बन्ध, सम्झौता, सुविधा, सिर्जना र मूल्य" },
  Sun: { en: "leadership, visibility, responsibility, and authority", ne: "नेतृत्व, पहिचान, जिम्मेवारी र अधिकार" },
  Moon: { en: "home, care, emotion, belonging, and public response", ne: "घर, हेरचाह, भावना, अपनत्व र सार्वजनिक प्रतिक्रिया" },
  Mars: { en: "decisive action, competition, courage, and conflict management", ne: "निर्णायक काम, प्रतिस्पर्धा, साहस र द्वन्द्व व्यवस्थापन" },
  Rahu: { en: "ambition, unfamiliar territory, technology, and appetite", ne: "महत्त्वाकाङ्क्षा, नयाँ क्षेत्र, प्रविधि र तीव्र चाहना" },
  Jupiter: { en: "learning, counsel, expansion, ethics, and long-term growth", ne: "शिक्षा, सल्लाह, विस्तार, नैतिकता र दीर्घ वृद्धि" },
  Saturn: { en: "discipline, duty, delay, structure, and durable results", ne: "अनुशासन, कर्तव्य, ढिलाइ, संरचना र टिकाउ परिणाम" },
  Mercury: { en: "communication, commerce, analysis, skills, and adaptability", ne: "सञ्चार, व्यापार, विश्लेषण, सीप र अनुकूलन" }
};

function dashaReport(member: FamilyMember, language: Language, now: Date): FeatureToolReport {
  const kundali = member.kundali!;
  const { maha, antar, next } = vimshottariSnapshot(kundali, now);
  const mahaName = lordName(maha.index, language);
  const antarName = lordName(antar.index, language);
  const nextName = next ? lordName(next.index, language) : "—";
  const currentTheme = lordThemes[DASHA_ORDER[maha.index]][language];
  const subTheme = lordThemes[DASHA_ORDER[antar.index]][language];
  const nextTheme = next ? lordThemes[DASHA_ORDER[next.index]][language] : "";
  const answer = language === "ne" ? [
    "## दशा र जीवन चरण",
    `**${displayName(member.name, language)}को हालको महादशा:** ${mahaName} — ${dateLabel(maha.startJD, language)} देखि ${dateLabel(maha.endJD, language)} सम्म`,
    `**हालको अन्तर्दशा:** ${antarName} — ${dateLabel(antar.startJD, language)} देखि ${dateLabel(antar.endJD, language)} सम्म`,
    `**अर्को महादशा:** ${nextName} — ${next ? dateLabel(next.startJD, language) : "उपलब्ध छैन"} बाट`,
    "## अहिलेको मुख्य अर्थ",
    `${mahaName} महादशाले ${currentTheme}लाई लामो पृष्ठभूमि बनाउँछ। ${antarName} अन्तर्दशाले अहिले ${subTheme}लाई बढी सक्रिय बनाउँछ। यो समयलाई निश्चित घटना होइन, निर्णयको मौसमका रूपमा बुझ्नुहोस्।`,
    "## जीवन क्षेत्र",
    `- **पेशा:** ${currentTheme}सँग मिल्ने जिम्मेवारी र सीपलाई प्राथमिकता दिनुहोस्; अन्तर्दशाको ${subTheme}ले तुरुन्त ध्यान चाहेको ठाउँ देखाउँछ।`,
    `- **सम्बन्ध/विवाह:** प्रतिक्रिया अघि संवाद गर्नुहोस्। दशाले प्रवृत्ति देखाउँछ, सम्बन्धको नतिजा तय गर्दैन।`,
    `- **धन:** नगद प्रवाह, कर्जा र ठूला प्रतिबद्धता लिखित योजनाबाट चलाउनुहोस्।`,
    `- **शिक्षा:** ${subTheme}सँग जोडिएको एउटा मापनयोग्य सीप रोज्नुहोस्।`,
    `- **सन्तान/परिवार:** समय, सीमा र अपेक्षा स्पष्ट राख्नुहोस्; डरमा आधारित भविष्यवाणी नगर्नुहोस्।`,
    `- **स्वास्थ्य:** दिनचर्या, निद्रा र जाँचलाई प्राथमिकता दिनुहोस्; यो चिकित्सकीय निदान होइन।`,
    "## अर्को ठूलो चरण",
    next ? `${nextName} महादशा ${dateLabel(next.startJD, language)} बाट सुरु हुन्छ। यसको मुख्य स्वर ${nextTheme} हुनेछ। परिवर्तनअघि ६–१२ महिनामा सीप, बचत र सम्बन्धका अधुरा संवाद व्यवस्थित गर्नु उपयोगी हुन्छ।` : "अर्को चरण गणना सीमाभित्र उपलब्ध छैन।",
    "## गर्नुपर्ने",
    "- मिति नजिकिँदा योजना पुनरावलोकन गर्नुहोस्।\n- तथ्य, बजेट र स्पष्ट संवादमा निर्णय राख्नुहोस्।\n- जन्मसमय अनिश्चित भए समयलाई अनुमानको दायराका रूपमा लिनुहोस्।",
    "## नगर्नुपर्ने",
    "- दशालाई डर वा भाग्यको अन्तिम फैसला नबनाउनुहोस्।\n- स्वास्थ्य, विवाह वा लगानीको ठूलो निर्णय केवल यो रिपोर्टबाट नगर्नुहोस्।\n- महँगो रत्न वा उपाय प्रमाणीकरणबिना नकिन्नुहोस्।"
  ].join("\n\n") : [
    "## Dashas & Life Phase",
    `**Current Mahadasha for ${member.name}:** ${mahaName} — ${dateLabel(maha.startJD, language)} to ${dateLabel(maha.endJD, language)}`,
    `**Current Antardasha:** ${antarName} — ${dateLabel(antar.startJD, language)} to ${dateLabel(antar.endJD, language)}`,
    `**Next Mahadasha:** ${nextName} — begins ${next ? dateLabel(next.startJD, language) : "unavailable"}`,
    "## What this phase emphasizes",
    `${mahaName} Mahadasha makes ${currentTheme} the long background. ${antarName} Antardasha brings ${subTheme} into immediate focus. Treat this as a decision climate, not a guaranteed event.`,
    "## Life areas",
    `- **Career:** Prioritize responsibilities and skills aligned with ${currentTheme}; ${subTheme} shows the nearer-term pressure point.`,
    "- **Relationships and marriage:** Communicate before reacting. A Dasha describes tendencies; it does not decide a relationship's outcome.",
    "- **Money:** Use a written plan for cash flow, debt, and major commitments.",
    `- **Education:** Choose one measurable skill connected with ${subTheme}.`,
    "- **Children and family:** Keep time, boundaries, and expectations explicit; avoid fear-based prediction.",
    "- **Health:** Protect routine, sleep, and appropriate checkups; this is not medical diagnosis.",
    "## Next major phase",
    next ? `${nextName} Mahadasha begins on ${dateLabel(next.startJD, language)}. Its central tone is ${nextTheme}. In the 6–12 months before the transition, organize skills, savings, and unfinished relationship conversations.` : "The next phase is outside the calculated range.",
    "## Do",
    "- Revisit plans as the transition date approaches.\n- Ground decisions in facts, budgets, and direct conversation.\n- Treat dates as a range when the saved birth time is uncertain.",
    "## Don't",
    "- Treat a Dasha as a verdict or source of fear.\n- Make a major medical, marriage, or investment decision from this report alone.\n- Buy expensive gemstones or remedies without independent verification."
  ].join("\n\n");
  return {
    answer,
    evidence: {
      tool: "vimshottari_dasha_report_v1",
      feature: "lifePhase",
      generatedAt: now.toISOString(),
      facts: {
        subjectMemberID: member.id,
        mahadasha: DASHA_ORDER[maha.index], mahadashaStart: dateFromJD(maha.startJD).toISOString(), mahadashaEnd: dateFromJD(maha.endJD).toISOString(),
        antardasha: DASHA_ORDER[antar.index], antardashaStart: dateFromJD(antar.startJD).toISOString(), antardashaEnd: dateFromJD(antar.endJD).toISOString(),
        nextMahadasha: next ? DASHA_ORDER[next.index] : null, nextMahadashaStart: next ? dateFromJD(next.startJD).toISOString() : null,
        birthTimeKnown: Boolean(member.birth?.timeKnown)
      },
      uncertainty: "Vimshottari dates use the saved Moon nakshatra fraction and a 365.25-day year. Birth-time uncertainty and the app's compact local ephemeris can shift boundaries; the agent must not override these tool dates without a higher-precision calculation."
    }
  };
}

function genericReport(featureID: JyotishFeatureID, self: FamilyMember, other: FamilyMember | undefined, language: Language, now: Date): FeatureToolReport {
  const feature = featureByID(featureID)!;
  const panchanga = panchangaFor(now, language);
  const socialLine = other?.kundali && self.kundali
    ? (language === "ne" ? `${displayName(self.name, language)}: ${rashiMeta[self.kundali.moonRashi].ne}, ${nakshatrasNE[self.kundali.moonNakshatraIndex]}; ${displayName(other.name, language)}: ${rashiMeta[other.kundali.moonRashi].ne}, ${nakshatrasNE[other.kundali.moonNakshatraIndex]}।` : `${self.name}: ${rashiMeta[self.kundali.moonRashi].short}, ${nakshatrasEN[self.kundali.moonNakshatraIndex]}; ${other.name}: ${rashiMeta[other.kundali.moonRashi].short}, ${nakshatrasEN[other.kundali.moonNakshatraIndex]}.`)
    : "";
  const muhuratFeature = featureID === "muhurta" || featureID.endsWith("Muhurat");
  let body: string;
  if (featureID === "panchang") body = language === "ne"
    ? `## आजको पञ्चाङ्ग\n\n- **तिथि:** ${panchanga.tithi}\n- **नक्षत्र:** ${panchanga.nakshatra}\n- **योग:** ${panchanga.yoga}\n- **करण:** ${panchanga.karana}\n\nसूर्योदय, सूर्यास्त, चन्द्रोदय, चन्द्रास्त, राहुकाल, गुलिक, यमगण्ड र अभिजित मुहूर्तका ठ्याक्कै स्थानीय समयका लागि पूर्ण स्थान-आधारित गणना आवश्यक छ। एजेन्टले सुरक्षित स्थान प्रयोग गरी ती समय थप्नुपर्छ।\n\n## गर्नुपर्ने\nदिनको काम तिथि र नक्षत्रको स्वभावसँग मिलाउनुहोस्।\n\n## नगर्नुपर्ने\nअधुरो समयलाई निश्चित शुभ/अशुभ फैसला नबनाउनुहोस्।`
    : `## Today's Panchang\n\n- **Tithi:** ${panchanga.tithi}\n- **Nakshatra:** ${panchanga.nakshatra}\n- **Yoga:** ${panchanga.yoga}\n- **Karana:** ${panchanga.karana}\n\nExact local sunrise, sunset, moonrise, moonset, Rahu Kaal, Gulika, Yamaganda, and Abhijit require the full location-aware calculation. The agent should add those times from the saved place.\n\n## Do\nMatch the day's work to the Tithi and Nakshatra qualities.\n\n## Don't\nTreat an incomplete time window as a final auspicious or inauspicious verdict.`;
  else if (muhuratFeature) body = language === "ne"
    ? `## ${feature.name.ne}\n\nउम्मेदवार मिति निकाल्नुअघि यी कुरा चाहिन्छ:\n- काम हुने स्थान\n- सुरु र अन्त्य मिति\n- टार्नुपर्ने दिन वा समय\n- सम्बन्धित व्यक्तिको जन्म विवरण\n\nएजेन्टले प्रत्येक मितिको तिथि, नक्षत्र, योग, करण र निषेधकाल तुलना गरेर ३–५ उम्मेदवार दिनुपर्छ। शल्यक्रियामा चिकित्सकको समयलाई सधैं प्राथमिकता दिनुहोस्।`
    : `## ${feature.name.en}\n\nBefore calculating candidate dates, I need:\n- event location\n- earliest and latest date\n- days or times to avoid\n- birth details of the people involved\n\nThe agent should compare Tithi, Nakshatra, Yoga, Karana, and avoidance windows and return 3–5 candidates. For surgery, clinical scheduling always takes priority.`;
  else if (feature.social) body = language === "ne"
    ? `## ${feature.name.ne}\n\n${socialLine}\n\nदुवै सुरक्षित कुण्डली एजेन्टलाई उपलब्ध छन्। रिपोर्टले राशि स्वामी, नक्षत्र, गण–नाडी–योनि जस्ता अष्टकूट घटक, मंगल संकेत, सहजता, तनाव र छलफलका प्रश्न छुट्टाछुट्टै देखाउनुपर्छ।\n\n## गर्नुपर्ने\nव्यवहार, सीमा र अपेक्षाबारे सिधा संवाद गर्नुहोस्।\n\n## नगर्नुपर्ने\nएक स्कोरका कारण सम्बन्ध स्वीकार वा अस्वीकार नगर्नुहोस्।`
    : `## ${feature.name.en}\n\n${socialLine}\n\nBoth saved Kundlis are available to the agent. The report should separately show rashi lords, nakshatras, Ashtakoota components such as Gana, Nadi, and Yoni, Manglik indicators, ease, tension, and discussion questions.\n\n## Do\nDiscuss behaviour, boundaries, and expectations directly.\n\n## Don't\nAccept or reject a relationship because of one score.`;
  else body = language === "ne"
    ? `## ${feature.name.ne}\n\n${feature.description.ne}\n\nएजेन्टले सुरक्षित जन्म विवरणबाट आवश्यक पूर्ण ग्रह स्थिति निकालेर प्रमाण, तीव्रता, अपवाद र व्यवहारिक अर्थ छुट्टाछुट्टै देखाउनुपर्छ। स्थानीय हल्का कुण्डलीमा नभएको ग्रह स्थिति अनुमान गरेर दोष वा उपाय घोषणा गर्नु हुँदैन।\n\n## गर्नुपर्ने\nकम खर्चिलो, सुरक्षित र व्यवहारिक उपायबाट सुरु गर्नुहोस्।\n\n## नगर्नुपर्ने\nडर, निश्चित दाबी वा महँगो रत्नलाई आधार नबनाउनुहोस्।`
    : `## ${feature.name.en}\n\n${feature.description.en}\n\nThe agent should calculate the required full planetary positions from the saved birth data and separate evidence, severity, exceptions, and practical meaning. It must not invent a Dosha or remedy from planets absent from the compact local chart.\n\n## Do\nStart with low-cost, safe, practical actions.\n\n## Don't\nUse fear, guaranteed claims, or expensive gemstones as the default.`;
  return { answer: body, evidence: { tool: "jyotish_feature_report_v1", feature: featureID, generatedAt: now.toISOString(), facts: { subjectMemberID: self.id, otherMemberID: other?.id ?? null, tithi: panchanga.tithi, nakshatra: panchanga.nakshatra, birthTimeKnown: Boolean(self.birth?.timeKnown), otherBirthTimeKnown: other ? Boolean(other.birth?.timeKnown) : null }, uncertainty: "The compact local chart contains Lagna, Sun, Moon, and Moon nakshatra. The agent must calculate and disclose any additional planetary evidence before asserting detailed Dosha, transit, Muhurat, or Ashtakoota results." } };
}

export function buildFeatureToolReport(featureID: JyotishFeatureID, family: FamilyMember[], language: Language, memberID?: string, now = new Date()): FeatureToolReport {
  const self = family.find((member) => member.relation === "selfMember" && member.kundali);
  const feature = featureByID(featureID)!;
  if (!self) {
    const answer = language === "ne" ? `## ${feature.name.ne}\n\nयो रिपोर्ट बनाउन पहिले आफ्नो पूरा जन्म मिति, समय र स्थान परिवारमा सुरक्षित गर्नुहोस्।` : `## ${feature.name.en}\n\nSave your complete birth date, time, and place in Parivar before preparing this report.`;
    return { answer, evidence: { tool: "missing_birth_profile", feature: featureID, generatedAt: now.toISOString(), facts: { hasSelfKundali: false }, uncertainty: "No self Kundli is available." } };
  }
  if (featureID === "lifePhase") return dashaReport(self, language, now);
  const other = memberID ? family.find((member) => member.id === memberID && member.kundali) : undefined;
  if (feature.social && !other) {
    const answer = language === "ne" ? `## ${feature.name.ne}\n\nयो रिपोर्टका लागि परिवार, साथी वा पार्टनरको पूरा जन्म विवरण थप्नुहोस्।` : `## ${feature.name.en}\n\nAdd a family member, friend, or partner with complete birth details to prepare this report.`;
    return { answer, evidence: { tool: "missing_relationship_profile", feature: featureID, generatedAt: now.toISOString(), facts: { hasSelfKundali: true, hasOtherKundali: false }, uncertainty: "A second Kundli is required." } };
  }
  return genericReport(featureID, self, other, language, now);
}
