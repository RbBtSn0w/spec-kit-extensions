# Technical Plan: MemoryLint 2.0 (Phase 2)

## Problem
Currently, `MemoryLint` primarily moves "out-of-bounds" architecture rules from `AGENTS.md` to `constitution.md`. However, it doesn't deeply analyze whether the instructions *inside* `AGENTS.md` or `constitution.md` are contradictory, redundant, or obsolete.

## Proposed Solution: Semantic Auditing
Extend `MemoryLint` to perform a semantic analysis of the rules using an LLM.

### Features
- **Conflict Detection**: Identify rules that contradict each other (e.g., "Always use X" vs "Never use X").
- **Redundancy Pruning**: Merging rules that express the same intent with different wording.
- **Obsolescence Check**: Comparing rules against the current codebase state (e.g., a rule for a library that was removed).

## Technical Feasibility Verification

### 1. LLM-Based Analysis
Spec Kit already provides LLM capabilities. `MemoryLint` can use these via its hook prompts.

### 2. Implementation Path
- Update `memorylint/commands/run.md` to include "Semantic Audit" instructions.
- Add a new hook `after_constitution` to perform redundancy pruning after a new constitution is generated.

## Feasibility Test
This requires an LLM call. We can simulate this by providing a prompt that asks for conflict detection between two sample rules.
