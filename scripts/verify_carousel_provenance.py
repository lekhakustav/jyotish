#!/usr/bin/env python3
"""Build and fail-closed verify a 14-slide Instagram carousel provenance package.

The manifest is deliberately self-contained and repository-relative.  It pins
the exact renderer source commit and every byte that the uploader is allowed to
use; it does not record local device paths, accounts, or credentials.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
SHA256 = re.compile(r"^[0-9a-f]{64}$")
GIT_SHA = re.compile(r"^[0-9a-f]{40}$")
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
EDITIONS = {"daily", "weekly"}
SCHEMA_VERSION = 1


def repo_path(value: object) -> bool:
    if not isinstance(value, str) or not value.strip() or "\\" in value:
        return False
    path = PurePosixPath(value)
    return not path.is_absolute() and ".." not in path.parts


def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_dimensions(path: Path) -> tuple[int, int] | None:
    try:
        header = path.read_bytes()[:24]
    except OSError:
        return None
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return int.from_bytes(header[16:20], "big"), int.from_bytes(header[20:24], "big")


def repository_file(root: Path, value: object, label: str, errors: list[str]) -> Path | None:
    if not repo_path(value):
        errors.append(f"{label} must be a safe repository-relative path")
        return None
    path = root / str(value)
    if not path.is_file():
        errors.append(f"{label} does not exist: {value}")
        return None
    return path


def check_hash(root: Path, record: object, label: str, errors: list[str]) -> None:
    if not isinstance(record, dict) or set(record) != {"path", "sha256"}:
        errors.append(f"{label} must contain exactly path and sha256")
        return
    path = repository_file(root, record["path"], f"{label}.path", errors)
    if not isinstance(record["sha256"], str) or not SHA256.fullmatch(record["sha256"]):
        errors.append(f"{label}.sha256 must be a lowercase SHA-256")
    elif path and file_hash(path) != record["sha256"]:
        errors.append(f"{label} SHA-256 does not match bytes: {record['path']}")


def git_commit_exists(root: Path, sha: str) -> bool:
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{sha}^{{commit}}"], cwd=root,
        text=True, capture_output=True,
    )
    return result.returncode == 0


def git_commit_is_pushed(root: Path, sha: str) -> bool:
    """Accept only commits reachable from an origin remote-tracking ref."""
    result = subprocess.run(
        ["git", "branch", "--remotes", "--contains", sha], cwd=root,
        text=True, capture_output=True,
    )
    return result.returncode == 0 and any(
        line.strip().removeprefix("*").strip().startswith("origin/")
        for line in result.stdout.splitlines()
    )


def validate_manifest(data: object, root: Path = ROOT, expected_source_sha: str | None = None) -> list[str]:
    errors: list[str] = []
    required = {
        "schema_version", "project_id", "edition", "date", "source", "renderer",
        "brand_assets", "contact_sheet", "slides", "upload_path", "verifier_command",
    }
    if not isinstance(data, dict):
        return ["manifest must be a JSON object"]
    if set(data) != required:
        return ["manifest fields must be exactly: " + ", ".join(sorted(required))]
    if data["schema_version"] != SCHEMA_VERSION:
        errors.append(f"schema_version must be {SCHEMA_VERSION}")
    if data["project_id"] != "jyotish-baje":
        errors.append("project_id must be jyotish-baje")
    if data["edition"] not in EDITIONS:
        errors.append("edition must be daily or weekly")
    if not isinstance(data["date"], str) or not DATE.fullmatch(data["date"]):
        errors.append("date must be YYYY-MM-DD")
        return errors
    date = data["date"]
    edition = data["edition"] if isinstance(data["edition"], str) else ""
    package_root = f"content/instagram/{date}"
    expected_upload = f"{package_root}/{edition}"
    if data["upload_path"] != expected_upload:
        errors.append(f"upload_path must be the pinned package path: {expected_upload}")

    source = data["source"]
    if not isinstance(source, dict) or set(source) != {"commit_sha", "json"}:
        errors.append("source must contain exactly commit_sha and json")
    else:
        sha = source["commit_sha"]
        if not isinstance(sha, str) or not GIT_SHA.fullmatch(sha):
            errors.append("source.commit_sha must be a full 40-character lowercase Git SHA")
        else:
            if expected_source_sha and sha != expected_source_sha:
                errors.append("source.commit_sha does not match the required source SHA")
            if (root / ".git").exists() and not git_commit_exists(root, sha):
                errors.append("source.commit_sha is not an available Git commit")
            elif (root / ".git").exists() and not git_commit_is_pushed(root, sha):
                errors.append("source.commit_sha is not reachable from a pushed origin ref")
        check_hash(root, source["json"], "source.json", errors)
        if isinstance(source.get("json"), dict) and source["json"].get("path") != f"{package_root}/carousel-copy.json":
            errors.append("source.json.path must be the dated carousel-copy.json; brand-date fallback is forbidden")

    renderer = data["renderer"]
    if not isinstance(renderer, dict) or set(renderer) != {"path", "sha256", "command", "version"}:
        errors.append("renderer must contain exactly path, sha256, command, and version")
    else:
        check_hash(root, {"path": renderer.get("path"), "sha256": renderer.get("sha256")}, "renderer", errors)
        command, version = renderer.get("command"), renderer.get("version")
        if not isinstance(command, str) or not command.strip() or "latest" in command.lower() or date not in command:
            errors.append("renderer.command must pin this date and cannot use a latest-brand fallback")
        if not isinstance(version, str) or not version.strip():
            errors.append("renderer.version must be non-empty")

    assets = data["brand_assets"]
    if not isinstance(assets, list) or not assets:
        errors.append("brand_assets must be a non-empty list")
    else:
        for index, asset in enumerate(assets):
            check_hash(root, asset, f"brand_assets[{index}]", errors)
            if isinstance(asset, dict) and not str(asset.get("path", "")).startswith(f"{package_root}/brand/"):
                errors.append("brand assets must come from the package's exact date; brand-date fallback is forbidden")

    check_hash(root, data["contact_sheet"], "contact_sheet", errors)
    if isinstance(data["contact_sheet"], dict) and data["contact_sheet"].get("path") != f"proof/{date}/{edition}-carousel-14-slide-contact-sheet.png":
        errors.append("contact_sheet.path must use the matching dated proof path")

    slides = data["slides"]
    if not isinstance(slides, list) or len(slides) != 14:
        errors.append("slides must contain exactly 14 ordered PNG records")
    else:
        for index, slide in enumerate(slides, start=1):
            label = f"slides[{index - 1}]"
            if not isinstance(slide, dict) or set(slide) != {"path", "sha256", "width", "height"}:
                errors.append(f"{label} must contain exactly path, sha256, width, and height")
                continue
            expected = f"{expected_upload}/{index:02d}.png"
            if slide["path"] != expected:
                errors.append(f"{label}.path must be ordered as {expected}")
            check_hash(root, {"path": slide["path"], "sha256": slide["sha256"]}, label, errors)
            if slide["width"] != 1080 or slide["height"] != 1350:
                errors.append(f"{label} manifest dimensions must be 1080x1350")
            path = repository_file(root, slide["path"], f"{label}.path", errors)
            if path and png_dimensions(path) != (1080, 1350):
                errors.append(f"{label} PNG dimensions must be 1080x1350")

    command = data["verifier_command"]
    if not isinstance(command, str) or not command.startswith("python3 scripts/verify_carousel_provenance.py verify --manifest "):
        errors.append("verifier_command must invoke the repository provenance verifier")
    elif expected_source_sha and expected_source_sha not in command:
        errors.append("verifier_command must include the required source SHA")
    return errors


def acknowledgement_errors(acknowledgement: object, manifest_path: str, source_sha: str) -> list[str]:
    if not isinstance(acknowledgement, dict) or set(acknowledgement) != {"manifest", "source_commit_sha", "verifier_result", "acknowledged_by", "at"}:
        return ["receiver acknowledgement must contain manifest, source_commit_sha, verifier_result, acknowledged_by, and at"]
    errors = []
    if acknowledgement["manifest"] != manifest_path:
        errors.append("receiver acknowledgement manifest does not match")
    if acknowledgement["source_commit_sha"] != source_sha:
        errors.append("receiver acknowledgement source SHA does not match")
    if acknowledgement["verifier_result"] != "PASS":
        errors.append("receiver acknowledgement must record verifier_result PASS")
    if not isinstance(acknowledgement["acknowledged_by"], str) or not acknowledgement["acknowledged_by"].strip():
        errors.append("receiver acknowledgement acknowledged_by must be non-empty")
    try:
        datetime.fromisoformat(str(acknowledgement["at"]).replace("Z", "+00:00"))
    except ValueError:
        errors.append("receiver acknowledgement at must be an ISO-8601 timestamp")
    return errors


def manifest_path(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def record(path: Path) -> dict[str, str]:
    return {"path": manifest_path(ROOT, path), "sha256": file_hash(path)}


def build(args: argparse.Namespace) -> int:
    date, edition = args.date, args.edition
    upload = ROOT / "content" / "instagram" / date / edition
    slides = [upload / f"{index:02d}.png" for index in range(1, 15)]
    manifest_rel = f"content/instagram/{date}/provenance-{edition}.json"
    output = ROOT / manifest_rel
    renderer = ROOT / args.renderer
    source = ROOT / args.source_json
    contact = ROOT / args.contact_sheet
    brand = [ROOT / item for item in args.brand_asset]
    required = [renderer, source, contact, *brand, *slides]
    missing = [item.as_posix() for item in required if not item.is_file()]
    if missing:
        print("FAIL\n- missing required package input(s): " + ", ".join(missing))
        return 1
    data = {
        "schema_version": SCHEMA_VERSION,
        "project_id": "jyotish-baje",
        "edition": edition,
        "date": date,
        "source": {"commit_sha": args.source_sha, "json": record(source)},
        "renderer": {"path": args.renderer, "sha256": file_hash(renderer), "command": args.renderer_command, "version": args.renderer_version},
        "brand_assets": [record(item) for item in brand],
        "contact_sheet": record(contact),
        "slides": [{**record(item), "width": 1080, "height": 1350} for item in slides],
        "upload_path": f"content/instagram/{date}/{edition}",
        "verifier_command": f"python3 scripts/verify_carousel_provenance.py verify --manifest {manifest_rel} --expected-source-sha {args.source_sha}",
    }
    errors = validate_manifest(data, expected_source_sha=args.source_sha)
    if errors:
        print("FAIL\n- " + "\n- ".join(errors))
        return 1
    output.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"PASS: wrote verified carousel provenance manifest ({manifest_rel})")
    return 0


def verify(args: argparse.Namespace) -> int:
    fetch = subprocess.run(["git", "fetch", "--quiet", "origin"], cwd=ROOT, text=True, capture_output=True)
    if fetch.returncode:
        print("FAIL\n- unable to fetch origin before provenance verification")
        return 1
    source = Path(args.manifest)
    try:
        data = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL\n- cannot read manifest: {error}")
        return 1
    errors = validate_manifest(data, expected_source_sha=args.expected_source_sha)
    if not errors and args.acknowledgement:
        try:
            acknowledgement = json.loads(Path(args.acknowledgement).read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            errors.append(f"cannot read receiver acknowledgement: {error}")
        else:
            errors.extend(acknowledgement_errors(acknowledgement, manifest_path(ROOT, source), data["source"]["commit_sha"]))
    if errors:
        print("FAIL\n- " + "\n- ".join(errors))
        return 1
    print(f"PASS: carousel provenance verified ({source})")
    return 0


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    commands = result.add_subparsers(dest="command", required=True)
    build_parser = commands.add_parser("build", help="write a manifest only after all package bytes verify")
    build_parser.add_argument("--date", required=True)
    build_parser.add_argument("--edition", choices=sorted(EDITIONS), required=True)
    build_parser.add_argument("--source-sha", required=True)
    build_parser.add_argument("--source-json", required=True)
    build_parser.add_argument("--renderer", required=True)
    build_parser.add_argument("--renderer-command", required=True)
    build_parser.add_argument("--renderer-version", required=True)
    build_parser.add_argument("--brand-asset", action="append", required=True)
    build_parser.add_argument("--contact-sheet", required=True)
    verify_parser = commands.add_parser("verify", help="verify a manifest and optional receiver acknowledgement")
    verify_parser.add_argument("--manifest", required=True)
    verify_parser.add_argument("--expected-source-sha", required=True)
    verify_parser.add_argument("--acknowledgement")
    return result


def main() -> int:
    args = parser().parse_args()
    return build(args) if args.command == "build" else verify(args)


if __name__ == "__main__":
    raise SystemExit(main())
