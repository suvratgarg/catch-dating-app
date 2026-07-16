---
doc_id: app_architecture
version: 1.4.31
updated: 2026-07-16
owner: recursive_audit_loop
status: active
---

# Catch App Architecture

This is the canonical architecture spec for Catch's Flutter app code under
`lib/`. It defines feature structure, screen ownership, controller/view-model
boundaries, repository access, async state handling, error surfacing, widget
ownership, enforcement, and migration policy.

Use this document first when changing app architecture. It is the single active
home for controller, UI layout, and error architecture guidance. If a durable
rule belongs to app code organization, put it here. Keep only narrow generated
inventories, implementation plans, or domain-specific contracts elsewhere.

## Sources Consolidated

This spec consolidates and normalizes guidance from:

- `lib/README.md`: feature-first folder structure.
- `PROJECT_CONTEXT.md`: current product/route/code map.
- historical controller/view-model guidance: action, flow, async, view-model
  provider patterns, and realtime stream lifecycle.
- historical error architecture guidance: app error taxonomy, branded error
  surfaces, mutation errors, operation context, scanner policy, and global
  reporting.
- historical UI architecture guidance: screen padding, sliver/scroll ownership,
  token tiers, sizing rules, design-tool boundaries, and analyzer-plugin policy.
- `docs/widget_catalog.md`: widget ownership, primitive governance, public
  widget catalog, and private-helper remediation.
- `docs/audit_registry/rules.json`: active enforceable rules such as
  `ASYNC-UI-001`, `CONTROLLER-BOUNDARY-001`, `PROVIDER-SEAM-001`,
  `ERROR-UI-001`, `MUTATION-ERROR-SURFACE-001`,
  `EXTERNAL-SIDE-EFFECT-001`, `UI-LINT-001`, and
  `WIDGET-CATALOG-001`.

## Canonical Decisions And Overrides

This section is intentionally explicit so architecture decisions stay in one
place.

1. Keep the canonical feature folder shape as `domain`, `data`, and
   `presentation`. Do not rename `data` to `repositories`.

2. A data-using screen does not have to use `CatchAsyncValueView` directly.
   It does have to use a named async state boundary: `CatchAsyncValueView`,
   `CatchAsyncValueSliver`, or a feature-owned typed UI-state adapter.

3. Widgets should not read repository providers directly. Plugin, platform, and
   local side effects must go through a provider, controller, repository, or
   service seam with a test replacement path.

4. Do not ban `StatefulWidget`. Use it for Flutter mechanics. Use controllers
   or view models for durable product state, async data, mutations, validation
   that changes product behavior, repository calls, and cross-widget
   coordination.

5. Domain/use-case classes are optional, not ceremony. Use them when business
   logic is shared, complex, or independently testable. Do not create a use
   case for every button tap.

6. Loading, error, empty, skeleton, and tab-body widgets are not screens unless
   they are themselves route-level or major navigable surfaces.

7. The old project context names some pre-migration error files. The current
   error owner is this document; app-facing errors must use the
   `CatchErrorState` family, `CatchMutationErrorBanner`,
   `CatchMutationErrorListener(s)`, or `showCatchErrorSnackBar` as appropriate.

8. Private helper widgets are not an acceptable long-term destination for
   reusable UI. A widget must be public and catalogable, merged into a canonical
   primitive, or inlined/deleted. Tiny private `State<T>` classes and private
   implementation helpers are fine when they are not standalone render
   components.

## Architecture Doctrine

Catch uses feature-first architecture with unidirectional data flow.

The normal flow is:

```text
User input
  -> screen/widget callback
  -> controller or view-model command
  -> repository/service
  -> backend/platform/local source
  -> repository provider
  -> view model / typed UI state
  -> screen async boundary
  -> feature/core widgets
```

Each layer should have one clear job:

| Layer | Owns | Does not own |
|---|---|---|
| `domain` | Freezed models, enums, value objects, pure business rules, domain validators, deterministic projections | Flutter widgets, Riverpod providers, Firebase SDK calls, platform plugins |
| `data` | Repositories, Firebase adapters, local/platform services, data providers, normalization at backend/plugin boundaries | Screen layout, navigation widgets, feature UI copy decisions except mapped error copy owned by core error utilities |
| `presentation` | Screens, controllers, view models, typed UI state, feature widgets, form and interaction wiring | Raw Firebase calls, repository implementation details, cross-feature persistence rules |
| `core` | App shell, routing primitives, design tokens, shared widgets, error utilities, analytics/logging seams, cross-feature platform services | Feature-specific product policy unless it is genuinely global |

The rule is not "more layers are always better." The rule is "state and side
effects have one predictable owner."

## Feature Folder Contract

Most app features should use this shape:

```text
lib/<feature>/
  domain/
    <model>.dart
    <value_object>.dart
    <pure_policy>.dart
  data/
    <feature>_repository.dart
    <feature>_service.dart
    <feature>_providers.dart
  presentation/
    <surface>_screen.dart
    <surface>_controller.dart
    <surface>_view_model.dart
    <surface>_state.dart
    widgets/
      <surface>_<role>.dart
```

Small features do not need every file. A feature may have only a repository and
one screen if the behavior is simple. Large features may split by surface under
`presentation/`, but should keep route-level screens easy to find.

Files under `lib/**/presentation/**` ending in `_state.dart` are provider-free
display adapters by naming convention. They may depend on domain/core/value
types and `CatchAsyncState`, but they must not import Riverpod, declare
providers, or call `ref.watch/read/listen`; provider-owned composition belongs
in a neighboring `_view_model.dart`, `_controller.dart`, or route screen.

Allowed exceptions:

- `lib/core/**` for app-wide primitives, theme, shared widgets, global app
  shell, shared services, and error/logging infrastructure.
- `lib/routing/**` for GoRouter configuration and route-path constants.
- `lib/exceptions/**` for app exception and logging infrastructure.
- `lib/firebase_options_*.dart` and generated config files.
- Intentional in-development feature folders documented by audit rules, such
  as `event_policies` and `event_success`.

Do not create parallel top-level folders such as `services`, `repositories`,
`view_models`, or `widgets` for feature-owned code. If code is genuinely shared,
move it to a clear `core` owner or a domain-specific shared feature with a doc
entry.

### Current Boundary Cleanup Baseline

The first folder-boundary cleanup applied after this spec uses these owners:

- App analytics instrumentation lives in `lib/core/analytics`, not a top-level
  `lib/analytics` feature.
- Explore search lives under `lib/explore/data`; it is part of the Explore
  aggregate surface, not a standalone `search` feature.
- The calendar route lives under `lib/events/presentation/calendar` because it
  is an event agenda surface. Do not recreate top-level `lib/calendar`.
- Chat and host-inbox list UI lives under `lib/chats/presentation/inbox`.
  `lib/matches` remains responsible for match lifecycle data/domain behavior and
  match-specific presentation such as the celebration dialog.
- Event formatters, arrival policy, QR payloads, map links, calendar links,
  invite/share copy, and check-in location services live in `events/domain` or
  `events/data` according to whether they are pure logic or service seams.
  They should not be imported from `events/presentation`.
- Shared activity/event visual primitives used by core widgets live in
  `lib/core/widgets`, not under `events/presentation/widgets`.
- Club display-name lookup is a data/provider seam in `lib/clubs/data`.

## Dependency Direction

The allowed dependency direction is:

```text
presentation -> domain
presentation -> core
presentation -> own feature controller/view-model/state/widgets
presentation -> data only through approved provider/controller seams

data -> domain
data -> core backend/error/logging/config seams
data -> Firebase/platform/local APIs

domain -> Dart/Freezed/json helpers only
core -> lower-level platform/framework APIs and explicit feature-neutral types
```

Hard rules:

- `domain` must not import Flutter, Riverpod, Firebase, platform plugins, or
  feature presentation files.
- `data` must not import feature presentation files.
- `presentation/widgets/**` must not call repository methods or watch
  repository providers directly.
- Aligned adopters whose architecture-tracker role declares provider-free body
  or state behavior are machine-checked by
  `node tool/architecture/check_adopted_architecture_boundaries.mjs`; do not
  mark a file aligned/provider-free until routing and provider APIs have been
  lifted to the route/controller boundary.
- A route-level `*_screen.dart` may watch a feature view model or controller
  provider, and may watch mutation state for display. It should not reach
  around those seams into repositories.
- Cross-feature reads must go through a named provider/view-model/repository
  seam or an explicitly sanctioned presentation seam. Do not deep-import
  sibling feature presentation internals. Sanctioned presentation seams are:
  (a) a sibling feature's public controller (`presentation/*_controller.dart`)
  imported from a route-level `*_screen.dart` or another `*_controller.dart`;
  and (b) symbols exported by the sibling feature root barrel
  (`lib/<feature>/<feature>.dart`). Every feature-root barrel export of a
  `presentation/` file must carry a same-line or previous-line
  `// public-api:` annotation explaining why that symbol is public. Widgets,
  state adapters, domain files, data files, and arbitrary presentation helpers
  do not get the direct-controller-import carve-out.
- Firebase SDK types are not a domain contract. New domain files must stay pure
  Dart plus approved annotation/value packages. Firestore, Auth, Functions,
  Storage, Remote Config, App Check, and plugin-specific types belong in
  repository/data boundaries or feature-neutral adapter seams that keep those
  SDKs out of domain models and validators.
- Domain serialization that still needs Firestore `Timestamp` handling routes
  through `core/firestore_converters`. Existing direct Firebase imports in
  domain are ratcheted debt in
  `tool/architecture/dependency_direction_baseline.json`; new domain code must
  not add them. The long-term target is no Firebase API calls or Firebase types
  in domain signatures. Full DTO purity is not the target by default.
- Platform/plugin effects such as URL launch, share, image picker, location,
  calendar, clipboard, haptics, notifications, and connectivity need a seam
  that tests can replace.

Temporary exceptions require an override comment described in
`Enforcement And Overrides`.

## Provider Topology Graph

Riverpod topology is a checked source contract, not an inferred diagram kept by
hand. `tool/architecture/provider_graph.dart` parses handwritten Dart sources
and generates the complete provider, family, consumer, override, alias,
Mutation, and dependency inventory under `docs/generated/provider_graph/`.

Use these commands after adding, removing, renaming, or changing dependencies
of a provider:

```sh
dart run tool/architecture/provider_graph.dart --write
dart run tool/architecture/provider_graph.dart --check
```

`tool/architecture/provider_graph_reviews.json` owns explicit decisions for
cross-feature edges, high-fan-out providers, aliases, and intentional manual
provider exceptions. The check rejects stale generated artifacts, dangling or
duplicate provider nodes, unresolved internal references, reactive cycles,
unreviewed candidates, and stale review decisions. Feature-owned async
providers should follow the generated family reference in
`ARCH-PROVIDER-CODEGEN-001`; manual providers require an exact reviewed
exception rather than an implicit allowlist.

## Screen Definition

A screen is a route-level or major navigable surface. A screen file normally
ends in `_screen.dart`.

A `FeatureScreen` owns:

- route parameters and route `extra` parsing;
- `Scaffold`, `SafeArea`, app bars, tab/page shell, and bottom docks;
- the screen-level padding contract;
- the single vertical scroll owner when the surface scrolls;
- the top-level async boundary for initial data, unless the screen is static;
- screen-level mutation listeners for transient action failures;
- retry invalidation for the provider/view model that failed;
- navigation callbacks and route exits;
- deciding which feature body/state widget is shown.

A `FeatureScreen` should not own:

- repository calls;
- backend/platform side effects;
- product-significant validation;
- mutation orchestration;
- per-section rendering details;
- repeated row/card/control layout.

These are not screens by default:

- loading widgets;
- error widgets;
- empty states;
- skeleton states;
- tab bodies that are mounted inside one route;
- section bodies, cards, rows, forms, slivers, rails, and bottom sheets;
- feature widgets that can be rendered inside more than one screen.

They should live under `presentation/widgets/` or `core/widgets/` depending on
ownership.

## Screen Composition Contract

Screen composition should be predictable:

