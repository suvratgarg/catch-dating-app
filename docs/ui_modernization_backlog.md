# UI modernization backlog

Living list of screens, widgets, and primitives that need the modernization
treatment that landed in the Explore (clubs list) screen refresh
(2026-05-26). Each item is sized as a follow-up that uses the new primitives
in [`lib/core/widgets/`](../lib/core/widgets/) and the updated tokens in
[`lib/core/theme/`](../lib/core/theme/).

Add to this list when you discover a candidate; tick items as PRs land.
Keep entries small and self-describing — one line is fine.

## Newly added primitives to adopt across the app

- `CatchCornerSash` — top-corner status mark on cards (replaces `EventTileStatusBadge` pill in hero card positions). See [catch_corner_sash.dart](../lib/core/widgets/catch_corner_sash.dart).
- `CatchMetaRow` / `CatchMetaDotRow` — bullet-separated icon + text inline meta row. See [catch_meta_row.dart](../lib/core/widgets/catch_meta_row.dart).
- `CatchKicker` — caps-tracked brand-orange time-line (e.g. `TONIGHT · 8:50 PM`). See [catch_kicker.dart](../lib/core/widgets/catch_kicker.dart).
- `CatchDaySectionHeader` — sticky day-grouped section header with right-aligned count. See [catch_day_section_header.dart](../lib/core/widgets/catch_day_section_header.dart).
- `CatchEventCardHero` — full-bleed photo + scrim + caps time + meta row. See [catch_event_card_hero.dart](../lib/core/widgets/catch_event_card_hero.dart).
- `CatchEventCardCompact` — list-row variant for day-grouped feeds. See [catch_event_card_compact.dart](../lib/core/widgets/catch_event_card_compact.dart).
- `CatchEventCardPeek` — image-left thumb card for the map peek rail. See [catch_event_card_peek.dart](../lib/core/widgets/catch_event_card_peek.dart).
- `CatchEventThumbnail` — shared photo+gradient fallback for any event surface. See [catch_event_thumbnail.dart](../lib/core/widgets/catch_event_thumbnail.dart).
- `CatchTextStyles.kickerCaps` — caps-tracked label style.
- `CatchTextStyles.numericLarge` — tabular numerals for counts/distances on cards.

## Screens to migrate to the new event card primitives

- [ ] **Dashboard / Home** ([lib/dashboard/presentation/](../lib/dashboard/presentation/)) — `EventFocusRail`, `RecommendCard`, hero card. Move to `CatchEventCardHero` for hero, `CatchEventCardCompact` for rail items.
- [ ] **Saved events** ([lib/events/presentation/saved_events_screen.dart](../lib/events/presentation/saved_events_screen.dart)) — rebuild with day-grouped feed using `CatchDaySectionHeader` + `CatchEventCardCompact`.
- [ ] **Club detail upcoming events** ([lib/clubs/presentation/detail/](../lib/clubs/presentation/detail/)) — replace `EventAgendaTile` usage with `CatchEventCardCompact`.
- [ ] **Event detail** ([lib/events/presentation/event_detail_screen.dart](../lib/events/presentation/event_detail_screen.dart)) — hero treatment should adopt the new scrim + caps-time pattern from `CatchEventCardHero`.
- [ ] **Club discover list** ([lib/clubs/presentation/list/widgets/club_discover_list.dart](../lib/clubs/presentation/list/widgets/club_discover_list.dart)) — the directory club tile is now the weakest visual on the screen; needs a peer redesign (photo + tag chips refined, drop the "NEXT" sash now that events are first-class above).
- [ ] **Event success / wingman screens** ([lib/event_success/presentation/](../lib/event_success/presentation/)) — currently use ad-hoc layouts; adopt `CatchDaySectionHeader` and the corner sash pattern.

## Tile/atom retirements

