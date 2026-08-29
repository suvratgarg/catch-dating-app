---
doc_id: agent_entrypoint
version: 3.1.0
updated: 2026-08-27
owner: agent_operating_model
status: active
---

# Catch Agent Entrypoint

This is a routing document. Git owns source, history, branches, and worktrees.
The Catch planner selects existing checks and delivery lanes, deterministic
tests and scanners prove correctness, and CI stores run evidence.

## Starting Loop

1. Run `git status --short` and preserve unrelated work.
2. For every new task, fetch `origin/main` and create its branch/worktree from
   that exact commit through `node tool/git/worktree_guard.mjs start`. Never
   use the ambient checkout HEAD as a new-task base. Existing non-main work may
   be continued only in its existing worktree when the user explicitly asks
   to continue it.
3. Read the owner document for the changed surface.
4. For broad work, inspect a read-only impact plan. Add the optional context
   guidance when owner-doc or check routing would help:

   ```sh
   node tool/harness.mjs plan --base <base> --head HEAD --json
   node tool/agent/context_pack.mjs --task <label> --paths <paths>
   ```

   Both commands are read-only with respect to the repository. The context
   guidance prints to stdout and is never a prerequisite for editing.
5. Run the focused checks selected by the changed surface. Use
   `node tool/run.mjs check <id...>` when a registered check exists.
6. Use a separate Git worktree for concurrent changes. New task worktrees use
   `node tool/git/worktree_guard.mjs start`; use `doctor|finish|stale` for
   inspection and closeout.
   The parent reviews and integrates each result; Git, PR, and CI output are
   the evidence.

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
| Parallel worktrees | `docs/agent_operating_model.md` | Ordinary Git plus the optional thin `tool/git/worktree_guard.mjs` safety wrapper |

## Removed Evidence Layer

The following legacy evidence paths have been deleted and must remain absent:

- `docs/audit_registry/files.jsonl`
- `docs/audit_registry/passes.jsonl`
- `docs/audit_registry/agent_metrics.jsonl`
- `docs/audit_registry/doc_versions.json`
- `docs/agent_regression_ledger.json`

Any older instruction that requires those writes is superseded by this section.
Put a recurring safety rule in an executable test or scanner; use an expiring
waiver in the owning source document only when automation is not possible.
Store generated inventories and run evidence in ignored local output or
expiring CI artifacts when a consumer needs them, never in a replacement
repository ledger.

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
- Do not add a new tracked evidence registry or generated history snapshot to
  replace the removed evidence.

## Measure, Don't Assume

Every delivery incident in this repository so far has the same shape: something
trusted a *representation* of the system instead of the system. A branch named
`main` that was 17 commits behind origin. A rules file in the repo that did not
match the deployed ruleset. A migration receipt claiming completion while a live
dry-run showed five blockers. A spec citing a capability that exists nowhere in
the code. Each was resolved by measuring the thing itself.

- **Verify against the source, not a description of it.** Before acting on a
  claim about deployed config, remote state, data, or a symbol's existence,
  query it. `git rev-list --left-right origin/main...HEAD` before anything that
  publishes; the live API before trusting a checked-in rules file.
- **Read whole units.** A `grep -A 12` of a 32-line function, or the first 60
  lines of a 90-line report, has produced a confidently wrong conclusion more
  than once. Read the whole function, the whole report, the whole file.
- **Derive the gates; do not recall them.** Run
  `node tool/harness/verify_local.mjs --base origin/main --list` to see exactly
  what CI will run for your change. Do not work from a remembered or
  copy-pasted gate list — every such list has drifted at least once.
  `flutter analyze` passing is not evidence CI will pass; CI uses
  `--fatal-infos` via `node tool/ci/check_flutter_workspace_analysis.mjs`.
- **Report pre-existing failures; do not inherit them.** A failure described as
  "known" in a prompt may have been fixed upstream and be failing only on your
  stale base. Check against the merge base before working around anything.
- **A prompt's diagnosis is a hypothesis.** If an instruction does not survive
  your own reading of the code, say so and stop rather than implementing it.
  Implementing an incorrect diagnosis has cost more here than asking has.
- **Commit incrementally.** Commit each coherent piece as it builds. Committed
  work survives an interrupted run; uncommitted work does not. Stage explicit
  paths — `git add -u` has silently dropped new files.

## Completion Standard

A task is complete when its intended source and contract changes are present,
the relevant focused checks pass, generated compile-critical outputs are
current, and the exact commit or working diff is preserved. Ordinary product
work must not recreate or replace the removed evidence layer.
