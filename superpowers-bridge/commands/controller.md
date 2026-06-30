---
description: >
  Mandatory implementation controller. Orchestrates task implementation
  by bridging installed execution skills (subagent-driven-development or executing-plans)
  and quality gate reviews.
scripts:
  sh: scripts/bash/sync-spec-status.sh
  ps: scripts/powershell/sync-spec-status.ps1
---

# Implementation Controller Gate — Before Implementation

> **Type:** Superpowers-adapted implementation controller
> **Skill origin:** `subagent-driven-development`, `executing-plans`, `test-driven-development`
> **Invocation:** Mandatory pre-hook for `speckit.implement`. Cannot be skipped.

---

## Step 1 — Resolve Installed Skill

1. Run `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill test-driven-development`.
   The resolver is the canonical discovery helper for this bridge. It checks
   direct skill roots first, then plugin-provided skills, in workspace scope
   before global scope:
   - `./.agents/skills/test-driven-development/SKILL.md`
   - `./.agents/plugins/*/skills/test-driven-development/SKILL.md`
   - `./.agents/plugins/*/*/skills/test-driven-development/SKILL.md`
   - `~/.agents/skills/test-driven-development/SKILL.md`
   - `~/.agents/plugins/*/skills/test-driven-development/SKILL.md`
   - `~/.agents/plugins/*/*/skills/test-driven-development/SKILL.md`
   Prefer the first readable match in that order.
   If no readable file is found, enter the **inline install recovery flow**:
   1. Run `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --check-prereqs`.
   2. If `npx` is available, show the missing-skill error plus the generated output from
      `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --print-guidance`, then ask:
      `Would you like to install now? (Select approach 1-3, or skip)`
   3. Only if the user explicitly selects `1`, `2`, or `3`, run:
      `bash "$(dirname "{SCRIPT}")/ensure-skills.sh" --install <selection>`
   4. After a successful install, re-run the skill resolution by invoking
      `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill test-driven-development`
      once before continuing.
   5. If the user skips, `npx` is unavailable, installation fails, or the re-check still
      cannot resolve the skill, print the guidance and halt execution with exit status 2.
   Report the source resolved before continuing, including install type (`skill-root` or `plugin`).

2. **Check for Optional Execution Skills**:
   - Check for `executing-plans` by running `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill executing-plans`. This skill provides native Inline Execution discipline when running in Single-Agent Mode.
   - Check for `subagent-driven-development` by running `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill subagent-driven-development`. This skill provides native subagent dispatching.

---

## Step 2 — Detect Subagent Capability and Mode Selection

Before starting, the Controller must detect if subagent dispatch is supported and allowed:
1. **Verify Tool Availability**: Check if the `define_subagent` tool is present in the assistant's tool declarations.
2. **Check User Override**: Check `$ARGUMENTS` for explicit overrides (e.g. `--inline` or `--sdd=false`).
3. **Fallback Decision**: If `define_subagent` is unavailable, OR if the user has explicitly requested inline execution, the Controller MUST degrade gracefully to **Single-Agent Mode** (Step 4a). Otherwise, proceed to **Multi-Agent SDD Mode** (Step 4b).

---

## Step 3 — Bind Spec-Kit Task Context

1. Identify the task or context to work on:
   ```
   $ARGUMENTS
   ```
2. Read `tasks.md` in the current feature directory to understand the task plan.
3. Run the project's test suite now and record the baseline:

```
Baseline: [N] tests, [M] passing, [K] failing
```

If the baseline has unexpected failures, **STOP** and report them before proceeding.

4. For each task, note its test target (file, assertion, verification command)
   as declared in `tasks.md`. These are your RED-phase targets — do not invent
   new test locations unless the plan specifies a reason.

Also resolve the current feature spec path using the same Spec Kit feature
resolution used by follow-up commands:

- Prefer `FEATURE_SPEC` when the prerequisite script exposes it
- Otherwise use `FEATURE_DIR/spec.md`

Do not infer the feature path from the current branch name manually.

---

## Step 4 — Execute

### Step 4a — Single-Agent Mode (Fallback)

