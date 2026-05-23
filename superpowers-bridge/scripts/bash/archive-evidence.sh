#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: archive-evidence.sh --feature-name <name> --build-status <PASS|FAIL|N/A> [--commit-hash <hash>]

Reads the checklist and test output from standard input, separated by the line "---OUTPUT---".

Options:
  --feature-name   The name of the feature being verified
  --build-status   The build/lint status (e.g. PASS, FAIL, N/A)
  --commit-hash    (Optional) The git commit hash. Auto-resolved if not provided.
EOF
}

FEATURE_NAME=""
BUILD_STATUS=""
COMMIT_HASH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature-name)
      FEATURE_NAME="${2:-}"
      shift 2
      ;;
    --build-status)
      BUILD_STATUS="${2:-}"
      shift 2
      ;;
    --commit-hash)
      COMMIT_HASH="${2:-}"
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

if [[ -z "${FEATURE_NAME//[[:space:]]/}" ]]; then
  echo "ERROR: --feature-name is required" >&2
  exit 1
fi

case "$BUILD_STATUS" in
  "PASS"|"FAIL"|"N/A")
    ;;
  "")
    echo "ERROR: --build-status is required" >&2
    exit 1
    ;;
  *)
    echo "ERROR: --build-status must be one of PASS, FAIL, or N/A" >&2
    exit 1
    ;;
esac

if [[ -z "$COMMIT_HASH" ]]; then
  COMMIT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "N/A")
fi

# Read stdin into variables
CHECKLIST=""
TEST_OUTPUT=""
READING_OUTPUT=false

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" == "---OUTPUT---" ]]; then
    READING_OUTPUT=true
    continue
  fi
  
  if [ "$READING_OUTPUT" = true ]; then
    TEST_OUTPUT="${TEST_OUTPUT}${line}"$'\n'
  else
    CHECKLIST="${CHECKLIST}${line}"$'\n'
  fi
done

if [[ "$READING_OUTPUT" != true ]]; then
  echo "ERROR: Separator '---OUTPUT---' not found in input." >&2
  exit 1
fi

if [[ -z "${CHECKLIST//[[:space:]]/}" ]]; then
  echo "ERROR: Checklist is required before the '---OUTPUT---' separator." >&2
  exit 1
fi

if [[ -z "${TEST_OUTPUT//[[:space:]]/}" ]]; then
  echo "ERROR: Test output is required after the '---OUTPUT---' separator." >&2
  exit 1
fi

EVIDENCE_DIR=".specify/evidence"
mkdir -p "$EVIDENCE_DIR"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
# Clean feature name for file path
SAFE_FEATURE_NAME=$(echo "$FEATURE_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
FILE_PATH="$EVIDENCE_DIR/${TIMESTAMP}-${SAFE_FEATURE_NAME}-verify.md"

cat <<EOF > "$FILE_PATH"
# Verification Evidence: $FEATURE_NAME

- **Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ") (UTC)
- **Git Commit Hash**: $COMMIT_HASH
- **Build/Lint Status**: $BUILD_STATUS

## Spec-Coverage Checklist

$CHECKLIST

## Test Suite Output

\`\`\`text
$TEST_OUTPUT
\`\`\`
EOF

echo "Evidence successfully archived to $FILE_PATH"
