# ज्योतिष — Jyotish

A SwiftUI iOS app that is your family's pandit: real Vedic astrology (kundali, dasha,
panchanga), generated rashifal, a Bikram Sambat patro with events, a family tree of
kundalis, and a bilingual (EN/नेपाली) Pandit-ji chatbot. Local-first; Supabase-ready
service layer stubs for future sync.

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
