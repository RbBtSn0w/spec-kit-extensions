# Data Model: Missing Skill Installation Guidance

**Feature**: [spec.md](./spec.md) | **Date**: 2026-06-30

## Entities

### Skill

A superpowers discipline represented as a filesystem artifact.

| Attribute | Type | Description |
|-----------|------|-------------|
| name | string | Canonical skill name (e.g., `test-driven-development`) |
| requirement_level | enum: `hard` \| `optional` | Whether missing skill blocks the main flow or only reduces capability |
| discovery_source | enum: `workspace` \| `global` \| `none` | Where the skill was found (or `none` if missing) |
| install_type | enum: `skill-root` \| `plugin` \| `none` | Whether the resolved skill came from a direct skill root or a plugin-provided skills directory |
| path | string \| null | Resolved absolute path to `SKILL.md`, or null if missing |
| status | enum: `READY` \| `MISSING` | Availability status after discovery |

**Discovery rules**:
- Workspace direct root: `./.agents/skills/<name>/SKILL.md`
- Workspace plugin roots: `./.agents/plugins/*/skills/<name>/SKILL.md` and `./.agents/plugins/*/*/skills/<name>/SKILL.md`
- Global direct root: `~/.agents/skills/<name>/SKILL.md`
- Global plugin roots: `~/.agents/plugins/*/skills/<name>/SKILL.md` and `~/.agents/plugins/*/*/skills/<name>/SKILL.md`
- Workspace wins over global when both exist
- Within the same scope, direct skill-root installs win over plugin-provided skills

### Skill Registry (static, from config)

The 11 known superpowers skills referenced by the bridge:

| Name | Requirement Level | Used By |
|------|-------------------|---------|
| `test-driven-development` | hard | controller, verify (indirect) |
| `verification-before-completion` | hard | verify |
| `brainstorming` | optional | brainstorm |
| `systematic-debugging` | optional | debug |
| `receiving-code-review` | optional | respond |
| `finishing-a-development-branch` | optional | finish |
| `dispatching-parallel-agents` | optional | debug (discipline) |
| `requesting-code-review` | optional | critique (discipline) |
| `writing-plans` | optional | review (discipline) |
| `executing-plans` | optional | controller (mode selection) |
| `subagent-driven-development` | optional | controller (mode selection) |

### Installation Approach

One of three supported methods for installing skills via `adg`.

| Attribute | Type | Description |
|-----------|------|-------------|
| label | string | User-facing label (`Recommended`, `Global`, `Project`) |
| command | string | Full CLI command string |
| priority | int | Display order (1 = recommended, 2 = global, 3 = project) |

**Static values**:

| Priority | Label | Command |
|----------|-------|---------|
| 1 | Recommended | `npx adg plugins add obra/superpowers -g` |
| 2 | Global | `npx adg skills add obra/superpowers --global -y` |
| 3 | Project | `npx adg skills add obra/superpowers -y` |

### Installation Guidance Block

A structured text fragment embedded in command output when skills are missing.

| Attribute | Type | Description |
|-----------|------|-------------|
| skill_name | string | The missing skill's canonical name |
| requirement_level | enum | `hard` or `optional` |
| adg_url | string (constant) | `https://github.com/RbBtSn0w/adg` |
| approaches | list\<InstallationApproach\> | The three installation methods |
| is_blocking | boolean | Whether this missing skill blocks the current operation |

### Discovery Helper

Read-only helper contract used by commands and diagnostics to resolve one skill.

| Attribute | Type | Description |
|-----------|------|-------------|
| script_name | string | `resolve-skill.sh` |
| input_skill | string | Requested skill name |
| output_available | boolean | Whether a readable `SKILL.md` was found |
| output_source | enum | `workspace`, `global`, or `none` |
| output_install_type | enum | `skill-root`, `plugin`, or `none` |
| output_path | string \| null | Resolved absolute path when available |

### Ensure Helper

Installation-oriented helper contract used only after a missing-skill condition is established.

| Attribute | Type | Description |
|-----------|------|-------------|
| script_name | string | `ensure-skills.sh` |
| operation | enum | `check-prereqs`, `print-guidance`, `install` |
| approach | int \| null | `1`, `2`, or `3` when operation is `install` |
| side_effects | enum | `none` for check/guidance, `installs` for install |

### Quick Setup Summary

Aggregated guidance block for the `check` command when multiple skills are missing.

| Attribute | Type | Description |
|-----------|------|-------------|
| missing_hard | list\<Skill\> | Missing hard-requirement skills |
| missing_optional | list\<Skill\> | Missing optional skills |
| npx_available | boolean | Whether `npx` was detected in PATH |
| approaches | list\<InstallationApproach\> | The three installation methods |

## State Transitions

### Skill Status Lifecycle

```
MISSING ──[user confirms install]──> INSTALLING ──[adg succeeds]──> READY
                                                  ──[adg fails]───> MISSING (with error note)
```

Note: `INSTALLING` is a transient state during the auto-install flow, not persisted.

### Check Command Output Flow

```
Start
  │
  ├─ Detect all 11 skills → build status table
  │
  ├─ Any MISSING?
  │   ├─ No  → show "All skills READY" verdict
  │   └─ Yes → show status table with per-skill guidance
  │            │
  │            ├─ Detect npx via ensure helper
  │            │   ├─ Available → show Quick Setup with install prompt
  │            │   │               │
  │            │   │               ├─ User confirms → execute adg → re-check → show updated table
  │            │   │               └─ User declines → show manual guidance only
  │            │   │
  │            │   └─ Not available → show manual guidance with adg URL only
  │            │
  │            └─ Show verdict (BLOCKED / PARTIAL)
  │
  End
```

## Relationships

```
Skill Registry (static config)
    │
    ├── 1:N ── Skill (runtime discovery result)
    │              │
    │              └── 1:1 ── Installation Guidance Block (if MISSING)
    │
    └── 1:1 ── Quick Setup Summary (aggregated, if any MISSING)
                   │
                   └── 1:N ── Installation Approach (3 static methods)
```
