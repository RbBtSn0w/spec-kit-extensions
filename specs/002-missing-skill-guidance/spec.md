# Feature Specification: Missing Skill Installation Guidance

**Feature Branch**: `002-missing-skill-guidance`

**Created**: 2026-06-30

**Status**: Draft

**Input**: User description: "针对 superpowers-bridge 新增一个功能，当发现依赖的 superpowers 的 skills 不存在时，提示用户使用 https://github.com/RbBtSn0w/adg 协助安装 superpowers 中的关键 skills。当用户使用 superb 时发现 skill 不存在，就给出提示指引。"

## Clarifications

### Session 2026-06-30

- Q: Should the bridge only display guidance text, or also offer automatic installation after user confirmation? → A: Interactive auto-install — prompt the user, and upon confirmation execute the installation command via `adg`.
- Q: What installation approaches should be offered to the user? → A: Three approaches in priority order: (1) Recommended: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g -y` (plugin bundle with selective skills, globally installed, auto-confirmed); (2) Alternative: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y` (global skills with selective scope); (3) Alternative: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` (project-level skills with selective scope).
- Q: Should installation be selective or batch? → A: Batch — install all 11 skills at once.
- Q: What happens when `npx`/`adg` is not available on the user's machine? → A: Pre-detect `npx` availability before offering auto-install; if unavailable, skip the auto-install option and display manual installation guidance with the `adg` repository link only.
- Q: Should the bridge verify installation success? → A: Yes — automatically re-run skill detection after installation and display the updated Skill Status table so users see MISSING → READY transitions.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guided Skill Installation on Check (Priority: P1)

A user runs the `speckit.superb.check` diagnostics command to verify their bridge readiness. The bridge discovers that one or more required or optional superpowers skills are missing from both workspace and global skill roots. The bridge displays actionable installation guidance and offers interactive auto-installation via the `adg` tool (`https://github.com/RbBtSn0w/adg`). If the user confirms, the bridge executes the installation command and then re-runs the skill detection to display updated results.

**Why this priority**: This is the canonical entry point for diagnosing bridge health. Users who see "MISSING" today have no built-in path to resolution. Providing both guidance and one-click installation eliminates the most common support question and unblocks the entire workflow.

**Independent Test**: Can be fully tested by running `/speckit-superb-check` with one or more skills intentionally absent from both skill roots and verifying that (a) the output includes `adg`-based installation guidance for each missing skill, (b) an interactive install prompt is offered, and (c) after user confirmation the skills are installed and re-detected.

**Acceptance Scenarios**:

1. **Given** a workspace where `test-driven-development` skill is not installed and `npx` is available, **When** the user runs `/speckit-superb-check`, **Then** the diagnostic output shows the skill as MISSING, presents three installation approaches (plugins recommended, skills global, skills project), and prompts the user to confirm installation.
2. **Given** the user confirms installation in the previous scenario, **When** the installation command completes, **Then** the bridge automatically re-runs skill detection and displays the updated Skill Status table showing `test-driven-development` as READY.
3. **Given** a workspace where all hard-requirement skills are installed but `brainstorming` and `systematic-debugging` optional skills are missing, **When** the user runs `/speckit-superb-check`, **Then** the diagnostic output shows each missing optional skill with installation guidance and offers batch installation of all missing skills.
4. **Given** a workspace where all skills are installed, **When** the user runs `/speckit-superb-check`, **Then** the diagnostic output shows all skills as READY, no installation guidance is displayed, and no install prompt appears.
5. **Given** `npx` is not available on the user's machine, **When** the user runs `/speckit-superb-check` with missing skills, **Then** the output shows manual installation guidance with the `adg` repository link and suggested commands but does not offer interactive auto-installation.

---

### User Story 2 - Inline Guidance on Hook/Command Invocation (Priority: P2)

A user attempts to invoke a `superb` bridge command (e.g., `/speckit-superb-debug`) or a mandatory hook fires (e.g., `before_implement`), but the required superpowers skill for that command is not installed. The bridge displays a clear message explaining which skill is missing and how to install it via `adg`, with an interactive install prompt if `npx` is available.

**Why this priority**: This catches users at the moment of failure — when they are actively trying to use a feature and are most motivated to fix the problem. Providing guidance and optional auto-install here reduces frustration and time-to-resolution.

**Independent Test**: Can be tested by removing a specific skill (e.g., `systematic-debugging`) and invoking the command that depends on it (e.g., `/speckit-superb-debug`), then verifying the error message contains `adg` installation guidance and an optional install prompt.

**Acceptance Scenarios**:

1. **Given** `systematic-debugging` skill is not installed and `npx` is available, **When** the user runs `/speckit-superb-debug`, **Then** the command outputs a clear message identifying the missing skill, presents the three installation approaches, and offers interactive auto-installation.
2. **Given** `test-driven-development` skill is not installed, **When** the `before_implement` mandatory hook fires, **Then** the hook output includes a BLOCKED status with `adg` installation guidance and an install prompt before halting.
3. **Given** `finishing-a-development-branch` skill is not installed and `npx` is not available, **When** the user runs `/speckit-superb-finish`, **Then** the command outputs manual installation guidance with the `adg` repository link rather than silently failing.

---

### User Story 3 - Aggregated Installation Summary (Priority: P3)

When multiple skills are missing, the bridge provides a consolidated installation summary at the end of the diagnostic report, grouping missing skills by priority (hard requirements first, then optional skills) and providing three installation approaches. The recommended approach installs all 11 skills in a single operation.

**Why this priority**: Users with a fresh setup may have many missing skills. A consolidated summary with batch installation prevents them from having to handle individual entries and reduces setup to one confirmation.

