---
doc_id: ui_layout_spacing
version: 1.0.0
updated: 2026-05-06
owner: recursive_audit_loop
status: active
---

# UI Layout And Spacing Guide

This document records durable layout spacing contracts that should be reused
across screens. Use it with `docs/widget_catalog.md` and
`docs/sliver_layout_guide.md`; do not duplicate full widget inventory here.

## Read Policy

Read this before adding or changing shared screen padding, tab body insets,
section spacing, fixed-format card spacing, or sliver/tab body gaps. For a
small local visual fix, prefer the existing named constant in code and update
this document only when the reusable contract changes.

## Rule Changelog

### 1.0.0

- Added the first durable tab-body spacing contract for Profile and future
  sibling tab screens.
- Documented the rule that repeated screen spacing needs a named constant near
  the owning widget or a shared layout primitive, not anonymous `EdgeInsets`
  scattered across sibling tabs.

## Token Scale

Use `CatchSpacing` from `lib/core/theme/catch_tokens.dart` for new reusable
layout constants.

| Token | Value | Typical use |
|---|---:|---|
| `CatchSpacing.s1` | 4 px | Tight icon/text gaps, compact separators |
| `CatchSpacing.s2` | 8 px | Compact vertical body gaps, chip spacing |
| `CatchSpacing.s3` | 12 px | Small section gaps |
| `CatchSpacing.s4` | 16 px | Standard card/content inset |
| `CatchSpacing.s5` | 20 px | Screen side gutters on mobile |
| `CatchSpacing.s6` | 24 px | Large section gaps |
| `CatchSpacing.s8` | 32 px | Bottom breathing room, large vertical endings |
| `CatchSpacing.s10` | 40 px | Hero-scale vertical spacing |
| `CatchSpacing.s12` | 48 px | Large hero/header spacing |
| `CatchSpacing.s16` | 64 px | Oversized hero spacing only |

`Sizes.p*` is a compatibility bridge for values that are intentionally off the
4-point scale, such as 6, 10, 14, or 18. Do not add new `Sizes` constants when
an existing `CatchSpacing` token is appropriate.

## Named Insets

When sibling surfaces must align, define one named constant and use it in every
sibling. Avoid separately writing equivalent `EdgeInsets` in each tab.

### Profile Tab Body

Current code owner: `profileTabBodyPadding` in
`lib/user_profile/presentation/widgets/profile_tab.dart`.

```dart
const profileTabBodyPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5, // 20 px left
  CatchSpacing.s2, // 8 px top
  CatchSpacing.s5, // 20 px right
  CatchSpacing.s8, // 32 px bottom
);
```

Use this for both Profile tabs:

- Edit tab: applied as `ListView.padding` for standalone usage and
  `SliverPadding` for the sliver body.
- Preview tab: applied inside the `SliverFillRemaining` child so the visible
  gap below the pinned tab bar belongs to the preview body, not to an outer
  sliver wrapper that disappears when the child scroll position changes.

If another two-tab route needs the same visual rhythm, add a feature-named
constant rather than reusing `profileTabBodyPadding` directly.

## Sliver Tab Body Gaps

For `NestedScrollView` + pinned tab rows:

- The outer header owns safe-area and pinned-row behavior.
- Each inner tab body starts with the required overlap injector.
- Body padding belongs to the tab body, not to the pinned tab row.
- If the tab body contains an independently scrollable child and the top gap
  must stay visible when that child returns to offset zero, put the gap inside
  the filled child.

Profile Preview currently follows the intended padding placement, but the
outer-header restoration from the preview card is still a known unresolved
sliver bug tracked as `PROFILE-001`.

## Card And Photo Insets

Profile cards use a deliberate split:

- Hero photo: full-bleed inside the card, with gradient/name overlay.
- Non-hero photos: inset with the same mobile side gutter rhythm and rounded
  corners so they look placed inside the immersive card rather than pasted to
  the edge.

Do not fork the Profile Preview card from the Swipes card to solve spacing
issues. Fix the shared `ProfileCard` / `ScrollableProfile` rendering path.

## Implementation Rule

Before adding a new padding value:

1. Check whether `CatchSpacing` already expresses it.
2. Check whether the screen already has a named inset constant.
3. If the value affects multiple sibling widgets or routes, name it and
   document it here.
4. If the value is one-off component tuning, keep it local and do not promote it
   prematurely.
