import json
import sys
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors = []
registry = json.loads((ROOT / 'coordination/projects.json').read_text())
chiefo_version = (ROOT / 'coordination/chiefo/VERSION').read_text().strip()
chiefo_contract = ROOT / 'docs/chiefo-shared-context-contract.md'
chiefo_change_schema = json.loads((ROOT / 'coordination/chiefo/change.schema.json').read_text())
chiefo_readback_schema = json.loads((ROOT / 'coordination/chiefo/readback.schema.json').read_text())
if not any(project.get('project_id') == 'chiefo' and project.get('status') == 'active' for project in registry.get('projects', [])):
    errors.append('project registry must contain active chiefo')
if not chiefo_contract.is_file():
    errors.append('missing Chiefo shared-context contract')
else:
    contract_text = chiefo_contract.read_text()
    contract_lower = contract_text.lower()
    for term in ('family-office ledgers', 'raw ledger', 'asynchronous', 'readback', 'github'):
        if term not in contract_lower:
            errors.append(f'Chiefo contract missing {term}')
if chiefo_change_schema.get('properties', {}).get('project_id', {}).get('const') != 'chiefo':
    errors.append('Chiefo change schema must be scoped to chiefo')
if chiefo_readback_schema.get('properties', {}).get('project_id', {}).get('const') != 'chiefo':
    errors.append('Chiefo readback schema must be scoped to chiefo')
integration_status = json.loads((ROOT / 'coordination/integration-status.json').read_text())
briefing_schedule = json.loads((ROOT / 'coordination/briefing-schedule.json').read_text())
if briefing_schedule.get('timezone') != 'Asia/Kathmandu' or briefing_schedule.get('owner') != 'Sirish' or briefing_schedule.get('visibility') != 'private':
    errors.append('briefing schedule must be private, owned by Sirish, and use Asia/Kathmandu')
expected_briefings = {
    'Morning Briefing': ('2026-07-26', '07:00', '07:30', 'q4g60chj5blesborvv3jfu2v64'),
    'Evening Briefing': ('2026-07-25', '20:30', '20:45', '1slq0n241d1bc1mdc05gkk95ek')
}
for event in briefing_schedule.get('events', []):
    expected = expected_briefings.get(event.get('name'))
    if expected and tuple(event.get(key) for key in ('start_date', 'start_time', 'end_time', 'event_id')) != expected:
        errors.append(f"briefing schedule mismatch for {event.get('name')}")
if {event.get('name') for event in briefing_schedule.get('events', [])} != set(expected_briefings):
    errors.append('briefing schedule must include Morning Briefing and Evening Briefing')
for integration_name in ('google_calendar', 'apple_calendar', 'alarms'):
    integration = integration_status.get('integrations', {}).get(integration_name, {})
    for key in ('status', 'owner', 'last_verified', 'last_action', 'proof_reference'):
        if key not in integration:
            errors.append(f'integration status missing {integration_name}.{key}')
if integration_status.get('integrations', {}).get('google_calendar', {}).get('token_persisted') is not False:
    errors.append('Google Calendar status must explicitly say token_persisted false')
if 'credential' in json.dumps(integration_status).lower() or 'secret' in json.dumps(integration_status).lower():
    errors.append('integration status must remain secret-free')
projects = registry.get('projects', [])
if not any(project.get('project_id') == 'jyotish-baje' and project.get('status') == 'active' for project in projects):
    errors.append('project registry must contain active jyotish-baje')
if 'project_id' not in (ROOT / 'coordination/README.md').read_text():
    errors.append('coordination contract must require explicit project_id')
if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', chiefo_version):
    errors.append('Lean Shared Chiefo VERSION must be semantic version MAJOR.MINOR.PATCH')
for path in ('coordination/chiefo/README.md', 'coordination/chiefo/task.schema.json', 'coordination/chiefo/capabilities.example.json', 'coordination/chiefo/tasks/README.md', 'scripts/chiefo_doctor.py', 'scripts/validate_chiefo_task.py', 'scripts/chiefo_task.py', 'scripts/chiefo_issue_loop.py', '.github/ISSUE_TEMPLATE/chiefo-team-task.md', '.github/workflows/chiefo-reminder-loop.yml'):
    if not (ROOT / path).is_file():
        errors.append(f'missing Lean Shared Chiefo contract file: {path}')
for task_path in (ROOT / 'coordination/chiefo/tasks').glob('*.json'):
    command = [sys.executable, str(ROOT / 'scripts/validate_chiefo_task.py'), '--file', str(task_path)]
    if subprocess.run(command, capture_output=True, text=True).returncode:
        errors.append(f'invalid durable Chiefo task record: {task_path.name}')
schema = json.loads((ROOT / 'content/schema.json').read_text())
if schema['properties']['slides'].get('minItems') != 12:
    errors.append('schema must require 12 slides')
