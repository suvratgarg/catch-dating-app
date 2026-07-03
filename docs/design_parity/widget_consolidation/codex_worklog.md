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

## WO-008 — Inline four more empty-state wrappers + pattern recon

Same policy as WO-003 (thin `CatchEmptyState` wrappers; inline at call sites,
delete class, widgetbook per gotcha 2, imports per gotcha 1):

- [ ] `PaymentHistoryEmptyState` (`lib/payments/presentation/payment_history_screen.dart`)
  and `ReviewsHistoryEmptyState` (`lib/reviews/presentation/reviews_history_screen.dart`)
  — both are `CatchScreenBody(scrollable: false, child: Center(child:
  CatchEmptyState(…)))`; inline with each call site's actual icon/title/message
  arguments.
- [ ] `CalendarMessage` (`lib/events/presentation/calendar/calendar_screen.dart`)
  and `SavedEventsMessage` (`lib/events/presentation/saved_events_screen.dart`)
  — inline, and use CalendarMessage's override set for BOTH surfaces:
  `iconSize: CatchLayout.calendarEmptyIconSize, padding:
  CatchInsets.contentSpacious, titleStyle: CatchTextStyles.titleL(context),
  messageStyle: CatchTextStyles.proseM(context, color: t.ink2)` (keep each
  site's own icon: calendar → `calendarMonthOutlined`, saved →
  `bookmarkBorderRounded`). This intentionally replaces SavedEventsMessage's
  `eventInfoTileExtent` icon size (token misuse) — accepted visual change.
- [ ] **Recon (report only, no code)**: count occurrences of the pattern
  `CatchScreenBody(… Center(child: CatchEmptyState(…)))` and of `Center(child:
  CatchEmptyState(…))` inside `lib/` after the inlines land. Post both counts
  under Escalations — if ≥4 screen-body cases, the next review batch designs a
  `CatchEmptyState` screen variant.
- [ ] regen + registries + receipts

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

- [ ] CatchCountBadge + migrations
- [ ] tab dock delegation
- [ ] recon report (count-pill triplication)
- [ ] PhotoSlotMainBadge -> CatchBadge; MapPill token fix
- [ ] regen + registries + receipts

## WO-010 — CatchConfirmDialog shell delegation

In `lib/core/widgets/catch_adaptive_dialog.dart`: `CatchFormDialog` renders
the overlay shell (Dialog + CatchSurface overlay elevation + title + stacked
actions row). Inspect `CatchConfirmDialog` (same file): if it duplicates that
shell, rewrite its build to delegate — `return CatchFormDialog(title: …,
child: <its message/content>, actions: <its actions>);` — keeping
CatchConfirmDialog's public API unchanged. If the shells differ structurally
(e.g. different insets, width, or action layout that is load-bearing), do NOT
force it: record the diff under Escalations. Both classes stay public.

- [ ] inspect + delegate (or escalate) + regen + receipts

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

- [ ] token + primitive + migrations + widgetbook + regen + receipts

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

- [ ] widget + 3 migrations + widgetbook + regen + receipts

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

- [ ] token sweep + regen + receipts

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

- [ ] DirectoryClubCard merge
- [ ] PaperTicketSerial delegation
- [ ] EventSuccessHeroSurface + three delegations
- [ ] regen + registries + receipts

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

- [ ] sweep + ledger entries + escalations
- [ ] rule-authorized executions in batches
- [ ] receipts with per-rule counts

---

## Escalations

- WO-002: `CatchScrim.photoFrame` keeps using
  `CatchOpacity.eventSuccessSubtleBorder` for its bottom-edge alpha to stay
  pixel-faithful, but the token name is event-success-specific and should be
  renamed or aliased by the owner in a token pass.

## Completed

(move finished orders here with their receipts line)