If fallback is active, run implementation locally within the parent conversation (Inline Execution):
1. Synchronize the feature spec status to "Implementing" by running:
   ```bash
   {SCRIPT} --status "Implementing"
   ```
2. **Execute with Decoupled Discipline Layers**:
   - **Layer 1: Native executing-plans discipline (Preferred)**:
     - If the `executing-plans` skill was successfully resolved in Step 1, the Agent MUST load and strictly enforce its **Inline Execution** discipline.
     - Loop through each task in `tasks.md` sequentially, using checkpoints for review, keeping all steps granular (RED-GREEN-COMMIT), and confirming with the user at checkpoint gates as defined in `executing-plans/SKILL.md`.
   - **Layer 2: Local fallback TDD discipline**:
     - If `executing-plans` is missing, loop through each task in `tasks.md` sequentially using local TDD instructions:
       - Identify the test target and write/run a failing test first (RED phase).
       - Prompt the user to confirm the failure and view the failure trace.
       - Write the minimum production code to pass the test (GREEN phase).
       - Refactor if necessary and commit changes.
       - Present evidence of RED and GREEN runs inline to the user.
       - Manually tick `[x]` for the completed task in `tasks.md`.

### Step 4b — Multi-Agent SDD Mode (Default)

If subagent dispatch is available and not overridden:

1. **Layered Detection**:
   - **Layer 1 (Native SDD)**: Resolve `subagent-driven-development` with `resolve-skill.sh`. If present, use it.
   - **Layer 2 (Composite TDD + Critique Fallback)**: If Layer 1 is absent, resolve `test-driven-development` with `resolve-skill.sh` (the bridge-native `critique` command is always available and used as the fallback reviewer).
   - If neither layer is ready, fallback to Single-Agent Mode (Step 4a).

2. **Initialize Discoveries Log**:
   - Create or read a stateful `discoveries.md` file in the feature directory. This file accumulates contracts, APIs, database schemas, and discoveries made by subagents during the workflow.

3. **Orchestrate Subagents**:
   - Read `tasks.md`. Parse all tasks sequentially or concurrently:
     - **Parallel Detection**: If adjacent tasks within the same phase are marked with `[P]`, they are parallelizable.
     - **Concurrent Dispatch**: The Controller MUST bundle these parallel tasks into a single `invoke_subagent` tool invocation. It specifies multiple subagent definitions inside the `Subagents` array argument of `invoke_subagent`, allowing them to execute concurrently in the background.
   - For each task (or concurrently dispatched group), define dedicated **Implementer** subagent(s).
   - **Context Isolation**: When invoking the subagent, provide:
     - The target task description and ID.
     - The feature specification (`spec.md`).
     - The current `discoveries.md` log.
     - **Constraint**: Do NOT pass the global `plan.md` or other tasks to the subagent to prevent token pollution.
   - **Layered Implementer Prompting**: If native SDD (Layer 1) is active, load and format the implementer prompt template from the resolved `subagent-driven-development` skill directory. Otherwise (Layer 2), construct a fallback TDD-implementer prompt based on `test-driven-development/SKILL.md` rules.
   - Invoke the Implementer subagent using `define_subagent` and `invoke_subagent`.
   - The subagent must run the TDD loop locally on the task file and report back when green.
   - **Two-stage Review Quality Gate (Feedback Loop)**:
     - Upon completion of the implementation task, if the code changes fail verification or the subagent completes, the Controller enters a review gate (up to **3 retries** total):
       1. **Stage 1 (Spec Reviewer) (FR-012)**: Spawns a `Spec Reviewer` subagent to compare the task's code changes and test output directly against the functional requirements in `spec.md`. The objective passing criteria are:
          - (a) All code modifications are strictly related to the target task.
          - (b) Valid passing TDD test suite outputs are provided.
          - If native SDD (Layer 1) is active, format the reviewer prompt using the resolved `subagent-driven-development/spec-reviewer-prompt.md`. Otherwise (Layer 2), fallback to using local bridge-native `critique.md` instructions.
          - If it detects a mismatch, unrelated changes, or missing test evidence, it returns feedback, and the Controller triggers a retry.
       2. **Stage 2 (Quality Reviewer) (FR-013)**: If Spec Review passes, spawns a `Quality Reviewer` subagent to check for security, style, and code quality regressions. If native SDD (Layer 1) is active, format the reviewer prompt using the resolved `subagent-driven-development/code-quality-reviewer-prompt.md`. Otherwise (Layer 2), fallback to the local `code-reviewer.md` template or `critique` command.
       3. **Failures**: If either reviewer fails the check, return feedback to the Implementer subagent to make fixes.
       4. **Meltdown (熔断) (FR-014)**: If a single task fails review **3 times**, the Controller must abort immediately, preserve the workspace state, and escalate to the user for manual troubleshooting.
     - **Progress Sync & Continuous Execution (FR-015, FR-016)**:
       - Upon a successful double-review pass, the Controller MUST **acquire an exclusive file lock** on `tasks.md`, then **automatically tick** the completed task's checkbox (changing `- [ ]` to `- [x]`) inside `tasks.md` without human intervention, and release the file lock.
       - The Controller then **automatically proceeds** to the next task in sequence. It must NOT pause or ask the user for confirmation to start the next task, ensuring continuous, fully automated progression.
   - Append any new API contracts or architectural discoveries returned by the subagent to `discoveries.md` before starting the next task.

