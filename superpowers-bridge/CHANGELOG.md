# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Optional alias-surface simplification based on command-usage feedback
- Additional docs/examples for standalone command chaining

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

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/superpowers-bridge-v1.0.0...HEAD
[1.0.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/superpowers-bridge-v1.0.0
