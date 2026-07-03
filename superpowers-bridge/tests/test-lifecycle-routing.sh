#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ruby - "$ROOT_DIR" <<'RUBY'
require "yaml"

root = ARGV.fetch(0)
manifest = YAML.load_file(File.join(root, "extension.yml"))
commands = manifest.fetch("provides").fetch("commands").map { |entry| entry.fetch("name") }
hooks = manifest.fetch("hooks")

expected_hooks = {
  "after_specify" => ["speckit.superb.brainstorm", true],
  "before_implement" => ["speckit.superb.implementation-gate", false],
}
abort "expected exactly two Superb hooks, got #{hooks.keys}" unless hooks.keys == expected_hooks.keys
expected_hooks.each do |name, (command, optional)|
  entry = hooks.fetch(name)
  abort "#{name} command mismatch" unless entry.fetch("command") == command
  abort "#{name} optional mismatch" unless entry.fetch("optional") == optional
end

%w[speckit.superb.controller speckit.superb.review speckit.superb.verify speckit.superb.plan-gate].each do |name|
  abort "removed command remains registered: #{name}" if commands.include?(name)
end
RUBY

for file in "$ROOT_DIR"/commands/*.md; do
  case "$(basename "$file")" in
    brainstorm.md|implementation-gate.md|check.md|critique.md|debug.md|respond.md|finish.md) ;;
    *) echo "unexpected active command payload: $file" >&2; exit 1 ;;
  esac
done

if rg -n 'sync-spec-status|archive-evidence|after_tasks|after_implement|after_converge|before_converge' \
  "$ROOT_DIR/extension.yml" "$ROOT_DIR/commands"; then
  echo "removed lifecycle state or hook remains active" >&2
  exit 1
fi

echo "lifecycle routing contract passed"
