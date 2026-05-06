---
doc_id: widget_catalog
version: 2.5.14
updated: 2026-05-06
owner: recursive_audit_loop
status: active
---

# Widget Catalog

## Read Policy

Use this as inventory, not as the primary process prompt. For process rules,
start with `docs/audit_registry/README.md`,
`docs/audit_registry/rules.json`, and `docs/widget_cleanup_todo.md`. Read a
feature section here only when auditing that feature's widget surface.

## Rule Changelog

### 2.5.14

- Added the shared celebration primitive family for high-emotion completion
  moments. `CatchCelebrationScreen` owns the full-screen branded surface,
  `CelebrationEffectsController` owns haptics, and feature screens supply
  moment-specific copy/details/actions. Haptics are enabled by default for host
  run creation, user run signup/payment confirmation, user self-check-in, and
  match creation. Sound is intentionally deferred under
  `CELEBRATION-SOUND-001` and should be added through the same effects
  controller rather than feature widgets.

### 2.5.13

- Home now mirrors the Profile tab architecture: `DashboardScreen` owns a
  route-local `TabController`, `NestedScrollView`, collapsible greeting/empty
  header, pinned `Dashboard`/`Activity` tab row, and native `TabBarView`
  paging. The Dashboard tab renders the existing dashboard widgets as sliver
  bodies, while the Activity tab owns notifications and run/message updates in
  a timeline-style activity feed.

### 2.5.12

- Profile-card follow-up guidance after visual review: Swipes, Profile
  Preview, and Public Profile must keep one identical `ProfileCard` rendering
  path. The canonical running identity should be a single dark `RUN PROFILE`
  card; do not also render duplicate pace/distance chips in a lower `RUNNING`
  card. Additional photo sections should be inset inside the card with
  consistent margins, rounded corners, and spacing instead of edge-to-edge
  blocks unless they are the hero photo.

### 2.5.11

- The shared swipe/profile-preview `ProfileCard` received its first polish
  pass while preserving one rendering path for Swipes, Profile Preview, and
  Public Profile. The card remains dark and immersive in both light and dark
  app themes, now uses a local `ProfileCardPalette`, shows only display name,
  age, and optional city on the hero photo, moves relationship goal into detail
  chips, promotes the bio prompt ahead of running stats, and uses a branded
  missing-photo fallback.

### 2.5.10

- Edit Profile now exposes `Display name` as the first About field. It is the
  editable public-facing name used by profile preview/public profile surfaces,
  initializes from onboarding first name, trims on save, and rejects blank or
  whitespace-only values. Legal identity fields from onboarding remain
  separate: date of birth and gender stay readonly, and last name is private.

### 2.5.9

- Profile range edit sheets keep discrete slider divisions for valid age/pace
  values, but hide RangeSlider tick marks so the track reads as a continuous
  control instead of a broken/dotted line.

### 2.5.8

- Profile Preview now bridges the inner `ProfileCard` leading overscroll back
  to the route-owned `NestedScrollView` controller, so dragging down from the
  top of the preview card reveals the Profile header continuously.

### 2.5.7

- Profile Edit and Preview tabs now share `profileTabBodyPadding`: 20 px
  horizontal, 8 px top, and 32 px bottom. Preview applies that inset inside its
  filled body so the card gap is persistent when its internal scroll returns to
  the top.

### 2.5.6

- Profile preview keeps its card inset inside the `SliverFillRemaining` child
  instead of as outer `SliverPadding`, so the top gap under the pinned tab bar
  returns after the user scrolls the preview card down and back to top.

### 2.5.5

- Profile tab labels are now `Edit` and `Preview`. The screen title already
  says `Profile`, so the tab row no longer repeats the word profile.

### 2.5.4

- `ChipField<T>` now gives multi-select sheets an explicit selected-state
  affordance by rendering a leading check icon on selected chips. Single-select
  chip fields keep the previous selected-chip treatment without a checkmark.

### 2.5.3

- `ProfileScreen` now explicitly preserves the `NestedScrollView` overlap
  contract: the scroll-away title remains a normal outer sliver, the pinned
  Edit/Preview tab row is wrapped in `SliverOverlapAbsorber`, and each tab
  `CustomScrollView` starts with a matching `SliverOverlapInjector`.

### 2.5.2

- `_SingleEnumEditSheet<T>` now separates persisted selection from a temporary
  pending chip tap. Immediate-save single-choice sheets show an inline saving
  indicator while the mutation is pending, and failed saves clear the pending
  highlight instead of making an unsaved nullable field look selected.

### 2.5.1

- `AppShellActiveTab` moved from `app_shell.dart` to
  `app_shell_active_tab.dart` and is now the shared retained-tab lifecycle
  primitive.
- `AppShell` no longer prewarms the Clubs list stream. Clubs, Catches, Chats,
  and Profile tab roots use the active-tab lifecycle signal to avoid watching
  screen-owned streams while their indexed-stack branch is inactive.

### 2.5.0

- Removed `CatchErrorText` instead of retaining it as a compatibility layer.
  Migrated remaining call sites to `CatchErrorState`, `CatchErrorScaffold`, or
  `CatchInlineErrorState` with feature context and retry callbacks where the
  provider seam is obvious.

### 2.4.9

- Added the canonical app-facing error primitive family: `CatchErrorState`,
  `CatchErrorScaffold`, `CatchSliverErrorState`, `CatchInlineErrorState`, and
  `showCatchErrorSnackBar`.
- `AsyncValueWidget` / `AsyncValueSliverWidget` now default to branded error
  states.

### 2.4.8

- Profile edit sheets now save before dismissing, show loading/error state while
  `ProfileEditController.saveFieldsMutation` is pending, and optional
  single-choice sheets open with no selected chip when the profile field is
  empty.
- `ChipField` now supports disabled state so modal choices can be locked while
  profile edits are saving.

### 2.4.7

- `ProfilePromptCard` now uses the same label/value typography hierarchy as
  the rest of Edit Profile instead of oversized prompt-card title text.

### 2.4.6

- Profile safe-area ownership moved to the route boundary so the pinned
  Edit/Preview row stays below the Dynamic Island without reserving a visible
  top-inset gap while the title header is expanded.

### 2.4.5

- Profile's pinned Edit/Preview tab row now reserves the top safe area when it
  sticks, and the route uses native `TabBarView` paging instead of manually
  swapping tab bodies at the end of a horizontal drag.

### 2.4.4

- Profile edit surfaces now keep signup identity fields readonly after
  onboarding, expose Instagram editing, and treat public profile names as
  first-name-only projections.

### 2.4.3

- `ProfileCard`/`ScrollableProfile` now accept an explicit preview scroll
  controller and keep the internal card scroll view non-primary so sliver route
  parents do not steal or share its vertical offset.

### 2.4.2

- Profile edit sheets now route text validation, keyboard/autofill behavior,
  bounded height edits, and open-ended age display/storage through shared
  profile validation helpers.

### 2.4.1

- `AppShell` now exposes the active bottom-tab index through
  `AppShellActiveTab` so retained indexed-stack branches can pause expensive
  screen-level listeners while inactive.
- `DashboardScreen` is now `ConsumerStatefulWidget` so Home can invalidate the
  booked-runs stream when the Home tab is no longer active and reopen it when
  the user returns.

### 2.4.0

- Home/Dashboard now owns run-arrival actions. Participant `Check in` and host
  `Take Attendance` render as the first dashboard content card when their time
  windows are active.
- Run detail bottom CTAs keep booking lifecycle actions only; arrival actions
  have moved to Home.

### 2.3.0

- Calendar is now a single sliver-native scroll surface. Its header and agenda
  scroll together instead of using a fixed header plus nested agenda scroll.
- `RunAgendaList` / `RunAgendaSliverList` now support `preserveInputOrder` for
  callers that need a precomputed semantic order, such as upcoming-first
  calendar agendas.

### 2.2.0

- Dashboard full and empty states are now sliver-native.
- Added `DashboardSliverHeader` to the inventory as the dashboard-specific
  wrapper around the shared `CatchSliverHeader` contract.

### 2.1.0

- Added `WIDGET-CATALOG-001` to the recursive audit rules.
- Future passes must update this catalog when they add, delete, move, rename, or
  materially change a widget, primitive API, screen ownership model,
  sliver/tab structure, or reusable design-system role.
- Tiny implementation-only edits do not require catalog changes when inventory
  and usage guidance stay the same.

### 2.0.0

- Widget inventory is versioned under the recursive audit loop.
- Active workflow rules moved to the audit registry and widget cleanup tracker
  so future passes can read deltas instead of the full catalog.

## Widget Cleanup Operating Instructions

### User Request

The user wants an ongoing architecture and widget-system cleanup of the Flutter
app. The goal is to make screens and widgets easier to maintain, easier to test,
and easier to apply a brand/design system to by reducing duplicate local UI
implementations and consolidating reusable patterns into appropriate shared
primitives.

The user specifically wants this work to proceed incrementally:

- Keep a single source of truth for the work in `docs/widget_cleanup_todo.md`.
- Keep appending newly discovered work, recommendations, and bug fixes to that
  tracker even when they are outside the current pass.
- Prefer controller-owned business logic and repository writes, while allowing
  widgets to own local UI concerns such as focus, scroll, animations, navigation,
  and temporary input state.
- Standardize nomenclature around `user_profile`, not `my_profile`.
- Clean up heavily duplicated widgets and screens in small verified batches.
- Expand scope to adjacent widgets, repositories, controllers, or tests when
  needed to make the cleanup coherent.
- Treat tests as design feedback, not just verification. Whenever a feature,
  repository, controller, provider, widget, or primitive is tested and the loop
  is closed, use the test structure, complexity, and brittleness to decide
  whether the implementation should be reshaped toward better readability,
  composability, performance, and testability.
