import React from "react";
import { Modal, View } from "react-native";
import { useAppState } from "@/app-state";
import { BottomTabShell } from "@/layout";
import { palette } from "@/theme";
import type { AppTab } from "@/types";
import { AuthScreen as ParityAuthScreen } from "@/screens/AuthScreen";
import { ChatScreen } from "@/screens/ChatScreen";
import { FamilyScreen } from "@/screens/FamilyScreen";
import { HomeScreen } from "@/screens/HomeScreen";
import { PatroScreen } from "@/screens/PatroScreen";
import { ProfileFlowScreen } from "@/screens/ProfileFlowScreen";
import { RashifalScreen } from "@/screens/RashifalScreen";
import { SettingsScreen } from "@/screens/SettingsScreen";
import { WelcomeScreen as ParityWelcomeScreen } from "@/screens/WelcomeScreen";

export { ParityWelcomeScreen as WelcomeScreen };
export { ParityAuthScreen as AuthScreen };

const tabs = [
  { value: "family", label: "My Kundli & QR", icon: "qr-code" },
  { value: "rashifal", label: "Rashifal", icon: "sparkle" },
  { value: "home", label: "Religious", icon: "sun" }
] as const;

/** The account-first profile route uses the same birth flow as Settings. */
export function ProfileScreen() {
  return <ProfileFlowScreen mode="self" />;
}

/**
 * Small Android shell that mirrors AppNavigation.swift: exactly three primary
 * tabs, with Patro secondary and Jyotish Baje modal. Liquid Glass is the only
 * intentional visual exception; Android keeps the same capsule geometry.
 */
export function MainScreen() {
  const app = useAppState();
  const [profileMode, setProfileMode] = React.useState<"self" | "family">("family");

  const openProfile = React.useCallback((mode: "self" | "family") => {
    setProfileMode(mode);
    app.openModal("profile");
  }, [app]);

  return (
    <View style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      {app.selectedTab === "home" ? (
        <HomeScreen />
      ) : app.selectedTab === "rashifal" ? (
        <RashifalScreen />
      ) : (
        <FamilyScreen onAddMember={() => openProfile("family")} />
      )}
      <BottomTabShell<AppTab> value={app.selectedTab} items={tabs} onChange={app.setSelectedTab} />
      <AppModal profileMode={profileMode} onEditProfile={() => openProfile("self")} />
    </View>
  );
}

function AppModal({ profileMode, onEditProfile }: {
  profileMode: "self" | "family";
  onEditProfile: () => void;
}) {
  const app = useAppState();
  const modal = app.modal;

  if (modal === "chat") {
    return (
      <Modal animationType="slide" visible onRequestClose={app.closeModal} statusBarTranslucent>
        <ChatScreen />
      </Modal>
    );
  }

  if (modal === "patro") {
    return (
      <Modal animationType="slide" visible onRequestClose={app.closeModal} statusBarTranslucent>
        <PatroScreen />
      </Modal>
    );
  }

  if (modal === "settings" || modal === "profile") {
    return (
      <Modal animationType="slide" transparent visible onRequestClose={app.closeModal} statusBarTranslucent>
        <View style={{ flex: 1, justifyContent: "flex-end", backgroundColor: "rgba(0,0,0,0.18)" }}>
          <View
            style={{
              height: "92%",
              overflow: "hidden",
              borderTopLeftRadius: 28,
              borderTopRightRadius: 28,
              backgroundColor: palette.bgCanvas
            }}
          >
            <View
              pointerEvents="none"
              style={{
                position: "absolute",
                zIndex: 2,
                top: 8,
                left: "50%",
                width: 36,
                height: 5,
                marginLeft: -18,
                borderRadius: 3,
                backgroundColor: palette.inkSecondary,
                opacity: 0.24
              }}
            />
            {modal === "settings" ? (
              <SettingsScreen onEditProfile={onEditProfile} />
            ) : (
              <ProfileFlowScreen mode={profileMode} />
            )}
          </View>
        </View>
      </Modal>
    );
  }

  if (modal === "auth") {
    return (
      <Modal animationType="slide" visible onRequestClose={app.closeModal} statusBarTranslucent>
        <ParityAuthScreen />
      </Modal>
    );
  }

  return null;
}
