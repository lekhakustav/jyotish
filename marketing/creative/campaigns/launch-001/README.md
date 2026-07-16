# Launch 001 creative production pack

**Campaign ID:** `cmp_20260716_launch`
**Pack status:** production-ready source material; no media has been generated, registered,
or approved for publication yet
**Primary markets:** Nepal and Nepali diaspora
**Secondary discovery market:** Hindu/Jyotish-interested audiences who can use the app in
English; Hinglish is an acquisition voiceover option, not a claim that the app has Hindi UI
**Format:** a 9:16 Reel/TikTok assembled from an 8-second Veo source scene, real app capture,
voiceover, burned-in captions, light editorial motion, and one CTA

## What this pack is for

This is the first executable creative backlog for Jyotish Baje. It turns the primary product
position—private Kundli sharing for Nepali Hindu families, followed by trusted household Jyotish
value—into twelve distinct short-form concepts. The Veo scene supplies a recognizable human
moment. Real app footage immediately proves the feature. The generated scene must never
impersonate the product UI.

The first learning objective is not "which ad went viral?" It is:

> Which truthful audience tension and shipped proof feature earns sustained watching,
> app-relevant action, and eventually an activated household?

The twelve concepts are deliberately broad seed treatments. Their first organic publications
are observational exploration, not a randomized experiment. Once a baseline treatment exists,
change one named factor at a time and pre-register the test in `marketing/experiments/` before
launch.

## Files in this pack

| File | Use |
| --- | --- |
| `creative-test-matrix.csv` | Machine-readable concept, audience, feature, claim, hypothesis, and factor map |
| `veo-prompts.md` | Twelve standalone copy-paste prompts for clean 8-second Veo source scenes |
| `voiceovers.md` | Nepali, English, and Hinglish voiceover treatments for every concept |
| `edit-recipes.md` | Second-by-second assembly instructions using the generated scene and real app proof |
| `app-capture-shot-list.md` | Reproducible capture plan using the built-in synthetic QA household |
| `preflight-checklist.md` | Claim, privacy, rights, lineage, language, edit, and draft-upload release gate |

## The twelve launch concepts

| # | Concept ID | Working title | Primary audience role | Shipped proof |
| ---: | --- | --- | --- | --- |
| 01 | `cpt_20260716_fam001` | The question is about family | Diaspora adult child / household installer | My Kundli & QR profiles + member-aware Jyotish Baje question |
| 02 | `cpt_20260716_nep001` | Made to be read in Nepali | Parent or grandparent in Nepal | Instant Nepali/English language switch |
| 03 | `cpt_20260716_pat001` | The family date keeper | Household calendar keeper | Bikram Sambat Patro + tithi + saved event |
| 04 | `cpt_20260716_kun001` | Built from a real Kundali | Calculation-depth seeker | Computed Kundali chart, Lagna, Rashi, Nakshatra, Dasha |
| 05 | `cpt_20260716_dsh001` | Which life chapter is this? | Adult seeking context | Current Mahadasha/Antardasha prepared report |
| 06 | `cpt_20260716_muh001` | Before the family chooses a time | Household decision maker | Muhurat Finder + supporting Panchang factors |
| 07 | `cpt_20260716_mat001` | A score is not the whole relationship | Couple / engaged adult | Traditional Kundli matching with explained evidence |
| 08 | `cpt_20260716_voc001` | Ask without typing | Older primary user / accessibility installer | Optional voice input with editable transcript |
| 09 | `cpt_20260716_dia001` | One family, two time zones | Diaspora adult child | Trusted-person private Kundli QR handoff |
| 10 | `cpt_20260716_rel001` | A family question needs family context | Parent / family coordinator | Relationship-aware guidance for a saved member |
| 11 | `cpt_20260716_pan001` | Before the day begins | Daily ritual and planning user | Today's Panchang and detailed day timings |
| 12 | `cpt_20260716_rev001` | From a birth detail to a Kundali | New user / adult child helping a parent | Paged birth flow, computation ceremony, Rashi/Nakshatra reveal |

## Claim contract

The exact safe claim for each concept is in `creative-test-matrix.csv`. Production may shorten
that claim, but may not strengthen it. In particular:

- Say **calculate**, **explore**, **compare**, **ask**, **save**, or **traditional guidance**.
- Do not say **guaranteed**, **accurate future**, **will happen**, **perfect match**, **bad fate**,
  or imply a ritual, score, time, or app answer controls an outcome.
- The Dasha treatment may show current boundaries and the next Mahadasha date. It may not show
  or promise the unimplemented future Dasha/transit alert system.
