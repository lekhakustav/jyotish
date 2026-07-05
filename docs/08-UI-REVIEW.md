# 08 - UI Review: Plain Canvas Pass

Date: 2026-07-05

This pass audits every mounted SwiftUI page against `docs/01-DESIGN-SYSTEM.md` v4:
plain canvas, no decorative containers, no placeholder UI, and structural fills only
where the user needs a target, input, or data grid.

## Container Rubric

Keep a container only when it has a job:

- **Input:** text fields, toggles, segmented controls, and primary buttons.
- **Selection:** selected row tint, calendar day target, user chat bubble.
- **Data structure:** Bikram Sambat calendar grid and North-Indian kundali chart.

Delete a container when it only makes content look "designed":

- Decorative cards around prose or rows.
- Background mandalas, gradient washes, ornament dividers, and tika dots.
- About/credit blocks and "coming soon" placeholders.
- Repeated soft fills where a `Hairline` or whitespace is enough.

## Page Review

| Page | Containers | Text | Placement |
| --- | --- | --- | --- |
| Welcome | Kept only the primary button and language control. Removed background gradient, mandala watermark, ornament divider, and sign-in explainer copy. | App name, Latin echo, tagline, and CTA are enough. | Centered identity stack and bottom actions remain; plainer canvas reduces visual competition. |
| Birth flow | Kept text field, date wheels, toggle, selected choice tint, and primary CTA. Removed normal-step mandala background and unselected choice cards. | Each step remains one direct question; subtitles kept only where they clarify birth date/time. | One-question paging remains; hairlines separate gender rows without making cards. |
| Kundali ceremony | Kept rotating mandala because it is payoff content, not decoration around a form. | "Drawing the kundali..." and reveal text remain. | Seal reveal remains centered for ceremony. |
| Home | Removed the Popular Aarti placeholder doorway. Kept tithi, rashifal, family, and upcoming blocks. | Removed future-looking placeholder copy by deleting the dead page. | Flat vertical rhythm with 40pt section spacing remains. |
| Rashifal | Kept segmented period control, rashi seals, and score row. | Generated reading, lucky items, and upaya remain; no descriptive section copy added. | Seal leads the reading; upaya is separated by the single allowed `Hairline`. |
| Patro | Kept month grid cell backgrounds for tappable calendar structure. Day sheet panchanga/events became plain rows. | Panchanga labels and event fields remain; no card labels or extra description. | Header -> today -> month controls -> grid stays scan-friendly. |
| Day detail sheet | Kept text fields, toggle, and add button. Removed panchanga/event cards and text-field borders. | Field placeholders remain functional. | Panchanga rows use hairlines; add-event form stays below the day's facts. |
| Family | Kept rashi seals and connector lines only when relatives exist. Removed mandala behind the constellation. | Member labels remain short and relation-driven. | Single-member state leads with the list; family tree renders only when it has relationships to show. |
| Member detail | Kept rashi seal, kundali chart, triad, timeline, reading, and guna rows. Removed decorative mandalas from gate and hero. | All text is chart-derived or actionable; no ornament captions. | Identity first, then chart facts, then longer reading/tables. |
| Chat | Kept user bubble, prompt chips, text input, mic, send, and speaker controls. Removed empty-state mandala. | Pandit replies remain bare prose; chips are direct questions. | Messages scroll above structural input controls. |
| Settings | Kept language/theme/profile/sign-out actions. Removed about/credit block and segmented border. | Every remaining label maps to an action. | Sheet stays dense and plain with top-right close affordance. |

## Implementation Notes

- `SacredCard` is intentionally a no-op for backward compatibility. New code should not
  use it to create visual surfaces.
- `bgCanvas` is the only screen background. `bgElevated` and `bgSunken` are for structural
  controls only.
- `MandalaView` is reserved for the kundali ceremony. Do not use it as a page watermark.
- Add new UI only after judging container, text, and placement with the table above.
