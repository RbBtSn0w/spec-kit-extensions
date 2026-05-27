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
import re

root = Path(sys.argv[1])
root_readme = (root / "README.md").read_text(encoding="utf-8")
review_regressions = (root / "tests/test-review-regressions.sh").read_text(encoding="utf-8")
ci = (root / ".github/workflows/ci.yml").read_text(encoding="utf-8")
release = (root / ".github/workflows/release-trigger.yml").read_text(encoding="utf-8")
critique = (root / "superpowers-bridge/commands/critique.md").read_text(encoding="utf-8")
ps_test = (root / "superpowers-bridge/tests/test-status-sync.ps1").read_text(encoding="utf-8")
verify = (root / "superpowers-bridge/commands/verify.md").read_text(encoding="utf-8")
extension = (root / "superpowers-bridge/extension.yml").read_text(encoding="utf-8")
readme = (root / "superpowers-bridge/README.md").read_text(encoding="utf-8")
debug = (root / "superpowers-bridge/commands/debug.md").read_text(encoding="utf-8")
review = (root / "superpowers-bridge/commands/review.md").read_text(encoding="utf-8")
check = (root / "superpowers-bridge/commands/check.md").read_text(encoding="utf-8")
config = (root / "superpowers-bridge/superb-config.template.yml").read_text(encoding="utf-8")
respond = (root / "superpowers-bridge/commands/respond.md").read_text(encoding="utf-8")
brainstorm_path = root / "superpowers-bridge/commands/brainstorm.md"
brainstorm = brainstorm_path.read_text(encoding="utf-8") if brainstorm_path.exists() else ""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def require_hook_optional(hook: str, expected: str) -> None:
    match = re.search(rf"^\s{{2}}{hook}:\n(?P<body>(?:^\s{{4}}.+\n)+)", extension, re.MULTILINE)
    require(match is not None, f"extension.yml must declare hooks.{hook}")
    require(
        f"optional: {expected}" in match.group("body"),
        f"hooks.{hook} must have optional: {expected}",
    )


def config_requirement_skills(kind: str):
    in_requirements = False
    in_requested_list = False
    skills = []

    for line in config.splitlines():
        if line == "requirements:":
            in_requirements = True
            continue
        if not in_requirements:
            continue
        if line and not line.startswith(" "):
            break
        if not line.strip():
            continue
        if line.startswith("  ") and not line.startswith("    "):
            in_requested_list = line.strip() == f"{kind}:"
            continue
        if in_requested_list and line.startswith("    - "):
            skills.append(line.strip()[2:])

    require(skills, f"superb-config.template.yml must declare requirements.{kind}")
    return skills


hard_skills = config_requirement_skills("hard")
optional_skills = config_requirement_skills("optional")


