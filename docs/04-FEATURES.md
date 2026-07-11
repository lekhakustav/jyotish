# 04 — Feature Specs

## Voice agent (Pandit-ji)
`Services/VoiceAgent.swift` — mic button in the chat input starts speech recognition and
shows the live transcript in the input before send. The app falls back through ne-NP,
hi-IN, en-IN, and en-US recognizers depending on what iOS makes available. Server-side
ElevenLabs config (`ELEVENLABS_API_KEY`, `ELEVENLABS_STT_MODEL=scribe_v2`,
`ELEVENLABS_TTS_MODEL=eleven_multilingual_v2`, agent IDs) is kept in ignored env files for
voice-agent and transcription work; it must not be placed in Info.plist or app source.
Spoken replies remain opt-in so typed chat does not unexpectedly start audio.

## Popular Aarti (deferred)
The placeholder doorway and "coming soon" list are intentionally not mounted in the
current UI. Add the entry point back only when the library has real lyrics/audio content.

## Tabs (3 + contextual destinations)
| Tab | Icon | Screen |
|---|---|---|
| Home | `house.fill` | Dashboard |
| Rashifal | `sparkles` | Daily/weekly/monthly/yearly |
| Parivar | `person.3.fill` | Family + kundalis |
Patro is opened from the Home date block and pushes onto the navigation stack. Pandit-ji
opens from Home/Rashifal as a modal chat. Settings remains reachable from Home (gear).

## 1. Onboarding
- **WelcomeView:** plain full-screen canvas, brand logo, app name in serif + Devanagari,
  one saffron button: "Continue with account (demo)" → DummyAuth → ProfileSetup, plus the
  language segmented control.
- **Birth flow (paged, one decision per screen — docs/01 craft rule 1):**
  step 1 name → step 2 gender (bare rows) → step 3 DOB (wheel) → step 4 time
  (wheel + "time unknown" toggle → 06:00) → step 5 birthplace (curated city list) →
  **ceremony**: rotating mandala + quiet rashi mark + "Drawing the kundali…" (~2s) → reveal screen with the
  computed rashi mark, moon rashi + nakshatra, and a blessing "शुभ होस् 🙏" → Home.
  Gold-diamond progress dots at top; back chevron; steps spring-slide from trailing edge.
  The same flow (prefixed with a relation step) is used for adding family members.

## 2. Home dashboard (the aarti thali)
Order: small settings header → **Pandit AI discovery module** → **personal rashifal block**
(unframed rashi mark + 2-line summary + star score + "read more" → Rashifal; dasha shown
as one quiet text line) → **today's tithi block** + Temple of the Day → **family quick row**
only when relatives exist → **upcoming events** only when events exist.

The Pandit module combines a general “Ask anything” prompt with three plain-language,
one-tap starters: today through the user's kundli, finding a shubh time, and family guidance.
Each starter opens chat and immediately sends a richer deterministic-tool prompt. After three
successful interactions, the teaching surface collapses to one rotating starter while the
general prompt remains available.

Temple of the Day should move from pure day-of-year rotation to the BS 2083 planning
dataset in `docs/10-TEMPLE-OF-DAY-SCHEDULE-2083.md`: festival anchors win first, then
tithi/weekday fallbacks choose the Nepal temple and explanation.
The Home artwork uses a stable 4:3 `scaledToFill` crop with matching placeholder geometry;
the detail sheet can preserve the fuller original composition.

## 3. Rashifal
- Segmented: दैनिक / साप्ताहिक / मासिक / वार्षिक.
- Default = user's janma rashi; horizontal rashi-mark picker to read any other rashi
  (the "grandmother checks the whole family's signs" use case).
- Reading: rashi mark, generated text, domain score dots
  (career/family/health/wealth/love as star icons 1–5), lucky color/number/day, upaya line.

## 4. Patro (Bikram Sambat calendar)
- Month grid of BS month; each day cell: BS digit (Nepali numerals in NE), small tithi name
  under it, and an event dot when needed. Saturdays are sindoor-tinted (Nepal weekend);
  today uses a subtle sunken background.
