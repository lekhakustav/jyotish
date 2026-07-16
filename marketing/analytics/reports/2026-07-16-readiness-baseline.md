# Marketing readiness baseline — 2026-07-16

**Observation date:** 2026-07-16
**Evidence state:** merged local marketing workspace
**Performance data state:** zero observations

## Executive baseline

The marketing operating system and Launch 001 source pack are substantially specified, but no ad
has been produced, registered, published, or measured. This report establishes a zero-data
baseline; it contains no reach, view, engagement, click, install, activation, retention, revenue,
or statistical result.

The first useful work is production and pipeline verification, not winner selection. Launch-stage
creative diagnostics can become active once publications and platform exports exist. Install,
activation, retention, CAC, ROAS, and profit conclusions remain blocked by instrumentation,
attribution, cohort maturity, or the absence of monetization.

## Evidence inventory

| Artifact | Observed state | Evidence |
| --- | --- | --- |
| Audience hypotheses | 13 registered rows | `marketing/registry/audiences.csv` |
| Launch campaign | 1 registered row | `marketing/registry/campaigns.csv` |
| Launch concepts | 12 registered rows | `marketing/registry/concepts.csv` |
| Veo prompt records | 12 registered rows | `marketing/registry/prompts.csv` |
| Creative records | 0 | `marketing/registry/creatives.csv` |
| Media records | 0 | `marketing/registry/media-manifest.csv` |
| Publications | 0 | `marketing/registry/publications.csv` |
| Experiments | 0 | `marketing/registry/experiments.csv` |
| Ingestion runs | 0 | `marketing/registry/ingestion-runs.csv` |
| Raw/normalized/derived performance facts | 0 data files or rows | `marketing/data/` |
| Google Drive media workspace | Root and folder IDs documented as verified | `marketing/operations/google-drive.md` and `marketing/registry/drive-folders.csv` |
| Launch production instructions | 12-concept prompts, voiceovers, edits, capture shots, and preflight gate present | `marketing/creative/campaigns/launch-001/` |
| Structural validator | Dependency-free executable and npm command are present; a passing run is required before publication | `package.json` and `marketing/scripts/validate-marketing-data.mjs` |

The counts above describe registry rows, not produced assets or performance. A concept or prompt
row is not evidence that media was generated or that a user saw an ad.

## Metrics active when source data arrives

These platform metrics have canonical definitions and can be calculated from privacy-safe
aggregate exports when the selected platform actually reports the numerator and denominator:

- `video_view_3s_rate = video_views_3s / impressions`
- `shares_per_1000 = 1000 * shares / impressions`
- `save_rate = saves / impressions`
- `comment_rate = comments / impressions`
- `completion_rate = video_plays_100pct / video_starts`
- `completion_per_impression = video_plays_100pct / impressions`
- `outbound_ctr = outbound_clicks / impressions`, once a verified destination exists

They are diagnostic metrics, not proof of installs or business value. A missing platform metric is
null, not zero. TikTok two-second views and Meta/Instagram three-second views remain separate
native definitions; do not manufacture a cross-platform hold rate.

The Launch 001 matrix now uses only canonical primary metric keys. `save_rate` and
`comment_rate` count all platform-reported saves/comments; they do not claim that comments were
qualitatively reviewed or "qualified."

## Metrics currently blocked

| Metric family | Status | Blocking evidence |
| --- | --- | --- |
| Feature-specific report/voice/profile rates | Blocked or unavailable | Exact event and denominator requirements are registered in `analytics/metrics.csv`; several canonical events/context joins do not exist |
| Creative-level installs and CPI | Blocked | No install-attribution mechanism; UTMs do not reliably survive every app-store install path |
| D1 activation and cost per activated install | Blocked | `app_first_open`, canonical personalized-value funnel, and creative attribution are incomplete |
| D1/D7/D30 guided retention | Blocked | Activation boundary is incomplete and no mature acquisition cohort exists |
| CAC, ROAS, revenue, profit | Future/inapplicable | The current app has no subscription or in-app purchase |

Feature metrics must remain null until their exact registered definition can be calculated. Raw
event counts, clicks, or a different denominator are not acceptable substitutes.

## Publication and paid-launch gates