require(
    "find_python3()" in review_regressions and '"$PYTHON_BIN" - "$ROOT_DIR"' in review_regressions,
    "test-review-regressions.sh must resolve a Python 3 interpreter before running its Python checks",
)
require(
    "Bridges selected Superpowers disciplines into Spec Kit as evidence-first trust gates for agent workflows" in root_readme,
    "root README must position Superpowers Bridge as Superpowers-sourced trust gates for Spec Kit agent workflows",
)
require(
    "Bridges selected [obra/superpowers](https://github.com/obra/superpowers)" in readme
    and "disciplines into [Spec Kit](https://github.com/github/spec-kit) as" in readme
    and "evidence-first trust gates for agent workflows" in readme
    and "makes Spec Kit implementation claims verifiable" in readme
    and "no agent should mark a Spec Kit feature" in readme
    and "## Naming And Brand" in readme
    and "| Superpowers Bridge | Official extension and product name | Public, stable |" in readme
    and "| `superpowers-bridge` | Spec Kit extension package, folder, release asset, and tag prefix | Public, stable |" in readme
    and "| `superb` | Command namespace and local shorthand, as in `/speckit.superb.verify` | Public, stable |" in readme
    and "Do not use `SuperB` or `SuperBridge` as official public names" in readme
    and "## Who This Is For" in readme
    and "## Open Source Adoption Path" in readme
    and "The extension is proving value when it blocks a false completion" in readme,
    "Superpowers Bridge README must preserve Superpowers identity, naming hierarchy, open-source wedge, ICP, and first-success path",
)
require(
    "description: \"Bridges selected Superpowers disciplines into Spec Kit as evidence-first trust gates" in extension
    and len(re.search(r'^\s{2}description: "([^"]+)"$', extension, re.MULTILINE).group(1)) <= 200,
    "extension.yml description must preserve Superpowers identity, trust-gate outcome, and catalog limits",
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
    "test-archive-evidence.sh" in ci and "test-pre-commit.sh" in ci,
    "ci.yml must include evidence archiving and universal pre-commit regression coverage",
)
require(
    "test-archive-evidence.ps1" in ci,
    "ci.yml must include PowerShell evidence archiving regression coverage",
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
    "archive_sh: scripts/bash/archive-evidence.sh" in verify
    and "archive_ps: scripts/powershell/archive-evidence.ps1" in verify,
    "verify.md must declare evidence archiving scripts in frontmatter",
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
    brainstorm_path.exists() and "$ARGUMENTS" in brainstorm,
    "brainstorm.md must exist and include the $ARGUMENTS user context block",
)
require(
    "name: speckit.superb.brainstorm" in extension
    and "after_specify:" in extension
    and "command: speckit.superb.brainstorm" in extension,
    "extension.yml must declare speckit.superb.brainstorm and wire it to hooks.after_specify",
)
require_hook_optional("after_specify", "true")
require_hook_optional("after_tasks", "true")
require_hook_optional("before_implement", "false")
require_hook_optional("after_implement", "false")
require(
    "## Hook Requirement Baseline" in readme
    and "| `after_specify` | `/speckit.superb.brainstorm` | Optional |" in readme
    and "| `after_tasks` | `/speckit.superb.review` | Optional |" in readme
    and "| `before_implement` | `/speckit.superb.tdd` | Required |" in readme
    and "| `after_implement` | `/speckit.superb.verify` | Required |" in readme,
    "README must document the baseline required/optional hook policy",
)
require(
    "## Goal Mode Usage" in readme
    and "Treat optional superb hooks as accepted for this goal" in readme
    and "run `/speckit.superb.brainstorm` after `/speckit.specify`" in readme
    and "run `/speckit.superb.review` after `/speckit.tasks`" in readme,
    "README must include a Goal mode usage prompt that opts into optional superb hooks",
)
require(
    "hook_policy:" in config
    and "required:" in config
    and "before_implement" in config
    and "after_implement" in config
    and "optional:" in config
    and "after_specify" in config
    and "after_tasks" in config,
    "superb-config.template.yml must document the baseline hook policy",
)
require(
    "| after_specify | /speckit.superb.brainstorm | Optional |" in check
    and "| after_tasks | /speckit.superb.review | Optional |" in check
    and "| before_implement | /speckit.superb.tdd | Required |" in check
    and "| after_implement | /speckit.superb.verify | Required |" in check,
    "check.md must report baseline hook policy consistently",
)
require(
    "brainstorming" in check
    and "brainstorming" in extension
    and "brainstorming" in optional_skills
    and "brainstorming" not in hard_skills
    and "test-driven-development" in hard_skills
    and "verification-before-completion" in hard_skills,
    "brainstorming must be treated as optional bridge capability, not a hard requirement",
)
require(
    "not directly bridged" in readme
    and "`requesting-code-review`" in readme
    and "- `brainstorming`" not in readme,
    "README must describe requesting-code-review as represented by critique/respond and must not list brainstorming as simply unbridged",
)
require(
    "### Review Role Boundaries" in readme
    and "`requesting-code-review` | Review request / handoff pattern" in readme
    and "`/speckit.superb.critique` | Local spec-aligned reviewer" in readme
    and "`/speckit.superb.respond` | Feedback receiver / implementer response" in readme,
    "README must define requesting-code-review, critique, and respond as separate review roles",
)
require(
    "## Superpowers Mapping Matrix" in readme
    and "| `brainstorming` | `/speckit.superb.brainstorm` |" in readme
    and "| `test-driven-development` | `/speckit.superb.tdd` |" in readme
    and "| `verification-before-completion` | `/speckit.superb.verify` |" in readme
    and "| `systematic-debugging` | `/speckit.superb.debug` |" in readme
    and "| `dispatching-parallel-agents` | `/speckit.superb.debug` parallel mode |" in readme
    and "| `requesting-code-review` | `/speckit.superb.critique` handoff section |" in readme
    and "| `receiving-code-review` | `/speckit.superb.respond` |" in readme
    and "| `finishing-a-development-branch` | `/speckit.superb.finish` |" in readme
    and "| `writing-plans` | `/speckit.superb.review` task-quality checks |" in readme
    and "| `subagent-driven-development` | Not exposed |" in readme
    and "| `executing-plans` | Not exposed |" in readme
    and "| `using-git-worktrees` | Not exposed |" in readme
    and "Borrowed disciplines do not create new bridge commands" in readme,
    "README must document the Superpowers-to-superb mapping matrix and bridge boundaries",
)
require(
    "### Agent Execution Contract" in readme
    and "treated as stage-specific middleware rather than a second workflow engine" in readme
    and "Required bridge hooks are gates" in readme
    and "Optional bridge hooks run only when the user, goal prompt, or local policy" in readme
    and "Manual bridge commands are situational tools" in readme,
    "README must explain how autonomous agents connect superb hooks into the Spec Kit workflow",
)
require(
    "### Role Boundary" in critique
    and "`critique` is the reviewer" in critique
    and "`requesting-code-review` is a handoff pattern" in critique
    and "`respond` is the feedback receiver" in critique,
    "critique.md must define local reviewer vs review-request vs feedback-response roles",
)
require(
    "## Role Boundary" in respond
    and "`respond` is not a reviewer" in respond
    and "`critique` or an external reviewer produces findings" in respond,
    "respond.md must say it receives and triages findings rather than performing review",
)
require(
    "Parallel Dispatch Mode" in debug
    and "2+ independent failure domains" in debug
    and "controller verification" in debug,
    "debug.md must document the dispatching-parallel-agents escalation boundary and controller verification",
)
require(
    "File Ownership Map" in review
    and "Task Granularity" in review
    and "RED/GREEN Target" in review
    and "Review Checkpoint Readiness" in review,
    "review.md must include writing-plans-derived file ownership, task granularity, RED/GREEN, and review checkpoint checks",
)
require(
    ".specify/plan-fix.md" not in critique
    and "append to the existing `plan.md`" not in critique
    and "Automatically write a fix plan" not in critique
    and "Fix Plan Draft" in critique
    and "Reviewer Boundary" in critique,
    "critique.md must not write planning artifacts and must present fix plans as drafts only",
)
require(
    "## Artifact Ownership Model" in readme
    and "Spec Kit owns creation, schema, lifecycle, and canonical meaning" in readme
    and "Superpowers Bridge may only refine, check, report, or synchronize within declared hook boundaries" in readme,
    "README must define artifact ownership separately from extension refinement/checking",
)
require(
    "Spec Kit remains artifact owner" in brainstorm
    and "Do not synchronize lifecycle status" in brainstorm
    and "get user approval before writing changes" in brainstorm,
    "brainstorm.md must require approval-before-write, no status sync, and artifact-owner reporting",
)
require(
    "check-prerequisites.sh --json --paths-only" in brainstorm
    and "Do not run the normal downstream prerequisite validation path here" in brainstorm
    and "plan.md` or `tasks.md`" in brainstorm,
    "brainstorm.md must resolve specs with hook paths or paths-only prerequisites before plan/tasks exist",
)
require(
    "Recommend adding missing tasks" in review
    and "Add missing tasks to tasks.md" not in review,
    "review.md must recommend task edits without implying it edits tasks.md itself",
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
