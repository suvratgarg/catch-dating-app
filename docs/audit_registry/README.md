---
doc_id: audit_registry
version: 2.1.0
updated: 2026-05-05
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
| `archive/` | Historical detail that should be searched only when a debt id or rule requires it. |

## Workflow

1. Refresh the inventory:

   ```sh
   dart tool/audit_registry.dart refresh
   ```

2. Pick scope:

   ```sh
   dart tool/audit_registry.dart next
   dart tool/audit_registry.dart backlog
   dart tool/audit_registry.dart rules --status active
   dart tool/audit_registry.dart docs --path widget
   dart tool/audit_registry.dart stale --doc widget_cleanup --version 2.0.0
   ```

3. Work in a focused batch and verify with scoped analyzer/tests/scanners.

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

## Pruning Policy

Keep active instructions small. When a repeated concern is solved, move its rule
from `active` to `watch`, then to `archived` after the sunset criteria are met.
Archived rules remain searchable but should not be loaded into every pass.

Long docs should expose version metadata and a short read policy at the top. Do
not reread full historical snapshots unless the current task explicitly depends
on them.
