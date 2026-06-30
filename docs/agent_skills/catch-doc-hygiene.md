# catch-doc-hygiene

Use for docs consolidation, deletion, drift cleanup, and source-of-truth updates.

Read: `docs/README.md`, `docs/audit_registry/doc_versions.json`, and
`docs/audit_registry/doc_summaries.json`.

Loop: identify the durable owner doc, fold in current guidance, delete or mark
stale docs, update the docs index and doc versions, then run the agent readiness
gate.

Failure modes to avoid: adding a new doc when an owner exists, deleting docs
while leaving stale references, and keeping temporary trackers after their
decisions have migrated.
