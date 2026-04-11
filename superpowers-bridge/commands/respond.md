---
description: >
  Code review response protocol. Bridges an installed obra/superpowers
  receiving-code-review skill. Enforces technical verification before
  implementing review feedback — no performative agreement, no blind fixes.
  Pairs with speckit.superb.critique as the implementer counterpart.
---

# Respond — Receiving Code Review Feedback

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `receiving-code-review`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call after receiving output from `speckit.superb.critique` or any external code review.

---

## Step 1 — Resolve Installed Skill

Look for `receiving-code-review/SKILL.md` in this exact order:

1. `./.agents/skills/receiving-code-review/SKILL.md`
2. `~/.agents/skills/receiving-code-review/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Optional superpowers skill `receiving-code-review` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: receiving-code-review
Source: [workspace|global]
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
