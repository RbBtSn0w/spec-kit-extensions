# Research: Missing Skill Installation Guidance

**Feature**: [spec.md](./spec.md) | **Date**: 2026-06-30

## Decision 1: `adg` CLI Invocation Method

**Decision**: Use `npx adg` for auto-installation — confirmed working via direct testing.

**Rationale**: `npx adg --help` executes successfully without prior global installation. The `adg` package is published on npm and `npx` resolves it on-the-fly. This removes the need for users to pre-install `adg` globally.

**Alternatives considered**:
- Global install (`npm install -g adg`) — adds a manual prerequisite step
- Direct git clone of superpowers repo — bypasses `adg`'s skill-agent linking logic

**Evidence**:
```
$ npx adg --help
adg — Agent Directory Group toolkit
...
$ npx adg skills --help
Usage: skills <command> [options]
  add <package>        Add a skill package
...
$ npx adg plugins --help
adg plugins — manage agent plugins
  add            install plugins from a source
...
```

## Decision 2: Three Installation Approaches

**Decision**: Offer three approaches in priority order:
1. **Recommended**: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g` — installs only the 11 required/optional superpowers skills as a plugin bundle, globally, and matches the current plugin-install contract
2. **Alternative (global)**: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y` — installs only the 11 skills globally
3. **Alternative (project)**: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` — installs only the 11 skills at project level

**Rationale**: Explicitly listing the 11 required/optional skills via `--skill` ensures we don't pull unneeded/unrelated skills from the repository, maintaining scope control and minimizing workspace pollution.

**Alternatives considered**:
- Installing all skills in the repository — rejected because it introduces unnecessary files and potential runtime manifest pollution.

## Decision 3: Uniform Error Message Pattern

**Decision**: Extend the existing uniform error message template used by all commands:
```
ERROR: [Required|Optional] superpowers skill `<skill-name>` not found.
Run /speckit.superb.check for diagnostics.
```
to:
```
ERROR: [Required|Optional] superpowers skill `<skill-name>` not found.

💡 Install via adg (https://github.com/RbBtSn0w/adg):
   Recommended:  npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g
   Global:       npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y
   Project:      npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y

Run /speckit-superb-check for full diagnostics and interactive installation.
```

**Rationale**: Preserves backward compatibility (existing error line unchanged), adds actionable guidance below. All 10 command files share the same pattern, so the extension is mechanical and consistent.

**Alternatives considered**:
- Centralized guidance in a separate guidance template file — adds indirection; inline is simpler for Markdown command definitions
- Linking to README only — not actionable enough; users want copy-pasteable commands

## Decision 4: npx Pre-Detection Strategy

**Decision**: Use `command -v npx` (POSIX-compatible) to detect `npx` availability before offering interactive auto-install.

**Rationale**: `command -v` is the most portable way to check for command availability in bash. No need to check npm or Node.js separately — if `npx` is in PATH, it will work.

**Alternatives considered**:
- `which npx` — not POSIX-standard, may not exist on all systems
- `npx --version` — heavier; spawns a process just to check availability
- No pre-detection (try and catch) — user rejected this in clarification (Q4)

**Current adg contract note**: Local verification on 2026-06-30 showed that `adg plugins add` accepts `-g` but rejects `-y`, while `adg skills add` still documents and recommends `-y`. The bridge therefore keeps `-y` only on the skills-based approaches.

## Decision 5: Post-Install Re-Check Implementation

**Decision**: After `adg` installation completes, re-run the same canonical discovery logic used by the `check` command and bridge commands. That discovery is installation-mechanism agnostic and scans direct skill roots plus plugin-provided skill directories in workspace scope before global scope.

**Rationale**: Reuses a single detection model everywhere. This avoids coupling runtime availability to `adg`-specific assumptions and correctly handles both `adg skills add` and `adg plugins add` outputs. It shows MISSING → READY transitions immediately, providing evidence-based confirmation (aligns with Constitution Principle I: Evidence-First Completion).

**Alternatives considered**:
- Trust `adg` exit code only — doesn't verify skills landed in the expected discovery roots
- Full `/speckit-superb-check` re-invocation — heavier; the status table alone is sufficient

## Decision 6: Split Discovery From Installation Orchestration

**Decision**: Expose two helper scripts with distinct responsibilities:
- `resolve-skill.sh` for read-only filesystem discovery of a named skill
- `ensure-skills.sh` for `npx` prerequisite checks, guidance rendering, and explicit `adg` installation

**Rationale**: A script named `install-skills` should not be the primary API for read-only operations. Separating discovery from installation reduces semantic ambiguity for downstream commands and keeps the bridge's runtime model independent from the chosen installer.

## Decision 7: Three Failure Modes and Guidance Strategy

**Decision**: Guidance insertion strategy varies by the command's failure mode:

| Failure Mode | Commands | Guidance Behavior |
|-------------|----------|-------------------|
| **Hard-STOP** (blocks main flow) | `controller`, `verify` | Show guidance + offer install prompt; remain BLOCKED until resolved |
| **Soft-STOP** (disables standalone command) | `debug`, `finish`, `brainstorm`, `respond` | Show guidance + offer install prompt; command remains unavailable |
| **Graceful degradation** (Layer 2 fallback) | Commands using `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents` | Show guidance as informational note; command proceeds with degraded capability |

**Rationale**: Matches the existing Dual-Layer Fallback architecture. Guidance severity is proportional to impact.

**Alternatives considered**:
- Uniform guidance for all modes — loses important context about what's actually blocked vs. degraded
