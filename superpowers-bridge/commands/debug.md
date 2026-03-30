---
description: >
  Systematic debugging protocol. Loads the obra/superpowers
  systematic-debugging SKILL.md at runtime. Enforces root-cause investigation
  before any fix attempt. Use when TDD hits repeated failures or any
  unexpected behavior surfaces during implementation.
---

# Systematic Debugging — Root Cause Before Fixes

> **Skill origin:** [obra/superpowers `systematic-debugging`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call manually when blocked, or escalated from the TDD gate after 2+ failed fix attempts.

---

## Step 1 — Load the Authoritative Debugging Skill

Locate and internalize the superpowers systematic-debugging skill using this priority chain:

1. **Local plugin:** Read `skills/systematic-debugging/SKILL.md` from the
   workspace root (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/systematic-debugging/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
   > Phase 1: Read errors, reproduce, check recent changes, trace data flow.
   > Phase 2: Find working examples, compare, identify differences.
   > Phase 3: Form single hypothesis, test minimally, one variable at a time.
   > Phase 4: Create failing test, implement single fix, verify.
   > If 3+ fixes fail, question the architecture — don't attempt fix #4.

**You must internalize the full SKILL.md content before proceeding.** Its rules
override any urge to "just try something."

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

Apply the loaded skill's four-phase protocol:

1. **Root Cause Investigation** — read errors completely, reproduce consistently,
   check recent changes, trace data flow. Do NOT skip to proposing solutions.
2. **Pattern Analysis** — find working examples in the same codebase, compare
   against what's broken, list every difference.
3. **Hypothesis and Testing** — form ONE hypothesis, test with the SMALLEST
   possible change, one variable at a time.
4. **Implementation** — create a failing test for the root cause, implement a
   single fix, verify the full test suite.

---

## Escalation Rule

If **3 or more fix attempts** have failed:

- **STOP.** Do not attempt fix #4.
- Question the architecture: Is the current pattern fundamentally sound?
- Report to the user with evidence of all 3 attempts and a recommendation:
  refactor the approach vs. continue fixing symptoms.

---

## Integration with TDD Gate

This command is the **escalation path** from `speckit.superb.tdd`.
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
