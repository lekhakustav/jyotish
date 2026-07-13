# 17 — iOS / Android Visual Parity

Last reviewed: 2026-07-13

SwiftUI is the visual and product source of truth. Android ports the same hierarchy,
measurements, typography roles, colors, icon meaning, content order, and destinations.
The deliberate exceptions are iOS Liquid Glass and platform-owned status/navigation
chrome. This document records the evidence-driven parity pass performed on an iPhone 17
Pro simulator and the available Android API 28 emulator.

## Acceptance method

1. Seed or preserve the same named dummy household on both platforms.
2. Capture the same surface and state with `simctl io screenshot` on iOS and `adb
   exec-out screencap` on Android. Do not use desktop screenshots.
3. Compare structure before polish: safe area, 24-point gutter, section order, controls,
   navigation destination, and information density.
4. Compare visual tokens: Fraunces/Inter role, size and weight, warm canvas, semantic
   colors, 16-point button corners, rashi paths, score marks, hairlines, and icons.
5. Exercise interactive states: all four rashifal horizons, Family to Kundli, Patro,
   Settings, chat history, a sent chat answer, and its generated follow-up suggestion.
6. Build both native targets after the review. A successful bundle alone is not visual
   acceptance.

Evidence is stored locally under
`.gstack/design-reports/screenshots/parity-2026-07-13/`. The folder contains baseline iOS
and Android captures plus final Android Home, Patro, Kundli, dasha, chat, settings,
Family, and four-horizon Rashifal states. It is intentionally ignored by Git.

## Element-by-element result

