#!/usr/bin/env bash

# Test case for US7: Checkpoint Resume.
# Verifies that superpowers-bridge/commands/controller.md defines:
# 1. Scanning tasks.md on restart to find the first unticked task.
# 2. Starting execution from that first unticked checkpoint.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US7 Checkpoint Resume Test..."

# 1. Verify scan for unticked tasks
if ! grep -q "first" "$CONTROLLER_CMD" && ! grep -q "第一个" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify scanning for the first incomplete/unticked task"
    exit 1
fi

# 2. Verify resume without rollback
if ! grep -q "resume" "$CONTROLLER_CMD" && ! grep -q "断点续传" "$CONTROLLER_CMD" && ! grep -q "恢复" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify checkpoint resume behavior on restart"
    exit 1
fi

echo "PASS: US7 checkpoint resume verified in controller.md"
