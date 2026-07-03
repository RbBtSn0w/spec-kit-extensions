---
description: >
  Mandatory read-only pre-implementation gate. Reports test-first readiness
  while leaving task execution and concurrency decisions with Spec Kit.
---

# Implementation Gate

## User Context

```text
$ARGUMENTS
```

This command is read-only. It never changes `spec.md`, `plan.md`, `tasks.md`,
task checkboxes, git state, or lifecycle state.

## Step 1 - Resolve Required Artifacts

Resolve the active feature through the Spec Kit prerequisite helper. Require
readable `spec.md`, `plan.md`, and `tasks.md`. If one is missing, report the
missing artifact and return control to its owning Spec Kit command.

## Step 2 - Load Test-First Guidance

Run:

```bash
bash .specify/extensions/superb/scripts/bash/resolve-skill.sh --skill test-driven-development
```

When the skill is available, apply its durable discipline: write a focused
failing test, observe the expected failure, make the minimum production change,
then observe the focused and regression checks pass.

When it is unavailable, apply this bridge-native minimum instead:

1. Every behavior-changing task identifies a focused test command.
2. The test must fail for the intended missing behavior before production work.
3. The smallest implementation makes that test pass.
4. Relevant regression checks pass before the task is marked complete.

The missing skill reduces guidance depth but does not block the standard Spec
Kit implementation path.

## Step 3 - Report Readiness

Inspect incomplete tasks and report:

- missing artifacts or unresolved prerequisites;
- whether upstream or native minimum TDD guidance applies;
- tasks that declare Spec Kit `[P]` independence markers;
- ordering or shared-file constraints already stated by `tasks.md`.

Do not convert `[P]` into an execution policy. The owning Spec Kit implementation
flow and active agent runtime decide ordering and concurrency.

Return only a readiness result:

```markdown
## Implementation Readiness

**Artifacts:** READY | BLOCKED
**TDD guidance:** UPSTREAM | NATIVE MINIMUM
**Incomplete tasks:** [task ids]
**Spec Kit `[P]` markers:** [task ids or none]
**Blocking findings:** [findings or none]

Readiness checked; return control to `/speckit.implement`.
```
