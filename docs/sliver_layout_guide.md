---
doc_id: sliver_layout
version: 2.1.3
updated: 2026-05-06
owner: recursive_audit_loop
status: active
---

# Sliver Layout Guide

This document explains the sliver-native layout pattern now used in several
Catch screens. It is meant to be both a maintenance guide for this codebase and
a short "Sliver 101" lesson for future implementation passes.

## Read Policy

Read this before changing sliver-native screens, tabbed `NestedScrollView`
surfaces, sticky headers, or scroll-heavy widget tests. For other work, use the
audit registry's `SLIVER-001` rule summary instead of loading this full guide.

## Rule Changelog

### 2.1.3

- Independently scrollable content inside a tabbed `NestedScrollView` needs an
  explicit leading-overscroll bridge if dragging down at the child top should
  expand the outer header. Profile Preview uses this for the internal
  `ProfileCard` scroll so the `Profile` title can return without touching the
  tab row.

### 2.1.2

- Sibling tab bodies under the same pinned tab row should share a named body
  inset constant. If a tab body contains an independently scrollable child and
  its top gap must remain visible when that child returns to offset zero, put
  the gap inside the filled child rather than as outer sliver padding.

### 2.1.1

- Profile-specific `NestedScrollView` rule clarified: absorb the pinned
  Edit/Preview tab-row sliver, not the whole Profile header group. The
  collapsible title should remain a normal outer sliver so it scrolls away
  naturally, while each tab body injects the absorbed pinned-row overlap before
  rendering its content.

### 2.1.0

- Collapsible title headers must move upward as they collapse. Pinned bottom
  rows, such as search/filter/tab rows, must not visually scroll over and cover
  the title.
- `CatchSliverHeader` now translates the title by the current shrink offset so
  the title behaves like normal scroll content while the bottom row pins.
- Apply this contract consistently to Profile, Run Clubs, Chats, and any future
  sliver-native feature header.

### 2.0.0

- Sliver ownership and `NestedScrollView` overlap rules are now versioned as
  `SLIVER-001` in `docs/audit_registry/rules.json`.
- Future sliver fixes should stamp files with the applied guide version.

## Short Verdict

Moving some screens to sliver-native layouts was a good decision, but it should
not become a blanket rule for every screen.

Slivers are the right tool when a screen needs one coordinated scrollable
surface with pinned headers, collapsible hero app bars, mixed list/section
content, or lazy repeated rows below a custom header. In those cases,
`CustomScrollView` plus slivers is more direct, more testable, and less fragile
than nesting `Column`, `ListView`, `SingleChildScrollView`, and custom app-bar
workarounds.

Slivers are unnecessary overhead for simple forms, modal sheets, short static
pages, and focused widgets that do not need to participate in a shared scroll
viewport. Those should stay box-based unless a real layout problem appears.

## Why We Migrated Some Screens

The migration was not done because `ListView.builder` is slow. It was done
because several screens had outgrown simple box layouts:

- Run clubs needed a collapsible feature title, a pinned search/filter header,
  a joined-club horizontal rail, and a discover list inside one scroll owner.
  The old shape mixed a `CustomScrollView` with boxed list content, which caused
  layout brittleness and widget-test failures.
- Chats needed a pinned search header plus loading, empty, error, and populated
  conversation states. Earlier loading states put tall skeleton content inside
  `SliverFillRemaining`, which was too constraining for the actual content.
- Run detail has a natural collapsing photo/map hero. A sliver app bar lets the
  hero, share/save controls, and content body behave as one scrollable surface
  instead of splitting the screen between an app bar and a separate list.
- User profile uses `NestedScrollView` because the profile header and tab body
  need coordinated scrolling.

So the architectural reason was scroll ownership: each full screen should have
one clear vertical scroll owner, and the direct children of that owner should
use the same scroll protocol.

## Sliver 101

Most Flutter layout widgets are box widgets. A `Column`, `Container`, `Padding`,
or `Text` lays out inside a two-dimensional box constraint system.

A sliver is different. A sliver is a scroll-aware layout participant. Instead of
only answering "how big is my box?", it answers questions such as:

