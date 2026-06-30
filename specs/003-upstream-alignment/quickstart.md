# Quickstart / Validation Guide: Upstream Alignment

**Feature**: 003-upstream-alignment | **Date**: 2026-06-30

Run from repo root. These scenarios prove each user story end-to-end. They follow the existing
shell-based test convention in `memorylint/tests/` and `superpowers-bridge/tests/`.

## Prerequisites

- Python 3.10+ with PyYAML available (MemoryLint scripts).
- `bash` test harness (existing `*.sh` tests).

## US1 — MemoryLint skips managed blocks and fails safe

1. **Fixture**: an `AGENTS.md` with real rules plus a block:
   ```
   <!-- SPECKIT START -->
   - Plan: specs/003-upstream-alignment/plan.md
   <!-- SPECKIT END -->
   ```
   and an `.specify/extensions/agent-context/agent-context-config.yml` with
   `context_files: [AGENTS.md]` (also test the singular `context_file` form).

2. **Extraction (C3)**: run the audit scanner; assert no `Rule`/finding references the
   `- Plan: …` line and no finding cites the markers.

3. **Plural files (US1-3)**: add a `CLAUDE.md` with its own block; assert the block is skipped
   there too.

4. **Apply staleness (C5)**: produce an audit report, then mutate `AGENTS.md` (simulate an
   agent-context update inserting/resizing the block), then run apply; assert apply exits non-zero
   with a message instructing re-audit and writes nothing.

5. **Unterminated block (C4)**: fixture with a start marker but no end marker; assert extraction
   skips to EOF and a warning naming the file is emitted; no edit targets that region.

6. **Invariance (C6)**: remove the agent-context config and blocks; assert audit/apply output is
   identical to the pre-feature baseline.

Expected: SC-001 (all findings/edits outside blocks), SC-002 (zero wrong-line writes).

## US2 — Converge output flows into the evidence gate

1. Assert `superpowers-bridge/extension.yml` declares `hooks.after_converge` → `speckit.superb.verify`
   with `optional: false` (parseable YAML; mirror the assertion style of existing manifest tests).
2. Simulate hook dispatch resolution: given an `.specify/extensions.yml` containing the bridge's
   `after_converge` entry, assert the dispatch contract yields `EXECUTE_COMMAND: speckit.superb.verify`.
3. Assert that with no bridge entry, no after_converge command is emitted (FR-009).

Expected: SC-003.

## US3 — Review focuses on quality/TDD, defers coverage to converge

1. Assert `review.md`'s decision table routes coverage-gap remediation to `/speckit-converge`
   and retains BLOCKED outcomes for plan↔task mismatch and TDD-readiness failures.
2. Assert the bridge README documents the review-vs-converge boundary.

Expected: SC-004.

## US4 — Config and catalog reflect opt-in reality

1. Assert README(s) and `.specify/extensions.yml` comments state agent-context is opt-in.
2. Assert `catalog.json` `requires.speckit_version` for both extensions declares the verified range.

Expected: SC-005.

## Full suite

Run both extensions' test suites; all MUST pass (SC-006):

```bash
for t in memorylint/tests/*.sh superpowers-bridge/tests/*.sh; do bash "$t"; done
```
