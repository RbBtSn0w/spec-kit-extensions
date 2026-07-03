# Superb Workflow Contract

Superb strengthens selected Spec Kit boundaries. Spec Kit remains the sole owner
of specification, clarification, planning, tasks, implementation,
convergence, and their canonical artifacts.

## Stage Routing

| Spec Kit event | Superb command | Policy | Responsibility |
|---|---|---|---|
| `after_specify` | `speckit.superb.brainstorm` | Optional | Apply user-approved refinement to the existing `spec.md`. |
| `before_implement` | `speckit.superb.implementation-gate` | Required | Report test-first readiness without executing or scheduling tasks. |

There are no Superb hooks after tasks, implementation, or convergence. Task
coverage belongs to `speckit.tasks` and `speckit.analyze`; delivered-code gaps
belong to `speckit.converge`.

## Standalone Commands

- `critique` reports evidence-backed implementation findings and is read-only.
- `debug` investigates the current failing task and returns control after focused verification.
- `respond` verifies supplied feedback and routes artifact meaning changes to the earliest owner.
- `finish` offers an explicit branch handoff after convergence and fresh checks.

## Skill Contract

Superb resolves exactly five disciplines: `brainstorming`,
`test-driven-development`, `systematic-debugging`, `receiving-code-review`, and
`finishing-a-development-branch`. Installing the complete upstream plugin is a
distribution option and does not expand this logical runtime contract.

## Migration

- Replace `speckit.superb.controller` with `speckit.superb.implementation-gate`.
- Use `speckit.tasks` and `speckit.analyze` instead of the removed post-tasks review.
- Use Spec Kit implementation evidence and `speckit.converge` instead of the removed completion command.
- Remove Superb status synchronization and temporary evidence archives.
