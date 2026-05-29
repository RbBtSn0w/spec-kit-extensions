#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-workspace-audit.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

"$PYTHON_BIN" "$AUDIT_SCRIPT" "$FIXTURES_DIR/clean-repo" --json-out "$TMP_DIR/clean.json" >/dev/null
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$FIXTURES_DIR/bloated-agents" --json-out "$TMP_DIR/bloated.json" >/dev/null

"$PYTHON_BIN" - "$TMP_DIR/clean.json" "$TMP_DIR/bloated.json" <<'PY'
import json
import sys
from pathlib import Path

clean = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
bloated = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))

if clean["metrics"]["total_findings"] != 0:
    raise SystemExit("FAIL: clean-repo workspace audit should produce zero findings")

required_top_level = {"schema_version", "workspace_root", "source_metadata", "instruction_map", "findings", "metrics", "summary"}
missing = required_top_level.difference(bloated.keys())
if missing:
    raise SystemExit(f"FAIL: bloated-agents report missing keys: {sorted(missing)}")

if not bloated["metrics"]["files_that_would_be_modified"]:
    raise SystemExit("FAIL: bloated-agents report should list files_that_would_be_modified")

handoffs = [finding for finding in bloated["findings"] if finding.get("manual_handoff")]
if not handoffs:
    raise SystemExit("FAIL: bloated-agents should emit at least one constitution manual handoff")

print("workspace audit checks passed")
PY
