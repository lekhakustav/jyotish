# App proof capture shot list

## Capture objective

The app footage is the proof layer. Record the exact shipped action named by the concept; do not
substitute a generic Home scroll. Keep one platform per creative and preserve enough pre/post-roll
for the editor to show a real tap and result without time compression that changes meaning.

## Approved synthetic household

Use only the QA fixture already built into the repository via `-demoSeed`:

| Role | Synthetic name | Synthetic birth input | Place |
| --- | --- | --- | --- |
| Self | Sita Sharma | 1962-03-15 07:30, known time | Kathmandu |
| Son | Aarav | 1990-06-15 08:30, known time | Kathmandu |
| Daughter | Priya | 1993-11-02 14:10, known time | Pokhara |

The fixture also creates synthetic events for Aarav's birthday and Satyanarayan Puja relative to
the capture date. Never replace these with a real person's name, birth data, event, QR, or chat.
Record the fixture name as `demoSeed-v1` in capture metadata. For the onboarding/reveal shots,
start from a clean install without `-demoSeed` and manually enter Sita's synthetic values.

## Before recording

1. Record Git SHA, platform, app version/build, OS, device model, locale, time zone, capture date,
   fixture version, network mode, and operator in the media manifest; do not burn this slate into
   the consumer clip.
2. Use a clean simulator/device profile with no personal accounts, notifications, keyboard
   history, contacts, photos, clipboard, or real QR payloads. Enable Do Not Disturb.
3. For iOS source-of-truth captures, build the documented `Jyotish` scheme and use `-demoSeed`
   plus `-lang ne` or `-lang en`. Use separate clean-install state for onboarding.
4. Record native portrait resolution at 60 fps when available, with taps visible only if the
   recorder adds a neutral touch indicator outside the app. Do not add fake taps in post.
5. Let every target screen settle for two seconds before and after the action. Do not speed up a
   calculation, streaming answer, or result in a way that suggests lower latency.
6. Use deterministic local/prepared reports for reproducibility unless the concept specifically
   needs the remote agent's phrasing. Never edit model prose to look like an app response.
7. Voice recognition and camera QR operation require final proof on physical hardware. Simulator
   paste flows are acceptable for internal assembly tests but not the final capability proof.
8. Upload raw source to Drive `source_app_captures`, assign a unique `media_id`, checksum it, and
   keep binaries out of Git.

## Shot catalogue

