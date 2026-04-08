# MemoryLint

MemoryLint is a Spec-kit extension designed for AI memory governance and boundary checking. 

## Problem Statement
In Spec-Driven Development (SDD), AI Agents rely on two core long-term memory files:
1. `AGENTS.md`: For general infrastructure, environment variables, and workflow standards.
2. `.specify/memory/constitution.md`: For project core architecture decisions, code paradigms, and safety constraints.

Over time, developers or AI assistants may mistakenly write "architectural constraints" into the global `AGENTS.md`. This causes blurred boundaries, context overload, and loss of a single source of truth.

## Solution
MemoryLint hooks into the `before_constitution` lifecycle. Before updating the constitution, it automatically audits `AGENTS.md`, extracts out-of-bounds architectural specifications, cleans up `AGENTS.md`, and seamlessly hands over the extracted specifications to `constitution.md` via conversational context.

## Usage
When you run `/speckit constitution`, the system will prompt:
`Run MemoryLint to audit and clean up out-of-bounds architectural specifications in AGENTS.md? (y/n)`

If you select `y`, the audit will run, and the extracted rules will be incorporated into the new constitution.
