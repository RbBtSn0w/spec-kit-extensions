#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE="$ROOT_DIR/commands/implementation-gate.md"

test -f "$GATE" || { echo "implementation-gate.md is missing" >&2; exit 1; }

for required in \
  '$ARGUMENTS' \
  'test-driven-development' \
  'native minimum' \
  'spec.md' \
  'plan.md' \
  'tasks.md' \
  '[P]' \
  'read-only'; do
  grep -Fq "$required" "$GATE" || { echo "missing gate contract: $required" >&2; exit 1; }
done

for forbidden in \
  'Single-Agent' \
  'Multi-Agent' \
  'dispatch' \
  'invoke_subagent' \
  'update task checkboxes' \
  'sync-spec-status' \
  'archive-evidence'; do
  if grep -Fqi "$forbidden" "$GATE"; then
    echo "forbidden orchestration contract remains: $forbidden" >&2
    exit 1
  fi
done

echo "implementation gate contract passed"
