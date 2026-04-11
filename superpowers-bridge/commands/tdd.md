---
description: >
  Mandatory pre-implement TDD gate. Bridges an installed obra/superpowers
  test-driven-development skill into spec-kit's tasks.md task structure and
  enforces RED-GREEN-REFACTOR for every task.
---

# TDD Enforcement Gate — Before Implementation

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `test-driven-development`](https://github.com/obra/superpowers)
> **Invocation:** Mandatory pre-hook for `speckit.implement`. Cannot be skipped.

---

## Step 1 — Resolve Installed Skill

Look for `test-driven-development/SKILL.md` in this exact order:

1. `./.agents/skills/test-driven-development/SKILL.md`
2. `~/.agents/skills/test-driven-development/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Required superpowers skill `test-driven-development` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: test-driven-development
Source: [workspace|global]
Path: [resolved path]
```

---

## Step 2 — Bind Spec-Kit Task Context

1. Identify the task or context to work on:
   ```
   $ARGUMENTS
   ```
2. Read `tasks.md` in the current feature directory to understand the task plan.
3. Run the project's test suite now and record the baseline:

```
Baseline: [N] tests, [M] passing, [K] failing
```

If the baseline has unexpected failures, **STOP** and report them before proceeding.

4. For each task, note its test target (file, assertion, verification command)
   as declared in `tasks.md`. These are your RED-phase targets — do not invent
   new test locations unless the plan specifies a reason.

---

## Step 3 — Execute

Apply the resolved installed TDD skill to every task in `tasks.md`:

- Follow the RED → GREEN → REFACTOR → COMMIT cycle exactly as the skill defines.
- Paste evidence of each RED failure and each GREEN pass inline.
- If any task starts with production code before a failing test, delete the code
  and restart from RED. **No exceptions without explicit user permission.**

---

## Escalation — When TDD Gets Stuck

If you have attempted **2 or more fixes** for the same failing test without
success, **STOP the TDD cycle** and escalate:

> Invoke `/speckit.superb.debug` to switch to the systematic
> debugging protocol. It will enforce root-cause investigation before any
> further fix attempts. Return to this TDD gate after the root cause is resolved.

Do not attempt fix #3 without completing the debugging protocol first.

---

## Enforcement Checklist (per task)

Before starting:
- [ ] No production code written yet for this task
- [ ] Test target identified from `tasks.md`

After completing:
- [ ] Saw the test FAIL before writing production code
- [ ] Wrote the MINIMUM code to pass
- [ ] Full test suite passes (no regressions)
- [ ] Committed the green state

**Cannot check all boxes? Stop. Restart the task from RED.**
