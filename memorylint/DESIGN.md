# MemoryLint Design

MemoryLint is a review-first instruction drift checker for Spec Kit
repositories. It protects long-lived agent instruction sources from boundary,
reality, conflict, and redundancy drift without silently rewriting project
memory.

## Product Boundary

MemoryLint is not a general AI governance platform and is not a replacement for
Spec Kit's constitution. Its job is narrower:

- discover long-lived instruction sources in a workspace;
- classify rules by their intended ownership boundary;
- bind each drift finding to concrete file or command evidence;
- produce a reviewable report that a human can approve or reject;
- apply approved fixes only through an explicit, validated apply gate.

The first supported product surface is Spec Kit repositories that use
`AGENTS.md`, `.specify/memory/constitution.md`, and related agent instruction
files such as `CLAUDE.md` or `.cursor/rules/*`.

## Trust Model

MemoryLint's trust model is evidence-first and mutation-last.

- Audit is read-only. It must not create, edit, or delete files.
- Findings without direct evidence are low-confidence by default.
- Hooks only run read-only commands.
- Apply is never attached to lifecycle hooks.
- Apply requires a report, a source staleness check, previewed changes, and
  explicit user approval.
- If post-apply validation fails, every change from that apply run is reverted.

This keeps MemoryLint useful inside automated Spec Kit flows without giving it
silent authority over long-lived project memory.

## Audit Pipeline

The audit command follows a deterministic conceptual pipeline:

1. **Instruction Inventory**: scan instruction sources such as `AGENTS.md`,
   `.specify/memory/constitution.md`, `CLAUDE.md`, `.cursor/rules/*`, README
   files, workflows, tests, and extension manifests.
2. **Rule Classification**: classify each rule as `infrastructure`,
   `architecture`, `workflow`, `domain`, `tooling`, `personal_preference`,
   `obsolete`, or `conflict`.
3. **Evidence Binding**: attach file-path, line-range, directory, or command
   evidence to each finding.
4. **Drift Detection**: detect `boundary`, `reality`, `conflict`, and
   `redundancy` drift.
5. **Report Generation**: emit both a human-readable Markdown report and a
   machine-readable `memorylint-report.json` artifact.

## Machine-Readable Report

`memorylint-report.json` is the authoritative apply input. Markdown is for
reviewers; JSON is for tooling.

Required top-level fields:

```json
{
  "schema_version": "1.0",
  "workspace_root": "/path/to/workspace",
  "source_metadata": [],
  "instruction_map": [],
  "findings": [],
  "metrics": {}
}
```

`source_metadata` records SHA-256 hashes for scanned source files. The apply
gate compares these hashes against current file content before modifying any
file. This prevents applying stale findings after instruction files have
changed.

## Apply Gate

Apply has three modes:

- `report-only`: default; display the report summary and make no changes.
- `apply-safe-fixes`: apply only high-confidence non-architectural fixes, such
  as stale reference removal or exact duplicate cleanup.
- `apply-all-approved`: apply explicitly approved fixes after preview.

Safe mode must not move architecture or domain rules, rewrite semantics, delete
constitution-owned rules, or apply medium/low-confidence findings.

Post-apply validation checks:

- `AGENTS.md` integrity and critical section preservation;
- constitution rule preservation;
- extension hook consistency;
- repository validation commands from `AGENTS.md`, or `git diff --check` as a
  fallback.

## Regression Corpus

The fixture corpus under `memorylint/tests/fixtures/` is the executable product
contract. It covers:

- clean baseline repositories;
- boundary drift in `AGENTS.md` and editor rules;
- stale script and command references;
- conflicting commit policies;
- redundant rules across root, nested, Claude, and constitution sources;
- missing constitution handling;
- hook breakage after command renames.

`memorylint/scripts/scan_fixtures.py --check` must generate findings that match
each fixture's `expected-findings.json`. This turns the design from a prompt-only
contract into a deterministic regression gate.

## Release Criteria

MemoryLint changes are ready to ship only when:

- command metadata and hook wiring are valid;
- audit/apply/load-agents prompts preserve their safety contracts;
- fixture schemas are valid;
- deterministic fixture scanning matches expected findings;
- repository workflow tests and whitespace checks pass.
