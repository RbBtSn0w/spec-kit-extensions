# Quickstart: Validate the Refocused Superb Boundary

## Prerequisites

- Bash 3.2 or later
- Python 3.10 or later
- Ruby with YAML support
- `npx` or `uvx` for pinned Spec Kit installation tests
- Network access for the pinned installation scenario
- PowerShell 7 when validating cross-platform scripts

## Scenario 1: Validate the Source Capability Set

Inspect `superpowers-bridge/extension.yml`, commands, config, scripts, and tests.

Expected result:

- Exactly seven public commands are declared.
- Exactly two Superb hooks are declared.
- Exactly five logical skills are required.
- No lifecycle store or removed command remains active.

## Scenario 2: Validate a Pinned Spec Kit Installation

Install the extension into an isolated temporary project using Spec Kit `0.12.4`, then inspect the registered extension rather than the source tree alone.

Expected result:

- Registration succeeds with schema `1.0`.
- Installed command paths resolve under `.specify/extensions/superb/`.
- The installed command, hook, and skill sets match the capability contract.
- MemoryLint remains independently installable and unchanged.

## Scenario 3: Exercise the Optional Brainstorm Hook

Run the `after_specify` hook with the brainstorming skill available, unavailable, and declined by the user.

Expected result:

- Approved improvements update only the current specification.
- Decline and missing-skill paths skip safely.
- No plan, task, branch, mode, or status mutation occurs.

## Scenario 4: Exercise the Mandatory Implementation Gate

Run `before_implement` with complete and incomplete feature artifacts, with TDD guidance available and unavailable, and with tasks containing Spec Kit `[P]` markers.

Expected result:

- Missing prerequisites block implementation with actionable output.
- Missing Superpowers TDD guidance falls back to a native minimum gate.
- `[P]` markers are reported as Spec Kit-owned parallelism.
- No agent mode, batch, dispatch, task execution, checkbox, commit, or status mutation occurs.

## Scenario 5: Confirm Native Lifecycle Ownership

Run or inspect the Spec Kit task, analysis, implementation, and convergence stages.

Expected result:

- Superb contributes no `after_tasks`, `after_implement`, `before_converge`, or `after_converge` hook.
- Spec Kit remains the sole owner of tasks, implementation progress, convergence reports, and completion state.
- No Superb status synchronization or evidence archive is created.

## Scenario 6: Exercise Standalone Commands

Invoke `critique`, `debug`, `respond`, and `finish` independently.

Expected result:

- Each command remains inside the read/write boundary in `contracts/command-boundaries.md`.
- Artifact meaning changes route back to the appropriate Spec Kit stage.
- `finish` acts only after convergence and only after an explicit user choice.

## Scenario 7: Validate Skill Distribution

Run the health check with all five skills available and with each skill missing in turn.

Expected result:

- The check reports exactly five logical skills.
- Missing skills produce an explicit install action or bounded fallback.
- No removed orchestration skill is installed or invoked transitively.

## Acceptance Commands

After implementation, run:

```bash
bash tests/test-review-regressions.sh
bash tests/test-release-workflow.sh
bash tests/test-superb-path-contract.sh
bash superpowers-bridge/tests/test-capability-contract.sh
bash superpowers-bridge/tests/test-lifecycle-routing.sh
bash superpowers-bridge/tests/test-command-boundaries.sh
bash superpowers-bridge/tests/test-e2e-installation.sh
bash superpowers-bridge/tests/test-spec-kit-012-install.sh
ruby -e "require 'yaml'; YAML.load_file('.github/workflows/ci.yml'); YAML.load_file('.github/workflows/release-trigger.yml')"
git diff --check
```

Run the PowerShell counterparts for any retained cross-platform runtime script. A source-only pass is insufficient; the pinned installed-package scenario is the compatibility gate.
