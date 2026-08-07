---
doc_id: agent_entrypoint
version: 2.0.0
updated: 2026-08-07
owner: agent_operating_model
status: active
---

# Catch Agent Entrypoint

This is a routing document, not a task ledger. Git owns history, the Catch
planner selects affected operations, existing tests and scanners prove
correctness, and CI stores run evidence.

## Starting Loop

1. Run `git status --short` and preserve unrelated work.
2. Read the owner document for the changed surface.
3. For broad work, generate a read-only plan or context pack before editing:

   ```sh
   node tool/agent/context_pack.mjs --task <task> --owned-paths <paths>
   node tool/harness.mjs plan --mode pr --base <base> --head HEAD
   ```

4. Run the focused checks selected by the changed surface. Use
   `node tool/run.mjs check <id...>` when a registered check exists.
5. Use a separate Git worktree for concurrent changes. The parent reviews and
   integrates each result; task, Git, PR, and CI output are the evidence.

## Source-Of-Truth Routing

| Work type | Read first | Verification |
|---|---|---|
| Flutter architecture, controllers, async, errors, widget ownership | `docs/app_architecture.md` | Focused tests/analyzer and registered architecture checks |
| Documentation cleanup | `docs/README.md` | Source metadata, link/reference, and relevant owner checks |
| Design system or app UI | `docs/design_language.md`, `docs/design_parity/README.md`, `docs/widget_catalog.md` | Widgetbook/contracts, design checks, focused Flutter tests |
| Catch UI lint/composition | `docs/app_architecture.md`, `design/components/README.md`, `design/screens/catch.screens.json` | `bash tool/check_catch_ui_lints.sh` and relevant composition checks |
| Data contracts, Firestore, Functions | `docs/data_contracts.md`, `docs/backend_operation_catalog.md` | `./tool/check_data_contract.sh` when behavior changes |
| Durable operations workflows | `docs/operations_platform.md`, `contracts/operations/README.md` | Operations tests/checks plus focused Functions/admin checks |
| Release, deploy, CI, environments | `docs/release_operations.md`, `docs/web_surface_architecture.md` | Local CI-equivalent checks and exact workflow/deploy-state verification |
| React website/admin architecture | `docs/web_surface_architecture.md`, `docs/agent_skills/catch-react-surface-refactor.md` | Registered React boundary, primitive, component, test, typecheck, and build checks |
| Marketing routes/components/SEO | `docs/marketing_website_architecture.md`, `design/website/routes.json`, `design/website/components.json` | Route/component/import checks and marketing typecheck/build |
| Widget consolidation or dedupe | `docs/design_parity/widget_consolidation/codex_worklog.md`, `docs/design_parity/widget_consolidation/consolidation_rules.md`, `docs/design_parity/widget_consolidation/decisions.json` | Apply only exact K/R/D rules; escalate unmatched identity or visual trade-offs; keep the decision ledger current |
| Tooling or automation | `tool/README.md`, `tool/tools_manifest.json` | `node tool/run.mjs check --manifest-only` plus focused tool tests |
| Parallel worktrees | `docs/agent_operating_model.md` | Current `node tool/harness.mjs task ...` lifecycle until the thin guard replaces it |

## Evidence Freeze

The following legacy snapshots are immutable pending deletion:

- `docs/audit_registry/files.jsonl`
- `docs/audit_registry/passes.jsonl`
- `docs/audit_registry/agent_metrics.jsonl`
- `docs/audit_registry/doc_versions.json`
- `docs/agent_regression_ledger.json`

Do not refresh, stamp, append, version-bump, or add entries to them. Any older
instruction that requires those writes is superseded by this section. Put a
recurring safety rule in an executable test or scanner; use an expiring waiver
in the owning source document only when automation is not possible. Store
generated inventories and run evidence in ignored local output or expiring CI
artifacts, never in a replacement repository ledger.

## Non-Negotiable Rules

- Prose is not enforcement. Repeated rules belong in tests, lints, scanners, or
  explicit manual review in the owning document.
- Broad tasks need a declared goal, scope, exclusions, checks, and acceptance.
- Do not create parallel architecture documents for the same concept.
- Preserve unrelated dirty work and never let a task's only copy remain
  uncommitted or unpushed.
- Before rewriting shared Git history, create a recoverable backup ref and
  verify the exact target.
- Do not run multiple Flutter analyzer/test processes concurrently.
- Do not add a new registry, receipt file, metrics ledger, or generated
  snapshot to replace the frozen evidence.

## Completion Standard

A task is complete when its intended source and contract changes are present,
the relevant focused checks pass, generated compile-critical outputs are
current, and the exact commit or working diff is preserved. Ordinary product
work must not modify any frozen evidence file.
