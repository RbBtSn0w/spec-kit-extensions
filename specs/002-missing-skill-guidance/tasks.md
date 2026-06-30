# Tasks: Missing Skill Installation Guidance

**Input**: Design documents from `/specs/002-missing-skill-guidance/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/output-format.md

**Tests**: Test tasks are MANDATORY per Constitution Principle IV (Test-Driven Development). Every behavior task must have a corresponding test verification step.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Includes exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and base branch setup

- [x] T001 Verify git branch is `002-missing-skill-guidance` and workspace is clean
- [x] T002 Bump extension version and document update intent in `superpowers-bridge/extension.yml`
- [x] T003 Initialize skeleton directory for tests and scripts in `superpowers-bridge/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Setup the core helper script that will be invoked by all interactive auto-install flows

- [x] T004 Create foundational installation orchestration script shell at `superpowers-bridge/scripts/bash/ensure-skills.sh`
- [x] T005 [P] Setup executable permissions and basic exit code framework in `superpowers-bridge/scripts/bash/ensure-skills.sh`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Guided Skill Installation on Check (Priority: P1) 🎯 MVP

**Goal**: Extend the diagnostic `check` command to display `adg` installation guidance for each missing skill.

**Independent Test**: Run `/speckit-superb-check` with at least one missing skill and verify that the output displays the skill as MISSING and includes `adg` installation commands with the repo link.

### Tests for User Story 1 (MANDATORY)

- [x] T006 [P] [US1] Create diagnostic guidance test script at `superpowers-bridge/tests/test-install-guidance.sh` that fails when missing skills lack adg links
- [x] T007 [P] [US1] Implement a test assertion in `superpowers-bridge/tests/test-install-guidance.sh` verifying that the repository URL `https://github.com/RbBtSn0w/adg` is present in the output

### Implementation for User Story 1

- [x] T008 [US1] Modify `superpowers-bridge/commands/check.md` to add the `Guidance` column to the Skill Status table
- [x] T009 [US1] Update the diagnostic resolution logic in `superpowers-bridge/commands/check.md` to populate the `Guidance` column with `Install via adg` for MISSING skills
- [x] T010 [US1] Run `bash superpowers-bridge/tests/test-install-guidance.sh` and verify it passes

**Checkpoint**: User Story 1 is functional. Diagnostic commands now point users to the right installation tool.

---

## Phase 4: User Story 2 - Inline Guidance on Hook/Command Invocation (Priority: P2)

**Goal**: Inject inline error messages and install prompts with npx pre-detection into all bridge commands and hooks.

**Independent Test**: Hide a skill (e.g. `systematic-debugging`), run `/speckit-superb-debug`, and confirm the error outputs the correct `adg` links.

### Tests for User Story 2 (MANDATORY)

- [x] T011 [P] [US2] Create npx pre-detection test script at `superpowers-bridge/tests/test-npx-detection.sh` validating fallback when npx is missing
- [x] T012 [P] [US2] Create command inline failure assertion test in `superpowers-bridge/tests/test-npx-detection.sh` to ensure commands stop when dependencies fail

### Implementation for User Story 2

- [x] T013 [US2] Implement POSIX-compliant npx check (`command -v npx`) in `superpowers-bridge/scripts/bash/ensure-skills.sh`
- [x] T014 [US2] Modify `superpowers-bridge/commands/controller.md` to append inline guidance for missing hard requirements (`test-driven-development` and `verification-before-completion`)
- [x] T015 [US2] Modify `superpowers-bridge/commands/debug.md` to append inline guidance for missing `systematic-debugging`
- [x] T016 [US2] Modify `superpowers-bridge/commands/finish.md` to append inline guidance for missing `finishing-a-development-branch`
- [x] T017 [US2] Modify `superpowers-bridge/commands/brainstorm.md` to append inline guidance for missing `brainstorming`
- [x] T018 [US2] Modify `superpowers-bridge/commands/verify.md` to append inline guidance for missing `verification-before-completion`
- [x] T019 [US2] Modify remaining command files (`critique.md`, `respond.md`, `review.md`, `plan-gate.md`) to align with the inline warning templates defined in contracts
- [x] T020 [US2] Run `bash superpowers-bridge/tests/test-npx-detection.sh` and verify it passes

**Checkpoint**: User Story 2 is functional. Any command or hook triggered with missing skills will now show guidance and prevent silent failure.

---

## Phase 5: User Story 3 - Aggregated Installation Summary (Priority: P3)

