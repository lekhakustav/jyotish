import { createClient } from "@supabase/supabase-js";
import * as SecureStore from "expo-secure-store";
import { makeRedirectUri } from "expo-auth-session";
import * as WebBrowser from "expo-web-browser";

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || "";
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_OR_PUBLISHABLE_KEY || "";

const ExpoSecureStoreAdapter = {
  getItem: (key: string) => SecureStore.getItemAsync(key),
  setItem: (key: string, value: string) => SecureStore.setItemAsync(key, value),
  removeItem: (key: string) => SecureStore.deleteItemAsync(key),
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: ExpoSecureStoreAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
    // PKCE returns the auth code in the query string (?code=), which survives
    // native deep links. The default implicit flow puts tokens in the URL hash
    // fragment, which Android often strips when delivering the redirect.
    flowType: "pkce",
  },
});

export const redirectUri = makeRedirectUri({ scheme: "jyotishbaje", path: "auth-callback" });

export type AuthCallbackParams = {
  code?: string | null;
  access_token?: string | null;
  refresh_token?: string | null;
};

// Completes a Supabase session from OAuth/email redirect params. Supports both
// PKCE (code) and implicit (access_token) responses.
export async function completeAuthFromParams(params: AuthCallbackParams) {
  if (params.code) {
    const { data, error } = await supabase.auth.exchangeCodeForSession(params.code);
    if (error) throw error;
    return data.session;
  }

  if (params.access_token) {
    const { data, error } = await supabase.auth.setSession({
      access_token: params.access_token,
      refresh_token: params.refresh_token ?? "",
    });
    if (error) throw error;
    return data.session;
  }

  return null;
}

// Extracts auth params from a full redirect URL (used when the in-app browser
// hands the URL back directly). The route path uses useLocalSearchParams.
export function parseAuthParamsFromUrl(url: string): AuthCallbackParams {
  const parsed = new URL(url);
  const hash = parsed.hash ? new URLSearchParams(parsed.hash.replace(/^#/, "")) : null;
  return {
    code: parsed.searchParams.get("code"),
    access_token: hash?.get("access_token") ?? parsed.searchParams.get("access_token"),
    refresh_token: hash?.get("refresh_token") ?? parsed.searchParams.get("refresh_token"),
  };
}

export async function signInWithGoogle() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: redirectUri,
      skipBrowserRedirect: true,
    },
  });

  if (error) throw error;
  if (!data.url) throw new Error("No OAuth URL returned");

  const result = await WebBrowser.openAuthSessionAsync(data.url, redirectUri);

  // Happy path: the in-app browser captured the redirect and handed us the URL.
  // Otherwise the redirect was delivered to the router as a deep link, and
  // app/auth-callback.tsx completes the session instead.
  if (result.type === "success" && result.url) {
    return completeAuthFromParams(parseAuthParamsFromUrl(result.url));
  }

  return null;
}

export async function signInWithEmail(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data.session;
}

export async function signUpWithEmail(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { emailRedirectTo: redirectUri },
  });
  if (error) throw error;
  return data;
}

export async function signOutSupabase() {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}

// Server-side account deletion (Play User Data policy / Apple 5.1.1(v)):
// the delete-account Edge Function wipes household and analytics rows, then
// the auth user. The local session is cleared only after the server confirms.
export async function deleteAccountSupabase() {
  const { data, error } = await supabase.functions.invoke("delete-account", { body: {} });
  if (error) throw error;
  if (!data?.deleted) throw new Error("Account deletion was not confirmed");
  await supabase.auth.signOut().catch(() => undefined);
}
