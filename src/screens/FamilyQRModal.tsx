import React from "react";
import { Alert, Modal, ScrollView, TextInput, View } from "react-native";
import { CameraView, useCameraPermissions, type BarcodeScanningResult } from "expo-camera";
import QRCode from "react-native-qrcode-svg";
import { AppText, PressableScale, SerifText } from "@/components";
import { encodeFamilyProfile, decodeFamilyProfile, sameSharedIdentity, type SharedFamilyProfile } from "@/family-qr";
import { displayName } from "@/l10n";
import { AppIcon } from "@/ornaments";
import { palette } from "@/theme";
import type { FamilyMember, Language, Relation } from "@/types";
import { track } from "@/analytics";
import { uuid } from "@/astro";

export type FamilyQRMode = "my" | "scan";

const importRelations: Relation[] = [
  "friend", "partner", "boyfriend", "girlfriend", "husband", "wife", "fiance", "fiancee",
  "father", "mother", "brother", "sister", "son", "daughter", "cousin", "colleague", "mentor"
];

const sharedRelationLabels: Record<Exclude<Relation, "selfMember">, [string, string]> = {
  father: ["Father", "बुबा"], mother: ["Mother", "आमा"], husband: ["Husband", "श्रीमान्"], wife: ["Wife", "श्रीमती"],
  son: ["Son", "छोरा"], daughter: ["Daughter", "छोरी"], brother: ["Brother", "दाजु/भाइ"], sister: ["Sister", "दिदी/बहिनी"],
  cousin: ["Cousin", "दाजुभाइ/दिदीबहिनी"], boyfriend: ["Boyfriend", "प्रेमी"], girlfriend: ["Girlfriend", "प्रेमिका"], partner: ["Partner", "साथी"],
  fiance: ["Fiance", "मंगेतर"], fiancee: ["Fiancee", "मंगेतर"], friend: ["Friend", "मित्र"], colleague: ["Colleague", "सहकर्मी"], mentor: ["Mentor", "मार्गदर्शक"]
};

function sharedRelationLabel(relation: Exclude<Relation, "selfMember">, language: Language) {
  return sharedRelationLabels[relation][language === "ne" ? 1 : 0];
}

