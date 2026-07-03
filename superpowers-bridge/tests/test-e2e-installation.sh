#!/usr/bin/env bash

# superpowers-bridge/tests/test-e2e-installation.sh
# End-to-End source-payload test for the focused bridge contract.
# Uses a clean, temporary sandboxed HOME directory to avoid touching the user's actual files.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
SANDBOX_DIR="$ROOT_DIR/tests/sandbox_e2e"

echo "=== Running E2E Installation Test ==="

EXPECTED_COMMANDS=(check brainstorm implementation-gate critique debug respond finish)
for command in "${EXPECTED_COMMANDS[@]}"; do
  test -f "$ROOT_DIR/commands/$command.md" || { echo "FAIL: missing command payload: $command"; exit 1; }
done

for removed in \
  commands/controller.md commands/review.md commands/verify.md commands/plan-gate.md \
  scripts/bash/sync-spec-status.sh scripts/bash/archive-evidence.sh \
  scripts/powershell/sync-spec-status.ps1 scripts/powershell/archive-evidence.ps1; do
  test ! -e "$ROOT_DIR/$removed" || { echo "FAIL: removed payload remains: $removed"; exit 1; }
done

if ! command -v npx &>/dev/null; then
  echo "Skipping E2E installation test: npx is not available."
  exit 0
fi

# 1. Setup clean sandboxed HOME environment
echo "Setting up sandbox environment..."
rm -rf "$SANDBOX_DIR"
mkdir -p "$SANDBOX_DIR"
export HOME="$SANDBOX_DIR"

echo "Using Sandboxed HOME: $HOME"

# 2. Verify that prior to execution, no global skills exist in the sandbox
GLOBAL_PLUGINS_DIR="$HOME/.agents/plugins"
if [ -d "$GLOBAL_PLUGINS_DIR" ]; then
  echo "FAIL: Global plugins directory should not exist yet in sandbox"
  exit 1
fi

# 3. Execute Approach 1 (compatible complete-plugin install).
echo "Executing ensure-skills.sh --install 1..."
# We run it with the override SPECIFY_FEATURE to bypass check-prerequisites if needed,
# although ensure-skills.sh doesn't restrict branches.
bash "$SCRIPTS_DIR/bash/ensure-skills.sh" --install 1

# 4. Verify that the five bridge contract skills are available in the plugin.
echo "Verifying installation output in sandbox..."

REQUIRED_SKILLS=(
  "test-driven-development"
  "brainstorming"
  "systematic-debugging"
  "receiving-code-review"
  "finishing-a-development-branch"
)

TARGET_SKILLS_DIR="$GLOBAL_PLUGINS_DIR/obra__superpowers/superpowers/skills"

for skill in "${REQUIRED_SKILLS[@]}"; do
  skill_dir="$TARGET_SKILLS_DIR/$skill"
  if [ ! -d "$skill_dir" ]; then
    echo "FAIL: Skill directory does not exist: $skill_dir"
    exit 1
  fi
  if [ ! -r "$skill_dir/SKILL.md" ]; then
    echo "FAIL: SKILL.md is missing or not readable in: $skill_dir"
    exit 1
  fi
  echo "✅ Skill verified: $skill"
done

# 5. Clean up sandbox environment
echo "Cleaning up sandbox environment..."
rm -rf "$SANDBOX_DIR"

echo "SUCCESS: E2E Installation Test completed successfully!"
exit 0
