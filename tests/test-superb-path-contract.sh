#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_PREREQ="$ROOT_DIR/.specify/scripts/bash/check-prerequisites.sh"

if [[ ! -x "$CHECK_PREREQ" ]]; then
  echo "FAIL: missing executable check-prerequisites helper at $CHECK_PREREQ" >&2
  exit 1
fi

assert_paths_payload() {
  local json_payload="$1"
  local branch
  branch="$(git -C "$ROOT_DIR" branch --show-current)"
  local expected_feature_dir="$ROOT_DIR/specs/$branch"
  local expected_feature_spec="$expected_feature_dir/spec.md"
  local expected_tasks="$expected_feature_dir/tasks.md"

  python3 - "$json_payload" "$ROOT_DIR" "$expected_feature_dir" "$expected_feature_spec" "$expected_tasks" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
expected_repo_root = sys.argv[2]
expected_feature_dir = sys.argv[3]
expected_feature_spec = sys.argv[4]
expected_tasks = sys.argv[5]

assert payload["REPO_ROOT"] == expected_repo_root, payload
assert payload["FEATURE_DIR"] == expected_feature_dir, payload
assert payload["FEATURE_SPEC"] == expected_feature_spec, payload
assert payload["TASKS"] == expected_tasks, payload
PY
}

root_payload="$(
  cd "$ROOT_DIR"
  bash "$CHECK_PREREQ" --paths-only --json
)"
assert_paths_payload "$root_payload"

subdir_payload="$(
  cd "$ROOT_DIR/superpowers-bridge/commands"
  bash "$CHECK_PREREQ" --paths-only --json
)"
assert_paths_payload "$subdir_payload"

if rg -n '\.specify/scripts/bash/(resolve-skill|ensure-skills)\.sh' \
  "$ROOT_DIR/superpowers-bridge" \
  "$ROOT_DIR/.specify" \
  "$ROOT_DIR/docs" \
  "$ROOT_DIR/tests" >/dev/null; then
  echo "FAIL: found stale superb helper path under .specify/scripts/bash/" >&2
  exit 1
fi

if ! rg -n '\.specify/extensions/superb/scripts/bash/(resolve-skill|ensure-skills)\.sh' \
  "$ROOT_DIR/superpowers-bridge" \
  "$ROOT_DIR/tests" >/dev/null; then
  echo "FAIL: missing explicit superb helper paths under .specify/extensions/superb/" >&2
  exit 1
fi

if rg -n '(sync-spec-status|archive-evidence)' \
  "$ROOT_DIR/superpowers-bridge/extension.yml" \
  "$ROOT_DIR/superpowers-bridge/commands" \
  "$ROOT_DIR/superpowers-bridge/scripts" \
  "$ROOT_DIR/superpowers-bridge/superb-config.template.yml" >/dev/null; then
  echo "FAIL: removed lifecycle helper remains referenced" >&2
  exit 1
fi

echo "superb path contract tests passed"
