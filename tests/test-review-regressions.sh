#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-review-regressions.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
review_regressions = (root / "tests/test-review-regressions.sh").read_text(encoding="utf-8")
ci = (root / ".github/workflows/ci.yml").read_text(encoding="utf-8")
release = (root / ".github/workflows/release-trigger.yml").read_text(encoding="utf-8")
critique = (root / "superpowers-bridge/commands/critique.md").read_text(encoding="utf-8")
ps_test = (root / "superpowers-bridge/tests/test-status-sync.ps1").read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


require(
    "find_python3()" in review_regressions and '"$PYTHON_BIN" - "$ROOT_DIR"' in review_regressions,
    "test-review-regressions.sh must resolve a Python 3 interpreter before running its Python checks",
)
require(
    "windows-latest" in ci and "pwsh" in ci,
    "ci.yml must include a windows-latest pwsh job for PowerShell coverage",
)
require(
    "ubuntu-latest" in ci and "test-review-regressions.sh" in ci,
    "ci.yml must include the existing shell regression coverage on ubuntu-latest",
)
require(
    'git checkout -B "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"' in release,
    "release-trigger.yml must switch to origin/$DEFAULT_BRANCH before preparing release files",
)
require(
    "createCommitOnBranch" in release and "gh api graphql" in release,
    "release-trigger.yml must create release metadata commits through GitHub GraphQL",
)
require(
    "--verify-tag" in release,
    "release-trigger.yml must verify the release tag before publishing the GitHub Release",
)
require(
    'git commit -m "' not in release,
    "release-trigger.yml must not fall back to unsigned local git commits for release metadata",
)

require(
    "refs/heads/main" in critique and "refs/heads/master" in critique,
    "critique.md must fall back to local main/master refs when origin refs are absent",
)
require(
    'git merge-base "$BASE_REF" HEAD' in critique,
    "critique.md must resolve a concrete BASE_REF before calling git merge-base",
)
require(
    "#### 🟠 Important" in critique and "#### 🔵 Minor" in critique,
    "critique.md must use the Critical/Important/Minor severity scale",
)
require(
    "#### 🟠 High" not in critique and "#### 🟡 Medium" not in critique,
    "critique.md must not emit High/Medium severity buckets",
)

require(
    "-notmatch '^\\*\\*Status\\*\\*: Tasked$'" not in ps_test,
    "test-status-sync.ps1 must not use single-line -match anchors for the Tasked assertion",
)
require(
    "-notmatch '^\\*\\*Status\\*\\*: Verified$'" not in ps_test,
    "test-status-sync.ps1 must not use single-line -match anchors for the Verified assertion",
)
require(
    "RegexOptions]::Multiline" in ps_test or "Get-Content $SpecFile" in ps_test,
    "test-status-sync.ps1 must use multiline or line-based assertions for status checks",
)
require(
    "^(# |\\*\\*Status\\*\\*:) " not in ps_test,
    "test-status-sync.ps1 must not use the broken heading/status regex sequence assertion",
)
require(
    'Matches[1].Value -ne "**Status**:"' not in ps_test,
    "test-status-sync.ps1 must not compare against the impossible Matches[1] heading/status value",
)
require(
    '$Lines = Get-Content $SpecFile' in ps_test and '$Lines[2] -ne "**Status**: Tasked"' in ps_test,
    "test-status-sync.ps1 must verify the initial insertion sequence with concrete line positions",
)
require(
    "spec_bom.md" in ps_test,
    "test-status-sync.ps1 must point the BOM case at spec_bom.md",
)

print("review regression checks passed")
PY
