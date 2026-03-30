---
description: >
  Mandatory completion gate. Loads the obra/superpowers verification skill
  at runtime and extends it with spec-kit's spec-coverage checklist.
  No task may be marked done without fresh evidence.
---

# Verification Before Completion — After Implementation

> **Skill origin:** [obra/superpowers `verification-before-completion`](https://github.com/obra/superpowers)
> **Invocation:** Mandatory post-hook for `speckit.implement`. Cannot be skipped.

---

## Step 1 — Load the Authoritative Verification Skill

Any user context provided:
```
$ARGUMENTS
```

Locate and internalize the superpowers verification skill using this priority chain:

1. **Local plugin:** Read `skills/verification-before-completion/SKILL.md` from the
   workspace root (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/verification-before-completion/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE.
   > 1. IDENTIFY which command proves the claim.
   > 2. RUN the full command (fresh, not cached).
   > 3. READ the output in full — check exit code, count failures.
   > 4. VERIFY the output confirms the claim. If not, state actual status.
   > 5. ONLY THEN make the completion claim.

**You must internalize the full SKILL.md content before proceeding.** Its rules
are non-negotiable for every completion claim.

---

## Step 2 — Execute the Verification Skill

Apply the loaded skill against the current implementation state:

1. Run the project's **full** test suite (not a subset) and paste the output.
2. Run any applicable build / lint / type-check commands and paste the output.
3. Follow the skill's evidence requirements exactly — "should pass" or
   "I'm confident" are never acceptable substitutes for fresh output.

---

## Step 3 — Spec-Kit Extension: Spec-Coverage Checklist

After the verification skill's checks pass, perform this additional spec-kit gate:

1. Re-read `spec.md` in full.
2. For each requirement or user story, verify the implementation satisfies the
   acceptance criteria and map it to a passing test:

```markdown
## Spec Verification Checklist

- [x] R01: [requirement] — verified by [test file]::[test name]
- [x] R02: [requirement] — verified by [test file]::[test name]
- [ ] R03: [requirement] — NOT VERIFIED ([reason])
```

3. If any `spec.md` requirement is unchecked:

```
⚠ INCOMPLETE: [N] spec requirements are not verified.
Cannot declare implementation complete.
Unmet requirements: [list them]
```

**Do not proceed past this point if any requirement is uncovered.**

---

## Step 4 — Completion Report

When all checks pass, output:

```markdown
## Implementation Complete — Verification Evidence

**Test suite:** [N] tests, [N] passing, 0 failing
**Spec coverage:** [N/N] requirements verified (see checklist above)
**Build:** [PASS / N/A]
**Lint:** [PASS / N/A]

All spec requirements are met. Implementation is verified complete.

Suggested next steps:
- Run `speckit.superb.critique` for code review against spec
- Or proceed to PR creation
```

If anything is unverified:

```markdown
## Implementation Status — INCOMPLETE

**Test suite:** [status]
**Spec coverage:** [N/M] requirements verified, [M-N] unverified
**Unverified requirements:** [list]

Implementation cannot be declared complete until all items above are resolved.
```
