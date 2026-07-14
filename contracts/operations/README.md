# Operations contracts

These draft-07 JSON Schemas define the portable boundary shared by operations
workers, trusted backend services, CLIs, and admin read models. They are not
Firestore collection registrations yet. A production persistence adapter must
project these JSON values to its native timestamp and transaction types without
changing their semantics.

The contracts deliberately separate:

- a run, which owns budgets and a frozen policy/ruleset;
- a work item, which has one exclusive primary stage plus orthogonal task flags;
- append-only action receipts and decisions;
- fenced leases for retry-safe workers;
- hash-bound publication plans; and
- rule proposals/evaluations, which require independent approval before
activation.

For the Supply Intake reference workflow, `primaryStage` is always exactly one
of `incoming`, `verify`, `resolve`, or `ready`. Publication, rejection, expiry,
cancellation, and takedown are lifecycle outcomes and never create extra review
columns. Display title, source profile, city, and other workflow-specific fields
belong in `normalizedPayload`; evidence and per-field derivation belong in
`evidenceRefs` and `fieldProvenance`.

Valid and deliberately invalid examples live under `fixtures/`. Invalid
fixtures include an `expectedIssueCode` alongside the invalid `document`; the
wrapper is test metadata and is not itself an operations document.

Operational code must not treat model confidence as authority, silently mutate
an applied publication plan, or let the same actor both propose and independently
approve a learned rule.
