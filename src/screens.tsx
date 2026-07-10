import * as Speech from "expo-speech";
import React from "react";
import { Image, KeyboardAvoidingView, Modal, ScrollView, TextInput, View } from "react-native";
import { computeKundali, generateRashifal, nakshatrasEN, nakshatrasNE, panchangaFor, rashiMeta, rashiOrder, todayBS, uuid } from "@/astro";
import { useAppState } from "@/app-state";
import { AppText, Field, GhostButton, Hairline, InfoRow, Logo, PrimaryButton, PressableScale, SectionLabel, SerifText, TypingIndicator } from "@/components";
import { digits, t } from "@/l10n";
import { palette } from "@/theme";
import type { AppTab, FamilyMember, PatroEvent, RashiKey } from "@/types";

export function WelcomeScreen() {
  const app = useAppState();
  return (
    <Screen>
      <View style={{ flex: 1, minHeight: 720, justifyContent: "center", gap: 28 }}>
        <View style={{ alignItems: "center", gap: 18 }}>
          <Logo size={132} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 48, textAlign: "center" }}>ज्योतिष बाजे</SerifText>
          <SerifText style={{ color: palette.inkSecondary, fontSize: 18, fontStyle: "italic", textAlign: "center", lineHeight: 28 }}>
            {t("app.tagline", app.language)}
          </SerifText>
        </View>
        <View style={{ gap: 14 }}>
          <PrimaryButton title={t("welcome.continue", app.language)} icon="◉" onPress={app.signInDemo} />
          <Segmented
            value={app.language}
            options={[{ value: "en", label: "English" }, { value: "ne", label: "नेपाली" }]}
            onChange={(value) => app.setLanguage(value as "en" | "ne")}
          />
        </View>
      </View>
    </Screen>
  );
}

export function ProfileScreen() {
  const app = useAppState();
  const [name, setName] = React.useState(app.account?.displayName || "Sita Sharma");
  return (
    <Screen>
      <View style={{ gap: 24, paddingTop: 40 }}>
        <Logo size={92} />
        <View style={{ gap: 8 }}>
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 36 }}>{t("profile.title", app.language)}</SerifText>
          <AppText style={{ color: palette.inkSecondary, lineHeight: 24 }}>Pandit-ji needs these to draw the kundali.</AppText>
        </View>
        <Field value={name} onChangeText={setName} placeholder="Full name" />
        <PrimaryButton
          title={t("profile.compute", app.language)}
          onPress={() => {
            app.saveSelf(name);
            app.closeModal();
          }}
        />
      </View>
    </Screen>
  );
}

