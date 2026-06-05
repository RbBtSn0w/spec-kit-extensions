#!/bin/bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d%H%M%S)
FEATURE_NAME="feasibility-test"
TEMP_ROOT="${TMPDIR:-/tmp}"
TEMP_ROOT="${TEMP_ROOT%/}"
FILE_PATH=""

cleanup() {
  if [ -n "$FILE_PATH" ]; then
    rm -f "$FILE_PATH"
  fi
}
trap cleanup EXIT

TEMP_FILE=$(mktemp "$TEMP_ROOT/speckit-superb-evidence-${FEATURE_NAME}-${TIMESTAMP}.XXXXXX")
FILE_PATH="${TEMP_FILE}.md"
mv "$TEMP_FILE" "$FILE_PATH"

cat <<EOF > "$FILE_PATH"
# Verification Evidence
- Feature: $FEATURE_NAME
- Date: $(date)
- Status: Verified
- Git Hash: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
EOF

if [ -f "$FILE_PATH" ]; then
  echo "Feasibility Test Passed: Evidence captured at $FILE_PATH"
  cat "$FILE_PATH"
else
  echo "Feasibility Test Failed"
  exit 1
fi
