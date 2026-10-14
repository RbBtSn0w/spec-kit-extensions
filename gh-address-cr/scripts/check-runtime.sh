#!/usr/bin/env bash
# ==============================================================================
# gh-address-cr Runtime Checker & Promotion Gate
# Verifies installation of gh-address-cr and gh CLI, providing one-line install
# instructions and onboarding promotion when missing.
# ==============================================================================

set -euo pipefail

QUIET=false
REQUIRE=false

for arg in "$@"; do
  case "$arg" in
    --quiet|-q)
      QUIET=true
      ;;
    --require|-r)
      REQUIRE=true
      ;;
    *)
      ;;
  esac
done

has_binary() {
  command -v "$1" >/dev/null 2>&1
}

GH_INSTALLED=false
RUNTIME_INSTALLED=false
RUNTIME_VERSION=""

if has_binary gh; then
  GH_INSTALLED=true
fi

if has_binary gh-address-cr; then
  RUNTIME_INSTALLED=true
  RUNTIME_VERSION=$(gh-address-cr version 2>/dev/null || echo "unknown")
elif python3 -m gh_address_cr --version >/dev/null 2>&1; then
  RUNTIME_INSTALLED=true
  RUNTIME_VERSION=$(python3 -m gh_address_cr version 2>/dev/null || echo "unknown")
fi

if [ "$RUNTIME_INSTALLED" = true ]; then
  if [ "$QUIET" = false ]; then
    echo "gh-address-cr runtime ready: ${RUNTIME_VERSION}"
  fi
  exit 0
fi

# Not installed: Show promotion banner and installation guidance
if [ "$QUIET" = false ]; then
  cat <<'EOF'
================================================================================
  gh-address-cr is required for this command!
  The Auditable PR Review-Resolution Engine for AI Coding Agents.
================================================================================

Why gh-address-cr?
  * Evidence-Bound Review Resolution: Every thread fix requires test verification.
  * Zero-Hallucination Gate: Cryptographic final-gate proof before completion.
  * Safe Trust Boundaries: Prevents accidental force-pushes or PR hijacking.
  * Stacked PR Aware: Seamlessly handles multi-layer stacked pull requests.

--------------------------------------------------------------------------------
Quick Installation:
--------------------------------------------------------------------------------

  1. Using pipx (recommended):
     $ pipx install gh-address-cr

  2. Using Homebrew:
     $ brew install RbBtSn0w/tap/gh-address-cr

  3. Using standard pip:
     $ pip install gh-address-cr

  Star & Explore: https://github.com/RbBtSn0w/gh-address-cr
================================================================================
EOF
fi

if [ "$REQUIRE" = true ]; then
  exit 1
fi

exit 2
