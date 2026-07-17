# Marketing readiness status

**Status date:** 2026-07-17
**System status:** operating foundation ready; production and publication not started

## Ready

- Repository, shipped product capabilities, market, competitors, audiences, platform guidance,
  and advertising-policy risks audited with dated sources.
- Git/Google Drive ownership boundary defined and enforced with binary ignore rules.
- Verified 26-folder Google Drive media workspace created under the Sodhera Admin account.
- Stable campaign-to-publication lineage, aggregate data contracts, experiment schemas, KPI
  definitions, reporting templates, privacy rules, and data-governance rules implemented.
- Launch 001 contains 12 copy-paste Veo prompts, 36 voiceover treatments, 12 second-by-second
  edit recipes, 28 reproducible real-app proof shots, and a publication preflight gate.
- Readiness baseline records the truthful zero-data state; no media, creative, publication,
  experiment, or performance result has been fabricated.
- `npm run marketing:validate` passes: 21 CSV contracts, 134 contracted rows, 12 launch concepts,
  and eight verified Drive document snapshots after the Drive evidence sync.

## Launch blockers

1. ~~Privacy-policy contradictions~~ Resolved 2026-07-17: legal docs now disclose first-party
   analytics, QR camera use, and real sign-in methods. Two successor blockers remain (see
   `docs/22-STORE-SUBMISSION-CHECKLISTS.md`): the corrected policy still needs a live public
   URL, and the app lacks the in-app account deletion Apple/Google require.
2. There is no app-store listing URL recorded in the repo, so final install CTAs and link QA
   cannot be completed yet.
3. There is no install-attribution mechanism. Do not claim creative-level app conversion
   causality from UTMs alone.
4. The app is free. Profit, CAC-to-payer, and ROAS reporting remain intentionally inactive.
5. Paid TikTok horoscope/astrology eligibility for Nepal and India is not confirmed in the
   accessed policy. Treat organic publishing and paid eligibility as separate reviews.

## Next operational milestone

Produce Nepali and English variants of `dia001`, `fam001`, `nep001`, and `voc001`: record clean
iOS and Android app proof clips at a known Git SHA, generate at least three Veo seeds per prompt,
register all source media in Drive, assemble unpublished drafts, and pass the preflight gate.
Register and run an A/A pipeline test only after its paid-platform, destination, assignment, and
measurement prerequisites are real. Publish only when the applicable blockers above are resolved
or explicitly accepted by the accountable owner.
