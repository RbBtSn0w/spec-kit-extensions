#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert_contains() {
  local file="$1" text="$2"
  grep -Fqi "$text" "$file" || { echo "$file missing boundary: $text" >&2; exit 1; }
}

assert_absent() {
  local file="$1" text="$2"
  if grep -Fqi "$text" "$file"; then
    echo "$file contains forbidden behavior: $text" >&2
    exit 1
  fi
}

assert_contains "$ROOT_DIR/commands/critique.md" "read-only"
assert_contains "$ROOT_DIR/commands/critique.md" "must not apply fixes"
assert_contains "$ROOT_DIR/commands/debug.md" "current failing task"
assert_contains "$ROOT_DIR/commands/debug.md" "return control"
assert_contains "$ROOT_DIR/commands/respond.md" "earliest owning Spec Kit command"
assert_contains "$ROOT_DIR/commands/respond.md" "test-first"
assert_contains "$ROOT_DIR/commands/finish.md" "fresh project checks"
assert_contains "$ROOT_DIR/commands/finish.md" "explicit choice"
assert_contains "$ROOT_DIR/commands/finish.md" "workspaces it does not own"

for file in critique debug respond finish; do
  path="$ROOT_DIR/commands/$file.md"
  assert_absent "$path" "sync-spec-status"
  assert_absent "$path" "archive-evidence"
  assert_absent "$path" "speckit.superb.verify"
  assert_absent "$path" "invoke_subagent"
done

echo "command boundaries passed"