- How much scroll extent do I contribute?
- Which portion of me is currently visible?
- What should be painted in or near the viewport?
- Should part of me remain pinned while the rest scrolls away?
- How many children need to be built and laid out for the current viewport?

Flutter's official docs describe a sliver as a portion of a scrollable area that
can behave in a special way. `CustomScrollView` is the widget that lets us
supply slivers directly, and its direct children must be widgets that produce
`RenderSliver` objects.

The important mental model:

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(...),
      SliverToBoxAdapter(child: SomeOneOffBoxWidget()),
      SliverList.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) => RowWidget(row: rows[index]),
      ),
    ],
  ),
)
```

Inside `CustomScrollView.slivers`, every direct child must be a sliver. Normal
box widgets can still be used, but they need to be adapted with
`SliverToBoxAdapter`, or included as children of a sliver such as `SliverList`.

## ListView And SliverList Are Closely Related

`ListView` is not a totally separate mechanism from slivers. Flutter documents
`ListView` as essentially a `CustomScrollView` with one `SliverList`.

That means:

- `ListView.builder` maps to a `SliverList` with a
  `SliverChildBuilderDelegate`.
- `ListView.separated` maps to a builder-style sliver delegate that produces
  row and separator children.
- `ListView` padding maps to wrapping the sliver list in `SliverPadding`.
- When a screen needs a list plus a `SliverAppBar`, pinned search, sliver grid,
  or custom header, using `CustomScrollView` directly is the idiomatic next
  step.

The performance model is therefore familiar. `ListView.builder` lazily creates
visible children. `SliverList` with `SliverChildBuilderDelegate` does the same
kind of lazy child creation inside a more general scroll protocol.

## How Slivers Build Lazily

A sliver list does not eagerly build every possible row. During layout, the
viewport gives each sliver scroll constraints, including the current scroll
offset and the viewport/cache area. The sliver then asks its child delegate for
only the children it needs to cover the visible area and the configured cache
extent.

For `SliverList` with `SliverChildBuilderDelegate`, this means:

- Children near the viewport are built, laid out, and painted.
- Children outside the visible/cache range are not built yet.
- When children scroll far enough away, their element/render subtrees can be
  destroyed.
- If the row scrolls back into view, it can be recreated from the source data.
- Keep-alive behavior can preserve selected row state, but that should be used
  intentionally.

This is why list-row business logic should not live inside a disposable row
subtree. Store durable state in repositories, controllers, providers, or view
models. Let row widgets be cheap to recreate from those inputs.

## Mixing Sliver And Non-Sliver Widgets

Yes, sliver and non-sliver widgets can be mixed. The rule is about where they
are mixed.

Good patterns:

```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: HeaderSummaryCard()),
    SliverList.builder(...),
  ],
)
```

```dart
SliverPadding(
  padding: const EdgeInsets.all(16),
  sliver: SliverList.list(
    children: [
      OverviewSection(),
      SizedBox(height: 24),
      SocialSection(),
    ],
  ),
)
```

Bad or risky patterns:

```dart
CustomScrollView(
  slivers: [
    Column(children: rows), // Invalid: Column is not a sliver.
  ],
)
```

```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: ListView.builder(...), // Usually nested scroll ownership.
    ),
  ],
)
```

```dart
SliverToBoxAdapter(
  child: Column(children: hundredsOfRows), // Builds all rows eagerly.
)
```

Use `SliverToBoxAdapter` for one-off boxes: summaries, skeleton groups, banners,
single empty-state cards, or small fixed sections. Use `SliverList`,
`SliverGrid`, or another lazy sliver for repeated content that can grow.

## Performance Implications

Sliver-native screens are not automatically faster than `ListView.builder`.
They are more expressive. The performance benefit comes from using the right
sliver for the right part of the scroll tree.

Good performance properties:

- `SliverList.builder` lazily builds rows in and near the viewport.
- `SliverGrid` provides the same kind of viewport-aware behavior for grids.
- `SliverAppBar` and `SliverPersistentHeader` let headers pin/collapse without
  layering a separate app bar over a separate scrollable body.
- A single vertical scroll owner avoids nested scroll physics, shrink-wrap
  layout work, and gesture conflicts.

Common performance and layout traps:

- A huge `Column` inside `SliverToBoxAdapter` builds all children eagerly.
- A vertical `ListView` inside `SliverToBoxAdapter` usually creates nested
  scrolling and often forces `shrinkWrap`, which is more expensive.
- `SliverFillRemaining` is for filling the remaining viewport. It is excellent
  for centered empty/error states, but it is a poor fit for tall unconstrained
  loading skeletons or arbitrary content that naturally wants to exceed the
  viewport.
- `SliverList.list` is fine for a small fixed set of sections, but use builder
  delegates for real lists.
- Pinned headers must reserve enough height for their child. In this repo, a
  pinned search header must fit the compact `CatchTextField`; otherwise tests
  and small screens expose overflows.

## Persistent Header Extents

`SliverPersistentHeaderDelegate` is not a normal shrink-wrap layout slot. The
delegate's `minExtent` and `maxExtent` are the source of truth for how much
vertical space Flutter gives the child as the header scrolls. During layout,
Flutter renders the child somewhere between those two extents based on
`shrinkOffset`.

That means header overflows are usually contract bugs, not cosmetic bugs:

- If a pinned header has `minExtent == maxExtent`, that extent must be at least
  as tall as the child plus its padding.
- If a collapsible header has `minExtent < maxExtent`, the child will receive a
  shrinking height as the user scrolls. If the title content should visually
  scroll away rather than compress, lay it out at its full height and clip the
  visible area as it collapses.
- When a collapsible title is followed by a pinned bottom row, the title must
  translate upward with the scroll offset. Do not let the bottom row appear to
  scroll over the title and cover it. This applies to Run Clubs, Chats, Profile,
  and any future screen with a scroll-away title plus sticky search/filter/tab
  row.
- Do not fix sticky-header overflows by repeatedly nudging feature heights until
  the error disappears. First calculate whether the declared extent matches the
  child layout: text line heights, gaps, vertical padding, icons, and input
  control height.
- Search headers should use a stable input-control height. In this app,
  `CatchTextField.compactControlHeight` is the control-height contract for
  compact search fields inside pinned sliver headers.

Catch's shared `CatchSliverHeader` now exposes
`CatchSliverHeader.twoLineTitleHeight` for feature headers that combine
`displayL`, `bodyS`, one small line gap, and standard title padding. Reuse that
constant before inventing another one-off title height.

## Current Codebase Patterns

### Shared Sliver Headers

`lib/core/widgets/catch_top_bar.dart` defines the shared sliver top-bar tools:

- `CatchSliverTopBar` wraps `SliverAppBar` for screens that want a Catch-styled
  collapsible top bar.
- `CatchSliverHeader` builds two `SliverPersistentHeader` slivers: a
  collapsible title and an optional pinned bottom area.

Feature headers should wrap these shared primitives instead of rebuilding local
header mechanics. Current examples:

- `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart`
- `lib/matches/presentation/widgets/chats_sliver_header.dart`
- `lib/user_profile/presentation/widgets/profile_sliver_header.dart`

There is still duplication between chats and run-clubs headers. The widget
cleanup tracker already calls out that `CatchSliverHeader` should probably grow
more reusable title/subtitle/action/search configuration so those feature
wrappers can get smaller or disappear.

### Run Clubs List

`lib/run_clubs/presentation/list/run_clubs_list_screen.dart` is a clean sliver
screen shape:

```dart
CustomScrollView(
  slivers: [
    ...RunClubsSliverHeader().buildSlivers(context),
    const RunClubsList(),
  ],
)
```

`RunClubsList` is the async state dispatcher and returns slivers for loading,
error, empty, and data states. This is important: because the parent owns a
`CustomScrollView`, the state widget also returns slivers.

`RunClubsListBody` is sliver-native through `SliverMainAxisGroup`. It can render
a one-off horizontal joined-club rail through `SliverToBoxAdapter`, then render
the discover directory through `RunClubDiscoverList`.

`RunClubDiscoverList` uses a real `SliverList` with
`SliverChildBuilderDelegate`, so the repeated directory rows participate in
viewport-aware lazy layout.

This is the best current example of the desired pattern.

### Chats List

`lib/matches/presentation/matches_list_screen.dart` also owns one
`CustomScrollView`:

```dart
CustomScrollView(
  slivers: [
    ...ChatsSliverHeader(count: count).buildSlivers(context),
    const ChatsList(),
  ],
)
```

`ChatsList` already handles loading, error, and empty states as slivers. The
populated state still wraps `ChatsListBody` in `SliverToBoxAdapter`, and
`ChatsListBody` is a `Column` containing the new-match rail and conversation
list.

That is acceptable while the populated chat body is small and bounded, but it is
not the ideal long-term shape if conversation count grows. If chats becomes a
large list, `ChatsListBody` should become sliver-native, following the run-clubs
pattern: one box adapter for the horizontal rail, then a `SliverList` for
conversations.

### Run Detail

`lib/runs/presentation/widgets/run_detail_body.dart` owns the loaded screen
scaffold and one `CustomScrollView`. It starts with
`RunDetailHeroAppBar`, which returns a `SliverAppBar`, then uses a
`SliverPadding` plus `SliverList.list` for a small fixed set of semantic
sections:

- `RunDetailOverviewSection`
- divider/spacing
- `RunDetailSocialSection`

This is a good use of `SliverList.list` because the body is not a large repeated
feed. It is a small set of sections that should scroll under a collapsing hero.

The prior nested-scaffold version was harder to reason about because screen
ownership was split between route-level wrappers and the loaded body. The
current version is cleaner: route-level loading/error/not-found states can own
their own simple scaffold, while the loaded body owns the actual detail screen.

### Run Club Detail

`lib/run_clubs/presentation/detail/widgets/club_detail_body.dart` uses
`CustomScrollView`, `ClubHeroAppBar`, a small `SliverList.list` of details, and
`ClubScheduleSection` for upcoming runs.

This is mostly appropriate because the page has a hero plus mixed detail
sections. The old two-dimensional `RunScheduleGrid` was removed because it was
heavier than the product need and introduced nested-scroll/layout pressure under
the page scroll. The current section reuses `RunAgendaSliverList`, so upcoming
runs are listed from soonest to latest using the same agenda language as the
Calendar screen.

### User Profile

`lib/user_profile/presentation/profile_screen.dart` uses `NestedScrollView`
with a sliver profile header and tabbed body scroll views. This is one of the
legitimate cases for `NestedScrollView`: the outer header and inner tab bodies
need to coordinate overlap and scroll behavior.

The maintenance rule is stricter here: when using `NestedScrollView`, keep the
`SliverOverlapAbsorber` and `SliverOverlapInjector` pair intact. Removing either
side usually creates header/body overlap bugs.

For Profile specifically, the absorber should wrap the pinned Edit/Preview tab
row, not the whole header group. The scroll-away `Profile` title is a normal
outer sliver. Each Edit/Preview tab `CustomScrollView` should start with the
matching `SliverOverlapInjector`, then render its feature slivers. Widget tests
should assert the absorber/injector pair and verify that initial tab content
starts below the pinned tab row.

Sibling tabs should also share one named body inset. In Profile, both Edit and
Preview use `profileTabBodyPadding`: 20 px horizontal, 8 px top, and 32 px
bottom. The Edit tab applies that inset as sliver/list padding because the tab
body owns the vertical scroll. Preview applies the same inset inside
`SliverFillRemaining` because the preview card owns its own internal scroll;
placing that gap outside the filled child lets the outer sliver padding scroll
away while the card has returned to its own top.

When a tab contains an independently scrollable child, such as the shared
`ProfileCard`, do not assume the child will hand gestures back to
`NestedScrollView` at its leading edge. If the intended UX is one continuous
gesture where dragging down from the child's top reveals the parent header,
bridge the child's leading overscroll to the route-owned outer scroll
controller and test that dragging on the child restores the header. Keep this
bridge route-specific unless the shared card/surface always needs parent-header
coordination.

## Should More Screens Become Sliver-Native?

Use slivers selectively.

Good candidates:

- Screens with a hero image/map/header that should collapse or pin while body
  content scrolls.
- Screens with a pinned search/filter area above a list.
- Screens that currently nest vertical `ListView`, `SingleChildScrollView`, or
  `Column` in a way that causes overflow, brittle tests, or gesture conflicts.
- Screens with mixed repeated sections: header, horizontal rail, vertical list,
  grid, empty/error/data states.
- Long feeds or rosters where repeated rows should be lazy and scroll under a
  shared top surface.

Poor candidates:

- Auth, onboarding, and create/edit forms where a normal `Scaffold` plus
  box-based form layout is simpler.
- Bottom sheets and dialogs.
- Short settings pages unless they need sticky groups or large lazy sections.
- Small reusable widgets that need to work both inside and outside scroll
  contexts. Keep those box-based and adapt them at the screen boundary.

Current repo-specific recommendation:

| Surface | Recommendation |
|---|---|
| Run clubs list | Keep sliver-native. This is the strongest pattern example. |
| Chats list | Keep sliver shell. Consider making populated body sliver-native if conversation count or tests demand it. |
| Run detail | Keep sliver-native. The collapsing hero justifies it. |
| Run club detail | Keep sliver-native. Upcoming runs should remain agenda-style unless a true calendar/schedule grid becomes a product requirement. |
| User profile | Keep `NestedScrollView`; document/test overlap behavior when editing. |
| Run map screen / map sheet | Audit before migrating. A map-heavy screen may need a stable map viewport more than a sliver body. If the sheet becomes a full-screen list with pinned controls, slivers may help. |
| Attendance sheet | Probably keep box-based if it remains a modal/sheet. Consider slivers only for a full-screen roster with sticky filters/actions. |
| Create run / onboarding / auth | Do not migrate just for consistency. These are form/workflow screens, not sliver-first surfaces. |

## Migration Checklist

When converting a screen:

1. Identify the single vertical scroll owner.
2. Put the scroll owner at the screen body boundary, usually
   `CustomScrollView`.
3. Convert app bars, hero headers, pinned search, or tab headers into slivers.
4. Keep async state dispatch sliver-native when the parent is sliver-native.
5. Use `SliverToBoxAdapter` only for one-off box sections.
6. Use `SliverList.builder`, `SliverList.separated`, or `SliverGrid` for
   repeated content that can grow.
7. Avoid vertical `ListView` inside `SliverToBoxAdapter`.
8. Avoid large `Column` trees inside `SliverToBoxAdapter`.
9. Use `SliverFillRemaining(hasScrollBody: false)` for centered empty/error
   states that should fill the viewport.
10. Use padded `SliverToBoxAdapter` or a real lazy sliver for loading skeletons
    that naturally exceed the viewport.
11. Test loading, empty, error, populated, and small-viewport behavior.
12. Treat widget-test brittleness as layout feedback. If tests need positional
    scrollables, timing hacks, or exact duplicate text counts, improve the
    screen seams or add semantic keys.

## Naming And Maintenance Rules For Catch

- If a widget returns a sliver, make that clear by context or name. Examples:
  `RunDetailHeroAppBar`, `RunClubsSliverHeader`, `ChatsSliverHeader`.
- Feature screens should compose slivers; lower-level leaf widgets should
  usually remain normal box widgets.
- Shared sliver primitives belong in `lib/core/widgets`.
- Feature-specific sliver wrappers belong near their feature screen.
- Do not make every primitive sliver-aware. Prefer adapting box primitives at
  screen composition boundaries.
- Keep business logic in controllers/view models, not in sliver delegates or
  row builders.
- Prefer stable tooltips, keys, and user-visible behavior in widget tests.

## Official References

- Flutter docs: [Using slivers to achieve fancy scrolling](https://docs.flutter.dev/ui/layout/scrolling/slivers)
- Flutter API: [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)
- Flutter API: [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- Flutter API: [SliverList](https://api.flutter.dev/flutter/widgets/SliverList-class.html)
- Flutter API: [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html)
- Flutter API: [SliverFillRemaining](https://api.flutter.dev/flutter/widgets/SliverFillRemaining-class.html)
