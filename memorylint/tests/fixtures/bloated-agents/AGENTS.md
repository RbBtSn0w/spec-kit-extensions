# Agent Rules

## Build Commands

- Run `make build` to compile the project.
- Run `make test` to execute the full test suite.
- CI runs on `ubuntu-latest`.

## Git Workflow

- Use focused commits with Conventional Commit style.
- Do not force-push to `main`.
- All PRs require at least one review approval.

## Architecture (MISPLACED — should be in constitution)

- Use MVC pattern for all user-facing modules.
- State management must be handled via Redux and only Redux.
- API design must follow REST principles with JSON:API response format.

## Release Process

- Releases are created through the `release-trigger.yml` workflow.
- Do not manually create git tags.

## Code Conventions (MISPLACED — should be in constitution)

- Prefer composition over inheritance in all service layers.
- All public interfaces must include JSDoc annotations.
