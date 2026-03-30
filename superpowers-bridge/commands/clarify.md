---
description: >
  Orchestrates the obra/superpowers brainstorming skill within the spec-kit
  specify workflow. Loads the authoritative SKILL.md at runtime, binds
  spec-kit context, and produces an intent summary for speckit.specify.
---

# Intent Clarification — Before Specification

> **Skill origin:** [obra/superpowers `brainstorming`](https://github.com/obra/superpowers)
> **Invocation:** Pre-hook for `speckit.specify`. Optional — skip if the requirement is already fully understood.

---

## Hard Gate

<HARD-GATE>
Do NOT write any spec file, scaffold any directory, or take any implementation
action during this command. The only output is clarifying questions, design
proposals, and a brief intent summary. Spec creation happens in the next step
(`speckit.specify`).
</HARD-GATE>

---

## Step 1 — Load the Authoritative Brainstorming Skill

Locate and internalize the superpowers brainstorming skill using this priority chain:

1. **Local plugin:** Read `skills/brainstorming/SKILL.md` from the workspace root
   (present when superpowers is installed as a plugin).
2. **Remote fetch:** If the local file does not exist, fetch from
   `https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/SKILL.md`
3. **Embedded fallback:** If both fail, apply this minimal contract:
   > One question at a time. Explore 2-3 design approaches with trade-offs.
   > YAGNI ruthlessly. Never commit to a single path before comparing.
   > Incremental validation — get confirmation before the next question.

**You must internalize the full SKILL.md content before proceeding.** Its rules
govern the dialogue structure for this session.

---

## Step 2 — Bind Spec-Kit Context

Before asking the user anything, silently read:

1. Any user context provided:
   ```
   $ARGUMENTS
   ```
2. Any existing `spec.md` or `constitution.md` in the feature directory
3. Recent commit messages (`git log --oneline -20`) to understand adjacent work
4. Any `.specify/init-options.json` to understand project conventions

If the intent is fully clear from context (e.g., tiny bug fix with exact
reproduction steps), output a one-line summary and exit:

```
Intent is unambiguous: [one sentence]. Proceeding to spec creation.
```

---

## Step 3 — Execute the Brainstorming Skill

Apply the loaded brainstorming skill with these spec-kit guardrails:

- Follow the skill's dialogue rules exactly (one question at a time, etc.)
- Respect the `<HARD-GATE>` above — no spec files, no code, no scaffolding
- Propose 2-3 design approaches with trade-offs, leading with your recommendation

---

## Step 4 — Produce Intent Summary

After the user selects an approach, output the following structured summary.
This is the **sole deliverable** of this command — it becomes input for
`speckit.specify`:

```markdown
## Intent Summary

**Feature:** [name]
**Problem being solved:** [one sentence]
**Chosen approach:** [approach name]
**Success criteria:**
- [ ] [measurable criterion 1]
- [ ] [measurable criterion 2]
**Out of scope (explicit):**
- [thing that was considered and excluded]
**Open questions for the spec:** (if any)
- [question that the spec author needs to answer]
```
