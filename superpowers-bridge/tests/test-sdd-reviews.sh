#!/usr/bin/env bash

# Test case for US4: Two-stage quality review gate.
# Verifies that superpowers-bridge/commands/controller.md implements the Spec Reviewer,
# Quality Reviewer, and the maximum 3 retries feedback loop.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US4 Two-Stage Review Test..."

# 1. Verify Spec Reviewer spawning instruction
if ! grep -q "Spec Reviewer" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define Spec Reviewer subagent"
    exit 1
fi

# 2. Verify Quality Reviewer spawning instruction
if ! grep -q "Quality Reviewer" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define Quality Reviewer subagent"
    exit 1
fi

# 3. Verify maximum 3 retries feedback loop instruction
if ! grep -q "3" "$CONTROLLER_CMD" || ! grep -q "retry" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define a retry limit or feedback loop"
    exit 1
fi

echo "PASS: US4 two-stage review logic verified"
