---
description: "Task list for Upstream Alignment for Converge and Agent-Context Opt-In"
---

# Tasks: Upstream Alignment for Converge and Agent-Context Opt-In

**Input**: Design documents from `/specs/003-upstream-alignment/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: MANDATORY per Constitution Principle IV (TDD). Every behavior task is preceded by a failing test task.

**Organization**: Grouped by user story. US1 and US2 are both P1; US1 carries the only data/state-corruption risk and is the recommended MVP.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- Paths are repository-relative.

---

## Phase 1: Setup

- [X] T001 [P] Add a managed-block test fixture set under `memorylint/tests/fixtures/managed-block/` using the **authoritative** default markers `<!-- SPECKIT START -->`/`<!-- SPECKIT END -->` (per data-model.md "Authoritative default markers" — do not invent marker strings): an `AGENTS.md` with real rules plus a well-formed block, a `CLAUDE.md` with its own block, an unterminated-block variant, an `agent-context-config.yml` in both plural `context_files` and singular `context_file` forms, and a config that points at a non-existent context file (for the absent-file edge case, C5).
- [X] T002 [P] Add a no-agent-context baseline fixture under `memorylint/tests/fixtures/no-agent-context/` (plain `AGENTS.md`, no config, no markers) for the invariance test (C6).

---

## Phase 2: Foundational

_No cross-story blocking prerequisites. MemoryLint config/range helpers are scoped to US1; the bridge hook is scoped to US2. Proceed directly to the user-story phases._

---

## Phase 3: User Story 1 — MemoryLint coexists safely with agent-context managed blocks (P1) 🎯 MVP

**Goal**: Rule extraction skips managed blocks across all configured `context_files`; apply refuses to write on staleness with re-audit guidance; malformed blocks fail safe.

**Independent Test**: Run audit+apply against the Phase 1 fixtures; verify no finding/edit lands inside a managed block, plural files are both skipped, apply aborts after a simulated block insertion, and an unterminated block produces a warning.

### Tests (write first, MUST fail)

- [X] T003 [US1] Add `memorylint/tests/test-managed-block-skip.sh` asserting (a) no `Rule`/finding originates inside the block in `AGENTS.md`, (b) the block in `CLAUDE.md` is also skipped (plural `context_files`), and (c) the singular `context_file` config form is honored. Run against fixtures from T001; confirm it fails before implementation. Covers contracts C1–C3, FR-001/FR-002/FR-003.
- [X] T004 [P] [US1] Add `memorylint/tests/test-managed-block-malformed.sh` asserting an unterminated block is skipped to EOF and a warning naming the file is emitted, with no edit targeting that region. Covers C4/FR-006.
- [X] T005 [P] [US1] Add `memorylint/tests/test-apply-staleness-message.sh`: build an audit report, mutate `AGENTS.md` to simulate an agent-context block insert, run apply, assert non-zero exit, nothing written, and a message instructing re-running `/speckit-memorylint-audit`. Covers C5/FR-004.
- [X] T006 [P] [US1] Add `memorylint/tests/test-managed-block-invariance.sh` asserting audit+apply output on the T002 baseline is identical to current behavior (no agent-context), and that a config pointing at a non-existent context file is treated as no-managed-block with no error (absent-file edge case, C5). Covers C6/FR-005 and the missing-context-file edge case.

### Implementation (make tests pass)

- [X] T007 [US1] Implement `resolve_managed_block_config(workspace_root)` in `memorylint/scripts/memorylint_core.py`: read `.specify/extensions/agent-context/agent-context-config.yml`, resolve `managed_files` from `context_files` (preferred) then `context_file` (both current upstream keys per FR-003), resolve markers using the shared authoritative default constants `<!-- SPECKIT START -->`/`<!-- SPECKIT END -->`, never raise on missing/invalid YAML or absent context-file paths. Covers C1/FR-003 and C4 (shared marker constant).
- [X] T008 [US1] Implement `managed_block_ranges(text, config)` in `memorylint/scripts/memorylint_core.py` returning inclusive 1-based ranges per block, with unterminated→EOF and `terminated=False`. Covers C2/FR-006.
- [X] T009 [US1] Update `markdown_rules()` (and `discover_sources` call site as needed) in `memorylint/scripts/memorylint_core.py` to skip lines inside any managed-block range for files in `managed_files` or that physically contain the start marker; emit the unterminated-block warning. Covers C3/C4/FR-001/FR-002/FR-006. Depends on T007, T008.
- [X] T010 [US1] Clarify the staleness-failure message in `memorylint/scripts/apply_report.py` (the `Staleness check failed for {relative}` path) to explicitly direct the user to re-run `/speckit-memorylint-audit`. Covers C5/FR-004.
- [X] T011 [US1] Run T003–T006; confirm all pass. Verify no regression in existing `memorylint/tests/*.sh`.

**Checkpoint**: US1 independently deliverable — MemoryLint is safe alongside agent-context.

---

## Phase 4: User Story 2 — Convergence output flows into the evidence gate (P1)

**Goal**: The bridge declares a mandatory `after_converge → speckit.superb.verify` hook so converge-driven work passes the evidence gate; bridge-absent runs are untouched.

**Independent Test**: Assert the manifest declares the hook and that hook dispatch yields `EXECUTE_COMMAND: speckit.superb.verify`; assert no command when the entry is absent.

### Tests (write first, MUST fail)

- [X] T012 [US2] Add `superpowers-bridge/tests/test-after-converge-hook.sh` asserting `superpowers-bridge/extension.yml` declares `hooks.after_converge` with `command: speckit.superb.verify` and `optional: false`, and that a sample `.specify/extensions.yml` containing this entry resolves to `EXECUTE_COMMAND: speckit.superb.verify` while an absent entry resolves to none. Covers contract C1/C2, FR-007/FR-008/FR-009. Confirm it fails first.
- [X] T012a [US2] Verify and document the upstream dispatch assumption (analysis C2): confirm the `speckit-converge` command's post-execution step reads `hooks.after_converge` and emits `EXECUTE_COMMAND` for mandatory hooks; record the source reference in `superpowers-bridge/tests/test-after-converge-hook.sh` (a comment) or the bridge README so a green test cannot mask a missing upstream lifecycle event.

### Implementation (make tests pass)

- [X] T013 [US2] Add the `after_converge` hook block to `superpowers-bridge/extension.yml` (`command: speckit.superb.verify`, `optional: false`, description per contract C1). Note in the description/README that blocking-on-missing-evidence is inherited from the reused `speckit.superb.verify` command (analysis C3) — no separate blocking test is needed since `verify`'s own gate behavior already covers it.
- [X] T014 [US2] Run T012; confirm pass.

**Checkpoint**: US2 independently deliverable — converge output is evidence-gated.

---

## Phase 5: User Story 3 — Review and converge have non-overlapping responsibilities (P2)

**Goal**: `review` drives its verdict from task quality/TDD-readiness/plan↔task consistency and delegates coverage-gap task creation to converge; the boundary is documented.

**Independent Test**: Run review against a feature with coverage gaps + TDD issues; verify coverage remediation routes to `/speckit-converge` and quality/TDD BLOCKED outcomes remain.

### Tests (write first, MUST fail)

- [X] T015 [US3] Add `superpowers-bridge/tests/test-review-converge-split.sh` asserting `superpowers-bridge/commands/review.md` routes coverage-gap remediation to `/speckit-converge` (not manual task additions) and retains BLOCKED outcomes for plan↔task mismatch and TDD-readiness failures. Covers C3/FR-010. Confirm it fails first.

### Implementation (make tests pass)

- [X] T016 [US3] Refocus `superpowers-bridge/commands/review.md`: update the decision table/recommendations so coverage gaps delegate to `/speckit-converge`; keep quality/TDD/plan-task BLOCKED logic. Covers FR-010.
- [X] T017 [P] [US3] Document the review (plan-stage prevention) vs converge (delivery-stage remediation) boundary and the `after_converge → verify` gate in `superpowers-bridge/README.md`. Covers C4/FR-012.
- [X] T018 [US3] Run T015; confirm pass.

**Checkpoint**: US3 deliverable — review/converge responsibilities are distinct and documented.

---

## Phase 6: User Story 4 — Configuration and docs reflect current upstream reality (P3)

**Goal**: agent-context documented as opt-in; catalog declares verified Spec Kit version ranges.

**Independent Test**: Read config/README/catalog and confirm opt-in statement and version ranges are present.

- [X] T019 [P] [US4] Update `catalog.json` `requires.speckit_version` for `superb` and `memorylint` to a range verified against converge and the 0.12 agent-context opt-in; refresh descriptions/tags as needed. Covers FR-013.
- [X] T020 [P] [US4] Note in `README.md` that agent-context is an opt-in dependency post-0.12 and its hooks apply only when enabled; add a clarifying comment in `.specify/extensions.yml` near the agent-context entries. Covers FR-011.
- [X] T021 [P] [US4] Mention agent-context opt-in tolerance and review-vs-converge in `memorylint/README.md` where relevant. Covers FR-011/FR-012.

---

## Phase 7: Polish & Cross-Cutting

- [X] T022 Add CHANGELOG entries under `superpowers-bridge/CHANGELOG.md` and `memorylint/CHANGELOG.md` describing the converge integration, review refocus, and managed-block handling (keep `## [Unreleased]` per Constitution).
- [X] T023 Run the full suites — `for t in memorylint/tests/*.sh superpowers-bridge/tests/*.sh; do bash "$t"; done` — and confirm all pass (SC-006).
- [X] T024 [P] Verify quickstart.md scenarios US1–US4 each map to a passing test; reconcile any gaps.

---

## Dependencies & Execution Order

- **Setup (T001–T002)** → before US1 tests.
- **US1 (T003–T011)**: tests T003–T006 before impl T007–T010; T009 depends on T007+T008; T011 closes.
- **US2 (T012–T014)**: independent of US1; can run in parallel by a second worker.
- **US3 (T015–T018)**: depends on US2 conceptually (references converge gate in docs) but file-independent; safe after US2.
- **US4 (T019–T021)**: independent; depends only on final naming decisions.
- **Polish (T022–T024)**: after all stories.

## Parallel Opportunities

- T001 ‖ T002 (different fixtures).
- T004 ‖ T005 ‖ T006 (different test files) after T003 establishes the harness.
- US1 ‖ US2 across two workers (disjoint files: `memorylint/` vs `superpowers-bridge/`).
- T019 ‖ T020 ‖ T021 (different files).

## Implementation Strategy

- **MVP = US1** (P1, sole corruption risk). Ship it first: MemoryLint safe alongside agent-context.
- **Second increment = US2** (P1): close the converge evidence loop.
- **Then US3 (P2), US4 (P3), Polish.**
- Each story is independently testable and deliverable per its checkpoint.
