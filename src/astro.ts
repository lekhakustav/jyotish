import type { BirthData, BirthPlace, FamilyMember, Kundali, Language, PatroEvent, RashiKey } from "@/types";

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

export function generateRashifal(rashi: RashiKey, period: "daily" | "weekly" | "monthly" | "yearly", language: Language) {
  const now = new Date();
  const focusDate = new Date(now);
  if (period === "weekly") focusDate.setDate(now.getDate() + 3);
  if (period === "monthly") focusDate.setDate(now.getDate() + 15);
  if (period === "yearly") focusDate.setMonth(now.getMonth() + 6);
  const isoWeek = Math.ceil((((Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()) - Date.UTC(now.getFullYear(), 0, 1)) / 86400000) + new Date(now.getFullYear(), 0, 1).getUTCDay() + 1) / 7);
  const stamp = period === "daily"
    ? now.getFullYear() * 10000 + (now.getMonth() + 1) * 100 + now.getDate()
    : period === "weekly" ? now.getFullYear() * 100 + isoWeek
      : period === "monthly" ? now.getFullYear() * 100 + now.getMonth() + 1
        : now.getFullYear();
  const rand = seeded(stamp + rashiOrder.indexOf(rashi) * 97);
  const ne = language === "ne";
  const domains = ["career", "family", "health", "wealth", "love"];
  const scores = Object.fromEntries(domains.map((domain) => [domain, 58 + Math.floor(rand() * 38)]));
  const copy = {
    daily: ne
      ? ["आजको चन्द्रगतिले छोटो निर्णयमा धैर्य माग्छ।", "आज परिवारको कुरा सुन्दा लाभ हुन्छ।", "आज सानो तर स्थिर काममा ध्यान दिनुहोस्।"]
      : ["Today rewards calm decisions and steady timing.", "Today, family signals are supportive if you listen first.", "Today favors one small, disciplined task."],
    weekly: ne
      ? ["यो साता संवाद र अधुरा काम मिलाउने समय हो।", "यो साता परिवारसँग तालमेल बढाउन सकिन्छ।", "यो साताको प्रगतिका लागि नियमितता रोज्नुहोस्।"]
      : ["This week favors clearing conversations and unfinished work.", "This week supports steadier family coordination.", "Build momentum this week through a simple routine."],
    monthly: ne
      ? ["यो महिना बानी र योजना सुधार्ने समय हो।", "यो महिना खर्च र सम्बन्धमा क्रम चाहिन्छ।", "यो महिना एउटा दीर्घ लक्ष्यलाई निरन्तरता दिनुहोस्।"]
      : ["This month is for improving habits and plans.", "This month asks for order in spending and relationships.", "Give one longer goal steady attention this month."],
    yearly: ne
      ? ["यो वर्ष जिम्मेवारी र दीर्घ दिशालाई बल दिने समय हो।", "यो वर्ष धैर्यले सम्बन्ध र काममा स्थिर लाभ दिन्छ।", "यो वर्ष क्रमिक परिवर्तनलाई प्राथमिकता दिनुहोस्।"]
      : ["This year favors responsibility and long direction.", "Patience can bring steadier gains in work and relationships this year.", "Choose gradual, lasting change this year."]
  } as const;
  const advice = period === "daily"
    ? (ne ? "बिहान छोटो प्रार्थना गरेर काम सुरु गर्नुहोस्।" : "Begin important work after a short morning prayer.")
    : period === "weekly"
      ? (ne ? "एक प्राथमिकता छानेर साताभरि त्यसमा टिक्नुहोस्।" : "Choose one priority and stay with it through the week.")
      : period === "monthly"
        ? (ne ? "महिनाको योजना लेखेर खर्च र समय जाँच्नुहोस्।" : "Write a monthly plan and review time and spending.")
        : (ne ? "दीर्घ लक्ष्यलाई साना चरणमा बाँड्नुहोस्।" : "Break a long goal into smaller, steady steps.");
  return {
    text: `${copy[period][Math.floor(rand() * copy[period].length)]} ${advice}`,
    scores: scores as Record<string, number>,
    upaya: ne ? "गुरु वा बुबाआमाको आशीर्वाद लिनुहोस्।" : "Seek an elder's blessing and offer a small act of service.",
    luckyColor: ne ? "सुनौलो" : "Gold",
    luckyNumber: 1 + Math.floor(rand() * 9),
    luckyDay: period === "daily" ? (ne ? "आज" : "Today") : period === "weekly" ? (ne ? "बिहीबार" : "Thursday") : period === "monthly" ? (ne ? "महिनाको दोस्रो भाग" : "Second half") : (ne ? "वर्षको मध्य भाग" : "Mid-year"),
    timeline: period === "daily" ? (ne ? "आज" : "Today") : period === "weekly" ? (ne ? "यस साताभरि" : "This week") : period === "monthly" ? (ne ? "यस महिनाभरि" : "This month") : (ne ? "यस वर्षभरि" : "This year"),
    focusDate
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
  if (!member.birth) return member;
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
