#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
APPLY_SCRIPT="$ROOT_DIR/memorylint/scripts/apply_report.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-apply-workflow.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/stale-command"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/stale-command" --json-out "$TMP_DIR/stale-command-report.json" >/dev/null
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/stale-command-report.json" --mode apply-safe-fixes >"$TMP_DIR/stale-apply.txt"
if grep -q "scripts/deploy.sh" "$TMP_DIR/stale-command/AGENTS.md"; then
  echo "FAIL: apply-safe-fixes should remove stale script reference" >&2
  exit 1
fi
if grep -q "npm run e2e" "$TMP_DIR/stale-command/AGENTS.md"; then
  echo "FAIL: apply-safe-fixes should remove stale npm script reference" >&2
  exit 1
fi

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/stale-stale"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/stale-stale" --json-out "$TMP_DIR/stale-stale-report.json" >/dev/null
printf '\n- manual mutation after audit\n' >> "$TMP_DIR/stale-stale/AGENTS.md"
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/stale-stale-report.json" --mode apply-safe-fixes >"$TMP_DIR/staleness.txt" 2>&1; then
  echo "FAIL: apply should reject stale reports" >&2
  exit 1
fi
grep -q "Staleness check failed" "$TMP_DIR/staleness.txt" || {
  echo "FAIL: staleness failure output missing" >&2
  exit 1
}

cp -R "$FIXTURES_DIR/post-apply-breakage" "$TMP_DIR/post-apply-breakage"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/post-apply-breakage" --json-out "$TMP_DIR/post-apply-report.json" >/dev/null
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/post-apply-report.json" --mode apply-all-approved --approve ML-003 >"$TMP_DIR/rollback.txt" 2>&1; then
  echo "FAIL: apply-all-approved should fail validation and rollback" >&2
  exit 1
fi
grep -q "All Changes Reverted" "$TMP_DIR/rollback.txt" || {
  echo "FAIL: rollback report missing" >&2
  exit 1
}
grep -q "speckit.memorylint.run" "$TMP_DIR/post-apply-breakage/extension.yml" || {
  echo "FAIL: rollback should restore original extension.yml" >&2
  exit 1
}

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/path-escape"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/path-escape" --json-out "$TMP_DIR/path-escape-report.json" >/dev/null
printf 'outside\n' > "$TMP_DIR/escaped.txt"
"$PYTHON_BIN" - "$TMP_DIR/path-escape-report.json" <<'PY'
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
report = json.loads(report_path.read_text(encoding="utf-8"))
report["findings"] = [{
    "id": "ML-escape",
    "drift_type": "reality",
    "severity": "warning",
    "confidence": "high",
    "source": "AGENTS.md:3-3",
    "evidence": "malicious report",
    "recommended_destination": "AGENTS.md",
    "suggested_action": "delete",
    "detail": "attempt escape",
    "edits": [{
        "path": "../escaped.txt",
        "action": "delete",
        "start_line": 1,
        "end_line": 1,
        "reason": "escape test"
    }]
}]
report["source_metadata"] = [{"path": "../escaped.txt", "sha256": "ignored"}]
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/path-escape-report.json" --mode apply-all-approved --approve ML-escape >"$TMP_DIR/path-escape.txt" 2>&1; then
  echo "FAIL: apply should reject report paths outside the workspace" >&2
  exit 1
fi
grep -q "Path escapes workspace" "$TMP_DIR/path-escape.txt" || {
  echo "FAIL: workspace escape failure output missing" >&2
  exit 1
}
grep -q '^outside$' "$TMP_DIR/escaped.txt" || {
  echo "FAIL: escaped target should remain unchanged" >&2
  exit 1
}

echo "apply workflow checks passed"
