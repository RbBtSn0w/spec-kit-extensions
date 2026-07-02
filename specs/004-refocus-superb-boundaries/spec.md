# Feature Specification: Refocus Superb Boundaries

**Feature Branch**: `004-refocus-superb-boundaries`

**Created**: 2026-07-02

**Status**: Draft

**Input**: User description: "Refocus Superb from a partial orchestration system into a focused Spec Kit enhancement extension. Retain capabilities that directly improve the spec -> plan -> tasks -> implement -> verify path, consolidate fallback-only capabilities into documentation, and reject exceptional-case control-flow layers by default."

## Clarifications

### Session 2026-07-02

- Q: What is the final disposition of `speckit.superb.verify`? → A: Remove the command, its lifecycle hooks, status synchronization, temporary evidence archiving, and `verification-before-completion` skill dependency; retain evidence-first completion as a governance rule enforced through the owning Spec Kit implementation and convergence flow.

### Session 2026-07-03

- Q: How should task-coverage validation be handled after `speckit.tasks`? → A: Remove `speckit.superb.review` and its `after_tasks` hook; keep task completeness with `speckit.tasks`, use `speckit.analyze` for cross-artifact coverage analysis, and route defects back to their earliest owning Spec Kit command.
- Q: What should Superb do at `before_implement`? → A: Replace `speckit.superb.controller` with a mandatory implementation/TDD readiness gate that checks test-first readiness only, never selects an agent mode or dispatch policy, and uses a bridge-native minimum TDD contract without blocking Spec Kit when the upstream skill is unavailable.
- Q: How should convergence participate in Superb? → A: Keep convergence entirely owned by `speckit.converge`; Superb may route delivery-stage gaps to that core command but MUST provide no convergence alias, wrapper, capability, or `before_converge`/`after_converge` hook.
- Q: Which standalone Superb commands should remain? → A: Retain narrowed `critique`, `debug`, `respond`, and `finish` commands with explicit Spec Kit context and write boundaries; remove lifecycle status, hidden parallel orchestration, verify prerequisites, and completion ownership from them.
- Q: What is Superb's final Superpowers runtime dependency contract? → A: Resolve only `brainstorming`, `test-driven-development`, `systematic-debugging`, `receiving-code-review`, and `finishing-a-development-branch`; a complete plugin may be used for physical installation, but no other bundled skill enters Superb's runtime contract.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Follow One Coherent Workflow (Priority: P1)

As a Spec Kit user, I want Superb to strengthen important lifecycle checkpoints without introducing a second planning or execution workflow, so that I can follow one clear path from specification through verification.

**Why this priority**: Competing workflow ownership is the primary source of complexity and makes it unclear whether Spec Kit or Superb controls implementation.

**Independent Test**: Inspect and exercise every Superb lifecycle integration in a representative feature. The user should remain in the Spec Kit workflow, while each Superb interaction either adds a focused check or returns control without creating parallel workflow state.

**Acceptance Scenarios**:

1. **Given** a user follows the normal Spec Kit lifecycle, **When** a Superb integration is reached, **Then** Superb provides a bounded enhancement and Spec Kit remains the owner of the current lifecycle stage.
2. **Given** implementation is ready to begin, **When** Superb evaluates readiness, **Then** it reports only test-first readiness constraints and does not select an agent mode, parallel batch, dispatch policy, separate plan, task store, execution lifecycle, or completion state.
3. **Given** implementation has completed, **When** the workflow reaches delivery-gap assessment, **Then** Superb routes to `speckit.converge`, which either reports convergence or appends traceable follow-up work without any Superb-owned convergence command or state.
4. **Given** Superb cannot provide an optional enhancement, **When** the workflow continues, **Then** the fallback is understandable without introducing another controller or asking the user to reason about internal orchestration modes.
5. **Given** Spec Kit implementation validation has produced fresh completion evidence, **When** the workflow proceeds to convergence, **Then** Superb does not repeat that validation through a separate verify command or persist a Superb-owned completion status.
6. **Given** `speckit.tasks` has generated the task artifact, **When** task completeness or cross-artifact consistency needs validation, **Then** the workflow uses `speckit.tasks` or `speckit.analyze` rather than a Superb-owned post-tasks review stage.

---

### User Story 2 - Understand Why Each Capability Exists (Priority: P2)

As a Superb maintainer, I want every exposed capability to have an explicit lifecycle purpose and disposition, so that redundant commands, skills, configuration, and fallback paths can be removed or consolidated with evidence.

**Why this priority**: A complete capability inventory prevents the refocus from becoming another partial deletion that leaves the actual stage behavior unchanged.

