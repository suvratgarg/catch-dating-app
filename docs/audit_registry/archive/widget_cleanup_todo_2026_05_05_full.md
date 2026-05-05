---
doc_id: widget_cleanup
version: 2.0.0
updated: 2026-05-05
owner: recursive_audit_loop
status: active
---

# Widget Cleanup To-Do

This is the running log for UI/design-system cleanup. Keep appending findings
as they appear, even when they are outside the current pass.

## Read Policy

For future passes, read this policy, `Status Board`, and the latest scanner
snapshot first. Search `Findings` only when the target feature, rule id, or debt
id points there. Use `docs/audit_registry/` for pass history and per-file
freshness instead of rereading this whole file.

## Rule Changelog

### 2.0.0

- AUDIT-REGISTRY-001: Stamp touched files and proof in
  `docs/audit_registry/` after each recursive cleanup pass.
- DOC-HYGIENE-001: Prefer versioned owners and archived/watch rules over adding
  new long-lived markdown trackers.
- DEBUG-LOOP-001: Treat interactive physical-phone debug logs as first-class
  pass evidence when the user is clicking through the app.
- WIDGET-TEST-001: Keep broad widget settling centralized in semantic helpers.
- TEST-ASYNC-001: Use `flushTestEventQueue` for queued async test delivery.

## Operating Instructions

- Treat this file as the single source of truth for the widget cleanup effort.
- Start every future pass by reading this file and the operating instructions at
  the top of `docs/widget_catalog.md`.
- When debugging physical-device UI/layout issues with the user controlling the
  phone, use an interactive `flutter run` loop instead of one-off builds:
  1. Start the app with an interactive terminal so stdin stays open. In a normal
     terminal run `./tool/flutter_with_env.sh dev run -d <device-id>`. In Codex
     tool calls, allocate a TTY for the run command; otherwise hot reload,
     restart, detach, and quit commands may fail because stdin closes.
  2. Wait until Flutter prints the run key commands and the VM Service URL.
     Treat logs after that point as the current debugging baseline. Old buffered
     exceptions from before a hot restart should not be treated as fresh
     evidence.
  3. Tell the user exactly which screen/interaction to exercise on the phone.
     While they tap, poll the interactive terminal for `[FATAL]`, `RenderFlex
     overflowed`, `RenderBox was not laid out`, controller lifecycle errors,
     permission errors, and timeout logs.
  4. Diagnose from the concrete runtime stack first. For layout issues, map the
     relevant widget/file/line from the device log, then inspect the owning
     shared primitive or screen contract before editing. Do not patch by
     guessing from screenshots or by trial-and-error constants.
  5. Make a narrow fix, run focused analyzer/tests for touched primitives and
     affected feature tests, then send `R` for hot restart when state/controller
     lifecycles or constructors changed. Use `r` only for pure visual edits
     where existing widget state can safely remain.
  6. After restart, ignore pre-restart buffered errors and ask the user to repeat
     the exact interaction. Keep watching logs for a clean post-fix window.
  7. Detach with `d` when handing the app back to the user, or quit with `q` if
     the run should stop. Do not leave a `flutter run` session running when
     finalizing work unless the user explicitly wants monitoring to continue.
  8. If the interactive session loses stdin, stop the stale `flutter run`
     process and relaunch with an interactive terminal/TTY before continuing.
- For broad cleanup passes, run `bash tool/widget_cleanup_scan.sh` near the
  beginning and end of the pass. Treat it as a triage aid, not a failing lint:
  inspect matches before editing, refine the scanner when it becomes noisy, and
  prefer the highest-signal repeated smells over mechanical rewrites.
- Keep appending newly discovered work, recommendations, bug fixes, and process
  improvements here, even when they are outside the current pass.
- Continue in small verified batches. Prefer shared primitives only where they
  remove real duplication or express a durable design-system concept.
- Name shared primitives by their durable semantic role, not by a temporary
  feature use or purely visual treatment. The name should make the widget easy
  to search for and easy to reason about in future cleanup passes.
- Keep feature-specific content local; consolidate repeated shells and patterns.
- Prefer controller-owned business logic and repository writes. Widgets may own
  focus, scroll, animations, navigation, temporary input state, and other local
  UI mechanics.
