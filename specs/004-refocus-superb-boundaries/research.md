# Superb Lifecycle and Capability Reassessment

**Date**: 2026-07-02  
**Feature**: `004-refocus-superb-boundaries`  
**Scope**: Spec Kit core commands and hooks, Superb hook and standalone commands,
and the complete installed Superpowers skill set.

## Executive Conclusion

Superb currently translates too much of Superpowers' skill-trigger model into a
second lifecycle layered over Spec Kit. The central design error is treating
Superpowers skills as workflow stages. They are not. Spec Kit owns stages and
canonical artifacts; Superpowers supplies conditional disciplines that may be
applied inside those stages.

The target design should therefore:

1. Keep Spec Kit as the only lifecycle and artifact owner.
2. Use hooks only where a bounded precondition or refinement cannot be expressed
   by an existing Spec Kit core command.
3. Never add a Superb lifecycle status, completion state, task store, execution
   mode, or remediation loop.
4. Route artifact defects back to the earliest Spec Kit command that owns the
   defective artifact.
5. Keep standalone commands only when adding active Spec Kit context materially
   changes the value of the upstream Superpowers discipline.

The recommended target has two lifecycle hooks, seven Superb commands, and five
logical Superpowers skill dependencies:

- Hooks: optional `after_specify` design refinement and mandatory
  `before_implement` implementation-readiness discipline.
- Commands: `check`, `brainstorm`, a renamed implementation gate, a narrowed
  `critique`, `debug`, `respond`, and `finish`.
- Runtime skills: `brainstorming`, `test-driven-development`,
  `systematic-debugging`, `receiving-code-review`, and
  `finishing-a-development-branch`.

`speckit.superb.review`, `speckit.superb.verify`, and the legacy `plan-gate`
should not remain active commands. Spec Kit already owns task completeness,
cross-artifact analysis, implementation validation, and convergence.

## Evidence Baseline

### Authoritative Sources

- Official Spec Kit release baseline: `v0.12.4`, the latest published release
  observed on 2026-07-02.
- Local Spec Kit CLI: `0.11.9.dev0`; its core command pack was compared against
  `v0.12.4`.
- Installed Spec Kit Codex plugin cache: `0.11.9-dev0`.
- Installed Superpowers Codex plugin cache: `6.1.0`.
- Public Superpowers release baseline observed on 2026-07-02: `v5.1.0`.
- Superb source manifest: `superpowers-bridge/extension.yml`, version `1.8.0`,
  declaring Spec Kit `>=0.12.0` and Superpowers `>=5.0.0`.
- Project constitution: `.specify/memory/constitution.md`, version `2.0.0`.

Official references:

- [Spec Kit releases](https://github.com/github/spec-kit/releases)
- [Spec Kit extension reference](https://github.github.com/spec-kit/reference/extensions.html)
- [Spec Kit complex-feature guidance](https://github.github.com/spec-kit/concepts/complex-features.html)
- [Spec Kit evolving-spec guidance](https://github.github.com/spec-kit/guides/evolving-specs.html)
- [Superpowers repository](https://github.com/obra/superpowers)

### Version Qualification

The local CLI is behind the declared extension floor, but its core command pack
already contains `converge` and the same command-owned write boundaries used by
0.12.4. Comparing local command templates to official `v0.12.4` found one
material hook-runtime change: current mandatory-hook instructions require the
agent to actually invoke the hook and wait for it, rather than merely emit an
`EXECUTE_COMMAND` marker.

Consequently:

- Core lifecycle semantics below are evaluated against official `v0.12.4`.
- Existing local tests that only assert an `EXECUTE_COMMAND` line are not
  sufficient runtime evidence for Spec Kit 0.12.4.
- A clean installation/runtime experiment must use Spec Kit 0.12.4 before the
  refactor is considered implementation-ready.

The local Superpowers 6.1.0 cache was also hash-compared with the public v5.1.0
skill sources. Thirteen of fourteen skill documents differed;
`verification-before-completion` was the only identical file. This means a
Superpowers skill document is not a stable callable API. Retained adapters must
depend on the skill's durable principle and trigger, not internal headings,
prompt-template filenames, or exact control-flow steps.

### Pinned 0.12.4 Installation Experiment

A temporary Codex project was initialized with official Spec Kit `v0.12.4`,
then the current local `superpowers-bridge/` was installed with `extension add
--dev`.

Observed results:

- Installation succeeded and registered all nine manifest commands.
- `.specify/extensions.yml` registered all five current hooks with the expected
  optional/mandatory policies.
- The complete source payload was copied into
  `.specify/extensions/superb/`, including unregistered `commands/plan-gate.md`,
  status scripts, and evidence-archive scripts.
- The installer reported the six-skill contract from current metadata.

This proves the manifest is accepted by 0.12.4 and that stale unregistered files
remain observable installed payload. It does not prove hook behavior is correct;
that requires command execution for each lifecycle outcome.

## First-Principles Model

### Spec Kit

Spec Kit is an artifact-driven lifecycle:

```text
constitution
  -> specify -> clarify -> plan -> tasks -> analyze
  -> implement -> converge -> implement ... -> converge
  -> review / integration
```

Its effective state is derived from artifact existence and contents, not a
persisted `Draft -> Tasked -> Implementing -> Verified` state machine.

Each core command owns:

- prerequisites;
- a bounded artifact read/write contract;
- a completion signal;
- optional `before_*` and `after_*` extension points.

### Superpowers

Superpowers is a trigger-driven discipline system:

- A skill activates when its situation applies.
- Some skills are narrow disciplines, such as TDD or systematic debugging.
- Some skills own complete workflows, such as brainstorming, writing plans,
  executing plans, and subagent-driven development.
- Environment-sensitive skills select behavior from available tools; they do
  not define a portable product lifecycle.

### Superb

Superb is an adapter. A valid adapter may:

- bind a narrow Superpowers discipline to the active Spec Kit artifact context;
- strengthen a critical boundary with a read-only or user-approved check;
- return evidence or constraints to the owning Spec Kit command.

It must not:

- recreate a stage already owned by a Spec Kit core command;
- import a complete Superpowers workflow into a hook;
- persist a competing completion or execution state;
- route to a command whose prerequisites are not yet satisfied;
- require users to understand internal agent-mode terminology.

## Spec Kit Command and Hook Inventory

| Core command | Owned artifact/action | Preconditions | Hook keys | Superb target |
|---|---|---|---|---|
| `constitution` | Governing principles and dependent-template consistency | Initialized project | `before_constitution`, `after_constitution` | No hook |
| `specify` | Creates/updates `spec.md` | Feature intent | `before_specify`, `after_specify` | Optional bounded design refinement |
| `clarify` | Resolves material ambiguity in `spec.md` | Existing spec | `before_clarify`, `after_clarify` | No hook |
| `plan` | Creates `plan.md`, research, model, contracts, quickstart | Clarified spec | `before_plan`, `after_plan` | No hook |
| `checklist` | Generates requirement-quality checklists | Existing spec | `before_checklist`, `after_checklist` | No hook |
| `tasks` | Generates complete dependency-ordered `tasks.md` | Spec and plan | `before_tasks`, `after_tasks` | No hook; use core analysis |
| `analyze` | Read-only cross-artifact consistency and coverage analysis | Complete spec/plan/tasks | `before_analyze`, `after_analyze` | No hook |
| `implement` | Executes and checks tasks; updates task checkboxes | Complete tasks and checklists | `before_implement`, `after_implement` | One bounded readiness hook only |
| `converge` | Assesses delivered code and appends remaining tasks | A completed implement pass | `before_converge`, `after_converge` | No hook; route to core command |
| `taskstoissues` | Exports tasks to GitHub issues | Existing tasks | `before_taskstoissues`, `after_taskstoissues` | No hook |

## Lifecycle Reassessment

### Constitution

**Core behavior**: Establishes non-negotiable governance and propagates it into
dependent templates.

**Current Superb integration**: None.

**Decision**: Retain no integration.

**Reasoning**: Superb is governed by the constitution and must not refine or
reinterpret it implicitly. MemoryLint also remains independently governed.

### Specify

**Core behavior**: Converts user intent into a structured, testable `spec.md`.

**Current Superb integration**: Optional `after_specify ->
speckit.superb.brainstorm`.

**Superpowers source**: `brainstorming` normally owns an entire design workflow,
creates `docs/superpowers/specs/...`, commits it, requires user review, and then
invokes `writing-plans`.

**Assessment**: The current wrapper correctly overrides the parallel document,
branch, plan, and task outputs. Its useful residue is design-option exploration,
scope decomposition, and approval before editing the canonical spec.

**Decision**: Retain, with cleanup.

Required changes:

- Keep it optional.
- Keep `spec.md` as the only write target.
- Remove unused status-sync scripts from frontmatter.
- Do not install or invoke `writing-plans`.
- Do not repeat clarify's exhaustive ambiguity scan; route unresolved questions
  to `speckit.clarify`.
- Add a regression test proving decline/no-approval leaves `spec.md` unchanged.

### Clarify

**Core behavior**: Asks at most five high-impact questions and incrementally
integrates accepted answers into `spec.md`.

**Current Superb integration**: None.

**Decision**: Retain no integration.

**Reasoning**: `brainstorm` may surface design choices, but `clarify` owns formal
ambiguity resolution and spec integration. Another hook would duplicate its
question loop.

### Plan

**Core behavior**: Produces implementation architecture, research, contracts,
data model, and quickstart artifacts.

**Current Superb integration**: No registered hook, but the deprecated
`commands/plan-gate.md` remains packaged.

**Superpowers sources**: `writing-plans` creates a second plan format and
mandates either `subagent-driven-development` or `executing-plans`.

**Decision**: Remove the legacy command file and its tests.

**Reasoning**: The file still contains executable instructions to resolve
`writing-plans`, spawn a plan reviewer, impose arbitrary 3-file/100-line limits,
and inject an SDD execution header into `plan.md`. Labeling it deprecated does
not make those instructions safe in an installed package.

### Checklist

**Core behavior**: Generates requirement-quality checklists that test the
quality of requirements rather than implementation behavior.

**Current Superb integration**: None.

**Decision**: Retain no integration.

**Reasoning**: No mapped Superpowers skill adds a unique capability at this
boundary.

### Tasks

**Core behavior**: Generates dependency-ordered tasks, user-story phases,
parallel markers, independent tests, and completeness validation.

**Current Superb integration**: Optional `after_tasks ->
speckit.superb.review`.

**Assessment**:

- The command duplicates task completeness checks already present in `tasks`.
- It duplicates cross-artifact coverage and consistency analysis owned by
  `speckit.analyze`.
- Its normal coverage-gap route is `/speckit-converge`, but converge explicitly
  requires a completed implement pass. This route is invalid immediately after
  task generation.
- It writes a Superb-owned `Tasked` status to `spec.md`.
- Its own workflow documentation says review must not invoke converge, directly
  contradicting the command table and regression test.

**Decision**: Consolidate into native Spec Kit commands and remove the hook.

Correct routing:

| Finding after tasks | Owning command |
|---|---|
| Ambiguous requirement | `speckit.clarify`, then regenerate downstream artifacts |
| Plan/spec mismatch | `speckit.plan`, then regenerate tasks |
| Missing or poor task coverage | `speckit.tasks` |
| Broad cross-artifact inconsistency | `speckit.analyze` |
| Delivered-code gap after implementation | `speckit.converge` |

### Analyze

**Core behavior**: Performs read-only duplication, ambiguity,
underspecification, constitution, coverage, and consistency analysis across
spec, plan, and tasks.

**Current Superb integration**: None.

**Decision**: Retain no integration and explicitly document it as the replacement
for the removed task-review hook.

### Implement

**Core behavior**: Reads task dependencies and `[P]` markers, follows TDD task
ordering, validates checkpoints, marks completed tasks, and performs completion
validation against spec, plan, tests, and coverage.

**Current Superb integration**: Mandatory `before_implement ->
speckit.superb.controller` and mandatory `after_implement ->
speckit.superb.verify`.

**Controller assessment**:

- The current refactor correctly stopped the controller from executing tasks,
  mutating checkboxes, writing status, or owning discoveries.
- It still invents a `Single-Agent | Multi-Agent` policy and returns a parallel
  batch to the parent command. Spec Kit already treats `[P]` as execution
  guidance and officially allows users to scope or delegate implement runs.
- A pre-hook cannot portably guarantee that every supported agent will apply a
  returned orchestration policy beyond the hook's completion.
- Missing `test-driven-development` currently blocks the core implementation
  path, conflicting with the requirement that the standard Spec Kit path remain
  valid when an optional upstream capability is unavailable.

**Decision**: Consolidate and rename the command to an implementation/TDD
readiness gate.

Target behavior:

- Validate that incomplete implementation tasks have explicit RED/GREEN or
  equivalent test-first expectations.
- Load `test-driven-development` when available.
- Use a bridge-native minimum TDD contract when the external skill is missing;
  report reduced enhancement rather than blocking Spec Kit itself.
- Return only readiness findings and TDD constraints.
- Do not select, name, or report an agent mode.
- Do not dispatch agents or calculate a parallel batch.

**Verify assessment**: Fully remove it, as already clarified in `spec.md`.
`speckit.implement` owns implementation validation and `speckit.converge` owns
remaining-work discovery. Evidence-first remains a governing rule, not a
separate completion workflow.

### Converge

**Core behavior**: After an implementation pass, compares current code against
spec, plan, tasks, and constitution. It either leaves tasks byte-for-byte
unchanged (`converged`) or appends a new convergence phase (`tasks_appended`).

**Current Superb integration**: Mandatory `after_converge ->
speckit.superb.verify`.

**Decision**: Remove the hook.

**Reasoning**:

- `tasks_appended` means implementation is incomplete and routes back to
  `speckit.implement`; a completion verify is semantically wrong.
- `converged` already means the implementation satisfies the active artifacts.
- One unconditional post-hook cannot safely represent both outcomes unless it
  recreates converge's branch logic.
- Superb should recognize and route to core converge, not claim to provide or
  own convergence.

The feature spec wording should eventually be tightened from “Superb includes a
convergence capability” to “Superb routes delivery-gap assessment to the owning
`speckit.converge` command.”

### Taskstoissues

**Core behavior**: Converts existing tasks into dependency-aware GitHub issues.

**Current Superb integration**: None.

**Decision**: Retain no integration.

**Reasoning**: It is an export concern outside Superb's selected discipline
bridge.

## Superb Command Disposition

| Superb command/file | Current role | Decision | Target role |
|---|---|---|---|
| `check` | Diagnose six skills and five hooks | Retain | Diagnose only the final logical skill and hook contract |
| `brainstorm` | Optional canonical-spec refinement | Retain | Bounded design refinement with no status helper |
| `controller` | TDD readiness plus agent-mode policy | Consolidate | Rename to an implementation/TDD readiness gate; remove mode selection |
| `review` | Task coverage, quality, routing, status | Consolidate | Remove command/hook; route users to `tasks` and `analyze` |
| `verify` | Full tests, spec coverage, evidence archive, status | Remove | No replacement command; use implement plus converge |
| `critique` | Spec-aligned diff/code review | Consolidate | Read-only implementation review; remove completion and task-remediation overlap |
| `debug` | Spec-bound systematic debugging plus parallel mode | Consolidate | Keep context binding; remove hidden parallel-dispatch dependency and status helper |
| `respond` | Review triage and accepted-fix implementation | Consolidate | Keep technical triage; route spec/artifact changes to their owners and require TDD for code changes |
| `finish` | Branch completion after Superb verify plus status writes | Consolidate | Keep branch integration convenience; require fresh tests directly and remove Superb status writes |
| `plan-gate.md` | Deprecated but executable legacy instructions | Remove | Delete payload and update migration notes |

### Recommended Target Counts

- Public Superb commands: 7.
- Lifecycle hooks: 2.
- Mandatory hooks: 1.
- Logical Superpowers runtime dependencies: 5.
- Superb-owned lifecycle statuses: 0.
- Superb-owned task or execution stores: 0.

These counts are outcomes of responsibility analysis, not targets chosen in
advance.

## Complete Superpowers Skill Disposition

| Superpowers skill | Upstream ownership | Superb decision | Rationale |
|---|---|---|---|
| `brainstorming` | Full design/spec workflow | Retain with adapter | Its option exploration and scope discipline improve `specify`; suppress its parallel artifacts and handoff |
| `test-driven-development` | RED-GREEN-REFACTOR discipline | Retain with adapter | It strengthens implement readiness without owning task execution |
| `systematic-debugging` | Root-cause debugging workflow | Retain for standalone command | Spec/task context materially improves debugging; remove parallel orchestration extension |
| `receiving-code-review` | Technical evaluation of review feedback | Retain for standalone command | Spec authority materially improves accept/reject decisions |
| `finishing-a-development-branch` | Merge/PR/keep/discard workflow | Retain for standalone command | Spec context improves branch handoff, but Superb status and verify dependencies must be removed |
| `verification-before-completion` | Evidence before completion claims | Document, no runtime dependency | The principle remains constitutional; implement and converge already own the checks |
| `requesting-code-review` | Subagent reviewer dispatch | Document, no runtime dependency | Requires agent dispatch and overlaps narrowed `critique` |
| `dispatching-parallel-agents` | Parallel independent-domain dispatch | Document, no runtime dependency | Environment-sensitive orchestration, not a portable Superb lifecycle capability |
| `writing-plans` | Creates a complete Superpowers implementation plan | Remove from bridge | Competes with `speckit.plan` and `speckit.tasks` |
| `executing-plans` | Executes a written plan as a workflow | Remove from bridge | Competes with `speckit.implement` |
| `subagent-driven-development` | Owns task execution and two-stage reviews | Remove from bridge | Competes with `speckit.implement`; requires subagents |
| `using-git-worktrees` | Creates/manages isolated workspaces | Document only | Git/harness concern with consent and cleanup semantics, not Superb ownership |
| `using-superpowers` | Meta skill router for all conversations | Document only | Installing or bridging it would import the entire Superpowers control model |
| `writing-skills` | Creates and validates reusable skills | Remove from bridge | No Spec Kit feature-lifecycle value |

## Findings

| ID | Severity | Finding | Evidence | Required correction |
|---|---|---|---|---|
| F01 | CRITICAL | `after_tasks.review` routes pre-implementation coverage gaps to converge even though converge requires a completed implement pass | `commands/review.md`; upstream converge prerequisites | Route to `tasks`/`plan`/`clarify`; reserve converge for delivered code |
| F02 | CRITICAL | Unconditional `after_converge.verify` cannot represent both `tasks_appended` and `converged` outcomes | `extension.yml`; upstream converge handoff | Remove the hook and verify command |
| F03 | CRITICAL | Superb persists a competing completion lifecycle in canonical `spec.md` | `sync-spec-status.*`, review, verify, finish | Remove all Superb status synchronization |
| F04 | HIGH | Current regression tests pass while asserting behavior now rejected by the active spec | `test-after-converge-hook.sh`, `test-review-converge-split.sh`, `test-review-regressions.sh` | Replace tests with target ownership and absence contracts |
| F05 | HIGH | Hook tests assert directive emission, not actual mandatory command invocation required by Spec Kit 0.12.4 | Local-vs-v0.12.4 template diff | Add a real installed-extension hook experiment |
| F06 | HIGH | Controller still creates a second execution policy through Single/Multi-Agent mode selection | `commands/controller.md` | Reduce to readiness/TDD constraints and rename |
| F07 | HIGH | Mandatory missing-skill behavior can block the standard Spec Kit implementation path | controller install-recovery halt | Provide a bridge-native minimum discipline and report enhancement availability |
| F08 | HIGH | `review` duplicates both task generation validation and `speckit.analyze` | tasks/analyze upstream contracts | Remove the hook command rather than maintain overlapping matrices |
| F09 | MEDIUM | `debug` has an undeclared optional dependency on `dispatching-parallel-agents` | `commands/debug.md` versus `check.md` | Remove parallel mode or declare a justified dependency; recommended removal |
| F10 | MEDIUM | Deprecated `plan-gate.md` remains an executable package payload | command file and packaging | Delete it and retain migration notes only |
| F11 | MEDIUM | `finish` is unusable after verify removal and still writes `In Review`/`Abandoned` states | `commands/finish.md` | Bind directly to fresh tests and branch actions; remove status writes |
| F12 | MEDIUM | Brainstorm, debug, and respond declare status scripts they do not use | command frontmatter search | Remove unused script declarations |
| F13 | MEDIUM | Config, installer, README, workflow docs, changelog, and tests still encode six skills and five hooks | repo-wide searches | Update all surfaces from one capability inventory |
| F14 | MEDIUM | Local validation runs on Spec Kit 0.11.9.dev0 while the package requires 0.12+ | CLI version and manifest | Add a pinned 0.12.4 install/runtime test |
| F15 | LOW | `critique` mixes code review, requirement completion, fix planning, and reviewer packaging | `commands/critique.md` | Narrow it to read-only implementation review and explicit routing |
| F16 | HIGH | Superb treats mutable Superpowers skill internals as a broad `>=5.0.0` contract | Public v5.1.0 versus local 6.1.0 hash comparison: 13/14 skills differ | Depend only on durable principles, add contract fixtures, and avoid internal prompt/template paths |

## Target Lifecycle

```text
speckit.constitution

speckit.specify
  -> optional superb.brainstorm

speckit.clarify
speckit.plan
speckit.checklist (as needed)
speckit.tasks
speckit.analyze (recommended before implementation)

speckit.implement
  -> mandatory superb implementation-readiness/TDD gate before execution
  -> Spec Kit owns task execution, [P] handling, checkboxes, tests, and completion validation

speckit.converge
  -> tasks_appended: return to speckit.implement
  -> converged: proceed to optional superb.critique or superb.finish

standalone, when triggered:
  superb.debug
  superb.respond
  superb.critique
  superb.finish
```

No Superb hook runs after implement or converge. No Superb command writes a
lifecycle status.

## Validation Strategy for the Refactor

### Contract Tests

1. Manifest declares exactly the approved command and hook set.
2. Every hook command is declared under `provides.commands`.
3. Removed commands, hooks, scripts, config keys, and skill names are absent
   from installed payloads and active documentation.
4. Every retained command includes `$ARGUMENTS` and valid extension-local script
   paths.
5. No retained command writes `**Status**:` or creates a task/execution store.

### Lifecycle Experiments

1. Install Superb with pinned Spec Kit 0.12.4 into a temporary initialized
   project.
2. Verify optional `after_specify` behavior for approve, decline, and missing
   brainstorming skill paths.
3. Verify the pre-implement gate returns readiness constraints but does not
   modify artifacts or block the core path solely because the optional upstream
   skill is unavailable.
4. Run implement with simple, `[P]`, and dependency-conflicting task sets and
   confirm Spec Kit remains the executor.
5. Run converge for both outcomes and confirm no Superb completion hook or
   status mutation occurs.
6. Exercise each retained standalone command independently and verify its
   declared write boundary.

### Current Test Interpretation

The following focused tests passed during this analysis:

- `test-after-converge-hook.sh`
- `test-review-converge-split.sh`
- `test-stage-runtime-contract.sh`
- `test-workflow-contract.sh`

Their passing result is evidence that the repository consistently implements
the current design. It is not evidence that the design is correct. The first
two tests specifically lock in F01 and F02 and must be replaced during the
refactor.

Repository-level checks also produced the following current-state evidence:

- `tests/test-review-regressions.sh`: passed.
- `tests/test-release-workflow.sh`: passed.
- `superpowers-bridge/tests/test-status-sync.sh`: passed.
- PowerShell status-sync test: not run because `pwsh` is not installed.
- CI and release workflow YAML parsing: passed.
- `git diff --check`: passed.

These checks prove current source consistency and packaging hygiene. They do
not override the semantic findings above; status-sync passing is specifically
evidence that the soon-to-be-removed state machine is implemented consistently.

## Final Decision Summary

The refactor is not “remove several skills.” It is a change in composition:

- Spec Kit commands own lifecycle progression and artifact repair.
- Superb hooks supply only bounded refinement/readiness constraints.
- Superpowers skills remain situational disciplines, not imported stages.
- Standalone Superb commands survive only where Spec Kit context changes the
  upstream discipline's result.

This model preserves the useful Superpowers advantages while eliminating the
second plan, execution, remediation, and completion systems that made Superb
harder to understand than the workflow it was intended to improve.
