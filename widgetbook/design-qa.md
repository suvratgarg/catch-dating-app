# Unified field transition prototype — design QA

## Scope

- Prototype only: `widgetbook/lib/geometry/field_transition_prototype.dart`
- Production `CatchField` and `CatchSection` behavior is unchanged.
- Review target: the complete pressed → open → pressed → closed handoff for both contained and divided sections.

## Visual truth

- Source geometry: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/divider-transition-audit/03-proposed-divider-consumed.png`
- Profile-mode pressed state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/21-profile-pressed.png`
- Profile-mode handoff state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/22-profile-handoff.png`
- Profile-mode scrubbed state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/23-profile-scrubbed.png`
- Profile-mode selected state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/24-profile-selected.png`
- Viewport: 1420 × 800 logical pixels in the Codex in-app browser.

## Comparison

### Full composition

- Both variants are visible in one scrollable Widgetbook use case.
- Contained geometry is clipped by the section perimeter and uses a rectangular field surface.
- Divided geometry owns a rounded interaction surface that extends across the adjacent divider edge.
- Resting field content, icons, chevrons, typography, and chip controls reuse Catch primitives and tokens.

### Focused transition region

- The divided row's single opaque interaction surface remains present from press tint through active tint, visually consuming the section-owned divider during the handoff.
- The contained row does not introduce nested rounded corners inside the section perimeter.
- Opening and closing use one shared 700 ms comparison timeline. The slider can scrub both variants to any frame, and named controls jump to Resting, Pressed, Handoff, or Selected.

## Findings and iteration history

1. Initial runtime QA found that Widgetbook's reduced-motion preview suppressed the interpolation while the replay timing continued. Production accessibility behavior was not changed.
2. Initial closing QA found that offstaging the drawer could remove it before its reverse interpolation completed. The offstage shortcut was removed so opacity, height factor, and translation animate through the full closing path.
3. The first slow-motion replay multiplied both interpolation durations and procedural waits, making intentional pauses appear as lag. It was replaced with one normal-speed timeline and a manual scrubber.
4. The transition renderer now derives tint, contextual border, reveal height, chevron rotation, and active shadow from the same progress value for both variants.
5. A transparent resting decoration produced a faint compositing surface in Flutter Web. The decoration is now omitted completely when progress is zero.
6. Final QA confirmed exact named states, continuous scrub behavior, normal-speed opening and closing, responsive stacking below a 900 px local content width, and a warning-free profile-mode build.

## Final result

passed
