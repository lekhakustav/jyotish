import React from "react";
import { Animated, View } from "react-native";
import { useAppState } from "@/app-state";
import { AppText, Logo, PressableScale, PrimaryButton, SerifText } from "@/components";
import { FixedScreen, useReduceMotion } from "@/layout";
import { AppIcon } from "@/ornaments";
import { palette } from "@/theme";
import { AuthScreen, type AuthMode } from "@/screens/AuthScreen";

function welcomeCopy(language: "en" | "ne") {
  return language === "ne"
    ? {
        tagline: "तपाईंको परिवारको कुण्डली, एकै निजी ठाउँमा",
        createAccount: "खाता खोल्नुहोस्",
        signIn: "साइन इन गर्नुहोस्"
      }
    : {
        tagline: "Your family's Kundli, in one private place",
        createAccount: "Create an account",
        signIn: "Sign in"
      };
}

/** Android counterpart to the SwiftUI WelcomeView; materials remain platform-native. */
export function WelcomeScreen() {
  const app = useAppState();
  const [authMode, setAuthMode] = React.useState<AuthMode>();
  const reduceMotion = useReduceMotion();
  const entrance = React.useRef(new Animated.Value(reduceMotion ? 1 : 0)).current;
  const copy = welcomeCopy(app.language);

  React.useEffect(() => {
    if (reduceMotion) {
      entrance.setValue(1);
      return;
    }
    Animated.timing(entrance, {
      toValue: 1,
      duration: 450,
      useNativeDriver: true
    }).start();
  }, [entrance, reduceMotion]);

  if (authMode) return <AuthScreen mode={authMode} onBack={() => setAuthMode(undefined)} />;

  return (
    <FixedScreen
      accessibilityLabel="Jyotish Baje welcome"
      contentStyle={{ paddingBottom: 40 }}
    >
      <Animated.View
        style={{
          flex: 1,
          opacity: entrance,
          transform: [{ translateY: entrance.interpolate({ inputRange: [0, 1], outputRange: [12, 0] }) }]
        }}
      >
        <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
          <Logo size={128} />
          <SerifText
            accessibilityRole="header"
            style={{
              marginTop: 20,
              fontFamily: "Fraunces-Bold",
              fontSize: 56,
              lineHeight: 64,
              textAlign: "center"
            }}
          >
            ज्योतिष बाजे
          </SerifText>
          <SerifText
            style={{
              marginTop: 20,
              maxWidth: 322,
              color: palette.inkSecondary,
              fontSize: 18,
              lineHeight: 27,
              fontStyle: "italic",
              textAlign: "center"
            }}
          >
            {copy.tagline}
          </SerifText>
        </View>

        <View style={{ gap: 14, alignItems: "center" }}>
          <View style={{ alignSelf: "stretch" }}>
            <PrimaryButton title={copy.createAccount} icon="sparkle" onPress={() => setAuthMode("signUp")} />
          </View>
          <WelcomeSecondaryButton title={copy.signIn} onPress={() => setAuthMode("signIn")} />
          <LanguageControl value={app.language} onChange={app.setLanguage} />
        </View>
      </Animated.View>
    </FixedScreen>
  );
}

function WelcomeSecondaryButton({ title, onPress }: { title: string; onPress: () => void }) {
  return (
    <PressableScale
      accessibilityRole="button"
      accessibilityLabel={title}
      onPress={onPress}
      style={{
        alignSelf: "stretch",
        minHeight: 56,
        borderRadius: 16,
        borderCurve: "continuous",
        borderWidth: 1,
        borderColor: "rgba(184, 134, 11, 0.4)",
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        gap: 8,
        paddingHorizontal: 18
      }}
    >
      <AppIcon name="profile" size={19} color={palette.inkPrimary} strokeWidth={2} />
      <AppText style={{ fontFamily: "Inter-SemiBold", fontSize: 17 }}>{title}</AppText>
    </PressableScale>
  );
}

function LanguageControl({ value, onChange }: { value: "en" | "ne"; onChange: (language: "en" | "ne") => void }) {
  return (
    <View
      accessibilityRole="radiogroup"
      style={{
        width: 240,
        padding: 4,
        borderRadius: 28,
        backgroundColor: palette.bgSunken,
        flexDirection: "row"
      }}
    >
      {([
        { value: "en", label: "English" },
        { value: "ne", label: "नेपाली" }
      ] as const).map((option) => {
        const selected = value === option.value;
        return (
          <PressableScale
            key={option.value}
            accessibilityRole="radio"
            accessibilityState={{ checked: selected }}
            onPress={() => onChange(option.value)}
            style={{
              flex: 1,
              minHeight: 48,
              borderRadius: 24,
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: selected ? "rgba(242, 169, 59, 0.25)" : "transparent"
            }}
          >
            <AppText
              style={{
                color: selected ? palette.sindoor : palette.inkSecondary,
                fontFamily: selected ? "Inter-SemiBold" : "Inter-Regular",
                fontSize: 15
              }}
            >
              {option.label}
            </AppText>
          </PressableScale>
        );
      })}
    </View>
  );
}
