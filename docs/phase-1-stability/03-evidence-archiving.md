# Technical Plan: Evidence-Based Archiving (Phase 1)

## Problem

`/speckit.superb.verify` can ask the agent to paste verification results into the chat, but chat evidence is transient. Once the session is closed, compacted, or summarized, reviewers cannot reliably inspect why a feature was marked `Verified`.

## Product Boundary

Evidence archiving is the current product wedge. The goal is not to create a dashboard; the goal is to make completion claims auditable in the repository.

## Proposed Solution

Archive verification artifacts under:

```text
.specify/evidence/
```

Each evidence file uses:

```text
<timestamp>-<feature-name>-verify.md
```

The archive must include:

- UTC timestamp;
- feature name;
- git commit hash;
- build/lint status;
- spec-coverage checklist;
- full test output.

## Completion Contract

`Verified` may be written only after:

1. verification has passed;
2. the spec-coverage checklist is complete;
3. test output is present;
4. evidence is archived successfully.

If evidence archiving fails, the previous status must remain unchanged.

## Implementation Path

- `superpowers-bridge/commands/verify.md` describes the verification and archiving sequence.
- `superpowers-bridge/scripts/bash/archive-evidence.sh` writes Unix evidence archives.
- `superpowers-bridge/scripts/powershell/archive-evidence.ps1` writes PowerShell evidence archives.
- `universal-bridge/hooks/pre-commit-sdd` checks that `Verified` specs have matching evidence before commit.

## Verification

- Missing checklist fails.
- Missing test output fails.
- Missing `---OUTPUT---` separator fails.
- Invalid build status fails.
- A `Verified` spec without matching evidence fails the portable pre-commit gate.
