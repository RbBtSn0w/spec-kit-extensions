#!/usr/bin/env bash

# Test case for US1: Single-agent fallback verification.
# Verifies that superpowers-bridge/commands/controller.md defines a clear fallback logic
# when define_subagent tool is not available.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTROLLER_CMD="$ROOT_DIR/superpowers-bridge/commands/controller.md"

echo "Running US1 Fallback Test..."

# We expect the markdown to contain instructions for checking if subagents are supported
# (e.g. checking define_subagent or invoke_subagent tool availability)
# and falling back to RED-GREEN-REFACTOR.

if ! grep -q "define_subagent" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not check define_subagent tool availability"
    exit 1
fi

if ! grep -q "fallback" "$CONTROLLER_CMD" && ! grep -q "降级" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not mention fallback or降级 logic"
    exit 1
fi

# 3. Check executing-plans detection description
if ! grep -q "executing-plans/SKILL.md" "$CONTROLLER_CMD" || ! grep -q "Layer 1: Native executing-plans" "$CONTROLLER_CMD"; then
    echo "FAIL: controller.md does not check for or use optional executing-plans skill in fallback mode"
    exit 1
fi

echo "PASS: Fallback instructions verified in controller.md"
