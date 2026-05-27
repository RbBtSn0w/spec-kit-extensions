---
description: >
  Bridge-native diagnostics command. Verifies that required and optional
  superpowers skills are installed in workspace or global skill roots and
  reports which hooks are ready to run.
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

Search for installed skills in this exact order:

1. `./.agents/skills/`
2. `~/.agents/skills/`

Workspace wins over global when both contain the same skill.

A skill is considered **available** only if all of the following are true:

- The skill directory exists
- `SKILL.md` exists inside that directory
- `SKILL.md` is readable

Do **not** fetch any remote content.
Do **not** silently fall back to embedded summaries.
Do **not** claim a skill is available unless the file is actually present.

---

## Required Skills

### Hard Requirements

- `test-driven-development`
- `verification-before-completion`

If either hard requirement is unavailable, the corresponding mandatory hook is
not ready and the bridge is not fully operational.

### Optional Skills

- `brainstorming`
- `systematic-debugging`
- `receiving-code-review`
- `finishing-a-development-branch`
- `dispatching-parallel-agents`
- `requesting-code-review`
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

| Skill | Required | Source | Path | Status |
|-------|----------|--------|------|--------|
| test-driven-development | Hard | workspace | ./.agents/skills/test-driven-development/SKILL.md | READY |
| verification-before-completion | Hard | global | ~/.agents/skills/verification-before-completion/SKILL.md | READY |
| brainstorming | Optional | workspace | ./.agents/skills/brainstorming/SKILL.md | READY |
| systematic-debugging | Optional | — | — | MISSING |
| dispatching-parallel-agents | Optional discipline | — | — | MISSING |
| requesting-code-review | Optional discipline | global | ~/.agents/skills/requesting-code-review/SKILL.md | READY |
| writing-plans | Optional discipline | global | ~/.agents/skills/writing-plans/SKILL.md | READY |

## Hook Readiness

| Hook | Command | Requirement | Status | Reason |
|------|---------|-------------|--------|--------|
| after_specify | /speckit.superb.brainstorm | Optional | READY | Optional brainstorming skill installed |
| after_tasks | /speckit.superb.review | Optional | READY | Bridge-native command |
| before_implement | /speckit.superb.tdd | Required | READY | Hard dependency installed |
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

## Verdict

[READY / PARTIAL / BLOCKED]

## Next Actions

- [Concrete installation or retry advice]
```

---

## Failure Rules

- If both discovery roots are missing, report `BLOCKED`
- If any hard requirement is missing, report `BLOCKED`
- If only optional skills are missing, report `PARTIAL`
- If all hard requirements are installed, the main bridge hooks are `READY`

This command is the canonical first step when a user is unsure whether the
bridge can operate correctly on the current machine.
