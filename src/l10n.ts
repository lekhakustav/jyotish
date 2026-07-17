import type { Language } from "@/types";

export const l10n: Record<string, { en: string; ne: string }> = {
  "app.name": { en: "Jyotish baje", ne: "ज्योतिष बाजे" },
  "app.tagline": { en: "Your family's Kundli, in one private place", ne: "तपाईंको परिवारको कुण्डली, एकै निजी ठाउँमा" },
  "welcome.continue": { en: "Continue with account (demo)", ne: "खाता सहित अगाडि बढ्नुहोस् (डेमो)" },
  "tab.home": { en: "Religious", ne: "धार्मिक" },
  "tab.rashifal": { en: "Rashifal", ne: "राशिफल" },
  "tab.family": { en: "My Kundli & QR", ne: "मेरो कुण्डली र QR" },
  "home.upcoming": { en: "Upcoming", ne: "आगामी" },
  "home.noEvents": { en: "No events yet - add one in Patro", ne: "अहिलेसम्म कुनै कार्यक्रम छैन - पात्रोमा थप्नुहोस्" },
  "home.mahadasha": { en: "Mahadasha", ne: "महादशा" },
  "home.antardasha": { en: "Antardasha", ne: "अन्तर्दशा" },
  "home.openPatro": { en: "Open Patro", ne: "पात्रो खोल्नुहोस्" },
  "home.askPandit": { en: "Ask Jyotish Baje", ne: "ज्योतिष बाजेलाई सोध्नुहोस्" },
  "home.templeOfDay": { en: "Temple of the Day", ne: "आजको मन्दिर" },
  "rashifal.title": { en: "Rashifal", ne: "राशिफल" },
  "rashifal.daily": { en: "Daily", ne: "दैनिक" },
  "rashifal.weekly": { en: "Weekly", ne: "साप्ताहिक" },
  "rashifal.monthly": { en: "Monthly", ne: "मासिक" },
  "rashifal.yearly": { en: "Yearly", ne: "वार्षिक" },
  "rashifal.upaya": { en: "Upaya", ne: "उपाय" },
  "family.title": { en: "My Kundli & QR", ne: "मेरो कुण्डली र QR" },
  "family.add": { en: "Add family member", ne: "परिवार सदस्य थप्नुहोस्" },
  "family.kundali": { en: "Kundali", ne: "कुण्डली" },
  "family.lagna": { en: "Lagna", ne: "लग्न" },
  "family.rashi": { en: "Rashi", ne: "राशि" },
  "family.nakshatra": { en: "Nakshatra", ne: "नक्षत्र" },
  "patro.title": { en: "Nepali Patro", ne: "नेपाली पात्रो" },
  "patro.events": { en: "Events", ne: "कार्यक्रमहरू" },
  "patro.panchanga": { en: "Panchanga", ne: "पञ्चाङ्ग" },
  "chat.title": { en: "Jyotish Baje", ne: "ज्योतिष बाजे" },
  "chat.placeholder": { en: "Ask Jyotish Baje...", ne: "ज्योतिष बाजेलाई सोध्नुहोस्..." },
  "chat.listening": { en: "Listening...", ne: "सुन्दै..." },
  "chat.speak": { en: "Speak replies", ne: "उत्तर बोल्ने" },
  "settings.title": { en: "Settings", ne: "सेटिङ" },
  "settings.language": { en: "Language", ne: "भाषा" },
  "settings.theme": { en: "Appearance", ne: "रूप" },
  "settings.signOut": { en: "Sign out", ne: "साइन आउट" },
  "profile.title": { en: "Birth Details", ne: "जन्म विवरण" },
  "profile.compute": { en: "Create my kundali", ne: "मेरो कुण्डली बनाउनुहोस्" },
  "auth.title": { en: "One Last Step", ne: "अन्तिम चरण" },
  "auth.subtitle": { en: "Sign in to save your kundali", ne: "आफ्नो कुण्डली सुरक्षित गर्न साइन इन गर्नुहोस्" },
  "auth.google": { en: "Continue with Google", ne: "गुगल मार्फत अगाडि बढ्नुहोस्" },
  "auth.email": { en: "Email", ne: "इमेल" },
  "auth.password": { en: "Password", ne: "पासवर्ड" },
  "auth.signIn": { en: "Sign In", ne: "साइन इन" },
  "auth.signUp": { en: "Sign Up", ne: "साइन अप" },
  "auth.or": { en: "or", ne: "वा" },
  "auth.skip": { en: "Continue without account", ne: "खाता बिना अगाडि बढ्नुहोस्" },
  "auth.loading": { en: "Please wait...", ne: "कृपया पर्खनुहोस्..." }
};

const neDigits = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"];

export function t(key: string, language: Language): string {
  const pair = l10n[key];
  if (!pair) return key;
  return language === "ne" ? pair.ne : pair.en;
}

export function digits(value: number, language: Language): string {
  if (language !== "ne") return String(value);
  return String(value)
    .split("")
    .map((char) => {
      const n = Number(char);
      return Number.isInteger(n) ? neDigits[n] : char;
    })
    .join("");
}

const knownNepaliNames: Record<string, string> = {
  aarav: "आरव", priya: "प्रिया", sita: "सीता", sharma: "शर्मा", maya: "माया",
  ram: "राम", rama: "रमा", gita: "गीता", geeta: "गीता", krishna: "कृष्ण",
  hari: "हरि", laxmi: "लक्ष्मी", lakshmi: "लक्ष्मी", sarita: "सरिता",
  sunita: "सुनिता", anita: "अनिता", roshan: "रोशन", suman: "सुमन",
  bikash: "विकास", vikas: "विकास", dipak: "दीपक", deepak: "दीपक",
  rajesh: "राजेश", ramesh: "रमेश", suresh: "सुरेश", mahesh: "महेश",
  ganesh: "गणेश", dinesh: "दिनेश", anil: "अनिल", sunil: "सुनील",
  manish: "मनीष", nisha: "निशा", asha: "आशा", usha: "उषा",
  pooja: "पूजा", puja: "पूजा", anjali: "अञ्जली", sanjay: "सञ्जय",
  bijay: "विजय", vijay: "विजय"
};

const fallbackLetters: Record<string, string> = {
  a: "अ", b: "ब", c: "क", d: "द", e: "ए", f: "फ", g: "ग", h: "ह", i: "इ",
  j: "ज", k: "क", l: "ल", m: "म", n: "न", o: "ओ", p: "प", q: "क", r: "र",
  s: "स", t: "त", u: "उ", v: "व", w: "व", x: "क्स", y: "य", z: "ज"
};

/** Keeps stored names untouched while preventing Latin text in Nepali UI. */
export function displayName(value: string, language: Language): string {
  if (language !== "ne" || !/[A-Za-z]/.test(value)) return value;
  return value.split(/(\s+)/).map((part) => {
    if (/^\s+$/.test(part)) return part;
    const leading = part.match(/^\P{L}*/u)?.[0] || "";
    const trailing = part.match(/\P{L}*$/u)?.[0] || "";
    const word = part.slice(leading.length, part.length - trailing.length).toLowerCase();
    const translated = knownNepaliNames[word] || [...word].map((letter) => fallbackLetters[letter] || "").join("");
    return `${leading}${translated || "नाम"}${trailing}`;
  }).join("");
}
