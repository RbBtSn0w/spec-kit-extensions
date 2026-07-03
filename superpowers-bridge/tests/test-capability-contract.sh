#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ruby - "$ROOT_DIR" <<'RUBY'
require "yaml"
root = ARGV.fetch(0)
manifest = YAML.load_file(File.join(root, "extension.yml"))
commands = manifest.fetch("provides").fetch("commands").map { |entry| entry.fetch("name") }
expected = %w[
  speckit.superb.check speckit.superb.brainstorm
  speckit.superb.implementation-gate speckit.superb.critique
  speckit.superb.debug speckit.superb.respond speckit.superb.finish
]
abort "command contract mismatch: #{commands}" unless commands == expected
abort "hook contract mismatch" unless manifest.fetch("hooks").keys == %w[after_specify before_implement]
RUBY

skills=(brainstorming test-driven-development systematic-debugging receiving-code-review finishing-a-development-branch)
for skill in "${skills[@]}"; do
  grep -Fq "\"$skill\"" "$ROOT_DIR/scripts/bash/ensure-skills.sh" || { echo "missing skill: $skill" >&2; exit 1; }
done

for forbidden in verification-before-completion writing-plans executing-plans subagent-driven-development requesting-code-review dispatching-parallel-agents; do
  if rg -n "$forbidden" "$ROOT_DIR/extension.yml" "$ROOT_DIR/superb-config.template.yml" "$ROOT_DIR/scripts/bash/ensure-skills.sh" "$ROOT_DIR/commands" "$ROOT_DIR/README.md" "$ROOT_DIR/WORKFLOW.md"; then
    echo "forbidden runtime dependency remains: $forbidden" >&2
    exit 1
  fi
done

test ! -e "$ROOT_DIR/V2-DESIGN-NOTES.md" || { echo "obsolete V2 design remains active" >&2; exit 1; }
echo "capability contract passed"
