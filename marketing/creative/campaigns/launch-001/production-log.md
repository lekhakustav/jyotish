# Launch 001 video production log

**Campaign:** `cmp_20260716_launch`  
**Purpose:** durable, append-only record of the Jyotish Baje short-form video production work.  
**Canonical prompt source:** [`veo-prompts.md`](veo-prompts.md)  
**Current status:** `cou001` revision 2 is ready with the approved natural Nepali hook, full Veo
scene, and truthful store end card; `cru001` now has a copy-paste young-teen Veo prompt.
**Last updated:** 2026-07-18

**User production rule:** one output per concept; never create three-seed variants or duplicate
copies. If the generated voice is unsuitable, adapt the script and edit around the existing
visual instead of regenerating solely for voice.

## How to use this log

- Append new events; do not rewrite history after results are known.
- Record rejected Veo renders as well as accepted renders.
- Never put user-level data, real birth data, private chat, QR payloads, or large media binaries
  in Git.
- Link each claim to evidence: a file path, Drive file ID, checksum, Git SHA, capture record, or
  reviewer decision.
- If a previous entry is wrong, add a correction entry instead of silently editing it.

## Current production objective

Produce the first wave of truthful 9:16 short-form videos using the existing Launch 001 pack:

1. `dia001` — private Kundli QR handoff across distance.
2. `fam001` — family profiles and member-aware Jyotish Baje questions.
3. `nep001` — Nepali/English language switching and readable Nepali UI.
4. `voc001` — voice input with an editable transcript.

`pat001` is the next supporting-retention concept after this wave.

## Queue

| Concept | Prompt ID | Proof shots | Language | Status | Creative ID | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `dia001` | `prm_20260716_dia001` | Full Veo + continuous native QR handoff | English | Script awaiting review; render blocked | `crv_20260718_dia001en03` | 24-second script; all 8 Veo seconds first; real sender/receiver demo follows. |
| `fam001` | `prm_20260716_fam001` | `SH-FAM-01` to `SH-FAM-03` | TBD | Veo source received | TBD | Family profiles and selected-member context. |
| `nep001` | `prm_20260716_nep001` | `SH-LANG-01` to `SH-LANG-02` | TBD | Veo source received | TBD | Fluent Nepali review required. |
| `voc001` | `prm_20260716_voc001` | `SH-VOC-01` to `SH-VOC-02` | TBD | Veo source received | TBD | Final capability proof requires physical hardware. |
| `pat001` | `prm_20260716_pat001` | `SH-PAT-01` to `SH-PAT-03` | Later | Not started | TBD | Supporting retention concept. |
| `cou001` | `prm_20260718_cou001` | Full Veo; real two-profile proof later | Nepali | Revision 2 ready for review | `crv_20260718_cou001ne02` | Full 8-second source plus 2.5-second truthful store end card; no app demo yet. |
| `cru001` | `prm_20260718_cru001` | Young-teen Veo hook; consensual app proof later | Visual only | Prompt ready; one generation allowed | TBD | Age-appropriate 16–17 crush scene; no media generated. |

## Render register

