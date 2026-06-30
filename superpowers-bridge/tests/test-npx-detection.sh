#!/usr/bin/env bash

# superpowers-bridge/tests/test-npx-detection.sh
# Test verification for User Story 2 (inline error messages and npx detection fallback).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/commands"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "=== Running User Story 2: npx Pre-detection & Inline Guidance Tests ==="

# 1. Test install-skills.sh with simulated missing npx on PATH
echo "Testing install-skills.sh npx detection fallback..."
(
  # Override PATH to hide npx
  export PATH="/usr/bin:/bin"
  
  # Allow the command to fail/exit with 2 under set -e
  set +e
  output=$(bash "$SCRIPTS_DIR/bash/install-skills.sh" --check-only 2>&1)
  exit_status=$?
  set -e
  
  echo "Simulated exit status: $exit_status"
  echo "Simulated output: $output"
  
  if [ "$exit_status" -ne 2 ]; then
    echo "FAIL: install-skills.sh did not exit with code 2 when npx is missing (got $exit_status)"
    exit 1
  fi
  
  if ! echo "$output" | grep -q '"npx_available": false'; then
    echo "FAIL: install-skills.sh did not output npx_available: false"
    exit 1
  fi
)

# 2. Verify all bridge command Markdown files have inline guidance and stop rules
echo "Testing inline command warnings..."

COMMAND_FILES=(
  "brainstorm.md"
  "controller.md"
  "debug.md"
  "finish.md"
  "verify.md"
)

for file in "${COMMAND_FILES[@]}"; do
  filepath="$COMMANDS_DIR/$file"
  if [ ! -f "$filepath" ]; then
    echo "FAIL: $file does not exist"
    exit 1
  fi

  # Check that command file references the install-skills.sh print-guidance script
  if ! grep -q "install-skills.sh.*--print-guidance" "$filepath"; then
    echo "FAIL: $file must delegate missing skill guidance output to install-skills.sh --print-guidance"
    exit 1
  fi
done

# 3. Verify that running install-skills.sh --print-guidance outputs the correct details
echo "Testing print-guidance script output..."
guidance_out=$(bash "$SCRIPTS_DIR/bash/install-skills.sh" --print-guidance)

if ! echo "$guidance_out" | grep -q "https://github.com/RbBtSn0w/adg"; then
  echo "FAIL: install-skills.sh --print-guidance must reference the adg repository URL: https://github.com/RbBtSn0w/adg"
  exit 1
fi

if ! echo "$guidance_out" | grep -q "npx adg plugins add"; then
  echo "FAIL: install-skills.sh --print-guidance must include the plugins installation command"
  exit 1
fi

echo "SUCCESS: npx pre-detection and inline warnings validation passed."
exit 0
