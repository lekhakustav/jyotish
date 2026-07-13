import React from "react";
import { View } from "react-native";
import Svg, { Line, Rect, Text as SvgText } from "react-native-svg";
import { AppText, Hairline, InfoRow, PressableScale, SectionLabel, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon, RashiMark } from "../ornaments";
import { useAppState } from "../app-state";
import { nakshatrasEN, nakshatrasNE, rashiMeta, rashiOrder } from "../astro";
import { layoutMetrics, palette, spacing } from "../theme";
import type { Kundali, Language, Relation } from "../types";
import { displayName } from "../l10n";

export function MemberDetailScreen({ memberId, onBack }: { memberId: string; onBack: () => void }) {
  const app = useAppState();
  const member = app.family.find((candidate) => candidate.id === memberId);

  if (!member) {
    return (
      <ScrollScreen topInset={8}>
        <DetailHeader title={app.language === "ne" ? "सदस्य भेटिएन" : "Member not found"} onBack={onBack} />
      </ScrollScreen>
    );
  }

  if (!member.kundali) {
    return (
      <ScrollScreen topInset={8} contentGap={spacing.lg}>
        <DetailHeader title={displayName(member.name, app.language)} onBack={onBack} />
        <View style={{ alignItems: "center", gap: spacing.md, paddingTop: 72 }}>
          <AppIcon name="profile" size={52} color={palette.templeGold} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24, textAlign: "center" }}>
            {app.language === "ne" ? "जन्म विवरण चाहिन्छ" : "Birth details are required"}
          </SerifText>
          <AppText style={{ color: palette.inkSecondary, fontSize: 16, lineHeight: 24, textAlign: "center", maxWidth: 300 }}>
            {app.language === "ne"
              ? "सुरक्षित जन्म मिति, समय र स्थान बिना कुण्डली देखाइँदैन।"
              : "A kundali is not shown until a saved birth date, time, and place are available."}
          </AppText>
        </View>
      </ScrollScreen>
    );
  }

  const kundali = member.kundali;
  const nakshatra = app.language === "ne" ? nakshatrasNE[kundali.moonNakshatraIndex] : nakshatrasEN[kundali.moonNakshatraIndex];
  return (
    <ScrollScreen topInset={8} bottomInset={96} contentGap={20}>
      <DetailHeader title={app.language === "ne" ? "कुण्डली" : "Kundali"} onBack={onBack} />

      <View style={{ alignItems: "center", gap: 7, paddingTop: 4 }}>
        <RashiMark rashi={kundali.moonRashi} size={84} />
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30, textAlign: "center" }}>{displayName(member.name, app.language)}</SerifText>
        <AppText style={{ color: palette.templeGold, fontSize: 15 }}>{relationLabel(member.relation, app.language)}</AppText>
      </View>

      <View style={{ flexDirection: "row", gap: 10 }}>
        <Triad label={app.language === "ne" ? "लग्न" : "Lagna"} value={rashiName(kundali.lagna, app.language)} />
        <Triad label={app.language === "ne" ? "राशि" : "Rashi"} value={rashiName(kundali.moonRashi, app.language)} />
        <Triad label={app.language === "ne" ? "नक्षत्र" : "Nakshatra"} value={nakshatra} />
      </View>

      <View style={{ gap: 12 }}>
        <SectionLabel>{app.language === "ne" ? "कुण्डली" : "Kundali"}</SectionLabel>
        <NorthIndianChart kundali={kundali} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "व्यक्तित्व" : "Personality"}</SectionLabel>
        <SerifText style={{ fontFamily: "Fraunces-Medium", fontSize: 16, lineHeight: 26 }}>
          {personalityReading(kundali, nakshatra, app.language)}
        </SerifText>
      </View>

      <View style={{ gap: 12 }}>
        <SectionLabel>{app.language === "ne" ? "दशा समयरेखा" : "Dasha timeline"}</SectionLabel>
        <DashaTimeline kundali={kundali} language={app.language} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "गुण र शुभ वस्तुहरू" : "Guna & Lucky things"}</SectionLabel>
        <GunaRows kundali={kundali} language={app.language} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "जन्म विवरण" : "Birth details"}</SectionLabel>
        {member.birth ? (
          <>
            <InfoRow label={app.language === "ne" ? "मिति" : "Date"} value={`${member.birth.year}-${two(member.birth.month)}-${two(member.birth.day)}`} />
            <Hairline />
            <InfoRow
              label={app.language === "ne" ? "समय" : "Time"}
              value={member.birth.timeKnown ? `${two(member.birth.hour)}:${two(member.birth.minute)}` : (app.language === "ne" ? "थाहा छैन" : "Unknown")}
            />
            <Hairline />
            <InfoRow label={app.language === "ne" ? "स्थान" : "Place"} value={app.language === "ne" ? member.birth.place.nameNE : member.birth.place.name} />
          </>
        ) : null}
        <AppText style={{ color: palette.inkSecondary, fontSize: 13, lineHeight: 19, paddingTop: 4 }}>
          {app.language === "ne" ? "यो सार सुरक्षित जन्म विवरणबाट गणना गरिएको हो।" : "This summary is calculated from the saved birth details."}
        </AppText>
      </View>
    </ScrollScreen>
  );
}

