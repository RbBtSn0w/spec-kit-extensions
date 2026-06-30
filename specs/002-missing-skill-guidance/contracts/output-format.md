# Contract: Installation Guidance Output Format

**Feature**: [spec.md](../spec.md) | **Date**: 2026-06-30

This document defines the output contracts for installation guidance blocks emitted by bridge commands. All output is plain-text Markdown.

## 1. Per-Skill Inline Guidance Block

Emitted by individual bridge commands when a required skill is missing. Appended to the existing error message.

### Template

```markdown
ERROR: [Required|Optional] superpowers skill `<skill-name>` not found.

💡 Install via adg (https://github.com/RbBtSn0w/adg):
   Recommended:  npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g
   Global:       npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y
   Project:      npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y

Run /speckit.superb.check for full diagnostics and interactive installation.
```

### Rules

- First line preserves the existing error format exactly (backward compatible)
- Blank line separates the error from the guidance
- `💡` emoji prefix for visual scan-ability; fallback to `>` blockquote if emoji not supported
- Three approaches listed in priority order (recommended first)
- Always ends with a pointer to the `check` command for full diagnostics
- If `npx` is available, the command must next ask:
  `Would you like to install now? (Select approach 1-3, or skip)`
- The command may run `ensure-skills.sh --install <selection>` only after explicit
  user confirmation, then must re-run the missing skill resolution once before proceeding
  or blocking.
- If the command is in **graceful degradation** mode (Layer 2 fallback available), use `NOTE` instead of `ERROR`:

```markdown
NOTE: Optional superpowers skill `<skill-name>` not installed. Running with local fallback.

💡 For enhanced behavior, install via adg (https://github.com/RbBtSn0w/adg):
   Recommended:  npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g
   Global:       npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y
   Project:      npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y
```

## 2. Check Command: Skill Status Table Extension

The existing Skill Status table in the `check` command output gains a new `Guidance` column.

### Template

```markdown
## Skill Status

| Skill | Required | Source | Path | Status | Guidance |
|-------|----------|--------|------|--------|----------|
| test-driven-development | Hard | workspace | ./.agents/skills/test-driven-development/SKILL.md | READY | — |
| verification-before-completion | Hard | — | — | MISSING | Install via `adg` |
| brainstorming | Optional | — | — | MISSING | Install via `adg` |
| ... | ... | ... | ... | ... | ... |
```

### Rules

- `Guidance` column shows `—` for READY skills and `Install via \`adg\`` for MISSING skills
- The table itself does not contain full install commands (those go in the Quick Setup section)

## 3. Check Command: Quick Setup Section

Appended after the standard check output when any skills are MISSING.

### Template (npx available)

```markdown
## Quick Setup

Missing skills can be installed via [adg](https://github.com/RbBtSn0w/adg):

### ⚠️ Hard Requirements (blocking)

| Skill | Impact |
|-------|--------|
| `test-driven-development` | Blocks `before_implement` hook |
| `verification-before-completion` | Blocks `after_implement` hook |

### Optional Skills (recommended)

| Skill | Impact |
|-------|--------|
| `brainstorming` | Disables `/speckit-superb-brainstorm` |
| `systematic-debugging` | Disables `/speckit.superb.debug` |
| ... | ... |

### Installation

Choose one approach to install all missing skills:

| # | Approach | Command |
|---|----------|---------|
| 1 | **Recommended** (plugin bundle) | `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g` |
| 2 | Global skills | `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y` |
| 3 | Project skills | `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` |

Would you like to install now? (Select approach 1-3, or skip)
```

### Template (npx NOT available)

```markdown
## Quick Setup

Missing skills can be installed via [adg](https://github.com/RbBtSn0w/adg):

### ⚠️ Hard Requirements (blocking)

[same table as above]

### Optional Skills (recommended)

[same table as above]

### Installation

`npx` was not detected. Install Node.js first, or manually install skills:

1. Visit https://github.com/RbBtSn0w/adg for setup instructions
2. Run: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g` (recommended)

Alternatively, clone the superpowers repository directly:
  `git clone https://github.com/obra/superpowers.git`
  Then copy skill directories to `./.agents/skills/`, `~/.agents/skills/`, or a plugin directory under `./.agents/plugins/` / `~/.agents/plugins/` that exposes `skills/<name>/SKILL.md`
```

## 4. Post-Install Re-Check Output

Displayed after successful auto-installation to show transitions.

### Template

```markdown
## Post-Install Verification

| Skill | Before | After |
|-------|--------|-------|
| test-driven-development | MISSING | ✅ READY |
| verification-before-completion | MISSING | ✅ READY |
| brainstorming | MISSING | ✅ READY |
| ... | ... | ... |

**Result**: [N] of [M] previously missing skills now READY.
**Updated Verdict**: [READY / PARTIAL / BLOCKED]
```

### Rules

- Only shows skills that were previously MISSING
- Uses ✅ prefix for newly READY skills
- Shows remaining MISSING skills without emoji
- Includes updated verdict reflecting current state

## 5. resolve-skill.sh Script Contract

### Input

| Argument | Required | Description |
|----------|----------|-------------|
| `--skill` | Yes | Canonical superpowers skill name to resolve |

### Output (stdout, JSON)

```json
{
  "available": true,
  "skill": "brainstorming",
  "source": "workspace",
  "install_type": "plugin",
  "path": "/abs/path/.agents/plugins/vendor__pack/superpowers/skills/brainstorming/SKILL.md"
}
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Skill found and resolved |
| 1 | Skill not found in any supported discovery root |
| 2 | Invalid arguments |

## 6. ensure-skills.sh Script Contract

### Input

| Argument | Required | Description |
|----------|----------|-------------|
| `--install` | No | `1` (plugins), `2` (global skills), or `3` (project skills) |
| `--check-prereqs` | No | If set, only run npx detection; do not install |
| `--print-guidance` | No | If set, print the canonical guidance block without side effects |

### Output (stdout, JSON when `--check-prereqs`)

```json
{
  "npx_available": true,
  "npx_path": "/opt/homebrew/bin/npx"
}
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Check or installation completed successfully |
| 1 | Installation failed (adg error) |
| 2 | `npx` not available |
| 3 | Invalid arguments |
