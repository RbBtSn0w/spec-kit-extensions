---
description: >
  Verify the generated tasks.md covers every requirement in spec.md before
  implementation begins. Produces a spec-coverage matrix, task-quality report,
  and TDD-readiness assessment. Catches missing or under-specified tasks at
  planning time, not delivery time.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
---

# Task Coverage Review — After Task Generation

> **Type:** Bridge-native command
> **Invocation:** Optional post-hook for `speckit.tasks`. Fires after `tasks.md` is generated.
> **Purpose:** Prevent "all tasks done, feature incomplete" — the most expensive form of rework.

This command is intentionally narrower than `/speckit.analyze`.
Use it to validate requirement coverage and implementation readiness, not to
replace full cross-artifact consistency analysis.

---

## Why This Matters

`tasks.md` is generated from `plan.md` and `spec.md`, but it is a mechanical
transformation. Requirements can fall through the cracks when:

- A user story has implied behaviors that were not written down
- Edge cases in `spec.md` were noted but not translated into tasks
- A data-model constraint was discussed in `research.md` but never became a task
- Task granularity is uneven — one task does too much and hides incomplete coverage

This review catches all of these before a single line of code is written.

---

## User Context
```
$ARGUMENTS
```

## Process — Execute in Order

### Step 1 — Load Artifacts

Read the following files (all from the current feature directory):

1. `spec.md` — the authoritative source of requirements
2. `plan.md` — the technical approach and architecture decisions
3. `tasks.md` — the generated implementation plan
4. `data-model.md` (if exists) — entity and relationship constraints
5. `contracts/` (if exists) — interface contracts

If `spec.md` is missing, **STOP** and report:
```
ERROR: spec.md not found. Cannot perform coverage review without the spec.
Run speckit.specify first.
```

Use the resolved current feature directory as the authoritative path for any
status synchronization. Do not guess the feature path from the branch name.

---

### Step 2 — Extract Requirements from spec.md

Produce a numbered list of every distinct, testable requirement from `spec.md`:

Format:
```
R01: [requirement — one sentence, action-oriented]
R02: [requirement]
...
```

Include:
- Every user story acceptance criterion
- Every constraint mentioned ("must not", "shall not", "required")
- Every non-functional requirement (performance, security, compatibility)
- Every error/edge case described

**Mark each requirement as:**
- `[TESTABLE]` — can be verified by a test
- `[OBSERVABLE]` — can be verified by running the feature
- `[STRUCTURAL]` — architectural constraint (no direct test, but verifiable via code review)

---

### Step 3 — Map Requirements to Tasks

For each requirement `R-XX`, find which task(s) in `tasks.md` implement it.

Produce the coverage matrix:

```
| Req  | Requirement                          | Tasks     | Coverage   |
|------|--------------------------------------|-----------|------------|
| R01  | User can log in with email+password  | T3, T4    | ✓ Covered  |
| R02  | Failed login shows error message     | T4        | ✓ Covered  |
| R03  | Passwords are stored hashed (bcrypt) | —         | ✗ Gap      |
| R04  | Session expires after 24 hours       | —         | ✗ Gap      |
| R05  | Supports OAuth2 login                | T7        | ~ Partial  |
```

Coverage status:
- `✓ Covered` — at least one task explicitly addresses this requirement
- `~ Partial` — a task addresses part of this requirement but leaves sub-requirements open
- `✗ Gap` — no task addresses this requirement

---

### Step 4 — Produce Gap Report

For every `✗ Gap` or `~ Partial`:

```markdown
## Coverage Gaps

### Gap: R03 — Passwords are stored hashed (bcrypt)

**Requirement:** spec.md, Section 2.3 — "Passwords must be stored using bcrypt
with a minimum work factor of 12"

**Missing task:** No task in tasks.md creates or verifies password hashing logic.

**Suggested task addition:**
> Task N+1: Write test asserting stored password hash matches bcrypt format with
> work factor ≥ 12. Implement bcrypt hashing in the auth service. Verify
> no plaintext passwords appear in logs or database.

---

### Gap: R04 — Session expires after 24 hours

**Requirement:** spec.md, Section 2.5 — "Sessions must be invalidated after 24 hours"

**Missing task:** Session expiry logic has no corresponding test task.

**Suggested task addition:**
> Task N+2: Write test asserting session token is rejected after 24 hours.
> Implement expiry check in session middleware.
```

---

### Step 5 — Check Task Quality And TDD Readiness

Beyond coverage, flag any task that has these quality issues:

| Quality Issue | Example | Flag |
|---|---|---|
| No test step | Task says "implement X" but has no "write failing test" step | ⚠ Missing TDD step |
| Vague file path | "Update the auth module" with no specific file | ⚠ Missing file path |
| Placeholder content | Task says "fill in details later" or "add appropriate handling" — open-ended directives with no concrete action | ⚠ Placeholder detected |
| Multiple behaviors in one task | Task covers login AND logout AND session | ⚠ Overly broad |
| No commit step | Task has no `git commit` at end | ⚠ Missing commit step |

Also evaluate whether the task set is ready for a strict TDD gate:

- Can each user-visible or testable requirement be linked to at least one test-first task?
- Are test targets concrete enough that `/speckit.superb.tdd` can enforce RED before GREEN?
- Are tasks ordered so foundational setup does not force speculative production code before tests?
- Are broad tasks split enough that one failing test can drive one meaningful increment?

---

### Step 6 — Summary and Decision

Produce a summary:

```markdown
## Coverage Review Summary

**Requirements extracted:** [N]
**Fully covered:** [A] ([A/N]%)
**Partially covered:** [B]
**Gaps identified:** [C]
**Task quality issues:** [D]
**TDD readiness:** [READY / PARTIAL / NOT READY]

**Decision:**
```

If `C > 0` (gaps exist):

```
⚠ GAPS DETECTED — Implementation should not begin until gaps are addressed.

Recommended action:
1. Review each gap above
2. Add missing tasks to tasks.md
3. Re-run coverage review OR proceed with explicit acknowledgment of scope reduction
```

If `C == 0` and `D == 0`:

```
✓ COVERAGE COMPLETE — All requirements have corresponding tasks.
tasks.md is ready for implementation.
```

If `C == 0` but `D > 0`:

```
⚠ QUALITY ISSUES — Coverage is complete but task quality issues may cause
TDD violations during implementation.

Recommended action: Fix flagged tasks before running speckit.implement.
```

---

### Step 7 — Status Synchronization

If this review is running as the normal `after_tasks` lifecycle step and
`tasks.md` was generated successfully, synchronize the feature spec status:

- Run:
  ```bash
  {SCRIPT} --status "Tasked"
  ```
- Use the script output as the source of truth for:
  - resolved spec path
  - previous status
  - new status
- Report the updated spec path and resulting status in the summary

Do **not** perform this update when:

- `tasks.md` generation failed
- the active feature spec cannot be resolved reliably
- the feature is already marked `Abandoned`

---

## Non-blocking Mode

If the user explicitly ran this review after acknowledging gaps, note the acknowledged
gaps and proceed:

```
NOTE: [N] gaps were identified and flagged. Proceeding to implementation
with explicit acknowledgment. Gaps should be tracked as follow-on work.
```
