# Sirish Codex architecture and Utsav onboarding

This is the portable operating reference for the private Sirish–Utsav collaboration hub. It describes coordination boundaries and evidence rules; it does not grant access, send notifications, authorize device actions, or prove completion by itself.

## Architecture

```text
Sirish: priorities, approvals, and review
  |
  v
Sirish Codex: local execution in the relevant project checkout
  |
  +--> GitHub repository: shared coordination state, reports, issues, artifacts, and proof pointers
  |
  +--> Utsav Codex: local execution on Utsav's device, including authorized posting and device integrations
```

The repository is the shared, private coordination hub. Each Codex runs locally on its own device. A GitHub issue is an assignment and audit pointer, not proof that local work happened. Completion requires the referenced artifact and independent readback evidence to exist.

The active project is `jyotish-baje`. Future projects must first register an explicit `project_id` in `coordination/projects.json`. Keep project-specific assets under the project namespace when practical.

## Operating rules

- Keep the repository private and add only verified collaborators.
- Keep secrets, credentials, tokens, personal analytics, contact data, and birth data out of Git.
- Treat generated content as draft until posting proof exists under `proof/YYYY-MM-DD/`.
- Every handoff, report, generated package, proof directory, and deviation names its `project_id`.
- Preserve exact project/date context and record blockers, reschedules, deviations, and autonomous batching decisions.
- Use artifact paths, checksums, screenshots, and readable readback evidence; a prompt or issue alone is not evidence.
- GitHub Actions schedules work in UTC. Human deadlines in this hub are expressed in Nepal time (`Asia/Kathmandu`); confirm the effective local date around midnight.
- Google Calendar, Apple Calendar, and alarms have separate device/authentication boundaries. A status record is not completion evidence unless its proof reference points to a readable artifact or screenshot.
- Daily Instagram carousels use 14 slides and must be uploaded from the phone; the desktop web workflow cannot publish the required carousel.
- Follow [`utsav-communication-protocol.md`](utsav-communication-protocol.md) for concise status, evidence, approval, privacy, and escalation rules.

## Utsav download and onboarding

The repository is private, so Utsav must already have access to the GitHub repository. Do not put a password, token, or credential in these commands or in Git.

```bash
git clone https://github.com/Sirish24/sirish-utsav-collaboration.git
cd sirish-utsav-collaboration
python3 --version
python3 scripts/validate.py
python3 scripts/generate_report.py --date "$(date -u +%F)" | python3 -m json.tool >/dev/null
```

Then:

1. Read this document, the root `README.md`, and `coordination/README.md`.
2. Inspect `coordination/projects.json` and open GitHub issues before starting work.
3. Preserve the assigned `project_id` and date in every report, handoff, artifact, and proof path.
4. Use local skills and device controls only when available and authorized. GitHub cannot set a phone alarm, grant iOS permissions, or prove a device-side action.
5. Commit the requested artifacts and proof. Keep proof under `proof/YYYY-MM-DD/`; posting proof uses `platform-posted-at.png` plus a README with platform, timestamp, safe post URL, and deviations.
6. Create and validate a completion record using `coordination/handoff.schema.json` and `scripts/validate_handoff.py`.

## Handoff and notification contract

Automated workflows create idempotent GitHub issues with a visible handoff key such as `daily:2026-07-25`, the requested artifact paths, the proof path, and an assignment attempt. The issue should remain usable if collaborator assignment is unavailable.

A completion record is a repository-relative JSON file with these fields:

```json
{
  "handoff_key": "daily:2026-07-25",
  "project_id": "jyotish-baje",
  "owner": "Utsav",
  "status": "complete",
  "completed_at": "2026-07-25T18:10:00Z",
  "artifacts": ["content/generated/daily-rashifal-2026-07-25.json"],
  "proof": ["proof/2026-07-25/platform-posted-at.png"],
  "notification": {
    "channel": "github_issue",
    "handoff_key": "daily:2026-07-25",
    "issue_reference": "https://github.com/Sirish24/sirish-utsav-collaboration/issues/123",
    "attempted": true,
    "assignment_status": "pending",
    "notes": "GitHub notification is best effort; it is not a guaranteed phone notification."
  },
  "blockers": [],
  "deviations": []
}
```

`complete` is valid only when artifact and proof paths are readable and the notification attempt is recorded. `pending` means work remains. `blocked` requires a non-empty blocker explanation. A GitHub issue, assignment, status JSON, or notification does not substitute for the artifact or independent proof. The checked-in example is synthetic and must not be copied as evidence of a real Utsav post or device action.

Validate a record locally:

```bash
python3 scripts/validate_handoff.py --file path/to/handoff.json
```

## Scope boundary

This document does not change GitHub permissions, issue assignment, workflow schedules, OAuth, Calendar, alarms, posting accounts, or device state. Those actions require the appropriate authenticated Codex and explicit evidence/readback.
