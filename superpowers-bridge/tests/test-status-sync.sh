#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t superb.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

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
  grep -q '^\*\*Status\*\*: Tasked$' specs/001-demo/spec.md

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Verified >/dev/null
  grep -q '^\*\*Status\*\*: Verified$' specs/001-demo/spec.md

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status Abandoned >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' specs/001-demo/spec.md

  "$ROOT_DIR/scripts/bash/sync-spec-status.sh" --status In\ Review >/dev/null
  grep -q '^\*\*Status\*\*: Abandoned$' specs/001-demo/spec.md
)

echo "status sync tests passed"
