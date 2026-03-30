---
description: >
  Development branch completion protocol. Loads the obra/superpowers
  finishing-a-development-branch SKILL.md at runtime. Guides the user through
  structured options (merge, PR, keep, discard) after verification passes.
   Call manually after speckit.superb.verify succeeds.
---

# Finish — Complete Development Branch

> **Skill origin:** [obra/superpowers `finishing-a-development-branch`](https://github.com/obra/superpowers)
> **Invocation:** Standalone command. Call after `speckit.superb.verify` confirms all checks pass.

---

## Prerequisite Gate

Before executing this command, confirm:

1. `speckit.superb.verify` has been run and **passed** in this session.
2. All tests are green (full suite, not subset).
3. All `spec.md` requirements are covered (spec-coverage checklist complete).

If any of the above is not met, **STOP**:
```
Cannot finish: verification has not passed yet.
Run /speckit.superb.verify first.
```

---

## Step 1 — Load the Authoritative Finishing Skill

Locate and internalize the superpowers finishing skill using this priority chain:

1. **Local plugin:** Read `skills/finishing-a-development-branch/SKILL.md` from the
   workspace root (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/finishing-a-development-branch/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > 1. Verify tests pass (full suite).
   > 2. Determine base branch (main/master).
   > 3. Present exactly 4 options: merge locally / push & create PR / keep as-is / discard.
   > 4. Execute the chosen option.
   > 5. Clean up worktree if applicable (options 1 and 4 only).

**You must internalize the full SKILL.md content before proceeding.**

---

## Step 2 — Bind Spec-Kit Context

1. Read any user-provided directives for the PR or merge context:
   ```
   $ARGUMENTS
   ```
2. Identify the current feature branch name from `tasks.md` header or `git branch --show-current`.
3. Identify the base branch:
   ```bash
   git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
   ```
4. Summarize what was implemented — read `spec.md` feature name and the
   verification evidence from the most recent `verify` run.

---

## Step 3 — Execute the Finishing Skill

Apply the loaded skill with these spec-kit additions:

1. **Final test verification** — run the full test suite one more time (the skill requires this).
2. **Present structured options** — exactly 4 choices, no open-ended questions:
   ```
   Implementation verified complete. What would you like to do?

   1. Merge back to [base-branch] locally
   2. Push and create a Pull Request
   3. Keep the branch as-is (I'll handle it later)
   4. Discard this work

   Which option?
   ```
3. **Execute the chosen option** — follow the skill's procedures for each option.
4. **Cleanup** — handle worktree cleanup per the skill's rules.

---

## Spec-Kit PR Enhancement (Option 2 only)

If the user chooses "Push and create a Pull Request", enhance the PR body with
spec-kit context:

```markdown
## Summary
[Feature name from spec.md]

## Spec Coverage
[Paste the spec-coverage checklist from the verify run]

## Verification Evidence
- Test suite: [N] tests, [N] passing, 0 failing
- Spec coverage: [N/N] requirements verified

## Review
Consider running `/speckit.superb.critique` for spec-aligned review.
```