- Treat documentation as part of the architecture. Prefer updating
  `docs/README.md`, `docs/widget_cleanup_todo.md`, this catalog, or another
  existing source-of-truth doc over creating a new markdown file. If a temporary
  audit/report produces durable guidance, migrate that guidance into the owning
  doc and delete the stale report.
- Ask questions only when the answer cannot be inferred safely from the repo or
  when a product/design decision would materially affect the implementation.

### How To Proceed

1. Start every pass by reading this section and
   `docs/widget_cleanup_todo.md`.
2. For broad cleanup passes, run `bash tool/widget_cleanup_scan.sh` before
   editing and again before wrapping up. Treat the output as a triage report,
   not a lint gate: inspect each match, fix high-signal repeated smells, and
   refine the scanner when it becomes noisy.
3. Inspect the target feature plus adjacent shared widgets, controllers, and
   tests before editing.
4. Identify duplicated local UI implementations that block design-system work:
   cards, empty states, bottom sheets, rows, rails, section scaffolds, loading
   states, mutation feedback, and one-off action surfaces.
5. Prefer existing primitives before creating new ones. Important current
   primitives include `CatchSurface`, `CatchButton`, `CatchTextField`,
   `CatchTopBar`, `CatchBottomSheetScaffold`, `CatchEmptyState`,
   `CatchHorizontalRail`, `CatchVerticalSection`, `PersonRow`, `PersonAvatar`,
   `RunCard`, `SettingsRow`, `CatchSkeleton`, `CatchBadge`, `StatusChip`,
   `CatchFormFieldLabel`, `ChipField`, `RunAgendaList`,
   `RunAgendaSliverList`, `MutationErrorSnackbarListener`, and
   `showConfirmDangerDialog`.
6. Add a new primitive only when at least one of these is true:
   repeated UI shells are already present, a primitive removes meaningful
   complexity, the API is likely to be reused soon, or the component expresses a
   durable design-system concept.
7. Keep feature-specific content local. Consolidate shells and patterns, not
   every line of UI copy or layout.
8. Do not over-abstract early. If only one surface needs a helper, use a private
   helper first and promote it later after a second concrete use appears.
9. Name shared primitives by their durable semantic role, not by a temporary
   feature use or purely visual treatment. The name should make the widget easy
   to search for and easy to reason about in future cleanup passes.
10. Keep business logic, repository writes, and product decisions in controllers
   unless there is a clear reason for local widget ownership.
11. Keep screens thin by default. A screen should usually compose feature
   content, route parameters, scaffold/top-bar structure, and local Flutter UI
   mechanics. Move provider state dispatch, repository writes, mutation
   callbacks, and product behavior into feature widgets, providers, or
   controllers unless the local screen ownership is explicit and justified.
12. Put state dispatch in a semantic feature content widget when the screen would
   otherwise become a large `AsyncValue.when` switch. The content widget should
   own loading, error, empty, and data composition for that feature surface.
13. Keep feature widgets single-purpose. A search field should be a search field;
   the parent layout should decide whether it sits next to a city picker,
   filter, or action.
14. Put side-effect feedback close to the trigger. For mutation snackbars and
   banners, wrap the widget that starts the mutation rather than the whole
   screen when feasible.
15. Do not pass `WidgetRef` through helper methods. If a helper needs `ref`,
   make it a `ConsumerWidget`, `ConsumerStatefulWidget`, controller method, or
   provider.
16. Feature-specific sliver headers should wrap generic primitives with feature
   configuration baked in, while keeping layout-only private helper widgets in
   the header file.
17. Keep platform and plugin side effects behind provider/controller seams where
   feasible. Current examples include `ExternalLinkController`,
   `ExternalShareController`, `PaymentConfirmationController`,
   `UpdateRequiredController`, `CreateRunClubController`, and app-shell
   provider seams.
18. Keep status out of this catalog. Pending, completed, next-up, and scanner
   snapshots belong in `docs/widget_cleanup_todo.md`; this file should describe
   reusable instructions, anti-patterns, widget inventory, and durable
   consolidation guidance.
19. After each meaningful batch, update `docs/widget_cleanup_todo.md` with:
   completed items, newly discovered backlog items, current findings, and the
   recommended next step.
20. After tests pass, inspect how the tests had to be written. If they required
   fragile finders, excessive provider overrides, private implementation
   knowledge, awkward setup, timing hacks, or broad integration scaffolding for
   narrow behavior, treat that as architecture feedback. Refactor or add a
   backlog item so future passes move the code toward clearer seams, smaller
   units, stable user-visible assertions, and easier dependency injection.
21. Update this catalog in the same pass when adding, deleting, moving,
   renaming, or materially changing widgets, primitive APIs, screen ownership
   models, sliver/tab structures, or reusable design-system roles. Skip catalog
   edits only for tiny implementation-only changes that do not affect inventory
   or usage guidance.
22. Verify with focused commands over touched files and relevant tests. Fix
   analyzer errors and warnings. Do not spend cleanup time on analyzer
   info-level issues unless they block the task, mask a real bug, or are already
   being edited for another reason.

### Recurring Anti-Patterns

Use this list as an active checklist during each pass. It should grow as more
patterns are discovered.

- Prop drilling theme tokens. Prefer `CatchTokens.of(context)` inside leaf
  widgets instead of passing `CatchTokens` through constructors.
- Hand-built bottom-sheet shells instead of `CatchBottomSheetScaffold`.
- Hand-built empty states instead of `CatchEmptyState`.
- Hand-built rails/sections instead of `CatchHorizontalRail` or
  `CatchVerticalSection`.
- General-purpose helpers stranded in feature folders instead of `core/widgets`.
- Widgets calling repositories or owning product behavior that belongs in a
  controller.
- Feature screens owning provider state dispatch, mutation callbacks, or
  mutation error feedback that would be clearer in semantic feature content
  widgets.
- Passing `WidgetRef` through helper methods instead of introducing a provider,
  controller method, or `ConsumerWidget` boundary.
- Nesting unrelated widgets together because they share a row or section. Layout
  belongs to the parent; single-purpose widgets should stay single-purpose.
- Duplicating feature-specific sliver header setup instead of baking feature
  configuration into a small wrapper around the shared header primitive.
- Hiding location/GPS or other product behavior in broad screen shells instead
  of putting it in the widget/controller/provider that actually needs it.
- Screen files mixing composition with repeated row/sheet/card plumbing.
- One-off `Container`/`BoxDecoration` card shells where `CatchSurface`,
  `RunCard`, `PersonRow`, `SettingsRow`, or another existing primitive fits.
- Bypassing feature-owned provider/view-model seams to call lower-level
  providers directly.
- Tests coupled to incidental nested-scroll implementation details instead of
  stable user-visible behavior.
- Passing tests that are hard to write, hard to read, slow, broad, flaky, or
  tightly coupled to private implementation details. These are signals that the
  feature may need better seams, clearer controller/provider boundaries, smaller
  widgets, or more semantic primitives.
- Split design-system ownership across `lib/constants`, top-level `lib/theme`,
  and `lib/core/theme`. New design tokens, spacing helpers, typography, app
  theme, motion, radii, and icon sizing should live under `lib/core/theme`.
- Declared controller mutations that the UI does not actually use. If a
  controller exposes a `Mutation`, the triggering widget should normally run the
  action through that mutation so loading/error/success behavior is observable
  and testable.
- Custom interactive widgets without semantic keys, tooltips, or labels. Any
  button-like tile, photo slot, swipe action, segmented action, or grid cell
  that users tap should have a stable semantic target before tests are written
  around it.
- Platform or plugin side effects embedded directly in widgets. Store launches,
  connectivity subscriptions, FCM initialization, and similar runtime effects
  should sit behind providers/controllers so they can be tested and replaced in
  harnesses.
- Share sheets, external URL launches, image pickers, and platform/store
  actions called directly from presentation widgets. Put these behind a small
  provider/controller seam so tests can replace the side effect and the widget
  only chooses when the action is requested.
- No local feedback loop for recurring cleanup smells. When the same
  anti-pattern appears repeatedly, add or refine a lightweight repo-local
  scanner/checklist, then keep it high-signal enough that future passes will
  actually use it.
- Scanner output that cannot distinguish real widget smells from valid
  controller/provider seams. Cleanup scans should exclude generated files,
  controllers, notifiers, and data layers where appropriate so they point at
  surfaces that actually need design-system attention.

### Catalog Ownership

This catalog is the durable widget inventory and cleanup playbook. It should
not carry the active backlog; use `docs/widget_cleanup_todo.md` for pending,
completed, next-up, scanner snapshots, and findings. Keep this file current
when widgets are added, deleted, moved, renamed, or when a shared primitive or
controller seam becomes part of the standard operating model.

Current durable direction:

- Theme, typography, spacing compatibility helpers, radii, and app theme belong
  under `lib/core/theme`.
- Run-club detail uses the shared agenda UI instead of a two-dimensional
  schedule grid.
- Normal leaf widgets should read `CatchTokens.of(context)` locally instead of
  receiving token objects through constructors.
- URL/share/store/image-picking side effects should go through controller or
  provider seams before reaching plugins.
- Broad cleanup passes should use `tool/widget_cleanup_scan.sh` as a triage
  aid, then update the tracker with what was fixed or intentionally deferred.

---

Every StatefulWidget, StatelessWidget, ConsumerWidget, and ConsumerStatefulWidget in `lib/`, grouped by feature area with a short description of what each widget does.

Generated 2026-05-06.

---

