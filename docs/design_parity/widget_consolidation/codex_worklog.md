# Widget Consolidation — Codex Work Log

Living queue of mechanical work orders for the widget consolidation initiative.
Decisions (the *why* and the API designs) are made in review sessions and
recorded in `decisions.json`; this file is the *how*. Work top-down. Mark each
order's checkboxes as you complete them and append a receipts line (commands +
headline numbers) under the order. Do not make design decisions here — if an
instruction is ambiguous or a design question appears, stop that order, note it
under **Escalations**, and continue with the next order.

## Standing environment facts

- Flutter/Dart: `export PATH="$HOME/development/flutter/bin:$PATH"` (or use
  `tool/flutter_with_env.sh`).
- Never edit `packages/catch_ui_lints/` (local plugin recompile crashes
  `dart analyze`).
- `lib/` analyzer baseline: **192 info-level issues, 0 warnings/errors**
  (verified 2026-07-03 on `claude/widget-consolidation-slice-1`). Any new
  warning/error is regression from your change.
- Widgetbook workspace analyzer baseline: 67 issues including 1 warning
  (`unused_element_parameter` at `widgetbook/lib/hosts/host_operations_use_cases.dart:7115`)
  — that warning is pre-slice-1 fallout addressed in WO-001.

## Hard-won gotchas (read before every order)

1. **Part files**: many feature widget files are `part of` a screen library
   (all of `lib/event_success/presentation/{host_parts,companion_parts}/…`).
   They cannot hold imports — add imports to the parent library file
   (`event_success_host_screen.dart` / `event_success_companion_screen.dart`).
2. **Widgetbook use-case deletion**: a use-case = `@widgetbook.UseCase(...)`
   annotation + the top-level function under it (ends at the next `}` at
   column 0). NEVER regex-match from `@widgetbook.UseCase(` to a `type:` line
   non-greedily — multi-line wildcards span across neighboring blocks and
   will delete thousands of lines. Parse annotation extent by paren depth
   (skip string literals), check it contains `type: <X>,`, then delete
   annotation + function. Assert expected deletion counts.
3. After adding/removing/repointing any `@widgetbook.UseCase`, regenerate:
   `cd widgetbook && flutter pub get && dart run build_runner build
   --delete-conflicting-outputs` (~30s).
4. `dart format` every touched file (mechanical injections leave bad wrapping).
5. When deleting a widget class, delete `class X extends … {` through the next
   `}` at column 0, then grep repo-wide (`lib/`, `widgetbook/lib`, excluding
   `*.g.dart`) for the name and assert zero references remain.
6. Registries go stale after any widget add/delete/rename. Regenerate in this
   order and run their checks:
   ```bash
   node tool/design/generate_widget_classification.mjs
   node tool/design/check_widget_classification.mjs
   dart run tool/widget_dedupe/bin/extract_fingerprints.dart
   node tool/design/build_widget_similarity.mjs
   node tool/design/build_widget_similarity.mjs --check
   node tool/design/check_widgetbook_coverage.mjs --check
   env DART=$HOME/development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs
   ```
7. Verification suite per order: `flutter analyze lib` (compare against
   baseline above), `cd widgetbook && flutter analyze`, plus item 6.
8. Append a receipts section per completed order to
   `docs/audit_registry/widget_consolidation_receipts.md` (commands, counts,
   spot-checks).

---

## WO-001 — Slice-1 cleanup (branch `claude/widget-consolidation-slice-1`)

Slice 1 (stats→CatchStatColumn, headers→CatchSectionHeader+subtitle, icon
actions→CatchTopBarIconAction, meta rows→new CatchMetaRow) is already executed
and analyzer-clean in `lib/`. Remaining mechanical debris:

- [ ] **Ugly renamed identifiers**: the bulk rename produced identifiers like
  `profileCatchStatColumnes` (was `profileRunningStat…`). Find them:
  `rg -n "CatchStatColumne|StatColumns|statColumn" widgetbook/lib/catches/catches_use_cases.dart widgetbook/lib/user_analytics/user_analytics_use_cases.dart`.
  Rename functions/locals to sensible names (e.g. `profileStatColumnStates`);
  grammar: lowerCamel, no mangled plurals. Then regen widgetbook (gotcha 3).
- [ ] **Orphaned `themeMode` param** at
  `widgetbook/lib/hosts/host_operations_use_cases.dart:7115`
  (`unused_element_parameter`): slice 1 deleted the only use-case(s) passing
  `themeMode:` to that scope class. Confirm via
  `git log -p -- widgetbook/lib/hosts/host_operations_use_cases.dart` on this
  branch; if confirmed, remove the constructor parameter and hardcode the
  previous default (`ThemeMode.light`) where the field was read. If other
  callers pass it, leave and note here.
- [ ] **Widgetbook knob coverage for new API**: add a `subtitle` example to
  the existing CatchSectionHeader use-case (search
  `widgetbook/lib/primitives/` for it) and confirm a CatchMetaRow state
  appears under the repointed club use-case (already typed
  `type: CatchMetaRow` in `widgetbook/lib/clubs/club_detail_use_cases.dart`).
- [ ] Registries + checks + receipts (gotchas 6–8).
- [ ] `dart format` pass over all files changed on the branch; commit.

## WO-002 — CatchScrim primitive (decision c004, decisions.json)

Create `lib/core/widgets/catch_scrim.dart`:

