---
doc_id: docs_index
version: 4.1.1
updated: 2026-05-22
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
| Widget inventory and reusable widget guidance | `widget_catalog.md` | Catalog of Flutter widgets, primitive APIs, feature ownership notes, and catalog-update rules for material widget architecture changes. |
| UI layout, spacing, slivers, scroll ownership | `ui_architecture.md` | Unified layout architecture guide for screen padding, tab body insets, sliver usage, scroll ownership, and widget-test layout expectations. |
| Controller architecture | `controller_patterns.md` | Current controller/view-model patterns, UI/controller boundary rules, and realtime stream lifecycle ownership guidance. |
| Action cardinality | `action_cardinality_policy.md` | Product and engineering rule for whether each action is disallowed, singleton, unbounded, or domain-bounded, plus initial action-surface audit. |
| Error handling | `error-handling-audit.md` | App-wide error-management architecture, backend migration checklist, frontend/local error playbook, Error 101 guide, app error catalogue, naming conventions, branded app error surface guidance, and remediation history. Re-verify before acting on counts. |
| Release operations | `release_operations.md` | CI/release gates, Firebase deploy ordering, environment prerequisites, smoke tests, and human release evidence. |
| Data contracts and Firestore/Functions ownership | `data_contracts.md` | Firestore document shape, schema tooling, relationship documents, rules-test workflow, migration policy, and data-contract watch items. |
| Backend operation ownership | `backend_operation_catalog.md` | Human-readable catalog of direct client writes, callable-owned mutations, trigger-owned projections, server-only collections, and notification starting points. |
| Event success | `event_success.md` | Live event-success architecture, product guardrails, Firestore contracts, manual QA, participant metrics, and open product decisions. |
| Location stack | `location_stack_plan.md` | Google Maps/Places, location permissions, run coordinates, check-in geofencing, map navigation, and current map/demo readiness. |
| Demo data seeding | `demo_data_seeding.md` | Demo seeding scenarios, warm account workflows, demo ops, cleanup/reset commands, and validation workflow. |
| Recursive audit registry | `audit_registry/` | Machine-readable file inventory, pass receipts, active rules, backlog, compact doc summaries, and doc versions for repeated cleanup loops. |

## Contextual READMEs

Some documentation belongs beside the code it governs instead of in this
folder. Treat these as source-of-truth documents too:

| Area | Document | Purpose |
|---|---|---|
| App feature map | `../lib/README.md` | Feature folder structure, feature-level README map, and cross-cutting code docs. |
| Event policies | `../lib/event_policies/README.md` | Event policy bundle migration, lab preservation rule, admission/pricing/waitlist/cancellation/settlement rules. |
| Safety | `../lib/safety/README.md` | Blocking, reporting, account deletion, safety retention, and open moderation decisions. |
| User profile | `../lib/user_profile/README.md` | Private profile contract, identity-field edit policy, public projection inputs, and verified remaining profile issues. |
| Contracts | `../contracts/README.md` | JSON schema and generated contract workflow. |
| Firebase | `../firebase/README.md` | Environment config, App Check, deploy prerequisites, and Firebase current state. |
| Functions | `../functions/README.md` | Cloud Functions inventory, security defaults, secrets, and backend runbook. |

## Temporary Active Trackers

These are intentionally still present because live-code verification found
remaining work. Delete them only after the remaining items are migrated into the
durable owners above or closed in code.

| Tracker | Why It Remains |
|---|---|
| `host_tooling_consolidation_tracker.md` | Host tooling is mostly consolidated, but Edit run and club archive/delete UX are still open product decisions. |
| `public_profile_overhaul_tracker.md` | Cardless profile surfaces are implemented, but profile prompt picker, richer compatibility reasons, quality coaching, visual regression coverage, device QA, and user-facing "swipe" copy cleanup remain. |
| `config_cicd_platform_audit_2026-05-21.md` | Config/CI/CD/platform hardening is mostly closed, but console-gated GA4 BigQuery proof, Crashlytics script noise, analytics plist verification, contract-source migration, and Razorpay env guard follow-ups remain. |

Completed temporary trackers removed or folded into owner docs after code
verification include `dashboard_run_focus_tracker.md`,
`run_tile_consolidation_tracker.md`, `photo_grid_editing_tracker.md`, and the
event-success tracker cluster now consolidated in `event_success.md`. The
remaining active Codex audit folder docs were folded into the contextual
READMEs and owner docs listed above.

## Before Adding A New Doc

1. Check whether the information belongs in one of the documents above.
2. If it is a temporary pass report, add only durable findings to the active
   tracker or architecture doc.
3. If a new durable document is still necessary, add it to this index with its
   owner area and update path.
4. Delete or mark any superseded document in the same pass so the docs folder
   does not accumulate stale sources of truth.