**Independent Test**: Review the complete Superb surface and confirm that every command, hook, configuration option, runtime dependency, and bridged Superpowers capability is classified with a lifecycle stage, user outcome, and retain, consolidate, document, or remove decision.

**Acceptance Scenarios**:

1. **Given** an exposed Superb capability, **When** it directly helps a user complete or validate a Spec Kit lifecycle step, **Then** it is retained with one clearly stated user outcome.
2. **Given** a capability mainly explains or supports another capability's fallback, **When** the inventory is reviewed, **Then** it is consolidated into the owning capability or moved to documentation.
3. **Given** a capability adds a new control-flow layer for an exceptional scenario, **When** no critical common-path need is demonstrated, **Then** it is excluded from the active workflow.
4. **Given** a complete Superpowers plugin is physically installed, **When** Superb checks readiness or executes a retained command, **Then** it resolves only the five declared runtime skills and does not treat other bundled skills as Superb capabilities.

---

### User Story 3 - Operate Superb Without Internal Orchestration Knowledge (Priority: P3)

As a user, I want Superb prompts and reports to describe decisions in terms of my Spec Kit task and evidence, so that I do not need to understand Superb's internal mode names, controller terminology, or upstream skill relationships.

**Why this priority**: Internal terminology increases cognitive load and exposes implementation structure instead of user value.

**Independent Test**: Run the retained Superb interactions using both a simple task and a task set with safe concurrency. The user-facing flow should explain readiness, constraints, and evidence without requiring the user to select or interpret an orchestration mode.

**Acceptance Scenarios**:

1. **Given** a task can proceed normally, **When** Superb reports readiness, **Then** it communicates actionable constraints and returns control to Spec Kit without asking the user to choose an execution mode.
2. **Given** concurrency is unavailable or unsafe, **When** Superb evaluates the task set, **Then** the workflow remains valid and continues serially without presenting a degraded or exceptional user path.
3. **Given** user-facing documentation describes a retained capability, **When** the user reads it, **Then** the description starts with the Spec Kit lifecycle benefit rather than Superb internals or upstream skill names.
4. **Given** a user invokes a retained standalone command, **When** it evaluates or changes the current work, **Then** it stays within its declared review, debugging, feedback-response, or branch-handoff boundary and does not create lifecycle state or bypass the owning Spec Kit artifact stage.

### Edge Cases

