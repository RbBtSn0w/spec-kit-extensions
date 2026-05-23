# Technical Plan: Semantic Critique (Phase 3)

## Problem
Standard code review often misses "requirement drift" — code that works but doesn't align with the original `spec.md`.

## Proposed Solution
Enhance `/speckit.superb.critique` to perform a rigorous mapping between code diffs and spec requirements.

### Features
- **Requirement Mapping**: Every changed line must be linked to a requirement in `spec.md`.
- **Side-Effect Analysis**: Detection of "hidden" changes that weren't in the plan.
- **Auto-Plan for Fixes**: If a critique fails, automatically generate a `plan.md` to fix the identified drift.
