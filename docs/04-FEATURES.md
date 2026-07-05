# 04 — Feature Specs

## Voice agent (Pandit-ji)
`Services/VoiceAgent.swift` — mic button in the chat input starts on-device speech
recognition (SFSpeechRecognizer; ne-NP unavailable on iOS → hi-IN Devanagari fallback →
en-IN); tapping stop sends the transcript as a question. Spoken replies use
AVSpeechSynthesizer only when explicitly enabled in code; typed chat does not auto-speak
by default. Recognition degrades gracefully (mic dims) when permissions are unavailable.

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
- **WelcomeView:** plain full-screen canvas, diya flame, app name in serif + Devanagari,
  one saffron button: "Continue with account (demo)" → DummyAuth → ProfileSetup, plus the
  language segmented control.
- **Birth flow (paged, one decision per screen — docs/01 craft rule 1):**
  step 1 name → step 2 gender (bare rows) → step 3 DOB (wheel) → step 4 time
  (wheel + "time unknown" toggle → 06:00) → step 5 birthplace (curated city list) →
  **ceremony**: rotating mandala + "Drawing the kundali…" (~2s) → reveal screen with the
  computed rashi mark, moon rashi + nakshatra, and a blessing "शुभ होस् 🙏" → Home.
  Gold-diamond progress dots at top; back chevron; steps spring-slide from trailing edge.
  The same flow (prefixed with a relation step) is used for adding family members.

## 2. Home dashboard (the aarti thali)
Order: small settings header → **today's tithi block** (BS day/month large + tithi,
paksha, nakshatra on separate lines + Open Patro action) → **personal rashifal block**
(unframed rashi mark + 2-line summary + star score + "read more" → Rashifal; dasha shown
as one quiet text line) → **family quick row** only when relatives exist → **upcoming
events** only when events exist. Home also carries the floating Pandit-ji chat action.

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
  prose on the canvas; user messages are the only tinted bubbles.
  Suggestion chips ("Which color suits my son's room?", "Best city for me?", "Vastu for main door",
  "मेरो दशा कस्तो छ?").
- **PanditBrain** (rule-based intent router, bilingual in/out) with tool access:
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
