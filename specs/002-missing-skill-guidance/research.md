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
1. **Recommended**: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` — installs only the 11 required/optional superpowers skills as a plugin bundle
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
   Recommended:  npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y
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

## Decision 5: Post-Install Re-Check Implementation

**Decision**: After `adg` installation completes, re-run the same discovery logic used by the `check` command (scan `./.agents/skills/` and `~/.agents/skills/` for each of the 11 skills) and display an updated Skill Status table.

**Rationale**: Reuses existing detection logic. Shows MISSING → READY transitions immediately, providing evidence-based confirmation (aligns with Constitution Principle I: Evidence-First Completion).

**Alternatives considered**:
- Trust `adg` exit code only — doesn't verify skills landed in the expected discovery roots
- Full `/speckit-superb-check` re-invocation — heavier; the status table alone is sufficient

## Decision 6: Three Failure Modes and Guidance Strategy

**Decision**: Guidance insertion strategy varies by the command's failure mode:

| Failure Mode | Commands | Guidance Behavior |
|-------------|----------|-------------------|
| **Hard-STOP** (blocks main flow) | `controller`, `verify` | Show guidance + offer install prompt; remain BLOCKED until resolved |
| **Soft-STOP** (disables standalone command) | `debug`, `finish`, `brainstorm`, `respond` | Show guidance + offer install prompt; command remains unavailable |
| **Graceful degradation** (Layer 2 fallback) | Commands using `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents` | Show guidance as informational note; command proceeds with degraded capability |

**Rationale**: Matches the existing Dual-Layer Fallback architecture. Guidance severity is proportional to impact.

**Alternatives considered**:
- Uniform guidance for all modes — loses important context about what's actually blocked vs. degraded
