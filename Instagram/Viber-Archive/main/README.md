# Sirish–Utsav collaboration hub

Long-lived private coordination hub for Sirish and Utsav. Jyotish Baje is the first active project; future work must register a project identifier. See [`coordination/README.md`](coordination/README.md) and [`coordination/projects.json`](coordination/projects.json).

Portable Codex architecture, Utsav onboarding, and completion handoff reference: [`docs/codex-architecture-and-utsav-onboarding.md`](docs/codex-architecture-and-utsav-onboarding.md).

Shared Chiefo versioning, acknowledgement, task lifecycle, capability checks, and opt-in audit mode: [`coordination/chiefo/README.md`](coordination/chiefo/README.md).

The low-token four-participant Chiefo chat is documented in
[`docs/chiefo-chat.md`](docs/chiefo-chat.md). The portable
[`chiefo-chat`](skills/chiefo-chat/SKILL.md) skill starts its localhost browser
room and gives both Codexes compact read/send commands.

Hybrid local/cloud Codex automation and the ChatGPT hourly notification monitor are documented in [`docs/codex-hybrid-automation.md`](docs/codex-hybrid-automation.md), with the reusable ChatGPT prompt in [`coordination/chatgpt-github-monitor-prompt.md`](coordination/chatgpt-github-monitor-prompt.md).

## Operating contract

- Keep the repository private and add only verified Sirish and Utsav collaborators.
- GitHub Actions schedules jobs; Nepal times are represented as UTC because GitHub cron has minute granularity.
- Utsav may reschedule or batch work, but records reason, owner, and next deadline.
- Content is draft until posted. Proof is a screenshot under `proof/YYYY-MM-DD/`.
- No secrets, personal analytics, birth data, contact data, or credentials in Git.
- Each Codex executes locally on its own device; GitHub stores coordination state, proof, media metadata, and reports.

## Local validation

```bash
python3 scripts/validate.py
python3 scripts/generate_report.py --date 2026-07-25
```

Google Calendar can be authorized through the current Codex browser sign-in or a future OAuth connector. Apple Calendar, alarms, and other device-local actions are delegated to the Codex that has local device control. GitHub remains the coordination hub, recording requested, action, and proof state; `integrations/` documents these boundaries and read-back expectations.

Generated JSON, SVG, and report packages are committed under `content/generated/` so they are accessible from the private repository on a phone. A future retention policy should prune old packages deliberately (for example, after an agreed number of days); pruning must be documented and reviewed before automation is added.

Daily project reports are committed under `reports/daily/YYYY-MM-DD.json`; weekly reports remain project-scoped in their generated package area. Reports identify assets, inventory, Utsav handoffs, proof, schedule/calendar actions, blockers, and deviations.
