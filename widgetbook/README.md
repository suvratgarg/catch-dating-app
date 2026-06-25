# Catch Widgetbook

This is the local Widgetbook workspace for reviewing Catch design-system
components outside the production app shell. It depends on the main Flutter app
by path, so previews render the real widgets, tokens, fonts, and theme.

## Run

```bash
cd widgetbook
flutter pub get
dart run build_runner build
flutter run -d chrome
```

## Verify

```bash
cd widgetbook
flutter analyze
flutter build web --release
```

## Add Previews

- Put use cases under `widgetbook/lib/`.
- Annotate each builder with `@widgetbook.UseCase`.
- Keep previews aligned to `design/components/catch.components.json` state
  contracts.
- Re-run `dart run build_runner build` whenever annotations change so
  `lib/main.directories.g.dart` stays current.
- Keep broad catalog previews aligned with `docs/widget_catalog.md`. Prefer the
  live Dart class name when the catalog contains an older handoff alias.

## Coverage

Widgetbook currently has 97 annotated primitive use cases:

- `lib/primitives/primitive_contract_use_cases.dart`: 10 use cases covering the
  formal component-contract registry in `design/components/catch.components.json`.
- `lib/primitives/core_catalog_use_cases.dart`: 87 use cases covering the broad
  Core Design System section of `docs/widget_catalog.md`, including menu,
  input, search, navigation, loading, feedback, activity/media, event-card,
  data-display, sheet/footer, section, row, people, device-frame, profile, and
  layout primitives.

The feedback/error section intentionally groups placement adapters together:
`CatchErrorState`, `CatchErrorScaffold`, `CatchSliverErrorState`, and
`CatchInlineErrorState` appear under one Error surfaces use case rather than as
separate primitive review pages.

Controller/helper-only catalog rows are represented through their visible
widgets instead of standalone fake surfaces. Examples: `CatchGrade` is reviewed
through `CatchGradedImage`, `EventTicketShapeClipper` through the ticket-surface
preview, and celebration effects through `CatchCelebrationScreen` with effects
disabled for deterministic review.