| Date | Concept | Prompt ID/version | Seed | `media_id` | Local path | Drive file ID | Checksum | Status | Reason/evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | `dia001` | `prm_20260716_dia001` v1 | Not supplied | `med_20260718_dia001` | `marketing/media/launch-001/veo-source/med_20260718_dia001__cmp_20260716_launch__veo-source__omni-flash__20260718-1433.mp4` | `15FavDZISXcLW1MVCH2AtYnB_vxu5xkPa` | `edd3711a5536d7902a871b3e8bd93f9191e742ba8853c8092092d15b94d0f443` | Uploaded/verified | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one source per concept. |
| 2026-07-18 | `fam001` | `prm_20260716_fam001` v1 | Not supplied | `med_20260718_fam001` | `marketing/media/launch-001/veo-source/med_20260718_fam001__cmp_20260716_launch__veo-source__omni-flash__20260718-1436.mp4` | `1qaWoHwNRw63T8kjlxCDrjXbDcn6kCekV` | `853dff9017cb024e586aae9502c93ec3366f787a5678855349009f6b18dfbc52` | Uploaded/verified | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one source per concept. |
| 2026-07-18 | `nep001` | `prm_20260716_nep001` v1 | Not supplied | `med_20260718_nep001` | `marketing/media/launch-001/veo-source/med_20260718_nep001__cmp_20260716_launch__veo-source__omni-flash__20260718-1438.mp4` | `1iJRA0924EU4zU8S6dSRGoNQvAJ1IkHAU` | `fca34062260d900eb49bc942e77902e8569957410eacb9a8e11b4e75b7637367` | Uploaded/verified | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one source per concept. |
| 2026-07-18 | `voc001` | `prm_20260716_voc001` v1 | Not supplied | `med_20260718_voc001` | `marketing/media/launch-001/veo-source/med_20260718_voc001__cmp_20260716_launch__veo-source__omni-flash__20260718-1440.mp4` | `17SZw-R-Tgn77CeFCHOiZcvyiV764xXd-` | `52848ab0bfeaf33ad0aa1ac8d8619e59d5f1c982035240bb0a5f28ba552cf045` | Uploaded/verified | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one source per concept. |
| 2026-07-18 | `cou001` | `prm_20260718_cou001` v1 | Not supplied | `med_20260718_cou001` | `marketing/media/launch-001/veo-source/med_20260718_cou001__cmp_20260716_launch__veo-source__omni-flash__20260718-1836.mp4` | `1RV8Fw4I0CqnGubrFbG15wr3C451r9gQw` | `46305d97b17dbb7eb30ec311350aa90734928813ef1cc2a1a2642e56ea9d9de6` | Uploaded/verified | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; visually verified breakfast and shared-phone beat. |

## App-capture register

| Date | Concept | Shot keys | Git SHA | Platform/device | Fixture | `media_id`/Drive IDs | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | — | — | — | — | — | — | No captures yet | Use `demoSeed-v1`; physical hardware is required for voice and QR public proof. |

## Voice, edit, and review register

| Date | Concept / `creative_id` | Language | Voice asset | Edit/master | Review status | Evidence/notes |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | — | — | — | — | Not started | No voice, edit, or review assets yet. |
| 2026-07-18 | `cou001` / `crv_20260718_cou001ne` | Nepali | `med_20260718_cou001vo1` / Drive `1pSPJ9tTElg2KGNyinEfivZX5082xzzVu` | `med_20260718_cou001v1` / Drive `1OXIuyYzkCK6qYylwLQBD90korRwLuCb7` | Ready for user voice/mood review | Full 8.000-second Veo source; voice at 0.55–6.79; original ambience restored for the ending. |
| 2026-07-18 | `cou001` / `crv_20260718_cou001ne02` | Nepali | `med_20260718_cou001vo2` / Drive `1colBffLuYGhNYXe6XKFdTjEkzoGpuaWI` | `med_20260718_cou001v2` / Drive `1rzVUWHKyA_ZzIarNyRLgiOmk5hPNnzXX` | Ready for user review | Approved `ए, तिमी त ठ्याक्कै यस्तै छौ!` hook; mispronounced spoken brand trimmed; full Veo plus 2.5-second coming-soon card. |

## Decision and event history

### 2026-07-18 — Production conversation started

- **Decision:** Use this Codex conversation plus this repository as the working system for video
  production.
- **Decision:** Preserve the existing Launch 001 prompt pack as canonical.
- **Decision:** Begin with `dia001`, `fam001`, `nep001`, and `voc001`; produce `pat001` next.
- **Decision:** Generate clean Veo source scenes first. Real app footage, voiceover, captions,
  and CTA are added later in the edit.
- **Evidence:** `marketing/creative/campaigns/launch-001/README.md`, `veo-prompts.md`,
  `app-capture-shot-list.md`, and `preflight-checklist.md`.
- **Evidence:** Four downloaded MP4s were moved out of `/Users/sirishjoshi/Downloads` into the
  ignored local media workspace and renamed with stable media IDs. The Downloads originals no
  longer exist.
