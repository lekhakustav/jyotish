# 03 — The Vedic Astrology Engine (real math, no fluff)

All astronomy lives in `Core/Astro/`. Pure functions, no UI. Accuracy targets:
Sun ±0.01°, Moon ±0.1°, planets ±0.5° — far finer than the 13°20′ nakshatra grid and
30° rashi grid we actually need, and sufficient for correct tithi/dasha in practice.

## 1. Time base
- Input: civil date+time + place (lat, lon, UTC offset; Nepal = +5:45).
- Julian Day `JD = civil → UT → JD`, then `T = (JD − 2451545.0) / 36525` (Julian centuries J2000).

## 2. Tropical positions (geocentric ecliptic longitude)
- **Sun:** mean longitude L + equation of center from mean anomaly M
  (`1.9146·sinM + 0.0200·sin2M + 0.0003·sin3M`, coefficients time-damped).
- **Moon:** truncated ELP — mean longitude L′ plus the ~14 largest periodic terms
  (evection 1.274°, variation 0.658°, annual equation 0.186°, …) using fundamental
  arguments D, M, M′, F. Accuracy ≈ 0.05–0.1°.
- **Mercury…Saturn:** heliocentric positions from mean Keplerian elements (a, e, i, Ω, ϖ, L
  with linear rates, J2000, standard JPL approximation table), Kepler's equation solved by
  Newton iteration, converted to geocentric ecliptic longitude via Earth's position.
- **Rahu:** mean ascending lunar node `Ω = 125.0445479 − 1934.1362891·T` (retrograde).
  **Ketu** = Rahu + 180°.

## 3. Sidereal conversion — Lahiri (Chitrapaksha) ayanamsa
`ayanamsa(T) ≈ 23.85236° + 1.3969°·T (50.29″/yr)`, subtract from tropical longitude,
normalize to [0, 360).

## 4. Derived chart
- **Rashi** = floor(λ/30) — 12 signs, Mesh…Meen (Nepali names first-class).
- **Nakshatra** = floor(λ/13°20′) — 27, with pada = quarter.
- **Lagna (ascendant):** GMST → LST(lon) → RAMC; ascendant
  `λasc = atan2(cos RAMC, −(sin RAMC·cos ε + tan φ·sin ε))`, then sidereal.
  Whole-sign houses from lagna (North-Indian chart convention).
- **Panchanga of any day** (computed at local sunrise ≈ 05:45 fallback):
  - **Tithi** = floor(((λmoon − λsun) mod 360) / 12) + 1 → 30 tithis, named, Shukla/Krishna paksha.
  - **Nakshatra of Moon**, **Yoga** = (λsun+λmoon)/13°20′ (27), **Karana** = half-tithi (11 names),
    **Vara** = weekday.
- **Vimshottari dasha:** Moon's nakshatra lord starts the 120-yr cycle
  (Ketu7 Venus20 Sun6 Moon10 Mars7 Rahu18 Jupiter16 Saturn19 Mercury17); elapsed fraction of
  the natal nakshatra sets the balance; produce mahadasha timeline + current antardasha.

## 5. Interpretation layer (`Interpreter.swift`)
Rule-based, written in a pandit's voice, EN + NE:
- Rashi personality profiles (12), nakshatra traits (27), lagna overlays (12).
- Planet-in-house significations (9 planets × 12 houses — concise sutra per combo).
- **Chandra bala** (transit Moon house from natal moon rashi: 1,3,6,7,10,11 favorable).
- **Sadhe Sati** detector (transit Saturn within ±1 sign of natal moon rashi, 3 phases).
- Guna essentials per rashi: element, ruling planet, gemstone, lucky color/number/day, deity, mantra.

## 6. Rashifal generation (`RashifalEngine.swift`) — computed, not canned
Daily/weekly/monthly/yearly per rashi, seeded deterministically by (rashi, period, date):
1. Compute real gochar for the period: Moon transit house (daily), Sun sign, Jupiter house,
   Saturn house (incl. Sadhe Sati flag) relative to the target rashi.
2. Score domains (career, family, health, wealth, love) from transit weights.
3. Render sentences from bilingual phrase banks selected by score bucket + seeded RNG,
   always ending with a concrete upaya (remedy) and lucky color/number from the rashi tables.
Same date + rashi ⇒ identical text (stable, feels authoritative). Personal rashifal uses the
member's moon rashi (janma rashi), which is the Nepali convention.

## 7. Bikram Sambat (`Core/Patro/BikramSambat.swift`)
Table-driven (BS is not algorithmic): month-length table for BS 2000–2099 plus anchor
2000-01-01 BS = 1943-04-14 AD. Conversion both directions by day-count walk from the anchor.
Month names Baisakh…Chait; Nepali digits when language = NE. Sanity anchors to verify after
any table edit: 2081-01-01 BS = 2024-04-13 AD, 2082-01-01 = 2025-04-14, 2083-03-20 ≈ 2026-07-04.

## 8. Validation targets (run mentally / in tests after changes)
- 2000-01-01 12:00 UT: Sun tropical ≈ 280.0°, Moon ≈ 223.3°.
- A person born 1990-06-15 Kathmandu: Sun sidereal Taurus (Vrish), verify tithi continuity.
- Purnima check: 2026-07-29 is Guru Purnima (Shukla 15) — engine's tithi that day must be 15.
