---
doc_id: catch-ui-lint-p0-spec
version: 0.5.0
updated: 2026-06-02
owner: ui_elevation_initiative
dri: TBD
status: remaining_work
priority: P0
parent: catch-ui-lint-rules-plan
---

# Catch UI Lint P0 - Remaining Work

The P0 analyzer plugin exists and is wired. This file now tracks only the gaps
between the original build spec and the live implementation.

## Implemented / Closed

- `packages/catch_ui_lints` is enabled from `analysis_options.yaml`.
- CI runs `flutter analyze --no-fatal-infos`, `tool/check_riverpod_lint.sh`,
  `tool/check_catch_ui_lints.sh`, `tool/check_sizing.sh`, and
  `tool/check_ui_local_constant_wrappers.sh`.
- The plugin emits the current P0 rule set:
  `catch_no_raw_ui_spacing`, `catch_no_token_arithmetic`,
  `catch_use_section_list`, `catch_prefer_semantic_insets`,
  `catch_event_detail_prefers_photo_thumbnail`,
  `catch_no_raw_material_control`, `catch_no_raw_color`,
  `catch_no_raw_text_style`, `catch_no_raw_font_drift`,
  `catch_no_raw_radius`, and `catch_no_widget_returning_method`.
- `tool/check_catch_ui_lints.sh` uses a seeded violation corpus and asserts diagnostic
  codes, not just analyzer exit status.
- `tool/check_catch_ui_lint_drift.sh --count` reports `0`, so the retired
  color/text/font scanner subset has an analyzer-backed drift count.
- The implementation no longer globally excludes `lib/labs/` or `explore_concept`.
- Raw-color carve-outs are line-level `token:allow` art exceptions; there are no
  whole-file color exemptions for `graded_image.dart` or `event_activity_visuals.dart`.
- `catch_no_raw_radius` covers `Radius.circular`, `Radius.elliptical`,
  `BorderRadius.circular`, and raw `Radius.*` arguments passed to `BorderRadius.all`,
  `only`, `vertical`, and `horizontal`.
- `catch_no_raw_material_control` is narrowed to the P0 `Chip`/`Card`/`Badge` family:
  `ActionChip`, `Badge`, `Card`, `Chip`, `ChoiceChip`, `FilterChip`, `InputChip`, and
  `RawChip`.
- `tool/check_ui_local_constant_wrappers.sh --summary` and
  `tool/check_ui_allow_debt.sh --summary` return `0`.
- `tool/check_sizing.sh`, `tool/check_ui_local_constant_wrappers.sh`,
  `tool/check_ui_system_raw_values.sh`, and `tool/check_ui_allow_debt.sh` are
  analyzer-output wrappers over Catch UI plugin diagnostics rather than shell scanners.
- The shared shell scanner helper has been retired.
- `tool/check_design_tokens.sh` and `tool/check_raw_color_sweep.sh` are gone in the
  current worktree; do not revive them.
- `test/lint_contracts/font_family_set_test.dart` guards plugin font-family drift.

## Remaining Work

No P0 implementation task remains in this spec. Future work should come from a
specific analyzer false positive/false negative, a new deterministic UI invariant,
or a decision to escalate an existing `INFO` rule to `WARNING`.

## Parked / Not P0

- A resolved-AST rule class is not required for the current P0 implementation. Keep
  parsed rules until a specific rule needs type identity.
- Do not re-add analyzer `errors:` overrides for plugin codes unless the local analyzer
  starts recognizing those codes in `analysis_options.yaml`; the current staging is via
  each `LintCode` severity.
- Style Dictionary / DTCG token source-of-truth is deferred until a designer or a second
  platform needs token editing outside Dart.

## Verification Commands

```bash
bash tool/check_catch_ui_lints.sh
bash tool/check_catch_ui_lint_drift.sh --count
bash tool/check_sizing.sh --count
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_system_raw_values.sh --count
bash tool/check_ui_allow_debt.sh --summary
flutter test test/lint_contracts/font_family_set_test.dart
flutter analyze --no-fatal-infos
```
