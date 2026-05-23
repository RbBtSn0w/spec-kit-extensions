#!/bin/bash
set -euo pipefail

# Create a temporary workspace for testing
TEMP_DIR=$(mktemp -d)
echo "Testing pre-commit-sdd hook in $TEMP_DIR"

# Copy the hook script
cp universal-bridge/hooks/pre-commit-sdd "$TEMP_DIR/"
HOOK_SCRIPT="$TEMP_DIR/pre-commit-sdd"
chmod +x "$HOOK_SCRIPT"

pushd "$TEMP_DIR" > /dev/null

# Initialize empty git repo so git diff --cached doesn't fail
git init > /dev/null
git commit --allow-empty -m "Initial commit" > /dev/null

# Test 1: No spec.md exists (should exit 0)
echo "Test 1: No spec.md"
if "$HOOK_SCRIPT" | grep -q "No spec.md found"; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

# Test 2: Spec exists, not verified (should exit 0)
echo "Test 2: Spec exists, status Tasked"
echo "**Status**: Tasked" > spec.md
git add spec.md
if "$HOOK_SCRIPT" >/dev/null; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

# Test 3: Spec Verified, but uncompleted tasks exist (should exit 1)
echo "Test 3: Spec Verified, uncompleted tasks"
echo "**Status**: Verified" > spec.md
echo "- [ ] Task 1" > tasks.md
git add spec.md tasks.md
if ! "$HOOK_SCRIPT" 2>&1 | grep -q "uncompleted tasks"; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

# Test 4: Spec Verified, tasks completed, but no evidence (should exit 1)
echo "Test 4: Spec Verified, no evidence"
echo "- [x] Task 1" > tasks.md
if ! "$HOOK_SCRIPT" 2>&1 | grep -q "No verification evidence found"; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

# Test 5: Spec Verified, tasks completed, evidence exists (should exit 0)
echo "Test 5: Spec Verified, evidence exists"
mkdir -p .specify/evidence
touch .specify/evidence/test.md
if "$HOOK_SCRIPT" >/dev/null; then
    echo "  -> Passed"
else
    echo "  -> Failed"
    exit 1
fi

popd > /dev/null
rm -rf "$TEMP_DIR"
echo "All tests passed successfully."
