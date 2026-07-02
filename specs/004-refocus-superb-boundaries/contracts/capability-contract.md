# Superb Capability Contract

## Public Command Surface

The installed `superb` extension MUST expose exactly these commands:

1. `speckit.superb.check`
2. `speckit.superb.brainstorm`
3. `speckit.superb.implementation-gate`
4. `speckit.superb.critique`
5. `speckit.superb.debug`
6. `speckit.superb.respond`
7. `speckit.superb.finish`

No alias or compatibility command may preserve a removed lifecycle surface.

## Hook Surface

| Stage | Command | Optional | Responsibility |
|---|---|---:|---|
| `after_specify` | `speckit.superb.brainstorm` | true | Offer a bounded specification-quality enhancement without taking ownership of planning. |
| `before_implement` | `speckit.superb.implementation-gate` | false | Check implementation readiness and TDD availability without executing or scheduling tasks. |

No Superb hook may run at `after_tasks`, `after_implement`, `before_converge`, or `after_converge`.

## Skill Surface

The bridge MUST discover or install exactly these logical Superpowers skills:

1. `brainstorming`
2. `test-driven-development`
3. `systematic-debugging`
4. `receiving-code-review`
5. `finishing-a-development-branch`

Missing skills MUST produce bounded native guidance or an explicit installation action. Missing skills MUST NOT activate an additional orchestration path.

## Forbidden Active Surface

The installed package MUST NOT expose or invoke:

- Commands: `controller`, `review`, `verify`, or `plan-gate`.
- Hooks: `after_tasks`, `after_implement`, `before_converge`, or `after_converge`.
- Skills: `verification-before-completion`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `requesting-code-review`, or `dispatching-parallel-agents`.
- Runtime helpers that synchronize spec status, archive evidence, own task completion, dispatch agents, or persist execution state.

Historical changelog entries may name removed surfaces, but active manifests, commands, scripts, config, tests, and installation artifacts may not depend on them.

## Package Invariants

- `extension.yml` remains valid for `schema_version: "1.0"`.
- `extension.id` remains `superb`.
- `extension.version` remains the latest published version until the release workflow publishes a new version.
- All runtime assets use installed extension paths under `.specify/extensions/superb/`.
- Superb owns no lifecycle status, task store, execution store, completion store, or convergence report.
- MemoryLint manifests, commands, hooks, scripts, configuration, and behavior remain unchanged.

## Compatibility Evidence

Acceptance requires both source-tree and installed-package evidence:

- Source validation proves the exact command, hook, skill, and forbidden-surface sets.
- Installation validation uses a pinned Spec Kit `0.12.4` environment and inspects the registered extension.
- Compatibility assertions test durable Spec Kit contracts and observable installed behavior, not copied internal skill prose.
