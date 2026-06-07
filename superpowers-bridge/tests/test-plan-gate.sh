#!/usr/bin/env bash

# Test case for US2: Plan-gate validation.
# Verifies that superpowers-bridge/commands/plan-gate.md defines strict checks
# for placeholders, task granularity, and injects the mandatory SDD directive.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN_GATE_CMD="$ROOT_DIR/superpowers-bridge/commands/plan-gate.md"

echo "Running US2 Plan Gate Test..."

if [ ! -f "$PLAN_GATE_CMD" ]; then
    echo "FAIL: plan-gate.md does not exist"
    exit 1
fi

# 1. Check placeholder instruction
if ! grep -q "TODO" "$PLAN_GATE_CMD" || ! grep -q "TKTK" "$PLAN_GATE_CMD" || ! grep -q "???" "$PLAN_GATE_CMD"; then
    echo "FAIL: plan-gate.md does not check for placeholders (TODO, TKTK, ???)"
    exit 1
fi

# 2. Check task granularity instruction (2-5 minutes)
if ! grep -q "2-5" "$PLAN_GATE_CMD"; then
    echo "FAIL: plan-gate.md does not check for task granularity of 2-5 minutes"
    exit 1
fi

# 3. Check SDD worker directive injection instruction
if ! grep -q "For agentic workers" "$PLAN_GATE_CMD"; then
    echo "FAIL: plan-gate.md does not inject the SDD worker directive"
    exit 1
fi

# 4. Check writing-plans skill resolution description
if ! grep -q "writing-plans/SKILL.md" "$PLAN_GATE_CMD" || ! grep -q "Layer 1: Native writing-plans" "$PLAN_GATE_CMD"; then
    echo "FAIL: plan-gate.md does not define resolution and preferred usage of writing-plans skill"
    exit 1
fi

echo "PASS: Plan gate instructions verified in plan-gate.md"
