# 12 — Brand Assets

## Current logo
The production name is **Jyotish baje** / **ज्योतिष बाजे**.

The current minimalist mark is a non-swastika Nepali kundali/mandala icon:

- Source asset: `assets/brand/jyotish-baje-logo-1024.png`
- App icon: `Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png`
- In-app welcome logo: `Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png`

The mark uses a sindoor/gold kundali diamond, circular jyotish orbit, and four bindu dots.
The image generation service rejected the swastika prompt, so the shipped logo avoids that
symbol while preserving Nepali devotional visual language.

## Supabase storage
Attempted upload target:

```text
temple-of-day/brand/jyotish-baje-logo-1024.png
```

The current publishable app key cannot upload storage objects:

```text
new row violates row-level security policy
```

That is the correct production posture. To store brand assets in Supabase, upload from a
trusted environment with `SUPABASE_SERVICE_ROLE_KEY`, or add a dedicated admin-only Edge
Function/storage policy. Do not add storage write permission for anonymous app clients.

Once the service-role key is present in ignored `.env.local`, run:

```sh
npm run upload:brand-logo
```