```text
<Feature>Screen
  -> mutation listener(s), if actions can fail transiently
  -> Scaffold / SafeArea / route chrome
  -> one scroll owner or one body shell
  -> CatchAsyncValueView / CatchAsyncValueSliver / typed UI-state adapter
  -> <Feature>Body / sliver body / state-specific widgets
  -> feature widgets and core primitives
```

Screen-level padding belongs at the screen/body boundary, not scattered across
unrelated child widgets. Use `CatchInsets`, `CatchGaps`, `CatchPageBody`,
`CatchSliverPageBody`, `CatchSectionList`, `CatchDetailSliverSectionList`, and
other semantic layout primitives described below.

If a parent owns a `CustomScrollView`, async loading/error/empty/data branches
should usually be sliver-native. Box widgets can still be used at composition
boundaries through `SliverToBoxAdapter`, but growing repeated content should use
lazy slivers.

## App Shell Chrome Policy

The consumer and host tab shells own bottom tab chrome only for tab-root
screens. Branch child routes that own their own route chrome or bottom affordance
must set `parentNavigatorKey: _rootNavigatorKey` in `lib/routing/go_router.dart`
so detail CTAs, chat composers, and full-screen actions are not rendered under
the floating tab bar.

Bottom sheets must be opened through `showCatchBottomSheet` from
`lib/core/widgets/catch_bottom_sheet.dart`. The helper presents on the root
navigator by default, which keeps drawers above shell chrome. Do not call
Flutter's raw `showModalBottomSheet` directly from production code unless this
policy test is intentionally updated.

Tab-root overlays that still coexist with the floating tab bar should use
`AppShellActiveTab.bottomOverlayClearanceOf(context, minimum: ...)`; feature
code should not recompute the tab-bar height, safe-area subtraction, or platform
floating inset. Root scroll views without tab chrome should end with a semantic
terminal sliver such as `CatchSliverTerminalPadding` instead of hard-coded
bottom spacers. When a route uses this terminal sliver inside a `SafeArea`, the
screen-level `SafeArea` must leave `bottom: false` so the device bottom inset
remains visible to the sliver and becomes scrollable clearance.

Software-keyboard visibility is defined by `MediaQuery.viewInsets.bottom > 0`,
not by focus. While that inset is nonzero, both `AppShell` and `HostAppShell`
omit authenticated navigation, the consumer shell also omits its guest auth
CTA, floating `extendBody` behavior is disabled, and
`AppShellActiveTab.bottomOverlayInset` is zero. Floating shells keep the route
body in the same stack position while removing only the navigation sibling, so
the focused editable element, text, cursor selection, and keyboard connection
survive the inset transition. A hardware keyboard leaves `viewInsets.bottom`
at zero, so navigation remains available.

## Layout, Spacing, And UI Architecture

Use `CatchSpacing` from `lib/core/theme/catch_tokens.dart` for reusable layout
contracts. Feature screens should usually consume the semantic layer
(`CatchGaps`, `CatchInsets`, or layout primitives) rather than composing
anonymous `EdgeInsets` from primitive spacing tokens.

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

Use semantic gaps for common relationships:

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

### Token Tier Model

Use the lowest tier that preserves intent, and move repeated feature-local
roles upward only when they recur.

| Tier | Owner | Examples | Use when |
|---|---|---|---|
| Primitive scale | `lib/core/theme/catch_tokens.dart` | `CatchSpacing`, `CatchRadius`, `CatchStroke`, `CatchMotion`, `CatchOpacity`, `CatchIcon` | A reusable value is part of the global visual scale. |
| Semantic layout role | `lib/core/theme/catch_tokens.dart` or a shared primitive | `CatchGaps.section`, `CatchInsets.pageBody`, `CatchLayout.maxContentWidth` | A value describes a repeated relationship or viewport/content contract. |
| Expressive palette role | `ActivityPalette` / `CatchTokens` theme extensions | activity swatches, functional status colors, photo grade overlays | Color communicates activity, state, or theme meaning rather than decoration. |
| Component contract | Owning component or primitive | profile tab body padding, ticket geometry, control shell sizing | A value is tied to one component family and should not become a global token yet. |
| Sanctioned art | Painter/canvas owner with a narrow comment | graded image grain, activity artwork, map-pin canvas colors pending policy | Raw values are part of deliberate illustration/canvas output and are not layout tokens. |

Do not add a new token namespace just because one raw value exists. Add a
primitive token when the value belongs to the global scale; add a semantic role
when the value names a repeated relationship; keep one-off component geometry in
the component until reuse is real.

`CatchBreakpoints` remains rejected for now. Whole-window responsive classes
already live in `ScreenSize`, while local component reflow thresholds live in
`ComponentBreakpoints`; collapsing those into the design-token namespace would
blur window and component ownership. `CatchLayout` remains appropriate for
content clamps such as `maxContentWidth`.

`CatchZIndex` also remains rejected for now. Current Flutter stacking behavior
is owned by widget order, overlays, navigators, and route/sheet primitives
rather than repeated numeric z-index values. Introduce a named stacking
contract only after two or more surfaces need the same explicit layer ordering.

### Sizing And Constraints

Catch must scale across phone sizes and Dynamic Type. Prefer constraints over
constant dimensions. Hardcoded heights/widths that wrap content are the main
cause of clipping at large text scales and cramped or stretched layouts.

`tool/check_sizing.sh` flags fixed `height`/`width`/`dimension` named args,
fixed `Size(...)`, `BoxConstraints.tight*/expand`, and dimension-like
`const double` declarations under `lib/`, except the design-system scale,
generated code, and retired sandboxes. A finding is cleared by converting it or
annotating the same line:

```dart
// sizing:allow: <reason>
```

Constant dimensions are allowed only for:

- icon sizes through `CatchIcon.{sm,md,lg}`;
- hairlines/dividers (`1` px) and `0`;
- spacing gaps through `CatchSpacing` or `gapH*`/`gapW*`;
- radii, border widths, and stroke widths through named tokens;
- genuinely fixed art such as logo canvases, QR codes, or platform-spec
  graphics, with `sizing:allow`.

Banned-to-preferred conversions:

| Instead of | Use |
|---|---|
| `SizedBox(height: 200, child: img)` | `AspectRatio(aspectRatio: 16 / 10, child: img)` |
| `Container(height: 120, child: ...)` | `ConstrainedBox(constraints: BoxConstraints(maxHeight: 120), ...)` |
| fixed row height around text | let it size; add min-height only for a floor |
| fixed-width sibling columns | `Expanded`, `Flexible`, or `FractionallySizedBox` |
| `BoxConstraints.tightFor(height: x)` | min/max constraints or `AspectRatio` |
| full-bleed content on large screens | centered `ConstrainedBox(maxWidth: CatchLayout.maxContentWidth)` |

Never fix the height of a text-bearing container. Use min-height plus padding
and let text grow. Validate important screens at text scale 1.0, 1.5, and 2.0.

### Scroll Ownership

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

Sliver rules:

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

### Nested Tab Screens

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
- Expandable fields reuse the nearest existing vertical scroll position. A tab
  body that sits behind shell chrome publishes the obstruction through
  `CatchFieldVisibilityScope` and supplies enough terminal scroll extent for its
  final field to clear that chrome. `CatchField` drives the chosen position
  frame by frame with the same duration and curve as the disclosure geometry so
  newly available extent is consumed without an end snap. Rapid close cancels
  the drive, direct user scrolling wins, reduced motion jumps immediately, and
  a zero-duration final correction covers any residual clamp. Do not add a
  second `ScrollController` inside the `NestedScrollView` to implement this.

### Current Screen Layout Decisions

| Surface | Direction |
|---|---|
| Home dashboard | Keep one `CustomScrollView` with `CatchSliverHeader(title: CatchScreenHeaderTitle.block(...))`; do not reintroduce Dashboard/Activity tabs without a product decision. |
| Explore | Keep sliver-native. This remains the strongest mixed event/club discovery pattern. |
| Chats list | Keep sliver shell; make populated body sliver-native only if list scale or tests demand it. |
| Event detail | Keep sliver-native because the collapsing hero justifies it. |
| Club detail | Keep sliver-native with agenda-style event list. |
| User profile | Keep the tested `ProfileTabScrollView` contract: preserve overlap injection and the preview-card scroll bridge, while only the Edit tab publishes field obstruction and terminal clearance for expanding field actions. |
| Map-heavy screens | Audit before migrating. Stable map viewport may matter more than sliver composition. |
| Attendance sheet | Keep box-based while it remains a modal/sheet. |
| Create event, onboarding, auth | Do not migrate just for consistency. |

### Design Tooling And Component Contracts

Catch's UI system has separate sources of truth by layer:

| Layer | Source of truth | Mirrors / consumers |
|---|---|---|
| Primitive token values | `design/tokens/catch.tokens.json` | Flutter generated tokens, website CSS, Figma variables, Claude/Figma context packs |
| Flutter widget behavior | `lib/core/widgets/catch_*.dart` | Component contracts, goldens/captures, Figma Code Connect snippets |
| Cross-tool component API | `design/components/catch.components.json` | Claude handoff rules, Figma component mappings, Code Connect templates, future registry docs |
| Screen composition | Feature Flutter code | UI captures, gallery screenshots, design review packs |

Design tools may propose screen structure, but production code should be built
from registered `Catch*` primitives or explicit deltas to the registry. Treat
arbitrary JSX/CSS exports as visual proposal material, not implementation
source. A handoff is implementation-ready only when it names component contract
ids, props, slots, and any missing primitive/token deltas.

Style Dictionary is a candidate token transformation engine, not a component
translator. Keep `dart run tool/design_tokens.dart` as the production generator
until a spike proves generated Dart/CSS equivalence, custom gradient/semantic
formats, deterministic `--check`, and real Figma/Tokens Studio value. Component
contracts remain separate; no Style Dictionary output is widget implementation.

Validate the component registry with:

```sh
node tool/design/check_component_contracts.mjs
```

### UI Analyzer Lint Policy

Catch-owned UI rules use the local analyzer plugin package
`packages/catch_ui_lints`. Do not add new `custom_lint` rules. Deterministic
UI invariants should be implemented as `analysis_server_plugin` diagnostics so
the IDE, `dart analyze`, and `flutter analyze` see the same signal.

The current lint scope is all handwritten `lib/**` Dart except
`lib/core/theme/**`, generated code, and schema-generated contracts. Theme files
are the source of raw token definitions; feature/shared widget code consumes
named `CatchSpacing`, `CatchLayout`, `CatchGaps`, `CatchInsets`, `CatchRadius`,
`CatchStroke`, and Catch control primitives instead of local raw layout numbers
or Material/Cupertino controls.

Implemented diagnostics include raw spacing, token arithmetic, section-list
composition, semantic inset preference, event-detail photo thumbnail preference,
raw Material control use, raw color/text/font/radius/content dimension/local
design constants/icon source/icon size/alpha/shadow/motion/breakpoint/surface
shell/stroke/asset path, icon-button tooltip requirements, allow-debt blocking,
and widget-returning method blocking.

Verification commands:

```sh
bash tool/check_catch_ui_lints.sh
bash tool/check_catch_ui_lint_drift.sh --count
bash tool/check_catch_ui_lint_drift.sh --all --json /private/tmp/catch-ui-lint-drift.json
bash tool/check_sizing.sh --count
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_system_raw_values.sh --count
bash tool/check_ui_allow_debt.sh --summary
flutter analyze --no-fatal-infos
```

## Async State Boundary Taxonomy

Every async state needs a named boundary. The boundary can be generic or
feature-specific, but it must be obvious to a reader where loading, error,
empty, retry, stale data, and mutation failure are handled.

