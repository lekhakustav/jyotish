# 18 — Relationships, Feature Hub, and Future-Date Language

Last updated: 2026-07-13

This document is the product and implementation contract for the July 2026 Jyotish Baje
engagement overhaul. It separates what is implemented now from the future-event notification
system that was intentionally requested as a report only.

## Shipped in this change

- Parivar supports family, friend, colleague, mentor, boyfriend, girlfriend, partner,
  fiance, and fiancee relationships.
- Parivar can display the current user's QR code and scan another Jyotish Baje QR code.
- Home shows a `Relationships` reading only when at least one other saved person has a
  complete birth profile. It renders nothing related to Relationships for a solo profile.
- Every daily, weekly, monthly, and yearly Rashifal contains two Dos and two Don'ts.
- Patro day details include Tithi, Nakshatra, Yoga, Karana, sunrise, sunset, approximate
  moonrise/moonset, Rahu Kaal, Gulika Kaal, Yamaganda, Abhijit Muhurat, and observances.
- Home uses five feature icons plus More. More opens a full list with an icon, name, and
  short description for every feature.
- Panchang, Life Phase, Muhurat Finder, individual Muhurat purposes, Dosha Check,
  Sade Sati and Dhaiya, Personal Upaya, Kundli Matching, and Relationship Guidance all
  open a short feature sheet and then preload a specific Jyotish Baje question.
- Social tools require a second saved profile. With none present, their sheet offers
  `Add a person` and routes to Parivar. With profiles present, the user chooses one before
  opening chat.

## Home information architecture

The main grid deliberately limits itself to:

1. Today's Panchang
2. Dashas & Life Phase
3. Muhurat Finder
4. Dosha Check
5. Kundli Matching
6. More

`More` is a catalog, not another question shelf. This avoids the previous habit of placing
multiple long questions on Home. The generic `Ask Jyotish Baje anything` action remains
available below the grid.

Dashas is primary because it is both a frequent-return use case and a report the local
engine can substantiate. Personal Upaya remains available in More.

## Prepared feature report contract

Every feature launch owns a stable source key:

```text
feature:<feature-id>:<self-or-family-member-id>
```

Android consumes this key in `src/app-state.tsx`, runs `buildFeatureToolReport`, and sends
`requestedFeature`, `toolEvidence`, and `localFallbackReply` to the agent. The Dasha report
is fully deterministic and includes current Mahadasha and Antardasha boundaries, the next
Mahadasha date, six life-area interpretations, Dos, Don'ts, and uncertainty. If the remote
agent is unavailable, the same prepared report still appears in chat. If it is available,
the backend may improve warmth and clarity but must preserve every supplied date.

For tools that require planets absent from Android's compact chart, the prepared report
states the calculation boundary and asks the agent to calculate and disclose the missing
evidence. It never fabricates a Dosha, transit, Ashtakoota score, or Muhurat.

## Relationship interpretation contract

The implementation uses the Hindu Kundli matching vocabulary, while adjusting the output
to the actual relationship type.

For marriage or romantic matching, the detailed report may show the complete Ashtakoota
model and its traditional 36-point total:

| Koota | Maximum | Interpretation used by the app |
| --- | ---: | --- |
| Varna | 1 | Values and approach to responsibility; never presented as a caste verdict |
| Vashya | 2 | Influence, accommodation, and power balance |
| Tara | 3 | Nakshatra-based mutual support and rhythm |
| Yoni | 4 | Instinctive temperament and intimacy, only in an appropriate romantic context |
| Graha Maitri | 5 | Friendship of Moon-sign lords and mental rapport |
| Gana | 6 | Temperament and conflict style |
| Bhakoot | 7 | Moon-sign pattern, shared direction, and household priorities |
| Nadi | 8 | Traditional constitutional compatibility; never a medical or genetic result |

Mangal Dosha is reported separately. The app explains the chart evidence, balance between
both charts, exceptions, uncertainty, and practical conversation topics. A numerical score
is context, not a command to begin or end a relationship.

For parents, children, siblings, friends, colleagues, or mentors, the daily Relationships
reading emphasizes Moon-rashi rhythm, Nakshatra temperament, sign-lord rapport, current
transits, strengths, tensions, and one Do/Don't. It does not turn a non-romantic relationship
into a marriage verdict and does not expose sexual or reproductive framing.

Research references used for the model:

- Drik Panchang, Horoscope Match: https://www.drikpanchang.com/jyotisha/horoscope-match/horoscope-match.html
- Astroyogi, Kundli Matching and the eight Kootas: https://www.astroyogi.com/kundli/kundli-matching

These sources describe traditional practice. Jyotish Baje keeps deterministic calculations
in the local engine and asks the AI agent to interpret supplied evidence rather than invent
planet positions or scores.

## Parivar QR mechanism and privacy

The QR payload is a versioned, URL-safe base64 JSON document using this route:

```text
jyotishbaje://family/add?payload=<encoded-profile>
```

Version 1 contains the person's name, gender, and complete birth data. The receiving user
chooses how they know the person before the profile is stored. Import is idempotent by
normalized name plus civil date of birth, preventing accidental duplicates.

Birth data is sensitive. The share sheet explicitly says what the code contains and tells
the user to show it only to someone they trust. The scanner has a paste-code fallback so the
flow remains testable in a simulator without a camera. A future server-backed QR must use a
short-lived signed token rather than placing account identifiers or authorization secrets in
the QR.

