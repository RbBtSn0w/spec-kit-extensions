#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILES=("$ROOT_DIR/extension.yml" "$ROOT_DIR/README.md" "$ROOT_DIR/WORKFLOW.md" "$ROOT_DIR/superb-config.template.yml" "$ROOT_DIR/commands"/*.md)

for forbidden in \
  'Single-Agent' 'Multi-Agent' 'select an execution mode' 'worker orchestration' \
  'speckit.superb.review' 'speckit.superb.verify'; do
  if rg -n -i "$forbidden" "${FILES[@]}"; then
    echo "internal orchestration language remains: $forbidden" >&2
    exit 1
  fi
done

grep -Fq 'Spec Kit remains the sole owner' "$ROOT_DIR/WORKFLOW.md"
grep -Fq 'implementation-gate' "$ROOT_DIR/WORKFLOW.md"
grep -Fq 'speckit.converge' "$ROOT_DIR/WORKFLOW.md"
echo "workflow language contract passed"
