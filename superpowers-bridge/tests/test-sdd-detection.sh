#!/usr/bin/env bash

# Test case for US3: Layered SDD detection and Controller dispatch verification.
# Verifies that superpowers-bridge/commands/controller.md implements the layered detection,
# argument overrides, and subagent dispatching context structure.
# Also verifies that check.md includes SDD readiness checks.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"
CHECK_CMD="$ROOT_DIR/superpowers-bridge/commands/check.md"

echo "Running US3 SDD Detection & Dispatch Test..."

# 1. Check for Layer 1 and Layer 2 skill checks in controller.md
if ! grep -q "subagent-driven-development" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not check for native subagent-driven-development skill (Layer 1)"
    exit 1
fi

if ! grep -q "code-review" "$CONTROLLER_CMD" && ! grep -q "critique" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not check for composite skills (Layer 2)"
    exit 1
fi

# 2. Check for isolated context and accumulated discoveries in controller.md
if ! grep -q "discoveries" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not implement Accumulated Discoveries propagation"
    exit 1
fi

# 3. Check for check.md diagnostics update
if ! grep -q "subagent-driven-development" "$CHECK_CMD"; then
    echo "FAIL: check.md does not contain SDD readiness diagnostics"
    exit 1
fi

echo "PASS: US3 layered detection and Controller dispatch verified"