export function FamilyQRModal({ mode, language, family, onAdd, onClose }: {
  mode?: FamilyQRMode;
  language: Language;
  family: FamilyMember[];
  onAdd: (member: FamilyMember) => void;
  onClose: () => void;
}) {
  const self = family.find((member) => member.relation === "selfMember");
  const [permission, requestPermission] = useCameraPermissions();
  const [raw, setRaw] = React.useState("");
  const [profile, setProfile] = React.useState<SharedFamilyProfile>();
  const [relation, setRelation] = React.useState<Relation>("friend");
  const [scanLocked, setScanLocked] = React.useState(false);

  React.useEffect(() => {
    if (mode === "scan" && permission && !permission.granted && permission.canAskAgain) void requestPermission();
  }, [mode, permission?.granted]);

  React.useEffect(() => {
    if (mode) track("family_qr_opened", { mode });
  }, [mode]);

  const parse = React.useCallback((value: string) => {
    try {
      const decoded = decodeFamilyProfile(value);
      setRaw(value);
      setProfile(decoded);
      setScanLocked(true);
      track("family_qr_scanned", { has_birth_data: Boolean(decoded.birth) });
    } catch {
      Alert.alert(language === "ne" ? "QR पढ्न सकिएन" : "Could not read QR", language === "ne" ? "यो Jyotish Baje कुण्डली QR हो कि जाँच्नुहोस्।" : "Make sure this is a Jyotish Baje Kundli QR code.");
      setScanLocked(false);
    }
  }, [language]);

  const importProfile = React.useCallback(() => {
    if (!profile) return;
    if (family.some((member) => sameSharedIdentity(member, profile))) {
      Alert.alert(language === "ne" ? "पहिले नै परिवारमा छ" : "Already in Parivar", language === "ne" ? "यही नाम र जन्ममिति भएको व्यक्ति पहिले नै थपिएको छ।" : "A person with this name and birth date is already saved.");
      return;
    }
    onAdd({ id: uuid(), name: profile.name, gender: profile.gender, relation, ...(profile.birth ? { birth: profile.birth } : {}) });
    track("family_qr_imported", { relation, has_birth_data: Boolean(profile.birth) });
    onClose();
  }, [family, language, onAdd, onClose, profile, relation]);

  if (!mode) return null;
  const qrValue = self?.birth ? encodeFamilyProfile(self) : undefined;
  return (
    <Modal animationType="slide" visible presentationStyle="pageSheet" onRequestClose={onClose}>
      <View style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
        <View style={{ minHeight: 72, paddingHorizontal: 20, flexDirection: "row", alignItems: "center", gap: 10 }}>
          <SerifText style={{ flex: 1, fontFamily: "Fraunces-Bold", fontSize: 28 }}>
            {mode === "my" ? (language === "ne" ? "मेरो निजी कुण्डली QR" : "My Private Kundli QR") : (language === "ne" ? "कुण्डली QR स्क्यान" : "Scan Kundli QR")}
          </SerifText>
          <PressableScale accessibilityLabel="Close" onPress={onClose} style={{ width: 48, height: 48, alignItems: "center", justifyContent: "center" }}>
            <AppIcon name="close" color={palette.inkSecondary} />
          </PressableScale>
        </View>
        <ScrollView keyboardShouldPersistTaps="handled" contentContainerStyle={{ padding: 24, paddingBottom: 48, gap: 20 }}>
          {mode === "my" ? (
            <View style={{ alignItems: "center", gap: 20 }}>
              {qrValue ? (
                <View style={{ padding: 20, borderRadius: 24, backgroundColor: "white" }}>
                  <QRCode value={qrValue} size={230} color="#3B1F14" backgroundColor="white" />
                </View>
              ) : (
                <AppText style={{ textAlign: "center", color: palette.inkSecondary }}>
                  {language === "ne" ? "पहिले आफ्नो जन्म विवरण परिवारमा थप्नुहोस्।" : "Add your profile to Parivar before sharing a QR code."}
                </AppText>
              )}
              {self ? <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24 }}>{displayName(self.name, language)}</SerifText> : null}
              <AppText style={{ color: palette.inkSecondary, lineHeight: 22, textAlign: "center" }}>
                {language === "ne" ? "यस QR मा तपाईंको नाम र जन्म विवरण हुन्छ। विश्वास गर्ने व्यक्तिलाई मात्र देखाउनुहोस्। तपाईंको कुण्डली वा परिवार सम्बन्ध साझा हुँदैन।" : "This QR contains your name and birth details. Show it only to people you trust. Your calculated Kundli and relationship labels are not shared."}
              </AppText>
            </View>
          ) : profile ? (
            <View style={{ gap: 18 }}>
              <View style={{ alignItems: "center", gap: 8, padding: 20, borderRadius: 20, backgroundColor: palette.bgSunken }}>
                <AppIcon name="profile" size={34} color={palette.saffron} />
                <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24 }}>{displayName(profile.name, language)}</SerifText>
                <AppText style={{ color: palette.inkSecondary }}>{profile.birth ? (language === "ne" ? "जन्म विवरण समावेश छ" : "Birth details included") : (language === "ne" ? "जन्म विवरण छैन" : "No birth details")}</AppText>
              </View>
              <SerifText style={{ fontFamily: "Fraunces-SemiBold", fontSize: 19 }}>{language === "ne" ? "तपाईंको सम्बन्ध" : "Your relationship"}</SerifText>
              <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
                {importRelations.map((item) => (
                  <PressableScale key={item} onPress={() => setRelation(item)} style={{ minHeight: 44, justifyContent: "center", paddingHorizontal: 14, borderRadius: 22, backgroundColor: relation === item ? palette.saffron : palette.bgSunken }}>
                    <AppText style={{ fontFamily: "Inter-SemiBold", color: relation === item ? palette.inkPrimary : palette.inkSecondary }}>{sharedRelationLabel(item as Exclude<Relation, "selfMember">, language)}</AppText>
                  </PressableScale>
                ))}
              </View>
              <PrimaryButton label={language === "ne" ? "परिवारमा थप्नुहोस्" : "Add to Parivar"} onPress={importProfile} />
              <PressableScale onPress={() => { setProfile(undefined); setRaw(""); setScanLocked(false); }} style={{ minHeight: 48, alignItems: "center", justifyContent: "center" }}>
                <AppText style={{ color: palette.sindoor, fontFamily: "Inter-SemiBold" }}>{language === "ne" ? "फेरि स्क्यान गर्नुहोस्" : "Scan again"}</AppText>
              </PressableScale>
            </View>
          ) : (
            <View style={{ gap: 18 }}>
              {permission?.granted ? (
                <View style={{ height: 330, overflow: "hidden", borderRadius: 24, backgroundColor: palette.bgSunken }}>
                  <CameraView
                    style={{ flex: 1 }}
                    barcodeScannerSettings={{ barcodeTypes: ["qr"] }}
                    onBarcodeScanned={scanLocked ? undefined : (result: BarcodeScanningResult) => parse(result.data)}
                  />
                  <View pointerEvents="none" style={{ position: "absolute", inset: 52, borderWidth: 2, borderRadius: 22, borderColor: palette.saffron }} />
                </View>
              ) : (
                <View style={{ minHeight: 180, borderRadius: 24, backgroundColor: palette.bgSunken, alignItems: "center", justifyContent: "center", gap: 12, padding: 24 }}>
                  <AppIcon name="profile" size={34} color={palette.templeGold} />
                  <AppText style={{ textAlign: "center", color: palette.inkSecondary }}>{language === "ne" ? "QR स्क्यान गर्न क्यामेरा अनुमति दिनुहोस्, वा तल QR को पाठ टाँस्नुहोस्।" : "Allow camera access to scan, or paste the QR text below."}</AppText>
                  {permission?.canAskAgain ? <PrimaryButton label={language === "ne" ? "क्यामेरा अनुमति" : "Allow camera"} onPress={() => void requestPermission()} /> : null}
                </View>
              )}
              <AppText style={{ textAlign: "center", color: palette.inkSecondary }}>{language === "ne" ? "वा QR पाठ टाँस्नुहोस्" : "or paste QR text"}</AppText>
              <TextInput value={raw} onChangeText={setRaw} autoCapitalize="none" autoCorrect={false} multiline placeholder="jyotishbaje://family/add?payload=…" placeholderTextColor={palette.inkSecondary} style={{ minHeight: 92, borderRadius: 18, backgroundColor: palette.bgSunken, color: palette.inkPrimary, padding: 14, fontFamily: "Inter-Regular" }} />
              <PrimaryButton label={language === "ne" ? "QR पढ्नुहोस्" : "Read QR"} onPress={() => parse(raw)} disabled={!raw.trim()} />
            </View>
          )}
        </ScrollView>
      </View>
    </Modal>
  );
}

function PrimaryButton({ label, onPress, disabled = false }: { label: string; onPress: () => void; disabled?: boolean }) {
  return (
    <PressableScale disabled={disabled} onPress={onPress} style={{ minHeight: 56, borderRadius: 16, backgroundColor: palette.saffron, alignItems: "center", justifyContent: "center", opacity: disabled ? 0.45 : 1 }}>
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18 }}>{label}</SerifText>
    </PressableScale>
  );
}