- Header: "Asar 2083"; chevrons move months and tapping the month opens direct
  month/year/day selection.
- Day cells show BS day + tithi + event dot only; AD day numbers are intentionally hidden.
- Tap a day → detail sheet: full panchanga for that day + its events + **"Add event"**
  (title, optional note, repeat-yearly toggle for birthdays). Events stored with BS date.

## 5. Parivar (family)
- List of members grouped around the user. The tree uses names and relation labels with
  gold connector lines; rashi marks stay in the member list/detail context.
- Add member: relation picker (Son, Daughter, Husband, Wife, Father, Mother, Grandson,
  Granddaughter, Brother, Sister…) + same birth form. Relation drives labels everywhere:
  "Your son Aarav" / "तपाईंको छोरा आरव".
- MemberDetailView: North-Indian kundali chart (Path-drawn), lagna/rashi/nakshatra marks,
  mahadasha timeline, personality reading, guna table (gemstone, deity, mantra, lucky items).

## 6. Pandit-ji chat
- Chat UI: modal with close button and history drawer. Pandit messages are bare serif
  prose on the canvas; user messages are the only tinted bubbles. Lightweight Markdown
  is rendered, never exposed as raw markers. The empty state greets the user by name and
  reuses the three large Home starter cards. After a question, those starters give way to
  two context-sensitive follow-ups derived from the current intent.
- Home starter taps carry a one-shot prompt into chat and send it automatically. Friendly
  phrases such as “shubh time” are part of the deterministic Muhurta intent vocabulary, so
  users never need to know the engine's technical command language.
- **OpenAI-backed Pandit agent** (`server/jyotish-agent.mjs` locally,
  `supabase/functions/jyotish-agent` in production) receives the full app context
  from `AgentService`: self and family birth data, computed kundlis, readings, current
  dasha, daily rashifal, saved events, chat history, and the local fallback answer.
  It keeps `OPENAI_API_KEY` server-side and answers in Pandit-ji style. The model
  interprets authoritative deterministic evidence; it does not invent Jyotish calculations.
- Chat requests stream over server-sent events when available. The assistant row appears
  immediately with a typing indicator, then fills character-by-character as deltas arrive.
- **PanditToolPlanner** is the agentic, local-first coordinator:
  - understands ordinary requests without requiring feature or astrology vocabulary,
  - calls deterministic Kundali/Dasha, Panchang, Muhurta, compatibility, festival/vrat,
    and devotional guidance tools,
  - always structures guidance as Direct answer → Why Baje says this → What to do →
    Optional practice → Uncertainty when inputs are incomplete,
  - offers only relevant actions in a horizontally scrolling row: Add to Patro, Remind me,
    Open Patro, Compare, Listen, See Kundli, and Share,
  - requires confirmation before Patro or notification writes and avoids duplicate events,
  - supports personal daily guidance, family/child questions, practical remedies,
    devotional practice and Puja support through the same single chat entry point,
- **PanditBrain** remains available for established local interpretation domains:
  - resolves the family member mentioned ("my son" → the son's chart; asks to add if absent),
  - **color questions** → member's rashi lucky colors + current dasha lord color,
  - **city/place questions** → CityMatcher (rashi→cities DB with reasons),
  - **vastu** → VastuKnowledge (directions, rooms, colors, main door, kitchen, bedroom, remedies),
  - **dasha/kundali/nakshatra/rashifal questions** → live engine calls,
  - profile-gated: if the needed member lacks birth data → politely ask to fill profile first,
  - fallback: warm general jyotish answer + offer of what he can do.
- Chat history persists via DataStore. Voice input remains optional; spoken replies are
  off by default so typed questions do not unexpectedly start audio.

## 7. Settings
Language (EN/नेपाली), theme (Light "Prabhat" / Dark "Ratri" / System), profile edit,
sign-out (returns to Welcome; data kept). No about/credit block in the live UI.

## 8. Bilinguality
`L10n` string tables; every user-facing string keyed. Nepali digits helper for Patro.
Language switch is instant (AppState.language republishes).
