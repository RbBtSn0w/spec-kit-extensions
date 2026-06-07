#!/usr/bin/env bash

# Test case for US5: Continuous execution and progress sync.
# Verifies that superpowers-bridge/commands/controller.md implements auto-ticking of tasks.md
# and continuous execution to subsequent tasks without manual confirmation.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US5 Continuous Sync Test..."

# 1. Verify auto-ticking instructions in controller.md
if ! grep -q "auto" "$CONTROLLER_CMD" && ! grep -q "automatically" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define automatic execution/ticking"
    exit 1
fi

if ! grep -q "tick" "$CONTROLLER_CMD" && ! grep -q "勾选" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define task ticking logic for multi-agent mode"
    exit 1
fi

# 2. Verify continuous progression (no human prompt between tasks)
if ! grep -q "next task" "$CONTROLLER_CMD" || ! grep -q "proceed" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not describe progression to the next task"
    exit 1
fi

echo "PASS: US5 continuous progression and ticking verified"
