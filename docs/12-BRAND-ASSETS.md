# 12 — Brand Assets

## Current logo
The production name is **Jyotish baje** / **ज्योतिष बाजे**.

The current minimalist mark is an imagegen-created Hindu swastika with delicate
Nepali kundali/mandala geometry:

- Canonical transparent source: `assets/brand/jyotish-baje-logo-imagegen-transparent.png`
- Source candidate: `assets/brand/candidates/jyotish-baje-logo-imagegen-source.png`
- Transparent candidate: `assets/brand/candidates/jyotish-baje-logo-imagegen-transparent.png`
- Published source asset: `assets/brand/jyotish-baje-logo-1024.png`
- Transparent app source: `assets/brand/jyotish-baje-swastika-logo-transparent.png`
- App icon: `Jyotish/Assets.xcassets/AppIcon.appiconset/icon1024.png`
- In-app welcome logo: `Jyotish/Assets.xcassets/BrandLogo.imageset/jyotish-baje-logo.png`

The mark uses sindoor red and temple gold. The swastika is upright, centered,
slimmer than the previous icon, and uses curved rounded-point terminals so it
reads as a devotional Hindu/Nepali symbol, not tilted Nazi-style iconography.
The surrounding geometry is intentionally sparse: a thin orbit, bindu dots,
small lotus hints, and light kundali-inspired accents.

## Imagegen prompt
Use this prompt when a future redesign needs the same direction:

```text
Use case: logo-brand
Asset type: transparent PNG logo mark for a refined iOS astrology app called Jyotish baje.
Primary request: Create a minimalist, sophisticated Hindu/Nepali swastika logo mark with tasteful, delicate geometric patterns around it. The swastika should be much slimmer and more elegant than a bold app icon: thin-to-medium stroke, equal proportions, centered symmetry, rounded pointed terminals, graceful curves, and balanced negative space. Around it, add a very subtle circular jyotish/mandala geometry: fine gold hairline orbit, four small bindu dots, tiny lotus-petal hints at cardinal points, and sparse kundali-inspired line accents. The surrounding pattern must feel premium and quiet, not busy, not childish, not thick, not ornate.
Style: refined vector-logo look, flat colors, high-end spiritual brand identity, crisp antialiased edges, no shadows, no texture, no gradients.
Palette: sindoor red mark with restrained temple gold accents; no black, no neon, no extra colors.
Composition: centered square logo with generous padding, usable at small iOS sizes, fully separated from background.
Cultural constraints: upright Hindu/Nepali devotional swastika only, not tilted, not Nazi-style, no political associations.
Background removal requirement: Place the logo on a perfectly flat solid #00ff00 chroma-key background for background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation. Do not use #00ff00 anywhere in the logo. No text, no watermark, no mockup, no paper, no frame.
```

The transparent source was produced by removing the chroma-key background from
the imagegen output with the local `imagegen` skill's `remove_chroma_key.py`
helper. Keep the source candidate in `assets/brand/candidates/` so future Codex
runs can compare or reprocess the original generation.

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

To regenerate the local source PNGs and Xcode asset catalog copies after
replacing `assets/brand/jyotish-baje-logo-imagegen-transparent.png`:

```sh
npm run generate:brand-assets
```

The generation script does not redraw the logo. It resizes and composites the
canonical transparent imagegen asset into the app icon, in-app logo, and
published 1024 px source PNGs.
