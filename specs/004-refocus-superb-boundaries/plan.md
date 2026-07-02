# Implementation Plan: Refocus Superb Boundaries

**Branch**: `004-refocus-superb-boundaries` | **Date**: 2026-07-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-refocus-superb-boundaries/spec.md`

## Summary

Refactor Superb from a five-hook partial workflow into a focused Spec Kit
adapter with exactly seven commands, two lifecycle hooks, five logical
Superpowers skills, and no Superb-owned lifecycle state. Spec Kit remains the
owner of task completeness, artifact analysis, implementation, convergence,
and completion validation. Superb retains optional spec refinement, a bounded
pre-implementation TDD readiness gate, and four narrowly scoped standalone
disciplines.

The implementation is a contract-first package migration. Tests will first
encode the target command/hook/skill inventory and each retained command's write
boundary. Production changes then remove the obsolete review, verify,
controller, plan-gate, status, and evidence surfaces; add the new
`implementation-gate`; narrow standalone commands; and synchronize every
manifest, config, installer, documentation, catalog, and test consumer.

## Technical Context

**Language/Version**: Markdown command definitions; YAML 1.2-compatible manifests/config;
Bash 3.2+; PowerShell 7 where parity applies; Python 3.10+ and Ruby for test assertions.

**Primary Dependencies**: Spec Kit extension schema `1.0`; Spec Kit `>=0.12.0`
with pinned `0.12.4` installation validation; Superpowers skill documents
`>=5.0.0`; optional `npx adg` installation path.

**Storage**: Repository files only: `extension.yml`, command Markdown, shell
helpers, config template, documentation, catalog metadata, and tests. No runtime
database or persistent Superb state.

**Testing**: Existing Bash contract/regression suites, PowerShell parity checks
where retained, Ruby YAML parsing, `git diff --check`, and a temporary pinned
Spec Kit 0.12.4 installation/package inspection experiment.

**Target Platform**: Developer workstations and CI on macOS/Linux; retained
PowerShell paths validated on Windows or any host with `pwsh`.

**Project Type**: Spec Kit extension package and agent-command integration.

**Performance Goals**: No material runtime performance target. Readiness and
diagnostic commands inspect only active feature artifacts and five declared
skills, with no network access unless the user chooses an installation action.

**Constraints**: Additive Spec Kit extension; schema version `1.0`; command
namespace `speckit.superb.*`; extension-local assets referenced through
`.specify/extensions/superb/...`; no direct edits to `.specify/scripts/` or
`.specify/templates/`; no early version bump; no MemoryLint behavior changes;
TDD required; preserve unrelated dirty-worktree changes.

**Scale/Scope**: One extension manifest; ten current command files reduced to
seven active files; five current hooks reduced to two; six current logical
skills reduced to five; four standalone commands narrowed; obsolete status and
evidence helpers removed; repository and extension tests updated from one
canonical capability contract.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Pre-Design | Post-Design | Evidence |
|---|---|---|---|
| I. Evidence-First Completion | PASS | PASS | Target tests precede payload changes; completion remains backed by Spec Kit implement/converge evidence. |
| II. Native Workflow Ownership | PASS | PASS | Spec Kit exclusively owns artifacts, implementation, convergence, and completion; Superb has no state machine. |
| III. Additive Extensions | PASS | PASS | All payload edits remain in `superpowers-bridge/`; repo-root edits are catalog/docs/tests only. |
| IV. Test-Driven Development | PASS | PASS | Each removal, replacement, and boundary receives a failing target-contract test before production edits. |
| V. Granular Implementation Control | PASS | PASS | The new gate reports readiness only; it does not select modes, dispatch agents, or execute tasks. |
| VI. Focused Superb Bridging | PASS | PASS | Final contract is exactly 7 commands, 2 hooks, 5 skills, and 0 lifecycle stores. |
| VII. Evidence-Bound MemoryLint Governance | PASS | PASS | MemoryLint files, dependencies, commands, hooks, and mutation boundaries are untouched. |

**Gate result**: PASS. No constitutional violation requires justification.

## Project Structure

### Documentation (this feature)

```text
specs/004-refocus-superb-boundaries/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── capability-contract.md
│   └── command-boundaries.md
└── tasks.md                  # generated later by /speckit-tasks
```

### Source Code (repository root)

```text
superpowers-bridge/
├── extension.yml
├── superb-config.template.yml
├── README.md
├── WORKFLOW.md
├── CHANGELOG.md
├── commands/
│   ├── check.md
│   ├── brainstorm.md
│   ├── implementation-gate.md   # new; replaces controller.md
│   ├── critique.md
│   ├── debug.md
│   ├── respond.md
│   └── finish.md
├── scripts/bash/
│   ├── ensure-skills.sh
│   └── resolve-skill.sh
└── tests/
    ├── test-capability-contract.sh
    ├── test-lifecycle-routing.sh
    ├── test-implementation-gate.sh
    ├── test-command-boundaries.sh
    ├── test-e2e-installation.sh
    ├── test-install-guidance.sh
    ├── test-resolve-skill.sh
    ├── test-spec-kit-012-install.sh
    └── test-workflow-contract.sh

