import React from "react";
import { ScrollView, View } from "react-native";
import Svg, { Path } from "react-native-svg";
import { generateRashifal, rashiMeta, rashiOrder } from "../astro";
import { useAppState } from "../app-state";
import { AppText, Hairline, PressableScale, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { RashiMark, YantraScore } from "../ornaments";
import { digits, t } from "../l10n";
import { palette } from "../theme";
import type { Language, RashiKey } from "../types";

type Period = "daily" | "weekly" | "monthly" | "yearly";

type EnhancedApp = ReturnType<typeof useAppState> & {
  openPandit?: (prompt?: string, sourceKey?: string) => void;
};

const periods: Period[] = ["daily", "weekly", "monthly", "yearly"];
const domains = ["career", "family", "health", "wealth", "love"] as const;

const domainLabels: Record<Language, Record<(typeof domains)[number], string>> = {
  en: { career: "Career", family: "Family", health: "Health", wealth: "Wealth", love: "Love" },
  ne: { career: "पेशा", family: "परिवार", health: "स्वास्थ्य", wealth: "धन", love: "प्रेम" }
};

export function RashifalScreen() {
  const app = useAppState() as EnhancedApp;
  const [period, setPeriod] = React.useState<Period>("daily");
  const [rashi, setRashi] = React.useState<RashiKey>(
    app.family.find((member) => member.relation === "selfMember")?.kundali?.moonRashi ?? "mesh"
  );
  const reading = generateRashifal(rashi, period, app.language);
  const scores = Object.fromEntries(
    domains.map((domain) => [domain, Math.max(1, Math.min(5, Math.round(reading.scores[domain] ?? 3)))])
  ) as Record<(typeof domains)[number], number>;
  const weakest = domains.reduce((current, domain) => scores[domain] < scores[current] ? domain : current, domains[0]);
  const cta = contextualCTA(weakest, period, app.language);
  const prompt = contextualPrompt(weakest, scores[weakest], period, app.language);

  const openPandit = () => {
    const sourceKey = `rashifal:${new Date().toISOString().slice(0, 10)}:${period}:${rashi}`;
    if (app.openPandit) {
      app.openPandit(prompt, sourceKey);
      return;
    }
    app.openModal("chat");
  };

  return (
    <ScrollScreen bottomInset={132} contentContainerStyle={{ gap: 28 }}>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 34, paddingTop: 8 }}>
        {t("rashifal.title", app.language)}
      </SerifText>

      <View style={{ flexDirection: "row", gap: 6, padding: 4, borderRadius: 28, backgroundColor: palette.bgSunken }}>
        {periods.map((item) => {
          const selected = item === period;
          return (
            <PressableScale
              key={item}
              accessibilityRole="button"
              accessibilityState={{ selected }}
              onPress={() => setPeriod(item)}
              style={{
                flex: 1,
                minHeight: 42,
                alignItems: "center",
                justifyContent: "center",
                borderRadius: 22,
                backgroundColor: selected ? palette.saffron : "transparent",
                paddingHorizontal: 5
              }}
            >
              <AppText
                numberOfLines={1}
                adjustsFontSizeToFit
                minimumFontScale={0.78}
                style={{
                  color: selected ? palette.inkPrimary : palette.inkSecondary,
                  fontFamily: selected ? "Inter-SemiBold" : "Inter-Regular",
                  fontSize: 14
                }}
              >
                {t(`rashifal.${item}`, app.language)}
              </AppText>
            </PressableScale>
          );
        })}
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: 14, paddingVertical: 4 }}
      >
        {rashiOrder.map((item) => {
          const selected = item === rashi;
          return (
            <PressableScale
              key={item}
              accessibilityRole="button"
              accessibilityState={{ selected }}
              accessibilityLabel={rashiName(item, app.language)}
              onPress={() => setRashi(item)}
              style={{ width: 58, alignItems: "center", gap: 5, paddingBottom: 4 }}
            >
              <RashiMark rashi={item} size={48} />
              <AppText
                numberOfLines={1}
                adjustsFontSizeToFit
                minimumFontScale={0.7}
                style={{
                  color: selected ? palette.sindoor : palette.inkSecondary,
                  fontFamily: selected ? "Inter-SemiBold" : "Inter-Regular",
                  fontSize: 13
                }}
              >
                {rashiName(item, app.language)}
              </AppText>
              <View style={{ width: "100%", height: 2, borderRadius: 1, backgroundColor: selected ? palette.saffron : "transparent" }} />
            </PressableScale>
          );
        })}
      </ScrollView>

      <View style={{ gap: 24 }}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 14 }}>
          <RashiMark rashi={rashi} size={58} />
          <View style={{ flex: 1, gap: 2 }}>
            <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 26 }}>
              {rashiName(rashi, app.language)}
            </SerifText>
            <AppText style={{ color: palette.templeGold, fontSize: 14 }}>{reading.timeline}</AppText>
          </View>
        </View>

        <SerifText style={{ fontSize: 17, lineHeight: 29 }}>{reading.text}</SerifText>

        <SerifText style={{ color: palette.inkSecondary, fontFamily: "Fraunces-Medium", fontSize: 15, lineHeight: 24 }}>
          {panditTeaser(weakest, scores[weakest], period, app.language)}
        </SerifText>

        <PressableScale
          accessibilityRole="button"
          onPress={openPandit}
          style={{
            minHeight: 52,
            borderRadius: 16,
            backgroundColor: palette.saffron,
            flexDirection: "row",
            alignItems: "center",
            gap: 8,
            paddingHorizontal: 16
          }}
        >
          <ChatIcon />
          <AppText numberOfLines={2} style={{ flex: 1, color: palette.inkPrimary, fontFamily: "Inter-SemiBold", fontSize: 15 }}>
            {cta}
          </AppText>
          <ArrowUpRightIcon />
        </PressableScale>

        <View style={{ gap: 10 }}>
          {domains.map((domain) => (
            <View key={domain} style={{ minHeight: 22, flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 16 }}>
              <AppText style={{ color: palette.inkSecondary, fontSize: 15 }}>{domainLabels[app.language][domain]}</AppText>
              <YantraScore score={scores[domain]} size={12.5} />
            </View>
          ))}
        </View>

        <View style={{ flexDirection: "row", gap: 10 }}>
          <LuckyFact
            label={app.language === "ne" ? "शुभ रङ" : "Lucky color"}
            value={reading.luckyColor}
          />
          <LuckyFact
            label={app.language === "ne" ? "शुभ अंक" : "Lucky number"}
            value={digits(reading.luckyNumber, app.language)}
          />
          <LuckyFact
            label={app.language === "ne" ? "शुभ दिन" : "Lucky day"}
            value={reading.luckyDay}
          />
        </View>

        <View style={{ gap: 10 }}>
          <Hairline />
          <SerifText style={{ fontSize: 15, fontStyle: "italic", lineHeight: 24 }}>{reading.upaya}</SerifText>
        </View>
      </View>
    </ScrollScreen>
  );
}

