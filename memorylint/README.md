# MemoryLint

MemoryLint is a Spec-kit extension designed for AI memory governance and boundary checking. 

This extension serves as an "infrastructure guardian," ensuring that project-specific architecture rules stay in the constitution, while automatically supplementing missing general workflows in the global agent configuration.

## Problem Statement
In Spec-Driven Development (SDD), AI Agents rely on two core long-term memory files:
1. `AGENTS.md`: For general infrastructure, environment variables, and workflow standards.
2. `.specify/memory/constitution.md`: For project core architecture decisions, code paradigms, and safety constraints.

Over time, developers or AI assistants may mistakenly write "architectural constraints" into the global `AGENTS.md`. This causes blurred boundaries, context overload, and loss of a single source of truth.

## Solution: Bidirectional Governance

MemoryLint hooks into the `before_constitution` lifecycle to perform bidirectional governance:
1. **Prune (Clean up)**: Automatically audits `AGENTS.md`, extracts out-of-bounds architectural specifications, and seamlessly hands them over to `constitution.md` via conversational context.
2. **Enrich (Supplement)**: Analyzes the workspace (e.g., `package.json`, `Makefile`) to infer and supplement `AGENTS.md` with missing essential infrastructure guidelines (like standard test/build commands or Git commit conventions).

## Workflow Architecture

```text
  [ Developer / AI Agent ]                [ AI Agent Execution Engine ]             [ Local File System ]
           │                                 │                                     │
           │ 1. Trigger Pre-hook             │                                     │
           │ > /speckit.memorylint...        │                                     │
           ├───────────────────────────────> │ Read check-boundaries.md (Prompt)   │
           │                                 │                                     │
           │                                 │ ─── (Action 1) Tool: read_file ───> │ 📄 AGENTS.md (Bloated)
           │                                 │ <── Return file content ────────────│
           │                                 │                                     │
           │                                 │ (Action 2) LLM: Identify & Extract  │
           │                                 │            Architecture Rules       │
           │                                 │                                     │
           │                                 │ (Action 3) LLM: Infer & Enrich      │
           │                                 │            Infrastructure Rules     │
           │                                 │                                     │
           │                                 │ ─── (Action 4) Tool: write_file ──> │ 📄 AGENTS.md (Governed)
           │                                 │     (Remove rules, Add missing info)│
           │                                 │                                     │
           │ 2. Hook exits, context ready    │                                     │
           │ <───────────────────────────────┤ (Output Protocol)                   │
           │ [Prints Markdown list to UI/CTX]│ Forces extracted rules into chat    │
           │ "### Extracted Rules..."        │ history (Short-term LLM memory)     │
           │                                 │                                     │
═══════════╪═════════════════════════════════╪═════════════════════════════════════╪═══════════════════
           │                                 │                                     │
           │ 3. Trigger Main Command         │                                     │
           │ > /speckit constitution         │                                     │
           ├───────────────────────────────> │ Read constitution prompt            │
           │                                 │ + retrieve extracted rules from ctx │
           │                                 │                                     │
           │                                 │ LLM: Merge old constitution with    │
           │                                 │      newly extracted rules          │
           │                                 │                                     │
           │                                 │ ─── Tool: write_file ─────────────> │ 📄 constitution.md
           │                                 │                                     │
═══════════╪═════════════════════════════════╪═════════════════════════════════════╪═══════════════════
           │                                 │                                     │
           │ 4. Trigger Plan Pre-hook        │                                     │
           │ > /speckit.memorylint.load-agents │ (Mandatory load-agents gate)     │
           ├───────────────────────────────> │ Read load-agents.md                │
           │                                 │ ─── (Action) Tool: read_file ─────> │ 📄 AGENTS.md (Governed)
           │                                 │ <── Return core rules context ──────│
           │                                 │                                     │
           │ 5. Trigger Planning Command     │                                     │
           │ > /speckit plan                 │                                     │
           ├───────────────────────────────> │ Read plan prompt                    │
           │                                 │ + retrieve core rules from ctx      │
           │                                 │                                     │
           │                                 │ LLM: Generate plan & tasks          │
           │                                 │      strictly following rules       │
           │                                 │                                     │
           │                                 │ ─── Tool: write_file ─────────────> │ 📄 plan.md / tasks.md
           │                                 │                                     │
```

## Features

- **Boundary Auditing**: Detects architecture leakage in `AGENTS.md`.
- **Context Handoff**: Passes extracted rules cleanly without destructive overwrites of `constitution.md`.
- **Infrastructure Enrichment**: Automatically detects missing test/build/git workflows and injects them into `AGENTS.md`.

## Installation

### Install from ZIP (Recommended)

Install directly from the release asset:

```bash
specify extension add memorylint --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/memorylint-v1.3.0/memorylint.zip
```

### Install from GitHub Repository (Development)

Clone the collection repository and install the extension folder locally:

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions
specify extension add --dev ./memorylint
```

## Commands

| Command | Type | Purpose |
|---|---|---|
| `/speckit.memorylint.run` | Hookable | Prune out-of-bounds rules and enrich missing infrastructure guidelines in `AGENTS.md`. |
| `/speckit.memorylint.load-agents` | Hookable | Mandatory gate: Load `AGENTS.md` to enforce core rules before planning. |

*(Note: If the interactive hook is skipped in non-TTY environments, you can manually trigger `/speckit.memorylint.run` before running `/speckit constitution`.)*

## Hook Integration

This extension registers the following hooks:

- `before_constitution` → `run` (optional)
- `before_plan` → `load-agents` (mandatory)

## Usage / Execution Flow

When you run `/speckit constitution`, the system will intercept the process and prompt:

```text
Run MemoryLint to prune out-of-bounds architecture rules and enrich missing infrastructure guidelines in AGENTS.md? (y/n)
```

- **If you select `y`**: The audit will run, govern `AGENTS.md`, and the extracted rules will be incorporated into the new constitution seamlessly.
- **If you select `n`**: The hook is bypassed and the standard constitution generation proceeds.

When you run `/speckit plan`, the system will automatically execute the `load-agents` hook:

- **Mandatory Gate**: The system will read your `AGENTS.md` file and acknowledge its core rules before starting the planning process. This ensures that the generated `plan.md` and `tasks.md` strictly adhere to your workspace's architectural constraints without needing manual confirmation.

## Requirements

- Spec Kit: `>=0.5.1`

## License

MIT — see [LICENSE](LICENSE).
