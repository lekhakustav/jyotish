# ज्योतिष बाजे — Jyotish baje

A SwiftUI iOS app that is your family's Jyotish baje: real Vedic astrology (kundali, dasha,
panchanga), generated rashifal, a Bikram Sambat patro with events, a family tree of
kundalis, and a bilingual (EN/नेपाली) Jyotish Baje chatbot. Local-first with optional
Supabase sync for real user profiles, family data, events, settings, and chat history.

## Run it
```sh
xcodegen generate
xcodebuild -project Jyotish.xcodeproj -scheme Jyotish \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
# then install/launch the built .app with `xcrun simctl`
```

## Run the Jyotish Baje backend
Copy `OPENAI_API_KEY` into ignored `.env.local` first, then:

```sh
npm run agent
```

The iOS app posts chat context to `http://127.0.0.1:8788` by default and falls back to the
local `PanditBrain` if the backend is unavailable. See `docs/06-BACKEND-AGENT.md`.

For production without a dedicated server, deploy `supabase/functions/jyotish-agent` and set
`JYOTISH_AGENT_ENDPOINT_URL` to the function URL.

## Documents (read these first — they are the source of truth)
- [docs/00-VISION.md](docs/00-VISION.md) — what & why, the vibe
- [docs/01-DESIGN-SYSTEM.md](docs/01-DESIGN-SYSTEM.md) — the taste bible (palette, ornament, motion)
- [docs/02-ARCHITECTURE.md](docs/02-ARCHITECTURE.md) — structure, Supabase-readiness
- [docs/03-ASTROLOGY-ENGINE.md](docs/03-ASTROLOGY-ENGINE.md) — the real math
- [docs/04-FEATURES.md](docs/04-FEATURES.md) — screen-by-screen specs
- [docs/05-ROADMAP.md](docs/05-ROADMAP.md) — build order & status
- [docs/06-BACKEND-AGENT.md](docs/06-BACKEND-AGENT.md) — OpenAI-backed backend agent contract
- [docs/07-SUPABASE.md](docs/07-SUPABASE.md) — Supabase auth, RLS, schema, and key handling
- [docs/08-UI-REVIEW.md](docs/08-UI-REVIEW.md) — page-by-page UI audit and container rubric
- [docs/09-TRANSCRIPT-GOALS.md](docs/09-TRANSCRIPT-GOALS.md) — critique-derived product goals and implementation status
- [docs/10-TEMPLE-OF-DAY-SCHEDULE-2083.md](docs/10-TEMPLE-OF-DAY-SCHEDULE-2083.md) — temple-of-day schedule
- [docs/11-TEMPLE-ART-ASSETS.md](docs/11-TEMPLE-ART-ASSETS.md) — temple art storage contract
- [docs/16-TEMPLE-OF-DAY-MAINTAINER.md](docs/16-TEMPLE-OF-DAY-MAINTAINER.md) — daily tithi-matched art generation and buffer runbook
- [docs/12-BRAND-ASSETS.md](docs/12-BRAND-ASSETS.md) — logo, app icon, and Supabase brand asset notes
- [docs/14-PRODUCT-UX-INTENT-REVIEW.md](docs/14-PRODUCT-UX-INTENT-REVIEW.md) — current UI/UX audit, market feature landscape, user-intent model, and Jyotish Baje agent direction
- [docs/18-RELATIONSHIPS-FEATURE-HUB-AND-FUTURE-DATES.md](docs/18-RELATIONSHIPS-FEATURE-HUB-AND-FUTURE-DATES.md) — relationship/QR mechanics, feature hub, safety contracts, and the report-only future-date notification language
- [docs/19-PRODUCT-ANALYTICS.md](docs/19-PRODUCT-ANALYTICS.md) — local-first event capture, privacy rules, Supabase schema, taxonomy, and queries
- [docs/20-ANDROID-PARITY-FEATURE-REPORTS.md](docs/20-ANDROID-PARITY-FEATURE-REPORTS.md) — Android voice/QR flows, feature-key contract, prepared Dasha reports, and release checks
- [marketing/README.md](marketing/README.md) — research, Veo prompts, creative production, Google Drive media, experiments, and performance analysis
