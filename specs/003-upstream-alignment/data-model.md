# Phase 1 Data Model: Upstream Alignment

**Feature**: 003-upstream-alignment | **Date**: 2026-06-30

This feature is tooling logic, not a persistence layer. The "entities" below are the in-memory
and on-disk structures the changes operate on.

## ManagedBlockConfig (new, MemoryLint)

Resolved configuration describing where agent-context managed blocks live.

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `start_marker` | str | `agent-context-config.yml` `context_markers.start` | Default `<!-- SPECKIT START -->` |
| `end_marker` | str | `agent-context-config.yml` `context_markers.end` | Default `<!-- SPECKIT END -->` |
| `managed_files` | list[str] | `context_files` (plural, preferred) → `context_file` (singular, fallback) | Empty when config absent |

**Authoritative default markers**: `<!-- SPECKIT START -->` / `<!-- SPECKIT END -->` are the
agent-context extension's own documented defaults (its `speckit.agent-context.update` command:
"Defaults to `<!-- SPECKIT START -->` and `<!-- SPECKIT END -->` when the field is missing"), and
match this repo's current `.specify/extensions/agent-context/agent-context-config.yml`. These exact
strings MUST be reused as the constants in code and test fixtures — they MUST NOT be reinvented, so
block-skipping matches real agent-context output.

**Resolution rules**:
- Read `.specify/extensions/agent-context/agent-context-config.yml` if present.
- `managed_files` = values from `context_files` if present, else `[context_file]` if present, else `[]`.
- Markers fall back to defaults when missing/unreadable/invalid YAML.
- A scanned file is block-filtered if it is in `managed_files` **or** physically contains
  `start_marker` (defensive).

## ManagedBlockRange (new, MemoryLint)

A line span to exclude during extraction, computed per file.

| Field | Type | Notes |
|-------|------|-------|
| `start_line` | int | 1-based line of `start_marker` (inclusive) |
| `end_line` | int | 1-based line of `end_marker` (inclusive); EOF if unterminated |
| `terminated` | bool | False when no matching end marker found → triggers FR-006 warning |

**Rules**: Multiple blocks per file are allowed. Lines within any `[start_line, end_line]` are
excluded from `markdown_rules()` output. An unterminated block extends to EOF and emits a warning.

## Rule (existing, memorylint_core.py:41) — unchanged shape, narrowed population

No field change. The only behavioral change: `markdown_rules()` MUST NOT emit a `Rule` whose
source line falls inside a `ManagedBlockRange`.

## SourceMetadata / Staleness (existing, memorylint_core.py:421) — unchanged

`source_metadata` already records a per-file `sha256` captured at audit time; `apply_report.py`
compares it to the current file hash and refuses to write on mismatch. This feature reuses it as
the apply-time location-safety guarantee (R3); only the failure message wording changes.

## AfterConvergeHook (new, Superpowers Bridge manifest)

Declarative hook entry added to `superpowers-bridge/extension.yml`.

| Field | Value |
|-------|-------|
| hook key | `after_converge` |
| `command` | `speckit.superb.verify` |
| `optional` | `false` (mandatory) |
| `description` | Evidence-first verification gate after convergence-appended tasks |

Activated only when the bridge is installed (the entry is merged into the consuming project's
`.specify/extensions.yml`). Absent bridge → no entry → converge unaffected (FR-009).

## CatalogRequirement (existing, catalog.json) — value update

`extensions.<id>.requires.speckit_version` updated to a range verified against converge and the
0.12 agent-context opt-in, for both `superb` and `memorylint`. No schema change.
