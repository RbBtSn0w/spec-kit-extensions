#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v uvx >/dev/null 2>&1; then
  echo "Skipping Spec Kit 0.12.4 installed-package contract: uvx is not available."
  exit 0
fi

SPECIFY=(uvx --from "git+https://github.com/github/spec-kit.git@v0.12.4" specify)
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

"${SPECIFY[@]}" --version | grep -Fq "specify 0.12.4"
"${SPECIFY[@]}" init "$TEMP_DIR/project" --ignore-agent-tools >/dev/null
(
  cd "$TEMP_DIR/project"
  "${SPECIFY[@]}" extension add "$ROOT_DIR" --dev --force >/dev/null
)

INSTALLED="$TEMP_DIR/project/.specify/extensions/superb"
test -d "$INSTALLED"

for command in check brainstorm implementation-gate critique debug respond finish; do
  test -f "$INSTALLED/commands/$command.md" || { echo "missing installed command: $command" >&2; exit 1; }
done

for removed in controller review verify plan-gate; do
  test ! -e "$INSTALLED/commands/$removed.md" || { echo "stale installed command: $removed" >&2; exit 1; }
done

ruby - "$TEMP_DIR/project/.specify/extensions.yml" <<'RUBY'
require "yaml"
hooks = YAML.load_file(ARGV.fetch(0)).fetch("hooks")
abort "installed hook mismatch: #{hooks.keys}" unless hooks.keys == %w[after_specify before_implement]
abort "implementation gate must be mandatory" unless hooks.fetch("before_implement").first.fetch("optional") == false
RUBY

echo "Spec Kit 0.12.4 installed-package contract passed"