| State category | Owner | UI primitive or pattern |
|---|---|---|
| Full-screen initial load | Screen | `CatchAsyncValueView`, `CatchErrorScaffold`, or typed screen-state adapter |
| Sliver initial load | Screen/sliver body | `CatchAsyncValueSliver`, `CatchSliverErrorState`, or typed sliver adapter |
| Section-level load | Section widget or view model | `CatchInlineErrorState`, section skeleton, section retry |
| Empty success | Screen/body/section | `CatchEmptyState` or domain-specific empty widget, never an error primitive |
| Mutation/action pending | Controller mutation + UI affordance | disabled control, spinner, optimistic state when intentional |
| Mutation/action failure | Screen or section | `CatchMutationErrorBanner`, `CatchMutationErrorListener(s)`, or `showCatchErrorSnackBar` |
| Form validation | Form/controller/domain validator | field error text or inline form banner |
| Optional enrichment failure | Repository/view model | keep primary UI alive, log through error context when useful |
| Platform/plugin failure | Service/repository/controller seam | typed app error, snackbar/banner if user action failed |
| Framework/runtime failure | Global handlers | `FlutterError.onError`, `PlatformDispatcher.instance.onError`, `CatchFrameworkErrorView` |

Use `CatchAsyncValueView` for simple body screens with one async value.

Use `CatchAsyncValueSliver` for simple sliver surfaces.

Use a feature-owned typed UI state when a screen has richer behavior, such as:

- partial secondary failures;
- stale cached data while refreshing;
- optimistic updates;
- separate section loading states;
- mixed permissions/auth/data outcomes;
- complex empty-state decisions;
- several repositories combined into one screen state;
- retry behavior that differs by section.

The typed state should still expose explicit loading/error/data semantics. Do
not hide `AsyncError` by calling `requireValue` or by converting failures into
empty states.

## Error Handling Contract

This section is the current error architecture contract. Historical migration
counts and old pass notes remain in git and audit history; active guidance lives
here.

### Current Error Surface Model

The error primitive family separates visual content, placement adapters, and
delivery channels:

- `CatchErrorState` owns app-facing branded error content through one resolved
  descriptor and one shared body renderer.
- `CatchErrorScaffold`, `CatchSliverErrorState`, and `CatchInlineErrorState`
  are placement adapters for root, sliver, and section errors.
- `CatchErrorBanner` is the persistent inline mutation/form error channel.
- `CatchMutationErrorBanner` is the persistent Riverpod mutation adapter.
- `CatchMutationErrorListener` and `CatchMutationErrorListeners` are transient
  snackbar boundaries for one or many mutations.
- `showCatchErrorSnackBar` is the canonical transient action failure surface.
- `CatchFrameworkErrorView` is separate and only for `ErrorWidget.builder` /
  framework build/render crashes.

Do not reintroduce `CatchErrorText`, raw `Center(Text(error.toString()))`,
raw vendor messages, or bespoke error cards that discard retry/error context.

### Failure Channels

A first-class Catch error system covers these channels:

| Channel | Examples | Required handling |
|---|---|---|
| Firebase backend services | Firestore, Auth, Functions, Storage, Messaging, Remote Config, App Check | Normalize vendor exceptions once at the boundary, preserve non-PII operation context, map to `AppException`, log/report with stable codes. |
| Platform/plugin side effects | Share sheet, URL launcher, image picker, location, device permissions, app-store launches | Put behind provider/service seams, normalize expected plugin failures, treat user cancellation as low severity, log unexpected plugin bugs. |
| Frontend validation and parsing | Form input, local draft JSON, route/deep-link params, profile/event fields, date/number parsing | Convert user-correctable failures into `ValidationException` or typed local exceptions before raw UI. |
| Domain/business rejections | Sign-in required, permission denied, already joined, not eligible, payment cancelled/failed, booking rejected | Use typed `AppException` subclasses only when code, retry policy, analytics, or tests need stable branching. |
| Controller/mutation failures | Riverpod mutations, multi-step flow mutations, callback-completer APIs | Let typed errors propagate to mutation state; add action context where the repository boundary cannot explain the failure. |
| Provider/load failures | `FutureProvider`, `StreamProvider`, cached/stale refresh, empty vs error states | Render through the `CatchErrorState` family, preserve retry actions, and log provider errors centrally. |
| Flutter framework failures | Build/layout/render exceptions, `ErrorWidget.builder` fallback | Keep minimal `CatchFrameworkErrorView`; report through global hooks; do not try to run normal app UI in an unstable build tree. |
| Uncaught asynchronous failures | Timers, plugin callbacks, unawaited futures, platform dispatcher errors | Wire `PlatformDispatcher.instance.onError`, pass to `ErrorLogger`, report fatal/nonfatal according to severity. |
| Unexpected programmer bugs | Bad state, invalid arguments, invariant violations, null/schema mismatch | Do not show raw details to users. Log/report with stack trace, show generic app copy, and turn recurring user-correctable instances into typed exceptions. |
| Operational/release signals | Crashlytics, Analytics, console fallback, emulator tests, dashboards, alerts | Attach useful non-PII keys/logs; smoke-test reporting in release-like builds. |

The goal is not "catch everything everywhere." The goal is:

1. Expected failures are typed, user-safe, retry-aware, and testable.
2. Unexpected failures retain stack traces and enough context to diagnose.
3. Every app-facing surface gets a branded error primitive.
4. Every caught error is displayed, rethrown as a typed app error,
   reported/logged, or intentionally documented as silent/noisy.
5. Product-significant expected failures can appear in analytics without
   polluting Crashlytics as crashes.

### Boundary Classification

Classify low-level errors at the closest stable boundary:

| Boundary | Preferred API | Notes |
|---|---|---|
| Firebase/backend repository call | `withBackendErrorContext` / `withBackendErrorStream` | Correct transport wrapper for backend calls. |
| Non-backend app operation | `withAppErrorContext` / `normalizeAppError` | Use for local, platform, validation, parsing, and controller-owned failures. |
| Fire-and-forget local work | `runLoggingAppErrors` / `logAppError` | Replacement for bare `catch (_) {}` when the app legitimately continues. |
| Form field validation | `FormField` validators plus reusable domain validators | Use inline field errors for simple per-field validation; throw only when async flow or shared business logic needs an exception. |
| Domain guard | `requireSignedInUid`, eligibility guards, action cardinality checks | Throw typed `AppException` when UI can recover or message the user. |
| Provider/load state | Riverpod `AsyncValue` | Preserve `error` and `stackTrace`; render with descriptor primitives. |
| Framework/global runtime | `FlutterError.onError`, `ErrorWidget.builder`, `PlatformDispatcher.instance.onError` | Report globally; avoid feature-level copy because the app tree may be compromised. |

Presentation `AppErrorContext` and operation context answer different questions.
Presentation context is where the error is shown. Operation context is what the
app was trying to do. Do not put PII in either.

### App Operation Context API

`lib/core/app_error_context.dart` is the non-backend parallel to
`BackendErrorContext`. It adapts to the backend normalizer/logging shape so the
whole app keeps one context and reporting model.

| Symbol | Shape | Use for |
|---|---|---|
| `AppOperation` | `validation`, `localPersistence`, `navigation`, `plugin`, `ui`, `runtime` | Tags the failure category. `plugin` logs under external service; the rest under local service. |
| `AppErrorContext` | `{operation, action, resource?, metadata}` | Low-cardinality, non-PII operation context. |
| `normalizeAppError(error, context, mapper?)` | `AppException` | Normalizes local/plugin errors and can promote user-correctable input to `ValidationException`. |
| `withAppErrorContext(op, context, mapper?)` | `Future<T>` | Wraps plugin/local async work so thrown errors become typed app exceptions. |
| `runLoggingAppErrors(op, context, logError, mapper?)` | `Future<bool>` | Runs best-effort work, logs normalized failure, returns `false`. |
| `logAppError(error, context, logError, mapper?)` | `void` | Normalizes and records a caught error when the operation legitimately continues. |

Privacy rules: never put user IDs, phone numbers, file names, message text,
bios, photo URLs, exact coordinates, payment ids, or raw document ids into
`action`, `resource`, or `metadata`.

### Exception Taxonomy

Use `AppException` subclasses only for stable product/domain concepts that need
branching, analytics, retry policy, audit value, or tests. Use mapped copy for
one-off wording.

| Family | Examples | Target handling |
|---|---|---|
| Auth/session | signed out, expired credential, auth provider disabled, throttled OTP | `SignInRequiredException`, Auth mapper, `ValidationException`, `NetworkException`. |
| Network/backend | offline, timeout, rate limit, permission denied, not found, backend unknown | `NetworkException`, `PermissionException`, `DocumentNotFoundException`, `BackendOperationException`. |
| Storage/media | upload cancelled, file missing, unauthorized, retry limit, invalid file | `StorageException` plus feature-specific mappers when needed. |
| Payments/booking | checkout cancelled, payment failed, verification failed, booking rejected | Payment/booking exceptions with support-oriented reporting and nonfatal severity. |
| Validation/forms | invalid name, date, phone, age, height, route params, local payload | Inline validators or `ValidationException` for shared/async failures. |
| Local persistence/cache | corrupt draft, unsupported schema, local write/read failure | Local operation context plus typed/mapped exception when user-facing. |
| Navigation/deep links | malformed link, missing route id, inaccessible target, stale invite | Typed route/deep-link failure if user-facing; otherwise logged unexpected bug. |
| Location/permissions | denied, permanently denied, service disabled, unavailable | Permission/location exception or mapper; retry/settings copy where useful. |
| External actions | share failed, URL launch failed, store link failed, picker failure | `ExternalActionException` or mapper through app operation context. |
| Programmer bugs | `StateError`, `ArgumentError`, assertion, schema invariant | Bugs unless user can correct the condition. Never show raw details. |
| User cancellation | picker/upload/payment cancelled | Usually low severity and often no error surface; must be explicit. |

### Descriptor And UI Contract

Every app-facing error ends in one descriptor contract:

```text
Object error + presentation AppErrorContext
  -> appErrorDescriptor
     -> title
     -> message
     -> severity
     -> retryable
     -> retryLabel
     -> icon
     -> support/report affordance when needed
```

Surface rules:

| Surface | Use when | Required behavior |
|---|---|---|
| `CatchErrorScaffold` | Root screen/tab cannot load | Title/message/retry from descriptor; never raw exception text. |
| `CatchSliverErrorState` | Sliver-native load failure | Same descriptor, sliver-compatible layout. |
| `CatchInlineErrorState` | Section/card-level failure | Compact descriptor copy and retry when retryable. |
| `CatchErrorBanner.fromError` / `CatchMutationErrorBanner` | Persistent form/mutation failure | No retry unless action exists; avoid duplicating field validation. |
| `showCatchErrorSnackBar` | Transient action failure | Descriptor message and retry action if the failed action can safely rerun. |
| Field validation error | Per-field invalid input | Specific field copy, not snackbar or generic exception. |
| `CatchFrameworkErrorView` | Flutter build/render failure | Minimal fallback; diagnostic details only in debug/reporting. |
| Empty state | Successful load with zero items | Never use an error primitive for empty data. |

Rules:

- Repositories wrap Firebase/backend operations with
  `withBackendErrorContext` or `withBackendErrorStream`.
- Local, validation, platform, and plugin operations use the app operation
  context APIs from `lib/core/app_error_context.dart` when they can fail outside
  backend wrappers.
- Controllers usually do not catch repository errors. Let typed errors
  propagate through Riverpod `AsyncValue` or `Mutation` state. Catch only when
  adding useful domain context, rollback, or alternate behavior.
- UI never shows raw `error.toString()`, raw Firebase messages, stack traces,
  or vendor/plugin objects.
- Full-screen data errors use `CatchErrorScaffold` or `CatchErrorState`.
- Sliver data errors use `CatchSliverErrorState`.
- Section errors use `CatchInlineErrorState`.
- Persistent mutation/form failures use `CatchErrorBanner.fromError` or
  `CatchMutationErrorBanner`.
- Transient action failures use `CatchMutationErrorListener(s)` or
  `showCatchErrorSnackBar`.
- Flutter framework/build/layout crashes use `CatchFrameworkErrorView`, not the
  normal app-facing error family.
- Empty state means successful data load with zero items. It is not an error
  fallback.

Every mutation watched for `isPending` must also surface `hasError`. Mutation
objects should use the same grain as the action cardinality contract: one
visible action plus one scope key maps to one pending/error surface. Do not use
one screen-wide mutation to drive several CTAs with different scope keys, and do
not split one singleton action into multiple independent mutation objects unless
the UI still renders one resulting state.

