---
doc_id: ui_architecture
version: 1.2.1
updated: 2026-06-01
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
contracts. Feature screens should usually consume the semantic layer
(`CatchGaps`, `CatchInsets`, or layout primitives) rather than composing
`EdgeInsets` directly from primitive spacing tokens.

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

Use the semantic spacing layer for common relationships:

- `CatchGaps.inline` for tight icon/label or metadata pairs.
- `CatchGaps.related` for closely related rows inside one content cluster.
- `CatchGaps.formField` for standard control gaps inside a form group.
- `CatchGaps.section` for peer page sections.
- `CatchGaps.majorSection` for major page-region separation.

Use semantic inset contracts for repeated shells:

- `CatchInsets.pageBody` for default page or scroll-body padding.
- `CatchInsets.pageBodyRelaxed` when the scroll end needs extra breathing room.
- `CatchInsets.pageBodyTight`, `CatchInsets.pageBodyRelaxedTight`, and
  `CatchInsets.pageBodyUnderHeader` when local chrome or dense headers already
  provide some top separation.
- `CatchInsets.pageHeaderBody`, `CatchInsets.pageHeaderCompact`, and
  `CatchInsets.sectionHeader` for page intro rows and compact rail/list headers.
- `CatchInsets.pageHorizontal` and `CatchInsets.pageHorizontalWide` when a
  page/list owns only horizontal gutters.
- `CatchInsets.formStepBody` and `CatchInsets.formStepBodyRelaxed` for
  create/edit form steps.
- `CatchInsets.content*`, `CatchInsets.tile*`, `CatchInsets.listBody*`, and
  `CatchInsets.compactControlContent` for card, tile, list, pill, chip, and
  compact-control internals.
- `CatchInsets.chatBubble*` for message bubble content and sender-group
  spacing shared between live chat bubbles and generated share cards.

When sibling surfaces must align, define one named inset near the owning widget
or primitive and reuse it. Do not scatter equivalent anonymous `EdgeInsets`
across sibling tabs. If a new repeated role appears, add a semantic
`CatchInsets` member or a layout primitive before migrating call sites.

Current named contract outside the global semantic layer:
`profileTabBodyPadding` in `lib/user_profile/presentation/widgets/profile_tab.dart`
uses 20 px horizontal, 8 px top, and 32 px bottom for Profile Edit and Preview
tabs.

## Semantic UI Lints

Catch-owned UI rules use a local analyzer plugin package:
`packages/catch_ui_lints`. Do not add new `custom_lint` rules; that package is
archived and no longer the supported direction for Catch. New deterministic UI
invariants should be implemented as `analysis_server_plugin` rules so the IDE,
`dart analyze`, and `flutter analyze` all see the same diagnostics.

Rules should start from the broadest useful app surface, then earn exemptions
through semantic ownership. The current Catch UI lint scope is all handwritten
`lib/**` Dart except `lib/core/theme/**`, generated code, and schema-generated
contracts. Theme files are the source of raw token definitions; feature and
shared widget code should consume named `CatchSpacing`, `CatchLayout`,
`CatchGaps`, `CatchInsets`, `CatchRadius`, `CatchStroke`, and Catch control
primitives instead of local raw layout numbers or Material/Cupertino controls.

The first wide-pass rules block raw spacing numbers above a hairline, token
arithmetic outside theme constants, raw Material/Cupertino controls outside the
core widget primitives that wrap them, direct event-detail activity backdrops,
and adjacent semantic sections separated by manual `SizedBox` gaps.

For vertical composition of audited detail screens, prefer:

- `CatchPageBody`, `CatchFormStepBody`, or `CatchSliverPageBody` for semantic
  page/form insets when a screen has one body child or sliver.
- `CatchDetailSliverSectionList` for sliver-native page body insets and section
  gaps.
- `CatchSectionList` for adjacent semantic sections inside a single box widget.

Feature code that still writes `EdgeInsets.*(CatchSpacing...)` is surfaced by
`catch_prefer_semantic_insets` at info severity. Treat it as a migration queue:
use an existing `CatchInsets` role, a named local inset contract owned by the
component, or a layout primitive. Add a new semantic role when the existing
contracts would be semantically wrong.

