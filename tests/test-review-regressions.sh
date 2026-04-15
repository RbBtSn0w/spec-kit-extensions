#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
release = (root / ".github/workflows/release-trigger.yml").read_text(encoding="utf-8")
critique = (root / "superpowers-bridge/commands/critique.md").read_text(encoding="utf-8")
ps_test = (root / "superpowers-bridge/tests/test-status-sync.ps1").read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


require(
    'git checkout -B "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"' in release,
    "release-trigger.yml must switch to origin/$DEFAULT_BRANCH before preparing release files",
)
require(
    'git push origin "HEAD:refs/heads/$DEFAULT_BRANCH"' in release,
    "release-trigger.yml must push only to refs/heads/$DEFAULT_BRANCH",
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
    "spec_bom.md" in ps_test,
    "test-status-sync.ps1 must point the BOM case at spec_bom.md",
)

print("review regression checks passed")
PY