1. **Privacy/legal alignment:** the current privacy policy says the app does not use the camera or
   collect analytics, while the shipped repository has Parivar QR camera access and first-party
   product analytics. Legal copy and store disclosures require review.
2. **Store destination:** no verified App Store or Google Play listing URL is registered, so final
   install CTA and destination QA cannot pass.
3. **Paid eligibility:** paid horoscope/astrology ad eligibility for the intended Nepal/India
   market-platform combination is not recorded as approved. Remain organic or eligibility-gated.
4. **Attribution decision:** choose and review platform-native attribution, SKAN/AdServices, or an
   MMP before claiming creative-level installs. Do not add IDFA, fingerprinting, or cross-app
   tracking incidentally.
5. **Media provenance:** every Veo render, voice, app capture, edit, and final master needs a
   `media_id`, Drive file ID, SHA-256, model/source, rights status, and derivation lineage.
6. **Proof privacy:** app captures must use the synthetic QA household and show no readable QR
   payload, real birth data, account identifier, chat content, or notification.
7. **Language and claims:** fluent review is required for Nepali/Hinglish; each treatment must stay
   at or below its safe claim and avoid certainty, fear, outcome guarantees, or fabricated UI.
8. **AIGC/platform QA:** apply current AI-generated-content disclosure and inspect crop, captions,
   audio, safe zones, and link behavior in a real platform draft.
9. **Structural validation:** `npm run marketing:validate` must pass before registry or experiment
   changes are considered launch-ready.

These gates do not prevent generating unpublished scenes, recording synthetic proof, or assembling
review drafts.

## First production wave

Produce the four already prioritized concepts, one Nepali and one English creative each. Language
versions are separate `creative_id` treatments:

1. `cpt_20260716_fam001` — family-aware value for a diaspora/family installer; primary diagnostic
   `shares_per_1000`.
2. `cpt_20260716_nep001` — Nepali-language recognition for the primary user;
   `video_view_3s_rate` where the platform exposes the exact three-second field.
3. `cpt_20260716_pat001` — recurring Patro/family-date utility; `save_rate`.
4. `cpt_20260716_voc001` — low-friction voice-input proof; `shares_per_1000`.

The first organic publications are observational exploration. They may establish source-specific
baselines and reveal production failures, but organic reach differences do not identify causal
creative effects.

## First A/A pipeline test prerequisites

The A/A test validates assignment, lineage, export ingestion, metric mapping, and analysis. It is
not expected to discover a creative winner.

Before pre-registration:

1. Resolve or explicitly gate the legal, paid-eligibility, store-destination, and platform access
   blockers above.
2. Produce one approved creative with final media checksum and complete Drive lineage.
3. Confirm the chosen platform can randomly split the same eligible population between two arms;
   ordinary optimized delivery is not an A/A test.
4. Choose one source-native primary metric available in the export. Prefer
   `video_view_3s_rate` only when the platform reports the exact three-second numerator and
   impressions denominator consistently.
5. Create two arm IDs and publication/ad IDs using the identical creative binary, copy, CTA,
   destination, audience, placements, schedule, and attribution settings; only assignment arm may
   differ.
6. Register the experiment and plan before launch. Specify traffic weights, exclusion rules,
   sample-ratio-mismatch check, fixed horizon or valid sequential method, attribution window, and
   data-maturity rule.
7. Estimate baseline variance/sample requirements from a genuine pilot or defensible prior. There
   is currently no data from which to invent a powered sample size or equivalence margin.
8. Verify that both publication IDs resolve through the normalized facts to one creative and the
   correct experiment arms, and that raw aggregate exports receive immutable ingestion IDs and
   checksums.
9. Run the structural validator before launch and again before analysis.

At analysis, inspect sample-ratio mismatch and delivery balance before comparing the primary
metric. A large arm difference suggests an assignment, delivery, or data-pipeline problem. A
non-significant difference does not by itself prove equivalence unless an equivalence test and
margin were pre-registered.

## Baseline conclusion

No performance conclusion is available on 2026-07-16. The truthful status is: strategy and source
creative are ready for bounded production; media, publications, performance facts, attribution,
and experiments are not yet present. The next evidence milestone is registered media plus the
first privacy-safe platform observation—not a forecast of virality or revenue.
