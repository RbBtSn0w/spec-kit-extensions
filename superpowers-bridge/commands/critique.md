---
description: Read-only implementation critique against active Spec Kit artifacts.
---

# Critique - Evidence-Backed Review

## User Context

```text
$ARGUMENTS
```

This command is read-only. Load the active `spec.md`, `plan.md`, `tasks.md`, the
requested diff scope, and fresh relevant checks. Report correctness regressions,
missing tests, requirement gaps, security risks, and unintended behavior in
Critical, Important, then Minor order with file evidence.

Route requirement changes to `speckit.clarify`, architecture changes to
`speckit.plan`, task-scope changes to `speckit.tasks`, and delivered-code gaps
to `speckit.converge`. This command must not apply fixes, create tasks, mutate
feature artifacts, or declare completion.
