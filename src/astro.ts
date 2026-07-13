import type {
  BirthData,
  BirthPlace,
  FamilyMember,
  Kundali,
  Language,
  PatroEvent,
  RashiKey,
  RashifalDomain,
  RashifalPeriod,
  RashifalScore
} from "@/types";

export const birthPlaces: BirthPlace[] = [
  { name: "Kathmandu", nameNE: "काठमाडौं", latitude: 27.7172, longitude: 85.324, utcOffsetHours: 5.75 },
  { name: "Pokhara", nameNE: "पोखरा", latitude: 28.2096, longitude: 83.9856, utcOffsetHours: 5.75 },
  { name: "Lalitpur", nameNE: "ललितपुर", latitude: 27.6588, longitude: 85.3247, utcOffsetHours: 5.75 },
  { name: "Biratnagar", nameNE: "विराटनगर", latitude: 26.4525, longitude: 87.2718, utcOffsetHours: 5.75 },
  { name: "Delhi, India", nameNE: "दिल्ली, भारत", latitude: 28.6139, longitude: 77.209, utcOffsetHours: 5.5 },
  { name: "New York, USA", nameNE: "न्यूयोर्क, अमेरिका", latitude: 40.7128, longitude: -74.006, utcOffsetHours: -5 }
];

export const rashiOrder: RashiKey[] = ["mesh", "vrish", "mithun", "karkat", "simha", "kanya", "tula", "vrischik", "dhanu", "makar", "kumbha", "meen"];

export const rashiMeta: Record<RashiKey, { en: string; ne: string; short: string; glyph: string; lord: string }> = {
  mesh: { en: "Mesh (Aries)", ne: "मेष", short: "Mesh", glyph: "मे", lord: "Mangal" },
  vrish: { en: "Vrish (Taurus)", ne: "वृष", short: "Vrish", glyph: "वृ", lord: "Shukra" },
  mithun: { en: "Mithun (Gemini)", ne: "मिथुन", short: "Mithun", glyph: "मि", lord: "Budha" },
  karkat: { en: "Karkat (Cancer)", ne: "कर्कट", short: "Karkat", glyph: "क", lord: "Chandra" },
  simha: { en: "Simha (Leo)", ne: "सिंह", short: "Simha", glyph: "सिं", lord: "Surya" },
  kanya: { en: "Kanya (Virgo)", ne: "कन्या", short: "Kanya", glyph: "कन्", lord: "Budha" },
  tula: { en: "Tula (Libra)", ne: "तुला", short: "Tula", glyph: "तु", lord: "Shukra" },
  vrischik: { en: "Vrischik (Scorpio)", ne: "वृश्चिक", short: "Vrischik", glyph: "वृश्", lord: "Mangal" },
  dhanu: { en: "Dhanu (Sagittarius)", ne: "धनु", short: "Dhanu", glyph: "ध", lord: "Brihaspati" },
  makar: { en: "Makar (Capricorn)", ne: "मकर", short: "Makar", glyph: "म", lord: "Shani" },
  kumbha: { en: "Kumbha (Aquarius)", ne: "कुम्भ", short: "Kumbha", glyph: "कु", lord: "Shani" },
  meen: { en: "Meen (Pisces)", ne: "मीन", short: "Meen", glyph: "मी", lord: "Brihaspati" }
};

export const nakshatrasEN = [
  "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashira", "Ardra", "Punarvasu", "Pushya", "Ashlesha",
  "Magha", "Purva Phalguni", "Uttara Phalguni", "Hasta", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshtha",
  "Mula", "Purva Ashadha", "Uttara Ashadha", "Shravana", "Dhanishta", "Shatabhisha", "Purva Bhadrapada", "Uttara Bhadrapada", "Revati"
];

export const nakshatrasNE = [
  "अश्विनी", "भरणी", "कृत्तिका", "रोहिणी", "मृगशिरा", "आर्द्रा", "पुनर्वसु", "पुष्य", "आश्लेषा",
  "मघा", "पूर्वफाल्गुनी", "उत्तरफाल्गुनी", "हस्त", "चित्रा", "स्वाति", "विशाखा", "अनुराधा", "ज्येष्ठा",
  "मूल", "पूर्वाषाढा", "उत्तराषाढा", "श्रवण", "धनिष्ठा", "शतभिषा", "पूर्वभाद्रपदा", "उत्तरभाद्रपदा", "रेवती"
];

export function uuid(): string {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
}