- Treat tests as design feedback, not just verification. After closing the loop
  on any feature, repository, controller, state provider, UI widget, or
  primitive, inspect the test structure, setup complexity, runtime, brittleness,
  and dependency overrides. If tests are awkward, broad, flaky, or coupled to
  internals, use that as evidence that the implementation needs better seams,
  more semantic primitives, smaller units, or clearer controller/provider
  boundaries.
- Ask the user only when a design/product decision cannot be inferred safely
  from the repo.
- Treat docs as part of the cleanup surface. Prefer updating
  `docs/README.md`, `docs/widget_catalog.md`, this tracker, or another existing
  source-of-truth doc over creating a new markdown file. When temporary audit
  reports or email-style summaries have been migrated into durable docs, delete
  the stale files so the repository does not accumulate competing sources of
  truth.
- Verification policy: fix analyzer errors and warnings. Do not spend this
  cleanup pass on analyzer info-level issues unless they block the task, mask a
  real bug, or are already in a touched line.

## Recurring Anti-Patterns To Watch For

These are not the only problems worth fixing, but they have recurred enough that
future passes should actively scan for them.

- Prop drilling theme tokens. Prefer `CatchTokens.of(context)` inside leaf
  widgets instead of passing `CatchTokens` through constructors unless there is a
  measurable reason or a widget is intentionally rendering with a non-current
  token set.
- Hand-built bottom-sheet shells. Prefer `CatchBottomSheetScaffold` for grabber,
  title/subtitle, keyboard-safe padding, and action layout.
- Hand-built empty states. Prefer `CatchEmptyState` for icon/title/message/action
  states before creating another local empty-state card.
- Hand-built horizontal rails and vertical sections. Prefer
  `CatchHorizontalRail` and `CatchVerticalSection` when a screen is rendering a
  titled list/rail.
- Feature-local shared infrastructure. If a helper is general-purpose
  (`MutationErrorSnackbarListener`, sheet shells, empty states), move it to
  `core/widgets` instead of leaving it under a feature folder.
- Widgets calling repositories or owning product behavior. Move repository
  writes, validation decisions, and side-effect orchestration into controllers;
  keep widgets focused on rendering and local UI mechanics.
- Screen-level files mixing composition with repeated row/sheet/card plumbing.
  Use private helpers for first-use cleanup, then promote to shared primitives
  only after a second concrete use appears.
- One-off card/surface styling. Prefer `CatchSurface`, `RunCard`, `PersonRow`,
  `SettingsRow`, `CatchBadge`, and existing card primitives before creating new
  `Container`/`BoxDecoration` shells.
- Bypassing feature-owned provider seams. If a feature has a view-model or
  feature-specific provider, screens/view-models should use that seam rather than
  reaching around it to a lower-level repository provider.
- Broad screen shells owning state dispatch, mutation callbacks, or mutation
  feedback that belongs in semantic feature content widgets or controllers.
- Passing `WidgetRef` through helper methods instead of introducing a provider,
  controller method, or `ConsumerWidget` boundary.
- Nesting unrelated widgets together just because they share a row or section.
  Keep child widgets single-purpose and let parent layouts compose them.
- Duplicate markdown trackers, one-off audit reports, or session-email drafts
  lingering in `docs/` after durable decisions have moved into their owning
  source-of-truth files.
- Tests coupled to incidental scroll internals. Prefer behavior assertions and
  stable screen-level scroll gestures over fragile assumptions about nested
  `Scrollable` structure.
- Tests that pass but are painful to write or maintain. Excessive setup,
  timing hacks, broad integration scaffolds for narrow behavior, private-widget
  assumptions, or fragile finders should trigger either an immediate refactor or
  a tracked backlog item so code quality improves over time instead of drifting.
- Scattered raw widget-test waits. If a feature flow genuinely needs route,
  sheet, dialog, menu, or provider-delivery settling, hide that behind a semantic
  domain helper or the shared `pumpFeatureUi` seam while the flow is refactored.
  Do not let direct `pumpAndSettle` calls accumulate in feature test files.
- Mixed scroll ownership inside sliver-native screens. If a parent owns a
  `CustomScrollView`, direct async/data children should usually return slivers.
  Use `SliverToBoxAdapter` for one-off box sections, `SliverFillRemaining` for
  intentional viewport-filling states, and `SliverList`/`SliverGrid` for
  repeated content. See `docs/sliver_layout_guide.md` before migrating another
  screen.