| Surface / element | SwiftUI reference | Android implementation after this pass | Status |
| --- | --- | --- | --- |
| System chrome | iOS status bar, home indicator, safe areas | Android status/navigation bars and matching safe-area content | Platform exception |
| Canvas and gutters | Warm `bgCanvas`, 24-point primary gutter | Same semantic canvas and 24dp gutter via `ScrollScreen`/`FixedScreen` | Matched |
| Type | Fraunces display hierarchy, Inter utility/body | Same bundled Fraunces weights and Inter weights; no synthetic display weight | Matched |
| Motion | Short fade/rise and spring presses, reduced-motion aware | Short opacity/transform transitions and reduced-motion fallback; chat streaming is batched | Matched in intent |
| Bottom navigation | Three icon-only tabs in a centered floating Liquid Glass capsule | Same three icons, order, 278x68 geometry, selection shape, and destinations on an opaque warm capsule | Matched except Liquid Glass |
| Home header | Time-aware greeting, member name, light gear icon | Same hierarchy, sizing, safe-area offset, and semantic gear | Matched |
| Home rashifal hero | Vector rashi mark, name, five-point score, hook, read-more, dasha | Same unframed vector paths, score stars, text roles, and order | Matched visually |
| Home feature hub | Five concise feature icons plus More; no shelf of long questions | Same primary catalog and modal/list flow. Dashas & Life Phase is primary on both platforms | Matched structurally |
| Home Relationships | Hidden for a solo profile; person-aware reading for complete saved relationships | Same conditional rendering, person choice, daily Do/Don't and detailed-report route | Matched structurally |
| Home CTA | Saffron 54/56-point button, sparkle, text, up-right arrow | Same geometry, copy, sparkle, and up-right arrow | Matched |
| Home Patro line | Exact BS day/month, tithi and paksha, secondary link | Exact table-backed BS conversion and named tithi/paksha with same hierarchy | Matched visually |
| Temple block | 4:3 rounded image, tithi-to-tradition explanation, temple copy | Same asset geometry and content order; the description explicitly relates the temple to the displayed tithi | Matched |
| Rashifal periods | Daily, weekly, monthly, yearly segmented control | Same four states; each generates and labels its own date range and content horizon | Matched |
| Rashifal rashi picker | Horizontal twelve-sign vector selector | Same twelve vector marks, underline selection, labels, and horizontal behavior | Matched |
| Rashifal content | Heading, timeline, reading, Baje CTA, five domain scores, lucky facts, upaya | Same order, typography roles, varied one-to-five scores, facts, and period-specific remedy | Matched visually |
| Family header/tree | `Parivar`, add/Scan QR/My QR actions, self node, connector lines, relation nodes | Same title, actions, node hierarchy, connectors, and localized relation labels | Matched structurally |
| Parivar QR | AVFoundation scanner, CoreImage QR, paste fallback, receiver-selected relation | CameraView scanner, SVG QR, paste fallback, same v1 payload and duplicate identity rule | Matched |
| Family rows | Rashi mark, name/relation, `See Kundli` affordance | Same structure and working navigation for every complete profile | Matched |
| Kundli hero/triad | Rashi mark, name/relation, lagna/rashi/nakshatra | Same centered hero and three-column summary | Matched |
| Kundli chart | North-Indian diamond chart with house signs and natal planets | Same chart geometry and house numbering; Android shows the birth-derived Lagna, Moon, and Sun available in its current model | Matched structurally; data scope noted below |
| Kundli reading/dasha/guna | Personality reading, nine-period timeline with current state, lucky rows | Same section order, birth-derived reading, Vimshottari period geometry/current highlight, and seven guna rows | Matched visually |
| Chat header | Tall two-line `Jyotish Baje`, history, new, close | Same 124-point header, two-line display type, icon order, and targets | Matched |
| Chat body | Unboxed assistant prose, restrained user bubble, smooth typing | Same visual treatment; streaming commits are capped and the cursor remains subtle | Matched |
| Chat voice typing | Native speech recognition with live transcript | Native Android recognizer, `ne-NP`/`en-IN`, permission and unavailable-service states | Matched in intent |
| Feature reports | Deterministic planner evidence is authoritative to the agent | Stable `feature:<id>:<member>` source, deterministic Dasha dates and prepared report fallback | Matched contract |
| Chat follow-ups | Brief answer ends with an opt-in question; first chip mirrors it | Same answer contract; first suggestion is generated from the final question and changes with the conversation | Matched |
| Chat history | Dimmed backdrop and partial-width conversation drawer | Same 81% drawer geometry, hierarchy, selection, and deletion affordance | Matched |
| Patro month | Fraunces title, month pill, seven-column calendar, named tithis, today state | Exact BS month table, same grid rhythm, full tithi names, Saturday accent, and today highlight | Matched visually |
| Patro day/events | Day header, panchanga rows, events, repeat toggle and add action | Same content hierarchy, semantic rows, and saved-event behavior | Matched |
| Settings | Rounded sheet, drag indicator, language/theme/profile/notifications/legal/sign-out | Same sheet geometry, groups, icons, controls, and destinations | Matched except Liquid Glass |
| Welcome/auth/profile | Brand hero, restrained auth choices, progressive birth-profile flow | Ported as dedicated screens with the same copy hierarchy, 56-point controls, validation, and destinations | Source/build verified; preserving the dummy account prevented destructive recapture |

## Deliberate differences and remaining risks

- Liquid Glass remains iOS-only. Android uses an opaque semantic surface while keeping the
  same capsule and sheet geometry.
- Platform-owned status/navigation bar glyphs and native font rasterization differ by OS.
- The Android astrology engine currently stores lagna, Moon, Sun, nakshatra, pada, and
  birth Julian day. SwiftUI calculates a fuller ephemeris. Consequently the same dummy
  birth record can currently produce different rashi/planet content between engines, and
  Android's Kundli chart can only place the three factors its model can substantiate. The
  UI does not fabricate missing planets. Exact astrological output parity is a separate
  engine-port requirement, not a visual one.
- The available Android visual run used API 28. Production acceptance should repeat the
  same matrix on a current API level and at least one physical device.
- The native Android debug target builds, but a directly installed debug APK expects the
  development bundle/server. The release APK is self-contained and was used for the final
  visual run.

## Verification completed

```text
npm run typecheck                                  PASS
npm run android:export                             PASS (1,801 modules)
./gradlew assembleDebug                            PASS
./gradlew assembleRelease                          PASS
xcodebuild ... test -only-testing:JyotishTests     PASS (29 tests, 0 failures)
Android release install and launch                 PASS
iOS simulator install and launch                   PASS
```

No SwiftUI product source was modified during this parity pass. Both simulators were
reinstalled/relaunched from verified builds after implementation.
