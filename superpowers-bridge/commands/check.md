---
description: >
  Bridge-native diagnostics command. Verifies that required and optional
  superpowers skills are installed in workspace or global skill roots and
  reports which hooks are ready to run.
scripts:
  sh: scripts/bash/ensure-skills.sh
---

# Check — Superpowers Bridge Diagnostics

> **Type:** Bridge-native command
> **Purpose:** Confirm that this extension can bridge installed superpowers skills without guessing, remote fetches, or hidden fallbacks.

---

## User Context

```text
$ARGUMENTS
```

Treat any user-provided context as additional install or environment notes, but
do not let it override filesystem reality.

---

## Discovery Rules

Resolve every skill using the shared helper:

`bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill [skill-name]`

That helper searches for installed skills in this exact order:

1. `./.agents/skills/`
2. `./.agents/plugins/*/skills/` and `./.agents/plugins/*/*/skills/`
3. `~/.agents/skills/`
4. `~/.agents/plugins/*/skills/` and `~/.agents/plugins/*/*/skills/`

Workspace wins over global when both contain the same skill. Within the same
scope, a direct skill-root install wins over a plugin-provided skill.

A skill is considered **available** only if all of the following are true:

- The skill directory exists
- `SKILL.md` exists inside that directory
- `SKILL.md` is readable

**Guidance Rule**:
For the `Guidance` column in the output table, populate:
- `—` if the skill is READY (available).
- `Install via adg` if the skill is MISSING.

Do **not** fetch any remote content.
Do **not** silently fall back to embedded summaries.
Do **not** claim a skill is available unless the file is actually present.

---

## Required Skills