### Controller And Mutation Errors

Controllers usually delegate to repositories and let errors propagate through
Riverpod `Mutation` state:

```dart
Future<void> joinWaitlist({required Event event}) async {
  final uid = requireSignedInUid(ref, action: 'join a waitlist');
  await ref
      .read(eventRepositoryProvider)
      .joinWaitlistViaFunction(eventId: event.id, uid: uid);
}
```

The UI watches and surfaces the mutation:

```dart
final joinMutation = ref.watch(EventBookingController.joinMutation);
return Column(
  children: [
    if (joinMutation.hasError)
      CatchMutationErrorBanner(mutation: joinMutation),
    CatchButton(
      isLoading: joinMutation.isPending,
      onPressed: () => Mutation.run(
        ref,
        (tx) => tx.get(eventBookingControllerProvider.notifier).joinWaitlist(),
      ),
    ),
  ],
);
```

For transient errors, wrap the screen or section:

```dart
CatchMutationErrorListener(
  mutation: EventBookingController.joinMutation,
  errorContext: AppErrorContext.events,
  child: EventDetailBody(...),
);
```

Use try/catch in controllers only for adding useful context, rollback, converting
callback APIs to futures, or intentionally continuing after a logged local
failure. Do not catch only to show UI from a controller.

### Logging And Telemetry

Current reporting path:

```text
Error thrown
  -> AsyncErrorLogger ProviderObserver
       -> AppException: warning-level/logged expected app failure
       -> BackendOperationException: optional backend_operation_failed analytics
       -> Other: ErrorLogger.logError -> Crashlytics in production release
  -> FlutterError.onError -> ErrorLogger.logFlutterError
  -> PlatformDispatcher.instance.onError -> ErrorLogger.logError
  -> explicit logAppError/runLoggingAppErrors for best-effort local/plugin work
```

Crash/reporting should be useful, not noisy:

| Event type | User display | Crashlytics | Analytics | Notes |
|---|---|---|---|---|
| Expected validation/auth/permission | User-safe copy | Usually no crash issue | Yes when product-significant | Avoid alert fatigue. |
| Expected retryable backend/network | Retry copy | Nonfatal only if repeated/high impact | Yes with service/action/code/retryable | Prefer aggregated analytics. |
| User cancellation | Usually no error or low-key copy | No | Usually no | Cancellation is not failure unless product says so. |
| Payment/booking verification failure | Support-oriented copy | Nonfatal with context | Yes | High business impact but not necessarily crash. |
| Unexpected exception/bug | Generic user copy | Yes with stack trace | Optional | Must retain stack and operation context. |
| Framework/global uncaught fatal | Fallback or app crash | Fatal | Optional | Covered by FlutterError/PlatformDispatcher. |

Use stable, low-cardinality keys: `app_env`, `app_version`, platform, Firebase
project alias, `error_family`, stable code, severity, retryable, expected,
service, feature, action, resource, and presentation context. Do not log PII.

### Privacy And Safety

- Never show raw `FirebaseException.message`, stack traces, callable details, or
  plugin object dumps to normal users.
- Error UI copy must not append debug diagnostics, even in debug builds.
- Developer details belong in `ErrorLogger`, Crashlytics, analytics metadata,
  backend logs, and the Flutter console.
- Never log PII in error metadata: names, phone numbers, exact birth dates,
  chat/message text, profile bio, photo URLs, precise locations, payment ids or
  signatures, and sensitive document ids.
- Preserve original cause and stack trace for developer diagnosis.
- Treat security-rule denials as product/security signals, not generic retry
  failures unless retry can actually succeed after user action.

### Error Scanners

Run the backend scanner before backend error work:

```sh
dart tool/audit/backend_error_candidates.dart
```

Run the frontend/local scanner before frontend/local/plugin error work:

```sh
dart tool/audit/frontend_error_candidates.dart
dart tool/audit/frontend_error_candidates.dart --check
```

Both scanners use stable buckets: `mustMigrate`, `review`, `verified`,
`intentional`, `fixture`, and `migrated`. `mustMigrate` and `review` should stay
at zero. The frontend check uses
`tool/audit/frontend_error_candidates_baseline.json` as a temporary ratchet for
reviewed legacy candidates, so new unbaselined `review` or `mustMigrate`
findings fail without requiring unrelated Flutter edits in the same pass. The
scanner is not proof by itself; it gives a single source of truth for what still
needs migration and what was intentionally retained.

Candidate patterns:

- bare `catch (_)`, empty catch, `.catchError` without logging/rethrow;
- `debugPrint`, raw `SnackBar`, or `Text(e.toString())` for errors;
- raw `StateError`, `ArgumentError`, `Exception`, or thrown strings;
- `AsyncValue(error:)` branches not using descriptor primitives;
- casual `requireValue` in widgets/providers;
- `Timer`, subscription, callback, unawaited future, or plugin futures;
- `jsonDecode`, local storage reads, route/deep-link parsing;
- `url_launcher`, share, image picker, geolocator, permission handlers;
- raw Firebase/Auth/Functions/Storage messages in UI;
- global handlers (`FlutterError`, `ErrorWidget.builder`, platform dispatcher);
- test fakes and fixtures for classification.

### Error Quick Reference

| Concern | File |
|---|---|
| Exception types | `lib/exceptions/app_exception.dart` |
| Backend error wrapping | `lib/core/backend_error_util.dart` |
| Frontend/local op context | `lib/core/app_error_context.dart` |
| User-facing backend messages | `lib/core/backend_error_message.dart` |
| UI-facing title/message facade | `lib/core/app_error_message.dart` |
| Central error logger and `AsyncErrorLogger` | `lib/exceptions/error_logger.dart` |
| Analytics error events | `lib/core/analytics/app_analytics.dart` |
| Backend scanner | `tool/audit/backend_error_candidates.dart` |
| Frontend scanner | `tool/audit/frontend_error_candidates.dart` |
| Branded error surfaces | `lib/core/widgets/catch_error_state.dart` |
| Branded error snackbar | `lib/core/widgets/catch_error_snackbar.dart` |
| Error banner | `lib/core/widgets/catch_error_banner.dart` |
| Mutation helpers | `lib/core/widgets/mutation_error_util.dart` |
| Mutation snackbar listener | `lib/core/widgets/catch_mutation_error_listener.dart` |
| Global error handlers | `lib/main.dart` |

## Controller And View-Model Contract

Controllers and view models live in `presentation` because they shape UI-facing
application behavior. They are not widgets, and they are not repositories.

Use the smallest controller pattern that owns the lifecycle correctly:

| Pattern | Use for | Typical Riverpod shape |
|---|---|---|
| Action controller | one-shot actions such as book, cancel, join, submit, delete, block, report, sign out | generated notifier with `Mutation` |
| Flow controller | multi-step flows whose state survives navigation inside the flow | generated notifier with immutable state |
| Async state controller | loaded state that is then mutated by user actions | `AsyncNotifier<T>` |
| View-model provider | read-only composition of repository streams/futures into screen-ready state | generated function provider |
| Domain/use-case class | shared or complex business logic independent of Flutter | pure Dart class/function |

Mutation key grain must match the UI interaction grain. Route-level single
actions such as book, cancel, submit, and delete for the route's single subject
may use static `Mutation` fields. Repeated row or list actions such as
attendance, waitlist offers, join-request decisions, or any per-entity action
rendered multiple times on one surface must key mutation state per target with
`mutation(key)` family instances. Keys are typed Dart records with value
equality, not concatenated strings. Use
`lib/hosts/presentation/host_event_booking_controller.dart` as the reference
implementation.

### Action Controller

Use a stateless generated notifier for one-shot user actions.

```dart
@riverpod
class ExampleController extends _$ExampleController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit() async {
    final uid = requireSignedInUid(ref, action: 'submit');
    await ref.read(exampleRepositoryProvider).submit(uid: uid);
  }
}
```

Use for book, cancel, join, leave, submit, delete, block, report, sign-out, and
other user-triggered actions. UI should call `Mutation.run(ref, ...)` so
Riverpod keeps provider dependencies alive while the side effect is running.

### Flow Controller

Use a generated notifier with immutable state for multi-step flows or screens
whose state is more than a single local input.

```dart
@Riverpod(keepAlive: true)
class ExampleFlowController extends _$ExampleFlowController {
  static final completeMutation = Mutation<void>();

  @override
  ExampleFlowState build() => const ExampleFlowState();
}
```

Use for auth, onboarding, or future wizards where state must survive navigation
inside the flow. Prefer auto-dispose unless the flow must survive route/tab
changes. If `keepAlive` is used, reset or invalidate state on completion,
sign-out, or cancellation.

### Async State Controller

Use `AsyncNotifier<T>` when state is loaded asynchronously and then mutated by
user actions. Good fits include queues, async local caches, paged lists, and
screens where the controller owns both loaded state and mutation methods.

### View-Model Provider

Use a pure generated function provider to combine repository streams/futures
into a read-only view model.

Good fit:

- one screen needs one `.when(loading:error:data:)` value from several async
  dependencies;
- data should be reshaped into screen-ready sections;
- widgets would otherwise read several repositories directly;
- the provider can stay side-effect free.

View-model providers can depend on repositories. Widgets should depend on the
view model.

Controllers own:

- repository calls needed by the screen or flow;
- mutation orchestration;
- product validation decisions;
- action cardinality and eligibility checks when not backend-owned;
- combining multiple providers into one screen-ready state;
- optimistic updates and rollback policy;
- retry invalidation targets;
- app/domain exceptions thrown for user-correctable failures.

Controllers do not own:

- raw visual layout;
- focus nodes, text controllers, scroll controllers, animation controllers;
- pure component rendering;
- route chrome;
- backend implementation details.

View models should return immutable state shaped for the UI. They should avoid
side effects. A view model can expose precomputed display booleans, labels, and
section models when that removes business logic from widgets.

### Exhibit ARCH-PROVIDER-CODEGEN-001: Generated Auto-Dispose Provider Family

<!-- exhibit-freshness: ARCH-PROVIDER-CODEGEN-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

Reference files:

- `lib/clubs/data/club_name_lookup.dart`
- `lib/clubs/data/club_name_lookup.g.dart`
- `test/architecture/generated_provider_family_test.dart`

Use generated function providers for feature-owned async families. Keep the
family argument as a value-equality query object when callers need a canonical
cache key independent of input order or duplicates. `@riverpod` remains
auto-dispose by default, the generated provider keeps the existing public name,
and the adjacent generated output stays checked in.

```dart
@riverpod
Future<Map<String, String>> clubNameLookup(
  Ref ref,
  ClubNameLookupQuery query,
) async {
  if (query.clubIds.isEmpty) return const <String, String>{};

  final repository = ref.watch(clubsRepositoryProvider);
  final clubs = await Future.wait(query.clubIds.map(repository.fetchClub));

  return {
    for (final club in clubs)
      if (club != null) club.id: club.name,
  };
}
```

Provider migrations must preserve the generated provider name, family call
shape, query equality, auto-dispose lifecycle, `.future` access where used, and
`overrideWith` / `overrideWithValue` test seams. Lock those contracts with a
`ProviderContainer` test before treating a mechanical conversion as complete.

### Realtime Stream Lifecycle

Firestore snapshot streams are long-lived realtime listeners. Silence after the
initial emission is normal and must not be treated as failure. Do not wrap these
streams in `Stream.timeout` to detect stalled initial loads; that converts a
healthy listener into an error if no document changes arrive before the timeout.

Use these lifecycle rules:

- Prefer generated `@riverpod` auto-dispose stream providers for route-owned
  reads. Let the provider close when the route is popped or when the screen
  stops watching it.
- Use `@Riverpod(keepAlive: true)` only when the stream is deliberately global
  or prewarmed. Document the reason at the provider or call site with a
  `// keepalive:` marker within the three lines above the annotation or
  handwritten provider declaration; the dependency-direction scanner enforces
  that marker.
