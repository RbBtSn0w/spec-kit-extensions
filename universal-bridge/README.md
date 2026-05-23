# SDD Universal Bridge

The **SDD Universal Bridge** abstracts the core Subagent-Driven Development (SDD) governance rules and protocols from Spec Kit into a platform-agnostic specification and hook suite. This allows you to apply rigorous SDD discipline when using other AI editors (such as Cursor, Windsurf) or running CI/CD pipelines.

## SDD Protocol JSON Schemas

The `schema/` directory contains JSON Schemas that formally define the structured metadata of SDD:

1. **`spec.schema.json`**: Defines the metadata structure of specification files (`spec.md`), ensuring that titles, lifecycle statuses (`Tasked`, `Implementing`, `Verified`, `In Review`, `Abandoned`), and requirements conform to a standard.
2. **`plan.schema.json`**: Defines the structure of implementation plans (`plan.md`), including goal definitions, tech stack lists, proposed changes (demarcated as `MODIFY`, `NEW`, or `DELETE`), and verification plans.
3. **`evidence.schema.json`**: Defines the archived verification evidence schema, capturing timestamps, git hashes, test coverage checklist status (`MET`, `NOT_MET`, `PARTIAL`), and stdout/stderr output from test runs.

## Portable Git Hooks

The `hooks/` directory provides standalone, platform-agnostic scripts that can be integrated into your development workflow.

### `pre-commit-sdd`

This pre-commit hook acts as an automated quality gate. It verifies the following rules before allowing a commit:
1. **Spec Identification**: Locates the active `spec.md` in the workspace.
2. **Status Constraints**:
   - If the specification's status is `Verified`, it ensures that `tasks.md` does not contain any uncompleted tasks (`- [ ]`).
   - If the status is `Verified`, it checks that evidence has been archived in `.specify/evidence/`.
3. **Safety warnings**: Issues warnings if commits are attempted on an `Abandoned` specification.

### Installation

To enable the hook in your local Git repository:

```bash
# Copy the hook script to your git hooks directory
cp universal-bridge/hooks/pre-commit-sdd .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## CI/CD Pipeline Integration

You can easily integrate the `pre-commit-sdd` script into your GitHub Actions, GitLab CI, or other automation environments to block merges where specifications are declared `Verified` without completing all tasks or producing archived verification evidence.

Example GitHub Actions step:

```yaml
- name: Verify SDD Discipline Gates
  run: |
    bash universal-bridge/hooks/pre-commit-sdd
```
