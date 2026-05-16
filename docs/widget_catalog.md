---
doc_id: widget_catalog
version: 2.5.74
updated: 2026-05-16
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

### 2.5.74

- `EventPolicyLabScreen` is the dev/staging-only visual lab for the parallel
  event-policy engine. It lives under `lib/event_policies/presentation`, is
  reachable at `/dev/event-policy-lab` when `AppConfig.enableEventPolicyLab` is
  true, and renders static preview fixtures without touching live booking,
  Firestore, Functions, drafts, or payments.
- Settings shows an `Event policy lab` row only under the same dev/staging gate.

### 2.5.73

- Home no longer has `Dashboard` / `Activity` tabs. `DashboardScreen` is a
  single sliver-owned Home surface with a top-right Notifications bell and red
  unread badge.
- The former Activity tab is now a `Notifications` screen opened from the Home
  header. It remains inside the Home shell route so the bottom navigation stays
  visible, and it marks unread activity notifications read when the screen
  opens.
- `ActivitySection` remains the reusable timeline body, but callers can hide
  the manual `Mark all read` action when the route owns automatic read state.
- `DashboardSliverHeader` now exposes action slots instead of a pinned tab row.

### 2.5.72

- Profile Preview now bridges both scroll directions while preserving the
  shared `ProfileSurface`: upward drags on the preview card collapse the
  Profile header until the Edit/Preview tabs pin, and leading overscroll at
  the card top expands the header again.
- `ScrollableProfile` can accept route-provided scroll physics when embedded
  inside a parent sliver route that needs coordinated header behavior.

### 2.5.71

- Host tooling now has shared primitives under `lib/host_tools/presentation`:
  `HostRunToolsCarousel`, `HostRunToolCard`, `HostRunBottomActions`,
  `HostClubToolsPanel`, `HostStatsStrip`, `HostStatChip`, and
  `HostToolPalette`.
- Dashboard host tools use full-width snapping cards with stacked Manage /
  Attendance actions instead of a clipped horizontal partial-card rail.
- Run detail now renders host-only bottom actions for hosted runs. Hosts see
  Manage and attendance availability instead of an empty footer or participant
  booking CTA.
- Run club host tools and attendance headers share the host palette, and hosted
  club schedule rows use the `HOSTED` run-tile state.

### 2.5.70

- The shared profile display is now `ProfileSurface`, a cardless renderer used
  by Catches, Profile Preview, and Public Profile. Reaction controls are
  mode-gated: Catches can pass section like/comment callbacks, while Preview
  and Public Profile render the same content without reaction overlays.
- `SwipeScreen` no longer uses `flutter_card_swiper`, deck gestures, generic
  like/pass bottom buttons, or swipe stamps. It renders the first candidate as a
  full structured profile and uses a floating lower-left pass X.

### 2.5.69

- `PreferredRunTime` is now part of `UserProfile` and `PublicProfile`.
  Onboarding and Edit Profile collect favorite run times alongside pace,
  distances, and reasons.
- Shared profile-card insights use preferred run times for morning/evening
  emotional tags, time-of-day compatibility reasons, and profile-quality
  scoring.

### 2.5.68

- Shared `ProfileSurface` rendering now derives contextual profile insights:
  confidence signals, emotional running tags, and viewer-aware compatibility
  reasons. Swipe, Preview, and Public Profile pass viewer/run context into the
  same rendering path instead of forking presentation logic.
- `ProfileMatchSignalsSection` is the first-class "Why you might click" /
  "Profile signals" block and is individually reactionable through the
  `compatibility` reaction target type.
- Edit Profile now shows profile-quality guidance above photos, backed by the
  same pure profile-insights scoring used by public profile confidence signals.

### 2.5.67

- Run card architecture now uses a surface-specific run tile catalog under
  `lib/runs/presentation/widgets/run_tiles/`: `RunTileData`,
  `RunAgendaTile`, `RunRailTile`, `RunHeroTile`, and `RunMapTile`.
- Calendar, Saved runs, Dashboard recommendations/upcoming hero, Run club
  schedule, and Map browse cards now render through those tile variants while
  their providers/view models own club-name and relationship-state lookup.
- The obsolete generic `RunCard` in `lib/core/widgets/run_card.dart` was
  removed because it was not used by production surfaces and had a stale
  one-size-fits-many API.

### 2.5.66

- Map surfaces use chromeless full-screen layouts with floating
  `MapOverlayControls` instead of a `CatchTopBar`, so map tiles extend to the
  top corners while back/confirm actions remain available above the map.

### 2.5.65

- `RunPinsMap` accepts a selected run camera target from map-browse screens.
  Tapping a nearby-run tile now animates the map to that run's exact starting
  point instead of only changing card and pin selection state.

### 2.5.64

- Map browse centering is now strictly device location unless the user manually
  selected a city or denied/unavailable location access, then selected city.
  Run pins never choose the browse-map camera center.
- Dashboard Map View's `View run` action routes to the dashboard run-detail
  path, not the Clubs branch route, so it opens details from the top-level map
  surface without branch mismatch.
- Map form previews use human state copy (`Starting point pinned`) instead of
  raw latitude/longitude display.

### 2.5.63

- App-wide ambient notices now use `CatchNoticeHost` / `CatchNotice` instead
  of the shell-level offline `MaterialBanner`. Offline state is a persistent
  safe-area-aware notice; foreground events such as matches can use the same
  queued notice host with dedupe and auto-dismiss behavior.

### 2.5.62

- Dashboard host actions are consolidated into `HostToolsRail`: each hosted run
  gets one horizontally scrollable card with both Manage and Attendance actions.
  Attendance is enabled only inside the host attendance window, while Manage
  stays available for actionable hosted runs.
- `DashboardFullViewModel` now exposes `DashboardHostRunTool` items instead of
  a raw hosted-run manage list, so attendance-open runs can sort ahead of later
  upcoming hosted runs without rendering a separate arrival card.

### 2.5.61

- Hosts can reopen `HostRunManageScreen` from the Dashboard through a
  horizontally scrollable `HostRunsManageRail` that lists all future hosted runs
  instead of relying on the post-create success screen.
- Host manage summary rows reserve a right-aligned value lane, and roster /
  waitlist empty states use compact title/icon styling instead of oversized
  display empty states.

### 2.5.60

- Run detail descriptions render under an explicit "About this run" heading, so
  backend description text cannot look like stray body copy.
- `RunDetailSocialSection` unlocks review writing only after an attended run has
  ended, and it does not render the reviews divider for guest-only social
  prompts.
- `WhoIsRunning` uses a neutral empty roster surface and suppresses swipe-window
  messaging when no one has booked the run.

### 2.5.59

- `CatchEmptyState` expands across bounded parent widths before centering its
  icon, title, message, and optional action. Do not repair empty-state
  alignment in feature screens with local `Center`/`SizedBox` wrappers; fix the
  shared primitive contract instead.

### 2.5.58

- `SwipeScreen` uses the `swipes` error context and the swipe queue now
  converts stalled candidate loads into a retryable error, so the Discover
  screen does not show an indefinite spinner when profile/candidate loading
  fails to resolve.

### 2.5.57

- `ProfileInfoTile` keeps one fixed-width chevron slot across collapsed and
  expanded inline editing states. Do not swap the closed affordance for a wider
  `IconButton`; it shifts the arrow inward and resets the rotation animation.
- Text-only Profile inline drawers use compact action padding so `Cancel` and
  `Done` stay visually attached to the edited value. Editors with validation
  errors or extra controls keep the roomier panel spacing.
- `RunHypeAvatarStack` now reads `PublicProfile.primaryPhotoThumbnailUrl`, so
  existing profiles with full photos render blurred imagery while thumbnail
  backfills are still catching up. Demo seed data must still write
  `photoThumbnailUrls` so tiny social-proof avatars do not depend on full-size
  images in normal dev fixtures.

### 2.5.56

- Platform chrome is now adaptive for the high-visibility native surfaces:
  `AppShell` uses `CupertinoTabBar` with Cupertino icons on iOS and Material
  `NavigationBar` elsewhere; `CatchTopBarTabBar` uses
  `CupertinoSlidingSegmentedControl` on iOS and Material `TabBar` elsewhere.
- Shell unread badges must reserve their own icon-box space instead of using
  negative offsets; Cupertino tab bars clip overflow above destination icons.
- Date/time selection must go through `showCatchDatePicker` and
  `showCatchTimePicker` so iOS gets bottom-wheel Cupertino pickers while
  Android keeps Material calendar/clock pickers.
- Confirmation dialogs must go through `showCatchAdaptiveDialog` or wrappers
  such as `showConfirmDangerDialog` so iOS gets `CupertinoAlertDialog` and
  Android keeps Material dialogs. Snackbars, app-wide `CatchNotice` overlays,
  and content-heavy Catch bottom sheets remain separate
  app-notification/sheet conventions.

### 2.5.55

- `CatchCelebrationScreen` is now a consistent white-on-orange celebration
  surface. Detail cards, note cards, dividers, icons, close affordances, and
  hero checkmarks use white/white-alpha content instead of the older dark ink
  treatment. Keep celebration CTAs as explicit action controls on the orange
  surface, but do not reintroduce dark text inside celebration content panels.

### 2.5.54

- `CatchSelectMenu` separates trigger radius from popup radius. Pill triggers
  may stay pill-shaped, but opened menus must use normal rounded panel corners
  so first/last rows are not clipped by a giant pill radius. This fixes the Run
  Clubs city picker dropdown and applies to future dropdowns that use the
  shared select primitive.

### 2.5.53

- `StepperFooter` blends into the create-run page background instead of using
  a separate surface band and top divider. Its draft and primary actions share
  the row width directly; do not reintroduce `Spacer` between the actions,
  because it can starve the primary button lane and cause label overflow.

### 2.5.52

- `ProfileInlineEditableText` supports multiline row-owned editing. Bio edits
  directly in the `ProfileInfoTile` value slot with a multiline `EditableText`;
  the inline drawer below the row is reserved for validation/save feedback and
  `Cancel`/`Done`, not a second boxed text field.
- Compact `CatchButton` labels scale down inside tight non-full-width action
  rows so inline editor actions do not produce right-edge overflow on narrow
  devices.

### 2.5.51

- `UpcomingRunsHero` no longer renders one pagination dot per booked run. Its
  carousel affordance is a fixed-width progress rail, while the in-card
  `N/total` pill remains the exact position indicator. Keep unbounded dashboard
  run counts out of width-growing rows.

### 2.5.50

- Chats tab header title is `Chats`, not `Your catches`, so it no longer wraps
  or conflicts with the separate Catches tab. The shared `CatchSliverHeader`
  keeps explicit long-title support through `wrappedTitleHeight`; short-title
  screens should use `twoLineTitleHeight`.
- `CatchSliverHeader` now exposes shared search-row spacing constants for the
  control top padding and the gap to first content. Use these before adding
  local search/list spacing math.
- `ChatListTile` unread state is row-level and conversation-level: warm surface
  tint, primary border, avatar ring, stronger text, and a visible unread chat
  pill by the timestamp. Do not show per-message counts or mark the user's own
  latest message as unread.

