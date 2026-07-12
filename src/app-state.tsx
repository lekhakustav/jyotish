import * as SecureStore from "expo-secure-store";
import React from "react";
import { useColorScheme } from "react-native";
import { demoEvents, demoFamily, localPanditReply, recomputeMember, uuid } from "@/astro";
import { signInWithGoogle, signInWithEmail, signUpWithEmail, signOutSupabase, supabase } from "@/supabase";
import type { AppModal, AppTab, ChatMessage, FamilyMember, Household, Language, PatroEvent, ThemeChoice, UserAccount } from "@/types";
import { applyPalette } from "@/theme";

type AppContextValue = {
  account?: UserAccount;
  family: FamilyMember[];
  events: PatroEvent[];
  chat: ChatMessage[];
  language: Language;
  theme: ThemeChoice;
  selectedTab: AppTab;
  modal: AppModal;
  isTyping: boolean;
  syncStatus?: string;
  signInDemo: () => void;
  signInGoogle: () => Promise<void>;
  signInEmail: (email: string, password: string) => Promise<void>;
  signUpEmail: (email: string, password: string) => Promise<void>;
  skipAuth: () => void;
  signOut: () => void;
  setLanguage: (language: Language) => void;
  setTheme: (theme: ThemeChoice) => void;
  setSelectedTab: (tab: AppTab) => void;
  openModal: (modal: AppModal) => void;
  closeModal: () => void;
  saveSelf: (name: string) => void;
  addMember: (member: FamilyMember) => void;
  addEvent: (event: PatroEvent) => void;
  sendChat: (text: string) => Promise<void>;
};

const storageKey = "jyotish.household.v1";
const AppContext = React.createContext<AppContextValue | undefined>(undefined);

