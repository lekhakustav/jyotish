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
              <AppText style={{ color: palette.inkSecondary, lineHeight: 24 }}>Jyotish Baje needs these to draw the kundali.</AppText>
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
  const bs = todayBS();
  const relatives = app.family.filter((member) => member.relation !== "selfMember");
  const starters = app.language === "ne"
    ? ["मेरो आजको दिन कस्तो छ?", "शुभ समय कहिले छ?", "परिवारको कुण्डली हेर्नुहोस्"]
    : ["How does today look for me?", "When is my auspicious time?", "Read my family's charts"];
  return (
    <Screen bottomInset={112}>
      <View style={{ flexDirection: "row", alignItems: "flex-start", justifyContent: "space-between" }}>
        <View style={{ gap: 2 }}>
          <SerifText style={{ color: palette.templeGold, fontSize: 16 }}>{greeting(app.language)}</SerifText>
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 26 }}>{self?.name}</SerifText>
        </View>
        <PressableScale accessibilityLabel={t("settings.title", app.language)} onPress={() => app.openModal("settings")} style={{ width: 48, height: 48, alignItems: "center", justifyContent: "center" }}>
          <AppText style={{ color: palette.inkSecondary, fontSize: 22 }}>⚙</AppText>
        </PressableScale>
      </View>

      <PressableScale onPress={() => app.setSelectedTab("rashifal")} style={{ gap: 14 }}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 14 }}>
          <RashiBadge rashi={rashi} size={52} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 22, flex: 1 }}>{rashiName(rashi, app.language)}</SerifText>
          <AppText style={{ color: palette.templeGold, fontFamily: "Inter-SemiBold" }}>✦ ✦ ✦</AppText>
        </View>
        <SerifText style={{ fontSize: 18, lineHeight: 28 }} numberOfLines={3}>{firstSentence(reading.text)}</SerifText>
        <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold" }}>{app.language === "ne" ? "थप पढ्नुहोस्  ›" : "Read more  ›"}</AppText>
      </PressableScale>

      <View style={{ gap: 10 }}>
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 19 }}>{app.language === "ne" ? "ज्योतिष बाजे" : "Jyotish Baje"}</SerifText>
        {starters.map((starter) => (
          <PressableScale key={starter} onPress={() => app.openModal("chat")} style={{ minHeight: 58, justifyContent: "center", borderBottomWidth: 1, borderBottomColor: palette.hairline }}>
            <View style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
              <AppText style={{ color: palette.saffron }}>✦</AppText>
              <SerifText style={{ fontSize: 16, flex: 1 }}>{starter}</SerifText>
              <AppText style={{ color: palette.inkSecondary }}>›</AppText>
            </View>
          </PressableScale>
        ))}
        <PrimaryButton title={app.language === "ne" ? "जे पनि सोध्नुहोस्" : "Ask anything"} icon="✦" onPress={() => app.openModal("chat")} />
      </View>

      <View style={{ gap: 12 }}>
        <View style={{ flexDirection: "row", alignItems: "baseline", gap: 8 }}>
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 20 }}>{`${digits(bs.day, app.language)} / ${digits(bs.month, app.language)}`}</SerifText>
          <AppText style={{ color: palette.inkSecondary }}>·</AppText>
          <SerifText style={{ color: palette.inkSecondary, fontSize: 14, flex: 1 }}>{panchanga.tithi}</SerifText>
        </View>
        <PressableScale onPress={() => app.openModal("patro")} style={{ minHeight: 44, justifyContent: "center" }}>
          <AppText style={{ color: palette.saffron, fontFamily: "Inter-SemiBold" }}>{t("home.openPatro", app.language)}  ›</AppText>
        </PressableScale>
        <Image source={require("../assets/expo/images/temple-pashupatinath-card.jpg")} resizeMode="cover" resizeMethod="resize" fadeDuration={0} style={{ width: "100%", aspectRatio: 4 / 3, borderRadius: 20 }} />
        <SerifText style={{ color: palette.templeGold, fontSize: 14, lineHeight: 22 }}>
          {templeTithiConnection(panchanga.tithi, panchanga.tithiNumber, app.language)}
        </SerifText>
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 21 }}>Pashupatinath</SerifText>
        <SerifText style={{ color: palette.inkSecondary, fontSize: 14, lineHeight: 22 }} numberOfLines={4}>A quiet morning darshan for steadiness, family protection, and right timing.</SerifText>
      </View>

      {relatives.length ? (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 16 }}>
          {relatives.map((member) => (
            <PressableScale key={member.id} onPress={() => app.setSelectedTab("family")} style={{ width: 66, alignItems: "center", gap: 5 }}>
              {member.kundali ? <RashiBadge rashi={member.kundali.moonRashi} size={50} /> : null}
              <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 13 }}>{member.name}</AppText>
            </PressableScale>
          ))}
        </ScrollView>
      ) : null}

      {app.events.length ? (
        <View style={{ gap: 0 }}>
          <SectionLabel>{t("home.upcoming", app.language)}</SectionLabel>
          {app.events.slice(0, 3).map((event, index) => (
            <View key={event.id} style={{ flexDirection: "row", gap: 14, paddingVertical: 12, borderBottomWidth: index < Math.min(3, app.events.length) - 1 ? 1 : 0, borderBottomColor: palette.hairline }}>
              <SerifText style={{ color: palette.sindoor, fontFamily: "Fraunces-Bold", width: 92 }}>{`${digits(event.bsDate.day, app.language)}/${digits(event.bsDate.month, app.language)}`}</SerifText>
              <SerifText style={{ flex: 1 }}>{event.title}</SerifText>
            </View>
          ))}
        </View>
      ) : null}
    </Screen>
  );
}