### 2.5.49

- Edit Profile bio now uses the same row-owned inline disclosure contract as
  other profile fields. `ProfileInlineTextEntryEditor` supports multiline
  row-owned editing for long text such as Bio.
- The signed-in Bio edit flow no longer uses `ProfilePromptCard` or the
  standalone `ProfileInlineTextEditor`; keep prompt-style bio presentation in
  read-only profile-card widgets.

### 2.5.48

- `PersonAvatar` now supports obscured rendering for tiny hype/social avatars,
  and `PersonAvatarStack` is the shared overlap/overflow primitive. Use the
  stack instead of feature-local circular-avatar stacks.
- `RunHypeAvatarStack` owns the run participant thumbnail row used by Dashboard
  upcoming-run cards and Run detail. It selects recent signed-up/attended
  `runParticipations`, filters toward the viewer's interested-in genders, reads
  `publicProfiles`, and prefers `photoThumbnailUrls` so tiny hype avatars do
  not load full profile photos once profile thumbnail backfill is complete.
- Chat and match celebration avatars should use non-obscured `PersonAvatar`
  with `PublicProfile.primaryPhotoThumbnailUrl`.

### 2.5.47

- `RunPinsMap` is the shared run-pin map canvas for both the browse map and
  single-run location map. Keep map centering outside the pin widget through
  `resolveRunMapInitialCenter`: device location wins until the user manually
  selects a city; selected city is the no-permission/manual-override fallback.
  Run pins must not choose the browse-map camera center.
- `RunMapViewModel` filters to upcoming, non-cancelled runs before rendering
  the browse map. Runs without exact coordinates may remain in the sheet, but
  they must not produce pins.

### 2.5.46

- `ChatThreadPreview` is the inbox rendering contract. The chats list view
  model collapses duplicate active match documents by other participant,
  separates no-message matches into the horizontal rail, and feeds complete
  preview rows to the tile widgets. Chat list tiles and rails should not
  re-fetch public profiles or raw match documents.
- `Match.runIds` replaces the old single `runId` contract. Dart remains
  backward-compatible with legacy `runId` documents, while Functions and demo
  data now write `runIds`. Keep merged run IDs ordered oldest-to-newest so
  `latestRunId` points at the newest shared run.
- Chat messages may temporarily have a null `sentAt` while Firestore resolves a
  server timestamp. Message bubbles must render that as a pending/sending state
  instead of assuming a non-null timestamp.

### 2.5.45

- Run detail location rows are map affordances only when the run has both
  `startingPointLat` and `startingPointLng`. `WhenWhereCard` owns the
  conditional chevron/tappable row, while `RunDetailBody` owns navigation to the
  neutral `/runs/:runId/location` route-backed `RunLocationMapRouteScreen`; do
  not show chevrons for address-only runs.

### 2.5.44

- `DashboardFull` header avatar now uses the current user's
  `primaryPhotoThumbnailUrl` with full-photo fallback and is an explicit button
  to the Profile tab. Tiny avatar-scale surfaces should prefer thumbnail URLs;
  backend thumbnail generation/backfill landed in 2.5.48.

### 2.5.43

- `ChatsListScreen` remains a `CustomScrollView` with a shared
  `CatchSliverHeader`, but the populated body is now sliver-native too:
  `ChatsListBody` returns a `SliverMainAxisGroup`, `ChatNewMatchesRail` is a
  one-off `SliverToBoxAdapter`, and `ChatConversationsList` owns a real
  `SliverList`. Do not reintroduce a shrink-wrapped vertical `ListView` for the
  inbox.
- `ChatListTile` is a full-width `CatchSurface` row using `PersonAvatar` and
  `CatchBadge`; keep chat tile visual changes inside that reusable row instead
  of styling raw `ListTile` instances.

### 2.5.42

- `ChatMessageList` must allow each `MessageBubble` to measure its own height.
  Do not use a one-line `prototypeItem` or fixed item extent for chat messages:
  multi-line bubbles and image bubbles need variable height so timestamps stay
  inside their bubble and do not overlap the next row.

### 2.5.41

- `ChatsListViewModel` is the inbox grouping boundary. It must collapse
  duplicate active match documents by the other participant before rendering,
  keeping the latest message preview/timestamp and deriving a 0/1 unread
  conversation flag for the visible row. Do not sum unread message counts.
- The chats header count is a match/person count, not live presence. Do not
  label it `active` unless the data model adds real presence or activity
  tracking.
- `ChatConversationsList` renders chat rows directly; do not reintroduce a
  redundant `Messages` section title under the screen title.

### 2.5.40

- `CatchRangeSlider` now accepts optional `minLabel` / `maxLabel` endpoint
  labels. Use endpoint labels for fixed slider bounds; do not repeat the
  currently selected range above the slider when the row already shows it.
- Profile inline multi-choice selected chips keep the multi-select check icon
  when rendered in the row value slot.
- Expanded profile row editors use a slightly larger label-to-value gap, while
  the shared inline panel keeps `Cancel`/`Done` closer to the editor controls.

### 2.5.39

- Added `ProfileInlineEditableText` for row-owned Profile text editing. It uses
  `EditableText` directly so the active value keeps the closed row style and
  position while adding only cursor, selection, validation, and a text-width
  underline.
- `ProfileInlineTextEntryEditor` now uses that inline editable value instead
  of embedding a boxed text-field primitive in the row. Long text row variants
  such as Bio now use the same row-owned editable value contract.
- The scroll-away Profile title header now owns only the Settings action. Review
  history, payment history, and sign out moved to `SettingsScreen` Account rows.

### 2.5.38

- `ProfileInlineAnimatedBody` now keeps collapsed and expanded drawers
  full-width and uses fade-only body content transitions while `AnimatedSize`
  owns the vertical reveal. This prevents profile inline action rows from
  sliding sideways during text/chip drawer open/close.
- Profile inline editors now share one internal panel for save errors,
  vertical padding, and `Cancel`/`Done` actions. Field-specific editors should
  provide only their controls and draft-state logic.
- Bio editing uses `ProfileInlineAnimatedBody` too, so edits follow the same
  drawer motion contract as grouped profile rows.
- Removed stale catalog references to the deleted profile bottom-sheet editor
  classes. Normal profile field editing is inline; future exceptions should be
  explicit route/dialog flows, not a resurrected generic field sheet.

### 2.5.37

- Added `ProfileInlineDisclosure` and `ProfileInlineAnimatedBody` as the shared
  animated shell for Edit Profile inline drawers. Text and enum row editors now
  route through the shell, and legacy `ProfileInfoEntry.editor` bodies are
  wrapped by `ProfileInfoSection`, so height/range drawers use the same
  open/close motion.
- `ProfileInfoTile` now animates row-height changes, row value swaps, and
  chevron rotation with `CatchMotion.base`, which covers text-field entry,
  selected chip wrapping, and dynamic chip list changes without custom
  animation controllers.

### 2.5.36

- `SettingsRow` value text now gets a real right-hand value lane when no custom
  trailing widget is supplied. Label/value rows therefore keep the primary
  label pinned left and the secondary value pinned right, while switch/trailing
  rows keep their existing trailing-widget behavior.

### 2.5.35

- Added `ProfileInlineSingleChoiceEntryEditor` and
  `ProfileInlineMultiChoiceEntryEditor` for Profile enum rows. These editors
  render selected `CatchChip` values inside the `ProfileInfoTile.valueEditor`
  slot, exclude selected values from the option list below the row, and keep
  `Cancel`/`Done` as the commit boundary.
- `ProfileInlineSingleChoiceEditor` and `ProfileInlineMultiChoiceEditor` were
  removed from Profile row usage so chip fields follow the same in-row editing
  model as text fields.

### 2.5.34

- `ProfileInfoTile` now supports an optional `valueEditor` slot for in-row
  editing. When present, the tile replaces its value text with the supplied
  control and shows a small collapse icon button instead of wrapping the whole
  row in an `InkWell`, so the embedded field can receive focus.
- Added `ProfileInlineTextEntryEditor`, which renders text Profile rows with a
  compact label-less `CatchTextField` in the value position and keeps
  error/actions below the row. This was superseded by 2.5.49 for long text,
  which uses the same row contract with a multiline body editor.

### 2.5.33

- `ChipField` now enforces required-vs-optional empty selection rules at the
  primitive boundary. `allowEmptySingleSelection` only clears on second tap when
  `isOptional` is true; required single-choice fields keep the selected value.
  Required multi-choice fields do not allow the last selected chip to be
  removed.

### 2.5.32

- `ChipField` now supports `allowEmptySingleSelection`, defaulting to `false`.
  Profile inline single-choice editors enable it so an already-selected chip can
  be tapped again to clear the local draft selection before `Done` saves.
- Profile inline single-choice editors no longer save immediately on chip tap
  and no longer render a separate `Clear` action. They now use the same
  `Cancel`/`Done` footer as text, range, height, and multi-choice editors.

### 2.5.31

- `ChipField` now supports `showLabel`, defaulting to `true` for standalone
  form usage. Expanded Profile inline editors opt out because the parent
  `ProfileInfoTile` already provides the visible field label.

### 2.5.30

- Create/Edit Run Club now uses the shared step-flow form pattern instead of a
  single long form. `CreateRunClubScreen` owns a two-step wizard (`Club basics`
  and `Club details`), reuses `CatchStepFlowHeader`/`StepperFooter`, and keeps
  finite form pages fully mounted so validation covers offscreen fields.
- Added local create-run-club draft support through `RunClubDraft`,
  `RunClubDraftRepository`, and `CreateRunClubDraftController`. Drafts are
  create-only, user-scoped, local to the device, and deleted after successful
  club creation.
- Run-club creation affordances now derive from `canCreateRunClubProvider`.
  The UI hides plus/create controls after the signed-in user already hosts a
  club; the `createRunClub` callable enforces the invariant with the
  server-owned `runClubHostClaims/{uid}` lock.
- Added `CatchStepFlowHeader` as the shared app-bar-level step primitive so
  Create Run, Create Run Club, and Onboarding keep the step count aligned with
  the title row instead of adding a separate vertical counter row.

### 2.5.29

- Edit Profile field editing now uses inline expansion as the default pattern.
  `ProfileInfoSection`/`ProfileInfoEntry` can host an expanded editor below a
  row, and `ProfileInfoTile` shows expanded state instead of always implying a
  route or sheet drill-in.
- Added the Profile inline editor family in
  `lib/user_profile/presentation/widgets/profile_inline_editors.dart` for text,
  nullable single-choice chips, multi-choice chips, height, and range edits.
  These widgets own transient input state and save through
  `ProfileEditController`, leaving repository and Firestore contracts
  unchanged.
- Removed the old profile field bottom-sheet editor file. Complex future flows
  such as photo management may still use focused routes/dialogs, but ordinary
  profile fields should not use bottom sheets.
- `CatchChip` now constrains long labels inside the chip row so inline editors
  and other narrow surfaces can reuse the primitive without feature-local
  overflow fixes.