- For bottom-tab branches retained by `StatefulShellRoute.indexedStack`, decide
  whether the stream should remain active while its tab is inactive. If not,
  gate the screen/view model on the active tab before watching feature-owned
  providers. If the active screen already has data and should force a fresh
  listener later, invalidate the specific stream provider when the tab becomes
  inactive.
- Avoid shell-level prewarming for feature-owned tab streams unless the UX
  benefit is explicit, the read cost is acceptable, and provider ownership is
  documented.
- Keep small global streams alive when they support shell-wide behavior, such
  as auth state, current user profile, connectivity, or unread-count badges.
- Add regression tests for lifecycle-sensitive streams. A good test opens the
  stream, emits data, advances fake time beyond any historical timeout window,
  and asserts the provider still holds data rather than `AsyncError`.

Reopening a listener can cost a fresh query read; leaving it open can incur
reads when matching documents change in the background. The right owner is the
surface that needs the data: shell-wide data belongs in the shell,
first-viewport tab data should usually pause when the tab is inactive, and
pushed detail-route data should usually auto-dispose when popped.

## StatefulWidget Policy

Use `StatefulWidget` for Flutter mechanics:

- `TextEditingController`;
- `FocusNode`;
- `ScrollController`;
- `TabController`;
- `AnimationController`;
- `FormState` keys;
- drag/gesture state;
- transient expansion state;
- text currently being edited before commit;
- local UI timers that do not affect product state.

Use a controller/view model instead when the state:

- is loaded asynchronously;
- is persisted;
- triggers a repository or platform operation;
- affects product eligibility, pricing, booking, profile, safety, chat, or host
  behavior;
- must survive route/tab transitions;
- is shared across widgets;
- needs tests without pumping a widget tree;
- has loading/error/retry behavior.

Do not move ephemeral Flutter controller state into Riverpod just for
uniformity. Do not keep product-significant state in a widget just because it is
convenient.

## Repository And Service Contract

Repositories live in `data` and are the app's source of truth for feature data
access. They expose typed reads/writes and hide Firebase/platform specifics.

Repositories own:

- Firestore/Auth/Storage/Functions/Messaging/Remote Config access;
- backend error context wrapping;
- query shape, batching, chunking, and projection reads;
- stream/future providers for feature data;
- data normalization and DTO/model conversion;
- partial-write policy and FieldValue operations;
- repository-level cache/local fallback policy when needed.

Services own low-level external APIs:

- platform plugins;
- SDK clients;
- URL/share/image/location/permission wrappers;
- local storage adapters;
- analytics/crash/logging adapters when feature-neutral.

Use a service when multiple repositories/controllers need the same external
operation or when the operation needs a test double. Put the service near the
owning feature when it is feature-specific; put it under `core` only when it is
truly app-wide.

Use an application service or coordinator only when a non-UI workflow combines
multiple repositories and is reused across features. If the orchestration exists
only for one screen action, keep it in that screen's controller.

Repository rules:

- No full-document client snapshot rewrites for mutations that change existing
  Firestore docs. Use partial `update()`, `set(merge: true)`, or `FieldValue`
  operations unless a transaction-guarded create owns the whole document.
- Do not idle-timeout realtime Firestore streams with `Stream.timeout`.
- Do not fan out display-only list data through per-tile realtime streams when
  one batched provider can resolve it.
- Use `keepAlive` only with documented lifecycle rationale.
- Do not expose raw Firebase exceptions to presentation.

### Legacy-mirror normalization and cutover

When a Firestore model is migrating from legacy scalar mirrors to one
structured canonical field, normalize at the repository/domain read boundary;
do not scatter `newField ?? oldField` fallbacks through presentation code.

The migration shape is:

1. Prefer a valid canonical object.
2. Otherwise promote a complete, internally consistent legacy field set into
   the canonical in-memory shape.
3. Treat partial, non-finite, or contradictory mirrors as invalid; any
   operation that requires the invariant must fail closed.
4. Dual-write the canonical field and supported mirrors while released clients
   still consume those mirrors.
5. Keep the canonical domain field nullable only while a measured production
   blocker set remains. Remove that compatibility state after the repair tool,
   read-only validation, and rollout receipt all report zero blockers.

Event meeting locations are the reference migration. New and edited events are
strict, while Dart reads remain compatibility-nullable because the 2026-07-16
production dry run still has nine coordinate-less historical records. The
exact cutover state and proof live in
`contracts/migrations/event_meeting_location.json`; do not copy the strict
branch implementation into production reads until that contract advances.
`RunClub` next-event projections and `Payment` legacy fields are candidates for
this pattern only after their own source-of-truth, repair, and cutover contracts
exist.

## Widget Ownership

Widgets have two normal homes:

- `lib/core/widgets/**` for shared, branded, feature-neutral primitives and
  compositions.
- `lib/<feature>/presentation/widgets/**` for feature-owned UI that depends on
  feature domain/state language.

Feature widgets own:

- rendering sections, rows, cards, slivers, rails, forms, and body fragments;
- local visual relationships inside their component;
- local Flutter mechanics when they are genuinely component-local;
- callbacks supplied by the screen/controller;
- translating typed display state into core primitives.

Feature widgets do not own:

- repository reads/writes;
- mutation orchestration;
- backend/platform calls;
- product eligibility decisions;
- global spacing/token definitions;
- cross-feature reusable primitives without catalog review.

Promote a feature widget to `core/widgets` only when:

- at least two unrelated features need the same visual/interaction contract;
- the API can be named without feature-specific language;
- it has a stable component role;
- it can be documented in `docs/widget_catalog.md`;
- Widgetbook/component contract coverage is planned or already present.

Do not promote a widget just to avoid duplication if the concepts are actually
different. Do not leave duplicate feature-local widgets when they are the same
concept under different names.

## Cross-Feature Behavior

Some actions affect multiple features. Choose the owner by product truth, not
by which screen happens to call it first.

Use a feature controller when:

- the workflow is initiated by one screen or flow;
- the UI owns the user's next step;
- orchestration is not reused elsewhere.

Use a feature repository when:

- the workflow mutates or reads one feature's source-of-truth data;
- the backend owns most policy;
- the operation should be reused by several controllers.

Use a domain/use-case class when:

- pure business rules combine multiple domain models;
- the result is reusable and testable without Flutter/Firebase;
- no side effect is required.

Use an application service/coordinator when:

- the workflow combines multiple repositories;
- it is not naturally owned by one screen;
- it must be reused by several features;
- it needs its own tests and operation context.

When ownership is unclear, start with the narrowest owner and document the
promotion trigger. Do not create a broad cross-feature service preemptively.

## Product Copy And Localization

User-facing prose is product content, not widget structure. Flutter product copy
must be authored in `lib/l10n/app_en.arb` and consumed through generated
`AppLocalizations`; `lib/l10n/l10n.dart` is the single context access seam.
Consumer and Host share the same catalog and locale lifecycle while keys carry
an explicit `consumer`, `host`, or `shared` audience in ARB metadata.

Every ARB message requires:

- a stable semantic key rather than a value-derived or line-derived key;
- a translator-facing `description`;
- `x-audience`, `x-owner`, and `x-surface` review metadata;
- `x-max-chars` when the layout has a real copy budget; and
- named ICU placeholders with types when content varies.

Presentation resolves copy as late as possible with `context.l10n`. Domain,
repository, controller, and view-model layers return semantic enum values,
validation codes, error codes, and interpolation data rather than English
sentences. Shared widgets may accept already-localized strings when the caller
owns the wording, or accept a semantic value when the widget owns a fixed
product concept. They must not import an English singleton or cache localized
messages globally.

Developer-only deterministic fixtures and exact canonical geographic
proper-noun catalogs may declare
`// copy:allow-file(<specific reason>)` in the first twelve lines. The scanner
accepts that directive only for exact fixture/preview/manual-QA/reference-data
surfaces it knows about; production screens cannot use it. A single intentional
technical literal elsewhere uses the narrower
`copy:allow-inline(<reason>)` marker.

The English ARB is the canonical mobile review file. Marketing can edit it
directly as JSON or request a spreadsheet-shaped review deck with:

```sh
node tool/copy/check_mobile_copy_catalog.mjs \
  --export-csv build/copy/mobile_copy_review.csv
```

The CSV is an export, never a second source of truth. After edits, run
`flutter gen-l10n`, the catalog check, focused app-role tests, and the ownership
ratchet. ICU apostrophes are doubled because `l10n.yaml` enables escaping.

Copy outside Flutter has explicit catalogs rather than being forced through a
runtime Flutter dependency:

- iOS permission prose is owned by `copy/native_en.json`; the native sync writes
  the base plist values and the localized `InfoPlist.strings` resource;
- server notification templates are owned by `copy/notifications_en.json`; the
  notification sync generates the typed Functions catalog; and
- synchronous structured domain content is owned by
  `copy/structured_domain_copy_en.json`; its generator writes typed Event
  Success/event-policy templates plus small Flutter-independent constants;
- Event Success questionnaire packs and normalization fallbacks are owned by
  `copy/event_success_questionnaires_en.json`; and
- `pushInstallations` records the device locale and timezone so notification
  selection can become recipient-aware without changing producer contracts.

Remote-config or CMS copy may later serve reversible campaign content, but it
must have a bundled fallback, schema/version validation, cache policy, and
rollback. Authentication, safety, legal, permission, error, and navigation copy
must remain bundled and release-reviewed.

### Exhibit ARCH-COPY-001: Product Copy Boundary

<!-- exhibit-freshness: ARCH-COPY-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

Reference implementation:

- `l10n.yaml` — deterministic `gen_l10n` configuration;
- `lib/l10n/app_en.arb` — canonical typed English Flutter catalog;
- `lib/l10n/l10n.dart` — presentation access seam and isolated-preview fallback;
- `lib/app.dart` — shared locale delegates, supported locales, and role-aware
  app title;
- `lib/core/presentation/app_shell.dart` and
  `lib/core/presentation/host_app_shell.dart` — semantic navigation destinations
  localized at render time;
- `lib/core/widgets/catch_notice.dart` — semantic offline notice factory;
- presentation-state factories such as
  `lib/onboarding/presentation/onboarding_flow_state.dart`,
  `lib/events/presentation/event_detail_screen_state.dart`, and
  `lib/event_success/presentation/event_success_companion_screen_state.dart`
  — receive `AppLocalizations` explicitly and return resolved display copy;
- `lib/core/widgets/event_activity_visuals.dart` — resolves semantic taxonomy
  labels from localization at the render boundary while domain activity kinds
  remain stable identifiers;
- `copy/native_en.json` and `tool/copy/sync_native_copy.mjs` — native copy lane;
- `copy/notifications_en.json` and
  `functions/src/shared/notificationCopy.ts` — server notification lane; and
- `copy/structured_domain_copy_en.json` and
  `tool/copy/sync_structured_domain_copy.dart` — schema-checked synchronous
  content lane for domain models that cannot depend on `BuildContext`;
- `lib/core/app_error_message.dart` — semantic exception-code localization at
  widget build time; and
- `tool/copy/check_mobile_copy_ownership.dart` — zero-debt ownership gate.
- `tool/copy/check_l10n_key_usage.mjs` — exact handwritten-key inventory and
  zero-orphan ratchet with generated evidence under the audit registry.

Required checks:

```sh
flutter gen-l10n
node tool/run.mjs check copy:mobile-catalog
node tool/run.mjs check copy:mobile-ownership
node tool/run.mjs check copy:l10n-key-usage
node tool/run.mjs check copy:native-sync
node tool/run.mjs check copy:notification-sync
node tool/run.mjs check copy:event-success-questionnaires
node tool/run.mjs check copy:structured-domain-content
```

The baselines in `tool/copy/mobile_copy_baseline.json` and
`tool/copy/l10n_orphan_baseline.json` must remain empty. New inline findings or
zero-use ARB keys fail immediately, and the checked key-usage inventory must
match the current catalog and handwritten Dart sources. An allowlist entry is
only appropriate for a technical identifier, test/demo fixture, or
user-authored value and must contain a narrow reason.

