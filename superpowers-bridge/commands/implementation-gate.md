---
description: >
  Mandatory read-only pre-implementation gate. Reports test-first readiness
  while leaving task execution decisions with Spec Kit.
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
- behavior-changing tasks without a focused test command or explicit test-first
  expectation.

Do not interpret task scheduling metadata. The owning Spec Kit implementation
flow and active agent runtime decide how tasks execute.

Return only a readiness result:

```markdown
## Implementation Readiness

**Artifacts:** READY | BLOCKED
**TDD guidance:** UPSTREAM | NATIVE MINIMUM
**Incomplete tasks:** [task ids]
**Missing test-first readiness:** [task ids or none]
**Blocking findings:** [findings or none]

Readiness checked; return control to `/speckit.implement`.
```
