#!/usr/bin/env bash
# US3 / FR-010: review delegates requirement-coverage-gap task creation to /speckit-converge
# (delivery-stage remediation) while keeping its own focus on task quality / TDD-readiness /
# plan↔task consistency (plan-stage prevention).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REVIEW="$ROOT_DIR/superpowers-bridge/commands/review.md"

[ -f "$REVIEW" ] || { echo "FAIL: review.md missing" >&2; exit 1; }

# 1. Coverage-gap remediation must delegate to converge, not recommend manual task additions.
if ! grep -qi "converge" "$REVIEW"; then
  echo "FAIL: review.md must delegate coverage-gap remediation to /speckit-converge" >&2; exit 1
fi
if grep -qi "adding missing tasks to tasks.md through the Spec Kit task flow" "$REVIEW"; then
  echo "FAIL: review.md still recommends manual task additions for coverage gaps" >&2; exit 1
fi

# 2. Quality/TDD-readiness and plan↔task BLOCKED outcomes must be retained.
grep -qi "TDD" "$REVIEW" || { echo "FAIL: review.md lost TDD-readiness focus" >&2; exit 1; }
grep -q "BLOCKED" "$REVIEW" || { echo "FAIL: review.md lost BLOCKED outcomes" >&2; exit 1; }
grep -qi "plan_task_mismatch\|plan.*task.*mismatch\|plan↔task" "$REVIEW" || {
  echo "FAIL: review.md lost plan↔task mismatch handling" >&2; exit 1; }

echo "PASS: test-review-converge-split.sh"