## App Entry Point

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `MyApp` | `lib/app.dart:17` | Root widget. Watches `goRouterProvider`, `forceUpdateRequiredProvider`, and `locationInitializerProvider`. Renders `MaterialApp.router` with Catch-theming, localization, and a force-update gate that shows `UpdateRequiredScreen` when the app version is below the remote minimum. Also renders an environment `Banner` in non-prod builds. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_ForceUpdateLifecycleWrapper` | `lib/app.dart:93` | Re-fetches Firebase Remote Config when the app is foregrounded so the force-update gate stays fresh during long-running sessions. Uses `WidgetsBindingObserver` to listen to `AppLifecycleState.resumed`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ForceUpdateCheckLoadingScreen` | `lib/app.dart:141` | Scaffold with centered `CatchLoadingIndicator` shown while the force-update check is loading. |
| `_ForceUpdateCheckErrorScreen` | `lib/app.dart:150` | Error screen shown when the force-update check fails. Displays a "Could not verify app version" message with a retry button and optional diagnostic info. |

---

## Core — Presentation (AppShell & Routing)

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShell` | `lib/core/presentation/app_shell.dart:33` | Main tab shell with a `NavigationBar` (Home, Clubs, Catches, Chats, Profile). Watches provider-backed connectivity for the offline banner, initializes FCM through `appShellFcmInitializationProvider`, exposes active-tab state through `AppShellActiveTab`, and keeps Crashlytics user ID synced with auth state. Shell-level streams stay limited to shell-wide UI such as auth, connectivity, FCM, and unread badges. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShellActiveTab` | `lib/core/presentation/app_shell_active_tab.dart:9` | Inherited lifecycle signal for indexed-stack tabs. Lets retained tab branches detect whether they are currently selected without coupling feature screens directly to `StatefulNavigationShell`. |
| `_AppShellNavigationBar` | `lib/core/presentation/app_shell.dart:101` | Private bottom-navigation wrapper with stable key and unread chat badge handling. |
| `_ConnectivityBanner` | `lib/core/presentation/app_shell.dart:165` | Inline keyed `MaterialBanner` shown at the top of the shell when provider-backed connectivity reports offline. |
| `_RouterLoadingScreen` | `lib/routing/go_router.dart:438` | Minimal scaffold with `CatchLoadingIndicator` shown during route-level async data resolution. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunRouteScreen` | `lib/routing/go_router.dart:447` | Route wrapper that fetches a `RunClub` by ID and delegates to `CreateRunScreen`. Shows a loading screen or error text while the club resolves. |
| `EditRunClubRouteScreen` | `lib/routing/go_router.dart:475` | Route wrapper that fetches a `RunClub` by ID and delegates to `CreateRunClubScreen` for editing. Same loading/error pattern. |

---

## Core — Design System Widgets

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchTextField` | `lib/core/widgets/catch_text_field.dart:12` | Canonical text input. Wraps `FormField<String>` + `TextField` in a token-driven shell with label, helper/error copy, prefix/suffix icons, clear button, stable single-line control heights, initial-value syncing, and theming via `CatchTextFieldSize`, `CatchTextFieldShape`, and `CatchTextFieldTone` enums. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, and `danger` variants; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; and an optional leading icon. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown for `Labelled` enum-like values. Wraps `FormField<T>` + `DropdownButton<T>` with focus-ring styling and label decoration. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:11` | Canonical top-bar. Renders a surface-fill bar with an optional back button (auto-detected from `Navigator.canPop`), title, leading widget, and action slots. Also supports a `bottom` `PreferredSizeWidget` (e.g., `TabBar`). Implements `PreferredSizeWidget` for use as an `AppBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:132` | Catch-styled `TabBar` for use inside `CatchTopBar.bottom` or sticky sliver headers. Uses `primary` indicator color and `labelL` text styles, implements `PreferredSizeWidget`, and accepts an optional explicit `TabController` for sliver-native tab rows that are not inside a `DefaultTabController`. |
| `CatchSliverHeader` | `lib/core/widgets/catch_top_bar.dart:290` | Shared sliver header primitive. Builds a scroll-away title and optional pinned bottom row; the title translates upward as it collapses so sticky search/filter/tab rows do not visually cover it. Used by Run Clubs, Chats, and Profile. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:156` | Overflow menu action for `CatchTopBar`. Renders a `PopupMenuButton<T>` wrapped in an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Renders a `TextButton` in primary color. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:44` | Pill-style segmented control. Active segment gets dark background with light text; inactive segments are transparent. Used for Day/Agenda calendar switching and Grid/List view toggling. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchHorizontalRail` | `lib/core/widgets/catch_horizontal_rail.dart:12` | Section with a `SectionHeader` title and a horizontally-scrolling `ListView.separated` of items. Supports optional trailing content and custom header/list padding for embedded layouts. |
| `CatchVerticalSection` | `lib/core/widgets/catch_vertical_section.dart:25` | Section with a `SectionHeader` title and a vertical `ListView.separated` of items (non-scrollable, meant for embedding in a parent scroll view). |
| `CatchLoadingIndicator` | `lib/core/widgets/catch_loading_indicator.dart:3` | Simple centered `CircularProgressIndicator` for use during async loading states. |
| `CatchFrameworkErrorView` | `lib/core/widgets/catch_framework_error_view.dart:9` | Branded fallback view used by `ErrorWidget.builder` for Flutter framework/build errors. Shows user-safe recovery copy and keeps debug exception details behind a disclosure in debug builds. |
| `CatchErrorState` | `lib/core/widgets/catch_error_state.dart:11` | Canonical branded app-facing error content. Supports full-screen, inline, and compact modes, mapped title/message copy, optional retry, and optional secondary action. |
| `CatchErrorScaffold` | `lib/core/widgets/catch_error_state.dart:118` | Full-screen/root-tab wrapper for load failures. Keeps framework crashes separate from app data-load failures. |
| `CatchSliverErrorState` | `lib/core/widgets/catch_error_state.dart:171` | Sliver-native branded error state. Uses `SliverFillRemaining` by default and supports retry callbacks for provider invalidation. |
| `CatchInlineErrorState` | `lib/core/widgets/catch_error_state.dart:227` | Compact branded error surface for sections/cards that fail while the rest of the screen remains usable. |
| `ErrorMessageWidget` | `lib/core/widgets/async_value_widget.dart:99` | Deprecated compatibility widget. Prefer `CatchErrorState`. |
| `AsyncValueWidget<T>` | `lib/core/widgets/async_value_widget.dart:17` | Generic widget handling `AsyncValue` states: loading (defaults to `CatchLoadingIndicator`), branded error state by default, and data (custom builder). |
| `AsyncValueSliverWidget<T>` | `lib/core/widgets/async_value_widget.dart:56` | Sliver equivalent of `AsyncValueWidget`. Defaults to `CatchSliverErrorState` for errors. |
| `CatchFormFieldLabel` | `lib/core/widgets/catch_form_field_label.dart:5` | Styled form field label with an optional badge (e.g., "Optional"). |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Tag/chip widget. Supports active/inactive states, an optional remove button, and Catch-themed coloring. Used in `ChipField` and independently for vibe tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Small label badge used for spots-left indicators, distance/pace pills, etc. Supports `solid`, `neutral`, and `outline` tones. |
| `IconBtn` | `lib/core/widgets/icon_btn.dart:22` | Circular 40x40 icon button used as the base for `CatchTopBar*Action` widgets. Renders `Material` + `InkWell` with a center-aligned child. |
| `BottomCTA` | `lib/core/widgets/bottom_cta.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content and bottom safe-area padding. |
| `CatchBottomSheetScaffold` | `lib/core/widgets/catch_bottom_sheet.dart:7` | Shared bottom-sheet shell with grabber, optional title/subtitle, keyboard-safe padding, content, and an optional action slot. |
| `CatchCelebrationScreen` | `lib/core/celebration/catch_celebration_screen.dart:37` | Shared full-screen celebration surface for high-emotion completion moments. Feature screens provide moment kind, copy, details, optional supplemental children, and primary/secondary actions; the primitive dispatches celebration effects once after first frame. |
| `CelebrationEffectsController` | `lib/core/celebration/celebration_effects_controller.dart:10` | Central haptic/sound boundary for celebration moments. Currently dispatches haptics by `CelebrationMomentKind`; future sound work should be added here instead of directly in feature widgets. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Shared empty-state primitive with icon, title, message, optional action, and surface/plain presentation modes. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, keeps the parent-owned `selected` set, supports disabled state for pending mutation sheets, and shows a leading check icon on selected chips only in multi-select mode. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Simple row with a label and value, used in detail/read-only views. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
| `showCatchErrorSnackBar` | `lib/core/widgets/catch_error_snackbar.dart:4` | Snackbar helper for transient action failures. Maps errors through `appErrorMessage` before display. |
| `SectionHeader` | `lib/core/widgets/section_header.dart:4` | Section header with uppercase or mixed-case title, optional heavy weight. |
| `StatusChip` | `lib/core/widgets/status_chip.dart:14` | Colored chip displaying run status (open, booked, full, cancelled, attending, waitlisted, not-going, attended, missed). |
| `StatColumn` | `lib/core/widgets/stat_column.dart:5` | Vertical stat display — value on top, label below. Used in run stats grids and profile sections. |
| `AppFormLayout` | `lib/core/widgets/app_form_layout.dart:3` | Form layout wrapper with consistent padding and spacing for form screens. |
| `BottomSheetGrabber` | `lib/core/widgets/bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets. |
| `PersonRow` | `lib/core/widgets/person_row.dart:77` | Multipurpose person row. In chat-thread mode (when `lastMessage` is non-null), renders name, timestamp, context line, last message, and unread badge. In roster mode, renders name, meta line, context line, and an optional trailing widget. Used in chat inbox, rosters, waitlists, and catches previews. |
| `_ChatLayout` | `lib/core/widgets/person_row.dart:136` | Internal chat-thread layout for `PersonRow` — name + timestamp row, run-context row, last-message + unread-badge row. |
| `_RosterLayout` | `lib/core/widgets/person_row.dart:228` | Internal roster layout for `PersonRow` — name + meta line + context line (run icon). |
| `PersonAvatar` | `lib/core/widgets/person_avatar.dart:33` | Circular avatar with deterministic gradient fallback derived from name hash. Supports image URL, colored border ring (for match state or stacking), and an online status dot. Named constructor `PersonAvatar.count` shows a "+N" overflow bubble. |
| `_GradientPlaceholder` | `lib/core/widgets/person_avatar.dart:162` | Deterministic gradient placeholder for avatars without a photo. Picks from 12 palettes based on a hash of the name. |
| `ResponsiveBuilder` | `lib/core/responsive/responsive_builder.dart:22` | Thin wrapper around `LayoutBuilder` that maps available width to `ScreenSize` (compact/medium/expanded) and calls the appropriate builder. Falls back gracefully when tablet/desktop builders are absent. |
| `RunCard` | `lib/core/widgets/run_card.dart:94` | Versatile run card rendered at three densities: `compact` (small row with distance badge), `standard` (vertical card with photo/map header and roster strip), and `hero` (full-bleed card with large photo, title, vibe tags, and roster strip). |
| `_CompactCard` | `lib/core/widgets/run_card.dart:136` | Compact RunCard variant — distance badge + when/location + price. |
| `_StandardCard` | `lib/core/widgets/run_card.dart:195` | Standard RunCard variant — photo header, club name, location, time, roster strip with Join CTA. |
| `_HeroCard` | `lib/core/widgets/run_card.dart:291` | Hero RunCard variant — large photo, club name, vibe tags, location, time, roster strip. |
| `_PhotoHeader` | `lib/core/widgets/run_card.dart:389` | Map/photo header shared by standard + hero cards. Renders a custom map widget, hero image, or stylized map placeholder. Overlays spot-left badge, dist/pace pill, status chip, and stacked attendee avatars. |
| `_StackedAvatars` | `lib/core/widgets/run_card.dart:456` | Horizontally stacked circular avatars with overlap and an overflow "+N" bubble. |
| `_RosterRow` | `lib/core/widgets/run_card.dart:503` | Roster strip at the bottom of standard + hero cards showing "N/M runners" and a "Join →" CTA pill. |
| `_MapPlaceholder` | `lib/core/widgets/run_card.dart:547` | Stylized faux map painted with `CustomPaint` — land, water, roads, city blocks, a park, and a primary-colored route overlay. |
| `_ButtonLabel` | `lib/core/widgets/catch_button.dart:141` | Internal label+icon row for `CatchButton`. |
| `_LoadingDots` | `lib/core/widgets/catch_button.dart:193` | Three animated dots shown during `CatchButton`'s loading state. |
| `SettingsRow` | `lib/core/widgets/settings_row.dart:25` | Settings-style row with icon, label, optional value, optional trailing widget (e.g., `Switch`), and a danger mode (primary-colored text). |

