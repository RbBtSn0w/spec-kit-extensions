#!/usr/bin/env python3
"""Run MemoryLint's executable audit core against the regression fixture corpus."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from memorylint_core import generate_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scan MemoryLint regression fixtures.")
    parser.add_argument("--fixtures", type=Path, required=True, help="Fixture corpus root.")
    parser.add_argument("--check", action="store_true", help="Compare actual findings to expected-findings.json.")
    parser.add_argument("--dump", action="store_true", help="Print actual findings for each fixture.")
    return parser.parse_args()


def normalize_finding(finding: dict[str, object]) -> dict[str, object]:
    source = re.sub(r":\d+(?:-\d+)?", "", str(finding["source"]))
    return {
        "drift_type": finding["drift_type"],
        "severity": finding["severity"],
        "confidence": finding["confidence"],
        "description": finding["detail"],
        "source": source,
        "evidence": finding["evidence"],
        "recommended_destination": finding["recommended_destination"],
        "suggested_action": finding["suggested_action"],
    }


def fixture_findings(fixtures_dir: Path) -> list[tuple[str, list[dict[str, object]]]]:
    findings_by_fixture: list[tuple[str, list[dict[str, object]]]] = []
    for fixture in sorted(fixtures_dir.iterdir()):
        if not fixture.is_dir() or fixture.name.startswith(".") or fixture.name.startswith("_"):
            continue
        report = generate_report(fixture.resolve())
        normalized = [normalize_finding(finding) for finding in report.findings]
        findings_by_fixture.append((fixture.name, normalized))
    return findings_by_fixture


def compare(expected: list[dict[str, object]], actual: list[dict[str, object]]) -> tuple[bool, str]:
    if expected == actual:
        return True, ""
    return (
        False,
        "Expected findings do not match actual findings.\n"
        f"Expected:\n{json.dumps(expected, indent=2, ensure_ascii=False)}\n"
        f"Actual:\n{json.dumps(actual, indent=2, ensure_ascii=False)}",
    )


def main() -> int:
    args = parse_args()
    fixtures_dir = args.fixtures.resolve()
    findings_by_fixture = fixture_findings(fixtures_dir)

    for fixture_name, findings in findings_by_fixture:
        if args.dump:
            print(f"## {fixture_name}")
            print(json.dumps(findings, indent=2, ensure_ascii=False))
        if args.check:
            manifest = fixtures_dir / fixture_name / "expected-findings.json"
            expected = json.loads(manifest.read_text(encoding="utf-8"))
            ok, message = compare(expected, findings)
            if not ok:
                raise SystemExit(f"FAIL: {fixture_name}\n{message}")

    if args.check:
        print(f"fixture scanner passed ({len(findings_by_fixture)} fixtures checked)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
