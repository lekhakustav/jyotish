import argparse
import json
import os
import re
from datetime import date
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RASHIS = ['मेष', 'वृषभ', 'मिथुन', 'कर्कट', 'सिंह', 'कन्या', 'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुम्भ', 'मीन']

def slide_copy(rashi, edition):
    return [
        f'{rashi} राशि का लागि {edition} ऊर्जा आत्मचिन्तन र स्पष्ट निर्णयलाई सहयोग गर्छ।',
        'ग्रहहरूको संकेतलाई शान्त रूपमा हेर्नुहोस् र आफ्नो कर्ममा ध्यान दिनुहोस्।',
        'सम्बन्ध, अध्ययन वा काममा एउटा सानो सकारात्मक कदम रोज्नुहोस्।',
    ]

def sentence_count(text):
    return len([part for part in re.split(r'[.!?।]+', text) if part.strip()])

def build_package(edition, day):
    slides = [{'rashi': rashi, 'stars': 3, 'sentences': slide_copy(rashi, edition)} for rashi in RASHIS]
    package = {
        'edition': edition,
        'date': day,
        'summary': {'highest': {'rashi': 'सिंह', 'stars': 4}, 'lowest': {'rashi': 'मकर', 'stars': 2}, 'average': 3.0},
        'slides': slides,
        'caption': f'{edition.title()} Rashifal — {day}. ग्रह र कर्मका संकेतलाई आत्मचिन्तनका लागि प्रयोग गर्नुहोस्; यो सामान्य मनोरञ्जनात्मक guidance हो, निश्चित भविष्यवाणी होइन।',
        'generation': {'strategy': 'deterministic-template', 'provider': os.getenv('CONTENT_MODEL_PROVIDER') or 'unconfigured', 'model': os.getenv('CONTENT_MODEL') or 'unconfigured'}
    }
    if edition == 'daily':
        package['posting'] = {
            'platform': 'instagram',
            'slide_count': 14,
            'upload_device': 'phone',
            'desktop_limit_reason': 'The desktop web workflow supports at most 10 photos for this post.'
        }
    return package

def write_svg(path, title, lines):
    text = ''.join(f'<text x="60" y="{150 + i * 58}" class="body">{escape(line)}</text>' for i, line in enumerate(lines))
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1080" viewBox="0 0 1080 1080"><rect width="1080" height="1080" fill="#fffaf0"/><text x="60" y="90" class="title">{escape(title)}</text>{text}<style>.title{{font:700 42px sans-serif;fill:#351b12}}.body{{font:400 28px sans-serif;fill:#4d3025}}</style></svg>'''
    path.write_text(svg)

def generate(edition, day, output):
    output.mkdir(parents=True, exist_ok=True)
    package = build_package(edition, day)
    package_path = output / f'{edition}-rashifal-{day}.json'
    package_path.write_text(json.dumps(package, ensure_ascii=False, indent=2) + '\n')
    if edition == 'daily':
        write_svg(output / f'{edition}-cover-{day}.svg', f'{edition.title()} Rashifal', [
            '14-slide Instagram carousel',
            'Upload from phone',
            f'{day} · swipe for all signs'
        ])
    write_svg(output / f'{edition}-summary-{day}.svg', f'{edition.title()} Rashifal', [
        f"Highest: {package['summary']['highest']['rashi']} ({package['summary']['highest']['stars']} stars)",
        f"Lowest: {package['summary']['lowest']['rashi']} ({package['summary']['lowest']['stars']} stars)",
        f"Average: {package['summary']['average']} stars", 'Swipe for more.'
    ])
    for slide in package['slides']:
        write_svg(output / f"{edition}-{RASHIS.index(slide['rashi']) + 1:02d}-{day}.svg", slide['rashi'], slide['sentences'])
    return package_path

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--edition', choices=('daily', 'weekly'), required=True)
    parser.add_argument('--date', default=date.today().isoformat())
    parser.add_argument('--output', default=str(ROOT / 'content/generated'))
    args = parser.parse_args()
    print(generate(args.edition, args.date, Path(args.output)))
