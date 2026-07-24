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

The generated Widgetbook coverage and contract-reference checks own the live
use-case counts; this README intentionally does not duplicate those changing
numbers. Run:

```bash
node tool/run.mjs check design:widgetbook-contract-refs design:widgetbook-coverage
```

CI also analyzes and compiles this package as a web consumer. Structural
annotation coverage is not sufficient on its own: a stale callback, constructor,
or generated route must fail compilation before merge.

The feedback/error section intentionally groups placement adapters together:
`CatchErrorState`, `CatchErrorScaffold`, `CatchSliverErrorState`, and
`CatchInlineErrorState` appear under one Error surfaces use case rather than as
separate primitive review pages.

Controller/helper-only catalog rows are represented through their visible
widgets instead of standalone fake surfaces. Examples: `CatchGrade` is reviewed
through `CatchGradedImage`, `EventTicketShapeClipper` through the ticket-surface
preview, and celebration effects through `CatchCelebrationScreen` with effects
disabled for deterministic review.
