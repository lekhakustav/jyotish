import React from "react";
import { Image, ScrollView, View } from "react-native";
import Svg, { Circle, Line, Path } from "react-native-svg";
import { generateRashifal, panchangaFor, rashiMeta } from "../astro";
import { useAppState } from "../app-state";
import { AppText, PressableScale, SectionLabel, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon, RashiMark, YantraScore } from "../ornaments";
import { digits, displayName, t } from "../l10n";
import { palette } from "../theme";
import type { Kundali, Language, RashiKey } from "../types";
import { adToBs } from "./PatroScreen";
import { RelationshipAndFeatureHub } from "./FeatureHub";

type EnhancedApp = ReturnType<typeof useAppState> & {
  openPandit?: (prompt?: string, sourceKey?: string) => void;
};

export function HomeScreen() {
  const app = useAppState() as EnhancedApp;
  const self = app.family.find((member) => member.relation === "selfMember");
  const rashi = self?.kundali?.moonRashi ?? "mesh";
  const reading = generateRashifal(rashi, "daily", app.language);
  const panchanga = panchangaFor(new Date(), app.language);
  const bs = adToBs(new Date());
  const tithi = localizedTithi(panchanga.tithiNumber, app.language);
  const relatives = app.family.filter((member) => member.relation !== "selfMember");
  const scoreValues = Object.values(reading.scores);
  const calculatedScore = scoreValues.length
    ? Math.max(1, Math.min(5, Math.round(scoreValues.reduce((sum, value) => sum + value, 0) / scoreValues.length)))
    : 3;

  const openPandit = (prompt?: string, sourceKey?: string) => {
    if (app.openPandit) {
      app.openPandit(prompt, sourceKey);
      return;
    }
    app.openModal("chat");
  };

  return (
    <ScrollScreen bottomInset={132} contentContainerStyle={{ gap: 36 }}>
      <View style={{ flexDirection: "row", alignItems: "flex-start", justifyContent: "space-between" }}>
        <View style={{ flex: 1, gap: 2, paddingTop: 8 }}>
          <SerifText style={{ color: palette.templeGold, fontFamily: "Fraunces-Medium", fontSize: 16 }}>
            {greeting(app.language)}
          </SerifText>
          {self?.name ? (
            <SerifText numberOfLines={1} adjustsFontSizeToFit minimumFontScale={0.75} style={{ fontFamily: "Fraunces-Bold", fontSize: 26 }}>
              {displayName(self.name, app.language)}
            </SerifText>
          ) : null}
        </View>
        <PressableScale
          accessibilityLabel={t("settings.title", app.language)}
          onPress={() => app.openModal("settings")}
          style={{ width: 48, height: 48, alignItems: "center", justifyContent: "center" }}
        >
          <GearIcon />
        </PressableScale>
      </View>

      <PressableScale
        accessibilityRole="button"
        onPress={() => app.setSelectedTab("rashifal")}
        style={{ width: "100%", gap: 14 }}
      >
        <View style={{ flexDirection: "row", alignItems: "center", gap: 14 }}>
          <RashiMark rashi={rashi} size={52} />
          <SerifText style={{ flex: 1, fontFamily: "Fraunces-SemiBold", fontSize: 22 }}>
            {rashiName(rashi, app.language)}
          </SerifText>
          <YantraScore score={calculatedScore} size={12.5} />
        </View>
        <SerifText numberOfLines={3} style={{ fontFamily: "Fraunces-Medium", fontSize: 18, lineHeight: 28 }}>
          {firstSentence(reading.text)}
        </SerifText>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 4 }}>
          <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold", fontSize: 15 }}>
            {app.language === "ne" ? "थप पढ्नुहोस्" : "Read more"}
          </AppText>
          <ChevronIcon color={palette.sindoor} />
        </View>
        {self?.kundali ? (
          <AppText style={{ color: palette.inkSecondary, fontSize: 13 }}>
            {currentDashaLine(self.kundali, app.language)}
          </AppText>
        ) : null}
      </PressableScale>

      <RelationshipAndFeatureHub />

      <View style={{ gap: 18 }}>
        <View style={{ gap: 12 }}>
          <View style={{ flexDirection: "row", alignItems: "baseline", gap: 8 }}>
            <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 20 }}>
              {`${digits(bs.day, app.language)} ${bsMonthName(bs.month, app.language)}`}
            </SerifText>
            <AppText style={{ color: palette.inkSecondary }}>·</AppText>
            <SerifText numberOfLines={1} style={{ flex: 1, color: palette.inkSecondary, fontFamily: "Fraunces-Medium", fontSize: 14 }}>
              {`${tithi.name} · ${tithi.paksha}`}
            </SerifText>
          </View>
          <PressableScale
            onPress={() => app.openModal("patro")}
            style={{ minHeight: 44, flexDirection: "row", alignItems: "center", gap: 6 }}
          >
            <SerifText style={{ color: palette.saffron, fontFamily: "Fraunces-SemiBold", fontSize: 15 }}>
              {t("home.openPatro", app.language)}
            </SerifText>
            <ChevronIcon color={palette.saffron} />
          </PressableScale>
        </View>

        <PressableScale onPress={() => undefined} style={{ gap: 12 }}>
          <Image
            source={require("../../assets/expo/images/temple-pashupatinath-card.jpg")}
            resizeMode="cover"
            resizeMethod="resize"
            fadeDuration={0}
            style={{ width: "100%", aspectRatio: 4 / 3, borderRadius: 20 }}
          />
          <SerifText style={{ color: palette.templeGold, fontFamily: "Fraunces-Medium", fontSize: 14, lineHeight: 22 }}>
            {templeTithiConnection(tithi.name, panchanga.tithiNumber, app.language)}
          </SerifText>
          <SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 21 }}>
            {app.language === "ne" ? "पशुपतिनाथ" : "Pashupatinath"}
          </SerifText>
          <SerifText numberOfLines={4} style={{ color: palette.inkSecondary, fontSize: 14, lineHeight: 22 }}>
            {app.language === "ne"
              ? "स्थिरता, परिवारको रक्षा र सही समयका लागि शान्त बिहानको दर्शन।"
              : "A quiet morning darshan for steadiness, family protection, and right timing."}
          </SerifText>
        </PressableScale>
      </View>

      {relatives.length ? (
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{ gap: 16 }}
        >
          {relatives.map((member) => (
            <PressableScale
              key={member.id}
              accessibilityLabel={displayName(member.name, app.language)}
              onPress={() => app.setSelectedTab("family")}
              style={{ width: 62, alignItems: "center", gap: 5 }}
            >
              {member.kundali ? <RashiMark rashi={member.kundali.moonRashi} size={50} /> : <EmptyRashiMark />}
              <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 13 }}>
                {displayName(member.name, app.language)}
              </AppText>
            </PressableScale>
          ))}
        </ScrollView>
      ) : null}

      {app.events.length ? (
        <View>
          <SectionLabel>{t("home.upcoming", app.language)}</SectionLabel>
          {app.events.slice(0, 3).map((event, index) => (
            <View
              key={event.id}
              style={{
                minHeight: 52,
                flexDirection: "row",
                alignItems: "center",
                gap: 14,
                borderBottomWidth: index < Math.min(3, app.events.length) - 1 ? 1 : 0,
                borderBottomColor: palette.hairline
              }}
            >
              <SerifText style={{ width: 92, color: palette.sindoor, fontFamily: "Fraunces-Bold" }}>
                {`${digits(event.bsDate.day, app.language)} ${bsMonthName(event.bsDate.month, app.language)}`}
              </SerifText>
              <SerifText style={{ flex: 1 }}>{event.title}</SerifText>
            </View>
          ))}
        </View>
      ) : null}
    </ScrollScreen>
  );
}