### Step 4c — Concurrency, Error Handling, & Lifecycle Control (SDD Enhanced)

Under Multi-Agent SDD Mode (Step 4b), the Controller must adhere to the following strict runtime lifecycle rules:

1. **Discoveries Lifecycle & 4000-Token Cap (FR-019)**:
   - The active `discoveries.md` log in memory must not exceed **4000 Tokens** (or roughly **16KB** in size).
   - If the log exceeds 4000 tokens during task accumulation, the Controller MUST dispatch a lightweight summary subagent to compress the historical log content before spawning the next Implementer subagent.
   - Upon completion of the entire `/speckit.implement` run (all tasks done), the Controller MUST automatically archive the active discoveries log to `.specify/discoveries_archive/[YYYYMMDD_HHMMSS].md` and clear the active discoveries log.

2. **Concurrency Dependency & Conflict Serial Fallback (FR-020, FR-021)**:
   - When preparing to dispatch a batch of tasks marked with `[P]` (Parallelizable), the Controller must perform static analysis to detect logical dependencies:
     - Check if two tasks attempt to modify the same file or directory path.
     - Check if one task references a class, method, or function symbol being newly created in another task.
   - If a dependency or write conflict is detected, the Controller MUST downgrade the conflicting tasks to **serial execution** (execute task A, commit changes, then execute task B on top of the new state).
   - In any concurrent execution, ensure a file lock is acquired before modifying `tasks.md` to prevent write collisions.

3. **Concurrency Failure Cascade Management (FR-022)**:
   - If a subagent task in a parallel batch fails double review 3 times and triggers a Meltdown:
     - The Controller MUST allow already active/dispatched subagent tasks in the same batch to complete their execution.
     - However, the Controller MUST immediately stop spawning any subsequent new tasks from the queue, halting progression to allow the user to troubleshoot.

4. **Controller Checkpoint Resume on Interruption (FR-023)**:
   - If the Controller process is aborted (e.g. by user SIGINT or CLI termination):
     - Upon the next execution of `/speckit.implement`, the Controller must scan `tasks.md` to locate the first unticked task (`- [ ]`).
     - It MUST resume execution from that first incomplete checkpoint, keeping all previously ticked tasks (`- [x]`) intact without rolling them back.

---

## Escalation — When TDD Gets Stuck

If you have attempted **2 or more fixes** for the same failing test without
success, **STOP the TDD cycle** and escalate:

> Invoke `/speckit.superb.debug` to switch to the systematic
> debugging protocol. It will enforce root-cause investigation before any
> further fix attempts. Return to this TDD gate after the root cause is resolved.

Do not attempt fix #3 without completing the debugging protocol first.

---

## Enforcement Checklist (per task)

Before starting:
- [ ] No production code written yet for this task
- [ ] Test target identified from `tasks.md`

After completing:
- [ ] Saw the test FAIL before writing production code
- [ ] Wrote the MINIMUM code to pass
- [ ] Full test suite passes (no regressions)
- [ ] Committed the green state

**Cannot check all boxes? Stop. Restart the task from RED.**
