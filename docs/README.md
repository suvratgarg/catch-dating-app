---
doc_id: docs_index
version: 4.6.0
updated: 2026-07-14
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
| Agent execution harness | `../AGENTS.md`, `agent_operating_model.md`, `agent_regression_ledger.json`, `agent_skills/` | Canonical AI-agent entrypoint, execution modes, parent-led Git/worktree delegation protocol, regression guards, project-local skills, readiness workflow, and metrics recording for deterministic Catch cleanup/refactor/design work. |
| AI-first workflow implementation guide | `ai_first_workflow_guide.md` | Shareable companion guide explaining how the agent entrypoint, context packs, docs registry, rules, scanners, lints, generated registries, audit receipts, CI gates, and readiness metrics combine into the Catch AI-first workflow. Descriptive only; canonical rules remain in owner docs. |
| Flutter app architecture | `app_architecture.md`, `audit_registry/architecture_pattern_adoption.json`, `generated/provider_graph/README.md` | Canonical feature/layer/screen/controller/repository/async/error/UI layout/scroll/sizing/widget ownership spec for `lib/**`, plus the generated Riverpod provider topology and reviewed relationship candidates; read before broad app architecture or code-organization work. Architecture rollouts must prototype one reference implementation, copy the exhibit into `app_architecture.md`, and track adopters/variants/exceptions in the JSON tracker. |
| Widget inventory and reusable widget guidance | `widget_catalog.md` | Catalog of Flutter widgets, primitive APIs, feature ownership notes, and catalog-update rules for material widget architecture changes. |
| Visual identity / design language | `design_language.md` | Locked editorial identity — palette (B&W base + activity color), typography (Archivo/platform system/IBM Plex Mono), photo grading, ticket/polaroid metaphors, exploration log, and the UI elevation roadmap. |
| Design parity state matrix, inventory, and composition migration | `design_parity/` | Feature-by-feature design-spec parity matrix plus Claude Design to Widgetbook inventory and layered composition migration spec connecting screens, states, captures, component contracts, previews, lints, token specimens, and visual-diff gaps. |
| UI migration prompts | `sizing_migration_prompt.md`, `design_token_migration_prompt.md` | Reusable agent prompts for the mechanical sizing and design-token sweeps; each pairs with its `tool/check_*.sh` scanner as the deterministic definition of done. |
| Action cardinality | `action_cardinality_policy.md` | Product and engineering rule for whether each action is disallowed, singleton, unbounded, or domain-bounded, plus initial action-surface audit. |
| Release operations | `release_operations.md` | CI/release gates, Firebase deploy ordering, environment prerequisites, smoke tests, and human release evidence. |
| Durable business operations | `operations_platform.md` | Canonical boundary for resumable human/worker/agent workflows, persisted runs and work items, authority lanes, Supply Intake stages, source learning, publication plans, and future admin-workflow adoption. |
| Web surface architecture | `web_surface_architecture.md` | Domain/subdomain ownership, Firebase Hosting targets, stack boundaries for marketing/app/admin, marketing CI/CD, public website route contracts, and future host-portal placement. |
| Marketing website architecture | `marketing_website_architecture.md` | Code organization, route-first/page-controller-component boundaries, target feature structure, and refactor order for `website/**`. |
| Admin and analytics dashboard | `admin_analytics_dashboard_spec.md` | Internal admin console and analytics product spec: safety/access ops, cohort retention, host/event analytics, user value, finance, BigQuery marts, and admin API boundaries. |
| Admin dashboard user stories and component catalogue | `admin_dashboard_user_stories_and_component_catalogue.md` | Tab-by-tab user stories, current workflow fit, top admin-console weaknesses, inspected-file log, and React admin primitive/component migration catalogue. |
| Marketing app media pipeline | `marketing_app_media_pipeline.md` | Capture manifest, website screenshot sync, host vertical media slots, and drift-check workflow for app-derived marketing assets. Fed by the UI capture pipeline below. |
| UI capture / visual review pipeline | `plans/ui_capture_pipeline_plan.md` | One deterministic per-screen capture harness with two consumers — raw review PNGs (fast UI review after changes) and curated marketing media (feeds the manifest above). Reuses the golden harness (`matchCatchGolden`); a route-drift check keeps the screen catalog honest. |
| Marketing landing page research | `marketing_landing_page_research.md` | Reference-site research, production rewrite rationale, guardrails, and residual marketing-site product decisions after the old tracker was folded in. |
| Organizer/event discovery and claimable listings | `plans/host_listing_discovery_architecture.md` | Deterministic organizer/event discovery, claim workflow, source-mention resolution, clustering, bounded LLM extraction/adjudication, candidate backlog, source-evidence ledger, index-readiness gates, and Firestore projection planning. |
| Data contracts and Firestore/Functions ownership | `data_contracts.md` | Firestore document shape, schema tooling, relationship documents, rules-test workflow, migration policy, and data-contract watch items. |
| Backend operation ownership | `backend_operation_catalog.md` | Human-readable catalog of direct client writes, callable-owned mutations, trigger-owned projections, server-only collections, and notification starting points. |
| Event success | `event_success.md` | Live event-success architecture, product guardrails, Firestore contracts, manual QA, participant metrics, and open product decisions. |
| Location stack | `location_stack_plan.md` | Google Maps/Places, location permissions, run coordinates, check-in geofencing, map navigation, and current map/demo readiness. |
| Demo data seeding | `demo_data_seeding.md` | Demo seeding scenarios, warm account workflows, demo ops, cleanup/reset commands, and validation workflow. |
| Sales demo persona cohorts | `sales_demo_persona_cohorts.md` | Cohort scope, NYC and India persona-library decisions, roster reuse policy, and city overlay rules for high-fidelity sales demos. |
| Sales demo image generation | `sales_demo_image_generation_runbook.md` | Mechanical ChatGPT-web image generation, review, local organization, UID-owned Storage upload, and post-upload validation workflow. |
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
| Marketing website | `../website/README.md` | Public website CI/CD, route-contract gate, analytics setup, and local marketing app workflow. |
| Shared React web config | `../packages/web-config/README.md` | Shared Vite, TypeScript, generated token CSS, and browser baseline plumbing for web-native surfaces. |