---

## Dashboard

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:18` | Home tab. Watches the user's profile and signed-up runs only while Home is active. Owns the Home `TabController`, `NestedScrollView`, collapsible greeting/empty header, pinned `Dashboard`/`Activity` tab row, and native `TabBarView` paging. Invalidates the booked-runs stream when the shell moves away from Home, then reopens it when the user returns. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:21` | Standalone full-dashboard wrapper used by focused tests/non-tab embedding. Renders the full dashboard header plus `DashboardFullSliverBody`. |
| `DashboardFullSliverBody` | `lib/dashboard/presentation/widgets/dashboard_full.dart:85` | Sliver body for the Dashboard tab: first-priority run-arrival action card, next-run hero, attended-run section (`StrideCard` + `CatchesCallout`), `QuickActions`, and recommended runs. Activity is intentionally not rendered here. |
| `ActivitySliverBody` | `lib/dashboard/presentation/widgets/activity_section.dart:19` | Sliver adapter for the Home Activity tab. Applies the tab body inset and renders `ActivitySection` as the tab-owned notifications/update timeline. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:53` | Timeline-style activity feed for unread messages, catches, and upcoming run reminders. Uses a branded inline error state with retry and delegates "Mark all read" to `ActivityController`. |
| `CatchesCallout` | `lib/dashboard/presentation/widgets/catches_callout.dart:11` | Dashboard card promoting the active catch window — shows the run name, remaining time, roster count, and a "Start catching" CTA. |
| `NextRunHero` | `lib/dashboard/presentation/widgets/next_run_hero.dart:11` | Hero card showing the user's next upcoming run with location, time, price, and a "View run" CTA. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Horizontal rail of `RecommendCard` widgets for recommended runs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:11` | Compact recommended-run card with club name, location, date, and price. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Row of quick-action buttons (e.g., "Find a Run", "Join a Club"). |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Standalone empty-dashboard wrapper used by focused tests/non-tab embedding. Renders the empty dashboard header plus `DashboardEmptySliverBody`. |
| `DashboardEmptySliverBody` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:116` | Sliver body for the empty Dashboard tab. Keeps the existing "book your first run" education flow without embedding activity updates. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Hero card variant shown on the empty dashboard prompting the user to book their first run. |
| `DashedAvatar` | `lib/dashboard/presentation/widgets/dashed_avatar.dart:7` | Dashed-border circular avatar placeholder used in empty-state layouts. |
| `RunArrivalActionCard` | `lib/dashboard/presentation/widgets/run_arrival_action_card.dart:17` | First-priority Home card for active run-arrival tasks. Shows participant self check-in or host attendance actions and routes mutations/navigation through `RunBookingController` / router seams. Participant self-check-in opens `RunCheckInCelebrationScreen`; host attendance intentionally does not. |
| `StaticMapDark` | `lib/dashboard/presentation/widgets/static_map_dark.dart:3` | Static map image widget with dark mode support. |

### Sliver Helpers

| Helper | File | Purpose |
|---|---|---|
| `DashboardSliverHeader` | `lib/dashboard/presentation/widgets/dashboard_sliver_header.dart:7` | Dashboard-specific wrapper around `CatchSliverHeader`. Keeps the home greeting/onboarding header visually consistent while allowing it to scroll away with the dashboard content, and can pin the shared `Dashboard`/`Activity` tab row when a controller is provided. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:221` | Loading scaffold for Home while profile/booked-run data resolves. |
| `_DashboardErrorScreen` | `lib/dashboard/presentation/dashboard_screen.dart:232` | Branded error scaffold for Home profile/booked-run load failures. |
| `_DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_full.dart:161` | Inline loading/error card for a dashboard section (e.g., "Loading your recent runs..."). |
| `_ActivityTile` | `lib/dashboard/presentation/widgets/activity_section.dart:171` | Single row in the Activity timeline — icon marker, title, subtitle, relative time, and optional route. |
| `_ActivityTimelineMarker` | `lib/dashboard/presentation/widgets/activity_section.dart:245` | Timeline rail marker for activity rows. Uses the primary color for unread/high-priority activity and the soft primary surface for normal activity. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:299` | Status label shown for the loading activity state. |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:18` | Main swipe screen. Manages a `CardSwiperController`, watches the swipe queue provider, and renders swipeable profile cards with pass/like action buttons. Handles swipe direction logic (right = like, left = pass). |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:19` | Swipe filters screen. Owns local draft slider/chip state, saves through `FiltersController.saveFiltersMutation`, exposes semantic filter keys, and pops on successful save. |
| `RunRecapScreen` | `lib/swipes/presentation/run_recap_screen.dart:23` | Post-run recap screen showing run details and a checked-in attendee vibe grid. Uses keyed vibe tiles, `CatchSurface` for the recap hero, and `CatchEmptyState` for an empty attendee roster. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:22` | "Catches" tab. Gates screen-owned streams while the retained tab branch is inactive, lists attended runs with open catch windows, uses leaf widgets to read theme tokens locally, shows a `CatchSurface` intro card for the featured run, and lists active runs with `AttendedRunTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:17` | Full-length scrollable profile card body used on swipe/public/profile-preview surfaces. Keeps the shared rendering path identical across Swipes and Profile Preview, renders the hero photo first, promotes the bio prompt, keeps running identity as a first-class dark card, then renders detail chips/photos/lifestyle. Its internal vertical scroll view is non-primary, can accept an explicit controller when embedded in a sliver route, and can report leading overscroll to a parent route for collapsible-header coordination. |
| `ProfileCard` | `lib/swipes/presentation/profile_card.dart:7` | The primary public-facing dating card. Wraps `ScrollableProfile` in a dark immersive card shell with themed border/shadow, keeps Swipes and Profile Preview visually identical, and overlays swipe stamps during deck gestures. Accepts an optional scroll controller for owner routes such as Profile Preview and can forward leading overscroll when embedded below a collapsible parent header. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:221` | Keyed attendee tile on the recap screen. Fetches its public profile, exposes tooltip/semantic selected state, and toggles local recap selection. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub — header, intro card for the featured run, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the run" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book a run. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo section inside the shared `ProfileCard`. The hero photo may be edge-to-edge with the dark gradient and name overlay; additional photos should be inset with consistent card margins, rounded corners, and spacing. Shows a branded "Photo coming soon" fallback when the user has no usable image. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Hero overlay for public display name, age, and optional city. Keep relationship goal, distance, and runner metadata out of the hero and in lower profile sections. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:61` | Legacy/specialized goal chip styling retained for profile-card contexts that need a pill, but the default shared card now renders relationship goal as a detail chip rather than hero overlay text. |
| `ProfileCardPalette` | `lib/swipes/presentation/widgets/profile_card_style.dart:4` | Local palette helper for the immersive dark profile card. It adapts accent, border, chip, fallback, and shadow colors to the active app light/dark theme while keeping the card itself dark. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:6` | Section of detail chips on the shared profile card. Relationship goal lives here; city stays on the hero overlay, and distance appears here only when current/profile locations are available. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:8` | Reusable dark section card wrapper for profile detail sections. Uses `ProfileCardPalette` rather than app surface colors so sections stay coherent inside the immersive card. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:6` | Prominent bio/prompt section on the shared card. Uses `ON A PERFECT RUN` as the prompt label and appears before running stats. |
| `ProfileRunningSection` | `lib/swipes/presentation/widgets/profile_running_section.dart:6` | Supplemental running preference chips only when they add content not already present in `_RunningIdentityCard`. Do not duplicate pace or preferred-distance values already shown in the canonical `RUN PROFILE` summary card. |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single info chip on the profile card — icon + label. |
| `SwipeActionButtons` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:5` | Pass and Like action buttons at the bottom of the swipe screen with stable keys, tooltips, and semantic labels. |
| `SwipeCircleButton` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:45` | Individual circular swipe action button (pass = X, like = heart). Reads theme tokens locally. |
| `SwipeStamp` | `lib/swipes/presentation/widgets/swipe_stamp.dart:15` | "LIKE" or "NOPE" stamp overlay that appears during swipe gestures. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedRunTile` | `lib/swipes/presentation/widgets/attended_run_tile.dart:14` | Row tile for an attended run in the catches hub list — shows run title, date, location, and a CTA arrow. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Canonical dark `RUN PROFILE` summary card inside `ScrollableProfile`. Retain this as the single first-class running identity section; it should use `ProfileCardPalette` in light and dark app themes and own the high-signal pace/distance summary. |
| `_RunStatPill` | `lib/swipes/presentation/widgets/scrollable_profile.dart:137` | Small stat pill inside the running identity card. |
| `_RecapHero` | `lib/swipes/presentation/run_recap_screen.dart:127` | `CatchSurface` hero section of the run recap screen — run name, distance, checked-in count, and catch-window status. |
| `_RecapStat` | `lib/swipes/presentation/run_recap_screen.dart:182` | Single stat counter on the recap screen (e.g., "12 Likes", "4 Matches"). |
| `_ProfilePhoto` | `lib/swipes/presentation/run_recap_screen.dart:295` | Single profile photo in the recap attendee grid. |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Empty state when the recap roster has no one. |
| `_FilterSection` | `lib/swipes/presentation/filters_screen.dart:264` | Collapsible section in the filters screen (header + expandable body). |
| `_FilterValue` | `lib/swipes/presentation/filters_screen.dart:296` | Single selectable filter value tile. |

