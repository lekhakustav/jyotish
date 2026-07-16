import * as SecureStore from "expo-secure-store";
import React from "react";
import { useColorScheme } from "react-native";
import { demoEvents, demoFamily, localPanditReply, recomputeMember, uuid } from "@/astro";
import { signInWithGoogle, signInWithEmail, signUpWithEmail, signOutSupabase, completeAuthFromParams, type AuthCallbackParams } from "@/supabase";
import type { AppModal, AppTab, BirthData, ChatConversation, ChatMessage, FamilyMember, Household, Language, PatroEvent, ThemeChoice, UserAccount } from "@/types";
import { applyPalette } from "@/theme";
import { track } from "@/analytics";
import { parseFeatureSource } from "@/features";
import { buildFeatureToolReport } from "@/jyotish-reports";

type AppContextValue = {
  account?: UserAccount;
  family: FamilyMember[];
  events: PatroEvent[];
  chat: ChatMessage[];
  conversations: ChatConversation[];
  activeConversationId?: string;
  selectedMemberId?: string;
  selectedMember?: FamilyMember;
  language: Language;
  theme: ThemeChoice;
  selectedTab: AppTab;
  modal: AppModal;
  isTyping: boolean;
  syncStatus?: string;
  pendingChatPrompt?: string;
  pendingChatSourceKey?: string;
  signInDemo: () => void;
  signInGoogle: () => Promise<void>;
  completeOAuth: (params: AuthCallbackParams) => Promise<void>;
  signInEmail: (email: string, password: string) => Promise<void>;
  signUpEmail: (email: string, password: string) => Promise<void>;
  skipAuth: () => void;
  signOut: () => void;
  setLanguage: (language: Language) => void;
  setTheme: (theme: ThemeChoice) => void;
  setSelectedTab: (tab: AppTab) => void;
  openModal: (modal: AppModal) => void;
  openPandit: (prompt?: string, sourceKey?: string) => void;
  consumePendingChatPrompt: () => void;
  consumePendingChatSourceKey: () => void;
  closeModal: () => void;
  saveSelf: (name: string, birth?: BirthData) => void;
  addMember: (member: FamilyMember) => void;
  selectMember: (memberId?: string) => void;
  addEvent: (event: PatroEvent) => void;
  newConversation: () => string;
  selectConversation: (conversationId: string) => void;
  deleteConversation: (conversationId: string) => void;
  sendChat: (text: string, sourceKey?: string) => Promise<void>;
};

const storageKey = "jyotish.household.v1";
const AppContext = React.createContext<AppContextValue | undefined>(undefined);

