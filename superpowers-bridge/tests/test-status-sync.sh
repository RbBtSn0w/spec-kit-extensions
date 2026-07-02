#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT
SYNC_SCRIPT="$TMP_DIR/scripts/bash/sync-spec-status.sh"

file_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "ERROR: Requires sha256sum or shasum for test hashing" >&2
    exit 1
  fi
}

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-status-sync.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

mkdir -p "$TMP_DIR/scripts/bash" "$TMP_DIR/specs/001-demo" "$TMP_DIR/work/subdir"
cp "$ROOT_DIR/scripts/bash/sync-spec-status.sh" "$SYNC_SCRIPT"
chmod +x "$SYNC_SCRIPT"

cat >"$TMP_DIR/scripts/bash/check-prerequisites.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--json" ]]; then
  project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '{"FEATURE_DIR":"%s/specs/001-demo","FEATURE_SPEC":"%s/specs/001-demo/spec.md"}\n' "$project_root" "$project_root"
  exit 0
fi
exit 1
EOF
chmod +x "$TMP_DIR/scripts/bash/check-prerequisites.sh"

cat >"$TMP_DIR/specs/001-demo/spec.md" <<'EOF'
# Demo Feature

## Overview

Testing status sync.
EOF

(
  cd "$TMP_DIR/work/subdir"
  "$SYNC_SCRIPT" --status Tasked >/dev/null
  # Check if it's there
  grep -q '^\*\*Status\*\*: Tasked$' ../../specs/001-demo/spec.md
  # Verify status appears after H1 heading
  h1_line=$(grep -n "^# " ../../specs/001-demo/spec.md | cut -d: -f1 | head -n 1)
  status_line=$(grep -n "^\*\*Status\*\*:" ../../specs/001-demo/spec.md | cut -d: -f1 | head -n 1)
  [[ -n "$h1_line" && -n "$status_line" && $status_line -gt $h1_line ]] || exit 1

  "$SYNC_SCRIPT" --status Verified >/dev/null
  grep -q '^\*\*Status\*\*: Verified$' ../../specs/001-demo/spec.md

  "$SYNC_SCRIPT" --status In\ Review >/dev/null
  grep -q '^\*\*Status\*\*: In Review$' ../../specs/001-demo/spec.md

  "$SYNC_SCRIPT" --status Abandoned >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' ../../specs/001-demo/spec.md

  "$SYNC_SCRIPT" --status In\ Review >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' ../../specs/001-demo/spec.md

)

# Test insertion without H1 heading
NO_H1_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb-noh1.XXXXXX)"
trap 'rm -rf "$TMP_DIR" "$NO_H1_DIR"' EXIT
mkdir -p "$NO_H1_DIR/scripts/bash" "$NO_H1_DIR/specs/001-demo"
cp "$TMP_DIR/scripts/bash/check-prerequisites.sh" "$NO_H1_DIR/scripts/bash/check-prerequisites.sh"
cp "$ROOT_DIR/scripts/bash/sync-spec-status.sh" "$NO_H1_DIR/scripts/bash/sync-spec-status.sh"
chmod +x "$NO_H1_DIR/scripts/bash/check-prerequisites.sh"
chmod +x "$NO_H1_DIR/scripts/bash/sync-spec-status.sh"
echo "No H1 here, just text." >"$NO_H1_DIR/specs/001-demo/spec.md"
mkdir -p "$NO_H1_DIR/work/subdir"

(
  cd "$NO_H1_DIR/work/subdir"
  "$NO_H1_DIR/scripts/bash/sync-spec-status.sh" --status Tasked >/dev/null
  # Should be at the top
  [[ "$(head -n 1 ../../specs/001-demo/spec.md)" == "**Status**: Tasked" ]] || exit 1
)

CRLF_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb-crlf.XXXXXX)"
trap 'rm -rf "$TMP_DIR" "$NO_H1_DIR" "$CRLF_DIR"' EXIT

mkdir -p "$CRLF_DIR/scripts/bash" "$CRLF_DIR/specs/001-demo"
cp "$TMP_DIR/scripts/bash/check-prerequisites.sh" "$CRLF_DIR/scripts/bash/check-prerequisites.sh"
cp "$ROOT_DIR/scripts/bash/sync-spec-status.sh" "$CRLF_DIR/scripts/bash/sync-spec-status.sh"
chmod +x "$CRLF_DIR/scripts/bash/check-prerequisites.sh"
chmod +x "$CRLF_DIR/scripts/bash/sync-spec-status.sh"
mkdir -p "$CRLF_DIR/work/subdir"

"$PYTHON_BIN" - "$CRLF_DIR/specs/001-demo/spec.md" <<'PY'
import sys
from pathlib import Path
Path(sys.argv[1]).write_bytes(
    b"# Demo Feature\r\n\r\n**Status**: Verified\r\n\r\n## Overview\r\n\r\nTesting status sync.\r\n"
)
PY

(
  cd "$CRLF_DIR/work/subdir"
  before_hash="$(file_sha256 ../../specs/001-demo/spec.md)"
  result="$("$CRLF_DIR/scripts/bash/sync-spec-status.sh" --status Verified)"
  after_hash="$(file_sha256 ../../specs/001-demo/spec.md)"
  [[ "$before_hash" == "$after_hash" ]] || exit 1
  printf '%s' "$result" | grep -q '"changed": false'
  "$PYTHON_BIN" - "../../specs/001-demo/spec.md" <<'PY'
import sys
from pathlib import Path
data = Path(sys.argv[1]).read_bytes()
assert b"\r\n" in data
assert b"\n" not in data.replace(b"\r\n", b"")
PY
)

echo "status sync tests passed"

# PowerShell status sync verified manually across encodings.
