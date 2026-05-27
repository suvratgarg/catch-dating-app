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
- `EventDateRailCard` — shared left-date-rail event row for Explore, Calendar, Saved Events, and club schedules. See [event_date_rail_card.dart](../lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart).
- `EventActivityVisualSpec` / `EventActivityBackdrop` — mutable production activity visual schema keyed by `ActivityKind`, shared by Explore cards, ticket imagery, and event detail headers. See [event_activity_visuals.dart](../lib/events/presentation/event_activity_visuals.dart).
- `CatchEventTicketCard` / `CatchEventSpotlightCard` — activity-art production event cards migrated from the Explore concept lab and backed by `EventActivityVisualSpec`. See [catch_event_activity_cards.dart](../lib/core/widgets/catch_event_activity_cards.dart).
- `CatchEventThumbnail` — shared photo + activity-art fallback for any event surface; callers can set `preferActivityArtwork` when the activity palette should override uploaded photos. See [catch_event_thumbnail.dart](../lib/core/widgets/catch_event_thumbnail.dart).
- `EventCapacityPresenter` — shared event-card capacity/attendance copy and progress source. See [event_capacity_presenter.dart](../lib/events/presentation/widgets/event_tiles/event_capacity_presenter.dart).
- `EventActivityStamp` / `EventClockMark` / `EventCapacityProgress` / `EventStatusPill` — shared event-card activity/status/progress atoms. See [event_visual_atoms.dart](../lib/events/presentation/widgets/event_tiles/event_visual_atoms.dart).
- `EventActionCard` — shared full-width lifecycle/action card for booked-event focus and host event operations. See [event_action_card.dart](../lib/events/presentation/widgets/event_tiles/event_action_card.dart).
- `EventCompactRow` — dense event row for notification/activity surfaces that still need a small tappable event depiction. See [event_compact_row.dart](../lib/events/presentation/widgets/event_tiles/event_compact_row.dart).
- `EventDateMarker` — shared calendar day/week marker with event dots and selected/today state. See [event_date_marker.dart](../lib/events/presentation/widgets/event_tiles/event_date_marker.dart).
- `ClubIdentityAtoms` — shared club-card member, tag, host, role, and rating atoms. See [club_identity_atoms.dart](../lib/clubs/presentation/shared/club_identity_atoms.dart).
- `CatchTextStyles.kickerCaps` — caps-tracked label style.
- `CatchTextStyles.numericLarge` — tabular numerals for counts/distances on cards.

## Screens to migrate to the new event card primitives

- [x] **Dashboard / Home** ([lib/dashboard/presentation/](../lib/dashboard/presentation/)) — `RecommendCard` uses `CatchEventTicketCard`; `EventFocusRail` and host tools use `EventActionCard`; Notifications upcoming rows use `EventCompactRow`.
- [x] **Saved events / calendar / club detail agenda rows** ([lib/events/presentation/widgets/event_agenda_list.dart](../lib/events/presentation/widgets/event_agenda_list.dart)) — agenda rows now route through `EventAgendaTile` into the shared `EventDateRailCard`, matching the Explore mixed-feed date-rail card instead of keeping a separate agenda visual.
- [x] **Event detail** ([lib/events/presentation/event_detail_screen.dart](../lib/events/presentation/event_detail_screen.dart)) — detail headers now prefer the shared activity artwork from `EventActivityVisualSpec`, so event detail, Explore spotlight cards, and map-selected cards use the same type palette.
- [ ] **Club discover list** ([lib/clubs/presentation/list/widgets/club_discover_list.dart](../lib/clubs/presentation/list/widgets/club_discover_list.dart)) — directory cards now share `ClubIdentityAtoms`; the remaining work is visual direction and no-cover primitive consolidation, not another host/tag/member-count implementation.
- [ ] **Event success / wingman screens** ([lib/event_success/presentation/](../lib/event_success/presentation/)) — currently use ad-hoc layouts; adopt `CatchDaySectionHeader` and the corner sash pattern.

## Tile/atom retirements

