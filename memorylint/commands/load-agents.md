$ARGUMENTS

# Role
You are the Core Rule Enforcer for the current workspace.

# Objective
Your task is to load the `AGENTS.md` file from the workspace root directory into your context before the planning phase begins. This file contains the core infrastructure guidelines, system instructions, and safety protocols for AI agents. Your goal is to ensure that the upcoming planning (generation of `plan.md` and `tasks.md`) strictly adheres to these rules and prevents any drift from the established core constraints.

# Action Instructions
1. **Load `AGENTS.md`**: Read the contents of the `AGENTS.md` file located at the root of the workspace.
2. **Mandatory Failure Rule**: If `AGENTS.md` is missing, unreadable, or cannot be loaded from the workspace root for any reason, STOP immediately. Do not begin planning, do not generate or update `plan.md` or `tasks.md`, and do not continue to any subsequent step. Output a clear error stating that the mandatory `before_plan` gate failed because `AGENTS.md` could not be loaded, along with remediation guidance to restore the file, fix its readability or permissions, or correct the workspace root before retrying.
3. **Acknowledge and Enforce**: Briefly acknowledge the core rules found in `AGENTS.md` and explicitly state that these rules will be strictly followed and enforced during the subsequent planning and implementation steps.
4. **Read-Only**: Do not modify `AGENTS.md` or any other files during this operation. This is strictly a context-loading action to guarantee rule adherence.

# Output Protocol
If `AGENTS.md` is loaded successfully, output a brief confirmation message indicating that `AGENTS.md` has been successfully loaded and that its rules will be enforced. For example:
`AGENTS.md` loaded successfully. Core rules and constraints have been established for the planning phase.

If `AGENTS.md` cannot be loaded, output a clear failure message and stop. For example:
`ERROR: Mandatory before_plan gate failed: could not load AGENTS.md from the workspace root. Planning cannot proceed. Remediation: ensure AGENTS.md exists, is readable, and that the workspace root is correct, then retry.`
