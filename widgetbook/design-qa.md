# Unified field transition prototype — design QA

## Scope

- Prototype only: `widgetbook/lib/geometry/field_transition_prototype.dart`
- Production `CatchField` and `CatchSection` behavior is unchanged.
- Review target: the complete pressed → open → pressed → closed handoff for both contained and divided sections.

## Visual truth

- Source geometry: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/divider-transition-audit/03-proposed-divider-consumed.png`
- Prototype resting state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/15-divided-direct-closed.png`
- Prototype pressed state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/07-opening-press-corrected.png`
- Prototype selected state: `/Users/suvratgarg/.codex/visualizations/2026/08/27/01a04248-440c-7150-a5f9-1bdc79df4d7c/field-transition-prototype/17-divided-direct-open.png`
- Viewport: 851 × 956 logical pixels in the Codex in-app browser.

## Comparison

### Full composition

- Both variants are visible in one scrollable Widgetbook use case.
- Contained geometry is clipped by the section perimeter and uses a rectangular field surface.
- Divided geometry owns a rounded interaction surface that extends across the adjacent divider edge.
- Resting field content, icons, chevrons, typography, and chip controls reuse Catch primitives and tokens.

### Focused transition region

- The divided row's single opaque interaction surface remains present from press tint through active tint, visually consuming the section-owned divider during the handoff.
- The contained row does not introduce nested rounded corners inside the section perimeter.
- Opening and closing can be replayed together at 4× slow motion or triggered independently by tapping either Host row.

## Findings and iteration history

1. Initial runtime QA found that Widgetbook's reduced-motion preview suppressed the interpolation while the replay timing continued. The prototype now deliberately shows motion regardless of that preview setting; production accessibility behavior was not changed.
2. Initial closing QA found that offstaging the drawer could remove it before its reverse interpolation completed. The offstage shortcut was removed so opacity, height factor, and translation animate through the full closing path.
3. Final direct-toggle QA confirmed independent open/close behavior and the intended selected geometry for both variants.

## Final result

passed
