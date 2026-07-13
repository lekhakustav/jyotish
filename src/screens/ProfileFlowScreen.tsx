import React from "react";
import { KeyboardAvoidingView, Platform, ScrollView, View } from "react-native";
import { AppText, Field, Hairline, PressableScale, PrimaryButton, SectionLabel, SerifText } from "../components";
import { FixedScreen } from "../layout";
import { AppIcon, RashiMark } from "../ornaments";
import { useAppState } from "../app-state";
import { birthPlaces, computeKundali, nakshatrasEN, nakshatrasNE, rashiMeta, uuid } from "../astro";
import { layoutMetrics, palette, spacing } from "../theme";
import type { BirthData, BirthPlace, FamilyMember, Gender, Relation } from "../types";
import { relationLabel } from "./FamilyScreen";

type FlowMode = "self" | "family";
type Step = "relation" | "name" | "date" | "time" | "place";

type ProfileFlowScreenProps = {
  mode?: FlowMode;
  editingMember?: FamilyMember;
  onClose?: () => void;
  onDone?: (member: FamilyMember) => void;
};

const familyRelations: Relation[] = ["husband", "wife", "son", "daughter", "father", "mother", "brother", "sister", "cousin", "boyfriend", "girlfriend", "partner", "fiance", "fiancee", "friend", "colleague", "mentor"];