function firstSentence(text: string) {
  const match = text.match(/^.*?[.!।](?:\s|$)/);
  return match?.[0]?.trim() || text;
}

function greeting(language: Language) {
  const hour = new Date().getHours();
  if (language === "ne") return hour < 12 ? "शुभ प्रभात" : hour < 18 ? "नमस्ते" : hour < 22 ? "शुभ सन्ध्या" : "शुभ रात्रि";
  return hour < 12 ? "Shubha Prabhat" : hour < 18 ? "Namaste" : hour < 22 ? "Shubha Sandhya" : "Shubha Ratri";
}

function rashiName(rashi: RashiKey, language: Language) {
  return language === "ne" ? rashiMeta[rashi].ne : rashiMeta[rashi].short;
}

const monthNames: Record<Language, string[]> = {
  en: ["Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Asoj", "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chait"],
  ne: ["वैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज", "कात्तिक", "मंसिर", "पुष", "माघ", "फागुन", "चैत"]
};

function bsMonthName(month: number, language: Language) {
  return monthNames[language][Math.max(0, Math.min(11, month - 1))];
}

const tithiNames: Record<Language, string[]> = {
  en: ["Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima"],
  ne: ["प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी", "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी", "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "पूर्णिमा"]
};

function localizedTithi(number: number, language: Language) {
  const inPaksha = ((number - 1) % 15) + 1;
  const shukla = number <= 15;
  const name = inPaksha === 15 && !shukla ? (language === "ne" ? "औंसी" : "Aunsi") : tithiNames[language][inPaksha - 1];
  return { name, paksha: shukla ? (language === "ne" ? "शुक्ल पक्ष" : "Shukla Paksha") : (language === "ne" ? "कृष्ण पक्ष" : "Krishna Paksha") };
}

function templeTithiConnection(tithi: string, number: number, language: Language) {
  const practice = (() => {
    switch (((number - 1) % 15) + 1) {
      case 4: return language === "ne" ? "गणेश आराधना" : "Ganesh worship";
      case 8:
      case 9:
      case 10: return language === "ne" ? "देवी र शक्तिको आराधना" : "Devi and Shakti worship";
      case 11:
      case 12: return language === "ne" ? "विष्णु व्रत र संयम" : "Vishnu vrata and reflection";
      case 13:
      case 14: return language === "ne" ? "शिव साधना र प्रदोष परम्परा" : "Shiva sadhana and Pradosh tradition";
      case 15: return language === "ne" ? "पूर्णिमा वा औँसीको विशेष स्मरण" : "the full- or new-moon observance";
      default: return language === "ne" ? "आजको चन्द्र पक्षअनुसारको श्रद्धा" : "today's lunar observance";
    }
  })();
  return language === "ne"
    ? `आजको ${tithi} को ${practice}सँग जोडेर पशुपतिनाथ रोजिएको हो।`
    : `Pashupatinath is paired with today's ${tithi} through ${practice}.`;
}

const dashaOrder = ["Ketu", "Shukra", "Surya", "Chandra", "Mangal", "Rahu", "Brihaspati", "Shani", "Budha"] as const;
const dashaYears = [7, 20, 6, 10, 7, 18, 16, 19, 17] as const;
const dashaNamesNE = ["केतु", "शुक्र", "सूर्य", "चन्द्र", "मंगल", "राहु", "बृहस्पति", "शनि", "बुध"] as const;

function currentDashaLine(kundali: Kundali, language: Language) {
  const startLord = kundali.moonNakshatraIndex % 9;
  const firstYears = dashaYears[startLord] * (1 - kundali.moonNakshatraFraction);
  const nowJD = Date.now() / 86_400_000 + 2_440_587.5;
  let cursor = kundali.birthJD;
  let mahaIndex = startLord;
  let mahaStart = cursor;
  let mahaEnd = cursor + firstYears * 365.25;

  for (let index = 0; index < 9; index += 1) {
    mahaIndex = (startLord + index) % 9;
    const spanYears = index === 0 ? firstYears : dashaYears[mahaIndex];
    mahaStart = cursor;
    mahaEnd = cursor + spanYears * 365.25;
    if (nowJD >= mahaStart && nowJD < mahaEnd) break;
    cursor = mahaEnd;
  }

  const fullSpan = dashaYears[mahaIndex] * 365.25;
  let antarCursor = mahaEnd - fullSpan;
  let antarIndex = mahaIndex;
  for (let index = 0; index < 9; index += 1) {
    const candidate = (mahaIndex + index) % 9;
    const end = antarCursor + fullSpan * dashaYears[candidate] / 120;
    antarIndex = candidate;
    if (nowJD >= Math.max(antarCursor, mahaStart) && nowJD < Math.min(end, mahaEnd)) break;
    antarCursor = end;
  }

  const names = language === "ne" ? dashaNamesNE : dashaOrder;
  return language === "ne"
    ? `महादशा ${names[mahaIndex]} · अन्तर्दशा ${names[antarIndex]}`
    : `Mahadasha ${names[mahaIndex]} · Antardasha ${names[antarIndex]}`;
}

function GearIcon() {
  return (
    <Svg width={22} height={22} viewBox="0 0 24 24" accessibilityElementsHidden>
      <Circle cx={12} cy={12} r={3.1} stroke={palette.inkSecondary} strokeWidth={1.7} fill="none" />
      <Path d="M12 2.8v2.1M12 19.1v2.1M2.8 12h2.1M19.1 12h2.1M5.5 5.5 7 7M17 17l1.5 1.5M18.5 5.5 17 7M7 17l-1.5 1.5" stroke={palette.inkSecondary} strokeWidth={1.7} strokeLinecap="round" />
      <Circle cx={12} cy={12} r={6.5} stroke={palette.inkSecondary} strokeWidth={1.4} fill="none" />
    </Svg>
  );
}

function ChevronIcon({ color }: { color: string }) {
  return (
    <Svg width={13} height={13} viewBox="0 0 13 13" accessibilityElementsHidden>
      <Path d="m4.5 2.5 4 4-4 4" stroke={color} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </Svg>
  );
}

function EmptyRashiMark() {
  return (
    <View style={{ width: 50, height: 50, borderRadius: 25, borderWidth: 1, borderStyle: "dashed", borderColor: palette.hairline, alignItems: "center", justifyContent: "center" }}>
      <Svg width={20} height={20} viewBox="0 0 24 24" accessibilityElementsHidden>
        <Circle cx={12} cy={8} r={3} stroke={palette.inkSecondary} strokeWidth={1.5} fill="none" />
        <Path d="M6.5 19c.7-4 2.5-6 5.5-6s4.8 2 5.5 6" stroke={palette.inkSecondary} strokeWidth={1.5} strokeLinecap="round" fill="none" />
      </Svg>
    </View>
  );
}
