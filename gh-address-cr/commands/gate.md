---
description: Run mandatory final-gate verification to prove zero unaddressed review threads or pending findings before completion.
scripts:
  - scripts/check-runtime.sh
---

# Final Gate - PR Review Completion Proof

## User Context

```text
$ARGUMENTS
```

## Role & Goal

You are an evidence verifier. Your job is to invoke the `gh-address-cr final-gate`
command to rigorously audit and prove that all GitHub review threads and ingested
findings for the target PR are fully addressed, backed by valid commit SHAs,
associated files, technical explanations, and passing validation tests.

## Pre-flight Check

Ensure `gh-address-cr` is installed and ready:

```bash
if command -v gh-address-cr >/dev/null 2>&1; then
  : # runtime available
elif [ -f ".specify/extensions/gh-address-cr/scripts/check-runtime.sh" ]; then
  bash .specify/extensions/gh-address-cr/scripts/check-runtime.sh --require
elif [ -f "gh-address-cr/scripts/check-runtime.sh" ]; then
  bash gh-address-cr/scripts/check-runtime.sh --require
else
  echo "Error: gh-address-cr is required. Install via 'pipx install gh-address-cr'." >&2
  exit 1
fi
```

## Target Pull Request Resolution

Parse `$ARGUMENTS`:
- `<owner/repo>` and `<pr_number>`
- Optional `--stack` flag if working within a GitHub stacked pull request chain.
- If omitted, resolve current branch PR via:
  ```bash
  gh-address-cr active-pr
  ```

## Execution

Execute the final gate verification:

```bash
gh-address-cr final-gate <owner/repo> <pr_number>
```

If validating a stacked PR bottom-up:

```bash
gh-address-cr final-gate <owner/repo> <pr_number> --stack
```

## Interpretation of Results

- **Exit Code 0 (PASS)**:
  All review threads and findings are resolved, verified with passing tests, and
  published. The PR review session is clean and proven. You may report completion.

- **Non-zero Exit Code (FAIL / BLOCKED)**:
  The output will detail the exact remaining blockers, such as:
  - `UNRESOLVED_THREADS`: GitHub review threads still open.
  - `MISSING_VALIDATION`: Items marked resolved without passing test evidence.
  - `UNPUBLISHED_CHANGES`: Pending resolutions not yet published to GitHub.
  
  Do NOT assume completion. Direct the user or proceed with `speckit.gh-address-cr.address`
  to resolve the remaining blocker items.
