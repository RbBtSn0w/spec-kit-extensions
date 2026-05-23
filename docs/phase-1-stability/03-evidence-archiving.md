# Technical Plan: Evidence-Based Archiving (Phase 1)

## Problem
Currently, the `/speckit.superb.verify` command outputs verification evidence (test results, spec coverage) directly to the chat context. While this satisfies the immediate requirement, the evidence is transient and hard to audit once the session is closed or truncated.

## Proposed Solution
Introduce a standardized archiving mechanism that saves verification artifacts to a local directory.

### Target Directory
`.specify/evidence/`

### File Format
`<timestamp>-<feature-name>-verify.md`

### Content Structure
- Timestamp and Feature Name
- Git Commit Hash
- Full Test Suite Output
- Spec-Coverage Checklist
- Build/Lint Status

## Technical Feasibility Verification

### 1. Capability to write to local filesystem
Spec Kit extensions can use `write_file` or execute shell scripts. Since the `verify` command already uses shell scripts for status syncing, we can extend this or add a new script.

### 2. Resolving Feature Name
The existing status sync scripts already resolve the feature spec path. We can extract the directory name as the feature name.

### 3. Implementation Path
- Modify `superpowers-bridge/commands/verify.md` to include an "Archiving" step.
- Create `superpowers-bridge/scripts/bash/archive-evidence.sh` to handle the file writing.

## Feasibility Test Script
We can test the shell script's ability to create the directory and file.

```bash
#!/bin/bash
EVIDENCE_DIR=".specify/evidence"
mkdir -p "$EVIDENCE_DIR"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FEATURE_NAME="test-feature"
FILE_PATH="$EVIDENCE_DIR/${TIMESTAMP}-${FEATURE_NAME}-verify.md"

cat <<EOF > "$FILE_PATH"
# Verification Evidence
- Feature: $FEATURE_NAME
- Date: $(date)
- Status: Verified
EOF

if [ -f "$FILE_PATH" ]; then
  echo "Feasibility Test Passed: Evidence archived at $FILE_PATH"
else
  echo "Feasibility Test Failed"
fi
```
