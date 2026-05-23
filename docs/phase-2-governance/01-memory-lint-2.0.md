# Technical Plan: MemoryLint 2.0 (Phase 2)

## Problem

`MemoryLint` already helps keep architecture rules out of `AGENTS.md` and in `.specify/memory/constitution.md`. The next risk is subtler: long-lived instructions can become contradictory, redundant, or obsolete while still looking useful.

## Product Boundary

MemoryLint is a secondary governance layer behind evidence-first completion. It should protect future plans from instruction drift, but it should not replace code review, verification, or the constitution.

## Proposed Solution: Semantic Audit

Extend `speckit.memorylint.run` so it reports:

- **Conflict Detection:** instructions that contradict each other.
- **Redundancy Pruning:** rules that say the same thing in different words.
- **Obsolescence Checks:** rules that reference tools, files, or workflows no longer present in the repository.

## Implementation Path

- Update `memorylint/commands/check-boundaries.md` with semantic audit instructions.
- Add an optional `after_constitution` hook that re-runs the audit after constitution generation.
- Keep `.specify/memory/constitution.md` mutation outside MemoryLint; extracted rules remain explicit handoff material.

## Verification

- Command output includes extracted rules, AGENTS.md enhancements, and semantic audit sections.
- Hook metadata declares `after_constitution` without changing the published `extension.version` before release.
- README and changelog describe the unreleased hook behavior.
