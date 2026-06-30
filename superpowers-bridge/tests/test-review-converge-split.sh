#!/usr/bin/env bash
# US3 / FR-010: review delegates requirement-coverage-gap task creation to /speckit-converge
# (delivery-stage remediation) while keeping its own focus on task quality / TDD-readiness /
# plan↔task consistency (plan-stage prevention).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REVIEW="$ROOT_DIR/superpowers-bridge/commands/review.md"

[ -f "$REVIEW" ] || { echo "FAIL: review.md missing" >&2; exit 1; }

# 1. Coverage-gap remediation must delegate to converge, not recommend manual task additions.
"$(command -v python3 || command -v python)" - "$REVIEW" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
normal_mode_rows = [
    line for line in text.splitlines()
    if line.startswith("|") and "coverage (Normal Mode)" in line
]
if len(normal_mode_rows) != 1:
    raise SystemExit(f"FAIL: expected one Normal Mode coverage-gap row, got {len(normal_mode_rows)}")
if "`/speckit-converge`" not in normal_mode_rows[0]:
    raise SystemExit("FAIL: Normal Mode coverage-gap row must route to /speckit-converge")

decision_schema = next(
    (
        line for line in text.splitlines()
        if line.startswith("**Next command:**") and " | " in line
    ),
    "",
)
if "`/speckit-converge`" not in decision_schema:
    raise SystemExit("FAIL: workflow decision schema must allow /speckit-converge")
PY
if grep -qi "adding missing tasks to tasks.md through the Spec Kit task flow" "$REVIEW"; then
  echo "FAIL: review.md still recommends manual task additions for coverage gaps" >&2; exit 1
fi

# 2. Quality/TDD-readiness and plan↔task BLOCKED outcomes must be retained.
grep -qi "TDD" "$REVIEW" || { echo "FAIL: review.md lost TDD-readiness focus" >&2; exit 1; }
grep -q "BLOCKED" "$REVIEW" || { echo "FAIL: review.md lost BLOCKED outcomes" >&2; exit 1; }
grep -qi "plan_task_mismatch\|plan.*task.*mismatch\|plan↔task" "$REVIEW" || {
  echo "FAIL: review.md lost plan↔task mismatch handling" >&2; exit 1; }

echo "PASS: test-review-converge-split.sh"
