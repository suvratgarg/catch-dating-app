---
doc_id: agent_entrypoint
version: 1.3.2
updated: 2026-07-01
owner: agent_operating_model
status: active
---

# Catch Agent Entrypoint

This file is the first routing document for AI agents working in this repo.
Keep it short. Do not duplicate the architecture docs, design docs, contracts,
or release runbooks here. Use this file to choose the right source of truth and
the right verification loop.

## Required Starting Loop

1. Check `git status --short` and preserve unrelated dirty work.
2. Read `docs/agent_operating_model.md` for the execution mode.
3. For broad cleanup or refactors, generate a context pack before editing:

   ```sh
   node tool/agent/context_pack.mjs --task <task-name> --paths <path[,path...]>
   ```

4. Run the agent readiness gate before handoff:

   ```sh
   node tool/agent/check_agent_readiness.mjs
   ```

5. For cleanup/refactor passes, stamp proof in `docs/audit_registry/passes.jsonl`.
6. If using parallel agents, use the worktree delegation protocol in
   `docs/agent_operating_model.md`; the parent agent owns final integration,
   canonical docs, generated registries, audit stamps, and verification.

## Source-Of-Truth Routing

| Work type | Read first | Required local loop |
|---|---|---|
| App architecture, feature folders, controllers, async, error UI, widget ownership | `docs/app_architecture.md`, `docs/audit_registry/architecture_pattern_adoption.json` | Prototype one reference implementation first; update the architecture exhibit and pattern-adoption tracker; `dart tool/audit_registry.dart refresh`; focused tests/analyzer; relevant scanners |
| Documentation cleanup | `docs/README.md`, `docs/audit_registry/doc_versions.json` | Update owner doc; remove or mark superseded docs; run readiness gate |
| Design-system or UI implementation | `docs/design_language.md`, `docs/design_parity/README.md`, `docs/widget_catalog.md` | Widgetbook/contract coverage where relevant; design checks; focused Flutter tests |
| Data contracts, Firestore, Functions writes | `docs/data_contracts.md`, `docs/backend_operation_catalog.md` | `./tool/check_data_contract.sh` when contract/rules behavior changed |
| Release, deploy, CI, environment config | `docs/release_operations.md`, `docs/web_surface_architecture.md` | Local CI-equivalent checks; verify workflow/deploy state before declaring done |
| Marketing website architecture, routes, components, public pages, SEO metadata, generated organizer listings | `docs/marketing_website_architecture.md`, `docs/web_surface_architecture.md`, `docs/marketing_landing_page_research.md`, `design/website/routes.json`, `design/website/components.json` | Update the route contract before public route changes; update the component registry before Storybook/component changes; run `node tool/run.mjs check marketing:website-routes`, `node tool/run.mjs check marketing:website-components`, and the marketing build/typecheck loop |
| Tooling or automation | `tool/README.md`, `tool/tools_manifest.json` | Add tool manifest entries; `node tool/run.mjs check --manifest-only` |
| Parallel agent delegation | `docs/agent_operating_model.md`, `docs/agent_skills/catch-parallel-delegation.md` | Use disposable worktrees from the current parent HEAD; assign disjoint file scopes; review subagent commits before importing; record outcomes with `node tool/agent/record_delegation_outcome.mjs` |

## Non-Negotiable Rules

- Prose is not enforcement. If a rule matters repeatedly, add a scanner, lint,
  test, contract check, Widgetbook coverage gate, or explicit manual status.
- Broad tasks need a declared scope and acceptance criteria before edits.
- Every hard-won regression should become a stable entry in
  `docs/agent_regression_ledger.json`.
- Do not recreate deleted controller, UI architecture, or error-handling docs.
  Fold durable guidance into `docs/app_architecture.md`.
- Do not solve drift by adding aliases or feature-only primitive buckets. Same
  concepts should converge on one canonical contract and coverage path.
- Do not start a repeated architecture migration from prose only. Create or
  reuse a reference exhibit and keep
  `docs/audit_registry/architecture_pattern_adoption.json` current.
- Do not let subagents become independent sources of truth. Subagents may
  explore or produce isolated branch commits, but the parent agent is the only
  default writer for canonical docs, generated registries, audit receipts, and
  final verification.
- Do not run multiple Flutter test/analyzer processes in parallel. Parallelize
  read-only inspection, Git review, JSON/Node scanners, and disjoint patch
  proposals; run Flutter verification sequentially.

## Completion Standard

A task is complete only when the changed surface has:

- source-of-truth docs updated or deliberately untouched;
- generated artifacts refreshed when the source changed;
- relevant checks run and reported;
- new debt recorded with a stable id; and
- audit/pass proof recorded for cleanup or refactor work.
