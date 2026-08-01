#!/usr/bin/env python3
"""Validate one secret-free, repository-relative completion handoff."""

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path

from verify_carousel_provenance import validate_manifest, acknowledgement_errors


ROOT = Path(__file__).resolve().parents[1]
HANDOFF_KEY = re.compile(r"^(daily|weekly|inventory):\d{4}-\d{2}-\d{2}$")
PROJECT_ID = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
STATUSES = {"pending", "complete", "blocked"}
ASSIGNMENT_STATUSES = {"not_attempted", "pending", "assigned", "unavailable", "unknown"}
CAROUSEL_PROVENANCE_EFFECTIVE_DATE = "2026-08-01"
REQUIRED = {
    "handoff_key",
    "project_id",
    "owner",
    "status",
    "completed_at",
    "artifacts",
    "proof",
    "notification",
    "blockers",
    "deviations",
}


def iso_datetime(value, field, errors, allow_null=True):
    if value is None and allow_null:
        return
    if not isinstance(value, str):
        errors.append(f"{field} must be an ISO-8601 string or null")
        return
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            errors.append(f"{field} must include a timezone")
    except ValueError:
        errors.append(f"{field} is not a valid ISO-8601 datetime")


def repository_path(value, field, errors):
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{field} must be a non-empty repository-relative path")
        return
    if value.startswith("/") or "\\" in value or value == ".." or value.startswith("../") or "/../" in value:
        errors.append(f"{field} must be repository-relative and cannot contain parent traversal: {value}")


def string_list(value, field, errors):
    if not isinstance(value, list):
        errors.append(f"{field} must be an array")
        return
    for index, item in enumerate(value):
        if not isinstance(item, str):
            errors.append(f"{field}[{index}] must be a string")


