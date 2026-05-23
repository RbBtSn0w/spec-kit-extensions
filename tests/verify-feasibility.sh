#!/bin/bash
set -euo pipefail

EVIDENCE_DIR=".specify/evidence"
mkdir -p "$EVIDENCE_DIR"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FEATURE_NAME="feasibility-test"
FILE_PATH="$EVIDENCE_DIR/${TIMESTAMP}-${FEATURE_NAME}-verify.md"

cleanup() {
  rm -f "$FILE_PATH"
  rmdir "$EVIDENCE_DIR" 2>/dev/null || true
  rmdir ".specify" 2>/dev/null || true
}
trap cleanup EXIT

cat <<EOF > "$FILE_PATH"
# Verification Evidence
- Feature: $FEATURE_NAME
- Date: $(date)
- Status: Verified
- Git Hash: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
EOF

if [ -f "$FILE_PATH" ]; then
  echo "Feasibility Test Passed: Evidence archived at $FILE_PATH"
  cat "$FILE_PATH"
else
  echo "Feasibility Test Failed"
  exit 1
fi
