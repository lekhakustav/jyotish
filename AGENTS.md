# Repository operating instructions

Document decisions, mechanisms, assumptions, and verification evidence so a later Codex
session can continue without reconstructing intent from Git history.

Commit coherent checkpoints frequently. Keep commits reviewable and describe the outcome,
not the tool used to produce it.

## Web research

Use the gstack `/browse` skill for all web browsing. Never use
`mcp__claude-in-chrome__*` tools. Record the URL, access date, claim supported, source type,
and material caveats in `marketing/research/sources.csv` for every source used in a decision.

## Marketing workspace

- `marketing/` is the source of truth for strategy, research, prompts, creative recipes,
  registries, experiment plans, aggregate performance data, and reports.
- Google Drive is the source of truth for large binary media: Veo renders, app captures,
  voice tracks, stock footage, edit projects, masters, and platform exports.
- Never add video, audio, editor project, archive, or large generated-media binaries to Git.
  Local copies belong under `marketing/media/`, which is intentionally ignored.
- Every Drive file used by a creative must have a stable `media_id`, Drive file ID, checksum,
  provenance, and rights status in `marketing/registry/media-manifest.csv`.
- Never store user-level analytics, birth data, names, contact details, chat text, device IDs,
  advertising IDs, or authentication data in Git. Only aggregate campaign/cohort data belongs
  here.
- Raw performance exports are append-only. Corrections receive a new ingestion ID and file;
  do not rewrite history after seeing results.
- A material creative change creates a new `creative_id`. Never replace a file in place and
  pretend it is the same treatment.
- Pre-register experiments before launch. Label organic comparisons observational and reserve
  causal language for randomized tests.
- Astrology advertising must not use fear, inevitability, medical/financial/legal certainty,
  guaranteed outcomes, caste discrimination, or pressure to buy remedies.
- Run `npm run marketing:validate` before committing marketing registry or experiment changes.

## Active Jyotish marketing-video handoff

This repository is the continuing workspace for the Jyotish Baje marketing-video production
conversation. When a later Codex chat references this work, read these files before taking
action:

1. `marketing/creative/campaigns/launch-001/production-log.md` — append-only decisions,
   actions, evidence, render IDs, blockers, and next steps.
2. `marketing/creative/campaigns/launch-001/README.md` — approved campaign sequence and
   production contract.
3. `marketing/creative/campaigns/launch-001/veo-prompts.md` — canonical copy-paste Veo prompts.
4. `marketing/creative/campaigns/launch-001/app-capture-shot-list.md` — exact real-app proof
   footage required for each concept.
5. `marketing/creative/campaigns/launch-001/preflight-checklist.md` — release gate.

The current objective is to generate and document the first production wave: `dia001`, `fam001`,
`nep001`, and `voc001`; `pat001` follows. Start with the existing prompt IDs
`prm_20260716_dia001`, `prm_20260716_fam001`, `prm_20260716_nep001`, and
`prm_20260716_voc001`. Do not invent replacement prompts or overwrite the canonical pack without
recording why.

For every Veo output, including rejected outputs, record a unique `media_id`, prompt ID/version,
seed, generation date, model/provenance, checksum, Drive location, and rejection/acceptance
reason in the production log and media manifest. Keep all large media out of Git. Every material
creative change receives a new `creative_id`. Keep the production log append-only and make a
coherent Git checkpoint after documentation or registry changes.

The user wants this work to remain resumable across chats. At the start of each continuation,
report the last logged state, inspect the next unfinished queue item, and ask only for missing
evidence such as Veo output IDs, Drive links, or generation results. Do not claim a scene was
generated, uploaded, approved, or published without a logged artifact or verification.

## gstack

Available gstack skills include `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`,
`/plan-design-review`, `/design-consultation`, `/review`, `/ship`, `/browse`, `/qa`,
`/qa-only`, `/design-review`, `/setup-browser-cookies`, `/retro`, `/investigate`,
`/document-release`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, and `/gstack-upgrade`.
