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

# Assertion 2: Check check.md defines installation recovery.
if ! grep -q "Installation Recovery" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must define installation recovery"
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

for required_skill in \
  test-driven-development \
  systematic-debugging \
  receiving-code-review \
  finishing-a-development-branch \
  brainstorming
do
  if ! grep -q -- "--skill $required_skill" "$COMMANDS_DIR/check.md"; then
    echo "FAIL: check.md installation commands must include $required_skill in the bridge contract bundle"
    exit 1
  fi
done

if ! grep -q -- "plugins add obra/superpowers -g" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must include the verified compatible plugin command"
  exit 1
fi

for workflow_skill in executing-plans requesting-code-review writing-plans subagent-driven-development dispatching-parallel-agents; do
  if grep -E -- "--skill $workflow_skill" "$COMMANDS_DIR/check.md" >/dev/null; then
    echo "FAIL: check.md must not install workflow owner $workflow_skill"
    exit 1
  fi
done

if ! grep -q "plugin choice is the compatibility path" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must distinguish full-plugin installation"
  exit 1
fi

# Assertion 6: Check for the required gate's native fallback behavior.
if ! grep -q "native minimum" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must describe the native TDD minimum"
  exit 1
fi

# Assertion 7: Check for optional behavior.
if ! grep -q "optional skill" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must describe optional skills"
  exit 1
fi

# Assertion 8: Check check.md exposes only the focused hook contract.
if ! grep -q "before_implement | /speckit.superb.implementation-gate" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must report the implementation readiness hook"
  exit 1
fi

if grep -Eq "after_tasks|after_implement|after_converge" "$COMMANDS_DIR/check.md"; then
  echo "FAIL: check.md must not report removed lifecycle hooks"
  exit 1
fi

# Test ensure-skills.sh exit codes with invalid inputs (T022 verification)
echo "=== Running Script Interface Validation ==="
if [ -f "$SCRIPTS_DIR/bash/ensure-skills.sh" ]; then
  # Invalid approach option should exit with 3
  if bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --install 4 2>/dev/null; then
    echo "FAIL: ensure-skills.sh did not exit with code 3 on invalid approach"
    exit 1
  fi
  
  # Missing arguments should exit with 3
  if bash "$SCRIPTS_DIR/bash/ensure-skills.sh" 2>/dev/null; then
    echo "FAIL: ensure-skills.sh did not exit with code 3 on missing arguments"
    exit 1
  fi
  
  # Unknown arguments should exit with 3
  if bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --invalid-flag 2>/dev/null; then
    echo "FAIL: ensure-skills.sh did not exit with code 3 on unknown arguments"
    exit 1
  fi
else
  echo "FAIL: ensure-skills.sh does not exist"
  exit 1
fi

echo "SUCCESS: Diagnostic guidance checks passed."
exit 0
