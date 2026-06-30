---
description: >
  Code review response protocol. Bridges an installed obra/superpowers
  receiving-code-review skill. Enforces technical verification before
  implementing review feedback — no performative agreement, no blind fixes.
  Pairs with speckit.superb.critique as the implementer counterpart.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
---

# Respond — Receiving Code Review Feedback

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `receiving-code-review`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call after receiving output from `speckit.superb.critique` or any external code review.

---

## Role Boundary

`respond` is not a reviewer. `critique` or an external reviewer produces findings;
`respond` receives those findings, checks them against the codebase and
`spec.md`, then accepts, rejects, clarifies, or implements them.

Do not use this command to create the original review. Use
`/speckit.superb.critique` when review findings do not already exist.

---

## Step 1 — Resolve Installed Skill

Run `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill receiving-code-review`.

The resolver is the canonical discovery helper for this bridge. It checks, in
order, direct workspace installs, workspace plugin installs, direct global
installs, then global plugin installs.

If no readable file is found, enter the **inline install recovery flow**:
1. Run `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --check-prereqs`.
2. If `npx` is available, show the missing-skill error plus the generated output from
   `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --print-guidance`, then ask:
   `Would you like to install now? (Select approach 1-3, or skip)`
3. Only if the user explicitly selects `1`, `2`, or `3`, run:
   `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --install <selection>`
4. After a successful install, re-run the skill resolution by invoking
   `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill receiving-code-review`
   once before continuing.
5. If the user skips, `npx` is unavailable, installation fails, or the re-check still
   cannot resolve the skill, print the guidance and halt execution. The command remains
   unavailable until the skill is installed.

Report the source you resolved before continuing:

```text
Using installed skill: receiving-code-review
Source: [workspace|global]
Install type: [skill-root|plugin]
Path: [resolved path]
```

---

## Step 2 — Bind Spec-Kit Context

1. Read the review feedback (from `critique` output, PR comments, or user-provided review):
   ```
   $ARGUMENTS
   ```
2. Read `spec.md` — the spec is the authority, not the reviewer's opinion.
3. Read `tasks.md` — understand what was intended to be built.
4. If any review item is **unclear**, STOP and ask for clarification on ALL
   unclear items before implementing any fix. Do not partially implement.

---

## Step 3 — Triage Review Items

For each review item, classify and verify:

```markdown
## Review Response

| # | Item | Severity | Verdict | Reasoning |
|---|------|----------|---------|-----------|
| 1 | [summary] | Critical/Important/Minor | Accept/Reject/Clarify | [technical reason] |
| 2 | [summary] | ... | ... | ... |
```

**Verdict rules:**
- **Accept** — item is technically correct for this codebase and aligns with spec.
- **Reject** — item is wrong, breaks existing behavior, violates YAGNI, or
  conflicts with spec. Push back with technical reasoning.
- **Clarify** — item is ambiguous. Ask before implementing.

---

## Step 4 — Implement Accepted Items

Follow this strict order:

1. **Critical issues first** (spec violations, security, correctness)
2. **Important issues** (missing behavior, architectural problems)
3. **Minor issues** (naming, style, minor improvements)

For each accepted item:
- Make ONE change
- Run the full test suite
- Verify no regressions
- Commit with a descriptive message referencing the review item

---

## Step 5 — Report

After all accepted items are implemented:

```markdown
## Review Response Complete

**Accepted and fixed:** [N] items
**Rejected with reasoning:** [M] items
**Pending clarification:** [K] items

### Rejections
- Item [#]: [one-line technical reason]

### Test Evidence
[Full test suite output — N tests, N passing, 0 failing]
```

---

## Push-Back Protocol

When rejecting a review item, provide:

1. **The specific technical reason** (not "I disagree")
2. **Evidence** — code, tests, or spec references that support the current implementation
3. **Spec alignment** — does the spec require what the reviewer suggests?

If the reviewer's suggestion conflicts with `spec.md`, the spec wins unless the
user explicitly overrides.