- Breaking the `NestedScrollView` overlap contract in tabbed sliver screens.
  If the outer header uses `SliverOverlapAbsorber`, each tab body must inject
  that overlap and avoid putting unconstrained vertical scrollables inside
  `SliverToBoxAdapter`. Prefer sliver-native tab bodies, or keep the whole tab
  as the inner scroll view.
- Heavy custom scroll widgets where a simpler semantic list better matches the
  product need. Do not keep a two-dimensional grid or nested scrollable just
  because it exists; prefer shared agenda/list primitives when the user wants a
  chronological run list.
- Split design-system ownership. Theme tokens, typography, app theme, spacing,
  radius, motion, icon sizes, and compatibility layout helpers should live under
  `lib/core/theme`. Do not add new design primitives under generic
  `lib/constants` or a parallel top-level `lib/theme` folder.
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
  anti-pattern appears repeatedly, add a lightweight repo-local scanner or
  checklist, then keep tuning it so it stays useful instead of becoming ignored
  noise.
- Scanner output that cannot distinguish real widget smells from valid
  controller/provider seams. Cleanup scans should exclude generated files,
  controllers, notifiers, and data layers where appropriate so they point at
  surfaces that actually need design-system attention.

## Status Board

This is the only status list for the widget cleanup work. Keep new work in
`Pending`, move finished work into `Completed History`, and keep `Next Up`
ordered by current value.

### Pending

- [pending] Fix the profile tab/preview tab blank-rendering regression. The
  current route-level `NestedScrollView` composition still lets `ProfileTab`
  render as an unconstrained `ListView` inside a sliver adapter; make the loaded
  profile tab body sliver-native or restore it as the actual inner scroll view,
  and keep preview card constraints finite.
- [pending] Replace remaining brittle widget-test timing patterns with semantic
  pumps, targeted route helpers, or stable test harness helpers where feasible.
  Current scanner count: 1 intentional centralized match in
  `test/test_pump_helpers.dart`; do not reintroduce feature-level raw waits.
- [pending] Continue auditing feature tappables for missing semantic keys,
  tooltips, and labels before adding more widget tests. Current scanner count:
  24 syntactic tappable candidates; this is now noisy because it still reports
  several audited widgets that are wrapped in `Semantics` or `Tooltip`.
- [pending] Gradually replace legacy `Sizes.p*` usage with canonical
  `CatchSpacing.s*` values where the layout is on the 4-point scale. Keep
  `Sizes.p*` only for intentional fine-grained component spacing. Current
  scanner count: 139 legacy spacing matches.
- [pending] Keep `docs/README.md` synchronized whenever a durable docs owner is
  added, renamed, or deleted.
- [pending] Keep appending widget-system findings here as they are found, even
  when they are not part of the current implementation batch.

### Next Up

1. Audit the 24 feature tappable candidates for accessibility/testability. Do
   not add keys mechanically; add tooltips/semantics only where they describe a
   real user action.
2. Do a piecemeal spacing migration. Prefer touched files and 4-point scale
   values; avoid an all-at-once mechanical rename.
3. Return to the profile tab/preview tab rendering fix when the user is ready;
   it is tracked above but explicitly deferred for now.

### Completed History

- [completed] Established the controller-first separation pattern and documented
  controller conventions in `docs/controller_patterns.md`.
- [completed] Standardized profile nomenclature on `user_profile`, deleted the
  obsolete `my_profile` implementation, and completed signed-in/public profile
  cleanup.
- [completed] Consolidated widget-audit guidance into
  `docs/widget_catalog.md`, this tracker, and `docs/README.md`; removed stale
  duplicate report/email docs after migrating durable guidance.
- [completed] Added and refined `tool/widget_cleanup_scan.sh` as the recursive
  cleanup feedback loop. Current scanner categories cover brittle widget-test
  timing, async unit-test flushes, positional finders, repository-provider
  reaches, `CatchTokens` prop drilling, feature tappables, legacy spacing, and
  presentation plugin imports.
- [completed] Centralized widget-test route/sheet/dialog settling through
  `test/test_pump_helpers.dart` and domain wrappers in create-run, run-clubs,
  dashboard, profile, payment, and onboarding tests. The high-volume direct
  `pumpAndSettle` cleanup is complete; one shared broad helper remains as an
  explicit seam for future narrowing.
- [completed] Replaced raw async unit-test zero-delay flushes with
  `flushTestEventQueue`, a named wrapper around Flutter's `pumpEventQueue`.
  Auth, error-logger, force-update, payment repository, and run-clubs list
  controller tests now express event-queue delivery explicitly.
