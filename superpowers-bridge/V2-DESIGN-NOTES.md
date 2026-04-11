# Superpowers Bridge V2 Design Notes

## Purpose

This document records the V2 redesign rationale for `superpowers-bridge`.
It explains:

- what changed in the product definition
- how the analysis was performed
- why Superpowers cannot be adopted wholesale inside Spec Kit
- how selected Superpowers capabilities can still be borrowed safely

The governing principle for V2 is:

> Build on top of the Spec Kit main flow, selectively introduce Superpowers quality-control skills, and add a small number of bridge-native commands where Spec Kit has no equivalent capability.

## Starting Point

The original bridge positioned itself as an orchestrator for Superpowers inside
Spec Kit. In practice, that created a conceptual mismatch.

Spec Kit already defines a primary workflow with its own core artifacts and
command boundaries:

- `specify`
- `clarify`
- `plan`
- `tasks`
- `analyze`
- `checklist`
- `implement`

Superpowers, by contrast, is not just a library of isolated skills. It is a
complete opinionated development workflow with its own progression:

- brainstorming
- using-git-worktrees
- writing-plans
- subagent-driven-development / executing-plans
- test-driven-development
- requesting-code-review
- finishing-a-development-branch

The key design problem was therefore not "How do we load more Superpowers
skills?" but rather:

> Which Superpowers capabilities can be introduced without breaking Spec Kit's
> ownership of specification, clarification, planning, task generation, and
> implementation?

## Analysis Process

The redesign was based on direct comparison of three inputs:

1. The current `superpowers-bridge` extension manifest, command docs, and README
2. The Superpowers workflow and skill definitions reviewed during the redesign
3. The Spec Kit command model and artifact ownership definitions reviewed during the redesign

The analysis focused on responsibility boundaries rather than superficial naming
similarity.

For each Superpowers skill, the following questions were asked:

1. Does this skill create, mutate, or replace a Spec Kit core artifact?
2. Does this skill introduce a second source of truth for planning or execution?
3. Does this skill belong to "quality control" or to "workflow ownership"?
4. If it overlaps with Spec Kit, is the overlap complementary or substitutive?

For each Spec Kit command, the analysis checked:

1. What artifact or decision does this command own?
2. Is there already a built-in quality gate or related extension point?
3. Would a bridge command strengthen the stage, or would it redirect the stage?

This led to a strict design rule:

> If a Superpowers skill would replace a Spec Kit stage, it is excluded from the
> bridge. If it strengthens quality inside a Spec Kit stage, it may be adapted.

## Why Superpowers Cannot Be Used Whole

Superpowers cannot be integrated as a full workflow inside Spec Kit without
creating collisions in ownership.

### 1. Brainstorming conflicts with `specify` and `clarify`

Superpowers `brainstorming` is designed to turn an idea into a validated design
through iterative questioning, comparison of approaches, and document writing.

Spec Kit already splits that responsibility across:

- `specify` for initial specification creation
- `clarify` for targeted ambiguity resolution and spec mutation

If `brainstorming` is inserted as a formal workflow stage, one of two bad things
happens:

- it replaces Spec Kit's specification path
- it creates a second design truth outside `spec.md`

Either result breaks the contract of the Spec Kit flow.

### 2. Writing-plans conflicts with `plan` and `tasks`

Superpowers `writing-plans` is not a small planning aid. It is a full plan
generator with detailed implementation instructions, test steps, and execution
handoff semantics.

Spec Kit already owns:

- `plan.md`
- `tasks.md`

If `writing-plans` is used directly, the system now has two plan authorities.
That is not an enhancement. It is a workflow fork.

### 3. Executing-plans and subagent-driven-development conflict with `implement`

Superpowers execution skills do not merely advise implementation discipline.
They control task execution sequencing, review cadence, and worker orchestration.

Spec Kit already defines `implement` as the execution phase and already treats
`tasks.md` as the task authority.

Bridging these Superpowers execution skills would create ambiguity around:

- which command owns execution
- which system updates task progress
- which system defines phase boundaries
- which system blocks or continues work

That is an architectural conflict, not just a UX issue.

### 4. Using-git-worktrees is too workflow-opinionated

`using-git-worktrees` may be a good engineering practice in some environments,
but it is not a safe universal precondition for a Spec Kit extension.

Projects differ in how they manage:

- branches
- worktrees
- monorepos
- CI assumptions
- local development constraints

The bridge must not impose a repository management strategy merely because
Superpowers prefers one.

### 5. Requesting-code-review overlaps with multiple review surfaces

Spec Kit now includes `analyze` and `checklist`, and this bridge also adds
bridge-native review utilities such as `review` and `critique`.

Bringing `requesting-code-review` in as a formal command would blur the
difference between:

