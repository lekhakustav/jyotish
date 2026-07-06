# 12 — Brand Assets

## Current logo
The production name is **Jyotish baje** / **ज्योतिष बाजे**.

The current minimalist mark is a Hindu swastika with Nepali kundali/mandala geometry:

- Source asset: `assets/brand/jyotish-baje-logo-1024.png`
- Transparent source: `assets/brand/jyotish-baje-swastika-logo-transparent.png`
- App icon: `Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png`
- In-app welcome logo: `Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png`

The mark uses sindoor red, temple gold, marigold, a circular jyotish orbit, lotus/mandala
petals, and four bindu dots. It is upright Hindu/Nepali devotional symbolism, not tilted
Nazi-style iconography.

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