- [completed] Moved shared UI infrastructure into core where appropriate:
  `MutationErrorSnackbarListener`, `CatchBottomSheetScaffold`,
  `CatchEmptyState`, `CatchHorizontalRail`, `CatchVerticalSection`,
  `PersonRow`, `CatchBadge`, and related semantic keys.
- [completed] Consolidated design-system ownership under `lib/core/theme`.
  `AppTheme` and spacing compatibility helpers now live with tokens,
  typography, radii, and related theme primitives.
- [completed] Cleared scanner-reported `CatchTokens` prop drilling. Onboarding
  and dashboard leaves now read tokens from local build context.
- [completed] Moved URL, share, store-launch, and create-run-club cover-picking
  actions behind provider/controller seams where audited:
  `ExternalLinkController`, `ExternalShareController`,
  `UpdateRequiredController`, `PaymentConfirmationController`, and
  `CreateRunClubController`.
- [completed] Completed major feature cleanup passes for dashboard, calendar,
  create-run, run clubs, chats, run detail, run map, attendance, payments,
  Auth UI, Safety/settings, Reviews, Swipes, image uploads/photo grid, force
  update, and app shell.
- [completed] Replaced run-club detail's two-dimensional schedule grid with the
  shared agenda UI via `RunAgendaSliverList`.
- [completed] Improved focused widget/controller tests across the audited
  surfaces and used test brittleness as design feedback for semantic keys,
  controller seams, sliver-native layout, and provider setup.
- [completed] Removed the remaining presentation/bootstrap platform side-effect
  imports. `AppShell` now reads connectivity through a core provider, `main.dart`
  registers FCM background handling through `FcmService`, and `FcmService`
  owns idempotent listener setup/reset for authenticated users.
- [completed] Cleared the scanner-reported positional widget finders. Tests now
  use purpose-specific keys, hit-testable overlay items, semantic run-club
  actions, or behavior-level widget predicates instead of `.first`/`.last`
  selectors.
- [completed] Audited a high-signal feature-tappable batch and added explicit
  semantics/tooltips for chat send actions, dashboard activity items, new-match
  avatars, run-club cover/contact/avatar actions, run-map markers, pace chips,
  swipe cards, and profile edit cards.
- [completed] Reviewed the remaining repository-provider reach. The location
  initializer is a valid provider-owned startup side effect, not UI logic, but
  the write is now narrower through `UserProfileRepository.updateDetectedLocation`.
  The scanner now scopes repository-provider reaches to presentation surfaces.

## Findings

- `profile_edit_sheet.dart` repeats bottom-sheet padding, grabber, keyboard-safe insets, and action rows across every editor.
- Profile edit modals still use several `StatefulBuilder` blocks; this is acceptable short-term for modal-local state, but the shared sheet shell should not be repeated.
- `ProfileTab` was mixing section composition with repeated modal plumbing; private field helpers are enough for now, but a typed metadata model may be useful once public profile shares the same fields.
- Public profile already reused `ProfileCard`, but its screen shell still had
  local submission state and a custom report bottom-sheet shell. It now uses
  controller mutations, shared mutation snackbars, and `CatchBottomSheetScaffold`.
- Do not merge signed-in editable field helpers with public/swipe
  `ProfileCardContent` yet. They describe different concerns: edit actions vs.
  read-only display facts.
- `CatchEmptyState` now covers plain centered and surfaced empty states with an
  optional action slot. Migrated `SwipeEmptyState`, `ChatsEmptyState`,
  `ActivitySection`, catches hub, and payment-history empty states.
- `PaymentHistoryScreen` detail sheet now uses `CatchBottomSheetScaffold`
  instead of a local `BottomSheetGrabber`/padding/title shell.
- Dashboard recommendations now use `CatchHorizontalRail`; the rail supports
  custom header/list padding for embedded padded layouts.
- `ChatScreen` is now a thin route wrapper over `_ChatContent`. The thread body
  composes `ChatTopBar`, `ChatRunContextHeader`, `ChatMessageList`, and
  `ChatInputBar`; repository writes and safety actions go through
  `ChatController` mutations.
- Do not use Riverpod providers during widget disposal. The chat unread reset is
  handled while the widget is mounted; the failed dispose-time reset showed that
  teardown side effects through auto-disposed notifiers are brittle.
