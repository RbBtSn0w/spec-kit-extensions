---
description: >
  Systematic debugging protocol. Bridges an installed obra/superpowers
  systematic-debugging skill. Enforces root-cause investigation before any fix
  attempt. Use when TDD hits repeated failures or any unexpected behavior
  surfaces during implementation.
---

# Systematic Debugging — Root Cause Before Fixes

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `systematic-debugging`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call manually when blocked, or escalated from the TDD gate after 2+ failed fix attempts.

---

## Step 1 — Resolve Installed Skill

Look for `systematic-debugging/SKILL.md` in this exact order:

1. `./.agents/skills/systematic-debugging/SKILL.md`
2. `~/.agents/skills/systematic-debugging/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Optional superpowers skill `systematic-debugging` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: systematic-debugging
Source: [workspace|global]
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

If parallel dispatch is appropriate, look for
`dispatching-parallel-agents/SKILL.md` in the same discovery order:

1. `./.agents/skills/dispatching-parallel-agents/SKILL.md`
2. `~/.agents/skills/dispatching-parallel-agents/SKILL.md`

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
