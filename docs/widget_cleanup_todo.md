# Widget Cleanup To-Do

This is the running log for UI/design-system cleanup. Keep appending findings
as they appear, even when they are outside the current pass.

## Operating Instructions

- Treat this file as the single source of truth for the widget cleanup effort.
- Start every future pass by reading this file and the operating instructions at
  the top of `docs/widget_catalog.md`.
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
- Mixed scroll ownership inside sliver-native screens. If a parent owns a
  `CustomScrollView`, direct async/data children should usually return slivers.
  Use `SliverToBoxAdapter` for one-off box sections, `SliverFillRemaining` for
  intentional viewport-filling states, and `SliverList`/`SliverGrid` for
  repeated content. See `docs/sliver_layout_guide.md` before migrating another
  screen.
- Heavy custom scroll widgets where a simpler semantic list better matches the
  product need. Do not keep a two-dimensional grid or nested scrollable just
  because it exists; prefer shared agenda/list primitives when the user wants a
  chronological run list.
- Split design-system ownership. Theme tokens, typography, app theme, spacing,
  radius, motion, icon sizes, and compatibility layout helpers should live under
  `lib/core/theme`. Do not add new design primitives under generic
  `lib/constants` or a parallel top-level `lib/theme` folder.

## Current Pass: Signed-In User Profile

- [completed] Standardize signed-in profile UI under `lib/user_profile`.
- [completed] Extract repeated profile edit bottom-sheet layout into a core primitive.
- [completed] Keep profile edit modal state local, but remove repeated sheet shell code.
- [completed] Extract the signed-in profile bio prompt into a reusable profile widget.
- [completed] Reduce repeated edit-row wiring in `ProfileTab` with private field helpers.
- [completed] Remove repeated nested-scroll tab wrappers in `ProfileScreen`.
- [completed] Run focused profile widget tests and analyzer after each meaningful batch.

## Conversation To-Dos Captured

These are the larger tasks from this architecture/widget cleanup thread. This
file is the source of truth for where we pick up next.

### Completed

- [completed] Critique and accept the controller-first separation pattern with
  the caveat that widgets may still own local UI state, focus, animations,
  navigation, and transient input mechanics.
- [completed] Document the consolidated controller patterns in
  `docs/controller_patterns.md`.
- [completed] Refactor direct UI repository writes into controller methods for
  the first architecture pass.
- [completed] Update the architecture audit docs with the controller pattern
  direction.
- [completed] Migrate profile nomenclature away from `my_profile` and standardize
  on `user_profile`.
- [completed] Delete the obsolete `lib/my_profile` implementation after routing
  and docs pointed at `lib/user_profile`.
- [completed] Create/update the widget catalog so the widget surface can be
  audited systematically.
- [completed] Complete the signed-in profile UI cleanup listed above.
- [completed] Consolidate widget-audit operating guidance from
  `docs/ui_audit_patterns.md` into `docs/widget_catalog.md` and this tracker.
- [completed] Add `docs/README.md` as the docs ownership map and document the
  no-proliferation rule for future cleanup passes.
- [completed] Remove stale session-email/report docs after migrating durable
  process guidance into the active docs.
- [completed] Start the fragile-test-pattern cleanup by adding semantic scroll
  keys to dashboard/profile widgets, targeting run-detail actions by tooltip,
  and replacing manual route-frame/fixed-duration pumps in the first hotspots.
- [completed] Refactor the run-clubs list surface as an underlying UI fix, not
  a test-only cleanup: make the data body sliver-native, size the pinned search
  header correctly, keep city selection visible when the city list is
  unavailable, and move join-mutation provider watching into the join button.
- [completed] Refactor the chat thread and chats-list surfaces as underlying UI
  fixes: split `ChatScreen` into route wrapper/content plus top-bar,
  run-context, and message-list widgets; route send/image/report/block through
  `ChatController` mutations; remove teardown-time provider usage; and fix
  chats-list loading/search sliver sizing so the inbox no longer overflows.
- [completed] Complete the first run-detail audit/refactor pass: remove the
  nested `Scaffold` route wrapper, move host-attendance eligibility into
  `RunDetailViewModel`, make `RunDetailCta` consume feature-owned state instead
  of fetching run-club data directly, inject time for CTA tests, and extract
  the run-detail hero app bar.
- [completed] Split the loaded run-detail body into semantic body sections:
  `RunDetailOverviewSection` owns title/date/stats/when-where/requirements, and
  `RunDetailSocialSection` owns roster, guest prompt, and reviews. Added a
  guest-state regression test and loosened brittle title-count assertions.