catalog.json
README.md
.github/workflows/ci.yml
tests/
├── test-review-regressions.sh
├── test-superb-path-contract.sh
├── test-catalog.sh
└── test-release-workflow.sh
```

Files removed from the installed payload:

```text
superpowers-bridge/commands/controller.md
superpowers-bridge/commands/review.md
superpowers-bridge/commands/verify.md
superpowers-bridge/commands/plan-gate.md
superpowers-bridge/scripts/bash/archive-evidence.sh
superpowers-bridge/scripts/bash/sync-spec-status.sh
superpowers-bridge/scripts/powershell/archive-evidence.ps1
superpowers-bridge/scripts/powershell/sync-spec-status.ps1
superpowers-bridge/V2-DESIGN-NOTES.md
```

Obsolete tests that assert removed behavior will be deleted or replaced rather
than weakened to accept both old and new contracts.

**Structure Decision**: Keep Superb self-contained and contract-driven. One
manifest declares the public surface; command files own only their bounded
behavior; shell helpers handle five-skill discovery/installation only; tests
inspect both source and installed payload. No shared orchestration module or
new runtime store is introduced.

## Phase 0: Research Decisions

The complete evidence and alternatives are recorded in [research.md](./research.md).
All technical unknowns are resolved. The implementation is governed by these
decisions:

1. Spec Kit is an artifact lifecycle; Superpowers skills are situational disciplines, not stages.
2. Remove `review` and use `speckit.tasks` plus `speckit.analyze` before implementation.
3. Replace `controller` with a readiness-only `implementation-gate` and never select an agent mode.
4. Remove `verify`, all Superb status writes, and all evidence-archive helpers.
5. Route delivery gaps directly to `speckit.converge`; register no converge hook.
6. Retain narrowed `critique`, `debug`, `respond`, and `finish` commands.
7. Resolve exactly five Superpowers skills; complete-plugin install is distribution only.
8. Validate official Spec Kit 0.12.4 installed behavior, not marker-only hook simulations.

## Phase 1: Design and Contracts

### Data Model

[data-model.md](./data-model.md) defines `CapabilityContract`,
`CommandContract`, `HookBinding`, `SkillContract`, `ArtifactRoute`, and
`MigrationRemoval`.

### Interface Contracts

- [capability-contract.md](./contracts/capability-contract.md) defines the exact manifest, hook, skill, config, and installed-payload contract.
- [command-boundaries.md](./contracts/command-boundaries.md) defines inputs, outputs, allowed writes, forbidden behavior, and fallback rules for all seven commands.

### Validation Guide

[quickstart.md](./quickstart.md) provides source-contract checks, pinned Spec
Kit installation inspection, lifecycle scenarios, standalone-command boundary
checks, and repository acceptance gates.

## Phase 2 Handoff

`/speckit-tasks` should generate TDD-first tasks in this order:

1. Add failing inventory, routing, installed-payload, and command-boundary tests.
2. Replace `controller` with `implementation-gate` and prove no mode or artifact mutation remains.
3. Remove `review`, `verify`, `plan-gate`, status, and archive surfaces.
4. Narrow `brainstorm`, `critique`, `debug`, `respond`, and `finish` to their contracts.
5. Synchronize the five-skill installer/resolver/check/config contract.
6. Synchronize manifest, README, WORKFLOW, CHANGELOG, root catalog/docs, CI, and regression tests; remove obsolete V2 design notes.
7. Run source, package-install, lifecycle, Bash, PowerShell, YAML, catalog, release, and diff checks.

Tasks must preserve independent testability and must not combine unrelated
command rewrites merely because they share documentation consumers.

## Complexity Tracking

No constitution violations. Section intentionally empty.