export function AuthScreen() {
  const app = useAppState();
  const [isLogin, setIsLogin] = React.useState(true);
  const [email, setEmail] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState("");

  const handleEmailAuth = async () => {
    if (!email || !password) return;
    setLoading(true);
    setError("");
    try {
      if (isLogin) {
        await app.signInEmail(email, password);
      } else {
        await app.signUpEmail(email, password);
      }
      app.closeModal();
    } catch (e: any) {
      setError(e.message || "Authentication failed");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleAuth = async () => {
    setLoading(true);
    setError("");
    try {
      await app.signInGoogle();
      app.closeModal();
    } catch (e: any) {
      setError(e.message || "Google sign in failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior="padding" style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      <Screen>
        <View style={{ gap: 24, paddingTop: 40, flex: 1, justifyContent: "center" }}>
          <View style={{ gap: 8, alignItems: "center" }}>
            <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 32, textAlign: "center" }}>{t("auth.title", app.language)}</SerifText>
            <AppText style={{ color: palette.inkSecondary, lineHeight: 24, textAlign: "center" }}>{t("auth.subtitle", app.language)}</AppText>
          </View>
          
          <View style={{ gap: 16, marginTop: 20 }}>
            <PressableScale
              disabled={loading}
              onPress={handleGoogleAuth}
              style={{
                minHeight: 52,
                borderRadius: 20,
                borderCurve: "continuous",
                backgroundColor: "#FFFFFF",
                alignItems: "center",
                justifyContent: "center",
                flexDirection: "row",
                gap: 12,
                borderWidth: 1,
                borderColor: "#E5E5E5"
              }}
            >
              <AppText style={{ fontSize: 20 }}>G</AppText>
              <AppText style={{ fontSize: 16, fontFamily: "Inter-SemiBold", color: "#3C4043" }}>{t("auth.google", app.language)}</AppText>
            </PressableScale>

            <View style={{ flexDirection: "row", alignItems: "center", gap: 12, paddingVertical: 8 }}>
              <Hairline /><AppText style={{ color: palette.inkSecondary }}>{t("auth.or", app.language)}</AppText><View style={{ flex: 1, height: 1, backgroundColor: palette.hairline }} />
            </View>

            <Field value={email} onChangeText={setEmail} placeholder={t("auth.email", app.language)} autoCapitalize="none" keyboardType="email-address" />
            <Field value={password} onChangeText={setPassword} placeholder={t("auth.password", app.language)} secureTextEntry />
            
            {error ? <AppText style={{ color: palette.sindoor, fontSize: 14, textAlign: "center" }}>{error}</AppText> : null}

            <PrimaryButton
              title={loading ? t("auth.loading", app.language) : (isLogin ? t("auth.signIn", app.language) : t("auth.signUp", app.language))}
              onPress={handleEmailAuth}
              disabled={loading}
            />

            <PressableScale onPress={() => setIsLogin(!isLogin)} style={{ alignItems: "center", padding: 8 }}>
              <AppText style={{ color: palette.inkSecondary }}>
                {isLogin ? "Need an account? Sign Up" : "Already have an account? Sign In"}
              </AppText>
            </PressableScale>
          </View>

          <View style={{ flex: 1 }} />

          <GhostButton
            title={t("auth.skip", app.language)}
            onPress={() => {
              app.skipAuth();
              app.closeModal();
            }}
          />
        </View>
      </Screen>
    </KeyboardAvoidingView>
  );
}

export function MainScreen() {
  const app = useAppState();
  return (
    <View style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      {app.selectedTab === "home" ? <HomeScreen /> : app.selectedTab === "rashifal" ? <RashifalScreen /> : <FamilyScreen />}
      <BottomTabs value={app.selectedTab} onChange={app.setSelectedTab} />
      <AppModal />
    </View>
  );
}

function HomeScreen() {
  const app = useAppState();
  const self = app.family.find((member) => member.relation === "selfMember");
  const rashi = self?.kundali?.moonRashi ?? "mesh";
  const reading = generateRashifal(rashi, "daily", app.language);
  const panchanga = panchangaFor(new Date(), app.language);
  return (
    <Screen bottomInset={112}>
      <Header title={greeting(app.language)} action="⚙" onAction={() => app.openModal("settings")} />
      <View style={{ gap: 22 }}>
        <View style={{ gap: 16 }}>
          <SectionLabel>{t("home.templeOfDay", app.language)}</SectionLabel>
          <Image source={require("../assets/expo/images/temple-pashupatinath.png")} resizeMode="cover" style={{ width: "100%", height: 178, borderRadius: 8 }} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 25 }}>Pashupatinath</SerifText>
          <AppText style={{ color: palette.inkSecondary, lineHeight: 23 }}>A quiet morning darshan for steadiness, family protection, and right timing.</AppText>
        </View>
        <ActionRow>
          <PrimaryButton title={t("home.askPandit", app.language)} icon="✦" onPress={() => app.openModal("chat")} />
          <GhostButton title={t("home.openPatro", app.language)} icon="◷" onPress={() => app.openModal("patro")} />
        </ActionRow>
        <Panel>
          <SectionLabel>{t("rashifal.title", app.language)}</SectionLabel>
          <View style={{ flexDirection: "row", gap: 16, alignItems: "center" }}>
            <RashiBadge rashi={rashi} />
            <View style={{ flex: 1, gap: 6 }}>
              <AppText style={{ fontFamily: "Inter-Bold", fontSize: 18 }}>{rashiName(rashi, app.language)}</AppText>
              <AppText style={{ color: palette.inkSecondary, lineHeight: 22 }}>{reading.text}</AppText>
            </View>
          </View>
        </Panel>
        <Panel>
          <SectionLabel>{t("patro.panchanga", app.language)}</SectionLabel>
          <InfoRow label="Tithi" value={panchanga.tithi} />
          <InfoRow label="Nakshatra" value={panchanga.nakshatra} />
          <InfoRow label="Yoga" value={panchanga.yoga} />
          <InfoRow label="Karana" value={panchanga.karana} />
        </Panel>
        <Panel>
          <SectionLabel>{t("home.upcoming", app.language)}</SectionLabel>
          {app.events.length === 0 ? (
            <AppText style={{ color: palette.inkSecondary }}>{t("home.noEvents", app.language)}</AppText>
          ) : (
            app.events.slice(0, 3).map((event) => <EventRow key={event.id} event={event} />)
          )}
        </Panel>
      </View>
    </Screen>
  );
}

