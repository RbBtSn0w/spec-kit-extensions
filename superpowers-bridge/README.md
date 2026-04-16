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
specify extension add superpowers-bridge --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.3.0/superpowers-bridge.zip
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

## When To Use Each Command

This table is the practical entry point for users. It shows when each command
should be used, whether it is automatic or manual, and what problem it solves.

| Command | Automatic? | Best Time To Use | Solves |
|---|---|---|---|
| `/speckit.superb.check` | Manual | Right after installing the extension or when bridge behavior looks wrong | Confirms which superpowers skills were found, where they were found, and which hooks or standalone commands are ready |
| `/speckit.superb.review` | Optional hook after `tasks` | After `tasks.md` is generated, before implementation starts | Checks whether `tasks.md` really covers `spec.md` and whether the task set is precise enough for strict TDD |
| `/speckit.superb.tdd` | Mandatory hook before `implement` | Immediately before implementation begins | Enforces RED-GREEN-REFACTOR and blocks speculative production code before a failing test |
| `/speckit.superb.verify` | Mandatory hook after `implement` | Immediately after implementation claims are made | Requires fresh evidence before any completion claim and verifies spec coverage against passing tests |
| `/speckit.superb.critique` | Manual | After a major task, after implementation, or before opening a PR | Reviews the code diff against `spec.md`, `plan.md`, and `tasks.md` to catch implementation drift |
| `/speckit.superb.debug` | Manual | When TDD is stuck, repeated fixes failed, or behavior is still unexplained | Switches from trial-and-error to root-cause debugging |
| `/speckit.superb.respond` | Manual | After receiving critique output, PR comments, or external review feedback | Processes review items rigorously before implementing or rejecting them |
| `/speckit.superb.finish` | Manual | After verification passes and the work is ready to integrate | Handles merge / PR / keep / discard decisions in a structured way |

## Typical Usage Order

For most users, the extension should feel like this:

1. Install the extension and run `/speckit.superb.check`.
2. Run the normal Spec Kit flow through `specify`, `clarify`, `plan`, and `tasks`.
3. Let `/speckit.superb.review` run after `tasks` if you want a task coverage and TDD-readiness gate.
4. Start `/speckit.implement`; `/speckit.superb.tdd` runs before implementation and `/speckit.superb.verify` runs after it.
5. If implementation gets stuck, run `/speckit.superb.debug`.
6. If you want an implementation review, run `/speckit.superb.critique`.
7. If review feedback arrives, run `/speckit.superb.respond`.
8. Once the work is verified and ready to integrate, run `/speckit.superb.finish`.

## Status Synchronization

The bridge also maintains a lightweight lifecycle marker in the active
`spec.md` file:

```markdown
**Status**: <State>
```

This status model is intentionally limited to states that the bridge can
actually observe with the current hook surface.

### Bridge-Owned States

| State | Written By | Meaning |
|---|---|---|
| `Tasked` | `after_tasks` via `/speckit.superb.review` | `tasks.md` exists and the feature has entered task-driven implementation preparation |
| `Implementing` | `before_implement` via `/speckit.superb.tdd` | implementation has formally entered execution |
| `Verified` | `/speckit.superb.verify` | implementation passed the verification gate and requirement evidence checks |
| `In Review` | `/speckit.superb.finish` after successful PR creation | work has been handed off into external review/merge flow |
| `Abandoned` | `/speckit.superb.finish` after successful discard | work was explicitly discarded |

### Why There Is No `Completed`

The bridge does **not** currently write `Completed`.

Reason:

- the common integration path is GitHub PR creation and later merge
- that final merge event happens outside the current bridge hook surface
- writing `Completed` during PR creation would be inaccurate

So the highest accurate PR-based state in the current design is:

- `In Review`

### Status Write Rules

- The bridge resolves the active feature path using the same Spec Kit feature
  resolution mechanism as follow-up commands.
- It prefers `FEATURE_SPEC` when available, otherwise `FEATURE_DIR/spec.md`.
- It never guesses the feature path from the branch name manually.
- Status updates are executed through the bundled helper scripts:
  - `scripts/bash/sync-spec-status.sh`
  - `scripts/powershell/sync-spec-status.ps1`
- If the status line is missing, the helper inserts it once near the top
  of the document: below the first H1 heading when present (after a blank
  line), otherwise at file start.
- If the status line exists, the helper updates it in place.
- The helper normalizes duplicate `**Status**:` lines into one canonical line.
- The bridge does not silently overwrite `Abandoned`.

## Hook Integration

This extension registers the following hooks:

- `after_tasks` → `review` (optional)
- `before_implement` → `tdd` (mandatory)
- `after_implement` → `verify` (mandatory)

## Configuration

`superb-config.template.yml` documents the intended bridge configuration shape
for discovery order, required skill sets, and standalone command toggles.
The current command prompts still use the documented defaults directly; the
template is not yet enforced as a live runtime config file. It does not define
remote fallbacks or bundled skill content.