### 2.5.28

- Reviews are now explicitly split by write contract. Run-club detail uses a
  read-only `RunClubReviewsSection` below the upcoming runs schedule and shows
  only the latest three reviews. Run detail uses `RunReviewsSection`, the only
  page-level review section that can open `WriteReviewSheet` for attended
  runners.
- Dashboard now derives a post-run review prompt from attended runs and the
  current user's existing reviews, then opens the existing run-scoped review
  sheet. The review prompt is a normal dashboard card, not a second mutation
  path.
- Added `ReviewsHistoryScreen` under `/you/reviews`, reachable from the Profile
  overflow menu, so users can see and edit their previous run reviews.

### 2.5.27

- Added `CatchTextButton` as the canonical primitive for inline, dialog,
  banner, and top-bar text-only actions. Raw feature `TextButton` usages were
  migrated to this primitive; `CatchButton` remains the pill CTA primitive.
- Added `CatchOtpCodeField` as the canonical one-time-code input primitive.
  `OtpPage` now delegates its visible digit boxes and hidden platform input to
  that core primitive instead of owning a screen-local raw `TextField`.
- `tool/widget_cleanup_scan.sh` now scans broad primitive-bypass classes:
  raw Material/Cupertino buttons, raw text inputs, literal `SizedBox` spacing,
  decorated feature-local surface shells, and app-facing unstyled `Text`
  candidates. Treat the broad `SizedBox`/surface/text queues as triage lists
  for focused feature batches.

### 2.5.26

- Numeric +/- controls now route through `CatchNumberStepper`. The former
  run-local `DurationStepper` was removed, Create Run duration now uses the core
  primitive directly, and Edit Profile height uses the same primitive for its
  bounded centimeter picker. Distance and capacity fields remain unchanged.
- `tool/widget_cleanup_scan.sh` now flags raw paired add/remove `IconButton`
  steppers outside the core primitive so future one-off numeric controls are
  caught before screenshots expose the drift.

### 2.5.25

- Range sliders now route through the shared `CatchRangeSlider` primitive,
  which hides tick marks centrally while preserving discrete divisions. The
  widget cleanup scanner flags raw `RangeSlider`/`SliderTheme` usage outside
  the primitive.
- Swipe Filters now expose only age and interested-in preferences. Pace range
  and run type are no longer client-editable filters, and the filter save
  controller persists only discovery age plus interested-in genders.
- Edit Profile no longer exposes private discovery preferences (`Interested in`
  and `Age range`). It remains focused on fields that render on the public
  profile/preview surfaces.
- Dark-theme primary CTA foreground is now white via `CatchTokens.primaryInk`,
  so screens using `CatchButton` defaults do not need per-screen foreground
  overrides.

### 2.5.25

- Settings notification toggles are now category-specific: matches/catches,
  messages, run reminders, run changes/cancellations, club announcements, and
  weekly digest. Club announcements are global; the per-club bell is stored on
  the membership edge.
- Run club detail now has a two-tier notification affordance: joining a club
  enrolls the user in durable Activity updates, while the bell next to the
  membership action opts into push notifications for non-critical club updates.
- Upcoming run reminders now have a backend scheduled producer. `ActivitySection`
  suppresses local derived reminder rows when a durable backend `runReminder`
  item already exists for the run.

### 2.5.24

- Activity timeline now also receives backend-owned `runUpdated` and
  `runCancelled` items. `updateRun` creates schedule/location change
  notifications for signed-up and waitlisted participants; `cancelRun` creates
  cancellation notifications. Run cancellation host UI and policy remain queued
  before exposing the action end to end.

### 2.5.23

- Activity timeline now also receives backend-owned `clubUpdate` items when a
  followed club posts a new run. These rows route to run detail through
  `runId`/`runClubId`, matching run signup and waitlist-promotion rows.

### 2.5.22

- Activity timeline now receives backend-owned run booking notifications as
  durable items too. `runSignup` and `waitlistPromotion` rows route to run
  detail through their `runId`/`runClubId` metadata, while upcoming run
  reminders remain local derived rows until the reminder producer exists.

### 2.5.21

- Home activity/notifications now has a durable notification seam.
  `ActivitySection` reads
  `watchActivityNotificationsProvider(uid)` from
  `notifications/{uid}/items`, renders match/message activity from backend-owned
  timeline items, keeps upcoming run reminders as local derived items for now,
  and uses `ActivityController.markAllRead` to mark notification docs read
  before resetting message unread counters.

### 2.5.20

- Run participation roster/count reads are migrated off compatibility arrays.
  `RunParticipationRoster` centralizes edge-derived booked, checked-in, and
  waitlisted ID lists; `WhoIsRunning` and `HostRunManageScreen` use it for exact
  rosters. List/stat surfaces use `Run` count projections instead of hidden
  participant arrays.

### 2.5.19

- Catches/swipes participation reads now use `runParticipations` for candidate
  generation, exhausted-queue empty-state attendance copy, and run recap
  attendee/checked-in state. `RunRecapViewModel` owns the recap data seam.

### 2.5.18

- Host attendance now uses `AttendanceSheetViewModel` to combine the run stream
  with `runParticipations` and derive roster/check-in state from participation
  statuses instead of `runs.signedUpUserIds` or `runs.attendedUserIds`.

### 2.5.17

- Run detail now treats `RunParticipation` as the source of truth for the
  current viewer's booking, waitlist, attendance, CTA, and review eligibility
  state. `RunDetailViewModel` watches `runParticipations/{runId_uid}`,
  `RunDetailBody` passes that edge to detail sections, and `RunDetailCta`
  ignores stale compatibility arrays for current-viewer status.

### 2.5.16

- Relationship-document read migration: Dashboard recommendations, Run Clubs
  list/detail membership state, and Run Map recommendations now read
  `runClubMemberships` instead of profile/club membership arrays.
  `DashboardFull` takes explicit `followedClubIds`, and runs
  recommendations use `RecommendedRunsQuery` so provider keys are stable when
  IDs are derived from membership streams.

### 2.5.15

- Completed the next profile-card polish pass. `RUN PROFILE` is now the only
  running identity section on the shared Swipes/Profile Preview/Public Profile
  card; the redundant lower `RUNNING` chip section and its widget were removed.
  Additional non-hero photos are now inset inside the card with consistent
  margins and rounded corners, while the hero photo remains full-bleed.

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

- Historical note, superseded by 2.5.73: Home mirrored the Profile tab
  architecture. `DashboardScreen` owned a
  route-local `TabController`, `NestedScrollView`, collapsible greeting/empty
  header, pinned `Dashboard`/`Activity` tab row, and native `TabBarView`
  paging. The Dashboard tab renders the existing dashboard widgets as sliver
  bodies, while the Activity tab owns notifications and run/message updates in
  a timeline-style activity feed.

### 2.5.12

- Profile-card follow-up guidance after visual review: Catches, Profile
  Preview, and Public Profile must keep one identical `ProfileSurface` rendering
  path. The canonical running identity should be a single dark `RUN PROFILE`
  card; do not also render duplicate pace/distance chips in a lower `RUNNING`
  card. Additional photo sections should be inset inside the card with
  consistent margins, rounded corners, and spacing instead of edge-to-edge
  blocks unless they are the hero photo.

### 2.5.11

- The shared swipe/profile-preview profile surface received its first polish
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

- Profile Preview now bridges the inner `ProfileSurface` leading overscroll back
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

- The old signed-in profile prompt card used the same label/value typography
  hierarchy as Edit Profile before being retired from the edit flow in 2.5.49.

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