function initialHousehold(): Household {
  return { schemaVersion: 2, family: [], events: [], chat: [], conversations: [], language: "ne", theme: "system" };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function conversationTitle(messages: ChatMessage[], fallback: string): string {
  const firstUserMessage = messages.find((message) => message.isUser && message.text.trim());
  if (!firstUserMessage) return fallback;
  const title = firstUserMessage.text.trim().replace(/\s+/g, " ");
  return title.length > 48 ? `${title.slice(0, 47).trimEnd()}…` : title;
}

function conversationFromLegacy(messages: ChatMessage[]): ChatConversation {
  const createdAt = messages[0]?.timestamp || new Date().toISOString();
  const updatedAt = messages[messages.length - 1]?.timestamp || createdAt;
  return { id: uuid(), title: conversationTitle(messages, "Jyotish Baje"), messages, createdAt, updatedAt };
}

/** Converts schema-v1 storage without rewriting any existing entity/message IDs. */
export function migrateHousehold(value: unknown): Household {
  if (!isRecord(value)) return initialHousehold();

  const family = Array.isArray(value.family) ? value.family as FamilyMember[] : [];
  const events = Array.isArray(value.events) ? value.events as PatroEvent[] : [];
  const legacyChat = Array.isArray(value.chat) ? value.chat as ChatMessage[] : [];
  let conversations = Array.isArray(value.conversations)
    ? (value.conversations as ChatConversation[]).filter((conversation) => isRecord(conversation) && typeof conversation.id === "string" && Array.isArray(conversation.messages))
    : [];
  if (conversations.length === 0 && legacyChat.length > 0) conversations = [conversationFromLegacy(legacyChat)];

  const requestedConversationId = typeof value.activeConversationId === "string" ? value.activeConversationId : undefined;
  const activeConversation = conversations.find((conversation) => conversation.id === requestedConversationId) ?? conversations[0];
  const requestedMemberId = typeof value.selectedMemberId === "string" ? value.selectedMemberId : undefined;
  const selectedMemberId = family.some((member) => member.id === requestedMemberId) ? requestedMemberId : undefined;
  const language: Language = value.language === "en" ? "en" : "ne";
  const theme: ThemeChoice = value.theme === "light" || value.theme === "dark" ? value.theme : "system";

  return {
    schemaVersion: 2,
    account: isRecord(value.account) ? value.account as UserAccount : undefined,
    family,
    events,
    chat: activeConversation?.messages ?? legacyChat,
    conversations,
    activeConversationId: activeConversation?.id,
    selectedMemberId,
    language,
    theme
  };
}

function replaceConversationMessages(current: Household, conversationId: string, messages: ChatMessage[]): Household {
  const now = messages[messages.length - 1]?.timestamp || new Date().toISOString();
  const conversations = current.conversations.map((conversation) => conversation.id === conversationId
    ? { ...conversation, title: conversationTitle(messages, conversation.title), messages, updatedAt: now }
    : conversation);
  return {
    ...current,
    conversations,
    chat: current.activeConversationId === conversationId ? messages : current.chat
  };
}

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const systemScheme = useColorScheme();
  const [household, setHousehold] = React.useState<Household>(initialHousehold);
  const [selectedTab, setSelectedTab] = React.useState<AppTab>("home");
  const [modal, setModal] = React.useState<AppModal>(null);
  const [isReady, setIsReady] = React.useState(false);
  const [isTyping, setIsTyping] = React.useState(false);
  const [syncStatus, setSyncStatus] = React.useState<string | undefined>();
  const [pendingChatPrompt, setPendingChatPrompt] = React.useState<string | undefined>();
  const [pendingChatSourceKey, setPendingChatSourceKey] = React.useState<string | undefined>();

  const isDark = household.theme === "dark" || (household.theme === "system" && systemScheme === "dark");
  applyPalette(isDark);

  React.useEffect(() => {
    SecureStore.getItemAsync(storageKey)
      .then((raw) => {
        if (raw) setHousehold(migrateHousehold(JSON.parse(raw) as unknown));
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

  const streamAssistantMessage = React.useCallback((conversationId: string, messageId: string, answer: string) => {
    setIsTyping(true);
    let index = 0;
    // A calm 30fps cadence avoids the jagged one-character jumps while keeping
    // long answers bounded to a small number of React/layout commits.
    const charactersPerCommit = Math.max(2, Math.ceil(answer.length / 48));
    return new Promise<void>((resolve) => {
      const timer = setInterval(() => {
        index = Math.min(answer.length, index + charactersPerCommit);
        setHousehold((current) => {
          const conversation = current.conversations.find((candidate) => candidate.id === conversationId);
          if (!conversation) return current;
          const messages = conversation.messages.map((message) => message.id === messageId ? { ...message, text: answer.slice(0, index) } : message);
          return replaceConversationMessages(current, conversationId, messages);
        });
        if (index >= answer.length) {
          clearInterval(timer);
          setIsTyping(false);
          resolve();
        }
      }, 33);
    });
  }, []);

  const signInDemo = React.useCallback(() => {
    track("auth_completed", { provider: "demo" });
    updateHousehold((current) => {
      const family = demoFamily();
      return {
        ...current,
        account: { id: uuid(), displayName: "Sita Sharma", isDemo: true, authProvider: "demo" },
        family,
        events: demoEvents(),
        selectedMemberId: family.find((member) => member.relation === "selfMember")?.id
      };
    });
  }, [updateHousehold]);

  const signInGoogle = React.useCallback(async () => {
    const session = await signInWithGoogle();
    if (session) {
      track("auth_completed", { provider: "google" });
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "google", supabaseUserId: session.user.id } : { id: uuid(), displayName: session.user.email?.split("@")[0] || "User", isDemo: false, authProvider: "google", supabaseUserId: session.user.id }
      }));
    }
  }, [updateHousehold]);

  const completeOAuth = React.useCallback(async (params: AuthCallbackParams) => {
    const session = await completeAuthFromParams(params);
    if (session) {
      track("auth_completed", { provider: "google" });
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "google", supabaseUserId: session.user.id, isDemo: false } : { id: uuid(), displayName: session.user.email?.split("@")[0] || "User", isDemo: false, authProvider: "google", supabaseUserId: session.user.id }
      }));
    }
  }, [updateHousehold]);

  const signInEmail = React.useCallback(async (email: string, password: string) => {
    const session = await signInWithEmail(email, password);
    if (session) {
      track("auth_completed", { provider: "email" });
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
      track("auth_completed", { provider: "email_signup" });
      updateHousehold((current) => ({
        ...current,
        account: current.account ? { ...current.account, authProvider: "email", supabaseUserId: user.id } : { id: uuid(), displayName: user.email?.split("@")[0] || "User", isDemo: false, authProvider: "email", supabaseUserId: user.id }
      }));
    }
  }, [updateHousehold]);

  const skipAuth = React.useCallback(() => {
    track("auth_skipped");
    updateHousehold((current) => ({
      ...current,
      account: current.account ? { ...current.account, authProvider: "demo" } : { id: uuid(), displayName: "User", isDemo: true, authProvider: "demo" }
    }));
  }, [updateHousehold]);

  const signOut = React.useCallback(() => {
    track("auth_signed_out");
    signOutSupabase().catch(() => undefined);
    setHousehold(initialHousehold());
    setSelectedTab("home");
    setModal(null);
  }, []);

  const setLanguage = React.useCallback((language: Language) => {
    track("preference_changed", { preference: "language", value: language });
    updateHousehold((current) => ({ ...current, language }));
  }, [updateHousehold]);

  const setTheme = React.useCallback((theme: ThemeChoice) => {
    track("preference_changed", { preference: "theme", value: theme });
    updateHousehold((current) => ({ ...current, theme }));
  }, [updateHousehold]);

  const saveSelf = React.useCallback((name: string, birth?: BirthData) => {
    track("profile_saved", { has_birth_data: Boolean(birth) });
    updateHousehold((current) => {
      const existing = current.family.find((member) => member.relation === "selfMember");
      const normalizedName = name.trim() || existing?.name || "User";
      const self = recomputeMember(existing
        ? { ...existing, name: normalizedName, ...(birth ? { birth } : {}) }
        : { id: uuid(), name: normalizedName, gender: "other", relation: "selfMember", ...(birth ? { birth } : {}) });
      const family = current.family.some((member) => member.relation === "selfMember")
        ? current.family.map((member) => (member.relation === "selfMember" ? self : member))
        : [self, ...current.family];
      return {
        ...current,
        account: current.account ? { ...current.account, displayName: normalizedName } : { id: uuid(), displayName: normalizedName, isDemo: true },
        family,
        selectedMemberId: self.id
      };
    });
  }, [updateHousehold]);

  const addMember = React.useCallback((member: FamilyMember) => {
    track("family_member_added", { relation: member.relation, has_birth_data: Boolean(member.birth) });
    updateHousehold((current) => ({ ...current, family: [...current.family, recomputeMember(member)] }));
  }, [updateHousehold]);

  const openPandit = React.useCallback((prompt?: string, sourceKey?: string) => {
    track("pandit_opened", { source: sourceKey || (prompt?.trim() ? "preloaded" : "manual") });
    if (prompt?.trim()) setPendingChatPrompt(prompt.trim());
    setPendingChatSourceKey(sourceKey);
    setModal("chat");
  }, []);

  const selectMember = React.useCallback((memberId?: string) => {
    track("family_member_opened", { has_member: Boolean(memberId) });
    updateHousehold((current) => ({
      ...current,
      selectedMemberId: memberId && current.family.some((member) => member.id === memberId) ? memberId : undefined
    }));
  }, [updateHousehold]);

  const addEvent = React.useCallback((event: PatroEvent) => {
    track("patro_event_added", { repeats_yearly: event.repeatsYearly });
    updateHousehold((current) => ({ ...current, events: [...current.events, event] }));
  }, [updateHousehold]);

  const newConversation = React.useCallback(() => {
    track("chat_conversation_created");
    const id = uuid();
    const now = new Date().toISOString();
    updateHousehold((current) => ({
      ...current,
      conversations: [{ id, title: "Jyotish Baje", messages: [], createdAt: now, updatedAt: now }, ...current.conversations],
      activeConversationId: id,
      chat: []
    }));
    return id;
  }, [updateHousehold]);

  const selectConversation = React.useCallback((conversationId: string) => {
    track("chat_conversation_selected");
    updateHousehold((current) => {
      const conversation = current.conversations.find((candidate) => candidate.id === conversationId);
      if (!conversation) return current;
      return { ...current, activeConversationId: conversation.id, chat: conversation.messages };
    });
  }, [updateHousehold]);

  const deleteConversation = React.useCallback((conversationId: string) => {
    track("chat_conversation_deleted");
    updateHousehold((current) => {
      const conversations = current.conversations.filter((conversation) => conversation.id !== conversationId);
      if (conversations.length === current.conversations.length) return current;
      if (current.activeConversationId !== conversationId) return { ...current, conversations };
      const next = conversations[0];
      return { ...current, conversations, activeConversationId: next?.id, chat: next?.messages ?? [] };
    });
  }, [updateHousehold]);

  const sendChat = React.useCallback(async (text: string, sourceKey?: string) => {
    const trimmed = text.trim();
    if (!trimmed || isTyping) return;
    const startedAt = Date.now();
    const featureContext = parseFeatureSource(sourceKey);
    track("chat_question_sent", { character_count: trimmed.length, language: household.language, source: sourceKey || "manual", feature: featureContext?.featureID || "none" });
    const sentAt = new Date().toISOString();
    const userMessage: ChatMessage = { id: uuid(), isUser: true, text: trimmed, timestamp: sentAt };
    const assistantID = uuid();
    const assistantMessage: ChatMessage = { id: assistantID, isUser: false, text: "", timestamp: new Date().toISOString() };
    const activeConversation = household.conversations.find((conversation) => conversation.id === household.activeConversationId);
    const conversationId = activeConversation?.id ?? uuid();
    const chatSnapshot = activeConversation?.messages ?? household.chat;
    const familySnapshot = household.family;
    const languageSnapshot = household.language;
    setHousehold((current) => {
      const existing = current.conversations.find((conversation) => conversation.id === conversationId);
      const previousMessages = existing?.messages ?? (current.activeConversationId ? [] : current.chat);
      const messages = [...previousMessages, userMessage, assistantMessage];
      const nextConversation: ChatConversation = existing
        ? { ...existing, title: conversationTitle(messages, existing.title), messages, updatedAt: assistantMessage.timestamp }
        : { id: conversationId, title: conversationTitle(messages, "Jyotish Baje"), messages, createdAt: sentAt, updatedAt: assistantMessage.timestamp };
      return {
        ...current,
        conversations: existing
          ? current.conversations.map((conversation) => conversation.id === conversationId ? nextConversation : conversation)
          : [nextConversation, ...current.conversations],
        activeConversationId: conversationId,
        chat: messages
      };
    });

    const preparedReport = featureContext
      ? buildFeatureToolReport(featureContext.featureID, familySnapshot, languageSnapshot, featureContext.memberID)
      : undefined;
    const localAnswer = preparedReport?.answer ?? localPanditReply(trimmed, familySnapshot, languageSnapshot);
    const endpoint = process.env.EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL || process.env.JYOTISH_AGENT_ENDPOINT_URL;
    let answer = localAnswer;
    let source = "local";
    if (endpoint) {
      try {
        const response = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            language: languageSnapshot,
            message: trimmed,
            family: familySnapshot,
            events: household.events,
            selfMemberID: familySnapshot.find((member) => member.relation === "selfMember")?.id,
            chatHistory: chatSnapshot.slice(-16),
            sourceKey,
            requestedFeature: featureContext?.featureID,
            nowISO: new Date().toISOString(),
            toolEvidence: preparedReport?.evidence,
            localFallbackReply: localAnswer
          })
        });
        if (response.ok) {
          const data = (await response.json()) as { reply?: string };
          answer = data.reply?.trim() || localAnswer;
          source = data.reply?.trim() ? "remote" : "local";
          setSyncStatus(undefined);
        } else {
          track("chat_backend_failed", { reason: "http" });
          setSyncStatus("Jyotish Baje backend unavailable; using local reading.");
        }
      } catch {
        track("chat_backend_failed", { reason: "network" });
        setSyncStatus("Jyotish Baje backend unavailable; using local reading.");
      }
    }
    await streamAssistantMessage(conversationId, assistantID, answer);
    track("chat_answer_completed", { source, character_count: answer.length, duration_ms: Date.now() - startedAt });
  }, [household, isTyping, streamAssistantMessage]);

  const selectTab = React.useCallback((tab: AppTab) => {
    track("screen_viewed", { screen: tab });
    setSelectedTab(tab);
  }, []);

  const showModal = React.useCallback((nextModal: AppModal) => {
    if (nextModal) track("modal_opened", { modal: nextModal });
    setModal(nextModal);
  }, []);

  const activeChat = household.conversations.find((conversation) => conversation.id === household.activeConversationId)?.messages ?? household.chat;
  const selectedMember = household.family.find((member) => member.id === household.selectedMemberId);

  const value = React.useMemo<AppContextValue>(() => ({
    account: household.account,
    family: household.family,
    events: household.events,
    chat: activeChat,
    conversations: household.conversations,
    activeConversationId: household.activeConversationId,
    selectedMemberId: household.selectedMemberId,
    selectedMember,
    language: household.language,
    theme: household.theme,
    selectedTab,
    modal,
    isTyping,
    syncStatus,
    pendingChatPrompt,
    pendingChatSourceKey,
    signInDemo,
    signInGoogle,
    completeOAuth,
    signInEmail,
    signUpEmail,
    skipAuth,
    signOut,
    setLanguage,
    setTheme,
    setSelectedTab: selectTab,
    openModal: showModal,
    openPandit,
    consumePendingChatPrompt: () => setPendingChatPrompt(undefined),
    consumePendingChatSourceKey: () => setPendingChatSourceKey(undefined),
    closeModal: () => setModal(null),
    saveSelf,
    addMember,
    selectMember,
    addEvent,
    newConversation,
    selectConversation,
    deleteConversation,
    sendChat
  }), [household, activeChat, selectedMember, selectedTab, modal, isTyping, syncStatus, pendingChatPrompt, pendingChatSourceKey, signInDemo, signInGoogle, completeOAuth, signInEmail, signUpEmail, skipAuth, signOut, setLanguage, setTheme, selectTab, showModal, saveSelf, addMember, openPandit, selectMember, addEvent, newConversation, selectConversation, deleteConversation, sendChat]);

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useAppState() {
  const value = React.use(AppContext);
  if (!value) throw new Error("useAppState must be used inside AppStateProvider");
  return value;
}