### Active Backlog

- [completed] Refactor public profile display using any profile primitives that survive this pass.
- [completed] Decide whether profile field metadata should graduate from private `ProfileTab` helpers into a typed profile-field model.
- [completed] Move `MutationErrorSnackbarListener` from `run_clubs` into `core/widgets`.
- [completed] Add a reusable empty-state primitive before standardizing dashboard/chats/swipes/payments empty states.
- [completed] Audit dashboard cards and rails against `CatchSurface`, `RunCard`, `PersonRow`, `CatchHorizontalRail`, and `CatchVerticalSection`.
- [completed] Refactor the payment-history detail sheet through `CatchBottomSheetScaffold`.
- [completed] Audit calendar and payment cards against `CatchSurface`, `RunCard`, `PersonRow`, `SettingsRow`, and `CatchBottomSheetScaffold`.
- [completed] Add focused calendar widget tests before deeper calendar refactors.
- [completed] Split `CreateRunScreen` after the shared primitives are stronger.
- [completed] Replace placeholder host-manage roster rows with profile-backed
  participant rows before treating that screen as a production management
  surface.
- [completed] Audit the create-run draft UX after the screen split.
- [completed] Scan remaining complex form/widget tests for positional finders
  and brittle timing/scroll patterns. The broad test audit found the suite is
  green and generally behavior-aligned, but create-run, onboarding, payment
  sheets, and run-club flows still have concentrated `pumpAndSettle`/dialog
  helper debt that should be handled in focused follow-up passes.
- [pending] Replace remaining fragile scroll/timing test patterns in create-run,
  onboarding, payment, run-club, dashboard, and profile widget tests with
  semantic targets or behavior-level helpers where feasible.
- [completed] Do a focused `test/run_clubs/run_clubs_widgets_test.dart`
  cleanup after fixing the underlying run-clubs layout. The full file now
  passes and covers the sliver body/header behavior without preserving stale
  spinner or boxed-body assumptions.
- [completed] Audit chats with the same feature-surface workflow. Started at
  `ChatScreen`, then split rendering, scroll behavior, message state dispatch,
  send/image/block/report actions, and run-context layout where the current
  screen was doing too much.
- [completed] Audit run detail and broader runs presentation after chats. Pay
  attention to sliver ownership, route wrappers, controller boundaries, and
  tests that still need route/frame or scroll workarounds. The first pass fixed
  the route/body scaffold boundary, host-state provider seam, deterministic CTA
  timing, and app-bar composition.
- [completed] Audit `RunMapScreen` and `_MapRunSheet`. The map screen now reads
  a feature-owned `RunMapViewModel`, signed-up run duplicates win over
  recommendation duplicates, map pin filtering is covered by unit tests, and
  the overlay sheet is a semantic `RunMapSheet` using `CatchSurface`.
- [completed] Audit `AttendanceSheetScreen`. Attendance empty/profile/error
  states now use shared primitives, attendee rows reuse `PersonRow` and
  `CatchBadge`, mutation errors use the canonical mutation error helper, and
  focused widget tests cover empty attendance plus profile-backed toggling.
- [completed] Complete a focused testability cleanup pass. Run-detail tests now
  target title presence, tooltips, and semantic content scrolling instead of
  exact duplicate counts, icon/widget positions, or fixed-duration frame loops.
  Top-level back-navigation tests now use the `Back` tooltip and deterministic
  router pumps instead of icon finders and broad `pumpAndSettle`.
- [completed] Complete the create-run test-harness cleanup for app-owned
  controls: semantic keys cover date/time/map picker tiles, duration/back
  actions are addressed by tooltip, and the flow helper no longer repeats the
  route-open choreography in each test.
- [completed] Replace run-club detail's two-dimensional schedule grid with the
  shared agenda UI. Upcoming runs are now sorted in
  `RunClubDetailViewModel`, rendered by `ClubScheduleSection`, and displayed
  from soonest to latest using `RunAgendaSliverList`.
- [completed] Complete the payment history and payment confirmation
  testability cleanup. Payment history rows now expose stable tile keys and
  semantic button rows, payment confirmation quick actions use icon-based
  action tiles with stable keys, and the payment widget tests use shared harness
  helpers instead of repeated provider setup.