- **Decision:** Do not regenerate these scenes solely because the generated voice is imperfect;
  the edit will use script adaptation and selected voiceover treatment around the visual.
- **Next action:** Review the four source scenes, choose the strongest usable moments, and then
  capture the matching real-app proof shots.

### 2026-07-18 14:33–14:40 Asia/Kathmandu — First-wave Veo sources received

- **Source:** Four MP4 files downloaded from Omni Flash using the canonical Launch 001 prompts.
- **Concept mapping:** `dia001` at 14:33, `fam001` at 14:36, `nep001` at 14:38, and `voc001` at
  14:40, based on the downloaded filenames and visual subjects.
- **Verified media properties:** each file is 8.000 seconds, 720×1280, 24 fps, H.264 video,
  AAC audio, and 9:16 portrait.
- **Handling:** moved, not copied, from `/Users/sirishjoshi/Downloads` to
  `marketing/media/launch-001/veo-source/`; the four original Downloads paths were verified
  absent after the move. Each local file has one copy.
- **Model:** recorded exactly as supplied by the user: `omni-flash`; seed was not supplied.
- **Status:** local inbox only. Drive IDs and the media-manifest rows remain pending rather than
  being fabricated.
- **Next action:** inspect the visual moments, then capture the exact real-app proof shots listed
  for each concept.

### 2026-07-18 — `dia001` Swift-faithful product-motion draft

- **Decision:** use a reproducible HTML product-motion renderer instead of repeatedly operating
  the simulator for the review prototype.
- **Identity:** every visible profile is `Sita Sharma`; no other synthetic or real person appears.
- **Treatment:** 2.3 seconds of the approved Veo family scene followed by an ornamented,
  Swift-faithful visualization of choose profile, masked QR, receiver-selected relationship,
  saved profile, and end card.
- **Privacy:** no real birth data appears and the QR-like graphic is intentionally blurred and
  blocked by a privacy mark.
- **Creative:** `crv_20260718_dia001en`.
- **Draft media:** `med_20260718_dia001dr`; 17.2 seconds, 1080×1920, 30 fps, H.264, no audio,
  2,087,302 bytes.
- **Drive evidence:** `1zzsQ8Vr8DW6JmgHKSgNkxuTaRmtZxH--` in `exports_review`.
- **Renderer:** `marketing/scripts/render-dia001-product-motion.mjs`.
- **Source:** `marketing/creative/campaigns/launch-001/product-motion/dia001.html`.
- **Next action:** user review of visual direction; if approved, add voice/music and apply the
  same renderer pattern to `fam001`, `nep001`, and `voc001`.

### 2026-07-18 17:50 Asia/Kathmandu — Browser-rendered revision rejected

- **Render:** `med_20260718_dia001v2`; 9.400 seconds, 1080×1920, 25 fps, H.264, no audio,
  1,901,894 bytes.
- **Checksum:** `77438e06af3ae34ffac102c38933e1e387a5bdfb64be2f39a64b30600a25a403`.
- **Status:** rejected before upload and not entered in the Drive-backed media registry.
- **Reason:** the browser-recording method produced visibly incomplete/laggy frame rendering
  and did not visibly incorporate the actual Veo source. The user correctly rejected it.
- **Decision:** stop browser-recorded video rendering for this creative. Preserve the old
  renderer only for lineage; do not use it for future review exports.

### 2026-07-18 18:03–18:18 Asia/Kathmandu — Corrected deterministic Veo + Swift proof cut

- **Creative:** `crv_20260718_dia001en02`, which supersedes the rejected
  `crv_20260718_dia001en`.
- **Render:** `med_20260718_dia001v3`; 8.000 seconds, exactly 192 frames, 1080×1920, 24 fps,
  H.264 video plus the original Veo AAC audio, 1,511,214 bytes.
- **Checksum:** `0b8ef20622ea3e738c30fe623f37dd49814bca5b630fe9d325076eb3112989d4`.
- **Actual Veo use:** frames 0–54 use source frames 0–54; frames 113–129 use source frames
  144–160. The original 8-second Veo audio remains intact.