/** One decision per page, matching BirthFlowView.swift's sheet geometry. */
export function ProfileFlowScreen({ mode = "family", editingMember, onClose, onDone }: ProfileFlowScreenProps = {}) {
  const app = useAppState();
  const steps: Step[] = mode === "family" ? ["relation", "name", "date", "time", "place"] : ["name", "date", "time", "place"];
  const [index, setIndex] = React.useState(0);
  const [relation, setRelation] = React.useState<Relation>(editingMember?.relation ?? (mode === "family" ? "son" : "selfMember"));
  const [name, setName] = React.useState(editingMember?.name ?? app.account?.displayName ?? "");
  const birth = editingMember?.birth;
  const [year, setYear] = React.useState(String(birth?.year ?? 1975));
  const [month, setMonth] = React.useState(String(birth?.month ?? 1));
  const [day, setDay] = React.useState(String(birth?.day ?? 1));
  const [timeKnown, setTimeKnown] = React.useState(birth?.timeKnown ?? true);
  const [hour, setHour] = React.useState(String(birth?.hour ?? 6));
  const [minute, setMinute] = React.useState(String(birth?.minute ?? 0));
  const [place, setPlace] = React.useState<BirthPlace>(birth?.place ?? birthPlaces[0]);
  const [revealed, setRevealed] = React.useState<ReturnType<typeof computeKundali>>();
  const step = steps[index];
  const close = onClose ?? app.closeModal;

  const birthData = React.useMemo<BirthData>(() => ({
    year: clampNumber(year, 1900, new Date().getFullYear(), 1975),
    month: clampNumber(month, 1, 12, 1),
    day: clampNumber(day, 1, 31, 1),
    hour: timeKnown ? clampNumber(hour, 0, 23, 6) : 6,
    minute: timeKnown ? clampNumber(minute, 0, 59, 0) : 0,
    timeKnown,
    place
  }), [day, hour, minute, month, place, timeKnown, year]);

  if (revealed) {
    const nakshatra = app.language === "ne" ? nakshatrasNE[revealed.moonNakshatraIndex] : nakshatrasEN[revealed.moonNakshatraIndex];
    return (
      <FixedScreen gutter={24} contentStyle={{ alignItems: "center", justifyContent: "center", gap: 18 }}>
        <RashiMark rashi={revealed.moonRashi} size={104} />
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 34, textAlign: "center" }}>
          {app.language === "ne" ? rashiMeta[revealed.moonRashi].ne : rashiMeta[revealed.moonRashi].short}
        </SerifText>
        <AppText style={{ color: palette.inkSecondary, fontSize: 16, textAlign: "center" }}>
          {`${nakshatra} · ${app.language === "ne" ? "लग्न" : "Lagna"} ${app.language === "ne" ? rashiMeta[revealed.lagna].ne : rashiMeta[revealed.lagna].short}`}
        </AppText>
        <SerifText style={{ color: palette.templeGold, fontSize: 18, textAlign: "center", marginTop: 4 }}>
          {app.language === "ne" ? "तपाईंको कुण्डली तयार भयो।" : "Your kundali is ready."}
        </SerifText>
        <View style={{ width: "100%", marginTop: 22 }}>
          <PrimaryButton
            title={app.language === "ne" ? "सम्पन्न" : "Done"}
            onPress={() => finish({ mode, editingMember, relation, name, birthData, app, onDone, close })}
          />
        </View>
      </FixedScreen>
    );
  }

  return (
    <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : undefined} style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      <FixedScreen gutter={0}>
        <View style={styles.topBar}>
          {index > 0 ? (
            <PressableScale accessibilityLabel="Back" onPress={() => setIndex((value) => value - 1)} style={styles.iconButton}>
              <AppIcon name="chevron-left" size={20} color={palette.inkSecondary} />
            </PressableScale>
          ) : <View style={styles.iconButton} />}
          <View style={{ flexDirection: "row", gap: 8 }} accessible={false}>
            {steps.map((item, dotIndex) => <View key={item} style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: dotIndex <= index ? palette.saffron : palette.hairline }} />)}
          </View>
          <PressableScale accessibilityLabel="Close" onPress={close} style={styles.iconButton}>
            <AppIcon name="close" size={19} color={palette.inkSecondary} />
          </PressableScale>
        </View>

        <ScrollView keyboardShouldPersistTaps="handled" contentContainerStyle={{ paddingHorizontal: 24, paddingTop: 28, paddingBottom: 24, gap: 28 }}>
          <Question step={step} mode={mode} language={app.language} />
          {step === "relation" ? <RelationStep value={relation} onChange={setRelation} language={app.language} /> : null}
          {step === "name" ? <NameStep value={name} onChange={setName} language={app.language} /> : null}
          {step === "date" ? <DateStep year={year} month={month} day={day} setYear={setYear} setMonth={setMonth} setDay={setDay} language={app.language} /> : null}
          {step === "time" ? <TimeStep known={timeKnown} setKnown={setTimeKnown} hour={hour} minute={minute} setHour={setHour} setMinute={setMinute} language={app.language} /> : null}
          {step === "place" ? <PlaceStep value={place} onChange={setPlace} language={app.language} /> : null}
        </ScrollView>

        <View style={{ paddingHorizontal: 24, paddingTop: 8, paddingBottom: 24 }}>
          <PrimaryButton
            title={index === steps.length - 1 ? (app.language === "ne" ? "मेरो कुण्डली बनाउनुहोस्" : "Create kundali") : (app.language === "ne" ? "अगाडि" : "Continue")}
            disabled={step === "name" && !name.trim()}
            onPress={() => {
              if (index < steps.length - 1) setIndex((value) => value + 1);
              else setRevealed(computeKundali(birthData));
            }}
          />
        </View>
      </FixedScreen>
    </KeyboardAvoidingView>
  );
}