Presentation models may contain resolved `String` fields, but any factory that
creates user-visible prose must accept `AppLocalizations` explicitly. Widgets
pass `context.l10n`; tests use `AppLocalizationsEn`. Domain entities,
repositories, controllers, and persisted records keep semantic enums, ids,
counts, dates, and user-authored data instead of localized strings. This makes
copy reviewable without coupling domain logic to Flutter context or hiding a
second English source inside state classes.

## Installable App Roles

Catch ships distinct consumer and host app experiences on a shared backend. The
role split is an architecture boundary, not just navigation polish.

Current roles:

| Role | Owns | Must not own |
|---|---|---|
| `consumer` | dating profile, discovery, booking, attendance, post-event reactions, matching, consumer chats, settings | host event creation/editing/manage tools, host-only club operations, professional host account setup |
| `host` | host shell, club/event creation and management, Event Success host tooling, host inbox, professional host identity, event-flow operations | dating browse/match surfaces, dating-profile editing as a prerequisite for host work, consumer-only social readiness gates |

Rules:

- App role selection belongs in bootstrap/entrypoint configuration and route
  graph wiring. Feature widgets should not infer role from bundle ids,
  Firebase project ids, or platform flavor strings.
- Consumer routing must not mount host create/edit/manage screens. Consumer
  surfaces may show host identity and public event/club information, but not
  host-management affordances.
- Host routing may show attendee, booking, roster, and operational state needed
  to run events, but it must not become a dating browse or match surface.
- Host identity is professional and separate from dating identity:
  `hostProfiles/{uid}` and club host snapshots own host display names, logos,
  roles, verification, and operational permissions. Dating `users/{uid}` /
  `publicProfiles/{uid}` must not be the source of truth for host display.
- The same auth user may have both a consumer dating profile and a host profile,
  but host onboarding cannot require a completed dating profile.
- Message-host conversations are professional support/operations threads.
  Headers, avatars, and CTAs must not deep-link to dating profiles or show
  match-style context by default.
- Push registration is install/app-role scoped. Shared notification code should
  preserve the role context used at registration and routing time.
- Deep-link aliases should resolve through the role-appropriate route graph. A
  host-only deep link opened in the consumer app should route to a safe public
  or unavailable state rather than exposing host tools.
- Native targets, Firebase app registrations, App Check providers, URL schemes,
  and launcher resources are release-configuration concerns; current release
  evidence and remaining TestFlight/Play work live in
  `docs/release_operations.md`.

Host Inbox is the reference for sharing foundations without sharing product
composition. Consumer `/chats` owns `ChatsListScreen`; Host `/host/inbox` owns
`HostInboxScreen`. They may reuse `ChatConversationsList`, `CatchPersonRow`,
search state, inquiry repositories, and routing contracts, but the consumer
screen must not remain the Host route dispatcher.

The Host Inbox contract is:

- an explicit selected Event or explicit General scope; General is never an
  event-id sentinel;
- personal two-party contacted-host inquiry threads, separated by event;
- Booked and Prospective thread views, with broadcast counts derived from
  `eventParticipations` rather than conversation count;
- inquiry-only users may appear as Prospective/Inquiry without becoming a
  broadcast recipient;
- event broadcasts use a dedicated callable and produce Activity plus
  preference-gated push, never match/message fan-out;
- production callable-backed affordances stay disabled until the target-specific
  live dependency preflight succeeds.

`HostInboxViewModel.compose` is the provider-free reference adapter for scope,
classification, roster/thread separation, search, lifecycle, and row-status
policy. `HostInboxScreen` owns provider reads, typed route effects, and sheet
composition; `HostInboxBroadcastController` owns the mutation.

### Installable App Target Contract

`tool/app_targets.json` is the source of truth for the six installable target
combinations: Consumer and Host across dev, staging, and prod. It explicitly
owns each target's entrypoint, display name, Apple scheme/configurations/bundle
id/icon/URL scheme, Android flavor/application id/icon source set, Firebase
project and app registrations, capability policy, deep-link ownership,
role-scoped force-update prefix, store product, and routine release owner.

Target identity must not be reconstructed independently in shell scripts,
Gradle, Xcode generators, Firebase activation scripts, or CI workflows. Those
surfaces must query the manifest or be checked against it. The first reference
implementation is:

```text
tool/app_targets.json
  -> tool/platform/resolve_app_target.mjs
  -> tool/flutter_with_env.sh
  -> Android app-target flavor or Apple app-target scheme
  -> role-matched Firebase config and Dart entrypoint
```

Current native policy:

- Android uses six explicit app-target flavors rather than an environment
  flavor plus a mutable global role property. Release manifests embed checked
  target/role and Firebase app/project markers; the signed-AAB gate compares
  those markers, Maps key, debug policy, package/version, and upload
  certificate against the target contract.
- Apple may continue using one `Runner` native target while each scheme has an
  explicit bundle id, Firebase role, icon, and role-specific entitlements. A
  second Xcode target becomes required if capabilities or build phases can no
  longer remain safely scheme/configuration driven.
- Consumer owns HealthKit/Health Connect and the current public event-link
  association. Host must not inherit those capabilities until a Host-specific
  product contract requires them.
- Force-update minimum builds and store URLs are role-prefixed. Consumer may
  temporarily fall back to the legacy unprefixed remote values during rollout;
  Host never does.
- GitHub Actions is the routine mobile release owner for both roles. One
  approval-free merge-driven workflow fans out by role: iOS archives upload to
  TestFlight and Android produces signed AABs for Play internal testing. Its
  credentials live in the main-only `prod-mobile` environment, not the shared
  backend/data `prod` environment. Each ephemeral iOS runner imports the same
  dedicated, fingerprint-checked CI Apple Development identity before invoking
  automatic signing; Xcode still owns profile updates and distribution
  re-signing at export. A runner must never create and then abandon a new
  development certificate. Xcode Cloud is a
  legacy cutover surface only; Play upload remains gated by
  `APP-TARGET-ANDROID-PLAY-001` until console enrollment and publisher access
  are proven.

Run `node tool/run.mjs check platform:app-targets` whenever app identity,
native configuration, Firebase registration, links, force-update policy, or
release ownership changes.

### Exhibit ARCH-APP-TARGET-001: Installable App Target Resolution

<!-- exhibit-freshness: ARCH-APP-TARGET-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

The build wrapper resolves entrypoint and native identity from the target
contract before it activates Firebase or invokes Flutter:

```bash
IFS=$'\t' read -r target_entrypoint ios_flavor android_flavor <<<"$(
  node "$repo_root/tool/platform/resolve_app_target.mjs" \
    --role "$app_role" \
    --environment "$environment" \
    --fields 'entrypoint,ios.scheme,android.flavor'
)"
```

Generators may read `tool/app_targets.json` directly. Other scripts should use
the resolver rather than reproduce suffix or role formulas.

## Routing And Navigation

Routing remains centralized in `lib/routing/go_router.dart`.

Rules:

- Route definitions should construct screens and parse path/query parameters.
- Route guards can redirect based on auth/profile/app state.
- Route config should not perform repository mutations.
- Production navigation outside `lib/routing/**` should use named routes, route
  constants, or typed route helpers instead of raw path string literals. Raw
  paths stay owned by route definitions and URL contract files.
- Screen constructors receive simple route values, not repository instances.
- Complex route extras should be normalized into a typed route argument object
  or handled by the screen/controller boundary.
- Legacy/deep-link aliases should delegate to canonical screens rather than
  duplicate product behavior.

## Testing Expectations

Test at the boundary that owns the behavior:

| Behavior | Test type |
|---|---|
| Pure domain rules | Dart unit test |
| Repository query/write mapping | repository test, emulator/rules test, or fake-backed unit test depending on risk |
| Controller action or flow | Riverpod/provider test with fake repositories |
| View-model composition | provider test |
| Async UI state rendering | widget test covering loading, error, empty, data, retry |
| Mutation error surfacing | widget test for pending/error display or listener behavior |
| Sliver/scroll ownership | widget test with small viewport and relevant scroll gestures |
| Shared primitive behavior | Widgetbook use case plus focused widget test when behavior is logic-bearing |
| Backend/rules/data contracts | `tool/check_data_contract.sh` and focused Functions/rules tests |

Brittle tests are design feedback. If a test needs private finders, timing
hacks, or duplicate-text counts, inspect whether the production seam should be
more explicit.

## Enforcement And Overrides

Use three enforcement levels.

The enforcement registry is checked by
`node tool/check_enforcement_integrity.mjs`. When a rule gains, loses, or
changes enforcement, update `docs/audit_registry/rules.json`,
`tool/tools_manifest.json`, the owner-doc anchor, and the known-bad proof or
baseline receipt together. Manual enforcement is explicit with `stage: manual`;
absence of an enforcement entry is drift.

### Screen chrome contracts

Every handwritten `Scaffold.appBar` is registered by exact file, role,
expression, and canonical owner in
`tool/design/screen_top_bar_contracts.json`. Root and root-like destinations
use `CatchScreenTopBar`, compact detail/edit/utility routes use `CatchTopBar`,
and identity routes use `CatchTopBar.identity`. A canonical call elsewhere in
the file cannot bless helper-owned or raw chrome inside the actual `appBar`
value.

Pushed routes that must always expose an exit declare `leading: "back"` in
the same manifest entry. The gate then requires an explicit
`CatchTopBarLeading.back` (or `showBackButton: true`) configuration, so a
correct primitive name cannot hide a navigation dead end. Screens that can be
entered as a root deep link should also provide an `onBack` fallback to their
owning root destination.

`node tool/run.mjs check design:screen-top-bar-contracts` walks all
handwritten `lib/**/*.dart`, not only `presentation/` or `*_screen.dart`. It
also inventories raw Material/Cupertino navigation bars, exact media-hero
exceptions, and feature classes ending in `Screen`, `Scaffold`, `Header`,
`TopBar`, or `HeaderContent` that own screen typography. Stateful-widget
owners include their matching `State<T>` body. Aligned
`ARCH-SCREEN-CHROME-001` adopter paths are checked surface by surface so one
canonical header cannot hide a second noncanonical implementation in the same
file. Other feature headers must name their content, screen, step-flow,
workspace, or temporary legacy role by symbol and owner. Role-to-owner policy
is enforced; raw Material app bars cannot be relabeled as workspace or hero
exceptions. Legacy entries are visible migration debt, not generic
exceptions.

Full-screen editors that must cover persistent shell navigation declare their
launcher in the same contract and push through
`Navigator.of(context, rootNavigator: true)`. This route ownership is separate
from title typography: Edit Photo remains correct compact `CatchTopBar`
navigation while the root presentation prevents the tab bar from leaking over
its body.

### Analyzer plugin rules

Use `packages/catch_ui_lints` or a future architecture lint package for
deterministic rules that should be visible in IDE/analyzer output.

Good analyzer-rule candidates:

- `presentation/widgets/**` must not import or watch `*RepositoryProvider`.
- feature presentation must not import sibling feature presentation internals
  except the sanctioned screen/controller-to-controller seam.
- `domain/**` must not import Flutter, Riverpod, Firebase, or platform plugins.
- direct raw Firebase UI messages are forbidden in presentation.
- `*_screen.dart` classes should use a named async boundary when they watch
  `AsyncValue`.
- UI that watches a `Mutation` for pending state must also handle error state.
- platform/plugin calls in widgets require an approved provider/service seam.

### Scanners

Use scanners for migration discovery or noisy rules that need judgement.

Good scanner candidates:

- screen-ish widgets missing clear route/screen classification;
- possible direct repository reads in presentation;
- aligned provider-free adopters drifting back into provider/routing imports
  via `tool/architecture/check_adopted_architecture_boundaries.mjs`;
- possible missing mutation listeners;
- overly complex widgets that should split rendering from behavior;
- raw `AsyncValue.when` branches that may need a wrapper or typed state;
- feature widgets that look like reusable primitives;
- private widget classes that need public/catalog resolution;
- stale docs or duplicate architecture guidance.

### Manual overrides

Overrides are allowed only when explicit, searchable, and reviewed.

Use this format on the line nearest the exception:

```dart
// architecture:allow <rule-id> -- reason: <why this is correct> -- owner: <name/team> -- expires: <date-or-debt-id>
```

