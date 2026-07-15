import React from "react";
import { Linking, Switch, View } from "react-native";
import { AppText, Hairline, PressableScale, SectionLabel, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon, type AppIconName } from "../ornaments";
import { useAppState } from "../app-state";
import { layoutMetrics, palette, spacing } from "../theme";
import type { Language, ThemeChoice } from "../types";

export type AndroidNotificationPreferences = {
  enabled: boolean;
  familyInsights: boolean;
  calendarReminders: boolean;
};

type SettingsScreenProps = {
  onEditProfile?: () => void;
  notificationPreferences?: AndroidNotificationPreferences;
  onNotificationPreferencesChange?: (preferences: AndroidNotificationPreferences) => void;
};

const defaultNotifications: AndroidNotificationPreferences = {
  enabled: false,
  familyInsights: true,
  calendarReminders: true
};

/** Flat Android settings sheet matching SettingsView.swift without Liquid Glass. */
export function SettingsScreen({ onEditProfile, notificationPreferences, onNotificationPreferencesChange }: SettingsScreenProps = {}) {
  const app = useAppState();
  const [localNotifications, setLocalNotifications] = React.useState(defaultNotifications);
  const notifications = notificationPreferences ?? localNotifications;
  const updateNotifications = (patch: Partial<AndroidNotificationPreferences>) => {
    const next = { ...notifications, ...patch };
    if (onNotificationPreferencesChange) onNotificationPreferencesChange(next);
    else setLocalNotifications(next);
  };

  return (
    <ScrollScreen gutter={layoutMetrics.sheetGutter} topInset={24} bottomInset={40} contentGap={24}>
      <View style={styles.header}>
        <SerifText style={styles.title}>{app.language === "ne" ? "सेटिङ" : "Settings"}</SerifText>
        <PressableScale accessibilityLabel="Close" onPress={app.closeModal} style={styles.iconButton}>
          <AppIcon name="close" size={20} color={palette.inkSecondary} />
        </PressableScale>
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "भाषा" : "Language"}</SectionLabel>
        <View style={styles.segmented}>
          <LanguageOption language="en" current={app.language} label="English" onPress={app.setLanguage} />
          <LanguageOption language="ne" current={app.language} label="नेपाली" onPress={app.setLanguage} />
        </View>
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "रूप" : "Appearance"}</SectionLabel>
        <ThemeRow value="system" current={app.theme} label={app.language === "ne" ? "प्रणाली अनुसार" : "System"} icon="globe" onPress={app.setTheme} />
        <Hairline />
        <ThemeRow value="light" current={app.theme} label={app.language === "ne" ? "उज्यालो" : "Light"} icon="sun" onPress={app.setTheme} />
        <Hairline />
        <ThemeRow value="dark" current={app.theme} label={app.language === "ne" ? "गाढा" : "Dark"} icon="moon" onPress={app.setTheme} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "जन्म विवरण" : "Birth details"}</SectionLabel>
        <SettingsRow
          label={app.language === "ne" ? "प्रोफाइल सम्पादन गर्नुहोस्" : "Edit profile"}
          icon="profile"
          onPress={onEditProfile ?? (() => app.openModal("profile"))}
        />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "सूचनाहरू" : "Notifications"}</SectionLabel>
        <ToggleRow
          label={app.language === "ne" ? "दैनिक ज्योतिष जानकारी" : "Daily astrology guidance"}
          value={notifications.enabled}
          onChange={(enabled) => updateNotifications({ enabled })}
        />
        {notifications.enabled ? (
          <>
            <Hairline />
            <ToggleRow
              label={app.language === "ne" ? "परिवारका संकेत" : "Family insights"}
              value={notifications.familyInsights}
              onChange={(familyInsights) => updateNotifications({ familyInsights })}
            />
            <Hairline />
            <ToggleRow
              label={app.language === "ne" ? "पात्रो सम्झना" : "Calendar reminders"}
              value={notifications.calendarReminders}
              onChange={(calendarReminders) => updateNotifications({ calendarReminders })}
            />
          </>
        ) : null}
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "कानूनी" : "Legal"}</SectionLabel>
        <SettingsRow
          label={app.language === "ne" ? "गोपनीयता नीति" : "Privacy policy"}
          icon="profile"
          onPress={() => void Linking.openURL("https://www.orecci.com/jyotish/privacy-policy.html")}
        />
        <Hairline />
        <SettingsRow
          label={app.language === "ne" ? "सेवाका सर्तहरू" : "Terms of service"}
          icon="message"
          onPress={() => void Linking.openURL("https://www.orecci.com/jyotish/terms-of-service.html")}
        />
      </View>

      <PressableScale accessibilityRole="button" onPress={app.signOut} style={styles.signOut}>
        <AppText style={{ color: palette.sindoor, fontSize: 16 }}>{app.language === "ne" ? "साइन आउट" : "Sign out"}</AppText>
      </PressableScale>
    </ScrollScreen>
  );
}

