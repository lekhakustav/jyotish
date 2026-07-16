# Creative production workflow

## 1. Open a campaign

Create a campaign row and a folder under `creative/campaigns/`. State the market, audience
role, job to be done, promise, shipped proof feature, primary metric, budget, and owner.

## 2. Pre-register the learning question

Write the hypothesis before generating assets. Pick one dominant factor to vary: opening
emotion, speaker, language, proof feature, voice, caption style, or CTA. Do not change all of
them and call the result a test.

## 3. Generate the scene

- Use a prompt from the campaign pack.
- Request 9:16, 8 seconds unless the recipe explicitly permits 12 seconds.
- Generate clean picture without text, logos, UI, captions, or spoken dialogue unless the
  prompt explicitly needs lip movement. Text and product proof are added in the edit.
- Create a new `media_id` for every render, including rejected renders.
- Upload the original output to Drive and record its checksum and model provenance.

## 4. Capture app proof

Record the exact shipped feature named in the concept. Record the app Git SHA, platform,
device, locale, and capture date. Remove real names, birth data, messages, notifications, and
account identifiers. Use only designated synthetic marketing profiles.

## 5. Assemble the Reel/TikTok

Follow the edit recipe's timeline. The default structure is:

| Time | Job |
| ---: | --- |
| 0.0–1.2s | visual and spoken hook; understandable with sound off |
| 1.2–6.5s | human tension or desired moment from the generated scene |
| 6.5–13.5s | hard cut to app proof; show the promised action, not a generic home screen |
| 13.5–17.0s | result/payoff, simple CTA, app name |

Use burned-in captions within platform-safe zones. Keep one visual idea per beat and one CTA.
Music supports the emotional temperature but must not cover speech. Record all licensed inputs.

## 6. Quality gate

- The first frame makes sense without context.
- The promise is visible in current app footage.
- Nepali text is read by a fluent reviewer before publication.
- No fabricated phone screen, impossible feature, fear claim, guaranteed outcome, or sensitive
  personal data appears.
- Voice, music, stock, and generated-media rights are recorded.
- `creative_id`, `publication_id`, UTMs, destination, and app store link are correct.
- Captions, audio, crop, and safe zones are checked in an actual draft upload.

## 7. Publish and observe

One upload equals one `publication_id`, even when the same creative is reposted. Capture a
technical QA snapshot at two hours, ingest daily platform data, and avoid declaring a winner
before the pre-registered stopping rule.

## 8. Decide and preserve

Use only `scale`, `iterate`, `hold`, `stop`, or `inconclusive`. Commit the analysis and decision.
Never delete the losing creative, prompt, render manifest, or raw aggregate export.
