---

description: "Implementation tasks for refocusing Superb as a bounded Spec Kit extension"
---

# Tasks: Refocus Superb Boundaries

**Input**: Design documents from `/specs/004-refocus-superb-boundaries/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests are mandatory under Constitution Principle IV. Every behavior change starts with a failing contract or integration test and follows RED-GREEN-REFACTOR.

**Organization**: Tasks are grouped by user story. Spec Kit `[P]` markers identify file-independent work only; Superb does not select or persist an execution mode.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because the task touches a different file and has no dependency on incomplete work
- **[Story]**: Maps the task to User Story 1, 2, or 3
- Every task names the exact file or command path it changes or validates

## Phase 1: Setup (Shared Test Entry Points)

**Purpose**: Make the target contract suites visible to repository validation before production behavior changes.

- [ ] T001 Register the planned Superb capability, lifecycle, command-boundary, and pinned-install suites in `.github/workflows/ci.yml` so missing suites fail before implementation

---

## Phase 2: Foundational (Blocking Ownership Guard)

**Purpose**: Lock the repository boundary that all three stories must preserve.

**CRITICAL**: Complete this phase before changing the Superb payload.

- [ ] T002 Add a failing regression proving the refocus changes no `memorylint/extension.yml`, MemoryLint command, hook, dependency, or mutation boundary in `tests/test-review-regressions.sh`

**Checkpoint**: CI knows the new validation entry points and the independent MemoryLint product boundary is protected.

---

## Phase 3: User Story 1 - Follow One Coherent Workflow (Priority: P1) MVP

**Goal**: Reduce Superb to bounded Spec Kit lifecycle enhancements with no competing review, verification, convergence, execution-mode, or completion workflow.

**Independent Test**: Install or inspect Superb and exercise `after_specify`, `before_implement`, implementation completion, and both convergence outcomes. Only the optional brainstorm and mandatory read-only implementation gate run; Spec Kit owns tasks, implementation, convergence, and completion state.

### Tests for User Story 1

> Write these tests first and confirm they fail against the current five-hook payload.

- [ ] T003 [P] [US1] Add failing assertions for exactly `after_specify` and `before_implement`, native task/analyze/converge routing, and absence of Superb lifecycle status in `superpowers-bridge/tests/test-lifecycle-routing.sh`
- [ ] T004 [P] [US1] Add failing read-only and fallback scenarios for `speckit.superb.implementation-gate` in `superpowers-bridge/tests/test-implementation-gate.sh`
- [ ] T005 [P] [US1] Add failing installed-payload assertions that reject `controller.md`, `review.md`, `verify.md`, `plan-gate.md`, status-sync helpers, and evidence archives in `superpowers-bridge/tests/test-e2e-installation.sh`

### Implementation for User Story 1

- [ ] T006 [US1] Replace controller/review/verify registrations and five hooks with `speckit.superb.implementation-gate` plus the exact two-hook routing in `superpowers-bridge/extension.yml`
- [ ] T007 [US1] Implement the read-only TDD readiness and native-minimum fallback contract without mode selection, batching, dispatch, task mutation, commits, or status writes in `superpowers-bridge/commands/implementation-gate.md`
- [ ] T008 [US1] Restrict optional spec refinement to user-approved `spec.md` changes and remove status-script declarations and parallel design outputs in `superpowers-bridge/commands/brainstorm.md`
- [ ] T009 [US1] Remove the superseded controller payload after the implementation-gate tests pass in `superpowers-bridge/commands/controller.md`
- [ ] T010 [US1] Remove the post-tasks review payload after native task/analyze routing tests pass in `superpowers-bridge/commands/review.md`
- [ ] T011 [US1] Remove the duplicate completion gate after implement/converge ownership tests pass in `superpowers-bridge/commands/verify.md`
- [ ] T012 [US1] Remove the unregistered legacy planning gate after installed-payload tests reject it in `superpowers-bridge/commands/plan-gate.md`
- [ ] T013 [US1] Remove Superb status persistence from `superpowers-bridge/scripts/bash/sync-spec-status.sh` and `superpowers-bridge/scripts/powershell/sync-spec-status.ps1`
- [ ] T014 [US1] Remove temporary evidence persistence from `superpowers-bridge/scripts/bash/archive-evidence.sh` and `superpowers-bridge/scripts/powershell/archive-evidence.ps1`
- [ ] T015 [US1] Replace obsolete status, archive, review/converge, controller, and orchestration expectations with lifecycle ownership assertions in `superpowers-bridge/tests/test-lifecycle-routing.sh`
- [ ] T016 [US1] Run `bash superpowers-bridge/tests/test-lifecycle-routing.sh`, `bash superpowers-bridge/tests/test-implementation-gate.sh`, and `bash superpowers-bridge/tests/test-e2e-installation.sh` to prove the US1 workflow independently

**Checkpoint**: The normal Spec Kit path works with two bounded Superb hooks and no Superb-owned lifecycle state.

---

## Phase 4: User Story 2 - Understand Why Each Capability Exists (Priority: P2)

**Goal**: Make every installed command, hook, config option, and Superpowers dependency agree with the exact 7-command, 2-hook, 5-skill, 0-store capability contract.

**Independent Test**: Audit both the source tree and a Spec Kit 0.12.4 temporary installation. Every active capability has one lifecycle outcome and disposition; removed orchestration skills and stale payload files are absent even when the complete Superpowers plugin is installed.

### Tests for User Story 2

> Write these tests first and confirm they fail against the current six-skill/config/documentation surface.

- [ ] T017 [P] [US2] Add a failing source contract for exactly seven commands, two hooks, five logical skills, zero lifecycle stores, and forbidden-surface absence in `superpowers-bridge/tests/test-capability-contract.sh`
- [ ] T018 [P] [US2] Add failing five-skill installation guidance and complete-plugin isolation scenarios in `superpowers-bridge/tests/test-install-guidance.sh`
- [ ] T019 [P] [US2] Add a failing real temporary installation and registered-payload inspection using pinned Spec Kit 0.12.4 in `superpowers-bridge/tests/test-spec-kit-012-install.sh`
- [ ] T020 [P] [US2] Add failing durable-skill fixtures that avoid internal headings, prompt filenames, and agent names in `superpowers-bridge/tests/test-resolve-skill.sh`

### Implementation for User Story 2

- [ ] T021 [US2] Change prerequisite checks, selective install commands, and diagnostics from six skills to the five contracted disciplines in `superpowers-bridge/scripts/bash/ensure-skills.sh`
- [ ] T022 [P] [US2] Align hard/optional requirements, two-hook policy, command toggles, and removal of mode-detection settings in `superpowers-bridge/superb-config.template.yml`
- [ ] T023 [US2] Report exactly five skills, two hooks, four standalone commands, and bounded missing-skill recovery in `superpowers-bridge/commands/check.md`
- [ ] T024 [P] [US2] Document the capability inventory, artifact-owner routing, five-skill logical contract, and migration from removed surfaces in `superpowers-bridge/WORKFLOW.md`
- [ ] T025 [P] [US2] Update installation, command, hook, fallback, and compatibility guidance to the exact target contract in `superpowers-bridge/README.md`
- [ ] T026 [P] [US2] Record the breaking removals and planned release bump only under Unreleased metadata in `superpowers-bridge/CHANGELOG.md`
- [ ] T027 [US2] Align catalog-facing command and capability metadata without changing the published extension version in `catalog.json`
- [ ] T028 [US2] Remove replaced review/converge suites `superpowers-bridge/tests/test-review-converge-split.sh` and `superpowers-bridge/tests/test-after-converge-hook.sh`
- [ ] T029 [US2] Remove replaced status and archive suites `superpowers-bridge/tests/test-status-sync.sh`, `superpowers-bridge/tests/test-status-sync.ps1`, `superpowers-bridge/tests/test-archive-evidence.sh`, and `superpowers-bridge/tests/test-archive-evidence.ps1`
- [ ] T030 [US2] Remove replaced plan/controller runtime suites `superpowers-bridge/tests/test-plan-gate.sh` and `superpowers-bridge/tests/test-stage-runtime-contract.sh`
- [ ] T031 [US2] Remove replaced concurrency-policy suites `superpowers-bridge/tests/test-concurrency-cascade.sh`, `superpowers-bridge/tests/test-concurrency-dependency.sh`, and `superpowers-bridge/tests/test-parallel-dispatch.sh`
- [ ] T032 [US2] Remove replaced SDD orchestration suites `superpowers-bridge/tests/test-sdd-detection.sh`, `superpowers-bridge/tests/test-sdd-fallback.sh`, and `superpowers-bridge/tests/test-sdd-reviews.sh`
- [ ] T033 [US2] Remove replaced lifecycle-state suites `superpowers-bridge/tests/test-checkpoint-resume.sh`, `superpowers-bridge/tests/test-continuous-sync.sh`, and `superpowers-bridge/tests/test-discoveries-lifecycle.sh`
- [ ] T034 [US2] Run `bash superpowers-bridge/tests/test-capability-contract.sh`, `bash superpowers-bridge/tests/test-install-guidance.sh`, `bash superpowers-bridge/tests/test-resolve-skill.sh`, and `bash superpowers-bridge/tests/test-spec-kit-012-install.sh` to prove the US2 inventory independently

**Checkpoint**: Source, configuration, installer, documentation, catalog, and installed package all expose exactly 7 commands, 2 hooks, 5 skills, and 0 Superb lifecycle stores.

---

## Phase 5: User Story 3 - Operate Superb Without Internal Orchestration Knowledge (Priority: P3)

**Goal**: Keep the four standalone disciplines useful while removing controller terminology, hidden dispatch, completion ownership, and writes outside each command's declared boundary.

**Independent Test**: Invoke `critique`, `debug`, `respond`, and `finish` with simple and concurrency-eligible work. Outputs use Spec Kit artifact and evidence language, perform only permitted writes, and never ask for an execution mode.

### Tests for User Story 3

> Write these tests first and confirm they fail against the current broad standalone commands.

- [ ] T035 [P] [US3] Add failing read/write and forbidden-behavior assertions for all four standalone commands in `superpowers-bridge/tests/test-command-boundaries.sh`
- [ ] T036 [P] [US3] Add failing user-language assertions rejecting controller, worker, mode-selection, hidden dispatch, and verify-prerequisite wording in `superpowers-bridge/tests/test-workflow-contract.sh`

### Implementation for User Story 3

- [ ] T037 [P] [US3] Narrow critique to read-only evidence-backed findings and artifact-owner remediation routing in `superpowers-bridge/commands/critique.md`
- [ ] T038 [P] [US3] Narrow debug to the current failing task, focused RED-GREEN verification, and return to the owning implementation flow in `superpowers-bridge/commands/debug.md`
- [ ] T039 [P] [US3] Route requirement, architecture, and task-scope feedback to the earliest Spec Kit owner before accepted in-scope fixes in `superpowers-bridge/commands/respond.md`
- [ ] T040 [P] [US3] Replace Superb verify/status prerequisites with fresh checks, explicit branch choices, and foreign-workspace preservation in `superpowers-bridge/commands/finish.md`
- [ ] T041 [US3] Run `bash superpowers-bridge/tests/test-command-boundaries.sh` and `bash superpowers-bridge/tests/test-workflow-contract.sh` to prove the US3 command boundaries independently

**Checkpoint**: All retained standalone commands describe user outcomes and evidence without exposing or recreating an orchestration system.

---

## Phase 6: Polish & Cross-Cutting Validation

**Purpose**: Prove repository, package, documentation, and release consistency after all independently testable stories pass.

- [ ] T042 [P] Synchronize root Superb overview and published-version references with the final extension surface in `README.md`
- [ ] T043 Replace root regression expectations for removed review/verify/status behavior with the final capability and routing contracts in `tests/test-review-regressions.sh`
- [ ] T044 Run `bash tests/test-review-regressions.sh`, `bash tests/test-release-workflow.sh`, `bash tests/test-superb-path-contract.sh`, and `bash tests/test-catalog.sh` for repository-level acceptance
- [ ] T045 Run the YAML parser command and every acceptance command listed in `specs/004-refocus-superb-boundaries/quickstart.md`, then run `git diff --check` as the final evidence gate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependency; registers the target validation surface.
- **Foundational (Phase 2)**: Depends on T001 and blocks all payload changes.
- **User Story 1 (Phase 3)**: Depends on T002 and establishes lifecycle ownership plus the replacement gate.
- **User Story 2 (Phase 4)**: Depends on US1 because its exact inventory includes the new command and removed payload.
- **User Story 3 (Phase 5)**: Depends on US1 for lifecycle terminology, but its four command rewrites remain independently testable.
- **Polish (Phase 6)**: Depends on all selected user stories.

### User Story Dependencies

- **US1 (P1)**: MVP and architectural spine; no dependency on another story after Foundation.
- **US2 (P2)**: Depends on US1's final command/hook surface; validates and distributes that surface consistently.
- **US3 (P3)**: Depends on US1's ownership vocabulary; does not depend on US2 documentation work.

### Within Each User Story

- Complete and observe failing test tasks before production tasks.
- Change the narrowest owning file that makes the test pass.
- Run each story's independent test task before moving to the next priority.
- Do not preserve compatibility aliases or dual old/new behavior.

### Parallel Opportunities

- T003, T004, and T005 can be authored in parallel before US1 implementation.
- T017, T018, T019, and T020 can be authored in parallel after the US1 surface is known.
- T022, T024, T025, and T026 touch separate contract consumers and can proceed in parallel after T021 defines the five-skill installer output.
- T035 and T036 can be authored in parallel; T037 through T040 can then proceed in parallel because each owns one command file.
- Spec Kit `[P]` markers express these opportunities; Superb performs no mode selection or agent dispatch.

---

## Parallel Example: User Story 1

```text
Task T003: lifecycle routing contract in superpowers-bridge/tests/test-lifecycle-routing.sh
Task T004: implementation gate contract in superpowers-bridge/tests/test-implementation-gate.sh
Task T005: installed payload absence contract in superpowers-bridge/tests/test-e2e-installation.sh
```

## Parallel Example: User Story 2

```text
Task T017: source capability contract in superpowers-bridge/tests/test-capability-contract.sh
Task T018: installation guidance contract in superpowers-bridge/tests/test-install-guidance.sh
Task T019: pinned Spec Kit install contract in superpowers-bridge/tests/test-spec-kit-012-install.sh
Task T020: durable skill resolution fixtures in superpowers-bridge/tests/test-resolve-skill.sh
```

## Parallel Example: User Story 3

```text
Task T037: critique boundary in superpowers-bridge/commands/critique.md
Task T038: debug boundary in superpowers-bridge/commands/debug.md
Task T039: respond boundary in superpowers-bridge/commands/respond.md
Task T040: finish boundary in superpowers-bridge/commands/finish.md
```

---

## Implementation Strategy

### MVP First: User Story 1

1. Complete Setup and the MemoryLint ownership guard.
2. Write and observe the three US1 suites fail.
3. Replace the five-hook lifecycle with brainstorm plus implementation gate.
4. Remove competing command, state, archive, and convergence behavior.
5. Stop and run T016; do not continue while the coherent workflow is unproven.

### Incremental Delivery

1. **US1**: Establish one coherent Spec Kit-owned workflow.
2. **US2**: Make every package and documentation consumer agree with the exact capability inventory.
3. **US3**: Preserve four useful standalone disciplines inside explicit write boundaries.
4. **Polish**: Run installed-package, repository, release, catalog, YAML, and whitespace gates.

### Parallel Team Strategy

1. Complete T001-T002 serially.
2. Author same-story failing tests in parallel where marked `[P]`.
3. Execute only file-independent implementation tasks in parallel.
4. Use the owning story checkpoint to merge evidence; do not introduce a Superb controller or separate task runtime.

---

## Notes

- `[P]` denotes Spec Kit task independence, not a Superb execution mode.
- Historical changelog text may name removed surfaces; active payload and guidance may not depend on them.
- Complete-plugin installation is allowed, but only five skills belong to Superb's logical runtime contract.
- Keep `extension.version` at the latest published value until the release workflow publishes a new version.
- Preserve unrelated staged and unstaged workspace changes throughout implementation.
