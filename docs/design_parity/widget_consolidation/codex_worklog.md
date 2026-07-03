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
- `lib/` analyzer baseline: **188 info-level issues, 0 warnings/errors**
  (re-verified 2026-07-03 post-WO-014 review). Any new warning/error is
  regression from your change; the info count may only go down.
- Widgetbook workspace analyzer baseline: **65 issues, 0 warnings** (post
  WO-014 review).
- `check_widgetbook_coverage.mjs --check` fails on an INHERITED
  catalog-or-replace decision queue (134 items at review time, owned by the
  review session — do not work it). Record the count in each receipt; treat
  the check as regression only if the count GROWS from your change.

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
9. **Escalations live in THIS file's Escalations section.** A skip justified
   only in the receipts doc is invisible to the review queue (the WO-006
   divider-skeleton skip was nearly missed this way). Receipts may repeat it;
   the worklog entry is mandatory.
10. **Cluster IDs are unstable**: `widget_similarity.json` renumbers clusters
    on every regeneration. Ledger entries must always carry member names;
    when triaging, match candidates against `decisions.json` by MEMBER SET,
    never by cluster id. The `*-reconciled` ledger-entry pattern is the
    blessed way to record an id remap without re-deciding.

---

## WO-001 — Slice-1 cleanup (branch `claude/widget-consolidation-slice-1`)

Slice 1 (stats→CatchStatColumn, headers→CatchSectionHeader+subtitle, icon
actions→CatchTopBarIconAction, meta rows→new CatchMetaRow) is already executed
and analyzer-clean in `lib/`. Remaining mechanical debris:

- [x] **Ugly renamed identifiers**: the bulk rename produced identifiers like
  `profileCatchStatColumnes` (was `profileRunningStat…`). Find them:
  `rg -n "CatchStatColumne|StatColumns|statColumn" widgetbook/lib/catches/catches_use_cases.dart widgetbook/lib/user_analytics/user_analytics_use_cases.dart`.
  Rename functions/locals to sensible names (e.g. `profileStatColumnStates`);
  grammar: lowerCamel, no mangled plurals. Then regen widgetbook (gotcha 3).
- [x] **Orphaned `themeMode` param** at
  `widgetbook/lib/hosts/host_operations_use_cases.dart:7115`
  (`unused_element_parameter`): slice 1 deleted the only use-case(s) passing
  `themeMode:` to that scope class. Confirm via
  `git log -p -- widgetbook/lib/hosts/host_operations_use_cases.dart` on this
  branch; if confirmed, remove the constructor parameter and hardcode the
  previous default (`ThemeMode.light`) where the field was read. If other
  callers pass it, leave and note here.
- [x] **Widgetbook knob coverage for new API**: add a `subtitle` example to
  the existing CatchSectionHeader use-case (search
  `widgetbook/lib/primitives/` for it) and confirm a CatchMetaRow state
  appears under the repointed club use-case (already typed
  `type: CatchMetaRow` in `widgetbook/lib/clubs/club_detail_use_cases.dart`).
- [x] Registries + checks + receipts (gotchas 6–8).
- [x] `dart format` pass over all files changed on the branch; commit.

Receipt: 2026-07-03 Codex WO-001 cleanup renamed `profileRunningStates`,
removed the unused `_HostManageRouteScope.themeMode` private API, added
`CatchSectionHeader.subtitle` catalog coverage, regenerated Widgetbook
directories, widget classification, and widget similarity, and appended the
full command receipt in
`docs/audit_registry/widget_consolidation_receipts.md`. Clean checks:
`flutter analyze --no-fatal-infos lib` (192 existing infos, 0
warnings/errors), widget classification check (1174 entries, 44 review items,
0 private widget classes flagged), widget similarity check (1066 widgets, 62
clusters, 10 absorb candidates), widget dedupe probes, widget cleanup scan,
manifest-only, agent readiness, and `git diff --check`. Existing blockers
recorded in the receipt: Widgetbook analyzer still has 66 inherited issues
after the removed `themeMode` warning, and Widgetbook coverage still has a 142
item catalog-or-replace decision queue with 0 stale decisions.

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

- [x] primitive + migration + deletions
- [x] widgetbook use-case + regen
- [x] registries + checks + receipts

Receipt: 2026-07-03 Codex WO-002 created `CatchScrim` with `detailHero`,
`photoFrame`, and `heroTint` presets; migrated detail hero, club directory
photo chrome, and profile hero callers; removed the three old local scrim
classes and their stale Widgetbook use cases; repointed the formal
`catch.detail_media.scrim` preview to `CatchScrim`; refreshed Widgetbook,
catalog, component contract, classification, and similarity artifacts. Clean
checks: `flutter analyze --no-fatal-infos lib` (192 existing infos, 0
warnings/errors), component contract check, classification check (1172 entries,
44 review items), similarity check (1064 widgets, 61 clusters, 9 absorb
candidates), dedupe probes, widget cleanup scan, manifest-only, agent
readiness, JSON parse, stale scrim symbol scan, and `git diff --check`.
Existing blockers recorded in the receipt: Widgetbook analyzer remains at 66
inherited issues, Widgetbook coverage remains at a 142 item queue, and
Widgetbook contract refs remain blocked by unrelated HostOperations preview ids.

## WO-003 — Inline six empty-state wrappers (decision c009)

Each class below is `Center(child: CatchEmptyState(icon: …, title: …,
message: …))`. For each: replace its single call site with that literal
expression (mark `const` where the old constructor call was const), delete the
class, ensure `CatchEmptyState`/`CatchIcons` imports exist in the call-site's
library (watch gotcha 1 — check for part files), delete/handle any widgetbook
use-case blocks typed to these names (gotcha 2; several live in
`event_success_strict_coverage_use_cases.dart`-style generated files — check
`rg -l` first).

- [x] `EventMapEmptyState`, `EventMapNoPinnedEventsState` — both defined and
  used in `lib/events/presentation/event_map_screen.dart`.
- [x] `LaunchAccessDisabledView`, `LaunchAccessSignedOutView`,
  `LaunchAccessStatusView` — `lib/launch_access/presentation/launch_access_application_screen.dart`.
  StatusView carries its conditionals inline:
  `icon: application.status.unlocksProfileCreation ? … : …` etc. — keep the
  exact expressions.
- [x] `ProfileUnavailableBody` — `lib/user_profile/presentation/profile_screen.dart`.
- [x] registries + checks + receipts. Expect `widget_classification.json`
  total to drop by 6.

Receipt: 2026-07-03 Codex WO-003 inlined all six
`Center(child: CatchEmptyState(...))` wrappers at their single production call
sites, removed the stale Widgetbook use cases typed to the retired event-map
and profile wrapper symbols, updated the profile screen contract and widget
catalog, and regenerated Widgetbook directories plus widget classification and
similarity. Clean checks: `flutter analyze --no-fatal-infos lib` (192 existing
infos, 0 warnings/errors), widget classification check (1166 entries, 44 review
items, 0 private widget classes flagged), widget similarity check (1058
widgets, 60 clusters, 9 absorb candidates), dedupe probes, screen contract
check, widget cleanup scan, manifest-only, agent readiness, JSON parse, stale
retired-symbol scan, and `git diff --check`. Existing blockers recorded in the
receipt: Widgetbook analyzer remains blocked by inherited HostOperations issues
(65), Widgetbook coverage remains at a 139 item queue with 0 stale decisions,
and Widgetbook contract refs remain blocked by unrelated HostOperations preview
ids. Note: the old call sites were `const` wrapper constructor calls, but the
inlined `CatchIcons` expressions are not valid constant expressions, so the
literal bodies intentionally cannot stay `const`.

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

- [x] merge + call sites + widgetbook + registries + receipts

Receipt: 2026-07-03 Codex WO-004 replaced `BookedLeading` and
`AttendedLeading` with feature-level `EventCtaStatusLeading`, updated
production dock-state mapping plus Event Detail and core-catalog Widgetbook
previews, repointed the standalone Widgetbook preview to the new type, added
the new public widget to `docs/widget_catalog.md` v2.5.549, and regenerated
Widgetbook, classification, and similarity. Clean checks:
`flutter analyze --no-fatal-infos lib` (192 existing infos, 0 warnings/errors),
widget classification check (1165 entries, 44 review items, 0 private widget
classes flagged), widget similarity check (1057 widgets, 60 clusters, 9 absorb
candidates), dedupe probes, widget cleanup scan, manifest-only, agent
readiness, JSON parse, stale retired-symbol scan, and `git diff --check`.
Existing blockers remain inherited: Widgetbook analyzer has 65 HostOperations
issues, Widgetbook coverage has a 139 item queue with 0 stale decisions, and
Widgetbook contract refs fail on unrelated HostOperations preview ids. Note:
`EventCtaStatusLeading` keeps a `const` constructor for callers with constant
icons, but current `CatchIcons` values are not valid constant expressions, so
the migrated call sites are intentionally non-const.

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

- [x] primitive + migration + deletions
- [x] token drift fix
- [x] widgetbook + regen + registries + receipts

Receipt: 2026-07-03 Codex WO-005 promoted the byte-identical
`HostAnalyticsBar` and `UserAnalyticsBar` implementations into
`CatchAnalyticsBar`, repointed production and Widgetbook use cases, refreshed
the generated Widgetbook directory, replaced the `CatchPersonRosterLayout`
raw context-icon size with `CatchIcon.micro`, and updated the widget catalog
to v2.5.550. Clean checks: widget classification check (1164 entries, 45
review items, 0 private widget classes flagged), widget similarity check (1056
widgets, 60 clusters, 9 absorb candidates), widget dedupe probes, root
`flutter analyze --no-fatal-infos lib` (192 existing infos, 0 warnings/errors),
widget cleanup scan, manifest-only, JSON parse, agent readiness, and
`git diff --check`. Existing blockers recorded in the receipt: Widgetbook
analyzer still has 65 inherited HostOperations issues, Widgetbook coverage
still has a 139 item catalog-or-replace decision queue with 0 stale decisions,
and Widgetbook contract refs still have inherited HostOperations preview-id
drift.

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

- [x] catch_skeleton_layouts.dart + widgetbook entry
- [x] 10 migrations + deletions (8 completed in WO-006; 2 resolved by WO-016)
- [x] event_success skeleton surface merge
- [x] regen + registries + receipts

Escalations:

- Resolved by WO-016: `HostEventRowsSkeleton` and
  `HostSettingsRowsSkeleton` were migrated after `CatchSkeletonRows.divided`
  added the divider behavior that WO-006 correctly refused to invent inline.

Receipt: 2026-07-03 Codex WO-006 created `CatchSkeletonRows`,
`CatchSkeletonBoxRow`, and `CatchSkeletonChips`, added their Widgetbook catalog
states, absorbed `HostRosterSkeleton`, `CompanionPeerListSkeleton`,
`EventSuccessLiveRosterSkeleton`, `DashboardQuickActionsLoadingRow`,
`EventSuccessTabPickerSkeleton`, `ClubTagLoadingSkeleton`,
`GenderFilterSkeleton`, and `OptimisticSocialSkeleton`, and moved the shared
Event Success section surface into `event_success_skeletons.dart` with
`trailingCount` API. Clean checks: widget classification check (1158 entries,
46 review items, 0 private widget classes flagged), widget similarity check
(1050 widgets, 59 clusters, 9 absorb candidates), widget dedupe probes, root
`flutter analyze --no-fatal-infos lib` (192 existing infos, 0 warnings/errors),
widget cleanup scan, manifest-only, JSON parse, agent readiness, and
`git diff --check`. Existing blockers recorded in the receipt: Widgetbook
analyzer still has 65 inherited HostOperations issues, Widgetbook coverage
still has a 134 item catalog-or-replace decision queue with 0 stale decisions,
and Widgetbook contract refs still have inherited HostOperations preview-id
drift.

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

