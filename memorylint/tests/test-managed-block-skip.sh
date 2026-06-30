#!/usr/bin/env bash
# US1 / FR-001, FR-002, FR-003: rule extraction skips agent-context managed blocks
# across every configured context file (plural context_files and singular context_file).

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
END="<!-- SPECKIT END -->"

make_config() {  # $1 = workspace dir, $2 = yaml key block (context_file(s) lines)
  local ws="$1"; local keyblock="$2"
  mkdir -p "$ws/.specify/extensions/agent-context"
  {
    printf '%s\n' "$keyblock"
    printf 'context_markers:\n  start: %s\n  end: %s\n' "$START" "$END"
  } > "$ws/.specify/extensions/agent-context/agent-context-config.yml"
}

audit_json() {  # $1 = workspace -> prints findings JSON sources+evidence joined
  "$PYTHON_BIN" "$AUDIT_SCRIPT" "$1" --format json 2>/dev/null
}

assert_absent() {  # $1 = json, $2 = needle
  if printf '%s' "$1" | grep -q "$2"; then
    echo "FAIL: managed-block content '$2' leaked into findings" >&2; exit 1
  fi
}
assert_present() {  # $1 = json, $2 = needle
  if ! printf '%s' "$1" | grep -q "$2"; then
    echo "FAIL: expected out-of-block finding '$2' missing" >&2; exit 1
  fi
}

# --- Case 1: singular context_file (AGENTS.md) ---
WS1="$TMP_DIR/singular"
mkdir -p "$WS1"
cat > "$WS1/AGENTS.md" <<EOF
# Rules

- Always read ./outside-missing.md before starting

$START
- Plan: specs/x/plan.md
- Always read ./inside-missing.md before starting
$END
EOF
make_config "$WS1" 'context_file: AGENTS.md'
J1="$(audit_json "$WS1")"
assert_present "$J1" "outside-missing.md"
assert_absent "$J1" "inside-missing.md"

# --- Case 2: plural context_files (AGENTS.md + CLAUDE.md) ---
WS2="$TMP_DIR/plural"
mkdir -p "$WS2"
cat > "$WS2/AGENTS.md" <<EOF
# Rules

- Always read ./outside-missing.md before starting

$START
- Always read ./agents-inside-missing.md before starting
$END
EOF
cat > "$WS2/CLAUDE.md" <<EOF
# Claude Rules

$START
- Always read ./claude-inside-missing.md before starting
$END
EOF
make_config "$WS2" $'context_files:\n  - AGENTS.md\n  - CLAUDE.md'
J2="$(audit_json "$WS2")"
assert_present "$J2" "outside-missing.md"
assert_absent "$J2" "agents-inside-missing.md"
assert_absent "$J2" "claude-inside-missing.md"

# --- Case 3: defensive detection (markers present, no config entry for the file) ---
WS3="$TMP_DIR/defensive"
mkdir -p "$WS3"
cat > "$WS3/AGENTS.md" <<EOF
# Rules

- Always read ./outside-missing.md before starting

$START
- Always read ./defensive-inside-missing.md before starting
$END
EOF
# No agent-context config at all -> rely on physical marker detection.
J3="$(audit_json "$WS3")"
assert_present "$J3" "outside-missing.md"
assert_absent "$J3" "defensive-inside-missing.md"

echo "PASS: test-managed-block-skip.sh"