| Shot key | Exact real-app action | Minimum raw clip | Proof that must remain visible | Guardrail / concept use |
| --- | --- | ---: | --- | --- |
| `SH-FAM-01` | Launch with `-demoSeed`; open Parivar and pause on Sita, Aarav, Priya with relationship labels. | 6s | More than one saved profile and the relationship labels. | Crop away birth details. `fam001` |
| `SH-FAM-02` | Tap Aarav from Parivar and pause on member detail; return or invoke the member-specific action used by the current build. | 8s | The selected person is visibly Aarav / son and the action belongs to that profile. | Do not show DOB/time/place. `fam001` |
| `SH-FAM-03` | From the member/social feature path, open Jyotish Baje with a preloaded question about Aarav; capture the complete structured answer/evidence. | 18s | Member-aware wording plus real evidence or uncertainty. | Use prepared/local answer if needed; no invented outcome. `fam001` |
| `SH-LANG-01` | In Settings or Welcome, switch English → नेपाली in one uninterrupted capture and pause. | 8s | Several visible labels change immediately. | Reject any mixed-language leak in hero area. `nep001` |
| `SH-LANG-02` | In Nepali mode, move Home → Patro or Parivar and back at natural speed. | 12s | Authentic Devanagari across two shipped surfaces. | Fluent review required; do not claim Hindi. `nep001` |
| `SH-PAT-01` | From Home, tap the BS date/tithi block to open Patro. | 8s | Real Home date context and real Patro destination. | Do not imply a notification. `pat001` |
| `SH-PAT-02` | Browse one Patro month; tap a day; hold Tithi/Nakshatra/details. | 12s | BS grid, tithi, selected-day detail. | Capture date/location in metadata. `pat001` |
| `SH-PAT-03` | Add a synthetic Patro event, save it, return to show the event dot/row. | 14s | Real write confirmation and saved result. | Synthetic title only; no reminder claim. `pat001` |
| `SH-KUN-01` | Parivar → Sita or Aarav → member detail; hold the North-Indian Kundali chart and calculated labels. | 10s | Chart plus Lagna/Rashi/Nakshatra context. | Never overlay altered placements. `kun001` |
| `SH-KUN-02` | Continue the same member detail to the Dasha timeline/related calculated evidence. | 12s | Continuity from the same synthetic member and visible Dasha evidence. | Same build/fixture as `SH-KUN-01`. `kun001` |
| `SH-DSH-01` | Home feature grid → Dashas & Life Phase → explanation sheet → continue. | 10s | Real shipped entry and explanation. | No future-alert or notification imagery. `dsh001` |
| `SH-DSH-02` | Capture the prepared Dasha report through current Mahadasha, Antardasha, next Mahadasha date, Dos/Don'ts, and uncertainty. | 22s | Exact dates and uncertainty from the app. | Do not retype or recalculate dates in post. `dsh001` |
| `SH-MUH-01` | Home feature grid → Muhurat Finder → choose a real purpose such as home entry. | 12s | Purpose selection and real transition to report/question. | The purpose must match the generated scene. `muh001` |
| `SH-MUH-02` | Capture complete Muhurat answer with proposed window, Panchang evidence, reasons, and uncertainty. | 20s | Time and its supporting evidence together. | Never isolate a time as guaranteed. `muh001` |
| `SH-MAT-01` | Home → Kundli Matching → choose the synthetic second profile. | 12s | Two-person selection with real relationship context. | Hide DOB/time/place. `mat001` |
| `SH-MAT-02` | Capture the traditional matching report, factor explanations, exceptions/uncertainty, and practical conversation context. | 22s | Evidence beyond a total score. | No caste, fertility, health, or relationship verdict. `mat001` |
| `SH-VOC-01` | On physical device, open Jyotish Baje, tap mic, dictate the approved synthetic question, wait for transcript. | 12s | Real mic state and recognized editable transcript. | Clean device; permission/service behavior recorded. `voc001` |
| `SH-VOC-02` | Edit one transcript word with the keyboard, then send; hold start of real answer. | 14s | Edit-before-send and sent question. | No real keyboard suggestions or clipboard data. `voc001` |
| `SH-QR-01` | Open My QR and its sensitive-data explanation using the synthetic Sita profile. | 10s | Real trust explanation and feature entry. | Mask the entire QR region in every exported frame. `dia001` |
| `SH-QR-02` | On a second clean physical device, scan the synthetic test QR or use the paste fallback; choose receiver relationship. | 16s | Scan/import path plus receiver-selected relationship. | Raw QR stays restricted; no encoded text in final. `dia001` |
| `SH-QR-03` | Complete import and show the synthetic profile in Parivar; test duplicate rejection separately for QA. | 10s | Saved result without automatic-sync implication. | Do not claim account transfer or syncing. `dia001` |
| `SH-REL-01` | From Home Relationships or a social feature, open the person chooser and select Aarav. | 10s | Selected son relationship and correct destination. | Complete birth profile required. `rel001` |
| `SH-REL-02` | Capture relationship-aware guidance for Aarav through evidence, one strength/tension, and a Do/Don't. | 18s | Non-romantic relationship framing and selected-member context. | No exam, visa, health, danger, or guaranteed outcome. `rel001` |
| `SH-PAN-01` | Home → Today's Panchang/feature sheet → continue to report or Patro day detail. | 10s | Real current-day entry and selected location. | Capture date/place in metadata. `pan001` |
| `SH-PAN-02` | Hold/scroll Tithi, Nakshatra, Yoga, Karana, sunrise/sunset, Rahu Kaal, Gulika, Yamaganda, and Abhijit. | 18s | Real calculated rows in correct order. | If moonrise/set appears, show approximate caveat. `pan001` |
| `SH-REV-01` | Clean install without seed; use demo login and enter Sita's synthetic name, gender, DOB, known time, and Kathmandu through the paged flow. | 30s | One-decision-per-page real onboarding. | Never use or paste a real person's data. `rev001` |
| `SH-REV-02` | Continue and record the full real rotating-mandala computation ceremony at natural speed. | 8s | Genuine in-app computation state. | No speed ramp or generated ornament. `rev001` |
| `SH-REV-03` | Record Rashi/Nakshatra blessing reveal and the first computed detail destination. | 12s | Real calculated reveal for the same synthetic input. | Keep birth-time precision disclosure in final. `rev001` |

## Capture acceptance checks

- The tap, transition, and claimed result are all present in one continuous raw clip.
- The visible data belongs only to `demoSeed-v1` and matches the recorded Git SHA.
- No personal status-bar notification, keyboard suggestion, clipboard, account token, email,
  analytics identifier, QR payload, or unrelated chat appears—even for one frame.
- The locale is internally consistent and all visible Nepali is fluent-review ready.
- The recording has no dropped frames, touch mismatch, loading error, debug overlay, cursor,
  simulator chrome, or unintended audio.
- A second reviewer can reproduce the path from this shot list without verbal instructions.