**Goal**: Provide a "Quick Setup" aggregated section in the check report with interactive approach prompts and automatic re-check on success.

**Independent Test**: Run `/speckit-superb-check` in a clean environment, select installation option 1, and verify that all 11 skills are successfully installed and verified on screen.

### Tests for User Story 3 (MANDATORY)

- [x] T021 [US3] Add a test scenario in `superpowers-bridge/tests/test-install-guidance.sh` verifying that the Quick Setup section correctly groups Hard Requirements vs Optional Skills
- [x] T022 [US3] Add a mock installation test scenario in `superpowers-bridge/tests/test-install-guidance.sh` verifying that selecting an approach invokes `ensure-skills.sh` with the correct arguments

### Implementation for User Story 3

- [x] T023 [US3] Implement interactive prompt logic in `superpowers-bridge/commands/check.md` to capture user approach selections (1-3)
- [x] T024 [US3] Map selected approaches to corresponding `npx adg` invocations (with exact `--skill` filters for all 11 skills) in `superpowers-bridge/scripts/bash/ensure-skills.sh`
- [x] T025 [US3] Implement post-install verification rendering logic in `superpowers-bridge/commands/check.md` to output the Before/After check table
- [x] T026 [US3] Run all newly created tests and verify they pass

**Checkpoint**: User Story 3 is functional. New setups can be fully configured interactively.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final clean-ups, documentation updates, and repository sanity checks.

- [x] T027 [US3] Update the extension `README.md` to document the missing skill diagnostic workflow and Quick Setup capabilities
- [x] T028 Run existing status-sync regression checks at `superpowers-bridge/tests/test-status-sync.sh`
- [x] T029 Run main branch review regressions check at `tests/test-review-regressions.sh`
- [x] T030 Validate git hygiene by running `git diff --check`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Phase 1.
- **User Stories (Phase 3+)**: Must start sequentially. US1 (Check) first, then US2 (Inline commands), then US3 (Quick Setup + Re-check).
- **Polish (Phase 6)**: Depends on all user stories completing.

### Within Each User Story

- Test cases must be written before implementation.
- Core commands must be modified before verification runs.

### Parallel Opportunities

- T006 and T007 (US1 tests) can be written in parallel.
- T011 and T012 (US2 tests) can be written in parallel.
- Polish phase tasks (README updates) can run in parallel with regression tests.

---

## Parallel Example: User Story 1

```bash
# Developer A writes the diagnostics test checking output structure:
Task: "T006 Create diagnostic guidance test script at superpowers-bridge/tests/test-install-guidance.sh"

# Developer B writes assertion ensuring the correct ADG URL is embedded:
Task: "T007 Implement a test assertion verifying repository URL in test-install-guidance.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 & 2.
2. Complete Phase 3 (US1 - Diagnostics check guidance).
3. Validate `/speckit-superb-check` produces the new `Guidance` column and points to `https://github.com/RbBtSn0w/adg`.
4. Stop and confirm manual path works before introducing interactive execution logic.

### Incremental Delivery

1. Phase 3 (MVP) -> Delivers diagnostics guidance.
2. Phase 4 (US2) -> Prevents silent hook failure by adding command-level guides.
3. Phase 5 (US3) -> Delivers interactive auto-installation.
4. Phase 6 (Polish) -> Integrates regression checks and publishes documentation.

## Phase 7: Convergence

- [x] T031 Align the recommended plugin installation command in `superpowers-bridge/scripts/bash/ensure-skills.sh`, `superpowers-bridge/commands/check.md`, and related guidance/tests to the spec-approved `npx adg plugins add ... -g` flow per FR-009 after verifying the current `adg` plugin contract
- [x] T032 Add opt-in inline auto-install handling for missing required skills in the dependent superb command/hook flows, including `npx` pre-detection, explicit confirmation, selected approach execution, post-install re-check behavior, and regression coverage per FR-002 / FR-006 / US2/AC1 / US2/AC2 (partial)

## Phase 8: Convergence

- [x] T033 Implement and verify inline opt-in auto-install handling in the dependent superb command/hook flows so missing required skills trigger `npx` pre-detection, explicit confirmation, selected `adg` approach execution, and post-install re-check behavior per FR-002 / FR-006 / FR-011 / US2/AC1 / US2/AC2 (partial)

## Phase 9: Convergence

- [x] T034 Fix the malformed inline ensure helper shell examples in the dependent superb command flows and add regression coverage that validates the full recovery command strings per FR-006 / FR-011 / SC-004 / US2/AC1 / US2/AC2 (partial)