- **Proof treatment:** the other frames use App Store compositions made from real Swift
  screenshots. The synthetic fixture's Sita Sharma profile is visible. The complete QR region
  is covered by a solid editorial privacy card in every exported proof frame.
- **Edit:** hard cuts only; no browser capture, fake tap, simulator claim, or frame interpolation.
- **Inspection:** sampled frames at 0.50, 2.00, 2.40, 4.60, 4.90, 5.60, and 7.50 seconds;
  verified 192-frame 24 fps output and 8.000-second matching audio/video streams.
- **Renderer:** `marketing/scripts/render-dia001-veo-swift-proof.sh`.
- **Drive:** uploaded once to `exports_review`; file ID
  `1UmDqGWh4NLptz-WmHiv1_y-aLeDrKZr3`; readback verified name, MIME type, byte size, and parent
  folder.
- **Status:** uploaded draft for user review, not registry-ready or approved for publication.
  Continuous real-app `SH-QR-02` and `SH-QR-03` action captures remain required before a public
  final.
- **Next action:** get the user's visual verdict on this corrected cut. If accepted, capture the
  missing continuous native actions and replace the screenshot proof section in a new creative.

### 2026-07-18 18:19 Asia/Kathmandu — Eight-second cut rejected; script-first reset

- **User verdict:** reject `crv_20260718_dia001en02` / `med_20260718_dia001v3`. The edit was too
  short, cut the Veo scene abruptly, did not let the product remain readable, and used
  unnecessary overlay text.
- **Root cause:** the edit imposed an eight-second total duration even though the user's intended
  structure was the complete eight-second Veo story followed by a separate screen-recorded
  demonstration.
- **Story correction:** the Veo source is one complete two-shot sequence: Sydney at 0–3.8 seconds
  and Kathmandu at 3.8–8.0 seconds. The generated match cut is the concept's emotional hook and
  must remain intact.
- **New treatment:** `crv_20260718_dia001en03`, a 24-second script using all 192 Veo frames in
  order, followed by continuous native sender, receiver, relationship-choice, and saved-result
  actions.
- **Script:** `marketing/creative/campaigns/launch-001/dia001-full-veo-demo-script.md`.
- **Script checksum:** `2f69fe840b5c7133efc34e5514cae96fe820966ee818198e2125a2cf7830e9b4`.
- **Text rule:** one light hook over the Veo quiet area, no labels over explanatory native UI,
  lock symbol only over the QR payload, and one restrained CTA/disclosure over the held result.
- **Render gate:** no new video may be rendered until the script is accepted and continuous
  physical-device sender/receiver captures exist.
- **Next action:** review and revise the written script with the user. Do not edit video yet.

### 2026-07-18 18:30 Asia/Kathmandu — Tagline narration, sound plan, and couple prompt

- **Narration decision:** reduce `dia001` to three lines: “One family. Two time zones.”,
  “Distance should not mean losing family context.”, and “Keep your family's astrology close
  with Jyotish Baje.”
- **Consumer-language decision:** do not use the user's rejected family-profile term in
  narration, editorial text, or visible capture copy. The current native family-sharing labels
  still contain it, so the next capture is blocked until neutral labels such as **My Family**,
  **Share My Birth Profile**, and **Add to Family** are approved and implemented.
- **Text decision:** only the first line, second line, and final value line appear editorially.
  Do not place labels or instructions over native UI.
- **Sound decision:** preserve the full Veo ambience; add a restrained modern acoustic bed,
  real-action tap accents only, and a warm resolution on the saved Sita result. No scanner beep,
  temple bell, chant, cosmic shimmer, or mystical cliché.
- **Updated script:** `marketing/creative/campaigns/launch-001/dia001-full-veo-demo-script.md`;
  checksum `b4b13a1218a2ebe00c2f40992e73d2bfb778de10b59c3f678d58a9ac129d23e2`.
- **New exploratory couple prompt:** `prm_20260718_cou001`, “That is so us,” appended to
  `veo-prompts.md`; prompt-block checksum
  `ac4d99950fbe216861c914adadd37c3e49b8d6912d4bd92fab0638d60f2cdd16`.