---

## Matches / Chats

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:11` | "Chats" tab. Gates screen-owned streams while the retained tab branch is inactive, then renders the chat conversations list with a sliver header (search + new matches rail) and the list of `ChatListTile` widgets. |
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:13` | Sliver body for chat conversations fed from `ChatsListViewModel`. Uses a padded skeleton loading sliver, empty/error states, and delegates populated data to `ChatsListBody`. |
| `MatchCelebrationDialog` | `lib/matches/presentation/widgets/match_celebration_dialog.dart:41` | Compatibility-named full-screen match celebration route. Uses `CatchCelebrationScreen` with match haptics, then routes the primary action into `ChatScreen` or dismisses back to swiping. |
| `ChatListTile` | `lib/matches/presentation/chat_list_tile.dart:9` | Single chat thread row in the inbox. Shows `PersonRow` in chat-thread mode with name, last message, timestamp, unread badge, and on-tap navigation to `ChatScreen`. |
| `ChatNewMatchesRail` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:10` | Horizontal rail of new match avatars at the top of the chats list. |
| `_NewMatchAvatar` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:40` | Single new-match avatar in the rail — circular photo with name. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Search text field for filtering chats list. |
| `ChatConversationsList` | `lib/matches/presentation/widgets/chat_conversations_list.dart:8` | The actual `ListView` of chat tiles, driven by `ChatsListViewModel`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations. |
| `ChatsListBody` | `lib/matches/presentation/widgets/chats_list_body.dart:7` | Body wrapper for the chats list (manages scroll controller, etc.). |
| `_TitleRow` | `lib/matches/presentation/widgets/chats_sliver_header.dart:16` | "Chats" title row in the chats sliver header. |
| `_SearchRow` | `lib/matches/presentation/widgets/chats_sliver_header.dart:70` | Pinned search-field row in the chats sliver header. Reserves enough height for the shared compact `CatchTextField`. |

---

## Chat Screen

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatScreen` | `lib/chats/presentation/chat_screen.dart:21` | Thin route-facing wrapper for a chat thread. Accepts the route match id and optional routed profile, then delegates thread state and composition to `_ChatContent`. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_ChatContent` | `lib/chats/presentation/chat_screen.dart:33` | Stateful chat-thread content. Owns local text/scroll controllers and mounted lifecycle effects, watches match/run/profile/message providers, and routes send/image/report/block actions through `ChatController` mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ChatMutationListeners` | `lib/chats/presentation/chat_screen.dart:288` | Mutation snackbar boundary for chat send/send-image/report/block errors. Keeps mutation feedback out of the rendering widgets. |
| `ChatTopBar` | `lib/chats/presentation/widgets/chat_top_bar.dart:10` | Chat app bar with avatar/name title and menu actions for profile/report/block. Navigation stays in the top-bar action because it is route UI, while safety actions are callbacks into the controller layer. |
| `ChatRunContextHeader` | `lib/chats/presentation/widgets/chat_run_context_header.dart:9` | Header inside the chat showing the shared run context — run icon, run name, and date. |
| `ChatMessageList` | `lib/chats/presentation/widgets/chat_message_list.dart:11` | Message-list renderer for loading, error, empty, and populated states. Uses `CatchEmptyState` for empty threads and `MessageBubble` for individual messages. |
| `ChatInputBar` | `lib/chats/presentation/widgets/chat_input_bar.dart:7` | Message input bar with text field, image picker button, and send button. |
| `MessageBubble` | `lib/chats/presentation/widgets/message_bubble.dart:6` | Single chat message bubble. Renders differently for sent vs. received messages (alignment, color, corner rounding). Shows timestamp and optional image attachment. |

---

## Public Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreen` | `lib/public_profile/presentation/public_profile_screen.dart:16` | Full-screen public profile view. Fetches `PublicProfile` by UID, renders the shared `ProfileCard`, and routes report/block actions through `PublicProfileController` mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ProfileBody` | `lib/public_profile/presentation/public_profile_screen.dart:192` | Body of the public profile with a shared profile card and pending-action overlay. |
| `_ReportReasonTile` | `lib/public_profile/presentation/public_profile_screen.dart:218` | Single selectable report reason row. |

---

## User Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileScreen` | `lib/user_profile/presentation/profile_screen.dart:16` | Profile tab destination. Gates screen-owned streams while the retained tab branch is inactive, owns the route-level top safe area, uses `NestedScrollView` for a scroll-away Profile title header plus pinned `Edit`/`Preview` tab row, and native `TabBarView` paging for smooth horizontal tab swipes. The scroll-away title remains a normal outer sliver; the pinned tab row is wrapped in `SliverOverlapAbsorber`; each tab body starts with `SliverOverlapInjector`. Owns the `TabController` locally because tab selection is route UI state. |
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:19` | Standalone profile tab content. Wraps the shared profile sections in a `ListView` for isolated/non-sliver usage. Uses `profileTabBodyPadding` for the shared Profile tab inset. `Display name` is the first editable About field and is the only public-facing profile name; onboarding identity fields such as date of birth and gender are readonly, and last name is not shown publicly. Optional/profile-detail fields, including Instagram, remain editable. Optional single-choice edit sheets open unselected when the underlying field is empty. |
| `ProfileTabSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:48` | Sliver-native profile tab body. Reuses the same profile sections as `ProfileTab` but contributes a padded `SliverList` for parent `CustomScrollView` usage. Uses the same `profileTabBodyPadding` as Preview. |
| `_OverflowMenu` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:109` | Overflow menu in the scroll-away profile title header (payments, sign out). |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared swipe `ProfileCard`, with owner-provided scroll and leading-overscroll callbacks when mounted inside ProfileScreen. |
| `ProfileInfoSection` | `lib/user_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows with a section header. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:6` | Single tappable info row — icon, label, value, chevron. Opens the corresponding edit sheet on tap. |
| `ProfilePromptCard` | `lib/user_profile/presentation/widgets/profile_prompt_card.dart:6` | Editable profile prompt card used by the signed-in profile bio section. Keeps its text hierarchy aligned with profile info rows: subdued body label plus body value/placeholder text. |
| `_ProfileUnavailableBody` | `lib/user_profile/presentation/profile_screen.dart:103` | Missing-profile state. Prevents the profile route from rendering a blank body when the signed-in user profile is unavailable. |
| `_PreviewTabSliverBody` | `lib/user_profile/presentation/profile_screen.dart:120` | Sliver-native preview body. Gives the shared `ProfileCard` bounded remaining viewport height inside the profile route's preview tab scroll view, passes a dedicated card scroll controller, applies `profileTabBodyPadding` inside the filled child so the card inset persists when the card scrolls back to top, and bridges card leading overscroll to the outer Profile header. |
| `_ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:29` | Scroll-away Profile title row with settings and overflow actions. |
| `_ProfileTabBar` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:66` | Pinned Edit/Preview tab bar surface for the sliver-native profile route. The route-level `SafeArea` keeps it below device cutouts without adding an expanded-header gap. |
| `_SettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:96` | Settings gear button in the scroll-away profile title header. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_TextEditSheet` | `lib/user_profile/presentation/widgets/profile_edit_sheet.dart:101` | Modal text editor for profile fields. Accepts field-specific keyboard, capitalization, autofill, shared validators from `profile_validation.dart`, optional value normalization, and save-before-pop mutation feedback. Keeps the sheet open with inline error feedback on failed saves. |
| `_HeightEditSheet` | `lib/user_profile/presentation/widgets/profile_edit_sheet.dart:225` | Bounded height editor using minus/plus controls instead of free-text input. Saves only values between the shared profile height minimum and maximum, locks controls while saving, and closes only after persistence succeeds. |
| `_SingleEnumEditSheet<T>` | `lib/user_profile/presentation/widgets/profile_edit_sheet.dart:345` | Optional single-choice profile editor. Preserves an empty visual selection when the field is null, saves the tapped chip through `ProfileEditController`, shows inline pending feedback while saving, clears optimistic pending highlight on failed saves, and closes only after the mutation succeeds. |
| `_MultiEnumEditSheet<T>` | `lib/user_profile/presentation/widgets/profile_edit_sheet.dart:460` | Multi-choice profile editor. Owns local selected-chip state, disables chips while saving, and persists through the profile edit mutation before dismissing. |
| `_RangeEditSheet` | `lib/user_profile/presentation/widgets/profile_edit_sheet.dart:568` | Range editor for age and pace preferences. Owns temporary slider state, normalizes open-ended age storage, disables the slider while saving, keeps discrete divisions for valid steps, hides slider tick marks for a continuous track, and closes only after the mutation succeeds. |