function LanguageOption({ language, current, label, onPress }: {
  language: Language;
  current: Language;
  label: string;
  onPress: (language: Language) => void;
}) {
  const selected = language === current;
  return (
    <PressableScale
      accessibilityState={{ selected }}
      onPress={() => onPress(language)}
      style={{ flex: 1, minHeight: 44, borderRadius: 22, borderCurve: "continuous", backgroundColor: selected ? "rgba(242,169,59,0.25)" : "transparent", alignItems: "center", justifyContent: "center" }}
    >
      <AppText style={{ color: selected ? palette.sindoor : palette.inkSecondary, fontFamily: selected ? "Inter-SemiBold" : "Inter-Regular", fontSize: 16 }}>{label}</AppText>
    </PressableScale>
  );
}

function ThemeRow({ value, current, label, icon, onPress }: {
  value: ThemeChoice;
  current: ThemeChoice;
  label: string;
  icon: AppIconName;
  onPress: (theme: ThemeChoice) => void;
}) {
  const selected = value === current;
  return (
    <PressableScale accessibilityState={{ selected }} onPress={() => onPress(value)} style={styles.row}>
      <AppIcon name={icon} size={21} color={palette.marigold} />
      <SerifText style={{ flex: 1, fontSize: 16 }}>{label}</SerifText>
      <View style={{ width: 20, height: 20, borderRadius: 10, borderWidth: selected ? 6 : 1, borderColor: selected ? palette.saffron : palette.hairline }} />
    </PressableScale>
  );
}

function SettingsRow({ label, icon, onPress }: { label: string; icon: AppIconName; onPress: () => void }) {
  return (
    <PressableScale onPress={onPress} style={styles.row}>
      <AppIcon name={icon} size={21} color={palette.saffron} />
      <SerifText style={{ flex: 1, fontSize: 16 }}>{label}</SerifText>
      <AppIcon name="arrow-right" size={17} color={palette.templeGold} />
    </PressableScale>
  );
}

function ToggleRow({ label, value, onChange }: { label: string; value: boolean; onChange: (value: boolean) => void }) {
  return (
    <View style={styles.row}>
      <SerifText style={{ flex: 1, fontSize: 16 }}>{label}</SerifText>
      <Switch value={value} onValueChange={onChange} trackColor={{ false: palette.bgSunken, true: palette.saffron }} thumbColor={palette.bgElevated} />
    </View>
  );
}

const styles = {
  header: { minHeight: 48, flexDirection: "row" as const, alignItems: "center" as const, justifyContent: "space-between" as const, gap: spacing.md },
  title: { fontFamily: "Fraunces-Bold", fontSize: 30, flexShrink: 1 },
  iconButton: { width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center" as const, justifyContent: "center" as const, marginRight: -8 },
  segmented: { minHeight: 52, flexDirection: "row" as const, gap: 4, borderRadius: 26, borderCurve: "continuous" as const, backgroundColor: palette.bgSunken, padding: 4 },
  row: { minHeight: 48, paddingVertical: 10, flexDirection: "row" as const, alignItems: "center" as const, gap: 12 },
  signOut: { minHeight: 50, alignItems: "center" as const, justifyContent: "center" as const }
};
