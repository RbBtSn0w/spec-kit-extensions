#!/usr/bin/env bash

# superpowers-bridge/tests/test-npx-detection.sh
# Test verification for User Story 2 (inline error messages and npx detection fallback).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/commands"
SCRIPTS_DIR="$ROOT_DIR/scripts"
EXPECTED_PRINT_GUIDANCE='bash .specify/extensions/superb/scripts/bash/ensure-skills.sh --print-guidance'
EXPECTED_CHECK_ONLY='bash .specify/extensions/superb/scripts/bash/ensure-skills.sh --check-prereqs'
EXPECTED_APPROACH='bash .specify/extensions/superb/scripts/bash/ensure-skills.sh --install <selection>'
EXPECTED_RESOLVE='bash .specify/extensions/superb/scripts/bash/resolve-skill.sh --skill'

echo "=== Running User Story 2: npx Pre-detection & Inline Guidance Tests ==="

# 1. Test ensure-skills.sh with simulated missing npx on PATH
echo "Testing ensure-skills.sh npx detection fallback..."
(
  # Allow the command to fail/exit with 2 under set -e
  set +e
  output=$(PATH="" /bin/bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --check-prereqs 2>&1)
  exit_status=$?
  set -e
  
  echo "Simulated exit status: $exit_status"
  echo "Simulated output: $output"
  
  if [ "$exit_status" -ne 2 ]; then
    echo "FAIL: ensure-skills.sh did not exit with code 2 when npx is missing (got $exit_status)"
    exit 1
  fi
  
  if ! echo "$output" | grep -q '"npx_available": false'; then
    echo "FAIL: ensure-skills.sh did not output npx_available: false"
    exit 1
  fi
)

# 2. Verify all bridge command Markdown files have inline guidance and stop rules
echo "Testing inline command warnings..."

COMMAND_FILES=(
  "brainstorm.md"
  "debug.md"
  "finish.md"
  "respond.md"
)

for file in "${COMMAND_FILES[@]}"; do
  filepath="$COMMANDS_DIR/$file"
  if [ ! -f "$filepath" ]; then
    echo "FAIL: $file does not exist"
    exit 1
  fi

  # Check that command file references the ensure-skills.sh print-guidance script
  if ! grep -Fq "$EXPECTED_PRINT_GUIDANCE" "$filepath"; then
    echo "FAIL: $file must include the exact print-guidance recovery command: $EXPECTED_PRINT_GUIDANCE"
    exit 1
  fi

done

# 3. Verify that running ensure-skills.sh --print-guidance outputs the correct details
echo "Testing print-guidance script output..."
guidance_out=$(bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --print-guidance)

if ! echo "$guidance_out" | grep -q "https://github.com/RbBtSn0w/adg"; then
  echo "FAIL: ensure-skills.sh --print-guidance must reference the adg repository URL: https://github.com/RbBtSn0w/adg"
  exit 1
fi

if ! echo "$guidance_out" | grep -q "npx adg plugins add"; then
  echo "FAIL: ensure-skills.sh --print-guidance must include the plugins installation command"
  exit 1
fi

for required_skill in \
  test-driven-development \
  brainstorming \
  systematic-debugging \
  receiving-code-review \
  finishing-a-development-branch
do
  if ! echo "$guidance_out" | grep -q -- "--skill $required_skill"; then
    echo "FAIL: ensure-skills.sh --print-guidance must include $required_skill in the bridge contract bundle"
    exit 1
  fi
done

if ! echo "$guidance_out" | grep -q "plugins add obra/superpowers -g"; then
  echo "FAIL: ensure-skills.sh --print-guidance must include the compatible plugin install"
  exit 1
fi

for workflow_skill in dispatching-parallel-agents requesting-code-review executing-plans writing-plans subagent-driven-development; do
  if echo "$guidance_out" | grep -q -- "--skill $workflow_skill"; then
    echo "FAIL: guidance must not include workflow owner $workflow_skill"
    exit 1
  fi
done

echo "SUCCESS: npx pre-detection and inline warnings validation passed."
exit 0