function DetailHeader({ title, onBack }: { title: string; onBack: () => void }) {
  return (
    <View style={{ minHeight: 48, flexDirection: "row", alignItems: "center", gap: 8 }}>
      <PressableScale accessibilityLabel="Back" onPress={onBack} style={{ width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center", justifyContent: "center", marginLeft: -12 }}>
        <AppIcon name="chevron-left" size={21} color={palette.saffron} />
      </PressableScale>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30, flex: 1 }}>{title}</SerifText>
    </View>
  );
}

function Triad({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flex: 1, minHeight: 68, alignItems: "center", justifyContent: "center", gap: 4 }}>
      <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontFamily: "Inter-SemiBold", fontSize: 11, textTransform: "uppercase" }}>{label}</AppText>
      <SerifText numberOfLines={1} adjustsFontSizeToFit style={{ color: palette.sindoor, fontFamily: "Fraunces-Bold", fontSize: 16, textAlign: "center" }}>{value}</SerifText>
    </View>
  );
}

function NorthIndianChart({ kundali }: { kundali: Kundali }) {
  const placements = chartPlacements(kundali);
  return (
    <View style={{ width: "100%", aspectRatio: 1, borderRadius: 4, overflow: "hidden", backgroundColor: palette.bgElevated, padding: 8 }}>
      <Svg width="100%" height="100%" viewBox="0 0 300 300" accessibilityLabel="North Indian kundali chart">
        <Rect x="1" y="1" width="298" height="298" fill="none" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="0" y1="0" x2="300" y2="300" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="300" y1="0" x2="0" y2="300" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="150" y1="0" x2="300" y2="150" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="300" y1="150" x2="150" y2="300" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="150" y1="300" x2="0" y2="150" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        <Line x1="0" y1="150" x2="150" y2="0" stroke={palette.templeGold} strokeOpacity={0.7} strokeWidth="1.2" />
        {HOUSE_CENTERS.map((center, house) => (
          <React.Fragment key={house}>
            <SvgText x={center.x} y={center.y - 5} textAnchor="middle" fontFamily="Fraunces-Medium" fontSize="10" fill={palette.inkSecondary}>
              {((rashiOrder.indexOf(kundali.lagna) + house) % 12) + 1}
            </SvgText>
            <SvgText x={center.x} y={center.y + 11} textAnchor="middle" fontFamily="Fraunces-SemiBold" fontSize="13" fill={palette.sindoor}>
              {placements[house]}
            </SvgText>
          </React.Fragment>
        ))}
      </Svg>
    </View>
  );
}

const HOUSE_CENTERS = [
  { x: 150, y: 75 }, { x: 75, y: 30 }, { x: 30, y: 75 }, { x: 75, y: 150 },
  { x: 30, y: 225 }, { x: 75, y: 270 }, { x: 150, y: 225 }, { x: 225, y: 270 },
  { x: 270, y: 225 }, { x: 225, y: 150 }, { x: 270, y: 75 }, { x: 225, y: 30 }
];

function chartPlacements(kundali: Kundali) {
  const values = Array.from({ length: 12 }, () => "");
  const lagnaIndex = rashiOrder.indexOf(kundali.lagna);
  const place = (rashi: Kundali["lagna"], label: string) => {
    const house = (rashiOrder.indexOf(rashi) - lagnaIndex + 12) % 12;
    values[house] = values[house] ? `${values[house]} ${label}` : label;
  };
  place(kundali.lagna, "La");
  place(kundali.moonRashi, "Mo");
  place(kundali.sunRashi, "Su");
  return values;
}

