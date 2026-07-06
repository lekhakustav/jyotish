# 01 — Design System: "प्रातः / Pratah" (Sacred Dawn)

This is the taste document. If the app is rebuilt from scratch, rebuild it from THIS file.
Every color, curve, and animation in the codebase must trace back to a rule here.

## 1. The Big Vibe

**Sacred dawn.** The moment a temple courtyard wakes: warm darkness lifting, vermillion
powder, cream-colored dhaka fabric, marigold orange. The app is that moment. It must feel:

- **Tasteful** — restrained luxury. Lots of warm negative space. One accent at a time.
- **Joyful** — marigold and saffron used *generously but purposefully*; celebratory moments
  (auspicious tithi, favorable rashifal) visibly glow.
- **Wonderful** — hand-crafted ornament: mandalas drawn in code, sunburst halos, paisley
  hairlines, Devanagari as decoration. Nothing that could come from a UI kit.

**The test:** screenshot any screen. If it could belong to a generic horoscope app, it fails.
If it looks like a page from a hand-illuminated panchanga, it passes.

### v3 — EXTREME MINIMALISM (current law, supersedes conflicting rules below)
Containers are banned unless the content structurally demands one (calendar grid,
kundali chart, text input, user chat tint). Everything else is **flat typography on
the canvas**: hierarchy comes from size, weight, serif/sans contrast, color and
whitespace (40pt between sections). The only divider is `Hairline` (1pt gold @18%).
No card borders, no shadows, no tika dots, no ornament dividers, no section
descriptions. Ornaments (mandala, rashi marks) survive only as *content*, never as
decoration-around-content. Every list is bare rows separated by hairlines.

### v4 — PLAIN CANVAS CLARIFICATION (current law)
The background is a plain warm canvas, not an illustrated or atmospheric scene. Do not
place screen-scale gradients, mandala watermarks, texture layers, or ornamental washes
behind normal content. Keep `MandalaView` for the kundali computation ceremony only.
Every container must pass this test before it is added:

- **Keep:** text fields, segmented controls, calendar day targets, the kundali chart,
  the user chat bubble, and primary buttons.
- **Delete:** decorative cards, about/credit blocks, placeholder "coming soon" rows,
  background ornaments, card wrappers around prose, and extra explanatory text.
- **Replace:** repeated card rows become bare rows with `Hairline`; section descriptions
  become stronger headings or disappear.

### Apple basics (non-negotiable)
- **Dynamic Type everywhere** via `scaledFont` (never `.font(.system(size:))` for text;
  exception: calendar grid cells, fixed ≥11pt).
- **Contrast:** ≥4.5:1 body, ≥3:1 large text. Saffron fills carry dark-umber labels.
- **Touch targets ≥44pt.** Haptics (`Haptics.tap/success`) on every selection and payoff.
- **Explicit dismiss** (`SheetCloseButton`) on every sheet; `statusBarFade` on every
  scrolling root; Reduce Motion respected in all custom animation.
- App icon + launch-screen color from the palette (no white flash).

### The craft rules (apply to every screen, no exceptions)
1. **One decision per screen.** Forms are never stacked — onboarding and data entry are
   paged flows: one focused question, one control, one continue button. Progress shown as
   small gold diamonds. Steps slide in from the trailing edge with a spring.
2. **Ceremony at the payoff.** Computing a kundali is a *moment*: rotating mandala +
   quiet rashi mark + "Drawing the kundali…", then the computed rashi reveals with a blessing. Never jump
   from a form straight to a dashboard.
3. **Minimalism first.** Prefer whitespace over borders, one accent per region, at most
   two card styles per screen. If an ornament competes with content, delete the ornament.
4. **Glyph honesty.** Rashi marks are path-drawn vector symbols. Never rely on zodiac
   emoji/Unicode/SF symbols that can render as tofu or disappear.
5. **Navigation depth ≤ 2.** Tab → detail. Everything else is a sheet with a drag indicator.

## 2. Color — "Sindoor & Gold" palette

All colors are defined ONCE in `DesignSystem/Theme.swift` and consumed via semantic names.
Never use raw hex in views.

### Light mode — "Shubha Prabhat" (auspicious morning)
| Token          | Hex       | Use |
|----------------|-----------|-----|
| `bgCanvas`     | `#FCF7ED` | App background — plain warm paper |
| `bgElevated`   | `#FFFDF7` | Structural button/chip/chart fill only |
| `bgSunken`     | `#F4ECDD` | Text fields, segmented controls, calendar grid |
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
`bgCanvas #17120C`, `bgElevated #1F1710`, `bgSunken #100B06`.
Ink becomes warm cream `#F4E7CE` / `#C4A886`. Saffron brightens to `#F49B3A`,
marigold to `#FFC15E`, sindoor to `#E05A41`, gold to `#D9A93F`, green `#7FA86B`,
pink `#E68BA4`, nightBlue `#8FA3C8`. The feeling: the same shrine, at night, lamp lit.

### Rules
- Exactly **one saturated accent zone per screen region**. Saffron leads; sindoor punctuates.
- Favorability is **green/gold/nightBlue**, never traffic-light red-green.
- Gradients are not used as screen backgrounds. Keep the app canvas plain.

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
| **Mandala** | `Canvas`-drawn: concentric petal rings (8/16/32 petals), 0.75pt `templeGold` strokes at 18–30% opacity. Reserved for the kundali computation ceremony. |
| **Rashi marks** | The 12 signs are unframed, path-drawn vector marks. Do not put text monograms inside circles for live rashi UI. |
| **Planet tokens** | Circular chips with the planet's traditional color: Su gold, Mo silver-cream, Ma sindoor, Me green, Ju saffron, Ve lotus pink, Sa nightBlue, Ra smoky brown, Ke smoky gray. |
| **North-Indian kundali chart** | The classic diamond chart drawn with `Path`: outer square + two diagonals + midpoint diamond, gold strokes on `bgElevated`, house numbers in `inkSecondary`, planet abbreviations placed per house. |

## 5. Shape, depth, layout

- Corner radius is reserved for structural controls: **16** primary buttons, **14** choice
  controls, **12** text fields/calendar cells. No decorative card radius.
- Borders and shadows are banned on ordinary content. Use `Hairline` for row separation.
- Spacing scale: 4/8/12/16/24/32. Screen gutter 20.
- Tap targets ≥ 48pt. Primary buttons: 56pt height, saffron fill, dark-umber serif label.

## 6. Motion — "reverent, never busy"

- Standard transition: `.spring(response: 0.45, dampingFraction: 0.85)`.
- Hero numbers/glyphs fade-rise in (opacity + 8pt y-offset) with 0.05s stagger.
- Mandala rotates imperceptibly during the kundali computation ceremony. Nothing else loops.
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
