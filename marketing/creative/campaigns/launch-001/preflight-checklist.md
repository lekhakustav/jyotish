# Creative preflight and publication gate

Copy this checklist into the production ticket for each `creative_id`. Every box requires a
named reviewer and date. `N/A` requires a written reason; silence is not approval.

## Stop conditions

Do not publish if any of these is true:

- The promised product action is not visible in real current-build app footage by about second 3.
- Any real person, birth data, QR payload, notification, contact, account, device identifier,
  advertising identifier, chat text, or user-level analytics appears.
- The edit claims a guaranteed outcome, fear/danger, inevitability, caste verdict, medical/legal/
  financial certainty, or pressure to purchase a remedy.
- The video implies Hindi UI, an automatic family-data sync, an automatic reminder, spoken
  replies after every typed question, or future Dasha/transit alerts.
- The AI-generated person is described or presented as a customer, pandit, testimonial, or real
  event, or the platform AIGC disclosure cannot be applied.
- App-store destination, disclosure, rights, or platform eligibility is unknown.

Paid horoscope/astrology-ad eligibility for Nepal and India is not confirmed in this pack. Keep
launch distribution organic or eligibility-gated until a reviewer checks the current platform,
market, targeting, and ad-product policies and records the source URL, access date, and conclusion
in `marketing/research/sources.csv`. Policy approval is platform- and market-specific.

## 1. Identity, lineage, and experiment

- [ ] Campaign ID is `cmp_20260716_launch`.
- [ ] `concept_id`, `prompt_id`, audience role, safe claim, proof shot keys, and dominant factor
      match one row in `creative-test-matrix.csv`.
- [ ] Every Veo render, reject, app capture, voice track, music/stock input, edit project, master,
      and platform export has a unique `media_id` and Drive file ID.
- [ ] Media manifest contains checksum, creator/model, creation date, prompt/version, provenance,
      rights status, and Drive location for every used input.
- [ ] The current treatment has a unique `creative_id`; any changed hook, speaker, language,
      caption timing, CTA, music, app proof, crop, or duration creates a new one.
- [ ] `supersedes_creative_id` is recorded when this is an iteration.
- [ ] If the result will be called causal, the experiment was pre-registered and varies one
      dominant factor. Otherwise the publication is labeled observational.
- [ ] One upload on one platform has one unique `publication_id` and approved UTM/destination.
- [ ] `npm run marketing:validate` passes after registry/experiment rows are added.

## 2. Claim and product proof

- [ ] Spoken and on-screen proposition is understandable inside the first 3 seconds.
- [ ] Genuine app UI appears by 2.2–2.8 seconds; the full 8-second Veo source does not run first.
- [ ] The finished ad uses no more than 2–4 seconds total of generated human footage unless a
      documented test intentionally varies this factor.
- [ ] Every stated feature is shipped in the recorded Git SHA and matches the current platform.
- [ ] The exact tap, action, and result are shown—not a generic landing screen.
- [ ] Copy is equal to or weaker than the safe claim in `creative-test-matrix.csv`.
- [ ] Astrology is framed as calculation plus traditional interpretation, not scientific proof
      or deterministic prediction.
- [ ] Kundali/Dasha treatment shows birth-time uncertainty where material and does not depict
      future alert scheduling.
- [ ] Muhurat treatment shows evidence/reasons with the time and says it is not a guarantee.
- [ ] Matching treatment shows evidence beyond a score and says it is not a relationship verdict.
- [ ] Voice treatment shows the editable transcript and does not imply universal recognition,
      continuous listening, or automatic spoken replies.
- [ ] QR treatment says `someone you trust`, masks every QR frame, and does not imply account sync.
- [ ] Panchang treatment records location; if moonrise/set is shown, `approximate` is visible.
- [ ] No medical procedure, urgent action, purchase, relationship, pregnancy, exam, job, visa,
      money, health, or safety outcome is promised or directed by astrology.

## 3. Synthetic capture and privacy

- [ ] App capture uses only `demoSeed-v1` or the documented manual Sita synthetic onboarding input.
- [ ] Git SHA, app build, platform, OS, device, locale, time zone, date, network mode, fixture, and
      capture operator are recorded.
- [ ] No real name, birth date/time/place, family relation, event, message, notification, email,
      account token, clipboard item, keyboard suggestion, analytics ID, or advertising ID appears.
- [ ] QR source uses only the synthetic fixture; final delivery contains no decodable QR frame or
      encoded payload.
- [ ] Voice and QR capability proof was captured on physical hardware; simulator-only proof is
      labeled internal and not used for the public capability claim.
- [ ] Status bar, notification center, camera roll, keyboard, and share sheet are clean.
- [ ] Capture files remain in Drive; no video/audio/editor binary is staged in Git.

