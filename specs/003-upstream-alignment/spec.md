# Feature Specification: Upstream Alignment for Converge and Agent-Context Opt-In

**Feature Branch**: `003-upstream-alignment`

**Created**: 2026-06-30

**Status**: Draft

**Input**: User description: "按照issue #18 将问题完整的分析，并完成技术的升级改造。这个过程不考虑兼容历史的问题。所以设计上需要考虑当下的变化。"

**Reference**: [Issue #18 — Align extensions with upstream speckit-converge and 0.12 agent-context opt-in](https://github.com/RbBtSn0w/spec-kit-extensions/issues/18)

## Overview *(context)*

Upstream Spec Kit introduced two changes that the two extensions in this repository (Superpowers Bridge and MemoryLint) must align with:

1. **`speckit-converge`** — a post-implement command that assesses code-vs-intent gaps and append-only writes remaining work as new tasks to `tasks.md`. It never runs tests and its `converged` verdict ignores test evidence.
2. **`0.12.0` agent-context full opt-in** — the Specify CLI no longer installs or manages the agent-context extension. The extension self-owns its config and a bundled per-agent defaults map, and it generalized the single managed `context_file` into plural `context_files`. When the extension is absent or disabled, Spec Kit touches no context file.

This feature delivers the technical upgrade described in issue #18. **Backward compatibility is explicitly out of scope** — the design targets the current upstream behavior (0.12 plural `context_files`, opt-in agent-context, converge present) and may drop assumptions that only existed for older upstream versions.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - MemoryLint coexists safely with agent-context managed blocks (Priority: P1)

A developer has both MemoryLint and the agent-context extension enabled. The agent-context extension maintains a machine-generated managed block (delimited by start/end markers) inside one or more agent context files (e.g. `AGENTS.md`, `CLAUDE.md`). The developer runs a MemoryLint audit and later applies approved fixes. MemoryLint must treat the managed block as off-limits and must not corrupt the file even when the managed block shifts line positions between audit and apply.

**Why this priority**: This is the only data/state-corruption risk in the set. A stale-line-number `apply` can write to the wrong lines of `AGENTS.md`, and ingesting the managed block as "rules" produces false findings and a churn loop where MemoryLint edits get clobbered by the next agent-context update. Highest severity, highest priority.

**Independent Test**: Seed a fixture `AGENTS.md` containing both genuine rules and an agent-context managed block; run audit then apply; verify (a) no finding references content inside the managed block, (b) no edit targets lines inside the managed block, and (c) apply either succeeds against current content or fails safely when the recorded location no longer matches.

**Acceptance Scenarios**:

1. **Given** an agent context file containing a managed block, **When** MemoryLint discovers and scans sources, **Then** no rule is extracted from lines inside the managed block and no finding cites the managed block as evidence.
2. **Given** an approved audit report, **When** the underlying file changed (managed block inserted/resized) after the audit was produced, **Then** apply detects the location mismatch and refuses to write, instructing the user to re-run the audit, rather than writing to incorrect lines.
3. **Given** multiple context files are configured (plural `context_files`), **When** MemoryLint runs, **Then** the managed block is skipped in every configured file, not just the first.
4. **Given** the agent-context extension is absent or disabled, **When** MemoryLint runs, **Then** behavior is unchanged and no managed-block handling interferes with normal rule extraction.

---

### User Story 2 - Convergence output flows into the evidence gate (Priority: P1)

A developer runs the implement → converge loop. After `speckit-converge` appends remaining-work tasks and they are implemented, the developer needs the same evidence-first completion guarantee the bridge already enforces after a normal implement. The bridge must hook the convergence lifecycle so that convergence-driven work cannot be declared complete without fresh evidence.

**Why this priority**: `converge`'s `converged` verdict ignores test evidence, so a converge-only workflow silently loses the bridge's core value (trustable, evidence-backed completion). Wiring the gate closes the loop and prevents `converged == complete` misreads.

**Independent Test**: With the bridge enabled, trigger the convergence completion point and verify the verification gate is invoked, and that a completion claim without fresh evidence is blocked.

**Acceptance Scenarios**:

1. **Given** the bridge is enabled and convergence has produced appended tasks, **When** the convergence lifecycle completion point is reached, **Then** the bridge's verification gate runs as part of that lifecycle.
2. **Given** convergence-appended tasks were implemented without fresh test evidence, **When** the verification gate runs, **Then** completion is blocked with the same evidence requirement applied after a normal implement.
3. **Given** the bridge is not enabled, **When** convergence runs, **Then** convergence proceeds normally with no bridge gate injected.

---

### User Story 3 - Review and converge have non-overlapping responsibilities (Priority: P2)

A developer relies on the bridge's task-coverage review at planning time and on `converge` at delivery time. The review command must stop duplicating what `converge` now automates (detecting requirement-coverage gaps and creating tasks) and instead concentrate on what `converge` cannot do: assessing `tasks.md` quality, TDD-readiness, and plan↔task consistency. The division of labor must be documented so users know which tool to reach for.

**Why this priority**: Reduces redundant, potentially conflicting gap reporting and clarifies the workflow, but carries no correctness or data-loss risk, so it ranks below the P1 stories.

**Independent Test**: Run the review command against a feature whose tasks have coverage gaps and quality/TDD issues; verify the output focuses on task quality, TDD-readiness, and plan↔task mismatches, and defers coverage-gap task creation to converge rather than recommending manual task additions for that purpose.

**Acceptance Scenarios**:

1. **Given** a `tasks.md` with both coverage gaps and TDD-readiness problems, **When** review runs, **Then** the report's primary verdict is driven by task-quality and TDD-readiness, and coverage-gap remediation is explicitly delegated to converge.
2. **Given** the extension documentation, **When** a user reads it, **Then** the boundary between review (plan-stage prevention) and converge (delivery-stage remediation) is clearly stated.

---

### User Story 4 - Configuration and docs reflect current upstream reality (Priority: P3)

A maintainer or new user inspects the repository's extension configuration and catalog. The configuration must not assume the agent-context extension is always present (it is opt-in post-0.12), and the catalog must declare the Spec Kit version range each extension has been verified against.

**Why this priority**: Prevents confusion and stale assumptions, but does not change runtime behavior, so it is the lowest priority.

**Acceptance Scenarios**:

1. **Given** the repository's extension configuration and README, **When** a user reads the agent-context-related entries, **Then** it is stated that agent-context is an opt-in dependency and the related hooks only apply when it is enabled.
2. **Given** the catalog entries, **When** a user checks compatibility, **Then** each extension declares the verified Spec Kit version range covering converge and the 0.12 change.

---

### Edge Cases

- A configured context file does not exist, or exists but contains no managed block → MemoryLint treats the whole file as normal rules; no special-casing breaks.
- A context file contains a malformed or unterminated managed block (start marker without end marker) → MemoryLint must fail safe by treating the affected region conservatively (skip from the start marker onward to avoid editing inside an incomplete block) and surface a warning, never silently editing within it.
- The agent-context configuration cannot be read or is invalid → MemoryLint falls back to the documented default markers and continues; it does not crash.
- Convergence produces zero findings (`converged`) → no appended tasks; the bridge gate at the convergence completion point reports cleanly without demanding rework.
- A feature has no constitution (unfilled template) → unchanged graceful-skip behavior is preserved across all touched commands.

## Requirements *(mandatory)*

### Functional Requirements

**MemoryLint × agent-context (US1)**

- **FR-001**: MemoryLint MUST exclude content within agent-context managed blocks from rule extraction across every configured context file.
- **FR-002**: MemoryLint MUST NOT generate any edit whose target range falls inside a managed block.
- **FR-003**: MemoryLint MUST discover the managed-block markers and the set of managed context files from the agent-context extension's self-owned configuration. It MUST read the plural `context_files` key with first precedence and the singular `context_file` key as the secondary source — both are current upstream-supported keys (the 0.12 bundled agent-context updater itself reads `context_files` or `context_file`), so accepting both is alignment with current upstream, not a pre-0.12 shim. MemoryLint MUST fall back to documented default markers when that configuration is missing or unreadable.
- **FR-004**: MemoryLint's apply step MUST verify that each recorded edit location still matches the expected content (anchor verification) before writing, and MUST refuse to write and direct the user to re-audit when the location no longer matches.
- **FR-005**: MemoryLint MUST behave identically to today when no agent-context extension is enabled and no managed blocks are present.
- **FR-006**: MemoryLint MUST fail safe on a malformed or unterminated managed block by not editing within the affected region and surfacing a warning.

**Superpowers Bridge × converge (US2, US3)**

- **FR-007**: The bridge MUST integrate with the convergence lifecycle so that its evidence-first verification gate runs at the convergence completion point when the bridge is enabled. This relies on the verified upstream behavior that `speckit-converge` reads `hooks.after_converge` from `.specify/extensions.yml` and emits `EXECUTE_COMMAND` for a mandatory hook (confirmed in the converge command's post-execution hook step). Implementation MUST cite this evidence rather than assume it.
- **FR-008**: The bridge's verification gate invoked via convergence MUST apply the same evidence requirements as the post-implement gate, blocking completion claims that lack fresh evidence. Because the converge gate reuses the identical `speckit.superb.verify` command, the blocking behavior is inherited from that command; verification MUST reference the existing `verify` blocking behavior rather than re-implement or assume it.
- **FR-009**: When the bridge is not enabled, convergence MUST run without any injected bridge behavior.
- **FR-010**: The review command MUST focus its verdict on `tasks.md` quality, TDD-readiness, and plan↔task consistency, and MUST delegate requirement-coverage-gap task creation to converge rather than reproducing it.

**Configuration & documentation (US4)**

- **FR-011**: The repository's extension configuration MUST express agent-context as an opt-in dependency, such that agent-context-related hooks/assumptions only take effect when the extension is enabled.
- **FR-012**: Extension documentation MUST describe the responsibilities of review vs converge, and the evidence-gate-after-converge behavior.
- **FR-013**: Catalog entries MUST declare, for each extension, the Spec Kit version range verified to work with converge and the 0.12 agent-context opt-in.

**Cross-cutting**

- **FR-014**: All changes MUST target current upstream behavior only; the design MUST NOT retain compatibility shims for behaviors that no longer exist upstream — specifically the pre-0.12 default-installed/CLI-managed agent-context lifecycle and CLI-registry lookups. This prohibition does NOT extend to the singular `context_file` key, which remains a current upstream-supported config form per FR-003.
- **FR-015**: Every behavioral change above MUST be covered by an automated test consistent with each extension's existing test suite.

### Key Entities *(include if feature involves data)*

- **Managed block**: A marker-delimited, machine-generated region inside an agent context file, owned exclusively by the agent-context extension.
- **Agent context file**: A file (e.g. `AGENTS.md`, `CLAUDE.md`) that may contain both human-authored rules (MemoryLint's domain) and a managed block (agent-context's domain); now potentially plural per the `context_files` model.
- **Agent-context configuration**: The agent-context extension's self-owned source of truth for markers and the set of managed files.
- **Audit report / edit**: A MemoryLint finding's proposed change, recorded with a location that must remain valid at apply time.
- **Convergence completion point**: The lifecycle moment after converge where the bridge's verification gate attaches.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a workspace where agent-context manages one or more context files, 100% of MemoryLint findings and applied edits fall outside managed blocks.
- **SC-002**: When a managed block shifts the recorded location of an approved edit, apply refuses to write in 100% of such cases (zero wrong-line writes).
- **SC-003**: With the bridge enabled, the evidence gate is reached on 100% of convergence completion runs, and an evidence-less completion claim is blocked every time.
- **SC-004**: The review command no longer emits requirement-coverage-gap task-creation recommendations that duplicate converge, while still reporting task-quality and TDD-readiness issues on features that have them.
- **SC-005**: A reader can determine from configuration, README, and catalog that agent-context is opt-in and which Spec Kit version range each extension supports, without inspecting source code.
- **SC-006**: All new and existing automated tests for both extensions pass.

## Assumptions

- Target environment is current upstream Spec Kit (0.12+) with converge available; older versions are not supported by this feature (per the no-backward-compat directive).
- The agent-context extension exposes a discoverable, self-owned configuration for its markers and managed file list, consistent with the 0.12 design.
- MemoryLint's authoritative source remains `AGENTS.md`, with other context files treated as it does today.
- The bridge's existing verification command remains the canonical evidence gate; this feature wires it to converge rather than introducing a new gate.
- Convergence remains append-only and does not run tests; the evidence guarantee is provided solely by the bridge gate.
- "Enabled / opt-in" status of an extension is determinable from the repository's extension configuration.
