#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if grep -R -n -E '\.specify/scripts/bash/(resolve-skill|ensure-skills)\.sh' \
  "$ROOT_DIR/superpowers-bridge" \
  "$ROOT_DIR/tests" >/dev/null; then
  echo "FAIL: found stale superb helper path under .specify/scripts/bash/" >&2
  exit 1
fi

if ! grep -R -n -E '\.specify/extensions/superb/scripts/bash/(resolve-skill|ensure-skills)\.sh' \
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
