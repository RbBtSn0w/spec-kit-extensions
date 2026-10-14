#!/usr/bin/env bash
# ==============================================================================
# Runtime check and fallback test for gh-address-cr extension
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CHECK_SCRIPT="$EXT_DIR/scripts/check-runtime.sh"

# 1. Test fallback when gh-address-cr is missing
fallback_output=$(PATH="/usr/bin:/bin" "$CHECK_SCRIPT" || true)
if ! echo "$fallback_output" | grep -qi "pipx install gh-address-cr"; then
  echo "ERROR: missing promotion/install guidance in fallback, got: $fallback_output" >&2
  exit 1
fi

# Test --require flag exits with code 1 when missing
if PATH="/usr/bin:/bin" "$CHECK_SCRIPT" --require >/dev/null 2>&1; then
  echo "ERROR: expected --require to exit non-zero when runtime missing" >&2
  exit 1
fi

# 2. Test mock gh-address-cr binary in a temporary directory
TMP_BIN_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_BIN_DIR"' EXIT

cat <<'MOCK' > "$TMP_BIN_DIR/gh-address-cr"
#!/usr/bin/env bash
if [ "${1:-}" = "version" ]; then
  echo "gh-address-cr 3.20.1-mock"
  exit 0
fi
exit 0
MOCK
chmod +x "$TMP_BIN_DIR/gh-address-cr"

ready_output=$(PATH="$TMP_BIN_DIR:$PATH" "$CHECK_SCRIPT")
if ! echo "$ready_output" | grep -qi "gh-address-cr runtime ready"; then
  echo "ERROR: expected runtime ready message with mock binary, got: $ready_output" >&2
  exit 1
fi

echo "gh-address-cr runtime fallback tests passed"
