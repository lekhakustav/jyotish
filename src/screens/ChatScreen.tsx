import React from "react";
import {
  Animated,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  Text,
  TextInput,
  View,
  useWindowDimensions,
  type NativeScrollEvent,
  type NativeSyntheticEvent
} from "react-native";
import { AppText, Hairline, PressableScale, SerifText, TypingIndicator } from "@/components";
import { useAppState } from "@/app-state";
import { chatSuggestions, parseChatBlocks, stripChatMarkdown } from "@/chat-format";
import { FixedScreen, useReduceMotion } from "@/layout";
import { t } from "@/l10n";
import { AppIcon, type AppIconName } from "@/ornaments";
import { palette } from "@/theme";
import type { ChatConversation, ChatMessage } from "@/types";

const CHAT_GUTTER = 24;

export function ChatScreen() {
  const app = useAppState();
  const listRef = React.useRef<FlatList<ChatMessage>>(null);
  const atBottom = React.useRef(true);
  const forceNextScroll = React.useRef(false);
  const [text, setText] = React.useState("");
  const [sending, setSending] = React.useState(false);
  const [listening, setListening] = React.useState(false);
  const [historyOpen, setHistoryOpen] = React.useState(false);
  const latestAssistant = React.useMemo(
    () => [...app.chat].reverse().find((message) => !message.isUser && message.text.trim()),
    [app.chat]
  );
  const suggestions = React.useMemo(
    () => app.isTyping ? [] : chatSuggestions(latestAssistant, app.language),
    [app.isTyping, app.language, latestAssistant]
  );

  const submit = React.useCallback((rawText: string) => {
    const message = stripChatMarkdown(rawText).trim();
    if (!message || sending || app.isTyping) return;
    setText("");
    setListening(false);
    setSending(true);
    forceNextScroll.current = true;
    void app.sendChat(message).finally(() => setSending(false));
  }, [app, sending]);

  const onContentSizeChange = React.useCallback(() => {
    if (!atBottom.current && !forceNextScroll.current) return;
    forceNextScroll.current = false;
    requestAnimationFrame(() => listRef.current?.scrollToEnd({ animated: !app.isTyping }));
  }, [app.isTyping]);

  const onScroll = React.useCallback((event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const { contentOffset, contentSize, layoutMeasurement } = event.nativeEvent;
    atBottom.current = contentSize.height - layoutMeasurement.height - contentOffset.y < 80;
  }, []);

  return (
    <FixedScreen gutter={0} testID="chat-screen">
      <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : "height"} style={{ flex: 1 }}>
        <ChatHeader
          title={t("chat.title", app.language)}
          onHistory={() => setHistoryOpen(true)}
          onNew={() => {
            app.newConversation();
            setText("");
            forceNextScroll.current = true;
          }}
          onClose={app.closeModal}
        />

        <FlatList
          ref={listRef}
          data={app.chat}
          keyExtractor={(message) => message.id}
          renderItem={({ item, index }) => (
            <MessageRow
              message={item}
              streaming={app.isTyping && index === app.chat.length - 1 && !item.isUser}
            />
          )}
          ListEmptyComponent={<EmptyChat language={app.language} />}
          ListFooterComponent={app.isTyping && !app.chat.at(-1)?.text ? <TypingIndicator /> : null}
          ItemSeparatorComponent={() => <View style={{ height: 20 }} />}
          contentContainerStyle={{
            flexGrow: 1,
            justifyContent: app.chat.length === 0 ? "center" : "flex-start",
            paddingHorizontal: CHAT_GUTTER,
            paddingTop: 12,
            paddingBottom: 24
          }}
          keyboardDismissMode="interactive"
          keyboardShouldPersistTaps="handled"
          maintainVisibleContentPosition={{ minIndexForVisible: 0, autoscrollToTopThreshold: 24 }}
          initialNumToRender={12}
          maxToRenderPerBatch={8}
          updateCellsBatchingPeriod={48}
          windowSize={7}
          removeClippedSubviews={Platform.OS === "android"}
          onScroll={onScroll}
          scrollEventThrottle={32}
          onContentSizeChange={onContentSizeChange}
          showsVerticalScrollIndicator={false}
        />

        {app.syncStatus ? (
          <AppText accessibilityRole="alert" style={{ color: palette.sindoor, fontSize: 12, paddingHorizontal: CHAT_GUTTER, paddingBottom: 6 }}>
            {app.syncStatus}
          </AppText>
        ) : null}

        <View style={{ backgroundColor: palette.bgCanvas }}>
          {suggestions.length > 0 ? (
            <ScrollView
              horizontal
              keyboardShouldPersistTaps="always"
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={{ gap: 8, paddingHorizontal: CHAT_GUTTER, paddingTop: 6, paddingBottom: 10 }}
            >
              {suggestions.map((suggestion) => (
                <PressableScale
                  key={suggestion}
                  accessibilityRole="button"
                  disabled={sending}
                  onPress={() => submit(suggestion)}
                  style={{
                    minHeight: 44,
                    maxWidth: 300,
                    justifyContent: "center",
                    paddingHorizontal: 16,
                    borderRadius: 22,
                    borderCurve: "continuous",
                    backgroundColor: palette.bgSunken
                  }}
                >
                  <AppText numberOfLines={2} style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold", fontSize: 13, lineHeight: 18 }}>
                    {suggestion}
                  </AppText>
                </PressableScale>
              ))}
            </ScrollView>
          ) : null}
          <Composer
            value={text}
            language={app.language}
            listening={listening}
            disabled={sending || app.isTyping}
            onChangeText={(value) => {
              setListening(false);
              setText(value);
            }}
            onSubmit={() => submit(text)}
            onMicrophone={() => setListening((current) => !current)}
          />
        </View>
      </KeyboardAvoidingView>

      {historyOpen ? (
        <HistoryDrawer
          conversations={app.conversations}
          activeConversationId={app.activeConversationId}
          language={app.language}
          onClose={() => setHistoryOpen(false)}
          onNew={() => {
            app.newConversation();
            setHistoryOpen(false);
            setText("");
          }}
          onSelect={(id) => {
            app.selectConversation(id);
            setHistoryOpen(false);
            forceNextScroll.current = true;
          }}
          onDelete={app.deleteConversation}
        />
      ) : null}
    </FixedScreen>
  );
}