function firstSentence(text: string) {
  const match = text.match(/^.*?[.!।](?:\s|$)/);
  return match?.[0]?.trim() || text;
}

function templeTithiConnection(tithi: string, number: number, language: "en" | "ne") {
  const practice = (() => {
    switch (((number - 1) % 15) + 1) {
      case 4: return language === "ne" ? "गणेश आराधना" : "Ganesh worship";
      case 8: case 9: case 10: return language === "ne" ? "देवी र शक्तिको आराधना" : "Devi and Shakti worship";
      case 11: case 12: return language === "ne" ? "विष्णु व्रत र संयम" : "Vishnu vrata and reflection";
      case 13: case 14: return language === "ne" ? "शिव साधना र प्रदोष परम्परा" : "Shiva sadhana and Pradosh tradition";
      case 15: return language === "ne" ? "पूर्णिमा वा औँसीको विशेष स्मरण" : "the full- or new-moon observance";
      default: return language === "ne" ? "आजको चन्द्र पक्षअनुसारको श्रद्धा" : "today's lunar observance";
    }
  })();
  return language === "ne"
    ? `आजको ${tithi} को ${practice}सँग जोडेर पशुपतिनाथ रोजिएको हो।`
    : `Pashupatinath is paired with today's ${tithi} through ${practice}.`;
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
      <View style={{ gap: 24 }}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 14 }}>
          <RashiBadge rashi={rashi} size={58} />
          <View style={{ gap: 2 }}>
            <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 26 }}>{rashiName(rashi, app.language)}</SerifText>
            <AppText style={{ color: palette.templeGold }}>{t(`rashifal.${period}`, app.language)}</AppText>
          </View>
        </View>
        <SerifText style={{ fontSize: 17, lineHeight: 28 }}>{reading.text}</SerifText>
        <SerifText style={{ color: palette.inkSecondary, fontSize: 15, lineHeight: 23 }}>Jyotish Baje can connect this reading with your current dasha and family chart.</SerifText>
        <PrimaryButton title={t("home.askPandit", app.language)} icon="✦" onPress={() => app.openModal("chat")} />
        <View style={{ gap: 10 }}>
          {Object.entries(reading.scores).map(([key, value]) => <ScoreRow key={key} label={key} value={value} />)}
        </View>
        <View style={{ flexDirection: "row", gap: 16 }}>
          <LuckyFact label="Lucky color" value={reading.luckyColor} />
          <LuckyFact label="Lucky number" value={digits(reading.luckyNumber, app.language)} />
          <LuckyFact label="Lucky day" value={period === "daily" ? "Today" : "Thursday"} />
        </View>
        <Hairline />
        <SerifText style={{ fontStyle: "italic", lineHeight: 24 }}>{reading.upaya}</SerifText>
      </View>
    </Screen>
  );
}

