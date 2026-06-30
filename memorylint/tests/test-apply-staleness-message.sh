#!/usr/bin/env bash
# US1 / FR-004, C5: when a target file changes after audit (e.g. agent-context inserts a
# managed block), apply refuses to write and the failure message directs the user to re-audit.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
APPLY_SCRIPT="$ROOT_DIR/memorylint/scripts/apply_report.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then echo "python3";
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then echo "python";
  else echo "ERROR: requires Python 3 on PATH" >&2; exit 1; fi
}
PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/ws"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/ws" --json-out "$TMP_DIR/report.json" >/dev/null

# Simulate an agent-context update inserting a managed block at the top of AGENTS.md.
ORIG="$(cat "$TMP_DIR/ws/AGENTS.md")"
{
  printf '<!-- SPECKIT START -->\n- Plan: specs/x/plan.md\n<!-- SPECKIT END -->\n\n'
  printf '%s\n' "$ORIG"
} > "$TMP_DIR/ws/AGENTS.md"
cp "$TMP_DIR/ws/AGENTS.md" "$TMP_DIR/agents-before-apply.md"

OUT="$TMP_DIR/apply.txt"
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/report.json" --mode apply-safe-fixes >"$OUT" 2>&1; then
  echo "FAIL: apply should refuse on staleness" >&2; exit 1
fi
grep -q "Staleness check failed" "$OUT" || { echo "FAIL: staleness failure missing" >&2; cat "$OUT" >&2; exit 1; }
if ! grep -qi "audit" "$OUT" || ! grep -qi "re-run\|rerun\|re-audit" "$OUT"; then
  echo "FAIL: staleness message must direct the user to re-run the audit" >&2; cat "$OUT" >&2; exit 1
fi
cmp -s "$TMP_DIR/agents-before-apply.md" "$TMP_DIR/ws/AGENTS.md" || {
  echo "FAIL: staleness refusal modified AGENTS.md" >&2; exit 1;
}

echo "PASS: test-apply-staleness-message.sh"