- [x] Retired **`CatchEventCardCompact`**, **`CatchEventCardHero`**, **`EventRailTile`**, **`EventMapTile`**, and **`CatchEventCardPeek`** — list/agenda surfaces now use `EventDateRailCard`; selected non-spotlight map pins and the nearby map rail use `CatchEventTicketCard`, while the selected spotlight pin keeps `CatchEventSpotlightCard`.
- [x] Consolidated card atoms for **club identity**, **event status**, **capacity copy**, and **activity clock/progress** — use `club_identity_atoms.dart`, `event_capacity_presenter.dart`, and `event_visual_atoms.dart` before adding new club/event card variants.
- [x] Retired **`EventHeroTile`**, **`EventTileStatusBadge`**, and **`EventTileFactWrap`** — the remaining production booked-event and host-event action surfaces now share `EventActionCard`, while dense event rows use `EventCompactRow` or `EventDateRailCard`.
- [ ] Delete **`ClubCoverFallback`** only after the remaining production no-image club surfaces migrate to the new club visual primitive. Current blockers: `_ExploreClubCover` in [explore_events_section.dart](../lib/clubs/presentation/list/widgets/explore_events_section.dart) for mixed-feed club cards, `_ClubImage._placeholder` in [club_image.dart](../lib/clubs/presentation/list/widgets/club_list_tile_parts/club_image.dart) for avatar/directory tiles, `_ClubLogoFallback` in [directory_card.dart](../lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart), and the fallback assertions in [clubs_widgets_test.dart](../test/clubs/clubs_widgets_test.dart). The new club detail hero path no longer depends on this widget.
- [ ] Audit all `Wrap(spacing: CatchSpacing.s1, runSpacing: ..., children: [CatchBadge(...), ...])` uses — many should become `CatchMetaDotRow`.
- [ ] **`CatchBadgeTone.live`** — the orange "LIVE" pill is overloaded language (suggests streaming/video). Audit every use site; "Event today" with `CatchStatusDot(success)` is usually right. Sites: [club_list_tile_parts/avatar_chip.dart](../lib/clubs/presentation/list/widgets/club_list_tile_parts/avatar_chip.dart), [event_tile_atoms.dart](../lib/events/presentation/widgets/event_tiles/event_tile_atoms.dart) (`hosted` status).

## Icon set

- [x] **`CatchIcons` facade landed** — [lib/core/theme/catch_icons.dart](../lib/core/theme/catch_icons.dart) wraps `phosphor_flutter`. The Explore screen, browse header, filter rail, event cards, and peek rail all reference `CatchIcons.*` instead of `Icons.*`. The facade keeps screens decoupled from the underlying package, so a future swap (e.g. to Lucide or to a custom brand set) is a one-file change.
- [x] **App-wide `Icons.*` migration complete** — `lib/**/*.dart` and `test/**/*.dart` now route Material icon usage through `CatchIcons.*`, with the only direct `Icons.*` references centralized in [catch_icons.dart](../lib/core/theme/catch_icons.dart). The Material-named facade entries are transitional compatibility aliases; new code should prefer semantic Catch-named getters and add facade entries instead of importing Material `Icons` directly.
- [ ] **Audit Phosphor weights**. The facade currently mixes Duotone (time pills, activity glyphs), Regular (filters, search), Bold (navigation chrome), and Fill (selected/active states). That distinction is intentional — duotone reads as expressive moments, regular as functional controls, bold for navigation, fill for active/saved — but the rest of the app should follow the same convention. Document it in the facade if a code reviewer ever questions a particular weight choice.

## Map

- [x] **Map pin clustering** — `EventPinsMap` now clusters dense pins with an app-rendered count marker below close zooms, then expands back to individual time pins at street-level zoom.
- [x] **Distance ring** around user GPS pin on the map (visual aid + filter affordance).
- [x] **User-location pin styling** — the map uses app-owned user-location circles instead of relying on the native blue-dot styling.
- [x] **Re-order PEEK rail by distance** as the user pans/zooms the map; the rail now re-sorts by distance from the latest camera center on idle.
- [x] **Distance ring filter affordance** — tapping the ring cycles through 1/3/5/10 km and back to any distance.

## Sheet & motion