- `ProfileSurface`/`ScrollableProfile` now accept an explicit preview scroll
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
- Historical note: `DashboardScreen` briefly became a `ConsumerStatefulWidget`
  so Home could invalidate the booked-runs stream when the Home tab was no
  longer active. The current Home screen is a stateless single-surface route;
  provider gating remains owned by the route/view-model layer.

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
   run tile variants, `SettingsRow`, `CatchSkeleton`, `CatchBadge`,
   `StatusChip`, `CatchFormFieldLabel`, `ChipField`, `RunAgendaList`,
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
- One-off `Container`/`BoxDecoration` card shells where `CatchSurface`, a run
  tile variant, `PersonRow`, `SettingsRow`, or another existing primitive fits.
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
| `AppShell` | `lib/core/presentation/app_shell.dart:34` | Main tab shell with adaptive bottom navigation (Home, Clubs, Catches, Chats, Profile): Material `NavigationBar` on Android/non-iOS platforms and `CupertinoTabBar` on iOS. Watches provider-backed connectivity for the offline app notice, initializes FCM through `appShellFcmInitializationProvider`, exposes active-tab state through `AppShellActiveTab`, and keeps Crashlytics user ID synced with auth state. Shell-level streams stay limited to shell-wide UI such as auth, connectivity, FCM, and unread badges. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShellActiveTab` | `lib/core/presentation/app_shell_active_tab.dart:9` | Inherited lifecycle signal for indexed-stack tabs. Lets retained tab branches detect whether they are currently selected without coupling feature screens directly to `StatefulNavigationShell`. |
| `_AppShellNavigationBar` | `lib/core/presentation/app_shell.dart:102` | Private adaptive bottom-navigation wrapper with stable key and unread chat badge handling. Uses Cupertino tab-bar chrome/icons on iOS and Material 3 navigation chrome elsewhere. |
| `AppShellNavigationBadge` | `lib/core/presentation/app_shell.dart:218` | Shell chat unread badge. Reserves a fixed icon box and positions the pill inside it so Cupertino and Material bottom nav containers cannot clip the count. |
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
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, `danger`, and `light` variants; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; optional leading icons; and `isInteractive: false` for button-looking labels inside an already tappable parent. Use `light` for solid-white pill CTAs so foreground/background colors stay paired across light and dark themes. |
| `CatchSelectMenu<T>` | `lib/core/widgets/catch_select_menu.dart:9` | Token-driven menu-anchor select primitive. Supports compact/md heights, rounded or pill triggers, optional prefix icons, disabled/error states, and a separately rounded popup panel so pill triggers do not clip opened menu rows. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown for `Labelled` enum-like values. Wraps `FormField<T>` + `DropdownButton<T>` with focus-ring styling and label decoration. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchTextButton` | `lib/core/widgets/catch_text_button.dart:6` | Canonical text-only action primitive for inline actions, dialog actions, retry links, and top-bar text actions. Uses Catch tokens and text styles while preserving Material `TextButton` semantics. Use `CatchButton` for pill CTAs. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:10` | Canonical OTP input primitive. Renders visible token-styled digit boxes over one hidden platform `TextField` so SMS autofill, paste, keyboard input, tests, digit-only filtering, and length limiting stay centralized. |
| `CatchNumberStepper` | `lib/core/widgets/catch_number_stepper.dart:6` | Canonical numeric +/- stepper. Renders the shared raised surface, compact add/remove buttons, centered mono value, optional min/max/step clamping, and feature-specific value formatting. Used by Create Run duration and Edit Profile height. |
| `CatchRangeSlider` | `lib/core/widgets/catch_range_slider.dart:7` | Canonical range slider. Wraps `RangeSlider` in the shared tickless slider theme so age/pace sliders keep discrete values without rendering dashed tick marks. Supports optional min/max endpoint labels for fixed slider bounds. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:11` | Canonical top-bar. Renders a surface-fill bar with an optional back button (auto-detected from `Navigator.canPop`), title, leading widget, and action slots. Also supports a `bottom` `PreferredSizeWidget` (e.g., `TabBar`). Implements `PreferredSizeWidget` for use as an `AppBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:133` | Adaptive top-tab primitive for use inside `CatchTopBar.bottom` or sticky sliver headers. Uses Material `TabBar` with primary indicator on Android/non-iOS platforms and `CupertinoSlidingSegmentedControl` on iOS. Implements `PreferredSizeWidget` and accepts an optional explicit `TabController` for sliver-native tab rows that are not inside a `DefaultTabController`. |
| `showCatchAdaptiveDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:18` | Shared platform-adaptive confirmation/dialog helper. Renders `CupertinoAlertDialog` on iOS and Material `AlertDialog` elsewhere, with typed action values plus default/destructive action metadata. |
| `showCatchDatePicker` / `showCatchTimePicker` | `lib/core/widgets/catch_adaptive_picker.dart:7` | Shared platform-adaptive date/time picker helpers. iOS renders bottom-wheel `CupertinoDatePicker` sheets with Cancel/Done toolbar; Android/non-iOS platforms keep Flutter's Material calendar and clock pickers. |
| `CatchSliverHeader` | `lib/core/widgets/catch_top_bar.dart:290` | Shared sliver header primitive. Builds a scroll-away title and optional pinned bottom row; the title translates upward as it collapses so sticky search/filter/tab rows do not visually cover it. Use `twoLineTitleHeight` for short title/subtitle headers, `wrappedTitleHeight` only when long titles need the extra space, and the shared search-row spacing constants before adding feature-local search/list gap math. Used by Run Clubs, Chats, and Profile. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:156` | Overflow menu action for `CatchTopBar`. Renders a `PopupMenuButton<T>` wrapped in an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Delegates to `CatchTextButton` so top-bar text actions share the same token-driven text-action primitive as dialogs and inline retry links. |
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
| `CatchCelebrationScreen` | `lib/core/celebration/catch_celebration_screen.dart:37` | Shared full-screen celebration surface for high-emotion completion moments. Feature screens provide moment kind, copy, details, optional supplemental children, and primary/secondary actions; the primitive dispatches celebration effects once after first frame. Solid-white primary actions use `CatchButtonVariant.light` instead of per-screen white/foreground overrides. |
| `CelebrationEffectsController` | `lib/core/celebration/celebration_effects_controller.dart:10` | Central haptic/sound boundary for celebration moments. Currently dispatches haptics by `CelebrationMomentKind`; future sound work should be added here instead of directly in feature widgets. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Shared empty-state primitive with icon, title, message, optional action, and surface/plain presentation modes. Expands to bounded parent widths before centering content so plain empty states remain centered inside start-aligned feature sections. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, keeps the parent-owned `selected` set, supports disabled state for pending mutation sheets, and shows a leading check icon on selected chips only in multi-select mode. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Simple row with a label and value, used in detail/read-only views. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
| `showCatchErrorSnackBar` | `lib/core/widgets/catch_error_snackbar.dart:4` | Snackbar helper for transient action failures. Maps errors through `appErrorMessage` before display. |
| `CatchNoticeHost` | `lib/core/widgets/catch_notice.dart:84` | App-wide overlay host for ambient notices. Renders persistent notices such as offline state below the safe area and queues ephemeral event notices through `appNoticeControllerProvider`. |
| `CatchNotice` | `lib/core/widgets/catch_notice.dart:184` | Reusable floating notice primitive with tone, icon, optional message, optional action, and optional dismiss control. Use for ambient app status/events, not inline form errors. |
| `SectionHeader` | `lib/core/widgets/section_header.dart:4` | Section header with uppercase or mixed-case title, optional heavy weight. |
| `StatusChip` | `lib/core/widgets/status_chip.dart:14` | Colored chip displaying run status (open, booked, full, cancelled, attending, waitlisted, not-going, attended, missed). |
| `StatColumn` | `lib/core/widgets/stat_column.dart:5` | Vertical stat display — value on top, label below. Used in run stats grids and profile sections. |
| `AppFormLayout` | `lib/core/widgets/app_form_layout.dart:3` | Form layout wrapper with consistent padding and spacing for form screens. |
| `BottomSheetGrabber` | `lib/core/widgets/bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets. |
| `PersonRow` | `lib/core/widgets/person_row.dart:77` | Multipurpose person row. In chat-thread mode (when `lastMessage` is non-null), renders name, timestamp, context line, last message, and unread badge. In roster mode, renders name, meta line, context line, and an optional trailing widget. Used in chat inbox, rosters, waitlists, and catches previews. |
| `_ChatLayout` | `lib/core/widgets/person_row.dart:136` | Internal chat-thread layout for `PersonRow` — name + timestamp row, run-context row, last-message + unread-badge row. |
| `_RosterLayout` | `lib/core/widgets/person_row.dart:228` | Internal roster layout for `PersonRow` — name + meta line + context line (run icon). |
| `PersonAvatar` | `lib/core/widgets/person_avatar.dart:33` | Circular avatar with deterministic gradient fallback derived from name hash. Supports image URL, colored border ring (for match state or stacking), online status dot, and obscured/blurred rendering for privacy-preserving hype avatars. Named constructor `PersonAvatar.count` shows a "+N" overflow bubble. |
| `PersonAvatarStack` | `lib/core/widgets/person_avatar.dart:130` | Shared overlapping avatar stack with optional overflow count and obscured rendering. Use this instead of feature-local stacked circular-avatar widgets. |
| `_GradientPlaceholder` | `lib/core/widgets/person_avatar.dart:162` | Deterministic gradient placeholder for avatars without a photo. Picks from 12 palettes based on a hash of the name. |
| `ResponsiveBuilder` | `lib/core/responsive/responsive_builder.dart:22` | Thin wrapper around `LayoutBuilder` that maps available width to `ScreenSize` (compact/medium/expanded) and calls the appropriate builder. Falls back gracefully when tablet/desktop builders are absent. |
| `_ButtonLabel` | `lib/core/widgets/catch_button.dart:141` | Internal label+icon row for `CatchButton`. |
| `_LoadingDots` | `lib/core/widgets/catch_button.dart:193` | Three animated dots shown during `CatchButton`'s loading state. |
| `SettingsRow` | `lib/core/widgets/settings_row.dart:25` | Settings-style row with icon, label, optional value, optional trailing widget (e.g., `Switch`), and a danger mode (primary-colored text). Label/value rows allocate separate left and right lanes so the value column right-aligns consistently. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:9` | Profile row primitive with icon, label, value/valueEditor slot, animated row-height/value swap, consistent label/value spacing, a fixed-width animated chevron slot, and stable collapsed/expanded row geometry. |
| `ProfileInlineDisclosure` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:113` | Animated profile inline-editor shell that pairs a row header with a drawer body. Use for row-owned edit interactions instead of manually inserting/removing editor widgets. |
| `ProfileInlineAnimatedBody` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:137` | Animated open/close body used by profile disclosures, prompt-card editors, and legacy `ProfileInfoEntry.editor` bodies. Keeps body width stable while height/fade animates with Catch motion tokens. |

---

## Dashboard

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:21` | Home tab. Watches the user's profile, active run-club memberships, signed-up runs, and Home unread notification count only while Home is active. Renders one `CustomScrollView` with a scroll-away greeting/empty header, top-right Notifications bell, red unread badge, and dashboard sliver body; it no longer owns a route-local tab controller or Dashboard/Activity tab row. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:21` | Standalone full-dashboard wrapper used by focused tests/non-tab embedding. Takes explicit `followedClubIds` from the membership-edge seam and renders the full dashboard header plus `DashboardFullSliverBody`. The header avatar is a Profile-tab button and must use thumbnail-scale profile imagery through `UserProfile.primaryPhotoThumbnailUrl`. |
| `DashboardFullSliverBody` | `lib/dashboard/presentation/widgets/dashboard_full.dart:80` | Sliver body for the populated Home dashboard: first-priority runner self-check-in action card, consolidated host tools carousel, upcoming-runs pager, attended-run section (`StrideCard` + `CatchesCallout`), post-run review prompt for the latest attended unreviewed run, `QuickActions`, and recommended runs. It joins club names for upcoming booked runs through `runClubNameLookupProvider`; notifications are intentionally routed to the dedicated Notifications screen. |
| `HostToolsRail` | `lib/dashboard/presentation/widgets/dashboard_full.dart:192` | Dashboard adapter for shared `HostRunToolsCarousel`. Converts `DashboardHostRunTool` availability into host-tool items and owns only route navigation for Manage and Attendance. |
| `ReviewPromptCard` | `lib/dashboard/presentation/widgets/review_prompt_card.dart:11` | Dashboard card shown after a completed attended run that the user has not reviewed. Opens the shared run-scoped `WriteReviewSheet`; it does not own review persistence. |
| `ActivityScreen` | `lib/dashboard/presentation/activity_screen.dart:18` | Route-level Notifications screen opened from the Home header bell. Uses `CatchTopBar(title: 'Notifications')`, keeps the bottom nav visible by living under the Home shell branch, renders `ActivitySection`, and automatically delegates unread notification docs to `ActivityController.markAllRead` when the screen opens. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:43` | Reusable timeline-style activity feed for backend-owned match, message, club-update, run-signup, waitlist-promotion, run-update, run-cancellation, and run-reminder notification items plus local derived reminders only until the backend reminder exists. Uses a branded inline error state with retry and can either show a manual `Mark all read` action or hide it when a route owns automatic read state. |
| `CatchesCallout` | `lib/dashboard/presentation/widgets/catches_callout.dart:11` | Dashboard card promoting the active catch window — shows the run name, remaining time, roster count, and a "Start catching" CTA. |
| `UpcomingRunsHero` | `lib/dashboard/presentation/widgets/next_run_hero.dart:10` | Horizontal pager for all booked upcoming runs, rendered soonest-first. Delegates tap behavior to the route owner so Home can open a dashboard-owned run detail route and preserve back navigation to Home. Its page affordance is a fixed-width progress rail, not one dot per run, so it remains bounded for unbounded upcoming-run counts. |
| `NextRunHero` | `lib/dashboard/presentation/widgets/next_run_hero.dart:133` | Compatibility wrapper around shared `RunHeroTile` for one booked upcoming run with location, time, distance/pace, projected confirmed-runner count, optional club name, and optional run-position pill. The runner hype row uses shared `RunHypeAvatarStack` so tiny circles use blurred profile thumbnails when available and deterministic obscured placeholders otherwise; never feed this row full-size profile photos. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Intrinsic-height horizontal rail of `RecommendCard` widgets for recommended runs from the user's followed clubs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:11` | Compatibility wrapper around shared `RunRailTile` for dashboard recommended runs. It surfaces distance, price, pace, title, club, date/time, meeting point, signed-up count, and recommendation reason without fake imagery. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Responsive dashboard quick-action grid for Browse runs, Map view, Calendar, and Saved runs. Avoids hardcoded tile heights so labels can wrap without clipping on narrow screens. |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Standalone empty-dashboard wrapper used by focused tests/non-tab embedding. Renders the empty dashboard header plus `DashboardEmptySliverBody`. |
| `DashboardEmptySliverBody` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:116` | Sliver body for the empty Home dashboard. Keeps the existing "book your first run" education flow without embedding activity updates. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Hero card variant shown on the empty dashboard prompting the user to book their first run. Its solid-white CTA uses `CatchButtonVariant.light` so the pill stays legible in dark mode. |
| `DashedAvatar` | `lib/dashboard/presentation/widgets/dashed_avatar.dart:7` | Dashed-border circular avatar placeholder used in empty-state layouts. |
| `RunArrivalActionCard` | `lib/dashboard/presentation/widgets/run_arrival_action_card.dart:17` | First-priority Home card for active run-arrival tasks. Shows participant self check-in or host attendance actions and routes mutations/navigation through `RunBookingController` / router seams. Participant self-check-in opens `RunCheckInCelebrationScreen`; host attendance intentionally does not. |
| `StaticMapDark` | `lib/dashboard/presentation/widgets/static_map_dark.dart:3` | Static map image widget with dark mode support. |

### Sliver Helpers

| Helper | File | Purpose |
|---|---|---|
| `DashboardSliverHeader` | `lib/dashboard/presentation/widgets/dashboard_sliver_header.dart:7` | Dashboard-specific wrapper around `CatchSliverHeader`. Keeps the home greeting/onboarding header visually consistent while allowing it to scroll away with the dashboard content, and exposes trailing action slots such as the Notifications bell. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:220` | Loading scaffold for Home while profile/booked-run data resolves. |
| `_DashboardErrorScreen` | `lib/dashboard/presentation/dashboard_screen.dart:229` | Branded error scaffold for Home profile/booked-run load failures. |
| `_DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_full.dart:161` | Inline loading/error card for a dashboard section (e.g., "Loading your recent runs..."). |
| `_ActivityTile` | `lib/dashboard/presentation/widgets/activity_section.dart:171` | Single row in the Activity timeline — icon marker, title, subtitle, relative time, and optional route. |
| `_ActivityTimelineMarker` | `lib/dashboard/presentation/widgets/activity_section.dart:245` | Timeline rail marker for activity rows. Uses the primary color for unread/high-priority activity and the soft primary surface for normal activity. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:299` | Status label shown for the loading activity state. |

---

## Host Tools

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `HostRunToolsCarousel` | `lib/host_tools/presentation/host_run_tools.dart:22` | Shared full-width host-run carousel for unbounded hosted runs. Uses swipe snapping, a bounded page indicator, and stacked actions so long labels such as "Attendance opens later" do not clip. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `HostRunToolCard` | `lib/host_tools/presentation/host_run_tools.dart:207` | Shared operational card for one hosted run. Shows host/attendance badges, date/time, meet point, booked/waitlist counts, and Manage/Attendance actions using the host palette. |
| `HostRunBottomActions` | `lib/host_tools/presentation/host_run_tools.dart:327` | Sticky host action footer used by run detail. Shows host/attendance badges and the same Manage/Attendance action stack as host-run cards. |
| `HostToolPalette` | `lib/host_tools/presentation/host_run_tools.dart:507` | Token-backed host-tool color helper for default host panels and attendance states. Use this instead of local orange-tinted containers for host chrome. |
| `HostClubToolsPanel` | `lib/host_tools/presentation/host_club_tools.dart:13` | Club-level host panel for Edit club and Add run. Used from run-club detail and kept separate from per-run operational cards. |
| `HostStatsStrip` | `lib/host_tools/presentation/host_club_tools.dart:108` | Shared booked/waitlist/revenue stats strip for host surfaces that aggregate upcoming hosted runs. |
| `HostStatChip` | `lib/host_tools/presentation/host_club_tools.dart:177` | Single reusable host stat chip used by host aggregate strips and host run management stats. |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:22` | Catches decision screen. Watches the swipe queue provider, renders the first candidate as a full `ProfileSurface`, submits section likes/comments through `SwipeQueueNotifier.swipe`, and exposes a floating lower-left pass X instead of deck gestures. Empty-state attendance copy uses the viewer's `RunParticipation` edge instead of compatibility arrays, and stuck queue loads now surface a retryable `Catches unavailable` error instead of spinning forever. |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:19` | Swipe filters screen. Owns local age and interested-in draft state, uses `CatchRangeSlider` for the 18-60+ age range, saves through `FiltersController.saveFiltersMutation`, and pops on successful save. Pace range and run type are intentionally not exposed as filters. |
| `RunRecapScreen` | `lib/swipes/presentation/run_recap_screen.dart:27` | Post-run recap screen showing run details and a checked-in attendee vibe grid. Watches `RunRecapViewModel`, uses keyed vibe tiles, `CatchSurface` for the recap hero, and `CatchEmptyState` for an empty attendee roster. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:22` | "Catches" tab. Gates screen-owned streams while the retained tab branch is inactive, lists edge-backed attended runs with open catch windows, uses leaf widgets to read theme tokens locally, shows a `CatchSurface` intro card with projected checked-in count for the featured run, and lists active runs with `AttendedRunTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:19` | Full-length scrollable profile body used inside `ProfileSurface`. Keeps the shared rendering path identical across Catches, Profile Preview, and Public Profile, renders the hero photo first, then contextual profile insights, profile prompts, one canonical `RUN PROFILE` running identity card, detail chips, inset photos, and lifestyle. Its internal vertical scroll view is non-primary, can accept an explicit controller and route-provided physics when embedded in a sliver route, and can report leading overscroll to a parent route for collapsible-header coordination. |
| `ProfileSurface` | `lib/swipes/presentation/profile_surface.dart:8` | Shared cardless public profile renderer. Wraps `ScrollableProfile`, passes optional viewer/run context for compatibility insights, and mode-gates reaction controls so Catches can show section like/comment affordances while Preview/Public Profile remain passive. |
| `RunRecapViewModel` | `lib/swipes/presentation/run_recap_view_model.dart:10` | Recap data seam. Combines the run, current uid, and `runParticipations` to derive checked-in count and the attendee IDs shown in the vibe grid without reading compatibility arrays. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:236` | Keyed attendee tile on the recap screen. Fetches its public profile, exposes tooltip/semantic selected state, and toggles local recap selection. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub — header, intro card for the featured run, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the run" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. The parent `CatchSurface` owns tap handling; the solid-white CTA is a non-interactive `CatchButtonVariant.light` display label so accessibility and color pairing stay correct. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book a run. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo section inside the shared `ProfileSurface`. The hero photo may be edge-to-edge with the dark gradient and name overlay; additional photos should be inset with consistent margins, rounded corners, and spacing. Shows a branded "Photo coming soon" fallback when the user has no usable image. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Hero overlay for public display name, age, and optional city. Keep relationship goal, distance, and runner metadata out of the hero and in lower profile sections. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:61` | Legacy/specialized goal chip styling retained for profile-card contexts that need a pill, but the default shared card now renders relationship goal as a detail chip rather than hero overlay text. |
| `ProfileCardPalette` | `lib/swipes/presentation/widgets/profile_card_style.dart:4` | Local palette helper for the shared public profile surface. It adapts accent, border, chip, fallback, and shadow colors to the active app light/dark theme while keeping sections coherent across Catches, Preview, and Public Profile. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:6` | Section of detail chips on the shared profile surface. Relationship goal lives here; city stays on the hero overlay, and distance appears here only when current/profile locations are available. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:8` | Reusable section card wrapper for profile detail sections. Uses `ProfileCardPalette` rather than raw app surface colors so sections stay coherent inside the shared public profile surface. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:6` | Prominent bio/prompt section on the shared surface. Uses `ON A PERFECT RUN` as the prompt label and appears before running stats. |
| `ProfileMatchSignalsSection` | `lib/swipes/presentation/widgets/profile_match_signals_section.dart:9` | Contextual signals section near the top of the shared profile surface. Shows profile confidence pills and viewer-aware "Why you might click" reasons, and exposes the section as one reactionable `compatibility` target. |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single info chip on the profile surface — icon + label. |
| `CatchesPassButton` | `lib/swipes/presentation/widgets/catches_pass_button.dart:5` | Floating lower-left pass button used on the Catches decision screen after removing generic deck action buttons. Uses the shared pass key, tooltip, and semantic label. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedRunTile` | `lib/swipes/presentation/widgets/attended_run_tile.dart:14` | Row tile for an attended run in the catches hub list — shows run title, date, projected checked-in count, recap CTA, and swipe badge. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Canonical dark `RUN PROFILE` summary card inside `ScrollableProfile`. Retain this as the single first-class running identity section; it should use `ProfileCardPalette` in light and dark app themes and own the high-signal pace/distance summary. |
| `_RunStatPill` | `lib/swipes/presentation/widgets/scrollable_profile.dart:137` | Small stat pill inside the running identity card. |
| `_RecapHero` | `lib/swipes/presentation/run_recap_screen.dart:144` | `CatchSurface` hero section of the run recap screen — run name, distance, checked-in count, and catch-window status. |
| `_RecapStat` | `lib/swipes/presentation/run_recap_screen.dart:200` | Single stat counter on the recap screen (e.g., "12 Likes", "4 Matches"). |
| `_ProfilePhoto` | `lib/swipes/presentation/run_recap_screen.dart:295` | Single profile photo in the recap attendee grid. |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Empty state when the recap roster has no one. |
| `_FilterSection` | `lib/swipes/presentation/filters_screen.dart:264` | Collapsible section in the filters screen (header + expandable body). |
| `_FilterValue` | `lib/swipes/presentation/filters_screen.dart:296` | Single selectable filter value tile. |

