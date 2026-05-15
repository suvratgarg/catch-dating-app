---
doc_id: docs_index
version: 3.0.2
updated: 2026-05-15
owner: recursive_audit_loop
status: active
---

# Docs Index

This folder should contain durable source-of-truth documents, not every session
report or temporary audit note. When a cleanup pass discovers new guidance, move
the durable decision into the relevant source-of-truth doc and delete the stale
or duplicated note once it has served its purpose.

## Read Policy

Start with `docs/audit_registry/README.md` and
`docs/audit_registry/doc_versions.json` before rereading long docs. Use this
index to find the durable owner for a topic, then read only the relevant
section unless the task requires a full historical audit.

## Documentation Hygiene

- Prefer updating an existing source-of-truth document over creating a new one.
- Create a new document only when it has a distinct durable owner, audience, and
  update path.
- Do not keep duplicate or conflicting trackers for the same work. If two docs
  disagree, reconcile them and leave one clear owner.
- Session reports, email drafts, and one-off implementation summaries should not
  live here after their durable decisions or backlog items have been migrated.
- Date-stamped audits are snapshots. Re-verify counts, statuses, and code paths
  before treating them as current.

## Current Source Of Truth

| Area | Document | Purpose |
|---|---|---|
| Widget cleanup process | `widget_cleanup_todo.md` | Short human-readable pointer for widget cleanup. Active state lives in `audit_registry/backlog.json`. |
| Widget inventory and reusable widget guidance | `widget_catalog.md` | Catalog of Flutter widgets, primitive APIs, feature ownership notes, and catalog-update rules for material widget architecture changes. |
| UI layout and spacing | `ui_layout_spacing.md` | Durable screen padding, tab body inset, sliver body gap, and card/photo spacing contracts. |
| Sliver layout guidance | `sliver_layout_guide.md` | Sliver-native screen pattern, performance tradeoffs, migration rubric, and Catch code examples. |
| Controller architecture | `controller_patterns.md` | Current controller/view-model patterns, UI/controller boundary rules, and realtime stream lifecycle ownership guidance. |
| Action cardinality | `action_cardinality_policy.md` | Product and engineering rule for whether each action is disallowed, singleton, unbounded, or domain-bounded, plus initial action-surface audit. |
| Error handling | `error-handling-audit.md` | App-wide error-management architecture, backend migration checklist, frontend/local error playbook, Error 101 guide, app error catalogue, naming conventions, branded app error surface guidance, and remediation history. Re-verify before acting on counts. |
| Release operations | `release_operations.md` | CI/release gates, Firebase deploy ordering, environment prerequisites, smoke tests, and human release evidence. |
| Firestore and Functions data contracts | `firestore_functions_data_contract_tracker.md` | Firestore rules, Cloud Functions boundaries, schema drift, contract-test workflow, and rules emulator requirements. |
| Schema contract unification | `schema_contract_unification_tracker.md` | Long-horizon contract-first migration for Dart/TypeScript schemas, runtime validation, prompt catalogs, seed validation, rules metadata, and future storage-path renames. |
| Backend operation ownership | `backend_operation_catalog.md` | Human-readable catalog of direct client writes, callable-owned mutations, trigger-owned projections, server-only collections, and notification starting points. |
| Firestore relationship migration | `firestore_relationship_documents_migration.md` | Persistent tracker for relationship/action document migration, match-scoped messages, compatibility arrays, migration tooling, and deletion/anonymization payoff. |
| Location stack | `location_stack_plan.md` | Google Maps/Places, location permissions, run coordinates, check-in geofencing, map navigation, and current map/demo readiness. |
| Demo data seeding | `demo_data_seeding.md` | Demo seeding scenarios, warm account workflows, demo ops, cleanup/reset commands, and validation workflow. |
| Recursive audit registry | `audit_registry/` | Machine-readable file inventory, pass receipts, active rules, backlog, compact doc summaries, and doc versions for repeated cleanup loops. |

## Before Adding A New Doc

1. Check whether the information belongs in one of the documents above.
2. If it is a temporary pass report, add only durable findings to the active
   tracker or architecture doc.
3. If a new durable document is still necessary, add it to this index with its
   owner area and update path.
4. Delete or mark any superseded document in the same pass so the docs folder
   does not accumulate stale sources of truth.
