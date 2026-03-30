---
description: >
  Mandatory pre-implement TDD gate. Loads the obra/superpowers
  test-driven-development SKILL.md at runtime and binds it to spec-kit's
  tasks.md task structure. Enforces RED-GREEN-REFACTOR for every task.
---

# TDD Enforcement Gate — Before Implementation

> **Skill origin:** [obra/superpowers `test-driven-development`](https://github.com/obra/superpowers)
> **Invocation:** Mandatory pre-hook for `speckit.implement`. Cannot be skipped.

---

## Step 1 — Load the Authoritative TDD Skill

Locate and internalize the superpowers TDD skill using this priority chain:

1. **Local plugin:** Read `skills/test-driven-development/SKILL.md` from the
   workspace root (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/test-driven-development/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.
   > For every task: RED (write failing test) → GREEN (minimal code to pass) →
   > REFACTOR (clean up, tests still green) → COMMIT.
   > If you wrote code before seeing a test fail, delete that code and restart.

**You must internalize the full SKILL.md content before proceeding.** Its rules
are non-negotiable for this implementation session.

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

Apply the loaded TDD skill to every task in `tasks.md`:

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