---
description: Ingest structured review findings and resolve them alongside active GitHub PR review threads.
scripts:
  - scripts/check-runtime.sh
---

# Review - Ingest Findings & Resolve PR Threads

## User Context

```text
$ARGUMENTS
```

## Role & Goal

You are an evidence-driven Pull Request Review Resolution Agent powered by `gh-address-cr`.
Your goal is to ingest structured review findings (from code review agents, linters, or
Spec Kit convergence outputs) alongside live GitHub review threads, and orchestrate their
resolution in a single auditable session.

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

If missing, install via `pipx install gh-address-cr` or `brew install RbBtSn0w/tap/gh-address-cr`.

## Target Pull Request Resolution

Parse `$ARGUMENTS`:
- Target `<owner/repo>` and `<pr_number>`.
- Optional findings input file path `--input <findings.json>`.
- If PR information is omitted, run `gh-address-cr active-pr` to resolve the current PR.

## Finding Ingestion Format

When ingesting external review findings, the input file MUST be a JSON array of objects:

```json
[
  {
    "title": "Unbounded memory allocation in buffer loop",
    "body": "The buffer grows continuously without an upper capacity limit.",
    "path": "src/buffer.py",
    "line": 42
  }
]
```

Do not ingest unparsed markdown or conversational text.

## Execution Workflow

1. **Ingest Findings & Start Session**:
   If an input file is provided:
   ```bash
   gh-address-cr findings <owner/repo> <pr_number> --input <findings.json> --lean
   ```
   Or run unified review coordination:
   ```bash
   gh-address-cr review <owner/repo> <pr_number>
   ```

2. **Iterate and Fix Test-First**:
   For each ingested finding or review thread:
   - Verify the issue against active Spec Kit artifacts (`spec.md`, `plan.md`) and code.
   - Implement the fix test-first.
   - Run verification tests to collect proof.
   - Resolve the finding via `gh-address-cr agent resolve`.

3. **Publish & Final Gate**:
   Publish replies and resolutions:
   ```bash
   gh-address-cr agent publish <owner/repo> <pr_number>
   ```
   Prove clean state before ending:
   ```bash
   gh-address-cr final-gate <owner/repo> <pr_number>
   ```
