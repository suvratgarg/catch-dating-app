# UI Cohesion Cleanup Todo

Scope: app-facing Catch Flutter UI consistency, spacing, surfaces, semantics,
scanner coverage, and process hardening after the typography migration.

## Active Todo

- [x] Add scanner coverage for typography regressions found during the previous
      pass: app-facing low-level type roles, nonzero letter spacing, and raw
      `TextStyle` use.
- [x] Tighten scanner coverage for spacing and decorated surfaces so future
      regressions are programmatically visible.
- [x] Migrate literal `SizedBox` spacing candidates to shared gap constants or
      documented spacing primitives.
- [x] Review `Sizes.p*` compatibility helper findings and either migrate them
      to `CatchSpacing` or document intentional fine-grained layout use.
- [x] Migrate decorated surface candidates to `CatchSurface`, a shared
      primitive, or a documented local exception where a custom paint/media shell
      is more appropriate.
- [x] Add semantics/tooltips or shared primitives for scanner-reported custom
      tappables.
- [x] Move presentation-owned repository/plugin side effects behind provider,
      controller, or service seams where appropriate.
- [x] Reduce brittle widget-test timing and positional finder findings, adding
      helper APIs when a pattern repeats.
- [x] Update widget catalog and audit registry with new primitive/process
      changes.
- [x] Run format, analyzer, focused tests, scanner, `git diff --check`, and
      audit report after all cleanup loops are exhausted.

## Newly Identified

- [x] Add `CatchBottomDock` for anchored chat/filter/auth action strips.
- [x] Add `CatchIconTile`, `CatchStatusDot`, and `CatchPageDots` so icon badges,
      tiny status dots, and page indicators do not reimplement local shells.
- [x] Extend `CatchSurface` with custom border-radius support for shaped
      surfaces such as chat bubbles.
- [x] Move `XFile` out of the profile photo editor screen so picker types stay
      behind the upload controller seam.
- [x] Teach the scanner to keep Event Success stage/cinematic surfaces,
      gradients, chart bars, media masks, and animated underlines out of the
      generic card-surface queue.

## Verification

- `dart format` on touched UI and test areas: clean.
- `flutter analyze --no-fatal-infos` on touched UI/domain/test graph: no issues.
- Focused Flutter test batch covering primitives, migrated surfaces, Event
  Success, profile, swipes, clubs, and uploads: 303 tests passed.
- `WIDGET_CLEANUP_SCAN_MAX_LINES=220 bash tool/widget_cleanup_scan.sh`: all
  scanner categories clean.
- `git diff --check`: clean.
- `dart tool/audit_registry.dart mark-pass --pass
  2026-05-25-ui-cohesion-spacing-surface-cleanup ...`: stamped 17 tracked
  paths; skipped this tracker while it remains untracked.
