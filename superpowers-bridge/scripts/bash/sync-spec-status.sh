#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-spec-status.sh --status <Tasked|Implementing|Verified|In Review|Abandoned>

Resolves the active Spec Kit feature spec using the project's own
check-prerequisites script and synchronizes a canonical:

**Status**: <State>

line in the feature's spec.md.
EOF
}

STATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)
      STATE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$STATE" in
  "Tasked"|"Implementing"|"Verified"|"In Review"|"Abandoned")
    ;;
  *)
    echo "ERROR: Invalid or missing --status value: ${STATE:-<empty>}" >&2
    usage >&2
    exit 1
    ;;
esac

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "ERROR: sync-spec-status.sh requires python3 or python on PATH" >&2
  exit 1
fi

resolve_feature_json() {
  local output

  if [[ ! -x scripts/bash/check-prerequisites.sh ]]; then
    echo "ERROR: scripts/bash/check-prerequisites.sh not found or not executable in project root" >&2
    return 1
  fi

  if output=$(scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  if output=$(scripts/bash/check-prerequisites.sh --json --paths-only 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  if output=$(scripts/bash/check-prerequisites.sh --json 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  echo "ERROR: Unable to resolve active feature via scripts/bash/check-prerequisites.sh" >&2
  return 1
}

JSON_PAYLOAD="$(resolve_feature_json)"

SPEC_PATH="$("$PYTHON_BIN" - "$JSON_PAYLOAD" <<'PY'
import json
import os
import sys

payload = json.loads(sys.argv[1])
feature_spec = payload.get("FEATURE_SPEC")
feature_dir = payload.get("FEATURE_DIR")

if feature_spec:
    print(feature_spec)
elif feature_dir:
    print(os.path.join(feature_dir, "spec.md"))
else:
    sys.exit(1)
PY
)"

if [[ -z "$SPEC_PATH" || ! -f "$SPEC_PATH" ]]; then
  echo "ERROR: Resolved spec file does not exist: ${SPEC_PATH:-<empty>}" >&2
  exit 1
fi

"$PYTHON_BIN" - "$SPEC_PATH" "$STATE" <<'PY'
import json
import pathlib
import re
import sys

spec_path = pathlib.Path(sys.argv[1])
target_status = sys.argv[2]
status_re = re.compile(r"^\*\*Status\*\*:\s*(.+?)\s*$")

lines = spec_path.read_text(encoding="utf-8").splitlines()
matches = [i for i, line in enumerate(lines) if status_re.match(line)]

previous_status = None
if matches:
    previous_status = status_re.match(lines[matches[0]]).group(1)

if previous_status == "Abandoned" and target_status != "Abandoned":
    print(json.dumps({
        "spec_path": str(spec_path),
        "previous_status": previous_status,
        "new_status": previous_status,
        "changed": False,
        "reason": "preserved_terminal_abandoned",
    }))
    sys.exit(0)

status_line = f"**Status**: {target_status}"

if matches:
    first = matches[0]
    lines[first] = status_line
    for index in reversed(matches[1:]):
        del lines[index]
else:
    heading_index = next((i for i, line in enumerate(lines) if line.startswith("# ")), None)
    if heading_index is None:
        lines.insert(0, status_line)
    else:
        insert_at = heading_index + 1
        if insert_at < len(lines) and lines[insert_at].strip() == "":
            insert_at += 1
        lines.insert(insert_at, status_line)

spec_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "spec_path": str(spec_path),
    "previous_status": previous_status,
    "new_status": target_status,
    "changed": previous_status != target_status,
}))
PY
