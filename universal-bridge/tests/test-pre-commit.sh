#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create a temporary workspace for testing
TEMP_DIR=$(mktemp -d)
PUSHED_TEMP_DIR=0

cleanup() {
    if [ "$PUSHED_TEMP_DIR" = "1" ]; then
        popd > /dev/null 2>&1 || true
    fi
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Testing pre-commit-sdd hook in $TEMP_DIR"

# Copy the hook script
cp "$ROOT_DIR/universal-bridge/hooks/pre-commit-sdd" "$TEMP_DIR/"
HOOK_SCRIPT="$TEMP_DIR/pre-commit-sdd"
chmod +x "$HOOK_SCRIPT"

pushd "$TEMP_DIR" > /dev/null
PUSHED_TEMP_DIR=1

# Initialize empty git repo so git diff --cached doesn't fail
git init > /dev/null
git -c user.name="SDD Test" -c user.email="sdd-test@example.com" commit --allow-empty -m "Initial commit" > /dev/null

assert_fails_with() {
    local expected="$1"
    shift

    set +e
    OUTPUT=$("$@" 2>&1)
    STATUS=$?
    set -e

    if [ "$STATUS" -eq 0 ]; then
        echo "  -> Failed: command unexpectedly succeeded"
        echo "$OUTPUT"
        exit 1
    fi

    if echo "$OUTPUT" | grep -q "$expected"; then
        echo "  -> Passed"
    else
        echo "  -> Failed: expected output to contain '$expected'"
        echo "$OUTPUT"
        exit 1
    fi
}

# Test 1: No spec.md exists (should exit 0)
echo "Test 1: No spec.md"
OUTPUT=$("$HOOK_SCRIPT")
if echo "$OUTPUT" | grep -q "No spec.md found"; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    echo "$OUTPUT"
    exit 1
fi

# Test 2: Staged path with spaces resolves the related spec.md (should exit 0)
echo "Test 2: Staged path with spaces"
mkdir -p "feature with spaces"
echo "**Status**: Tasked" > "feature with spaces/spec.md"
echo "change" > "feature with spaces/file name.txt"
git add "feature with spaces/spec.md" "feature with spaces/file name.txt"
OUTPUT=$("$HOOK_SCRIPT")
if echo "$OUTPUT" | grep -q "feature with spaces/spec.md"; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    echo "$OUTPUT"
    exit 1
fi
git rm --cached -r -- "feature with spaces" > /dev/null
rm -rf "feature with spaces"

# Test 3: Spec exists, not verified (should exit 0)
echo "Test 3: Spec exists, status Tasked"
echo "**Status**: Tasked" > spec.md
git add spec.md
if "$HOOK_SCRIPT" >/dev/null; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

# Test 4: Spec Verified, but uncompleted tasks exist (should exit 1)
echo "Test 4: Spec Verified, uncompleted tasks"
echo "**Status**: Verified" > spec.md
echo "- [ ] Task 1" > tasks.md
git add spec.md tasks.md
assert_fails_with "uncompleted tasks" "$HOOK_SCRIPT"

# Test 5: Spec Verified, tasks completed, but no evidence (should exit 1)
echo "Test 5: Spec Verified, no evidence"
echo "- [x] Task 1" > tasks.md
assert_fails_with "no verification evidence found" "$HOOK_SCRIPT"

# Test 6: Spec Verified, tasks completed, unrelated evidence exists (should exit 1)
echo "Test 6: Spec Verified, unrelated evidence exists"
mkdir -p .specify/evidence
touch .specify/evidence/20260523000000-other-feature-verify.md
assert_fails_with "no verification evidence found" "$HOOK_SCRIPT"

# Test 7: Spec Verified, tasks completed, matching evidence exists (should exit 0)
echo "Test 7: Spec Verified, matching evidence exists"
SAFE_TEMP_NAME=$(basename "$TEMP_DIR" | sed 's/[^a-zA-Z0-9_-]/_/g')
touch ".specify/evidence/20260523000000-${SAFE_TEMP_NAME}-verify.md"
if "$HOOK_SCRIPT" >/dev/null; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

PUSHED_TEMP_DIR=0
popd > /dev/null
echo "All tests passed successfully."