function RashifalScreen() {
  const app = useAppState();
  const [period, setPeriod] = React.useState<"daily" | "weekly" | "monthly" | "yearly">("daily");
  const [rashi, setRashi] = React.useState<RashiKey>(app.family.find((member) => member.relation === "selfMember")?.kundali?.moonRashi ?? "mesh");
  const reading = generateRashifal(rashi, period, app.language);
  return (
    <Screen bottomInset={112}>
      <Header title={t("rashifal.title", app.language)} />
      <Segmented
        value={period}
        options={[
          { value: "daily", label: t("rashifal.daily", app.language) },
          { value: "weekly", label: t("rashifal.weekly", app.language) },
          { value: "monthly", label: t("rashifal.monthly", app.language) },
          { value: "yearly", label: t("rashifal.yearly", app.language) }
        ]}
        onChange={(value) => setPeriod(value as typeof period)}
      />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 10, paddingVertical: 4 }}>
        {rashiOrder.map((item) => <RashiChip key={item} rashi={item} selected={item === rashi} onPress={() => setRashi(item)} />)}
      </ScrollView>
      <Panel>
        <View style={{ alignItems: "center", gap: 12 }}>
          <RashiBadge rashi={rashi} size={82} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 31, textAlign: "center" }}>{rashiName(rashi, app.language)}</SerifText>
          <AppText style={{ color: palette.inkSecondary, lineHeight: 24, textAlign: "center" }}>{reading.text}</AppText>
        </View>
        <Hairline />
        <View style={{ gap: 10 }}>
          {Object.entries(reading.scores).map(([key, value]) => <ScoreRow key={key} label={key} value={value} />)}
        </View>
        <Hairline />
        <InfoRow label="Lucky color" value={reading.luckyColor} />
        <InfoRow label="Lucky number" value={digits(reading.luckyNumber, app.language)} />
        <InfoRow label={t("rashifal.upaya", app.language)} value={reading.upaya} />
      </Panel>
      <PrimaryButton title={t("home.askPandit", app.language)} icon="✦" onPress={() => app.openModal("chat")} />
    </Screen>
  );
}

function FamilyScreen() {
  const app = useAppState();
  return (
    <Screen bottomInset={112}>
      <Header title={t("family.title", app.language)} action="+" onAction={() => app.openModal("profile")} />
      <View style={{ gap: 14 }}>
        {app.family.map((member) => <MemberPanel key={member.id} member={member} />)}
      </View>
      <PrimaryButton
        title={t("family.add", app.language)}
        icon="+"
        onPress={() => {
          const member: FamilyMember = {
            id: uuid(),
            name: `Family ${app.family.length + 1}`,
            gender: "other",
            relation: "cousin",
            birth: { year: 1995, month: 1, day: 1, hour: 6, minute: 0, timeKnown: false, place: { name: "Kathmandu", nameNE: "काठमाडौं", latitude: 27.7172, longitude: 85.324, utcOffsetHours: 5.75 } }
          };
          app.addMember(member);
        }}
      />
    </Screen>
  );
}

