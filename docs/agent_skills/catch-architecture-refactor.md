# catch-architecture-refactor

Use for broad app code organization, feature-boundary, controller, async-state,
repository, widget-ownership, and testability refactors under `lib/**`.

Read: `docs/app_architecture.md`, `lib/README.md`,
`docs/audit_registry/README.md`,
`docs/audit_registry/architecture_pattern_adoption.json`, and
`docs/agent_regression_ledger.json`.

Loop: generate an architecture context pack, refresh the audit registry, edit a
coherent batch, run focused tests/analyzer/scanners, refresh generated artifacts
that changed, and stamp a pass receipt.

For repeated architecture patterns, prototype first:

1. Create or reuse a pattern id from
   `docs/audit_registry/architecture_pattern_adoption.json`.
2. Build one high-quality reference implementation before broad migration.
3. Copy the reference code excerpt into `docs/app_architecture.md` as an
   exhibit.
4. Track every adopter, variant, exception, and required back-propagation in the
   JSON tracker.
5. If a later candidate improves the pattern, update the exhibit first and
   revisit all earlier adopters in the same pass.

Failure modes to avoid: ad hoc file choice, stale generated metadata, and
feature-boundary moves that do not update the canonical architecture doc or the
pattern-adoption tracker.
