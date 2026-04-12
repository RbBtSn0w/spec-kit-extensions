# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New features and improvements that are not yet released.

## [2.0.0] - 2026-04-12

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
- Because this release removes a previously supported hook/command path, the next published release should be treated as `2.0.0`.

## [1.0.0] - 2026-03-30

### Added

- Initial release for remote repository (`github.com/RbBtSn0w/spec-kit-extensions`).
- Standalone command: `/speckit.superb.debug`
- Standalone command: `/speckit.superb.finish`
- Standalone command: `/speckit.superb.respond`
- Standalone command: `/speckit.superb.critique`
- Hookable command: `/speckit.superb.clarify`
- Hookable command: `/speckit.superb.tdd`
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

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/superpowers-bridge-v2.0.0...HEAD
[2.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v2.0.0
[1.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.0.0
