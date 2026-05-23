#!/bin/bash
set -euo pipefail

EVIDENCE_DIR=".specify/evidence"
SCRIPT_PATH="./superpowers-bridge/scripts/bash/archive-evidence.sh"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Clean up before testing
rm -rf "$EVIDENCE_DIR"
mkdir -p "$EVIDENCE_DIR"

# Test 1: Successful archiving
echo "Test 1: Successful Archiving"
cat << 'EOF' | bash "$SCRIPT_PATH" --feature-name "test-feature" --build-status "PASS" --commit-hash "12345abc"
- [x] R01
- [x] R02

---OUTPUT---
Tests passing: 5
Tests failing: 0
EOF

ARCHIVED_FILE=$(ls "$EVIDENCE_DIR"/*.md | head -n 1)

if [ -f "$ARCHIVED_FILE" ]; then
    echo "  -> Passed: File created: $ARCHIVED_FILE"
    
    if grep -q "12345abc" "$ARCHIVED_FILE"; then
        echo "  -> Passed: Commit hash found."
    else
        echo "  -> Failed: Commit hash not found."
        exit 1
    fi
    
    if grep -q "Tests passing: 5" "$ARCHIVED_FILE"; then
        echo "  -> Passed: Test output found."
    else
        echo "  -> Failed: Test output not found."
        exit 1
    fi
else
    echo "  -> Failed: File not created."
    exit 1
fi

# Test 2: Missing required arguments
echo "Test 2: Missing Required Arguments"
if bash "$SCRIPT_PATH" --feature-name "test-feature" 2>/dev/null; then
    echo "  -> Failed: Script should have failed due to missing --build-status."
    exit 1
else
    echo "  -> Passed: Script correctly failed."
fi

echo "All tests passed successfully."
rm -rf "$EVIDENCE_DIR"