- Muhurat is supportive traditional timing, not a guarantee. It must never delay urgent or
  medically necessary action.
- Kundli matching is context for reflection, not a command to begin or end a relationship.
- Voice recognition depends on device permission and available speech services.
- The QR treatment must say "someone you trust" and must never expose a readable QR payload,
  birth record, account identifier, or real customer data in an ad.
- Moonrise/moonset is approximate in the current Panchang implementation; avoid foregrounding
  it unless the caveat is visible.
- Never imply an AI-generated person is a customer, pandit, testimonial, or real event.

## Production sequence

1. Choose one row from `creative-test-matrix.csv` and freeze its concept, audience role,
   language, safe claim, dominant factor, and proof shots.
2. Copy the matching prompt from `veo-prompts.md` into Veo. Generate 9:16 at 8 seconds. Create
   a new `media_id` for every output, including rejects; upload originals to the Drive `ai_veo`
   folder and record provenance, checksum, and rights status in the media manifest.
3. Record only the shot keys listed for that concept in `app-capture-shot-list.md`. Use the
   repository's `-demoSeed` QA household, record the Git SHA and capture environment, and upload
   source clips to the Drive `source_app_captures` folder.
4. Select one language treatment from `voiceovers.md`. Have Nepali reviewed by a fluent Nepali
   speaker and Hinglish by a fluent Hindi speaker before synthesis. Register the voice model,
   voice identity, settings, and usage rights.
5. Build the timeline exactly once from `edit-recipes.md`. The 8-second Veo file is source
   footage; use/intercut only its strongest 2–4 seconds, state the proposition inside three
   seconds, and show genuine app UI by 2.2–2.8 seconds.
6. Create a new `creative_id` for every language, hook, speaker, CTA, proof, duration, music,
   or caption-timing treatment. Never overwrite a creative in place.
7. Complete `preflight-checklist.md`, export a platform draft, and inspect it on a real phone
   with sound both on and off.
8. Create one `publication_id` per upload. Use aggregate performance data only. Preserve every
   render, publication, null result, and stopped treatment.

## Recommended first production wave

Produce these four before the remaining backlog because together they cover the primary private
sharing promise, the household value that follows it, language accessibility, and low-friction
input:

1. `dia001` — the private Kundli QR handoff, which is the first product promise.
2. `fam001` — family-aware value after a trusted profile is saved.
3. `nep001` — Nepali-language recognition for the documented primary user.
4. `voc001` — an accessibility-oriented interaction proof.

Produce `pat001` next as the first supporting-retention concept: it demonstrates practical,
recurring Patro value after the acquisition promise is understood.

Use one Nepali and one English creative per concept, but treat language versions as separate
creatives. Do not interpret organic reach differences as causal. After a baseline is stable,
the cleanest controlled follow-ups are:

- Same `dia001` edit, privacy-choice hook vs two-time-zones hook, all other elements held constant.
- Same `fam001` edit, Nepali vs English voice/captions, audience and delivery held constant.
- Same `voc001` edit, older-user speaker vs adult-child installer speaker, all other elements
  held constant.

## Publication blockers inherited from the marketing system

- The repository privacy policy and the shipped camera/analytics behavior are not yet aligned.
  Resolve the legal/store disclosure blocker before paid acquisition or privacy claims.
- No app-store listing URL is recorded. Final install CTA and destination QA remain blocked.
- Install attribution is not implemented. UTMs can support click analysis but do not prove an
  individual creative caused an install.
- The app is free. Do not optimize or report profit, payer CAC, ROAS, or revenue at launch.
- Paid horoscope/astrology-ad eligibility for Nepal and India is not confirmed. Keep distribution
  organic or eligibility-gated until current platform/market policy is recorded and approved.
- Apply the platform's current AI-generated-content/AIGC disclosure to every post using a Veo
  scene, even though all product UI is genuine app capture.

These blockers do not prevent generating source scenes, recording synthetic app proof, or
assembling unpublished drafts.

## Product sources used for this pack

This pack was grounded in the current repository contracts: `marketing/GOALS.md`,
`marketing/operations/workflow.md`, `marketing/operations/claims-and-privacy.md`,
`docs/00-VISION.md`, `docs/01-DESIGN-SYSTEM.md`, `docs/04-FEATURES.md`,
`docs/05-ROADMAP.md`, `docs/06-BACKEND-AGENT.md`,
`docs/18-RELATIONSHIPS-FEATURE-HUB-AND-FUTURE-DATES.md`, and
`docs/20-ANDROID-PARITY-FEATURE-REPORTS.md`. No new web claim was introduced by this pack.