- Chat tests exposed a hidden dependency on `watchRunProvider(match.runId)`.
  Tests now override that run-context provider explicitly, and future route
  tests should treat hidden provider reads as architecture feedback.
- `ChatsList` loading state should not put a tall `CatchSkeletonList` inside
  `SliverFillRemaining`; use a padded `SliverToBoxAdapter` unless the content is
  intentionally constrained to the viewport. `ChatsSliverHeader` must reserve
  enough pinned height for the shared `CatchTextField`.
- `RunDetailScreen` should not wrap `RunDetailBody` in another `Scaffold`.
  Route-level loading/error/not-found states may use their own scaffold, but the
  loaded detail body owns the screen scaffold and sliver structure.
- `RunDetailCta` should not reach directly into `fetchRunClubProvider` to infer
  host state. Host attendance state now comes from `RunDetailViewModel`, keeping
  the detail screen on one feature-owned data seam.
- Time-window CTA behavior should be testable without wall-clock dependence.
  `RunDetailCta` accepts an optional `now` value, and the host attendance CTA
  has a deterministic widget test.
- `RunDetailHeroAppBar` is now a semantic app-bar widget for the run detail
  hero, share action, and saved-run action. Continue extracting body sections
  only where the result improves readability or test seams.
- `RunDetailBody` now composes semantic sections instead of owning every body
  row inline. Keep `RunDetailOverviewSection` responsible for static run facts
  and `RunDetailSocialSection` responsible for roster/review/guest social
  context.
- Swipes exposed a mutation-seam drift: `FiltersController.saveFiltersMutation`
  existed but `FiltersScreen` still managed `_saving` locally and called the
  controller directly. Future passes should check that declared mutations are
  actually used at the UI trigger site.
- Photo uploads exposed the same issue: `PhotoUploadController.uploadPhotoMutation`
  existed but onboarding/profile called `pickAndUpload` directly. Shared
  controller mutations should be treated as the canonical action seam unless a
  screen has a specific reason to bypass them.
- AppShell exposed side-effect ownership drift. Connectivity and FCM
  initialization are runtime effects that belong behind provider/controller
  seams, not direct widget subscriptions and flags. Connectivity now lives in
  `appConnectivityProvider`, and FCM listener lifecycle is owned by
  `FcmService`.
- Update-required store launching is platform/product logic. Keeping it in
  `UpdateRequiredController` makes URL selection and launch failures testable
  without invoking `url_launcher` in widget tests.
- Tests exposed that exact text counts are brittle when the same run title is
  legitimately rendered in both the hero and the overview. Prefer presence or
  section-specific assertions over incidental global counts.
- Dashboard child widgets now read `CatchTokens` locally instead of receiving
  token objects from `DashboardFull`.
- Dashboard tests exposed that `DashboardFullViewModel` was bypassing the
  dashboard-specific recommendation provider. It now watches
  `dashboardRecommendedRunsProvider`, keeping the dashboard recommendation seam
  testable and feature-owned.
- Do not replace dashboard recommendation cards with `RunCard` yet. `RunCard`
  currently needs a full `RunCardData` adapter and has no compact horizontal
  recommendation density; add an adapter/density only when a second run-card
  surface needs the same shape.
- Calendar private widgets were prop-drilling `CatchTokens` and hand-building
  simple card/message shells. They now read tokens locally and use
  `CatchSurface` for stats/agenda/timeline surfaces plus `CatchEmptyState` for
  calendar empty/error states.
- Payment confirmation now uses `CatchSurface` for the run summary, quick-action
  tiles, heads-up box, and referral banner. The action tile remains private
  because "confirmation quick action" is not yet a proven shared primitive; keep
  it local until a second concrete surface needs the same semantic component.
- There was no focused `test/calendar` coverage before this pass, which made
  deeper calendar extraction riskier than necessary.
- `test/calendar/calendar_screen_test.dart` now covers loading, empty, error,
  agenda stats/details, and the Agenda -> Day timeline toggle. This unblocks a
  future calendar extraction pass if the screen grows further.
- `CreateRunScreen` is now focused on wizard state, draft restore/save, local
  form controllers, and submit orchestration. `CreateRunSuccessScreen`,
  `HostRunManageScreen`, and `CreateRunStepHeader` are split into semantically
  named files.
- Host manage cards now use `CatchSurface`, and empty roster/waitlist states use
  `CatchEmptyState`.
