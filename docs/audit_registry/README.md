---
doc_id: audit_registry
version: 2.6.3
updated: 2026-07-10
owner: recursive_audit_loop
status: active
---

# Recursive Audit Registry

This folder is the durable state for repeated architecture, widget, controller,
state-management, testability, and documentation cleanup passes.

Use this registry before reading long tracker docs. The goal is to answer:

1. Which files exist in the active audit surface?
2. Which pass last reviewed each file?
3. Which versioned rules and docs were applied?
4. What proof shows the pass actually closed the loop?

## Files

| File | Purpose |
|---|---|
| `files.jsonl` | One JSON object per tracked file. Generated and updated by `tool/audit_registry.dart`. |
| `passes.jsonl` | Append-only pass receipts with scope, rules, commands, outcomes, and new debt. |
| `rules.json` | Active/watch/archived rules used by recursive cleanup passes. |
| `doc_versions.json` | Version metadata for durable docs that Codex reads repeatedly. |
| `backlog.json` | Active backlog, next-up order, stable debt ids, and scanner counts. |
| `doc_summaries.json` | Compact read/skip policies for long docs. |
| `agent_metrics.jsonl` | Append-only measurements for agent-readiness score, check counts, delegation outcomes, and workflow-quality trend events. |
| `architecture_pattern_adoption.json` | Machine-readable tracker for architecture reference exhibits, prototype files, adopters, variants, exceptions, and back-propagation obligations. |
| `react_component_governance_families.json` | Generated reader snapshot of React component families governed by `tool/web/check_react_component_governance.mjs --families-json`. |
| `react_staff_review_remediation.json` | Staff review item tracker for the 2026-07-02 organizer publication, public listing, and claim CTA remediation pass. |
| `widget_classification.json` | Generated registry of every Dart widget class, its role, ownership boundaries, catalog status, and allowed public remediation path. |
| `widget_classification.schema.json` | JSON schema for the generated widget classification registry. |
| `widget_similarity.json` | Generated structural-similarity registry for widget consolidation review packets. |
| `widget_consolidation_receipts.md` | Command receipts, spot-checks, calibration notes, and known limitations for the widget consolidation pipeline. |
| `new_widget_inventory_scan.json` | Generated report comparing the working tree to a base ref for newly added widgets, private widget classes, widget-returning helpers, and Widgetbook/catalog coverage gaps. |
| `archive/` | Historical detail that should be searched only when a debt id or rule requires it. |

The inventory includes native Android, iOS, macOS, and Flutter web files in
addition to Dart, tests, tooling, design, and documentation, so release identity
changes receive the same pass history as application code.

## Enforcement Metadata

Active rules declare `enforcement` entries. Machine-backed entries bind to a
tool id in `tool/tools_manifest.json`; manual entries use `stage: manual` so
the absence of a scanner is explicit. Manifest tools that enforce rules declare
their `role`, reverse `rules` mapping, and, for gates or ratchets,
`vacuityProof`. Active tools under `tool/*.sh`, `tool/architecture/**`, or
`tool/audit/**`, and any active tool with a non-syntax manifest check, must
declare a `role` so runtime checks cannot hide from enforcement review. Ratchet
tools with checked baselines should also have a matching receipt in
`agent_metrics.jsonl` when the baseline changes. For `maxCounts` baselines, the
receipt stores the matching `maxCounts`; for `allowedFindings` baselines, it
stores `allowedFindingsCount`.

Validate this layer with:

```sh
node tool/check_enforcement_integrity.mjs
node tool/run.mjs check --category meta
```

## Workflow

1. Refresh the inventory:

   ```sh
   dart tool/audit_registry.dart refresh
   ```

2. Pick scope:

   ```sh
   dart tool/audit_registry.dart next --screen-limit 20
   dart tool/audit_registry.dart next --code-only --screen-limit 20
   dart tool/audit_registry.dart backlog
   dart tool/audit_registry.dart rules --status active
   dart tool/audit_registry.dart docs --path widget
   dart tool/audit_registry.dart stale --doc widget_cleanup --version 2.0.0
   ```

   `next` prints non-blocked screen-contract gaps from
   `design/screens/catch.screens.json` before the raw unreviewed-file list, so
   broad agent loops keep choosing product-relevant migration work when the
   backlog is blocked on owner/device input.
   Use `--code-only` for autonomous refactor loops; it filters gaps classified
   as reference-only or future-design work while preserving them in the default
   queue for design/capture passes.

3. Work in a focused batch and verify with scoped analyzer/tests/scanners.

   For widget-system work, regenerate and check the exhaustive role registry:

   ```sh
   npm run design:widgets:classify
   npm run design:widgets:check
   npm run design:widgets:new
   ```

   Private helper widgets are not an allowed destination. A widget that is too
   local or too redundant must still resolve through a public catalog action:
   merge into a canonical public widget, promote to the catalog, or inline/delete
   the duplicate.

   For Riverpod, Freezed, json_serializable, envied, or other build_runner-backed
   source edits, keep generated files synchronized. During iterative cleanup
   loops, prefer:

   ```sh
   dart run build_runner watch --delete-conflicting-outputs
   ```

   Do not manually revert generated output just to reduce diff size when the
   source change legitimately caused regeneration.

4. Stamp the pass:

   ```sh
   dart tool/audit_registry.dart mark-pass \
     --pass 2026-05-05-widget-test-cleanup \
     --rules WIDGET-TEST-001,TEST-ASYNC-001 \
     --paths test/runs/create_run_screen_test.dart,test/test_pump_helpers.dart \
     --proof "flutter test test/runs/create_run_screen_test.dart" \
     --proof "flutter analyze --no-fatal-infos test/runs/create_run_screen_test.dart"
   ```

5. Use the report when handing off:

   ```sh
   dart tool/audit_registry.dart report
   ```

6. If the pass used parallel agents or disposable worktrees, record the
   parent-reviewed outcome:

   ```sh
   node tool/agent/record_delegation_outcome.mjs \
     --task-id <task-id> \
     --mode worker-patch \
     --status integrated \
     --parent-review-outcome accepted-with-edits
   ```

## Completion Criteria

A pass is complete only when:

- touched files are stamped in `files.jsonl`;
- new recurring findings are added to `rules.json` or an existing rule;
- focused analyzer has no errors or warnings for the touched scope;
- focused tests pass, or the failure is documented as external/deferred;
- relevant scanners were run and counts were reduced, justified, or marked noisy;
- new debt has a stable debt id; and
- any human device-debug logs used during the pass are summarized in
  `passes.jsonl`.
- any parallel-agent work that influenced the parent branch is recorded in
  `agent_metrics.jsonl`.

## Pruning Policy

Keep active instructions small. When a repeated concern is solved, move its rule
from `active` to `watch`, then to `archived` after the sunset criteria are met.
Archived rules remain searchable but should not be loaded into every pass.

Long docs should expose version metadata and a short read policy at the top. Do
not reread full historical snapshots unless the current task explicitly depends
on them.
