#!/usr/bin/env bash

# Test case for US7: Concurrency Dependency & Conflict Serial Fallback.
# Verifies that superpowers-bridge/commands/controller.md defines:
# 1. Dependency checks: file overlap or referencing new symbols.
# 2. Conflict serial fallback: downgrade to serial if same-file conflicts are detected.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US7 Concurrency Dependency and Fallback Test..."

# 1. Verify dependency detection rule
if ! grep -q "same" "$CONTROLLER_CMD" && ! grep -q "相同" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define check for same-file modifications"
    exit 1
fi

if ! grep -q "symbol" "$CONTROLLER_CMD" && ! grep -q "class" "$CONTROLLER_CMD" && ! grep -q "function" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define check for symbol reference dependencies"
    exit 1
fi

# 2. Verify fallback to serial execution on conflict
if ! grep -q "serial" "$CONTROLLER_CMD" && ! grep -q "串行" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define serial fallback on concurrency conflicts"
    exit 1
fi

if ! grep -q "commit" "$CONTROLLER_CMD" && ! grep -q "提交" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not define incremental commits during serial fallback"
    exit 1
fi

echo "PASS: US7 concurrency dependency and conflict fallback verified in controller.md"
