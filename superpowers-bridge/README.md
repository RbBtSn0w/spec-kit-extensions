# Superpowers Bridge

Superpowers Bridge packages the `superb` Spec Kit extension. It applies five
selected [obra/superpowers](https://github.com/obra/superpowers) disciplines at
bounded lifecycle points without importing the complete Superpowers workflow.

## Boundary

Spec Kit owns `specify -> clarify -> plan -> tasks -> implement -> converge`.
Superb contributes optional specification refinement, mandatory test-first
readiness, and four standalone developer disciplines. It owns no plan, task
store, execution lifecycle, completion state, or convergence command.

## Commands

| Command | Purpose |
|---|---|
| `/speckit.superb.check` | Diagnose the focused capability contract. |
| `/speckit.superb.brainstorm` | Refine the active spec after user approval. |
| `/speckit.superb.implementation-gate` | Report test-first readiness before implementation. |
| `/speckit.superb.critique` | Review implementation evidence without applying fixes. |
| `/speckit.superb.debug` | Investigate the current failing task. |
| `/speckit.superb.respond` | Verify and respond to supplied review feedback. |
| `/speckit.superb.finish` | Perform an explicit post-convergence branch handoff. |

## Hook Registration

| Hook | Command | Policy |
|---|---|---|
| `after_specify` | `/speckit.superb.brainstorm` | Optional |
| `before_implement` | `/speckit.superb.implementation-gate` | Required |

## Skill Contract

Superb directly uses five Superpowers skills:

- `brainstorming`
- `test-driven-development`
- `systematic-debugging`
- `receiving-code-review`
- `finishing-a-development-branch`

All five are optional upstream enhancements to the Spec Kit path. Test-first
behavior remains required through the bridge-native minimum when
`test-driven-development` is unavailable; missing standalone-command skills
disable only their corresponding Superb command.

The complete plugin may be installed for distribution convenience, but other
bundled skills are not Superb runtime dependencies.

## Installation

```bash
specify extension catalog add https://raw.githubusercontent.com/RbBtSn0w/spec-kit-extensions/main/catalog.json \
  --name rbbtsn0w-spec-kit-extensions --priority 1 --install-allowed
specify extension add superb
specify extension update superb
```

Published release installation:

```bash
specify extension add superpowers-bridge --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.9.0/superpowers-bridge.zip
```

Local development installation:

```bash
specify extension add --dev ./superpowers-bridge
```

Superpowers installation choices are offered only after explicit user approval:

```bash
npx @rbbtsn0w/adg plugins add obra/superpowers -g
npx @rbbtsn0w/adg skills add obra/superpowers --skill brainstorming --skill test-driven-development --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --global -y
```

## Migration

Existing users must remove references to the old controller, post-tasks review,
completion command, status synchronization, and evidence archives. See
[WORKFLOW.md](./WORKFLOW.md) for owning Spec Kit routes.

## Development Verification

```bash
bash superpowers-bridge/tests/test-capability-contract.sh
bash superpowers-bridge/tests/test-lifecycle-routing.sh
bash superpowers-bridge/tests/test-command-boundaries.sh
bash superpowers-bridge/tests/test-e2e-installation.sh
git diff --check
```
