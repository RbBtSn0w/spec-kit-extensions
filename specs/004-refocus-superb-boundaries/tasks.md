---

description: "Implementation tasks for refocusing Superb as a bounded Spec Kit extension"
---

# Tasks: Refocus Superb Boundaries

**Input**: Design documents from `/specs/004-refocus-superb-boundaries/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests are mandatory under Constitution Principle IV. Superb behavior changes follow RED-GREEN-REFACTOR. Unchanged cross-extension boundaries use passing characterization tests rather than artificial failures.

**Organization**: Tasks are grouped by user story. Spec Kit `[P]` markers identify file-independent work only; Superb does not select or persist an execution mode.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel after its stated prerequisites because it touches a different file
- **[Story]**: Maps the task to User Story 1, 2, or 3
- Every task names the exact file or command path it changes or validates

## Phase 1: Setup (Passing Ownership Baseline)

**Purpose**: Establish the invariant that the Superb refocus does not alter the independent MemoryLint extension.

- [X] T001 Add and run a passing characterization guard for `memorylint/extension.yml` commands, hooks, dependencies, and mutation boundaries in `tests/test-review-regressions.sh`

**Checkpoint**: The MemoryLint boundary is green before any Superb payload change and must remain green throughout implementation.

---

## Phase 2: User Story 1 - Follow One Coherent Workflow (Priority: P1) MVP

**Goal**: Reduce Superb to bounded Spec Kit lifecycle enhancements with no competing review, verification, convergence, execution-mode, or completion workflow.

**Independent Test**: Install or inspect Superb and exercise `after_specify`, `before_implement`, implementation completion, and both convergence outcomes. Only the optional brainstorm and mandatory read-only implementation gate run; Spec Kit owns tasks, implementation, convergence, and completion evidence.

### Tests for User Story 1

> Write these tests first and confirm they fail against the current five-hook payload for the intended contract reasons.

- [X] T002 [P] [US1] Add failing assertions for exactly `after_specify` and `before_implement`, native task/analyze/converge routing, and absence of Superb lifecycle status in `superpowers-bridge/tests/test-lifecycle-routing.sh`
- [X] T003 [P] [US1] Add failing read-only, missing-artifact, installed-TDD, missing-TDD fallback, and native `[P]` reporting scenarios in `superpowers-bridge/tests/test-implementation-gate.sh`
- [X] T004 [P] [US1] Add failing installed-payload assertions that reject `controller.md`, `review.md`, `verify.md`, `plan-gate.md`, status-sync helpers, and evidence archives in `superpowers-bridge/tests/test-e2e-installation.sh`

### Implementation for User Story 1

- [X] T005 [US1] Replace controller/review/verify registrations and five hooks with `speckit.superb.implementation-gate` plus the exact two-hook routing in `superpowers-bridge/extension.yml`
- [X] T006 [US1] Implement the read-only TDD readiness and native-minimum fallback contract without mode selection, batching, dispatch, task mutation, commits, or status writes in `superpowers-bridge/commands/implementation-gate.md`
- [X] T007 [US1] Restrict optional spec refinement to user-approved `spec.md` changes and remove status-script declarations and parallel design outputs in `superpowers-bridge/commands/brainstorm.md`
- [X] T008 [P] [US1] Remove the superseded controller payload after T002-T004 establish replacement coverage in `superpowers-bridge/commands/controller.md`
- [X] T009 [P] [US1] Remove the post-tasks review payload after T002-T004 establish native task/analyze routing coverage in `superpowers-bridge/commands/review.md`
- [X] T010 [P] [US1] Remove the duplicate completion gate after T002-T004 establish implement/converge ownership coverage in `superpowers-bridge/commands/verify.md`
- [X] T011 [P] [US1] Remove the unregistered legacy planning gate after T004 rejects stale installed payload in `superpowers-bridge/commands/plan-gate.md`
- [X] T012 [P] [US1] Remove Superb status persistence from `superpowers-bridge/scripts/bash/sync-spec-status.sh`
- [X] T013 [P] [US1] Remove Superb status persistence from `superpowers-bridge/scripts/powershell/sync-spec-status.ps1`
- [X] T014 [P] [US1] Remove temporary evidence persistence from `superpowers-bridge/scripts/bash/archive-evidence.sh`
- [X] T015 [P] [US1] Remove temporary evidence persistence from `superpowers-bridge/scripts/powershell/archive-evidence.ps1`
- [X] T016 [US1] Run `bash superpowers-bridge/tests/test-lifecycle-routing.sh`, `bash superpowers-bridge/tests/test-implementation-gate.sh`, and `bash superpowers-bridge/tests/test-e2e-installation.sh` to prove the US1 workflow independently

**Checkpoint**: The normal Spec Kit path works with two bounded Superb hooks and no Superb-owned lifecycle state.

---

## Phase 3: User Story 2 - Understand Why Each Capability Exists (Priority: P2)

**Goal**: Make every installed command, hook, config option, document, and Superpowers dependency agree with the exact 7-command, 2-hook, 5-skill, 0-store capability contract.

**Independent Test**: Audit both the source tree and a Spec Kit 0.12.4 temporary installation. Every active capability has one lifecycle outcome and disposition; removed orchestration skills and stale payload files are absent even when the complete Superpowers plugin is installed.

### Tests for User Story 2

> Write these tests first and confirm they fail against the current six-skill/config/documentation surface.

- [X] T017 [P] [US2] Add a failing source contract for exactly seven commands, two hooks, five logical skills, zero lifecycle stores, forbidden-surface absence, and all active Superb documents in `superpowers-bridge/tests/test-capability-contract.sh`
- [X] T018 [P] [US2] Add failing five-skill installation guidance and complete-plugin isolation scenarios in `superpowers-bridge/tests/test-install-guidance.sh`
- [X] T019 [P] [US2] Add a failing real temporary installation and registered-payload inspection using pinned Spec Kit 0.12.4 in `superpowers-bridge/tests/test-spec-kit-012-install.sh`
- [X] T020 [P] [US2] Add failing supported-version fixtures that resolve five disciplines without internal headings, prompt filenames, or agent names in `superpowers-bridge/tests/test-resolve-skill.sh`

### Implementation for User Story 2

- [X] T021 [US2] Change prerequisite checks, selective install commands, and diagnostics from six skills to the five contracted disciplines in `superpowers-bridge/scripts/bash/ensure-skills.sh`
- [X] T022 [P] [US2] Align hard/optional requirements, two-hook policy, command toggles, and removal of mode-detection settings in `superpowers-bridge/superb-config.template.yml`
- [X] T023 [US2] Report exactly five skills, two hooks, four standalone commands, and bounded missing-skill recovery in `superpowers-bridge/commands/check.md`
- [X] T024 [P] [US2] Document the capability inventory, artifact-owner routing, five-skill logical contract, and migration from removed surfaces in `superpowers-bridge/WORKFLOW.md`
- [X] T025 [P] [US2] Update installation, command, hook, fallback, and compatibility guidance to the exact target contract in `superpowers-bridge/README.md`
- [X] T026 [P] [US2] Remove obsolete controller, review, verify, status, and multi-agent orchestration design notes from the active package by deleting `superpowers-bridge/V2-DESIGN-NOTES.md`
- [X] T027 [P] [US2] Record the breaking removals and planned release bump only under Unreleased metadata in `superpowers-bridge/CHANGELOG.md`
- [X] T028 [US2] Align catalog-facing command and capability metadata without changing the published extension version in `catalog.json`
- [X] T029 [P] [US2] Remove the replaced review/converge suite in `superpowers-bridge/tests/test-review-converge-split.sh`
- [X] T030 [P] [US2] Remove the replaced post-converge hook suite in `superpowers-bridge/tests/test-after-converge-hook.sh`
- [X] T031 [P] [US2] Remove the replaced Bash status-sync suite in `superpowers-bridge/tests/test-status-sync.sh`
- [X] T032 [P] [US2] Remove the replaced PowerShell status-sync suite in `superpowers-bridge/tests/test-status-sync.ps1`
- [X] T033 [P] [US2] Remove the replaced Bash evidence-archive suite in `superpowers-bridge/tests/test-archive-evidence.sh`
- [X] T034 [P] [US2] Remove the replaced PowerShell evidence-archive suite in `superpowers-bridge/tests/test-archive-evidence.ps1`
- [X] T035 [P] [US2] Remove the replaced legacy planning-gate suite in `superpowers-bridge/tests/test-plan-gate.sh`
- [X] T036 [P] [US2] Remove the replaced stage-runtime controller suite in `superpowers-bridge/tests/test-stage-runtime-contract.sh`
- [X] T037 [P] [US2] Remove the replaced concurrency-cascade suite in `superpowers-bridge/tests/test-concurrency-cascade.sh`
- [X] T038 [P] [US2] Remove the replaced concurrency-dependency suite in `superpowers-bridge/tests/test-concurrency-dependency.sh`
- [X] T039 [P] [US2] Remove the replaced parallel-dispatch suite in `superpowers-bridge/tests/test-parallel-dispatch.sh`
- [X] T040 [P] [US2] Remove the replaced SDD-detection suite in `superpowers-bridge/tests/test-sdd-detection.sh`
- [X] T041 [P] [US2] Remove the replaced SDD-fallback suite in `superpowers-bridge/tests/test-sdd-fallback.sh`
- [X] T042 [P] [US2] Remove the replaced SDD-review suite in `superpowers-bridge/tests/test-sdd-reviews.sh`
- [X] T043 [P] [US2] Remove the replaced checkpoint-resume suite in `superpowers-bridge/tests/test-checkpoint-resume.sh`
- [X] T044 [P] [US2] Remove the replaced continuous-sync suite in `superpowers-bridge/tests/test-continuous-sync.sh`
- [X] T045 [P] [US2] Remove the replaced discoveries-lifecycle suite in `superpowers-bridge/tests/test-discoveries-lifecycle.sh`
- [X] T046 [US2] Run `bash superpowers-bridge/tests/test-capability-contract.sh`, `bash superpowers-bridge/tests/test-install-guidance.sh`, `bash superpowers-bridge/tests/test-resolve-skill.sh`, and `bash superpowers-bridge/tests/test-spec-kit-012-install.sh` to prove the US2 inventory independently

**Checkpoint**: Source, configuration, installer, all active documents, catalog, and installed package expose exactly 7 commands, 2 hooks, 5 skills, and 0 Superb lifecycle stores.

---

## Phase 4: User Story 3 - Operate Superb Without Internal Orchestration Knowledge (Priority: P3)

**Goal**: Keep the four standalone disciplines useful while removing controller terminology, hidden dispatch, completion ownership, and writes outside each command's declared boundary.

**Independent Test**: Invoke `critique`, `debug`, `respond`, and `finish` with simple and concurrency-eligible work. Outputs use Spec Kit artifact and evidence language, perform only permitted writes, and leave concurrency decisions to the owning Spec Kit implementation flow or active agent runtime.

### Tests for User Story 3

> Write these tests first and confirm they fail against the current broad standalone commands.

- [X] T047 [P] [US3] Add failing read/write and forbidden-behavior assertions for all four standalone commands in `superpowers-bridge/tests/test-command-boundaries.sh`
- [X] T048 [P] [US3] Add failing user-language assertions rejecting controller, worker, mode-selection, hidden dispatch, and Superb verify-prerequisite wording in `superpowers-bridge/tests/test-workflow-contract.sh`

### Implementation for User Story 3

- [X] T049 [P] [US3] Narrow critique to read-only evidence-backed findings and artifact-owner remediation routing in `superpowers-bridge/commands/critique.md`
- [X] T050 [P] [US3] Narrow debug to the current failing task, focused RED-GREEN verification, and return to the owning implementation flow in `superpowers-bridge/commands/debug.md`
- [X] T051 [P] [US3] Route requirement, architecture, and task-scope feedback to the earliest Spec Kit owner before accepted in-scope fixes in `superpowers-bridge/commands/respond.md`
- [X] T052 [P] [US3] Replace Superb verify/status prerequisites with fresh checks, explicit branch choices, and foreign-workspace preservation in `superpowers-bridge/commands/finish.md`
- [X] T053 [US3] Run `bash superpowers-bridge/tests/test-command-boundaries.sh` and `bash superpowers-bridge/tests/test-workflow-contract.sh` to prove the US3 command boundaries independently

**Checkpoint**: All retained standalone commands describe user outcomes and evidence without exposing or recreating an orchestration system.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Register completed suites and prove repository, package, documentation, and release consistency.

- [X] T054 Register the existing Superb capability, lifecycle, command-boundary, and pinned-install suites in `.github/workflows/ci.yml` after T002, T003, T004, T017, T019, T047, and T048 create them
- [X] T055 [P] Synchronize root Superb overview and published-version references with the final extension surface in `README.md`
- [X] T056 Preserve the T001 MemoryLint characterization guard while replacing root expectations for removed review/verify/status behavior with final capability and routing contracts in `tests/test-review-regressions.sh`
- [X] T057 Run `bash tests/test-review-regressions.sh`, `bash tests/test-release-workflow.sh`, `bash tests/test-superb-path-contract.sh`, and `bash tests/test-catalog.sh` for repository-level acceptance
- [X] T058 Run the YAML parser command and every acceptance command listed in `specs/004-refocus-superb-boundaries/quickstart.md`, then run `git diff --check` as the final evidence gate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependency; establishes a passing MemoryLint boundary.
- **US1 (Phase 2)**: Depends on T001 and establishes lifecycle ownership plus the replacement gate.
- **US2 (Phase 3)**: Depends on T016 because its exact inventory includes the new command and removed lifecycle payload.
- **US3 (Phase 4)**: Depends on T016 for ownership vocabulary; it does not depend on US2 documentation changes.
- **Polish (Phase 5)**: Depends on T046 and T053 so CI only registers suites that already exist.

### User Story Dependencies

- **US1 (P1)**: MVP and architectural spine; no dependency on another story after Setup.
- **US2 (P2)**: Depends on US1's final command/hook surface; validates and distributes that surface consistently.
- **US3 (P3)**: Depends on US1's ownership vocabulary; remains independently testable from US2.

### Within Each User Story

- Complete and observe behavior-contract tests fail before production tasks.
- Require failures to identify target behavior, not missing test files or unrelated infrastructure.
- Change the narrowest owning file that makes the test pass.
- Run each story's independent test task before moving to its dependents.
- Do not preserve compatibility aliases or dual old/new behavior.

### Parallel Opportunities

- T002, T003, and T004 can be authored in parallel before US1 implementation.
- After T005-T007, T008 through T015 can run in parallel because each removes one independently covered file.
- T017 through T020 can be authored in parallel after US1 passes.
- T022 and T024 through T027 can proceed in parallel after the target five-skill contract is fixed by T021.
- After T017-T020 are green, T029 through T045 can run in parallel because each removes one obsolete test file.
- T047 and T048 can be authored in parallel; T049 through T052 can then proceed in parallel because each owns one command file.
- Spec Kit `[P]` markers express these opportunities; Superb performs no mode selection or agent dispatch.

---

## Parallel Example: User Story 1

```text
Task T002: lifecycle routing contract in superpowers-bridge/tests/test-lifecycle-routing.sh
Task T003: implementation gate contract in superpowers-bridge/tests/test-implementation-gate.sh
Task T004: installed payload absence contract in superpowers-bridge/tests/test-e2e-installation.sh
```

## Parallel Example: User Story 2

```text
Task T017: source capability and documentation contract in superpowers-bridge/tests/test-capability-contract.sh
Task T018: installation guidance contract in superpowers-bridge/tests/test-install-guidance.sh
Task T019: pinned Spec Kit install contract in superpowers-bridge/tests/test-spec-kit-012-install.sh
Task T020: durable skill resolution fixtures in superpowers-bridge/tests/test-resolve-skill.sh
```

## Parallel Example: User Story 3

```text
Task T049: critique boundary in superpowers-bridge/commands/critique.md
Task T050: debug boundary in superpowers-bridge/commands/debug.md
Task T051: respond boundary in superpowers-bridge/commands/respond.md
Task T052: finish boundary in superpowers-bridge/commands/finish.md
```

---

## Implementation Strategy

### MVP First: User Story 1

1. Establish and run the passing MemoryLint boundary guard.
2. Write T002-T004 and confirm each fails for its target contract.
3. Replace the five-hook lifecycle with brainstorm plus implementation gate.
4. Remove competing command, state, archive, and convergence behavior one file at a time.
5. Stop and run T016; do not continue while the coherent workflow is unproven.

### Incremental Delivery

1. **US1**: Establish one coherent Spec Kit-owned workflow.
2. **US2**: Make every package, document, and distribution consumer agree with the exact capability inventory.
3. **US3**: Preserve four useful standalone disciplines inside explicit write boundaries.
4. **Polish**: Register completed tests and run installed-package, repository, release, catalog, YAML, and whitespace gates.

### Parallel Team Strategy

1. Complete T001 serially.
2. Author same-story failing tests in parallel where marked `[P]`.
3. Execute only file-independent implementation tasks in parallel after their tests establish coverage.
4. Use the owning story checkpoint to merge evidence; do not introduce a Superb controller or separate task runtime.

---

## Notes

- `[P]` denotes Spec Kit task independence, not a Superb execution mode.
- Historical changelog text may name removed surfaces; active payload and guidance may not depend on them.
- `V2-DESIGN-NOTES.md` is removed because its superseded orchestration design must not remain active package documentation.
- Complete-plugin installation is allowed, but only five skills belong to Superb's logical runtime contract.
- Keep `extension.version` at the latest published value until the release workflow publishes a new version.
- Preserve unrelated staged and unstaged workspace changes throughout implementation.
