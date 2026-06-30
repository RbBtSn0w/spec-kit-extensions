# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.8.0] - 2026-06-30
### Added

- Mandatory `after_converge` hook running `speckit.superb.verify`, so work produced by upstream
  `/speckit-converge` passes the evidence-first gate before it can be declared complete
  (`implement → converge → implement → verify`).

### Changed

- `review` now delegates requirement-coverage-gap remediation to `/speckit-converge` instead of
  recommending manual task additions, and focuses its own verdict on task quality, TDD-readiness,
  and plan↔task consistency. README documents the `review` (plan-stage) vs `converge`
  (delivery-stage) boundary.
- Declared Spec Kit compatibility raised to `>=0.12.0`.

## [1.7.0] - 2026-06-30
<!-- planned-bump: minor -->
<!-- next-release-version: 1.7.0 -->

### Added

- Added centralized missing skill guidance and installation orchestration in `ensure-skills.sh`, plus installation-agnostic skill discovery in `resolve-skill.sh`.
- Added interactive `npx` checking, Quick Setup impact groupings (Hard Requirements vs Optional Skills), and prompt selection execution in `/speckit.superb.check`.
- Added sandboxed HOME E2E installation test.

## [1.6.1] - 2026-06-16
### Removed

- Removed the external `code-review` skill dependency from `check.md` diagnostics and `controller.md` Multi-Agent SDD Layer 2 fallback to maintain a pure Superpowers identity.

## [1.6.0] - 2026-06-07
<!-- planned-bump: minor -->
<!-- next-release-version: 1.6.0 -->

### Added

- Added mandatory `plan-gate` command and `after_plan` hook to verify task list granularity and prevent placeholder leakage.
- Integrated `subagent-driven-development` (SDD) orchestration logic (Controller-Worker-Reviewer pattern) into the TDD implementation gate (`controller.md`).
- Supported concurrent subagent dispatch for tasks marked with `[P]`.
- Implemented stateful `discoveries.md` log propagation across worker subagents for isolated context implementation.

## [1.5.2] - 2026-06-05
### Changed

- Changed `/speckit.superb.verify` evidence capture to write run-local files in
  the system temporary directory instead of creating project files under
  `.specify/evidence/`.
- Updated the Universal Bridge pre-commit hook so `Verified` specs require
  completed tasks but no longer require repository-stored evidence files.

## [1.5.1] - 2026-06-04

### Fixed

- Updated `/speckit.superb.review` to emit a stable workflow decision block that
  routes passing, blocked, inconclusive, missing-artifact, and abandoned-feature
  outcomes to the correct next Spec Kit command or user approval gate.

## [1.5.0] - 2026-05-27
### Added

- Added optional `/speckit.superb.brainstorm` after-specify refinement hook for
  applying installed Superpowers `brainstorming` discipline to the active Spec
  Kit `spec.md`.

### Changed

- Clarified the Superpowers gap map: `requesting-code-review` is represented by
  `critique`/`respond`, `dispatching-parallel-agents` informs `debug`, and
  `writing-plans` informs task-quality checks in `review`.
- Added a Superpowers-to-Superpowers Bridge mapping matrix documenting direct
  bridges, borrowed disciplines, non-exposed workflow skills, and Spec Kit
  stage integration.
- Clarified the autonomous agent execution contract for required hooks,
  optional hooks, manual commands, and borrowed disciplines.
- Reframed the open-source product positioning around selected Superpowers
  disciplines delivered as evidence-first trust gates for Spec Kit agent
  workflows, including ICP and first-success adoption guidance.
- Documented the naming hierarchy for `Superpowers Bridge`,
  `superpowers-bridge`, and the `superb` command namespace.
- Documented the Goal mode prompt pattern for opting into optional superb hooks
  while preserving the baseline required/optional policy.
- Expanded bridge diagnostics and configuration templates for optional
  Superpowers discipline skills without changing hard requirements.

## [1.4.0] - 2026-05-24
### Added

- Added evidence archiving scripts for Bash and PowerShell so `/speckit.superb.verify` can persist verification output under `.specify/evidence/`.
- Added regression coverage for evidence archive creation, missing checklist/test output, missing separators, and invalid build statuses.

### Changed

- Updated `/speckit.superb.verify` so `Verified` status synchronization happens only after evidence archiving succeeds.
- Tightened `/speckit.superb.critique` around requirement mapping, side-effect detection, and fix-plan generation for critical drift.
- Wired evidence archive tests into CI.

## [1.3.0] - 2026-04-16
### Changed

- No extension payload changes since `1.1.0`; current unreleased work only corrects release metadata wording for the existing bridge package.

## [1.1.0] - 2026-04-16

### Changed

- Repositioned Superpowers Bridge as a Spec Kit enhancement layer instead of a workflow replacement
- Added `speckit.superb.check` for local superpowers skill discovery and readiness diagnostics
- Updated command docs to bridge installed local skills from workspace/global roots instead of remote or embedded fallbacks
- Narrowed `speckit.superb.review` to task coverage and TDD-readiness checks
- Clarified which capabilities are bridge-native versus superpowers-adapted
- Added bridge-owned `spec.md` status synchronization for observable lifecycle states: `Tasked`, `Implementing`, `Verified`, `In Review`, and `Abandoned`
- Explicitly excluded `Completed` from the current bridge status model because GitHub merge completion is outside the current hook surface

### Removed

- Removed the `before_specify` clarify bridge from the official hook surface

### Upgrade Notes

- Users upgrading from `1.0.0` must stop relying on the `before_specify` clarify bridge and migrate to the remaining supported hook surface.
- This release removes a previously supported hook/command path; treat upgrades from `1.0.0` as a breaking change even though the published tag is `1.1.0`.

## [1.0.0] - 2026-03-30

### Added

- Initial release for remote repository (`github.com/RbBtSn0w/spec-kit-extensions`).
- Standalone command: `/speckit.superb.debug`
- Standalone command: `/speckit.superb.finish`
- Standalone command: `/speckit.superb.respond`
- Standalone command: `/speckit.superb.critique`
- Hookable command: `/speckit.superb.clarify`
- Hookable command: `/speckit.superb.controller`
- Hookable command: `/speckit.superb.review`
- Hookable command: `/speckit.superb.verify`
- TDD escalation guidance to invoke debug protocol after repeated failed fixes

### Changed

- Refactored bridge commands to thin-orchestration model that loads authoritative superpowers SKILL.md at runtime where applicable
- Updated extension metadata and catalog alignment for command count expansion

### Requirements

- Spec Kit: `>=0.4.3`
- Optional tool: `superpowers >=5.0.0`

---

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/superpowers-bridge-v1.8.0...HEAD
[1.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.0.0
[1.1.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.1.0
[1.3.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.3.0
[1.4.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.4.0
[1.5.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.5.0
[1.5.1]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.5.1
[1.5.2]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.5.2
[1.6.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.6.0
[1.6.1]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.6.1
[1.7.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.7.0
[1.8.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.8.0