```dart
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Photo scrim gradients. The design-system vocabulary for darkening photo
/// surfaces so overlaid ink stays readable. Always pointer-transparent.
class CatchScrim extends StatelessWidget {
  /// Detail-screen hero: editorial dark, heavier at the top.
  const CatchScrim.detailHero({super.key})
    : _stops = const [0.0, 0.45, 1.0],
      _base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.photoScrimMedium,
        CatchOpacity.onDarkMuted,
      ];

  /// Card photo frame: light top band, clear middle, subtle bottom edge.
  const CatchScrim.photoFrame({super.key})
    : _stops = const [0.0, 0.48, 1.0],
      _base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.none,
        CatchOpacity.eventSuccessSubtleBorder,
      ];

  /// Profile hero: caller-tinted, readable top and bottom thirds.
  const CatchScrim.heroTint({super.key, required Color base})
    : _stops = const [0.0, 0.45, 0.78, 1.0],
      _base = base,
      _alphas = const [
        CatchOpacity.profileHeroScrimTop,
        CatchOpacity.none,
        CatchOpacity.profileHeroScrimMid,
        CatchOpacity.profileHeroScrimBottom,
      ];

  final List<double> _stops;
  final List<double> _alphas;
  final Color? _base;

  @override
  Widget build(BuildContext context) {
    final base = _base ?? CatchTokens.editorialDark;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: _stops,
            colors: [for (final a in _alphas) base.withValues(alpha: a)],
          ),
        ),
      ),
    );
  }
}
```

Notes: `CatchOpacity.none` must exist (it is used by ProfileHeroScrim today as
`CatchOpacity.none`); ClubPhotoScrim's middle stop is `Colors.transparent` —
`base.withValues(alpha: CatchOpacity.none)` is visually identical (alpha 0).
If `CatchOpacity`/`CatchTokens` need extra imports in this file, mirror
`catch_detail_hero_backdrop.dart`'s imports. `eventSuccessSubtleBorder` as a
bottom-edge alpha is pre-existing token reuse from ClubPhotoScrim — keep, but
note it under Escalations as a token-naming smell for the owner.

Migration map (then delete each old class; gotchas 2, 5, 6):

| old | new | sites |
|---|---|---|
| `const CatchDetailHeroScrim()` | `const CatchScrim.detailHero()` | rg `CatchDetailHeroScrim` — lib + widgetbook; class in `catch_detail_hero_backdrop.dart` |
| `const ClubPhotoScrim()` | `const CatchScrim.photoFrame()` | class in `clubs/.../directory_card.dart` |
| `ProfileHeroScrim(base: X)` | `CatchScrim.heroTint(base: X)` | class in `swipes/shared/profile_surface/catch_profile_view.dart` |

`CatchEventThumbnailScrimOverlay` stays untouched. Add one widgetbook use-case
for CatchScrim under `widgetbook/lib/primitives/` showing the three presets
over a sample photo/color block. Delete or repoint widgetbook use-cases typed
to the three old names (gotcha 2).

- [ ] primitive + migration + deletions
- [ ] widgetbook use-case + regen
- [ ] registries + checks + receipts

## WO-003 — Inline six empty-state wrappers (decision c009)

Each class below is `Center(child: CatchEmptyState(icon: …, title: …,
message: …))`. For each: replace its single call site with that literal
expression (mark `const` where the old constructor call was const), delete the
class, ensure `CatchEmptyState`/`CatchIcons` imports exist in the call-site's
library (watch gotcha 1 — check for part files), delete/handle any widgetbook
use-case blocks typed to these names (gotcha 2; several live in
`event_success_strict_coverage_use_cases.dart`-style generated files — check
`rg -l` first).

- [ ] `EventMapEmptyState`, `EventMapNoPinnedEventsState` — both defined and
  used in `lib/events/presentation/event_map_screen.dart`.
- [ ] `LaunchAccessDisabledView`, `LaunchAccessSignedOutView`,
  `LaunchAccessStatusView` — `lib/launch_access/presentation/launch_access_application_screen.dart`.
  StatusView carries its conditionals inline:
  `icon: application.status.unlocksProfileCreation ? … : …` etc. — keep the
  exact expressions.
- [ ] `ProfileUnavailableBody` — `lib/user_profile/presentation/profile_screen.dart`.
- [ ] registries + checks + receipts. Expect `widget_classification.json`
  total to drop by 6.

## WO-004 — EventCtaStatusLeading (decision small-widget family)

In `lib/events/presentation/widgets/event_detail_cta.dart`: replace
`AttendedLeading` and `BookedLeading` with one widget in the same file:

```dart
class EventCtaStatusLeading extends StatelessWidget {
  const EventCtaStatusLeading({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: t.primary, size: CatchIcon.md),
        gapW6,
        Text(label, style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}
```

Call-site mapping: `AttendedLeading()` →
`EventCtaStatusLeading(icon: CatchIcons.directionsRunRounded, label: 'Completed')`;
`BookedLeading()` →
`EventCtaStatusLeading(icon: CatchIcons.checkCircleRounded, label: "You're in!")`.
`UnsavedChangesPill` stays. Repoint/delete widgetbook use-cases for the two
old names (gotcha 2).

- [ ] merge + call sites + widgetbook + registries + receipts

---

## Escalations

(append design questions / blockers here; the review session picks them up)

## Completed

(move finished orders here with their receipts line)
