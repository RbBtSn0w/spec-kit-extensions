# MemoryLint

Evidence-driven instruction drift checker for Spec Kit.

MemoryLint audits long-lived agent instruction files — `AGENTS.md`, `.specify/memory/constitution.md`, `CLAUDE.md`, `.cursor/rules/`, and other sources — to detect boundary violations, stale references, conflicts, and redundancies. Every finding is backed by concrete evidence so reviewers can trust the report before applying any changes.

## Problem Statement

In Spec-Driven Development (SDD), AI agents rely on long-lived instruction files:

1. `AGENTS.md`: Infrastructure rules, environment setup, and workflow standards.
2. `.specify/memory/constitution.md`: Architecture decisions, code paradigms, and safety constraints.
3. Additional sources: `CLAUDE.md`, `.cursor/rules/`, `README.md`, workflow configs.

Over time, these files drift:

- **Boundary drift**: Architecture rules leak into `AGENTS.md`, or workflow rules end up in the constitution.
- **Reality drift**: Rules reference scripts, tools, or directories that no longer exist.
- **Conflict drift**: Two files give contradictory instructions.
- **Redundancy drift**: The same rule appears in multiple files, risking future divergence.

## Solution: Evidence-Driven Drift Checking

MemoryLint follows a strict pipeline that separates audit from apply:

```text
┌─────────────────────┐
│ Instruction Inventory│  Scan all long-lived instruction sources
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Rule Classification  │  Categorise each rule (8 categories)
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Evidence Binding     │  Attach file/command proof to every finding
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Drift Detection      │  Detect boundary, reality, conflict, redundancy
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Drift Report         │  Structured, reviewable report (read-only)
│                     │  Markdown + memorylint-report.json
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Human Apply Gate     │  3-tier: report-only / safe-fixes / all-approved
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Post-Apply Validation│  Integrity checks + automatic rollback on failure
└─────────────────────┘
```

## Commands

| Command | Type | Purpose |
|---|---|---|
| `speckit.memorylint.audit` | Hookable | Scan instruction files and generate an evidence-bound Drift Report. Read-only — never modifies files. |
| `speckit.memorylint.apply` | Manual | Apply approved fixes from a previous audit report. Supports three apply modes with post-apply validation and rollback. |
| `speckit.memorylint.load-agents` | Hookable | Mandatory gate: load `AGENTS.md` into context before planning to prevent rule drift. |

## Hook Integration

This extension registers the following Spec Kit lifecycle hooks:

| Hook | Command | Required? | Purpose |
|------|---------|-----------|---------|
| `before_constitution` | `audit` | Optional | Generate a boundary report before constitution generation |
| `after_constitution` | `audit` | Optional | Check for conflicts between constitution and AGENTS.md |
| `before_plan` | `load-agents` | **Mandatory** | Load AGENTS.md to enforce core rules before plan generation |

Key design constraint: hooks only run **read-only** operations. The `apply` command is never wired to a hook — it is always an explicit user action.

## Apply Modes

| Mode | Behaviour |
|------|-----------|
| `report-only` | Default. Re-display the report summary without making changes. |
| `apply-safe-fixes` | Apply only high-confidence, non-architectural fixes: dead reference removal, deduplication, formatting. |
| `apply-all-approved` | Apply every fix the user has explicitly approved. Requires confirmation. |

After applying, MemoryLint validates:

1. `AGENTS.md` structural integrity (critical sections preserved).
2. Constitution rule preservation (no accidental deletions).
3. Hook reference consistency (all `extension.yml` hooks still valid).
4. Repository validation commands pass.

If any validation fails, **all changes are automatically reverted**.

## Report Contract

Every audit produces two synchronized outputs:

- A human-readable Markdown Drift Report for review.
- A fenced `memorylint-report.json` artifact that tools can parse.

The JSON artifact is the authoritative input for `speckit.memorylint.apply`.
It includes `schema_version`, `source_metadata`, `instruction_map`, `findings`,
and `metrics`. `source_metadata` records SHA-256 hashes for scanned files so the
apply gate can reject stale reports before changing anything.

## Rule Classification

Every rule is classified into one of eight categories:

| Category | Meaning |
|----------|---------|
| `infrastructure` | CI, packaging, release mechanics, build/test commands |
| `architecture` | Directory layout, module boundaries, design patterns |
| `workflow` | Git hygiene, review process, commit conventions |
| `domain` | Product behaviour, Spec Kit hook semantics |
| `tooling` | CLI tools, language runtimes, editor config |
| `personal_preference` | Style choices that do not affect correctness |
| `obsolete` | References something that no longer exists |
| `conflict` | Contradicts another rule |

## Trust Metrics

Every audit report includes a metrics section tracking:

| Metric | Purpose |
|--------|---------|
| High-confidence finding acceptance rate | Measures report accuracy |
| False positive rate | Must stay low to maintain trust |
| Suggested diff apply rate | Tracks actionability |
| Real stale/conflicting rules found | Measures value delivered |
| Destructive surprise edits | Must be **zero** |

## Regression Corpus

MemoryLint includes a regression corpus of nine fixture repos under `tests/fixtures/`:

| Fixture | Tests |
|---------|-------|
| `clean-repo` | Zero findings baseline |
| `bloated-agents` | Boundary drift detection |
| `stale-command` | Reality drift detection |
| `conflicting-rules` | Conflict drift detection |
| `redundant-rules` | Redundancy drift detection |
| `missing-constitution` | Graceful handling of absent files |
| `monorepo-nested` | Nested instruction file support |
| `multi-source` | Multi-tool instruction scanning |
| `post-apply-breakage` | Apply safety validation |

The fixture corpus is executable. `memorylint/scripts/scan_fixtures.py --check`
generates deterministic findings for every fixture and compares them with each
fixture's `expected-findings.json`.

## Design

See [DESIGN.md](DESIGN.md) for the product boundary, trust model, audit/apply
pipeline, machine-readable report contract, and release criteria.

## Installation

### Install from ZIP (Recommended)

```bash
specify extension add memorylint --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/memorylint-v1.4.0/memorylint.zip
```

### Install from GitHub Repository (Development)

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions
specify extension add --dev ./memorylint
```

## Requirements

- Spec Kit: `>=0.5.1`

## License

MIT — see [LICENSE](LICENSE).
