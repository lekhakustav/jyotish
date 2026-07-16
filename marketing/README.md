# Jyotish Baje marketing operating system

This directory turns marketing into a reproducible product discipline. It connects a market
hypothesis to a Veo prompt, generated scene, edit, publication, observed performance, app
activation, experiment decision, and next creative iteration without losing provenance.

The objective is not to manufacture a one-off “viral” post. It is to build a compounding
learning system that discovers which truthful messages make the right people install,
complete a birth profile, receive personalized value, and return.

## Start here

1. Read [GOALS.md](GOALS.md) for the business objective and measurement hierarchy.
2. Read [STATUS.md](STATUS.md) for current readiness and blockers.
3. Read [operations/workflow.md](operations/workflow.md) before producing an ad.
4. Read [operations/google-drive.md](operations/google-drive.md) before handling media.
5. Read [operations/claims-and-privacy.md](operations/claims-and-privacy.md) before publishing.
6. Use the launch campaign under [creative/campaigns/launch-001](creative/campaigns/launch-001)
   as the first creative and experiment backlog.

## Source-of-truth boundary

| Artifact | Canonical home | Git policy |
| --- | --- | --- |
| Strategy, research, prompts, scripts, recipes | Git | Track |
| Campaign, creative, publication, experiment registries | Git | Track |
| Aggregate performance exports and derived reports | Git | Track when privacy-safe |
| Veo renders, app recordings, audio, stock, edit projects | Google Drive | Do not track |
| Local working copies and caches | `marketing/media/` | Ignored |
| User-level product events or sensitive profile data | Supabase/admin systems | Never put in Git or Drive marketing folders |

## Directory map

```text
marketing/
  research/       sourced market, audience, competitor, and channel findings
  strategy/       positioning, audience hypotheses, channel plan
  creative/       Veo prompts, voiceovers, edit recipes, campaign packs
  registry/       stable IDs and lineage across every marketing entity
  experiments/    pre-registered plans, amendments, analyses, decisions
  data/           immutable raw aggregate exports, normalized facts, derived data
  analytics/      KPI definitions and dated reports
  operations/     workflow, governance, Drive, naming, claims, reporting
  templates/      copy-first starting points for repeatable work
  scripts/        validation and later normalization/report generation
  media/          ignored local mirror/cache for Drive binaries
```

## Required validation

```sh
npm run marketing:validate
```

The validator checks foreign keys, ID formats, experiment traffic weights, required fields,
unsafe paths, binary leakage, and common privacy mistakes. A passing validator proves
structural consistency, not business success or legal compliance.
