#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-review-regressions.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$ROOT_DIR" <<'PY'
from pathlib import Path
import os
import sys

root = Path(sys.argv[1])
memorylint = (root / "memorylint/extension.yml").read_text(encoding="utf-8")
for expected in (
    'id: "memorylint"',
    'name: "speckit.memorylint.audit"',
    'name: "speckit.memorylint.apply"',
    'name: "speckit.memorylint.load-agents"',
    'before_constitution:',
    'after_constitution:',
    'before_plan:',
    'optional: false',
):
    if expected not in memorylint:
        raise SystemExit(f"MemoryLint independence contract changed: missing {expected}")
if "superb" in memorylint.lower() or "superpowers" in memorylint.lower():
    raise SystemExit("MemoryLint must not depend on Superb or Superpowers")
if os.environ.get("MEMORYLINT_ONLY") == "1":
    print("MemoryLint independence contract passed")
    raise SystemExit(0)
PY

bash "$ROOT_DIR/superpowers-bridge/tests/test-capability-contract.sh"
bash "$ROOT_DIR/superpowers-bridge/tests/test-lifecycle-routing.sh"
bash "$ROOT_DIR/superpowers-bridge/tests/test-implementation-gate.sh"
bash "$ROOT_DIR/superpowers-bridge/tests/test-command-boundaries.sh"
bash "$ROOT_DIR/superpowers-bridge/tests/test-workflow-contract.sh"

echo "review regressions passed"