export function julianDay(year: number, month: number, day: number, hourUT: number): number {
  let y = year;
  let m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  const a = Math.floor(y / 100);
  const b = 2 - a + Math.floor(a / 4);
  return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524.5 + hourUT / 24;
}

function norm360(value: number): number {
  const x = value % 360;
  return x < 0 ? x + 360 : x;
}

function rashiFromLongitude(longitude: number): RashiKey {
  return rashiOrder[Math.floor(norm360(longitude) / 30)];
}

function pseudoLongitude(jd: number, rate: number, offset: number): number {
  return norm360(offset + rate * (jd - 2451545.0));
}

export function computeKundali(birth: BirthData): Kundali {
  const localHour = birth.timeKnown ? birth.hour + birth.minute / 60 : 6;
  const jd = julianDay(birth.year, birth.month, birth.day, localHour - birth.place.utcOffsetHours);
  const moon = pseudoLongitude(jd, 13.176358, 218.316);
  const sun = pseudoLongitude(jd, 0.985647, 280.466);
  const lagna = pseudoLongitude(jd, 361.0, birth.place.longitude + birth.place.latitude * 0.25);
  const nakFloat = norm360(moon) / (360 / 27);
  const nakIndex = Math.floor(nakFloat);
  const nakFraction = nakFloat - nakIndex;
  return {
    lagna: rashiFromLongitude(lagna),
    moonRashi: rashiFromLongitude(moon),
    sunRashi: rashiFromLongitude(sun),
    moonNakshatraIndex: nakIndex,
    moonNakshatraPada: Math.floor(nakFraction * 4) + 1,
    moonNakshatraFraction: nakFraction,
    birthJD: jd
  };
}

function seeded(seed: number): () => number {
  let x = seed || 1;
  return () => {
    x = (x * 1664525 + 1013904223) >>> 0;
    return x / 0xffffffff;
  };
}

function startOfLocalDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function rashifalWindow(period: RashifalPeriod, now: Date): { start: Date; end: Date; stamp: number } {
  if (period === "daily") {
    const start = startOfLocalDay(now);
    return { start, end: new Date(start.getFullYear(), start.getMonth(), start.getDate(), 23, 59, 59, 999), stamp: start.getFullYear() * 10000 + (start.getMonth() + 1) * 100 + start.getDate() };
  }
  if (period === "weekly") {
    const start = startOfLocalDay(now);
    const daysSinceMonday = (start.getDay() + 6) % 7;
    start.setDate(start.getDate() - daysSinceMonday);
    const end = new Date(start);
    end.setDate(start.getDate() + 6);
    end.setHours(23, 59, 59, 999);
    return { start, end, stamp: start.getFullYear() * 10000 + (start.getMonth() + 1) * 100 + start.getDate() };
  }
  if (period === "monthly") {
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    const end = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
    return { start, end, stamp: start.getFullYear() * 100 + start.getMonth() + 1 };
  }
  const start = new Date(now.getFullYear(), 0, 1);
  const end = new Date(now.getFullYear(), 11, 31, 23, 59, 59, 999);
  return { start, end, stamp: start.getFullYear() };
}

function formatRashifalTimeline(period: RashifalPeriod, start: Date, end: Date, language: Language): string {
  const locale = language === "ne" ? "ne-NP" : "en-US";
  if (period === "daily") return start.toLocaleDateString(locale, { weekday: "long", month: "short", day: "numeric" });
  if (period === "weekly") {
    const startLabel = start.toLocaleDateString(locale, { month: "short", day: "numeric" });
    const endLabel = end.toLocaleDateString(locale, { month: "short", day: "numeric" });
    return `${startLabel} – ${endLabel}`;
  }
  if (period === "monthly") return start.toLocaleDateString(locale, { month: "long", year: "numeric" });
  return start.toLocaleDateString(locale, { year: "numeric" });
}

