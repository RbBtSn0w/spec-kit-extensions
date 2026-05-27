#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-fixture-validation.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$FIXTURES_DIR" <<'PY'
import json
import sys
from pathlib import Path

fixtures_dir = Path(sys.argv[1])

VALID_DRIFT_TYPES = {"boundary", "reality", "conflict", "redundancy"}
VALID_SEVERITIES = {"critical", "warning", "info"}
VALID_CONFIDENCES = {"high", "medium", "low"}

fixture_count = 0

for fixture in sorted(fixtures_dir.iterdir()):
    if not fixture.is_dir() or fixture.name.startswith('.') or fixture.name.startswith('_'):
        continue

    fixture_count += 1
    manifest = fixture / "expected-findings.json"

    if not manifest.exists():
        raise SystemExit(f"FAIL: {fixture.name}/ is missing expected-findings.json")

    try:
        findings = json.loads(manifest.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        raise SystemExit(f"FAIL: {fixture.name}/expected-findings.json is invalid JSON: {e}")

    if not isinstance(findings, list):
        raise SystemExit(f"FAIL: {fixture.name}/expected-findings.json must be a JSON array")

    for i, entry in enumerate(findings):
        prefix = f"{fixture.name}/expected-findings.json[{i}]"

        if not isinstance(entry, dict):
            raise SystemExit(f"FAIL: {prefix} must be a JSON object")

        for field in (
            "drift_type",
            "severity",
            "confidence",
            "description",
            "source",
            "evidence",
            "recommended_destination",
            "suggested_action",
        ):
            if field not in entry:
                raise SystemExit(f"FAIL: {prefix} is missing required field '{field}'")

        for field in ("description", "source", "evidence", "recommended_destination", "suggested_action"):
            if not isinstance(entry[field], str) or not entry[field].strip():
                raise SystemExit(f"FAIL: {prefix} {field} must be a non-empty string")

        dt = entry["drift_type"]
        if dt not in VALID_DRIFT_TYPES:
            raise SystemExit(f"FAIL: {prefix} drift_type '{dt}' not in {VALID_DRIFT_TYPES}")

        sev = entry["severity"]
        if sev not in VALID_SEVERITIES:
            raise SystemExit(f"FAIL: {prefix} severity '{sev}' not in {VALID_SEVERITIES}")

        conf = entry["confidence"]
        if conf not in VALID_CONFIDENCES:
            raise SystemExit(f"FAIL: {prefix} confidence '{conf}' not in {VALID_CONFIDENCES}")

if fixture_count == 0:
    raise SystemExit(f"FAIL: no fixture directories found in {fixtures_dir}")

print(f"fixture validation passed ({fixture_count} fixtures checked)")
PY
