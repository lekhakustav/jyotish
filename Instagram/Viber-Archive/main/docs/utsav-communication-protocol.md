# Utsav Codex communication and posting protocol

This protocol applies to Utsav-owned work coordinated through the private
Sirish–Utsav repository.

## Every readback

Keep updates short and use this order:

1. `project_id` and handoff key.
2. Status: `complete`, `partial`, `blocked`, or `unknown`.
3. What changed since the previous update.
4. Exact repository-relative artifact and proof paths.
5. Commit SHA and checks run, with pass/fail results.
6. Blocker, approval needed, or next action and deadline in `Asia/Kathmandu`.

If nothing changed, say: `No change; still <status>.` Do not repeat the whole
history.

## Evidence rules

- An issue, assignment, prompt, or verbal claim is not completion proof.
- Do not call work complete until the referenced artifact and readable proof
  exist and the handoff validator passes.
- Separate local-device facts from GitHub or cloud facts. GitHub cannot prove
  phone state, local credentials, calendar actions, alarms, or an upload that
  has no committed readback.
- Report the exact blocker instead of guessing or silently retrying.
- Utsav-owned implementation requires explicit approval in the relevant issue
  before changing the local runtime or repository behavior.

## Privacy and safety

- Never commit credentials, tokens, private chats, prompts, browser/session
  data, personal analytics, contact data, or private device state.
- Use redacted paths, aggregate metadata, safe URLs, and hashes.
- Do not initialize, migrate, or change the family-office runtime until its
  state-root, schema, and bootstrap method are explicitly approved.

## Daily Instagram posting

- The daily post is a 14-slide carousel.
- A carousel handoff is uploadable only when its dated provenance manifest
  passes the listed verifier command. Do not substitute a locally newer or
  older brand directory: the manifest's source SHA, hashes, and ordered paths
  are the only approved package.
- Before upload acknowledgement, record the manifest path, the exact 40-character
  source SHA, and `PASS` from the verifier. A generic carousel handoff without
  this acknowledgement is rejected.
- Upload the carousel from the phone. The desktop web workflow is limited to
  10 photos and cannot publish the required 14-slide post.
- Before reporting completion, commit readable proof under
  `proof/YYYY-MM-DD/`, including the posting screenshot and a short README
  with the platform, Kathmandu timestamp, safe post URL, and deviations.
- If the post was uploaded but proof cannot yet be committed, report
  `partial` and say that the upload is user-reported but not repository-verified.
- For 2026-07-26 only, Sirish waived screenshot proof for the TikTok and Instagram
  posts. Starting 2026-07-27, every posting readback must include the screenshot
  under `proof/YYYY-MM-DD/` before it is reported complete.
- For the next daily handoff, use the same 14-slide phone workflow and report
  only what changed.

## Where to communicate

- Use the daily GitHub handoff issue for daily content work.
- Use issue #6 for onboarding, runtime compatibility, and approval questions.
- Use `coordination/notifications/YYYY-MM-DD/` for secret-free user-facing
  notification records.
- Keep one concise status readback in the relevant issue after each meaningful
  change.
