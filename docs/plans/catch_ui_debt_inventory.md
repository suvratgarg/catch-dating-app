---
doc_id: catch-ui-debt-inventory
version: 1.2
updated: 2026-06-01
owner: ui_elevation_initiative
status: watch
audience: codex (execution)
related: [catch-ui-lint-p0-spec, catch-ui-lint-rules-plan, ui-elevation-implementation]
---

# Catch UI Debt Inventory - Remaining Work

This file was reduced on 2026-06-01 to the work still worth tracking. The old
"no-carve-out scan" narrative is stale: raw color/text/font drift is now handled by
the Catch UI analyzer plugin, and the original counts have drifted with the live
worktree.

## Implemented / No Longer A Plan Item

- Raw color, text-style, and font drift are enforced by `packages/catch_ui_lints`
  plus `tool/check_catch_ui_lint_drift.sh`; verified count: `0`.
- Fixed sizing drift is covered by `tool/check_sizing.sh`; verified count: `0`.
- Broader system raw-value drift is covered by `tool/check_ui_system_raw_values.sh`;
  verified count: `0`.
- `tool/check_ui_local_constant_wrappers.sh --summary` returns `0`; token-backed named
  `EdgeInsets` constants are treated as semantic contracts rather than raw-value debt.
- `tool/check_ui_allow_debt.sh --summary` returns `0`; only fixed theme-independent art
  exceptions are accepted by the gate.
- The old "dashboard raw Badge" item is stale. The remaining raw `Badge` hit is
  inside the `CatchBadge` primitive implementation, where it belongs.
- Naive `BoxDecoration`/private-widget counts are triage signals, not debt by
  themselves. Core primitive internals and small private widgets are often correct.
- `bash tool/widget_cleanup_scan.sh --summary` now reports no feature-local decorated
  surface candidates and no unreviewed feature tappable candidates.
- `_ExploreClubCover` uses `GradedImage` for remote club photos and falls back to the
  club artwork primitive when no image is available.
- High-value widget-returning helper cleanup was done for the Event Success companion
  route chrome: repeated loading, error, and message helper functions are now named
  private widgets.
- Large Event Success and host-management files were audited. The remaining
  widget-returning methods are state-local section selectors or large reveal-card build
  decompositions, not duplicated shared UI shapes worth extracting as a standalone pass.

## Remaining Work

No standalone implementation task remains in this inventory after the 2026-06-01
cleanup pass. Future work should come from a fresh scanner delta, a specific
screen review, or an analyzer rule escalation rather than the old broad counts.

## Watch / Not Worth As Standalone

- Existing private widget classes in Event Success and host-management are mostly
  feature-local composition. Do not extract them just to reduce a count.
- `catch_no_widget_returning_method` remains useful at `info`; escalate only after a
  calibrated complexity threshold or repeated review findings prove it should be a
  stronger rule.
- Remaining typography-role scanner hits are review prompts, not confirmed debt.

## Verification Commands

```bash
bash tool/check_catch_ui_lint_drift.sh --count
bash tool/check_sizing.sh --count
bash tool/check_ui_system_raw_values.sh --count
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_allow_debt.sh --summary
bash tool/widget_cleanup_scan.sh --summary
flutter analyze --no-fatal-infos
```