---

## Onboarding

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OnboardingScreen` | `lib/onboarding/presentation/onboarding_screen.dart:16` | Multi-step onboarding flow shell. Manages step navigation via `PageController`, renders the step progress bar, and delegates to individual step pages. |
| `NameDobPage` | `lib/onboarding/presentation/pages/name_dob_page.dart:11` | Name and date-of-birth entry page — text field + date picker. |
| `GenderInterestPage` | `lib/onboarding/presentation/pages/gender_interest_page.dart:12` | Gender identity and interest selection page using `ChipField` with semantic chip keys for self-identification vs interested-in selections. |
| `RunningPrefsPage` | `lib/onboarding/presentation/pages/running_prefs_page.dart:15` | Running preferences page — pace, distance, days, goals, and experience level. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomePage` | `lib/onboarding/presentation/pages/welcome_page.dart:10` | Landing/welcome page shown at the start of onboarding — app logo, tagline, and "Get started" button. |
| `PhotosPage` | `lib/onboarding/presentation/pages/photos_page.dart:13` | Photo upload page — renders `PhotoGrid` for the user to add/remove profile photos. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_OnboardingTopBar` | `lib/onboarding/presentation/onboarding_screen.dart:94` | Top bar for onboarding screens — back button (when applicable) + optional "Skip" text action. |
| `_ProgressBar` | `lib/onboarding/presentation/onboarding_screen.dart:138` | Horizontal progress bar showing current step in the onboarding flow. |
| `OnboardingStepHeader` | `lib/onboarding/presentation/widgets/onboarding_step_header.dart:5` | Title + subtitle header for each onboarding step page. |
| `_TrackPattern` | `lib/onboarding/presentation/pages/welcome_page.dart:81` | Decorative track/route pattern shown on the welcome page background. |
| `OnboardingFormKeys` | `lib/onboarding/presentation/onboarding_form_keys.dart:4` | Stable semantic keys for onboarding form controls whose visible labels repeat across sections. |

---

## Auth

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthScreen` | `lib/auth/presentation/auth_screen.dart:7` | Phone-auth flow shell. Watches `AuthController.step` and switches between phone entry and OTP entry without owning local UI state. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `PhonePage` | `lib/auth/presentation/phone_page.dart:16` | Phone number entry step. Owns local text field state, uses `AuthController.sendOtpMutation`, and exposes stable auth form keys for the phone field/send action. |
| `OtpPage` | `lib/auth/presentation/otp_page.dart:17` | OTP entry step. Owns OTP field focus/timer mechanics, uses `AuthController.verifyOtpMutation`/`sendOtpMutation`, and exposes stable auth form keys for OTP, resend, and change-number actions. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthFormKeys` | `lib/auth/presentation/auth_form_keys.dart:3` | Stable semantic keys for auth form controls and actions. |
| `_OtpDigitField` | `lib/auth/presentation/otp_page.dart:214` | Invisible text field plus visual 6-digit OTP boxes. Reads design tokens locally and forwards changes/submits to `OtpPage`. |
| `_OtpDigitBox` | `lib/auth/presentation/otp_page.dart:287` | Single visual OTP digit box with active-border state. |

---

## Image Uploads

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotoGrid` | `lib/image_uploads/presentation/photo_grid.dart:10` | Grid of profile photo slots. Uses `maxProfilePhotoCount`, keyed slots, and delegates taps to the owning upload caller. |
| `PhotoSlot` | `lib/image_uploads/presentation/widgets/photo_slot.dart:6` | Single keyed photo slot. Renders through `CatchSurface`, exposes semantic labels/tooltips for add/replace/uploading/unavailable states, and blocks taps while inactive or loading. |

---

## Run Clubs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunClubScreen` | `lib/run_clubs/presentation/create/create_run_club_screen.dart:22` | Create/edit run club form. Multi-section form with cover photo picker, details fields, contact fields, and a submit CTA. Handles both create and edit flows (initialized via `initialRunClub`). |
| `CityPicker` | `lib/run_clubs/presentation/list/widgets/city_picker.dart:12` | City selector dropdown at the top of the clubs list. Matches `CatchTextField.compactControlHeight` and pill styling so it aligns visually with `RunClubsSearchField`; watches and updates `selectedRunClubCityProvider`, listens for GPS location updates, and keeps showing the selected city while the remote city list is loading or unavailable. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubDetailScreen` | `lib/run_clubs/presentation/detail/run_club_detail_screen.dart:16` | Run club detail screen. Fetches the club, current user profile, upcoming runs, reviews, and handles membership state via `RunClubMembershipController`. Renders `ClubDetailBody`. |
| `RunClubsList` | `lib/run_clubs/presentation/list/widgets/run_clubs_list.dart:11` | Sliver state-dispatch widget for the clubs tab. Renders skeleton, error, empty, and data slivers from `RunClubsListViewModel` and owns join-mutation feedback. |
| `RunClubsSearchField` | `lib/run_clubs/presentation/list/widgets/run_clubs_search_field.dart:6` | Search text field for filtering the clubs list. |
| `_SearchRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:66` | Search row inside the clubs sliver header. |
| `MembershipButton` | `lib/run_clubs/presentation/detail/widgets/membership_button.dart:6` | Join/Leave/Request membership button on the club detail screen. Calls `RunClubMembershipController`. |
| `MutationErrorSnackbarListener` | `lib/core/widgets/mutation_error_snackbar_listener.dart:13` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used for transient mutation errors such as join/leave club failures. |
| `_DirectoryCard` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:3` | Directory-style club card — larger layout with cover image, host avatar, stats strip, and "Join Club" CTA. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubsListScreen` | `lib/run_clubs/presentation/list/run_clubs_list_screen.dart:11` | "Clubs" tab. Gates screen-owned streams while the retained tab branch is inactive, then renders the clubs sliver header (city picker, search, create button) + `RunClubsList` body. |
| `RunClubsListBody` | `lib/run_clubs/presentation/list/widgets/run_clubs_list_body.dart:7` | Sliver-native data body for the clubs tab. Composes the joined-club horizontal rail and discover sliver list without embedding a vertical `ListView` inside the parent `CustomScrollView`. |
| `RunClubDiscoverList` | `lib/run_clubs/presentation/list/widgets/run_club_discover_list.dart:6` | Discovery section of the clubs list — section header plus a real `SliverList` of directory cards. |
| `RunClubListTile` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile.dart:26` | Club tile rendered as directory card or avatar chip. Display-only tile rendering does not watch provider state; only the join button owns the mutation provider. |
| `RunClubsEmptyState` | `lib/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart:5` | Empty state when no clubs are found. |
| `RunClubAvatarRail` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:9` | Horizontal avatar rail of the user's joined clubs + a create-club button. |
| `_CreateClubButton` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:34` | "+" button at the end of the avatar rail to create a new club. |
| `_TitleRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:22` | "Clubs" title row in the clubs sliver header. |
| `_AddButton` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:50` | "+" button next to the title to create a new club. |
| `ClubHeroAppBar` | `lib/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart:15` | Hero-style app bar for the club detail screen — large cover image, club name, location, and back button. |
| `ClubDetailBody` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:21` | Scrollable club detail body — about section, stats, upcoming runs list, reviews section, and host action panel. |
| `ClubScheduleSection` | `lib/run_clubs/presentation/detail/widgets/club_schedule_section.dart:7` | Sliver-native agenda section for a club's upcoming runs. Reuses `RunAgendaSliverList`, shows empty state when no upcoming runs exist, and routes selected runs to detail. |
| `_HostActionPanel` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:119` | Action panel shown when the current user is the club host — create run, edit club, etc. |
| `_ClubContactSection` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:177` | Contact info section — Instagram, website, WhatsApp, email rows. |
| `_ContactRow` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:228` | Single contact row (icon + label + value). |
| `HostStatsBar` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:7` | Host stats bar — member count, run count, founding date. |
| `HostStatChip` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:83` | Single stat chip in the host stats bar. |
| `StatsStrip` | `lib/run_clubs/presentation/detail/widgets/stats_strip.dart:6` | Horizontal strip of stats — runs hosted, members, location — shown on club cards. |
| `RunClubCoverFallback` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:6` | Gradient + chip fallback shown when a club has no cover photo. |
| `_CoverChip` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:98` | Small distance/location chip overlaid on the cover fallback. |
| `CreateRunClubDetailsFields` | `lib/run_clubs/presentation/create/widgets/create_run_club_details_fields.dart:7` | Club name, description, and location fields for the create/edit form. |
| `CreateRunClubCoverPicker` | `lib/run_clubs/presentation/create/widgets/create_run_club_cover_picker.dart:9` | Cover photo picker for the create/edit club form. |
| `CreateRunClubContactFields` | `lib/run_clubs/presentation/create/widgets/create_run_club_contact_fields.dart:6` | Contact fields (Instagram, WhatsApp, website, email) for the create/edit form. |
| `_ClubImage` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/club_image.dart:3` | Club cover image for list tiles. |
| `_HostAvatar` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:163` | Host avatar shown on directory cards. |
| `_AvatarChip` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/avatar_chip.dart:3` | Small avatar chip with member photo and count. |