- [x] rewrite + deletion + widgetbook + regen + receipts

Receipt: 2026-07-03 Codex WO-007 rewired `showChatShareCardSheet` to
`CatchShareCardSheet`, deleted `ChatShareCardSheet` and
`_ChatShareCardSheetState`, kept `ChatShareCard`, `ShareCardHeader`,
`ShareCardBubble`, `hasShareableChatMessages`, and private message helpers, and
repointed the Widgetbook sheet state to `CatchShareCardSheet`. The core sheet
already constrains the preview through `ConstrainedBox(maxWidth:
widget.maxWidth)`, so no escalation was needed. Clean checks: focused analyzer,
root `flutter analyze --no-fatal-infos lib` (192 existing infos, 0
warnings/errors), widget classification (1156 entries, 46 review items, 0
private widget classes flagged), widget similarity (1049 widgets, 59 clusters,
9 absorb candidates), widget dedupe probes, widget cleanup scan, manifest-only,
JSON parse, stale active-code scan, and `git diff --check`. Existing blockers:
Widgetbook analyzer still has 65 inherited HostOperations issues, Widgetbook
coverage still has a 134 item catalog-or-replace decision queue with 0 stale
decisions, and Widgetbook contract refs still have inherited HostOperations
preview-id drift.

## WO-008 — Inline four more empty-state wrappers + pattern recon

Same policy as WO-003 (thin `CatchEmptyState` wrappers; inline at call sites,
delete class, widgetbook per gotcha 2, imports per gotcha 1):

- [x] `PaymentHistoryEmptyState` (`lib/payments/presentation/payment_history_screen.dart`)
  and `ReviewsHistoryEmptyState` (`lib/reviews/presentation/reviews_history_screen.dart`)
  — both are `CatchScreenBody(scrollable: false, child: Center(child:
  CatchEmptyState(…)))`; inline with each call site's actual icon/title/message
  arguments.
- [x] `CalendarMessage` (`lib/events/presentation/calendar/calendar_screen.dart`)
  and `SavedEventsMessage` (`lib/events/presentation/saved_events_screen.dart`)
  — inline, and use CalendarMessage's override set for BOTH surfaces:
  `iconSize: CatchLayout.calendarEmptyIconSize, padding:
  CatchInsets.contentSpacious, titleStyle: CatchTextStyles.titleL(context),
  messageStyle: CatchTextStyles.proseM(context, color: t.ink2)` (keep each
  site's own icon: calendar → `calendarMonthOutlined`, saved →
  `bookmarkBorderRounded`). This intentionally replaces SavedEventsMessage's
  `eventInfoTileExtent` icon size (token misuse) — accepted visual change.
- [x] **Recon (report only, no code)**: count occurrences of the pattern
  `CatchScreenBody(… Center(child: CatchEmptyState(…)))` and of `Center(child:
  CatchEmptyState(…))` inside `lib/` after the inlines land. Post both counts
  under Escalations — if ≥4 screen-body cases, the next review batch designs a
  `CatchEmptyState` screen variant.
- [x] regen + registries + receipts

Escalations:

- Post-inline recon found 3 `CatchScreenBody(... Center(child:
  CatchEmptyState(...)))` cases and 14 direct `Center(child:
  CatchEmptyState(...))` cases in `lib/`. The screen-body count is below the
  >=4 threshold, so no `CatchEmptyState` screen variant work order was opened.

Receipt: 2026-07-03 Codex WO-008 inlined `PaymentHistoryEmptyState`,
`ReviewsHistoryEmptyState`, `CalendarMessage`, and `SavedEventsMessage`;
standardized Saved Events on the Calendar empty-state override set while
keeping its bookmark icon; deleted the wrapper-specific Widgetbook use cases;
regenerated Widgetbook/classification/similarity; and recorded the recon
counts above. Clean checks: focused analyzer, root `flutter analyze
--no-fatal-infos lib` (192 existing infos, 0 warnings/errors), widget
classification (1152 entries, 46 review items, 0 private widget classes
flagged), widget similarity (1045 widgets, 57 clusters, 9 absorb candidates),
widget dedupe probes, widget cleanup scan, manifest-only, JSON parse, active
code stale-name scan, and `git diff --check`. Existing blockers: Widgetbook
analyzer still has 65 inherited HostOperations issues, Widgetbook coverage
still has a 133 item catalog-or-replace decision queue with 0 stale decisions,
and Widgetbook contract refs still have inherited HostOperations preview-id
drift.

## WO-009 — CatchCountBadge + badge/pill cleanups

1. New `lib/core/widgets/catch_count_badge.dart`: move the body of
   `AppShellNavigationBadge` (in `lib/core/presentation/app_shell.dart`)
   verbatim as:

```dart
/// Overlays a count pill on [child]; renders [child] alone when count <= 0.
class CatchCountBadge extends StatelessWidget {
  const CatchCountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;
  // build: verbatim AppShellNavigationBadge body (99+ clamp, SizedBox +
  // Stack + bottom-aligned child + positioned CatchSurface pill).
}
```

   Migrate app-shell call sites, delete `AppShellNavigationBadge`.
2. Rewrite `CatchTabDockIcon` (`lib/core/widgets/catch_tab_dock.dart`): build
   the glyph `Icon(icon, size: CatchLayout.tabDockIconSize, color: color)` and
   `return CatchCountBadge(count: badgeCount, child: glyph);` — delete its
   copy-pasted overlay body. Pixel parity expected (same tokens).
3. **Recon**: check whether `CatchCountPill` / `CatchPersonUnreadCountPill`
   also implement the `> 99 ? '99+'` clamp + primary pill recipe. Report under
   Escalations (possible third copy; do not merge without a decision).
4. `PhotoSlotMainBadge` (`lib/image_uploads/shared/photo_slot.dart`) → replace
   call sites with the existing `CatchBadge`: `CatchBadge(label: label,
   uppercase: true, backgroundColor: t.ink, foregroundColor: t.bg)` — if
   CatchBadgeTone has an ink/inverse tone that matches, prefer the tone over
   raw color overrides. Minor padding delta vs the old `micro10/s1` insets is
   accepted standardization. Delete the class.
