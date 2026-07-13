import React from "react";
import { Modal, ScrollView, View, useWindowDimensions } from "react-native";
import { useAppState } from "@/app-state";
import { AppText, Hairline, PressableScale, SerifText } from "@/components";
import { homeFeatureIDs, jyotishFeatures, promptForFeature, type JyotishFeature } from "@/features";
import { displayName } from "@/l10n";
import { AppIcon, RashiMark } from "@/ornaments";
import { rashiOrder } from "@/astro";
import { palette } from "@/theme";
import type { FamilyMember } from "@/types";
import { track } from "@/analytics";

export function RelationshipAndFeatureHub() {
  const app = useAppState();
  const relatives = app.family.filter((member) => member.relation !== "selfMember" && member.kundali);
  const [relationshipMemberID, setRelationshipMemberID] = React.useState(relatives[0]?.id);
  const [selected, setSelected] = React.useState<JyotishFeature>();
  const [moreOpen, setMoreOpen] = React.useState(false);
  const relationshipMember = relatives.find((member) => member.id === relationshipMemberID) ?? relatives[0];
  const homeFeatures = homeFeatureIDs.flatMap((id) => jyotishFeatures.filter((feature) => feature.id === id));

  const choose = (feature: JyotishFeature) => {
    track("feature_opened", { feature: feature.id, social: Boolean(feature.social) });
    setMoreOpen(false);
    setSelected(feature);
  };

  return (
    <>
      {relationshipMember ? (
        <RelationshipSection
          member={relationshipMember}
          relatives={relatives}
          language={app.language}
          onMember={setRelationshipMemberID}
          onDetailed={() => choose(jyotishFeatures.find((feature) => feature.id === "relationshipGuidance")!)}
        />
      ) : null}

      <View style={{ gap: 14 }}>
        <View style={{ flexDirection: "row", alignItems: "baseline", justifyContent: "space-between", gap: 12 }}>
          <SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 20 }}>{app.language === "ne" ? "ज्योतिष सुविधाहरू" : "Jyotish tools"}</SerifText>
          <AppText style={{ color: palette.inkSecondary, fontSize: 12 }}>{app.language === "ne" ? "रिपोर्ट तयार हुन्छ" : "Prepared reports"}</AppText>
        </View>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 10 }}>
          {homeFeatures.map((feature) => <FeatureIcon key={feature.id} feature={feature} language={app.language} onPress={() => choose(feature)} />)}
          <FeatureIcon
            feature={{ id: "remedies", icon: "plus", name: { en: "More", ne: "थप" }, description: { en: "", ne: "" }, prompt: { en: "", ne: "" } }}
            language={app.language}
            onPress={() => { track("feature_more_opened"); setMoreOpen(true); }}
          />
        </View>
        <PressableScale onPress={() => app.openPandit()} style={{ minHeight: 56, borderRadius: 16, backgroundColor: palette.saffron, flexDirection: "row", alignItems: "center", gap: 12, paddingHorizontal: 18 }}>
          <AppIcon name="sparkle" size={21} color={palette.inkPrimary} strokeWidth={2} />
          <SerifText style={{ flex: 1, fontFamily: "Fraunces-SemiBold", fontSize: 18 }}>{app.language === "ne" ? "ज्योतिष बाजेलाई जे पनि सोध्नुहोस्" : "Ask Jyotish Baje anything"}</SerifText>
          <AppIcon name="arrow-up-right" size={19} color={palette.inkPrimary} strokeWidth={2} />
        </PressableScale>
      </View>

      <MoreFeaturesModal visible={moreOpen} language={app.language} onClose={() => setMoreOpen(false)} onChoose={choose} />
      <FeatureLaunchModal feature={selected} relatives={relatives} language={app.language} onClose={() => setSelected(undefined)} onAddPerson={() => { setSelected(undefined); app.setSelectedTab("family"); }} onStart={(feature, member) => {
        const prompt = promptForFeature(feature, app.language, member);
        track("feature_chat_started", { feature: feature.id, social: Boolean(feature.social), relation: member?.relation ?? "self" });
        setSelected(undefined);
        requestAnimationFrame(() => app.openPandit(prompt, `feature:${feature.id}:${member?.id ?? "self"}`));
      }} />
    </>
  );
}

