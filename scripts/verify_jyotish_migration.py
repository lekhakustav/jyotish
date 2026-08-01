#!/usr/bin/env python3
"""Build or verify the immutable Jyotish migration file manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "Instagram" / "Viber-Archive" / "migration-manifest.json"
SOURCE_MAIN_SHA = "118168f393b7ddc884c8a670c0a2d2179e77c53d"
SOURCE_FEATURE_SHA = "da179dffb8d574691f457994faabb6c1ac239337"
MIGRATION_ROOTS = (
    "assets/temples",
    "content",
    "inventory",
    "proof",
    "reports",
    "Instagram",
    "social-media-account-setup",
)
MIGRATION_FILES = (
    ".github/workflows/social-carousel-verify.yml",
    "docs/21-SOCIAL-CAROUSEL-WORKFLOW.md",
    "scripts/generate_content.py",
    "scripts/render_daily_carousel_14.cjs",
    "scripts/render_daily_carousel_14.js",
    "scripts/render_daily_carousel_platforms.cjs",
    "scripts/render_instagram_carousel_14.cjs",
    "scripts/render_instagram_carousel_14.js",
    "scripts/render_instagram_carousel_14.legacy.cjs",
    "scripts/render_instagram_carousel_14.legacy.js",
    "scripts/render_weekly_mantra_carousel.cjs",
    "scripts/validate_social_carousel.py",
    "scripts/validate_handoff.py",
    "scripts/verify_carousel_provenance.py",
    "scripts/verify_jyotish_migration.py",
    "tests/test_carousel_provenance.py",
)


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def migration_files() -> list[Path]:
    files: set[Path] = set()
    for item in MIGRATION_ROOTS:
        path = ROOT / item
        if path.is_dir():
            files.update(candidate for candidate in path.rglob("*") if candidate.is_file())
    for item in MIGRATION_FILES:
        path = ROOT / item
        if path.is_file():
            files.add(path)
    files.discard(MANIFEST)
    return sorted(files, key=relative)


def build() -> int:
    records = [
        {"path": relative(path), "bytes": path.stat().st_size, "sha256": digest(path)}
        for path in migration_files()
    ]
    data = {
        "schema_version": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "source": {
            "repository": "Sirish24/sirish-utsav-collaboration",
            "main_commit": SOURCE_MAIN_SHA,
            "carousel_feature_commit": SOURCE_FEATURE_SHA,
        },
        "destination": "lekhakustav/jyotish",
        "file_count": len(records),
        "total_bytes": sum(item["bytes"] for item in records),
        "files": records,
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"PASS: wrote migration manifest ({len(records)} files)")
    return 0


def verify() -> int:
    try:
        data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL: cannot read migration manifest: {error}")
        return 1
    errors: list[str] = []
    if data.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    if data.get("source", {}).get("main_commit") != SOURCE_MAIN_SHA:
        errors.append("source main commit changed")
    if data.get("source", {}).get("carousel_feature_commit") != SOURCE_FEATURE_SHA:
        errors.append("source feature commit changed")
    records = data.get("files")
    if not isinstance(records, list) or data.get("file_count") != len(records):
        errors.append("file_count does not match manifest records")
        records = records if isinstance(records, list) else []
    for record in records:
        path = ROOT / str(record.get("path", ""))
        if not path.is_file():
            errors.append(f"missing: {record.get('path')}")
            continue
        if path.stat().st_size != record.get("bytes"):
            errors.append(f"size changed: {record.get('path')}")
        elif digest(path) != record.get("sha256"):
            errors.append(f"hash changed: {record.get('path')}")
    if sum(int(item.get("bytes", 0)) for item in records) != data.get("total_bytes"):
        errors.append("total_bytes does not match manifest records")
    if errors:
        print("FAIL\n- " + "\n- ".join(errors))
        return 1
    print(f"PASS: migration verified ({len(records)} files, {data['total_bytes']} bytes)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("build", "verify"))
    args = parser.parse_args()
    return build() if args.command == "build" else verify()


if __name__ == "__main__":
    raise SystemExit(main())
