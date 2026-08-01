import argparse, json, os
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def build_report(day):
    inventory = json.loads((ROOT / 'inventory/temple-images.json').read_text())
    integration_status = json.loads((ROOT / 'coordination/integration-status.json').read_text())
    briefing_schedule = json.loads((ROOT / 'coordination/briefing-schedule.json').read_text())
    threshold = int(os.getenv('TEMPLE_ONE_DAY_THRESHOLD', inventory.get('threshold_days', 1)))
    remaining = sum(int(x.get('remaining_uses', 0)) for x in inventory.get('images', []))
    return {
        'project_id': 'jyotish-baje', 'date': day, 'status': 'scaffold',
        'content': {'daily': f'content/generated/daily-rashifal-{day}.json', 'weekly': f'content/generated/weekly-rashifal-{day}.json', 'proof': 'pending'},
        'temple_inventory': {'remaining_uses': remaining, 'threshold': threshold, 'action_due': remaining <= threshold},
        'model': {'strategy': 'deterministic-first', 'provider': os.getenv('CONTENT_MODEL_PROVIDER') or 'unconfigured', 'model': os.getenv('CONTENT_MODEL') or 'unconfigured'},
        'integrations': integration_status,
        'handoff': {'project_id': 'jyotish-baje', 'owner': 'Utsav', 'proof_path': f'proof/{day}/', 'deviations': []},
        'schedule_calendar_actions': briefing_schedule, 'blockers': [], 'deviations': []
    }

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--date', default=date.today().isoformat())
    args = parser.parse_args()
    print(json.dumps(build_report(args.date), indent=2, ensure_ascii=False))
