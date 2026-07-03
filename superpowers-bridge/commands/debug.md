---
description: Apply systematic root-cause investigation to the current failing task.
---

# Debug - Current Failure Scope

## User Context

```text
$ARGUMENTS
```

Resolve `systematic-debugging`, then bind investigation to the current failing
task or the explicit user scope. Capture the exact failure, reproduce it, trace
the data flow, compare a working example, and test one root-cause hypothesis at
a time.

When implementation was requested, add a focused failing test before the
minimum fix and run focused verification. Do not broaden scope, create lifecycle
state, or choose an execution topology. Return control to the owning Spec Kit
implementation flow with the root cause and fresh evidence.

If the skill is unavailable, run
`bash .specify/extensions/superb/scripts/bash/ensure-skills.sh --print-guidance`
and direct the user to `/speckit.superb.check`; do not fetch skill content.
