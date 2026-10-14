#!/usr/bin/env bash
# ==============================================================================
# gh-address-cr Doctor
# Diagnostic inspection for GitHub CLI, gh-address-cr runtime, and active PR
# session state.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================================================"
echo "  speckit.gh-address-cr Doctor - Environment & Session Diagnostics"
echo "================================================================================"
echo ""

# 1. Check gh-address-cr runtime
echo "[1/4] Checking gh-address-cr CLI runtime..."
if command -v gh-address-cr >/dev/null 2>&1; then
  VERSION=$(gh-address-cr version 2>/dev/null || echo "detected")
  echo "  ✓ gh-address-cr is installed: ${VERSION}"
  echo "    Path: $(command -v gh-address-cr)"
elif python3 -m gh_address_cr --version >/dev/null 2>&1; then
  VERSION=$(python3 -m gh_address_cr version 2>/dev/null || echo "detected")
  echo "  ✓ gh-address-cr is installed via python3 -m gh_address_cr: ${VERSION}"
else
  echo "  ✗ gh-address-cr is NOT installed."
  echo ""
  echo "  👉 Quick Install:"
  echo "     $ pipx install gh-address-cr"
  echo "     or"
  echo "     $ brew install RbBtSn0w/tap/gh-address-cr"
  echo "     Repository: https://github.com/RbBtSn0w/gh-address-cr"
fi
echo ""

# 2. Check GitHub CLI (gh)
echo "[2/4] Checking GitHub CLI (gh)..."
if command -v gh >/dev/null 2>&1; then
  GH_VER=$(gh --version 2>/dev/null | head -n 1 || echo "detected")
  echo "  ✓ GitHub CLI is installed: ${GH_VER}"
  if gh auth status >/dev/null 2>&1; then
    echo "  ✓ GitHub CLI is authenticated."
  else
    echo "  ! GitHub CLI is not authenticated. Run 'gh auth login' to authenticate."
  fi
else
  echo "  ✗ GitHub CLI (gh) is NOT installed."
  echo "    Install via Homebrew: brew install gh"
fi
echo ""

# 3. Check Git Repository Context
CURRENT_BRANCH="unknown"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  echo "[3/4] Checking Git repository..."
  echo "  ✓ Inside git repository: ${REPO_ROOT}"
  echo "  ✓ Current branch: ${CURRENT_BRANCH}"
else
  echo "[3/4] Checking Git repository..."
  echo "  ! Not inside a git repository."
fi
echo ""

# 4. Check Active PR Context
echo "[4/4] Checking active pull request session..."
if command -v gh-address-cr >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ACTIVE_OUTPUT=""
  ACTIVE_CODE=0
  ACTIVE_OUTPUT=$(gh-address-cr active-pr 2>&1) || ACTIVE_CODE=$?
  if [ "$ACTIVE_CODE" -eq 0 ] && [ -n "$ACTIVE_OUTPUT" ]; then
    echo "  ✓ Active PR detected:"
    echo "    $ACTIVE_OUTPUT"
  else
    echo "  - No active OPEN pull request detected for branch '${CURRENT_BRANCH}'."
    echo "    Specify target PR with: speckit.gh-address-cr.address <owner/repo> <pr_number>"
  fi
else
  echo "  - Skipped PR check (requires gh-address-cr and git repository)."
fi

echo ""
echo "================================================================================"
echo "  Diagnostics complete."
echo "  Project: https://github.com/RbBtSn0w/gh-address-cr"
echo "================================================================================"
