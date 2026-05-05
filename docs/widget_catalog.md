# Widget Catalog

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
   `RunCard`, `SettingsRow`, `CatchSkeleton`, `CatchBadge`, and `StatusChip`.
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
17. After each meaningful batch, update `docs/widget_cleanup_todo.md` with:
   completed items, newly discovered backlog items, current findings, and the
   recommended next step.
18. After tests pass, inspect how the tests had to be written. If they required
   fragile finders, excessive provider overrides, private implementation
   knowledge, awkward setup, timing hacks, or broad integration scaffolding for
   narrow behavior, treat that as architecture feedback. Refactor or add a
   backlog item so future passes move the code toward clearer seams, smaller
   units, stable user-visible assertions, and easier dependency injection.
19. Update this catalog when adding, deleting, moving, or materially changing
   widgets.
20. Verify with focused commands over touched files and relevant tests. Fix
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

### Current Direction

The `CreateRunScreen` split, host-manage roster cleanup, create-run draft UX,
create-run testability pass, run-clubs list/layout pass, chat thread/list pass,
run-detail route/body pass, run map, attendance, run-club detail schedule
cleanup, Auth UI cleanup, design-system theme-folder consolidation,
Safety/settings UI cleanup, Reviews UI cleanup, Swipes deep pass, image
uploads/photo grid cleanup, force-update/app-shell cleanup, and the first
external link/share side-effect seam cleanup are complete. A recursive cleanup
scanner now lives at `tool/widget_cleanup_scan.sh` and should be used to keep
future passes focused on repeated anti-patterns instead of relying only on
manual memory. The scanner's `CatchTokens` prop-drilling category is currently
clear after moving onboarding/dashboard leaf widgets to local token reads.
Run-club detail no longer uses a
two-dimensional schedule grid; it reuses the shared agenda UI and receives
upcoming runs sorted by the detail view model. Theme, typography, spacing
compatibility helpers, and app theme now live under `lib/core/theme`.

---

Every StatefulWidget, StatelessWidget, ConsumerWidget, and ConsumerStatefulWidget in `lib/`, grouped by feature area with a short description of what each widget does.

