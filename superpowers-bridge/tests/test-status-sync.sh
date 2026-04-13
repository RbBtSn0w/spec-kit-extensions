#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

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

mkdir -p "$TMP_DIR/scripts/bash" "$TMP_DIR/specs/001-demo"

cat >"$TMP_DIR/scripts/bash/check-prerequisites.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--json" ]]; then
  printf '{"FEATURE_DIR":"%s/specs/001-demo","FEATURE_SPEC":"%s/specs/001-demo/spec.md"}\n' "$PWD" "$PWD"
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
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Tasked >/dev/null
  # Check if it's there
  grep -q '^\*\*Status\*\*: Tasked$' specs/001-demo/spec.md
  # Check position: line 1 should be heading, line 2 blank, line 3 status
  [[ "$(head -n 1 specs/001-demo/spec.md)" == "# Demo Feature" ]]
  [[ "$(sed -n '3p' specs/001-demo/spec.md)" == "**Status**: Tasked" ]]

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Verified >/dev/null
  grep -q '^\*\*Status\*\*: Verified$' specs/001-demo/spec.md

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Abandoned >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' specs/001-demo/spec.md

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status In\ Review >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' specs/001-demo/spec.md

)

# Test insertion without H1 heading
NO_H1_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb-noh1.XXXXXX)"
mkdir -p "$NO_H1_DIR/scripts/bash" "$NO_H1_DIR/specs/001-demo"
cp "$TMP_DIR/scripts/bash/check-prerequisites.sh" "$NO_H1_DIR/scripts/bash/check-prerequisites.sh"
chmod +x "$NO_H1_DIR/scripts/bash/check-prerequisites.sh"
echo "No H1 here, just text." >"$NO_H1_DIR/specs/001-demo/spec.md"

(
  cd "$NO_H1_DIR"
  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Tasked >/dev/null
  # Should be at the top
  [[ "$(head -n 1 specs/001-demo/spec.md)" == "**Status**: Tasked" ]]
)

CRLF_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb-crlf.XXXXXX)"
trap 'rm -rf "$TMP_DIR" "$NO_H1_DIR" "$CRLF_DIR"' EXIT

mkdir -p "$CRLF_DIR/scripts/bash" "$CRLF_DIR/specs/001-demo"
cp "$TMP_DIR/scripts/bash/check-prerequisites.sh" "$CRLF_DIR/scripts/bash/check-prerequisites.sh"
chmod +x "$CRLF_DIR/scripts/bash/check-prerequisites.sh"

python3 - "$CRLF_DIR/specs/001-demo/spec.md" <<'PY'
from pathlib import Path
Path(__import__("sys").argv[1]).write_bytes(
    b"# Demo Feature\r\n\r\n**Status**: Verified\r\n\r\n## Overview\r\n\r\nTesting status sync.\r\n"
)
PY

(
  cd "$CRLF_DIR"
  before_hash="$(file_sha256 specs/001-demo/spec.md)"
  result="$("$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Verified)"
  after_hash="$(file_sha256 specs/001-demo/spec.md)"
  [[ "$before_hash" == "$after_hash" ]]
  printf '%s' "$result" | grep -q '"changed": false'
  python3 - <<'PY'
from pathlib import Path
data = Path("specs/001-demo/spec.md").read_bytes()
assert b"\r\n" in data
assert b"\n" not in data.replace(b"\r\n", b"")
PY
)

echo "status sync tests passed"
