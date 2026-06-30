---
description: >
  Mandatory after-plan quality gate. Enforces task granularity (2-5 minutes),
  placeholder rejection, and injects agentic worker directives.
---

# Plan Quality Gate

> **Type:** Bridge-native after_plan gate
> **Invocation:** Mandatory post-hook for `speckit.plan` (after_plan). Executed automatically after `/speckit.plan`.

---

## Step 0 — Resolve Installed Skill

Run `bash "$(dirname "{SCRIPT}")/resolve-skill.sh" --skill writing-plans`.

The resolver is the canonical discovery helper for this bridge. It checks, in
order, direct workspace installs, workspace plugin installs, direct global
installs, then global plugin installs. Prefer the first readable match.

---

## Step 1 — Check Placeholders & Plan Quality

Scan the generated `plan.md` and associated design files in the feature directory.

### Layer 1: Native writing-plans Reviewer (Preferred)
If the `writing-plans` skill was successfully resolved in Step 0 and the `define_subagent` tool is available in the assistant's tool declarations, the Controller MUST spawn a dedicated **Plan Reviewer** subagent using `define_subagent` and `invoke_subagent`:
1. **Subagent Configuration**:
   - **TypeName**: `research` or `self`
   - **Role**: `Plan Document Reviewer`
   - **Prompt**: Load and format the template from the resolved `writing-plans/plan-document-reviewer-prompt.md` file, filling in `[PLAN_FILE_PATH]` with the absolute path of `plan.md` and `[SPEC_FILE_PATH]` with the absolute path of `spec.md`.
2. **Review Execution**:
   - Invoke the subagent. The subagent will analyze the plan against the specification, completeness requirements, and the No Placeholders rules.
3. **Handle Review Result**:
   - Read the subagent's return output.
   - If the output Status is **Issues Found** or contains serious placeholder/granularity gaps:
     - **STOP** and abort the gate with Exit Code 1, listing the issues returned by the subagent.
   - If the status is **Approved**, proceed to Step 2.

### Layer 2: Local fallback discipline
If `writing-plans` is not installed or subagent tools are unavailable, the current Agent must fallback to manually scanning `plan.md` for standard placeholder patterns:
- `TODO`, `TKTK`, `???`, `<placeholder>`, and `TBD`.

If any placeholders are found in this fallback scan:
1. **STOP** and abort with a clear error:
   ```text
   ERROR: Plan contains unresolved placeholders (TODO/TKTK/???).
   All design details must be settled before proceeding.
   Found at: [file path and line context]
   ```
2. Do not proceed to task generation.

---

## Step 2 — Check Task Granularity

Analyze the tasks proposed in `plan.md` (or the initial tasks outline).

Regardless of skill availability, the Controller MUST enforce the following **Objective Redlines (FR-008)**:
- A task is strictly considered **too coarse** or **overly broad** and MUST be rejected if:
  - (a) It involves modifying **3 or more files**.
  - (b) The expected output exceeds **100 lines of production code**.

### Layer 1: Native writing-plans discipline (Preferred)
If `writing-plans` is available, additionally apply its **Bite-Sized Task Granularity** principles, ensuring each task represents a tiny, incremental change taking **2-5 minutes of focused TDD work**.

### Layer 2: Local fallback discipline
If `writing-plans` is missing, fallback to estimating that each task represents an atomic action fitting within a 2-5 minutes window.

If any task violates the FR-008 objective redlines or the 2-5 minutes window:
- **STOP** and abort with a clear error:
  ```text
  ERROR: Proposed tasks are too broad (violates 3-file/100-line granularity limits).
  Please break down the following task: [task description]
  ```
- Do not proceed to task generation.

---

## Step 3 — Inject Agentic SDD Directive

If all quality checks in Step 1 and Step 2 pass successfully:

1. Locate the feature's `plan.md` file.
2. Inject the mandatory directive block at the top of `plan.md` (directly below the main H1 header or description):

### Layer 1: Native writing-plans Header (Preferred)
If `writing-plans` was resolved, inject its official **Plan Document Header** directive:
```markdown
> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
```

### Layer 2: Local fallback directive
If `writing-plans` is missing, inject the local fallback directive:
```markdown
> **For agentic workers:** Use test-driven-development and the bridge-native critique command to implement each task sequentially. Do not proceed to the next task until both gates pass.
```

3. Output a success message confirming the gate has passed and the directive has been successfully injected.
