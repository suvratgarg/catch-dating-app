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

## WO-005 — CatchAnalyticsBar + person-layout token fix

1. Create `lib/core/widgets/catch_analytics_bar.dart`:

```dart
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Bottom-anchored fractional fill bar for mini bar charts.
///
/// Renders value/maxValue as a filled column; zero values show a faint stub.
class CatchAnalyticsBar extends StatelessWidget {
  const CatchAnalyticsBar({
    super.key,
    required this.value,
    required this.maxValue,
  });

  final num value;
  final num maxValue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final ratio = maxValue <= 0 ? 0.02 : (value / maxValue).clamp(0.06, 1);
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: ratio.toDouble(),
        child: CatchSurface(
          radius: CatchRadius.xs,
          borderWidth: 0,
          backgroundColor: value <= 0 ? t.line2 : t.ink,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
```

(Body is verbatim from the two byte-identical originals — `HostAnalyticsBar` in
`lib/hosts/presentation/host_operations_screen.dart`, `UserAnalyticsBar` in
`lib/user_analytics/shared/user_analytics_panel.dart`. If `CatchRadius` needs
an import in this file, mirror what catch_surface.dart consumers do.)

2. Migrate all call sites (`rg -w` both names in lib + widgetbook), delete
   both classes, handle widgetbook use-cases per gotcha 2, imports per
   gotcha 1 (host_operations_screen is a plain library; check the user
   analytics panel).
3. **Token drift fix** (separate concern, same order): in
   `lib/core/widgets/catch_person_row.dart`, `CatchPersonRosterLayout` uses
   `size: 11` for the context-line icon where `CatchPersonChatLayout` uses
   `size: CatchIcon.micro`. Change `11` → `CatchIcon.micro`.
4. Registries + checks + receipts (gotchas 6–8).

- [ ] primitive + migration + deletions
- [ ] token drift fix
- [ ] widgetbook + regen + registries + receipts

## WO-006 — Skeleton composition kit

New file `lib/core/widgets/catch_skeleton_layouts.dart` (keep
`catch_skeleton.dart` as the shape primitives; this file is compositions).
All three widgets below go in it.

```dart
enum CatchSkeletonRowLeading { mediaTile, avatar, icon }

/// Surface with N skeleton list rows: leading shape + two text lines,
/// optionally headed by a section-title line.
class CatchSkeletonRows extends StatelessWidget {
  const CatchSkeletonRows({
    super.key,
    this.leading = CatchSkeletonRowLeading.avatar,
    this.count = 3,
    this.titleWidth,
  });

  final CatchSkeletonRowLeading leading;
  final int count;
  /// Width of the leading section-title skeleton line; null = no title.
  final double? titleWidth;
  // build: CatchSurface(borderColor: t.line, padding: CatchInsets.content,
  //   child: Column(crossAxisAlignment: start, children: [
  //     if titleWidth != null: CatchSkeleton.text(width: titleWidth!), gapH14,
  //     for i in 0..count: Row([
  //       <leading>: mediaTile -> CatchSkeleton.box(width/height:
  //         CatchLayout.skeletonMediaTileExtent, radius: CatchRadius.sm);
  //         avatar -> CatchSkeleton.circle(size:
  //         CatchLayout.skeletonAvatarCompactExtent);
  //         icon -> CatchSkeleton.box(width/height: CatchIcon.md,
  //         radius: CatchRadius.sm),
  //       gapW12,
  //       Expanded(Column(start, [
  //         CatchSkeleton.text(width: i.isEven
  //           ? CatchLayout.skeletonTextBodyLongWidth
  //           : CatchLayout.skeletonTextSecondaryWidth),
  //         gapH6,
  //         CatchSkeleton.text(width: CatchLayout.skeletonTextDetailWidth),
  //       ])),
  //     ]), with gapH14 between rows (not after the last)
  //   ]))
}

/// Row of [count] equal expanded skeleton boxes (tab pickers, action rows).
class CatchSkeletonBoxRow extends StatelessWidget {
  const CatchSkeletonBoxRow({
    super.key,
    this.count = 2,
    required this.height,
    this.radius = CatchRadius.md,
    this.gap = CatchSpacing.s3,
  });
  // Row([for i: Expanded(CatchSkeleton.box(height: height, radius: radius)),
  //      gap between siblings])
}

/// Jittered wrap of pill skeletons standing in for chip/tag rows.
class CatchSkeletonChips extends StatelessWidget {
  const CatchSkeletonChips({super.key, this.height = CatchSpacing.s9});
  // Wrap(spacing/runSpacing: CatchSpacing.s2, children: three
  //   CatchSkeleton.box(radius: CatchRadius.pill, height: height) with widths
  //   CatchSpacing.s16 + s6 / s16 + s10 / s16 + s4)
}
```

