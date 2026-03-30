---
description: >
  Code review response protocol. Loads the obra/superpowers
  receiving-code-review SKILL.md at runtime. Enforces technical verification
  before implementing review feedback — no performative agreement, no blind
   fixes. Pairs with speckit.superb.critique as the implementer
  counterpart.
---

# Respond — Receiving Code Review Feedback

> **Skill origin:** [obra/superpowers `receiving-code-review`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call after receiving output from `speckit.superb.critique` or any external code review.

---

## Step 1 — Load the Authoritative Code Review Reception Skill

Locate and internalize the superpowers receiving-code-review skill using this priority chain:

1. **Local plugin:** Read `skills/receiving-code-review/SKILL.md` from the
   workspace root (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/receiving-code-review/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > 1. READ: Complete feedback without reacting.
   > 2. UNDERSTAND: Restate each item in own words.
   > 3. VERIFY: Check against codebase reality — is the suggestion correct HERE?
   > 4. EVALUATE: Technically sound for THIS codebase and spec?
   > 5. RESPOND: Technical acknowledgment or reasoned pushback.
   > 6. IMPLEMENT: One item at a time, test after each fix.
   > Never say "Great point!" or "You're absolutely right!" — just fix or push back.

**You must internalize the full SKILL.md content before proceeding.**

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
