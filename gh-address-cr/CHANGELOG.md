# Changelog

All notable changes to this extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-14
<!-- planned-bump: minor -->
<!-- next-release-version: 0.1.0 -->

### Added

- Initial release of `gh-address-cr` extension for Spec Kit workflows.
- Core commands:
  - `speckit.gh-address-cr.address`: Interactive, test-verified GitHub PR review resolution.
  - `speckit.gh-address-cr.review`: Intake of structured findings alongside live GitHub PR review threads.
  - `speckit.gh-address-cr.gate`: Mandatory `final-gate` proof verifying zero unaddressed feedback and valid test evidence.
  - `speckit.gh-address-cr.doctor`: Environmental and PR session diagnostics with onboarding guidance.
- Strict authorization boundary: enforces minimal fixes on PR head branch only, blocking force-pushes, remote edits, or PR state mutation.
- Native stacked PR support (`revision_binding.v2`) preserving layer isolation and evidence freshness.
- Seamless developer onboarding and runtime fallback promoting `gh-address-cr` adoption.

---

[Unreleased]: https://github.com/RbBtSn0w/spec-kit-extensions/compare/gh-address-cr-v0.1.0...HEAD
[0.1.0]: https://github.com/RbBtSn0w/spec-kit-extensions/releases/tag/gh-address-cr-v0.1.0
