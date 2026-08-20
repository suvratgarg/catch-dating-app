# Host form builder design QA

## Scope

- Surface: compact Host form creation and editing, guided Questions step.
- Viewport: 390 x 844 logical pixels, light theme.
- Source: `/Users/suvratgarg/.codex/generated_images/01a01efa-9d9b-7341-afec-be4e1cf572dc/exec-f3a9eb6f-3b0c-4265-8513-f378965f4b36.png`.
- Implementation: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/host-form-builder-guided-questions/light.png`.
- Side-by-side comparison: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01efa-9d9b-7341-afec-be4e1cf572dc/host-form-builder-guided-comparison.png`.

## Comparison

- The implementation now matches the selected workflow hierarchy: Build and Responses remain form-level destinations, while Questions, Settings, and Publish are explicit builder steps.
- The Questions step uses the approved decision-oriented heading and guidance, then presents the materialized form questions as the dominant editing controls.
- Existing Catch top-bar, field-row, section, and bottom-action primitives remain intact. The compact title uses the smaller canonical section-title treatment so the form identity stays readable alongside Preview and overflow actions.
- Question rows now emphasize the question label and subordinate the real answer type and requiredness. This matches the reference hierarchy without inventing application-specific behavior metadata.
- Reordering is functional rather than decorative: the visible Reorder questions action opens drag handles for each persisted question. A question editor can also move a stable question identity into another section.
- The reference's unchecked optional suggestions are not rendered. The current editor response contains only materialized questions, and the product contract requires templates to remain versioned source data rather than hard-coded widget branches. Adding suggestion toggles truthfully therefore needs a catalog/editor contract extension.

## Severity review

- P0: none.
- P1: none.
- P2: source-backed optional question suggestions remain a later backend/catalog increment.

## Iteration history

1. Replaced the settings-first compact layout with a question-first outline.
2. Split compact creation into Questions, Settings, and Publish steps with contextual pinned actions.
3. Added direct drag reordering and cross-section question moves while preserving question IDs.
4. Removed the now-redundant compact settings sheet and its stale localization copy.
5. Captured production Flutter fonts and icons at the reference viewport, compared both screens together, and tightened title and row hierarchy from the visual result.

## Final result

passed