- Host manage roster rows now reuse the existing public-profile batch-fetch seam
  and render through `PersonRow` with `CatchBadge` status labels, preserving
  participant order without exposing raw user IDs in the row UI.
- The draft picker claimed deletes were permanent but only removed drafts from
  local sheet state. It now accepts an explicit delete callback, calls
  `CreateRunDraftController.deleteDraftMutation`, keeps the sheet open when
  other drafts remain, and is covered by a persisted-draft regression test.
- `DraftPickerSheet` now uses `CatchBottomSheetScaffold`, `CatchSurface`, and
  `CatchEmptyState` instead of hand-built bottom-sheet and card shells.
- Create-run widget tests were relying on positional `CatchTextField.at(n)`
  selectors. That was a testability signal, so create-run form fields now have
  semantic `CreateRunFormKeys`, and tests target fields by purpose instead of
  layout order.
- The initial test-brittleness scan found remaining positional scroll/timing
  patterns in dashboard tests (`ListView.first`), profile tests
  (`Scrollable.first`), run detail/run clubs tests (fixed-duration pumps), and
  routing tests (manual frame pump). Track these as cleanup candidates and
  prefer semantic keys or behavior-level helpers before adding more tests in
  those areas.
- Positional finder cleanup is a good accessibility feedback loop. Run-club
  tiles now expose an "Open ... run club" semantic action, draft deletion has a
  draft-specific key, and dropdown/date-picker tests use hit-testable overlay
  items instead of assuming a particular duplicate text order.
- The feature-tappable scanner is now intentionally conservative but noisy. It
  catches real unnamed actions, but it cannot distinguish raw tappables from
  tappables wrapped in `Semantics`/`Tooltip`. Before treating its count as real
  debt, inspect the surrounding widget and either fix the interaction contract
  or refine the scanner so audited widgets do not keep appearing as stale work.
- `CreateRunScreen` tests no longer suppress missed taps on the primary button
  helper; `ensureVisible` plus a normal tap is sufficient, so future failures
  will expose real tappability/layout issues.
- `docs/ui_audit_patterns.md` duplicated guidance that now belongs in the
  widget catalog and cleanup tracker. Its durable guidance has been migrated
  into the operating instructions and recurring anti-patterns; the stale source
  file can be deleted.
- `docs/email-drafts/` and `docs/emails/` were session-report collections, not
  durable source-of-truth docs. Their useful themes are already represented in
  the current audit, controller, launch, error-handling, and widget cleanup docs,
  so keeping them in `docs/` creates source-of-truth noise.
- Dashboard and profile tests now use semantic widget scroll keys instead of
  `ListView.first`/`Scrollable.first`; keep using named keys or user-visible
  behavior when adding tests around long scrolling surfaces.
- Run detail top actions are discoverable by tooltip (`Back`, `Share run`,
  `Save run`/`Unsave run`), so tests should prefer those tooltips over
  positional `IconBtn.at(n)` selectors.
- The full run-clubs widget test file still has unrelated failures outside the
  two mutation-listener tests touched here: stale empty/loading expectations and
  layout overflows in list/header harnesses. Keep the targeted listener tests,
  then clean the broader file in a dedicated pass.
- Run-clubs failures were caused by real UI architecture issues, not just test
  brittleness. `RunClubsListBody` was returned through `SliverToBoxAdapter` and
  then embedded a vertical list inside the tab's `CustomScrollView`, while the
  pinned search header was too short for `CatchTextField.compact`.
- `RunClubsListBody` is now sliver-native through `SliverMainAxisGroup`;
  `RunClubDiscoverList` uses a real `SliverList`; loading uses padded skeleton
  cards instead of a constrained `SliverFillRemaining` column; and the empty
  state uses `CatchEmptyState`.
- `RunClubListTile` no longer watches mutation state for display-only joined
  cards. The provider-dependent join behavior lives in a small `_JoinClubButton`
  so read-only tile tests and tile rendering are not forced to carry mutation
  provider state.
- `CityPicker` now keeps the selected city visible when the city list provider
  is loading or unavailable. Tests override the city and location seams
  explicitly so provider retry timers do not hide layout regressions.
- `docs/sliver_layout_guide.md` now documents the sliver-native screen pattern,
  why it was introduced, when to use it, when not to use it, performance
  implications, and Catch-specific examples from run clubs, chats, run detail,
  run-club detail, and user profile.
