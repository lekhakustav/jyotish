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

## gstack

Available gstack skills include `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`,
`/plan-design-review`, `/design-consultation`, `/review`, `/ship`, `/browse`, `/qa`,
`/qa-only`, `/design-review`, `/setup-browser-cookies`, `/retro`, `/investigate`,
`/document-release`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, and `/gstack-upgrade`.
