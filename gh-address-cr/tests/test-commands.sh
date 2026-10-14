#!/usr/bin/env bash
# ==============================================================================
# Command boundaries and format tests for gh-address-cr extension
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

for cmd in address review gate doctor; do
  file="$EXT_DIR/commands/$cmd.md"
  if [ ! -f "$file" ]; then
    echo "ERROR: missing command file $file" >&2
    exit 1
  fi

  # Must contain $ARGUMENTS block
  if ! grep -Fq '$ARGUMENTS' "$file"; then
    echo "ERROR: $file is missing \$ARGUMENTS context block" >&2
    exit 1
  fi

  # Must declare frontmatter scripts
  if ! grep -Fq 'scripts:' "$file"; then
    echo "ERROR: $file is missing frontmatter scripts declaration" >&2
    exit 1
  fi
done

# Address command must define safety boundaries
if ! grep -qi "force-push" "$EXT_DIR/commands/address.md"; then
  echo "ERROR: address.md must explicitly forbid force-pushing" >&2
  exit 1
fi

if ! grep -qi "final-gate" "$EXT_DIR/commands/address.md"; then
  echo "ERROR: address.md must mandate final-gate proof" >&2
  exit 1
fi

# Gate command must reference final-gate
if ! grep -qi "final-gate" "$EXT_DIR/commands/gate.md"; then
  echo "ERROR: gate.md must invoke final-gate" >&2
  exit 1
fi

echo "gh-address-cr command contract passed"