---

## Matches / Chats

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:11` | "Chats" tab. Gates screen-owned streams while the retained tab branch is inactive, then renders the chat conversations list with a sliver header whose badge reports unique matches/people, not live active users. |
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:13` | Sliver body for chat conversations fed from `ChatsListViewModel`. Uses a padded skeleton loading sliver, empty/error states, and delegates populated data to `ChatsListBody`. |
| `MatchCelebrationDialog` | `lib/matches/presentation/widgets/match_celebration_dialog.dart:41` | Compatibility-named full-screen match celebration route. Uses `CatchCelebrationScreen` with match haptics, then routes the primary action into `ChatScreen` or dismisses back to swiping. |
| `ChatListTile` | `lib/matches/presentation/chat_list_tile.dart:9` | Single conversation row in the inbox. Receives a `ChatThreadPreview`, renders one full-width `CatchSurface` row with `PersonAvatar`, latest preview text, timestamp, and row-level unread treatment: warm tint, primary border/accent, avatar ring, stronger text, and a visible 0/1 unread-chat pill near the timestamp. Routes to `ChatScreen`. |
| `ChatNewMatchesRail` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:10` | Horizontal rail of no-message `ChatThreadPreview` matches at the top of the chats list. |
| `_NewMatchAvatar` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:31` | Single new-match avatar in the rail — circular photo with name. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Search text field for filtering chats list. |
| `ChatConversationsList` | `lib/matches/presentation/widgets/chat_conversations_list.dart:8` | Headerless `SliverList` of conversation previews, driven by `ChatsListViewModel`, with stable spacing between full-width chat surfaces. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations. |
| `ChatsListBody` | `lib/matches/presentation/widgets/chats_list_body.dart:7` | Body wrapper for the chats list. Shows new-match rail and headerless conversation rows without a second "Messages" title. |
| `_TitleRow` | `lib/matches/presentation/widgets/chats_sliver_header.dart:16` | "Chats" title row in the chats sliver header. Its badge is a unique match/person count, not presence/active-user detection. |
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
| `ChatMessageList` | `lib/chats/presentation/widgets/chat_message_list.dart:11` | Message-list renderer for loading, error, empty, and populated states. Uses `CatchEmptyState` for empty threads and variable-height `MessageBubble` rows for individual messages. Do not add `prototypeItem`/fixed item extents because chat bubbles can wrap or contain images. |
| `ChatInputBar` | `lib/chats/presentation/widgets/chat_input_bar.dart:7` | Message input bar with text field, image picker button, and send button. |
| `MessageBubble` | `lib/chats/presentation/widgets/message_bubble.dart:6` | Single chat message bubble. Renders differently for sent vs. received messages (alignment, color, corner rounding). Shows timestamp and optional image attachment. |