- [completed] Complete the Auth UI cleanup pass. `AuthScreen` is now a
  `ConsumerWidget`, phone/OTP controls expose `AuthFormKeys`, OTP digit widgets
  read design tokens locally instead of prop-drilling them, and auth widget
  tests now cover phone submission plus OTP verification through the controller.
- [completed] Consolidate design-system theme ownership. `AppTheme` moved from
  top-level `lib/theme` to `lib/core/theme`, spacing helpers moved from
  `lib/constants/app_sizes.dart` to `lib/core/theme/catch_spacing.dart`, and
  old import paths were removed.
- [completed] Complete the Safety/settings UI cleanup pass. Settings mutations
  now use shared snackbar error feedback, destructive confirmations use a shared
  danger-dialog helper, blocked-account empty/error states use `CatchEmptyState`,
  blocked rows expose semantic unblock keys, and safety widget tests cover
  profile-backed rendering, preference writes, failed optimistic-write rollback,
  unblocking, and delete-account confirmation.
- [completed] Complete the Reviews UI cleanup pass. Review cards now use
  `CatchSurface`, empty reviews use `CatchEmptyState`, review writing uses
  `CatchBottomSheetScaffold`, the edit sheet exposes the existing delete
  mutation, star picking has semantic keys/tooltips, and review controller plus
  widget tests cover create, edit, delete, validation, and sheet behavior.
- [pending] Gradually replace legacy `Sizes.p*` usage with canonical
  `CatchSpacing.s*` values where the layout is on the 4-point scale. Keep
  `Sizes.p*` only for intentional fine-grained component spacing.
- [pending] Keep appending widget-system cleanup findings here as they are found,
  even when they are not part of the current implementation batch.
- [pending] Keep `docs/README.md` synchronized whenever a new durable docs owner
  is added, renamed, or deleted.
- [pending] Do a later focused testing pass after the widget structure settles;
  keep running scoped analyzer/tests after each meaningful batch in the meantime.

## Next Up

Continue through the remaining unaudited or lightly audited feature surfaces in
this order unless a product bug changes priority:

1. Swipes deep pass: `SwipeScreen`, `FiltersScreen`, `RunRecapScreen`,
   `SwipeActionButtons`, and remaining swipe queue UI.
2. Image uploads/photo grid: `PhotoGrid`, `PhotoSlot`, and
   `PhotoUploadController` seams used by onboarding/profile.
3. Force update and app shell: `UpdateRequiredScreen`,
   `force_update_diagnostics.dart`, and `AppShell` side-effect boundaries.

## Recommended Order

1. Move `MutationErrorSnackbarListener` into `core/widgets` and update imports.
   This is small, reduces feature-owned shared infrastructure, and gives later
   screens one canonical mutation-error feedback primitive. Done in this pass.
2. Refactor public profile display using the profile primitives from this pass.
   While doing this, decide whether profile field metadata should become a typed
   model or remain private helper methods. Done in this pass; keep
   `ProfileCardContent` as the read-only public/swipe metadata layer and keep
   signed-in edit helpers private until another edit surface needs them.
3. Add a reusable empty-state primitive, then migrate the most repetitive empty
   states first. Start with dashboard/chats/swipes/payments only after the core
   primitive exists. Done in this pass for activity, chats, swipe, catches hub,
   and payment-history empty states.
4. Audit dashboard cards and rails against existing primitives (`CatchSurface`,
   `RunCard`, `PersonRow`, `CatchHorizontalRail`, `CatchVerticalSection`).
   Consolidate only duplicated card shells and states, not feature-specific
   content. Done for the dashboard recommendation rail and theme-token plumbing.
5. Audit calendar and payment cards next because they are adjacent to booking
   and confirmation flows and should reuse the same surface/action patterns.
   Done for calendar local card/message shells and payment-confirmation cards,
   action tiles, and referral surfaces. The payment-history detail sheet is
   already on `CatchBottomSheetScaffold`.
6. Split `CreateRunScreen` after the above primitives are stable so the split can
   use the stronger shared UI vocabulary instead of inventing another local one.
   Done by moving the post-submit success and host-management surfaces into
   semantically named files and extracting the wizard header.
7. Run a broader widget-test pass and add missing tests around any refactored
   shared primitives once the first few migrations prove the APIs are stable.
   Done for the calendar screen's loading, empty, error, agenda, and timeline
   toggle states.

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
  access; several payment/run-club/onboarding tests use broad `pumpAndSettle`
  because of sheets, menus, and navigation; and some design-system primitive
  tests intentionally assert widget types/sizes as visual contract tests.
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
