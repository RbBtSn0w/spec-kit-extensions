---
description: >
  Optional after-specify refinement gate. Bridges an installed
  obra/superpowers brainstorming skill into the active Spec Kit spec.md without
  creating a second design document or replacing speckit.specify.
---

# Brainstorm — Spec Refinement Gate

> **Type:** Superpowers-adapted command
> **Skill origin:** [obra/superpowers `brainstorming`](https://github.com/obra/superpowers)
> **Invocation:** Optional post-hook for `speckit.specify`; manual rerun only
> when an active Spec Kit `spec.md` already exists.

This command strengthens a newly created Spec Kit specification with the
collaborative design discipline from Superpowers brainstorming. It does not
start a new feature, create a new branch, or write a parallel design document.

---

## User Context

```text
$ARGUMENTS
```

Treat user-provided context as refinement guidance for the active Spec Kit
feature. Do not treat it as permission to bypass Spec Kit artifact ownership.

---

## Step 1 — Resolve Installed Skill

Look for `brainstorming/SKILL.md` in this exact order:

1. `./.agents/skills/brainstorming/SKILL.md`
2. `~/.agents/skills/brainstorming/SKILL.md`

If the workspace and global copies both exist, use the workspace copy.

If no readable file is found, **STOP**:

```text
ERROR: Optional superpowers skill `brainstorming` not found.
Run /speckit.superb.check for diagnostics.
```

Report the source you resolved before continuing:

```text
Using installed skill: brainstorming
Source: [workspace|global]
Path: [resolved path]
```

Do not fetch remote content. Do not silently fall back to bundled or summarized
skill text.

---

## Step 2 — Resolve Active Spec Kit Spec

Resolve the active feature spec path without requiring downstream planning
artifacts. `brainstorm` runs in `after_specify`, so `plan.md` and `tasks.md`
normally do not exist yet.

Use this resolution order:

1. Prefer hook-provided `FEATURE_SPEC` when present and readable.
2. Otherwise use hook-provided `FEATURE_DIR/spec.md` when present and readable.
3. Otherwise run the Spec Kit prerequisite script in paths-only mode
   (`check-prerequisites.sh --json --paths-only`, or the PowerShell
   equivalent) and read `FEATURE_SPEC` or `FEATURE_DIR/spec.md` from its JSON
   output.

Do not run the normal downstream prerequisite validation path here; it may
require `plan.md` or `tasks.md` and would be incorrect immediately after
`/speckit.specify`.

If the active feature spec cannot be resolved or read, **STOP**:

```text
ERROR: active Spec Kit spec.md not found.
Run /speckit.specify first, then rerun /speckit.superb.brainstorm.
```

Manual invocation is allowed only as a rerun/refinement path for an existing
Spec Kit feature.

---

## Step 3 — Bind Brainstorming To Spec Kit Ownership

Apply the resolved `brainstorming` skill with these mandatory overrides:

1. The active Spec Kit `spec.md` is the only design output.
2. Do **not** write to `docs/superpowers/specs/`.
3. Do **not** create a new feature branch or feature directory.
4. Do **not** invoke `writing-plans`.
5. Do **not** generate or modify `plan.md` or `tasks.md`.
6. Preserve the Spec Kit spec structure and heading order when updating content.
7. Do not synchronize lifecycle status. `brainstorm` does not write
   `**Status**:` or otherwise claim lifecycle progress.

The upstream brainstorming skill may mention a default design-doc location.
This bridge treats the current Spec Kit `spec.md` as the user's explicit spec
location preference.

---

## Step 4 — Refinement Process

Execute the brainstorming discipline in a Spec Kit-safe form:

1. Read the current `spec.md` completely.
2. Explore project context before asking questions:
   - existing repository structure
   - related docs
   - recent relevant changes when useful
3. Identify whether the feature is too broad for one Spec Kit feature. If it is,
   recommend decomposition before writing broad requirements.
4. Ask only questions that materially change scope, success criteria, user
   flows, constraints, or acceptance criteria.
5. Propose 2-3 approaches when the design direction is not obvious.
6. Present the refined design and get user approval before writing changes.

If the user declines refinement or approval is not reached, leave `spec.md`
unchanged and report what remains unresolved.

---

## Step 5 — Write Back To `spec.md`

When the user approves the refined design, update only the active `spec.md`.

The final spec must remain compatible with Spec Kit expectations:

- User scenarios and testing flows are concrete
- Functional requirements are testable and unambiguous
- Success criteria are measurable and technology-agnostic
- Edge cases are captured when relevant
- Assumptions are explicit
- No implementation plan, framework choice, file map, or task list leaks into
  the specification

Do not add a separate Superpowers design-doc header, footer, or status model.

---

## Step 6 — Self Review

Before reporting completion, re-read the updated `spec.md` and check:

1. No `TBD`, `TODO`, unresolved placeholders, or stale
   `[NEEDS CLARIFICATION]` markers were introduced.
2. No section contradicts another section.
3. Scope remains focused enough for one Spec Kit feature.
4. Requirements can feed `/speckit.clarify`, `/speckit.plan`, and
   `/speckit.tasks` without another design source of truth.

If issues are found, fix them inline before reporting.

---

## Report Format

```markdown
## Brainstorm Refinement

**Spec:** [resolved spec.md path]
**Skill source:** [workspace|global] — [path]
**Mode:** after_specify hook | manual rerun

### Refinements Applied
- [Concrete spec changes]

### Boundary
Spec Kit remains artifact owner. This command only applied approved refinement
to the existing canonical `spec.md`.

### Remaining Questions
- [Only if unresolved]

### Next Step
Run `/speckit.clarify` if questions remain, otherwise continue to `/speckit.plan`.
```