Examples:

```dart
// architecture:allow repository-read -- reason: legacy route migration shim while EventDetailViewModel lands -- owner: app -- expires: ARCH-EVENT-DETAIL-001
```

```dart
// architecture:allow platform-call -- reason: debug-only diagnostics before app services initialize -- owner: app -- expires: never
```

If overrides pile up for one rule, redesign the rule. If overrides are rare and
specific, keep the rule and migrate the call sites.

## Reference Implementation Workflow

Architecture migration must proceed from a reference implementation, not from
abstract prose alone. Before rolling a pattern across many files, create one
high-quality prototype, copy the relevant code excerpt into this document as an
exhibit, and record adopters in
`docs/audit_registry/architecture_pattern_adoption.json`.

The workflow is:

1. Pick one concrete pattern id before editing the batch.
   - Use ids such as `ARCH-UI-STATE-001` or `ARCH-CONTROLLER-001`.
   - Record the prototype file, tests, Widgetbook/catalog surfaces if any, and
     intended adopters in the tracker.

2. Build one reference prototype first.
   - The prototype should be better than the average migration target: clear
     ownership, provider seams, stable tests, catalog coverage when UI is public,
     and no private widget/helper drift.
   - Do not start a mechanical rollout until the prototype passes its focused
     tests and relevant scanners.

3. Copy a real code excerpt into this document.
   - The exhibit is not pseudocode. It should show the exact shape agents are
     expected to preserve.
   - Keep the excerpt short enough to review, but specific enough that another
     agent can compare a candidate file against it.

4. During rollout, classify every candidate.
   - `aligned`: conforms to the current exhibit.
   - `needs_update`: can conform with local edits.
   - `variant_needed`: valid product constraint that the exhibit does not cover.
   - `exception`: intentionally different, with a debt id or override.

5. When a candidate reveals a better pattern, update the exhibit first.
   - Then revisit every file already marked as an adopter of the previous
     exhibit and either update it or record why it remains a variant/exception.
   - A migration batch is not complete if earlier adopters silently lag behind
     an edited exhibit.

6. Stamp the pass with pattern evidence.
   - Include the pattern id, prototype path, adopter paths, and verification
     commands in the audit-registry pass receipt.

Exhibit freshness is owned by this doc plus
`docs/audit_registry/architecture_pattern_adoption.json`. Every exhibit block
must carry an `exhibit-freshness` marker naming its tracker source and owner.
`node tool/architecture/check_app_architecture_exhibits.mjs` checks those
markers, verifies the tracker points back to the current doc anchor, and rejects
known stale snippets from prior reference shapes.

### Exhibit ARCH-SCREEN-001: Feature Screen Boundary

<!-- exhibit-freshness: ARCH-SCREEN-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

Reference files:

- `lib/events/presentation/event_detail_screen.dart`
- `lib/events/presentation/event_detail_controller.dart`
- `lib/events/presentation/widgets/event_detail_body.dart`
- `test/events/event_detail_controller_test.dart`
- `test/events/event_detail_widgets_test.dart`
- `design/screens/catch.screens.json`
- `widgetbook/lib/events/event_detail_use_cases.dart`

Use this pattern for route-level or major navigable feature screens. The screen
owns route parameters, provider watches, top-level async/error branches, route
`Scaffold`, bottom navigation, screen-level mutation listeners, navigation
callbacks, retry invalidation, and controller/service side-effect calls. Loaded
body widgets receive explicit view data, shell state, and callbacks; they do not
reach around the screen for route-level repositories or app-shell decisions.

`design/screens/catch.screens.json` is the screen inventory and screen
composition map. Do not create a second screen-inventory document for the same
purpose. The architecture pattern tracker records which screen files conform to
this exhibit.

`EventDetailBody` and `EventLocationMapScreen` do not expose direct scaffold
compatibility. Direct Widgetbook or widget-test states may mount those bodies as
body-only review surfaces, but any state that needs route chrome, bottom
navigation, access/loading/error branches, or mutation listeners must mount the
route screen with provider overrides. Body-only Event Detail fixtures must
provide explicit save/share/calendar/back callbacks, display flags, companion
state, host state, and route-intent callbacks; they must not rely on body-owned
provider fallbacks for route side effects.

Current aligned adopters:

- `lib/events/presentation/event_location_map_screen.dart` uses
  `EventLocationMapRouteScreen` as the route shell. The route watches
  `EventDetailViewModel`, owns the chromeless `Scaffold`, floating back
  controls, loading/error/not-found branches, exact-coordinate gate, retry
  invalidation, and external directions side effect. It resolves
  `EventLocationMapState` and passes that provider-free state plus
  `onGetDirections` into `EventLocationMapScreen`. Direct
  `EventLocationMapScreen` Widgetbook/test states are body-only states with the
  same explicit state/callback API.

- `lib/events/presentation/calendar/calendar_screen.dart` uses
  `CalendarScreen` as the route shell. The screen owns uid/event provider
  waves, the route `Scaffold`, loading/error branches, retry invalidation,
  selected-date and expanded-header inputs, scroll-to-day behavior, and
  event-detail navigation. It resolves `CalendarHomeState` for event
  merge/sort, selected date, header mode, and club-id lookup input before
  composing provider-free calendar header, stats, agenda, and state sections.

- `lib/events/presentation/saved_events_screen.dart` uses
  `SavedEventsScreen` as the route shell. The screen owns uid/saved-event
  provider waves, the route `Scaffold`, loading/error/empty branches, retry
  invalidation, club-name lookup, and saved-event detail navigation. It resolves
  `SavedEventsListState` for ordering, saved/past labels, tile statuses, today,
  and club-id lookup input before composing shared provider-free agenda rows.

Defined variant:

- `ARCH-SCREEN-001C` covers host workspaces such as
  `lib/hosts/presentation/host_event_manage_screen.dart`. Host Event Manage is
  not a mechanical Event Detail copy because one canonical route owns multiple
  route aliases and lifecycle sections: Setup, Guests, Live, and Report.
  `HostEventManageRouteScreen` keeps canonical route ids/aliases, uid/club/event
  loading, missing-resource/error branches, host access gating, retry
  invalidation, and initial section/deep-link inputs. The loaded workspace may
  keep local tab/section state while migration is in progress, but the target is
  a `HostEventManageScreenState` or split workspace adapters that feed
  provider-free setup, roster, private-access, invite-link, Event Success,
  report, and host-action sections with explicit display state and typed
  callbacks. Do not move solved route loading/access work into the workspace
  adapter, and do not duplicate attendance or Event Success aliases as separate
  screen contracts.

```dart
@override
Widget build(BuildContext context) {
  final vmAsync = ref.watch(eventDetailViewModelProvider(widget.eventId));
  final vm = vmAsync.asData?.value;
  final isHostApp = AppConfig.appRole.isHost;

  if (vm != null) {
    final now = DateTime.now();
    final viewerIsHost = vm.isHost;
    final sectionVisibility = eventDetailSectionVisibilityStateFrom(
      event: vm.event,
      participation: vm.participation,
      isHostApp: isHostApp,
      isHost: viewerIsHost,
      now: now,
    );
    final isSpotlightDark =
        widget.presentationMode == EventDetailPresentationMode.spotlightDark;
    final style = _eventDetailSurfaceStyle(
      context,
      presentationMode: widget.presentationMode,
    );
    final saveMutation = ref.watch(
      EventDetailController.toggleSavedEventMutation,
    );
    final share = ref.watch(externalShareControllerProvider);
    final calendar = ref.watch(eventCalendarControllerProvider);
    final canOpenCompanion = eventDetailCanOpenCompanion(
      participation: vm.participation,
      showConsumerActions: sectionVisibility.showConsumerActions,
    );
    final companionState = eventDetailCompanionStateFrom(
      participation: vm.participation,
      showConsumerActions: sectionVisibility.showConsumerActions,
      planState: canOpenCompanion
          ? _catchAsyncState(
              ref.watch(watchEventSuccessPlanProvider(vm.event.id)),
            )
          : null,
    );
    final hostState = eventDetailHostStateFrom(
      clubState: _catchAsyncState(ref.watch(fetchClubProvider(widget.clubId))),
      currentUid: vm.userProfile?.uid,
      canMessageHost:
          sectionVisibility.showConsumerActions && vm.isAuthenticated,
    );
    final socialState = eventDetailSocialStateFrom(
      event: vm.event,
      userProfile: vm.userProfile,
      isAuthenticated: vm.isAuthenticated,
      renderAsHost: sectionVisibility.renderSocialAsHost,
      participation: vm.participation,
      now: now,
    );

    if (vm.isAuthenticated) {
      ref.listen(EventBookingController.bookMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          showCatchSnackBar(context, 'Booking confirmed!');
        }
      });
      ref.listen(EventBookingController.cancelMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          showCatchSnackBar(context, 'Booking cancelled.');
        }
      });
    }

    void shareEvent(BuildContext buttonContext) => unawaited(
      _shareEvent(
        buttonContext,
        vm.event,
        share,
        widget.inviteCode,
        widget.inviteLinkId,
      ),
    );

    return CatchMutationErrorListener(
      mutation: EventDetailController.toggleSavedEventMutation,
      errorContext: AppErrorContext.event,
      child: Scaffold(
        backgroundColor: style.pageBackground,
        body: EventDetailBody(
          event: vm.event,
          userProfile: vm.userProfile,
          clubId: widget.clubId,
          reviews: vm.reviews,
          isAuthenticated: vm.isAuthenticated,
          sectionVisibility: sectionVisibility,
          isSaved: vm.isSaved,
          participation: vm.participation,
          savePending: saveMutation.isPending,
          surfaceStyle: style,
          onBack: () => Navigator.of(context).pop(),
          onShare: shareEvent,
          showAddToCalendar: _canAddEventToCalendar(
            event: vm.event,
            participation: vm.participation,
            isHost: sectionVisibility.renderSocialAsHost,
            now: now,
          ),
          onAddToCalendar: (buttonContext) =>
              unawaited(_addEventToCalendar(buttonContext, vm.event, calendar)),
          onToggleSaved: () => _toggleSavedEvent(
            context,
            ref,
            event: vm.event,
            clubId: widget.clubId,
            userProfile: vm.userProfile,
            isAuthenticated: vm.isAuthenticated,
            isSaved: vm.isSaved,
          ),
          companionState: companionState,
          hostState: hostState,
          socialState: socialState,
          onLocationTap: vm.event.hasExactStartingPoint
              ? () => context.pushNamed(
                  Routes.eventLocationMapScreen.name,
                  pathParameters: {'eventId': vm.event.id},
                )
              : null,
          onOpenCompanion: () => context.pushNamed(
            Routes.eventSuccessCompanionScreen.name,
            pathParameters: {'clubId': widget.clubId, 'eventId': vm.event.id},
            extra: vm.event,
          ),
          onRetryCompanion: () =>
              ref.invalidate(watchEventSuccessPlanProvider(vm.event.id)),
          onViewClub: (clubId) => context.pushNamed(
            Routes.clubDetailScreen.name,
            pathParameters: {'clubId': clubId},
          ),
          onMessageHost: (clubId, hostUid) => unawaited(
            _messageHost(context, ref, clubId: clubId, hostUid: hostUid),
          ),
          onRetryHosts: () => ref.invalidate(fetchClubProvider(widget.clubId)),
          inviteCode: widget.inviteCode,
          inviteLinkId: widget.inviteLinkId,
          now: now,
          presentationMode: widget.presentationMode,
          heroTag: widget.heroTag,
        ),
        bottomNavigationBar: _eventDetailBottomNavigationBar(
          event: vm.event,
          userProfile: vm.userProfile,
          clubId: widget.clubId,
          isAuthenticated: vm.isAuthenticated,
          participation: vm.participation,
          inviteCode: widget.inviteCode,
          inviteLinkId: widget.inviteLinkId,
          now: now,
          darkSurface: isSpotlightDark,
          sectionVisibility: sectionVisibility,
          onGuestBook: () => _openEventSignIn(
            context,
            clubId: widget.clubId,
            eventId: vm.event.id,
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
          ),
        ),
      ),
    );
  }

  if (vmAsync.isLoading && _initialEventMatchesRoute) {
    return EventDetailOptimisticBody(
      event: widget.initialEvent!,
      clubId: widget.clubId,
      presentationMode: widget.presentationMode,
      heroTag: widget.heroTag,
      inviteCode: widget.inviteCode,
      inviteLinkId: widget.inviteLinkId,
    );
  }

  if (vmAsync.isLoading) {
    return EventDetailLoadingScreen(
      presentationMode: widget.presentationMode,
    );
  }

  if (vmAsync.hasError) {
    return CatchErrorScaffold.fromError(
      vmAsync.error!,
      context: AppErrorContext.event,
      onRetry: () =>
          ref.invalidate(eventDetailViewModelProvider(widget.eventId)),
    );
  }

  return const CatchErrorScaffold(
    title: 'Event not found',
    message: 'This event is no longer available.',
  );
}
```

