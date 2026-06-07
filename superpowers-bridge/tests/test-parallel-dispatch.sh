#!/usr/bin/env bash

# Test case for US6: Parallel task dispatch.
# Verifies that superpowers-bridge/commands/controller.md defines detection of the [P] marker
# and parallel dispatching using concurrent invoke_subagent calls.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US6 Parallel Dispatch Test..."

# 1. Verify [P] marker checking logic in controller.md
if ! grep -q "\[P\]" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not check for [P] markers"
    exit 1
fi

# 2. Verify concurrency array / multi-agent dispatch logic
if ! grep -q "concurrent" "$CONTROLLER_CMD" && ! grep -q "concurrently" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not describe concurrent subagent dispatching"
    exit 1
fi

if ! grep -q "Subagents" "$CONTROLLER_CMD" && ! grep -q "multiple subagent" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define dispatching multiple subagents in a single invoke_subagent call"
    exit 1
fi

echo "PASS: US6 parallel dispatch logic verified"
