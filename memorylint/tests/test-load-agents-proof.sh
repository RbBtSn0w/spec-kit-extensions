#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOAD_SCRIPT="$ROOT_DIR/memorylint/scripts/load_agents_state.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-load-agents-proof.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$LOAD_SCRIPT" "$FIXTURES_DIR/clean-repo" <<'PY'
import json
import subprocess
import sys

payload = json.loads(
    subprocess.check_output([sys.executable, sys.argv[1], sys.argv[2]], text=True)
)

required = {"workspace_root", "agents_path", "agents_sha256", "rule_count", "sections", "rule_summaries"}
missing = required.difference(payload.keys())
if missing:
    raise SystemExit(f"FAIL: load-agents payload missing keys: {sorted(missing)}")

if payload["agents_path"] != "AGENTS.md":
    raise SystemExit("FAIL: load-agents should target the root AGENTS.md")

if payload["rule_count"] <= 0 or not payload["rule_summaries"]:
    raise SystemExit("FAIL: load-agents payload should include extracted rule summaries")

print("load-agents proof checks passed")
PY