function LuckyFact({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flex: 1, gap: 6 }}>
      <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 13 }}>{label}</AppText>
      <SerifText numberOfLines={2} style={{ fontFamily: "Fraunces-Bold", fontSize: 15 }}>{value}</SerifText>
    </View>
  );
}

function FamilyScreen() {
  const app = useAppState();
  const self = app.family.find((member) => member.relation === "selfMember");
  const relatives = app.family.filter((member) => member.relation !== "selfMember");
  return (
    <Screen bottomInset={112}>
      <Header title={t("family.title", app.language)} action="+" onAction={() => app.openModal("profile")} />
      {relatives.length ? (
        <View style={{ alignItems: "center", gap: 10, paddingVertical: 4 }}>
          {self ? <FamilyNode member={self} relation={app.language === "ne" ? "तपाईं" : "You"} large /> : null}
          <View style={{ width: 1, height: 30, backgroundColor: palette.hairline }} />
          <View style={{ flexDirection: "row", justifyContent: "center", gap: 16, flexWrap: "wrap" }}>
            {relatives.map((member) => <FamilyNode key={member.id} member={member} relation={member.relation} />)}
          </View>
        </View>
      ) : null}
      <View style={{ gap: 0 }}>
        {app.family.map((member, index) => (
          <View key={member.id} style={{ borderBottomWidth: index < app.family.length - 1 ? 1 : 0, borderBottomColor: palette.hairline }}>
            <MemberPanel member={member} />
          </View>
        ))}
      </View>
    </Screen>
  );
}

function FamilyNode({ member, relation, large = false }: { member: FamilyMember; relation: string; large?: boolean }) {
  const size = large ? 72 : 60;
  return (
    <View style={{ width: size + 34, alignItems: "center", gap: 5 }}>
      <View style={{ width: size, height: size, borderRadius: size / 2, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center" }}>
        <AppText style={{ color: palette.saffron, fontSize: size * 0.34 }}>♙</AppText>
      </View>
      <SerifText numberOfLines={1} style={{ fontFamily: "Fraunces-Bold", fontSize: 13 }}>{member.name}</SerifText>
      <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 13 }}>{relation}</AppText>
    </View>
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
    <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between" }}>
      <AppText style={{ color: palette.inkSecondary, textTransform: "capitalize" }}>{label}</AppText>
      <AppText style={{ color: palette.templeGold, letterSpacing: 3 }}>{Array.from({ length: 5 }, (_, index) => index < Math.max(1, Math.min(5, value)) ? "◆" : "◇").join("")}</AppText>
    </View>
  );
}

function MemberPanel({ member }: { member: FamilyMember }) {
  const app = useAppState();
  const kundali = member.kundali ?? computeKundali(member.birth ?? { year: 1990, month: 1, day: 1, hour: 6, minute: 0, timeKnown: false, place: { name: "Kathmandu", nameNE: "काठमाडौं", latitude: 27.7172, longitude: 85.324, utcOffsetHours: 5.75 } });
  return (
    <PressableScale onPress={() => undefined} style={{ minHeight: 72, flexDirection: "row", alignItems: "center", gap: 14, paddingVertical: 10 }}>
        <RashiBadge rashi={kundali.moonRashi} size={46} />
        <View style={{ flex: 1, gap: 2 }}>
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18 }}>{member.name}</SerifText>
          <AppText style={{ color: palette.inkSecondary }}>{member.relation}</AppText>
        </View>
        <View style={{ minHeight: 40, borderRadius: 20, backgroundColor: palette.bgSunken, paddingHorizontal: 11, alignItems: "center", justifyContent: "center" }}>
          <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold", fontSize: 13 }}>{app.language === "ne" ? "कुण्डली" : "See Kundli"}</AppText>
        </View>
    </PressableScale>
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
