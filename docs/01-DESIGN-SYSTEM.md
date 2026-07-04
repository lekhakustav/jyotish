# 01 — Design System: "प्रातः / Pratah" (Sacred Dawn)

This is the taste document. If the app is rebuilt from scratch, rebuild it from THIS file.
Every color, curve, and animation in the codebase must trace back to a rule here.

## 1. The Big Vibe

**Morning aarti.** The moment a brass diya is lit in a dim shrine room: deep warm darkness,
a single golden flame, vermillion powder, cream-colored dhaka fabric, marigold orange.
The app is that moment. It must feel:

- **Tasteful** — restrained luxury. Lots of warm negative space. One accent at a time.
- **Joyful** — marigold and saffron used *generously but purposefully*; celebratory moments
  (auspicious tithi, favorable rashifal) visibly glow.
- **Wonderful** — hand-crafted ornament: mandalas drawn in code, sunburst halos, paisley
  hairlines, Devanagari as decoration. Nothing that could come from a UI kit.

**The test:** screenshot any screen. If it could belong to a generic horoscope app, it fails.
If it looks like a page from a hand-illuminated panchanga, it passes.

### The craft rules (apply to every screen, no exceptions)
1. **One decision per screen.** Forms are never stacked — onboarding and data entry are
   paged flows: one focused question, one control, one continue button. Progress shown as
   small gold diamonds. Steps slide in from the trailing edge with a spring.
2. **Ceremony at the payoff.** Computing a kundali is a *moment*: rotating mandala +
   diya + "Drawing the kundali…", then the rashi seal reveals with a blessing. Never jump
   from a form straight to a dashboard.
3. **Minimalism first.** Prefer whitespace over borders, one accent per region, at most
   two card styles per screen. If an ornament competes with content, delete the ornament.
4. **Glyph honesty.** Rashi seals use Devanagari monograms (मे, वृ, मि…) — native to the
   audience and always renderable. Never rely on zodiac emoji/Unicode symbols.
5. **Navigation depth ≤ 2.** Tab → detail. Everything else is a sheet with a drag indicator.

## 2. Color — "Diya & Sindoor" palette

All colors are defined ONCE in `DesignSystem/Theme.swift` and consumed via semantic names.
Never use raw hex in views.

### Light mode — "Shubha Prabhat" (auspicious morning)
| Token          | Hex       | Use |
|----------------|-----------|-----|
| `bgCanvas`     | `#FAF3E3` | App background — aged handmade paper (Nepali lokta) |
| `bgElevated`   | `#FFFBF0` | Cards — cream dhaka fabric |
| `bgSunken`     | `#F1E6CE` | Inset wells, calendar grid |
| `inkPrimary`   | `#3B1F14` | Body text — burnt umber, never pure black |
| `inkSecondary` | `#7A5C48` | Captions, secondary |
| `saffron`      | `#E8801A` | THE brand accent. Primary buttons, active tab, highlights |
| `marigold`     | `#F2A93B` | Joyful secondary — badges, glows, tithi highlights |
| `sindoor`      | `#B9331F` | Vermillion — sacred emphasis, headers' accent line, alerts |
| `templeGold`   | `#B8860B` | Hairlines, ornament strokes, borders |
| `peepalGreen`  | `#4F7942` | Auspicious / favorable states |
| `lotusPink`    | `#D96C8A` | Rare tender accent (family, love) |
| `nightBlue`    | `#27334D` | Rahu/Shani, "challenging" states — never harsh red |

### Dark mode — "Ratri Aarti" (night lamp)
Backgrounds shift to warm near-black **browns**, never gray/blue-black:
`bgCanvas #171009`, `bgElevated #221709`→use `#231809`, `bgSunken #100B06`.
Ink becomes warm cream `#F4E7CE` / `#C4A886`. Saffron brightens to `#F49B3A`,
marigold to `#FFC15E`, sindoor to `#E05A41`, gold to `#D9A93F`, green `#7FA86B`,
pink `#E68BA4`, nightBlue `#8FA3C8`. The feeling: the same shrine, at night, lamp lit.