---

## Runs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunScreen` | `lib/runs/presentation/create_run_screen.dart:29` | Multi-step run creation flow (When → Where → Details → Eligibility → Review). Manages `PageController`, draft auto-save/restore, local form controllers, and the create-run mutation. On success transitions to `CreateRunSuccessScreen` or `HostRunManageScreen`. |
| `RunMapScreen` | `lib/runs/presentation/run_map_screen.dart:16` | Map route wrapper. Watches `RunMapViewModel`, owns local selected-run state, and composes the map pins plus `RunMapSheet`. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `RunDetailScreen` | `lib/runs/presentation/run_detail_screen.dart:8` | Route-facing run detail entry. Fetches `RunDetailViewModel`, renders scaffolded loading/error/not-found states, and delegates the loaded screen to `RunDetailBody` without nesting scaffolds. |
| `RunDetailBody` | `lib/runs/presentation/widgets/run_detail_body.dart:24` | Scrollable run detail body — owns the loaded detail `Scaffold`, composes `RunDetailHeroAppBar`, `RunDetailOverviewSection`, `RunDetailSocialSection`, and the bottom CTA. |
| `RunDetailCta` | `lib/runs/presentation/widgets/run_detail_cta.dart:21` | Bottom CTA bar for run detail. Owns booking lifecycle actions (book, cancel, waitlist, eligibility, attended/past states) and intentionally omits arrival actions (`Check in`, `Take Attendance`) because those now surface first on Home. Free-run signup opens `RunJoinedCelebrationScreen`; paid signup routes to payment confirmation, which uses the same joined celebration surface. |
| `AttendanceSheetScreen` | `lib/runs/presentation/attendance_sheet_screen.dart:20` | Host-facing attendance sheet. Watches the run stream, renders route-level loading/error/not-found states, and delegates attendance body composition to `_AttendanceList`. |
| `_AttendanceList` | `lib/runs/presentation/attendance_sheet_screen.dart:59` | Attendance body. Handles empty/profile-loading/profile-error states, mutation error banner, checked-in summary, and the attendee list. |
| `_AttendeeRow` | `lib/runs/presentation/attendance_sheet_screen.dart:168` | Single attendance row using `CatchSurface`, `PersonRow`, and `CatchBadge`; routes toggle actions through `RunBookingController.markAttendanceMutation`. |
| `_RunsMap` | `lib/runs/presentation/run_map_screen.dart:81` | The actual Flutter map widget rendering pinned runs. Uses device location only for map centering, not feature data composition. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `LocationPickerScreen` | `lib/runs/presentation/location_picker_screen.dart:8` | Map-based location picker. Lets users long-press or search for a location and returns the selected `LatLng` + address. |
| `_DraftPickerSheet` | `lib/runs/presentation/widgets/draft_picker_sheet.dart:37` | `CatchBottomSheetScaffold` listing saved run drafts. Users can resume, start fresh, or permanently delete persisted drafts through the create-run draft controller. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunSuccessScreen` | `lib/runs/presentation/create_run_success_screen.dart:10` | Host run-created success screen backed by `CatchCelebrationScreen`. Shows live-run confirmation details, run-created haptics, "Manage run", and "Back to club" actions. |
| `RunJoinedCelebrationScreen` | `lib/runs/presentation/run_joined_celebration_screen.dart:7` | User run-signup celebration surface shared by free bookings and post-payment confirmation. Shows run details, optional payment details, supplemental payment actions, haptics, and View run / Back home actions. |
| `RunCheckInCelebrationScreen` | `lib/runs/presentation/run_check_in_celebration_screen.dart:7` | Participant self-check-in celebration surface. Used only after user self-check-in from Home succeeds; host attendance remains a normal operational flow. |
| `RunCheckInLocationService` | `lib/runs/presentation/run_check_in_location_service.dart:5` | Provider-backed location seam for self-check-in. Production uses Geolocator with high accuracy and a timeout; tests can inject coordinates without invoking platform plugins. |
| `HostRunManageScreen` | `lib/runs/presentation/host_run_manage_screen.dart:11` | Host run management screen — shows run stats, summary, profile-backed roster, and waitlist. |
| `CreateRunStepHeader` | `lib/runs/presentation/widgets/create_run_step_header.dart:7` | Header for the create-run wizard — back action, step title, club name, step count, and progress bar. |
| `CreateRunFormKeys` | `lib/runs/presentation/create_run_form_keys.dart:3` | Stable semantic keys for create-run form fields so widget tests target fields by purpose rather than layout order. |
| `_HostRunStatCard` | `lib/runs/presentation/host_run_manage_screen.dart:134` | `CatchSurface` stat card on the manage screen (booked, waitlist, revenue). |
| `_HostRunSummaryCard` | `lib/runs/presentation/host_run_manage_screen.dart:160` | `CatchSurface` summary card showing run details on the host manage screen. |
| `_HostRunSummaryRow` | `lib/runs/presentation/host_run_manage_screen.dart:205` | Single key-value row in the host summary card. |
| `_HostRunUserList` | `lib/runs/presentation/host_run_manage_screen.dart:250` | Profile-backed roster/waitlist list on the host manage screen. Uses `PersonRow`, `CatchBadge`, and `CatchEmptyState`. |
| `_AttendanceSummaryHeader` | `lib/runs/presentation/attendance_sheet_screen.dart:131` | Header row for host attendance showing checked-in count and the toggle hint. |
| `RunAgendaList` | `lib/runs/presentation/widgets/run_agenda_list.dart:9` | Box-facing agenda list for runs grouped by day. Sorts by start time by default, with `preserveInputOrder` for callers that precompute semantic order. |
| `RunAgendaSliverList` | `lib/runs/presentation/widgets/run_agenda_list.dart:41` | Sliver-facing agenda list for runs grouped by day. Sorts by start time by default, with `preserveInputOrder` for sliver-native screens such as Calendar that need upcoming-first ordering. |
| `RunAgendaRunCard` | `lib/runs/presentation/widgets/run_agenda_list.dart:101` | Tappable agenda card for a run — time, meeting point, distance/pace/spots metadata, and optional badge. |
| `WhenStep` | `lib/runs/presentation/widgets/when_step.dart:7` | "When" form step in create run — date + time pickers. |
| `WhereStep` | `lib/runs/presentation/widgets/where_step.dart:8` | "Where" form step — location picker, address display, and map preview. |
| `RunDetailsStep` | `lib/runs/presentation/widgets/run_details_step.dart:9` | "Details" form step — distance, pace, price, capacity, and vibe tags. |
| `EligibilityStep` | `lib/runs/presentation/widgets/eligibility_step.dart:9` | "Eligibility" form step — gender, age, and experience requirements. |
| `StepProgressBar` | `lib/runs/presentation/widgets/step_progress_bar.dart:4` | Horizontal step indicator showing current step out of total. |
| `StepperFooter` | `lib/runs/presentation/widgets/stepper_footer.dart:5` | Footer with Back/Next buttons for the create-run stepper. |
| `WhenWhereCard` | `lib/runs/presentation/widgets/when_where_card.dart:8` | Read-only card showing when/where info (used on draft previews and recap). |
| `RunStatsGrid` | `lib/runs/presentation/widgets/run_stats_grid.dart:8` | Grid of stat cells (distance, pace, elevation, etc.) for run detail. |
| `RunStatCell` | `lib/runs/presentation/widgets/run_stats_grid.dart:39` | Single stat cell with value + label. |
| `RunStatDivider` | `lib/runs/presentation/widgets/run_stats_grid.dart:81` | Vertical divider between stat cells. |
| `RunDetailHeroAppBar` | `lib/runs/presentation/widgets/run_detail_hero_app_bar.dart:7` | Sliver hero app bar for run detail. Owns the photo/map hero, back/share controls, and saved-run icon state. |
| `RunDetailOverviewSection` | `lib/runs/presentation/widgets/run_detail_overview_section.dart:10` | Static run facts section for the loaded run detail body: title, pace/date, stats, when/where, description, and requirements. |
| `RunDetailSocialSection` | `lib/runs/presentation/widgets/run_detail_social_section.dart:10` | Social context section for the loaded run detail body: roster, guest lock prompt, divider, and reviews for signed-in users. |
| `RunMapSheet` | `lib/runs/presentation/widgets/run_map_sheet.dart:12` | Overlay sheet for map runs. Uses `CatchSurface`, renders horizontal run chips, and routes the highlighted run to detail. |
| `RunPhotoHeader` | `lib/runs/presentation/widgets/run_photo_header.dart:6` | Photo/map header for the run detail screen. |
| `MapPinTile` | `lib/runs/presentation/widgets/map_pin_tile.dart:7` | Route map + pin display tile. |
| `PickerTile` | `lib/runs/presentation/widgets/picker_tile.dart:6` | Tappable tile that opens a picker (date, time, etc.) — shows label + selected value. |
| `DurationStepper` | `lib/runs/presentation/widgets/duration_stepper.dart:6` | +/- stepper for selecting duration. |
| `RequirementsRow` | `lib/runs/presentation/widgets/requirements_row.dart:7` | Read-only row showing eligibility requirements. |
| `FieldLabel` | `lib/runs/presentation/widgets/field_label.dart:4` | Styled label for form fields in the create-run flow. |
| `_DraftCard` | `lib/runs/presentation/widgets/draft_picker_sheet.dart:161` | `CatchSurface` draft card in the draft picker sheet — shows run summary, relative save time, and delete state. |
| `PriceLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:246` | Price display widget shown as leading content in `RunDetailCta` (price + "incl. coffee"). |
| `BookedLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:270` | "You're booked" badge shown when the user already booked. |
| `AttendedLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:287` | "You attended" badge shown for past attended runs. |
| `_MapEmptyState` | `lib/runs/presentation/run_map_screen.dart:155` | `CatchEmptyState` shown when the current user has no signed-up or recommended runs for the map. |

---

## Calendar

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:18` | Calendar route for booked runs. Uses one sliver-native scroll surface, derives an upcoming-first calendar summary, anchors the header to the next upcoming run or current week, and manages local view mode state (`agenda` vs `timeline`). |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarHeader` | `lib/calendar/presentation/calendar_screen.dart:86` | Calendar header inside the route's sliver scroll surface — month label, `CatchSegmentedControl`, week strip, and `CatchSurface` stats row. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:179` | Horizontal week strip showing 7 days with date indicators. Anchors to the next upcoming run, or to the current week when there is no upcoming run. |
| `_WeekDay` | `lib/calendar/presentation/calendar_screen.dart:211` | Single day cell in the week strip — day name, date number, and active indicator. |
| `_TimelineSliverList` | `lib/calendar/presentation/calendar_screen.dart:265` | Sliver-native day/timeline view of booked runs using the same upcoming-first ordering as agenda mode. |
| `_TimelineRun` | `lib/calendar/presentation/calendar_screen.dart:290` | Single `CatchSurface` run block in the timeline view — time, meeting point, distance, and pace. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:360` | Divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:375` | Calendar empty/error state rendered through `CatchEmptyState`. |
| `_CalendarRunSummary` | `lib/calendar/presentation/calendar_screen.dart:398` | Private view model for calendar display order and header stats. Splits upcoming vs past runs, puts upcoming runs first, uses current week as the fallback anchor, and exposes `nextRun`. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:22` | Post-payment confirmation route. Loads the run/club context and delegates the success UI to `RunJoinedCelebrationScreen`, adding payment quick actions, heads-up copy, referral share, and the stable Back home key. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:47` | Thin payment confirmation adapter that composes `RunJoinedCelebrationScreen` with paid-run supplemental children and router actions. |
| `PaymentConfirmationKeys` | `lib/payments/presentation/payment_confirmation_keys.dart:3` | Stable semantic keys for confirmation quick actions, referral share, and sticky back-home CTA. |
| `PaymentHistoryScreen` | `lib/payments/presentation/payment_history_screen.dart:20` | List of past payment transactions. Watches `watchPaymentsForUserProvider`, renders `_PaymentTile` items, and shows transaction details in `CatchBottomSheetScaffold`. |
| `_PaymentList` | `lib/payments/presentation/payment_history_screen.dart:42` | The list view of payment tiles. |
| `_PaymentTile` | `lib/payments/presentation/payment_history_screen.dart:74` | Single semantic payment transaction row — amount, date, run name, and status. Tapping opens the detail bottom sheet. |
| `PaymentHistoryKeys` | `lib/payments/presentation/payment_history_keys.dart:3` | Stable semantic payment-history tile keys for tests and future automation. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_QuickActions` | `lib/payments/presentation/payment_confirmation_screen.dart:86` | Row of quick-action tiles (add to calendar, directions, invite a friend) shown inside the run-joined celebration. |
| `_ActionTile` | `lib/payments/presentation/payment_confirmation_screen.dart:124` | Private icon-based `CatchSurface` quick-action tile. Keep private until this semantic component has a second concrete use. |
| `_HeadsUp` | `lib/payments/presentation/payment_confirmation_screen.dart:166` | `CatchSurface` info box about arrival/run-day expectations. |
| `_ReferralBanner` | `lib/payments/presentation/payment_confirmation_screen.dart:197` | Tappable `CatchSurface` referral banner shown inside the run-joined celebration. |

---

## Safety / Settings

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SettingsScreen` | `lib/safety/presentation/settings_screen.dart:26` | Full settings screen. Manages optimistic notification toggle state, wraps settings mutations in shared snackbar error feedback, delegates writes to `SettingsController`, and composes account, discovery, notification, safety, about, and delete-account sections. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `_BlockedAccountsSection` | `lib/safety/presentation/settings_screen.dart:345` | Section listing blocked accounts. Uses `CatchLoadingIndicator` for loading, `CatchEmptyState` for empty/error states, and renders `_BlockedAccountTile` rows for blocked users. |
| `_BlockedAccountTile` | `lib/safety/presentation/settings_screen.dart:404` | Single blocked account row. Resolves the blocked user's public profile, renders a `PersonRow`, and routes the semantic unblock button through `SettingsController.unblockUserMutation`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_SettingsSection` | `lib/safety/presentation/settings_screen.dart:311` | Private section helper that pairs a `SectionHeader` with the shared settings card shell. |
| `_SettingsCard` | `lib/safety/presentation/settings_screen.dart:329` | Private `CatchSurface` wrapper for settings row groups. |
| `SettingsKeys` | `lib/safety/presentation/settings_keys.dart:3` | Stable semantic keys for settings switches, delete-account row, and blocked-user unblock buttons. |
| `showConfirmDangerDialog` | `lib/core/widgets/confirm_danger_dialog.dart:4` | Shared destructive confirmation dialog helper used by safety/account actions such as block and delete-account confirmations. |

