# Store submission checklists

Verified state as of 2026-07-17. Each item is marked **DONE** (verified in this repo/session),
**OWNER** (only the account owner can do it, in App Store Connect / Play Console), or
**BLOCKER** (must be resolved or consciously risk-accepted before submitting).

## Blockers (both stores)

1. **BLOCKER — In-app account deletion.** The app supports account creation (Apple, Google,
   email) but Settings only offers *Sign out*. Apple Guideline 5.1.1(v) requires in-app
   account deletion for any app with account creation; Google Play's User Data policy requires
   an in-app deletion path (or prominent link) too. Implementation sketch: a Supabase Edge
   Function `delete-account` (verify_jwt on, service-role deletion of the auth user +
   household + analytics rows) plus a confirmed "Delete account" action in Settings on both
   platforms. Do not ship the button before the function is deployed — App Review presses it.
2. **BLOCKER — Privacy policy live URL.** Both stores require a public HTTPS privacy-policy
   URL at submission time. [privacy-policy.md](legal/privacy-policy.md) is now accurate but
   unhosted. Host it (and ideally the ToS/EULA) and record the URL here and in
   `marketing/STATUS.md`.
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
| 11 | Account deletion in app | **BLOCKER 1** |
| 12 | Privacy policy URL | **BLOCKER 2** |
| 13 | Build: archive with release config, upload via Xcode/Transporter (`ExportOptions-AppStore.plist` exists) | OWNER |
| 14 | Full native test suite green | DONE — `xcodebuild test` passed 2026-07-17 |

## Google Play

| # | Item | Status |
| --- | --- | --- |
| 1 | Listing text (en + ne): title ≤30, short ≤80, full ≤4000 ([android-en.md](../marketing/app-store/android-en.md), [android-ne.md](../marketing/app-store/android-ne.md)) | DONE — paste into Play Console |
| 2 | Data safety form answers documented | DONE — table in android-en.md; OWNER fills the console form |
| 3 | Screenshots 1080×2160 (within Play's 2:1 limit) | DONE — `marketing/media/playstore-private-kundli-2026-07-17/`; **replace with real Android captures before publishing** (current set renders iOS captures; Play flags misleading UI) |
| 4 | Feature graphic 1024×500 | OWNER/TODO — not yet produced |
| 5 | Permissions declared match usage (CAMERA, RECORD_AUDIO, INTERNET, VIBRATE) | DONE — AndroidManifest reviewed; remove SYSTEM_ALERT_WINDOW for release (debug overlay permission; Play flags it) |
| 6 | Release signing configured | DONE — gradle.properties (commit 7666be5c) |
| 7 | App bundle: `./gradlew bundleRelease` (Play requires .aab, not .apk) | OWNER — run before upload |
| 8 | versionCode/versionName sane (1 / 1.0.0) | DONE |
| 9 | Login + onboarding + tabs verified on emulator | see session notes — release APK smoke test |
| 10 | Account deletion path | **BLOCKER 1** |
| 11 | Privacy policy URL | **BLOCKER 2** |
| 12 | Content rating questionnaire, target audience (13+), ads declaration (none) | OWNER |

## Positioning guardrails (both stores)

- The app is presented as a **private family/social tool for Nepali households** (Kundli
  records, QR sharing, Patro, festivals); traditional readings are supporting guidance.
  Auth-screen tagline updated to "Your family's Kundli, in one private place" and the
  onboarding no longer references "Pandit-ji" (2026-07-17).
- Never claim: public social network, permanent mutual connection, end-to-end encryption,
  anonymity, revocable sharing, guaranteed outcomes, or "Nepal's first".