### Exhibit ARCH-SCREEN-CHROME-001: Root Screen Header Chrome

<!-- exhibit-freshness: ARCH-SCREEN-CHROME-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

Reference files:

- `lib/core/widgets/catch_top_bar.dart`
- `lib/dashboard/presentation/dashboard_home_screen.dart`
- `lib/chats/presentation/inbox/widgets/chats_sliver_header.dart`
- `lib/explore/presentation/widgets/explore_header.dart`
- `lib/user_profile/presentation/profile_screen.dart`

Use this pattern for root tab screens and root-like shell destinations whose
screen title should read as Catch voice/head typography. The title text routes
through `CatchScreenHeaderTitle`, which uses `CatchTextStyles.headline`
(Archivo) for the primary title, optional mono kicker and supporting subtitle
roles, and explicit leading/action slots. Sliver screens pass
`CatchScreenHeaderTitle.block(...)` into `CatchSliverHeader.title`; app-bar
screens use `CatchScreenTopBar(...)`, which wraps `CatchTopBar` while preserving
search, leading, action, safe-area, and padding configuration.

Do not use bare `CatchTopBar(title: ...)` for these root headers. That compact
route-title path intentionally remains available for detail, edit, lab, and
utility screens where the title is functional navigation chrome rather than the
root screen voice.

```dart
const CatchScreenHeaderTitle.block({
  required this.title,
  this.eyebrow,
  this.subtitle,
  this.leading,
  this.actions = const <Widget>[],
  this.padding = CatchInsets.screenTitleBlock,
  this.backgroundColor,
}) : material = true;

@override
Widget build(BuildContext context) {
  final t = CatchTokens.of(context);

  return Row(
    children: [
      if (leading != null) ...[leading!, gapW12],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH2,
            ],
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.headline(context, color: t.ink),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: CatchGaps.headerTitleToSubtitle),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ],
        ),
      ),
      if (actions.isNotEmpty) ...[
        gapW12,
        Row(mainAxisSize: MainAxisSize.min, children: actions),
      ],
    ],
  );
}

@override
Widget build(BuildContext context) {
  return CatchTopBar(
    titleWidget: CatchScreenHeaderTitle(
      title: title,
      eyebrow: eyebrow,
      subtitle: subtitle,
    ),
    large: false,
    leading: leading,
    leadingType: leadingType,
    actions: actions,
    contentPadding: contentPadding,
    height: height,
    searchValue: searchValue,
    searchEnabled: searchEnabled,
    onSearch: onSearch,
  );
}
```

### Exhibit ARCH-UI-STATE-001: Provider-Free Presentation State Model

<!-- exhibit-freshness: ARCH-UI-STATE-001 source=docs/audit_registry/architecture_pattern_adoption.json owner=recursive_audit_loop -->

Reference files:

- `lib/events/presentation/calendar/calendar_screen_state.dart`
- `test/calendar/calendar_screen_state_test.dart`
- `lib/events/presentation/calendar/calendar_screen.dart`

Current Host-v2 adopter:

- `lib/hosts/presentation/host_home_screen_state.dart`
- `lib/hosts/presentation/host_operations/host_events_list.dart`
- `test/hosts/host_operations_screen_test.dart`

`HostEventsWorkspaceState` applies the same boundary to lifecycle policy: the
provider adapter supplies events and an injected clock once; the state object
owns cancellation exclusion, exact Upcoming/Live/Past classification, ordering,
month/year grouping, Repeat availability, fill clamping, and render-ready row
metadata; provider-free widgets consume only that state and typed callbacks.
Do not move those decisions back into row widgets or substitute waitlist count
for a pending-approval aggregate.

Use this pattern when a screen needs a provider-free display model that merges
repository/domain data into UI-ready state. The screen may watch providers at the
route edge, but widgets below the screen consume the presentation state object
instead of reading repositories or recomputing product policy. In this exhibit,
`CalendarHomeState` owns the screen-level selected-date/header/view inputs and
`CalendarEventSummary` owns the merged event list.

This is a narrow state-boundary exhibit. The first full route/controller
migration still needs its own reference exhibit before a broad rollout.
`CalendarHomeState` is the reference route-edge state object; it composes the
`CalendarEventSummary` adapter shown below.

```dart
class CalendarEventSummary {
  const CalendarEventSummary({
    required this.events,
    required this.agendaEvents,
    required this.savedOnlyEventIds,
    required this.today,
    required this.anchorDate,
    required this.totalDistance,
    this.nextEvent,
  });

  final List<Event> events;
  final List<Event> agendaEvents;
  final Set<String> savedOnlyEventIds;
  final DateTime today;
  final DateTime anchorDate;
  final double totalDistance;
  final Event? nextEvent;

  bool isSavedOnly(Event event) => savedOnlyEventIds.contains(event.id);

  static CalendarEventSummary from({
    required List<Event> signedUpEvents,
    List<Event> savedEvents = const <Event>[],
    required DateTime now,
  }) {
    final signedUpIds = signedUpEvents.map((event) => event.id).toSet();
    final savedOnlyEventIds = <String>{};
    final byId = <String, Event>{};

    for (final event in savedEvents) {
      if (event.isCancelled || !event.startTime.isAfter(now)) continue;
      byId[event.id] = event;
      if (!signedUpIds.contains(event.id)) savedOnlyEventIds.add(event.id);
    }
    for (final event in signedUpEvents) {
      byId[event.id] = event;
    }

    final sorted = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final today = DateUtils.dateOnly(now);
    final totalDistance = sorted
        .where((event) => !event.isCancelled)
        .fold<double>(0, (sum, event) => sum + event.distanceKm);

    final upcoming = <Event>[];
    final cancelledUpcoming = <Event>[];
    final past = <Event>[];
    for (final event in sorted) {
      if (!event.startTime.isBefore(now) && event.isCancelled) {
        cancelledUpcoming.add(event);
      } else if (event.startTime.isBefore(now)) {
        past.add(event);
      } else {
        upcoming.add(event);
      }
    }

    final nextEvent = upcoming.isEmpty ? null : upcoming.first;
    final latestPastFirst = [...past]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final anchorDate = nextEvent?.startTime ?? today;

    return CalendarEventSummary(
      events: List.unmodifiable(sorted),
      agendaEvents: List.unmodifiable([
        ...upcoming,
        ...cancelledUpcoming,
        ...latestPastFirst,
      ]),
      savedOnlyEventIds: Set.unmodifiable(savedOnlyEventIds),
      today: today,
      anchorDate: anchorDate,
      totalDistance: totalDistance,
      nextEvent: nextEvent,
    );
  }
}
```

## Migration Plan

Use this order for architecture cleanup:

1. Refresh audit state.
   - `dart tool/audit_registry.dart refresh`
   - `dart tool/audit_registry.dart rules --status active`
   - relevant doc read policies from `dart tool/audit_registry.dart docs --path <topic>`

2. Inventory the current surface.
   - `python3 tool/scan_architecture.py`
   - `bash tool/widget_cleanup_scan.sh --summary`
   - `dart tool/audit/backend_error_candidates.dart`
   - `dart tool/audit/frontend_error_candidates.dart`
   - relevant `npm run design:widgets:*` checks for widget/catalog changes

3. Pick one feature, one enforcement rule, or one reference pattern.
   - Do not run a whole-app rewrite in one batch.
   - Prefer features with active repository reads in widgets, raw async
     branches, or mutation-error drift.
   - If the batch rolls out an architecture pattern, update
     `docs/audit_registry/architecture_pattern_adoption.json` before edits.
   - If no reference exhibit exists for the pattern, create the prototype and
     exhibit first.

4. Establish the screen boundary.
   - Identify route-level screens.
   - Move page chrome, safe area, scroll ownership, and padding to the screen.
   - Move body sections into feature widgets.

5. Establish the state boundary.
   - Simple async screen: `CatchAsyncValueView` or `CatchAsyncValueSliver`.
   - Complex async screen: typed `UiState` and adapter.
   - Preserve section/partial/stale/mutation states explicitly.

6. Establish controller/repository seams.
   - Move repository calls out of widgets.
   - Add view-model providers for combined reads.
   - Add action/flow controllers for mutations and product validation.
   - Add service seams for platform/plugin operations.

7. Establish error surfaces.
   - Full-screen/sliver/inline data errors use branded error primitives.
   - Mutation errors use banner/listener/snackbar based on persistence needs.
   - Optional enrichment failures log or degrade without breaking primary UI.

8. Clean widget ownership.
   - Keep feature-specific widgets under feature `presentation/widgets`.
   - Promote reusable primitives through `core/widgets`, `docs/widget_catalog.md`,
     Widgetbook, and component contracts.
   - Inline or delete private helper widgets that are not legitimate classes.

9. Add or tighten enforcement.
   - Start with scanners for inventory.
   - Promote deterministic, low-noise rules into analyzer diagnostics.
   - Add explicit overrides only with reason and debt/expiry.

10. Verify and stamp.
    - Run focused analyzer/tests/scanners.
    - Update docs/catalogs when ownership changes.
    - Stamp touched files through the audit registry.

## Definition Of Done

An architecture migration slice is done when:

- route-level screens are identifiable and own chrome/padding/scroll concerns;
- widgets no longer read repositories directly except documented overrides;
- async data surfaces use named boundaries;
- mutation pending states also surface errors;
- data-load errors use branded Catch error primitives with retry when safe;
- controllers/view models own product state and repository orchestration;
- StatefulWidget usage is limited to Flutter mechanics or explicitly justified;
- platform/plugin effects have service/provider seams;
- reusable widgets have catalog/Widgetbook/component-contract ownership;
- focused analyzer/tests pass;
- relevant scanners are clean, reduced, or have documented debt;
- docs and audit registry are updated in the same pass.

## Implementation Notes For New Features

When adding a new feature, start with the thinnest structure that satisfies the
contract:

```text
lib/new_feature/
  domain/new_feature_model.dart
  data/new_feature_repository.dart
  presentation/new_feature_screen.dart
  presentation/new_feature_view_model.dart
  presentation/widgets/new_feature_body.dart
```

Add a controller only when there is a mutation or durable flow state.

Add a typed `UiState` when the screen cannot be honestly represented as one
`AsyncValue<T>`.

Add a domain/use-case class only when business logic is shared, complex, or
valuable to test independently.

Add a service only when an external/platform operation needs a replaceable seam
or is reused across controllers/repositories.

Add a shared core widget only after checking `docs/widget_catalog.md` and the
existing `Catch*` primitives.

## Quick Review Checklist

Use this checklist during code review:

- Is this file in the layer that owns the behavior?
- Does the screen own page chrome, safe area, padding, scroll, and top async
  boundary?
- Is any repository provider read from a widget?
- Is any plugin/platform call made directly from a widget?
- Does every async branch preserve loading, error, data, and retry semantics?
- Are empty states separate from errors?
- Does every pending mutation have an error surface?
- Is `StatefulWidget` used for Flutter mechanics rather than product state?
- Are domain rules testable without Flutter?
- Are reusable widgets in `core/widgets` and feature-specific widgets in
  feature `presentation/widgets`?
- Would a new developer know where to add the next related behavior?
