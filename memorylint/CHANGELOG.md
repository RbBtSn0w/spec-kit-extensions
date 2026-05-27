# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

<!-- planned-bump: major -->
<!-- next-release-version: 2.0.0 -->

### Added

- `speckit.memorylint.audit` command: read-only, evidence-driven instruction
  drift audit. Produces a structured Drift Report with finding IDs, severity,
  confidence, evidence bindings, and suggested actions.
- Instruction Inventory: full-scan of all long-lived instruction sources
  (AGENTS.md, constitution.md, CLAUDE.md, .cursor/rules/, README, workflows,
  tests) with an output Instruction Map table.
- Four-class drift detection: boundary, reality, conflict, redundancy.
- Eight-category rule classification: infrastructure, architecture, workflow,
  domain, tooling, personal_preference, obsolete, conflict.
- `speckit.memorylint.apply` command with three-tier apply gate:
  `report-only` (default), `apply-safe-fixes`, `apply-all-approved`.
- Pre-apply staleness checks: refuses to apply if instruction files changed
  since the audit report was generated.
- Post-apply validation with automatic rollback on failure: checks AGENTS.md
  integrity, constitution preservation, hook consistency, and repo validation
  commands.
- Trust metrics section in audit report output.
- Regression test suite (`test-memorylint-regressions.sh`).
- Fixture validation suite (`test-fixture-validation.sh`).
- Deterministic fixture scanner (`memorylint/scripts/scan_fixtures.py`) that
  generates findings for the regression corpus and compares them with
  `expected-findings.json`.
- Machine-readable `memorylint-report.json` audit artifact contract for
  apply-safe parsing and staleness checks.
- Nine regression corpus fixtures covering clean, bloated, stale, conflicting,
  redundant, missing-constitution, monorepo, multi-source, and post-apply
  breakage scenarios.
- CI integration for MemoryLint tests.
- Design document for the drift checker architecture.

### Changed

- Replaced `speckit.memorylint.run` with `speckit.memorylint.audit` (read-only)
  and `speckit.memorylint.apply` (gated writes).
- `before_constitution` and `after_constitution` hooks now target `audit`
  instead of `run`.
- Extension description updated to reflect evidence-driven drift checking.
- Rule classification expanded from implicit 2-category (architecture vs
  infrastructure) to explicit 8-category taxonomy.

### Removed

- Removed `speckit.memorylint.run` command and `check-boundaries.md`. Audit
  and apply are now separate commands with distinct safety properties.

## [1.4.0] - 2026-05-24
### Changed

- Added semantic audit instructions to `speckit.memorylint.run` for contradiction, redundancy, and obsolescence reporting.
- Added an optional `after_constitution` hook that can re-run MemoryLint after constitution generation.
- Kept `extension.version` at `1.3.0` until the release workflow publishes the next version.

## [1.3.0] - 2026-04-16

### Changed

- Hardened `speckit.memorylint.load-agents` with an explicit fail-fast rule when `AGENTS.md` is missing, unreadable, or cannot be loaded from the workspace root.
- Expanded the README workflow narrative to show the mandatory `before_plan` gate and its planning-time enforcement.
- Updated the published install example and documented the raised minimum Spec Kit requirement to `>=0.5.1`.

## [1.1.0] - 2026-04-11

### Added

- Added `speckit.memorylint.load-agents` as a mandatory planning gate that loads `AGENTS.md` before Spec Kit generates `plan.md` or `tasks.md`.

### Changed

- Documented the new `before_plan` hook and clarified how the planning flow inherits workspace rules from `AGENTS.md`.

## [1.0.0] - 2026-04-09

### Added

- Initial release of MemoryLint for auditing boundary conflicts between `AGENTS.md` and `.specify/memory/constitution.md`.
- Added the `speckit.memorylint.run` command and optional `before_constitution` hook for bidirectional governance of agent memory files.
- Included installation and usage documentation for the first published package.

---

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/memorylint-v1.4.0...HEAD
[1.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.0.0
[1.1.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.1.0
[1.3.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.3.0
[1.4.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.4.0
