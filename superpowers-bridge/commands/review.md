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

If `spec.md` exists and its actual status is `Abandoned`, emit the full
`Workflow Decision` block before any missing-artifact fallback, even when
`plan.md` or `tasks.md` is missing or unresolved:

```markdown
## Workflow Decision

**Feature status:** Abandoned
**Gate:** after_tasks.review
**Outcome:** BLOCKED
**Reason:** abandoned_feature
**Next command:** none
**Requires user approval:** true

**Why:** Abandoned features cannot route to implementation or artifact repair until the user reactivates the feature.
```

Then **STOP** and report:
```
ERROR: Feature status is Abandoned. Reactivate the feature before running coverage review.
```

If `spec.md`, `plan.md`, or `tasks.md` is missing or cannot be resolved after
the abandoned-status check, emit the full `Workflow Decision` block (use the
actual spec status from `spec.md` if available, otherwise use `unknown`):

```markdown
## Workflow Decision

**Feature status:** [actual status or unknown]
**Gate:** after_tasks.review
**Outcome:** INCONCLUSIVE
**Reason:** missing_artifact
**Next command:** none
**Requires user approval:** true

**Why:** Required planning artifacts are missing or unresolved. Cannot perform coverage review.
```

Then **STOP** and report:
```
ERROR: One or more required planning artifacts (spec.md, plan.md, tasks.md) are missing or unresolved. Run the appropriate Spec Kit pipeline stage.
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
- Are test targets concrete enough that `/speckit.superb.controller` can enforce RED before GREEN?
- Are tasks ordered so foundational setup does not force speculative production code before tests?
- Are broad tasks split enough that one failing test can drive one meaningful increment?

Apply these `writing-plans`-derived checks without generating or replacing a
Spec Kit plan:

### File Ownership Map

Every implementation task should name the concrete file, module, contract, or
test target it owns. Flag tasks that require an implementer to rediscover the
intended file map from scratch.

### Task Granularity

Tasks should be bite-sized enough for one RED → GREEN → REFACTOR increment.
Flag tasks that combine unrelated behaviors, setup, migration, and polish in a
single checkbox.

### RED/GREEN Target

Every testable behavior should identify the failing test or observable check
that proves RED before production code is written, and the command that proves
GREEN after implementation.

### Review Checkpoint Readiness

The task set should make it clear where a reviewer can check spec compliance
and code quality. Flag task groups that have no natural review checkpoint before
large cross-cutting changes accumulate.

### Artifact Consistency Checks

Evaluate whether the artifacts contain any obvious blocking discrepancies (note: this command does not replace full consistency checks performed by `/speckit.analyze`, but visible issues must block execution):

- **Spec Ambiguity**: Are requirements in `spec.md` blatantly ambiguous, contradictory, or missing critical details that tasks had to guess?
- **Plan/Task Discrepancies**: Do `plan.md` and `tasks.md` disagree on architecture, files, interface contracts, or implementation sequencing?

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
2. Delegate requirement-coverage-gap remediation to `/speckit-converge`, which assesses the
   code against spec/plan/tasks and append-only writes the remaining work as new, traceable
   tasks. This command does NOT itself add coverage tasks — converge owns delivery-stage
   coverage remediation; review owns plan-stage task-quality and TDD-readiness gating.
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

Then always emit a workflow routing decision. This decision does not create a
new lifecycle state. It explains whether the current feature status (`Tasked` or `Abandoned`) is
ready to enter implementation, or which Spec Kit owner should handle the
remediation loop.

```markdown
## Workflow Decision

**Feature status:** Tasked | Abandoned | unknown
**Gate:** after_tasks.review
**Outcome:** PASS | BLOCKED | INCONCLUSIVE
**Reason:** none | coverage_gap | task_quality_issue | spec_ambiguity | plan_task_mismatch | missing_artifact | abandoned_feature
**Next command:** `/speckit.implement` | `/speckit.clarify` | `/speckit.plan` | `/speckit.tasks` | `/speckit-converge` | none
**Requires user approval:** true | false

**Why:** [One sentence explaining why the selected command owns the next step.]
```

Use this routing table:

| Condition | Outcome | Reason | Next command | Requires user approval | Why |
|---|---|---|---|---|---|
| No gaps, no task quality issues, TDD readiness is READY, and feature status is not Abandoned | PASS | none | `/speckit.implement` | false | `tasks.md` is coverage-complete and ready for the TDD gate. |
| Feature status is Abandoned | BLOCKED | abandoned_feature | none | true | Abandoned features cannot route to implementation. |
| `spec.md` requirement is ambiguous or contradictory | BLOCKED | spec_ambiguity | `/speckit.clarify` | true | The spec owns requirement meaning; tasks should not guess. |
| `plan.md` and `tasks.md` disagree about architecture, files, contracts, or sequencing | BLOCKED | plan_task_mismatch | `/speckit.plan` | true | The technical plan owns the implementation approach before tasks are regenerated. |
| One or more requirements have `✗ Gap` or `~ Partial` task coverage (Normal Mode) | BLOCKED | coverage_gap | `/speckit-converge` | false | Converge owns delivery-stage requirement-gap remediation and appends traceable remaining-work tasks. |
| One or more requirements have `✗ Gap` or `~ Partial` task coverage (Non-blocking Mode with explicit gap acknowledgment) | PASS | none | `/speckit.implement` | false | The user explicitly acknowledged gaps to bypass task regeneration. |
| Coverage is complete but tasks are too broad, vague, missing file ownership, missing RED/GREEN targets, missing test/commit steps, or TDD readiness is PARTIAL/NOT READY | BLOCKED | task_quality_issue | `/speckit.tasks` | false | The task artifact must be shaped before strict TDD can execute it. |
| Required artifacts are missing or cannot be resolved | INCONCLUSIVE | missing_artifact | none | true | The gate lacks enough evidence to route safely. |

When multiple conditions apply, prioritize `abandoned_feature` (which blocks the review) first, and then `missing_artifact` (which makes the review `INCONCLUSIVE`). Otherwise, choose the earliest owning stage in the Spec Kit flow: `clarify` before `plan`, `plan` before `tasks`, and `tasks` before `implement`. Include the lower-level issues in the report, but route to the earliest stage that can correct the source of truth.

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
