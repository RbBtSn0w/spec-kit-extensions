---
description: Diagnose gh-address-cr runtime availability, GitHub auth, and current PR session health, with one-line install guidance.
scripts:
  - scripts/doctor.sh
  - scripts/check-runtime.sh
---

# Doctor - Environment & PR Review Session Health

## User Context

```text
$ARGUMENTS
```

## Role & Goal

You are diagnosing the local environment for `gh-address-cr` readiness.
Run the bundled diagnostic suite to inspect GitHub CLI auth, `gh-address-cr`
binary installation, current git branch upstream tracking, and active PR context.

## Diagnostics Execution

Run the installed doctor script:

```bash
if [ -f ".specify/extensions/gh-address-cr/scripts/doctor.sh" ]; then
  bash .specify/extensions/gh-address-cr/scripts/doctor.sh
elif [ -f "gh-address-cr/scripts/doctor.sh" ]; then
  bash gh-address-cr/scripts/doctor.sh
else
  gh-address-cr doctor || gh-address-cr --help
fi
```

## Summary & Guidance

Present the diagnostic results clearly to the user:
1. **Runtime Status**: If `gh-address-cr` is installed and its version.
2. **GitHub CLI Status**: Whether `gh` is authenticated.
3. **Active PR Status**: Whether an open PR is detected for the current branch.
4. If `gh-address-cr` is missing or out-of-date, prominently show the one-line install:
   - `pipx install gh-address-cr` (or `brew install RbBtSn0w/tap/gh-address-cr`)
   - Repository link: https://github.com/RbBtSn0w/gh-address-cr