function FeatureIcon({ feature, language, onPress }: { feature: JyotishFeature; language: "en" | "ne"; onPress: () => void }) {
  const { width } = useWindowDimensions();
  const itemWidth = Math.floor((Math.min(width, 700) - 48 - 20) / 3);
  return (
    <PressableScale accessibilityRole="button" accessibilityLabel={feature.name[language]} onPress={onPress} style={{ width: itemWidth, minHeight: 106, alignItems: "center", justifyContent: "center", gap: 8, borderRadius: 20, backgroundColor: palette.bgSunken, padding: 8 }}>
      <View style={{ width: 42, height: 42, borderRadius: 21, backgroundColor: "rgba(242, 169, 59, 0.18)", alignItems: "center", justifyContent: "center" }}>
        <AppIcon name={feature.icon} size={22} color={palette.saffron} strokeWidth={1.8} />
      </View>
      <SerifText numberOfLines={2} style={{ fontFamily: "Fraunces-SemiBold", fontSize: 13, lineHeight: 17, textAlign: "center" }}>{feature.name[language]}</SerifText>
    </PressableScale>
  );
}

function RelationshipSection({ member, relatives, language, onMember, onDetailed }: { member: FamilyMember; relatives: FamilyMember[]; language: "en" | "ne"; onMember: (id: string) => void; onDetailed: () => void }) {
  const app = useAppState();
  const self = app.family.find((candidate) => candidate.relation === "selfMember" && candidate.kundali);
  if (!self?.kundali || !member.kundali) return null;
  const index = (rashiOrder.indexOf(self.kundali.moonRashi) + rashiOrder.indexOf(member.kundali.moonRashi) + new Date().getDate()) % 3;
  const readings = language === "ne" ? [
    "आज एकअर्काको कुरा समाधान खोज्नुअघि पूरा सुन्नुहोस्। सानो स्पष्टताले पुरानो तनाव नरम बनाउन सक्छ।",
    "आजको सम्बन्धको बल सहयोग हो। अपेक्षा अनुमान नगरी शब्दमा भन्नुहोस्।",
    "गति फरक हुन सक्छ। एक जनालाई ठाउँ र अर्कोलाई आश्वासन चाहिन सक्छ—दुवैलाई मान्यता दिनुहोस्।"
  ] : [
    "Listen fully before trying to solve anything today. One small clarification can soften an old tension.",
    "Cooperation is the relationship's strength today. Put expectations into words instead of assuming them.",
    "Your pace may differ today. One person may need space and the other reassurance; make room for both."
  ];
  return (
    <View style={{ gap: 13 }}>
      <SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 20 }}>{language === "ne" ? "सम्बन्धहरू" : "Relationships"}</SerifText>
      {relatives.length > 1 ? (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8 }}>
          {relatives.map((candidate) => (
            <PressableScale key={candidate.id} onPress={() => onMember(candidate.id)} style={{ minHeight: 42, justifyContent: "center", paddingHorizontal: 15, borderRadius: 22, backgroundColor: candidate.id === member.id ? palette.saffron : palette.bgSunken }}>
              <AppText style={{ fontFamily: "Inter-SemiBold", color: candidate.id === member.id ? palette.inkPrimary : palette.inkSecondary }}>{displayName(candidate.name, language)}</AppText>
            </PressableScale>
          ))}
        </ScrollView>
      ) : null}
      <PressableScale onPress={onDetailed} style={{ borderRadius: 20, backgroundColor: palette.bgSunken, padding: 18, gap: 12 }}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
          <RashiMark rashi={self.kundali.moonRashi} size={42} />
          <View style={{ flex: 1 }}><SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18 }}>{displayName(self.name, language)} × {displayName(member.name, language)}</SerifText></View>
          <RashiMark rashi={member.kundali.moonRashi} size={42} />
        </View>
        <SerifText style={{ fontSize: 16, lineHeight: 25 }}>{readings[index]}</SerifText>
        <View style={{ flexDirection: "row", gap: 12 }}>
          <AppText style={{ flex: 1, color: palette.peepalGreen, lineHeight: 19 }}>✓ {language === "ne" ? "खुला प्रश्न सोध्नुहोस्" : "Ask an open question"}</AppText>
          <AppText style={{ flex: 1, color: palette.sindoor, lineHeight: 19 }}>× {language === "ne" ? "मन पढेको नठान्नुहोस्" : "Don't mind-read"}</AppText>
        </View>
        <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold" }}>{language === "ne" ? "विस्तृत रिपोर्ट" : "Detailed report"} →</AppText>
      </PressableScale>
    </View>
  );
}

