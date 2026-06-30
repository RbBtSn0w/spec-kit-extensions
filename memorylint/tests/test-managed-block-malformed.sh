#!/usr/bin/env bash
# US1 / FR-006, C4: an unterminated managed block is skipped to EOF, a warning naming the
# file is emitted, and no in-block content leaks into findings.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then echo "python3";
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then echo "python";
  else echo "ERROR: requires Python 3 on PATH" >&2; exit 1; fi
}
PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

START="<!-- SPECKIT START -->"

WS="$TMP_DIR/malformed"
mkdir -p "$WS"
cat > "$WS/AGENTS.md" <<EOF
# Rules

- Always read ./outside-missing.md before starting

$START
- Always read ./unterminated-inside-missing.md before starting
EOF

STDERR_FILE="$TMP_DIR/stderr.txt"
JSON="$("$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS" --format json 2>"$STDERR_FILE")"

if printf '%s' "$JSON" | grep -q "unterminated-inside-missing.md"; then
  echo "FAIL: unterminated block content leaked into findings" >&2; exit 1
fi
if ! printf '%s' "$JSON" | grep -q "outside-missing.md"; then
  echo "FAIL: out-of-block finding missing" >&2; exit 1
fi
if ! grep -qi "warning" "$STDERR_FILE" || ! grep -q "AGENTS.md" "$STDERR_FILE"; then
  echo "FAIL: expected an unterminated-block warning naming AGENTS.md on stderr" >&2
  cat "$STDERR_FILE" >&2
  exit 1
fi

echo "PASS: test-managed-block-malformed.sh"
