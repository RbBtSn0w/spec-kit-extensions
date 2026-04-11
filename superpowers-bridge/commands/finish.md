---
description: >
  Development branch completion protocol. Bridges an installed
  obra/superpowers finishing-a-development-branch skill. Guides the user
  through structured options (merge, PR, keep, discard) after verification
  passes. Call manually after speckit.superb.verify succeeds.
---

# Finish — Complete Development Branch

> **Type:** Superpowers-adapted command
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

## Step 1 — Resolve Installed Skill

Look for `finishing-a-development-branch/SKILL.md` in this exact order:

1. `./.agents/skills/finishing-a-development-branch/SKILL.md`
2. `~/.agents/skills/finishing-a-development-branch/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Optional superpowers skill `finishing-a-development-branch` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: finishing-a-development-branch
Source: [workspace|global]
Path: [resolved path]
```

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

Apply the resolved installed skill with these spec-kit additions:

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
