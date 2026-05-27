# Agent Rules

## Build Commands

- Run `make build` to compile the project.
- Run `make test` to execute the full test suite.
- Run `make lint` to check code style.

## Git Workflow

- Use focused commits with Conventional Commit style.
- Do not force-push to `main`.
- All PRs require at least one review approval.

## CI Entry Points

- CI runs on `ubuntu-latest`.
- Every PR triggers the `ci.yml` workflow.
