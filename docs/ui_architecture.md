---
doc_id: ui_architecture
version: 1.0.0
updated: 2026-05-22
owner: recursive_audit_loop
status: active
---

# UI Architecture

This is the source of truth for Catch layout, spacing, scroll ownership, sliver
usage, and widget-test layout expectations. It replaces the separate UI spacing
and sliver guides.

Read this before changing shared screen padding, pinned headers,
`CustomScrollView`, `NestedScrollView`, tab bodies, sticky search/filter rows,
or scroll-heavy widget tests. For widget inventory and reusable primitives, use
`docs/widget_catalog.md`.

## Spacing Rules

Use `CatchSpacing` from `lib/core/theme/catch_tokens.dart` for reusable layout
contracts.

| Token | Value | Typical use |
|---|---:|---|
| `CatchSpacing.s1` | 4 px | Tight icon/text gaps |
| `CatchSpacing.s2` | 8 px | Compact vertical gaps and chip spacing |
| `CatchSpacing.s3` | 12 px | Small section gaps |
| `CatchSpacing.s4` | 16 px | Standard card/content inset |
| `CatchSpacing.s5` | 20 px | Mobile screen side gutters |
| `CatchSpacing.s6` | 24 px | Large section gaps |
| `CatchSpacing.s8` | 32 px | Bottom breathing room |
| `CatchSpacing.s10` | 40 px | Hero-scale vertical spacing |
| `CatchSpacing.s12` | 48 px | Large header spacing |
| `CatchSpacing.s16` | 64 px | Oversized hero spacing only |

`Sizes.p*` is a compatibility bridge for intentional off-scale values such as
6, 10, 14, or 18. Do not add new `Sizes` constants when `CatchSpacing` already
fits.

When sibling surfaces must align, define one named inset near the owning widget
or primitive and reuse it. Do not scatter equivalent anonymous `EdgeInsets`
across sibling tabs.

Current named contract: `profileTabBodyPadding` in
`lib/user_profile/presentation/widgets/profile_tab.dart` uses 20 px horizontal,
8 px top, and 32 px bottom for Profile Edit and Preview tabs.

## Scroll Ownership

Each full screen should have one clear vertical scroll owner.

Use slivers when a screen needs:

- a collapsing hero/header;
- a pinned search, filter, or tab row;
- mixed header/rail/list/grid content in one viewport;
- lazy repeated rows below a custom header;
- route-owned and tab-owned scroll positions that must coordinate.

Prefer box layout for auth, onboarding, create/edit forms, bottom sheets,
dialogs, short settings pages, and small reusable widgets that need to work
inside more than one scroll context.

## Sliver Rules

- Direct children of `CustomScrollView.slivers` must be slivers.
- Use `SliverToBoxAdapter` only for one-off boxes.
- Use `SliverList.builder`, `SliverList.separated`, or `SliverGrid` for
  repeated content that can grow.
- Avoid a vertical `ListView` or large `Column` inside `SliverToBoxAdapter`.
- Use `SliverFillRemaining(hasScrollBody: false)` for centered empty/error
  states, not for tall skeletons or arbitrary content.
- If a parent owns a sliver scroll view, async loading/error/empty/data state
  widgets should usually return slivers too.

`SliverPersistentHeaderDelegate.minExtent` and `maxExtent` are layout
contracts. Header overflows usually mean the declared extent does not fit text
line height, gaps, padding, icons, or control height. Do not fix those by
negative padding or feature-local nudges.

Pinned bottom rows must not visually cover a collapsing title. Shared feature
headers should use `CatchSliverHeader` from `lib/core/widgets/catch_top_bar.dart`
and its title-height contracts before adding local header math.

## Nested Tab Screens

For `NestedScrollView` plus pinned tab rows:

- The outer header owns safe area and pinned-row behavior.
- The absorbed sliver should be the pinned tab row, not the entire scroll-away
  title group.
- Each tab body starts with the matching `SliverOverlapInjector`.
- Body padding belongs to the tab body, not to the pinned tab row.
- If a tab body contains an independently scrollable child and its top gap must
  remain visible when that child returns to offset zero, put the gap inside that
  filled child.
- If the intended UX is one continuous gesture, bridge both directions:
  child-upward scroll collapses the parent header first, and leading overscroll
  at the child top expands the parent header again.

Profile currently owns that stricter contract. Keep widget tests around the
absorber/injector pair and preview-card scroll bridge.

## Current Screen Decisions

| Surface | Direction |
|---|---|
| Home dashboard | Keep one `CustomScrollView` with `DashboardSliverHeader`; do not reintroduce Dashboard/Activity tabs without a product decision. |
| Clubs list | Keep sliver-native. This remains the strongest mixed rail/list pattern. |
| Chats list | Keep sliver shell; make populated body sliver-native only if list scale or tests demand it. |
| Event detail | Keep sliver-native because the collapsing hero justifies it. |
| Club detail | Keep sliver-native with agenda-style event list. |
| User profile | Keep `NestedScrollView`; preserve overlap injection and preview-card scroll bridge. |
| Map-heavy screens | Audit before migrating. Stable map viewport may matter more than sliver composition. |
| Attendance sheet | Keep box-based while it remains a modal/sheet. |
| Create event, onboarding, auth | Do not migrate just for consistency. |

## Migration Checklist

1. Identify the single vertical scroll owner.
2. Put it at the screen body boundary.
3. Convert app bars, hero headers, pinned controls, or tab headers into slivers.
4. Keep async state dispatch sliver-native below a sliver parent.
5. Use lazy slivers for growing repeated content.
6. Keep leaf widgets box-based and adapt them at screen composition boundaries.
7. Test loading, empty, error, populated, and small-viewport states.
8. Treat brittle widget tests as layout feedback: positional finders, timing
   hacks, or exact duplicate-text counts usually mean the seams need work.