function MoreFeaturesModal({ visible, language, onClose, onChoose }: { visible: boolean; language: "en" | "ne"; onClose: () => void; onChoose: (feature: JyotishFeature) => void }) {
  return <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}><View style={{ flex: 1, backgroundColor: palette.bgCanvas }}><ModalHeader title={language === "ne" ? "लोकप्रिय सुविधाहरू" : "Popular features"} onClose={onClose} /><ScrollView contentContainerStyle={{ paddingHorizontal: 24, paddingBottom: 44 }}>{jyotishFeatures.map((feature, index) => <React.Fragment key={feature.id}><PressableScale onPress={() => onChoose(feature)} style={{ minHeight: 76, flexDirection: "row", alignItems: "center", gap: 14, paddingVertical: 10 }}><View style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center" }}><AppIcon name={feature.icon} size={21} color={palette.saffron} /></View><View style={{ flex: 1, gap: 3 }}><SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 17 }}>{feature.name[language]}</SerifText><AppText numberOfLines={2} style={{ color: palette.inkSecondary, fontSize: 13, lineHeight: 18 }}>{feature.description[language]}</AppText></View><AppIcon name="chevron-right" size={16} color={palette.inkSecondary} /></PressableScale>{index < jyotishFeatures.length - 1 ? <Hairline /> : null}</React.Fragment>)}</ScrollView></View></Modal>;
}

function FeatureLaunchModal({ feature, relatives, language, onClose, onAddPerson, onStart }: { feature?: JyotishFeature; relatives: FamilyMember[]; language: "en" | "ne"; onClose: () => void; onAddPerson: () => void; onStart: (feature: JyotishFeature, member?: FamilyMember) => void }) {
  const [memberID, setMemberID] = React.useState<string>();
  React.useEffect(() => setMemberID(relatives[0]?.id), [feature?.id]);
  if (!feature) return null;
  const member = relatives.find((candidate) => candidate.id === memberID) ?? relatives[0];
  return <Modal visible animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}><View style={{ flex: 1, backgroundColor: palette.bgCanvas }}><ModalHeader title={feature.name[language]} onClose={onClose} /><ScrollView contentContainerStyle={{ padding: 24, paddingBottom: 44, gap: 20 }}><View style={{ width: 64, height: 64, borderRadius: 32, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center" }}><AppIcon name={feature.icon} size={30} color={palette.saffron} /></View><SerifText style={{ color: palette.inkSecondary, fontSize: 17, lineHeight: 27 }}>{feature.description[language]}</SerifText>{feature.social && relatives.length ? <View style={{ gap: 8 }}><SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 18 }}>{language === "ne" ? "व्यक्ति छान्नुहोस्" : "Choose a person"}</SerifText>{relatives.map((candidate) => <PressableScale key={candidate.id} onPress={() => { setMemberID(candidate.id); track("relationship_person_selected", { feature: feature.id, relation: candidate.relation }); }} style={{ minHeight: 58, flexDirection: "row", alignItems: "center", gap: 12 }}><RashiMark rashi={candidate.kundali!.moonRashi} size={38} /><View style={{ flex: 1 }}><SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 17 }}>{displayName(candidate.name, language)}</SerifText></View><AppIcon name={candidate.id === member?.id ? "sparkle" : "profile"} size={18} color={candidate.id === member?.id ? palette.saffron : palette.inkSecondary} /></PressableScale>)}</View> : null}{feature.social && !relatives.length ? <><AppText style={{ color: palette.inkSecondary, lineHeight: 22 }}>{language === "ne" ? "यो रिपोर्टका लागि परिवार, साथी वा पार्टनरको जन्म विवरण थप्नुहोस्।" : "Add a family member, friend, or partner with birth details to create this report."}</AppText><PrimaryButton label={language === "ne" ? "व्यक्ति थप्नुहोस्" : "Add a person"} onPress={onAddPerson} /></> : <PrimaryButton label={language === "ne" ? "ज्योतिष बाजेसँग रिपोर्ट बनाउनुहोस्" : "Prepare with Jyotish Baje"} onPress={() => onStart(feature, feature.social ? member : undefined)} />}</ScrollView></View></Modal>;
}

function ModalHeader({ title, onClose }: { title: string; onClose: () => void }) { return <View style={{ minHeight: 76, paddingHorizontal: 24, flexDirection: "row", alignItems: "center", gap: 10 }}><SerifText numberOfLines={2} style={{ flex: 1, fontFamily: "Fraunces-Bold", fontSize: 27 }}>{title}</SerifText><PressableScale accessibilityLabel="Close" onPress={onClose} style={{ width: 48, height: 48, alignItems: "center", justifyContent: "center" }}><AppIcon name="close" color={palette.inkSecondary} /></PressableScale></View>; }
function PrimaryButton({ label, onPress }: { label: string; onPress: () => void }) { return <PressableScale onPress={onPress} style={{ minHeight: 56, borderRadius: 16, backgroundColor: palette.saffron, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 10, paddingHorizontal: 16 }}><AppIcon name="sparkle" size={19} color={palette.inkPrimary} /><SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 17, textAlign: "center" }}>{label}</SerifText></PressableScale>; }