function PatroScreen() {
  const app = useAppState();
  const bs = todayBS();
  const pan = panchangaFor(new Date(), app.language);
  const [title, setTitle] = React.useState("");
  return (
    <Screen>
      <Header title={t("patro.title", app.language)} action="×" onAction={app.closeModal} />
      <Panel>
        <SectionLabel>{`${digits(bs.year, app.language)} / ${digits(bs.month, app.language)} / ${digits(bs.day, app.language)}`}</SectionLabel>
        <InfoRow label="Tithi" value={pan.tithi} />
        <InfoRow label="Nakshatra" value={pan.nakshatra} />
        <InfoRow label="Yoga" value={pan.yoga} />
        <InfoRow label="Karana" value={pan.karana} />
      </Panel>
      <Panel>
        <SectionLabel>{t("patro.events", app.language)}</SectionLabel>
        {app.events.map((event) => <EventRow key={event.id} event={event} />)}
        <Field value={title} onChangeText={setTitle} placeholder="Event title" />
        <PrimaryButton
          title="Add event"
          onPress={() => {
            if (!title.trim()) return;
            app.addEvent({ id: uuid(), title: title.trim(), note: "", bsDate: bs, repeatsYearly: false });
            setTitle("");
          }}
        />
      </Panel>
    </Screen>
  );
}

function ChatScreen() {
  const app = useAppState();
  const [text, setText] = React.useState("");
  const [speak, setSpeak] = React.useState(false);
  const latestAssistant = [...app.chat].reverse().find((message) => !message.isUser && message.text);
  React.useEffect(() => {
    if (speak && latestAssistant?.text) Speech.speak(latestAssistant.text, { language: app.language === "ne" ? "ne-NP" : "en-US" });
  }, [latestAssistant?.id]);
  return (
    <KeyboardAvoidingView behavior="padding" style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      <Screen>
        <Header title={t("chat.title", app.language)} action="×" onAction={app.closeModal} />
        <View style={{ gap: 12, flex: 1 }}>
          {app.chat.length === 0 ? (
            <Panel>
              <AppText style={{ color: palette.inkSecondary }}>Ask about dasha, colors, city, vastu, timing, or family charts.</AppText>
            </Panel>
          ) : (
            app.chat.map((message) => <ChatBubble key={message.id} message={message} />)
          )}
          {app.isTyping ? <TypingIndicator /> : null}
        </View>
        {app.syncStatus ? <AppText style={{ color: palette.sindoor }}>{app.syncStatus}</AppText> : null}
        <View style={{ flexDirection: "row", gap: 10, alignItems: "center" }}>
          <TextInput
            value={text}
            onChangeText={setText}
            placeholder={t("chat.placeholder", app.language)}
            placeholderTextColor={palette.inkSecondary}
            style={{
              flex: 1,
              minHeight: 52,
              maxHeight: 110,
              borderRadius: 20,
              borderCurve: "continuous",
              backgroundColor: palette.bgSunken,
              color: palette.inkPrimary,
              paddingHorizontal: 16,
              paddingVertical: 12,
              fontFamily: "Inter-Regular"
            }}
            multiline
          />
          <PressableScale
            onPress={() => {
              app.sendChat(text).then(() => setText(""));
            }}
            style={{ width: 52, height: 52, borderRadius: 18, backgroundColor: palette.saffron, alignItems: "center", justifyContent: "center" }}
          >
            <AppText style={{ fontFamily: "Inter-Bold" }}>↑</AppText>
          </PressableScale>
        </View>
        <GhostButton title={t("chat.speak", app.language)} icon={speak ? "●" : "○"} selected={speak} onPress={() => setSpeak(!speak)} />
      </Screen>
    </KeyboardAvoidingView>
  );
}

function SettingsScreen() {
  const app = useAppState();
  return (
    <Screen>
      <Header title={t("settings.title", app.language)} action="×" onAction={app.closeModal} />
      <Panel>
        <SectionLabel>{t("settings.language", app.language)}</SectionLabel>
        <Segmented
          value={app.language}
          options={[{ value: "en", label: "English" }, { value: "ne", label: "नेपाली" }]}
          onChange={(value) => app.setLanguage(value as "en" | "ne")}
        />
      </Panel>
      <Panel>
        <SectionLabel>{t("settings.theme", app.language)}</SectionLabel>
        <Segmented
          value={app.theme}
          options={[{ value: "system", label: "System" }, { value: "light", label: "Light" }, { value: "dark", label: "Dark" }]}
          onChange={(value) => app.setTheme(value as typeof app.theme)}
        />
      </Panel>
      <PrimaryButton title={t("settings.signOut", app.language)} icon="×" onPress={app.signOut} />
    </Screen>
  );
}