---

## Public Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreen` | `lib/public_profile/presentation/public_profile_screen.dart:16` | Full-screen public profile view. Fetches `PublicProfile` by UID, passes the current viewer profile into the shared `ProfileSurface` when viewing someone else, and routes report/block actions through `PublicProfileController` mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ProfileBody` | `lib/public_profile/presentation/public_profile_screen.dart:192` | Body of the public profile with a shared cardless profile surface and pending-action overlay. |
| `_ReportReasonTile` | `lib/public_profile/presentation/public_profile_screen.dart:218` | Single selectable report reason row. |

---

## User Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileScreen` | `lib/user_profile/presentation/profile_screen.dart:16` | Profile tab destination. Gates screen-owned streams while the retained tab branch is inactive, owns the route-level top safe area, uses `NestedScrollView` for a scroll-away Profile title header plus pinned `Edit`/`Preview` tab row, and native `TabBarView` paging for smooth horizontal tab swipes. The scroll-away title remains a normal outer sliver; the pinned tab row is wrapped in `SliverOverlapAbsorber`; each tab body starts with `SliverOverlapInjector`. Owns the `TabController` locally because tab selection is route UI state. |
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:19` | Standalone profile tab content. Wraps the shared profile sections in a `ListView` for isolated/non-sliver usage and shows profile-quality guidance above photos from the public-profile insight scorer. Uses `profileTabBodyPadding` for the shared Profile tab inset. `Display name` is the first editable About field and is the only public-facing profile name; onboarding identity fields such as date of birth and gender are readonly, and last name is not shown publicly. Optional/profile-detail fields, including Instagram, remain editable. Running Details owns pace, distances, reasons, and favorite run times. Discovery-only preferences such as interested-in genders and match age range live in Filters, not Edit Profile. Optional single-choice edit sheets open unselected when the underlying field is empty. |
| `ProfileTabSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:48` | Sliver-native profile tab body. Reuses the same profile sections as `ProfileTab` but contributes a padded `SliverList` for parent `CustomScrollView` usage. Uses the same `profileTabBodyPadding` as Preview. |
### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared `ProfileSurface`, with owner-provided scroll controller, physics, bottom padding, and leading-overscroll callback when mounted inside ProfileScreen. |
| `ProfileInfoSection` | `lib/user_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows with a section header. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:6` | Single profile info row with icon, label, value or in-row value editor, and animated expanded chevron. Row-owned edits expand inline rather than opening a field sheet; expanded editor values get a little more vertical breathing room than closed text values. |
| `_ProfileUnavailableBody` | `lib/user_profile/presentation/profile_screen.dart:103` | Missing-profile state. Prevents the profile route from rendering a blank body when the signed-in user profile is unavailable. |
| `_PreviewTabSliverBody` | `lib/user_profile/presentation/profile_screen.dart:120` | Sliver-native preview body. Gives the shared `ProfileSurface` bounded remaining viewport height inside the profile route's preview tab scroll view, passes a dedicated profile scroll controller, applies `profileTabBodyPadding` inside the filled child, and bridges upward scroll plus leading overscroll to the outer Profile header. |
| `_ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:25` | Scroll-away Profile title row with one Settings action. Account actions live inside Settings, not in a second header overflow menu. |
| `_ProfileTabBar` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:55` | Pinned Edit/Preview tab bar surface for the sliver-native profile route. The route-level `SafeArea` keeps it below device cutouts without adding an expanded-header gap. |
| `_SettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:82` | Settings gear button in the scroll-away profile title header. |
| `ProfileInlineEditableText` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:105` | Row-value editable text primitive built on `EditableText`. Preserves the closed row value style/position, supports multiline row-owned editing for Bio, and signals focus with cursor, selection, and a text-width underline instead of a boxed field. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileInlineTextEntryEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:221` | Row-owned text editor that turns `ProfileInfoTile` values into `ProfileInlineEditableText`, including multiline Bio editing in the row value slot, and keeps validation plus trailing `Cancel`/`Done` actions in the shared inline panel. |
| `ProfileInlineHeightEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:473` | Inline bounded height editor using `CatchNumberStepper` and the shared inline editor panel. |
| `ProfileInlineSingleChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:533` | Row-owned nullable single-choice editor. Selected value renders in the row slot, available alternatives render below, and `Cancel`/`Done` owns commit/discard. |
| `ProfileInlineMultiChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:656` | Row-owned multi-choice editor. Selected chips stay in the row slot with check icons, available alternatives render below, and optional fields allow deselecting row chips. |
| `ProfileInlineRangeEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:912` | Inline range editor using `CatchRangeSlider`, local draft range state, endpoint labels for slider bounds, and the shared inline editor panel. The row owns the selected range display, so the editor does not repeat it above the slider. |

---