def validate(data, source):
    errors = []
    if not isinstance(data, dict):
        return ["handoff must be a JSON object"]

    unknown = set(data) - (REQUIRED | {"example", "created_at", "carousel"})
    if unknown:
        errors.append("unknown top-level fields: " + ", ".join(sorted(unknown)))
    missing = REQUIRED - set(data)
    if missing:
        errors.append("missing required fields: " + ", ".join(sorted(missing)))
        return errors

    if "example" in data and not isinstance(data["example"], bool):
        errors.append("example must be boolean")
    if not isinstance(data["handoff_key"], str) or not HANDOFF_KEY.fullmatch(data["handoff_key"]):
        errors.append("handoff_key must match daily|weekly|inventory:YYYY-MM-DD")
    if not isinstance(data["project_id"], str) or not PROJECT_ID.fullmatch(data["project_id"]):
        errors.append("project_id must be lowercase kebab-case")
    if not isinstance(data["owner"], str) or not data["owner"].strip():
        errors.append("owner must be a non-empty string")
    status = data["status"]
    if status not in STATUSES:
        errors.append("status must be pending, complete, or blocked")
    iso_datetime(data.get("created_at"), "created_at", errors)
    iso_datetime(data.get("completed_at"), "completed_at", errors)

    for field in ("artifacts", "proof"):
        value = data[field]
        if not isinstance(value, list):
            errors.append(f"{field} must be an array")
            continue
        for index, item in enumerate(value):
            repository_path(item, f"{field}[{index}]", errors)

    string_list(data["blockers"], "blockers", errors)
    string_list(data["deviations"], "deviations", errors)

    notification = data["notification"]
    if not isinstance(notification, dict):
        errors.append("notification must be an object")
    else:
        required_notification = {
            "channel",
            "handoff_key",
            "issue_reference",
            "attempted",
            "assignment_status",
            "notes",
        }
        missing_notification = required_notification - set(notification)
        if missing_notification:
            errors.append(
                "notification missing required fields: " + ", ".join(sorted(missing_notification))
            )
        unknown_notification = set(notification) - required_notification
        if unknown_notification:
            errors.append(
                "notification has unknown fields: " + ", ".join(sorted(unknown_notification))
            )
        if notification.get("channel") != "github_issue":
            errors.append("notification.channel must be github_issue")
        if notification.get("handoff_key") != data["handoff_key"]:
            errors.append("notification.handoff_key must match handoff_key")
        if not isinstance(notification.get("issue_reference"), str) or not notification.get("issue_reference", "").strip():
            errors.append("notification.issue_reference must be a non-empty string")
        if not isinstance(notification.get("attempted"), bool):
            errors.append("notification.attempted must be boolean")
        if notification.get("assignment_status") not in ASSIGNMENT_STATUSES:
            errors.append("notification.assignment_status is invalid")
        if not isinstance(notification.get("notes"), str):
            errors.append("notification.notes must be a string")

    if status == "complete":
        if not isinstance(data["completed_at"], str):
            errors.append("complete handoff requires completed_at")
        if not data["artifacts"]:
            errors.append("complete handoff requires at least one artifact")
        if not data["proof"]:
            errors.append("complete handoff requires at least one proof reference")
        if isinstance(notification, dict) and notification.get("attempted") is not True:
            errors.append("complete handoff requires notification.attempted=true")
    elif data["completed_at"] is not None:
        errors.append("only complete handoffs may set completed_at")

    if status == "blocked" and not data["blockers"]:
        errors.append("blocked handoff requires at least one blocker")

    # A carousel is never generic media.  Its receiver must acknowledge the
    # exact pinned manifest SHA and a PASS verifier result before handoff.
    handoff_kind, _, handoff_date = str(data.get("handoff_key", "")).partition(":")
    requires_carousel = (
        data.get("project_id") == "jyotish-baje"
        and handoff_kind in {"daily", "weekly"}
        and handoff_date >= CAROUSEL_PROVENANCE_EFFECTIVE_DATE
    )
    carousel = data.get("carousel")
    if requires_carousel and carousel is None:
        errors.append(
            "Jyotish daily/weekly handoffs on or after "
            f"{CAROUSEL_PROVENANCE_EFFECTIVE_DATE} require a carousel provenance record"
        )
    if carousel is not None and not isinstance(carousel, dict):
        errors.append("carousel must be an object when present")
    elif isinstance(carousel, dict):
        expected = {"manifest", "source_commit_sha", "upload_path", "verifier_command", "receiver_acknowledgement"}
        if set(carousel) != expected:
            errors.append("carousel must contain exactly manifest, source_commit_sha, upload_path, verifier_command, and receiver_acknowledgement")
        else:
            manifest_path = carousel["manifest"]
            acknowledgement_path = carousel["receiver_acknowledgement"]
            for field, value in (("carousel.manifest", manifest_path), ("carousel.receiver_acknowledgement", acknowledgement_path)):
                repository_path(value, field, errors)
            if not isinstance(carousel["source_commit_sha"], str) or not re.fullmatch(r"[0-9a-f]{40}", carousel["source_commit_sha"]):
                errors.append("carousel.source_commit_sha must be a full 40-character lowercase Git SHA")
            if not isinstance(carousel["upload_path"], str) or not carousel["upload_path"].strip():
                errors.append("carousel.upload_path must be non-empty")
            if not isinstance(carousel["verifier_command"], str) or not carousel["verifier_command"].strip():
                errors.append("carousel.verifier_command must be non-empty")
            manifest_file = ROOT / str(manifest_path)
            acknowledgement_file = ROOT / str(acknowledgement_path)
            try:
                manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as error:
                errors.append(f"carousel manifest is unreadable: {error}")
            else:
                errors.extend(validate_manifest(manifest, expected_source_sha=carousel["source_commit_sha"]))
                if manifest.get("upload_path") != carousel["upload_path"]:
                    errors.append("carousel.upload_path must match manifest")
                if manifest.get("verifier_command") != carousel["verifier_command"]:
                    errors.append("carousel.verifier_command must match manifest")
            try:
                acknowledgement = json.loads(acknowledgement_file.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as error:
                errors.append(f"carousel receiver acknowledgement is unreadable: {error}")
            else:
                errors.extend(acknowledgement_errors(acknowledgement, str(manifest_path), carousel["source_commit_sha"]))

    if not data.get("example", False):
        for field in ("artifacts", "proof"):
            for item in data[field]:
                target = ROOT / item
                if not target.exists():
                    errors.append(f"{field} path does not exist: {item}")
                elif not target.is_dir() and not target.is_file():
                    errors.append(f"{field} path is not readable: {item}")

    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file", required=True, help="JSON handoff file to validate")
    args = parser.parse_args()
    source = Path(args.file)
    try:
        data = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL\n- cannot read {source}: {error}")
        return 1
    errors = validate(data, source)
    if errors:
        print("FAIL\n- " + "\n- ".join(errors))
        return 1
    print(f"PASS: handoff contract validated ({source})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