function initialHousehold(): Household {
  return { schemaVersion: 1, family: [], events: [], chat: [], language: "ne", theme: "system" };
}

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const systemScheme = useColorScheme();
  const [household, setHousehold] = React.useState<Household>(initialHousehold);
  const [selectedTab, setSelectedTab] = React.useState<AppTab>("home");
  const [modal, setModal] = React.useState<AppModal>(null);
  const [isReady, setIsReady] = React.useState(false);
  const [isTyping, setIsTyping] = React.useState(false);
  const [syncStatus, setSyncStatus] = React.useState<string | undefined>();

  const isDark = household.theme === "dark" || (household.theme === "system" && systemScheme === "dark");
  applyPalette(isDark);

  React.useEffect(() => {
    SecureStore.getItemAsync(storageKey)
      .then((raw) => {
        if (raw) setHousehold(JSON.parse(raw) as Household);
      })
      .catch((error: unknown) => setSyncStatus(error instanceof Error ? error.message : "Could not load local household"))
      .finally(() => setIsReady(true));
  }, []);

  React.useEffect(() => {
    if (!isReady) return;
    const id = setTimeout(() => {
      SecureStore.setItemAsync(storageKey, JSON.stringify(household)).catch((error: unknown) =>
        setSyncStatus(error instanceof Error ? error.message : "Could not save local household")
      );
    }, 350);
    return () => clearTimeout(id);
  }, [household, isReady]);

  const updateHousehold = React.useCallback((updater: (current: Household) => Household) => {
    setHousehold((current) => updater(current));
  }, []);

  const streamAssistantMessage = React.useCallback((id: string, answer: string) => {
    setIsTyping(true);
    let index = 0;
    // A calm 30fps cadence avoids the jagged one-character jumps while keeping
    // long answers bounded to a small number of React/layout commits.
    const charactersPerCommit = Math.max(2, Math.ceil(answer.length / 48));
    return new Promise<void>((resolve) => {
      const timer = setInterval(() => {
        index = Math.min(answer.length, index + charactersPerCommit);
        setHousehold((current) => ({
          ...current,
          chat: current.chat.map((message) => (message.id === id ? { ...message, text: answer.slice(0, index) } : message))
        }));
        if (index >= answer.length) {
          clearInterval(timer);
          setIsTyping(false);
          resolve();
        }
      }, 33);
    });
  }, []);

  const signInDemo = React.useCallback(() => {
    updateHousehold((current) => ({
      ...current,
      account: { id: uuid(), displayName: "Sita Sharma", isDemo: true, authProvider: "demo" },
      family: demoFamily(),
      events: demoEvents()
    }));
  }, [updateHousehold]);

  const signInGoogle = React.useCallback(async () => {
    const session = await signInWithGoogle();
    if (session) {
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "google", supabaseUserId: session.user.id } : { id: uuid(), displayName: session.user.email?.split("@")[0] || "User", isDemo: false, authProvider: "google", supabaseUserId: session.user.id }
      }));
    }
  }, [updateHousehold]);

  const signInEmail = React.useCallback(async (email: string, password: string) => {
    const session = await signInWithEmail(email, password);
    if (session) {
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "email", supabaseUserId: session.user.id } : { id: uuid(), displayName: session.user.email?.split("@")[0] || "User", isDemo: false, authProvider: "email", supabaseUserId: session.user.id }
      }));
    }
  }, [updateHousehold]);

  const signUpEmail = React.useCallback(async (email: string, password: string) => {
    const data = await signUpWithEmail(email, password);
    const user = data.user;
    if (user) {
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "email", supabaseUserId: user.id } : { id: uuid(), displayName: user.email?.split("@")[0] || "User", isDemo: false, authProvider: "email", supabaseUserId: user.id }
      }));
    }
  }, [updateHousehold]);

  const skipAuth = React.useCallback(() => {
    updateHousehold((current) => ({
      ...current,
      account: current.account ? { ...current.account, authProvider: "demo" } : { id: uuid(), displayName: "User", isDemo: true, authProvider: "demo" }
    }));
  }, [updateHousehold]);

  const signOut = React.useCallback(() => {
    signOutSupabase().catch(() => undefined);
    setHousehold(initialHousehold());
    setSelectedTab("home");
    setModal(null);
  }, []);

  const setLanguage = React.useCallback((language: Language) => {
    updateHousehold((current) => ({ ...current, language }));
  }, [updateHousehold]);

  const setTheme = React.useCallback((theme: ThemeChoice) => {
    updateHousehold((current) => ({ ...current, theme }));
  }, [updateHousehold]);

  const saveSelf = React.useCallback((name: string) => {
    updateHousehold((current) => {
      const existing = current.family.find((member) => member.relation === "selfMember") ?? demoFamily()[0];
      const self = recomputeMember({ ...existing, name });
      const family = current.family.some((member) => member.relation === "selfMember")
        ? current.family.map((member) => (member.relation === "selfMember" ? self : member))
        : [self, ...current.family];
      return {
        ...current,
        account: current.account ? { ...current.account, displayName: name } : { id: uuid(), displayName: name, isDemo: true },
        family
      };
    });
  }, [updateHousehold]);

  const addMember = React.useCallback((member: FamilyMember) => {
    updateHousehold((current) => ({ ...current, family: [...current.family, recomputeMember(member)] }));
  }, [updateHousehold]);

  const addEvent = React.useCallback((event: PatroEvent) => {
    updateHousehold((current) => ({ ...current, events: [...current.events, event] }));
  }, [updateHousehold]);

  const sendChat = React.useCallback(async (text: string) => {
    const trimmed = text.trim();
    if (!trimmed || isTyping) return;
    const userMessage: ChatMessage = { id: uuid(), isUser: true, text: trimmed, timestamp: new Date().toISOString() };
    const assistantID = uuid();
    const assistantMessage: ChatMessage = { id: assistantID, isUser: false, text: "", timestamp: new Date().toISOString() };
    let familySnapshot: FamilyMember[] = [];
    let languageSnapshot: Language = "en";
    setHousehold((current) => {
      familySnapshot = current.family;
      languageSnapshot = current.language;
      return { ...current, chat: [...current.chat, userMessage, assistantMessage] };
    });

    const localAnswer = localPanditReply(trimmed, familySnapshot, languageSnapshot);
    const endpoint = process.env.EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL || process.env.JYOTISH_AGENT_ENDPOINT_URL;
    let answer = localAnswer;
    if (endpoint) {
      try {
        const response = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            language: languageSnapshot,
            message: trimmed,
            family: familySnapshot,
            chatHistory: household.chat.slice(-16),
            localFallbackReply: localAnswer
          })
        });
        if (response.ok) {
          const data = (await response.json()) as { reply?: string };
          answer = data.reply?.trim() || localAnswer;
          setSyncStatus(undefined);
        } else {
          setSyncStatus("Jyotish Baje backend unavailable; using local reading.");
        }
      } catch {
        setSyncStatus("Jyotish Baje backend unavailable; using local reading.");
      }
    }
    await streamAssistantMessage(assistantID, answer);
  }, [household.chat, isTyping, streamAssistantMessage]);

  const value = React.useMemo<AppContextValue>(() => ({
    account: household.account,
    family: household.family,
    events: household.events,
    chat: household.chat,
    language: household.language,
    theme: household.theme,
    selectedTab,
    modal,
    isTyping,
    syncStatus,
    signInDemo,
    signInGoogle,
    signInEmail,
    signUpEmail,
    skipAuth,
    signOut,
    setLanguage,
    setTheme,
    setSelectedTab,
    openModal: setModal,
    closeModal: () => setModal(null),
    saveSelf,
    addMember,
    addEvent,
    sendChat
  }), [household, selectedTab, modal, isTyping, syncStatus, signInDemo, signInGoogle, signInEmail, signUpEmail, skipAuth, signOut, setLanguage, setTheme, saveSelf, addMember, addEvent, sendChat]);

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useAppState() {
  const value = React.use(AppContext);
  if (!value) throw new Error("useAppState must be used inside AppStateProvider");
  return value;
}