5. `MapPill` (`lib/events/presentation/widgets/event_detail_design_primitives.dart`):
   add `CatchOpacity.overlayPillFill = 0.93` to the CatchOpacity token set
   (follow the existing token file's ordering/doc style) and replace the raw
   `0.93`. Widget stays.
6. widgetbook (new CatchCountBadge use-case under primitives; repoint/delete
   old-typed blocks) + regen + registries + receipts.

- [x] CatchCountBadge + migrations
- [x] tab dock delegation
- [x] recon report (count-pill triplication)
- [x] PhotoSlotMainBadge -> CatchBadge; MapPill token fix
- [x] regen + registries + receipts

Completed by Codex: added `CatchCountBadge` as `catch.badge.count_badge`,
migrated `AppShellNavigationBar` and `CatchTabDockIcon`, replaced
`PhotoSlotMainBadge` with `CatchBadge`, moved the map overlay alpha to
`CatchOpacity.overlayPillFill`, regenerated Widgetbook and widget registries,
and recorded the receipt.

Escalations / recon:

- `CatchPersonUnreadCountPill` also clamps counts with `count > 99 ? '99+'`
  and uses the primary/primaryInk badge recipe through `CatchBadge`; keep it as
  a separate row-trailing unread-chat semantic primitive unless a later decision
  explicitly folds person-row trailing badges into the count-badge family.
- `CatchCountPill` is related but not the same contract: it accepts a
  caller-supplied badge string, does not own the 99+ clamp, and uses an ink
  overlay badge on a raised floating control rather than the primary anchored
  navigation/icon overlay recipe.

## WO-010 — CatchConfirmDialog shell delegation

In `lib/core/widgets/catch_adaptive_dialog.dart`: `CatchFormDialog` renders
the overlay shell (Dialog + CatchSurface overlay elevation + title + stacked
actions row). Inspect `CatchConfirmDialog` (same file): if it duplicates that
shell, rewrite its build to delegate — `return CatchFormDialog(title: …,
child: <its message/content>, actions: <its actions>);` — keeping
CatchConfirmDialog's public API unchanged. If the shells differ structurally
(e.g. different insets, width, or action layout that is load-bearing), do NOT
force it: record the diff under Escalations. Both classes stay public.

- [x] inspect + delegate (or escalate) + regen + receipts

Completed by Codex as an escalation, not a merge: `CatchConfirmDialog` and
`CatchFormDialog` share the same outer `Dialog` + overlay `CatchSurface` shell,
but their inner contracts differ in load-bearing ways. Confirm dialogs center
the title/body copy and render two or fewer actions as equal-width full-width
buttons, falling back to a stacked column for longer action lists. Form dialogs
left-align the title, reserve a child content slot after `gapH16`, and
right-align arbitrary action widgets in a trailing row. Delegating
`CatchConfirmDialog` directly to `CatchFormDialog` would either wrap the
confirm action row in an unconstrained trailing row or change its button layout,
so both public classes stay distinct pending a later decision to introduce a
private shared shell.

## WO-011 — CatchTabRail<T>

New `lib/core/widgets/catch_tab_rail.dart`:

```dart
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:flutter/material.dart';

/// Segmented tab rail for app-bar bottoms: a [CatchOptionGroup] in the
/// standard rail shell.
class CatchTabRail<T> extends StatelessWidget implements PreferredSizeWidget {
  const CatchTabRail({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    this.groupKey,
  });

  final T selected;
  final ValueChanged<T> onChanged;
  final List<CatchOption<T>> options;
  final Key? groupKey;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5, 0, CatchSpacing.s5, CatchSpacing.s2),
        child: CatchOptionGroup<T>(
          key: groupKey,
          selected: selected,
          onChanged: onChanged,
          options: options,
        ),
      ),
    );
  }
}
```

1. Add `CatchLayout.tabRailHeight = 48` token (both old rails hardcode
   `Size.fromHeight(48)`); follow the CatchLayout file's grouping/doc style.
   Fix imports so CatchLayout/CatchOption resolve (mirror the old rails).
2. Migrate: `HostClubTabRail(selected:, onChanged:)` →
   `CatchTabRail<HostClubTab>(groupKey: _hostClubTabRailKey, selected:,
   onChanged:, options: const [...verbatim four CatchOptions...])` (in
   `lib/hosts/presentation/host_operations_screen.dart`; the private key
   stays in that file). Same for `HostSettingsTabRail` →
   `CatchTabRail<HostSettingsMode>` (two options, no key) in
   `host_account_screen.dart`. Delete both classes.
3. Widgetbook: repoint/delete old-typed use-cases (gotcha 2); add a
   CatchTabRail use-case under primitives.
4. regen + registries + receipts.

- [x] token + primitive + migrations + widgetbook + regen + receipts

Completed by Codex: added `CatchTabRail<T>` plus
`CatchLayout.tabRailHeight`, migrated Host Clubs and Host Settings app-bar
bottom rails to the shared primitive, deleted `HostClubTabRail` and
`HostSettingsTabRail`, removed their Widgetbook use cases, added the
`catch.tab_rail` component contract and primitive Widgetbook states, repointed
Host Settings/Host Clubs design metadata to the shared rail, regenerated
Widgetbook and widget registries, and recorded the receipt.

## WO-012 — HostEmptyActionCard

New `lib/hosts/presentation/widgets/host_empty_action_card.dart`:

```dart
/// Empty-state card with CTA actions for host surfaces.
class HostEmptyActionCard extends StatelessWidget {
  const HostEmptyActionCard({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
  });

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          if (actions.isNotEmpty) ...[
            gapH18,
            if (actions.length == 1)
              actions.single
            else
              Row(
                children: [
                  for (final indexed in actions.indexed) ...[
                    if (indexed.$1 > 0) gapW8,
                    Expanded(child: indexed.$2),
                  ],
                ],
              ),
          ],
        ],
      ),
    );
  }
}
```

Migrate (all three in `lib/hosts/presentation/host_operations_screen.dart`;
read each full body first — HostProfileMissingState keeps its outer ListView
at the call site, HostTodayEmptyEvents passes its two buttons as `actions`,
title/body strings move to call sites verbatim including the
`${club.name}` interpolation). Delete the three classes; widgetbook per
gotcha 2; regen + registries + receipts. If any body has structure beyond
title/body/actions (e.g. the `creating` flag maps to the button's isLoading
at the call site), keep that logic at the call site — escalate only if it
does not fit the actions-slot shape.

- [x] widget + 3 migrations + widgetbook + regen + receipts

Completed by Codex: added feature-level `HostEmptyActionCard`, migrated Host
Home no-club branches, Host Clubs no-club branch, Host Profile missing branch,
and Host Today empty-events branch to caller-owned actions inside the shared
card, deleted `HostEmptyState`, `HostProfileMissingState`, and
`HostTodayEmptyEvents`, replaced wrapper Widgetbook coverage with
`HostEmptyActionCard` states, repointed design metadata, regenerated Widgetbook
and widget registries, and recorded the receipt.

## WO-013 — Skeleton title-width token drift

`EventSuccessLiveTabSkeleton` / `EventSuccessSetupTabSkeleton` /
`EventSuccessReportTabSkeleton` (in
`lib/event_success/presentation/event_success_host_screen.dart`) pass raw
title widths (148, 190, 170, 150, …) to `EventSuccessSkeletonSurface`.
Replace each with the nearest existing `CatchLayout.skeletonText*` token
(list them first: `rg "skeletonText" lib/core/theme/`). Exact widths are
skeleton noise — nearest token is fine; do NOT add new tokens. Also sweep the
rest of that file and `event_success_event_preview_loading_screen.dart` for
other raw skeleton widths while there. The widgets themselves stay.

- [x] token sweep + regen + receipts

Completed by Codex: replaced raw `EventSuccessSkeletonSurface.titleWidth`
values in the Host Setup/Live/Report tab skeletons and Event Success preview
loading skeletons with nearest existing `CatchLayout.skeletonText*` tokens,
confirmed no raw `titleWidth`/`width` literals remain in the WO-013 scope,
regenerated widget classification/fingerprint/similarity artifacts, and
recorded the receipt.

## WO-014 — Batch A/B merges (directory card, paper ticket, hero shell)

1. **DirectoryClubCard** (rule R3): `DirectoryIdentityCard` and
   `DirectoryPhotoCard` in
   `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart`
   are identical except the `media:` argument (`ClubPolaroidArtwork` vs
   `ClubPhotoMediaOverlay`). Merge into one `DirectoryClubCard` in the same
   file. First check the call sites: if the caller picks the variant based on
   photo availability (like `ClubShareArtwork` does internally in
   `club_share_card.dart`), fold that choice into the widget and drop the
   param; otherwise keep `media` as a `Widget` param. Note which path you took
   in the receipt.
2. **PaperTicketSerial delegation** (rule R4): in
   `lib/event_success/presentation/companion_parts/event_success_companion_shared.dart`,
   rewrite `PaperTicketSerial.build` to compute its two strings and
   `return PaperTicketDetail(label: …, value: …);`. Accepted visual delta:
   value maxLines 1→2.
3. **EventSuccessHeroSurface**: new shared widget in
   `lib/event_success/presentation/event_success_hero_surface.dart` (plain
   library, not a part file):

```dart
/// Accent→ink diagonal gradient hero shell for event_success surfaces.
class EventSuccessHeroSurface extends StatelessWidget {
  const EventSuccessHeroSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentRelaxed,
      child: child,
    );
  }
}
```

   Rewrite `EventPreviewHero`, `LabHero`, `ManualQaHero` (files per
   decisions.json c045 entry) to return
   `EventSuccessHeroSurface(child: <their existing Column>)`; LabHero keeps
   its outer Padding/Center/ConstrainedBox around the shell. All three stay
   public. Watch part-file imports (gotcha 1).
4. widgetbook per gotcha 2 where types changed + regen + registries +
   receipts.

- [x] DirectoryClubCard merge
- [x] PaperTicketSerial delegation
- [x] EventSuccessHeroSurface + three delegations
- [x] regen + registries + receipts

Completed by Codex: merged `DirectoryPhotoCard` and `DirectoryIdentityCard`
into `DirectoryClubCard`, folding the photo/no-cover choice inside the widget
from `hasCoverImage` while preserving the no-cover two-line title behavior;
rewrote `PaperTicketSerial` to compute its label/value and delegate to
`PaperTicketDetail`; added `EventSuccessHeroSurface` and delegated
`EventPreviewHero`, `LabHero`, and `ManualQaHero` to the shared shell; added
direct Widgetbook coverage for the merged directory card and new hero shell;
regenerated Widgetbook, variant, classification, fingerprint, similarity, and
coverage artifacts; and recorded the receipt.

## WO-015 — Rule-driven triage sweep (read consolidation_rules.md first)

`docs/design_parity/widget_consolidation/consolidation_rules.md` now encodes
the review session's decision patterns. Sweep every cluster and ranked pair
in `docs/audit_registry/widget_similarity.json` that has NO entry in
`decisions.json`:

1. For each candidate, test the KEEP rules (K1–K4), then the MERGE rules
   (R1–R4), in order. Apply the first exact match; record the outcome in
   `decisions.json` with `"decidedBy": "codex-rule:<id>"` and a one-line
   rationale naming the evidence (hashes equal, composition edge, etc.).
2. No exact match, or K5 territory → add one Escalations line here:
   `- [cluster id] members … — nearest rule …, blocked because …`.
3. Execute the mechanical merges/inlines/delegations that rules R1–R4
   authorize (respecting the scope limits at the top of the rulebook),
   batch-committing per ~5 candidates with the full verification suite
   (gotchas 6–7) per batch.
4. Screens-scope clusters: ledger them as escalations without reading deeply.
5. Receipt: counts of candidates triaged per rule, escalated, merged,
   deleted.

- [x] sweep + ledger entries + escalations
- [x] rule-authorized executions in batches
- [x] receipts with per-rule counts

**Operating amendments (2026-07-03 review of WO-001..014 — read before
continuing the sweep):**

1. Scope for the overnight run is clusters + ranked pairs ONLY. Do NOT start
   the 236 name families or the 134-item widgetbook coverage queue — both are
   review-session work.
2. Screen-scope clusters: ledger them as `codex-rule:scope-screen` with
   member names; do NOT also add an Escalations line for each (the existing
   screen escalation lines are acknowledged — future ones would be noise; the
   review session reads them from the ledger).
3. Gotchas 9 and 10 above are new (worklog-escalations mandate; member-set
   matching / unstable cluster ids) — they came from this review.
4. Use the updated analyzer baselines from Standing environment facts (188 /
   65); after each batch the numbers may only improve.
5. When a merge rule authorizes execution but the FULL body reveals structure
   the target primitive does not model (the WO-006 divider case), the outcome
   is: keep, ledger with the reason, AND an Escalations line here — never
   extend a core primitive's API yourself.

Progress by Codex: applied the rulebook's screen-scope limit to the current
similarity registry and ledgered seven screen clusters as escalations in
`decisions.json`: `c011-event-success-report-metrics-skeleton`,
`c016-loading-screen`, `c039-filters-section`, `c043-calendar-stats-header`,
`c048-companion-primary-action-skeleton`, `c049-sliver-body`, and
`c051-footer`. No code was changed in this ledger-only batch.

Progress by Codex: reconciled current registry ids `c003-catch-meta-row` and
`c033-event-cta-status-leading` to the existing owner decisions for
`StageSectionLabel` and `UnsavedChangesPill`, then escalated `c044-row`
(`ActivityTypeRow`, `MoreActivityTypesRow`) under K5. No code was changed in
this ledger-only batch.

Progress by Codex: reconciled seven additional current registry ids to
previously reviewed decisions: `c004-layout`, `c005-dialog`,
`c009-rows-skeleton`, `c013-host-card`, `c021-rotation-slots`,
`c022-override-sheet`, and `c023-override-round-editor`. No code was changed in
this ledger-only batch.

Progress by Codex: reconciled six remaining screen-scope/current-id clusters
to prior reviewed decisions: `c017-tab-skeleton`, `c025-rows`, `c029-row`,
`c046-hero`, `c047-home-screen`, and `c050-companion-error`. No code was
changed in this ledger-only batch.

Progress by Codex: reconciled six more current registry ids to prior reviewed
decisions: `c026-slot-row`, `c034-celebration-details-card`,
`c036-dashboard-full`, `c037-card`, `c038-profile-tab`, and `c042-editor`. No
code was changed in this ledger-only batch.

Progress by Codex: triaged eight small widget clusters. Kept `c028-panel` and
`c031-event-detail-policy-summary` under K4; escalated
`c012-pill`, `c018-icon`, and
`c030-catch-framework-error-debug-details` under K5; escalated
`c010-choice-entry-editor`, `c014-catch-option-group-item`, and
`c035-reveal-host-copy` as no-exact-match design/API questions. No code was
changed in this ledger-only batch.

Progress by Codex: completed the remaining current-cluster sweep after WO-016
regenerated similarity ids. Kept `c006-sliver-body`, `c014-skeleton`,
`c018-card`, `c019-skeleton`, `c023-app-shell`,
`c026-event-success-skeleton-surface`, `c039-people-token-row`, `c040-card`,
and `c044-event-focus-rail` under K2/K4; escalated
`c002-afterglow-beat-row`, `c007-attendee-prompt-preview`, and
`c008-stage-action-dock` under K5; escalated
`c031-activity-attribute-goal-chips` as no-exact-match feature API design. No
code was changed in this ledger-only batch. Ranked-pair-only candidates remain
for the next WO-015 pass.

Progress by Codex: executed ranked-pair R2 for
`CatchEmptyState`/`ExploreEmptyState`. Deleted the feature wrapper, inlined the
Explore empty/search/filter copies into direct `CatchEmptyState` compositions in
production and Widgetbook, updated Explore design-contract preview ids to
`CatchEmptyState/Empty states`, regenerated Widgetbook and widget registries,
and recorded the receipt. Ranked-pair-only candidates still remain open after
this targeted execution.

Progress by Codex: triaged the next eight ranked-pair-only candidates by member
set: the three Host/User analytics metric/tile/trend pairs are now reopened as
analytics-kit escalations under the v0.2 K2 discriminator, the branded/plain
sheet header pair remains a K4 keep, and four design/API questions remain
escalated (`EditHostedEventPickerTile`/`WhenStepPickerTile`,
`DarkPill`/`EventSuccessDarkPill`, `CatchMetaRow`/`EventPolicyLabSectionTitle`,
and `CatchTopBarIconAction`/`OverlayIconAction`). No code was changed in this
ledger-only batch. Ranked-pair-only candidates still remain open after this
targeted triage.

Progress by Codex: triaged ranked-pair-only candidates 34-56 by member set.
Kept five composition-wrapper pairs under K1, three domain-fork pairs under K2,
and three small/specialized pairs under K4. Escalated eight K5 concept
mismatches and four no-exact API/screen-state questions. No code was changed in
this ledger-only batch. Ranked-pair-only candidates still remain open after
this targeted triage.

Progress by Codex: triaged ranked-pair-only candidates 58-99 by member set.
Kept eight skeleton/state/small-card pairs under K4. Escalated five K5 concept
mismatches and five no-exact screen-scope/API questions. No code was changed in
this ledger-only batch. Ranked-pair-only candidates still remain open after
this targeted triage.

Progress by Codex: triaged ranked-pair-only candidates 101-130 by member set.
Kept one composition-wrapper pair under K1, seven domain-fork pairs under K2,
three shared-internal pairs under K3, and nine small/state/skeleton pairs under
K4. Escalated four K5 concept mismatches and six no-exact API/screen-state
questions. No code was changed in this ledger-only batch. Ranked-pair-only
candidates still remain open after this targeted triage.

Progress by Codex: triaged ranked-pair-only candidates 131-160 by member set.
Kept one composition-wrapper pair under K1, five domain-fork pairs under K2,
and thirteen small/state/skeleton pairs under K4. Reopened two analytics-kit
candidates under the v0.2 K2 discriminator, escalated eight K5 concept
mismatches, and escalated one no-exact screen-scope/API question. No code was
changed in this ledger-only batch. Ranked-pair-only candidates still remain
open after this targeted triage.

Progress by Codex: triaged the final ranked-pair-only candidates 161-200 by
member set. Kept one composition-wrapper pair under K1, eight domain-fork pairs
under K2, and four small/skeleton pairs under K4. Reopened one analytics-kit
candidate under the v0.2 K2 discriminator, escalated thirteen K5 concept
mismatches, and escalated eleven no-exact screen-scope/API questions. No code
was changed in this ledger-only batch. Member-set comparison now reports zero
uncovered ranked pairs, so WO-015 is complete for the amended clusters +
ranked-pairs scope.

## WO-016 — Review answers from the WO-001..014 audit

1. **`CatchSkeletonRows.divided` flag** (answers the WO-006 skip): add
   `this.divided = false` to `CatchSkeletonRows`
   (`lib/core/widgets/catch_skeleton_layouts.dart`); when true, separate rows
   with the divider treatment used by `HostEventRowsSkeleton` /
   `HostSettingsRowsSkeleton` in
   `lib/hosts/presentation/widgets/host_loading_skeletons.dart` — read their
   full bodies and mirror the divider's exact color/height/insets. Then
   absorb both: `HostEventRowsSkeleton(count: n)` →
   `CatchSkeletonRows(leading: CatchSkeletonRowLeading.mediaTile, count: n,
   divided: true)`; `HostSettingsRowsSkeleton(rowCount: n)` →
   `CatchSkeletonRows(leading: CatchSkeletonRowLeading.icon, count: n,
   divided: true)` (verify titled-ness per body before migrating). Delete the
   classes (~17 refs incl. widgetbook), gotchas 1/2/5/6.
2. **`CatchOpacity.photoFrameEdge` token** (answers the WO-002 escalation):
   add a token with the same value as `CatchOpacity.eventSuccessSubtleBorder`
   (follow the token file's ordering/doc style; doc comment: bottom-edge
   alpha for photo-frame scrims) and switch `CatchScrim.photoFrame` to it.
   Leave `eventSuccessSubtleBorder` in place for its event_success usages.
3. regen + registries + receipts; ledger both under the existing decision
   entries (update status), member-set matching per gotcha 10.

- [x] divided flag + two absorptions
- [x] photoFrameEdge token swap
- [x] regen + registries + receipts

Progress by Codex: added `CatchSkeletonRows.divided`, absorbed
`HostEventRowsSkeleton` and `HostSettingsRowsSkeleton` into the shared
primitive, added `CatchOpacity.photoFrameEdge`, and switched
`CatchScrim.photoFrame` to the new token. Widgetbook directories,
classification, fingerprints, and similarity were regenerated; final registry
checks and receipt stamping are still in progress.

Receipt by Codex: completed the regeneration and receipt pass. Focused app and
Widgetbook analyzers for the changed files were clean; full app analyzer stayed
at the inherited info-only baseline; full Widgetbook analyzer, coverage, and
contract-reference gates remain blocked by the existing HostOperations queue
listed in the receipt.

## WO-017 — Shared count-label formatter (for when work resumes)

The `count > 99 ? '99+' : '$count'` clamp exists in `CatchCountBadge`
(`lib/core/widgets/catch_count_badge.dart`) and
`CatchPersonUnreadCountPill` (`lib/core/widgets/catch_person_row.dart`).
Add a top-level `String catchCountLabel(int count)` in
`catch_count_badge.dart`, use it in both, and sweep `lib/` for other
`'99+'` clamps. No visual change.

- [x] formatter + two call sites + sweep + regen + receipts

Progress by Codex: added `catchCountLabel(int count)` in
`catch_count_badge.dart`, switched `CatchCountBadge`,
`CatchPersonUnreadCountPill`, and the swept `DashboardNotificationBellButton`
clamp to the helper, ran the `99+` clamp sweep, refreshed the audit registry
(no generated file changes), fixed the stale `CatchDetailHeroScrim` test
reference to `CatchScrim`, and recorded the receipt.

---

## WO-018 — Analytics kit v1 (CatchAnalyticsMetricTile / MetricGrid / Section)

Resolves the `escalated-analytics-kit` ledger entries. Design principle: the
kit renders **display-ready data**; feature-specific metric-id switches,
value formatters, and copy tables STAY in the features, which map their typed
models into the kit model at call sites.

1. New `lib/core/widgets/catch_analytics_kit.dart` (imports mirror
   catch_analytics_bar.dart plus badge/text/tokens):

```dart
enum CatchMetricStatus { ready, partial, missing }

/// Display-ready payload for one analytics metric tile.
class CatchMetricCardData {
  const CatchMetricCardData({
    required this.icon,
    required this.value,
    required this.label,
    this.caption,
    this.status = CatchMetricStatus.ready,
    this.partialBadgeLabel = 'Partial',
    this.missingBadgeLabel = 'Missing',
  });

  final IconData icon;
  final String value;
  final String label;
  final String? caption;
  final CatchMetricStatus status;
  final String partialBadgeLabel;
  final String missingBadgeLabel;
}

/// Metric tile: icon + status badge, numeric value, label, optional caption.
class CatchAnalyticsMetricTile extends StatelessWidget {
  const CatchAnalyticsMetricTile({super.key, required this.data});

  final CatchMetricCardData data;

  // build: verbatim shared body of the two old tiles —
  // muted = status == missing;
  // CatchSurface(padding: CatchInsets.content,
  //   borderColor: muted ? t.warning.withValues(alpha: CatchOpacity.mutedBorderUrgent) : t.line,
  //   backgroundColor: muted ? t.warning.withValues(alpha: CatchOpacity.warningFill) : t.surface,
  //   child: Column(start, [
  //     Row([Icon(data.icon, size: CatchIcon.sm, color: t.ink2), Spacer(),
  //          if (status != ready) CatchBadge(
  //            label: partial ? data.partialBadgeLabel : data.missingBadgeLabel,
  //            tone: partial ? CatchBadgeTone.warning : CatchBadgeTone.neutral)]),
  //     gapH12,
  //     Text(data.value, maxLines: 1, ellipsis, numericLarge(muted ? t.ink3 : t.ink)),
  //     gapH4,
  //     Text(data.label, maxLines: 1, ellipsis, labelM(t.ink2)),
  //     if (data.caption non-blank) gapH8 + Text(caption, maxLines: 2, ellipsis,
  //       supporting(t.ink3)),
  //   ]))
}

/// Two-column wrap grid of metric tiles.
class CatchAnalyticsMetricGrid extends StatelessWidget {
  const CatchAnalyticsMetricGrid({
    super.key,
    required this.metrics,
    this.maxItems,
  });

  final List<CatchMetricCardData> metrics;
  final int? maxItems;
  // build: verbatim old grid (LayoutBuilder, itemWidth = (maxWidth - s3)/2,
  // Wrap s3/s3); iterate maxItems == null ? metrics : metrics.take(maxItems!).
}

/// Labeled analytics section: kicker label + gap + child.
class CatchAnalyticsSection extends StatelessWidget {
  const CatchAnalyticsSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;
  // build: Column(crossAxisAlignment: stretch, [
  //   Text(label, style: CatchTextStyles.kicker(context, color: t.ink3)),
  //   gapH8, child])
  // NOTE: intentional standardization — user side moves labelL -> kicker.
}
```

2. Feature mappers (place next to the existing helpers in each file):
   - `lib/hosts/presentation/host_operations_screen.dart`:
     `CatchMetricCardData _hostMetricCardData(HostAnalyticsMetricCard m) =>
     CatchMetricCardData(icon: _metricIcon(m.id), value: _formatMetricValue(m),
     label: m.label, caption: m.caption, status: <switch on m.status>);`
   - `lib/user_analytics/shared/user_analytics_panel.dart`: same shape, but
     label/caption via the existing `UserAnalyticsCopy.metricLabel/metricCaption`
     indirection, and pass `partialBadgeLabel: UserAnalyticsCopy.partialBadge,
     missingBadgeLabel: UserAnalyticsCopy.missingBadge`. The old `_statusBadge`
     helper dies with the old tile.
3. Migrations (then delete the six old widgets; gotchas 1/2/5/6):
   - `HostAnalyticsMetricTile(metric: m)` → `CatchAnalyticsMetricTile(data: _hostMetricCardData(m))`
   - `UserAnalyticsMetricTile(metric: m)` → same pattern with the user mapper
   - `HostAnalyticsMetricGrid(metrics: xs)` → `CatchAnalyticsMetricGrid(metrics: [for (final m in xs) _hostMetricCardData(m)])`
   - `UserAnalyticsMetricGrid(metrics: xs)` → same + `maxItems: 6`
   - `HostAnalyticsSection` / `UserAnalyticsSection` → `CatchAnalyticsSection`
     (all call sites incl. the trend/data-quality panels, which otherwise stay)
   - `HostSectionLabel`: check remaining usages after migration; if analytics
     sections were its only consumers, delete it too, else leave.
4. Widgetbook: one kit use-case under primitives (tile ready/partial/missing,
   grid, section); repoint/delete old-typed blocks (gotcha 2).
5. regen + registries + receipts. Expected: widget count −5 (6 absorbed, 3 kit
   widgets added, minus HostSectionLabel if orphaned).

- [x] kit file + widgetbook
- [x] mappers + migrations + deletions
- [x] regen + registries + receipts

## WO-019 — Pill merge + privacy badge unification

1. **DarkPill → EventSuccessDarkPill** (ledger: absorb): move
   `EventSuccessDarkPill` from `event_success_feature_blocks.dart` to a
   shared event_success location if needed for the manual-QA import, replace
   `DarkPill(...)` call sites in
   `lib/event_success/presentation/event_success_manual_qa_screen.dart`
   (label pass-through; the reveal token treatment wins — intentional visual
   change on the QA screen), delete `DarkPill`. Then check
   `CatchOpacity.manualQaPillFill` / `manualQaPillBorder` for remaining
   usages; if orphaned, remove the tokens (token file + any token tests).
2. **PrivacyBadge → CatchPrivacyBadge** (ledger: absorb): extend
   `CatchPrivacyBadgeKind` (in `lib/core/widgets/catch_privacy_badge.dart`)
   with `privateToYou`, `hostCanSee`, `catchPrivate`; labels/icons verbatim
   from `PrivacyBadge` in
   `lib/event_success/presentation/companion_parts/event_success_companion_shared.dart`
   ('Private to you'/lockOutlineRounded, 'Host can see'/visibilityOutlined,
   'Catch private'/shieldOutlined). Replace `PrivacyBadge(audience)` call
   sites with `CatchPrivacyBadge(kind: ...)` (the private `_PrivacyAudience`
   enum dies with the widget). Companion moves from the CatchBadge treatment
   to the core mono-pill — intentional standardization.
3. **D1 fix**: `Icon(data.icon, size: 11, ...)` in catch_privacy_badge.dart →
   `size: CatchIcon.micro`.
4. Widgetbook: add the three new kinds to the CatchPrivacyBadge use-case;
   repoint/delete old-typed blocks (gotcha 2). regen + registries + receipts.

- [x] dark pill merge + token orphan check
- [x] privacy badge kinds + migration + micro-icon fix
- [x] widgetbook + regen + registries + receipts

## WO-020 — Escalation-queue resolutions (batch A/B/C)

1. **CatchIconAction rename + OverlayIconAction absorb**: rename
   `CatchTopBarIconAction` → `CatchIconAction`, moving it to its own
   `lib/core/widgets/catch_icon_action.dart` (it is used well beyond top bars
   since slice 1). Leave `@Deprecated('Use CatchIconAction') typedef
   CatchTopBarIconAction = CatchIconAction;` in catch_top_bar.dart for one
   release; migrate all call sites now anyway (rg -w, ~25 sites). Then absorb
   `OverlayIconAction` (`lib/swipes/presentation/swipe_screen.dart`):
   `OverlayIconAction(tooltip:, icon:, onPressed:)` →
   `CatchIconAction(icon:, tooltip:, onPressed:, size:
   CatchLayout.floatingControlExtent, backgroundColor:
   t.surface.withValues(alpha: CatchOpacity.floatingControlFill))`.
   Accepted standardization: overlay icon glyph size row → md; the extra
   Semantics(button:) wrapper drops (Tooltip provides the label).
2. **HostOrganizerSectionHeader → CatchSectionHeader** (delete class in
   host_operations_screen.dart): call sites become
   `CatchSectionHeader(title: label, padding: EdgeInsets.zero, titleStyle:
   CatchTextStyles.monoLabel(context, color: t.ink2), trailing: actionLabel
   != null ? CatchTextButton(label: actionLabel!, onPressed: onAction, tone:
   CatchTextButtonTone.neutral, minimumSize: const Size(0, CatchSpacing.s8))
   : null)` — expand per call site with its actual args.
3. **HostOrganizerMetricTile → CatchStatColumn** (delete class in
   host_operations_screen.dart): `CatchStatColumn(value: item.value, label:
   item.label)` — keep the surrounding horizontal padding at call sites;
   uppercase label standardizes away (intentional, same as RunningStat).
4. **HostPickerTile merge** (rule R1 cross-screen): move the shared body of
   `EditHostedEventPickerTile` (`edit_hosted_event_screen.dart`) and
   `WhenStepPickerTile` (`event_management/widgets/when_step.dart`) into
   `lib/hosts/presentation/widgets/host_picker_tile.dart` as
   `HostPickerTile({icon, value, placeholder, onTap})` (diff the two bodies
   first — take the union; they were verified identical through the Row
   opening). Delete both originals, repoint call sites + widgetbook.
5. **CatchShareCardFooter**: the share cards each hand-roll the brand footer
   `Row(['CATCH' kicker(t.ink), Spacer(), Text(trailing, labelS(color))])`
   (see chat_share_card.dart ~line 212 and club_share_card.dart ~line 109;
   check event_share_card.dart for its variant). New tiny primitive in
   `lib/core/widgets/catch_share_card_footer.dart`:
   `CatchShareCardFooter({required String trailing, Color? trailingColor})`
   rendering exactly that row; replace the three hand-rolled footers. If the
   event card's footer diverges structurally, escalate instead.
6. **Explore empty states** (conditional R2): `ExploreListEmptyState` and
   `ExploreScreenEmptyState` — if each is a thin wrapper over
   CatchEmptyState per rule R2's predicate, inline and delete; otherwise
   ledger keep-distinct with the body quoted. (Explore files are globally
   lint-exempt; still follow the standard verification suite.)
7. **D1 drift fixes**: `size: 18` → `CatchIcon.sm` (verify token value ==18,
   else nearest) in `StagePrivacyLine`
   (event_success_companion_shared.dart); `CatchPersonAvatar(size: 64 …)` in
   `HostOrganizerHeader` → nearest CatchLayout avatar token (list candidates
   first; escalate if none within 10%).
8. Widgetbook for all changed/new types (gotcha 2) + regen + registries +
   receipts.

- [x] CatchIconAction rename + overlay absorb
- [x] section header + metric tile absorbs
- [x] HostPickerTile merge
- [x] CatchShareCardFooter extraction
- [x] explore empty-state conditional review
- [x] drift fixes + widgetbook
- [x] regen + registries + receipts

Progress by Codex: moved `CatchTopBarIconAction` into
`CatchIconAction`, left the one-release deprecated typedef, migrated active
call sites, and absorbed `OverlayIconAction` into the shared action with
floating-control sizing. `HostOrganizerSectionHeader` now composes
`CatchSectionHeader`, `HostOrganizerMetricTile` composes `CatchStatColumn`, the
create/edit event picker rows share `HostPickerTile`, and chat/club/event share
cards share `CatchShareCardFooter`. `StagePrivacyLine` now uses
`CatchIcon.md`; the 64px host organizer avatar stayed raw because the only
exact 64px tokens are semantically unrelated chat/club tokens. The Explore
empty-state pair stayed distinct after review because one is provider-aware and
the other is route-state driven.

## WO-021 — Review-batch resolutions: analytics kit v2 close-out + deferred pairs

All ledger entries for this order are already written (2026-07-04 review):
items 1–6 below carry status `work-order WO-021`; flip each to
`executed-WO-021` as it lands. The rest of the deferred queue closed as
keep-distinct — no code work for those.

1. **CatchAnalyticsDataQualityList (kit v2)** in
   `lib/core/widgets/catch_analytics_kit.dart`:

```dart
/// Display-ready payload for one analytics data-quality row.
class CatchDataQualityRowData {
  const CatchDataQualityRowData({required this.status, required this.detail});

  final CatchMetricStatus status; // ready == ok
  final String detail;
}

/// Stacked per-row status surfaces for analytics data-quality rows.
class CatchAnalyticsDataQualityList extends StatelessWidget {
  const CatchAnalyticsDataQualityList({super.key, required this.rows});

  final List<CatchDataQualityRowData> rows;
  // build: verbatim HostAnalyticsDataQualityPanel row treatment, generalized
  // to three states — Column of rows with gapH8 between; each row =
  // CatchSurface(padding: CatchInsets.contentDense, borderColor: t.line,
  //   backgroundColor: ready ? t.surface
  //       : t.warning.withValues(alpha: CatchOpacity.warningFill),
  //   child: Row(crossAxisAlignment: start, [
  //     Icon(ready -> CatchIcons.checkCircleOutlineRounded, color: t.success;
  //          partial -> CatchIcons.warningAmberRounded, color: t.warning;
  //          missing -> CatchIcons.errorOutlineRounded, color: t.warning;
  //          size: CatchIcon.md),
  //     SizedBox(width: CatchSpacing.s3),
  //     Expanded(Text(detail, supporting(t.ink2)))]))
}
```

   Mappers next to the existing kit mappers: host
   `CatchDataQualityRowData _hostDataQualityRowData(HostAnalyticsDataQuality r)`
   — map enum cases by name (ok -> ready; partial -> partial if the case
   exists; everything else -> missing); user `_userDataQualityRowData`
   (ok/partial/missing map 1:1). Replace each panel's call site in the two
   report views with `CatchAnalyticsSection(label: <old section label>, child:
   CatchAnalyticsDataQualityList(rows: [for ... mapper(...)]))`, then delete
   `HostAnalyticsDataQualityPanel`, `UserAnalyticsDataQualityPanel`,
   `UserAnalyticsDataQualityRow`, and the user `_qualityIcon` helper.
   ACCEPTED VISUAL CHANGE (review-approved): the user side moves from one
   divided surface with sm neutral icons to per-row contentDense surfaces
   with md status-colored icons. Update the data-quality block of
   `UserAnalyticsReportSkeleton` to mirror the new shape (two contentDense
   surfaces, each icon box + text line, gapH8 between); check the host
   skeleton for a data-quality mimic and align it too if one exists.

2. **HostAnalyticsInlineStat → CatchStatColumn**: replace the 6 call sites in
   host_operations_screen.dart (`HostAnalyticsInlineStat(label: L, value: V)`
   → `CatchStatColumn(label: L, value: V)`), delete the class and its
   widgetbook block. Accepted standardization: value numericMeta →
   sectionTitle, label labelS → supporting (matches the user analytics side
   and WO-020's HostOrganizerMetricTile absorb).

3. **ExploreRailLabel → CatchOptionGroupItem** (decision c014): in
   catch_option_group.dart make `CatchOptionGroupItem.selectedRule` a
   `Color?` (build resolves `selectedRule ?? t.ink`) and give `variant` a
   default of `CatchOptionGroupVariant.label`; `CatchOptionGroup`'s own
   construction keeps passing both explicitly. Then in
   explore_filter_rail.dart replace the `ExploreRailLabel(...)` construction
   with `CatchOptionGroupItem<ExploreTimeFilter>(option: option, selected:
   option.value == filters.timeFilter, onTap: () =>
   onTimeFilterSelected?.call(option.value))`, delete the class, and repoint
   its widgetbook use-case (hand-edit, gotcha 2). Accepted: rail labels gain
   ellipsis overflow (visual noop at these lengths).

4. **SetupChoiceChips<T> merge** (decision c031) in
   event_success_setup_body.dart — one generic replaces both
   RotationCadenceChips and RevealCountdownChips (QuestionnaireBlock and
   ActivityAttributeGoalChips stay untouched):

```dart
/// Labeled single-select chip row for setup controls rendered beneath a
/// During-stage toggle (rotation cadence, reveal countdown).
class SetupChoiceChips<T> extends StatelessWidget {
  const SetupChoiceChips({
    required this.label,
    required this.options,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final List<CatchOption<T>> options; // reuse core catch_option_group.dart
  final T value;
  final bool enabled;
  final ValueChanged<T> onChanged;
  // build: verbatim twin body — Padding(_setupNestedControlPadding,
  //   Column(start, [Text(label, CatchTextStyles.labelM(context)), gapH6,
  //     Wrap(spacing/runSpacing s2, [for (final option in options)
  //       CatchSelectChip(label: option.label, active: value == option.value,
  //         enabled: enabled,
  //         onTap: enabled ? () => onChanged(option.value) : null)])]))
}
```

   Call sites: rotation → `SetupChoiceChips<int?>(label: 'Rotation cadence',
   options: const [CatchOption(value: null, label: 'No timed rotation'),
   CatchOption(value: 10, label: '10 min'), CatchOption(value: 15, label:
   '15 min'), CatchOption(value: 20, label: '20 min'), CatchOption(value: 30,
   label: '30 min')], value:, enabled:, onChanged:)`; reveal →
   `SetupChoiceChips<int>(label: <existing label arg>, options: const
   [CatchOption(value: 0, label: 'Off'), CatchOption(value: 5, label: '5s'),
   CatchOption(value: 10, label: '10s'), CatchOption(value: 15, label:
   '15s')], ...)`. Widgetbook: replace the two old use-cases with one
   SetupChoiceChips case.

5. **Footer inlines** (decision c051): inline
   `EditHostedEventFooter(state:, onSave:)` at its single call site as
   `CatchBottomDock(child: CatchButton(key: EditHostedEventKeys.saveButton,
   label: state.label, onPressed: state.isEnabled ? onSave : null, isLoading:
   state.isLoading, fullWidth: true, icon: Icon(CatchIcons.saveOutlined)))` —
   substituting the call site's actual expressions for `state`/`onSave` — and
   `HostClubEditFooter` likewise, keeping its `padding:
   CatchInsets.formActionDock`. Delete both classes + widgetbook blocks; the
   footer-state VM types stay.

6. **D1**: QuestionProgressRail (event_success_companion_questionnaire.dart)
   `minHeight: 8` → the CatchSpacing token whose value is exactly 8 (verify;
   expected s2); if none matches exactly, escalate per D1.

7. Widgetbook for all changed/new types (gotcha 2) + build_runner regen +
   registries + receipts; flip the WO-021 ledger entries to
   `executed-WO-021`.

- [x] CatchAnalyticsDataQualityList + panel deletions + skeleton alignment
- [x] HostAnalyticsInlineStat absorb
- [x] ExploreRailLabel absorb + core param loosening
- [x] SetupChoiceChips merge
- [x] footer inlines
- [x] D1 + widgetbook + regen + receipts

## WO-022 — Name-family batch 1: thin-wrapper inlines + avatar tokens + D1

From the 2026-07-04 name-family review (ledger entries `n001…n094`; the four
carrying `work-order WO-022` flip to `executed-WO-022` as they land; the rest
of the batch closed keep-distinct with no code work).

1. **Inline five EventPreview tab skeletons** (decision
   n001-event-skeleton-residual), all in
   `event_success_event_preview_loading_screen.dart`:
   `EventPreviewNotesSkeleton`, `EventPreviewSetupSkeleton`,
   `EventPreviewLiveSkeleton`, `EventPreviewCompanionSkeleton`,
   `EventPreviewReportSkeleton` are each a const
   `EventSuccessSkeletonSurface(titleWidth:, textLines:, trailingCount:)`
   wrapper. Replace each call site with the wrapped expression verbatim,
   delete the five classes (EventPreviewHeroSkeleton and the body/screen
   stay), repoint/delete widgetbook blocks (gotcha 2).

2. **Inline EventHeroSurface** (decision n021-event-surface): the core class
   in `event_ticket_surface.dart` only wraps `catchHeroSurface(tag:, child:)`
   from catch_transitions.dart. Replace its single construction
   (event_detail_hero_app_bar.dart, inside `EventDetailTicketHeroSurface`)
   with `catchHeroSurface(tag: tag, child: surface)`, delete the class +
   widgetbook block + now-unused imports.

3. **Inline HostEventRow** (decision n008-host-row): thin wrapper over
   `CatchField.nav(title: row.title, valueText: row.timeRangeLabel, icon:
   CatchIcons.calendarTodayOutlined, divider: row.divider, onTap: onTap)` in
   host_operations_screen.dart, ≤3 call sites. Inline the expression
   (substitute each call site's actual `row`/`onTap` expressions), delete the
   class + widgetbook block. `HostHomeEventRowData` stays.

4. **Inline two trivial empty states** (decision n010-empty-state-residual):
   - `HostSettingsClubsEmptyState` (host_account_screen.dart) → its single
     call site becomes `Text('No host clubs yet.', style:
     CatchTextStyles.supporting(context, color: t.ink2))` (resolve `t` from
     the call-site context; add a local `final t =` only if none is in
     scope).
   - `EmptyRoster` (event_recap_screen.dart) → single call site becomes the
     wrapped `CatchEmptyState(icon: CatchIcons.groupOffRounded, title: 'No
     attendees to tag', message: 'No other checked-in attendees are attached
     to this event yet.')`.
   Delete both classes + widgetbook blocks.

5. **Semantic avatar tokens** (decision n008-host-row; closes the WO-020
   64px escalation). In CatchLayout (next to the other avatar/extent tokens):
   - `avatarRowExtent` with the SAME value as `skeletonAvatarCompactExtent`
     (read the current value; define the skeleton token as
     `= avatarRowExtent` so they stay locked, keeping the skeleton name for
     skeleton call sites).
   - `avatarIdentityExtent = 64.0`.
   Repoint `HostOrganizerTeamRow`'s `CatchPersonAvatar(size:
   CatchLayout.skeletonAvatarCompactExtent …)` → `avatarRowExtent`, and
   `HostOrganizerHeader`'s raw `size: 64` → `avatarIdentityExtent`.

6. **D1 fixes**:
   - `HostEventToolCard` (host_event_tools.dart): `EventActionCard(radius:
     22 …)` → `CatchRadius.heroCard` (verified == 22.0).
   - `EventDetailMapCard` (event_detail_design_primitives.dart,
     `_MapGridPainter` args): `t.surface.withValues(alpha: 0.52)` and
     `activity.accent.withValues(alpha: 0.24)` → existing CatchOpacity
     tokens with exact values; if no exact token exists, escalate with
     proposed names (do not add tokens for these yourself).

7. Widgetbook (gotcha 2) + build_runner regen + registries + receipts; flip
   the four WO-022 ledger entries to `executed-WO-022`.

- [x] EventPreview skeleton inlines
- [x] EventHeroSurface inline
- [x] HostEventRow inline
- [x] empty-state inlines
- [x] avatar tokens + repoints
- [x] D1 + widgetbook + regen + receipts

## WO-023 — Name-family batch 2: pass-through absorbs + D1

From the 2026-07-04 name-family review batch 2 (ledger `n0xx` entries dated
2026-07-04; the three carrying `work-order WO-023` flip to `executed-WO-023`
as they land). This closes the name-family detector queue — all 222 families
are now decided.

1. **Absorb ClubHostAvatar into CatchPersonAvatar** (decision n129): the
   class in `lib/clubs/shared/club_identity_atoms.dart` is a 1:1 pass-through
   (name/imageUrl/borderWidth/borderColor) whose only addition is a raw
   `size = 32` default. Replace its ~4 call sites with
   `CatchPersonAvatar(...)` passing the same args; where a call site relied
   on the 32 default: if CatchPersonAvatar's own default size is 32, omit
   `size`; otherwise pass `size: 32` verbatim and check for an exact
   32-valued CatchLayout avatar token (none known — if none, keep the
   literal and escalate with a proposed name per D1). Delete the class +
   widgetbook block. HostAvatar (event detail) stays.

2. **Inline EventFocusPageIndicator** (decision n173): single call site in
   event_focus_rail.dart becomes `Center(child:
   CatchPageDots(selectedIndex: <expr>, itemCount: <expr>, semanticLabel:
   'Event ${<expr> + 1} of $<expr>'))` with the call site's actual
   expressions. Delete the class + widgetbook block.

3. **Inline ManualQaToggleRow** (decision n205): both call sites in
   event_success_manual_qa_screen.dart become `CatchField.toggle(title:,
   value:, onChanged:)` with the call sites' args. Delete the class (+ any
   widgetbook block).

4. **D1 fixes**:
   - `HostEventToolsPageIndicator` (host_event_tools.dart):
     `minHeight: 6` → the CatchSpacing token whose value is exactly 6
     (expected micro6; verify), else escalate.
   - `ForceUpdateCheckErrorScreen` (lib/app.dart): raw
     `maxWidth: 420` — no exact token exists (maxContentWidth is 600). Per
     D1, do NOT invent a token: leave the literal and record an escalation
     listing nearest candidates. Its `Theme.textTheme` usage is a deliberate
     pre-shell bootstrap constraint — leave it.

5. Widgetbook (gotcha 2) + build_runner regen + registries + receipts; flip
   the three WO-023 ledger entries to `executed-WO-023`.

- [x] ClubHostAvatar absorb
- [x] EventFocusPageIndicator inline
- [x] ManualQaToggleRow inline
- [x] D1 + widgetbook + regen + receipts

## Audit note (2026-07-03, claude): WO-015 sweep quality

Code-level audit of sampled sweep decisions: 3 of 4 sampled keeps verified
correct against source (dashboard loading cards, count pills, row skeletons —
K4 applied honestly). One systematic misapplication found and corrected:
**K2 was applied to the Host/User analytics kit** (MetricTile, TrendPanel,
MetricGrid, DataQualityPanel, EventTile, and ReportView pairs), whose bodies are
near-identical presentation over parallel view-model types. Those six ledger
entries are re-opened as `escalated-analytics-kit`; the rulebook
gained a K2 discriminator (v0.2.0). The **analytics-kit unification is a
review-session item** (needs a shared presentation-model API design) — Codex
must not attempt it.

## Escalations

> Review answers (2026-07-03): the WO-002 token escalation and the WO-006
> divider-skeleton skip are resolved by WO-016 below. The `c044-row` K5
> escalation is decided keep-distinct (ledgered). Screen-scope escalations
> below are acknowledged and queued for the next review batch — no further
> action from Codex.
>
> Review answers (2026-07-04): the deferred-next-review-batch queue and the
> analytics-kit-v2 deferral are fully resolved; outcomes live in the ledger.
> Keep-distinct closures: c010 choice-entry editors, c015+c017,
> ProfileMulti/SingleEnumEntry, HostActivitySummary/HostFunnelSummary,
> PaperProgressRail/QuestionProgressRail, and the
> Host/UserAnalyticsReportView pair (analytics kit v2 closes with no shared
> report view). Code work queued as WO-021: CatchAnalyticsDataQualityList,
> HostAnalyticsInlineStat absorb, ExploreRailLabel absorb (c014),
> SetupChoiceChips merge (c031), footer inlines (c051), one D1 fix. The
> escalation queue is now empty.

- WO-002: resolved by WO-016 — `CatchScrim.photoFrame` now uses
  `CatchOpacity.photoFrameEdge`; `CatchOpacity.eventSuccessSubtleBorder` remains
  only for Event Success usages.
- WO-015: `c011-event-success-report-metrics-skeleton` members
  `EventSuccessReportMetricsSkeleton`, `EventSuccessSetupControlsSkeleton`,
  `PaymentConfirmationLoadingScreen`, `ReviewHistoryItemSkeleton` — nearest
  rule: screen-scope limit, blocked because screen clusters embed route/provider
  or whole-state composition and require review.
- WO-015: `c016-loading-screen` members
  `EventSuccessEventPreviewLoadingScreen`, `HostLoadingScreen` — nearest rule:
  screen-scope limit, blocked because screen clusters embed route/provider or
  whole-state composition and require review.
- WO-015: `c039-filters-section` members `FiltersSection`,
  `ReadOnlyHostedEventScheduleCard` — nearest rule: screen-scope limit, blocked
  because screen clusters embed route/provider or whole-state composition and
  require review.
- WO-015: `c043-calendar-stats-header` members `CalendarStatsHeader`,
  `CalendarStatsHeaderSkeleton` — nearest rule: screen-scope limit, blocked
  because screen clusters embed route/provider or whole-state composition and
  require review.
- WO-015: `c048-companion-primary-action-skeleton` members
  `CompanionPrimaryActionSkeleton`, `CompanionStageSkeleton`,
  `DashboardFocusLoadingCard` — nearest rule: screen-scope limit, blocked
  because screen clusters embed route/provider or whole-state composition and
  require review.
- WO-015: `c049-sliver-body` members `PreviewTabSkeletonSliverBody`,
  `PreviewTabSliverBody` — nearest rule: screen-scope limit, blocked because
  screen clusters embed route/provider or whole-state composition and require
  review.
- WO-015: `c051-footer` members `EditHostedEventFooter`,
  `HostClubEditFooter` — nearest rule: screen-scope limit, blocked because
  screen clusters embed route/provider or whole-state composition and require
  review.
- WO-015: `c044-row` members `ActivityTypeRow`, `MoreActivityTypesRow` —
  nearest rule: K5 concept mismatch, blocked because the two rows share an
  outer tap-row shell but differ in selected filter semantics, title/count
  treatment, overflow-expander semantics, kicker typography, and arrow
  affordance.
- WO-015: `c010-choice-entry-editor` members
  `ProfileInlineMultiChoiceEntryEditor`, `ProfileInlineSingleChoiceEntryEditor`
  — nearest rule: no exact K/R match, blocked because single-choice owns
  nullable selected state and empty-selection behavior while multi-choice owns
  `Set<T>` state, optional removal rules, and latest-profile patching.
- WO-015: `c012-pill` members `EventSharePill`, `EventSuccessDarkPill` —
  nearest rule: K5 concept mismatch, blocked because the former is a light
  share-card metadata pill and the latter is a dark editorial overlay pill with
  different token roles and typography.
- WO-015: `c014-catch-option-group-item` members `CatchOptionGroupItem`,
  `ExploreRailLabel` — nearest rule: no exact K/R match, blocked because
  absorbing the rail label needs a core option-item API/design decision around
  selected rule color, variant handling, option typing, and whether explore
  filter rails are option groups.
- WO-015: `c018-icon` members `CatchErrorIcon`, `PaperCelebrationIcon` —
  nearest rule: K5 concept mismatch, blocked because the former is the core
  danger/error medallion while the latter is celebration-specific primary art
  direction with fixed sizing.
- WO-015: `c030-catch-framework-error-debug-details` members
  `CatchFrameworkErrorDebugDetails`, `SetupDisclosureSection` — nearest rule:
  K5 concept mismatch, blocked because developer-error debug disclosure and
  Event Success setup disclosure have different content contracts and token
  roles.
- WO-015: `c035-reveal-host-copy` members `RevealHostCopy`,
  `StructureNumberField` — nearest rule: no exact K/R match, blocked because
  reveal host copy is dark live-reveal content while `StructureNumberField` is
  a setup form-field label/detail/child wrapper already kept distinct from
  stat/header concepts.
- WO-015: `c002-afterglow-beat-row` members `AfterglowBeatRow`,
  `CountdownCuePill`, `EmptyRosterMessage`, `EventSuccessPromptCard`,
  `EventSuccessRecommendationTile`, `HostFunnelSummary`,
  `HostReportSignalGrid`, `LiveAttendanceSummaryCard`, `LiveCheckInQrCard`,
  `NoticeCard`, `UserAnalyticsDataQualityRow`, `UserAnalyticsEmptyState`,
  `UserAnalyticsTipRow`, `WaitingRevealCue` — nearest rule: K5 concept
  mismatch, blocked because the shared icon/text/surface skeleton spans
  companion beats, live host cards, setup notices, and user analytics rows with
  different typography, token roles, and data contracts.
- WO-015: `c007-attendee-prompt-preview` members `AttendeePromptPreview`,
  `DashboardSectionStateCard`, `FoundationLine`, `PaperExpectationRow`,
  `PaperPrivacyCard`, `PreviewLine`, `ProfileCompatibility`, `ProfileFacts`,
  `SafetyFooter`, `StagePrivacyLine`, `SwipeWindowBanner` — nearest rule: K5
  concept mismatch, blocked because these rows and cards carry setup,
  dashboard, paper-companion, profile, safety, and swipe-window semantics with
  different label/body/kicker and surface roles.
- WO-015: `c008-stage-action-dock` members `StageActionDock`, `StagePanel`,
  `StageSoftBand` — nearest rule: K5 concept mismatch, blocked because the
  child-surface shells represent the dark action dock, animated ambient stage
  panel, and soft nested band with different token roles.
- WO-015: `c031-activity-attribute-goal-chips` members
  `ActivityAttributeGoalChips`, `QuestionnaireBlock`, `RevealCountdownChips`,
  `RotationCadenceChips` — nearest rule: no exact K/R match, blocked because
  the shared chip-wrap shape hides different multi-select, questionnaire,
  reveal countdown, and rotation-cadence APIs that need feature-level design.
- WO-015 ranked-pair: `EditHostedEventPickerTile`, `WhenStepPickerTile` —
  resolved by WO-020 as `HostPickerTile`; the shared contract standardizes
  empty strings to the placeholder state.
- WO-015 ranked-pair: `DarkPill`, `EventSuccessDarkPill` — resolved by
  WO-019; manual-QA dark pills now reuse `EventSuccessDarkPill`.
- WO-015 ranked-pair: `CatchMetaRow`, `EventPolicyLabSectionTitle` — nearest
  rule: K5 concept mismatch, blocked because metadata rows and policy-lab
  section-title rows use different typography, trailing affordance, and icon
  sizing contracts.
- WO-015 ranked-pair: `CatchTopBarIconAction`, `OverlayIconAction` —
  resolved by WO-020 as `CatchIconAction`; the old top-bar name remains only as
  a deprecated typedef.
- WO-015 ranked-pair: `EventDetailBody`, `EventDetailOptimisticBody` —
  nearest rule: no exact K/R match, blocked because merging the optimistic
  fallback into the loaded detail body requires an event-detail state/action API
  decision.
- WO-015 ranked-pair: `CatchSectionLabel`, `StageSectionLabel` — nearest rule:
  K5 concept mismatch, blocked because the core kicker/header label and Event
  Success live-stage label use different typography, required color, and
  wrapping contracts.
- WO-015 ranked-pair: `CatchPersonAvatar`, `CatchVeiledPersonAvatar` —
  nearest rule: no exact K/R match, blocked because absorbing veiled activity
  placeholders into the core avatar requires a reviewed avatar API decision.
- WO-015 ranked-pair: `CatchSectionHeader`, `HostOrganizerSectionHeader` —
  resolved by WO-020; host organizer rows now compose `CatchSectionHeader` with
  mono title styling and optional `CatchTextButton` trailing action.
- WO-015 ranked-pair: `EventDetailPolicySummary`, `EventPolicySummary` —
  nearest rule: K5 concept mismatch, blocked because attendee-facing event
  policy copy and policy-lab scenario/debug policy rows are different surfaces.
- WO-015 ranked-pair: `CatchEmptyStateContent`, `EmptyHeroContent` — nearest
  rule: K5 concept mismatch, blocked because the core empty-state layout body
  and dashboard editorial hero CTA are different concepts.
- WO-015 ranked-pair: `CatchPersonAvatarStack`, `HostTodayAvatarStack` —
  nearest rule: K5 concept mismatch, blocked because real person-avatar stacks
  and fixed host activity-dot previews are different concepts.
- WO-015 ranked-pair: `CatchTopBarTabBar`, `ProfileTabBar` — nearest rule: K5
  concept mismatch, blocked because the top-bar Material tab wrapper and
  profile-specific segmented option rail have different behavior contracts.
- WO-015 ranked-pair: `EventAgendaSliverList`, `EventDetailHintList` —
  nearest rule: K5 concept mismatch, blocked because grouped sliver agendas and
  event-detail hint hairline lists have different layout/data contracts.
- WO-015 ranked-pair: `CatchScreenBody`, `PublicProfileScreenBody` — nearest
  rule: no exact K/R match, blocked because a generic padding/scroll shell and
  public-profile route-state dispatcher are not the same abstraction.
- WO-015 ranked-pair: `CatchPrivacyBadge`, `PrivacyBadge` — resolved by
  WO-019; the core badge owns the Event Success privacy vocabulary.
- WO-015 ranked-pair: `CatchFieldRow`, `ProfileFieldRow` — nearest rule: no
  exact K/R match, blocked because the core row layout primitive and profile
  descriptor/editor dispatcher live at different abstraction levels.
- WO-015 ranked-pair: `DarkPill`, `EventSharePill` — nearest rule: K5 concept
  mismatch, blocked because manual-QA dark accent pills and light event
  share-card metadata pills use different surface and typography roles.
- WO-015 ranked-pair: `FiltersSection`, `StageCard` — nearest rule: K5 concept
  mismatch, blocked because filter/editing section surfaces and Event Success
  stage cards have different user tasks and data contracts.
- WO-015 ranked-pair: `HostAnalyticsInlineStat`, `StructureNumberField` —
  nearest rule: K5 concept mismatch, blocked because compact analytics stats
  and setup form-field label/detail/child wrappers are different concepts.
- WO-015 ranked-pair: `EventPolicyLabSectionTitle`, `StageSectionLabel` —
  nearest rule: K5 concept mismatch, blocked because policy-lab section headers
  and Event Success live-stage labels have different trailing, color, and
  wrapping contracts.
- WO-015 ranked-pair: `EventPolicyLabSectionTitle`, `PreviewLine` — nearest
  rule: K5 concept mismatch, blocked because policy-lab section headers and
  Event Success preview/detail copy lines are different concepts.
- WO-015 ranked-pair: `EventPolicyLabScreen`,
  `EventSuccessEventPreviewLoadingScreen` — nearest rule: no exact K/R match,
  blocked because these are separate screen-level compositions.
- WO-015 ranked-pair: `HostEventManageRouteScreen`, `HostLoadingScreen` —
  nearest rule: no exact K/R match, blocked because route/provider screens and
  generic host loading states are not the same abstraction.
- WO-015 ranked-pair: `EventSuccessEventPreviewLoadingScreen`,
  `EventSuccessEventPreviewScreen` — nearest rule: no exact K/R match, blocked
  because loading and loaded preview screens need an Event Success screen-state
  contract before any merge.
- WO-015 ranked-pair: `EventSuccessEventPreviewLoadingScreen`,
  `EventSuccessManualQaScreen` — nearest rule: no exact K/R match, blocked
  because preview loading and manual-QA screens have different data/workflow
  ownership.
- WO-015 ranked-pair: `EditHostedEventRouteScreen`,
  `HostEventManageRouteScreen` — nearest rule: no exact K/R match, blocked
  because host route-level screens are architecture decisions, not widget-shape
  merges.
- WO-015 ranked-pair: `ExploreListEmptyState`, `ExploreScreenEmptyState` —
  resolved by WO-020 as keep-distinct; the list variant owns provider-backed
  clear actions while the screen variant consumes route-level empty state and
  callbacks.
- WO-015 ranked-pair: `ProfileMultiEnumEntry`, `ProfileSingleEnumEntry` —
  nearest rule: no exact K/R match, blocked because single-choice and
  multi-choice profile enum entries have different selection, empty-affordance,
  and patching contracts.
- WO-015 ranked-pair: `HostActivitySummary`, `HostFunnelSummary` — nearest
  rule: K5 concept mismatch, blocked because setup activity summaries and
  post-event funnel summaries carry different Event Success concepts.
- WO-015 ranked-pair: `HostClubsScaffold`, `HostEventsScaffold` — nearest
  rule: no exact K/R match, blocked because these host screen scaffolds own
  separate stateful tab/selection flows and need host operations architecture
  review.
- WO-015 ranked-pair: `CelebrationIcon`, `PaperCelebrationIcon` — nearest
  rule: K5 concept mismatch, blocked because immersive and paper celebration
  medallions use different color, extent, and icon treatments.
- WO-015 ranked-pair: `EventRecapLoadingBody`,
  `EventSuccessCompanionLoadingBody` — nearest rule: no exact K/R match,
  blocked because these are screen-level loading bodies with different route
  ownership.
- WO-015 ranked-pair: `ClubShareCard`, `EventShareCard` — resolved by WO-020
  for the shared footer only; card bodies stay distinct because art systems,
  metadata, and CTA contracts differ.
- WO-015 ranked-pair: `HostClubEditorStateView`,
  `HostCreateEventRouteStateView` — nearest rule: no exact K/R match, blocked
  because host route/editor state dispatchers are architecture decisions.
- WO-015 ranked-pair: `HostCapacityTile`, `HostOrganizerMetricTile` —
  resolved by WO-020 for the organizer metric cell only:
  `HostOrganizerMetricTile` now composes `CatchStatColumn`; `HostCapacityTile`
  remains distinct.
- WO-015 ranked-pair: `PaperCelebrationDetailRow`, `PaperExpectationRow` —
  nearest rule: K5 concept mismatch, blocked because paper celebration
  label/value facts and companion expectation rows are different row concepts.
- WO-015 ranked-pair: `EventActionCardHeader`, `EventPolicyLabHeader` —
  nearest rule: K5 concept mismatch, blocked because compact action-card badge
  chrome and policy-lab screen hero headers are different concepts.
- WO-015 ranked-pair: `StageCueLine`, `StagePrivacyLine` — resolved by WO-020
  as keep-distinct; the token drift on `StagePrivacyLine` was fixed to
  `CatchIcon.md`.
- WO-015 ranked-pair: `HostActionRow`, `HostEventSummaryRow` — nearest rule:
  K5 concept mismatch, blocked because host management action rows and
  icon-led event summary facts are different row concepts.
- WO-015 ranked-pair: `CountdownBeatPill`, `CountdownCuePill` — nearest rule:
  K5 concept mismatch, blocked because reveal-progress beat pills and cue
  instruction cards carry different typography and state semantics.
- WO-015 ranked-pair: `EventActionCard`, `HostEmptyActionCard` — nearest
  rule: K5 concept mismatch, blocked because event action cards model badges,
  meta rows, gradients, and actions while host empty action cards are simple
  empty-state CTA surfaces.
- WO-015 ranked-pair: `DashboardHeaderContent`, `ExploreBrowseHeaderContent`
  — nearest rule: K5 concept mismatch, blocked because dashboard title chrome
  and explore browse/search/city-picker chrome are different app-header
  concepts.
- WO-015 ranked-pair: `CompanionPaperScaffold`, `CompanionStageScaffold` —
  nearest rule: K5 concept mismatch, blocked because paper and cinematic stage
  companion scaffolds own different background, animation, navigation, and
  self-check-in contracts.
- WO-015 ranked-pair: `EditHostedEventRouteScreen`,
  `EditHostedEventScreen` — nearest rule: no exact K/R match, blocked because
  the route screen owns providers, async route states, and error/loading
  scaffolds while the edit screen owns form state.
- WO-015 ranked-pair: `ProfileHeightStepperControls`,
  `ProfileReactionControls` — nearest rule: K5 concept mismatch, blocked
  because numeric height steppers and profile reaction controls are different
  interaction concepts.
- WO-015 ranked-pair: `HostTodayClubPill`, `HostTodayCountdownPill` —
  nearest rule: K5 concept mismatch, blocked because host today club identity
  pills and countdown urgency pills have different token roles, copy, and
  status semantics.
- WO-015 ranked-pair: `ClubDirectorySkeletonCard`, `ClubShareCard` — nearest
  rule: K5 concept mismatch, blocked because directory loading skeleton cards
  and rich club share cards are different surfaces.
- WO-015 ranked-pair: `EventDetailTicketSurface`,
  `EventSuccessSkeletonSurface` — nearest rule: K5 concept mismatch, blocked
  because live ticket chrome and Event Success loading placeholders are
  different concepts.
- WO-015 ranked-pair: `HostOrganizerHeader`, `HostTodayHeader` — resolved by
  WO-020 as keep-distinct. The 64px organizer avatar remains raw pending a
  semantic host-organizer avatar token because existing exact 64px tokens are
  chat/club-specific.
- WO-015 ranked-pair: `PaperProgressRail`, `QuestionProgressRail` — nearest
  rule: K5 concept mismatch, blocked because passive companion-step rails and
  interactive questionnaire rails have different behavior contracts.
- WO-015 ranked-pair: `ExploreBrowseHeaderContent`, `ExplorePeekRailContent`
  — nearest rule: K5 concept mismatch, blocked because browse search/city
  chrome and peek-rail preview navigation are different concepts.
- WO-015 ranked-pair: `EventPolicyLabScreen`, `EventSuccessLabScreen` —
  nearest rule: no exact K/R match, blocked because these are separate
  screen-level lab compositions.
- WO-015 ranked-pair: `HostClubInsightsPane`, `HostClubPreviewPane` —
  nearest rule: no exact K/R match, blocked because these are screen-pane
  compositions with different providers, state, and host operations tasks.
- WO-015 ranked-pair: `PresetReviewCard`, `ReviewCard` — nearest rule: K5
  concept mismatch, blocked because Event Success preset review cards and user
  review cards carry different data, actions, and review semantics.
- WO-015 ranked-pair: `PaymentHistoryScreen`, `ReviewsHistoryScreen` —
  nearest rule: no exact K/R match, blocked because payment history and review
  history are separate screen-level flows.
- WO-015 ranked-pair: `CreateClubScreen`, `CreateEventScreen` — nearest rule:
  no exact K/R match, blocked because create-club and create-event screens are
  separate route-level workflows with different models and persistence
  contracts.
- WO-015 ranked-pair: `PaymentConfirmationScreen`, `PaymentHistoryScreen` —
  nearest rule: no exact K/R match, blocked because confirmation and history
  are different payment routes with different async state and user tasks.
- WO-015 ranked-pair: `HostActionRow`, `SuvbotResetActionRow` — nearest rule:
  K5 concept mismatch, blocked because host management action rows and Suvbot
  reset actions are different command surfaces.
- WO-015 ranked-pair: `PaperExpectationCard`, `PaperPrivacyCard` — nearest
  rule: K5 concept mismatch, blocked because companion expectation cards and
  privacy cards carry different paper-mode concepts.
- WO-015 ranked-pair: `ClubDetailScreen`, `EventDetailScreen` — nearest rule:
  no exact K/R match, blocked because club detail and event detail are
  route-level screens with different providers and state machines.
- WO-015 ranked-pair: `ExploreCityPickerSheet`, `ExploreFilterSheet` —
  nearest rule: no exact K/R match, blocked because city and filter sheets
  share modal chrome but own different option models and callbacks.
- WO-015 ranked-pair: `AttendeeQaControls`, `ManualQaControls` — nearest
  rule: K5 concept mismatch, blocked because attendee QA toggles and manual
  fixture scenario controls are different QA concepts.
- WO-015 ranked-pair: `EventActionCardHeader`, `ShareCardHeader` — nearest
  rule: K5 concept mismatch, blocked because event action card headers and
  share card headers use different badge, title, and sharing-context
  contracts.
- WO-015 ranked-pair: `CreateEventScreen`, `EditHostedEventScreen` — nearest
  rule: no exact K/R match, blocked because create and edit event screens are
  route-level form workflows with different initialization and persistence
  paths.
- WO-015 ranked-pair: `DraftPickerSheet`, `ExploreCityPickerSheet` —
  nearest rule: no exact K/R match, blocked because draft and city picker
  sheets share bottom-sheet chrome but own different option data, destructive
  actions, and completion behavior.
- WO-015 ranked-pair: `HostProfileScreen`, `PublicProfileScreen` — nearest
  rule: no exact K/R match, blocked because host and public profile screens
  are route-level flows with different providers and editing affordances.
- WO-015 ranked-pair: `EventPolicyScenarioPicker`, `EventSuccessTabPicker` —
  nearest rule: K5 concept mismatch, blocked because policy scenario pickers
  and Event Success tab pickers have different option domains and surrounding
  chrome.
- WO-015 ranked-pair: `CalendarDateHeader`, `CalendarStatsHeader` — nearest
  rule: K5 concept mismatch, blocked because calendar date selectors and
  calendar stats headers have different interaction, data, and typography
  contracts.
- WO-015 ranked-pair: `EventLocationMapScreen`, `ExploreMapScreen` — nearest
  rule: no exact K/R match, blocked because event location maps and explore
  maps are route-level map screens with different data sources and markers.

## Completed

(move finished orders here with their receipts line)
