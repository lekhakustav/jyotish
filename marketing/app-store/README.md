# App Store product page

This folder is the text source of truth for approval-facing App Store metadata and review notes.
It is intentionally separate from campaign copy because App Review must see an exact,
demonstrable description of the shipped binary.

## Current story

The product page leads with **private Kundli sharing for Nepali Hindu families**:

1. keep a personal Kundli and trusted profiles in one private household;
2. intentionally share the name and birth details behind a Kundli through QR;
3. scan a trusted person's QR and choose the relationship locally;
4. use the Religious tab for Nepal-specific Patro, Tithi, festivals, Rashifal, and guidance.

The QR exchange is not described as encrypted, anonymous, a public social network, a permanent
mutual connection, or automatic two-way synchronization because the shipped v1 flow does not
provide those properties.

`Nepal's first` is a campaign hypothesis, not approved metadata. Do not place it in App Store
Connect unless a dated competitive search and legal review substantiate the exact claim.

## Files

- `ios-en-GB.md`: paste-ready English (U.K.) App Store product-page fields.
- `ios-ne-NP.md`: Nepali reference copy for the listing (and ads/web reuse).
- `android-en.md` / `android-ne.md`: paste-ready Google Play listing fields plus the
  data-safety form answers.
- `review-notes.md`: paste-ready review explanation, test path, and demo-account slot
  (the password is held by the owner and is never committed).

Generate the current screenshot sets with:

```sh
python3 scripts/generate_appstore_screenshots.py                     # iOS 1320x2868
python3 scripts/generate_appstore_screenshots.py --platform android  # Play 1080x2160
```

The Play set renders real Android emulator captures from
`marketing/media/playstore-android-source/`.

The output stays in ignored `marketing/media/`; large product-page binaries must not be added
to Git.