## Panchang calculation boundary

Tithi, Nakshatra, Yoga, and Karana continue to come from the deterministic astrology engine.
Sunrise and sunset are location-based solar calculations. Rahu Kaal, Gulika Kaal, Yamaganda,
and Abhijit are derived from that local daylight span. The current Moon rise/set values use
an approximation and are labeled as such in the interface; they must not be silently upgraded
to authoritative values until a tested topocentric lunar-rise calculation is available.

## Dosha and Upaya safety contract

Dosha Check covers Mangal Dosha, Kaal Sarp indicators, Pitra indicators, Shani Sade Sati,
Dhaiya, and Guru Chandal Yoga. Each result includes evidence, severity, effects, exceptions,
and remedies. The words `indicator` and `traditional interpretation` are intentional: the
agent must not use fear, certainty, or paid-remedy pressure.

Upaya may suggest mantra, temple or home practice, daan, charity, cautious fasting, colors,
foods, yantra, and gemstone guidance. It prioritizes free and low-cost practices. It must
warn users not to fast when medically unsafe, never delay care or surgery for Muhurat, and
never claim that a gemstone or ritual guarantees an outcome.

## Future Kundli dates — report only, not implemented

No automatic Dasha/transit event generation, notification scheduling, or date-alert UI was
added in this change. The following is the approved naming and copy direction for that future
system.

### User-facing event names

| Plain name | Detail label | Example title |
| --- | --- | --- |
| Your Current Chapter | Mahadasha + Antardasha | Your current chapter is changing |
| A Major Chapter Begins | Mahadasha transition | A bigger life chapter begins in September |
| A Turning Point | Antardasha transition | A turning point is 30 days away |
| A Growth Window | Jupiter period or transit | A growth window opens next week |
| A Responsibility Phase | Saturn period, Sade Sati, or Dhaiya | Saturn asks for patience this month |
| Relationship Window | Supported 7th-house/Venus/Jupiter period | A relationship window is approaching |
| Career Momentum | Supported 10th-house/Dasha period | Career momentum builds from Thursday |
| Money & Stability Window | Supported 2nd/11th-house period | A money-planning window opens soon |
| Learning Window | Supported 5th/9th-house period | A strong learning phase begins |
| Home & Family Shift | Supported 4th-house period | Home and family take focus next month |
| Health & Routine Check-in | Supported 6th/8th/12th-house period | Simplify your routine this week |
| A Caution Window | Multiple challenging indicators | Move gently through the next three days |

The plain name is always primary. Sanskrit or technical detail appears below it, for example:
`Jupiter Mahadasha begins · 18 September 2027`.

### Example notification copy

- `A major chapter begins in 90 days` — `Jupiter Mahadasha starts 18 Sep 2027. Preview what it may emphasize in career, relationships, money, learning, children, and health.`
- `Your current chapter is changing` — `The Jupiter–Saturn Antardasha begins next month. See the responsibilities and opportunities Baje would prepare for.`
- `A relationship window opens in 12 days` — `Your Dasha and current transit both support clearer conversations. See what to do and what not to rush.`
- `Saturn asks for patience this week` — `A responsibility phase is active. Protect time, avoid fear, and review the practical guidance.`
- `Career momentum builds from Thursday` — `A supportive window begins. Prepare the conversation or application before it opens.`
- `Move gently through the next three days` — `Several indicators ask for extra margin. This is guidance, not a prediction of harm.`

### Delivery rules for the future implementation

- Compute from deterministic Dasha and transit evidence; the language model explains only.
- Default lead times: 90 days for Mahadasha, 30 and 7 days for Antardasha, 7 and 1 day for
  shorter windows. Never send all lead times for low-confidence signals.
- One event family may send at most one preview and one start notification unless the user
  explicitly follows it.
- Combine overlapping indicators into one named window rather than flooding the user with
  planet jargon.
- Every notification opens a dated detail page with evidence, confidence, affected life
  areas, Dos/Don'ts, and an `Ask Jyotish Baje` question.
- Users can disable categories, quiet hours are mandatory, and sensitive health/fertility/
  death wording is prohibited.
- Store the evidence version, calculation version, timezone, generated-at time, and stable
  deduplication key with every proposed event.

### Future AI question shown on each date

```text
Explain this upcoming phase from my Kundli. Show the exact Dasha and transit evidence,
the dates, likely themes for career, relationships, money, education, children and health,
what to do, what not to do, and what remains uncertain. Do not use fear or certainty.
```

## Maintainer verification

When changing this feature family:

1. Verify Home has no Relationships section with only the self profile.
2. Add a friend with complete birth data and verify Relationships appears.
3. Open both social features with and without another profile.
4. Round-trip a Parivar share code and confirm duplicate handling.
5. Check all four Rashifal horizons for Dos and Don'ts.
6. Check Panchang timing order for at least Kathmandu and one non-Nepal location.
7. Confirm surgery copy never tells a user to delay medically necessary care.
8. Open Dashas & Life Phase and verify the report contains Mahadasha, Antardasha, next
   phase, six life areas, Dos and Don'ts.
9. On Android, dictate in both language settings and verify the transcript remains editable.
10. Run `PanditToolsTests`, TypeScript checking, Android export/native builds, and an iOS simulator build.
