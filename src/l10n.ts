import type { Language } from "@/types";

export const l10n: Record<string, { en: string; ne: string }> = {
  "app.name": { en: "Jyotish baje", ne: "ज्योतिष बाजे" },
  "app.tagline": { en: "Your family's pandit, in your pocket", ne: "तपाईंको परिवारको पण्डित, तपाईंकै हातमा" },
  "welcome.continue": { en: "Continue with account (demo)", ne: "खाता सहित अगाडि बढ्नुहोस् (डेमो)" },
  "tab.home": { en: "Home", ne: "गृह" },
  "tab.rashifal": { en: "Rashifal", ne: "राशिफल" },
  "tab.family": { en: "Parivar", ne: "परिवार" },
  "home.upcoming": { en: "Upcoming", ne: "आगामी" },
  "home.noEvents": { en: "No events yet - add one in Patro", ne: "अहिलेसम्म कुनै कार्यक्रम छैन - पात्रोमा थप्नुहोस्" },
  "home.mahadasha": { en: "Mahadasha", ne: "महादशा" },
  "home.antardasha": { en: "Antardasha", ne: "अन्तर्दशा" },
  "home.openPatro": { en: "Open Patro", ne: "पात्रो खोल्नुहोस्" },
  "home.askPandit": { en: "Ask Pandit-ji", ne: "पण्डितजीलाई सोध्नुहोस्" },
  "home.templeOfDay": { en: "Temple of the Day", ne: "आजको मन्दिर" },
  "rashifal.title": { en: "Rashifal", ne: "राशिफल" },
  "rashifal.daily": { en: "Daily", ne: "दैनिक" },
  "rashifal.weekly": { en: "Weekly", ne: "साप्ताहिक" },
  "rashifal.monthly": { en: "Monthly", ne: "मासिक" },
  "rashifal.yearly": { en: "Yearly", ne: "वार्षिक" },
  "rashifal.upaya": { en: "Upaya", ne: "उपाय" },
  "family.title": { en: "Parivar", ne: "परिवार" },
  "family.add": { en: "Add family member", ne: "परिवार सदस्य थप्नुहोस्" },
  "family.kundali": { en: "Kundali", ne: "कुण्डली" },
  "family.lagna": { en: "Lagna", ne: "लग्न" },
  "family.rashi": { en: "Rashi", ne: "राशि" },
  "family.nakshatra": { en: "Nakshatra", ne: "नक्षत्र" },
  "patro.title": { en: "Nepali Patro", ne: "नेपाली पात्रो" },
  "patro.events": { en: "Events", ne: "कार्यक्रमहरू" },
  "patro.panchanga": { en: "Panchanga", ne: "पञ्चाङ्ग" },
  "chat.title": { en: "Pandit-ji", ne: "पण्डितजी" },
  "chat.placeholder": { en: "Ask Pandit-ji...", ne: "पण्डितजीलाई सोध्नुहोस्..." },
  "chat.listening": { en: "Listening...", ne: "सुन्दै..." },
  "chat.speak": { en: "Speak replies", ne: "उत्तर बोल्ने" },
  "settings.title": { en: "Settings", ne: "सेटिङ" },
  "settings.language": { en: "Language", ne: "भाषा" },
  "settings.theme": { en: "Appearance", ne: "रूप" },
  "settings.signOut": { en: "Sign out", ne: "साइन आउट" },
  "profile.title": { en: "Birth Details", ne: "जन्म विवरण" },
  "profile.compute": { en: "Create my kundali", ne: "मेरो कुण्डली बनाउनुहोस्" }
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