Generated 2026-05-05.

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
| `AppShell` | `lib/core/presentation/app_shell.dart:48` | Main tab shell with a `NavigationBar` (Home, Clubs, Catches, Chats, You). Watches provider-backed connectivity for the offline banner, initializes FCM through `appShellFcmInitializationProvider`, pre-warms the clubs list stream, and keeps Crashlytics user ID synced with auth state. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_AppShellNavigationBar` | `lib/core/presentation/app_shell.dart:119` | Private bottom-navigation wrapper with stable key and unread chat badge handling. |
| `_ConnectivityBanner` | `lib/core/presentation/app_shell.dart:183` | Inline keyed `MaterialBanner` shown at the top of the shell when provider-backed connectivity reports offline. |
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
| `CatchTextField` | `lib/core/widgets/catch_text_field.dart:12` | Canonical text input. Wraps `FormField<String>` + `TextField` in a token-driven shell with label, helper/error copy, prefix/suffix icons, clear button, and theming via `CatchTextFieldSize`, `CatchTextFieldShape`, and `CatchTextFieldTone` enums. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, and `danger` variants; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; and an optional leading icon. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown for `Labelled` enum-like values. Wraps `FormField<T>` + `DropdownButton<T>` with focus-ring styling and label decoration. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:11` | Canonical top-bar. Renders a surface-fill bar with an optional back button (auto-detected from `Navigator.canPop`), title, leading widget, and action slots. Also supports a `bottom` `PreferredSizeWidget` (e.g., `TabBar`). Implements `PreferredSizeWidget` for use as an `AppBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:132` | Catch-styled `TabBar` for use inside `CatchTopBar.bottom`. Uses `primary` indicator color and `labelL` text styles. Implements `PreferredSizeWidget`. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:156` | Overflow menu action for `CatchTopBar`. Renders a `PopupMenuButton<T>` wrapped in an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Renders a `TextButton` in primary color. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:44` | Pill-style segmented control. Active segment gets dark background with light text; inactive segments are transparent. Used for Day/Agenda calendar switching and Grid/List view toggling. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchHorizontalRail` | `lib/core/widgets/catch_horizontal_rail.dart:12` | Section with a `SectionHeader` title and a horizontally-scrolling `ListView.separated` of items. Supports optional trailing content and custom header/list padding for embedded layouts. |
| `CatchVerticalSection` | `lib/core/widgets/catch_vertical_section.dart:25` | Section with a `SectionHeader` title and a vertical `ListView.separated` of items (non-scrollable, meant for embedding in a parent scroll view). |
| `CatchLoadingIndicator` | `lib/core/widgets/catch_loading_indicator.dart:3` | Simple centered `CircularProgressIndicator` for use during async loading states. |
| `CatchErrorText` | `lib/core/widgets/catch_error_text.dart:4` | Minimal error display widget — renders error text centered with error color. |
| `ErrorMessageWidget` | `lib/core/widgets/async_value_widget.dart:77` | Simple centered error message text widget used as the default error builder inside `AsyncValueWidget`. |
| `AsyncValueWidget<T>` | `lib/core/widgets/async_value_widget.dart:16` | Generic widget handling `AsyncValue` states: loading (defaults to `CatchLoadingIndicator`), error (defaults to `ErrorMessageWidget`), and data (custom builder). |
| `AsyncValueSliverWidget<T>` | `lib/core/widgets/async_value_widget.dart:47` | Sliver equivalent of `AsyncValueWidget`. Renders loading/error states inside `SliverToBoxAdapter`. |
| `CatchFormFieldLabel` | `lib/core/widgets/catch_form_field_label.dart:5` | Styled form field label with an optional badge (e.g., "Optional"). |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Tag/chip widget. Supports active/inactive states, an optional remove button, and Catch-themed coloring. Used in `ChipField` and independently for vibe tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Small label badge used for spots-left indicators, distance/pace pills, etc. Supports `solid`, `neutral`, and `outline` tones. |
| `IconBtn` | `lib/core/widgets/icon_btn.dart:22` | Circular 40x40 icon button used as the base for `CatchTopBar*Action` widgets. Renders `Material` + `InkWell` with a center-aligned child. |
| `BottomCTA` | `lib/core/widgets/bottom_cta.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content and bottom safe-area padding. |
| `CatchBottomSheetScaffold` | `lib/core/widgets/catch_bottom_sheet.dart:7` | Shared bottom-sheet shell with grabber, optional title/subtitle, keyboard-safe padding, content, and an optional action slot. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Shared empty-state primitive with icon, title, message, optional action, and surface/plain presentation modes. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, and keeps the parent-owned `selected` set. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Simple row with a label and value, used in detail/read-only views. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
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
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:9` | Home tab. Watches the user's profile and signed-up runs. Renders `DashboardFull` when there are runs, `DashboardEmpty` when there aren't, and loading/error screens while async data resolves. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:20` | Full dashboard content: greeting header with avatar, next-run hero, attended-run section (StrideCard + CatchesCallout), QuickActions, recommended runs section, and ActivitySection. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:18` | Scroll of past activities (runs + swipes) with tiles showing date, run info, participant avatars, and match count. |
| `CatchesCallout` | `lib/dashboard/presentation/widgets/catches_callout.dart:11` | Dashboard card promoting the active catch window — shows the run name, remaining time, roster count, and a "Start catching" CTA. |
| `NextRunHero` | `lib/dashboard/presentation/widgets/next_run_hero.dart:11` | Hero card showing the user's next upcoming run with location, time, price, and a "View run" CTA. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Horizontal rail of `RecommendCard` widgets for recommended runs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:11` | Compact recommended-run card with club name, location, date, and price. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Row of quick-action buttons (e.g., "Find a Run", "Join a Club"). |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Empty state shown when the user has no booked runs — prompts them to find their first run. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Hero card variant shown on the empty dashboard prompting the user to book their first run. |
| `DashedAvatar` | `lib/dashboard/presentation/widgets/dashed_avatar.dart:7` | Dashed-border circular avatar placeholder used in empty-state layouts. |
| `StaticMapDark` | `lib/dashboard/presentation/widgets/static_map_dark.dart:3` | Static map image widget with dark mode support. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:39` | Loading scaffold for the dashboard. |
| `_DashboardMessageScreen` | `lib/dashboard/presentation/dashboard_screen.dart:48` | Error message scaffold for the dashboard. |
| `_DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_full.dart:189` | Inline loading/error card for a dashboard section (e.g., "Loading your recent runs..."). |
| `_ActivityTile` | `lib/dashboard/presentation/widgets/activity_section.dart:142` | Single row in the activity section — shows run date, club name, participant avatars, match count, and participant list. |
| `_ActivityMessage` | `lib/dashboard/presentation/widgets/activity_section.dart:211` | Empty or error message inside the activity section. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:250` | Status label shown on past activity tiles (e.g., "You attended", "You missed"). |

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
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:19` | "Catches" tab. Lists attended runs with open catch windows, uses leaf widgets to read theme tokens locally, shows a `CatchSurface` intro card for the featured run, and lists active runs with `AttendedRunTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:17` | Full-length scrollable profile card used on the swipe screen. Renders running identity, bio, photos, attributes, running/lifestyle sections. |
| `ProfileCard` | `lib/swipes/presentation/profile_card.dart:7` | The primary swipe card. Shows the user's photos (via `CardPhotoSection`), name overlay, and attribute chips in a card layout. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:221` | Keyed attendee tile on the recap screen. Fetches its public profile, exposes tooltip/semantic selected state, and toggles local recap selection. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub — header, intro card for the featured run, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the run" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book a run. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo carousel section inside the swipe `ProfileCard`. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Name + age overlay at the bottom of the swipe card photo with goal pill. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:56` | Small chip showing the user's running goal. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:5` | Section of attribute chips (pace, distance, club) on the swipe card. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:5` | Reusable section card wrapper for profile detail sections. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:4` | Bio text section on the swipe card / profile. |
| `ProfileRunningSection` | `lib/swipes/presentation/widgets/profile_running_section.dart:6` | Running preferences section (pace, distance, days, etc.). |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single info chip on the profile card — icon + label. |
| `SwipeActionButtons` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:5` | Pass and Like action buttons at the bottom of the swipe screen with stable keys, tooltips, and semantic labels. |
| `SwipeCircleButton` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:45` | Individual circular swipe action button (pass = X, like = heart). Reads theme tokens locally. |
| `SwipeStamp` | `lib/swipes/presentation/widgets/swipe_stamp.dart:15` | "LIKE" or "NOPE" stamp overlay that appears during swipe gestures. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedRunTile` | `lib/swipes/presentation/widgets/attended_run_tile.dart:14` | Row tile for an attended run in the catches hub list — shows run title, date, location, and a CTA arrow. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Card inside `ScrollableProfile` showing the user's running identity (pace, distance, frequency). |
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
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:8` | "Chats" tab. Renders the chat conversations list with a sliver header (search + new matches rail) and the list of `ChatListTile` widgets. |
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:13` | Sliver body for chat conversations fed from `ChatsListViewModel`. Uses a padded skeleton loading sliver, empty/error states, and delegates populated data to `ChatsListBody`. |
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
| `ProfileScreen` | `lib/user_profile/presentation/profile_screen.dart:13` | "You" tab. Renders the user's own profile with a sliver header (avatar, name, city), tab bar (Profile / Preview), and tab content. |
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:17` | Editable profile tab content — info sections, prompt cards, and edit sheets for each field. |
| `_OverflowMenu` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:56` | Overflow menu in the profile sliver header (settings, payments, sign out). |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared swipe `ProfileCard`. |
| `ProfileInfoSection` | `lib/user_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows with a section header. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:6` | Single tappable info row — icon, label, value, chevron. Opens the corresponding edit sheet on tap. |
| `ProfilePromptCard` | `lib/user_profile/presentation/widgets/profile_prompt_card.dart:6` | Editable profile prompt card used by the signed-in profile bio section. |
| `_ProfileTabScrollView` | `lib/user_profile/presentation/profile_screen.dart:71` | Private helper that applies the `NestedScrollView` overlap injector around each profile tab body. |
| `_ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:26` | Name + city title in the profile sliver header. |
| `_SettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:43` | Settings gear button in the profile header. |

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
| `CityPicker` | `lib/run_clubs/presentation/list/widgets/city_picker.dart:11` | City selector dropdown at the top of the clubs list. Watches and updates `selectedRunClubCityProvider`, listens for GPS location updates, and keeps showing the selected city while the remote city list is loading or unavailable. |

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
| `RunClubsListScreen` | `lib/run_clubs/presentation/list/run_clubs_list_screen.dart:6` | "Clubs" tab. Renders the clubs sliver header (city picker, search, create button) + `RunClubsList` body. |
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
| `RunDetailCta` | `lib/runs/presentation/widgets/run_detail_cta.dart:24` | Bottom CTA bar for run detail. Consumes host state from `RunDetailViewModel`, supports deterministic time-window tests via optional `now`, and shows booking/cancel/waitlist/check-in/attendance states. |
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
| `CreateRunSuccessScreen` | `lib/runs/presentation/create_run_success_screen.dart:10` | Success confirmation screen after creating a run — shows live-run confirmation and a "Manage run" CTA. |
| `HostRunManageScreen` | `lib/runs/presentation/host_run_manage_screen.dart:11` | Host run management screen — shows run stats, summary, profile-backed roster, and waitlist. |
| `CreateRunStepHeader` | `lib/runs/presentation/widgets/create_run_step_header.dart:7` | Header for the create-run wizard — back action, step title, club name, step count, and progress bar. |
| `CreateRunFormKeys` | `lib/runs/presentation/create_run_form_keys.dart:3` | Stable semantic keys for create-run form fields so widget tests target fields by purpose rather than layout order. |
| `_HostRunStatCard` | `lib/runs/presentation/host_run_manage_screen.dart:134` | `CatchSurface` stat card on the manage screen (booked, waitlist, revenue). |
| `_HostRunSummaryCard` | `lib/runs/presentation/host_run_manage_screen.dart:160` | `CatchSurface` summary card showing run details on the host manage screen. |
| `_HostRunSummaryRow` | `lib/runs/presentation/host_run_manage_screen.dart:205` | Single key-value row in the host summary card. |
| `_HostRunUserList` | `lib/runs/presentation/host_run_manage_screen.dart:250` | Profile-backed roster/waitlist list on the host manage screen. Uses `PersonRow`, `CatchBadge`, and `CatchEmptyState`. |
| `_AttendanceSummaryHeader` | `lib/runs/presentation/attendance_sheet_screen.dart:131` | Header row for host attendance showing checked-in count and the toggle hint. |
| `RunAgendaList` | `lib/runs/presentation/widgets/run_agenda_list.dart:9` | Box-facing agenda list for runs grouped by day and sorted by start time. Used by Calendar's agenda mode. |
| `RunAgendaSliverList` | `lib/runs/presentation/widgets/run_agenda_list.dart:35` | Sliver-facing agenda list for runs grouped by day and sorted by start time. Used inside sliver-native feature screens such as run-club detail. |
| `RunAgendaRunCard` | `lib/runs/presentation/widgets/run_agenda_list.dart:91` | Tappable agenda card for a run — time, meeting point, distance/pace/spots metadata, and optional badge. |
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
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:15` | Calendar tab showing the user's booked runs. Manages view mode state (`agenda` vs `timeline`) and renders the appropriate view. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarHeader` | `lib/calendar/presentation/calendar_screen.dart:73` | Calendar header — "Calendar" title, `CatchSegmentedControl`, week strip, and `CatchSurface` stats row. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:171` | Horizontal week strip showing 7 days with date indicators. |
| `_WeekDay` | `lib/calendar/presentation/calendar_screen.dart:203` | Single day cell in the week strip — day name, date number, and active indicator. |
| `_AgendaView` | `lib/calendar/presentation/calendar_screen.dart:257` | Agenda (list) view of booked runs grouped by date. |
| `_AgendaRunCard` | `lib/calendar/presentation/calendar_screen.dart:294` | `CatchSurface` run card in the agenda view — time, distance badge, club name, location. |
| `_TimelineView` | `lib/calendar/presentation/calendar_screen.dart:358` | Timeline (week) view of booked runs. |
| `_TimelineRun` | `lib/calendar/presentation/calendar_screen.dart:384` | Single `CatchSurface` run block in the timeline view — positioned by time of day. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:454` | Divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:469` | Calendar empty/error state rendered through `CatchEmptyState`. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:21` | Post-payment confirmation screen. Shows hero animation, run summary card, quick actions (add to calendar, share, view club), and a referral banner. Also manages a "Back to Home" sticky CTA. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:45` | Scrollable body of the confirmation screen. |
| `PaymentConfirmationKeys` | `lib/payments/presentation/payment_confirmation_keys.dart:3` | Stable semantic keys for confirmation quick actions, referral share, and sticky back-home CTA. |
| `PaymentHistoryScreen` | `lib/payments/presentation/payment_history_screen.dart:20` | List of past payment transactions. Watches `watchPaymentsForUserProvider`, renders `_PaymentTile` items, and shows transaction details in `CatchBottomSheetScaffold`. |
| `_PaymentList` | `lib/payments/presentation/payment_history_screen.dart:42` | The list view of payment tiles. |
| `_PaymentTile` | `lib/payments/presentation/payment_history_screen.dart:74` | Single semantic payment transaction row — amount, date, run name, and status. Tapping opens the detail bottom sheet. |
| `PaymentHistoryKeys` | `lib/payments/presentation/payment_history_keys.dart:3` | Stable semantic payment-history tile keys for tests and future automation. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_HeroSection` | `lib/payments/presentation/payment_confirmation_screen.dart:97` | Animated hero section with checkmark and "Payment confirmed" text. |
| `_RunSummaryCard` | `lib/payments/presentation/payment_confirmation_screen.dart:195` | `CatchSurface` card summarizing the booked run — club name, location, date, distance, pace, and price. |
| `_QuickActions` | `lib/payments/presentation/payment_confirmation_screen.dart:287` | Row of quick-action tiles (add to calendar, directions, invite a friend). |
| `_ActionTile` | `lib/payments/presentation/payment_confirmation_screen.dart:374` | Private icon-based `CatchSurface` quick-action tile. Keep private until this semantic component has a second concrete use. |
| `_HeadsUp` | `lib/payments/presentation/payment_confirmation_screen.dart:408` | `CatchSurface` info box about cancellation policy. |
| `_ReferralBanner` | `lib/payments/presentation/payment_confirmation_screen.dart:439` | Tappable `CatchSurface` referral banner — "Invite friends, earn credit". |
| `_StickyBackToHome` | `lib/payments/presentation/payment_confirmation_screen.dart:494` | Sticky "Back to Home" button at the bottom of the confirmation screen. |

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

## Consolidation Opportunities

### High impact — clear duplicates, should be merged

#### 1. `FieldLabel` (runs) is a useless wrapper around `CatchFormFieldLabel`

`lib/runs/presentation/widgets/field_label.dart` is a one-line pass-through:

```dart
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.isOptional = false});
  @override
  Widget build(BuildContext context) =>
      CatchFormFieldLabel(label: label, isOptional: isOptional, large: true);
}
```

It exists solely to pass `large: true`. **Fix**: delete `FieldLabel` and have its 2 call sites pass `large: true` to `CatchFormFieldLabel` directly.

#### 2. `_DashboardLoadingScreen` and `_RouterLoadingScreen` are identical

Both are `Scaffold(body: CatchLoadingIndicator())`. **Fix**: extract a shared `CatchLoadingScreen` in `lib/core/widgets/` and reuse from both places.

#### 3. `_DashboardMessageScreen` and `_CalendarMessage` are near-identical

Both render a centered text message on a scaffold. `_CalendarMessage` adds a title + body column; `_DashboardMessageScreen` is body-only. **Fix**: unify into a single `CatchMessageScreen` widget with optional title.

#### 4. Six different empty-state widgets duplicate the same layout

| Widget | File | Pattern |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart` | Icon in circle → title → body text |
| `RunClubsEmptyState` | `lib/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart` | Icon → title → body text |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Icon in circle → title → body text → CTA |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart` | Icon → title → body text |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Similar empty pattern |
| `_MapEmptyState` | `lib/runs/presentation/run_map_screen.dart:320` | Body text only |

`SwipeEmptyState` already has the right architecture — it takes a `SwipeEmptyContent` data class. **Fix**: create a single `CatchEmptyState` widget in core accepting `icon`, `title`, `message`, and optional `cta` (label + onPressed). Replace all six. Feature-specific content data classes stay where they are; only the layout widget is shared.

#### 5. `ChatsSliverHeader` and `RunClubsSliverHeader` share the same skeleton

Both extend `CatchSliverHeader` with identical structure:

- `_TitleRow`: displayL title + bodyS subtitle + right-side action widget
- `_SearchRow`: horizontal padding + search/action content

Only the text strings and action widget differ. **Fix**: add `title`, `subtitle`, `actions`, and `search` parameters to `CatchSliverHeader` so the two subclasses can be deleted. The base already accepts `title` and `bottom` widgets — the change is making the title-building pattern reusable instead of duplicated.

#### 6. `ProfileInfoChip` (swipes) duplicates `CatchChip` (core)

`lib/swipes/presentation/widgets/profile_info_chip.dart` renders an icon + label chip with hardcoded white-transparent colors. `CatchChip` already supports icon + label with token-driven theming. **Fix**: add optional `backgroundColor`/`foregroundColor` overrides to `CatchChip` (matching the pattern already used in `CatchBadge` and `CatchButton`), then delete `ProfileInfoChip` and use `CatchChip` instead.

---

### Medium impact — worth considering

#### 7. Stat display widgets overlap

| Widget | File | Layout |
|---|---|---|
| `StatColumn` | `lib/core/widgets/stat_column.dart` | Value + label vertically, optional icon, highlight, mono/center |
| `RunStatCell` | `lib/runs/presentation/widgets/run_stats_grid.dart` | Value + unit on baseline row, label below, always centered |
| `HostStatChip` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart` | Already wraps `StatColumn` in a surface container |