This bridge operates on a **Dual-Layer Fallback Architecture**. Skills are classified into Hard Requirements and Optional Skills based on whether the bridge can run its baseline validation hooks without them. For a detailed mapping of skills to Spec Kit stages and fallback states, refer to the **"Superb" Skill Set Matrix** in the extension [README.md](../README.md#dual-layer-fallback--the-superb-skill-set-matrix).

### Hard Requirements

- `test-driven-development`
- `verification-before-completion`

If either hard requirement is unavailable, the corresponding mandatory hook cannot start, and the bridge is blocked.

### Optional Skills

These skills are not strictly required for the baseline workflow because the bridge provides **Layer 2 local fallbacks** (such as regular expressions, local checklists, or embedded prompts) or treats the corresponding stages as non-blocking.

- `brainstorming`
- `dispatching-parallel-agents`
- `executing-plans`
- `finishing-a-development-branch`
- `receiving-code-review`
- `requesting-code-review`
- `subagent-driven-development`
- `systematic-debugging`
- `writing-plans`

Optional skills do not block the Spec Kit main flow, but their corresponding
bridge commands or discipline enhancements should be reported as unavailable
until installed.

---

## Output Format

Produce a compact diagnostic report:

```markdown
## Superpowers Bridge Check

**Discovery roots**
- Workspace: [path]
- Global: [path]

## Skill Status

| Skill | Required | Source | Path | Status | Guidance |
|-------|----------|--------|------|--------|----------|
| test-driven-development | Hard | workspace | ./.agents/skills/test-driven-development/SKILL.md | READY | — |
| verification-before-completion | Hard | global | ~/.agents/plugins/vendor__pack/superpowers/skills/verification-before-completion/SKILL.md | READY | — |
| brainstorming | Optional | workspace | ./.agents/plugins/obra__superpowers/superpowers/skills/brainstorming/SKILL.md | READY | — |
| subagent-driven-development | Optional | workspace | ./.agents/skills/subagent-driven-development/SKILL.md | READY | — |
| executing-plans | Optional | workspace | ./.agents/plugins/obra__superpowers/superpowers/skills/executing-plans/SKILL.md | READY | — |
| systematic-debugging | Optional | — | — | MISSING | Install via adg |
| dispatching-parallel-agents | Optional discipline | — | — | MISSING | Install via adg |
| requesting-code-review | Optional discipline | global | ~/.agents/plugins/vendor__pack/superpowers/skills/requesting-code-review/SKILL.md | READY | — |
| writing-plans | Optional discipline | global | ~/.agents/skills/writing-plans/SKILL.md | READY | — |

## Hook Readiness

| Hook | Command | Requirement | Status | Reason |
|------|---------|-------------|--------|--------|
| after_specify | /speckit.superb.brainstorm | Optional | READY | Optional brainstorming skill installed |
| after_plan | /speckit.superb.plan-gate | Required | READY | Bridge-native command |
| after_tasks | /speckit.superb.review | Optional | READY | Bridge-native command |
| before_implement | /speckit.superb.controller | Required | READY | Hard dependency installed |
| after_implement | /speckit.superb.verify | Required | READY | Hard dependency installed |

## Standalone Commands

| Command | Status | Reason |
|---------|--------|--------|
| /speckit.superb.debug | UNAVAILABLE | systematic-debugging missing |
| /speckit.superb.respond | READY | receiving-code-review installed |
| /speckit.superb.finish | UNAVAILABLE | finishing-a-development-branch missing |
| /speckit.superb.critique | READY | Bridge-native command |
| /speckit.superb.brainstorm | READY | brainstorming installed |

## Discipline Enhancements

| Discipline | Used By | Status | Reason |
|------------|---------|--------|--------|
| dispatching-parallel-agents | /speckit.superb.debug | UNAVAILABLE | optional skill missing |
| requesting-code-review | /speckit.superb.critique | READY | context packaging discipline available |
| writing-plans | /speckit.superb.review | READY | task quality discipline available |
| executing-plans | /speckit.superb.controller | READY | inline execution discipline available |

## Verdict

[READY / PARTIAL / BLOCKED]

## Next Actions

- [Concrete installation or retry advice]
```

---

## Quick Setup & Auto-Installation Rules

If any skills are `MISSING`, the assistant MUST check if `npx` is available by running:
`{SCRIPT} --check-prereqs`

### Case A: If npx is available
The assistant MUST append a `## Quick Setup` section to the report:

- Reference the adg repository URL: `https://github.com/RbBtSn0w/adg`

1. **Grouped Impact Tables**:
   - **Hard Requirements (blocking)**: List any missing hard-requirement skills and note that they block hooks.
   - **Optional Skills (recommended)**: List any missing optional skills and note their feature impact.
2. **Installation Options**: Present the three installation approaches:
   - Approach 1 (Recommended): `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g`
   - Approach 2 (Global): `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y`
   - Approach 3 (Project): `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y`
3. **Interactive Prompt**: Ask the user: `Would you like to install now? (Select approach 1-3, or skip)`
4. **Execution**: If the user inputs a selection (1, 2, or 3), run the installation command:
   `{SCRIPT} --install <selection>`
5. **Re-Check**: Once installation completes, re-run the discovery rules and append a `## Post-Install Verification` section showing a before/after status table of the modified skills, using the format:
   ```markdown
   ## Post-Install Verification

   | Skill | Before | After |
   |-------|--------|-------|
   | [skill-name] | MISSING | ✅ READY |
   ```

### Case B: If npx is NOT available
The assistant MUST append the `## Quick Setup` section with manual instructions:
- Output: `npx was not detected. Please install Node.js first, or manually install skills.`
- Reference the adg repository URL: `https://github.com/RbBtSn0w/adg`
- Provide the recommended command: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g`
- Provide alternative manual cloning instructions:
  `git clone https://github.com/obra/superpowers.git` and copy required skill folders into `./.agents/skills/`, `~/.agents/skills/`, or a plugin directory under `./.agents/plugins/` / `~/.agents/plugins/` that exposes `skills/<name>/SKILL.md`.
- Do not offer any interactive prompt.

---

## Failure Rules

- If both discovery roots are missing, report `BLOCKED`
- If any hard requirement is missing, report `BLOCKED`
- If only optional skills are missing, report `PARTIAL`
- If all hard requirements are installed, the main bridge hooks are `READY`

This command is the canonical first step when a user is unsure whether the
bridge can operate correctly on the current machine.