template = (ROOT / 'content/template.md').read_text()
for term in ('Highest', 'Lowest', 'Average', 'Swipe for more', 'मेष', 'मीन'):
    if term not in template:
        errors.append(f'template missing {term}')
inventory = json.loads((ROOT / 'inventory/temple-images.json').read_text())
for item in inventory.get('images', []):
    for key in ('media_id', 'filename', 'sha256', 'created_at', 'rights_status', 'source', 'remaining_uses'):
        if key not in item:
            errors.append(f'inventory entry missing {key}')
for workflow in (ROOT / '.github/workflows').glob('*.yml'):
    text = workflow.read_text()
    if workflow.name == 'chiefo-event-bridge.yml':
        if 'issue_comment:' not in text or 'push:' not in text:
            errors.append('chiefo-event-bridge.yml: must trigger on issue_comment and push')
        for permission in ('contents: read', 'pull-requests: read'):
            if permission not in text:
                errors.append(f'chiefo-event-bridge.yml: missing {permission}')
        if 'issues: read' not in text and 'issues: write' not in text:
            errors.append('chiefo-event-bridge.yml: missing issues permission')
        for term in ('scripts/record_chiefo_event.py', 'actions/upload-artifact@v4'):
            if term not in text:
                errors.append(f'chiefo-event-bridge.yml: missing {term}')
        continue
    if 'schedule:' not in text or 'cron:' not in text:
        errors.append(f'workflow lacks schedule: {workflow.name}')
    if workflow.name in ('daily-content.yml', 'weekly-content.yml', 'inventory-and-handoff.yml'):
        required_contents = 'contents: write' if workflow.name in ('daily-content.yml', 'weekly-content.yml') else 'contents: read'
        if required_contents not in text or 'issues: write' not in text:
            errors.append(f'{workflow.name}: requires {required_contents} and issues: write')
        if 'gh issue create' not in text or '--assignee lekhakustav' not in text:
            if 'gh issue edit "$ISSUE_NUMBER" --add-assignee lekhakustav' not in text:
                errors.append(f'{workflow.name}: missing assignment attempt')
        if 'gh issue list --state open --json number,title --limit 100 | jq -r --arg title' not in text or 'select(.title == $title)' not in text:
            errors.append(f'{workflow.name}: missing external jq exact-title idempotency lookup')
        if 'Handoff key:' not in text or 'body-file handoff-body.md' not in text:
            errors.append(f'{workflow.name}: missing visible handoff key/body-file contract')
        required_paths = ('content/generated/', 'reports/daily/', 'proof/') if workflow.name in ('daily-content.yml', 'weekly-content.yml') else ('inventory/temple-images.json', 'proof/')
        for required_path in required_paths:
            if required_path not in text:
                errors.append(f'{workflow.name}: missing handoff path {required_path}')
        if 'without assignment' not in text or 'Assignment pending' not in text:
            errors.append(f'{workflow.name}: missing pending-invitation handling')
    if workflow.name in ('daily-content.yml', 'weekly-content.yml') and ('git add content/generated/' not in text or 'git push' not in text):
        errors.append(f'{workflow.name}: missing generated-package commit/push contract')
    if workflow.name == 'inventory-and-handoff.yml' and 'contents: write' in text:
        errors.append('inventory-and-handoff.yml: must remain contents read-only')
generator = (ROOT / 'scripts/generate_content.py').read_text()
if 'deterministic-template' not in generator:
    errors.append('generator must provide deterministic template path')
# Regression boundary: reports are JSON too, but only generated package names
# matching *-rashifal-*.json are package inputs for slide validation.
for package_path in (ROOT / 'content/generated').glob('*-rashifal-*.json'):
    package = json.loads(package_path.read_text())
    if len(package.get('slides', [])) != 12:
        errors.append(f'{package_path.name}: must contain exactly 12 slides')
    if {slide.get('rashi') for slide in package.get('slides', [])} != set(['मेष', 'वृषभ', 'मिथुन', 'कर्कट', 'सिंह', 'कन्या', 'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुम्भ', 'मीन']):
        errors.append(f'{package_path.name}: required Rashi names missing')
    for slide in package.get('slides', []):
        if len(slide.get('sentences', [])) > 3 or any(not sentence.strip() for sentence in slide.get('sentences', [])):
            errors.append(f'{package_path.name}: sentence limit violated for {slide.get("rashi")}')
for report_path in (ROOT / 'reports/daily').glob('*.json'):
    report = json.loads(report_path.read_text())
    for key in ('project_id', 'date', 'content', 'temple_inventory', 'handoff', 'blockers', 'deviations'):
        if key not in report:
            errors.append(f'{report_path.name}: daily report missing {key}')
    if 'integrations' not in report:
        errors.append(f'{report_path.name}: daily report missing integration readback')
if errors:
    print('FAIL\n- ' + '\n- '.join(errors))
    sys.exit(1)
print('PASS: schema, template, inventory, and scheduled workflows validated')