function Question({ step, mode, language }: { step: Step; mode: FlowMode; language: "en" | "ne" }) {
  const copy: Record<Step, { script: string; en: string; ne: string; subEN?: string; subNE?: string }> = {
    relation: { script: "नाता", en: "How are they related to you?", ne: "उहाँसँग तपाईंको नाता के हो?" },
    name: { script: "नाम", en: mode === "family" ? "What is their name?" : "What is your name?", ne: mode === "family" ? "उहाँको नाम के हो?" : "तपाईंको नाम के हो?" },
    date: { script: "जन्म मिति", en: "When were they born?", ne: "जन्म मिति कहिले हो?", subEN: "Use the Gregorian date from the birth record.", subNE: "जन्म अभिलेखको इस्वी संवत् मिति लेख्नुहोस्।" },
    time: { script: "जन्म समय", en: "What time were they born?", ne: "जन्म समय कति हो?", subEN: "An exact time improves the ascendant calculation.", subNE: "ठ्याक्कै समयले लग्न गणना सुधार्छ।" },
    place: { script: "जन्म स्थान", en: "Where were they born?", ne: "जन्म स्थान कहाँ हो?" }
  };
  const item = copy[step];
  return (
    <View style={{ gap: 6 }}>
      <SerifText style={{ color: palette.templeGold, fontSize: 15 }}>{item.script}</SerifText>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30, lineHeight: 36 }}>{language === "ne" ? item.ne : item.en}</SerifText>
      {item.subEN ? <AppText style={{ color: palette.inkSecondary, fontSize: 15, lineHeight: 22 }}>{language === "ne" ? item.subNE : item.subEN}</AppText> : null}
    </View>
  );
}

function RelationStep({ value, onChange, language }: { value: Relation; onChange: (relation: Relation) => void; language: "en" | "ne" }) {
  return (
    <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 10 }}>
      {familyRelations.map((relation) => {
        const selected = relation === value;
        return (
          <PressableScale key={relation} onPress={() => onChange(relation)} style={{ width: "48%", minHeight: 56, borderRadius: 14, borderCurve: "continuous", backgroundColor: selected ? "rgba(242,169,59,0.16)" : "transparent", alignItems: "center", justifyContent: "center", paddingHorizontal: 6 }}>
            <SerifText style={{ color: selected ? palette.sindoor : palette.inkPrimary, fontFamily: selected ? "Fraunces-Bold" : "Fraunces-Regular", fontSize: 15, textAlign: "center" }}>{relationLabel(relation, language)}</SerifText>
          </PressableScale>
        );
      })}
    </View>
  );
}

function NameStep({ value, onChange, language }: { value: string; onChange: (value: string) => void; language: "en" | "ne" }) {
  return <Field autoFocus value={value} onChangeText={onChange} placeholder={language === "ne" ? "नाम" : "Name"} style={styles.largeField} returnKeyType="next" />;
}

function DateStep({ year, month, day, setYear, setMonth, setDay, language }: {
  year: string; month: string; day: string;
  setYear: (value: string) => void; setMonth: (value: string) => void; setDay: (value: string) => void;
  language: "en" | "ne";
}) {
  return (
    <View style={{ flexDirection: "row", gap: 10 }}>
      <NumberField label={language === "ne" ? "वर्ष" : "Year"} value={year} onChange={setYear} flex={1.5} />
      <NumberField label={language === "ne" ? "महिना" : "Month"} value={month} onChange={setMonth} />
      <NumberField label={language === "ne" ? "दिन" : "Day"} value={day} onChange={setDay} />
    </View>
  );
}

function TimeStep({ known, setKnown, hour, minute, setHour, setMinute, language }: {
  known: boolean; setKnown: (known: boolean) => void; hour: string; minute: string;
  setHour: (value: string) => void; setMinute: (value: string) => void; language: "en" | "ne";
}) {
  return (
    <View style={{ gap: 18 }}>
      {known ? (
        <View style={{ flexDirection: "row", gap: 10 }}>
          <NumberField label={language === "ne" ? "घण्टा" : "Hour (0–23)"} value={hour} onChange={setHour} />
          <NumberField label={language === "ne" ? "मिनेट" : "Minute"} value={minute} onChange={setMinute} />
        </View>
      ) : null}
      <PressableScale onPress={() => setKnown(!known)} style={{ minHeight: 52, flexDirection: "row", alignItems: "center", gap: 12 }}>
        <View style={{ width: 20, height: 20, borderRadius: 10, borderWidth: known ? 1 : 6, borderColor: known ? palette.hairline : palette.saffron }} />
        <AppText style={{ color: palette.inkSecondary, fontSize: 15 }}>{language === "ne" ? "जन्म समय थाहा छैन" : "Birth time is unknown"}</AppText>
      </PressableScale>
    </View>
  );
}