function ChatHeader({ title, onHistory, onNew, onClose }: { title: string; onHistory: () => void; onNew: () => void; onClose: () => void }) {
  return (
    <View style={{ minHeight: 64, paddingHorizontal: CHAT_GUTTER, flexDirection: "row", alignItems: "center", gap: 8 }}>
      <IconButton icon="history" label="Chat history" onPress={onHistory} />
      <SerifText numberOfLines={1} style={{ flex: 1, fontSize: 28, fontFamily: "Fraunces-Bold", textAlign: "center" }}>{title}</SerifText>
      <IconButton icon="plus" label="New chat" onPress={onNew} />
      <IconButton icon="close" label="Close chat" onPress={onClose} />
    </View>
  );
}

const MessageRow = React.memo(function MessageRow({ message, streaming }: { message: ChatMessage; streaming: boolean }) {
  if (message.isUser) {
    return (
      <View style={{ alignSelf: "flex-end", maxWidth: "86%", borderRadius: 20, borderCurve: "continuous", backgroundColor: "rgba(242, 169, 59, 0.20)", paddingHorizontal: 16, paddingVertical: 10 }}>
        <SerifText selectable style={{ fontSize: 16, lineHeight: 24 }}>{stripChatMarkdown(message.text)}</SerifText>
      </View>
    );
  }
  return <AssistantMessage text={message.text} streaming={streaming} />;
});

function AssistantMessage({ text, streaming }: { text: string; streaming: boolean }) {
  const blocks = React.useMemo(() => parseChatBlocks(text), [text]);
  return (
    <View style={{ alignSelf: "stretch", gap: 8, paddingRight: 18 }}>
      {blocks.map((block, index) => (
        <View key={`${block.kind}-${index}`} style={block.kind === "bullet" ? { flexDirection: "row", alignItems: "flex-start", gap: 9 } : undefined}>
          {block.kind === "bullet" ? <View style={{ width: 5, height: 5, borderRadius: 3, marginTop: 11, backgroundColor: palette.templeGold }} /> : null}
          <InlineRichText text={block.text} heading={block.kind === "heading"} />
        </View>
      ))}
      {streaming ? <StreamingCursor /> : null}
    </View>
  );
}