const DASHA_ORDER = ["Ketu", "Venus", "Sun", "Moon", "Mars", "Rahu", "Jupiter", "Saturn", "Mercury"] as const;
const DASHA_YEARS = [7, 20, 6, 10, 7, 18, 16, 19, 17] as const;
const DASHA_NE = ["केतु", "शुक्र", "सूर्य", "चन्द्र", "मंगल", "राहु", "बृहस्पति", "शनि", "बुध"] as const;

function DashaTimeline({ kundali, language }: { kundali: Kundali; language: Language }) {
  const nowJD = Date.now() / 86_400_000 + 2_440_587.5;
  const startIndex = kundali.moonNakshatraIndex % DASHA_ORDER.length;
  let cursor = kundali.birthJD;
  const periods = Array.from({ length: 9 }, (_, offset) => {
    const index = (startIndex + offset) % DASHA_ORDER.length;
    const years = offset === 0 ? DASHA_YEARS[index] * (1 - kundali.moonNakshatraFraction) : DASHA_YEARS[index];
    const start = cursor;
    const end = start + years * 365.25;
    cursor = end;
    return { index, start, end };
  });
  return periods.map((period, index) => {
    const current = nowJD >= period.start && nowJD < period.end;
    return (
      <React.Fragment key={`${period.index}-${period.start}`}>
        <View style={{ minHeight: 38, flexDirection: "row", alignItems: "center", gap: 11 }}>
          <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: current ? palette.saffron : `${palette.templeGold}59` }} />
          <SerifText style={{ flex: 1, color: current ? palette.sindoor : palette.inkPrimary, fontFamily: current ? "Fraunces-SemiBold" : "Fraunces-Medium", fontSize: 16 }}>
            {language === "ne" ? DASHA_NE[period.index] : DASHA_ORDER[period.index]}
          </SerifText>
          <AppText style={{ color: palette.inkSecondary, fontSize: 13 }}>{`${jdYear(period.start)} – ${jdYear(period.end)}`}</AppText>
        </View>
        {index < periods.length - 1 ? <Hairline /> : null}
      </React.Fragment>
    );
  });
}

function jdYear(jd: number) {
  return new Date((jd - 2_440_587.5) * 86_400_000).getFullYear();
}