- **Couple direction:** a playful Nepali couple shares a harmless “that is so us” astrology
  moment while making breakfast. It is not marriage matching, a compatibility score, a verdict,
  or a testimonial.
- **Production rule:** generate one couple output only if the user proceeds with this prompt.
- **Next action:** give the user the copy-paste couple prompt and the revised three-line
  narration/sound/text plan. Do not render `dia001` yet.

### 2026-07-18 18:36–18:47 Asia/Kathmandu — Couple source, Nepali voice review, and crush script

- **Prompt-location correction:** the previous event correctly records the generated prompt and
  checksum but its location is no longer canonical. `prm_20260718_cou001` was moved from the
  Launch 001 pack to `marketing/creative/explorations/cou001/veo-prompt.md` so the fixed launch
  matrix remains unchanged. The exact fenced prompt checksum remains
  `ac4d99950fbe216861c914adadd37c3e49b8d6912d4bd92fab0638d60f2cdd16`.
- **Source handling:** moved, not copied, from
  `/Users/sirishjoshi/Downloads/Couple_making_breakfast_together_202607181836.mp4` to the
  ignored media path registered as `med_20260718_cou001`; verified the Downloads source is
  absent and only the renamed local source remains.
- **Source evidence:** SHA-256
  `46305d97b17dbb7eb30ec311350aa90734928813ef1cc2a1a2642e56ea9d9de6`;
  2,227,671 bytes; 8.000 seconds; 720×1280; 24 fps; exactly 192 H.264/AAC frames. Contact-sheet
  inspection confirmed the breakfast, hidden-phone, and playful shared-laugh sequence.
- **Source Drive:** uploaded once to `ai_veo`; file ID
  `1RV8Fw4I0CqnGubrFbG15wr3C451r9gQw`. Metadata readback verified name, MIME type, size, and
  parent folder.
- **Reusable voice mechanism:** added
  `marketing/scripts/generate-elevenlabs-marketing-voice.mjs`. It reads the existing
  `ELEVENLABS_API_KEY` from `/Users/sirishjoshi/Documents/New project 2` without copying or
  printing the secret.
- **Voice selection:** added the shared ElevenLabs voice `Karki - Nepali voice Artist` as
  `Karki Nepali Marketing` (`6oN9zQt5lDqGi7wZn5p2`). Use Eleven v3 because the multilingual-v2
  endpoint rejected Nepali language code `ne`. Default speed is 1.08 with a casual social-video
  treatment.
- **Voice line:** “यो त हामी जस्तै छ! ज्योतिष पनि सँगै हेर्दा झन् रमाइलो हुन्छ। ज्योतिष
  बाजेसँग।” The one generated output is `med_20260718_cou001vo1`, SHA-256
  `388ad37ae3e834fc0de47d1c182474e532fc78abbf0f41150be820e630d9be44`, 6.240 seconds.
  ElevenLabs Scribe returned the intended Nepali wording exactly.
- **Voice Drive:** uploaded once to `ai_voice`; file ID
  `1pSPJ9tTElg2KGNyinEfivZX5082xzzVu`. Metadata readback verified name, MIME type, size, and
  parent folder.
- **Review edit:** `med_20260718_cou001v1` uses all 192 source frames in order. The voice begins
  at 0.55 seconds; source ambience is ducked only under speech and restored for the final
  laughter. There is no overlay text, time-stretch, source cut, or app-proof claim.
- **Review evidence:** SHA-256
  `a43c7eacad6f8d5af790057336607421b2d0bfdeb202129daf5953bde9df7508`;
  2,287,253 bytes; 8.000 seconds; 720×1280; 24 fps; H.264/AAC; Drive file ID
  `1OXIuyYzkCK6qYylwLQBD90korRwLuCb7` in `exports_review`, with metadata readback verified.
- **Identity continuity:** use `Sita Sharma` for every visible synthetic name when real app
  footage is appended. No real names or birth details may appear.
- **New crush script:** `marketing/creative/explorations/cru001/script.md` targets 18–19-year-old
  late teens and young adults with a playful crush hook, consensual two-profile proof, no score,
  and no claim that astrology discovers feelings or decides a relationship.
