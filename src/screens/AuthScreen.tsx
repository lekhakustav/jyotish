import React from "react";
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TextInput,
  View
} from "react-native";
import Svg, { Path } from "react-native-svg";
import { useAppState } from "@/app-state";
import { AppText, PressableScale, PrimaryButton, SerifText } from "@/components";
import { FixedScreen } from "@/layout";
import { AppIcon } from "@/ornaments";
import { palette } from "@/theme";

export type AuthMode = "signIn" | "signUp";

type AuthScreenProps = {
  mode?: AuthMode;
  onBack?: () => void;
};

function authCopy(language: "en" | "ne", mode: AuthMode) {
  const signUp = mode === "signUp";
  return language === "ne"
    ? {
        title: signUp ? "साइन अप गर्नुहोस्" : "साइन इन गर्नुहोस्",
        google: signUp ? "गुगलबाट साइन अप गर्नुहोस्" : "गुगलबाट साइन इन गर्नुहोस्",
        email: signUp ? "इमेलबाट साइन अप गर्नुहोस्" : "इमेलबाट साइन इन गर्नुहोस्",
        emailPlaceholder: "इमेल",
        passwordPlaceholder: "पासवर्ड",
        submit: signUp ? "साइन अप गर्नुहोस्" : "साइन इन गर्नुहोस्",
        wait: "कृपया पर्खनुहोस्...",
        back: "पछाडि"
      }
    : {
        title: signUp ? "Sign up" : "Sign in",
        google: signUp ? "Sign up with Google" : "Sign in with Google",
        email: signUp ? "Sign up with email" : "Sign in with email",
        emailPlaceholder: "Email",
        passwordPlaceholder: "Password",
        submit: signUp ? "Sign up" : "Sign in",
        wait: "Please wait...",
        back: "Back"
      };
}

/** Android provider screen: Google and email mirror iOS hierarchy; Apple stays iOS-only. */
export function AuthScreen({ mode = "signIn", onBack }: AuthScreenProps) {
  const app = useAppState();
  const [showEmail, setShowEmail] = React.useState(false);
  const [email, setEmail] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [activeProvider, setActiveProvider] = React.useState<"google" | "email">();
  const [error, setError] = React.useState("");
  const copy = authCopy(app.language, mode);
  const formValid = email.includes("@") && password.length >= 6;

  const authenticate = async (provider: "google" | "email") => {
    if (provider === "email" && !formValid) return;
    setActiveProvider(provider);
    setError("");
    try {
      if (provider === "google") await app.signInGoogle();
      else if (mode === "signUp") await app.signUpEmail(email.trim(), password);
      else await app.signInEmail(email.trim(), password);
    } catch (caught: unknown) {
      setError(caught instanceof Error ? caught.message : "Authentication failed");
    } finally {
      setActiveProvider(undefined);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === "ios" ? "padding" : "height"}
      style={{ flex: 1, backgroundColor: palette.bgCanvas }}
    >
      <FixedScreen>
        {onBack ? (
          <PressableScale
            accessibilityRole="button"
            accessibilityLabel={copy.back}
            disabled={Boolean(activeProvider)}
            onPress={onBack}
            style={{ width: 48, height: 48, marginLeft: -12, alignItems: "center", justifyContent: "center" }}
          >
            <AppIcon name="chevron-left" size={24} color={palette.inkSecondary} strokeWidth={2} />
          </PressableScale>
        ) : null}

        <ScrollView
          automaticallyAdjustContentInsets={false}
          contentContainerStyle={{ flexGrow: 1, justifyContent: "center", paddingVertical: 24 }}
          keyboardDismissMode="on-drag"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <View style={{ gap: 24, paddingBottom: onBack ? 48 : 0 }}>
            <SerifText
              accessibilityRole="header"
              style={{ fontFamily: "Fraunces-Bold", fontSize: 30, lineHeight: 38 }}
            >
              {copy.title}
            </SerifText>

            <View style={{ gap: 14 }}>
              <ProviderButton
                title={copy.google}
                disabled={Boolean(activeProvider)}
                loading={activeProvider === "google"}
                mark={<GoogleMark />}
                onPress={() => authenticate("google")}
              />
              <ProviderButton
                title={copy.email}
                disabled={Boolean(activeProvider)}
                mark={<EmailMark />}
                onPress={() => setShowEmail((visible) => !visible)}
              />

              {showEmail ? (
                <View style={{ gap: 18, paddingTop: 4 }}>
                  <UnderlinedField
                    value={email}
                    onChangeText={setEmail}
                    placeholder={copy.emailPlaceholder}
                    autoCapitalize="none"
                    autoCorrect={false}
                    keyboardType="email-address"
                    returnKeyType="next"
                  />
                  <UnderlinedField
                    value={password}
                    onChangeText={setPassword}
                    placeholder={copy.passwordPlaceholder}
                    secureTextEntry
                    returnKeyType="done"
                    onSubmitEditing={() => authenticate("email")}
                  />
                  {error ? (
                    <AppText accessibilityRole="alert" style={{ color: palette.sindoor, fontSize: 14, lineHeight: 20, textAlign: "center" }}>
                      {error}
                    </AppText>
                  ) : null}
                  <PrimaryButton
                    title={activeProvider === "email" ? copy.wait : copy.submit}
                    disabled={!formValid || Boolean(activeProvider)}
                    onPress={() => authenticate("email")}
                  />
                </View>
              ) : error ? (
                <AppText accessibilityRole="alert" style={{ color: palette.sindoor, fontSize: 14, lineHeight: 20, textAlign: "center" }}>
                  {error}
                </AppText>
              ) : null}
            </View>
          </View>
        </ScrollView>
      </FixedScreen>
    </KeyboardAvoidingView>
  );
}

