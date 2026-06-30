# Contract: MemoryLint Managed-Block Handling

**Surface**: `memorylint/scripts/memorylint_core.py` (rule extraction) and
`memorylint/scripts/apply_report.py` (apply gate). These are internal Python module contracts
consumed by the `audit`/`apply` commands.

## C1 — Managed-block config resolution

```
resolve_managed_block_config(workspace_root) -> ManagedBlockConfig
```

- Reads `.specify/extensions/agent-context/agent-context-config.yml` if present.
- `managed_files`: `context_files` (list) if present; else `[context_file]` if present; else `[]`.
- Markers: from `context_markers.{start,end}`; default to the agent-context extension's own
  documented defaults `<!-- SPECKIT START -->` / `<!-- SPECKIT END -->` when
  missing/unreadable/invalid. These exact strings are authoritative (per the
  `speckit.agent-context.update` command docs) and MUST be the shared constant used by code and
  test fixtures alike.
- MUST NOT raise on missing file or invalid YAML — returns defaults with empty `managed_files`.
- A configured-but-absent context file path MUST be treated as having no managed block (no error).

## C2 — Block detection

```
managed_block_ranges(text, config) -> list[ManagedBlockRange]
```

- Returns every `[start_line, end_line]` (1-based, inclusive) bounded by the marker pair.
- An unterminated start marker yields one range to EOF with `terminated=False`.
- Returns `[]` when no start marker is present.

## C3 — Extraction exclusion (FR-001, FR-002)

`markdown_rules()` MUST skip any line within a `ManagedBlockRange` for files that are managed
(in `managed_files`) or that physically contain the start marker.

**Guarantees**:
- No `Rule` originates inside a managed block → no finding cites it (FR-001).
- No `Edit` can target a managed-block line, since edits derive from `Rule.line_range` (FR-002).

## C4 — Unterminated block (FR-006)

When a block is `terminated=False`, extraction skips from the start marker to EOF and the audit
output MUST include a warning naming the file. No edit may target the affected region.

## C5 — Apply staleness refusal (FR-004)

Unchanged behavior, improved message: when a target file's current SHA256 differs from the audit
`source_metadata` hash, apply MUST refuse to write all edits and print a failure that explicitly
instructs the user to re-run `/speckit-memorylint-audit`. Exit non-zero.

## C6 — No-agent-context invariance (FR-005)

When `managed_files` is empty and no scanned file contains the markers, extraction and apply
behave byte-for-byte as before this feature.
