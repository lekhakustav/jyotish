export type Language = "en" | "ne";
export type ThemeChoice = "system" | "light" | "dark";
export type Gender = "male" | "female" | "other";
export type Relation = "selfMember" | "father" | "mother" | "husband" | "wife" | "son" | "daughter" | "brother" | "sister" | "cousin"
  | "boyfriend" | "girlfriend" | "partner" | "fiance" | "fiancee" | "friend" | "colleague" | "mentor";
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
  authProvider?: "google" | "email" | "demo";
  supabaseUserId?: string;
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
  suggestedReplies?: string[];
};

export type ChatConversation = {
  id: string;
  title: string;
  messages: ChatMessage[];
  createdAt: string;
  updatedAt: string;
};

export type Household = {
  schemaVersion: 2;
  account?: UserAccount;
  family: FamilyMember[];
  events: PatroEvent[];
  /**
   * Compatibility mirror of the active conversation. New code should prefer
   * `conversations`, but retaining this field lets older UI code and stored
   * schema-v1 households continue to work during the native parity migration.
   */
  chat: ChatMessage[];
  conversations: ChatConversation[];
  activeConversationId?: string;
  selectedMemberId?: string;
  language: Language;
  theme: ThemeChoice;
};

export type RashifalPeriod = "daily" | "weekly" | "monthly" | "yearly";
export type RashifalDomain = "career" | "family" | "health" | "wealth" | "love";
export type RashifalScore = 1 | 2 | 3 | 4 | 5;

export type AppTab = "home" | "rashifal" | "family";
export type AppModal = "chat" | "settings" | "patro" | "profile" | "auth" | null;
