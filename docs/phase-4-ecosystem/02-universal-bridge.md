# Technical Plan: Universal Bridge (Phase 4, Deferred)

## Problem

The evidence-first discipline should eventually work outside Spec Kit, but portability is not the first product proof. Cross-tool support can easily become adapter work before the core gate is proven.

## Current Status

`universal-bridge/` is an experimental toolkit, not a published Spec Kit extension. It currently contains:

- JSON schemas for specs, plans, and evidence;
- a portable `pre-commit-sdd` hook;
- tests for the hook behavior.

## Proposed Direction

Keep Universal Bridge behind the Spec Kit wedge until the repository proves that evidence-first completion gates are useful in real projects.

## Non-Goals For Now

- Do not position this as enterprise-ready governance.
- Do not add adapters for every AI editor at once.
- Do not loosen evidence checks to make portability easier.

## Verification Before Promotion

Universal Bridge can become a first-class product surface only after:

- the hook verifies evidence for the active feature rather than any stale artifact;
- CI runs the hook tests;
- at least one non-Spec-Kit workflow uses it successfully without weakening the evidence contract.
