---
doc_id: widget_cleanup
version: 3.0.0
updated: 2026-05-12
owner: recursive_audit_loop
status: active
---

# Widget Cleanup

This is the short human-readable entry point for widget cleanup. Active state
lives in `docs/audit_registry/backlog.json`; recurring rules live in
`docs/audit_registry/rules.json`; detailed historical notes live in
`docs/audit_registry/archive/widget_cleanup_todo_2026_05_05_full.md`.

## Read Policy

For future passes:

1. Read `docs/audit_registry/README.md`.
2. Read `docs/audit_registry/backlog.json` for current pending work, next-up
   order, stable debt ids, and scanner counts.
3. Read `docs/audit_registry/rules.json` for active/watch rules.
4. Read feature-specific sections in `docs/widget_catalog.md` only when the
   target surface needs widget inventory or primitive ownership context.
5. If a pass adds, deletes, moves, renames, or materially changes a widget,
   primitive API, screen ownership model, sliver/tab structure, or reusable
   design-system role, update `docs/widget_catalog.md` in the same pass.
6. Search the archived full tracker only when a stable debt id, rule id, or old
   finding explicitly points there.

## Current Sources

| Source | Purpose |
|---|---|
| `docs/audit_registry/backlog.json` | Active queue, next actions, stable debt ids, scanner snapshot. |
| `docs/audit_registry/rules.json` | Active/watch/archived audit rules and sunset criteria. |
| `docs/widget_catalog.md` | Current widget inventory, primitive APIs, and feature ownership notes. |
| `docs/audit_registry/archive/widget_cleanup_todo_2026_05_05_full.md` | Historical changelog retained for forensics only. |

## Current Scanner Snapshot

The active scanner snapshot is stored in `docs/audit_registry/backlog.json`.
As of the latest stored snapshot, the important queues are:

| Scanner | Count | Interpretation |
|---|---:|---|
| `centralized_widget_timing` | 3 | Intentional centralized timing helpers plus queued calendar cleanup. |
| `feature_tappable_candidates` | 1 | One remaining feature-level tap target needing semantic review. |
| `literal_sized_box_spacing_candidates` | 176 | Broad spacing triage queue; fix touch-by-touch, not as a sweeping churn pass. |
| `raw_decorated_surface_candidates` | 67 | Broad decorated-surface triage queue; includes some primitive-local chrome. |
| `unstyled_text_candidates` | 15 | Broad text-style triage queue. |
| `fine_grained_spacing_compatibility` | 17 | Compatibility helpers, separate from canonical 4-point spacing migration. |

The following scanners were clean in the stored snapshot:

- `async_unit_flush`
- `positional_widget_finders`
- `presentation_repository_reaches`
- `catch_tokens_prop_drilling`
- `raw_material_button_candidates`
- `raw_text_input_candidates`
- `profile_bottom_sheet_editor_candidates`
- `profile_inline_chip_label_candidates`
- `profile_inline_chip_clear_action_candidates`
- `profile_stacked_text_tile_editor_candidates`
- `profile_stacked_chip_tile_editor_candidates`
- `fixed_white_pill_cta_candidates`
- `raw_range_slider_candidates`
- `raw_number_stepper_candidates`
- `legacy_spacing_canonical_candidates`
- `presentation_plugin_imports`
- `raw_error_surface_candidates`

## Update Policy

Do not add dated changelog entries to this file. When a cleanup pass changes
the active state, update `backlog.json`, `rules.json`, `widget_catalog.md`, or
the specific durable source-of-truth doc. This file should remain a compact
navigation pointer.
