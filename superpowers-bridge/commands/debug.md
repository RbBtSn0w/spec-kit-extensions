---
description: >
  Systematic debugging protocol. Bridges an installed obra/superpowers
  systematic-debugging skill. Enforces root-cause investigation before any fix
  attempt. Use when TDD hits repeated failures or any unexpected behavior
  surfaces during implementation.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
---

# Systematic Debugging — Root Cause Before Fixes

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `systematic-debugging`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call manually when blocked, or escalated from the TDD gate after 2+ failed fix attempts.

---

## Step 1 — Resolve Installed Skill

Run `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill systematic-debugging`.

The resolver is the canonical discovery helper for this bridge. It checks, in
order, direct workspace installs, workspace plugin installs, direct global
installs, then global plugin installs.

If no readable file is found, enter the **inline install recovery flow**:
1. Run `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --check-prereqs`.
2. If `npx` is available, show the missing-skill error plus the generated output from
   `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --print-guidance`, then ask:
   `Would you like to install now? (Select approach 1-3, or skip)`
3. Only if the user explicitly selects `1`, `2`, or `3`, run:
   `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --install <selection>`
4. After a successful install, re-run the skill resolution by invoking
   `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill systematic-debugging`
   once before continuing.
5. If the user skips, `npx` is unavailable, installation fails, or the re-check still
   cannot resolve the skill, print the guidance and halt execution. The command remains
   unavailable until the skill is installed.

Report the source you resolved before continuing:

```text
Using installed skill: systematic-debugging
Source: [workspace|global]
Install type: [skill-root|plugin]
Path: [resolved path]
```

---

## Step 2 — Bind Spec-Kit Context

1. Read any user-provided context or explicit error logs:
   ```
   $ARGUMENTS
   ```
2. Read the current `tasks.md` to identify which task is blocked.
3. Read `spec.md` to understand the intended behavior (not what the code does,
   but what it **should** do).
4. Gather evidence:
   - The exact error message or unexpected behavior
   - The test command and its output
   - Recent `git diff` or `git log --oneline -10`

Do not propose any fix yet. Evidence gathering is Phase 1.

---

## Step 3 — Execute the Debugging Skill

Apply the resolved installed skill's four-phase protocol:

1. **Root Cause Investigation** — read errors completely, reproduce consistently,
   check recent changes, trace data flow. Do NOT skip to proposing solutions.
2. **Pattern Analysis** — find working examples in the same codebase, compare
   against what's broken, list every difference.
3. **Hypothesis and Testing** — form ONE hypothesis, test with the SMALLEST
   possible change, one variable at a time.
4. **Implementation** — create a failing test for the root cause, implement a
   single fix, verify the full test suite.

---

## Step 4 — Parallel Dispatch Mode

Use this mode only when debugging evidence shows **2+ independent failure domains**.
It is adapted from the optional `dispatching-parallel-agents` skill, but this
command remains the controller.

### Independence Gate

Before preparing parallel work, answer all of these from evidence:

- Are there multiple failures, test files, subsystems, or bugs?
- Can each domain be understood without shared context from the others?
- Would fixing one domain be unlikely to change the others?
- Can agents work without editing the same files or shared state?

If any answer is "no" or "unknown", do not dispatch in parallel. Continue with
single-root-cause systematic debugging.

### Optional Skill Resolution

If parallel dispatch is appropriate, resolve `dispatching-parallel-agents` with
`bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill dispatching-parallel-agents`.

If unavailable, still produce the domain breakdown and focused task prompts,
but report that automated parallel dispatch guidance is unavailable.

### Task Package Format

For each independent domain, produce one focused agent task:

```markdown
## Parallel Debug Task: [domain name]

**Scope:** [one test file, subsystem, or bug cluster]
**Known failures:** [test names, error messages, commands]
**Relevant spec/task context:** [requirement or task references]
**Goal:** Identify root cause and propose or implement the smallest fix.
**Constraints:** Do not edit unrelated files. Do not broaden scope. Do not hide
failures by changing expectations without evidence.
**Return:** Root cause, files changed or recommended, verification command and
output, remaining risks.
```

### Controller Integration

Parallel agent outputs are not completion evidence. After all agents return:

1. Review every summary and diff.
2. Check for overlapping files or conflicting assumptions.
3. Run the targeted failing tests.
4. Run the full relevant test suite.
5. Perform **controller verification** before declaring the debugging pass
   resolved.

If any fix changes another domain, stop parallel integration and return to
single-threaded root-cause analysis.

---

## Escalation Rule

If **3 or more fix attempts** have failed:

- **STOP.** Do not attempt fix #4.
- Question the architecture: Is the current pattern fundamentally sound?
- Report to the user with evidence of all 3 attempts and a recommendation:
  refactor the approach vs. continue fixing symptoms.

---

## Integration with TDD Gate

This command is the **escalation path** from `speckit.superb.controller`.
When the TDD cycle hits repeated RED failures that don't resolve with simple
GREEN fixes:

```
TDD cycle → RED passes but GREEN fails repeatedly
         → 2+ attempts without resolution
         → STOP TDD → invoke this command
         → resolve root cause
         → return to TDD cycle
```

After debugging resolves the root cause, return to the TDD gate and resume
the RED → GREEN → REFACTOR cycle for the current task.
