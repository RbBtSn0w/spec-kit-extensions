# Superpowers Bridge

Bridges selected installed [obra/superpowers](https://github.com/obra/superpowers) quality-control skills into the Spec Kit workflow and adds a small set of bridge-native review utilities.

This extension combines:

- **Hook-based guardrails** for core Spec Kit commands (`tasks`, `implement`), and
- **Standalone operational commands** for debugging, review response, and branch completion.

It does **not** replace the Spec Kit main flow. The main flow remains:

`/speckit.specify -> /speckit.clarify -> /speckit.plan -> /speckit.tasks -> /speckit.analyze | /speckit.checklist -> /speckit.implement`

## Bridge Model

```text
  [ Spec Kit Main Flow ]                         [ Bridge Enhancements ]

 ┌───────────────────┐
 │ /speckit specify  │ ─────> Spec Kit owns specification creation
 └─────────┬─────────┘
           │
 ┌─────────▼─────────┐
 │ /speckit clarify  │ ─────> Spec Kit owns clarification and spec updates
 └─────────┬─────────┘
           │
 ┌─────────▼─────────┐
 │ /speckit plan     │ ─────> Spec Kit owns technical planning
 └─────────┬─────────┘
           │
 ┌─────────▼─────────┐
 │ /speckit tasks    │ ─────> 1. Execute Core Tasks Logic
 └─────────┬─────────┘        2. 🔍 review (Optional: Coverage + TDD-readiness)
           │                  (after_tasks)
           │
 ┌─────────▼─────────┐       (before_implement)
 │ /speckit implement│ ─────> 1. 🔴 tdd (Mandatory: RED-GREEN-REFACTOR Enforcer)
 └─────────┬─────────┘        2. Execute Core Implement Logic
           │                  3. ✅ verify (Mandatory: Evidence-Based Completion Gate)
           │                  (after_implement)
           ▼
  [ Standalone Utilities ]
   ├─ /speckit.superb.check   ──> 🩺 Skill installation and hook readiness diagnostics
   ├─ /speckit.superb.debug   ──> 🐛 Systematic root-cause investigation
   ├─ /speckit.superb.critique──> 📝 Bridge-native spec-aligned code review
   ├─ /speckit.superb.respond ──> 💬 Rigorous review feedback implementation
   └─ /speckit.superb.finish  ──> 🏁 Branch completion & merge strategy
```

## Features

- Local skill discovery and readiness diagnostics (`check`)
- Mandatory TDD gate before implementation (`tdd`)
- Task/spec coverage and TDD-readiness check (`review`)
- Mandatory evidence-based completion gate (`verify`)
- Bridge-native spec-aligned reviewer role (`critique`)
- Root-cause debugging escalation (`debug`)
- Structured branch completion options (`finish`)
- Technical response workflow for review feedback (`respond`)

## What This Bridge Does Not Do

The bridge intentionally does **not** take over these responsibilities from
Spec Kit:

- Specification generation and branch creation
- Clarification and spec mutation
- Technical planning
- Task generation
- Implementation orchestration

The following superpowers workflow skills are therefore **not** bridged as
formal commands or hooks:

- `brainstorming`
- `writing-plans`
- `subagent-driven-development`
- `executing-plans`
- `using-git-worktrees`
- `requesting-code-review`

## Design Notes

The V2 redesign rationale is documented in
[V2-DESIGN-NOTES.md](V2-DESIGN-NOTES.md), including:

- why the bridge no longer tries to embed the full Superpowers workflow
- which Superpowers skills are intentionally excluded
- how Spec Kit ownership boundaries were used to shape the bridge
- why the bridge now depends on locally installed skills instead of remote fallbacks

## Installation

### Install from ZIP (Recommended)

Install directly from the release asset:

```bash
specify extension add superpowers-bridge --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.0.0/superpowers-bridge.zip
```

### Install from GitHub Repository (Development)

Clone the collection repository and install the extension folder locally:

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions
specify extension add --dev ./superpowers-bridge
```

### Install Superpowers Skills

This bridge expects the relevant superpowers skills to already be installed in
one of these locations:

1. `./.agents/skills/`
2. `~/.agents/skills/`

Workspace skills take precedence over global skills.

Run the diagnostics command after installation:

```text
/speckit.superb.check
```

## Commands

| Command | Type | Purpose |
|---|---|---|
| `/speckit.superb.check` | Standalone | Verify installed skill availability and hook readiness |
| `/speckit.superb.tdd` | Hookable | Enforce RED-GREEN-REFACTOR before code changes |
| `/speckit.superb.review` | Hookable | Check `tasks.md` coverage and TDD-readiness |
| `/speckit.superb.verify` | Hookable | Block completion claims without fresh evidence |
| `/speckit.superb.critique` | Standalone | Bridge-native spec-aligned code review |
| `/speckit.superb.debug` | Standalone | Systematic root-cause debugging |
| `/speckit.superb.finish` | Standalone | Post-verify branch completion workflow |
| `/speckit.superb.respond` | Standalone | Process and implement review feedback rigorously |

## Hook Integration

This extension registers the following hooks:

- `after_tasks` → `review` (optional)
- `before_implement` → `tdd` (mandatory)
- `after_implement` → `verify` (mandatory)

## Configuration

`superb-config.template.yml` controls discovery order, required skill sets, and
which standalone bridge commands are enabled. It does not define remote
fallbacks or bundled skill content.

## Requirements

- Spec Kit: `>=0.4.3`
- Installed superpowers-compatible skills in `./.agents/skills/` or `~/.agents/skills/`

## Responsibility Boundaries

| Responsibility | Owner |
|---|---|
| Create and update `spec.md` | Spec Kit |
| Clarify unresolved spec decisions | Spec Kit |
| Build `plan.md` and `tasks.md` | Spec Kit |
| Analyze artifact consistency | Spec Kit |
| Generate requirements-quality checklists | Spec Kit |
| Enforce TDD discipline during implementation | Superpowers Bridge |
| Enforce verification before completion | Superpowers Bridge |
| Review task coverage and TDD-readiness | Superpowers Bridge |
| Review implementation against spec/plan/tasks | Superpowers Bridge |

## License

MIT — see [LICENSE](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
