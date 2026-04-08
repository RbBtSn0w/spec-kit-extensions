$ARGUMENTS

# Role
You are a rigorous System Architect and DevOps Engineer. Your task is to audit and govern the AI agent memory boundaries in the current workspace.

# Objective
1. **Prune**: Analyze the `AGENTS.md` file and extract any architectural rules, design patterns, or project-specific code constraints that belong in the project constitution (`.specify/memory/constitution.md`).
2. **Enrich**: Supplement `AGENTS.md` with missing essential infrastructure guidelines (e.g., standard test/build commands, Git workflows, or baseline agent behaviors) by inferring from the workspace context.

# Rules for Boundary Definition
- **Belongs in `AGENTS.md` (Infrastructure - KEEP or ADD):**
  - Build commands, test commands, linting scripts.
  - Git workflows, branch strategies, and commit conventions (e.g., Conventional Commits).
  - Environment variable setups and package manager constraints (e.g., strict pnpm usage).
  - CLI tool instructions and toolchain configurations.
  - General agent behaviors, safety protocols, and system instructions.
- **Belongs in `constitution.md` (Architecture - EXTRACT and REMOVE):**
  - Architectural layering logic (e.g., MVC, Clean Architecture).
  - State management choices (e.g., Redux, Zustand).
  - Code style paradigms (e.g., OOP vs. FP).
  - Error handling principles and API design guidelines.
  - Domain-specific business logic constraints.

# Action Instructions
1. **Read & Contextualize**: Analyze `AGENTS.md` and briefly inspect the workspace root (e.g., `package.json`, `Makefile`, etc., using your available tools if necessary) to understand the tech stack.
2. **Identify (Extract)**: Find all rules in `AGENTS.md` that fall under the "Architecture" category defined above.
3. **Cleanse**: Remove the identified architectural rules from `AGENTS.md`.
4. **Supplement (Enrich)**: Evaluate if `AGENTS.md` is missing critical "Infrastructure" rules. If test commands, build commands, or basic Git commit conventions are missing, generate them based on your workspace inspection and append them to a new section in `AGENTS.md`.
5. **Inject Pointer**: Add a clear reference pointer at the top of `AGENTS.md` (if not already present) directing the agent to read `.specify/memory/constitution.md` for project-specific architectural guidelines. Example: `> **Note:** For project-specific architectural rules, design patterns, and coding standards, refer to \`.specify/memory/constitution.md\`.`
6. **Overwrite**: Safely overwrite `AGENTS.md` with the cleansed and supplemented content. **DO NOT** directly modify `.specify/memory/constitution.md`.

# Output Protocol (CRITICAL)
You MUST output the extracted architectural principles as a Markdown list at the end of your response. This ensures the subsequent constitution generation command can read them from the context window.
Format the output exactly as follows:

```markdown
### Extracted Architectural Rules for Constitution
- [Rule 1]
- [Rule 2]
...

### Enhancements Made to AGENTS.md
- [Briefly list what infrastructure rules you added to AGENTS.md, e.g., "Added npm run test command", "Added Conventional Commits guideline". If none, write "None".]
```

If no out-of-bounds architecture rules are found, output:
```markdown
### Extracted Architectural Rules for Constitution
*(None found. AGENTS.md is clean.)*

### Enhancements Made to AGENTS.md
- [Briefly list additions...]
```