function AppModal() {
  const app = useAppState();
  return (
    <Modal animationType="slide" visible={app.modal !== null} onRequestClose={app.closeModal}>
      {app.modal === "auth" ? <AuthScreen /> : app.modal === "chat" ? <ChatScreen /> : app.modal === "settings" ? <SettingsScreen /> : app.modal === "patro" ? <PatroScreen /> : <ProfileScreen />}
    </Modal>
  );
}

function Screen({ children, bottomInset = 32 }: { children: React.ReactNode; bottomInset?: number }) {
  return (
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      keyboardShouldPersistTaps="handled"
      style={{ flex: 1, backgroundColor: palette.bgCanvas }}
      contentContainerStyle={{ padding: 22, paddingTop: 54, paddingBottom: bottomInset, gap: 22 }}
    >
      {children}
    </ScrollView>
  );
}

function Header({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <View style={{ minHeight: 44, flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 16 }}>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 34, flexShrink: 1 }}>{title}</SerifText>
      {action ? (
        <PressableScale onPress={onAction ?? (() => undefined)} style={{ width: 42, height: 42, borderRadius: 16, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center" }}>
          <AppText style={{ fontFamily: "Inter-Bold", fontSize: 20 }}>{action}</AppText>
        </PressableScale>
      ) : null}
    </View>
  );
}

function Panel({ children }: { children: React.ReactNode }) {
  return <View style={{ gap: 14 }}>{children}</View>;
}

function ActionRow({ children }: { children: React.ReactNode }) {
  return <View style={{ gap: 10 }}>{children}</View>;
}

function Segmented({ value, options, onChange }: { value: string; options: { value: string; label: string }[]; onChange: (value: string) => void }) {
  return (
    <View style={{ flexDirection: "row", backgroundColor: palette.bgSunken, padding: 4, borderRadius: 18, borderCurve: "continuous", gap: 4 }}>
      {options.map((option) => (
        <PressableScale
          key={option.value}
          onPress={() => onChange(option.value)}
          style={{
            flex: 1,
            minHeight: 42,
            borderRadius: 15,
            borderCurve: "continuous",
            alignItems: "center",
            justifyContent: "center",
            backgroundColor: option.value === value ? "rgba(242, 169, 59, 0.34)" : "transparent",
            paddingHorizontal: 8
          }}
        >
          <AppText style={{ color: option.value === value ? palette.sindoor : palette.inkSecondary, fontFamily: option.value === value ? "Inter-Bold" : "Inter-Regular" }}>
            {option.label}
          </AppText>
        </PressableScale>
      ))}
    </View>
  );
}

function BottomTabs({ value, onChange }: { value: AppTab; onChange: (tab: AppTab) => void }) {
  const items: { tab: AppTab; icon: string; label: string }[] = [
    { tab: "home", icon: "⌂", label: "Home" },
    { tab: "rashifal", icon: "✦", label: "Rashifal" },
    { tab: "family", icon: "☷", label: "Family" }
  ];
  return (
    <View style={{ position: "absolute", left: 16, right: 16, bottom: 20, backgroundColor: palette.bgElevated, borderRadius: 24, borderCurve: "continuous", padding: 6, flexDirection: "row", gap: 4, borderWidth: 1, borderColor: palette.hairline }}>
      {items.map((item) => (
        <PressableScale key={item.tab} onPress={() => onChange(item.tab)} style={{ flex: 1, minHeight: 54, borderRadius: 19, alignItems: "center", justifyContent: "center", backgroundColor: value === item.tab ? "rgba(242, 169, 59, 0.32)" : "transparent" }}>
          <AppText style={{ color: value === item.tab ? palette.sindoor : palette.inkSecondary, fontFamily: "Inter-Bold" }}>{item.icon}</AppText>
          <AppText style={{ color: value === item.tab ? palette.sindoor : palette.inkSecondary, fontSize: 12 }}>{item.label}</AppText>
        </PressableScale>
      ))}
    </View>
  );
}

function RashiBadge({ rashi, size = 64 }: { rashi: RashiKey; size?: number }) {
  return (
    <View style={{ width: size, height: size, borderRadius: size / 2, borderWidth: 1, borderColor: palette.hairline, alignItems: "center", justifyContent: "center" }}>
      <SerifText style={{ color: palette.sindoor, fontFamily: "Fraunces-Bold", fontSize: size * 0.32 }}>{rashiMeta[rashi].glyph}</SerifText>
    </View>
  );
}