type Guna = { element: [string, string]; gemstone: [string, string]; colors: [string, string]; numbers: string; day: [string, string]; deity: [string, string]; nature: [string, string] };
const GUNA: Record<Kundali["moonRashi"], Guna> = {
  mesh: { element: ["Fire", "अग्नि"], gemstone: ["Red Coral", "रातो मूगा"], colors: ["Red, Saffron", "रातो, केसरी"], numbers: "9, 1", day: ["Tuesday", "मङ्गलबार"], deity: ["Hanuman", "हनुमान"], nature: ["Courageous and pioneering — a natural leader who acts first and inspires others. Guard against haste and a quick temper.", "साहसी र अग्रगामी — स्वाभाविक नेतृत्व गर्ने। हतार र रिसबाट भने जोगिनुहोस्।"] },
  vrish: { element: ["Earth", "पृथ्वी"], gemstone: ["Diamond / Opal", "हीरा / ओपल"], colors: ["White, Cream, Green", "सेतो, क्रीम, हरियो"], numbers: "6, 2", day: ["Friday", "शुक्रबार"], deity: ["Lakshmi", "लक्ष्मी"], nature: ["Steady, loyal and fond of beauty and comfort. Builds wealth patiently. Watch for stubbornness.", "स्थिर, वफादार र सौन्दर्यप्रेमी। धैर्यपूर्वक सम्पत्ति जोड्ने। जिद्दीपनबाट सचेत रहनुहोस्।"] },
  mithun: { element: ["Air", "वायु"], gemstone: ["Emerald", "पन्ना"], colors: ["Green, Light Yellow", "हरियो, हल्का पहेंलो"], numbers: "5, 3", day: ["Wednesday", "बुधबार"], deity: ["Saraswati", "सरस्वती"], nature: ["Witty, curious and expressive — a gifted communicator. Learn to finish what you start.", "हाजिरजवाफ, जिज्ञासु र अभिव्यक्तिशील। सुरु गरेको काम पूरा गर्न सिक्नुहोस्।"] },
  karkat: { element: ["Water", "जल"], gemstone: ["Pearl", "मोती"], colors: ["White, Silver, Sea Blue", "सेतो, चाँदी, समुद्री नीलो"], numbers: "2, 7", day: ["Monday", "सोमबार"], deity: ["Shiva", "शिव"], nature: ["Tender-hearted and deeply devoted to family — the home is your temple. Protect your sensitive heart.", "कोमल हृदयको र परिवारप्रति समर्पित — घर नै तपाईंको मन्दिर हो। संवेदनशील मनको ख्याल राख्नुहोस्।"] },
  simha: { element: ["Fire", "अग्नि"], gemstone: ["Ruby", "माणिक"], colors: ["Gold, Orange, Copper", "सुनौलो, सुन्तला, तामा"], numbers: "1, 4", day: ["Sunday", "आइतबार"], deity: ["Surya", "सूर्य"], nature: ["Regal, generous and warm like the midday sun. Born to lead — soften pride with humility.", "राजसी, उदार र घामजस्तै न्यानो। नेतृत्वका लागि जन्मेको — अभिमानलाई विनम्रताले नरम बनाउनुहोस्।"] },
  kanya: { element: ["Earth", "पृथ्वी"], gemstone: ["Emerald", "पन्ना"], colors: ["Green, White", "हरियो, सेतो"], numbers: "5, 6", day: ["Wednesday", "बुधबार"], deity: ["Ganesh", "गणेश"], nature: ["Precise, service-minded and quietly brilliant. Healing hands. Do not let worry cloud your gifts.", "सूक्ष्म, सेवाभावी र शान्त प्रतिभाशाली। चिन्ताले प्रतिभा नछोपोस्।"] },
  tula: { element: ["Air", "वायु"], gemstone: ["Diamond", "हीरा"], colors: ["White, Light Blue, Pink", "सेतो, हल्का नीलो, गुलाबी"], numbers: "6, 9", day: ["Friday", "शुक्रबार"], deity: ["Lakshmi", "लक्ष्मी"], nature: ["Graceful peace-maker with a fine eye for harmony and justice. Decide with the heart once the mind has weighed.", "सन्तुलन र न्यायप्रेमी, शान्ति स्थापना गर्ने। मनले तौलेपछि हृदयले निर्णय गर्नुहोस्।"] },
  vrischik: { element: ["Water", "जल"], gemstone: ["Red Coral", "रातो मूगा"], colors: ["Deep Red, Maroon", "गाढा रातो, मरून"], numbers: "9, 8", day: ["Tuesday", "मङ्गलबार"], deity: ["Hanuman", "हनुमान"], nature: ["Intense, magnetic and unbreakably determined. Deep intuition. Transform, never merely react.", "तीव्र, आकर्षक र अटल संकल्पको। गहिरो अन्तर्ज्ञान छ। प्रतिक्रिया होइन, रूपान्तरण गर्नुहोस्।"] },
  dhanu: { element: ["Fire", "अग्नि"], gemstone: ["Yellow Sapphire", "पुखराज"], colors: ["Yellow, Saffron", "पहेंलो, केसरी"], numbers: "3, 9", day: ["Thursday", "बिहीबार"], deity: ["Vishnu", "विष्णु"], nature: ["Optimistic seeker of truth — a teacher and traveler at heart. Aim the arrow before you release it.", "आशावादी सत्यखोजी — मनैदेखि शिक्षक र यात्री। वाण छोड्नु अघि निशाना ठीक पार्नुहोस्।"] },
  makar: { element: ["Earth", "पृथ्वी"], gemstone: ["Blue Sapphire", "नीलम"], colors: ["Dark Blue, Black, Grey", "गाढा नीलो, कालो, खैरो"], numbers: "8, 6", day: ["Saturday", "शनिबार"], deity: ["Shani Dev", "शनि देव"], nature: ["Disciplined mountain-climber — patient, responsible, built for the long game. Rest is also duty.", "अनुशासित र धैर्यवान् — लामो यात्राका लागि बनेको। आराम पनि कर्तव्य हो।"] },
  kumbha: { element: ["Air", "वायु"], gemstone: ["Blue Sapphire", "नीलम"], colors: ["Blue, Violet", "नीलो, बैजनी"], numbers: "8, 4", day: ["Saturday", "शनिबार"], deity: ["Shani Dev", "शनि देव"], nature: ["Visionary humanitarian — sees tomorrow before others do. Keep one foot on today's ground.", "दूरदर्शी र परोपकारी — अरूभन्दा पहिले भोलि देख्ने। एक खुट्टा आजको धरातलमा राख्नुहोस्।"] },
  meen: { element: ["Water", "जल"], gemstone: ["Yellow Sapphire", "पुखराज"], colors: ["Yellow, Sea Green", "पहेंलो, समुद्री हरियो"], numbers: "3, 7", day: ["Thursday", "बिहीबार"], deity: ["Vishnu", "विष्णु"], nature: ["Compassionate dreamer swimming between two worlds — art and spirit flow through you. Anchor with daily practice.", "करुणामयी स्वप्नद्रष्टा — कला र अध्यात्म तपाईंभित्र बग्छ। दैनिक साधनाले स्थिर रहनुहोस्।"] }
};