- A capability benefits multiple lifecycle stages but has no single accountable stage or outcome.
- An optional upstream capability is unavailable while the owning Spec Kit stage can still complete safely.
- A task set is marked parallel but contains hidden file, artifact, or ordering conflicts.
- Existing configuration refers to a capability that is consolidated, documented, or removed.
- Documentation, hooks, commands, and validation checks disagree about which capabilities remain supported.
- Existing installations or configuration still reference `speckit.superb.verify`, its lifecycle hooks, status synchronization, evidence archiving, or the `verification-before-completion` dependency after those surfaces are removed.
- A standalone command discovers that accepted feedback or a proposed fix changes the meaning of `spec.md`, the architecture in `plan.md`, or task scope in `tasks.md`.
- A branch-completion choice is destructive or would remove a workspace not created by the current tool.
- A proposed Superb change would accidentally alter MemoryLint behavior or introduce a dependency between the two extensions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The refocus MUST inventory every user-visible command, lifecycle hook, configuration option, runtime dependency, and bridged Superpowers capability in Superb.
- **FR-002**: Every inventoried capability MUST identify the Spec Kit lifecycle stage it serves, the user outcome it improves, and a disposition of `retain`, `consolidate`, `document`, or `remove`.
- **FR-003**: A capability MUST be retained in the active workflow only when it directly helps users complete or validate a step in the Spec Kit `spec -> plan -> tasks -> implement -> verify` path.
- **FR-004**: A capability whose primary purpose is explaining or supporting another capability's fallback MUST be consolidated into its owning capability or moved to documentation.
- **FR-005**: A capability that introduces an additional control-flow layer for exceptional scenarios MUST be excluded by default unless evidence demonstrates a critical common-path need that cannot be satisfied by the owning Spec Kit workflow.
- **FR-006**: Spec Kit MUST remain the sole owner of specification, clarification, planning, task generation, implementation, convergence, and their canonical artifacts.
- **FR-007**: Superb MUST NOT create or maintain a competing plan, task store, execution lifecycle, execution journal, or completion state.
- **FR-008**: Retained Superb behavior MUST be expressed as a focused discipline, validation, decision, or evidence gate at an explicit Spec Kit lifecycle boundary.
- **FR-009**: Superb MUST NOT select, expose, or persist a Single-Agent, Multi-Agent, parallel-batch, worker, or dispatch mode; task ordering, parallel execution, delegation, and implementation control MUST remain with the owning Spec Kit implementation flow and active agent runtime.
- **FR-010**: When advanced execution capabilities are unavailable, unsupported, or unsafe, the standard Spec Kit execution path MUST remain valid without adding a separate fallback workflow.
- **FR-011**: User-facing prompts, reports, and documentation MUST prioritize lifecycle purpose, actionable constraints, and evidence over controller, worker, mode, or upstream-skill terminology.
- **FR-012**: Installation and readiness guidance MUST distinguish required active-workflow capabilities from optional or standalone capabilities and MUST NOT imply that the complete Superpowers workflow is required.
- **FR-013**: The extension manifest, commands, configuration, documentation, and validation coverage MUST agree on the retained Superb capability set and lifecycle routing.
- **FR-014**: The refocus MUST preserve the independence of MemoryLint and MUST NOT change its commands, hooks, dependencies, audit/apply boundaries, or product responsibilities.
- **FR-015**: Removed or consolidated behavior MUST include a clear migration path for existing Superb users and configurations.
- **FR-016**: Superb MUST route post-implementation delivery-gap assessment to the owning `speckit.converge` command and MUST NOT provide a convergence alias, wrapper, replacement capability, artifact mutation, or lifecycle state.
- **FR-017**: The refocus MUST remove `speckit.superb.verify` from the active command surface, remove its `after_implement` and `after_converge` lifecycle hooks, and remove the associated status synchronization, temporary evidence archiving, and `verification-before-completion` runtime dependency.
- **FR-018**: Evidence-first completion MUST remain a governing rule, but implementation validation and test evidence MUST be produced by the owning Spec Kit implementation flow, while remaining-work discovery and task creation MUST be owned by `speckit-converge`; Superb MUST NOT duplicate either responsibility through a separate completion command or persisted completion state.
- **FR-019**: The refocus MUST remove `speckit.superb.review` from the active command surface and remove its `after_tasks` lifecycle hook, status synchronization, workflow-decision schema, and delivery-stage convergence routing.
- **FR-020**: Task completeness defects MUST route to `speckit.tasks`, cross-artifact coverage or consistency findings MUST route through `speckit.analyze` to the earliest owning Spec Kit command, and `speckit-converge` MUST be reserved for delivered-code assessment after an implementation pass.
- **FR-021**: The refocus MUST remove `speckit.superb.controller` and replace it with a mandatory `before_implement` implementation/TDD readiness command whose only responsibility is validating and reporting test-first readiness constraints without executing or scheduling tasks.
- **FR-022**: The implementation/TDD readiness command MUST apply the installed `test-driven-development` discipline when available and MUST fall back to a bridge-native minimum test-first contract when it is unavailable, reporting reduced enhancement without blocking the standard Spec Kit implementation path solely because the external skill is missing.
- **FR-023**: The refocus MUST register no `before_converge` or `after_converge` Superb hook; the `tasks_appended` and `converged` outcomes and their next actions MUST remain exclusively defined by `speckit.converge`.
- **FR-024**: The active standalone command surface MUST retain narrowed `speckit.superb.critique`, `speckit.superb.debug`, `speckit.superb.respond`, and `speckit.superb.finish` commands, each bound to the active Spec Kit feature context and prohibited from writing Superb lifecycle status.
- **FR-025**: `speckit.superb.critique` MUST be read-only, review implementation diffs against active Spec Kit artifacts, report findings with evidence, and route remediation without creating tasks, applying fixes, or declaring completion.
- **FR-026**: `speckit.superb.debug` MUST apply systematic root-cause investigation within the current failing task or explicitly supplied scope, MUST NOT introduce a parallel-agent mode or hidden dispatch dependency, and MUST return control to the owning implementation flow after focused verification.
- **FR-027**: `speckit.superb.respond` MUST technically classify review feedback against active Spec Kit artifacts; feedback that changes requirement meaning, architecture, or task scope MUST route to the earliest owning Spec Kit command before code changes, while accepted in-scope code fixes MUST follow test-first verification.
- **FR-028**: `speckit.superb.finish` MUST require fresh passing project checks before presenting branch actions, execute only the user's explicit integration choice, preserve workspaces it does not own, and MUST NOT depend on `speckit.superb.verify` or write `In Review`, `Abandoned`, or any other Superb lifecycle status.
- **FR-029**: Superb's logical Superpowers runtime contract MUST contain exactly five skills: `brainstorming`, `test-driven-development`, `systematic-debugging`, `receiving-code-review`, and `finishing-a-development-branch`.
- **FR-030**: A complete Superpowers plugin MAY be offered as a compatible physical installation path, but Superb readiness checks, configuration, command resolution, documentation, and tests MUST NOT treat any other bundled skill as part of Superb's runtime contract.
- **FR-031**: Retained adapters MUST depend only on the durable trigger and discipline of an upstream skill and MUST NOT require unstable internal headings, prompt-template filenames, agent names, or exact workflow steps from a particular Superpowers version.
- **FR-032**: The final active Superb command surface MUST contain exactly seven commands: `speckit.superb.check`, `speckit.superb.brainstorm`, `speckit.superb.implementation-gate`, `speckit.superb.critique`, `speckit.superb.debug`, `speckit.superb.respond`, and `speckit.superb.finish`.
- **FR-033**: The final Superb lifecycle surface MUST contain exactly two hooks: optional `after_specify` invoking `speckit.superb.brainstorm`, and mandatory `before_implement` invoking `speckit.superb.implementation-gate`.

