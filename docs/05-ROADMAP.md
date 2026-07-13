# 05 — Build Roadmap & Status

If a session dies mid-build, resume from the first unchecked box, guided by docs 01–04.

## Phase A — Skeleton
- [x] `project.yml` (XcodeGen, iOS 17, target Jyotish) + Info.plist
- [x] Theme.swift (full palette both modes), Components, Ornaments (mandala, rashi marks, divider, kundali chart path)
- [x] L10n.swift, Models.swift, AppState + RootView + JyotishApp

## Phase B — Engines
- [x] Ephemeris (Sun/Moon/planets/Rahu, Lahiri, per docs/03)
- [x] Kundali + Panchanga + Vimshottari Dasha
- [x] Interpreter (rashi/nakshatra/house texts, chandra bala, sadhe sati, guna tables)
- [x] RashifalEngine (seeded, transit-driven, EN/NE phrase banks)
- [x] BikramSambat tables + conversion (verified: 2083-03-20 == 2026-07-04, both year anchors)
- [x] PanditBrain + VastuKnowledge + CityMatcher

## Phase C — Services
- [x] AuthService (Dummy + Supabase anonymous auth), DataStore (Local JSON + Supabase sync)

## Phase D — Features
- [x] Welcome + paged birth flow with kundali ceremony/reveal
- [x] Home dashboard
- [x] Rashifal
- [x] Patro + events
- [x] Parivar + MemberDetail (kundali chart)
- [x] Chat
- [x] Settings
- [x] Relationship-aware Parivar (friends/partners), conditional Home relationship guidance
- [x] Parivar QR sharing/scanning with duplicate protection and simulator paste fallback
- [x] Feature icon hub + More catalog + social person selection + preloaded AI questions
- [x] Full Patro day timing fields and all-horizon Rashifal Dos/Don'ts
- [x] Deterministic Ashtakoota, Dosha, and Upaya evidence for Jyotish Baje
- [ ] Future Dasha/transit date notifications — language/report approved in docs/18; engine and scheduling intentionally not implemented

## Phase E — Ship
- [x] xcodebuild clean, fix all errors
- [x] Install + launch on iPhone 17 Pro simulator
- [x] Screenshot review against 01-DESIGN-SYSTEM §1 "the test" (light + dark, EN + NE)
- [x] Sanity-check math anchors (docs/03 §8) and BS anchors (§7) — all pass;
      Guru Purnima 2026-07-29 → tithi 15 ✓, Saturn in Meen / Jupiter in Karkat mid-2026 ✓
- [x] git commit

## Hard-won lessons (do not re-learn these)
- **Zodiac Unicode/SF glyphs and emoji can render as tofu or disappear** in iOS text —
  use path-drawn rashi marks and no emoji in copy (docs/01 craft rule 4).
- **LazyVGrid with two ForEach ranges must not share integer ids** — leading blank
  calendar cells use a negative range or rows scramble.
- **Date text must carry `.locale(app.locale)`** ("ne_NP") or dates render in English
  while the app is in Nepali.
- **Large fixed-size ornaments inside a ZStack inflate layout** past the screen —
  mount them with `.overlay` on a background color instead.
- QA hooks: launch args `-demoSeed` (seed household), `-tab N` (open tab), `-lang ne`.

## Post-v1 (when Supabase arrives)
Supabase sync is implemented for the current "Continue" path through anonymous auth,
one user-owned `households` JSONB row, and RLS. Next step: add explicit email/phone
account linking UI so users can restore the same account across devices.
Schema is documented in `docs/07-SUPABASE.md`.
