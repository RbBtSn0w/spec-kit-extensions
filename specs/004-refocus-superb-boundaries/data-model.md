# Data Model: Refocus Superb Boundaries

**Feature**: `004-refocus-superb-boundaries` | **Date**: 2026-07-03

This feature has no application persistence model. Its entities are declarative
extension contracts represented in YAML, Markdown, configuration, and tests.

## CapabilityContract

| Field | Type | Validation |
|---|---|---|
| `commands` | ordered set of `CommandContract` | Exactly seven unique command names |
| `hooks` | ordered set of `HookBinding` | Exactly two unique lifecycle keys |
| `skills` | ordered set of `SkillContract` | Exactly five unique skill names |
| `statuses` | set | Must be empty |
| `task_stores` | set | Must be empty |
| `execution_stores` | set | Must be empty |
| `completion_stores` | set | Must be empty |

Identity is the `superb` extension namespace plus the installed extension
version. Counts must agree across manifest, configuration, installer,
diagnostics, documentation, and tests.

## CommandContract

| Field | Type | Notes |
|---|---|---|
| `name` | command identifier | Must use `speckit.superb.*` |
| `kind` | `hook` or `standalone` | Hook commands remain manually invocable |
| `lifecycle_boundary` | hook key or `standalone` | Exactly one accountable boundary |
| `user_outcome` | string | Lifecycle benefit, not internal terminology |
| `reads` | set | Minimum necessary artifacts/context |
| `writes` | set | Explicit allowlist |
| `forbidden` | set | State, orchestration, or ownership violations |
| `skill` | optional `SkillContract` | At most one primary upstream discipline |
| `fallback` | enum | `native_minimum`, `unavailable`, or `not_applicable` |

### Command Identities

1. `speckit.superb.check`
2. `speckit.superb.brainstorm`
3. `speckit.superb.implementation-gate`
4. `speckit.superb.critique`
5. `speckit.superb.debug`
6. `speckit.superb.respond`
7. `speckit.superb.finish`

## HookBinding

| Hook | Command | Policy | Mutation |
|---|---|---|---|
| `after_specify` | `speckit.superb.brainstorm` | Optional | User-approved `spec.md` refinement only |
| `before_implement` | `speckit.superb.implementation-gate` | Mandatory | Read-only |

No other Superb hook is valid. In particular, `after_tasks`, `after_implement`,
`before_converge`, and `after_converge` must be absent.

## SkillContract

| Name | Consumer | Availability behavior | Stable dependency |
|---|---|---|---|
| `brainstorming` | `brainstorm` | Optional command/hook unavailable or skipped safely | Design alternatives, scope, approval |
| `test-driven-development` | `implementation-gate` | Optional upstream enhancement; bridge-native minimum TDD readiness when absent | RED before production change |
| `systematic-debugging` | `debug` | Standalone unavailable with install guidance | Evidence-led root-cause investigation |
| `receiving-code-review` | `respond` | Standalone unavailable with install guidance | Technical verification of feedback |
| `finishing-a-development-branch` | `finish` | Standalone unavailable with install guidance | Fresh tests and explicit branch choice |

Internal headings, prompt-template filenames, named agents, and exact workflow
steps are not fields in this contract.

## ArtifactRoute

| Defect class | Owning command | Superb behavior |
|---|---|---|
| Requirement ambiguity | `speckit.clarify` | Report and route |
| Plan/architecture mismatch | `speckit.plan` | Report and route |
| Missing or malformed tasks | `speckit.tasks` | Report and route |
| Cross-artifact inconsistency | `speckit.analyze`, then earliest owner | Report and route |
| Implementation execution | `speckit.implement` | Gate readiness only |
| Delivered-code gap | `speckit.converge` | Route only |
| Feedback changes requirement/plan/task meaning | Earliest affected owner | Respond stops direct code mutation |

## MigrationRemoval

Each removed surface has one terminal transition: `active -> removed`.

| Surface | Replacement/route |
|---|---|
| `speckit.superb.controller` | `speckit.superb.implementation-gate` |
| `speckit.superb.review` | `speckit.tasks` and `speckit.analyze` |
| `speckit.superb.verify` | `speckit.implement` validation and `speckit.converge` |
| `plan-gate.md` | Native `speckit.plan` |
| Superb status synchronization | No replacement state machine |
| Temporary evidence archive | Owning command's fresh in-session evidence |

Removed files, config keys, docs, and tests must not remain in the installed
payload. Migration guidance may name them only as historical removed surfaces.