export function generateRashifal(rashi: RashiKey, period: RashifalPeriod, language: Language) {
  const now = new Date();
  const window = rashifalWindow(period, now);
  const rand = seeded(window.stamp + rashiOrder.indexOf(rashi) * 97 + period.length * 1_009);
  const ne = language === "ne";
  const domains: RashifalDomain[] = ["career", "family", "health", "wealth", "love"];
  const scoreValues = domains.map(() => (1 + Math.floor(rand() * 5)) as RashifalScore);
  // A flat row of identical marks looks fabricated and hides domain nuance.
  // Deterministically nudge one value when the seeded draw happens to tie.
  if (new Set(scoreValues).size === 1) scoreValues[scoreValues.length - 1] = scoreValues[0] === 5 ? 4 : ((scoreValues[0] + 1) as RashifalScore);
  const scores = Object.fromEntries(domains.map((domain, index) => [domain, scoreValues[index]])) as Record<RashifalDomain, RashifalScore>;

  const copy: Record<RashifalPeriod, readonly string[]> = {
    daily: ne
      ? ["बिहान निर्णय स्पष्ट हुन्छ; साँझ परिवारको कुरा धैर्यपूर्वक सुन्नुहोस्।", "आज एउटा सानो काम पूरा गर्दा बाँकी दिन हल्का हुन्छ।", "आज तुरुन्त प्रतिक्रिया दिनुभन्दा एकछिन रोकिएर बोल्नु लाभदायी छ।"]
      : ["Decisions are clearer this morning; listen patiently to family this evening.", "Finishing one small task today makes the rest of the day lighter.", "Today rewards a short pause before you respond."],
    weekly: ne
      ? ["साताको सुरुमा अधुरा काम मिलाउनुहोस्; मध्यसातामा संवाद र अन्त्यतिर विश्रामलाई ठाउँ दिनुहोस्।", "यो साता एक प्राथमिकतामा टिक्दा काम र घर दुवैमा तालमेल बढ्छ।", "सोमबारको योजना बिहीबार जाँच्नुहोस् र सप्ताहान्तमा अनावश्यक बोझ छोड्नुहोस्।"]
      : ["Clear unfinished work early in the week, handle conversations midweek, and leave room to rest near the weekend.", "This week improves when one priority guides both work and home.", "Set the plan on Monday, review it Thursday, and release unnecessary load by the weekend."],
    monthly: ne
      ? ["महिनाको पहिलो भाग योजना र खर्च मिलाउन, दोस्रो भाग सम्बन्ध र दीर्घ काम अघि बढाउन उपयुक्त छ।", "यो महिना बानी सुधारमा निरन्तरता राख्दा अन्तिम सातासम्म स्पष्ट परिणाम देखिन्छ।", "एक मासिक लक्ष्य छानेर हरेक साताको सानो समीक्षा गर्नुहोस्।"]
      : ["Use the first half of the month to organize plans and spending; use the second half for relationships and longer work.", "Consistent habit changes this month should show a clearer result by the final week.", "Choose one monthly goal and review it briefly each week."],
    yearly: ne
      ? ["वर्षको पहिलो चौमासिकले आधार बनाउँछ, मध्यभागले जिम्मेवारी बढाउँछ र अन्तिम भागले स्थिर फल देखाउँछ।", "यो वर्ष छिटो परिवर्तनभन्दा क्रमिक सुधारले काम, धन र सम्बन्धमा दीर्घ लाभ दिन्छ।", "वार्षिक दिशालाई चार साना चरणमा बाँडेर प्रत्येक तीन महिनामा समीक्षा गर्नुहोस्।"]
      : ["The first quarter builds the foundation, midyear increases responsibility, and the final months reveal the steadier result.", "This year favors gradual improvement over abrupt change in work, money, and relationships.", "Divide the year's direction into four smaller stages and review it every quarter."]
  };
  const advice: Record<RashifalPeriod, string> = {
    daily: ne ? "आजको मुख्य काम बिहानै तय गर्नुहोस्।" : "Choose today's main task before the morning gets busy.",
    weekly: ne ? "एक प्राथमिकता छानेर साताभरि त्यसमा टिक्नुहोस्।" : "Choose one priority and stay with it through the week.",
    monthly: ne ? "महिनाको योजना लेखेर प्रत्येक साताको प्रगति जाँच्नुहोस्।" : "Write the monthly plan and check progress each week.",
    yearly: ne ? "दीर्घ लक्ष्यलाई त्रैमासिक चरणमा बाँड्नुहोस्।" : "Break the long goal into quarterly stages."
  };
  const upaya: Record<RashifalPeriod, string> = {
    daily: ne ? "बिहान दीप बालेर तीन मिनेट मौन बस्नुहोस्।" : "Light a lamp and sit quietly for three minutes this morning.",
    weekly: ne ? "यस साता एक दिन ज्येष्ठ व्यक्तिको सेवा गर्नुहोस्।" : "Offer one act of service to an elder this week.",
    monthly: ne ? "यस महिना एक बिहीबार अन्न दान गर्नुहोस्।" : "Donate a simple meal on one Thursday this month.",
    yearly: ne ? "वर्षभरि महिनामा एक पटक गुरु वा बुबाआमाको आशीर्वाद लिनुहोस्।" : "Seek an elder's blessing once each month this year."
  };

  return {
    period,
    text: `${copy[period][Math.floor(rand() * copy[period].length)]} ${advice[period]}`,
    scores,
    upaya: upaya[period],
    luckyColor: ne ? "सुनौलो" : "Gold",
    luckyNumber: 1 + Math.floor(rand() * 9),
    luckyDay: period === "daily" ? (ne ? "आज" : "Today") : period === "weekly" ? (ne ? "बिहीबार" : "Thursday") : period === "monthly" ? (ne ? "तेस्रो साता" : "Third week") : (ne ? "असोज–मंसिर" : "September–November"),
    timeline: formatRashifalTimeline(period, window.start, window.end, language),
    periodStart: window.start,
    periodEnd: window.end,
    focusDate: new Date((window.start.getTime() + window.end.getTime()) / 2)
  };
}

