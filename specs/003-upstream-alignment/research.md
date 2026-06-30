# Phase 0 Research: Upstream Alignment

**Feature**: 003-upstream-alignment | **Date**: 2026-06-30

This document records the codebase findings that resolve the open design questions for
issue #18. All findings are from direct inspection of the current source.

## R1 — How MemoryLint discovers and extracts rules (US1 / FR-001, FR-002)

**Decision**: Inject managed-block awareness into `markdown_rules()` (rule extraction) so that
lines inside an agent-context managed block are never emitted as `Rule` objects. Because all
downstream findings/edits derive from `Rule` line ranges, suppressing extraction inside the
block is sufficient to also satisfy FR-002 (no edit targets a managed-block line).

**Rationale**:
- `memorylint_core.discover_sources()` (lines 180-209) globs `AGENTS.md`/`CLAUDE.md`/etc.
- `markdown_rules()` (lines 212-241) iterates lines, recording bullet/heading lines as `Rule`
  with `line_range = str(line_number)`. This is the single choke point where block content
  enters the model. All finding generators (`make_boundary_findings`, `detect_reality_findings`,
  …) consume `Rule`s and derive `Edit.start_line/end_line` from `rule.line_range`.
- Therefore a block-skip filter at extraction time transitively prevents both spurious findings
  (FR-001) and in-block edits (FR-002) — no need to touch every finding generator.

**Alternatives considered**:
- Filter at the finding/edit layer — rejected: many generators, higher surface, easy to miss one.
- Strip the block before parsing — rejected: would shift line numbers and break `line_range`
  fidelity against the on-disk file.

## R2 — Where the marker/file-list configuration lives (US1 / FR-003, FR-006)

**Decision**: Resolve markers and the managed-file set from the agent-context extension's
self-owned config at `.specify/extensions/agent-context/agent-context-config.yml`, reading the
plural `context_files` key first and falling back to the singular `context_file`; when neither
the file nor the keys are present, fall back to the documented defaults
`<!-- SPECKIT START -->` / `<!-- SPECKIT END -->`. A file is only block-scanned for markers
when it is in the resolved managed-file set (or, defensively, any scanned file that physically
contains the markers).

**Rationale**:
- Per upstream 0.12 (PR github/spec-kit#3097) the CLI no longer owns this; the extension self-owns
  `agent-context-config.yml` plus a bundled `agent-context-defaults.json`. The bundled updater
  script reads `context_files` or `context_file` from the config — MemoryLint mirrors that key
  precedence to stay consistent with what actually writes the block.
- This repo's current config still uses singular `context_file: AGENTS.md` with explicit
  `context_markers.start/end`; reading both keys covers current and 0.12 layouts without a
  compatibility shim (both are "current" upstream-supported keys).
- Defensive marker detection (treat any file that contains the markers as having a managed block,
  even if not listed) hardens against config drift at zero cost.

**Malformed block (FR-006)**: If a start marker has no matching end marker, skip from the start
marker to end-of-file and surface a warning, never editing inside the unterminated region.

**Alternatives considered**:
- Read the CLI registry — rejected: 0.12 removed it; all agent→file knowledge now lives in the
  extension.
- Hard-code `AGENTS.md` only — rejected: violates the plural `context_files` requirement.

## R3 — Apply-time location safety (US1 / FR-004)

**Decision**: The core wrong-line-write protection **already exists** — `apply_report.py`
(lines 115-131) computes a whole-file SHA256 and compares it to the `source_metadata` hash
captured at audit time, refusing to write on any mismatch ("Staleness check failed"). Remaining
work is limited to: (a) making that failure message explicitly instruct the user to re-run the
audit, and (b) a regression test proving that an agent-context block insertion between audit and
apply triggers the staleness refusal.

**Rationale**:
- A managed-block insert/resize changes the file's bytes → hash mismatch → apply aborts before
  any write. This already guarantees SC-002 (zero wrong-line writes) at file granularity.
- No new anchor-text mechanism is needed; adding one would duplicate the existing hash gate.
  This keeps the change minimal and avoids redundant logic.

**Alternatives considered**:
- Per-edit anchor-text verification — rejected as redundant given the whole-file hash gate; would
  add complexity without improving the guarantee.

## R4 — Wiring the bridge verification gate to converge (US2 / FR-007, FR-008, FR-009)

**Decision**: Declare an `after_converge` hook in `superpowers-bridge/extension.yml` that invokes
`speckit.superb.verify` as a mandatory (`optional: false`) gate. Upstream `speckit-converge`
reads `hooks.after_converge` from `.specify/extensions.yml` (SKILL.md line 244) and emits
`EXECUTE_COMMAND` for mandatory hooks, so no converge-side change is required. When the bridge is
not installed, no `after_converge` entry exists in the consuming project and converge runs
untouched (FR-009).

**Rationale**:
- The bridge already owns `speckit.superb.verify` as the canonical evidence gate; reusing it via
  a new hook satisfies FR-008 by construction (same command, same evidence requirements).
- Hook declaration in the manifest is the additive, Constitution-III-compliant integration point —
  no edits to `.specify/scripts` or templates.

**Alternatives considered**:
- A new dedicated post-converge command — rejected: duplicates verify, splits the evidence story.
- An `optional` hook — rejected: US2 requires the gate to be unskippable to preserve the
  evidence-first guarantee (Constitution I).

## R5 — Review vs converge responsibility split (US3 / FR-010)

**Decision**: Refocus `superpowers-bridge/commands/review.md` so its verdict is driven by
`tasks.md` quality, TDD-readiness, and plan↔task consistency. Where requirement-coverage gaps are
detected, the command states the gap and delegates task creation to `/speckit-converge` rather
than recommending manual task additions. Document the review (plan-stage prevention) vs converge
(delivery-stage remediation) boundary in the bridge README.

**Rationale**:
- converge now automates "coverage gap → append task" more thoroughly than review's recommend-only
  behavior; keeping both creates redundant, potentially conflicting guidance.
- review's unique, non-replaceable value is task-quality/TDD-readiness/plan-task-mismatch analysis,
  which converge never performs (it trusts `tasks.md` as the source of intent).

**Alternatives considered**:
- Remove `review` entirely — rejected: its quality/TDD gate is unique and valuable.
- Leave `review` unchanged — rejected: perpetuates the documented overlap (#1).

## R6 — Configuration & catalog declarations (US4 / FR-011, FR-013)

**Decision**: (a) Document in both extension READMEs and in `.specify/extensions.yml` comments that
agent-context is an opt-in dependency post-0.12 and that its hooks/assumptions apply only when it
is enabled. (b) Update `catalog.json` `requires.speckit_version` for both extensions to a range
verified against converge and the 0.12 agent-context opt-in, and note converge/agent-context
compatibility in the catalog descriptions/tags.

**Rationale**:
- MemoryLint's R2 fallback already makes it tolerant of agent-context absence; the remaining gap is
  purely informational (stale "always present" assumption in config/docs).
- A declared verified version range removes ambiguity for installers (SC-005).

**Alternatives considered**:
- Programmatically detect enablement at runtime and branch — rejected: MemoryLint already degrades
  gracefully via R2; runtime detection adds complexity for no behavioral gain.

## Cross-cutting: no backward compatibility (FR-014)

Per the directive, the design targets current upstream only. MemoryLint reads the plural
`context_files` (with singular `context_file` accepted because upstream's own writer still accepts
both keys — not a legacy shim). No pre-0.12 default-install assumptions are retained.
