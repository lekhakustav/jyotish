# 20 — Android Parity and Prepared Feature Reports

Last updated: 2026-07-13

This is the maintainer guide for the Android parity expansion. SwiftUI remains the product
source of truth, but feature identifiers and agent behavior are now explicit contracts that
must stay aligned across both clients.

## User flows

### Voice typing

1. Open Jyotish Baje and tap the microphone while the composer is empty.
2. Android requests microphone permission and starts the installed speech service using
   `ne-NP` for Nepali or `en-IN` for English.
3. Interim recognition replaces the composer draft. Tap the microphone to stop, edit if
   needed, then send normally.
4. Missing permission, locale, or recognition service is a visible recoverable state.

Implementation: `src/screens/ChatScreen.tsx`. Native configuration: `app.json` with the
`expo-speech-recognition` config plugin and `RECORD_AUDIO` permission.

### Parivar QR

`My QR` requires a self profile with complete birth data. The v1 QR contains name, gender,
and birth data in a URL-safe base64 JSON envelope. It never contains account IDs, auth
tokens, stored relatives, or a calculated Kundli. `Scan QR` accepts camera input or pasted
text. The receiver chooses the relationship; the app rejects the same normalized name plus
civil birth date and recalculates Kundli locally.

Implementation: `src/family-qr.ts`, `src/screens/FamilyQRModal.tsx`, and
`src/screens/FamilyScreen.tsx`. Keep the envelope interoperable with
`Jyotish/Features/Family/FamilyQRCode.swift`.

### Feature reports

`src/features.ts` is Android's bilingual catalog. The five primary items are Panchang,
Dashas & Life Phase, Muhurat Finder, Dosha Check, and Kundli Matching. Every other feature
is in More. Social features require a second complete Kundli and otherwise route to Parivar.

Launching a feature opens chat with `feature:<feature-id>:<member-or-self>`. App state parses
that key and calls `buildFeatureToolReport` in `src/jyotish-reports.ts`. The request sends:

- `requestedFeature` for report-mode behavior;
- `toolEvidence` as authoritative deterministic facts and uncertainty;
- `localFallbackReply` as the complete usable report;
- household, event, and recent conversation context.

The local/Edge agent prompt must interpret evidence, never override it. Report mode must
not collapse exact Dasha dates or requested life-area sections into a generic short reply.

## Dasha calculation

Vimshottari order and year spans are Ketu 7, Venus 20, Sun 6, Moon 10, Mars 7, Rahu 18,
Jupiter 16, Saturn 19, and Mercury 17. The birth Mahadasha balance comes from the unused
fraction of the saved Moon nakshatra. Antardasha duration is Mahadasha years multiplied by
the sub-lord years divided by 120. Dates use a 365.25-day year, matching the existing mobile
timeline contract.

The report always discloses that uncertain birth time and the compact Android ephemeris can
shift boundaries. Do not let a language model recalculate these dates silently.

## Analytics and privacy

Feature opens, More opens, selected relationship type, report starts, QR opens/scans/imports,
and chat source/feature are recorded. Analytics properties must never contain a person's
name, birth data, QR value, or raw chat text. `src/analytics.ts` persists a bounded local
queue and uploads only for authenticated users.

## Release verification

```sh
npm run typecheck
npm run android:export
npm run android:prebuild -- --no-install
cd android && ./gradlew assembleDebug assembleRelease
```

Then verify camera scanning and voice recognition on a physical Android phone; an emulator
can validate permission and paste paths but cannot prove the hardware/service path. Build
and test the iOS target after any catalog or agent-contract change.
