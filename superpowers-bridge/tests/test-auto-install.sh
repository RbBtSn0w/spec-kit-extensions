#!/usr/bin/env bash

# superpowers-bridge/tests/test-auto-install.sh
# Test verification for User Story 3 (Interactive auto-install flows and interface validation).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "=== Running User Story 3: Auto-Installation Flow & Interface Tests ==="

# 1. Test check-prereqs interface execution
echo "Testing check-prereqs execution..."
output=$(bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --check-prereqs)
echo "Output: $output"
if ! echo "$output" | grep -q '"npx_available"'; then
  echo "FAIL: ensure-skills.sh --check-prereqs did not output npx json"
  exit 1
fi

# 2. Test input validations (T022 verification)
echo "Testing input validations..."

# Test approach 0 (out of bounds)
set +e
bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --install 0 2>/dev/null
exit_code=$?
set -e
if [ "$exit_code" -ne 3 ]; then
  echo "FAIL: Expected exit code 3 for approach 0, got $exit_code"
  exit 1
fi

# Test approach 4 (out of bounds)
set +e
bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --install 4 2>/dev/null
exit_code=$?
set -e
if [ "$exit_code" -ne 3 ]; then
  echo "FAIL: Expected exit code 3 for approach 4, got $exit_code"
  exit 1
fi

# Test missing approach value
set +e
bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --install 2>/dev/null
exit_code=$?
set -e
if [ "$exit_code" -ne 3 ]; then
  echo "FAIL: Expected exit code 3 for missing approach value, got $exit_code"
  exit 1
fi

echo "SUCCESS: Auto-installation and interface validation tests passed."
exit 0
