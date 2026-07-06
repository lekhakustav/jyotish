# 13 — Android React Native App

The Android app is an Expo/React Native port that lives beside the native SwiftUI iOS
app. The goal is product parity: the same Jyotish baje brand, Home/Rashifal/Family
main tabs, Patro as a secondary surface, Pandit-ji as modal chat, local-first household
state, and the same server-side agent contract.

## Run

Install dependencies once:

```sh
npm install
```

Start the Android app on an attached emulator/device:

```sh
npm run android
```

The JavaScript bundle can read the agent endpoint from either
`EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL` or the existing `JYOTISH_AGENT_ENDPOINT_URL`.
Do not expose OpenAI or ElevenLabs private keys to the Android client; keep those
server-side in the Supabase Edge Function/local agent.

For a fast JS bundle check:

```sh
npm run android:export
```

For a native project refresh after `app.json` plugin/config changes:

```sh
npm run android:prebuild -- --no-install
```

## Structure

- `app/` — Expo Router entrypoints.
- `src/app-state.tsx` — household state, local persistence, modal/tab routing, chat send/streaming.
- `src/screens.tsx` — Android screens matching the current SwiftUI app contract.
- `src/astro.ts` — TypeScript astrology/rashifal/panchanga/demo data layer.
- `assets/expo/` — Android app icon, brand logo, temple image, and bundled fonts.
- `android/` — generated native Android project for `com.sodhera.jyotish`.

## Current Parity Notes

- The Android app has the same onboarding, main tabs, Patro, Family, Rashifal, settings,
  and Pandit chat surfaces.
- The chat UI shows a typing indicator and streams local fallback replies character by
  character. If `EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL` is present, it attempts the
  backend agent first and falls back locally on failure.
- The Android astrology layer is local TypeScript. It preserves deterministic Jyotish
  behavior and user-facing structure, but the full Swift ephemeris should remain the
  accuracy reference until a second pass ports every Swift astronomy term exactly.
- Voice reply playback is wired through `expo-speech`. Recording/STT permission is declared
  for Android, but full ElevenLabs voice-agent recording should be completed in the next
  native QA pass.

## Verification

Before pushing Android changes, run:

```sh
npm run typecheck
npm run android:export
cd android && ./gradlew assembleDebug
```

On a fresh Mac, Gradle also needs an Android SDK. This machine uses an ignored
`android/local.properties` file pointing at:

```text
/opt/homebrew/share/android-commandlinetools
```