function ProviderButton({ title, mark, loading = false, disabled = false, onPress }: {
  title: string;
  mark: React.ReactNode;
  loading?: boolean;
  disabled?: boolean;
  onPress: () => void;
}) {
  return (
    <PressableScale
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityState={{ busy: loading, disabled }}
      disabled={disabled}
      onPress={onPress}
      style={{
        minHeight: 56,
        borderRadius: 16,
        borderCurve: "continuous",
        borderWidth: 1,
        borderColor: "rgba(184, 134, 11, 0.4)",
        paddingHorizontal: 18,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        gap: 10
      }}
    >
      {loading ? <ActivityIndicator size="small" color={palette.inkPrimary} /> : mark}
      <AppText style={{ fontFamily: "Inter-SemiBold", fontSize: 17, textAlign: "center" }}>{title}</AppText>
    </PressableScale>
  );
}

function UnderlinedField(props: React.ComponentProps<typeof TextInput>) {
  return (
    <TextInput
      placeholderTextColor={palette.inkSecondary}
      selectionColor={palette.saffron}
      style={{
        minHeight: 48,
        borderBottomWidth: 1,
        borderBottomColor: "rgba(184, 134, 11, 0.3)",
        color: palette.inkPrimary,
        fontFamily: "Fraunces-Regular",
        fontSize: 19,
        paddingHorizontal: 0,
        paddingVertical: 10
      }}
      {...props}
    />
  );
}

function GoogleMark() {
  return (
    <Svg width={20} height={20} viewBox="0 0 24 24" accessible={false}>
      <Path fill="#4285F4" d="M21.6 12.23c0-.71-.06-1.4-.18-2.07H12v3.92h5.38a4.6 4.6 0 0 1-2 3.02v2.55h3.24c1.9-1.75 2.98-4.33 2.98-7.42Z" />
      <Path fill="#34A853" d="M12 22c2.7 0 4.98-.9 6.64-2.43l-3.24-2.55c-.9.6-2.05.96-3.4.96-2.61 0-4.82-1.77-5.61-4.14H3.04v2.63A10 10 0 0 0 12 22Z" />
      <Path fill="#FBBC05" d="M6.39 13.84A6 6 0 0 1 6.08 12c0-.64.11-1.26.31-1.84V7.53H3.04A10 10 0 0 0 2 12c0 1.61.39 3.13 1.04 4.47l3.35-2.63Z" />
      <Path fill="#EA4335" d="M12 6.02c1.47 0 2.79.5 3.83 1.5l2.87-2.87A9.62 9.62 0 0 0 12 2a10 10 0 0 0-8.96 5.53l3.35 2.63C7.18 7.79 9.39 6.02 12 6.02Z" />
    </Svg>
  );
}

function EmailMark() {
  return (
    <Svg width={20} height={20} viewBox="0 0 24 24" accessible={false}>
      <Path d="M3 5.5h18v13H3zM3.5 6l8.5 7 8.5-7" fill="none" stroke={palette.inkPrimary} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}
