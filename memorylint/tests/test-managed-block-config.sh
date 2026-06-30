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
ws = Path(sys.argv[2])
config_path = ws / ".specify/extensions/agent-context/agent-context-config.yml"

def test_config(content, yaml_available=True):
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text(content, encoding="utf-8")

    # Simulate yaml module availability/unavailability
    if not yaml_available:
        sys.modules['yaml'] = None
    else:
        sys.modules.pop('yaml', None)

    if 'memorylint_core' in sys.modules:
        del sys.modules['memorylint_core']

    from memorylint_core import (  # noqa: E402
        DEFAULT_BLOCK_END,
        DEFAULT_BLOCK_START,
        resolve_managed_block_config,
    )

    config = resolve_managed_block_config(ws)
    if config.start_marker != DEFAULT_BLOCK_START or config.end_marker != DEFAULT_BLOCK_END:
        raise SystemExit(f"FAIL: invalid YAML (yaml_avail={yaml_available}) retained non-default markers: {config}")
    if config.managed_files:
        raise SystemExit(f"FAIL: invalid YAML (yaml_avail={yaml_available}) retained managed files: {config.managed_files}")

# Cases to test:
# 1. Flow sequence error (original)
# 2. Invalid indentation under context_markers
# 3. Missing mapping colons
invalid_cases = [
    """context_file: AGENTS.md
context_markers:
  start: CUSTOM START
  end: CUSTOM END
broken: [""",
    """context_markers:
start: CUSTOM START""",
    """context_file AGENTS.md""",
]

# Supported behavior: unknown keys must be gracefully ignored, preserving valid keys
ignore_cases = [
    """context_file: AGENTS.md
unknown_key: true""",
    """context_file: AGENTS.md
unknown_key:
  nested_key: value""",
]

def test_ignore_config(content, yaml_available=True):
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text(content, encoding="utf-8")

    # Simulate yaml module availability/unavailability
    if not yaml_available:
        sys.modules['yaml'] = None
    else:
        sys.modules.pop('yaml', None)

    if 'memorylint_core' in sys.modules:
        del sys.modules['memorylint_core']

    from memorylint_core import (  # noqa: E402
        DEFAULT_BLOCK_END,
        DEFAULT_BLOCK_START,
        resolve_managed_block_config,
    )

    config = resolve_managed_block_config(ws)
    if config.start_marker != DEFAULT_BLOCK_START or config.end_marker != DEFAULT_BLOCK_END:
        raise SystemExit(f"FAIL: ignore YAML (yaml_avail={yaml_available}) changed markers: {config}")
    if config.managed_files != ('AGENTS.md',):
        raise SystemExit(f"FAIL: ignore YAML (yaml_avail={yaml_available}) did not retain managed files: {config.managed_files}")

for content in invalid_cases:
    test_config(content, yaml_available=True)
    test_config(content, yaml_available=False)

for content in ignore_cases:
    test_ignore_config(content, yaml_available=True)
    test_ignore_config(content, yaml_available=False)

# Restore normal module state
sys.modules.pop('yaml', None)
print("Python config assertions passed")
PY

# Set up an invalid config with bad indentation for the final integration check
cat > "$WS/.specify/extensions/agent-context/agent-context-config.yml" <<'EOF'
context_markers:
start: CUSTOM START
EOF

JSON="$("$PYTHON_BIN" "$AUDIT_SCRIPT" "$WS" --format json 2>/dev/null)"
printf '%s' "$JSON" | grep -q "outside-missing.md" || {
  echo "FAIL: invalid config prevented normal extraction" >&2; exit 1;
}
if printf '%s' "$JSON" | grep -q "inside-missing.md"; then
  echo "FAIL: default-marker managed block leaked after invalid config fallback" >&2; exit 1
fi

echo "PASS: test-managed-block-config.sh"
