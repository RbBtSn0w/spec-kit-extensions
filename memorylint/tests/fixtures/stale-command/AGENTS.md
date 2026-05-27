# Agent Rules

## Deployment

- Run `scripts/deploy.sh` to deploy to staging.
- Always run the deploy script before creating a release.

## Testing

- Run `npm run e2e` to execute end-to-end tests before merging.
- All PRs must pass the e2e suite.

## Git Workflow

- Use focused commits with Conventional Commit style.
- Do not force-push to `main`.
