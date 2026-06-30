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

# Baseline: a known fixture with no agent-context must still produce its stale-ref findings.
BASE="$("$PYTHON_BIN" "$AUDIT_SCRIPT" "$FIXTURES_DIR/stale-command" --format json 2>/dev/null)"
printf '%s' "$BASE" | grep -q "deploy.sh" || { echo "FAIL: baseline finding lost (deploy.sh)" >&2; exit 1; }

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
