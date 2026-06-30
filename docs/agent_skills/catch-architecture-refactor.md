# catch-architecture-refactor

Use for broad app code organization, feature-boundary, controller, async-state,
repository, widget-ownership, and testability refactors under `lib/**`.

Read: `docs/app_architecture.md`, `lib/README.md`,
`docs/audit_registry/README.md`, and `docs/agent_regression_ledger.json`.

Loop: generate an architecture context pack, refresh the audit registry, edit a
coherent batch, run focused tests/analyzer/scanners, refresh generated artifacts
that changed, and stamp a pass receipt.

Failure modes to avoid: ad hoc file choice, stale generated metadata, and
feature-boundary moves that do not update the canonical architecture doc.
