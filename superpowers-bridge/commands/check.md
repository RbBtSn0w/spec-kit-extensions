---
description: >
  Diagnose the five Superpowers disciplines used by Superb and report the
  focused hook and standalone-command contract.
scripts:
  sh: .specify/extensions/superb/scripts/bash/ensure-skills.sh
---

# Check - Superb Diagnostics

## User Context

```text
$ARGUMENTS
```

Resolve exactly these skills with
`.specify/extensions/superb/scripts/bash/resolve-skill.sh`:

- `brainstorming` - optional `after_specify` refinement
- `test-driven-development` - optional upstream enhancement for the required
  test-first discipline, with a native minimum fallback
- `systematic-debugging` - standalone `debug`
- `receiving-code-review` - standalone `respond`
- `finishing-a-development-branch` - standalone `finish`

## Hook Readiness

| Hook | Command | Policy |
|---|---|---|
| after_specify | /speckit.superb.brainstorm | Optional |
| before_implement | /speckit.superb.implementation-gate | Required |

Report standalone availability for `critique`, `debug`, `respond`, and
`finish`. A missing optional skill affects only its command. Missing
`test-driven-development` selects the implementation gate's native minimum and
does not block Spec Kit.

## Installation Recovery

Run `{SCRIPT} --check-prereqs`, then show `{SCRIPT} --print-guidance`. Install
only after the user explicitly selects one of these approaches:

Installer reference: `https://github.com/RbBtSn0w/adg`

```text
npx @rbbtsn0w/adg plugins add obra/superpowers -g
npx @rbbtsn0w/adg skills add obra/superpowers --skill brainstorming --skill test-driven-development --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --global -y
npx @rbbtsn0w/adg skills add obra/superpowers --skill brainstorming --skill test-driven-development --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch -y
```

The plugin choice is the compatibility path and may install additional upstream
skills. Superb still resolves only the five skills listed above.
