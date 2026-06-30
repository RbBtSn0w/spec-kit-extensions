# Contract: Superpowers Bridge ↔ Converge Integration

**Surface**: `superpowers-bridge/extension.yml` (hook declaration) and
`superpowers-bridge/commands/review.md` (responsibility refocus). Consumed by upstream
`speckit-converge` and `speckit-tasks` hook dispatch.

## C1 — after_converge hook declaration (FR-007, FR-008)

`superpowers-bridge/extension.yml` MUST declare:

```yaml
hooks:
  after_converge:
    command: speckit.superb.verify
    optional: false
    description: >
      Mandatory evidence-first verification gate after convergence appends and
      implements remaining tasks. Reuses the post-implement verify gate.
```

**Behavior contract**:
- Upstream converge reads `hooks.after_converge` and, for a mandatory hook, emits
  `EXECUTE_COMMAND: speckit.superb.verify` after reporting the convergence outcome.
- The invoked `verify` applies the identical evidence requirements as the `after_implement` gate
  (it is the same command); a completion claim without fresh evidence is blocked.

## C2 — Bridge-absent invariance (FR-009)

When the bridge is not installed, no `after_converge` entry exists in the consuming project's
`.specify/extensions.yml`; converge dispatches no bridge hook and runs unchanged.

## C3 — Review responsibility (FR-010)

`review.md`'s decision table MUST:
- Drive its primary verdict from task quality, TDD-readiness, and plan↔task consistency.
- For requirement-coverage gaps, report the gap and route remediation to `/speckit-converge`
  (delivery-stage), instead of recommending manual task additions for coverage.
- Preserve the existing BLOCKED outcome for plan↔task mismatch and task-quality/TDD failures.

## C4 — Documentation (FR-012)

The bridge README MUST state:
- `review` = plan-stage prevention (task quality / TDD-readiness).
- `converge` = delivery-stage remediation (coverage gaps → appended tasks).
- `after_converge → verify` = evidence gate closing the converge loop.
