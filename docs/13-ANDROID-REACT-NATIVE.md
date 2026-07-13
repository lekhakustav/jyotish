# 13 — Android React Native App

The Android app is an Expo/React Native port that lives beside the native SwiftUI iOS
app. The goal is product parity: the same Jyotish baje brand, Home/Rashifal/Family
main tabs, Patro as a secondary surface, Jyotish Baje as modal chat, local-first household
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
- `src/app-state.tsx` — schema-v2 household state, migration-safe persistence, modal/tab routing, conversation history, and batched chat streaming.
- `src/screens.tsx` — the small Android navigation shell; each feature screen lives in `src/screens/`.
- `src/layout.tsx` — safe-area screen primitives and the SwiftUI-shaped floating tab capsule.
- `src/ornaments.tsx` — semantic vector icons, the twelve rashi marks, yantra scores, and shared visual ornaments.
- `src/theme.ts` — shared palette, spacing, layout, and motion constants ported from the SwiftUI design system.
- `src/astro.ts` — TypeScript astrology/rashifal/panchanga/demo data layer.
- `assets/expo/` — Android app icon, brand logo, temple image, and bundled fonts.
- `android/` — generated native Android project for `com.sodhera.jyotish`.

## Current Parity Notes

- The Android app has the same onboarding, main tabs, Patro, Family, Rashifal, settings,
  and Jyotish Baje chat surfaces.
- Android bundles the same Fraunces weights used by SwiftUI and renders the twelve rashi
  marks, star scores, and North-Indian Kundli chart as vectors rather than text glyphs.
- The chat UI shows a typing indicator and streams local fallback replies character by
  character. If `EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL` is present, it attempts the
  backend agent first and falls back locally on failure.
- The Android astrology layer is local TypeScript. It preserves deterministic Jyotish
  behavior and user-facing structure, but the full Swift ephemeris should remain the
  accuracy reference until a second pass ports every Swift astronomy term exactly.
- Voice reply playback is wired through `expo-speech`. Recording/STT permission is declared
  for Android, but full ElevenLabs voice-agent recording should be completed in the next
  native QA pass.

## SwiftUI parity contract

SwiftUI is the product and visual source of truth. Android must preserve the same content
hierarchy even when native platform chrome differs:

| Surface | Shared contract |
| --- | --- |
| App shell | Home, Rashifal, and Family are the only primary tabs. Patro is secondary and Jyotish Baje is modal. |
| Home | Greeting/name, personal rashifal hook, three Jyotish Baje starters plus ask-anything CTA, tithi/Patro link, temple, relatives, then upcoming events. |
| Rashifal | Period selector, horizontal rashi selector, rashi/period heading, reading and Baje CTA, five-point domain scores, lucky facts, then upaya. |
| Family | Optional family tree followed by flat member rows and a Kundli affordance. The add action belongs in the header. |
| Visual system | Plain warm canvas, Fraunces display type, Inter body type, 24dp primary gutters, 40dp section rhythm, semantic palette only, and no decorative content cards. |
| Appearance | Light, dark, and system settings use the same semantic colors as SwiftUI. |

Android may use its own system status/navigation bars and tab implementation. iOS Liquid
Glass is deliberately not copied. Content order, copy, information density, colors,
typography roles, and interaction destinations must otherwise remain aligned.

When SwiftUI screen structure changes, update this table and the corresponding Android
screen in the same change. Treat a successful bundle as necessary but not sufficient:
compare both apps on similarly sized emulators before release.

The dated element-by-element acceptance record is in
[`17-IOS-ANDROID-VISUAL-PARITY.md`](17-IOS-ANDROID-VISUAL-PARITY.md). Update it or add a
new dated review whenever either implementation changes its visible hierarchy.

## Runtime performance guardrails

- The home temple asset is sized for its 4:3 card and uses Android's native resize
  path, avoiding a full-resolution bitmap upload for a small on-screen surface.
- Local chat streaming batches characters into at most 72 UI commits, rather than
  forcing one JavaScript render for every character.
- Release builds enable R8 minification and unused-resource shrinking; keep that
  release-only so debug traces and development iteration remain reliable.
- Do not add timers, animated loops, or full-screen image preloading to Home. The
  SwiftUI and Android implementations should keep one temple image resident and
  load other visuals only on demand.

## Temple-of-the-day context

The temple card must explain its calendar pairing immediately below the image. Android
derives the text from the same displayed tithi; Swift prefers the curated manifest's
`sourceScheduleReason` and falls back to the same tithi tradition categories offline.
This preserves the ritual meaning of the daily selection rather than presenting the
temple as a generic illustration.

## Rashifal and chat parity

Daily, weekly, monthly, and yearly readings must each state and calculate for their
own horizon; they are not alternative labels for a daily reading. Chat uses the
same brief-answer and final opt-in-question contract as SwiftUI. Its first suggestion
chip mirrors the answer's final question, and assistant prose stays unboxed while
user messages use the same restrained marigold tint as iOS.

## Verification

Before pushing Android changes, run:

```sh
npm run typecheck
npm run android:export
cd android && ./gradlew assembleDebug
cd android && ./gradlew assembleRelease
```

If a dependency refresh leaves Reanimated pointing at an obsolete Worklets CMake output,
regenerate the native cache before retrying:

```sh
cd android
./gradlew :react-native-reanimated:externalNativeBuildCleanDebug
./gradlew assembleDebug
```

On a fresh Mac, Gradle also needs an Android SDK. This machine uses an ignored
`android/local.properties` file pointing at:

```text
/opt/homebrew/share/android-commandlinetools
```
