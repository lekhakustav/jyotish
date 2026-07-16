# Private Kundli sharing repositioning

## Intent

Reposition Jyotish Baje for App Review with the smallest truthful product change: make private
Kundli exchange the first experience and treat the existing daily astrology surface as a
religious supporting tab.

## Evidence recovered from the earlier discussion

The July 16 `Discuss performance tweaks` Codex task found four approval risks:

1. the submitted screenshot order led with generic Rashifal and astrology reports;
2. Parivar QR and family context appeared too late to affect the reviewer's category judgment;
3. cosmetic, localisation and metadata-only changes rarely resolved Guideline 4.3(b);
4. `Nepal's first` was an unverifiable superlative and the current QR import was not a permanent
   two-way social connection.

This implementation promotes the real QR workflow without claiming synchronization or a public
social graph.

## Shipped hierarchy

| Position | Tab | Purpose |
| --- | --- | --- |
| 1 | My Kundli & QR | Default private birth-profile storage, QR share/scan and saved charts |
| 2 | Rashifal | Existing daily, weekly, monthly and yearly readings |
| 3 | Religious | Existing Home content: daily context, features, Patro, temple and Baje access |

The Swift `AppTab` tags and Android string union remain stable (`family`, `rashifal`, `home`) so
analytics and deep links keep their existing destination identifiers. Only order, default
selection and user-facing naming changed.

## Privacy mechanics

The v1 QR payload remains versioned and interoperable across iOS and Android. It contains name,
gender and birth data. It does not contain a calculated chart, receiver relationship, account
credential, chat text or analytics identifier. A receiver chooses the relationship and stores
the imported profile in their own household.

`private` describes an intentional, non-public exchange. It does not mean end-to-end encrypted,
anonymous or revocable after a recipient has copied the payload. The UI tells users to share only
with people they trust.

## QA and screenshot capture

Use a synthetic household only:

```sh
xcrun simctl launch booted com.sodhera.jyotishbaje -demoSeed -tab 0
xcrun simctl launch booted com.sodhera.jyotishbaje -demoSeed -tab 0 -showMyQR
```

`-tab 0` opens My Kundli & QR, `-tab 1` opens Rashifal, and `-tab 2` opens Religious. The legacy
Parivar index `-tab 3` still opens My Kundli & QR for older scripts.

The App Store screenshot generator reads synthetic captures from ignored `marketing/media/` and
writes the finished 1320x2868 set there. Do not commit the generated PNG files.

## Approval copy decision

The campaign idea `Nepal's First Private Kundli Sharing Platform` is recorded as a hypothesis,
not pasted into App Store metadata. The approval-facing phrase is `Private Kundli Sharing` or
`Private Kundli sharing for Nepal` until a dated competitive substantiation and legal review can
support the superlative.
