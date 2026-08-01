# Jyotish social carousel home

This Jyotish repository is now the source of truth for every Instagram and TikTok carousel asset, format, renderer, source file, proof record, and historical package migrated from the former collaboration repository.

## Active locations

- `content/generated/` — Daily and weekly Rashifal source data and generated SVG summaries.
- `content/instagram/YYYY-MM-DD/` — Automated Instagram carousel packages.
- `content/tiktok/YYYY-MM-DD/` — Automated TikTok carousel packages.
- `Instagram/YYYY-MM-DD/` — Human-prepared and earlier platform packages, including editable files, exports, fonts, logos, and contact sheets.
- `proof/YYYY-MM-DD/` — Historical upload screenshots and readbacks.
- `scripts/` — Active renderers and verification tools.
- `Instagram/Viber-Archive/` — Static historical records and retired workflow documents that are retained for completeness but are not active automation.

`D:\viber` is not required for future carousel work. Do not read or sync it unless the user explicitly asks for that repository.

## Current daily format

- 14 ordered slides.
- Instagram: 1080x1350.
- TikTok: 1080x1920.
- Warm cream canvas, editorial Fraunces headings, Inter supporting text, restrained Jyotish red accent.
- Romanized Nepali rashi names in canonical order: Mesh, Vrish, Mithun, Karkat, Simha, Kanya, Tula, Vrischik, Dhanu, Makar, Kumbha, Meen.
- Meen remains its own sign slide and slide 14 is the app action page.
- Upload files in `01` through `14` order.

## Render and verify

```powershell
$env:NODE_PATH='C:\Users\user\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules'
node scripts/render_instagram_carousel_14.cjs --date YYYY-MM-DD --edition daily --platform both --content content/generated/daily-rashifal-YYYY-MM-DD.json --asset-date YYYY-MM-DD
python scripts/validate_social_carousel.py
python scripts/verify_jyotish_migration.py verify
```

The migration verifier protects the imported files with SHA-256 hashes. Future dated packages may be added without rebuilding the historical migration manifest.