- artifact analysis
- requirement quality checklists
- implementation review
- feedback response handling

Its principles are useful, but its workflow role is too overlapping to be
adopted directly.

## What Can Be Borrowed Safely

The bridge can safely adopt Superpowers skills when they operate as quality
discipline rather than as workflow ownership.

These skills fit that rule:

- `test-driven-development`
- `verification-before-completion`
- `systematic-debugging`
- `receiving-code-review`
- `finishing-a-development-branch`

They do not need to replace the Spec Kit flow. They can strengthen it at defined
points.

### Safe integration pattern

- `after_tasks`:
  bridge-native `review` checks coverage and TDD readiness
- `before_implement`:
  adapted `tdd` enforces test-first discipline
- `after_implement`:
  adapted `verify` enforces evidence before completion claims
- standalone:
  `debug`, `respond`, and `finish` remain explicit user-invoked tools

This pattern preserves Spec Kit's stage ownership while introducing stronger
execution discipline where it helps most.

## Bridge-Native Capability Justification

Not everything in V2 should come from Superpowers.

Some commands exist because Spec Kit and Superpowers leave a useful gap between
them.

### `review`

`review` is bridge-native because it is tailored to a very specific need:

- map `spec.md` requirements to `tasks.md`
- detect missing task coverage
- assess whether the task set is ready for a strict TDD gate

This is narrower than Spec Kit `analyze`, and more Spec-Kit-specific than any
single Superpowers skill.

### `critique`

`critique` is bridge-native because it reviews implementation against:

- `spec.md`
- `plan.md`
- `tasks.md`

It is not simply generic code review. It is a Spec Kit artifact alignment review.

### `check`

`check` is bridge-native because a bridge needs an explicit diagnostics command.
Since V2 depends on locally installed skills instead of remote fetching or
bundled fallback text, users need a single place to answer:

- which skills were found
- where they were found
- which hooks are ready
- which commands are blocked

That is bridge infrastructure, not a Superpowers workflow concern.

## Why V2 Uses Installed Local Skills

V2 intentionally moved away from the old "local -> remote -> embedded fallback"
model.

That earlier model had several problems:

- it obscured the actual source of behavior
- it weakened reproducibility
- it encouraged silent degradation
- it made debugging harder
- it blurred the definition of what the bridge truly depended on

The V2 rule is simpler:

- the bridge expects relevant skills to be installed locally
- workspace skills override global skills
- required skills fail fast if missing
- optional skills make only their own commands unavailable

This is closer to the semantics of a real bridge:

> The bridge connects two existing systems. It does not secretly substitute one
> of them when the connection fails.

## Final Product Definition

V2 defines `superpowers-bridge` as:

> A Spec Kit extension that bridges selected installed Superpowers
> quality-control skills into the Spec Kit workflow and adds a limited set of
> bridge-native review and diagnostics commands.

This definition intentionally excludes full workflow takeover.

### Spec Kit remains the owner of:

- specification creation
- clarification
- technical planning
- task generation
- implementation orchestration

### Superpowers Bridge contributes:

- TDD discipline
- verification discipline
- debugging discipline
- review-feedback handling discipline
- branch completion assistance
- Spec-Kit-specific coverage/review diagnostics

## Design Outcome

The result is a narrower but more coherent product.

It is narrower because it does less:

- it no longer pretends to bridge the whole Superpowers workflow
- it no longer formalizes a pre-spec brainstorming stage
- it no longer implies a second planning or execution system

It is more coherent because it does one thing well:

- strengthen the quality gates around the Spec Kit main flow without trying to
  replace that flow

That is the core V2 decision, and it is the reason the redesign deliberately
rejects complete adoption of all Superpowers skills.

## Status Synchronization Follow-Up

A later refinement added bridge-owned lifecycle synchronization to `spec.md`,
but only for states the bridge can observe directly with its existing hooks and
manual commands.

The bridge-owned states are:

- `Tasked`
- `Implementing`
- `Verified`
- `In Review`
- `Abandoned`

Notably excluded:

- `Completed`

Why `Completed` is excluded:

- the dominant integration path is GitHub PR creation followed by merge later
- that merge event happens outside the current bridge hook surface
- writing `Completed` at PR creation time would be inaccurate

Why `Abandoned` is still valid:

- discard is executed directly inside `superb.finish`
- the bridge can observe whether the discard action actually succeeded

This keeps status synchronization aligned with the same core design rule as the
rest of V2:

> The bridge should only claim lifecycle progress it can directly observe and
> verify.

In implementation terms, this lifecycle sync is handled by bundled helper
scripts that:

- resolve the active feature via Spec Kit prerequisite scripts
- find the current `spec.md`
- insert or update a canonical `**Status**:` line
- preserve `Abandoned` as a terminal bridge-owned state