export function panchangaFor(date = new Date(), language: Language = "en") {
  const jd = julianDay(date.getFullYear(), date.getMonth() + 1, date.getDate(), 0);
  const tithi = Math.floor(norm360(pseudoLongitude(jd, 12.19, 40) - pseudoLongitude(jd, 0.985647, 280)) / 12) + 1;
  const nak = Math.floor(norm360(pseudoLongitude(jd, 13.176358, 218)) / (360 / 27));
  return {
    tithiNumber: tithi,
    tithi: language === "ne" ? `${tithi} तिथि` : `Tithi ${tithi}`,
    nakshatra: language === "ne" ? nakshatrasNE[nak] : nakshatrasEN[nak],
    yoga: language === "ne" ? "शुभ" : "Shubha",
    karana: language === "ne" ? "बव" : "Bava"
  };
}

export function todayBS() {
  const now = new Date();
  return { year: now.getFullYear() + 57, month: now.getMonth() + 1, day: now.getDate() };
}

export function recomputeMember(member: FamilyMember): FamilyMember {
  if (!member.birth) {
    // A kundali is derived data. Keeping one without its source birth record
    // makes a placeholder chart look authoritative, so remove it explicitly.
    const { kundali: _discardedKundali, ...memberWithoutKundali } = member;
    return memberWithoutKundali;
  }
  return { ...member, kundali: computeKundali(member.birth) };
}

export function demoFamily(): FamilyMember[] {
  return [
    recomputeMember({
      id: uuid(),
      name: "Sita Sharma",
      gender: "female",
      relation: "selfMember",
      birth: { year: 1962, month: 3, day: 15, hour: 7, minute: 30, timeKnown: true, place: birthPlaces[0] }
    }),
    recomputeMember({
      id: uuid(),
      name: "Aarav",
      gender: "male",
      relation: "son",
      birth: { year: 1990, month: 6, day: 15, hour: 8, minute: 30, timeKnown: true, place: birthPlaces[0] }
    }),
    recomputeMember({
      id: uuid(),
      name: "Priya",
      gender: "female",
      relation: "daughter",
      birth: { year: 1993, month: 11, day: 2, hour: 14, minute: 10, timeKnown: true, place: birthPlaces[1] }
    })
  ];
}

export function demoEvents(): PatroEvent[] {
  const bs = todayBS();
  return [
    { id: uuid(), title: "Aarav's birthday", note: "Ashirwad + kheer", bsDate: { ...bs, day: Math.min(28, bs.day + 3) }, repeatsYearly: true },
    { id: uuid(), title: "Satyanarayan Puja", note: "", bsDate: { ...bs, day: Math.min(30, bs.day + 9) }, repeatsYearly: false }
  ];
}

export function localPanditReply(message: string, family: FamilyMember[], language: Language): string {
  const self = family.find((member) => member.relation === "selfMember");
  const rashi = self?.kundali?.moonRashi ?? "mesh";
  const reading = generateRashifal(rashi, "daily", language);
  if (language === "ne") {
    return `तपाईंको ${rashiMeta[rashi].ne} राशिका आधारमा ${reading.text} ${reading.upaya} के तपाईं यसको शुभ समय वा दशासँगको सम्बन्ध पनि जान्न चाहनुहुन्छ?`;
  }
  return `For your ${rashiMeta[rashi].short} moon sign: ${reading.text} ${reading.upaya} Would you like me to connect this with your dasha or an auspicious time?`;
}
