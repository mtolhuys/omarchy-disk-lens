# Contributing

Thank you for helping make storage analysis on Omarchy clearer and safer.

## Before starting

Read [`AGENTS.md`](AGENTS.md) and the product contracts under [`docs/`](docs/). Changes that alter behavior or public claims must update the relevant contract and tests in the same change.

## Development principles

- Preserve the distinction between cheap filesystem capacity and explicit recursive scanning.
- Prefer exact, inspectable data and calm hierarchy over decorative complexity.
- Keep QDirStat optional and installation user-driven.
- Treat every path as hostile data and every long-running process as cancellable state.
- Add no destructive action without an approved product/security decision.
- Keep public documentation and fixtures in English and free of private machine data.

## Testing

Run `make test` and `make validate`. Any action that installs, enables, updates, removes, or visually exercises the plugin must run in the disposable Omarchy Plugin Lab according to [`docs/TESTING.md`](docs/TESTING.md).

Do not activate development builds on a contributor's daily Omarchy session.

## Changes and pull requests

- Keep commits focused and explain the user-visible effect.
- Include tests for success, failure, cancellation, and cleanup paths.
- Include before/after screenshots only for synthetic fixtures and only when visual behavior changes.
- State which evidence level was run and what remains unverified.
- Do not combine formatting, generated evidence, or unrelated refactors with a product change.
