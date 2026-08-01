# Codex notification outbox

This directory contains secret-free, repository-relative notification records emitted by local or cloud Codex runs.

## File layout

Use one file per event:

`coordination/notifications/YYYY-MM-DD/<event_id>.json`

The `event_id` must be stable across retries. Do not overwrite a different event with the same filename.

## Record shape

```json
{
  "event_id": "jyotish-baje-daily-2026-07-25-build-failed",
  "project_id": "jyotish-baje",
  "status": "open",
  "created_at": "2026-07-25T12:00:00Z",
  "severity": "warning",
  "title": "Daily generation needs attention",
  "summary": "The deterministic validation step failed.",
  "source": "github_actions",
  "requires_action": true,
  "owner": "Sirish",
  "artifact_paths": ["reports/daily/2026-07-25.json"],
  "proof_paths": [],
  "urls": ["https://github.com/Sirish24/sirish-utsav-collaboration/actions"]
}
```

Required fields are `event_id`, `project_id`, `status`, `created_at`, `severity`, `title`, `summary`, `source`, `requires_action`, and `owner`. `artifact_paths`, `proof_paths`, and `urls` are arrays and may be empty.

Allowed statuses are `open`, `acknowledged`, `resolved`, and `blocked`. The hourly sweep surfaces `open` and `blocked` records. Keep a record in Git history; update its status instead of deleting it.

## Rules

- Never include secrets, credentials, tokens, private event contents, personal analytics, birth data, or device-local secrets.
- Paths must be repository-relative and must not contain parent traversal.
- A record is an observation/notification, not completion proof.
- Local Codex writes the record and pushes it when authorized. If it cannot push, it reports the sync blocker.
- Utsav-owned implementation requires explicit approval in the relevant GitHub issue before his Codex acts.