IMPORTANT — before migrating each old widget, read its FULL body and confirm
it is only the pattern above (my review saw the first ~30 lines of each). If
a body has extra trailing elements or diverging structure, do NOT force it —
list it under Escalations and skip that member.

Migration map (then delete old classes; gotchas 1, 2, 5, 6 — several live in
part files / screen libraries):

| old | new |
|---|---|
| `HostRosterSkeleton(count: n)` | `CatchSkeletonRows(count: n, titleWidth: CatchLayout.skeletonTextSectionWidth)` |
| `CompanionPeerListSkeleton()` | `CatchSkeletonRows(titleWidth: CatchLayout.skeletonTextSectionWideWidth)` |
| `EventSuccessLiveRosterSkeleton()` | `CatchSkeletonRows(titleWidth: CatchLayout.skeletonTextTitleWidth)` |
| `HostEventRowsSkeleton(count: n)` | `CatchSkeletonRows(leading: CatchSkeletonRowLeading.mediaTile, count: n)` |
| `HostSettingsRowsSkeleton(rowCount: n)` | `CatchSkeletonRows(leading: CatchSkeletonRowLeading.icon, count: n)` |
| `DashboardQuickActionsLoadingRow()` | `CatchSkeletonBoxRow(height: CatchLayout.dashboardQuickActionSkeletonHeight, gap: CatchSpacing.s3)` |
| `EventSuccessTabPickerSkeleton()` | `CatchSkeletonBoxRow(count: 3, height: CatchLayout.controlCompactMinHeight, radius: CatchRadius.sm, gap: CatchSpacing.s2)` |
| `ClubTagLoadingSkeleton()` | `CatchSkeletonChips(height: CatchSpacing.s8)` |
| `GenderFilterSkeleton()` | `CatchSkeletonChips()` |
| `OptimisticSocialSkeleton()` | `EventDetailSocialSkeleton()` (byte-identical dupe; delete Optimistic, import `event_detail_loading_skeleton.dart` where needed) |

Also (same order): unify `EventPreviewSectionSkeleton` into
`EventSuccessSkeletonSurface` — both event_success, params unify to
`(titleWidth, textLines, trailingCount)`. Move the surviving class to
`lib/event_success/presentation/event_success_skeletons.dart` (new shared
feature file; both current hosts are screen-specific). Diff both bodies
first; escalate if the trailing sections differ structurally.

Note on intentional visual change: per-row text-width jitter is standardized
by `CatchSkeletonRows` — old widgets used slightly different width tokens per
row. This is accepted (skeleton widths are noise, not design intent).

Add one widgetbook use-case file for the three new compositions under
`widgetbook/lib/primitives/` (one state each; avatar-titled, mediaTile,
icon, box-row, chips).

- [ ] catch_skeleton_layouts.dart + widgetbook entry
- [ ] 10 migrations + deletions (bodies verified, escalations recorded)
- [ ] event_success skeleton surface merge
- [ ] regen + registries + receipts

## WO-007 — Absorb ChatShareCardSheet into CatchShareCardSheet

`lib/chats/presentation/widgets/chat_share_card.dart` hand-rolls the share
sheet that `lib/core/widgets/catch_share_card_sheet.dart` provides (club and
event share flows already use the core one).

1. Rewrite `showChatShareCardSheet` to build the core sheet:

```dart
Future<void> showChatShareCardSheet(
  BuildContext context, {
  required List<ChatMessage> messages,
  required String currentUid,
  required Event? event,
  required ExternalShareController share,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CatchShareCardSheet(
      card: ChatShareCard(
        messages: messages,
        currentUid: currentUid,
        event: event,
      ),
      share: share,
      fileName: 'catch-chat-card.png',
      buttonLabel: 'Share card',
      footnote: 'Names, photos, and timestamps are hidden.',
      subject: 'Catch chat card',
      text: 'Shared from Catch.',
      maxWidth: CatchLayout.chatShareCardWidth,
      pixelRatio: CatchLayout.chatShareCardPixelRatio,
    ),
  );
}
```

2. Delete `ChatShareCardSheet` + `_ChatShareCardSheetState`. KEEP
   `ChatShareCard`, `ShareCardHeader`, `ShareCardBubble`,
   `hasShareableChatMessages`, and the private message helpers.
3. Check the core sheet renders the card inside its own width constraint the
   same way the chat sheet did (`ConstrainedBox(maxWidth:)` vs the core
   `maxWidth` param) — if the core sheet does NOT constrain card width via
   `maxWidth`, escalate instead of hacking.
4. Widgetbook: repoint/delete use-cases typed `ChatShareCardSheet` (gotcha 2);
   keep `ChatShareCard` use-cases.
5. Imports (chat file is a plain library), regen, registries, receipts.

- [ ] rewrite + deletion + widgetbook + regen + receipts

---

## Escalations

(append design questions / blockers here; the review session picks them up)

## Completed

(move finished orders here with their receipts line)
