# Spec Kit Extensions Roadmap

This roadmap defines the product direction for Spec Kit Extensions after the v1.4.0 planning pass.

## Current Wedge

The current product wedge is **evidence-first completion gates for AI-agent engineering**.

Spec Kit already gives agents a structured path from specification to implementation. The sharp pain this repository should solve first is narrower: AI agents can still claim work is complete without fresh tests, requirement coverage, or durable evidence. These extensions make that claim auditable.

## Strategic Principle

**Governance > Magic**

The product should not promise that agents become smarter by adding more prompts. It should make agent work easier to trust by enforcing small, observable gates:

1. Completion claims must have archived evidence.
2. Requirement drift must be caught before merge.
3. Long-lived agent instructions must stay scoped and non-contradictory.
4. Cross-tool portability comes only after the Spec Kit workflow is reliable.

## ICP

Start with senior developers and small teams already using Spec Kit or agentic coding tools on real repositories.

Do not optimize the first releases for casual vibe-coding demos or broad enterprise governance. Those users may arrive later, but the first proof must come from people who already feel the cost of false completion, requirement drift, and review rework.

## Phase 1: Trustable Completion (P0)

**Goal:** make `/speckit.implement` completion claims auditable.

- **Evidence-Based Archiving:** save spec coverage, test output, build/lint status, timestamp, and commit hash to `.specify/evidence/`.
- **Verified-State Discipline:** write `Verified` only after verification and evidence archiving both succeed.
- **Installer:** reduce local setup friction for the extension collection after users clone the repository.
- **CI Coverage:** keep shell and PowerShell behavior protected by regression tests.

Exit criteria:

- A real feature can move from implementation to `Verified` with a matching evidence artifact.
- Missing checklist, missing test output, or missing matching evidence blocks completion or commit gates.
- The release package declares every script dependency used by its commands.

## Phase 2: Memory Governance (P1)

**Goal:** prevent instruction drift from corrupting future plans.

- **MemoryLint 2.0:** audit `AGENTS.md` and `.specify/memory/constitution.md` for contradictions, redundancy, and obsolete rules.
- **Boundary Preservation:** keep runtime instructions in `AGENTS.md` and architecture/product contracts in the constitution.
- **Planning Guard:** ensure `AGENTS.md` is loaded before plan generation.

Exit criteria:

- MemoryLint produces an actionable semantic audit report.
- It does not directly mutate the constitution; extracted rules remain explicit handoff material.
- The command output is predictable enough to review in PRs.

## Phase 3: Requirement Drift Review (P2)

**Goal:** catch code that passes tests but no longer matches the spec.

- **Semantic Critique:** map changed files back to `spec.md`, `plan.md`, and `tasks.md`.
- **Side-Effect Detection:** call out implementation work that is unrelated to declared requirements.
- **Fix Planning:** produce a small repair plan for drift instead of burying it in prose.

Exit criteria:

- A reviewer can see which requirement each meaningful change satisfies.
- Unmapped behavior is treated as drift until justified or removed.
- Critical drift produces an explicit next-step plan.

## Phase 4: Portable Governance (Deferred)

**Goal:** carry the evidence-first discipline outside Spec Kit only after the Spec Kit loop is proven.

- **Universal Bridge:** keep JSON schemas and portable hooks as an experimental toolkit.
- **Cross-Tool Adapters:** validate one tool at a time, starting with workflows that already support project rules or lifecycle hooks.
- **Extension SDK:** defer until external contributors repeatedly ask to build compatible gates.

Exit criteria:

- At least five real repositories have used Phase 1 gates successfully.
- The portable hook can prove it is checking the active feature, not stale workspace evidence.
- Portability does not weaken the evidence-first contract.

## What Not To Build Yet

- Broad enterprise positioning without real team usage.
- Platform-agnostic abstractions before the Spec Kit workflow is reliable.
- Token heatmaps, dashboards, or analytics that do not directly prove or block completion quality.
- Generic "AI governance" copy that does not name the completion/evidence failure mode.

---

Last updated: May 23, 2026