- **Next action:** user reviews the full couple voice/mood treatment. If the voice is accepted,
  append a readable real-app relationship-astrology demonstration in a new creative rather than
  shortening the Veo source.

### 2026-07-18 19:10–19:20 Asia/Kathmandu — Natural Nepali revision, store card, and teen Veo prompt

- **User correction:** reject the translated `यो त हामी जस्तै छ!` opening in
  `crv_20260718_cou001ne`. It does not sound natural in Nepali context. Mark that creative
  rejected without deleting its registered evidence.
- **Approved hook:** use `ए, तिमी त ठ्याक्कै यस्तै छौ!`, followed by the concrete couple value
  `एकअर्काको बानी र सोच अझ राम्रोसँग बुझ्न।`
- **Voice source:** generated one new Eleven v3 take, `med_20260718_cou001vo2`, using Karki Nepali
  Marketing at speed 1.08. SHA-256
  `454b0f3c0c76e0d660465d4c21e6b4f84d4bbb0ef0be0a8661aba78141c6b426`;
  111,221 bytes; 6.880 seconds.
- **Pronunciation verification:** Scribe v2 recognized the approved hook and couple-benefit
  wording, but heard the generated brand as `ज्योतिस बाजे`. Keep the take and trim it at source
  time 5.55 seconds after `बुझ्न`; let the real on-screen logo identify the brand. This avoids
  another voice generation solely for one unsuitable word.
- **Voice Drive:** uploaded once to `ai_voice`; file ID
  `1colBffLuYGhNYXe6XKFdTjEkzoGpuaWI`. Metadata readback verified name, MIME type, byte size,
  and parent folder.
- **End card:** native Swift renderer uses the repository's real transparent Jyotish Baje logo
  on a cream card for 2.5 seconds. It says `Understand each other better.` and names both
  `App Store` and `Google Play`.
- **Store-truth decision:** the local release checklist still has owner submission work and
  blockers for both stores. The required web checker was not installed, so no live listing was
  independently verified. The card therefore says `Coming soon to`, not `Download now`.
- **Revised export:** `med_20260718_cou001v2` / `crv_20260718_cou001ne02`; all 192 Veo frames
  remain in order, followed by the card. The 10.500-second output has exactly 252 frames at
  24 fps, 720×1280 H.264 video, AAC audio, and SHA-256
  `0fb25a3af193ff07eec3511cedd74882b70541c2a699d5a209af1e208799041f`.
- **Final-audio verification:** Scribe v2 on the mixed MP4 returned only
  `ए तिमी त ठ्याक्कै यस्तै छौ। एकअर्काको बानी र सोच अझ राम्रोसँग बुझ्न।`; the rejected
  brand pronunciation is absent from the final export.
- **Review Drive:** uploaded once to `exports_review`; file ID
  `1rzVUWHKyA_ZzIarNyRLgiOmk5hPNnzXX`. Metadata readback verified name, MIME type, byte size,
  and parent folder.
- **Render mechanism:** `marketing/scripts/render-cou001-nepali-insight-endcard.sh` orchestrates
  the audio/video edit; `marketing/scripts/render-jyotish-store-endcard.swift` creates the card
  without browser recording or frame-render lag.
- **Young-teen clarification:** `cru001` is now a 16–17-year-old, age-appropriate crush concept,
  not an 18–19 college concept. The exact one-output Veo prompt is
  `marketing/creative/explorations/cru001/veo-prompt.md`, prompt ID
  `prm_20260718_cru001`, fenced-content SHA-256
  `f07f49b153f41134d25080e50f1ede20749c42dfac768190e7f4b859798fa7ae`.
- **Next action:** user reviews `cou001` revision 2 and generates exactly one `cru001` Veo
  output from the registered prompt.

## Handoff checklist for the next chat

- Read this log and report the last event before doing anything else.
- Check the queue for the first `Not started` or `In progress` item.
- Use the matching canonical prompt from `veo-prompts.md`.
- Ask for or inspect the generated output; do not infer quality from the prompt alone.
- Register every output, including rejects, with provenance and a reason.
- Append the next event and leave a clear next action.
