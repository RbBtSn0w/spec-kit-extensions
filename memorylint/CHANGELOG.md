# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- No extension payload changes since `1.3.0`; current unreleased work backfills changelog coverage for historical releases and future release-workflow compatibility.

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

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/memorylint-v1.3.0...HEAD
[1.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.0.0
[1.1.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.1.0
[1.3.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/memorylint-v1.3.0
