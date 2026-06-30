# Implementation Plan: Upstream Alignment for Converge and Agent-Context Opt-In

**Branch**: `003-upstream-alignment` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-upstream-alignment/spec.md`

## Summary

Align the two extensions with current upstream Spec Kit (converge + 0.12 agent-context opt-in),
with no backward-compatibility obligations. Two substantive changes plus docs/config:

1. **MemoryLint** gains agent-context managed-block awareness — rule extraction skips managed
   blocks across all configured `context_files`, the apply staleness gate's refusal message is
   clarified, and a malformed block fails safe (US1).
2. **Superpowers Bridge** declares a mandatory `after_converge → speckit.superb.verify` hook to
   fold convergence output into the evidence gate, and refocuses `review` on task quality/TDD,
   delegating coverage-gap task creation to converge (US2, US3).
3. **Config/docs**: mark agent-context as opt-in and declare verified Spec Kit version ranges
   in the catalog (US4).

Research (`research.md`) established that MemoryLint's existing whole-file SHA256 staleness gate
already prevents wrong-line writes, so US1's apply work is a message+test refinement, not a new
mechanism. The single extraction choke point (`markdown_rules()`) makes block-skipping the
minimal, transitive fix for both false findings and in-block edits.

## Technical Context

**Language/Version**: Python 3.10+ (MemoryLint scripts); Bash + PowerShell parity for tests;
Markdown + YAML for bridge commands/manifests.

**Primary Dependencies**: PyYAML (config parsing); existing `memorylint_core` module; Spec Kit
extension hook dispatch (upstream `speckit-converge`).

**Storage**: Files only — `AGENTS.md`/`CLAUDE.md`, `agent-context-config.yml`, `extension.yml`,
`catalog.json`, `.specify/extensions.yml`. No database.

**Testing**: Existing shell test suites in `memorylint/tests/` and `superpowers-bridge/tests/`;
Python-level assertions invoked from those tests, mirroring current patterns.

**Target Platform**: Developer workstations / CI running Spec Kit 0.12+.

**Project Type**: Spec Kit extensions (CLI/agent tooling), single repo, two extension packages.

**Performance Goals**: N/A (audit/apply run on a handful of small markdown files).

**Constraints**: No backward-compat shims (FR-014); changes confined to extension directories
(Constitution III); artifacts stay pure Markdown/YAML (Constitution II).

**Scale/Scope**: Two extensions; ~3 Python functions touched in MemoryLint, 1 manifest hook +
1 command refocus + README/catalog edits in the bridge.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Evidence-First Completion | ✅ PASS | US2 strengthens it (verify after converge); FR-015 requires tests for every change. |
| II. Unobtrusive Bridging | ✅ PASS | MemoryLint reads agent-context config read-only; artifacts stay Markdown/YAML; no state machine added. |
| III. Additive Extensions | ✅ PASS | All edits live under `memorylint/` and `superpowers-bridge/` (plus repo-local `.specify/extensions.yml` comment + `catalog.json`); no edits to `.specify/scripts/` or `.specify/templates/`. |
| IV. TDD (NON-NEGOTIABLE) | ✅ PASS | Each behavior (block skip, plural files, unterminated block, staleness message, hook declaration, review refocus) gets a failing test first. |
| V. Granular Implementation Control | ✅ PASS | Work decomposes into atomic 2–5 min tasks (see Phase 2 handoff). |
| VI. Bridge-Native Subagent Orchestration | ✅ N/A | No change to the multi-agent runtime. |

**Gate result**: PASS — no violations. Complexity Tracking left empty.

Post-Phase-1 re-check: design introduces no new principle conflicts (config read-only, hook is
additive, tests mandatory). **Still PASS.**

## Project Structure

### Documentation (this feature)

```text
specs/003-upstream-alignment/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── memorylint-managed-block.md
│   └── bridge-converge-hook.md
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
memorylint/
├── scripts/
│   ├── memorylint_core.py     # + resolve_managed_block_config(), managed_block_ranges();
│   │                          #   markdown_rules() skips managed blocks
│   └── apply_report.py        # clarify staleness-failure message (re-audit guidance)
└── tests/
    ├── test-managed-block-skip.sh      # NEW (US1: C3, plural files, unterminated)
    └── test-apply-staleness-message.sh # NEW (US1: C5)

superpowers-bridge/
├── extension.yml          # + hooks.after_converge → speckit.superb.verify (optional:false)
├── commands/review.md     # refocus verdict; delegate coverage gaps to converge
├── README.md              # document review-vs-converge + after_converge gate
└── tests/
    └── test-after-converge-hook.sh     # NEW (US2: C1/C2)

catalog.json               # requires.speckit_version range for both extensions (US4)
.specify/extensions.yml    # comment: agent-context is opt-in (US4)
README.md                  # note agent-context opt-in (US4)
```

**Structure Decision**: Keep each extension self-contained. MemoryLint changes are localized to
two scripts plus new shell tests; bridge changes are manifest + one command + README plus one
shell test. Repo-root `catalog.json`/`README.md`/`.specify/extensions.yml` receive doc/config-only
edits. No shared/new top-level modules are introduced.

## Complexity Tracking

> No Constitution violations — section intentionally empty.

## Phase 2 Handoff (for /speckit-tasks)

Task generation should produce, TDD-first, atomic tasks grouped by user story:

- **US1 (P1)**: failing tests for block-skip / plural files / unterminated block / staleness
  message → implement `resolve_managed_block_config`, `managed_block_ranges`, `markdown_rules`
  skip, apply message → green.
- **US2 (P1)**: failing test asserting `after_converge` hook → add manifest hook → green.
- **US3 (P2)**: failing test asserting review delegates coverage to converge → refocus `review.md`
  + README → green.
- **US4 (P3)**: update `catalog.json` version ranges + opt-in notes in README/`extensions.yml`.
- Final: run full suite (`memorylint/tests/*.sh`, `superpowers-bridge/tests/*.sh`) — SC-006.
