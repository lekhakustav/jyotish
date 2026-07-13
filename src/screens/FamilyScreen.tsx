import React from "react";
import { ScrollView, View, type LayoutChangeEvent } from "react-native";
import Svg, { Line } from "react-native-svg";
import { AppText, Hairline, PressableScale, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon, RashiMark } from "../ornaments";
import { useAppState } from "../app-state";
import { layoutMetrics, palette, spacing } from "../theme";
import type { FamilyMember, Language, Relation } from "../types";
import { MemberDetailScreen } from "./MemberDetailScreen";

type FamilyScreenProps = {
  onAddMember?: () => void;
  onOpenMember?: (memberId: string) => void;
};

const relationLabels: Record<Relation, Record<Language, string>> = {
  selfMember: { en: "You", ne: "तपाईं" },
  father: { en: "Father", ne: "बुबा" },
  mother: { en: "Mother", ne: "आमा" },
  husband: { en: "Husband", ne: "श्रीमान्" },
  wife: { en: "Wife", ne: "श्रीमती" },
  son: { en: "Son", ne: "छोरा" },
  daughter: { en: "Daughter", ne: "छोरी" },
  brother: { en: "Brother", ne: "दाजु/भाइ" },
  sister: { en: "Sister", ne: "दिदी/बहिनी" },
  cousin: { en: "Cousin", ne: "दाजुभाइ/दिदीबहिनी" }
};

export function relationLabel(relation: Relation, language: Language) {
  return relationLabels[relation][language];
}

/**
 * Android counterpart of FamilyView.swift. It keeps the tree and the member
 * list flat, measures the available tree width, and routes a press to the
 * member's real saved kundali instead of rendering a placeholder chart.
 */
export function FamilyScreen({ onAddMember, onOpenMember }: FamilyScreenProps = {}) {
  const app = useAppState();
  const [openedMemberId, setOpenedMemberId] = React.useState<string>();
  const [treeWidth, setTreeWidth] = React.useState(0);

  const openMember = React.useCallback((memberId: string) => {
    app.selectMember(memberId);
    if (onOpenMember) onOpenMember(memberId);
    else setOpenedMemberId(memberId);
  }, [app, onOpenMember]);

  if (openedMemberId && !onOpenMember) {
    return (
      <MemberDetailScreen
        memberId={openedMemberId}
        onBack={() => {
          setOpenedMemberId(undefined);
          app.selectMember(undefined);
        }}
      />
    );
  }

  const self = app.family.find((member) => member.relation === "selfMember");
  const parents = app.family.filter((member) => member.relation === "father" || member.relation === "mother");
  const peers = app.family.filter((member) => ["husband", "wife", "brother", "sister", "cousin"].includes(member.relation));
  const children = app.family.filter((member) => member.relation === "son" || member.relation === "daughter");
  const hasTree = parents.length + peers.length + children.length > 0;

  return (
    <ScrollScreen bottomInset={112} contentGap={20} topInset={8}>
      <View style={styles.header}>
        <SerifText style={styles.title}>{app.language === "ne" ? "परिवार" : "Parivar"}</SerifText>
        <PressableScale
          accessibilityLabel={app.language === "ne" ? "परिवार सदस्य थप्नुहोस्" : "Add family member"}
          onPress={onAddMember ?? (() => app.openModal("profile"))}
          style={styles.headerAction}
        >
          <AppIcon name="plus" size={27} color={palette.saffron} strokeWidth={2.1} />
        </PressableScale>
      </View>

      {hasTree ? (
        <View
          accessibilityLabel={app.language === "ne" ? "परिवार वृक्ष" : "Family tree"}
          onLayout={(event: LayoutChangeEvent) => setTreeWidth(event.nativeEvent.layout.width)}
          style={{ gap: 8, paddingTop: 4, paddingBottom: 12 }}
        >
          {parents.length > 0 ? (
            <>
              <TreeRow members={parents} language={app.language} width={treeWidth} onOpen={openMember} />
              <TreeBranch width={treeWidth} upperCount={parents.length} lowerCount={1} />
            </>
          ) : null}

          <View style={{ alignItems: "center" }}>
            <FamilyNode member={self} language={app.language} size={72} onPress={self ? () => openMember(self.id) : undefined} />
          </View>

          {peers.length > 0 ? (
            <TreeRow members={peers} language={app.language} width={treeWidth} size={58} onOpen={openMember} />
          ) : null}

          {children.length > 0 ? (
            <>
              <TreeBranch width={treeWidth} upperCount={1} lowerCount={children.length} />
              <TreeRow members={children} language={app.language} width={treeWidth} onOpen={openMember} />
            </>
          ) : null}
        </View>
      ) : null}

      <View>
        {app.family.length === 0 ? (
          <View style={{ alignItems: "center", gap: 10, paddingVertical: spacing.xl }}>
            <AppIcon name="family" size={36} color={palette.templeGold} />
            <SerifText style={{ fontSize: 20, textAlign: "center" }}>
              {app.language === "ne" ? "पहिलो परिवार सदस्य थप्नुहोस्" : "Add your first family member"}
            </SerifText>
          </View>
        ) : app.family.map((member, index) => (
          <React.Fragment key={member.id}>
            <MemberRow member={member} language={app.language} onPress={() => openMember(member.id)} />
            {index < app.family.length - 1 ? <Hairline /> : null}
          </React.Fragment>
        ))}
      </View>
    </ScrollScreen>
  );
}

