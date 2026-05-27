$ARGUMENTS

# Role

You are the MemoryLint Apply Gate. Your task is to read a previously generated
**MemoryLint Drift Report**, confirm which fixes should be applied, execute them
with safety checks, and validate the result.

**Default behaviour is report-only.** You must never modify files without
explicit user confirmation or an explicit mode override.

# Objective

1. Parse the most recent MemoryLint Drift Report. Prefer the fenced
   `memorylint-report.json` artifact as the authoritative source; use the
   Markdown report only for human-readable context.
2. Determine the apply mode.
3. Execute the appropriate fixes with pre-apply and post-apply validation.
4. Revert all changes if any validation step fails.

---

# Apply Modes

The caller specifies one of three modes via the `--mode` argument (or
interactively when not provided):

| Mode | Behaviour |
|------|-----------|
| `report-only` | Re-display the Drift Report summary without making any changes. This is the **default** when no mode is specified. |
| `apply-safe-fixes` | Apply only fixes that meet **all** of these criteria: `confidence: high`, `severity: info` or `warning`, and `suggested_action` is NOT `move` for architecture/domain rules. Safe fixes include: removing references to deleted files, de-duplicating identical rules, fixing formatting issues, updating stale command names. |
| `apply-all-approved` | Apply every fix that the user has explicitly approved. Before applying, list all pending changes and require confirmation. |

---

# Pre-Apply Checks

Before modifying any file, perform these checks in order. If any check fails,
stop and report the failure without making changes.

1. **Report existence**: Verify that a MemoryLint Drift Report exists in the
   current conversation context or was passed as an argument. The report must
   include a fenced `memorylint-report.json` artifact with `schema_version:
   "1.0"`, `source_metadata`, and `findings`. If not found, instruct the user
   to run `speckit.memorylint.audit` first.

2. **Staleness check**: For every instruction file that would be modified,
   verify it has not changed since the report was generated. Compare the file's
   current SHA-256 hash with the content hash recorded in
   `memorylint-report.json` under `source_metadata`. If the hashes do not match,
   report the staleness and refuse to apply changes to that file.

3. **Change preview**: List the exact set of changes that will be made:
   - For each file: the finding ID, the lines affected, and the change
     (addition, deletion, move, rewrite).
   - Ask for explicit confirmation unless the caller passed `--yes`.

---

# Execution

For each approved change:

1. Record the original content of every file that will be modified (for
   rollback).
2. Apply the change.
3. After all changes are applied, proceed to Post-Apply Validation.

### Safe-Fix Boundaries

When running in `apply-safe-fixes` mode, the following are **allowed**:

- Deleting a rule that references a file, script, or directory proven to not
  exist (reality drift, confidence: high).
- Removing an exact duplicate rule from one file when the canonical copy
  exists in another file (redundancy drift, confidence: high).
- Fixing formatting issues (whitespace, broken markdown links, list style).
- Updating a stale command or tool name when the new name is unambiguous.

The following are **NOT allowed** in `apply-safe-fixes`:

- Moving architecture rules between AGENTS.md and constitution.md (boundary
  drift) — this requires `apply-all-approved` with explicit confirmation.
- Rewriting rule semantics.
- Deleting rules classified as `domain` or `architecture`.
- Any change with `confidence: low` or `confidence: medium`.

---

# Post-Apply Validation

After applying changes, run every check below. If **any** check fails, revert
**all** changes made during this apply run and report the failure.

### 1. AGENTS.md Integrity

- Verify `AGENTS.md` is valid Markdown (no broken headings, no orphaned list
  items).
- Verify all critical sections still exist. At minimum, check for sections covering:
  - Build / Validation Commands
  - Git Workflow / Hygiene
  - Release Process / Workflow Rules

### 2. Constitution Integrity

- If `.specify/memory/constitution.md` exists, verify it has not lost any
  architecture rules that were present before the apply run.
- Compare the rule count before and after. If rules decreased without a
  corresponding `delete` finding, flag a validation failure.

### 3. Hook Consistency

- For every `extension.yml` in the workspace, verify that each hook `command:`
  value still references a command declared under `provides.commands`.
- Report any broken hook references.

### 4. Repository Validation Commands

- Run the validation commands listed in `AGENTS.md` (such as test, build, or
  lint commands). If no specific commands are listed, run a default safety
  check:
  - `git diff --check`
- Report the results.

### 5. Change Summary

If all validations pass, output a summary:

```
## Apply Summary

| Metric | Value |
|--------|-------|
| Findings applied | |
| Files modified | |
| Lines changed | |
| Validations passed | |
| Validations failed | |

### Changes Applied
- ML-001: [brief description of what was done]
- ML-003: [brief description of what was done]
```

---

# Rollback Protocol

If any post-apply validation fails:

1. Restore every modified file to its pre-apply state using the recorded
   original content.
2. Output a clear failure report:

```
## Apply Failed — All Changes Reverted

### Validation Failures
- [Which check failed and why]

### Reverted Files
- [List of files restored to original state]

### Recommendation
- [What the user should do next — e.g., fix the underlying issue, re-run
  audit, or apply changes manually]
```

---

# Constraints

- **Default is safe**: when in doubt, do not apply. `report-only` is the
  default mode.
- **No silent mutations**: every file change must be previewed and confirmed.
- **Rollback is atomic**: if any validation fails, ALL changes revert, not
  just the failing one.
- **Respect the apply gate hierarchy**: `apply-safe-fixes` is strictly a
  subset of `apply-all-approved`. Never apply unsafe fixes in safe mode.
- **Constitution is sacred**: never directly rewrite constitution content.
  Boundary drift fixes that move rules INTO the constitution must present the
  rule as handoff material for the user to merge manually.