## Temporary Active Trackers

These are intentionally still present because live-code verification found
remaining work. Delete them only after the remaining items are migrated into the
durable owners above or closed in code.

| Tracker | Why It Remains |
|---|---|
| `ds_resync_audit_2026-06.md` | Active execution tracker for re-syncing `lib/` to the latest Catch design-system spec (event-detail vertical first). Holds the 2026-06-16 gap audit, owner decisions, and the dependency-ordered porting plan. **Supersedes the older font/type language in `ui_elevation_implementation.md` and `design_language.md`** (Archivo + system font + IBM Plex Mono; retired type studies removed from code). Delete once the port completes and durable findings migrate to `design_language.md`. |
| `ui_elevation_implementation.md` | Execution checklist for the UI elevation initiative (encode tokens/fonts → re-skin proof → flagship Profile → rollout). Self-contained for an implementing agent; pairs with `design_language.md`. **Font section is stale**; see `ds_resync_audit_2026-06.md`. Delete once the rollout completes. |
| `host_tooling_consolidation_tracker.md` | Host tooling is mostly consolidated, but Edit run and club archive/delete UX are still open product decisions. |
| `public_profile_overhaul_tracker.md` | Cardless profile surfaces are implemented, but profile prompt picker, richer compatibility reasons, quality coaching, visual regression coverage, device QA, and user-facing "swipe" copy cleanup remain. |
| `config_cicd_platform_audit_2026-05-21.md` | Config/CI/CD/platform hardening is mostly closed, but Crashlytics script noise, analytics plist verification, contract-source migration, and Razorpay env guard follow-ups remain. |
| `event_success_theatrical_experience_tracker.md` | Event Success live ceremony polish is active: native sensory cues, attendee moment theatre, host showtime console, invite-loop follow-up, private afterglow recap planning, and the optional First Hello arrival ritual. |
| `sales_demo_seed_tracker.md` | Sales-grade synthetic supply is active: canonical personas/assets, cohort scope, image production, U.S./India market packs, host sales scenario, event policy coverage, and migration of lower-quality demo surfaces remain. |
| `plans/repository_root_hygiene_spec.md` | Proposed Fable/owner review spec for classifying all project-root entries, reclaiming reproducible local output safely, retiring legacy artifacts, consolidating root docs, and adding manifest-backed root hygiene/cleanup enforcement. Delete or mark implemented after accepted policy moves into owner docs, tooling, and the audit registry. |

Completed temporary trackers removed or folded into owner docs after code
verification include `dashboard_run_focus_tracker.md`,
`run_tile_consolidation_tracker.md`, `photo_grid_editing_tracker.md`, and the
event-success tracker cluster now consolidated in `event_success.md`. The
2026-06-30 docs hygiene pass also folded and deleted the host app release recap,
host/consumer split tracker, host sales gap tracker, organizer claim workflow
plan, integration-test architecture tracker, admin dashboard tracker, marketing
landing-page tracker, website mockup functionality tracker, duplicate design
parity todo, and no-work-left UI lint/debt trackers. Their durable decisions now
live in the owner docs above plus `docs/audit_registry/passes.jsonl`.

## Before Adding A New Doc

1. Check whether the information belongs in one of the documents above.
2. If it is a temporary pass report, add only durable findings to the active
   tracker or architecture doc.
3. If a new durable document is still necessary, add it to this index with its
   owner area and update path.
4. Delete or mark any superseded document in the same pass so the docs folder
   does not accumulate stale sources of truth.
