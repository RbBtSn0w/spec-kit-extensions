#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-spec-status.sh --status <Tasked|Implementing|Verified|In Review|Abandoned>

Note:
  Multi-word statuses must be quoted or escaped.
  Example: sync-spec-status.sh --status "In Review"
           sync-spec-status.sh --status In\ Review

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
      if [[ $# -lt 2 ]]; then
        echo "ERROR: Invalid or missing --status value: <empty>" >&2
        usage >&2
        exit 1
      fi
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
elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "ERROR: sync-spec-status.sh requires Python 3 on PATH (python3, or python if it is Python 3)" >&2
  exit 1
fi

resolve_feature_json() {
  local output
  local prereq="scripts/bash/check-prerequisites.sh"
  
  if [[ ! -f "$prereq" ]]; then
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Try common extension layout relative to script location
    if [[ -f "$script_dir/../../../scripts/bash/check-prerequisites.sh" ]]; then
      prereq="$script_dir/../../../scripts/bash/check-prerequisites.sh"
    fi
  fi

  if [[ ! -f "$prereq" || ! -r "$prereq" ]]; then
    echo "ERROR: check-prerequisites.sh not found or not readable (checked project root and extension scripts dir)" >&2
    return 1
  fi

  if output=$(bash "$prereq" --json --require-tasks --include-tasks 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  if output=$(bash "$prereq" --json --paths-only 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  if output=$(bash "$prereq" --json 2>/dev/null); then
    printf '%s\n' "$output"
    return 0
  fi

  echo "ERROR: Unable to resolve active feature via $prereq" >&2
  return 1
}

JSON_PAYLOAD="$(resolve_feature_json)" || exit 1

if ! SPEC_PATH="$("$PYTHON_BIN" - "$JSON_PAYLOAD" <<'PY'
import json
import os
import sys

try:
    payload = json.loads(sys.argv[1])
except json.JSONDecodeError as exc:
    print(f"ERROR: check-prerequisites.sh returned invalid JSON: {exc}", file=sys.stderr)
    sys.exit(2)

feature_spec = payload.get("FEATURE_SPEC")
feature_dir = payload.get("FEATURE_DIR")

if feature_spec:
    print(feature_spec)
elif feature_dir:
    print(os.path.join(feature_dir, "spec.md"))
else:
    print("ERROR: feature resolution did not provide FEATURE_SPEC or FEATURE_DIR", file=sys.stderr)
    sys.exit(3)
PY
)"; then
  echo "ERROR: Unable to resolve spec path from check-prerequisites output" >&2
  exit 1
fi

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

# Detect BOM and line endings
raw_bytes = spec_path.read_bytes()
has_bom = raw_bytes.startswith(b"\xef\xbb\xbf")
encoding = "utf-8-sig" if has_bom else "utf-8"

raw_text = raw_bytes.decode(encoding)
line_ending = "\r\n" if "\r\n" in raw_text else ("\n" if "\n" in raw_text else ("\r" if "\r" in raw_text else "\n"))
had_trailing_newline = raw_text.endswith(("\r\n", "\n", "\r"))
lines = raw_text.splitlines()
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
        if len(lines) > 1 and lines[1].strip():
            lines.insert(1, "")
    else:
        lines.insert(heading_index + 1, "")
        lines.insert(heading_index + 2, status_line)

new_text = line_ending.join(lines)
if had_trailing_newline:
    new_text += line_ending

changed = new_text != raw_text
if changed:
    output_encoding = "utf-8-sig" if has_bom else "utf-8"
    with spec_path.open("w", encoding=output_encoding, newline="") as spec_file:
        spec_file.write(new_text)

print(json.dumps({
    "spec_path": str(spec_path),
    "previous_status": previous_status,
    "new_status": target_status,
    "changed": changed,
}))
PY
