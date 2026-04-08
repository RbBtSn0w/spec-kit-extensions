# Superpowers Bridge

Orchestrates selected [obra/superpowers](https://github.com/obra/superpowers) skills inside the Spec Kit SDD workflow.

This extension combines:

- **Hook-based guardrails** for core Spec Kit commands (`specify`, `tasks`, `implement`), and
- **Standalone operational commands** for debugging, review response, and branch completion.

## Workflow Architecture

```text
  [ Developer Workflow ]                               [ Superpowers Bridge Hooks & Commands ]
           │
           ├── (Optional) /speckit.superb.clarify ───> 🧠 Brainstorming & Intent Clarification
           │
 ┌─────────▼─────────┐
 │ /speckit specify  │ 
 └─────────┬─────────┘
           │
 ┌─────────▼─────────┐
 │ /speckit tasks    │
 └─────────┬─────────┘
           │
           ├── (Optional) /speckit.superb.review ────> 🔍 Spec-Coverage Gap Analysis
           │
           ├── (Mandatory) /speckit.superb.tdd ──────> 🔴 RED-GREEN-REFACTOR Enforcer
           │
 ┌─────────▼─────────┐
 │ /speckit implement│
 └─────────┬─────────┘
           │
           ├── (Mandatory) /speckit.superb.verify ───> ✅ Evidence-Based Completion Gate
           │
           ▼
  [ Standalone Utilities ]
   ├─ /speckit.superb.debug   ──> 🐛 Systematic root-cause investigation
   ├─ /speckit.superb.critique──> 📝 Independent spec-aligned code review
   ├─ /speckit.superb.respond ──> 💬 Rigorous review feedback implementation
   └─ /speckit.superb.finish  ──> 🏁 Branch completion & merge strategy
```

## Features

- Pre-spec intent clarification (`clarify`)
- Mandatory TDD gate before implementation (`tdd`)
- Task/spec coverage check (`review`)
- Mandatory evidence-based completion gate (`verify`)
- Spec-aligned reviewer role (`critique`)
- Root-cause debugging escalation (`debug`)
- Structured branch completion options (`finish`)
- Technical response workflow for review feedback (`respond`)

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

## Commands

| Command | Type | Purpose |
|---|---|---|
| `/speckit.superb.clarify` | Hookable | Run brainstorming-style clarification before writing spec |
| `/speckit.superb.tdd` | Hookable | Enforce RED-GREEN-REFACTOR before code changes |
| `/speckit.superb.review` | Hookable | Check `tasks.md` covers `spec.md` requirements |
| `/speckit.superb.verify` | Hookable | Block completion claims without fresh evidence |
| `/speckit.superb.critique` | Standalone | Independent spec-aligned code review |
| `/speckit.superb.debug` | Standalone | Systematic root-cause debugging |
| `/speckit.superb.finish` | Standalone | Post-verify branch completion workflow |
| `/speckit.superb.respond` | Standalone | Process and implement review feedback rigorously |

## Hook Integration

This extension registers the following hooks:

- `before_specify` → `clarify` (optional)
- `after_tasks` → `review` (optional)
- `before_implement` → `tdd` (mandatory)
- `after_implement` → `verify` (mandatory)

## Configuration

This extension currently has **no required runtime configuration**.

A placeholder `superb-config.template.yml` is included for future extension options and
for consistency with the Spec Kit extension template.

## Requirements

- Spec Kit: `>=0.4.3`
- Optional tool: `superpowers >=5.0.0`

## License

MIT — see [LICENSE](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
