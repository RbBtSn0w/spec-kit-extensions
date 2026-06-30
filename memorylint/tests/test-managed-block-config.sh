#!/usr/bin/env bash
# US1 / FR-003, FR-015: invalid agent-context YAML must fail safe to authoritative defaults.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then echo "python3";
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then echo "python";
  else echo "ERROR: requires Python 3 on PATH" >&2; exit 1; fi
}
PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

WS="$TMP_DIR/invalid-config"
mkdir -p "$WS/.specify/extensions/agent-context"
cat > "$WS/AGENTS.md" <<'EOF'
# Rules

- Always read ./outside-missing.md before starting

<!-- SPECKIT START -->
- Always read ./inside-missing.md before starting
<!-- SPECKIT END -->
EOF
cat > "$WS/.specify/extensions/agent-context/agent-context-config.yml" <<'EOF'
context_file: AGENTS.md
context_markers:
  start: CUSTOM START
  end: CUSTOM END
broken: [
EOF

"$PYTHON_BIN" - "$ROOT_DIR/memorylint/scripts" "$WS" <<'PY'
from pathlib import Path
import sys

sys.path.insert(0, sys.argv[1])
from memorylint_core import (  # noqa: E402
    DEFAULT_BLOCK_END,
    DEFAULT_BLOCK_START,
    resolve_managed_block_config,
)

config = resolve_managed_block_config(Path(sys.argv[2]))
if config.start_marker != DEFAULT_BLOCK_START or config.end_marker != DEFAULT_BLOCK_END:
    raise SystemExit(f"FAIL: invalid YAML retained non-default markers: {config}")
if config.managed_files:
    raise SystemExit(f"FAIL: invalid YAML retained managed files: {config.managed_files}")
PY

JSON="$("$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS" --format json 2>/dev/null)"
printf '%s' "$JSON" | grep -q "outside-missing.md" || {
  echo "FAIL: invalid config prevented normal extraction" >&2; exit 1;
}
if printf '%s' "$JSON" | grep -q "inside-missing.md"; then
  echo "FAIL: default-marker managed block leaked after invalid config fallback" >&2; exit 1
fi

echo "PASS: test-managed-block-config.sh"
