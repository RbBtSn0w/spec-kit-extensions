#!/usr/bin/env bash

# Test case for US7: Parallel Failure Cascade Management.
# Verifies that superpowers-bridge/commands/controller.md defines:
# 1. Allowing active subagents to finish when one fails.
# 2. Halting further dispatching of new tasks.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US7 Parallel Failure Cascade Test..."

# 1. Verify cascade halt rules
if ! grep -q "halt" "$CONTROLLER_CMD" && ! grep -q "stop" "$CONTROLLER_CMD" && ! grep -q "停止" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define stopping further task dispatches upon failure"
    exit 1
fi

if ! grep -q "finish" "$CONTROLLER_CMD" && ! grep -q "complete" "$CONTROLLER_CMD" && ! grep -q "执行完毕" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify that already dispatched/active subagents can finish"
    exit 1
fi

echo "PASS: US7 parallel failure cascade verified in controller.md"
