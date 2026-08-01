# Social carousel workflow

## Decision

All Jyotish Baje social-carousel work now lives in this repository. The former `D:\viber` collaboration checkout is a paused historical source and is not part of the generation, validation, upload, or proof workflow.

## Package contract

Daily Rashifal uses one cover, twelve individual romanized Nepali rashi slides, and one ending/app-action slide. Instagram exports are 1080x1350 and TikTok exports are 1080x1920. The upload order is always `01` through `14`.

Each dated package should keep its own source copy, editable SVG files, PNG exports, fonts, logo, contact sheet, and provenance information. Do not silently borrow brand files from a different date when preparing a provenance-pinned package.

## Canonical paths

- Automated source: `content/generated/`
- Instagram automation output: `content/instagram/YYYY-MM-DD/daily/`
- TikTok automation output: `content/tiktok/YYYY-MM-DD/daily/`
- Curated packages: `Instagram/YYYY-MM-DD/`
- Upload proof: `proof/YYYY-MM-DD/`
- Daily reports: `reports/daily/`
- Temple inventory and art: `inventory/` and `assets/temples/`

## Tools

- `scripts/render_instagram_carousel_14.cjs` is the current dual-platform daily renderer migrated from the collaboration project.
- `scripts/render_daily_carousel_platforms.cjs` and the legacy renderers are retained because they produced historical packages.
- `scripts/verify_carousel_provenance.py` verifies the original provenance-gated format for packages created from a pushed commit in this repository.
- `scripts/validate_social_carousel.py` checks package counts, dimensions, required files, JSON readability, and the absence of active Chiefo dependencies.
- `scripts/verify_jyotish_migration.py` protects the migration archive and active imported files with SHA-256 hashes.

## Historical preservation

`Instagram/Viber-Archive/` contains the collaboration-era handoffs, notifications, workflow definitions, communication documents, and source metadata that should remain readable but must not run as active Chiefo automation. The full content, proof, report, inventory, and temple collections were promoted to their normal top-level paths.
