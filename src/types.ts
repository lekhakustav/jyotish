export type Language = "en" | "ne";
export type ThemeChoice = "system" | "light" | "dark";
export type Gender = "male" | "female" | "other";
export type Relation = "selfMember" | "father" | "mother" | "husband" | "wife" | "son" | "daughter" | "brother" | "sister" | "cousin";
export type RashiKey =
  | "mesh"
  | "vrish"
  | "mithun"
  | "karkat"
  | "simha"
  | "kanya"
  | "tula"
  | "vrischik"
  | "dhanu"
  | "makar"
  | "kumbha"
  | "meen";

export type BirthPlace = {
  name: string;
  nameNE: string;
  latitude: number;
  longitude: number;
  utcOffsetHours: number;
};

export type BirthData = {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  timeKnown: boolean;
  place: BirthPlace;
};

export type Kundali = {
  lagna: RashiKey;
  moonRashi: RashiKey;
  sunRashi: RashiKey;
  moonNakshatraIndex: number;
  moonNakshatraPada: number;
  moonNakshatraFraction: number;
  birthJD: number;
};

export type FamilyMember = {
  id: string;
  name: string;
  gender: Gender;
  relation: Relation;
  birth?: BirthData;
  kundali?: Kundali;
};

export type UserAccount = {
  id: string;
  email?: string;
  displayName: string;
  isDemo: boolean;
};

export type NepaliDate = {
  year: number;
  month: number;
  day: number;
};

export type PatroEvent = {
  id: string;
  title: string;
  note: string;
  bsDate: NepaliDate;
  repeatsYearly: boolean;
};

export type ChatMessage = {
  id: string;
  isUser: boolean;
  text: string;
  timestamp: string;
};

export type Household = {
  schemaVersion: number;
  account?: UserAccount;
  family: FamilyMember[];
  events: PatroEvent[];
  chat: ChatMessage[];
  language: Language;
  theme: ThemeChoice;
};

export type AppTab = "home" | "rashifal" | "family";
export type AppModal = "chat" | "settings" | "patro" | "profile" | null;
