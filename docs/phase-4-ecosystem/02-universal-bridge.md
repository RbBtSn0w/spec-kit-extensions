# Technical Plan: Universal Bridge (Phase 4)

## Problem
The "discipline" and "governance" logic is currently locked into the `Spec Kit` / `specify` ecosystem.

## Proposed Solution
Abstract the core SDD enforcement logic into a platform-agnostic library or CLI tool that can be called by other AI editors (Cursor, Windsurf, etc.).

### Features
- **SDD Protocol**: A JSON schema for specs, plans, and evidence.
- **Portable Hooks**: Standalone scripts that can be integrated into `pre-commit` or CI pipelines regardless of the AI orchestrator.
