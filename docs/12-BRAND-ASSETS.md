# 12 — Brand Assets

## Current logo
The production name is **Jyotish baje** / **ज्योतिष बाजे**.

The current minimalist mark is a Hindu swastika with balanced Nepali kundali geometry:

- Source asset: `assets/brand/jyotish-baje-logo-1024.png`
- Transparent source: `assets/brand/jyotish-baje-swastika-logo-transparent.png`
- App icon: `Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png`
- In-app welcome logo: `Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png`

The mark uses sindoor red and temple gold. The swastika is upright, centered, equal-armed,
and drawn with rounded pointed terminals so it reads as a devotional Hindu/Nepali symbol,
not tilted Nazi-style iconography. Onboarding uses the mark without extra decorative
mandala/petal line work.

## Supabase storage
Uploaded target:

```text
temple-of-day/brand/jyotish-baje-logo-1024.png
```

Public URL:

```text
https://ghfcssxptpazfbtiwshz.supabase.co/storage/v1/object/public/temple-of-day/brand/jyotish-baje-logo-1024.png
```

The publishable app key cannot upload storage objects; Supabase correctly blocks that with
RLS. Brand uploads must use `SUPABASE_SERVICE_ROLE_KEY` from a trusted environment or a
dedicated admin-only Edge Function/storage policy. Do not add storage write permission for
anonymous app clients.

Once the service-role key is present in ignored `.env.local`, run:

```sh
npm run upload:brand-logo
```

To regenerate the local source PNGs and Xcode asset catalog copies after geometry changes:

```sh
npm run generate:brand-assets
```
