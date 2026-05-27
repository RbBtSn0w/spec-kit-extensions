# Constitution

## Module Boundaries

- Each extension lives in its own top-level directory.
- Extensions must not import from sibling extensions directly.

## Design Patterns

- Use command pattern for all user-facing operations.
- Keep business logic out of hook handlers.

## Code Conventions

- All public APIs must include type annotations.
- Prefer composition over inheritance.
- Error handling uses structured error types, not string exceptions.