- [x] **Wrist-lift map reveal** — Explore wraps `sensors_plus` behind `DeviceMotionSource`, runs a conservative pitch/acceleration recognizer only while the full sheet is active, and uses a distinct light-impact, overshoot-and-settle animation for the physical reveal.
- [x] **Sticky day-section headers** — the primary Explore sheet now spreads flat slivers and uses `SliverPersistentHeader(pinned: true)` with `CatchDaySectionHeaderDelegate`. The legacy single-widget `ExploreEventsSection` compatibility wrapper keeps inline headers to avoid the `SliverMainAxisGroup` assertion path.
- [x] **Spring-curve sheet snap** — `_snapTo` uses `CatchMotion.springCurve`. ([clubs_list_screen.dart](../lib/clubs/presentation/list/clubs_list_screen.dart))
- [x] **Haptic light-tap on pin tap + sheet snap** — `_showMap`, `_showList`, `_selectMapEvent` all fire `HapticFeedback.selectionClick()`. ([clubs_list_screen.dart](../lib/clubs/presentation/list/clubs_list_screen.dart))
- [x] **Animated count ticker** on day-section header — `CatchDaySectionHeader` slides + fades the count when it changes. ([catch_day_section_header.dart](../lib/core/widgets/catch_day_section_header.dart))

## Catch primitives — additions worth considering

- [ ] **`CatchSegmentedControl`** already exists but isn't used on Explore; once we want a "Events / Clubs" lens toggle, adopt it.
- [x] **`CatchEmptyState`** — Explore event empty states now use time-aware copy with one-tap shifts such as "Nothing tonight" → "See weekend" and "Nothing this week" → "See anytime".
- [ ] **Skeleton library** ([catch_skeleton.dart](../lib/core/widgets/catch_skeleton.dart)) — the current shimmer styles assume Sunset cream. Audit dark-mode rendering.
- [ ] **`CatchSurface`** — add `elevation: CatchSurfaceElevation.floating` between `raised` and `overlay` for cards that hover but aren't quite overlays (selected map pin, peek rail "now" card).

## Discovered while implementing the Explore refresh

- The `_FloatingActionPill` toggle (`Map · N` ↔ `List`) at the bottom-left of the scaffold could benefit from a softer entry animation when the sheet snaps — right now it just morphs label in place.
- Featured card meta row "ollective · 6/6 spots" was clipped at narrow viewports — root cause: it stacked `${club.name} · ${data.spotsLabel}` into a single `Text` with ellipsis but `club.name` runs first; ellipsis swallows `spotsLabel`. Fixed by moving meta into a `CatchMetaDotRow`.
- `EventTileStatus.hosted` uses `CatchBadgeTone.live` — the same "loud orange" complaint as the avatar-rail LIVE badge. Reuse the new corner sash and distinguish via icon, not tone.
- `selected ? t.primary : t.line` borders are everywhere — produced the "error-state look" the user called out on older selected cards. The retired `CatchEventCardPeek` no longer owns the map selected state; future selected-card treatments should use committed primitives instead of local border color flips.
- `_ExploreEventFallback` used raw `Color.withValues(alpha: ...)` on a linear gradient and rendered like a broken image. Replaced with `CatchEventThumbnail` so every fallback shares the same committed-looking gradient based on `pace_level_theme.dart`.
- **Bounded error sliver** — `CatchInlineErrorState` inside a `SliverToBoxAdapter` rendered an unbounded `Text` of `error.toString()`. When a wrapped `ProviderException` had a full stack trace, the sliver's scroll extent dominated the sheet viewport and later sibling slivers (like the club directory) never got built. Two fixes landed: (1) `CatchErrorState` now caps the message `Text` at 4/8 lines, (2) `explore_events_section.dart` wraps the error sliver in `ClipRect + SizedBox(180) + OverflowBox` so its scroll extent stays bounded. Worth a global audit: every `CatchInlineErrorState.fromError(error, ...)` site should make sure the error toString is bounded.
- **Sliver `cacheExtent` matters in DraggableScrollableSheet** — sheet-constrained scroll viewports have a small visible height (~420 px on phone). The default `cacheExtent` of 250 means siblings further down the body never build until the user scrolls. The Explore sheet now uses `cacheExtent: 1600`. Any other sheet/scroll combo built on `DraggableScrollableSheet` should set this explicitly.
- **Sliver flattening** — avoid nesting `SliverMainAxisGroup` more than one level deep. We saw two distinct bugs (pinned-header `paintExtent < layoutExtent` and missing-builder for later items) that traced back to nested groups. The new pattern in this codebase is to expose `List<Widget>` sliver builders (`buildExploreEventsSlivers`, `buildClubDirectorySlivers`, `buildClubsListBodySlivers`) that callers spread into a single parent group.
