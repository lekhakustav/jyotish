# ज्योतिष — Jyotish

A SwiftUI iOS app that is your family's pandit: real Vedic astrology (kundali, dasha,
panchanga), generated rashifal, a Bikram Sambat patro with events, a family tree of
kundalis, and a bilingual (EN/नेपाली) Pandit-ji chatbot. Local-first with optional
Supabase sync for real user profiles, family data, events, settings, and chat history.

## Run it
```sh
xcodegen generate
xcodebuild -project Jyotish.xcodeproj -scheme Jyotish \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
# then install/launch the built .app with `xcrun simctl`
```

## Documents (read these first — they are the source of truth)
- [docs/00-VISION.md](docs/00-VISION.md) — what & why, the vibe
- [docs/01-DESIGN-SYSTEM.md](docs/01-DESIGN-SYSTEM.md) — the taste bible (palette, ornament, motion)
- [docs/02-ARCHITECTURE.md](docs/02-ARCHITECTURE.md) — structure, Supabase-readiness
- [docs/03-ASTROLOGY-ENGINE.md](docs/03-ASTROLOGY-ENGINE.md) — the real math
- [docs/04-FEATURES.md](docs/04-FEATURES.md) — screen-by-screen specs
- [docs/05-ROADMAP.md](docs/05-ROADMAP.md) — build order & status
- [docs/06-BACKEND-AGENT.md](docs/06-BACKEND-AGENT.md) — OpenAI-backed backend agent contract
- [docs/07-SUPABASE.md](docs/07-SUPABASE.md) — Supabase auth, RLS, schema, and key handling
