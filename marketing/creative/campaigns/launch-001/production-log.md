# Launch 001 video production log

**Campaign:** `cmp_20260716_launch`  
**Purpose:** durable, append-only record of the Jyotish Baje short-form video production work.  
**Canonical prompt source:** [`veo-prompts.md`](veo-prompts.md)  
**Current status:** four first-wave Veo source scenes received locally; app-proof capture and
assembly are not started.
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
| `dia001` | `prm_20260716_dia001` | `SH-QR-01` to `SH-QR-03` | TBD | Veo source received | `med_20260718_dia001` | First product promise; mask every QR frame. |
| `fam001` | `prm_20260716_fam001` | `SH-FAM-01` to `SH-FAM-03` | TBD | Veo source received | `med_20260718_fam001` | Family profiles and selected-member context. |
| `nep001` | `prm_20260716_nep001` | `SH-LANG-01` to `SH-LANG-02` | TBD | Veo source received | `med_20260718_nep001` | Fluent Nepali review required. |
| `voc001` | `prm_20260716_voc001` | `SH-VOC-01` to `SH-VOC-02` | TBD | Veo source received | `med_20260718_voc001` | Final capability proof requires physical hardware. |
| `pat001` | `prm_20260716_pat001` | `SH-PAT-01` to `SH-PAT-03` | Later | Not started | TBD | Supporting retention concept. |

## Render register

| Date | Concept | Prompt ID/version | Seed | `media_id` | Local path | Drive file ID | Checksum | Status | Reason/evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | `dia001` | `prm_20260716_dia001` v1 | Not supplied | `med_20260718_dia001` | `marketing/media/launch-001/veo-source/med_20260718_dia001__cmp_20260716_launch__veo-source__omni-flash__20260718-1433.mp4` | Pending upload | `edd3711a5536d7902a871b3e8bd93f9191e742ba8853c8092092d15b94d0f443` | Local inbox | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one local copy. |
| 2026-07-18 | `fam001` | `prm_20260716_fam001` v1 | Not supplied | `med_20260718_fam001` | `marketing/media/launch-001/veo-source/med_20260718_fam001__cmp_20260716_launch__veo-source__omni-flash__20260718-1436.mp4` | Pending upload | `853dff9017cb024e586aae9502c93ec3366f787a5678855349009f6b18dfbc52` | Local inbox | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one local copy. |
| 2026-07-18 | `nep001` | `prm_20260716_nep001` v1 | Not supplied | `med_20260718_nep001` | `marketing/media/launch-001/veo-source/med_20260718_nep001__cmp_20260716_launch__veo-source__omni-flash__20260718-1438.mp4` | Pending upload | `fca34062260d900eb49bc942e77902e8569957410eacb9a8e11b4e75b7637367` | Local inbox | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one local copy. |
| 2026-07-18 | `voc001` | `prm_20260716_voc001` v1 | Not supplied | `med_20260718_voc001` | `marketing/media/launch-001/veo-source/med_20260718_voc001__cmp_20260716_launch__veo-source__omni-flash__20260718-1440.mp4` | Pending upload | `52848ab0bfeaf33ad0aa1ac8d8619e59d5f1c982035240bb0a5f28ba552cf045` | Local inbox | Omni Flash; 8.000s; 720×1280; 24fps; H.264/AAC; one local copy. |

## App-capture register

| Date | Concept | Shot keys | Git SHA | Platform/device | Fixture | `media_id`/Drive IDs | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | — | — | — | — | — | — | No captures yet | Use `demoSeed-v1`; physical hardware is required for voice and QR public proof. |

## Voice, edit, and review register

| Date | Concept / `creative_id` | Language | Voice asset | Edit/master | Review status | Evidence/notes |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-07-18 | — | — | — | — | Not started | No voice, edit, or review assets yet. |

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

## Handoff checklist for the next chat

- Read this log and report the last event before doing anything else.
- Check the queue for the first `Not started` or `In progress` item.
- Use the matching canonical prompt from `veo-prompts.md`.
- Ask for or inspect the generated output; do not infer quality from the prompt alone.
- Register every output, including rejects, with provenance and a reason.
- Append the next event and leave a clear next action.