function TreeRow({ members, language, width, size = 64, onOpen }: {
  members: FamilyMember[];
  language: Language;
  width: number;
  size?: number;
  onOpen: (memberId: string) => void;
}) {
  const contentWidth = Math.max(width, members.length * (size + 42));
  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ width: contentWidth }}>
      {members.map((member) => (
        <View key={member.id} style={{ flex: 1, alignItems: "center" }}>
          <FamilyNode member={member} language={language} size={size} onPress={() => onOpen(member.id)} />
        </View>
      ))}
    </ScrollView>
  );
}

function TreeBranch({ width, upperCount, lowerCount }: { width: number; upperCount: number; lowerCount: number }) {
  if (!width) return <View style={{ height: 38 }} />;
  const xs = (count: number) => Array.from({ length: count }, (_, index) => width * (index + 0.5) / count);
  const upper = xs(upperCount);
  const lower = xs(lowerCount);
  const bridge = [...upper, ...lower];
  const min = Math.min(...bridge);
  const max = Math.max(...bridge);
  const mid = 18;
  return (
    <Svg width={width} height={38} accessible={false}>
      {upper.map((x) => <Line key={`u-${x}`} x1={x} y1={0} x2={x} y2={mid} stroke={palette.templeGold} strokeOpacity={0.34} strokeWidth={1} />)}
      {bridge.length > 1 ? <Line x1={min} y1={mid} x2={max} y2={mid} stroke={palette.templeGold} strokeOpacity={0.34} strokeWidth={1} /> : null}
      {lower.map((x) => <Line key={`l-${x}`} x1={x} y1={mid} x2={x} y2={38} stroke={palette.templeGold} strokeOpacity={0.34} strokeWidth={1} />)}
    </Svg>
  );
}

function FamilyNode({ member, language, size, onPress }: {
  member?: FamilyMember;
  language: Language;
  size: number;
  onPress?: () => void;
}) {
  return (
    <PressableScale
      disabled={!onPress}
      onPress={onPress}
      accessibilityLabel={member ? `${member.name}, ${relationLabel(member.relation, language)}` : relationLabel("selfMember", language)}
      style={{ width: size + 34, alignItems: "center", gap: 5 }}
    >
      <View style={{ width: size, height: size, borderRadius: size / 2, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center" }}>
        <AppIcon name={member?.relation === "husband" || member?.relation === "wife" ? "family" : "profile"} size={size * 0.34} color={palette.saffron} strokeWidth={1.7} />
      </View>
      <SerifText numberOfLines={1} style={{ fontFamily: "Fraunces-Bold", fontSize: 13, textAlign: "center" }}>
        {member?.name ?? relationLabel("selfMember", language)}
      </SerifText>
      <AppText numberOfLines={1} style={{ color: palette.inkSecondary, fontSize: 13, textAlign: "center" }}>
        {member ? relationLabel(member.relation, language) : relationLabel("selfMember", language)}
      </AppText>
    </PressableScale>
  );
}

function MemberRow({ member, language, onPress }: { member: FamilyMember; language: Language; onPress: () => void }) {
  return (
    <PressableScale
      onPress={onPress}
      accessibilityLabel={`${member.name}, ${relationLabel(member.relation, language)}`}
      style={styles.memberRow}
    >
      {member.kundali ? (
        <RashiMark rashi={member.kundali.moonRashi} size={46} />
      ) : (
        <View style={styles.emptySeal}><AppIcon name="profile" size={21} color={palette.inkSecondary} /></View>
      )}
      <View style={{ flex: 1, gap: 2 }}>
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18 }}>{member.name}</SerifText>
        <AppText style={{ color: palette.inkSecondary, fontSize: 13 }}>{relationLabel(member.relation, language)}</AppText>
      </View>
      {member.kundali ? (
        <View style={styles.kundaliAction}>
          <AppIcon name="sparkle" size={15} color={palette.sindoor} />
          <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold", fontSize: 13 }}>
            {language === "ne" ? "कुण्डली हेर्नुहोस्" : "See Kundli"}
          </AppText>
        </View>
      ) : <AppIcon name="chevron-right" size={18} color={palette.templeGold} />}
    </PressableScale>
  );
}

const styles = {
  header: { minHeight: 48, flexDirection: "row" as const, alignItems: "center" as const, justifyContent: "space-between" as const, gap: spacing.md },
  title: { fontFamily: "Fraunces-Bold", fontSize: 34, flexShrink: 1 },
  headerAction: { width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center" as const, justifyContent: "center" as const },
  memberRow: { minHeight: 72, paddingVertical: 12, flexDirection: "row" as const, alignItems: "center" as const, gap: 14 },
  emptySeal: { width: 46, height: 46, borderRadius: 23, borderWidth: 1, borderStyle: "dashed" as const, borderColor: palette.hairline, alignItems: "center" as const, justifyContent: "center" as const },
  kundaliAction: { minHeight: 40, borderRadius: 20, borderCurve: "continuous" as const, backgroundColor: palette.bgSunken, paddingHorizontal: 11, flexDirection: "row" as const, gap: 6, alignItems: "center" as const, justifyContent: "center" as const }
};
