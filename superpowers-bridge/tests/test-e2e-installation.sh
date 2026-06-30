#!/usr/bin/env bash

# superpowers-bridge/tests/test-e2e-installation.sh
# End-to-End test to verify the skill installation flow using adg with the -g flag.
# Uses a clean, temporary sandboxed HOME directory to avoid touching the user's actual files.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
SANDBOX_DIR="$ROOT_DIR/tests/sandbox_e2e"

echo "=== Running E2E Installation Test ==="

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

# 3. Execute install-skills.sh with Approach 1 (Recommended plugins add with -g)
echo "Executing install-skills.sh --approach 1..."
# We run it with the override SPECIFY_FEATURE to bypass check-prerequisites if needed, 
# although install-skills.sh doesn't restrict branches.
bash "$SCRIPTS_DIR/bash/install-skills.sh" --approach 1

# 4. Verify that the plugin directory and skills have been successfully created/cloned
echo "Verifying installation output in sandbox..."

TARGET_PLUGIN_DIR="$GLOBAL_PLUGINS_DIR/obra__superpowers/superpowers"
if [ ! -d "$TARGET_PLUGIN_DIR" ]; then
  echo "FAIL: Plugin directory was not created: $TARGET_PLUGIN_DIR"
  exit 1
fi

# Let's check that some core skills exist in the plugin
REQUIRED_SKILLS=(
  "test-driven-development"
  "verification-before-completion"
  "brainstorming"
)

for skill in "${REQUIRED_SKILLS[@]}"; do
  skill_dir="$TARGET_PLUGIN_DIR/skills/$skill"
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
