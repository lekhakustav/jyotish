# Jyotish — Vision Document

> **The one-line vibe:** *Morning aarti in your pocket.* Brass diya light, marigold garlands,
> vermillion sindoor, the hush of a temple courtyard at dawn — rendered as a modern iOS app
> that feels like it was made by a master craftsman, not a template.

## What we are building

A **SwiftUI iOS app** (local-first, simulator-ready, no external services required) that acts as a
family's personal **pandit**: it computes real Vedic (Hindu) astrology from birth data, speaks
warmly in **English and Nepali**, and organizes the spiritual rhythm of a Nepali household —
rashifal, kundali, the Bikram Sambat patro, and a conversational Pandit-ji chatbot.

## Who it is for

Parents and grandparents in Nepal, **age 40–80**. Design consequences:

- **Large type, generous tap targets** (min 48pt), high contrast in both themes.
- **Warm, respectful voice.** The app addresses the user like a family pandit would —
  never clinical, never "techy". Family members are always "your son", "your daughter" (तपाईंको छोरा).
- **Nothing hidden behind gestures.** Every action has a visible, labeled control.
- **Nepali is a first-class language**, not a translation afterthought. Devanagari is used
  decoratively even in English mode (headers carry a Devanagari echo line).

## Product pillars

1. **Real computation, not horoscope-column fluff.** A genuine Vedic engine: sidereal planetary
   positions (Lahiri ayanamsa), lagna, rashi, nakshatra, vimshottari dasha, panchanga
   (tithi/yoga/karana), gochar (transits). Rashifal text is *generated from these computations*.
2. **The family is the unit, not the individual.** One account holds many kundalis. The app
   draws the family constellation automatically and speaks about members relationally.
3. **The patro is the heartbeat.** Bikram Sambat calendar with tithis on every day cell,
   today's tithi on the home screen, and personal events saved in Nepali dates.
4. **Pandit-ji, the chatbot,** can reach every tool himself: kundali, dasha, gochar, vastu,
   city matching, colors, gemstones — and answers like a wise, warm human.
5. **Award-grade craft.** Every pixel obeys the design system (see 01-DESIGN-SYSTEM.md).
   If a detail doesn't sing "tasteful, joyful, wonderful", it doesn't ship.

## Non-goals (v1)

- No real network calls. Supabase is **stubbed behind protocols** (see 02-ARCHITECTURE.md);
  a dummy login button stands in for auth. Everything persists locally as JSON.
- No push notifications, no widgets, no payments.

## Definition of done (v1)

- Builds clean with `xcodegen && xcodebuild` and runs on the iOS Simulator (iPhone 17 Pro).
- Full flow works: welcome → dummy login → birth profile → home dashboard → all 5 tabs.
- Language toggle (EN/NE) and dark/light mode work everywhere, instantly.
- Kundali math sanity-checked (sun sign, moon nakshatra, tithi for known dates).
