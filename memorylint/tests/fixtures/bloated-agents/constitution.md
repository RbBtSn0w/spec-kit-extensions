# Constitution

## Module Boundaries

- Each extension lives in its own top-level directory.
- Extensions must not import from sibling extensions directly.

## Design Patterns

- Use command pattern for all user-facing operations.
- Keep business logic out of hook handlers.
