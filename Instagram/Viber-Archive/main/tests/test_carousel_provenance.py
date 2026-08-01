#!/usr/bin/env python3
"""Regression tests for the fail-closed carousel provenance gate."""

import hashlib
import json
import shutil
import subprocess
import sys
import unittest
import uuid
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "verify_carousel_provenance.py"
HANDOFF_SCRIPT = ROOT / "scripts" / "validate_handoff.py"


def png(width=1080, height=1350):
    return b"\x89PNG\r\n\x1a\n" + (13).to_bytes(4, "big") + b"IHDR" + width.to_bytes(4, "big") + height.to_bytes(4, "big")


class CarouselProvenanceTests(unittest.TestCase):
    def setUp(self):
        self.date = "2030-01-02"
        self.base = ROOT / f".carousel-provenance-test-{uuid.uuid4().hex}"
        self.package = ROOT / "content" / "instagram" / self.date
        if self.package.exists():
            shutil.rmtree(self.package)
        if (ROOT / "proof" / self.date).exists():
            shutil.rmtree(ROOT / "proof" / self.date)
        self.base.mkdir()
        (self.package / "daily").mkdir(parents=True)
        (self.package / "brand").mkdir()
        (ROOT / "proof" / self.date).mkdir(parents=True)
        (self.package / "carousel-copy.json").write_text("{}")
        (self.package / "brand" / "jyotish-logo-transparent.png").write_bytes(b"brand")
        (self.base / "renderer.js").write_text("// renderer")
        (ROOT / "proof" / self.date / "daily-carousel-14-slide-contact-sheet.png").write_bytes(b"contact")
        for index in range(1, 15):
            (self.package / "daily" / f"{index:02d}.png").write_bytes(png())
        self.source_sha = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True, capture_output=True, check=True).stdout.strip()
        self.manifest = self.package / "provenance-daily.json"
        self.build()

    def tearDown(self):
        shutil.rmtree(self.base)
        shutil.rmtree(self.package)
        shutil.rmtree(ROOT / "proof" / self.date)

    def rel(self, path):
        return path.relative_to(ROOT).as_posix()

    def invoke(self, *args, ok=True):
        result = subprocess.run([sys.executable, str(SCRIPT), *args], cwd=ROOT, text=True, capture_output=True)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def build(self):
        self.invoke(
            "build", "--date", self.date, "--edition", "daily", "--source-sha", self.source_sha,
            "--source-json", self.rel(self.package / "carousel-copy.json"),
            "--renderer", self.rel(self.base / "renderer.js"),
            "--renderer-command", f"node {self.rel(self.base / 'renderer.js')} {self.date}",
            "--renderer-version", "v20.0.0",
            "--brand-asset", self.rel(self.package / "brand" / "jyotish-logo-transparent.png"),
            "--contact-sheet", self.rel(ROOT / "proof" / self.date / "daily-carousel-14-slide-contact-sheet.png"),
        )

    def verify(self, ok=True, acknowledgement=None, expected=None):
        args = ["verify", "--manifest", self.rel(self.manifest), "--expected-source-sha", expected or self.source_sha]
        if acknowledgement:
            args += ["--acknowledgement", self.rel(acknowledgement)]
        return self.invoke(*args, ok=ok)

    def data(self):
        return json.loads(self.manifest.read_text())

    def save(self, data):
        self.manifest.write_text(json.dumps(data, indent=2) + "\n")

    def test_valid_package_and_matching_acknowledgement_pass(self):
        acknowledgement = self.base / "acknowledgement.json"
        acknowledgement.write_text(json.dumps({
            "manifest": self.rel(self.manifest), "source_commit_sha": self.source_sha,
            "verifier_result": "PASS", "acknowledged_by": "Utsav", "at": "2030-01-02T12:00:00+05:45",
        }))
        self.verify(acknowledgement=acknowledgement)

    def test_rejects_asset_hash_mismatch(self):
        (self.package / "brand" / "jyotish-logo-transparent.png").write_bytes(b"changed brand")
        self.assertIn("SHA-256 does not match bytes", self.verify(ok=False).stdout)

    def test_rejects_slide_byte_hash_order_dimension_and_missing_file(self):
        first = self.package / "daily" / "01.png"
        first.write_bytes(png() + b"changed")
        self.assertIn("SHA-256 does not match bytes", self.verify(ok=False).stdout)
        self.build()
        data = self.data()
        data["slides"][0], data["slides"][1] = data["slides"][1], data["slides"][0]
        self.save(data)
        self.assertIn("must be ordered", self.verify(ok=False).stdout)
        self.build()
        (self.package / "daily" / "01.png").write_bytes(png(1080, 1080))
        self.assertIn("PNG dimensions must be 1080x1350", self.verify(ok=False).stdout)
        (self.package / "daily" / "14.png").unlink()
        self.assertIn("does not exist", self.verify(ok=False).stdout)

    def test_rejects_old_or_mismatched_source_commit(self):
        self.assertIn("does not match the required source SHA", self.verify(ok=False, expected="0" * 40).stdout)

    def test_rejects_non_passing_or_wrong_sha_receiver_acknowledgement(self):
        acknowledgement = self.base / "acknowledgement.json"
        acknowledgement.write_text(json.dumps({
            "manifest": self.rel(self.manifest), "source_commit_sha": "0" * 40,
            "verifier_result": "FAIL", "acknowledged_by": "Utsav", "at": "2030-01-02T12:00:00+05:45",
        }))
        output = self.verify(ok=False, acknowledgement=acknowledgement).stdout
        self.assertIn("source SHA does not match", output)
        self.assertIn("verifier_result PASS", output)

    def test_generic_carousel_handoff_requires_receiver_acknowledgement(self):
        handoff = self.base / "handoff.json"
        data = self.data()
        handoff.write_text(json.dumps({
            "handoff_key": "daily:2030-01-02", "project_id": "jyotish-baje", "owner": "Utsav", "status": "complete",
            "created_at": "2030-01-02T10:00:00+05:45", "completed_at": "2030-01-02T12:00:00+05:45",
            "artifacts": [self.rel(self.manifest)], "proof": [self.rel(ROOT / "proof" / self.date)],
            "notification": {"channel": "github_issue", "handoff_key": "daily:2030-01-02", "issue_reference": "https://example.test/issues/1", "attempted": True, "assignment_status": "assigned", "notes": "test"},
            "blockers": [], "deviations": [],
            "carousel": {"manifest": self.rel(self.manifest), "source_commit_sha": self.source_sha, "upload_path": data["upload_path"], "verifier_command": data["verifier_command"], "receiver_acknowledgement": self.rel(self.base / "missing-ack.json")},
        }))
        result = subprocess.run([sys.executable, str(HANDOFF_SCRIPT), "--file", str(handoff)], cwd=ROOT, text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("receiver acknowledgement is unreadable", result.stdout)

    def test_future_jyotish_handoff_cannot_omit_carousel_provenance(self):
        handoff = self.base / "handoff-without-provenance.json"
        handoff.write_text(json.dumps({
            "handoff_key": "daily:2030-01-02", "project_id": "jyotish-baje", "owner": "Utsav", "status": "complete",
            "created_at": "2030-01-02T10:00:00+05:45", "completed_at": "2030-01-02T12:00:00+05:45",
            "artifacts": [self.rel(self.manifest)], "proof": [self.rel(ROOT / "proof" / self.date)],
            "notification": {"channel": "github_issue", "handoff_key": "daily:2030-01-02", "issue_reference": "https://example.test/issues/1", "attempted": True, "assignment_status": "assigned", "notes": "test"},
            "blockers": [], "deviations": [],
        }))
        result = subprocess.run([sys.executable, str(HANDOFF_SCRIPT), "--file", str(handoff)], cwd=ROOT, text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("require a carousel provenance record", result.stdout)


if __name__ == "__main__":
    unittest.main()
