import React from "react";
import { View } from "react-native";
import { AppText, Hairline, InfoRow, PressableScale, SectionLabel, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon, RashiMark } from "../ornaments";
import { useAppState } from "../app-state";
import { nakshatrasEN, nakshatrasNE, rashiMeta } from "../astro";
import { layoutMetrics, palette, spacing } from "../theme";
import type { Kundali, Language, Relation } from "../types";

export function MemberDetailScreen({ memberId, onBack }: { memberId: string; onBack: () => void }) {
  const app = useAppState();
  const member = app.family.find((candidate) => candidate.id === memberId);

  if (!member) {
    return (
      <ScrollScreen topInset={8}>
        <DetailHeader title={app.language === "ne" ? "सदस्य भेटिएन" : "Member not found"} onBack={onBack} />
      </ScrollScreen>
    );
  }

  if (!member.kundali) {
    return (
      <ScrollScreen topInset={8} contentGap={spacing.lg}>
        <DetailHeader title={member.name} onBack={onBack} />
        <View style={{ alignItems: "center", gap: spacing.md, paddingTop: 72 }}>
          <AppIcon name="profile" size={52} color={palette.templeGold} />
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24, textAlign: "center" }}>
            {app.language === "ne" ? "जन्म विवरण चाहिन्छ" : "Birth details are required"}
          </SerifText>
          <AppText style={{ color: palette.inkSecondary, fontSize: 16, lineHeight: 24, textAlign: "center", maxWidth: 300 }}>
            {app.language === "ne"
              ? "सुरक्षित जन्म मिति, समय र स्थान बिना कुण्डली देखाइँदैन।"
              : "A kundali is not shown until a saved birth date, time, and place are available."}
          </AppText>
        </View>
      </ScrollScreen>
    );
  }

  const kundali = member.kundali;
  const nakshatra = app.language === "ne" ? nakshatrasNE[kundali.moonNakshatraIndex] : nakshatrasEN[kundali.moonNakshatraIndex];
  return (
    <ScrollScreen topInset={8} bottomInset={96} contentGap={20}>
      <DetailHeader title={app.language === "ne" ? "कुण्डली" : "Kundali"} onBack={onBack} />

      <View style={{ alignItems: "center", gap: 7, paddingTop: 4 }}>
        <RashiMark rashi={kundali.moonRashi} size={84} />
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30, textAlign: "center" }}>{member.name}</SerifText>
        <AppText style={{ color: palette.templeGold, fontSize: 15 }}>{relationLabel(member.relation, app.language)}</AppText>
      </View>

      <View style={{ flexDirection: "row", gap: 10 }}>
        <Triad label={app.language === "ne" ? "लग्न" : "Lagna"} value={rashiName(kundali.lagna, app.language)} />
        <Triad label={app.language === "ne" ? "राशि" : "Rashi"} value={rashiName(kundali.moonRashi, app.language)} />
        <Triad label={app.language === "ne" ? "नक्षत्र" : "Nakshatra"} value={nakshatra} />
      </View>

      <View style={{ gap: 12 }}>
        <SectionLabel>{app.language === "ne" ? "कुण्डली सार" : "Chart summary"}</SectionLabel>
        <ChartFact label={app.language === "ne" ? "लग्न" : "Ascendant"} value={rashiName(kundali.lagna, app.language)} rashi={kundali.lagna} />
        <Hairline />
        <ChartFact label={app.language === "ne" ? "चन्द्र राशि" : "Moon rashi"} value={rashiName(kundali.moonRashi, app.language)} rashi={kundali.moonRashi} />
        <Hairline />
        <ChartFact label={app.language === "ne" ? "सूर्य राशि" : "Sun rashi"} value={rashiName(kundali.sunRashi, app.language)} rashi={kundali.sunRashi} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "जन्म विवरण" : "Birth details"}</SectionLabel>
        {member.birth ? (
          <>
            <InfoRow label={app.language === "ne" ? "मिति" : "Date"} value={`${member.birth.year}-${two(member.birth.month)}-${two(member.birth.day)}`} />
            <Hairline />
            <InfoRow
              label={app.language === "ne" ? "समय" : "Time"}
              value={member.birth.timeKnown ? `${two(member.birth.hour)}:${two(member.birth.minute)}` : (app.language === "ne" ? "थाहा छैन" : "Unknown")}
            />
            <Hairline />
            <InfoRow label={app.language === "ne" ? "स्थान" : "Place"} value={app.language === "ne" ? member.birth.place.nameNE : member.birth.place.name} />
          </>
        ) : null}
        <AppText style={{ color: palette.inkSecondary, fontSize: 13, lineHeight: 19, paddingTop: 4 }}>
          {app.language === "ne" ? "यो सार सुरक्षित जन्म विवरणबाट गणना गरिएको हो।" : "This summary is calculated from the saved birth details."}
        </AppText>
      </View>
    </ScrollScreen>
  );
}

function DetailHeader({ title, onBack }: { title: string; onBack: () => void }) {
  return (
    <View style={{ minHeight: 48, flexDirection: "row", alignItems: "center", gap: 8 }}>
      <PressableScale accessibilityLabel="Back" onPress={onBack} style={{ width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center", justifyContent: "center", marginLeft: -12 }}>
        <AppIcon name="chevron-left" size={21} color={palette.saffron} />
      </PressableScale>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30, flex: 1 }}>{title}</SerifText>
    </View>
  );
}

function Triad({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flex: 1, minHeight: 68, alignItems: "center", justifyContent: "center", gap: 4 }}>
      <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontFamily: "Inter-SemiBold", fontSize: 11, textTransform: "uppercase" }}>{label}</AppText>
      <SerifText numberOfLines={1} adjustsFontSizeToFit style={{ color: palette.sindoor, fontFamily: "Fraunces-Bold", fontSize: 16, textAlign: "center" }}>{value}</SerifText>
    </View>
  );
}

function ChartFact({ label, value, rashi }: { label: string; value: string; rashi: Kundali["lagna"] }) {
  return (
    <View style={{ minHeight: 56, flexDirection: "row", alignItems: "center", gap: 14 }}>
      <RashiMark rashi={rashi} size={44} />
      <AppText style={{ color: palette.inkSecondary, flex: 1 }}>{label}</AppText>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 16 }}>{value}</SerifText>
    </View>
  );
}

function rashiName(rashi: Kundali["lagna"], language: Language) {
  return language === "ne" ? rashiMeta[rashi].ne : rashiMeta[rashi].short;
}

const relations: Record<Relation, Record<Language, string>> = {
  selfMember: { en: "You", ne: "तपाईं" }, father: { en: "Father", ne: "बुबा" }, mother: { en: "Mother", ne: "आमा" },
  husband: { en: "Husband", ne: "श्रीमान्" }, wife: { en: "Wife", ne: "श्रीमती" }, son: { en: "Son", ne: "छोरा" },
  daughter: { en: "Daughter", ne: "छोरी" }, brother: { en: "Brother", ne: "दाजु/भाइ" }, sister: { en: "Sister", ne: "दिदी/बहिनी" },
  cousin: { en: "Cousin", ne: "दाजुभाइ/दिदीबहिनी" }
};

function relationLabel(relation: Relation, language: Language) {
  return relations[relation][language];
}

function two(value: number) {
  return String(value).padStart(2, "0");
}
