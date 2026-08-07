---
doc_id: audit_registry
version: 4.0.0
updated: 2026-08-07
owner: agent_operating_model
status: active
---

# Legacy Audit Snapshots

The audit registry previously stored generated file history, pass receipts,
agent metrics, document routing, rules, backlogs, and design inventories in one
tracked directory. That model is being retired because every branch rewrote the
same evidence and made ordinary work conflict with unrelated work.

## Frozen Files

These files are immutable migration inputs and must not be changed:

- `files.jsonl`
- `passes.jsonl`
- `agent_metrics.jsonl`
- `doc_versions.json`
- `../agent_regression_ledger.json`

Plain `dart tool/audit_registry.dart refresh`, `mark-pass`, readiness metric
recording, and delegation recording are retired. Historical references remain
searchable through Git. Do not create an archive or replacement ledger.

## Where Current Authority Lives

| Concern | Current authority |
|---|---|
| Repository paths and change history | Git |
| Path-to-component and affected-operation routing | `tool/harness/component_graph.json` |
| Executable checks | `tool/tools_manifest.json` and their owning tests/scanners |
| Document lifecycle and ownership | Source frontmatter and `docs/README.md` |
| Architecture decisions | Owning architecture document or authored domain contract |
| Generated inventories and run proof | Ignored local output or expiring CI artifacts |
| Regression prevention | Focused tests, lints, scanners, or an expiring owner-doc waiver |

Some authored decision files still live under `docs/audit_registry/` while
they migrate to their durable domain owners. They remain normal reviewed
source, not proof that every task must update this directory.

## Read-Only Compatibility

During deletion migration, read-only commands may inspect the frozen snapshots:

```sh
dart tool/audit_registry.dart report
dart tool/audit_registry.dart rules --status active
dart tool/audit_registry.dart docs --path <topic>
dart tool/audit_registry.dart refresh --check
```

`refresh --check` is compatibility diagnostics only and is not a required
handoff gate. It may report intentional drift after a retired producer or
snapshot path is removed.

## Completion

Run the checks owned by the changed component. Git and CI output preserve the
result. A cleanup or refactor is not required to stamp files, append a receipt,
record a score, update a documentation catalog, or add a regression-ledger
entry.

The migration is complete when active tools and instructions no longer read the
frozen files, the files are deleted, and two representative product changes
finish with zero governance-file modifications.