`RunStatCell` could become a variant of `StatColumn` by accepting a Widget for the "value" slot instead of a String. Low urgency since the baseline-aligned layout is unique to `RunStatCell`, but the 3 widgets share the same value-above-label conceptual model.

#### 8. `StatusChip` and `CatchBadge` both render status labels

`StatusChip` is enum-driven (run status → color mapping). `CatchBadge` is a general-purpose label badge with 7 tone variants. `StatusChip` could be rebuilt to use `CatchBadge` internally. Optional — they serve different semantic purposes and the dedup win is small.

---

### Low impact — OK as-is

- **`_DashboardSectionStateCard`** and **`_ActivityMessage`** — slightly different layouts for section-level loading/error states. Could share a widget but the payoff is small.
- **`VibeTag`** vs **`CatchChip`** — different visual design. Vibe tags are softer accent tags; `CatchChip` is a binary active/inactive selector chip. Different use cases.

---

### Consolidation scorecard

| Category | Widgets eliminated | Replaced by |
|---|---|---|
| Useless wrapper | 1 (`FieldLabel`) | `CatchFormFieldLabel` with `large: true` |
| Identical loading screens | 2 (`_DashboardLoadingScreen`, `_RouterLoadingScreen`) | 1 `CatchLoadingScreen` |
| Near-identical message screens | 2 (`_DashboardMessageScreen`, `_CalendarMessage`) | 1 `CatchMessageScreen` |
| Near-identical empty states | 6 (all empty state widgets) | 1 `CatchEmptyState` |
| Near-identical sliver headers | 2 (`ChatsSliverHeader`, `RunClubsSliverHeader`) | Parameterized `CatchSliverHeader` |
| Feature chip duplicates core | 1 (`ProfileInfoChip`) | Extended `CatchChip` |
| **Total** | **14 widgets → 5 shared** | |
