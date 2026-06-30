#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESOLVER="$ROOT_DIR/scripts/bash/resolve-skill.sh"
SANDBOX_DIR="$ROOT_DIR/tests/sandbox_resolve"

echo "=== Running Skill Resolution Helper Tests ==="

rm -rf "$SANDBOX_DIR"
mkdir -p "$SANDBOX_DIR/workspace" "$SANDBOX_DIR/home"

export HOME="$SANDBOX_DIR/home"

if [ ! -x "$RESOLVER" ]; then
  echo "FAIL: resolver helper is missing or not executable: $RESOLVER"
  exit 1
fi

mkdir -p "$SANDBOX_DIR/workspace/.agents/skills/brainstorming"
printf '# Workspace Brainstorming\n' > "$SANDBOX_DIR/workspace/.agents/skills/brainstorming/SKILL.md"

workspace_output="$(
  cd "$SANDBOX_DIR/workspace" &&
  bash "$RESOLVER" --skill brainstorming
)"

if ! echo "$workspace_output" | grep -q '"source":"workspace"'; then
  echo "FAIL: workspace direct skill should resolve as workspace source"
  exit 1
fi

if ! echo "$workspace_output" | grep -q '"install_type":"skill-root"'; then
  echo "FAIL: workspace direct skill should resolve as skill-root"
  exit 1
fi

rm -rf "$SANDBOX_DIR/workspace/.agents/skills/brainstorming"
mkdir -p "$SANDBOX_DIR/home/.agents/plugins/vendor__pack/superpowers/skills/brainstorming"
printf '# Global Plugin Brainstorming\n' > "$SANDBOX_DIR/home/.agents/plugins/vendor__pack/superpowers/skills/brainstorming/SKILL.md"

plugin_output="$(
  cd "$SANDBOX_DIR/workspace" &&
  bash "$RESOLVER" --skill brainstorming
)"

if ! echo "$plugin_output" | grep -q '"source":"global"'; then
  echo "FAIL: global plugin skill should resolve as global source"
  exit 1
fi

if ! echo "$plugin_output" | grep -q '"install_type":"plugin"'; then
  echo "FAIL: global plugin skill should resolve as plugin install type"
  exit 1
fi

rm -rf "$SANDBOX_DIR/home/.agents/plugins"
mkdir -p "$SANDBOX_DIR/workspace/.specify" "$SANDBOX_DIR/workspace/.agents/skills/brainstorming" "$SANDBOX_DIR/workspace/nested/path"
printf '# Nested Workspace Brainstorming\n' > "$SANDBOX_DIR/workspace/.agents/skills/brainstorming/SKILL.md"

nested_output="$(
  cd "$SANDBOX_DIR/workspace/nested/path" &&
  bash "$RESOLVER" --skill brainstorming
)"

if ! echo "$nested_output" | grep -q '"source":"workspace"'; then
  echo "FAIL: nested execution should still resolve workspace skill"
  exit 1
fi

if ! echo "$nested_output" | grep -q '"install_type":"skill-root"'; then
  echo "FAIL: nested execution should preserve workspace skill-root resolution"
  exit 1
fi

set +e
missing_output="$(
  cd "$SANDBOX_DIR/workspace" &&
  bash "$RESOLVER" --skill missing-skill
)"
missing_status=$?
set -e

if [ "$missing_status" -ne 1 ]; then
  echo "FAIL: missing skill should exit with status 1"
  exit 1
fi

if ! echo "$missing_output" | grep -q '"available":false'; then
  echo "FAIL: missing skill should report available:false"
  exit 1
fi

rm -rf "$SANDBOX_DIR"

echo "SUCCESS: skill resolution helper passed."
exit 0
