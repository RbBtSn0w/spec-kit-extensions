---
description: >
  Development branch completion protocol. Bridges an installed
  obra/superpowers finishing-a-development-branch skill. Guides the user
  through structured options (merge, PR, keep, discard) after verification
  passes. Call manually after speckit.superb.verify succeeds.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
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
5. Resolve the active feature spec path using the same Spec Kit prerequisite
   script pattern used by follow-up commands:
   - Prefer `FEATURE_SPEC` when present
   - Otherwise use `FEATURE_DIR/spec.md`
   - Do not infer the path from the branch name manually

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

## Step 4 — Status Synchronization

Synchronize `spec.md` only for outcomes this command can directly observe.

### If the user chooses "Push and create a Pull Request"

Update the spec by running:

```bash
{SCRIPT} --status "In Review"
```

Only do this after PR creation succeeds.
If PR creation fails, preserve the previous status, typically `Verified`.

### If the user chooses "Keep the branch as-is"

Do not change status.
If verification already passed, the feature usually remains `Verified`.

### If the user chooses "Discard this work"

After explicit confirmation and only after discard succeeds, update the spec by
running:

```bash
{SCRIPT} --status "Abandoned"
```

If discard fails, preserve the previous status.

### If the user chooses "Merge back locally"

Do not write `Completed`.
Preserve the current status.

This bridge intentionally avoids claiming final completion because the dominant
real-world integration path is GitHub PR creation and later merge, which happens
outside the current bridge hook surface.

General rules:

- Use the script output as the source of truth for resolved spec path and
  resulting status
- Do not overwrite `Abandoned` silently later
- Do not introduce `Completed` in the current bridge lifecycle model

---

## Step 5 — Spec-Kit PR Enhancement (Option 2 only)

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
