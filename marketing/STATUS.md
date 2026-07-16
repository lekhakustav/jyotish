# Marketing readiness status

**Status date:** 2026-07-16  
**System status:** foundation in progress

## Ready

- Repository and product capabilities audited.
- Git/Google Drive ownership boundary defined.
- Verified Google Drive media workspace created under the Sodhera Admin account.
- Stable campaign-to-publication lineage and privacy rules defined.
- Initial market research, launch creative pack, schemas, and validator are being added in
  this setup change.

## Launch blockers

1. The privacy policy says the app does not collect analytics or use the camera, while the
   shipped app has first-party product analytics and Parivar QR camera access. Legal/privacy
   copy and store disclosures require review before paid acquisition or attribution work.
2. There is no app-store listing URL recorded in the repo, so final install CTAs and link QA
   cannot be completed yet.
3. There is no install-attribution mechanism. Do not claim creative-level app conversion
   causality from UTMs alone.
4. The app is free. Profit, CAC-to-payer, and ROAS reporting remain intentionally inactive.

## Next operational milestone

Record clean iOS and Android app proof clips at a known Git SHA, generate the first Veo scene
variants, assemble the A/A pipeline test, and publish only after the launch blockers above are
either resolved or explicitly accepted as limitations.