function InlineRichText({ text, heading }: { text: string; heading: boolean }) {
  const pieces = text.split(/(\*\*.*?\*\*|__.*?__)/g).filter(Boolean);
  return (
    <Text
      selectable
      style={{
        flexShrink: 1,
        color: palette.inkPrimary,
        fontFamily: heading ? "Fraunces-Bold" : "Fraunces-Regular",
        fontSize: heading ? 18 : 17,
        lineHeight: heading ? 26 : 28
      }}
    >
      {pieces.map((piece, index) => {
        const bold = /^(?:\*\*|__).*(?:\*\*|__)$/.test(piece);
        const copy = bold ? piece.slice(2, -2) : piece;
        return <Text key={`${index}-${copy}`} style={bold ? { fontFamily: "Fraunces-Bold" } : undefined}>{copy}</Text>;
      })}
    </Text>
  );
}

function StreamingCursor() {
  const opacity = React.useRef(new Animated.Value(1)).current;
  const reduceMotion = useReduceMotion();
  React.useEffect(() => {
    if (reduceMotion) return;
    const animation = Animated.loop(Animated.sequence([
      Animated.timing(opacity, { toValue: 0.2, duration: 420, useNativeDriver: true }),
      Animated.timing(opacity, { toValue: 1, duration: 420, useNativeDriver: true })
    ]));
    animation.start();
    return () => animation.stop();
  }, [opacity, reduceMotion]);
  return <Animated.View style={{ width: 2, height: 18, backgroundColor: palette.sindoor, opacity }} />;
}

function Composer({ value, language, listening, disabled, onChangeText, onSubmit, onMicrophone }: {
  value: string;
  language: "en" | "ne";
  listening: boolean;
  disabled: boolean;
  onChangeText: (value: string) => void;
  onSubmit: () => void;
  onMicrophone: () => void;
}) {
  const hasText = value.trim().length > 0;
  return (
    <View style={{ flexDirection: "row", alignItems: "flex-end", gap: 8, paddingHorizontal: CHAT_GUTTER, paddingTop: 4, paddingBottom: 10 }}>
      <TextInput
        accessibilityLabel={listening ? t("chat.listening", language) : t("chat.placeholder", language)}
        value={value}
        editable={!disabled}
        onChangeText={onChangeText}
        onSubmitEditing={hasText ? onSubmit : undefined}
        blurOnSubmit={false}
        placeholder={listening ? t("chat.listening", language) : t("chat.placeholder", language)}
        placeholderTextColor={palette.inkSecondary}
        multiline
        style={{
          flex: 1,
          minHeight: 48,
          maxHeight: 120,
          borderRadius: 22,
          borderCurve: "continuous",
          backgroundColor: palette.bgSunken,
          color: palette.inkPrimary,
          paddingHorizontal: 16,
          paddingTop: 13,
          paddingBottom: 11,
          fontFamily: "Inter-Regular",
          fontSize: 16,
          lineHeight: 22,
          opacity: disabled ? 0.62 : 1
        }}
      />
      <PressableScale
        accessibilityRole="button"
        accessibilityLabel={hasText ? "Send message" : listening ? "Stop listening" : "Start voice input"}
        disabled={disabled}
        onPress={hasText ? onSubmit : onMicrophone}
        style={{
          width: 48,
          height: 48,
          borderRadius: 24,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: hasText ? palette.saffron : listening ? "rgba(242, 169, 59, 0.28)" : palette.bgSunken
        }}
      >
        <AppIcon name={hasText ? "send" : "microphone"} size={21} color={hasText || listening ? palette.inkPrimary : palette.inkSecondary} strokeWidth={2} />
      </PressableScale>
    </View>
  );
}

