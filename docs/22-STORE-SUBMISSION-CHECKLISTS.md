# Store submission checklists

Verified state as of 2026-07-17. Each item is marked **DONE** (verified in this repo/session),
**OWNER** (only the account owner can do it, in App Store Connect / Play Console), or
**BLOCKER** (must be resolved or consciously risk-accepted before submitting).

## Blockers (both stores)

1. **DONE — In-app account deletion (2026-07-17).** The `delete-account` Supabase Edge
   Function is deployed (verify_jwt on; wipes `households` and `analytics_events` rows, then
   the auth user — data first, so a failure leaves the account retryable). Settings on both
   platforms now has a confirmed, destructive "Delete account" action (en + ne) that clears
   local state only after the server confirms. Verified end-to-end on the Android emulator
   (account deleted through the UI; server then rejects the credentials) and API-level with a
   throwaway user; the iOS confirmation flow was verified on the simulator and the suite
   passes.
2. **BLOCKER — Privacy policy live URL.** Both stores require a public HTTPS privacy-policy
   URL at submission time. [privacy-policy.md](legal/privacy-policy.md) is now accurate but
   the hosted copies at `www.orecci.com/jyotish/…` (linked from in-app Settings) predate the
   2026-07-17 rewrite. Re-publish the corrected privacy policy and terms to those URLs and
   record the date here and in `marketing/STATUS.md`.
3. **DONE — Legal copy truthfulness.** Privacy policy, ToS, and EULA now disclose camera
   (QR-scan only), first-party analytics, real sign-in methods (Apple/Google/email), and the
   Kundli-QR user-to-user data flow, and describe the app as a private family tool rather
   than an astrology app (2026-07-17 revision).

## Apple App Store

| # | Item | Status |
| --- | --- | --- |
| 1 | Positioning: default tab is My Kundli & QR; tab order My Kundli & QR → Rashifal → Religious | DONE — verified on simulator (iOS 26.5, fresh install) |
| 2 | Metadata: name, subtitle, promo text, keywords, description ([ios-en-GB.md](../marketing/app-store/ios-en-GB.md), [ios-ne-NP.md](../marketing/app-store/ios-ne-NP.md)) | DONE — paste into App Store Connect |
| 3 | No unverifiable superlatives ("Nepal's first") in metadata | DONE |
| 4 | Review notes with suggested review path ([review-notes.md](../marketing/app-store/review-notes.md)) | DONE — paste into App Review Information |
| 5 | Demo account for App Review | DONE — `review.test+appstore@sodhera.com` exists and signs in (verified end-to-end on simulator); enter the password (held by owner, not in Git) in App Review Information |
| 6 | Screenshots 1320×2868, iPhone-framed, ten slides | DONE — regenerated 2026-07-17 in `marketing/media/appstore-private-kundli-2026-07-16/` |
| 7 | Privacy nutrition label matches policy §13 (Name, Email, User Content, User ID, Product Interaction; no tracking) | OWNER — fill in App Store Connect exactly as policy §13 |
| 8 | `NSCameraUsageDescription` / mic / speech strings present | DONE — in Info.plist |
| 9 | PrivacyInfo.xcprivacy present, `NSPrivacyTracking=false` | DONE |
| 10 | Sign in with Apple offered alongside Google (Guideline 4.8) | DONE — verified on device |
| 11 | Account deletion in app | DONE — Settings → Delete account, backed by the deployed `delete-account` function |
| 12 | Privacy policy URL | **BLOCKER 2** |
| 13 | Build: archive with release config, upload via Xcode/Transporter (`ExportOptions-AppStore.plist` exists) | OWNER |
| 14 | Full native test suite green | DONE — `xcodebuild test` passed 2026-07-17 |

## Google Play

| # | Item | Status |
| --- | --- | --- |
| 1 | Listing text (en + ne): title ≤30, short ≤80, full ≤4000 ([android-en.md](../marketing/app-store/android-en.md), [android-ne.md](../marketing/app-store/android-ne.md)) | DONE — paste into Play Console |
| 2 | Data safety form answers documented | DONE — table in android-en.md; OWNER fills the console form |
| 3 | Screenshots 1080×2160 (within Play's 2:1 limit) | DONE — `marketing/media/playstore-private-kundli-2026-07-17/`, rendered from real Android emulator captures (2026-07-17) |
| 4 | Feature graphic 1024×500 | OWNER/TODO — not yet produced |
| 5 | Permissions declared match usage (CAMERA, RECORD_AUDIO, INTERNET, VIBRATE) | DONE — AndroidManifest reviewed; SYSTEM_ALERT_WINDOW stripped from release builds via release-variant manifest (2026-07-17) |
| 6 | Release signing configured | DONE — gradle.properties (commit 7666be5c) |
| 7 | App bundle: `./gradlew bundleRelease` (Play requires .aab, not .apk) | OWNER — run before upload |
| 8 | versionCode/versionName sane (1 / 1.0.0) | DONE |
| 9 | Login + onboarding + tabs verified on emulator | see session notes — release APK smoke test |
| 10 | Account deletion path | DONE — verified end-to-end on emulator 2026-07-17 |
| 11 | Privacy policy URL | **BLOCKER 2** |
| 12 | Content rating questionnaire, target audience (13+), ads declaration (none) | OWNER |

## Positioning guardrails (both stores)

- The app is presented as a **private family/social tool for Nepali households** (Kundli
  records, QR sharing, Patro, festivals); traditional readings are supporting guidance.
  Auth-screen tagline updated to "Your family's Kundli, in one private place" and the
  onboarding no longer references "Pandit-ji" (2026-07-17).
- Never claim: public social network, permanent mutual connection, end-to-end encryption,
  anonymity, revocable sharing, guaranteed outcomes, or "Nepal's first".