- [ ] Retire **`EventTileStatusBadge`** as a chip in card body positions — replace with `CatchCornerSash`. The pill is fine in dense list rows but reads as clutter on hero cards.
- [ ] Retire **`EventTileFactWrap`** — the wrap of Distance/Pace/Price as separate badges fights modern card hierarchy. Replace with a single `CatchMetaDotRow`.
- [ ] Audit all `Wrap(spacing: CatchSpacing.s1, runSpacing: ..., children: [CatchBadge(...), ...])` uses — many should become `CatchMetaDotRow`.
- [ ] **`CatchBadgeTone.live`** — the orange "LIVE" pill is overloaded language (suggests streaming/video). Audit every use site; "Event today" with `CatchStatusDot(success)` is usually right. Sites: [club_list_tile_parts/avatar_chip.dart](../lib/clubs/presentation/list/widgets/club_list_tile_parts/avatar_chip.dart), [event_tile_atoms.dart](../lib/events/presentation/widgets/event_tiles/event_tile_atoms.dart) (`hosted` status).

## Icon set

- [x] **`CatchIcons` facade landed** — [lib/core/theme/catch_icons.dart](../lib/core/theme/catch_icons.dart) wraps `phosphor_flutter`. The Explore screen, browse header, filter rail, event cards, and peek rail all reference `CatchIcons.*` instead of `Icons.*`. The facade keeps screens decoupled from the underlying package, so a future swap (e.g. to Lucide or to a custom brand set) is a one-file change.
- [ ] **Migrate the rest of the app** off `Icons.*` to `CatchIcons.*`. Scope: every `lib/**/*.dart` outside the Explore feature. Strategy:
  - Run `grep -rn 'Icons\.' lib --include='*.dart'` to find candidates.
  - For icons that don't yet have a `CatchIcons` entry, add a new constant in the facade rather than reaching into `phosphor_flutter` directly.
  - Test files that locate widgets via `find.byIcon(Icons.foo)` need the same migration.
- [ ] **Audit Phosphor weights**. The facade currently mixes Duotone (time pills, activity glyphs), Regular (filters, search), Bold (navigation chrome), and Fill (selected/active states). That distinction is intentional — duotone reads as expressive moments, regular as functional controls, bold for navigation, fill for active/saved — but the rest of the app should follow the same convention. Document it in the facade if a code reviewer ever questions a particular weight choice.

## Map

- [ ] **Map pin clustering** — `EventPinsMap` does not cluster. Add `google_maps_cluster_manager` or render clusters server-side when density >5 pins/visible viewport.
- [ ] **Distance ring** around user GPS pin on the map (visual aid + filter affordance).
- [ ] **User-location pin styling** — currently the default Google blue dot. Could be styled to match brand.
- [ ] **Re-order PEEK rail by distance** as the user pans/zooms the map (the rail is currently chronologically sorted; it should re-sort to be distance-from-camera-center on idle).
- [ ] **Distance ring filter affordance** — tap the ring to cycle through 1/3/5/10 km.

## Sheet & motion