function personalityReading(kundali: Kundali, nakshatra: string, language: Language) {
  const g = GUNA[kundali.moonRashi];
  if (language === "ne") return `${rashiName(kundali.moonRashi, language)} राशि, ${nakshatra} नक्षत्र (पद ${kundali.moonNakshatraPada}), ${rashiName(kundali.lagna, language)} लग्न। ${g.nature[1]} स्वामी ग्रह ${rashiMeta[kundali.moonRashi].lord} हुनुहुन्छ; ${g.day[1]} विशेष शुभ रहन्छ।`;
  return `Moon in ${rashiName(kundali.moonRashi, language)} rashi, ${nakshatra} nakshatra (pada ${kundali.moonNakshatraPada}), with ${rashiName(kundali.lagna, language)} rising. ${g.nature[0]} The ruling planet is ${rashiMeta[kundali.moonRashi].lord}, and ${g.day[0]} carries special blessing.`;
}

function GunaRows({ kundali, language }: { kundali: Kundali; language: Language }) {
  const g = GUNA[kundali.moonRashi];
  const side = language === "ne" ? 1 : 0;
  const rows = [
    [language === "ne" ? "तत्व" : "Element", g.element[side]],
    [language === "ne" ? "स्वामी" : "Lord", rashiMeta[kundali.moonRashi].lord],
    [language === "ne" ? "रत्न" : "Gemstone", g.gemstone[side]],
    [language === "ne" ? "शुभ रंग" : "Lucky color", g.colors[side]],
    [language === "ne" ? "शुभ अंक" : "Lucky number", g.numbers],
    [language === "ne" ? "शुभ दिन" : "Lucky day", g.day[side]],
    [language === "ne" ? "देवता" : "Deity", g.deity[side]]
  ];
  return rows.map(([label, value], index) => (
    <React.Fragment key={label}>
      <InfoRow label={label} value={value} />
      {index < rows.length - 1 ? <Hairline /> : null}
    </React.Fragment>
  ));
}

function rashiName(rashi: Kundali["lagna"], language: Language) {
  return language === "ne" ? rashiMeta[rashi].ne : rashiMeta[rashi].short;
}

const relations: Record<Relation, Record<Language, string>> = {
  selfMember: { en: "You", ne: "तपाईं" }, father: { en: "Father", ne: "बुबा" }, mother: { en: "Mother", ne: "आमा" },
  husband: { en: "Husband", ne: "श्रीमान्" }, wife: { en: "Wife", ne: "श्रीमती" }, son: { en: "Son", ne: "छोरा" },
  daughter: { en: "Daughter", ne: "छोरी" }, brother: { en: "Brother", ne: "दाजु/भाइ" }, sister: { en: "Sister", ne: "दिदी/बहिनी" },
  cousin: { en: "Cousin", ne: "दाजुभाइ/दिदीबहिनी" }, boyfriend: { en: "Boyfriend", ne: "प्रेमी" },
  girlfriend: { en: "Girlfriend", ne: "प्रेमिका" }, partner: { en: "Partner", ne: "साथी" },
  fiance: { en: "Fiance", ne: "मंगेतर" }, fiancee: { en: "Fiancee", ne: "मंगेतर" },
  friend: { en: "Friend", ne: "मित्र" }, colleague: { en: "Colleague", ne: "सहकर्मी" },
  mentor: { en: "Mentor", ne: "मार्गदर्शक" }
};

function relationLabel(relation: Relation, language: Language) {
  return relations[relation][language];
}

function two(value: number) {
  return String(value).padStart(2, "0");
}