function LuckyFact({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flex: 1, gap: 6, paddingVertical: 4 }}>
      <AppText numberOfLines={1} adjustsFontSizeToFit minimumFontScale={0.8} style={{ color: palette.inkSecondary, fontSize: 13 }}>
        {label}
      </AppText>
      <SerifText numberOfLines={2} adjustsFontSizeToFit minimumFontScale={0.75} style={{ fontFamily: "Fraunces-SemiBold", fontSize: 15 }}>
        {value}
      </SerifText>
    </View>
  );
}

function rashiName(rashi: RashiKey, language: Language) {
  return language === "ne" ? rashiMeta[rashi].ne : rashiMeta[rashi].short;
}

function contextualCTA(domain: (typeof domains)[number], period: Period, language: Language) {
  if (language === "ne") return `${domainLabels.ne[domain]} र मेरो दशाबारे सोध्नुहोस्`;
  return `Ask how ${domainLabels.en[domain].toLowerCase()} connects to my dasha`;
}

function contextualPrompt(domain: (typeof domains)[number], score: number, period: Period, language: Language) {
  if (language === "ne") {
    return `मेरो ${t(`rashifal.${period}`, "ne")} राशिफलमा ${domainLabels.ne[domain]} ${score}/5 छ। यो मेरो कुण्डली र हालको दशासँग कसरी जोडिन्छ, र मैले के गर्नुपर्छ?`;
  }
  return `My ${period} rashifal gives ${domain} ${score}/5. How does that connect with my kundli and current dasha, and what should I do?`;
}

function panditTeaser(domain: (typeof domains)[number], score: number, period: Period, language: Language) {
  if (language === "ne") {
    return `यस ${t(`rashifal.${period}`, "ne")} पढाइमा ${domainLabels.ne[domain]} ${score}/5 छ। ज्योतिष बाजेले यसलाई तपाईंको हालको दशा र परिवारको कुण्डलीसँग जोडेर बुझाउन सक्छन्।`;
  }
  return `${domainLabels.en[domain]} is ${score}/5 in this ${period} reading. Jyotish Baje can connect it with your current dasha and family chart.`;
}

function ChatIcon() {
  return (
    <Svg width={18} height={18} viewBox="0 0 24 24" accessibilityElementsHidden>
      <Path d="M4 5.5h11.5v8H9l-4 3v-3H4zM15 9h5v7.5h-2V19l-3.5-2.5H11" stroke={palette.inkPrimary} strokeWidth={1.7} strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </Svg>
  );
}

function ArrowUpRightIcon() {
  return (
    <Svg width={14} height={14} viewBox="0 0 14 14" accessibilityElementsHidden>
      <Path d="M3 11 11 3M5 3h6v6" stroke={palette.inkPrimary} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </Svg>
  );
}
