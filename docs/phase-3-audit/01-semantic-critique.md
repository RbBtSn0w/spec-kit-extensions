# Technical Plan: Semantic Critique (Phase 3)

## Problem

Code can pass tests and still drift from `spec.md`, `plan.md`, or `tasks.md`. This is especially common when agents make convenient side changes while implementing a requested feature.

## Product Boundary

`speckit.superb.critique` should be a review gate, not an autonomous rewrite agent. It identifies drift and produces a repair plan; it does not silently edit code.

## Proposed Solution

Enhance the critique command to:

- map meaningful code changes to requirements or tasks;
- call out unmapped side effects;
- classify issues as Critical, Important, or Minor;
- produce a small fix plan when critical drift blocks progress.

## Verification

- The command prompt resolves a concrete base ref before diffing.
- The review output contains a requirement/code mapping table.
- Critical drift requires a repair plan before further implementation work.