function RashiChip({ rashi, selected, onPress }: { rashi: RashiKey; selected: boolean; onPress: () => void }) {
  return (
    <PressableScale onPress={onPress} style={{ width: 76, minHeight: 84, alignItems: "center", justifyContent: "center", gap: 6, borderRadius: 8, backgroundColor: selected ? "rgba(242, 169, 59, 0.22)" : "transparent" }}>
      <RashiBadge rashi={rashi} size={46} />
      <AppText style={{ fontSize: 12, color: selected ? palette.sindoor : palette.inkSecondary, textAlign: "center" }}>{rashiMeta[rashi].short}</AppText>
    </PressableScale>
  );
}

function ScoreRow({ label, value }: { label: string; value: number }) {
  return (
    <View style={{ gap: 6 }}>
      <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
        <AppText style={{ color: palette.inkSecondary, textTransform: "capitalize" }}>{label}</AppText>
        <AppText style={{ fontFamily: "Inter-Bold", fontVariant: ["tabular-nums"] }}>{value}</AppText>
      </View>
      <View style={{ height: 7, borderRadius: 4, backgroundColor: palette.bgSunken, overflow: "hidden" }}>
        <View style={{ height: 7, width: `${value}%`, backgroundColor: palette.marigold }} />
      </View>
    </View>
  );
}

function MemberPanel({ member }: { member: FamilyMember }) {
  const app = useAppState();
  const kundali = member.kundali ?? computeKundali(member.birth ?? { year: 1990, month: 1, day: 1, hour: 6, minute: 0, timeKnown: false, place: { name: "Kathmandu", nameNE: "काठमाडौं", latitude: 27.7172, longitude: 85.324, utcOffsetHours: 5.75 } });
  return (
    <Panel>
      <View style={{ flexDirection: "row", alignItems: "center", gap: 14 }}>
        <RashiBadge rashi={kundali.moonRashi} />
        <View style={{ flex: 1, gap: 4 }}>
          <AppText style={{ fontFamily: "Inter-Bold", fontSize: 18 }}>{member.name}</AppText>
          <AppText style={{ color: palette.inkSecondary }}>{member.relation}</AppText>
        </View>
      </View>
      <InfoRow label={t("family.lagna", app.language)} value={rashiName(kundali.lagna, app.language)} />
      <InfoRow label={t("family.rashi", app.language)} value={rashiName(kundali.moonRashi, app.language)} />
      <InfoRow label={t("family.nakshatra", app.language)} value={app.language === "ne" ? nakshatrasNE[kundali.moonNakshatraIndex] : nakshatrasEN[kundali.moonNakshatraIndex]} />
      <Hairline />
    </Panel>
  );
}

function ChatBubble({ message }: { message: { isUser: boolean; text: string } }) {
  return (
    <View style={{ alignSelf: message.isUser ? "flex-end" : "flex-start", maxWidth: "88%", backgroundColor: message.isUser ? palette.saffron : palette.bgSunken, borderRadius: 18, borderCurve: "continuous", paddingHorizontal: 14, paddingVertical: 11 }}>
      <AppText style={{ color: palette.inkPrimary, lineHeight: 22 }}>{message.text}</AppText>
    </View>
  );
}

function EventRow({ event }: { event: PatroEvent }) {
  return (
    <View style={{ gap: 4, paddingVertical: 4 }}>
      <AppText style={{ fontFamily: "Inter-SemiBold" }}>{event.title}</AppText>
      <AppText style={{ color: palette.inkSecondary }}>{`${event.bsDate.year}/${event.bsDate.month}/${event.bsDate.day}${event.repeatsYearly ? " · yearly" : ""}`}</AppText>
    </View>
  );
}

function greeting(language: "en" | "ne") {
  const hour = new Date().getHours();
  if (language === "ne") return hour < 12 ? "शुभ प्रभात" : hour < 18 ? "नमस्ते" : "शुभ सन्ध्या";
  return hour < 12 ? "Shubha Prabhat" : hour < 18 ? "Namaste" : "Shubha Sandhya";
}

function rashiName(rashi: RashiKey, language: "en" | "ne") {
  return language === "ne" ? rashiMeta[rashi].ne : rashiMeta[rashi].en;
}
