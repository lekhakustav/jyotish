# 04 — Feature Specs

## Voice agent (Pandit-ji)
`Services/VoiceAgent.swift` — mic button in the chat input starts on-device speech
recognition (SFSpeechRecognizer; ne-NP unavailable on iOS → hi-IN Devanagari fallback →
en-IN); tapping stop sends the transcript as a question. Replies are spoken via
AVSpeechSynthesizer (same voice fallback chain), toggled by the speaker button in the
chat header. Degrades gracefully (mic dims) when recognition/permissions are unavailable.

## Popular Aarti (placeholder)
Home carries a "Popular Aarti / लोकप्रिय आरती" doorway → `AartiView`, a flat hairline
list of the popular aartis (Om Jai Jagdish Hare, Ganesh, Shiva, Durga, Lakshmi, Krishna,
Saraswati) each marked "coming soon". Lyrics/audio arrive in a later phase — only the
section exists now, by design.

## Tabs (5)
| Tab | Icon | Screen |
|---|---|---|
| Home | `house.fill` | Dashboard |
| Rashifal | `sparkles` | Daily/weekly/monthly/yearly |
| Patro | `calendar` | BS calendar + events |
| Parivar | `person.3.fill` | Family + kundalis |
| Pandit | `bubble.left.and.bubble.right.fill` | Chatbot |
Settings reachable from Home header (gear).

## 1. Onboarding
- **WelcomeView:** full-bleed dawn hero (mandala watermark, diya flame, app name in serif +
  Devanagari), one saffron button: "Continue with account (demo)" → DummyAuth → ProfileSetup.
  Subtext notes real sign-in arrives with Supabase.
- **Birth flow (paged, one decision per screen — docs/01 craft rule 1):**
  step 1 name → step 2 gender (three tall cards) → step 3 DOB (wheel) → step 4 time
  (wheel + "time unknown" toggle → 06:00) → step 5 birthplace (curated city list) →
  **ceremony**: rotating mandala + "Drawing the kundali…" (~2s) → reveal screen with the
  computed rashi seal, moon rashi + nakshatra, and a blessing "शुभ होस् 🙏" → Home.
  Gold-diamond progress dots at top; back chevron; steps spring-slide from trailing edge.
  The same flow (prefixed with a relation step) is used for adding family members.

## 2. Home dashboard (the aarti thali)
Order: greeting header (time-aware, diya flame, user name, gear) → **Today's Tithi card**
(sindoor tika dot, BS date large + tithi + paksha + nakshatra + AD date small) → **Today's
personal rashifal card** (rashi seal + 2-line summary + score dots + "read more" → Rashifal tab)
→ **Dasha strip** (current mahadasha/antardasha chips) → **family quick row** (member avatars →
Parivar) → **upcoming events** (next 3 from Patro).

## 3. Rashifal
- Segmented: दैनिक / साप्ताहिक / मासिक / वार्षिक.
- Default = user's janma rashi; horizontal rashi-seal picker to read any other rashi
  (the "grandmother checks the whole family's signs" use case).
- Card: sunburst halo behind rashi seal, generated text, domain score dots
  (career/family/health/wealth/love as diya icons 1–5), lucky color/number/day, upaya line.

## 4. Patro (Bikram Sambat calendar)
- Month grid of BS month; each day cell: BS digit (Nepali numerals in NE), small tithi name
  under it, small AD day number at bottom; Saturdays sindoor-tinted (Nepal weekend), today
  ringed in saffron, event days show a marigold dot.
- Header: "Asar 2083" + AD range; chevrons to move months.
- **Today box** pinned above grid: tithi, paksha, nakshatra, vara.
- Tap a day → detail sheet: full panchanga for that day + its events + **"Add event"**
  (title, optional note, repeat-yearly toggle for birthdays). Events stored with BS date.

## 5. Parivar (family)
- List of members grouped around the user ("You" seal center in a header constellation
  drawing: user seal centered, member seals orbiting, gold connector lines = the auto family tree).
- Add member: relation picker (Son, Daughter, Husband, Wife, Father, Mother, Grandson,
  Granddaughter, Brother, Sister…) + same birth form. Relation drives labels everywhere:
  "Your son Aarav" / "तपाईंको छोरा आरव".
- MemberDetailView: North-Indian kundali chart (Path-drawn), lagna/rashi/nakshatra seals,
  mahadasha timeline, personality reading, guna table (gemstone, deity, mantra, lucky items).

## 6. Pandit-ji chat
- Chat UI: pandit messages on cream cards with gold edge; user messages saffron-tinted.
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
- Chat history persists via DataStore.

## 7. Settings
Language (EN/नेपाली), theme (Light "Prabhat" / Dark "Ratri" / System), profile edit,
sign-out (returns to Welcome; data kept), about card crediting the design language.

## 8. Bilinguality
`L10n` string tables; every user-facing string keyed. Nepali digits helper for Patro.
Language switch is instant (AppState.language republishes).
