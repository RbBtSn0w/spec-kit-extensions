---
description: Complete branch handoff after Spec Kit convergence and fresh checks.
---

# Finish - Explicit Branch Handoff

## User Context

```text
$ARGUMENTS
```

Resolve `finishing-a-development-branch`. Require a converged Spec Kit feature
and run fresh project checks before presenting any branch action. Summarize the
branch, base, verification evidence, and workspace ownership.

Offer merge, pull request, keep, or discard as an explicit choice. Execute only
the user's selected action. Preserve workspaces it does not own and never infer
a destructive choice. This command creates no Superb lifecycle status and does
not repeat convergence.

If the skill is unavailable, run
`bash .specify/extensions/superb/scripts/bash/ensure-skills.sh --print-guidance`
and direct the user to `/speckit.superb.check`; do not infer branch actions.
