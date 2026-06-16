# Catch Agent Context

This file is intentionally small. The old audit checklist that previously lived
here was consolidated into the current source-of-truth docs and removed during
the 2026-05-21 documentation hygiene pass. Use git history only when exact
historical wording is needed.

Current source-of-truth docs:

- [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) for architecture, product flow, routes, data model, and known gotchas.
- [`lib/README.md`](lib/README.md) for the feature code map and feature-level README owners.
- [`lib/core/widgets/README.md`](lib/core/widgets/README.md) for the UI widget catalog, the compose-don't-reimplement decision tree, and lint enforcement.
- [`README.md`](README.md) for local setup and common commands.
- [`docs/README.md`](docs/README.md) for the docs source-of-truth index.
- [`docs/audit_registry/README.md`](docs/audit_registry/README.md) for recursive audit workflow and historical pass receipts.
- [`firebase/README.md`](firebase/README.md) for the Firebase environment runbook.
- [`functions/README.md`](functions/README.md) for Cloud Functions security defaults, function inventory, and secrets.
- [`TESTS.md`](TESTS.md) for the current test-suite inventory.
- [`docs/release_operations.md`](docs/release_operations.md) for CI gates, Firebase deploy ordering, TestFlight/Xcode Cloud release, smoke tests, and release-readiness evidence.

Before changing code, read `PROJECT_CONTEXT.md` first, then the feature folder
and any relevant runbook above. Treat archived trackers as historical evidence,
not current project status.