## 4. Veo scene and AI disclosure

- [ ] The selected render follows its prompt: 8 seconds, vertical 9:16, culturally specific,
      contemporary, and free of fear or testimonial behavior.
- [ ] No malformed anatomy, face drift, temporal jump, illegible invented writing, generated
      phone UI, fake chart, logo, brand, watermark, notification, or mystical/cosmic cliché appears.
- [ ] Generated phone screens remain completely hidden; all product screens are real captures.
- [ ] Generated scene audio is muted unless explicitly rights-cleared and reviewed; no generated
      dialogue is represented as a real person speaking.
- [ ] The edit/project metadata marks the asset as AI-generated.
- [ ] The platform's current AI-generated-content/AIGC label or disclosure is enabled at upload.
- [ ] Caption/copy does not imply the generated people are customers or that the scene happened.

## 5. Voice, language, captions, and accessibility

- [ ] Voice model/actor, voice ID, consent or license basis, settings, and output `media_id` are
      recorded; no public figure, pandit, creator, or customer is imitated.
- [ ] Nepali script and speech were approved by a fluent Nepali reviewer.
- [ ] Hinglish script and speech were approved by a fluent Hindi reviewer; proof remains English
      or Nepali and makes no Hindi-UI claim.
- [ ] Pronunciation of Jyotish, Baje, Patro, Panchang, Kundali, Dasha, Muhurat, Rashi, Nakshatra,
      and Nepali names is correct.
- [ ] Burned-in captions match the final audio word for word and work with sound off.
- [ ] Hook/captions/disclosure/CTA stay outside top 14%, bottom 35%, and side 6%; critical app
      evidence is reframed into the same conservative center area.
- [ ] Text is no more than two lines, remains readable on a small phone, and does not flash too fast.
- [ ] Required disclosure remains readable for at least two seconds and is not hidden by controls.

## 6. Edit, sound, brand, and rights

- [ ] Export is 1080 × 1920, 9:16, with clean frame pacing, no black frames, and no editor chrome.
- [ ] App proof is not zoomed so far that labels pixelate or context disappears.
- [ ] Editorial highlights point to real values and do not redraw, replace, or alter them.
- [ ] Approved current icon/wordmark is used; Veo did not generate the brand or app UI.
- [ ] One CTA appears. Until the verified store URL exists it is `Meet Jyotish Baje`, not a false
      install destination.
- [ ] Voice is intelligible on phone speakers; music and effects never mask it.
- [ ] No ominous drone, heartbeat, jump scare, magical whoosh, or manipulative countdown is used.
- [ ] Music, stock, font, voice, generated asset, and brand rights are documented for both organic
      and paid use in the target countries.
- [ ] No copyrighted song or unlicensed platform-trending audio exists in the master.

## 7. Platform draft and destination

- [ ] Current Instagram/TikTok ad, AIGC, astrology/horoscope, targeting, landing-page, and local
      market rules were checked on publication day; sources and caveats were logged.
- [ ] If eligibility is uncertain, the post stays organic and no paid boost is scheduled.
- [ ] Draft upload was viewed once with sound on and once muted on a real phone.
- [ ] Platform crop and overlays do not hide hook, disclosure, evidence, captions, or CTA.
- [ ] Cover frame is truthful, legible, and contains no generated app screen or exaggerated claim.
- [ ] Caption, hashtags, alt text, AIGC disclosure, destination, UTM, and app-store link are approved.
- [ ] Destination opens on the intended device/market and the app listing matches the ad language.
- [ ] Comments/community response plan forbids personalized predictions, fear escalation, medical/
      legal/financial advice, and requests for public birth details.

## 8. Measurement readiness

- [ ] Primary/secondary metrics match `creative-test-matrix.csv` and KPI definitions.
- [ ] Baseline, observation window, stopping rule, minimum spend/sample if applicable, and decision
      vocabulary (`scale`, `iterate`, `hold`, `stop`, `inconclusive`) are set before launch.
- [ ] Two-hour technical QA snapshot and daily aggregate export owner are assigned.
- [ ] No user-level platform or product export will enter Git or the marketing Drive folders.
- [ ] Click/install conclusions are labeled directional until attribution is implemented and
      legally reviewed.
- [ ] No revenue, profit, ROAS, or payer-CAC claim is planned while the app is free.

## Sign-off

| Gate | Reviewer | Date/time UTC | Decision / notes |
| --- | --- | --- | --- |
| Product + claim |  |  |  |
| Privacy + legal |  |  |  |
| Nepali/Hinglish language |  |  |  |
| Creative + brand |  |  |  |
| Platform eligibility + AIGC |  |  |  |
| Destination + measurement |  |  |  |
