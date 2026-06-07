#!/usr/bin/env bash

# Test case for US7: Discoveries Lifecycle and Token Cap.
# Verifies that superpowers-bridge/commands/controller.md defines:
# 1. 4000 token (16KB) memory limit and summary compression.
# 2. Archiving of discoveries to .specify/discoveries_archive/[Timestamp].md on completion.
# 3. Clearing of the active discoveries log.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US7 Discoveries Lifecycle Test..."

# 1. Verify token limit instruction
if ! grep -q "4000" "$CONTROLLER_CMD" || ! grep -q "16KB" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify 4000 token / 16KB memory cap for discoveries"
    exit 1
fi

if ! grep -q "summary" "$CONTROLLER_CMD" && ! grep -q "compress" "$CONTROLLER_CMD" && ! grep -q "压缩" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not describe summary compression for discoveries when limit exceeded"
    exit 1
fi

# 2. Verify archive on completion
if ! grep -q "discoveries_archive" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify archiving to .specify/discoveries_archive/ on completion"
    exit 1
fi

# 3. Verify clearing active discoveries log
if ! grep -q "clear" "$CONTROLLER_CMD" && ! grep -q "清空" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not specify clearing the active discoveries log"
    exit 1
fi

echo "PASS: US7 discoveries lifecycle and token limit verified in controller.md"
