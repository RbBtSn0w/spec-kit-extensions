# Superpowers Bridge

Bridges selected [obra/superpowers](https://github.com/obra/superpowers)
disciplines into [Spec Kit](https://github.com/github/spec-kit) as
evidence-first trust gates for agent workflows.

Superpowers Bridge makes Spec Kit implementation claims verifiable: TDD before
code, review against `spec.md` / `plan.md` / `tasks.md`, and fresh evidence
before a feature can be treated as `Verified`.

The current product promise is narrow: no agent should mark a Spec Kit feature
complete without fresh verification evidence and mapped spec coverage.

This extension combines:

- **Optional post-stage refinement** after `specify`,
- **Hook-based guardrails** for core Spec Kit commands (`tasks`, `implement`), and
- **Standalone operational commands** for debugging, review response, and branch completion.

It does **not** replace the Spec Kit main flow. The main flow remains:

`/speckit.specify -> /speckit.clarify -> /speckit.plan -> /speckit.tasks -> /speckit.analyze | /speckit.checklist -> /speckit.implement`

## Naming And Brand

Use these names consistently:

| Name | Use For | Stability |
|---|---|---|
| Superpowers Bridge | Official extension and product name | Public, stable |
| `superpowers-bridge` | Spec Kit extension package, folder, release asset, and tag prefix | Public, stable |
| `superb` | Command namespace and local shorthand, as in `/speckit.superb.verify` | Public, stable |

Do not use `SuperB` or `SuperBridge` as official public names for this
extension. `SuperB` is easy to confuse with the lowercase command namespace,
and `SuperBridge` hides the product's relationship to Superpowers. If a future
broader bridge product needs either name, document it as a separate brand layer
rather than renaming this extension in place.

## Who This Is For

Use this extension when:

- You use Spec Kit as the source of truth for `spec.md`, `plan.md`, and
  `tasks.md`.
- You let an autonomous coding agent implement features and need proof that it
  did not skip tests, requirements, or verification.
- You want selected Superpowers development discipline without adopting the
  entire Superpowers workflow as a second owner.

It is not a general-purpose code-review bot, a replacement for Spec Kit, or a
standalone Superpowers workflow runner.

## Open Source Adoption Path

The fastest way to validate the extension is one real feature, not a synthetic
demo:

1. Install the extension and the hard-required local Superpowers skills.
2. Run `/speckit.superb.check` and confirm `test-driven-development` and
   `verification-before-completion` are `READY`.
3. Run one normal Spec Kit feature through `specify`, `plan`, `tasks`, and
   `implement`.
4. Let `/speckit.superb.controller` run before implementation and
   `/speckit.superb.verify` run after implementation.
5. Treat the first success as real only when `/speckit.superb.verify` captures
   fresh run-local evidence with test output and a spec-coverage checklist.

The extension is proving value when it blocks a false completion or exposes a
missing requirement-to-task link before `Verified` is synchronized.

## Bridge Model

```text
  [ Spec Kit Main Flow ]                         [ Bridge Enhancements ]

 ┌───────────────────┐
 │ /speckit specify  │ ─────> 1. Spec Kit owns specification creation
 └─────────┬─────────┘        2. 🧠 brainstorm (Optional: spec refinement)
           │                  (after_specify)
           │
 ┌─────────▼─────────┐
 │ /speckit clarify  │ ─────> Spec Kit owns clarification and spec updates
 └─────────┬─────────┘
           │
 ┌─────────▼─────────┐
 │ /speckit plan     │ ─────> 1. Spec Kit owns technical planning
 └─────────┬─────────┘        2. 📋 plan-gate (Mandatory: Granularity & placeholders)
           │                  (after_plan)
           │
 ┌─────────▼─────────┐
 │ /speckit tasks    │ ─────> 1. Execute Core Tasks Logic
 └─────────┬─────────┘        2. 🔍 review (Optional: Coverage + TDD-readiness)
           │                  (after_tasks)
           │
 ┌─────────▼─────────┐       (before_implement)
 │ /speckit implement│ ─────> 1. ⚙️ controller (Mandatory: Implementation Controller)
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
- Optional post-specification brainstorming refinement (`brainstorm`)
- Mandatory Plan gate (granularity and placeholders) (`plan-gate`)
- Mandatory Implementation Controller gate (`controller`) with SDD/TDD orchestration
- Task/spec coverage and TDD-readiness check (`review`)
- Mandatory evidence-based completion gate (`verify`)
- Bridge-native spec-aligned reviewer role (`critique`)
- Root-cause debugging escalation (`debug`)
- Structured branch completion options (`finish`)
- Technical response workflow for review feedback (`respond`)

## Evidence-First Completion

`/speckit.superb.verify` captures completion evidence in the system temporary directory before it synchronizes the active `spec.md` status to `Verified`. The evidence file is a run-local artifact for the current gate, not a source-controlled project artifact.

Each temporary evidence file records:

- UTC timestamp
- git commit hash
- build/lint status
- spec-coverage checklist
- full test output

If the checklist, test output, or evidence capture step is missing, the previous status is preserved.

## What This Bridge Does Not Do

The bridge intentionally does **not** take over these responsibilities from
Spec Kit:

- Specification generation and branch creation
- Clarification ownership and unapproved spec mutation
- Technical planning
- Task generation
- Implementation orchestration

The following superpowers workflow skills are therefore **not** exposed as
independent standalone bridge commands:

- `writing-plans`
- `executing-plans`
- `using-git-worktrees`

The following skills are represented by existing bridge commands rather than
directly exposed as separate commands:

- `requesting-code-review` is not directly bridged as a standalone command.
  Its handoff packaging discipline is available inside
  `/speckit.superb.critique` when the user wants an external or subagent review
  prompt.
- `writing-plans` does not generate `plan.md` or `tasks.md`; selected task
  quality checks are folded into `/speckit.superb.review`.
- `dispatching-parallel-agents` is not a main-flow hook; its parallel
  investigation discipline is available inside `/speckit.superb.debug` when
  there are multiple independent failure domains.

### Review Role Boundaries

The review-related surfaces intentionally have different roles:

| Surface | Role | Owns | Does not own |
|---|---|---|---|
| `requesting-code-review` | Review request / handoff pattern | Packaging context for another reviewer or subagent | Performing the review inside this bridge |
| `/speckit.superb.critique` | Local spec-aligned reviewer | Reviewing diff against `spec.md`, `plan.md`, `tasks.md`, and optionally producing a handoff package | Implementing fixes or receiving feedback |
| `/speckit.superb.respond` | Feedback receiver / implementer response | Triage, accept/reject/clarify, and implement accepted review items | Producing the original review |

#### `review` vs `converge`

`/speckit.superb.review` and upstream `/speckit-converge` address the same coverage concern at
two different stages and must not be confused:

| Command | Stage | Owns | Does not own |
|---|---|---|---|
| `/speckit.superb.review` | Plan-stage prevention (after `tasks`, before `implement`) | Task quality, TDD-readiness, plan↔task consistency; flagging coverage gaps | Creating tasks for coverage gaps (delegates to converge) |
| `/speckit-converge` | Delivery-stage remediation (after `implement`) | Assessing code vs spec/plan/tasks and append-only writing remaining work as tasks | Task-quality / TDD-readiness gating; running tests or proving completion |

Because `converge` never runs tests and its `converged` verdict ignores evidence, the bridge
registers a mandatory **`after_converge` hook** that runs `/speckit.superb.verify` — the same
evidence-first gate used after `implement`. This closes the convergence loop so converge-driven
work cannot be declared complete without fresh evidence (`implement → converge → implement →
verify`).

## Superpowers Mapping Matrix

This matrix is the compatibility map between Superpowers skills, the
Superpowers Bridge (`superb`) command surface, and the Spec Kit lifecycle.
It separates direct bridges from borrowed disciplines and intentionally
unexposed workflow skills.

| Superpowers skill | Bridge surface | Spec Kit integration point | Mechanism | Boundary |
|---|---|---|---|---|
| `brainstorming` | `/speckit.superb.brainstorm` | After `/speckit.specify`, before `/speckit.clarify` or `/speckit.plan` | Optional `after_specify` hook or manual rerun/refinement | Refines the existing `spec.md` with user approval; does not create a feature, branch, parallel design doc, `plan.md`, `tasks.md`, or lifecycle status. |
| `test-driven-development` | `/speckit.superb.controller` | Immediately before `/speckit.implement` writes production code | Required `before_implement` hook | Enforces TDD discipline and orchestrates single/multi-agent implementation layers. |
| `verification-before-completion` | `/speckit.superb.verify` | Immediately after `/speckit.implement` claims completion | Required `after_implement` hook | Requires fresh evidence before completion claims and synchronizes only bridge-owned verified state. |
| `systematic-debugging` | `/speckit.superb.debug` | During implementation when failures repeat or behavior is unexplained | Manual support command | Produces root-cause investigation and evidence; does not bypass TDD or verification gates. |
| `dispatching-parallel-agents` | `/speckit.superb.debug` parallel mode | Debugging only, when there are 2+ independent failure domains | Borrowed discipline inside `debug` | Creates independent investigation task packages; the controller performs final synthesis and verification. |
| `requesting-code-review` | `/speckit.superb.critique` handoff section | Before external review, subagent review, PR review, or merge review | Borrowed handoff-packaging discipline | Packages reviewer context; it is not exposed as `/speckit.superb.request-review` and does not receive feedback. |
| `receiving-code-review` | `/speckit.superb.respond` | After critique output, PR comments, or external review feedback arrives | Manual support command | Triage, accept/reject/clarify, and implement accepted items; it does not produce the original review. |
| `finishing-a-development-branch` | `/speckit.superb.finish` | After verification succeeds and integration is ready | Manual support command | Handles PR/merge/keep/discard decisions and bridge-owned handoff state; does not replace repository policy. |
| `writing-plans` | `/speckit.superb.review` task-quality checks | After `/speckit.tasks`, before implementation | Borrowed discipline inside `review` | Checks file ownership, task granularity, RED/GREEN target, and review checkpoint readiness; does not generate or edit `plan.md` or `tasks.md`. |
| `subagent-driven-development` | Not exposed | None | Borrowed discipline inside `controller` | Integrated internally as a worker orchestration layer for `controller.md` and `plan-gate.md`. |
| `executing-plans` | Not exposed | None | Borrowed discipline inside `controller` | Drives Inline Execution (Layer 1) in Single-Agent Mode; does not compete with `/speckit.implement`. |
| `using-git-worktrees` | Not exposed | None | Not bridged | Repository/worktree strategy is project policy, not a required Spec Kit extension behavior. |
| `using-superpowers` | Not exposed | Agent/bootstrap layer | Not part of the extension command surface | Skill installation and loading remain outside the feature lifecycle; `/speckit.superb.check` only reports readiness. |
| `writing-skills` | Not exposed | Extension maintenance only | Not part of feature delivery | Useful for maintaining skills, but not for a Spec Kit feature workflow. |

### Dual-Layer Fallback & The "Superb" Skill Set Matrix

This bridge operates on a **Dual-Layer Fallback Architecture**:
- **Hard Requirements** are skills that the bridge cannot run its baseline validation hooks without (no simple text/regex fallbacks exist).
- **Optional Skills** improve workflow quality but are not strictly required because the bridge provides **Layer 2 local fallbacks** (such as regular expressions, local checklists, or embedded prompts) or treats the corresponding stages as non-blocking.

To unlock the full, premium experience of the Superpowers Bridge across all Spec Kit workflow stages (the **"Superb" Suite**), the following skills are recommended:

| Stage / Feature | Intended Command | Optimal Skills Required (Layer 1) | Local Fallback (Layer 2) |
|---|---|---|---|
| **Spec Refinement** | `/speckit.superb.brainstorm` | `brainstorming` | Hook skipped (optional) |
| **Inline Implementation** | `/speckit.superb.controller` (`--inline`) | `executing-plans` + `test-driven-development` | Local TDD loop |
| **Multi-Agent Dispatch** | `/speckit.superb.controller` | `subagent-driven-development` + `test-driven-development` | Single-Agent fallback |
| **Double-Review Quality Gate** | `/speckit.superb.controller` (Review) | `subagent-driven-development` | Local checklist / `critique` |
| **Requirement Verification** | `/speckit.superb.verify` | `verification-before-completion` + `writing-plans` | Baseline verification |
| **Troubleshooting Escalation** | `/speckit.superb.debug` | `systematic-debugging` + `dispatching-parallel-agents` | Command disabled |
| **Review Feedback & Handoff** | `/speckit.superb.critique` / `respond` | `requesting-code-review` + `receiving-code-review` | Local critique only |
| **Branch Completion** | `/speckit.superb.finish` | `finishing-a-development-branch` | Command disabled |

### Runtime Mode Diagnostics (Q&A)

**Q: How do I know if Subagent-Driven Development (SDD) is active or if the controller is running in Single-Agent serial mode?**

**A:** The controller dynamically resolves the execution mode during startup and reports its selection in the run log. You can verify the active mode through static checks or dynamic run behaviors.

1. **Static Diagnostics (Before Execution)**:
   Run the diagnostics command:
   ```text
   /speckit.superb.check
   ```
   Check the **Skill Status** and **Discipline Enhancements** sections:
   - If `subagent-driven-development` status is `READY`, the native SDD skill is installed and the controller has access to native SDD templates for the double-review quality gate under multi-agent mode (which falls back to the local `critique` command if SDD is absent).
   - If `executing-plans` status is `READY`, the controller will use native Inline Execution discipline when degrading to Single-Agent mode.

2. **Dynamic Log Signals (During Execution)**:
   Look at the controller's initial startup output:
   - **Multi-Agent SDD Mode**: The log displays `Multi-Agent SDD Mode (Default)` and resolves `subagent-driven-development/SKILL.md` (or composite TDD + Critique fallback). You will see subagents being defined and invoked (e.g., `Spec Reviewer` and `Quality Reviewer`), and tasks in `tasks.md` will be updated and ticked automatically without user prompts.
   - **Single-Agent Mode**: The log displays `Single-Agent Mode (Fallback)` or mentions `degrading gracefully to Single-Agent Mode` (due to missing `define_subagent` tool capability, missing required skills, or explicit `--inline` / `--sdd=false` user overrides). Implementation code modifications and TDD verification will be performed directly within the parent conversation.

**Q: Can I force the controller to run in Single-Agent mode?**

**A:** Yes. You can bypass subagent dispatching by passing `--inline` or `--sdd=false` inside the command arguments:
```text
/speckit.implement --inline
```
This forces the controller to run implementation inline inside the parent session, even if subagent capabilities and SDD skills are fully available.

### How The Matrix Connects To Spec Kit

- Hooked stages are limited to `after_specify`, `after_plan`, `after_tasks`,
  `before_implement`, and `after_implement`.
- Required hooks are reserved for plan quality and implementation trust boundaries:
  `/speckit.superb.plan-gate` after plan, `/speckit.superb.controller` before implementation, and `/speckit.superb.verify`
  after implementation.
- Optional hooks improve artifact quality after Spec Kit has created the
  relevant artifact, but they do not own the next stage.
- Manual support commands are called by the user or autonomous agent when the
  situation appears: debugging, critique, feedback response, and finishing.
- Borrowed disciplines do not create new bridge commands. They are constrained
  subroutines inside an existing command and inherit that command's boundary.
- Every bridge command depends on locally installed Superpowers skill content
  where applicable; the bridge does not embed remote fallback behavior.

### Agent Execution Contract

When an autonomous agent or Goal mode runs the workflow, the bridge should be
treated as stage-specific middleware rather than a second workflow engine:

- Spec Kit commands create and advance the canonical artifacts.
- Required bridge hooks are gates. If their context is missing or verification
  fails, the agent must stop and report the blocker instead of claiming progress.
- Optional bridge hooks run only when the user, goal prompt, or local policy
  opts into them. Skipping an optional hook must not block the Spec Kit stage.
- Manual bridge commands are situational tools. The agent may call them when
  their trigger condition appears, but they do not advance the Spec Kit stage by
  themselves.
- Borrowed discipline sections, such as `requesting-code-review` packaging or
  `dispatching-parallel-agents` task bundles, must return evidence or a draft
  back to the active bridge command; they do not create a new owner for the
  feature lifecycle.

### Missing Skill Diagnostics & Quick Setup

If any Superpowers skills are missing on the host environment, the bridge provides an interactive diagnostics and installation workflow:

1. **Diagnostics**:
   Run `/speckit.superb.check` to scan workspace and global roots. The output contains a **Guidance** column specifying `Install via adg` for missing skills.
2. **Auto-Installation**:
   If the check command detects `npx` in the environment, it appends a `## Quick Setup` section presenting three installation approaches:
   - **Approach 1 (Recommended)**: Installs all 11 skills under `adg plugins add obra/superpowers` with `-g` using `--skill` filters, which matches the current non-interactive plugin installation contract.
   - **Approach 2 (Global)**: Installs all 11 skills globally using `adg skills add obra/superpowers --global -y`.
   - **Approach 3 (Project)**: Installs all 11 skills project-locally using `adg skills add obra/superpowers -y`.
   The agent will prompt the user to choose an installation option (1-3) or skip, executing the helper script `ensure-skills.sh` accordingly.
3. **Manual Fallback**:
   If `npx` is not available, the check report lists manual cloning and setup steps pointing directly to the [adg repository (https://github.com/RbBtSn0w/adg)](https://github.com/RbBtSn0w/adg).
4. **Command Inline Failures**:
   If any bridge-native command (like `/speckit.superb.controller` or `/speckit.superb.verify`) is invoked when a required skill is missing, it will halt execution immediately, print the inline installation commands and the repository link, and redirect the user to `/speckit.superb.check` for full interactive setup.

## Design Notes

The V2 redesign rationale is documented in
[V2-DESIGN-NOTES.md](V2-DESIGN-NOTES.md), including:

- why the bridge no longer tries to embed the full Superpowers workflow
- which Superpowers skills are intentionally excluded
- how Spec Kit ownership boundaries were used to shape the bridge
- why the bridge now depends on locally installed skills instead of remote fallbacks

## Installation

### Install from Catalog (Recommended)

Register this repository's catalog once. The `--install-allowed` flag is
required because Spec Kit's official community catalog is discovery-only and
does not permit `extension update` for community entries.

```bash
specify extension catalog add https://raw.githubusercontent.com/RbBtSn0w/spec-kit-extensions/main/catalog.json \
  --name rbbtsn0w-spec-kit-extensions \
  --priority 1 \
  --install-allowed \
  --description "RbBtSn0w Spec Kit Extensions"
```

Install and update the bridge by its stable extension ID, `superb`:

```bash
specify extension add superb
specify extension update superb
```

### Install from ZIP

For one-off installs without catalog-managed updates, install directly from the
published release asset:

```bash
specify extension add superpowers-bridge --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.8.0/superpowers-bridge.zip
```

### Install from GitHub Repository (Development)

Clone the collection repository and install the extension folder locally:

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions
specify extension add --dev ./superpowers-bridge
```

### Install Superpowers Skills

This bridge resolves the relevant superpowers skills from these discovery roots:

1. `./.agents/skills/`
2. `./.agents/plugins/*/skills/` and `./.agents/plugins/*/*/skills/`
3. `~/.agents/skills/`
4. `~/.agents/plugins/*/skills/` and `~/.agents/plugins/*/*/skills/`

Workspace discoveries take precedence over global discoveries. Within the same
scope, a direct skill-root install wins over a plugin-provided skill.

Run the diagnostics command after installation:

```text
/speckit.superb.check
```

## Commands

| Command | Type | Purpose |
|---|---|---|
| `/speckit.superb.check` | Standalone | Verify installed skill availability and hook readiness |
| `/speckit.superb.brainstorm` | Hookable | Optionally refine the active `spec.md` after `speckit.specify` |
| `/speckit.superb.controller` | Hookable | Enforce RED-GREEN-REFACTOR before code changes |
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
| `/speckit.superb.brainstorm` | Optional hook after `specify` | After `spec.md` is created, before `clarify` or `plan` | Uses Superpowers brainstorming discipline to refine the active Spec Kit spec without creating a second design document |
| `/speckit.superb.review` | Optional hook after `tasks` | After `tasks.md` is generated, before implementation starts | Checks whether `tasks.md` really covers `spec.md` and whether the task set is precise enough for strict TDD |
| `/speckit.superb.controller` | Mandatory hook before `implement` | Immediately before implementation begins | Enforces RED-GREEN-REFACTOR and blocks speculative production code before a failing test |
| `/speckit.superb.verify` | Mandatory hook after `implement` | Immediately after implementation claims are made | Requires fresh evidence before any completion claim and verifies spec coverage against passing tests |
| `/speckit.superb.critique` | Manual | After a major task, after implementation, or before opening a PR | Reviews the code diff against `spec.md`, `plan.md`, and `tasks.md` to catch implementation drift |
| `/speckit.superb.debug` | Manual | When TDD is stuck, repeated fixes failed, or behavior is still unexplained | Switches from trial-and-error to root-cause debugging |
| `/speckit.superb.respond` | Manual | After receiving critique output, PR comments, or external review feedback | Processes review items rigorously before implementing or rejecting them |
| `/speckit.superb.finish` | Manual | After verification passes and the work is ready to integrate | Handles merge / PR / keep / discard decisions in a structured way |

## Typical Usage Order

For most users, the extension should feel like this:

1. Install the extension and run `/speckit.superb.check`.
2. Run `/speckit.specify`; optionally let `/speckit.superb.brainstorm` refine the new `spec.md`.
3. Continue the normal Spec Kit flow through `clarify`, `plan`, and `tasks`.
4. Let `/speckit.superb.review` run after `tasks` if you want a task coverage and TDD-readiness gate.
5. Start `/speckit.implement`; `/speckit.superb.controller` runs before implementation and `/speckit.superb.verify` runs after it.
6. If implementation gets stuck, run `/speckit.superb.debug`.
7. If you want an implementation review, run `/speckit.superb.critique`.
8. If review feedback arrives, run `/speckit.superb.respond`.
9. Once the work is verified and ready to integrate, run `/speckit.superb.finish`.

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
| `Implementing` | `before_implement` via `/speckit.superb.controller` | implementation has formally entered execution |
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

- `after_specify` → `brainstorm` (optional)
- `after_plan` → `plan-gate` (mandatory)
- `after_tasks` → `review` (optional)
- `before_implement` → `controller` (mandatory)
- `after_implement` → `verify` (mandatory)

## Hook Requirement Baseline

The baseline policy is conservative: required hooks protect claims that would
otherwise make implementation state untrustworthy; optional hooks improve
quality without owning the next Spec Kit stage.

| Hook | Command | Requirement | Baseline rationale |
|---|---|---|---|
| `after_specify` | `/speckit.superb.brainstorm` | Optional | Refines an existing spec, but simple features and teams that prefer direct clarification should not be blocked. |
| `after_plan` | `/speckit.superb.plan-gate` | Required | Plan quality is a core bridge guarantee; task lists and plans should not contain placeholders or coarse tasks. |
| `after_tasks` | `/speckit.superb.review` | Optional | Finds task/spec gaps and task-quality issues, but users may intentionally proceed with acknowledged gaps. |
| `before_implement` | `/speckit.superb.controller` | Required | Implementation discipline is a core bridge guarantee; production code should not begin without the TDD gate. |
| `after_implement` | `/speckit.superb.verify` | Required | Completion claims are not trustworthy without fresh verification evidence and spec coverage. |

Future strict modes may choose to require `after_tasks`, but the default
baseline keeps it optional so the bridge does not silently take over task
generation or planning ownership.

## Goal Mode Usage

In Codex Goal mode or another autonomous agent mode, optional hooks may be
shown as choices rather than executed automatically. If you want the agent to
run the full baseline workflow for a goal, opt in to the optional superb hooks
in the goal prompt.

Use this prompt pattern:

```text
Run this goal with the full Spec Kit + Superpowers Bridge baseline workflow.
Treat optional superb hooks as accepted for this goal: run `/speckit.superb.brainstorm` after `/speckit.specify` and run `/speckit.superb.review` after `/speckit.tasks` unless the required context is unavailable or I explicitly tell you to skip them.
Required superb hooks must still run: `/speckit.superb.controller` before implementation and `/speckit.superb.verify` after implementation.
Use `/speckit.superb.debug` when repeated failures or unexplained behavior appear, `/speckit.superb.critique` before PR/merge or after major implementation, `/speckit.superb.respond` for review feedback, and `/speckit.superb.finish` after verification when integration decisions are needed.
```

Short form:

```text
Use the full superb flow for this goal. Treat optional superb hooks as accepted for this goal, and run required superb hooks as gates.
```

This keeps the default extension policy conservative while giving a single
goal-level instruction for users who want the whole workflow.

## Configuration

`superb-config.template.yml` documents the intended bridge configuration shape
for discovery order, required skill sets, and standalone command toggles.
The current command prompts still use the documented defaults directly; the
template is not yet enforced as a live runtime config file. It does not define
remote fallbacks or bundled skill content.

## Requirements

- Spec Kit: `>=0.4.3`
- Installed superpowers-compatible skills discoverable from `./.agents/skills/`, `~/.agents/skills/`, or plugin-provided `skills/<name>/SKILL.md` directories under `./.agents/plugins/` / `~/.agents/plugins/`
- Optional: the `superpowers` tool, if you use it to install or manage those skills; the bridge itself relies on the installed skill content being present

## Artifact Ownership Model

Spec Kit owns creation, schema, lifecycle, and canonical meaning of
`spec.md`, `plan.md`, and `tasks.md`.

Superpowers Bridge may only refine, check, report, or synchronize within declared hook boundaries:

- `brainstorm` may apply user-approved refinements to the existing `spec.md`
  after Spec Kit creates it.
- `review`, `critique`, and `debug` report findings, drafts, or task packages;
  they do not own planning artifacts.
- `controller`, `verify`, and `finish` may synchronize only the bridge-owned lifecycle
  states documented below.

## Responsibility Boundaries

| Responsibility | Owner |
|---|---|
| Create `spec.md` and define its canonical structure | Spec Kit |
| Clarify unresolved spec decisions | Spec Kit |
| Apply approved refinements to an existing `spec.md` | Superpowers Bridge, under Spec Kit artifact ownership |
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
| `/speckit.superb.brainstorm` | Superpowers Bridge | existing `spec.md` | Refines a newly created spec through brainstorming discipline without creating another design document |
| `/speckit.superb.review` | Superpowers Bridge | `tasks.md` against `spec.md` / `plan.md` | Checks whether the generated task plan actually covers the spec and is specific enough for a strict TDD gate |
| `/speckit.superb.critique` | Superpowers Bridge | code diff against `spec.md` / `plan.md` / `tasks.md` | Reviews implementation output against declared requirements and implementation intent |

### `checklist` vs `analyze` vs Bridge Commands

| Command | Owner | Primary Focus | Solves |
|---|---|---|---|
| `/speckit.checklist` | Spec Kit | Requirements-writing quality | Tests whether requirements are complete, clear, consistent, measurable, and ready for implementation |
| `/speckit.analyze` | Spec Kit | Cross-artifact consistency | Detects contradictions, ambiguity, duplication, and missing links across `spec.md`, `plan.md`, and `tasks.md` |
| `/speckit.superb.review` | Superpowers Bridge | Coverage + TDD readiness | Determines whether `tasks.md` is implementation-ready and can support `before_implement` TDD enforcement |
| `/speckit.superb.controller` | Superpowers Bridge | Implementation discipline | Enforces RED-GREEN-REFACTOR once implementation begins |
| `/speckit.superb.verify` | Superpowers Bridge | Completion evidence | Blocks completion claims unless full verification evidence exists |
| `/speckit.superb.finish` | Superpowers Bridge | Integration handoff state | Moves the feature into `In Review` after PR creation or `Abandoned` after successful discard |

### Responsibility Map

```text
 /speckit.superb.check
     |
     +--> validates local superpowers skills and hook readiness

 /speckit.specify -> /speckit.clarify -> /speckit.checklist
        |                 |                  |
        +--> /speckit.superb.brainstorm
        |    optionally refines the active spec.md after creation
        |
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
        +--> /speckit.superb.controller
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
- Use `/speckit.superb.brainstorm` when the newly created spec needs broader
  design exploration before clarification or planning; do not use it to create
  a second design source.
- Use `/speckit.checklist` when you want to test the quality of the written requirements themselves.
- Use `/speckit.analyze` when you want a broad consistency check across `spec.md`, `plan.md`, and `tasks.md`.
- Use `/speckit.superb.review` when you specifically want to know whether `tasks.md` is complete enough and precise enough for strict TDD-driven implementation.
- Use `/speckit.superb.controller` and `/speckit.superb.verify` only around implementation, not during specification or planning.
- Use `/speckit.superb.critique` when the code itself, not just the planning artifacts, needs to be reviewed against the declared requirements.
- Use `/speckit.superb.debug` when you need root-cause investigation rather than another quick fix.
- Use `/speckit.superb.respond` after review comments arrive and you need a disciplined way to accept, reject, or clarify them.
- Use `/speckit.superb.finish` only after verification is complete and you are deciding how to integrate or preserve the branch.
- Read `In Review` as the current highest accurate PR-based lifecycle state; this bridge does not currently track final GitHub merge completion.

## License

MIT — see [LICENSE](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
