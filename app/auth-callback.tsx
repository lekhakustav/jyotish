import React from "react";
import { ActivityIndicator, View } from "react-native";
import { router, useLocalSearchParams } from "expo-router";
import { useAppState } from "@/app-state";
import { palette } from "@/theme";

// Handles the OAuth / email redirect (jyotishbaje://auth-callback?code=...).
// Supabase redirects here as a deep link; expo-router parses the query into
// params. We exchange the code for a session, update auth state, then return
// to the app root which routes by account state.
export default function AuthCallbackRoute() {
  const app = useAppState();
  const params = useLocalSearchParams<{ code?: string; access_token?: string; refresh_token?: string }>();

  const code = typeof params.code === "string" ? params.code : undefined;
  const accessToken = typeof params.access_token === "string" ? params.access_token : undefined;
  const refreshToken = typeof params.refresh_token === "string" ? params.refresh_token : undefined;

  React.useEffect(() => {
    if (!code && !accessToken) return;
    let done = false;
    const goHome = () => {
      if (done) return;
      done = true;
      router.replace("/");
    };
    // Safety net so a stalled or cancelled exchange never hangs on the spinner.
    const timeout = setTimeout(goHome, 12000);
    app
      .completeOAuth({ code, access_token: accessToken, refresh_token: refreshToken })
      .catch(() => undefined)
      .finally(goHome);
    return () => {
      done = true;
      clearTimeout(timeout);
    };
  }, [code, accessToken, refreshToken]);

  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center", backgroundColor: palette.bgCanvas }}>
      <ActivityIndicator color={palette.saffron} />
    </View>
  );
}