The CI smoke checks are:

- `bash tool/check_riverpod_lint.sh`
- `bash tool/check_catch_ui_lints.sh`

Standard Flutter/Dart lints can support this layer, but they should not replace
Catch-owned analyzer plugin diagnostics for design-system invariants. The
current advisory lint set intentionally runs at info severity so cleanup volume
can be measured before any rule is escalated: `use_named_constants`,
`sized_box_shrink_expand`, `use_colored_box`, `use_decorated_box`,
`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, and
`avoid_redundant_argument_values`.

## Sizing & Constraints

Catch must scale seamlessly across phone sizes and Dynamic Type. **Prefer
constraints over constant dimensions.** Hardcoded heights/widths that wrap
content are the main cause of clipping at large text scales and of cramped or
stretched layouts on small/large devices.

This doctrine is enforced by **`tool/check_sizing.sh`** (wire into CI next to
`tool/check_data_contract.sh`). It flags fixed `height`/`width`/`dimension`
named args, fixed `Size(...)`, `BoxConstraints.tight*/expand`, and
dimension-like `const double` declarations — anywhere under `lib/` except the
design-system scale (`lib/core/theme/**`), generated code, and retired
sandboxes. A finding is cleared by **converting it** (below) or **annotating the
same line** `// sizing:allow: <reason>`.

### Constant dimensions are allowed ONLY for
- **Icon sizes** via `CatchIcon.{sm,md,lg}` (never a raw number).
- **Hairlines / dividers** (`1` px) and `0` — auto-exempt.
- **Spacing gaps** via `CatchSpacing` / `gapH*`/`gapW*` — never a raw
  `SizedBox(height: 24)`; write `SizedBox(height: CatchSpacing.s6)` or `gapH24`.
- **Radii** (`CatchRadius`), **border/stroke widths**.
- **Genuinely fixed art** (logo canvas, QR, platform-spec graphic) — keep and
  annotate `// sizing:allow: <reason>`.

Everything that sizes *content* uses constraints.

### Banned → preferred
| Instead of | Use |
|---|---|
| `SizedBox(height: 200, child: img)` (media) | `AspectRatio(aspectRatio: 16/10, child: img)` |
| `Container(height: 120, child: …)` (cap) | `ConstrainedBox(constraints: BoxConstraints(maxHeight: 120), …)` |
| Fixed row height that wraps text | let it size; add `ConstrainedBox(minHeight:)` only for a floor |
| Fixed-width sibling columns | `Expanded` / `Flexible` (in a Row) or `FractionallySizedBox` |
| `BoxConstraints.tightFor(height: X)` | min/max constraints, or `AspectRatio` |
| Full-bleed content on large screens | center the body in `ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)` |

Add **`CatchLayout.maxContentWidth`** (≈ 600) to `lib/core/theme/catch_tokens.dart`
as the content max-width clamp for large phones/foldables.

### Dynamic Type
Never fix the height of a text-bearing container. Use min-height + padding and
let text grow. Validate every screen at text scale **1.0 / 1.5 / 2.0** — no
clipping or overflow.

### Deterministic conversion algorithm
For each `tool/check_sizing.sh` finding, in order:
1. **Icon size?** → `CatchIcon.{sm,md,lg}`.
2. **Spacing gap** (`SizedBox` with no `child`)? → `CatchSpacing.*` / `gapH*`/`gapW*`.
3. **Media** (image/photo/backdrop)? → `AspectRatio`; drop the fixed height.
4. **Box that should fit its child?** → remove the fixed dim; let it size.
5. **Box that must cap size?** → `ConstrainedBox(maxHeight|maxWidth)`.
6. **Fixed-width sibling in a Row/Column?** → `Expanded` / `Flexible` / `FractionallySizedBox`.
7. **Page/content width on large screens?** → wrap body in
   `ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)`, centered.
8. **Genuinely fixed art?** → keep + `// sizing:allow: <reason>`.

After each change run `flutter analyze` and verify at text scale 1.0/1.5/2.0 in
light + dark. Repeat until `tool/check_sizing.sh` exits 0.

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
