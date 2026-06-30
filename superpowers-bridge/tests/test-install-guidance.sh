#!/usr/bin/env bash

# superpowers-bridge/tests/test-install-guidance.sh
# Test verification for User Story 1 (check diagnostics guidance) and User Story 3 (Summary).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/commands"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "=== Running User Story 1: Diagnostic Guidance Tests ==="

# Assertion 1: Check commands/check.md exists
if [ ! -f "$COMMANDS_DIR/check.md" ]; then
  echo "FAIL: check.md does not exist"
  exit 1
fi

# Assertion 2: Check check.md contains the Guidance column header
if ! grep -q "| Guidance |" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md table must contain a 'Guidance' column"
  exit 1
fi

# Assertion 3: Check check.md contains the repository URL
if ! grep -q "https://github.com/RbBtSn0w/adg" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must reference the adg repository URL: https://github.com/RbBtSn0w/adg"
  exit 1
fi

# Assertion 4: Check check.md contains the Quick Setup templates and three approaches
if ! grep -q "npx adg plugins add" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must include the plugins installation command"
  exit 1
fi

if ! grep -q "npx adg skills add" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must include the skills installation commands"
  exit 1
fi

# Assertion 5: Check check.md contains --skill arguments to limit scope
if ! grep -q -- "--skill test-driven-development" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md installation commands must restrict scope using --skill parameters"
  exit 1
fi

# Assertion 6: Check for Hard Requirements grouping under Quick Setup (T021)
if ! grep -q "Hard Requirements" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must group Hard Requirements under Quick Setup"
  exit 1
fi

# Assertion 7: Check for Optional Skills grouping under Quick Setup (T021)
if ! grep -q "Optional Skills" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must group Optional Skills under Quick Setup"
  exit 1
fi

# Test install-skills.sh exit codes with invalid inputs (T022 verification)
echo "=== Running Script Interface Validation ==="
if [ -f "$SCRIPTS_DIR/bash/install-skills.sh" ]; then
  # Invalid approach option should exit with 3
  if bash "$SCRIPTS_DIR/bash/install-skills.sh" --approach 4 2>/dev/null; then
    echo "FAIL: install-skills.sh did not exit with code 3 on invalid approach"
    exit 1
  fi
  
  # Missing arguments should exit with 3
  if bash "$SCRIPTS_DIR/bash/install-skills.sh" 2>/dev/null; then
    echo "FAIL: install-skills.sh did not exit with code 3 on missing arguments"
    exit 1
  fi
  
  # Unknown arguments should exit with 3
  if bash "$SCRIPTS_DIR/bash/install-skills.sh" --invalid-flag 2>/dev/null; then
    echo "FAIL: install-skills.sh did not exit with code 3 on unknown arguments"
    exit 1
  fi
else
  echo "FAIL: install-skills.sh does not exist"
  exit 1
fi

echo "SUCCESS: Diagnostic guidance checks passed."
exit 0
