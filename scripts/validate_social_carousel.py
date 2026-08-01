#!/usr/bin/env python3
"""Validate the migrated Jyotish social-carousel workspace."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def png_dimensions(path: Path) -> tuple[int, int] | None:
    header = path.read_bytes()[:24]
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return int.from_bytes(header[16:20], "big"), int.from_bytes(header[20:24], "big")


def check_platform(path: Path, expected: tuple[int, int], filename_pattern: str, errors: list[str]) -> None:
    pngs = sorted(candidate for candidate in path.glob("*.png") if re.fullmatch(filename_pattern, candidate.name))
    if len(pngs) != 14:
        errors.append(f"{path.relative_to(ROOT)} must contain exactly 14 PNG files, found {len(pngs)}")
    for png in pngs:
        if png_dimensions(png) != expected:
            errors.append(f"wrong dimensions for {png.relative_to(ROOT)}: {png_dimensions(png)}")


def main() -> int:
    errors: list[str] = []
    required = (
        "content/generated/daily-rashifal-2026-07-25.json",
        "content/generated/daily-rashifal-2026-07-26.json",
        "content/generated/daily-rashifal-2026-07-27.json",
        "content/generated/daily-rashifal-2026-07-28.json",
        "content/generated/daily-rashifal-2026-07-29.json",
        "content/generated/daily-rashifal-2026-07-30.json",
        "content/generated/daily-rashifal-2026-08-01.json",
        "content/instagram/2026-08-01/carousel-copy.json",
        "content/instagram/2026-08-01/provenance-daily.json",
        "scripts/render_instagram_carousel_14.cjs",
        "scripts/verify_carousel_provenance.py",
        "Instagram/2026-08-01/weekly-mantra/README.md",
        "Instagram/Viber-Archive/main/coordination/carousel-provenance.schema.json",
    )
    for item in required:
        if not (ROOT / item).is_file():
            errors.append(f"missing required migration file: {item}")

    for path in (ROOT / "content").rglob("*.json"):
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            errors.append(f"invalid JSON {path.relative_to(ROOT)}: {error}")

    check_platform(ROOT / "content/instagram/2026-08-01/daily", (1080, 1350), r"\d{2}\.png", errors)
    check_platform(ROOT / "content/tiktok/2026-08-01/daily", (1080, 1920), r"\d{2}-.+\.png", errors)
    check_platform(ROOT / "content/tiktok/2026-07-30/daily", (1080, 1920), r"\d{2}-.+\.png", errors)

    for date in ("2026-07-25", "2026-07-26", "2026-07-28", "2026-07-29", "2026-07-30", "2026-08-01"):
        if not (ROOT / "content" / "instagram" / date).is_dir():
            errors.append(f"missing automated Instagram package date: {date}")
    for date in ("2026-07-25", "2026-07-27", "2026-07-31", "2026-08-01"):
        if not (ROOT / "Instagram" / date).is_dir():
            errors.append(f"missing curated Instagram package date: {date}")

    active_paths = [ROOT / "scripts", ROOT / ".github" / "workflows"]
    for base in active_paths:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if not path.is_file() or "Viber-Archive" in path.parts:
                continue
            if path.name in {"validate_social_carousel.py", "verify_jyotish_migration.py"}:
                continue
            if path.suffix.lower() not in {".py", ".js", ".cjs", ".yml", ".yaml", ".md"}:
                continue
            text = path.read_text(encoding="utf-8", errors="replace").lower()
            if "chiefo" in text or "sirish24/sirish-utsav-collaboration" in text:
                errors.append(f"active file retains Chiefo dependency: {path.relative_to(ROOT)}")

    if errors:
        print("FAIL\n- " + "\n- ".join(errors))
        return 1
    print("PASS: Jyotish social carousel assets, formats, dimensions, history, and independence validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