- [ ] **Sticky day-section headers** — currently inlined (non-pinned) because `SliverPersistentHeader(pinned: true)` nested inside a `SliverMainAxisGroup` hits a Flutter layout assertion when the header is partially clipped (upstream [flutter#146867](https://github.com/flutter/flutter/issues/146867)). When the bug is fixed (or we restructure to avoid `SliverMainAxisGroup` here), swap `SliverToBoxAdapter(child: CatchDaySectionHeader(...))` back to `SliverPersistentHeader(pinned: true, delegate: CatchDaySectionHeaderDelegate(...))` in [explore_events_section.dart](../lib/clubs/presentation/list/widgets/explore_events_section.dart).
- [x] **Spring-curve sheet snap** — `_snapTo` uses `CatchMotion.springCurve`. ([clubs_list_screen.dart:189](../lib/clubs/presentation/list/clubs_list_screen.dart:189))
- [x] **Haptic light-tap on pin tap + sheet snap** — `_showMap`, `_showList`, `_selectMapEvent` all fire `HapticFeedback.selectionClick()`. ([clubs_list_screen.dart:168](../lib/clubs/presentation/list/clubs_list_screen.dart:168))
- [x] **Animated count ticker** on day-section header — `CatchDaySectionHeader` slides + fades the count when it changes. ([catch_day_section_header.dart](../lib/core/widgets/catch_day_section_header.dart))

## Catch primitives — additions worth considering

- [ ] **`CatchSegmentedControl`** already exists but isn't used on Explore; once we want a "Events / Clubs" lens toggle, adopt it.
- [ ] **`CatchEmptyState`** — current `_ExploreEventsEmptyState` is generic; should grow time-aware copy ("Nothing tonight — see this weekend?") with a one-tap shift.
- [ ] **Skeleton library** ([catch_skeleton.dart](../lib/core/widgets/catch_skeleton.dart)) — the current shimmer styles assume Sunset cream. Audit dark-mode rendering.
- [ ] **`CatchSurface`** — add `elevation: CatchSurfaceElevation.floating` between `raised` and `overlay` for cards that hover but aren't quite overlays (selected map pin, peek rail "now" card).

## Discovered while implementing the Explore refresh

- The `_FloatingActionPill` toggle (`Map · N` ↔ `List`) at the bottom-left of the scaffold could benefit from a softer entry animation when the sheet snaps — right now it just morphs label in place.
- Featured card meta row "ollective · 6/6 spots" was clipped at narrow viewports — root cause: it stacked `${club.name} · ${data.spotsLabel}` into a single `Text` with ellipsis but `club.name` runs first; ellipsis swallows `spotsLabel`. Fixed by moving meta into a `CatchMetaDotRow`.
- `EventTileStatus.hosted` uses `CatchBadgeTone.live` — the same "loud orange" complaint as the avatar-rail LIVE badge. Reuse the new corner sash and distinguish via icon, not tone.
- `selected ? t.primary : t.line` borders are everywhere — produced the "error-state look" the user called out on the peek rail. `CatchEventCardPeek` switches to a left-edge accent bar + tonal background tint + soft `card` elevation as the selected-state primitive. Adopt the same pattern wherever a "selected card" appears.
- `_ExploreEventFallback` used raw `Color.withValues(alpha: ...)` on a linear gradient and rendered like a broken image. Replaced with `CatchEventThumbnail` so every fallback shares the same committed-looking gradient based on `pace_level_theme.dart`.
- **Bounded error sliver** — `CatchInlineErrorState` inside a `SliverToBoxAdapter` rendered an unbounded `Text` of `error.toString()`. When a wrapped `ProviderException` had a full stack trace, the sliver's scroll extent dominated the sheet viewport and later sibling slivers (like the club directory) never got built. Two fixes landed: (1) `CatchErrorState` now caps the message `Text` at 4/8 lines, (2) `explore_events_section.dart` wraps the error sliver in `ClipRect + SizedBox(180) + OverflowBox` so its scroll extent stays bounded. Worth a global audit: every `CatchInlineErrorState.fromError(error, ...)` site should make sure the error toString is bounded.
- **Sliver `cacheExtent` matters in DraggableScrollableSheet** — sheet-constrained scroll viewports have a small visible height (~420 px on phone). The default `cacheExtent` of 250 means siblings further down the body never build until the user scrolls. The Explore sheet now uses `cacheExtent: 1600`. Any other sheet/scroll combo built on `DraggableScrollableSheet` should set this explicitly.
- **Sliver flattening** — avoid nesting `SliverMainAxisGroup` more than one level deep. We saw two distinct bugs (pinned-header `paintExtent < layoutExtent` and missing-builder for later items) that traced back to nested groups. The new pattern in this codebase is to expose `List<Widget>` sliver builders (`buildExploreEventsSlivers`, `buildClubDirectorySlivers`, `buildClubsListBodySlivers`) that callers spread into a single parent group.