function EmptyChat({ language }: { language: "en" | "ne" }) {
  return (
    <View style={{ alignItems: "center", gap: 12, paddingHorizontal: 24 }}>
      <AppIcon name="sparkle" size={30} color={palette.templeGold} />
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24, textAlign: "center" }}>
        {language === "ne" ? "आज के बुझ्न चाहनुहुन्छ?" : "What would you like to understand today?"}
      </SerifText>
      <AppText style={{ color: palette.inkSecondary, fontSize: 15, lineHeight: 22, textAlign: "center" }}>
        {language === "ne" ? "दशा, समय, परिवार वा आफ्नो कुण्डलीबारे सोध्नुहोस्।" : "Ask about your dasha, timing, family, or birth chart."}
      </AppText>
    </View>
  );
}

function HistoryDrawer({ conversations, activeConversationId, language, onClose, onNew, onSelect, onDelete }: {
  conversations: ChatConversation[];
  activeConversationId?: string;
  language: "en" | "ne";
  onClose: () => void;
  onNew: () => void;
  onSelect: (id: string) => void;
  onDelete: (id: string) => void;
}) {
  const { width } = useWindowDimensions();
  const sorted = React.useMemo(
    () => [...conversations].sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)),
    [conversations]
  );
  return (
    <View accessibilityViewIsModal style={{ position: "absolute", inset: 0, flexDirection: "row" }}>
      <View style={{ width: Math.min(width * 0.81, 430), backgroundColor: palette.bgElevated, paddingHorizontal: 20, paddingVertical: 14 }}>
        <View style={{ minHeight: 52, flexDirection: "row", alignItems: "center", gap: 8 }}>
          <SerifText style={{ flex: 1, fontFamily: "Fraunces-Bold", fontSize: 24 }}>
            {language === "ne" ? "कुराकानीहरू" : "Conversations"}
          </SerifText>
          <IconButton icon="close" label="Close history" onPress={onClose} />
        </View>
        <PressableScale
          accessibilityRole="button"
          onPress={onNew}
          style={{ minHeight: 56, borderRadius: 16, borderCurve: "continuous", backgroundColor: palette.saffron, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 10, marginVertical: 12 }}
        >
          <AppIcon name="plus" size={19} color={palette.inkPrimary} strokeWidth={2} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18 }}>{language === "ne" ? "नयाँ कुराकानी" : "New conversation"}</SerifText>
        </PressableScale>
        <FlatList
          data={sorted}
          keyExtractor={(conversation) => conversation.id}
          renderItem={({ item }) => (
            <View>
              <View style={{ minHeight: 66, flexDirection: "row", alignItems: "center", gap: 4 }}>
                <PressableScale
                  accessibilityRole="button"
                  accessibilityState={{ selected: item.id === activeConversationId }}
                  onPress={() => onSelect(item.id)}
                  style={{ flex: 1, justifyContent: "center", minHeight: 56, paddingRight: 8 }}
                >
                  <AppText numberOfLines={1} style={{ fontFamily: item.id === activeConversationId ? "Inter-Bold" : "Inter-SemiBold", fontSize: 15 }}>{item.title}</AppText>
                  <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 12, marginTop: 4 }}>
                    {new Date(item.updatedAt).toLocaleDateString(language === "ne" ? "ne-NP" : "en-US", { month: "short", day: "numeric" })}
                  </AppText>
                </PressableScale>
                <IconButton icon="trash" label={`Delete ${item.title}`} color={palette.sindoor} onPress={() => onDelete(item.id)} />
              </View>
              <Hairline />
            </View>
          )}
          ListEmptyComponent={<AppText style={{ color: palette.inkSecondary, paddingVertical: 20 }}>{language === "ne" ? "अहिलेसम्म कुनै कुराकानी छैन।" : "No conversations yet."}</AppText>}
          showsVerticalScrollIndicator={false}
        />
      </View>
      <Pressable accessibilityLabel="Close history" accessibilityRole="button" onPress={onClose} style={{ flex: 1, backgroundColor: "rgba(59, 31, 20, 0.28)" }} />
    </View>
  );
}

function IconButton({ icon, label, color = palette.inkSecondary, onPress }: { icon: AppIconName; label: string; color?: string; onPress: () => void }) {
  return (
    <PressableScale
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={{ width: 48, height: 48, alignItems: "center", justifyContent: "center" }}
    >
      <AppIcon name={icon} size={22} color={color} strokeWidth={2} />
    </PressableScale>
  );
}
