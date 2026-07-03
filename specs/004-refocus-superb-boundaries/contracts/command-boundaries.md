# Superb Command Boundaries

## `speckit.superb.check`

- Reads: installed extension metadata, Superb config, and availability of the five contracted skills.
- Writes: nothing unless the user explicitly accepts a skill installation action.
- Reports: five-skill readiness, two-hook registration, and availability of the four standalone commands.
- Must not: inspect or install unrelated plugins, mutate feature artifacts, or create lifecycle state.

## `speckit.superb.brainstorm`

- Trigger: optional `after_specify` hook or explicit invocation.
- Reads: the current feature specification, relevant project context, and the `brainstorming` skill when available.
- Writes: only user-approved improvements to the current specification.
- Fallback: safely skip or provide bounded native questions when the skill is unavailable.
- Must not: create plans or tasks, change branches, select an execution mode, update status, or invoke `writing-plans`.

## `speckit.superb.implementation-gate`

- Trigger: mandatory `before_implement` hook or explicit invocation.
- Reads: the current specification, plan, tasks, and availability of `test-driven-development`.
- Writes: no feature artifacts and no runtime state.
- Reports: implementation readiness, missing prerequisites, TDD guidance availability, and behavior-changing tasks without explicit test-first readiness.
- Must not: inspect or report parallel markers, ordering, shared-file constraints, or any other task-scheduling metadata.
- Fallback: provide the minimum native TDD gate when the Superpowers skill is unavailable.
- Must not: select single-agent or multi-agent modes, form batches, dispatch agents, execute tasks, edit task checkboxes, commit changes, or persist status.

## `speckit.superb.critique`

- Trigger: explicit invocation only.
- Reads: the supplied diff or review scope and relevant requirements.
- Writes: no code or feature artifacts.
- Reports: evidence-backed findings ordered by severity, with artifact-routing guidance when requirements are wrong or incomplete.
- Must not: fix findings, create tasks, declare completion, or replace Spec Kit analysis and convergence.

## `speckit.superb.debug`

- Trigger: explicit invocation for a current reproducible failure.
- Reads: the failing task, evidence, focused tests, and `systematic-debugging` when available.
- Writes: a focused failing test and minimal fix when the user requested implementation.
- Must not: dispatch parallel agents, update lifecycle status, modify unrelated tasks, or advance the Spec Kit stage automatically.

## `speckit.superb.respond`

- Trigger: explicit invocation with supplied review findings.
- Reads: the findings, affected requirements, code, and `receiving-code-review` when available.
- Writes: only accepted, in-scope fixes.
- Routing rule: findings that change specification, planning, or task meaning return to `speckit-clarify`, `speckit-plan`, or `speckit-tasks` before code mutation.
- Must not: invent review findings, silently broaden scope, or mark the feature complete.

## `speckit.superb.finish`

- Trigger: explicit invocation after Spec Kit convergence and required checks.
- Reads: fresh verification evidence, branch state, workspace ownership, and `finishing-a-development-branch` when available.
- Writes: only the git or pull-request action explicitly selected by the user.
- Must preserve: unrelated workspaces and uncommitted changes not owned by the current feature.
- Must not: run a second convergence workflow, write Superb status, archive evidence, or choose a destructive git action implicitly.