## Onboarding

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OnboardingScreen` | `lib/onboarding/presentation/onboarding_screen.dart:16` | Multi-step onboarding flow shell. Manages step navigation via `PageController`, renders the step progress bar, and delegates to individual step pages. |
| `NameDobPage` | `lib/onboarding/presentation/pages/name_dob_page.dart:11` | Name and date-of-birth entry page — text field + date picker. |
| `GenderInterestPage` | `lib/onboarding/presentation/pages/gender_interest_page.dart:12` | Gender identity and interest selection page using `ChipField` with semantic chip keys for self-identification vs interested-in selections. |
| `RunningPrefsPage` | `lib/onboarding/presentation/pages/running_prefs_page.dart:15` | Running preferences page — pace, preferred distances, reasons for running, and favorite run times. Uses `CatchRangeSlider` for the comfortable pace range and `ChipField` for selectable identity/preferences. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomePage` | `lib/onboarding/presentation/pages/welcome_page.dart:10` | Landing/welcome page shown at the start of onboarding — app logo, tagline, and phone CTA. The solid-white CTA uses `CatchButtonVariant.light` instead of screen-local white/foreground overrides. |
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
| `CreateRunClubScreen` | `lib/run_clubs/presentation/create/create_run_club_screen.dart:23` | Create/edit run club form. Uses a two-step wizard with `CatchStepFlowHeader`, `StepperFooter`, create-only local drafts, cover photo picking, and submit mutation feedback. Handles both create and edit flows (initialized via `initialRunClub`). |
| `RunClubBasicsStep` | `lib/run_clubs/presentation/create/widgets/run_club_basics_step.dart:10` | First run-club form step. Keeps cover, club name, city, and area fields in one fully mounted scroll body so validation sees all required fields. |
| `RunClubDetailsStep` | `lib/run_clubs/presentation/create/widgets/run_club_details_step.dart:6` | Second run-club form step. Holds required description plus optional contact fields. |
| `CityPicker` | `lib/run_clubs/presentation/list/widgets/city_picker.dart:12` | City selector dropdown at the top of the clubs list. Matches `CatchTextField.compactControlHeight` and pill styling so it aligns visually with `RunClubsSearchField`; watches and updates `selectedRunClubCityProvider`, listens for GPS location updates, and keeps showing the selected city while the remote city list is loading or unavailable. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubDetailScreen` | `lib/run_clubs/presentation/detail/run_club_detail_screen.dart:16` | Run club detail screen. Fetches the club, current user profile, active membership edge, upcoming runs, and reviews; join/leave mutations stay in `RunClubMembershipController`. Renders `ClubDetailBody`. |
| `RunClubsList` | `lib/run_clubs/presentation/list/widgets/run_clubs_list.dart:11` | Sliver state-dispatch widget for the clubs tab. Renders skeleton, error, empty, and data slivers from `RunClubsListViewModel`, which partitions joined/discover clubs from active membership edges, and owns join-mutation feedback. |
| `RunClubsSearchField` | `lib/run_clubs/presentation/list/widgets/run_clubs_search_field.dart:6` | Search text field for filtering the clubs list. |
| `_SearchRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:66` | Search row inside the clubs sliver header. |
| `MembershipButton` | `lib/run_clubs/presentation/detail/widgets/membership_button.dart:6` | Join/Leave/Request membership button on the club detail screen. Calls `RunClubMembershipController`. |
| `MutationErrorSnackbarListener` | `lib/core/widgets/mutation_error_snackbar_listener.dart:13` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used for transient mutation errors such as join/leave club failures. |
| `_DirectoryCard` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:3` | Directory-style club card with cover image, host avatar, stats strip, and role-aware membership CTA. Hosts render a non-interactive `Host` pill, members render `Joined`, and discoverable clubs render `Join`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubsListScreen` | `lib/run_clubs/presentation/list/run_clubs_list_screen.dart:11` | "Clubs" tab. Gates screen-owned streams while the retained tab branch is inactive, then renders the clubs sliver header (city picker, search, create button) + `RunClubsList` body. |
| `RunClubsListBody` | `lib/run_clubs/presentation/list/widgets/run_clubs_list_body.dart:7` | Sliver-native data body for the clubs tab. Composes the joined-club horizontal rail and discover sliver list without embedding a vertical `ListView` inside the parent `CustomScrollView`. |
| `RunClubDiscoverList` | `lib/run_clubs/presentation/list/widgets/run_club_discover_list.dart:6` | Discovery section of the clubs list with a real `SliverList` of directory cards. Passes joined and hosted club IDs separately so host-owned clubs are not mislabeled as ordinary joined clubs. |
| `RunClubListTile` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile.dart:26` | Club tile rendered as directory card or avatar chip. Display-only tile rendering does not watch provider state; only the join button owns the mutation provider, and host state is passed explicitly for role-aware labeling. |
| `RunClubsEmptyState` | `lib/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart:5` | Empty state when no clubs are found. |
| `RunClubAvatarRail` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:9` | Horizontal avatar rail of the user's joined clubs + a create-club button. |
| `_CreateClubButton` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:34` | "+" button at the end of the avatar rail to create a new club. |
| `_TitleRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:22` | "Clubs" title row in the clubs sliver header. |
| `_AddButton` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:50` | "+" button next to the title to create a new club. |
| `ClubHeroAppBar` | `lib/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart:15` | Hero-style app bar for the club detail screen — large cover image, club name, location, and back button. |
| `ClubDetailBody` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:21` | Scrollable club detail body — about section, stats, host/member controls, upcoming runs list, then read-only club review aggregate. Club detail never exposes review creation because reviews are associated with specific runs. |
| `ClubScheduleSection` | `lib/run_clubs/presentation/detail/widgets/club_schedule_section.dart:9` | Sliver-native agenda section for a club's upcoming runs. Reuses `RunAgendaSliverList`, shows empty state when no upcoming runs exist, routes selected runs to detail, and marks host-owned schedules with the `HOSTED` run-tile status. |
| `_ClubContactSection` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:148` | Contact info section — Instagram, website, WhatsApp, email rows. |
| `_ContactRow` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:201` | Single contact row (icon + label + value). |
| `HostStatsBar` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:5` | Compatibility wrapper around shared `HostStatsStrip` for upcoming club-run booked, waitlist, and revenue totals. Prefer `HostStatsStrip` for new host surfaces. |
| `StatsStrip` | `lib/run_clubs/presentation/detail/widgets/stats_strip.dart:6` | Horizontal strip of stats — runs hosted, members, location — shown on club cards. |
| `RunClubCoverFallback` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:6` | Gradient + chip fallback shown when a club has no cover photo. |
| `_CoverChip` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:98` | Small distance/location chip overlaid on the cover fallback. |
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
| `CreateRunScreen` | `lib/runs/presentation/create_run_screen.dart:29` | Multi-step run creation flow (Run details → Where → When → Eligibility). Manages `PageController`, draft save/restore, local form controllers, and the create-run mutation. On success transitions to `CreateRunSuccessScreen` or `HostRunManageScreen`. |
| `RunMapScreen` | `lib/runs/presentation/run_map_screen.dart:18` | Chromeless map route wrapper. Watches `RunMapViewModel`, centers on device location unless the selected run-club city was manually overridden or location is unavailable, owns local selected-run state, and composes full-screen `RunPinsMap`, floating `MapOverlayControls`, and `RunMapSheet`. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `HostRunManageRouteScreen` | `lib/runs/presentation/host_run_manage_screen.dart:23` | Route-facing host manage entry used from Dashboard. Loads the run and club by id, gates access to the club host, and delegates the loaded state to `HostRunManageScreen`. |
| `RunDetailScreen` | `lib/runs/presentation/run_detail_screen.dart:8` | Route-facing run detail entry. Fetches `RunDetailViewModel`, renders scaffolded loading/error/not-found states, and delegates the loaded screen to `RunDetailBody` without nesting scaffolds. |
| `RunLocationMapRouteScreen` | `lib/runs/presentation/run_location_map_screen.dart:20` | Route-facing single-run map entry. Reuses `RunDetailViewModel` by `runId`, renders chromeless load/error/not-found states with floating back controls, and delegates mapped runs to `RunLocationMapScreen`. |
| `RunDetailBody` | `lib/runs/presentation/widgets/run_detail_body.dart:24` | Scrollable run detail body — owns the loaded detail `Scaffold`, composes `RunDetailHeroAppBar`, `RunDetailOverviewSection`, `RunDetailSocialSection`, and the bottom CTA. Passes the viewer's `RunParticipation` edge to social/review and CTA sections so current-viewer state is not inferred from compatibility arrays. Owns run-location navigation and passes it down only when the run has exact coordinates. |
| `RunDetailCta` | `lib/runs/presentation/widgets/run_detail_cta.dart:24` | Bottom CTA bar for run detail. For hosts it renders shared `HostRunBottomActions` with Manage and attendance availability; for runners it owns booking lifecycle actions (book, cancel, waitlist, eligibility, attended/past states) from the current viewer's `RunParticipation` edge. It only treats `attended` as completed once the run has started so stale future attendance data cannot contradict upcoming schedule surfaces. Free-run signup opens `RunJoinedCelebrationScreen`; paid signup routes to payment confirmation. |
| `AttendanceSheetScreen` | `lib/runs/presentation/attendance_sheet_screen.dart:23` | Host-facing attendance sheet. Watches `AttendanceSheetViewModel`, renders route-level loading/error/not-found states, and delegates attendance body composition to `_AttendanceList` with host-tool visual treatment. |
| `AttendanceSheetViewModel` | `lib/runs/presentation/attendance_sheet_view_model.dart:9` | Attendance data seam. Combines the run stream with `runParticipations` and derives attendee IDs plus checked-in state from participation statuses so host attendance does not read compatibility arrays. |
| `WhoIsRunning` | `lib/runs/presentation/widgets/who_is_running.dart:32` | Run detail social roster. Watches `RunParticipationRoster` for booked counts and renders shared blurred `RunHypeAvatarStack` thumbnails; uses `Run` count projections only as a loading fallback. Empty rosters render a neutral empty surface and do not show swipe-window messaging until at least one runner is booked. |
| `RunHypeAvatarStack` | `lib/runs/presentation/widgets/run_hype_avatar_stack.dart:80` | Shared run social-proof avatar row for Dashboard and Run detail. Provider-owned selection queries recent signed-up/attended `runParticipations`, filters toward viewer interest genders, fetches `publicProfiles`, and passes `PublicProfile.primaryPhotoThumbnailUrl` into blurred avatars so thumbnail URLs are preferred while older full-photo-only profiles still render imagery. |
| `_AttendanceList` | `lib/runs/presentation/attendance_sheet_screen.dart:71` | Attendance body. Handles empty/profile-loading/profile-error states, mutation error banner, checked-in summary, and the attendee list from `AttendanceSheetViewModel`. |
| `_AttendeeRow` | `lib/runs/presentation/attendance_sheet_screen.dart:183` | Single attendance row using `CatchSurface`, `PersonRow`, and `CatchBadge`; routes toggle actions through `RunBookingController.markAttendanceMutation`. |
| `RunPinsMap` | `lib/runs/presentation/widgets/run_pins_map.dart:7` | Shared Flutter map canvas for run pins. Used by both `RunMapScreen` and `RunLocationMapScreen`; renders only runs with exact coordinates, recenters when the route resolves a better initial center such as device location, and gives selected run coordinates precedence when a map-browse tile or pin is tapped. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `LocationPickerScreen` | `lib/runs/presentation/location_picker_screen.dart:17` | Chromeless map-based location picker. Lets users tap or search for a location and returns the selected `LocationCoordinate`; keeps `Confirm` and search as floating map controls instead of a top app bar. |
| `_DraftPickerSheet` | `lib/runs/presentation/widgets/draft_picker_sheet.dart:37` | `CatchBottomSheetScaffold` listing saved run drafts. Users can resume, start fresh, or permanently delete persisted drafts through the create-run draft controller. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunSuccessScreen` | `lib/runs/presentation/create_run_success_screen.dart:10` | Host run-created success screen backed by `CatchCelebrationScreen`. Shows live-run confirmation details, run-created haptics, "Manage run", and "Back to club" actions. |
| `RunJoinedCelebrationScreen` | `lib/runs/presentation/run_joined_celebration_screen.dart:7` | User run-signup celebration surface shared by free bookings and post-payment confirmation. Shows run details, optional payment details, supplemental payment actions, haptics, and View run / Back home actions. |
| `RunCheckInCelebrationScreen` | `lib/runs/presentation/run_check_in_celebration_screen.dart:7` | Participant self-check-in celebration surface. Used only after user self-check-in from Home succeeds; host attendance remains a normal operational flow. |
| `RunCheckInLocationService` | `lib/runs/presentation/run_check_in_location_service.dart:5` | Provider-backed location seam for self-check-in. Production uses Geolocator with high accuracy and a timeout; tests can inject coordinates without invoking platform plugins. |
| `RunLocationMapScreen` | `lib/runs/presentation/run_location_map_screen.dart:63` | Chromeless full-screen single-run map with one pinned exact starting point, floating back controls, and a bottom location summary. Reuses `RunPinsMap`; use only when `Run.hasExactStartingPoint` is true. Address-only runs should stay static and show no chevron. |
| `HostRunManageScreen` | `lib/runs/presentation/host_run_manage_screen.dart:95` | Host run management screen — shows shared host stat chips, summary, host cancel/delete actions, profile-backed roster, and waitlist. Roster/waitlist IDs come from `runParticipations` through `RunParticipationRoster`; count stats treat `Run` projections as a conservative floor so delete remains unavailable when aggregate activity is visible. |
| `CreateRunStepHeader` | `lib/runs/presentation/widgets/create_run_step_header.dart:7` | Header for the create-run wizard — back action, step title, club name, step count, and progress bar. |
| `CreateRunFormKeys` | `lib/runs/presentation/create_run_form_keys.dart:3` | Stable semantic keys for create-run form fields so widget tests target fields by purpose rather than layout order. |
| `_HostRunActionsCard` | `lib/runs/presentation/host_run_manage_screen.dart:257` | Host action surface for cancelling active runs and deleting unused runs. Uses Pattern A `RunBookingController` mutations, destructive confirmation dialogs, mutation error banners, and activity-aware delete gating. |
| `_HostRunSummaryCard` | `lib/runs/presentation/host_run_manage_screen.dart:426` | `CatchSurface` summary card showing run details on the host manage screen. Label/value rows reserve a right-aligned value lane so club, meet point, run details, and price align consistently. |
| `_HostRunSummaryRow` | `lib/runs/presentation/host_run_manage_screen.dart:474` | Single key-value row in the host summary card. |
| `_HostRunRosterSection` | `lib/runs/presentation/host_run_manage_screen.dart:545` | Async roster adapter for host manage. Renders loading/error states for `RunParticipationRoster` and passes selected booked/waitlisted IDs to `_HostRunUserList`. |
| `_HostRunRosterLoading` | `lib/runs/presentation/host_run_manage_screen.dart:582` | Small `CatchSurface` loading row for host roster/waitlist sections. |
| `_HostRunUserList` | `lib/runs/presentation/host_run_manage_screen.dart:610` | Profile-backed roster/waitlist list on the host manage screen. Uses `PersonRow`, `CatchBadge`, and `CatchEmptyState`. |
| `_AttendanceSummaryHeader` | `lib/runs/presentation/attendance_sheet_screen.dart:148` | Host-palette attendance summary card showing checked-in count, host/attendance badges, and the toggle hint. |
| `SavedRunsScreen` | `lib/runs/presentation/saved_runs_screen.dart:15` | Saved-runs route. Streams the current user's saved run details, orders future saved runs before past saved runs, joins club names via `runClubNameLookupProvider`, and opens saved-run detail routes from shared agenda tiles. |
| `RunTileData` | `lib/runs/presentation/widgets/run_tiles/run_tile_data.dart:10` | Shared display model for run tile variants. Wraps a `Run` plus relationship status, optional club name, recommendation reason, and carousel position label so widgets do not recompute product state. |
| `RunTileStatusBadge` | `lib/runs/presentation/widgets/run_tiles/run_tile_atoms.dart:6` | Status badge mapper for run tile relationship states (`joined`, `saved`, `recommended`, `hosted`, `past`, etc.) using `CatchBadge` tones and icons. |
| `RunAgendaTile` | `lib/runs/presentation/widgets/run_tiles/run_agenda_tile.dart:7` | Agenda/list tile for Calendar, Saved runs, and Run club schedules. It is content-sized, can show global club context, and displays time, meeting point, status, distance, pace, and spots. |
| `RunRailTile` | `lib/runs/presentation/widgets/run_tiles/run_rail_tile.dart:8` | Horizontal discovery/recommendation tile for dashboard rails. Shows status, distance, pace, price, title, club, date/time, meeting point, signup count, and optional recommendation reason. |
| `RunHeroTile` | `lib/runs/presentation/widgets/run_tiles/run_hero_tile.dart:8` | Dashboard hero tile for booked upcoming runs. Shows next-run countdown, optional carousel position, title, club, time/location/distance metadata, and `RunHypeAvatarStack` social proof. |
| `RunMapTile` | `lib/runs/presentation/widgets/run_tiles/run_map_tile.dart:8` | Map bottom-sheet tile for mixed nearby runs. Shows relationship status, no-pin state, club, time, location, distance, pace, price, and signup count; tap selects/recenters the map while the sheet button opens detail. |
| `RunAgendaList` | `lib/runs/presentation/widgets/run_agenda_list.dart:9` | Box-facing agenda list for runs grouped by day. Sorts by start time by default, with `preserveInputOrder` for callers that precompute semantic order plus optional club-name/status builders for global mixed-state surfaces. |
| `RunAgendaSliverList` | `lib/runs/presentation/widgets/run_agenda_list.dart:46` | Sliver-facing agenda list for runs grouped by day. Sorts by start time by default, with `preserveInputOrder` for sliver-native screens such as Calendar/Saved runs that need semantic ordering. |
| `RunAgendaRunCard` | `lib/runs/presentation/widgets/run_agenda_list.dart:136` | Backward-compatible wrapper around `RunAgendaTile` for existing agenda tests/callers. New surfaces should pass `RunTileData` to a specific run tile variant where possible. |
| `WhenStep` | `lib/runs/presentation/widgets/when_step.dart:7` | "When" form step in create run — date + time pickers plus duration selection through `CatchNumberStepper`. |
| `WhereStep` | `lib/runs/presentation/widgets/where_step.dart:8` | "Where" form step — location picker, address display, and map preview. |
| `RunDetailsStep` | `lib/runs/presentation/widgets/run_details_step.dart:9` | "Details" form step — distance, pace, price, capacity, and vibe tags. |
| `EligibilityStep` | `lib/runs/presentation/widgets/eligibility_step.dart:9` | "Eligibility" form step — gender, age, and experience requirements. |
| `StepProgressBar` | `lib/runs/presentation/widgets/step_progress_bar.dart:4` | Horizontal step indicator showing current step out of total. |
| `StepperFooter` | `lib/runs/presentation/widgets/stepper_footer.dart:5` | Create-run bottom action footer. Blends into the page background with no top divider, renders draft as a ghost action, and gives the primary action a full-width lane so labels such as `Schedule run` scale within the available width instead of overflowing. |
| `WhenWhereCard` | `lib/runs/presentation/widgets/when_where_card.dart:8` | Card showing when/where info. The location row is tappable and shows a chevron only when both exact coordinates and an `onLocationTap` callback are present; address-only runs render static text. |
| `RunStatsGrid` | `lib/runs/presentation/widgets/run_stats_grid.dart:8` | Grid of stat cells (distance, pace, signed-up count, etc.) for run detail. Values scale down within their cell instead of forcing fixed-width overflow on narrow screens or larger text settings. |
| `RunStatCell` | `lib/runs/presentation/widgets/run_stats_grid.dart:39` | Single stat cell with value + label. |
| `RunStatDivider` | `lib/runs/presentation/widgets/run_stats_grid.dart:81` | Vertical divider between stat cells. |
| `RunDetailHeroAppBar` | `lib/runs/presentation/widgets/run_detail_hero_app_bar.dart:7` | Sliver hero app bar for run detail. Owns the photo/map hero, back/share controls, and saved-run icon state. |
| `RunDetailOverviewSection` | `lib/runs/presentation/widgets/run_detail_overview_section.dart:10` | Static run facts section for the loaded run detail body: title, pace/date, stats, when/where, labeled description, and requirements. |
| `RunDetailSocialSection` | `lib/runs/presentation/widgets/run_detail_social_section.dart:10` | Social context section for the loaded run detail body: roster, guest lock prompt, divider, and run-scoped reviews for signed-in users. Review writing requires the current viewer's attended `RunParticipation` and a run end time that has passed. |
| `MapOverlayControls` | `lib/runs/presentation/widgets/map_overlay_controls.dart:5` | Floating safe-area controls for chromeless map surfaces. Provides the rounded back affordance plus optional trailing and below content for map actions such as create-run confirm/search. |
| `RunMapSheet` | `lib/runs/presentation/widgets/run_map_sheet.dart:12` | Overlay sheet for map runs. Uses `CatchSurface`, renders horizontal `RunMapTile` items from relationship-aware `RunMapItem` data, and routes the highlighted run to the dashboard run-detail path from the top-level map surface. |
| `RunPhotoHeader` | `lib/runs/presentation/widgets/run_photo_header.dart:6` | Photo header for the run detail screen. Renders uploaded `Run.photoUrl` images with a themed fallback when a run has no photo. |
| `CreateRunPhotoPicker` | `lib/runs/presentation/widgets/create_run_photo_picker.dart:7` | Optional create-run photo picker surface. Shows selected image bytes before submission and delegates picking/upload behavior to `CreateRunController`. |
| `MapPinTile` | `lib/runs/presentation/widgets/map_pin_tile.dart:7` | Create-run map-pin tile. Shows whether the starting point is pinned without exposing raw coordinates in the form preview. |
| `PickerTile` | `lib/runs/presentation/widgets/picker_tile.dart:6` | Tappable tile that opens a picker (date, time, etc.) — shows label + selected value. |
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
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:18` | Calendar route for planned runs. Merges booked runs with future saved runs, labels mixed agenda rows as JOINED/SAVED, uses one sliver-native scroll surface, anchors the header to the next upcoming run or current week, and manages local view mode state (`agenda` vs `timeline`). |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarHeader` | `lib/calendar/presentation/calendar_screen.dart:86` | Calendar header inside the route's sliver scroll surface — month label, `CatchSegmentedControl`, week strip, and `CatchSurface` stats row. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:179` | Horizontal week strip showing 7 days with date indicators. Anchors to the next upcoming run, or to the current week when there is no upcoming run. |
| `_WeekDay` | `lib/calendar/presentation/calendar_screen.dart:211` | Single day cell in the week strip — day name, date number, and active indicator. |
| `_TimelineSliverList` | `lib/calendar/presentation/calendar_screen.dart:265` | Sliver-native day/timeline view of planned runs using the same upcoming-first ordering as agenda mode. |
| `_TimelineRun` | `lib/calendar/presentation/calendar_screen.dart:290` | Single `CatchSurface` run block in the timeline view — time, meeting point, distance, and pace. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:360` | Divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:375` | Calendar empty/error state rendered through `CatchEmptyState`. |
| `_CalendarRunSummary` | `lib/calendar/presentation/calendar_screen.dart:398` | Private view model for calendar display order and header stats. De-duplicates signed-up/saved runs, keeps only future saved-only runs, puts upcoming runs first, uses current week as the fallback anchor, and exposes `nextRun`. |

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
| `SettingsScreen` | `lib/safety/presentation/settings_screen.dart:29` | Full settings screen. Manages optimistic notification toggle state, wraps settings and sign-out mutations in shared snackbar error feedback, delegates preference/deletion/unblock writes to `SettingsController`, owns sign out through `AuthSessionController`, and composes account/history, discovery, notification, safety, about, and delete-account sections. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `_BlockedAccountsSection` | `lib/safety/presentation/settings_screen.dart:454` | Section listing blocked accounts. Uses `CatchLoadingIndicator` for loading, `CatchEmptyState` for empty/error states, and renders `_BlockedAccountTile` rows for blocked users. |
| `_BlockedAccountTile` | `lib/safety/presentation/settings_screen.dart:513` | Single blocked account row. Resolves the blocked user's public profile, renders a `PersonRow`, and routes the semantic unblock button through `SettingsController.unblockUserMutation`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_SettingsSection` | `lib/safety/presentation/settings_screen.dart:420` | Private section helper that pairs a `SectionHeader` with the shared settings card shell. |
| `_SettingsCard` | `lib/safety/presentation/settings_screen.dart:438` | Private `CatchSurface` wrapper for settings row groups. |
| `SettingsKeys` | `lib/safety/presentation/settings_keys.dart:3` | Stable semantic keys for account action rows, settings switches, delete-account row, and blocked-user unblock buttons. |
| `showConfirmDangerDialog` | `lib/core/widgets/confirm_danger_dialog.dart:4` | Shared destructive confirmation dialog helper used by safety/account actions such as block and delete-account confirmations. Delegates to `showCatchAdaptiveDialog` so iOS gets Cupertino alert chrome and Android/non-iOS platforms keep Material alert chrome. |

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
| `_WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:39` | Bottom sheet for writing, editing, or deleting a run review. Requires a concrete `runId`, uses `CatchBottomSheetScaffold`, semantic star/action keys, inline mutation errors, and `WriteReviewController` submit/delete mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubReviewsSection` | `lib/reviews/presentation/reviews_section.dart:19` | Read-only club review aggregate. Shows the latest three reviews and never opens the write/edit sheet. |
| `RunReviewsSection` | `lib/reviews/presentation/reviews_section.dart:44` | Run-scoped reviews with write/edit CTA for attended runners. This is the only page-level review section that should open `WriteReviewSheet`. |
| `ReviewsPreviewSection` | `lib/reviews/presentation/reviews_section.dart:120` | Shared read-only preview list: header, aggregate rating, empty state, top-N review cards, and optional see-all sheet. Callers supply edit callbacks only when the parent surface is run-scoped. |
| `ReviewsHistoryScreen` | `lib/reviews/presentation/reviews_history_screen.dart:19` | Profile-owned review history screen. Lists the current user's reviews newest-first and opens the shared edit review sheet for run-backed reviews. |
| `ReviewCard` | `lib/reviews/presentation/reviews_section.dart:226` | Single tokenized review surface with reviewer avatar/name, star rating, optional comment, and optional edit action for the current user's own review. |
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