### Rules
- Exactly **one saturated accent zone per screen region**. Saffron leads; sindoor punctuates.
- Favorability is **green/gold/nightBlue**, never traffic-light red-green.
- Gradients allowed only as: (a) diya-glow radial (marigold→clear), (b) dawn linear
  (saffron→marigold at 15% opacity) on hero headers, (c) gold shimmer on ornaments.

## 3. Typography

- **Display / headers:** system **serif** (`.fontDesign(.serif)`) — evokes devotional print.
  Sizes: hero 34/bold, section 22/semibold.
- **Body:** SF Pro (default), 17pt minimum — audience is 40–80. Never below 13pt (captions).
- **Devanagari:** rendered by system fonts automatically. Every major screen header carries a
  small Devanagari echo above the Latin title (e.g. "राशिफल" over "Rashifal") in `templeGold`.
- **Numerals in Patro:** Nepali digits (०१२३४५६७८९) when language = Nepali.

## 4. Ornament & Graphics (all drawn in code — no image assets)

| Element | Spec |
|---|---|
| **Mandala** | `Canvas`-drawn: concentric petal rings (8/16/32 petals), 0.75pt `templeGold` strokes at 18–30% opacity. Used as watermark behind heroes, rotating 1°/sec on the kundali screen. |
| **Sunburst halo** | 24 tapered rays behind the rashi glyph on rashifal cards, marigold 25%. |
| **Diya flame** | Home greeting: small teardrop flame (2 blended ellipses, marigold core + saffron rim) with a gentle 1.6s scale-flicker animation. |
| **Paisley hairline** | Section dividers: a 1pt gold line interrupted by a small diamond ◆ at center. Component: `OrnamentDivider`. |
| **Rashi glyphs** | The 12 zodiac Unicode glyphs (♈–♓) set in serif inside a gold-ringed circular seal with radial gradient — treated like a wax seal / temple token. |
| **Planet tokens** | Circular chips with the planet's traditional color: Su gold, Mo silver-cream, Ma sindoor, Me green, Ju saffron, Ve lotus pink, Sa nightBlue, Ra smoky brown, Ke smoky gray. |
| **North-Indian kundali chart** | The classic diamond chart drawn with `Path`: outer square + two diagonals + midpoint diamond, gold strokes on `bgElevated`, house numbers in `inkSecondary`, planet abbreviations placed per house. |
| **Corner tika** | Cards of highest importance (today's rashifal, today's tithi) get a small sindoor dot ● at top-center — like a tika on a forehead. |

## 5. Shape, depth, layout

- Corner radius: **20** cards, **14** inner elements, **28** hero panels. Continuous corners.
- Borders: 1pt `templeGold` at 25% opacity on every card — the "gilded edge". Shadows are
  warm (`saffron` 8%, radius 14, y 6), never gray.
- Spacing scale: 4/8/12/16/24/32. Screen gutter 20.
- Tap targets ≥ 48pt. Primary buttons: 56pt height, saffron fill, cream serif label.

## 6. Motion — "reverent, never busy"

- Standard transition: `.spring(response: 0.45, dampingFraction: 0.85)`.
- Hero numbers/glyphs fade-rise in (opacity + 8pt y-offset) with 0.05s stagger.
- Diya flame flickers forever, softly. Mandala rotates imperceptibly. Nothing else loops.
- Tab switching: crossfade, no slide. Respect Reduce Motion.

## 7. Voice

- The app speaks as **Pandit-ji**: warm, respectful, uses "तपाईं" (never "तिमी"), sprinkles
  "🙏", blessings ("शुभ होस्"), and addresses relatives as "your son / तपाईंको छोरा".
- Greetings follow the clock: "शुभ प्रभात / Shubha Prabhat" before noon, "नमस्ते" afternoon,
  "शुभ सन्ध्या" evening.
- Never doom-monger. Challenging periods are framed as "a time for patience and remedy",
  always with an upaya (remedy).

## 8. Iconography

SF Symbols only, `.light` weight where possible, tinted `inkSecondary` (inactive) /
`saffron` (active). Tabs: Home `house.fill`… see 04-FEATURES.md §Tabs.

## 9. Accessibility

- Both themes pass WCAG AA for body text.
- Dynamic Type supported up to XXL on all reading surfaces.
- Every ornament is `accessibilityHidden(true)`; every control has a label in both languages.
