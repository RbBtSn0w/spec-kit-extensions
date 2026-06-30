# Implementation Plan: Missing Skill Installation Guidance

**Branch**: `002-missing-skill-guidance` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/002-missing-skill-guidance/spec.md`

## Summary

Add installation guidance and interactive auto-installation to the superpowers-bridge extension when missing skills are detected. Currently, bridge commands report skills as "MISSING" or "UNAVAILABLE" but provide no resolution path. This feature extends the `check` command with a "Quick Setup" section offering three `adg`-based installation approaches (plugins recommended, global skills, project skills), adds inline guidance to every command that detects a missing dependency, pre-detects `npx` availability to offer interactive auto-install with user confirmation, and automatically re-checks skill status after installation.

## Technical Context

**Language/Version**: Markdown command definitions (bridge-native); Bash scripts for shell helpers

**Primary Dependencies**: `adg` CLI (`https://github.com/RbBtSn0w/adg`) via `npx`; Spec Kit extension framework (schema_version 1.0)

**Storage**: N/A — no persistent state; skill detection is filesystem-based (`./.agents/skills/` and `~/.agents/skills/`)

**Testing**: Bash test scripts (`superpowers-bridge/tests/test-*.sh`), PowerShell tests (`test-*.ps1`)

**Target Platform**: macOS, Linux (any system with Node.js/npx for auto-install; manual guidance works everywhere)

**Project Type**: Spec Kit extension (Markdown command definitions + shell scripts)

**Performance Goals**: N/A — one-time diagnostics/installation flow

**Constraints**: No remote fetches during normal bridge operation; `adg` invocation only on explicit user confirmation; guidance must render as valid Markdown in terminals

**Scale/Scope**: 10 existing command files to update with inline guidance; 1 check command to extend with Quick Setup section; 1 new helper script for npx detection + adg invocation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Evidence-First Completion | ✅ PASS | Post-install re-check provides evidence that skills transitioned to READY |
| II. Unobtrusive Bridging | ✅ PASS | Guidance extends existing Markdown output; no new artifacts or competing state |
| III. Additive Extensions | ✅ PASS | Changes are within extension boundary; no edits to `.specify/scripts/` or `.specify/templates/` |
| IV. Test-Driven Development | ✅ PASS | New test scripts will validate guidance output and npx detection |
| V. Granular Implementation Control | ✅ PASS | Each command update is atomic and independently testable |
| VI. Bridge-Native Subagent Orchestration | N/A | Not applicable — this feature is user-facing guidance, not subagent orchestration |

## Project Structure

### Documentation (this feature)

```text
specs/002-missing-skill-guidance/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
superpowers-bridge/
├── commands/
│   ├── check.md             # MODIFY — add Quick Setup section, per-skill guidance, install prompt
│   ├── brainstorm.md        # MODIFY — add inline guidance on missing skill
│   ├── controller.md        # MODIFY — add inline guidance on missing hard requirements
│   ├── critique.md          # MODIFY — add inline guidance (bridge-native, no external skill dep)
│   ├── debug.md             # MODIFY — add inline guidance on missing systematic-debugging
│   ├── finish.md            # MODIFY — add inline guidance on missing finishing-a-development-branch
│   ├── plan-gate.md         # MODIFY — add inline guidance (bridge-native, minimal changes)
│   ├── respond.md           # MODIFY — add inline guidance on missing receiving-code-review
│   ├── review.md            # MODIFY — add inline guidance (bridge-native, minimal changes)
│   └── verify.md            # MODIFY — add inline guidance on missing verification-before-completion
├── scripts/
│   └── bash/
│       └── install-skills.sh    # NEW — npx detection, adg invocation, post-install re-check
├── tests/
│   ├── test-install-guidance.sh # NEW — validate check output includes guidance for missing skills
│   └── test-npx-detection.sh   # NEW — validate npx pre-detection and fallback behavior
├── extension.yml            # MODIFY — bump version, add install-skills command if needed
├── superb-config.template.yml  # NO CHANGE — skill lists already defined here
└── README.md                # MODIFY — document the new installation guidance feature
```

**Structure Decision**: This feature is additive within the existing `superpowers-bridge/` extension directory. No new top-level directories. One new bash script for the installation flow, two new test scripts, and updates to all 10 existing command files.

## Complexity Tracking

No constitution violations. Table not needed.