### Key Entities

- **Capability**: A Superb command, hook behavior, configuration option, runtime dependency, or bridged Superpowers discipline being evaluated.
- **Lifecycle Boundary**: The explicit point in the Spec Kit flow where a retained capability provides user value.
- **Capability Decision**: The evidence-backed classification, lifecycle mapping, user outcome, and disposition for one capability.
- **Execution Constraint**: A bounded instruction returned to the owning Spec Kit stage without creating independent workflow state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Superb's exposed capabilities and runtime dependencies have a documented lifecycle mapping, user outcome, and disposition.
- **SC-002**: 100% of retained active-workflow capabilities map to at least one acceptance scenario and exactly one accountable lifecycle boundary.
- **SC-003**: A full normal-path walkthrough completes from specification through verification with zero competing Superb-owned plans, task stores, execution lifecycles, journals, or completion states.
- **SC-004**: Users complete both simple and concurrency-eligible implementation walkthroughs with zero Superb-generated agent-mode, parallel-batch, worker, or dispatch-policy decisions.
- **SC-005**: All supported fallback walkthroughs return to a valid Spec Kit path without invoking an additional Superb-owned control-flow layer.
- **SC-006**: Manifest, command, configuration, documentation, and validation audits report zero contradictions about the retained capability set or lifecycle routing.
- **SC-007**: MemoryLint's published command, hook, dependency, and mutation boundaries remain unchanged after the Superb refocus.
- **SC-008**: A post-implementation convergence pass either reports no remaining work or appends traceable follow-up tasks without requiring user mode selection or introducing a parallel Superb-owned lifecycle.
- **SC-009**: Installed Superb manifests, commands, scripts, configuration, documentation, dependency checks, and tests contain zero active references to `speckit.superb.verify`, its removed hooks, Superb-owned lifecycle status synchronization, temporary evidence archiving, or the `verification-before-completion` runtime dependency.
- **SC-010**: Installed Superb manifests, commands, configuration, documentation, and tests contain zero active references to `speckit.superb.review` or `after_tasks`, and all task-stage defect routes resolve to `speckit.tasks`, `speckit.analyze`, or the earlier Spec Kit artifact owner without invoking convergence before implementation.
- **SC-011**: The mandatory pre-implementation gate produces only test-first readiness findings, modifies no feature artifact, and allows the owning Spec Kit implementation flow to remain usable when the upstream TDD skill is unavailable.
- **SC-012**: Installed Superb manifests, commands, configuration, documentation, and tests contain zero Superb convergence commands or hooks, while delivery-stage gap routes point directly to `speckit.converge` and preserve both native outcomes.
- **SC-013**: Contract tests exercise all four retained standalone commands and prove their declared artifact/write boundaries, including read-only critique, non-orchestrating debug, artifact-owner routing in respond, and explicit-choice branch handoff in finish.
- **SC-014**: Installed-package inspection reports exactly seven Superb commands, two Superb hooks, five logical Superpowers runtime skills, and zero Superb-owned lifecycle statuses, task stores, execution stores, or completion stores.
- **SC-015**: Contract fixtures covering the supported Superpowers version range prove that retained adapters resolve the five declared disciplines without relying on version-specific internal skill structure.

## Assumptions

- Spec Kit continues to own its canonical lifecycle stages and artifacts.
- Superb remains an extension identifier and product surface; this feature narrows its responsibilities rather than removing the extension.
- A small number of high-value gates is preferable to broad Superpowers workflow coverage, but the final retained set must be justified by the capability inventory rather than a predetermined count.
- Serial execution is the safe default whenever task independence or runtime concurrency support is uncertain.
- Standalone developer disciplines may remain available when they provide direct user value without participating in the core Spec Kit lifecycle.
- Installing the complete Superpowers plugin is a distribution choice and does not expand Superb's logical runtime contract beyond the five declared skills.
- MemoryLint is a separate extension in the same repository and is outside the implementation scope of this feature.
