# Host form builder design QA

## Scope

- Surface: compact Host form creation and editing, guided Questions step and inline question editor.
- Viewports: 390 x 844 for the workflow reference and 393 x 852 for the production-pattern comparison, verified in light and dark themes.
- Workflow source: `/Users/suvratgarg/.codex/generated_images/01a01efa-9d9b-7341-afec-be4e1cf572dc/exec-f3a9eb6f-3b0c-4265-8513-f378965f4b36.png`.
- Interaction source: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/edit-organizer-reference/host_clubs_inline_edit_pending/light.png`.
- Implementation: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/host-form-builder-inline-reorder/light.png`.
- Focused editor: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/host-form-builder-inline-question-focus/light.png` and `dark.png`.
- Side-by-side comparison: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/host-form-builder-inline-reorder-comparison.png`.

## Comparison

- The implementation now matches the selected workflow hierarchy: Build and Responses remain form-level destinations, while Questions, Settings, and Publish are explicit builder steps.
- The Questions step uses the approved decision-oriented heading and guidance, then presents the materialized form questions as the dominant editing controls.
- Existing Catch top-bar, field-row, section, and bottom-action primitives remain intact. The compact title uses the smaller canonical section-title treatment so the form identity stays readable alongside Preview and overflow actions.
- Question rows now emphasize the question label and subordinate the real answer type and requiredness. This matches the reference hierarchy without inventing application-specific behavior metadata.
- Reordering is functional rather than decorative: each persisted question owns its drag handle, so order is changed in place without navigating to a second reorder surface. The drag affordance remains attached to the question when that field expands.
- The focused editor no longer opens a modal. It reuses the production Edit Organizer disclosure pattern: the selected row becomes one rounded, outlined section with a rotating chevron and its editor content revealed in place.
- One stable question ID may be expanded at a time. Opening another question collapses the previous outline, including after reordering.
- Every question setting is visible in the expanded section: wording, answer type, help, requiredness, data classification, prefill, Host response presentation, choice options, and applicable validation fields. There is no nested Advanced settings disclosure.
- Compact move-up and move-down buttons are no longer shown because they duplicate the inline drag interaction. The wide editor retains them for keyboard and desktop workflows.
- The reference's unchecked optional suggestions are not rendered. The current editor response contains only materialized questions, and the product contract requires templates to remain versioned source data rather than hard-coded widget branches. Adding suggestion toggles truthfully therefore needs a catalog/editor contract extension.

## Severity review

- P0: none.
- P1: none.
- P2: none.

Source-backed optional question suggestions remain a later catalog/editor-contract increment rather than a visual parity fix.

## Iteration history

1. Replaced the settings-first compact layout with a question-first outline.
2. Split compact creation into Questions, Settings, and Publish steps with contextual pinned actions.
3. Added direct drag reordering and cross-section question moves while preserving question IDs.
4. Removed the now-redundant compact settings sheet and its stale localization copy.
5. Captured production Flutter fonts and icons at the reference viewport, compared both screens together, and tightened title and row hierarchy from the visual result.
6. Moved reorder handles into every question row and deleted the redundant reorder sheet, action, and localization copy.
7. Simplified the focused question editor while preserving every advanced control.
8. Replaced the question bottom sheet with the Edit Organizer accordion-owned outlined field, kept reordering attached to the row, and exposed all question details inline.

## Final result

passed