- `RunMapScreen` no longer owns profile/run stream composition inline. The new
  `RunMapViewModel` provider combines user profile, signed-up runs, recommended
  runs, de-duplicates by run ID, preserves signed-up data over recommended
  duplicates, sorts chronologically, and exposes pinned runs separately for map
  markers.
- `_MapRunSheet` was promoted to `RunMapSheet` in
  `lib/runs/presentation/widgets/run_map_sheet.dart` and now uses
  `CatchSurface`; the map empty state now uses `CatchEmptyState`.
- `AttendanceSheetScreen` now treats missing runner profiles as a real async
  state instead of silently falling back to placeholder rows on profile-load
  errors. It uses `CatchEmptyState` for no sign-ups, `CatchSurface`/`PersonRow`
  for rows, `CatchBadge` for checked-in/absent status, and
  `mutationErrorMessage` for attendance mutation failures.
- The general test audit found 70 Dart test files and 474 passing tests. The
  suite broadly reflects intended app behavior: repositories cover Firestore and
  callable boundaries, controllers cover mutation delegation and auth
  preconditions, domain tests cover derived model behavior, and widget tests
  cover the primary user-visible states for the recently audited surfaces.
- Remaining testability debt is concentrated rather than systemic:
  `CreateRunScreen` tests still carry the heaviest wizard/dialog choreography;
  stock Flutter date/time picker tests still require positional dialog field
  access; feature tests now route broad route/sheet/menu settling through
  domain helpers and `pumpFeatureUi`; and some design-system primitive tests
  intentionally assert widget types/sizes as visual contract tests.
- The run-detail test pass confirmed a useful feedback loop: replacing raw
  `ensureVisible` failed because the sliver body had not built the target yet,
  so the final helper scrolls the vertical `Scrollable` until semantic content
  appears. Future sliver tests should prefer semantic target scrolling over
  fixed drags or assumptions that offscreen sliver children already exist.
- Create-run test harness cleanup is complete for app-owned controls: date,
  time, and map pickers now have semantic `CreateRunFormKeys`, duration/back
  actions are targeted by tooltips, and tests no longer rely on app-owned icon
  positions. Remaining create-run dialog debt is limited to Flutter stock
  date/time picker internals, where positional editable fields are still
  necessary.
- Run-club detail no longer uses the two-dimensional `RunScheduleGrid`. The
  old grid, day header, run card, and `two_dimensional_scrollables` dependency
  were removed. Calendar's private agenda UI was promoted to reusable
  `RunAgendaList`/`RunAgendaSliverList`, and run-club detail now displays
  upcoming runs from soonest to latest via `ClubScheduleSection`.
- Onboarding gender/interest tests no longer use positional
  `CatchChip.first`/`.last` selectors for duplicated labels. `ChipField` now
  accepts an optional semantic key builder, and `GenderInterestPage` exposes
  `OnboardingFormKeys` for self-gender vs interested-in chips.
- Payment history tests no longer tap incidental status text to open bottom
  sheets; they target `PaymentHistoryKeys.paymentTile`. Payment confirmation
  tests now target `PaymentConfirmationKeys` for quick actions, referral share,
  and the sticky back-home CTA. The confirmation quick actions also moved from
  emoji labels to icon-based tiles to better match the app's design-system
  conventions.
- Auth tests now target `AuthFormKeys` instead of only visible button text, and
  they exercise the real send-code and verify-code controller paths from the UI.
  The OTP visual digit widgets no longer receive `CatchTokens` through
  constructors.
- `lib/constants/app_sizes.dart` and top-level `lib/theme/app_theme.dart` were
  parallel design-system entry points. They have been consolidated under
  `lib/core/theme`. `catch_spacing.dart` intentionally preserves `Sizes.p*` and
  `gapH/gapW` as compatibility helpers so cleanup can continue piecemeal
  without a risky all-at-once spacing rename.
- Safety/settings had controller-owned writes, but the screen did not surface
  mutation failures consistently and hand-built blocked-account empty/error
  states inside a settings card. It now wraps settings mutations in
  `MutationErrorSnackbarListener`, reuses `CatchEmptyState`, and uses
  `SettingsKeys` so tests target semantic controls instead of incidental text or
  switch positions.
- Optimistic UI is only acceptable when failure handling is explicit. Settings
  preference toggles now roll back if `savePreferenceMutation` fails; use the
  same pattern for future optimistic switches or action rows.
