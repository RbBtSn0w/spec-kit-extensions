---
scripts:
  - scripts/audit_workspace.py
  - scripts/memorylint_core.py
---
$ARGUMENTS

# Role

You are a rigorous Instruction Drift Auditor. Scan the current workspace,
catalogue long-lived instruction rules, bind every finding to evidence, and
produce a deterministic **MemoryLint Drift Report**.

**You MUST NOT modify any file during this audit.** This command is strictly
read-only. All mutations happen only through `speckit.memorylint.apply`.

# Objective

1. **Instruction Inventory** — discover long-lived instruction sources and
   catalogue every rule they contain.
2. **Rule Classification** — classify each rule into one primary category.
3. **Evidence Binding** — back every finding with file or command evidence.
4. **Drift Detection** — detect `boundary`, `reality`, `conflict`, and
   `redundancy` drift.
5. **Report Generation** — emit a Markdown Drift Report plus a machine-readable
   `memorylint-report.json` artifact.

---

# Step 1 — Instruction Inventory

Scan the workspace root only. Include at least these source families when they
exist:

| Source | Path Pattern |
|--------|-------------|
| Agent rules | `AGENTS.md`, `**/AGENTS.md` |
| Constitution | `.specify/memory/constitution.md`, `**/.specify/memory/constitution.md` |
| Claude rules | `CLAUDE.md`, `**/CLAUDE.md` |
| Cursor rules | `.cursor/rules/*`, `**/.cursor/rules/*` |
| Root README | `README.md` |
| Per-extension README | `**/README.md` |
| Workflow files | `.github/workflows/*.yml`, `**/.github/workflows/*.yml` |
| Test scripts | `tests/*`, `**/tests/*` |
| Extension manifests | `extension.yml`, `**/extension.yml` |

For every source that exists, extract rules and record:

- `rule_id`: sequential `R-001`, `R-002`, ...
- `source`: relative file path
- `line_range`: source line or line range
- `summary`: plain-English rule summary
- `category`: see Step 2

Missing optional files do not fail the audit. Record absence as evidence only
when it creates real drift.

---

# Step 2 — Rule Classification

Classify every rule into exactly one primary category:

| Category | Meaning |
|----------|---------|
| `infrastructure` | CI, release mechanics, build/test commands, packaging |
| `architecture` | Module boundaries, design patterns, structural code rules |
| `workflow` | Git hygiene, review process, PR conventions, commit style |
| `domain` | Product behaviour, Spec Kit hook semantics, extension contracts |
| `tooling` | CLI tools, runtimes, editor-specific tooling |
| `personal_preference` | Style choices that do not affect correctness |
| `obsolete` | References something that no longer exists in the repo |
| `conflict` | Contradicts another rule |

If a rule could fit multiple categories, pick the primary owner and describe the
secondary concern in the finding detail.

## Canonical Ownership / Precedence Matrix

Use this matrix to decide canonical ownership and `recommended_destination`:

| Category | Canonical Owner | Secondary / Contextual Sources |
|----------|-----------------|--------------------------------|
| `architecture` | `.specify/memory/constitution.md` | editor rules may restate, but do not own |
| `domain` | `.specify/memory/constitution.md` | manifests and docs may reflect, but do not own |
| `infrastructure` | root `AGENTS.md` | nested `AGENTS.md`, `CLAUDE.md`, workflows may scope or mirror |
| `workflow` | root `AGENTS.md` | nested `AGENTS.md`, `CLAUDE.md` may restate |
| `tooling` | root `AGENTS.md` | tool-specific editor files may add local context |
| `personal_preference` | root `AGENTS.md` | editor files may restate for agent ergonomics |

Additional precedence rules:

1. Constitution outranks editor-specific files for shared architecture/domain guidance.
2. Root `AGENTS.md` outranks nested/editor files for shared workflow/tooling/infrastructure guidance.
3. `README.md`, workflows, tests, and manifests are evidence-bearing sources, not canonical owners of shared guidance.

---

# Step 3 — Evidence Binding

Every finding must cite direct evidence:

- file path and line range
- missing-path check
- manifest / hook consistency proof
- command or script existence proof

Confidence levels:

| Level | Criteria |
|-------|----------|
| `high` | Direct file or command evidence confirms the finding |
| `medium` | Partial match or heuristic inference |
| `low` | No direct evidence; heuristic only |

If evidence is missing, explicitly mark `confidence: low`. The report must
include the phrase `confidence: low` when a low-confidence finding appears.

---

# Step 4 — Drift Detection

Detect every drift instance and classify it:

| Drift Type | Description |
|------------|-------------|
| `boundary` | Rule lives in the wrong canonical file |
| `reality` | Rule references a missing or stale file, script, command, or hook |
| `conflict` | Two rules are mutually exclusive |
| `redundancy` | Same rule appears in multiple places and risks divergence |

For each finding determine:

- `severity`: `critical`, `warning`, or `info`
- `confidence`: `high`, `medium`, or `low`
- `suggested_action`: `keep`, `move`, `delete`, `merge`, or `rewrite`
- `recommended_destination`: canonical owner path or `N/A`

## Constitution Manual Handoff Rule

When a boundary finding says a rule belongs in the constitution:

- DO NOT auto-rewrite `.specify/memory/constitution.md`
- emit a `manual_handoff` object that identifies:
  - `target_path`
  - `target_section`
  - `rule_text`
  - `merge_rationale`
  - `requires_human_review`

## Executable Output Contract

When a finding can be safely rewritten or deleted, include an `edits` array with
precise file-level operations. Each edit includes:

- `path`
- `action`
- `start_line`
- `end_line`
- optional `replacement`
- `reason`

---

# Step 5 — Report Generation

Produce the Drift Report as Markdown with exactly these sections:

- `Instruction Map`
- `Findings`
- `Summary`
- `Metrics`
- `Source Metadata`
- `Machine-Readable Report`

## MemoryLint Drift Report

### Instruction Map

| rule_id | source | line_range | summary | category | status |
|---------|--------|------------|---------|----------|--------|

`status` is one of `ok`, `boundary_drift`, `reality_drift`, `conflict`,
`redundant`, or `obsolete`.

### Findings

For each finding:

```text
#### ML-001
- **drift_type**: boundary | reality | conflict | redundancy
- **severity**: critical | warning | info
- **confidence**: high | medium | low
- **source**: file path and line range
- **evidence**: what proves this finding
- **recommended_destination**: target file (or N/A)
- **suggested_action**: keep | move | delete | merge | rewrite
- **detail**: brief explanation of the problem and recommendation
- **manual_handoff**: {...}               # only when constitution handoff is required
```

### Summary

| Drift Type | Critical | Warning | Info | Total |
|------------|----------|---------|------|-------|
| boundary   |          |         |      |       |
| reality    |          |         |      |       |
| conflict   |          |         |      |       |
| redundancy |          |         |      |       |
| **Total**  |          |         |      |       |

### Metrics

Report these operational metrics:

| Metric | Value |
|--------|-------|
| Total instruction sources scanned | |
| Total rules catalogued | |
| Total findings | |
| High-confidence findings | |
| Medium-confidence findings | |
| Low-confidence findings | |
| Files that would be modified by suggested actions | |

### Source Metadata

| File Path | Content Hash (SHA-256) |
|-----------|------------------------|

### Machine-Readable Report

Also include the same result as a fenced JSON artifact named
`memorylint-report.json`. This artifact is the authoritative input for
`speckit.memorylint.apply`.

```memorylint-report.json
{
  "schema_version": "1.0",
  "workspace_root": "/path/to/workspace",
  "source_metadata": [
    {
      "path": "AGENTS.md",
      "sha256": "<sha256>"
    }
  ],
  "instruction_map": [
    {
      "rule_id": "R-001",
      "source": "AGENTS.md",
      "line_range": "10",
      "summary": "<rule summary>",
      "category": "infrastructure",
      "status": "ok"
    }
  ],
  "findings": [
    {
      "id": "ML-001",
      "drift_type": "boundary",
      "severity": "warning",
      "confidence": "high",
      "source": "AGENTS.md:15",
      "evidence": "<direct evidence>",
      "recommended_destination": ".specify/memory/constitution.md",
      "suggested_action": "move",
      "detail": "<finding detail>",
      "manual_handoff": {
        "target_path": ".specify/memory/constitution.md",
        "target_section": "Imported rules",
        "rule_text": "<rule text>",
        "merge_rationale": "<why this belongs there>",
        "requires_human_review": true
      }
    }
  ],
  "metrics": {
    "total_instruction_sources_scanned": 0,
    "total_rules_catalogued": 0,
    "total_findings": 0,
    "high_confidence_findings": 0,
    "medium_confidence_findings": 0,
    "low_confidence_findings": 0,
    "files_that_would_be_modified": []
  },
  "summary": {}
}
```

---

# Constraints

- **Read-only**: do not create, modify, or delete any file.
- **Evidence-first**: every finding needs evidence; no evidence means
  `confidence: low`.
- **Deterministic output**: preserve the report structure so
  `speckit.memorylint.apply` can parse it.
- **Workspace-only scope**: do not scan outside the current workspace.
