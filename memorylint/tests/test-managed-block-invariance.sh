#!/usr/bin/env bash
# US1 / FR-005, C6 + absent-file edge (C5): with no agent-context (no config, no markers)
# behavior is unchanged; and a config pointing at a non-existent context file is a no-op
# (no error, normal findings preserved).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then echo "python3";
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then echo "python";
  else echo "ERROR: requires Python 3 on PATH" >&2; exit 1; fi
}
PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Baseline: repeated audit and report-only apply are byte-for-byte stable without agent-context.
WS_BASE="$TMP_DIR/no-agent-context"
cp -R "$FIXTURES_DIR/no-agent-context" "$WS_BASE"
BASE_ONE="$TMP_DIR/baseline-one.json"
BASE_TWO="$TMP_DIR/baseline-two.json"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS_BASE" --json-out "$BASE_ONE" >/dev/null
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS_BASE" --json-out "$BASE_TWO" >/dev/null
cmp -s "$BASE_ONE" "$BASE_TWO" || {
  echo "FAIL: no-agent-context audit output is not byte-for-byte stable" >&2; exit 1;
}

APPLY_SCRIPT="$ROOT_DIR/memorylint/scripts/apply_report.py"
"$PYTHON_BIN" "$APPLY_SCRIPT" "$BASE_ONE" --mode report-only > "$TMP_DIR/apply-one.txt"
"$PYTHON_BIN" "$APPLY_SCRIPT" "$BASE_ONE" --mode report-only > "$TMP_DIR/apply-two.txt"
cmp -s "$TMP_DIR/apply-one.txt" "$TMP_DIR/apply-two.txt" || {
  echo "FAIL: no-agent-context apply output is not byte-for-byte stable" >&2; exit 1;
}

# Absent-file edge: config names a context file that does not exist -> no error, findings intact.
WS="$TMP_DIR/absent"
cp -R "$FIXTURES_DIR/stale-command" "$WS"
mkdir -p "$WS/.specify/extensions/agent-context"
cat > "$WS/.specify/extensions/agent-context/agent-context-config.yml" <<'EOF'
context_file: DOES-NOT-EXIST.md
context_markers:
  start: <!-- SPECKIT START -->
  end: <!-- SPECKIT END -->
EOF
ABSENT="$("$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS" --format json 2>/dev/null)"
printf '%s' "$ABSENT" | grep -q "deploy.sh" || { echo "FAIL: absent-context-file config altered findings" >&2; exit 1; }

echo "PASS: test-managed-block-invariance.sh"