function PlaceStep({ value, onChange, language }: { value: BirthPlace; onChange: (place: BirthPlace) => void; language: "en" | "ne" }) {
  return (
    <View>
      {birthPlaces.map((place, index) => {
        const selected = place.name === value.name;
        return (
          <React.Fragment key={place.name}>
            <PressableScale onPress={() => onChange(place)} style={{ minHeight: 52, paddingHorizontal: 18, borderRadius: 14, borderCurve: "continuous", backgroundColor: selected ? "rgba(242,169,59,0.14)" : "transparent", flexDirection: "row", alignItems: "center", gap: 12 }}>
              <SerifText style={{ flex: 1, fontFamily: selected ? "Fraunces-Bold" : "Fraunces-Regular", fontSize: 17 }}>{language === "ne" ? place.nameNE : place.name}</SerifText>
              {selected ? <View style={{ width: 9, height: 9, borderRadius: 5, backgroundColor: palette.saffron }} /> : null}
            </PressableScale>
            {index < birthPlaces.length - 1 ? <Hairline /> : null}
          </React.Fragment>
        );
      })}
    </View>
  );
}

function NumberField({ label, value, onChange, flex = 1 }: { label: string; value: string; onChange: (value: string) => void; flex?: number }) {
  return (
    <View style={{ flex, gap: 8 }}>
      <SectionLabel>{label}</SectionLabel>
      <Field keyboardType="number-pad" value={value} onChangeText={(text) => onChange(text.replace(/\D/g, ""))} style={{ fontSize: 20, textAlign: "center" }} />
    </View>
  );
}

function finish({ mode, editingMember, relation, name, birthData, app, onDone, close }: {
  mode: FlowMode;
  editingMember?: FamilyMember;
  relation: Relation;
  name: string;
  birthData: BirthData;
  app: ReturnType<typeof useAppState>;
  onDone?: (member: FamilyMember) => void;
  close: () => void;
}) {
  const cleanName = name.trim();
  if (mode === "self") {
    app.saveSelf(cleanName, birthData);
    const member: FamilyMember = { id: editingMember?.id ?? app.selectedMemberId ?? uuid(), name: cleanName, gender: editingMember?.gender ?? "other", relation: "selfMember", birth: birthData, kundali: computeKundali(birthData) };
    onDone?.(member);
  } else {
    const member: FamilyMember = { id: editingMember?.id ?? uuid(), name: cleanName, gender: genderForRelation(relation), relation, birth: birthData, kundali: computeKundali(birthData) };
    if (!editingMember) app.addMember(member);
    onDone?.(member);
  }
  close();
}

function genderForRelation(relation: Relation): Gender {
  if (["husband", "son", "father", "brother"].includes(relation)) return "male";
  if (["wife", "daughter", "mother", "sister"].includes(relation)) return "female";
  return "other";
}

function clampNumber(value: string, minimum: number, maximum: number, fallback: number) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? Math.max(minimum, Math.min(maximum, parsed)) : fallback;
}

const styles = {
  topBar: { minHeight: 56, paddingHorizontal: 8, paddingTop: 4, flexDirection: "row" as const, alignItems: "center" as const, justifyContent: "space-between" as const },
  iconButton: { width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center" as const, justifyContent: "center" as const },
  largeField: { minHeight: 62, borderRadius: 0, backgroundColor: "transparent", borderBottomWidth: 1, borderBottomColor: palette.hairline, paddingHorizontal: 0, fontFamily: "Fraunces-Bold", fontSize: 26 }
};