---

## Force Update

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `UpdateRequiredScreen` | `lib/force_update/presentation/update_required_screen.dart:15` | Blocking full-screen prompting the user to update the app. Reads store URLs from `AppVersionConfig`, delegates store URL selection/launching to `UpdateRequiredController`, and shows a snackbar if launch fails. The user cannot dismiss this screen. |
| `UpdateRequiredController` | `lib/force_update/presentation/update_required_controller.dart:18` | Provider-backed controller for choosing the platform store URL and launching it through an injectable `StoreLauncher`. |

---

## Reviews

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:39` | Bottom sheet for writing, editing, or deleting a run review. Uses `CatchBottomSheetScaffold`, semantic star/action keys, inline mutation errors, and `WriteReviewController` submit/delete mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ReviewsSection` | `lib/reviews/presentation/reviews_section.dart:22` | Section header, rating summary, empty state, preview list, see-all sheet, and write/edit review CTA for run-scoped reviews. |
| `ReviewCard` | `lib/reviews/presentation/reviews_section.dart:177` | Single tokenized review surface with reviewer avatar/name, star rating, optional comment, and edit action for the current user's own review. |
| `StarRating` | `lib/reviews/presentation/star_rating.dart:5` | Read-only token-colored 5-star display. Clamps rating values into the valid visual range. |
| `StarRatingPicker` | `lib/reviews/presentation/star_rating.dart:31` | Semantic/tappable 5-star picker. Supports caller-provided keys for stable widget tests and exposes tooltip/semantics labels per rating. |
| `ReviewKeys` | `lib/reviews/presentation/review_keys.dart:3` | Stable semantic keys for review write/edit/delete/submit actions, comment field, see-all button, and rating stars. |

---

## Summary

| Type | Count |
|---|---|
| `ConsumerStatefulWidget` | 19 |
| `ConsumerWidget` | 42 |
| `StatefulWidget` | 4 |
| `StatelessWidget` | ~150 |

---

## Consolidation Candidates

Keep this section current and conservative. It is for durable consolidation
ideas that still appear valid after the widget cleanup passes, not for active
status. Move any selected item into `docs/widget_cleanup_todo.md` before
implementing it.

### High Signal

| Candidate | Current State | Recommended Direction |
|---|---|---|
| `FieldLabel` | Thin create-run wrapper around `CatchFormFieldLabel(large: true)`. | Delete only if call sites stay clearer with direct `CatchFormFieldLabel`; otherwise keep as a create-run semantic wrapper. |
| `_DashboardLoadingScreen`, `_RouterLoadingScreen`, route-level loading scaffolds | Several screens still create a full-screen loading scaffold by hand. | Consider `CatchLoadingScreen` only if another pass touches two or more route-level loading screens together. |
| `_DashboardMessageScreen`, route-level error/message scaffolds | Message screens are similar but not identical. | Consider `CatchMessageScreen` with optional title/body/action if repeated route-level message screens continue to grow. |
| `ChatsSliverHeader`, `RunClubsSliverHeader` | Feature-specific wrappers around `CatchSliverHeader` still share structure. | Parameterize the shared sliver header only if a third feature needs the same title/search/action pattern. |
| `ProfileInfoChip` | Swipe profile chip overlaps conceptually with `CatchChip`, but has overlay styling needs. | Extend `CatchChip` only if overlay-style info chips recur outside swipes. |

### Watch, Do Not Force

| Candidate | Reason To Wait |
|---|---|
| Feature empty-state wrappers | Most now delegate to `CatchEmptyState`. Keep wrappers when they encode feature-specific copy/content semantics; inline only when the wrapper adds no meaning. |
| `StatColumn`, `RunStatCell`, `HostStatChip` | They share a value-over-label concept, but baseline alignment and surface ownership differ enough that forced unification may reduce clarity. |
| `StatusChip` and `CatchBadge` | `StatusChip` is enum-driven and semantic; `CatchBadge` is a general label primitive. Rebuild `StatusChip` on `CatchBadge` only if it removes real styling drift. |
| `VibeTag` and `CatchChip` | Different interaction and visual roles. Keep separate unless a broader chip/token audit proves they should converge. |
