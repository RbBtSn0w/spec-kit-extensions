---
description: >
  Mandatory completion gate. Bridges an installed obra/superpowers
  verification-before-completion skill and extends it with spec-kit's
  spec-coverage checklist. No task may be marked done without fresh evidence.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
  archive_sh: scripts/bash/archive-evidence.sh
  archive_ps: scripts/powershell/archive-evidence.ps1
---

# Verification Before Completion — After Implementation

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `verification-before-completion`](https://github.com/obra/superpowers)
> **Invocation:** Mandatory post-hook for `speckit.implement`. Cannot be skipped.

---

## Step 1 — Resolve Installed Skill

Any user context provided:
```
$ARGUMENTS
```

Look for `verification-before-completion/SKILL.md` in this exact order:

1. `./.agents/skills/verification-before-completion/SKILL.md`
2. `~/.agents/skills/verification-before-completion/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Required superpowers skill `verification-before-completion` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: verification-before-completion
Source: [workspace|global]
Path: [resolved path]
```

---

## Step 2 — Resolve Active Feature Spec

Resolve the active feature spec path using the same Spec Kit prerequisite script
pattern used by follow-up commands:

- Prefer `FEATURE_SPEC` when present
- Otherwise use `FEATURE_DIR/spec.md`

Do not derive the path from the branch name manually.
If the active feature spec cannot be resolved, **STOP** and report the failure.

---

## Step 3 — Execute the Verification Skill

Apply the resolved installed skill against the current implementation state:

1. Run the project's **full** test suite (not a subset) and paste the output.
2. Run any applicable build / lint / type-check commands and paste the output.
3. Follow the skill's evidence requirements exactly — "should pass" or
   "I'm confident" are never acceptable substitutes for fresh output.

---

## Step 4 — Spec-Kit Extension: Spec-Coverage Checklist

After the verification skill's checks pass, perform this additional spec-kit gate:

1. Re-read `spec.md` in full.
2. For each requirement or user story, verify the implementation satisfies the
   acceptance criteria and map it to a passing test:

```markdown
## Spec Verification Checklist

- [x] R01: [requirement] — verified by [test file]::[test name]
- [x] R02: [requirement] — verified by [test file]::[test name]
- [ ] R03: [requirement] — NOT VERIFIED ([reason])
```

3. If any `spec.md` requirement is unchecked:

```
⚠ INCOMPLETE: [N] spec requirements are not verified.
Cannot declare implementation complete.
Unmet requirements: [list them]
```

**Do not proceed past this point if any requirement is uncovered.**

---

## Step 5 — Archiving Evidence

Archive the verification results to `.specify/evidence/` by executing the archiving script. The test output and checklist must both be present and should be passed via stdin to avoid command-line argument size limits.

On Unix-like systems (sh):
```bash
ARCHIVE_SCRIPT="$(dirname "{SCRIPT}")/archive-evidence.sh"
cat << 'EOF' | bash "$ARCHIVE_SCRIPT" --feature-name "[feature-name]" --build-status "[build-status]"
[checklist]

---OUTPUT---
[test-output]
EOF
```

On Windows (PowerShell):
```powershell
$ArchiveScript = Join-Path (Split-Path "{SCRIPT}") "archive-evidence.ps1"
$EvidenceContent = @"
[checklist]

---OUTPUT---
[test-output]
"@
$EvidenceContent | pwsh -NoProfile -File "$ArchiveScript" -FeatureName "[feature-name]" -BuildStatus "[build-status]"
```

Replace the arguments with:
- `[feature-name]`: The active feature directory name resolved from Step 2. If `spec.md` is at the repository root, use the repository directory name.
- `[build-status]`: "PASS", "FAIL", or "N/A" depending on the build / lint / type-check status.
- `[test-output]`: The full stdout/stderr of the test suite (from Step 3).
- `[checklist]`: The completed markdown Spec Verification Checklist (from Step 4).

---

## Step 6 — Status Synchronization

Only after all verification checks pass AND evidence is successfully archived, synchronize the feature spec status to:

```bash
{SCRIPT} --status "Verified"
```

Status sync rules:

- Use the script output as the source of truth for resolved spec path and
  resulting status
- If verification fails or archiving fails, leave the previous status unchanged
- Do not overwrite `Abandoned`
- Do not introduce `Completed` here

---

## Step 7 — Completion Report

When all checks pass, output:

```markdown
## Implementation Complete — Verification Evidence

**Test suite:** [N] tests, [N] passing, 0 failing
**Spec coverage:** [N/N] requirements verified (see checklist above)
**Build:** [PASS / N/A]
**Lint:** [PASS / N/A]

All spec requirements are met. Implementation is verified complete.

Suggested next steps:
- Run `speckit.superb.critique` for code review against spec
- Or proceed to PR creation
```

If anything is unverified:

```markdown
## Implementation Status — INCOMPLETE

**Test suite:** [status]
**Spec coverage:** [N/M] requirements verified, [M-N] unverified
**Unverified requirements:** [list]

Implementation cannot be declared complete until all items above are resolved.
```