## Requirements

- Spec Kit: `>=0.4.3`
- Installed superpowers-compatible skills in `./.agents/skills/` or `~/.agents/skills/`
- Optional: the `superpowers` tool, if you use it to install or manage those skills; the bridge itself relies on the installed skill content being present

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
| Synchronize bridge-owned lifecycle states in `spec.md` | Superpowers Bridge |

## Stage Boundaries

The bridge is designed to complement, not replace, the Spec Kit commands that
already own specification quality and artifact consistency.

### `clarify` vs Bridge Commands

| Command | Owner | Primary Artifact | Solves |
|---|---|---|---|
| `/speckit.clarify` | Spec Kit | `spec.md` | Resolves underspecified or ambiguous product requirements and writes the answers back into the spec |
| `/speckit.superb.review` | Superpowers Bridge | `tasks.md` against `spec.md` / `plan.md` | Checks whether the generated task plan actually covers the spec and is specific enough for a strict TDD gate |
| `/speckit.superb.critique` | Superpowers Bridge | code diff against `spec.md` / `plan.md` / `tasks.md` | Reviews implementation output against declared requirements and implementation intent |

### `checklist` vs `analyze` vs Bridge Commands

| Command | Owner | Primary Focus | Solves |
|---|---|---|---|
| `/speckit.checklist` | Spec Kit | Requirements-writing quality | Tests whether requirements are complete, clear, consistent, measurable, and ready for implementation |
| `/speckit.analyze` | Spec Kit | Cross-artifact consistency | Detects contradictions, ambiguity, duplication, and missing links across `spec.md`, `plan.md`, and `tasks.md` |
| `/speckit.superb.review` | Superpowers Bridge | Coverage + TDD readiness | Determines whether `tasks.md` is implementation-ready and can support `before_implement` TDD enforcement |
| `/speckit.superb.tdd` | Superpowers Bridge | Implementation discipline | Enforces RED-GREEN-REFACTOR once implementation begins |
| `/speckit.superb.verify` | Superpowers Bridge | Completion evidence | Blocks completion claims unless full verification evidence exists |
| `/speckit.superb.finish` | Superpowers Bridge | Integration handoff state | Moves the feature into `In Review` after PR creation or `Abandoned` after successful discard |

### Responsibility Map

```text
 /speckit.superb.check
     |
     +--> validates local superpowers skills and hook readiness

 /speckit.specify -> /speckit.clarify -> /speckit.checklist
        |                 |                  |
        |                 |                  +--> checks requirement-writing quality
        |                 |
        |                 +--> resolves ambiguous or missing product decisions
        |
        +--> creates the feature spec

 /speckit.plan -> /speckit.tasks -> /speckit.analyze
        |                |                 |
        |                |                 +--> checks cross-artifact consistency
        |                |
        |                +--> /speckit.superb.review
        |                     checks task coverage and TDD readiness
        |                     writes `**Status**: Tasked`
        |
        +--> creates technical plan and implementation structure

 /speckit.implement
        |
        +--> /speckit.superb.tdd
        |     enforces test-first implementation before work starts
        |     writes `**Status**: Implementing`
        |
        +--> implementation execution
        |
        +--> /speckit.superb.verify
              enforces evidence before completion claims
              writes `**Status**: Verified`

 Standalone support around implementation:
 - /speckit.superb.debug
   use when implementation is blocked or repeated fixes failed
 - /speckit.superb.critique
   use to review the implementation against spec, plan, and tasks
 - /speckit.superb.respond
   use after critique output or external review feedback
 - /speckit.superb.finish
   use after verification succeeds and the branch is ready to integrate
   writes `**Status**: In Review` after successful PR creation
   writes `**Status**: Abandoned` after successful discard
```

### Practical Division Of Labor

- Use `/speckit.clarify` when the spec still has unresolved product or behavior questions.
- Use `/speckit.checklist` when you want to test the quality of the written requirements themselves.
- Use `/speckit.analyze` when you want a broad consistency check across `spec.md`, `plan.md`, and `tasks.md`.
- Use `/speckit.superb.review` when you specifically want to know whether `tasks.md` is complete enough and precise enough for strict TDD-driven implementation.
- Use `/speckit.superb.tdd` and `/speckit.superb.verify` only around implementation, not during specification or planning.
- Use `/speckit.superb.critique` when the code itself, not just the planning artifacts, needs to be reviewed against the declared requirements.
- Use `/speckit.superb.debug` when you need root-cause investigation rather than another quick fix.
- Use `/speckit.superb.respond` after review comments arrive and you need a disciplined way to accept, reject, or clarify them.
- Use `/speckit.superb.finish` only after verification is complete and you are deciding how to integrate or preserve the branch.
- Read `In Review` as the current highest accurate PR-based lifecycle state; this bridge does not currently track final GitHub merge completion.

## License

MIT — see [LICENSE](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