- The safety widget tests exposed the same provider-priming lesson as other
  controller-backed screens: tests that trigger controller mutations must make
  the signed-in UID provider resolve before tapping UI controls. Keep adding
  lightweight test primers instead of bypassing controller preconditions.
- Reviews had a controller delete mutation but no edit-sheet delete UI. When a
  controller already exposes a product action, audit whether the surface should
  expose it, remove it, or document why it is intentionally hidden.
- Mutation resets that depend on Riverpod provider scope should not run in
  `initState`. The review sheet now resets static mutations in
  `didChangeDependencies`, which avoids inherited-scope lifecycle assertions
  while still clearing stale submit/delete state when the sheet opens.
- The recursive cleanup scanner is now part of the workflow. Its current output
  should guide triage, not dictate edits: it intentionally reports candidates
  such as `pumpAndSettle`, positional finders, custom tappables, token
  prop-drilling, plugin imports, and legacy spacing. Refine the scan when false
  positives outnumber useful leads.
- Current scanner snapshot after widget/async test cleanup: 1 centralized widget
  timing candidate, no async unit-test flush candidates, no positional finder
  matches, no presentation repository-provider reaches, no token prop-drilling
  matches, 24 syntactic custom tappable candidates, 139 legacy spacing matches,
  and no presentation plugin/platform imports.
- Direct `url_launcher` and `share_plus` calls in widgets were a repeated
  side-effect smell. `ExternalLinkController` now backs settings contact links,
  run-club contact links, force-update store links, and payment confirmation
  calendar/directions actions. `ExternalShareController` now backs payment
  invite/referral sharing plus run/run-club hero sharing.
- Payment confirmation was doing product-action construction in the widget.
  `PaymentConfirmationController` now owns calendar URI construction,
  directions URI construction, invite text, referral text, URL launching, and
  sharing. Unit tests cover the pure action builders without pumping the
  confirmation screen.
- Isolated sliver widgets should stay easy to render in tests. Converting the
  whole `ClubHeroAppBar` to `ConsumerWidget` forced unrelated tests to carry a
  `ProviderScope`; the final version keeps the app bar stateless and reads the
  share provider only when the default share action is invoked.
- Stale tests are useful product feedback when copy moves into shared
  primitives. The run-club review empty-state test was updated to assert the
  current `CatchEmptyState` copy rather than the old inline message.
- Token objects should almost never be constructor parameters for normal leaf
  widgets. The scanner reached zero `CatchTokens` prop-drilling matches after
  changing onboarding/dashboard leaves to call `CatchTokens.of(context)`
  locally, and the focused onboarding/dashboard tests stayed green.
- Create-run-club cover picking is now controller-owned. The screen chooses when
  the user requested a cover image, while `CreateRunClubController` owns the
  image-picking call and preview-byte read. This kept the existing widget cover
  preview test green and added a narrow controller test for picked preview
  bytes.
- Profile screen tab layout now follows the `NestedScrollView` overlap contract:
  the editable tab body injects the absorbed overlap and renders
  `ProfileTabSliverBody` as a real `SliverList` instead of hiding
  `ProfileTab`'s `ListView` inside a `SliverToBoxAdapter`. `ProfileTab` remains
  the standalone/non-sliver wrapper for isolated tests and reuse.
- Sticky feature headers now follow Flutter's `SliverPersistentHeader` extent
  contract more explicitly. Collapsible title children are laid out at their
  declared full height and clipped as the sliver shrinks; two-line feature
  titles use `CatchSliverHeader.twoLineTitleHeight`; and compact search fields
  have a stable single-line `CatchTextField` control height. Do not fix future
  sticky-header overflows by trial-and-error height bumps: first check whether
  the delegate's `minExtent`/`maxExtent` truthfully match the child layout.
- `CatchTextField` now syncs changed `initialValue`s into its internally owned
  controller. Search fields should watch the query provider and let the text
  field update in place instead of using changing widget keys to tear down and
  recreate controllers.
- The widget-test timing pass confirmed that broad waits are sometimes exposing
  real route/dialog complexity rather than only test laziness. The create-run
  wizard failed when its helper was narrowed to a fixed animation pump, because
  date/time dialogs and route transitions still need full settling. Keep the
  wait centralized for now, then reduce it only when the underlying flow gains
  narrower, testable seams.