**Independent Test**: Can be tested by running `/speckit-superb-check` on a workspace with no superpowers skills installed and verifying a "Quick Setup" summary section appears at the end of the report with grouped installation instructions and three approach options.

**Acceptance Scenarios**:

1. **Given** no superpowers skills are installed and `npx` is available, **When** the user runs `/speckit-superb-check`, **Then** the output includes a "Quick Setup" section at the bottom that: (a) groups missing hard requirements and optional skills separately, (b) presents three installation approaches with plugins as recommended, and (c) offers a single confirmation prompt to batch install all 11 skills.
2. **Given** only hard requirements are missing, **When** the user runs `/speckit-superb-check`, **Then** the "Quick Setup" section prioritizes hard requirements, marks them as blocking, and still offers batch installation of all missing skills.

---

### Edge Cases

- What happens when the `adg` repository URL is unreachable? The guidance should still be displayed with the URL; reachability is the user's responsibility. Auto-install will fail gracefully and fall back to manual guidance.
- What happens when a skill directory exists but `SKILL.md` is missing or unreadable? The guidance should treat this as MISSING and include the same installation hint.
- What happens when the user has a partial installation (skill directory exists, but from a different source, not superpowers)? The bridge should not recommend `adg` for non-superpowers skills; guidance only applies to known superpowers skill names.
- What happens when bridge commands are invoked in a non-interactive environment (CI/scripts)? The auto-install prompt should be skipped; only manual guidance text is displayed.
- What happens when `npx` is available but `adg` package resolution fails (e.g., npm registry issue)? The bridge should catch the failure, report it, and fall back to displaying manual installation guidance with the repository link.
- What happens when installation succeeds for some skills but fails for others? The post-install re-check will accurately reflect which skills transitioned to READY and which remain MISSING, with continued guidance for the remaining ones.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect missing superpowers skills during the `check` command and include per-skill installation guidance referencing the `adg` tool repository (`https://github.com/RbBtSn0w/adg`).
- **FR-002**: System MUST detect missing required skills when a bridge command or hook is invoked and display installation guidance inline before blocking or degrading.
- **FR-003**: System MUST distinguish between hard-requirement skills and optional skills in the guidance output, clearly communicating which missing skills block the workflow and which reduce capability.
- **FR-004**: System MUST provide a consolidated "Quick Setup" summary in the `check` command output when multiple skills are missing, grouping by priority level.
- **FR-005**: System MUST display guidance as plain-text Markdown, suitable for both interactive and non-interactive (CI) environments.
- **FR-006**: System MUST offer interactive auto-installation when missing skills are detected and `npx` is available. The system MUST NOT execute any installation command without explicit user confirmation (the flow is strictly opt-in).
- **FR-007**: System MUST only recommend `adg` for skills that are part of the known superpowers skill set (as defined in the bridge configuration). Non-superpowers skills are excluded from `adg` guidance.
- **FR-008**: System MUST include the `adg` repository URL (`https://github.com/RbBtSn0w/adg`) in every installation guidance message so users can navigate directly to the tool.
- **FR-009**: System MUST present three installation approaches in priority order:
  - (1) Recommended: `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g -y` (plugin bundle with selective skills)
  - (2) Alternative: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y` (global skills with selective scope)
  - (3) Alternative: `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` (project-level skills with selective scope)
- **FR-010**: System MUST install all 11 superpowers skills (2 hard + 9 optional) as a single batch operation when the user confirms installation.
- **FR-011**: System MUST pre-detect `npx` availability before offering interactive auto-installation. If `npx` is not available, the system skips the auto-install prompt and displays manual guidance only.
- **FR-012**: System MUST automatically re-run skill detection after successful installation and display the updated Skill Status table, showing MISSING → READY transitions.

### Key Entities

- **Skill**: A superpowers discipline or practice represented as a directory containing a `SKILL.md` file, discoverable via workspace or global skill roots.
- **Installation Guidance**: A structured text block containing the skill name, its requirement level (hard/optional), the `adg` repository URL, three installation approaches, and suggested installation steps.
- **Quick Setup Summary**: An aggregated section in the `check` output that groups all missing skills with consolidated installation instructions and a single confirmation prompt.
- **Installation Approach**: One of three supported methods for installing superpowers skills via `adg`: plugins (recommended), global skills, or project-level skills.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of missing superpowers skills detected by the `check` command include `adg` installation guidance in the output.
- **SC-002**: Every bridge command that depends on an uninstalled skill displays installation guidance before blocking or degrading, with zero silent failures.
- **SC-003**: Users encountering missing skills can identify the resolution path (install via `adg`) within 10 seconds of reading the output.
- **SC-004**: The guidance output is valid Markdown and renders correctly in terminal and rendered Markdown environments.
- **SC-005**: When `npx` is available and the user confirms, all 11 missing skills are installed in a single batch operation and verified by automatic re-check.

## Assumptions

- The `adg` tool at `https://github.com/RbBtSn0w/adg` is the recommended installer for superpowers skills and is available via `npx adg` without prior global installation.
- The superpowers skills source repository is `obra/superpowers` on GitHub.
- The bridge already has a well-defined list of known superpowers skills (2 hard requirements + 9 optional) in the configuration template (`superb-config.template.yml`).
- `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g -y` installs only the specific 11 superpowers skills as a plugin bundle while keeping the install global and non-interactive.
- `npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y` installs only the specific 11 superpowers skills at project scope.
- The existing `check` command's output format (Markdown table) is extended, not replaced.
- Users running bridge commands have access to a terminal; auto-install requires `npx` (Node.js) in PATH.
