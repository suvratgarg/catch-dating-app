---
doc_id: widget_catalog
version: 2.5.149
updated: 2026-05-27
owner: recursive_audit_loop
status: active
---

# Widget Catalog

## Read Policy

Use this as inventory, not as the primary process prompt. For process rules,
start with `docs/audit_registry/README.md`,
`docs/audit_registry/rules.json`, and `docs/audit_registry/backlog.json`. Read
a feature section here only when auditing that feature's widget surface.

## Rule Changelog

### 2.5.149

- Explore's closed/list state now paints an explicit top lid across the
  status-bar/notch area plus header/filter chrome. The map can remain mounted
  behind the sheet for continuity, but it is only allowed to show through the
  safe area after the map reveal starts and that lid fades away.

### 2.5.148

- Production Explore now uses a mixed discovery feed instead of separate
  personal-club, event, spotlight, and club-directory blocks. The full sheet
  interleaves compact activity-coded event rows, an Instax-like club
  recommendation, the editor spotlight event, and compact club rows before the
  bottom `ExploreEventTypeBrowseGrid`; the personal `Your clubs` rail now
  lives on Home through `DashboardClubsRail`.

### 2.5.147

- Dashboard recommended events now use the production `CatchEventTicketCard`
  activity-art ticket instead of the older compact event rail tile. The ticket
  keeps the recommendation reason in the media label and folds distance, pace,
  booked count, and remaining spots into the bottom mono line.

### 2.5.146

- Explore's floating chrome now owns the top safe-area boundary separately from
  the map canvas. The map remains full-bleed, while the closed draggable sheet
  starts below the header/filter chrome so feed cards cannot scroll behind the
  Dynamic Island or status bar.

### 2.5.145

- Explore club directory cards now formalize the production media contract:
  `Club.imageUrl` is the cover photo, `Club.profileImageUrl` is the circular
  logo crest from the first club profile image, and club ratings render beside
  the title without restoring the old reviews/meta row.

### 2.5.144

- Production Explore club directory cards now adopt the concept-lab club
  spotlight direction. `ClubListTile` dispatches image-backed clubs to a
  photo card and no-image clubs to an identity card that reuses
  `ClubCoverFallback` and the shared `ClubCoverVisualPalette`, keeping the
  no-cover colors and fallback imagery in one iterable schema.

### 2.5.143

- Explore concept lab now includes a compact `This week` mixed-list primitive:
  dense event rows for chronological listings and a club recommendation row for
  non-hero discovery slots, so the lab covers more than spotlight/ticket cards.

### 2.5.142

- Explore's wrist-lift map reveal now uses a distinct momentum animation: a
  quick light-impact drop past the map detent, then a short spring settle back
  to the designed map size. The visible `Map` pill keeps the calmer direct
  ease-out reveal so the experimental physical gesture can be tuned separately.

### 2.5.141

- Explore can now reveal the map through a subtle wrist-lift motion gesture.
  `DeviceMotionSource` wraps `sensors_plus`, `ExploreMapMotionRevealRecognizer`
  keeps the thresholds testable, and `ClubsListScreen` listens only while the
  full/list sheet state is active.

### 2.5.140

- Production Explore now uses the activity-coded event-card direction from the
  concept lab. `EventActivityVisualSpec` centralizes the mutable `ActivityKind`
  palette/backdrop/icon mapping, `CatchEventTicketCard` and
  `CatchEventSpotlightCard` render the production feed and selected-pin cards,
  `EventPhotoHeader` prefers the same activity artwork, and
  `ExploreEventTypeBrowseGrid` adds bottom-of-page activity filtering.

### 2.5.139

- Explore concept club spotlight cards now support two equal-size variants:
  a cover-photo card where the whole card reads as an Instax-like club snapshot,
  and a restrained no-cover identity card that keeps the existing crest,
  member seal, hosted-by row, tags, and CTA without duplicating member count.

### 2.5.138

- Explore concept ticket event-card side cutouts are now shallower, offset bites
  so the transparent notch reads as a ticket edge instead of a circular badge
  pasted onto the rail card.

### 2.5.137

- Explore concept ticket event cards now use a clipped ticket shape for truly
  transparent side notches, extend the media band slightly closer to the
  perforation line, and show the capacity label without tally dots.

### 2.5.136

- Removed the Explore concept timeline/evening-arc widget from the lab. The
  prototype now focuses on event tickets, spotlight/detail treatments, club
  spotlight, map pin treatment, and browse-by-type tiles.

### 2.5.135

- Explore concept browse-by-type tiles now render as compact horizontal cards
  with a small activity color cue instead of large category blocks. The club
  spotlight concept now uses a clean sharp-corner surface without the dotted
  paper background so it reads separately from event tickets.

### 2.5.134

- Explore concept lab now exposes an activity color-system board and shared
  activity-coded backdrop primitive. Ticket event cards, spotlight event cards,
  detail-header mocks, and browse-by-type tiles can reuse the same `ActivityKind`
  gradient, motif, and icon mapping while production Explore data adapters stay
  untouched.

### 2.5.133

- Explore's soft sheet settling now runs from a short controller debounce, not
  only scroll-end notifications, so native sheet drags near the compact bottom
  state reliably settle to the shorter closed height.

### 2.5.132

- Explore's draggable map sheet now uses soft settling zones: releases near the
  shorter bottom extent, map detent, or full/list state animate into those
  anchors, while the middle range remains free-resizable.

### 2.5.131

- Explore map mode is now open-only from the floating action pill: the `Map`
  pill appears in the full/list state, disappears after opening, and users
  close or resize the sheet by dragging the handle instead of tapping a `List`
  pill.
- The Explore sheet no longer snaps on user release. Programmatic open still
  lands on the designed map detent and the bottom state is bounded by a shorter
  min extent, but intermediate drag positions can now rest naturally.

### 2.5.130

- Explore map opening now snaps to a higher map detent just below the quick
  filter strip, uses a slower ease-out open motion, and rounds/fades in the
  draggable sheet edge as the chrome spacer collapses for a lid-opening feel.
- `CatchDraggableSheetShell` now lets callers control handle opacity and top
  corner radius so persistent sheets can animate their edge treatment without
  replacing the shared shell.

### 2.5.129

- Explore map reveal now lets `EventMapView` fill the full viewport, including
  the status-bar/notch area, while the Explore chrome remains safe-area aligned
  over the map and the full/list sheet preserves its safe top spacer.

### 2.5.128

- Explore's list-first state now uses a full-height draggable sheet with a
  chrome-height internal spacer, so no idle map sliver appears below the
  filter rail. Opening the map collapses that spacer while the sheet drops to
  the medium detent.
- `ClubsBrowseHeaderContent`, `ClubsFilterRail`, and `CatchBrowseHeader` now
  accept parent-supplied background colors so Explore can fade the outer chrome
  away while keeping the city, search, and filter controls floating over the
  map.

### 2.5.127

- Explore map browsing now renders app-owned dense-event clusters, a user
  location mark, and a distance filter ring. Tapping the ring cycles the
  distance filter, and the peek rail re-sorts from the latest map camera center.
- Explore's day-grouped feed now uses flat slivers with pinned
  `CatchDaySectionHeaderDelegate` headers in the primary sheet, while the
  compatibility `ExploreEventsSection` wrapper keeps inline headers when nested
  under `SliverMainAxisGroup`.
- The Explore map sheet lead is now `buildExploreMapSheetLeadSlivers`: selected
  pin cards share their photo into event detail, collapsed summaries switch from
  city label to `Map area` after a meaningful pan, and the sheet chrome uses the
  shared `CatchDraggableSheetShell` primitive instead of a feature-local shell.
- Event discovery now avoids eager signed/saved event-detail watches by loading
  missing personal events through the batched `watchEventsByIdsProvider` seam.

### 2.5.126

- Explore discovery now passes the viewer's event-policy cohort into the
  direct event query, allowing the backend index to pre-filter open slots for
  standard cohort-cap and ratio policies before the client resolves saved,
  joined, hosted, invite, membership, and manual-approval state.
- Explore cards and the peek rail now emit non-PII analytics for event opens
  and map/rail event selection so release smoke testing can measure discovery
  engagement instead of only screen views.

### 2.5.125

- Explore event discovery now queries the `events` collection directly through
  backend-owned discovery projection fields instead of resolving city clubs
  before asking for events. Club reads remain in the view model only for card
  metadata, club-directory rows, and club-specific secondary filters.
- Added a dry-run-first event discovery backfill tool so older event docs can
  be repaired before launching the direct index in shared environments.

### 2.5.124

- `ExplorePeekRail` now uses a semantic `InkWell` action for the compact
  "See all" control, with a stable widget key and tooltip. The change clears
  the widget cleanup scanner's only Explore tappable hit while preserving the
  compact peek-state layout.

### 2.5.123

- Added `EventDiscoveryRepository` and `EventDiscoveryQuery` as the Explore
  event data seam. The first implementation is a compatibility adapter over
  club-scoped upcoming event fetches, but the UI/view-model boundary now names
  city-scoped event discovery explicitly so a future backend index can replace
  the adapter without changing Explore cards, map pins, or sheet state.

### 2.5.122

- Explore's production provider seam is now `EventDiscoveryViewModel`, with
  `ExploreFeedViewModel` retained as a compatibility alias for existing clubs
  imports. The model carries event, club, map status, distance, and viewer
  availability instead of treating saved/signed-up/full as a local widget
  shortcut.
- Added `ViewerEventAvailability` as the reusable event availability primitive
  for Explore cards. It combines event policy, current profile, participation,
  saved edge, hosted club state, and club membership so cards can distinguish
  open, saved, joined, waitlisted, invite-required, request-required, full, and
  full-for-viewer states.

### 2.5.121

- Explore quick filters now include real distance windows (`Within 1 km`,
  `Within 3 km`, `Within 5 km`, `Within 10 km`) backed by
  `deviceLocationProvider` and event starting-point coordinates.
- Explore map pin selection now updates parent sheet state: tapping a pin snaps
  to the half-open sheet and promotes the selected event into a full-width hero
  card. The lowest peek snap now stays map-first with only aggregate result
  summary copy instead of a horizontal card rail.
- The event-map placeholder used in tests/offline map mode now lays pins out
  spatially and labels them by meeting point so selected-pin flows can be
  exercised without network map tiles.

### 2.5.120

- Explore now derives the map's `EventMapViewModel` from
  `ExploreFeedViewModel`, so the draggable map, pin empty states, and peek rail
  all reflect the same filtered event set as the feed.
- `EventMapView` accepts an optional parent-supplied
  `AsyncValue<EventMapViewModel>` and falls back to
  `eventMapViewModelProvider` only for standalone map routes. Parent surfaces
  can also supply their own retry callback so refresh ownership stays with the
  provider that produced the view model.

### 2.5.119

- Explore now uses a persistent `EventMapView` behind a snapping
  `DraggableScrollableSheet` instead of swapping between separate list and map
  bodies. The cold-open sheet stays at the full feed snap; the Map and List
  buttons animate between full and half snaps.
- Added a compact peek-state event rail for the lowest Explore sheet snap so
  map-first browsing can show nearby event context without reintroducing the
  legacy static `EventMapSheet` inside the Clubs surface.
- `EventMapView` can now hide its built-in `EventMapSheet` and report selected
  pin events to a parent surface, while the standalone map route keeps the
  legacy sheet enabled.

### 2.5.118

- Explore filters now model time as an explicit `ExploreTimeFilter` instead of
  a single club-era `thisWeekOnly` flag. Tonight, Tomorrow, Weekend, and This
  week chips share one provider state across the event feed and club directory.
- `ClubsFilterRail` has a stable scroll key so widget tests and future UI
  automation can target the horizontal filter rail without positional finders.

### 2.5.117

- The bottom navigation and Clubs browse header now present the branch as
  Explore while preserving `/clubs` routes and existing club detail paths.
- `ExploreFeedViewModel` derives an event-first feed from the selected city's
  clubs, current club filters, signed-up/saved state, and upcoming event
  queries so list mode starts with events before the club directory.
- Added `ExploreEventsSection` above the club directory. It renders a featured
  upcoming event, horizontal event rail, loading skeleton, inline empty state,
  and event-detail navigation through existing event tile/data primitives.

### 2.5.116

- Host Manage participation filters now render as one compact four-item strip
  instead of a two-row nested surface grid; filter labels keep larger count
  text and drop the secondary meta copy.
- Roster search rows no longer carry trailing non-action badges such as
  Roster, Live, or Export.
- The Event Success Live Now console no longer repeats a checked-in progress
  meter when Host Manage already embeds the editable check-in roster below it.

### 2.5.115

- Host Manage Report now exports real CSV files through the shared
  `ExternalShareController` seam instead of disabled placeholder buttons.
- Revenue CSV exports one row per roster/customer record plus summary rows for
  estimated active revenue, no-shows, and cancellations. Amount columns are
  explicitly marked as event-price estimates when only roster-visible
  participation/payment-id data is available.
- Ops CSV is justified as an operational ledger for attendance reconciliation:
  roster status, check-in status, approval state, arrival order, timestamps,
  cohort/gender-at-signup, and payment-id context.

### 2.5.114

- Host Manage keeps the Setup / Live / Report segmented lifecycle control at
  the top of the body and removes the duplicated booked/waitlist/revenue stat
  strip.
- `HostEventParticipantsPanel` now owns the participant counts as compact
  filter tiles for each lifecycle: Setup filters All, Booked,
  Requests-or-Waitlist, and Slots; Live filters All, Due, In, and
  Requests-or-Waitlist; Report filters All, Attended, No-show, and Waitlist.
- Live and Report participation surfaces now use the same dense table shell for
  filtered empty, zero, loading, and error states instead of separate summary
  cards above the roster.

### 2.5.113

- `EventSuccessManualQaScreen` now embeds the canonical
  `HostEventManageScreen` as its host pane with fixture-backed provider
  overrides, so Setup, Live, Report, and participation table changes are tested
  through the same host controls used in production instead of a duplicate QA
  host fixture.

### 2.5.112

- Added `CatchBottomDock`, `CatchIconTile`, `CatchStatusDot`, and
  `CatchPageDots` so bottom action docks, icon badges, tiny status markers, and
  carousel/page indicators use shared primitives instead of local decorated
  shells.
- `CatchSurface` now accepts a custom border radius, allowing shaped surfaces
  such as chat bubbles to keep their silhouette while still inheriting shared
  surface behavior.
- Widget cleanup scanning now covers typography regressions, spacing gaps,
  low-level spacing helper drift, raw app-facing `TextStyle`, and reviewed
  surface exceptions for media, chart, Event Success stage, and animation
  surfaces.

### 2.5.111

- `HostEventParticipantsPanel` now keeps true zero-participant states inside
  the lifecycle-specific board/table surfaces instead of rendering a standalone
  empty block above Host Manage setup content. Loading, event-not-found, and
  data-load errors remain branded outer states because the lifecycle board
  cannot be built until the event context is available.

### 2.5.110

- Catch typography now exposes expressive semantic roles for hero, screen
  headline, form question, card title, section title, body lead, supporting
  copy, kicker/status labels, chat messages, profile answers, and tabular stats.
- Material fallback text, menus, snackbars, buttons, inputs, chips, badges,
  rows, empty states, and profile/event/event-success surfaces now use semantic
  text roles instead of ad hoc `bodyS`, `bodyM`, or `titleS` calls.
- App-facing raw text, raw Material button, raw text input, and nonzero
  letter-spacing typography scanner findings are cleared for this pass.

### 2.5.109

- `HostEventParticipantsPanel` now renders lifecycle-specific participation
  boards instead of a single card-list roster: Setup focuses profile/request
  review, Live focuses dense check-in operations, and Report focuses
  attendance/payment reconciliation with export placeholders.
- `AttendanceSheetViewModel` now exposes the visible participation records by
  user id so roster rows can render timestamps, payment presence, and active
  participation status without presentation widgets reaching around the view
  model.

### 2.5.108

- Clubs browse now owns the list/map mode switch. List mode remains a club
  directory with quick filters, while map mode embeds the reusable event map so
  pins represent upcoming events rather than clubs.
- `EventMapScreen` now delegates its map body to reusable `EventMapView`, and
  event-map cards route to the Clubs event detail route instead of the legacy
  dashboard detail route.
- Dashboard quick actions no longer expose Map view; dashboard keeps Calendar
  and Saved events while spatial discovery lives under Clubs.

### 2.5.107

- Notifications now separate signed-up upcoming events from durable recent
  notification history. `ActivitySection` renders upcoming event tiles first,
  then groups backend-owned notification updates with typed badges and compact
  icon chips.
- The old vertical Activity timeline connector has been removed from the
  Notifications screen; rows now use `CatchSurface` and `CatchBadge` so the
  route matches the current Catch design primitives.

### 2.5.106

- Clubs browse now keeps search reachable even when the selected city has no
  clubs, adds a sliver-native quick-filter rail for upcoming, rating, joined,
  hosted, activity, and neighborhood filters, and clears city-local filters
  when the city changes.
- Club directory cards now surface next-event and review-count context in the
  card body, and the clubs list loading state uses card-shaped skeletons that
  match the loaded directory layout.
- Clubs empty states now distinguish empty city, no-search-result, and
  no-filter-result cases with clearer recovery copy and inline clear actions.

### 2.5.105

- Host Manage Live now embeds the editable roster inside the event-success Live
  now flow. The old standalone live-attendance summary is hidden in that
  context, and the arrival control becomes a QR-only check-in tool so roster
  status, current stage, and next action do not repeat across separate cards.

### 2.5.104

- Event Success now catalogs the optional First Hello arrival ritual. The
  manual QA harness can toggle it from the shared host controls and drive the
  attendee mission through completion without desynchronizing host and attendee
  state.
- Added `_FirstHelloCheckInCard` for the attendee companion's server/manual-QA
  provided arrival mission surface.

### 2.5.101

- Clubs `CityPicker` closed state is now an icon-only circular control. The
  full city name stays in tooltip, semantics, and the selection sheet so long
  city labels cannot push the browse title across the header.
- `CatchBrowseHeader` now morphs the circular search action into the full
  search field from the same right-aligned control. It no longer renders an
  in-app keyboard-hide button; search dismissal uses the field's platform Done
  action, clear button, and focus loss.
- Clubs and Chats search fields both request `TextInputAction.done`, so the
  platform keyboard owns the dismissal affordance while the pinned browse row
  stays visually consistent across tabs.

### 2.5.100

- Chats now reuses `CatchBrowseHeader` in the pinned sliver slot. The header
  owns title/subtitle plus a top-right search action; search expands into the
  full row with the same animated behavior as Clubs.
- Removed the chat-count badge from the Chats header. Conversation counts stay
  in list/body context instead of competing with the primary header action.

### 2.5.99

- Clubs keeps the consolidated browse header in the pinned sliver slot so the
  city picker, title/subtitle, search action, and expanded search field remain
  sticky while the club list scrolls.

### 2.5.98

- Clubs browse now uses a compact city-code picker (`IDR`, `HYD`, etc.) with a
  location icon so short and long city names reserve the same header width.
- `CatchBrowseHeader` search opens with a shared motion transition and uses a
  same-height keyboard-dismiss control instead of a back button beside the
  search field.
- `CatchTextField` now defaults to a platform done action and unfocuses on
  submit/tap-outside so app keyboards have a shared dismissal path.
- `ClubCoverFallback` no longer renders generated initials artwork. No-photo
  club tiles use a quieter map-style fallback with a location mark.

### 2.5.97

- Added `CatchBrowseHeader` as a shared self-contained browse-tab header for
  title, scope picker, search expansion, and actions in one module.
- Clubs now uses the browse header instead of a separate title row plus pinned
  city/search row; search opens into the full header row and city selection uses
  a bottom sheet picker.
- Club directory and avatar tiles now pass explicit no-photo fallback chrome so
  list cards do not repeat location labels already rendered below the cover.

### 2.5.96

- Dashboard host event tools are now self-contained cards: the parent adapter no
  longer renders a Host tools header, event-count badge, Active/Past buckets, or
  explanatory rail text.
- `HostEventToolCard` owns its Host event identity chip, attendance lifecycle
  chip, fixed-width in-card progress rail, and one contextual CTA: Manage event,
  Take attendance, or View report.
- `HostEventToolsPageIndicator` uses a constant-width progress rail plus
  `N of total` text instead of rendering one dot per hosted event.

### 2.5.95

- Host Manage Setup now surfaces the participant roster before event details,
  live-guide setup, and lower-priority admin/destructive actions. Cancel/delete
  copy distinguishes cancelled published events from permanently deleted unused
  events.
- Event-success host loading now waits for the saved plan first and skips
  roster, assignment, preference, wingman, and report streams while no live
  guide exists, so unsaved events render the unavailable guide state instead of
  an indefinite loading indicator.

### 2.5.94

- Widget cleanup status now lives in `docs/audit_registry/backlog.json`; the
  old short Markdown pointer was removed during docs consolidation.

### 2.5.93

- Split event-success host, companion, and live-reveal presentation surfaces
  into focused `part` files for setup, live controls, report, reveal actions,
  attendee cards, wingman requests, feedback, and shared widgets while keeping
  the public import points stable.
- Host setup now uses progressive disclosure for advanced event structure,
  tool, and delivery controls.

### 2.5.92

- Added `EventSuccessManualQaScreen`, a dev/staging side-by-side harness for
  inspecting host and attendee event-success surfaces from shared fixture state.
- Settings Development now links to the event-success manual QA harness.

### 2.5.91

- Host report now includes a signal-quality grid built from already-loaded
  feedback, assignment, opt-out, and wingman-request data.
- `EventSuccessPostEventReport` now renders `Working well` strengths before
  coach recommendations so the report can call out successful event patterns.

### 2.5.90

- Added the attendee compatibility questionnaire surface to event companion,
  using `CatchSurface`, `CatchChip`, `CatchBadge`, and `CatchButton`.
- Host setup now exposes the explicit compatibility-ranking switch; host Live
  mode shows whether questionnaire answers are clues-only or ranking-enabled.

### 2.5.89

- Event-success setup now includes the Live reveal product layer for structured
  formats, with persisted reveal countdown state on the plan.
- Added `EventSuccessLiveRevealHostCard` for host-controlled countdown,
  round-reveal, reset, and reveal-queue status in Live mode.
- Added `EventSuccessLiveRevealAttendeeCard` for companion-side pod/rotation
  reveal gating, countdown clues, and revealed assignment details.

### 2.5.88

- Shared public profile cards now follow the Edit Profile section treatment:
  sentence-case titles, calmer title weight, tighter card padding, and less
  crowded prompt/running text.
- `ProfileInlineTextEntryEditor` now requests focus after the expansion frame
  instead of using immediate `EditableText.autofocus`, preventing first-tap
  keyboard/focus flicker while the row opens.
- Edit Profile row icons stay on the muted field-icon color even when the row
  is an add affordance; only the add value text uses primary color.

### 2.5.88

- Club detail now supports multi-host presentation and owner host-team
  management. `ClubDetailBody` renders every `ClubHostProfile`, exposes
  host-message actions for signed-in non-host viewers, and shows owner-only
  add/remove/transfer controls backed by `ClubHostManagementController`.
- Club create/edit now separates event-success defaults into
  `ClubEventSuccessDefaultsStep`, making the club wizard four steps for owners
  while co-host edit mode narrows to media updates only.
- Added `FormStepSpec` helpers in `form_step_flow.dart` so create-club and
  create-event flows share step title/key lookup instead of hand-written
  switch statements.

### 2.5.87

- Added `CatchSectionCard` as the shared polished content-section wrapper:
  sentence-case title, optional subtitle/trailing context, `CatchSurface`
  border, and tokenized spacing.
- Edit Profile now renders Profile strength, Photos, Profile prompts, About,
  Location, Background, Intentions, Lifestyle, and Running details as coherent
  section cards instead of external uppercase labels plus grouped rows.
- `SectionHeader` now defaults to sentence-case label styling. Explicit
  uppercase remains available for badges, status labels, and intentional
  metadata/eyebrow treatments.

### 2.5.86

- Club create/edit now includes a host-defaults step for event policy and
  event-success defaults. `ClubHostDefaultsStep` owns admission, cohort caps,
  cancellation, and dynamic-pricing controls; event-success defaults now live on
  the dedicated `ClubEventSuccessDefaultsStep`.
- Create event applies club host defaults to the policy step and lets hosts
  override them per event before publishing. Optional event-success setup is
  saved when enabled.
- Edit hosted event now supports pre-activity policy edits for capacity, price,
  admission format, invite code, cohort/age limits, dynamic pricing, and
  cancellation policy. These controls become read-only once the event has
  started or has booking, waitlist, or attendance activity.

### 2.5.85

- Host Manage now uses `HostEventParticipantsPanel` as the single participant
  surface across Setup, Live, and Report. Setup shows booked/waitlisted people
  read-only, Live owns check-in mutation, and Report shows the attendance
  summary. Event-success Live remains unavailable until setup has been saved, so
  unsaved default plans cannot trigger Firestore live-step writes.

### 2.5.84

- `CatchSegmentedControl` now supports expanded icon+label segments and a
  raised-surface selected style. Host Manage uses it for the Setup / Live /
  Report lifecycle switcher instead of separate chips.

### 2.5.83

- Host Manage now uses one lifecycle picker with Setup, Live, and Report sections.
  Setup combines the prior event overview/admin surface with event-success setup,
  Live combines host attendance with event-success live mode, and Report opens
  the post-event host report directly. The nested event-success tab picker is
  hidden inside Host Manage.

### 2.5.82

- Host Manage moved fully into the `hosts` feature at
  `lib/hosts/presentation/host_event_manage_screen.dart`; the canonical route is
  now `/clubs/:clubId/events/:eventId/manage`, with the old dashboard-shaped
  path kept as an alias.
- Added `EditHostedEventScreen` at `/clubs/:clubId/events/:eventId/edit` for
  backend-supported operational edits. Schedule edits lock once an event has
  started or has booking, waitlist, or attendance activity.
- Removed the standalone `AttendanceSheetScreen`, `EventSuccessHostScreen`,
  `HostClubToolsPanel`, and `HostStatsStrip` wrappers. Screens now import the
  host widgets they use directly.
- Host attendance-window state now lives in
  `lib/hosts/domain/host_attendance_window.dart`, and Dashboard host tools split
  active and past hosted events into a segmented Host operations rail.

### 2.5.81

- `HostEventManageScreen` is now the canonical per-event host workspace with
  lifecycle sections: Setup, Live, and Report. The old event-success and
  attendance route paths remain as aliases that open Host Manage with the
  relevant lifecycle section selected.
- Club detail now renders a single `HostClubManagementPanel` that combines
  Add event, Edit club, and upcoming booked/waitlist/revenue stats. The old
  `HostStatsBar` compatibility wrapper was removed.
- `CreateEventScreen` no longer embeds Host Manage after the celebration; its
  Manage event action routes to the canonical Host Manage route.
- Event-success lab/preview/companion surfaces share reusable prompt, dark-pill,
  metric-pill, and recommendation-tile widgets from
  `event_success_feature_blocks.dart`.

### 2.5.80

- Event detail no longer renders a host-only sticky bottom footer. Host
  operations stay on Dashboard and Host Manage so the detail page does not have
  two competing host-tool sections.
- Dashboard host tools now retain non-cancelled past hosted events after
  attendance closes, with open attendance first, upcoming events next, and
  recently closed past events last.

### 2.5.79

- Shared host tooling now lives under the feature-owned
  `lib/hosts/presentation/widgets` folder instead of the standalone
  `lib/host_tools/presentation` utility module. Existing host surfaces import
  the widgets directly from that feature folder.

### 2.5.79

- Create event now separates `Event policy` from `Live event guide`.
  Capacity, admission, price, age, cancellation, and payout controls stay on
  policy; event-success defaults move to their own final step before scheduling.

### 2.5.78

- Event detail now includes a `What to expect` section ahead of booking,
  cancellation, and settlement policy details. It is derived from the already
  loaded event snapshot, so the listing/detail policy copy does not add another
  Firestore read.
- Live event-success host setup now exposes target attendance, host goal,
  attendee prompt, module selection, private follow-up, contextual openers, and
  a start-time freeze notice on the production host success screen.
- The attendee companion private follow-up action now feeds the post-event
  feedback/report aggregate while private-crush target identities remain
  attendee-private.

### 2.5.77

- Home run-state actions are consolidated into `RunFocusRail`. The old
  dashboard-only `UpcomingRunsHero`, `RunArrivalActionCard`, `CatchesCallout`,
  and `ReviewPromptCard` widgets have been deleted; committed-run state now
  flows through one full-width snapping rail with check-in, directions,
  calendar, catch-window, and review actions.
- Profile photo editing is now grouped-photo first. `PhotoGrid` renders
  `ProfilePhoto` objects, supports guarded delete and long-press reorder, and
  routes add/replace/edit work through `ProfilePhotoEditorScreen`.
- Host event management now includes guarded Cancel event and Delete event actions
  on `HostEventManageScreen`; unused events can be deleted, while events with visible
  activity are cancelled and retain history.

### 2.5.76

- `CreateEventScreen` now uses an `Event policy` step for capacity, base price,
  admission format, age bounds, cohort caps, cancellation policy, and host
  payout timing. The old event details step now stays focused on distance, pace,
  photo, and description.
- `EventDetailCta` prices the current viewer through the event policy
  snapshot, and `EventDetailOverviewSection` shows booking, cancellation, and
  settlement policy details.

### 2.5.75

- `EventPolicyLabScreen` now previews cancellation outcomes alongside
  admission and pricing. The lab shows bounded attendee cancellation policies,
  host-cancellation make-complete behavior, and host payout timing held until
  event completion.

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

- Host tooling now has shared primitives under `lib/hosts/presentation/widgets`:
  `HostEventToolsCarousel`, `HostEventToolCard`, `HostClubManagementPanel`,
  `HostEventAttendancePanel`, `HostStatChip`, and `HostToolPalette`.
- Dashboard host tools use full-width snapping cards with stacked Manage /
  Attendance actions instead of a clipped horizontal partial-card rail.
- Club host tools and attendance headers share the host palette, and hosted
  club schedule rows use the `HOSTED` event-tile state.

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

- Event card architecture now uses a surface-specific event tile catalog under
  `lib/events/presentation/widgets/event_tiles/`: `EventTileData`,
  `EventAgendaTile`, `EventRailTile`, `EventHeroTile`, and `EventMapTile`.
- Calendar, Saved events, Dashboard recommendations/upcoming hero, club
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

- `EventPinsMap` accepts a selected event camera target from map-browse screens.
  Tapping a nearby-event tile now animates the map to that event's exact starting
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

- Dashboard host actions are consolidated into `HostToolsRail`: each hosted event
  gets one horizontally scrollable card with both Manage and Attendance actions.
  Attendance is enabled only inside the host attendance window, while Manage
  stays available for actionable hosted events.
- `DashboardFullViewModel` now exposes `DashboardHostEventTool` items instead of
  a raw hosted-event manage list, so attendance-open events can sort ahead of
  later upcoming hosted events without rendering a separate arrival card.

### 2.5.61

- Hosts can reopen `HostEventManageScreen` from the Dashboard through
  `HostToolsRail`; active and past hosted events remain reachable instead of
  relying on the post-create success screen.
- Host manage summary rows reserve a right-aligned value lane, and roster /
  waitlist empty states use compact title/icon styling instead of oversized
  display empty states.

### 2.5.60

- Event detail descriptions render under an explicit "About this event" heading, so
  backend description text cannot look like stray body copy.
- `EventDetailSocialSection` unlocks review writing only after an attended event has
  ended, and it does not render the reviews divider for guest-only social
  prompts.
- `WhoIsGoing` uses a neutral empty roster surface and suppresses swipe-window
  messaging when no one has booked the event.

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
  backfills are still catching up. Demo seed data must write
  `profilePhotos.thumbnailUrl` so tiny social-proof avatars do not depend on
  full-size images in normal dev fixtures.

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

- `StepperFooter` blends into the create-event page background instead of using
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
  `publicProfiles`, and prefers `profilePhotos.thumbnailUrl` so tiny hype
  avatars do not load full profile photos once profile thumbnail backfill is
  complete.
- Chat and match celebration avatars should use non-obscured `PersonAvatar`
  with `PublicProfile.primaryPhotoThumbnailUrl`.

### 2.5.47

- `EventPinsMap` is the shared event-pin map canvas for both the browse map and
  single-run location map. Keep map centering outside the pin widget through
  `resolveEventMapInitialCenter`: device location wins until the user manually
  selects a city; selected city is the no-permission/manual-override fallback.
- Event pins must not choose the browse-map camera center.
- `EventMapViewModel` filters to upcoming, non-cancelled events before rendering
  the browse map. Events without exact coordinates may remain in the sheet, but
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

- Event detail location rows are map affordances only when the event has both
  `startingPointLat` and `startingPointLng`. `WhenWhereCard` owns the
  conditional chevron/tappable row, while `EventDetailBody` owns navigation to
  the neutral `/events/:eventId/location` route-backed
  `EventLocationMapRouteScreen`; do not show chevrons for address-only events.

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

- Create/Edit Club now uses the shared step-flow form pattern instead of a
  single long form. `CreateClubScreen` owns a four-step owner wizard
  (`Club basics`, `Club details`, `Host defaults`, and
  `Event success defaults`), reuses
  `CatchStepFlowHeader`/`StepperFooter`, and keeps finite form pages fully
  mounted so validation covers offscreen fields.
- Added local create-club draft support through `ClubDraft`,
  `ClubDraftRepository`, and `CreateClubDraftController`. Drafts are
  create-only, user-scoped, local to the device, and deleted after successful
  club creation.
- Club creation affordances now derive from `canCreateClubProvider`.
  The UI hides plus/create controls after the signed-in user already hosts a
  club; the `createClub` callable enforces the invariant with the
  server-owned `clubHostClaims/{uid}` lock.
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

- Reviews are now explicitly split by write contract. Club detail uses a
  read-only review summary below the upcoming events schedule and shows only
  the latest three reviews. Event detail is the page-level review surface that
  can open `WriteReviewSheet` for attended participants.
- Dashboard now derives a post-event review prompt from attended events and the
  current user's existing reviews, then opens the existing event-scoped review
  sheet. The review prompt is a normal dashboard card, not a second mutation
  path.
- Added `ReviewsHistoryScreen` under `/you/reviews`, reachable from the Profile
  overflow menu, so users can see and edit their previous event reviews.

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

- Activity timeline now also receives backend-owned `eventUpdated` and
  `eventCancelled` items. `updateEvent` creates schedule/location change
  notifications for signed-up and waitlisted participants; `cancelEvent` creates
  cancellation notifications. Event cancellation host UI and policy remain queued
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

- Event participation roster/count reads are migrated off compatibility arrays.
  `EventParticipationRoster` centralizes edge-derived booked, checked-in, and
  waitlisted ID lists; `WhoIsGoing` and `HostEventManageScreen` use it for exact
  rosters. List/stat surfaces use `Event` count projections instead of hidden
  participant arrays.

### 2.5.19

- Catches/swipes participation reads now use `eventParticipations` for
  candidate generation, exhausted-queue empty-state attendance copy, and event
  recap attendee/checked-in state. `EventRecapViewModel` owns the recap data
  seam.

### 2.5.18

- Host attendance now uses `AttendanceSheetViewModel` to combine the event
  stream with `eventParticipations` and derive roster/check-in state from
  participation statuses instead of legacy event participant arrays.

### 2.5.17

- Event detail now treats `EventParticipation` as the source of truth for the
  current viewer's booking, waitlist, attendance, CTA, and review eligibility
  state. `EventDetailViewModel` watches `eventParticipations/{eventId_uid}`,
  `EventDetailBody` passes that edge to detail sections, and `EventDetailCta`
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
- Event detail bottom CTAs keep booking lifecycle actions only; arrival actions
  have moved to Home.

### 2.3.0

- Calendar is now a single sliver-native scroll surface. Its header and agenda
  scroll together instead of using a fixed header plus nested agenda scroll.
- `EventAgendaList` / `EventAgendaSliverList` now support `preserveInputOrder` for
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

- Keep a single source of truth for active cleanup status in
  `docs/audit_registry/backlog.json`.
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
  `docs/README.md`, `docs/audit_registry/backlog.json`, this catalog, or another
  existing source-of-truth doc over creating a new markdown file. If a temporary
  audit/report produces durable guidance, migrate that guidance into the owning
  doc and delete the stale report.
- Ask questions only when the answer cannot be inferred safely from the repo or
  when a product/design decision would materially affect the implementation.

### How To Proceed

1. Start every pass by reading this section and
   `docs/audit_registry/backlog.json`.
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
   event tile variants, `SettingsRow`, `CatchSkeleton`, `CatchBadge`,
   `StatusChip`, `CatchFormFieldLabel`, `ChipField`, `EventAgendaList`,
   `EventAgendaSliverList`, `MutationErrorSnackbarListener`, and
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
   `UpdateRequiredController`, `CreateClubController`, and app-shell
   provider seams.
18. Keep status out of this catalog. Pending, completed, next-up, and scanner
   snapshots belong in `docs/audit_registry/backlog.json`; this file should
   describe reusable instructions, anti-patterns, widget inventory, and durable
   consolidation guidance.
19. After each meaningful batch, update `docs/audit_registry/backlog.json` with
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
- Direct Material `Icons.*` imports in feature widgets or widget tests. Route
  icon choices through `CatchIcons.*`; transitional Material-compatible aliases
  are centralized in `lib/core/theme/catch_icons.dart` while semantic names
  remain the preferred API for new surfaces.
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
not carry the active backlog; use `docs/audit_registry/backlog.json` for
pending, completed, next-up, scanner snapshots, and findings. Keep this file current
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
| `AppShell` | `lib/core/presentation/app_shell.dart:34` | Main tab shell with adaptive bottom navigation (Home, Explore, Catches, Chats, Profile): Material `NavigationBar` on Android/non-iOS platforms and `CupertinoTabBar` on iOS. Watches provider-backed connectivity for the offline app notice, initializes FCM through `appShellFcmInitializationProvider`, exposes active-tab state through `AppShellActiveTab`, and keeps Crashlytics/Analytics user IDs synced with auth state. Shell-level streams stay limited to shell-wide UI such as auth, connectivity, FCM, and unread badges. |

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
| `CreateEventRouteScreen` | `lib/routing/go_router.dart:447` | Route wrapper that fetches a `Club` by ID and delegates to `CreateEventScreen`. Shows a loading screen or error text while the club resolves. |
| `EditClubRouteScreen` | `lib/routing/go_router.dart:475` | Route wrapper that fetches a `Club` by ID and delegates to `CreateClubScreen` for editing. Same loading/error pattern. |

---

## Core — Design System Widgets

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchTextField` | `lib/core/widgets/catch_text_field.dart:12` | Canonical text input. Wraps `FormField<String>` + `TextField` in `CatchControlShell` with label, helper/error copy, prefix/suffix icons, clear button, initial-value syncing, default keyboard done/dismiss behavior, tap-outside unfocus, and theming via `CatchTextFieldSize`, `CatchTextFieldShape`, and `CatchTextFieldTone` enums. `floating` is for map/hero overlay chrome, `compact` for dense search/filter rows, and `md` for regular forms. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, `danger`, and `light` variants; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; optional leading icons; and `isInteractive: false` for button-looking labels inside an already tappable parent. Use `light` for solid-white pill CTAs so foreground/background colors stay paired across light and dark themes. |
| `CatchSelectMenu<T>` | `lib/core/widgets/catch_select_menu.dart:9` | Token-driven menu-anchor select primitive. Supports compact/md heights, rounded or pill triggers, optional prefix icons, disabled/error states, and a separately rounded popup panel so pill triggers do not clip opened menu rows. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown for `Labelled` enum-like values. Wraps `FormField<T>` + `DropdownButton<T>` with focus-ring styling and label decoration. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchDetailHeroBackdrop` | `lib/core/widgets/catch_detail_hero_backdrop.dart:4` | Shared photo-or-branded-fallback backdrop for detail-page heroes. Used by club and event detail headers so no-photo states share the same dark branded gradient and scrim treatment. |
| `CatchMetricStrip` | `lib/core/widgets/catch_metric_strip.dart:17` | Shared detail-page metric rail for compact value-over-label stats. Owns the white surface, border, spacing, dividers, mono value styling, optional unit styling, and label truncation so club and event detail stats cannot drift. |
| `CatchTextButton` | `lib/core/widgets/catch_text_button.dart:6` | Canonical text-only action primitive for inline actions, dialog actions, retry links, and top-bar text actions. Uses Catch tokens and text styles while preserving Material `TextButton` semantics. Use `CatchButton` for pill CTAs. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:10` | Canonical OTP input primitive. Renders visible token-styled digit boxes over one hidden platform `TextField` so SMS autofill, paste, keyboard input, tests, digit-only filtering, and length limiting stay centralized. |
| `CatchNumberStepper` | `lib/core/widgets/catch_number_stepper.dart:6` | Canonical numeric +/- stepper. Renders the shared raised `CatchControlShell`, compact add/remove buttons, centered mono value, optional min/max/step clamping, and feature-specific value formatting. Used by event duration and profile height controls. |
| `CatchRangeSlider` | `lib/core/widgets/catch_range_slider.dart:7` | Canonical range slider. Wraps `RangeSlider` in the shared tickless slider theme so age/pace sliders keep discrete values without rendering dashed tick marks. Supports optional min/max endpoint labels for fixed slider bounds. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:11` | Canonical top-bar. Renders a surface-fill bar with an optional back button (auto-detected from `Navigator.canPop`), title, leading widget, and action slots. Also supports a `bottom` `PreferredSizeWidget` (e.g., `TabBar`). Implements `PreferredSizeWidget` for use as an `AppBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:133` | Adaptive top-tab primitive for use inside `CatchTopBar.bottom` or sticky sliver headers. Uses Material `TabBar` with primary indicator on Android/non-iOS platforms and `CupertinoSlidingSegmentedControl` on iOS. Implements `PreferredSizeWidget` and accepts an optional explicit `TabController` for sliver-native tab rows that are not inside a `DefaultTabController`. |
| `showCatchAdaptiveDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:18` | Shared platform-adaptive confirmation/dialog helper. Renders `CupertinoAlertDialog` on iOS and Material `AlertDialog` elsewhere, with typed action values plus default/destructive action metadata. |
| `showCatchDatePicker` / `showCatchTimePicker` | `lib/core/widgets/catch_adaptive_picker.dart:7` | Shared platform-adaptive date/time picker helpers. iOS renders bottom-wheel `CupertinoDatePicker` sheets with Cancel/Done toolbar; Android/non-iOS platforms keep Flutter's Material calendar and clock pickers. |
| `CatchSliverHeader` | `lib/core/widgets/catch_top_bar.dart:290` | Shared sliver header primitive. Builds a scroll-away title and optional pinned bottom row; the title translates upward as it collapses so sticky search/filter/tab rows do not visually cover it. Use `twoLineTitleHeight` for short title/subtitle headers, `wrappedTitleHeight` only when long titles need the extra space, and the shared search-row spacing constants before adding feature-local search/list gap math. Used by Run Clubs, Chats, and Profile. |
| `CatchBrowseHeader` | `lib/core/widgets/catch_browse_header.dart:9` | Self-contained browse-tab header for a scope picker, title/subtitle, right-aligned search action that morphs into the full search field, optional actions, and an optional parent-supplied background color in one composable module. Use for Clubs/Chats-style tabs that should not split scope/search chrome into separate rail headers. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:156` | Overflow menu action for `CatchTopBar`. Renders a `PopupMenuButton<T>` wrapped in an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`; accepts an optional explicit size for overlay rows that must align with floating controls without changing the default app-bar button size. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Delegates to `CatchTextButton` so top-bar text actions share the same token-driven text-action primitive as dialogs and inline retry links. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:48` | Pill-style segmented control. Supports compact or full-width expanded layouts, icon-only, label-only, or icon+label segments, and filled or raised-surface selected styles. Used for lifecycle/workspace switching where tapping a segment changes the content below. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchSectionCard` | `lib/core/widgets/catch_section_card.dart:9` | Shared polished section-card primitive. Wraps a body in `CatchSurface` with a sentence-case title, optional subtitle, optional trailing context, tokenized padding, and the same restrained hierarchy used by profile-strength guidance. |
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
| `CatchControlShell` | `lib/core/widgets/catch_control_shell.dart:50` | Shared single-line control shell for fields, select triggers, picker tiles, map pin tiles, and steppers. Owns the fill, border, focus ring, radius, and size metrics. Use `floating` for overlay chrome, `compact` for dense header/search controls, and `md` for regular form controls. |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Tag/chip widget. Supports active/inactive states, an optional remove button, and Catch-themed coloring. Used in `ChipField` and independently for vibe tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Small label badge used for spots-left indicators, distance/pace pills, etc. Supports `solid`, `neutral`, and `outline` tones. |
| `IconBtn` | `lib/core/widgets/icon_btn.dart:22` | Circular 40x40 icon button used as the base for `CatchTopBar*Action` widgets. Renders `Material` + `InkWell` with a center-aligned child. |
| `BottomCTA` | `lib/core/widgets/bottom_cta.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content and bottom safe-area padding. |
| `CatchBottomSheetScaffold` | `lib/core/widgets/catch_bottom_sheet.dart:7` | Shared bottom-sheet shell with grabber, optional title/subtitle, keyboard-safe padding, content, and an optional action slot. |
| `CatchDraggableSheetShell` | `lib/core/widgets/catch_draggable_sheet_shell.dart:6` | Shared shell for persistent `DraggableScrollableSheet` surfaces. Owns the rounded top edge, border, optional raised shadow, and grabber slot while leaving snap state and scroll content to feature screens. Callers can tune handle opacity and top radius for sheet reveal animations without forking the shell. |
| `CatchCelebrationScreen` | `lib/core/celebration/catch_celebration_screen.dart:37` | Shared full-screen celebration surface for high-emotion completion moments. Feature screens provide moment kind, copy, details, optional supplemental children, and primary/secondary actions; the primitive dispatches celebration effects once after first frame. Solid-white primary actions use `CatchButtonVariant.light` instead of per-screen white/foreground overrides. |
| `CelebrationEffectsController` | `lib/core/celebration/celebration_effects_controller.dart:10` | Central haptic/sound boundary for celebration moments. Currently dispatches haptics by `CelebrationMomentKind`; future sound work should be added here instead of directly in feature widgets. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Shared empty-state primitive with icon, title, message, optional action, surface/plain presentation modes, and stacked or compact inline layouts. Expands to bounded parent widths before centering content so plain empty states remain centered inside start-aligned feature sections. |
| `CatchDaySectionHeader` | `lib/core/widgets/catch_day_section_header.dart:11` | Sticky day-section header for chronological feeds. Use `CatchDaySectionHeaderDelegate` when the parent owns a flat `CustomScrollView` and pinned day headers are needed; the delegate binds the child height to its sliver extent so pinned geometry stays valid under constrained sheets. |
| `CatchEventCardHero` | `lib/core/widgets/catch_event_card_hero.dart:21` | Hero-sized event card primitive for feed leads and selected map cards. Owns photo/fallback, scrim, event copy, meta row, optional sash/price labels, and an optional photo Hero tag for card-to-detail transitions. |
| `CatchEventTicketCard` | `lib/core/widgets/catch_event_activity_cards.dart:17` | Ticket-style production event card backed by `EventActivityVisualSpec`. Used by Explore day-grouped event rows so each event type shares the same activity-coded backdrop, stamp, dynamic clock mark, status pill, and capacity copy. |
| `CatchEventSpotlightCard` | `lib/core/widgets/catch_event_activity_cards.dart:133` | Large activity-art production event card for featured Explore items and selected map pins. Reuses `EventActivityBackdrop`, supports an optional visual Hero tag for card-to-detail transitions, and keeps non-open states in the kicker slot. |
| `CatchEventThumbnail` | `lib/core/widgets/catch_event_thumbnail.dart:10` | Shared event image primitive. Renders uploaded photos by default, falls back to `EventActivityBackdrop`, and supports `preferActivityArtwork` for surfaces such as event detail headers and peek cards that should stay color-coded by event type even when a photo exists. |
| `EventActivityVisualSpec` / `EventActivityBackdrop` | `lib/events/presentation/event_activity_visuals.dart:17` | Mutable presentation schema for `ActivityKind` imagery. Centralizes activity label, icon, gradient palette, pattern, and browse-order choices so Explore cards, spotlight cards, thumbnails, browse tiles, and event detail headers do not fork color decisions. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, keeps the parent-owned `selected` set, supports disabled state for pending mutation sheets, and shows a leading check icon on selected chips only in multi-select mode. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Simple row with a label and value, used in detail/read-only views. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
| `showCatchErrorSnackBar` | `lib/core/widgets/catch_error_snackbar.dart:4` | Snackbar helper for transient action failures. Maps errors through `appErrorMessage` before display. |
| `CatchNoticeHost` | `lib/core/widgets/catch_notice.dart:84` | App-wide overlay host for ambient notices. Renders persistent notices such as offline state below the safe area and queues ephemeral event notices through `appNoticeControllerProvider`. |
| `CatchNotice` | `lib/core/widgets/catch_notice.dart:184` | Reusable floating notice primitive with tone, icon, optional message, optional action, and optional dismiss control. Use for ambient app status/events, not inline form errors. |
| `SectionHeader` | `lib/core/widgets/section_header.dart:4` | Lightweight section header with sentence-case styling by default, optional heavy weight, and opt-in uppercase for intentional metadata/eyebrow labels. Prefer `CatchSectionCard` for carded content sections. |
| `StatusChip` | `lib/core/widgets/status_chip.dart:14` | Colored chip displaying event status (open, booked, full, cancelled, attending, waitlisted, not-going, attended, missed). |
| `StatColumn` | `lib/core/widgets/stat_column.dart:5` | Vertical stat display: value on top, label below. Used by profile and host surfaces that need local surface ownership; detail-page rails should use `CatchMetricStrip`. |
| `AppFormLayout` | `lib/core/widgets/app_form_layout.dart:3` | Form layout wrapper with consistent padding and spacing for form screens. |
| `BottomSheetGrabber` | `lib/core/widgets/bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets and draggable sheet shells. Supports caller-owned width/height while keeping tokenized color and radius. |
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
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:21` | Home tab. Watches the user's profile, active club memberships, signed-up events, and Home unread notification count only while Home is active. Renders one `CustomScrollView` with a scroll-away greeting/empty header, top-right Notifications bell, red unread badge, and dashboard sliver body; it no longer owns a route-local tab controller or Dashboard/Activity tab row. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:21` | Standalone full-dashboard wrapper used by focused tests/non-tab embedding. Takes explicit `followedClubIds` from the membership-edge seam and renders the full dashboard header plus `DashboardFullSliverBody`. The header avatar is a Profile-tab button and must use thumbnail-scale profile imagery through `UserProfile.primaryPhotoThumbnailUrl`. |
| `DashboardFullSliverBody` | `lib/dashboard/presentation/widgets/dashboard_full.dart:86` | Sliver body for the populated Home dashboard: consolidated attendee `EventFocusRail`, consolidated host tools carousel, `StrideCard`, `QuickActions`, the personal `DashboardClubsRail`, and recommended events. It joins club names for committed events through `clubNameLookupProvider`; notifications are intentionally routed to the dedicated Notifications screen. |
| `HostToolsRail` | `lib/dashboard/presentation/widgets/dashboard_full.dart:170` | Dashboard adapter for shared `HostEventToolsCarousel`. Converts `DashboardHostEventTool` availability into host-tool items and owns route navigation for Manage, Attendance, and Report without adding header/count/bucket chrome around the card. |
| `EventFocusRail` | `lib/dashboard/presentation/widgets/event_focus_rail.dart:28` | Consolidated Home rail for attendee committed-event actions. Builds full-width snapping event cards for upcoming, check-in, catch-window, and review states; stacks actions such as View event, Check in, Directions, Add to calendar, Start catching, and Write review so labels do not clip on narrow screens. |
| `DashboardClubsRail` | `lib/dashboard/presentation/widgets/dashboard_clubs_rail.dart:10` | Home-owned personal club rail. Resolves followed club IDs through `watchClubProvider`, reuses `ClubAvatarRail` without create/directory chrome, and stays hidden when no club data is available so Explore can keep club recommendations discovery-oriented instead of user-owned. |
| `ActivityScreen` | `lib/dashboard/presentation/activity_screen.dart:18` | Route-level Notifications screen opened from the Home header bell. Uses `CatchTopBar(title: 'Notifications')`, keeps the bottom nav visible by living under the Home shell branch, renders `ActivitySection`, and automatically delegates unread notification docs to `ActivityController.markAllRead` when the screen opens. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:43` | Reusable notifications body. Separates signed-up upcoming events from backend-owned recent updates, renders event rows as `CatchSurface` tiles, groups notification history by recency, and uses typed `CatchBadge`/icon-chip treatments for match, club, booking, reminder, update, waitlist, and cancellation items. Uses a branded inline error state with retry and can either show a manual `Mark all read` action or hide it when a route owns automatic read state. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Intrinsic-height horizontal rail of `RecommendCard` widgets for recommended events from the user's followed clubs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:8` | Dashboard recommended-event adapter around `CatchEventTicketCard`. It uses the shared activity-art ticket shape, keeps the recommender reason in the media label, and preserves price, title, club, date/time, meeting point, distance/pace, booked count, and remaining spots. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Responsive dashboard quick-action grid for Calendar and Saved events. Spatial discovery lives under Clubs, so the dashboard no longer exposes Map view. Avoids hardcoded tile heights so labels can wrap without clipping on narrow screens. |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Standalone empty-dashboard wrapper used by focused tests/non-tab embedding. Renders the empty dashboard header plus `DashboardEmptySliverBody`. |
| `DashboardEmptySliverBody` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:60` | Sliver body for the empty Home dashboard. Keeps the existing "book your first run" education flow, can show the personal `DashboardClubsRail`, and avoids embedding activity updates. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Hero card variant shown on the empty dashboard prompting the user to book their first event. Its solid-white CTA uses `CatchButtonVariant.light` so the pill stays legible in dark mode. |
| `DashedAvatar` | `lib/dashboard/presentation/widgets/dashed_avatar.dart:7` | Dashed-border circular avatar placeholder used in empty-state layouts. |
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
| `_UpcomingEventTile` | `lib/dashboard/presentation/widgets/activity_section.dart:193` | Signed-up upcoming event row for Notifications. Shows date, meeting point, time range, distance, pace, and event-detail navigation without mixing the row into notification history. |
| `_EventDatePill` | `lib/dashboard/presentation/widgets/activity_section.dart:256` | Compact date marker used only inside upcoming-event tiles. |
| `_NotificationTile` | `lib/dashboard/presentation/widgets/activity_section.dart:293` | Single recent-update row for backend-owned activity notifications. Uses `CatchSurface`, typed badges, relative time, unread styling, and optional route navigation. |
| `_NotificationIconChip` | `lib/dashboard/presentation/widgets/activity_section.dart:385` | Compact icon container for notification types. It is decorative row chrome, not a standalone surface primitive. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:638` | Status label shown for the loading activity state. |

---

## Host Tools

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `HostEventToolsCarousel` | `lib/hosts/presentation/widgets/host_event_tools.dart:22` | Shared full-width host-event carousel for unbounded hosted events, including closed past hosted events retained for host operations. It renders self-contained cards with swipe snapping and no external section header, event-count badge, or footer chrome. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `HostEventToolsPageIndicator` | `lib/hosts/presentation/widgets/host_event_tools.dart:162` | In-card hosted-event position indicator. Shows `N of total` plus a bounded progress rail so unbounded hosted-event counts do not grow the rendered indicator. |
| `HostEventToolCard` | `lib/hosts/presentation/widgets/host_event_tools.dart:217` | Shared operational card for one hosted event. Shows Host event and attendance lifecycle chips, bounded in-card progress, date/time, meet point, booked/waitlist counts, and one contextual CTA using the host palette. |
| `HostToolPalette` | `lib/hosts/presentation/widgets/host_event_tools.dart:431` | Token-backed host-tool color helper for default host panels and attendance states. Use this instead of local orange-tinted containers for host chrome. |
| `HostClubManagementPanel` | `lib/hosts/presentation/widgets/host_club_tools.dart:15` | Club-detail host management panel that combines Add event, Edit club, and upcoming booked/waitlist/base-revenue stats into one host section. |
| `HostStatChip` | `lib/hosts/presentation/widgets/host_club_tools.dart:161` | Single reusable host stat chip used by the consolidated club host management panel and host event management stats. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `HostEventAttendancePanel` | `lib/hosts/presentation/widgets/host_event_attendance_panel.dart:31` | Shared host attendance panel. Watches `AttendanceSheetViewModel`, renders loading/error/event-not-found outer states, and delegates zero-participant, filtered-empty, profile-backed roster rows, and attendance toggle mutations to the lifecycle-specific Host Manage board/table surfaces. Lifecycle participation counts are compact filter tiles, not a separate stat strip, so Setup, Live, and Report each expose the statuses hosts need without repeating top-level metrics. Report mode exports Revenue and Ops CSV files through shared external sharing; revenue uses roster-visible payment ids plus event-price estimates until a backend host payment-report callable exposes actual settled/refunded amounts. |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:22` | Catches decision screen. Watches the swipe queue provider, renders the first candidate as a full `ProfileSurface`, submits section likes/comments through `SwipeQueueNotifier.swipe`, and exposes a floating lower-left pass X instead of deck gestures. Empty-state attendance copy uses the viewer's `EventParticipation` edge instead of compatibility arrays, and stuck queue loads now surface a retryable `Catches unavailable` error instead of spinning forever. |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:19` | Swipe filters screen. Owns local age and interested-in draft state, uses `CatchRangeSlider` for the 18-60+ age range, saves through `FiltersController.saveFiltersMutation`, and pops on successful save. Pace range and run type are intentionally not exposed as filters. |
| `EventRecapScreen` | `lib/swipes/presentation/event_recap_screen.dart:27` | Post-event recap screen showing event details and a checked-in attendee vibe grid. Watches `EventRecapViewModel`, uses keyed vibe tiles, `CatchSurface` for the recap hero, and `CatchEmptyState` for an empty attendee roster. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:21` | "Catches" tab. Gates screen-owned streams while the retained tab branch is inactive, lists edge-backed attended events with open catch windows, uses leaf widgets to read theme tokens locally, shows a `CatchSurface` intro card with projected checked-in count for the featured event, and lists active events with `AttendedEventTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:19` | Full-length scrollable profile body used inside `ProfileSurface`. Keeps the shared rendering path identical across Catches, Profile Preview, and Public Profile, renders the hero photo first, then contextual profile insights, profile prompts, one canonical `RUN PROFILE` running identity card, detail chips, inset photos, and lifestyle. Its internal vertical scroll view is non-primary, can accept an explicit controller and route-provided physics when embedded in a sliver route, and can report leading overscroll to a parent route for collapsible-header coordination. |
| `ProfileSurface` | `lib/swipes/presentation/profile_surface.dart:8` | Shared cardless public profile renderer. Wraps `ScrollableProfile`, passes optional viewer/event context for compatibility insights, and mode-gates reaction controls so Catches can show section like/comment affordances while Preview/Public Profile remain passive. |
| `EventRecapViewModel` | `lib/swipes/presentation/event_recap_view_model.dart:11` | Recap data seam. Combines the event, current uid, and `eventParticipations` to derive checked-in count and the attendee IDs shown in the vibe grid without reading compatibility arrays. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:236` | Keyed attendee tile on the recap screen. Fetches its public profile, exposes tooltip/semantic selected state, and toggles local recap selection. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub: header, intro card for the featured event, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the event" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. The parent `CatchSurface` owns tap handling; the solid-white CTA is a non-interactive `CatchButtonVariant.light` display label so accessibility and color pairing stay correct. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book an event. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo section inside the shared `ProfileSurface`. The hero photo may be edge-to-edge with the dark gradient and name overlay; additional photos should be inset with consistent margins, rounded corners, and spacing. Shows a branded "Photo coming soon" fallback when the user has no usable image. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Hero overlay for public display name, age, and optional city. Keep relationship goal, distance, and runner metadata out of the hero and in lower profile sections. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:61` | Legacy/specialized goal chip styling retained for profile-card contexts that need a pill, but the default shared card now renders relationship goal as a detail chip rather than hero overlay text. |
| `ProfileCardPalette` | `lib/swipes/presentation/widgets/profile_card_style.dart:4` | Local palette helper for the shared public profile surface. It adapts accent, border, chip, fallback, and shadow colors to the active app light/dark theme while keeping sections coherent across Catches, Preview, and Public Profile. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:6` | Section of detail chips on the shared profile surface. Relationship goal lives here; city stays on the hero overlay, and distance appears here only when current/profile locations are available. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:8` | Reusable section card wrapper for profile detail sections. Uses `ProfileCardPalette` rather than raw app surface colors, sentence-case `labelL` headers, and compact tokenized padding so sections stay coherent inside the shared public profile surface. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:6` | Prompt section on the shared surface. Uses the prompt text as a sentence-case section label and restrained title typography for answers so long prompt copy stays readable before running stats. |
| `ProfileMatchSignalsSection` | `lib/swipes/presentation/widgets/profile_match_signals_section.dart:9` | Contextual signals section near the top of the shared profile surface. Shows profile confidence pills and viewer-aware "Why you might click" reasons, and exposes the section as one reactionable `compatibility` target. |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single compact info chip on the profile surface — muted icon + label. |
| `CatchesPassButton` | `lib/swipes/presentation/widgets/catches_pass_button.dart:5` | Floating lower-left pass button used on the Catches decision screen after removing generic deck action buttons. Uses the shared pass key, tooltip, and semantic label. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedEventTile` | `lib/swipes/presentation/widgets/attended_event_tile.dart:14` | Row tile for an attended event in the catches hub list: event title, date, projected checked-in count, recap CTA, and swipe badge. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Canonical dark `RUN PROFILE` summary card inside `ScrollableProfile`. Retain this as the single first-class running identity section; it should use `ProfileCardPalette` in light and dark app themes and own the high-signal pace/distance summary. |
| `_RunStatPill` | `lib/swipes/presentation/widgets/scrollable_profile.dart:137` | Small stat pill inside the running identity card. |
| `_RecapHero` | `lib/swipes/presentation/event_recap_screen.dart:144` | `CatchSurface` hero section of the event recap screen: event name, activity metadata, checked-in count, and catch-window status. |
| `_RecapStat` | `lib/swipes/presentation/event_recap_screen.dart:200` | Single stat counter on the recap screen (for example, "12 Likes", "4 Matches"). |
| `_ProfilePhoto` | `lib/swipes/presentation/event_recap_screen.dart:295` | Single profile photo in the recap attendee grid. |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Empty state when the recap roster has no one. |
| `_FilterSection` | `lib/swipes/presentation/filters_screen.dart:264` | Collapsible section in the filters screen (header + expandable body). |
| `_FilterValue` | `lib/swipes/presentation/filters_screen.dart:296` | Single selectable filter value tile. |

---

## Matches / Chats

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:11` | "Chats" tab. Gates screen-owned streams while the retained tab branch is inactive, then renders the pinned composable chats browse header (title/subtitle, expandable search action) plus the chat conversations body. |
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:13` | Sliver body for chat conversations fed from `ChatsListViewModel`. Uses a padded skeleton loading sliver, empty/error states, and delegates populated data to `ChatsListBody`. |
| `MatchCelebrationDialog` | `lib/matches/presentation/widgets/match_celebration_dialog.dart:41` | Compatibility-named full-screen match celebration route. Uses `CatchCelebrationScreen` with match haptics, then routes the primary action into `ChatScreen` or dismisses back to swiping. |
| `ChatListTile` | `lib/matches/presentation/chat_list_tile.dart:9` | Single conversation row in the inbox. Receives a `ChatThreadPreview`, renders one full-width `CatchSurface` row with `PersonAvatar`, latest preview text, timestamp, and row-level unread treatment: warm tint, primary border/accent, avatar ring, stronger text, and a visible 0/1 unread-chat pill near the timestamp. Routes to `ChatScreen`. |
| `ChatNewMatchesRail` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:10` | Horizontal rail of no-message `ChatThreadPreview` matches at the top of the chats list. |
| `_NewMatchAvatar` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:31` | Single new-match avatar in the rail — circular photo with name. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Search text field for filtering chats list. Supports autofocus and a platform Done action so `ChatsSliverHeader` can expand search into the full browse-header row without rendering a separate keyboard-dismiss button. |
| `ChatConversationsList` | `lib/matches/presentation/widgets/chat_conversations_list.dart:8` | Headerless `SliverList` of conversation previews, driven by `ChatsListViewModel`, with stable spacing between full-width chat surfaces. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations. |
| `ChatsListBody` | `lib/matches/presentation/widgets/chats_list_body.dart:7` | Body wrapper for the chats list. Shows new-match rail and headerless conversation rows without a second "Messages" title. |
| `ChatsSliverHeader` | `lib/matches/presentation/widgets/chats_sliver_header.dart:10` | Chats-specific wrapper around `CatchBrowseHeader`. It is rendered in the pinned sliver slot, owns temporary search-open state, wires the search action, and keeps query state in `chatSearchQueryProvider`. |
| `_ChatsBrowseHeader` | `lib/matches/presentation/widgets/chats_sliver_header.dart:20` | Stateful chats browse-header adapter that removes the old count badge, animates search expansion, and clears `chatSearchQueryProvider` when search closes. |

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
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:19` | Standalone profile tab content. Wraps the shared profile sections in a `ListView` for isolated/non-sliver usage and renders Profile strength, Photos, Profile prompts, About, Location, Background, Intentions, Lifestyle, and Running details as `CatchSectionCard`-style sentence-case sections. Profile-quality guidance is backed by the public-profile insight scorer. Uses `profileTabBodyPadding` for the shared Profile tab inset. `Display name` is the first editable About field and is the only public-facing profile name; onboarding identity fields such as date of birth and gender are readonly, and last name is not shown publicly. Optional/profile-detail fields, including Instagram, remain editable. Running details owns pace, distances, reasons, and favorite run times. Discovery-only preferences such as interested-in genders and match age range live in Filters, not Edit Profile. Optional single-choice edit sheets open unselected when the underlying field is empty. |
| `ProfileTabSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:48` | Sliver-native profile tab body. Reuses the same profile sections as `ProfileTab` but contributes a padded `SliverList` for parent `CustomScrollView` usage. Uses the same `profileTabBodyPadding` as Preview. |
### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared `ProfileSurface`, with owner-provided scroll controller, physics, bottom padding, and leading-overscroll callback when mounted inside ProfileScreen. |
| `ProfileInfoSection` | `lib/user_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows. Titled grouped sections render through `CatchSectionCard` with optional subtitle context, while untitled grouped sections keep the compact legacy card shell for embedded callers. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:6` | Single profile info row with compact muted icon, label, value or in-row value editor, and animated expanded chevron. Row-owned edits expand inline rather than opening a field sheet; values use restrained tokenized row typography and add affordance value text uses primary color. |
| `_ProfileUnavailableBody` | `lib/user_profile/presentation/profile_screen.dart:103` | Missing-profile state. Prevents the profile route from rendering a blank body when the signed-in user profile is unavailable. |
| `_PreviewTabSliverBody` | `lib/user_profile/presentation/profile_screen.dart:120` | Sliver-native preview body. Gives the shared `ProfileSurface` bounded remaining viewport height inside the profile route's preview tab scroll view, passes a dedicated profile scroll controller, applies `profileTabBodyPadding` inside the filled child, and bridges upward scroll plus leading overscroll to the outer Profile header. |
| `_ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:25` | Scroll-away Profile title row with one Settings action. Account actions live inside Settings, not in a second header overflow menu. |
| `_ProfileTabBar` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:55` | Pinned Edit/Preview tab bar surface for the sliver-native profile route. The route-level `SafeArea` keeps it below device cutouts without adding an expanded-header gap. |
| `_SettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:82` | Settings gear button in the scroll-away profile title header. |
| `ProfileInlineEditableText` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:105` | Row-value editable text primitive built on `EditableText`. Preserves the closed row value style/position, supports multiline row-owned editing for Bio, and signals focus with cursor, selection, and a text-width underline instead of a boxed field. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileInlineTextEntryEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:221` | Row-owned text editor that turns `ProfileInfoTile` values into `ProfileInlineEditableText`, including multiline Bio editing in the row value slot, delayed post-expansion focus, and validation plus trailing `Cancel`/`Done` actions in the shared inline panel. |
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

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfilePhotoEditorScreen` | `lib/image_uploads/presentation/profile_photo_editor_screen.dart:14` | Add/edit profile-photo flow opened by onboarding and Edit Profile. It picks or replaces the image, shows a crop preview, lets the user choose an optional catalog photo prompt, supports guarded deletion, and saves through `PhotoUploadController.savePhoto` so grouped `profilePhotos` stay synchronized. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotoGrid` | `lib/image_uploads/presentation/photo_grid.dart:10` | Dense 3x2 profile photo grid over normalized `ProfilePhoto` objects. Uses `maximumProfilePhotoCount`, keyed slots, guarded delete callbacks, and long-press drag targets for reorder; callers own opening `ProfilePhotoEditorScreen` and enforcing the completed-profile minimum. |
| `PhotoSlot` | `lib/image_uploads/presentation/widgets/photo_slot.dart:6` | Single keyed photo slot. Renders through `CatchSurface`, exposes semantic labels/tooltips for add/edit/delete/uploading/unavailable states, displays selected photo prompts where present, shows reorder target affordance, and blocks taps while inactive or loading. |

---

## Run Clubs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateClubScreen` | `lib/clubs/presentation/create/create_club_screen.dart:18` | Create/edit club form. Uses shared `FormStepSpec` metadata with `CatchStepFlowHeader`, `StepperFooter`, create-only local drafts, cover/profile photo picking, host defaults, a dedicated event-success defaults step, and submit mutation feedback. Owner edit keeps the full wizard; co-host edit narrows to media-only updates. |
| `ClubBasicsStep` | `lib/clubs/presentation/create/widgets/club_basics_step.dart:11` | First club form step. Keeps cover/profile media, club name, city, and area fields in one fully mounted scroll body so validation sees all required fields. In co-host media edit mode, non-media fields render disabled. |
| `ClubDetailsStep` | `lib/clubs/presentation/create/widgets/club_details_step.dart:7` | Second club form step. Holds required description plus optional contact fields. |
| `ClubHostDefaultsStep` | `lib/clubs/presentation/create/widgets/club_host_defaults_step.dart:12` | Third club form step. Configures club-level host defaults for admission, cohort caps, dynamic pricing, age range, and cancellation policy inherited by new events. |
| `ClubEventSuccessDefaultsStep` | `lib/clubs/presentation/create/widgets/club_event_success_defaults_step.dart:6` | Fourth club form step. Wraps `EventSuccessDefaultsPanel` for the club's primary activity so event-success run-of-show defaults are edited separately from booking policy defaults. |
| `CityPicker` | `lib/clubs/presentation/list/widgets/city_picker.dart:12` | Compact city scope picker for the clubs browse header. The closed trigger is a fixed-size circular `CatchControlShell` with a location icon only, while the full city label stays in tooltip/semantics and the token-styled bottom sheet. It updates `selectedClubCityProvider`, clears club search on city changes through the provider seam, listens for GPS/profile auto-selection, and keeps the selected city while the remote city list is loading or unavailable. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubDetailScreen` | `lib/clubs/presentation/detail/club_detail_screen.dart:16` | Club detail screen. Fetches the club, current user profile, active membership edge, upcoming events, and reviews; join/leave mutations stay in `ClubMembershipController`. Renders `ClubDetailBody`. |
| `ClubsList` | `lib/clubs/presentation/list/widgets/clubs_list.dart:14` | Sliver state-dispatch widget for the Explore tab's club directory state. Renders directory-card skeletons, error, city-empty, search-empty, filter-empty, and data slivers from `ClubsListViewModel`, which partitions joined/discover clubs from active membership edges, and owns join-mutation feedback. |
| `ClubsSearchField` | `lib/clubs/presentation/list/widgets/clubs_search_field.dart:6` | Search text field for filtering Explore events and clubs. Supports autofocus and a platform Done action so `ClubsSliverHeader` can expand search into the full browse-header row without rendering a separate keyboard-dismiss button. |
| `ClubsFilterRail` | `lib/clubs/presentation/list/widgets/clubs_filter_rail.dart:8` | Horizontal quick-filter rail for Explore browse. Uses `CatchChip` for explicit time windows (Tonight, Tomorrow, Weekend, This week, Anytime), compact distance filters (1/3/5/10 km), Joined, and contextual Clear actions backed by `clubBrowseFiltersProvider`. Event-first feed and club directory both read this filter state where their data supports it, the rail exposes a stable scroll key for tests/automation, and Explore can supply a transparent background while the controls float over the map. |
| `MembershipButton` | `lib/clubs/presentation/detail/widgets/membership_button.dart:7` | Join/Leave/Request membership button on the club detail screen. Calls `ClubMembershipController`. |
| `MutationErrorSnackbarListener` | `lib/core/widgets/mutation_error_snackbar_listener.dart:13` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used for transient mutation errors such as join/leave club failures. |
| `_DirectoryCard` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart:3` | Directory-style club card router for Explore. Chooses the concept-lab-inspired photo card when cover/profile imagery exists and the no-cover identity card otherwise, while preserving host-before-joined role precedence and keeping only discoverable clubs eligible for the `Join` CTA. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubsListScreen` | `lib/clubs/presentation/list/clubs_list_screen.dart:31` | Explore tab route. Owns the persistent sheet-over-map browse surface: `EventMapView` stays mounted behind a draggable sheet and receives its map view model from the same filtered event discovery feed used by the list. The map can fill the full viewport, but the full/list state paints an opaque top lid over the status-bar/notch area and header/filter chrome while the sheet begins below that chrome, so the closed page does not show map content in the safe area. The `Map` pill appears only in this full/list state; after opening, users close or resize by dragging the handle. Programmatic map open lands on a higher detent just under the filter strip, fades the top lid/header/filter backgrounds transparent, and keeps the city/search/filter controls floating over the map while the sheet edge rounds and selected map pins promote into a full-width event hero card. User drags use soft settling zones: releases near the shorter bottom extent, map detent, or full/list state animate into those anchors, while the middle range can rest naturally. The peek state renders only aggregate result summary copy. Selecting a map pin stores the selected event id and snaps to the map selected-card state. The screen also listens for map camera-center changes so nearby event ordering can remain spatial, and a distance-ring tap cycles the active distance filter. |
| `ClubsListBody` | `lib/clubs/presentation/list/widgets/clubs_list_body.dart:10` | Sliver-native data body for the Explore tab. Production `ClubsListScreen` disables the old personal rail and directory stack, then composes the mixed `ExploreEventsSection` with the bottom-of-page `ExploreEventTypeBrowseGrid` without embedding a vertical `ListView` inside the parent `CustomScrollView`. Legacy callers can still opt into the joined-club rail or club directory through explicit flags. |
| `ExploreEventsSection` | `lib/clubs/presentation/list/widgets/explore_events_section.dart:101` | Mixed Explore discovery section. Watches the event discovery feed, accepts candidate clubs from `ClubsListBody`, interleaves compact activity-coded event rows, an Instax-like club spotlight, the editor-pick event spotlight, and compact club rows, then routes event taps to `Routes.eventDetailScreen` and club taps to `Routes.clubDetailScreen`. Skeleton/error/empty states still belong to the event discovery feed, with club-only fallback content allowed when events are empty. |
| `ExploreEventTypeBrowseGrid` | `lib/clubs/presentation/list/widgets/explore_event_type_browse_grid.dart:13` | Bottom-of-page Browse by event type surface. Reads the current Explore feed and `clubBrowseFiltersProvider`, renders `primaryBrowseActivityKinds` with the shared activity palette and visible-feed counts, and toggles `activityTag` filters from each tile. |
| `ExplorePeekRail` | `lib/clubs/presentation/list/widgets/explore_peek_rail.dart:13` | Lead sliver builder for the Explore map sheet. `buildExploreMapSheetLeadSlivers` renders aggregate count/scope copy in collapsed mode, a full-width `CatchEventSpotlightCard` with a shared activity-art Hero in selected-pin mode, and the compact nearby rail with spatial reordering plus a semantic "See all" action in unselected half/full mode. |
| `ExploreConceptPreviewScreen` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_preview_screen.dart:14` | Dev-only static lab for the next Explore visual direction. It renders presentation-only concept data through isolated ticket event cards, the mixed This week list, spotlight event and club cards, an activity color-system board, detail header treatment, map pin treatment, and browse-by-type grid without reading live events, clubs, memberships, or booking state. |
| `ExploreConceptActivityThemeBoard` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_theme_board.dart:10` | Dev-only board for inspecting the proposed `ActivityKind` visual taxonomy. Shows the shared gradient, motif, icon, and swatches that ticket cards, spotlight cards, detail headers, and browse tiles reuse. |
| `ExploreConceptActivityBackdrop` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_visuals.dart:7` | Concept-lab compatibility alias for the production `EventActivityBackdrop` schema. The lab still owns presentation experiments, but activity color decisions now flow from `lib/events/presentation/event_activity_visuals.dart` so production and prototypes iterate from one palette. |
| `ExploreConceptEventTicketCard` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart:17` | Prototype ticket-style event card for horizontal rails. Uses concept-only event data, the shared `ActivityKind` visual backdrop, stamp/status treatment, dynamic clock mark, a clipped ticket shape with transparent side notches, perforated divider, and plain capacity label while staying separate from production `EventDiscoveryItem` rendering. |
| `ExploreConceptEventSpotlightCard` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart:127` | Prototype large spotlight event card for an editor-pick/picked-for-you position. Reuses the activity-coded visual backdrop from the ticket cards and is intended for visual iteration before deciding how real ranking/curation should adapt into the production Explore feed. |
| `ExploreConceptThisWeekList` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart:456` | Prototype compact mixed listing for the Explore concept lab. Renders chronological event rows with date capsule, activity stamp, dynamic clock mark, capacity progress, and activity accent rail, plus club recommendation rows with a larger club stamp and follow CTA for concise discovery slots. |
| `ExploreConceptEventDetailHeaderMock` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart:798` | Static detail-header mock that applies the same activity-coded gradient and motif to the event detail top surface. It exists only to inspect cross-surface color continuity before touching production event-detail routes. |
| `ExploreConceptClubSpotlightCard` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart:257` | Prototype club spotlight card with equal-size cover and no-cover variants. Clubs with cover photos render as a single Instax-like club snapshot card with member count on the image and club identity in the caption band; no-cover clubs keep the restrained crest/member-seal identity card, hosted-by row, tags, and compact CTA without duplicating member count. |
| `ExploreConceptCategoryGrid` | `lib/clubs/presentation/list/widgets/explore_concept/explore_concept_category_grid.dart:12` | Prototype browse-by-event-type grid. Uses concept category data and `ActivityKind` color themes in compact horizontal cards with a softened color cue, keeping the browse section visually lighter than the spotlight and ticket event surfaces. |
| `ClubDiscoverList` | `lib/clubs/presentation/list/widgets/club_discover_list.dart:8` | Club directory section of Explore with a real `SliverList` of directory cards. Passes joined and hosted club IDs separately so host-owned clubs are not mislabeled as ordinary joined clubs. |
| `ClubListTile` | `lib/clubs/presentation/list/widgets/club_list_tile.dart:33` | Club tile rendered as directory card or avatar chip. Directory cards now use the productionized concept-lab club language: image-backed clubs get a bounded photo card with member seal, serif title, tags, host row, and role sash; no-image clubs get an identity card that reuses the shared fallback palette. Display-only tile rendering does not watch provider state; only the join button owns the mutation provider. |
| `ClubsEmptyState` | `lib/clubs/presentation/list/widgets/clubs_empty_state.dart:4` | Empty state for empty-city, search-empty, filter-empty, and combined search/filter-empty cases. Uses `CatchEmptyState` with recovery copy and optional clear actions owned by `ClubsList`. |
| `ClubAvatarRail` | `lib/clubs/presentation/list/widgets/club_avatar_rail.dart:12` | Horizontal rail of the user's joined clubs plus an optional create-club tile. Uses larger rounded image chips so no-photo fallback marks and live badges remain legible, and exposes padding/divider controls so Home can reuse the rail without Explore-specific chrome. |
| `_CreateClubButton` | `lib/clubs/presentation/list/widgets/club_avatar_rail.dart:36` | Rounded-square create tile at the end of the avatar rail to create a new club. |
| `ClubsBrowseHeaderContent` | `lib/clubs/presentation/list/widgets/clubs_sliver_header.dart:23` | Explore-specific wrapper around `CatchBrowseHeader`. It can render in the pinned sliver slot or inside Explore's floating chrome layer, owns temporary search-open state, wires city picker/search/create actions, accepts an optional background color, and keeps query state in `clubSearchQueryProvider` for event and club search. |
| `ClubHeroAppBar` | `lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:16` | Club detail identity hero with cover-photo support, shared branded fallback, name, area/city, back, and share. Rating and host-only ownership cues stay out of the hero, and no-photo headers use a shorter height. |
| `ClubDetailBody` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:21` | Scrollable club detail body: host tools when applicable, stats, the public multi-host strip, owner-only host-team management, about copy, host/member controls, upcoming events list, then read-only club review aggregate. Host rows show owner/host badges, profile affordances, and signed-in viewer message buttons backed by the host-inquiry conversation flow. |
| `ClubScheduleSection` | `lib/clubs/presentation/detail/widgets/club_schedule_section.dart:9` | Sliver-native agenda section for a club's upcoming events. Reuses `EventAgendaSliverList`, shows the compact inline empty state when no events exist, routes selected events to detail, and marks host-owned schedules with the `HOSTED` event-tile status. |
| `_ClubContactSection` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:148` | Contact info section: Instagram, website, WhatsApp, email rows. |
| `_ContactRow` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:201` | Single contact row: icon, label, and value. |
| `StatsStrip` | `lib/clubs/presentation/detail/widgets/stats_strip.dart:6` | Club detail stats wrapper. Adapts club metrics into the shared `CatchMetricStrip` so club and event detail metric rails use the same surface treatment. |
| `ClubCoverFallback` | `lib/clubs/presentation/shared/club_cover_fallback.dart:11` | Map-style branded fallback shown when a club has no cover photo. It avoids generated initials, uses a quiet location mark, and lets callers independently hide the location chip and footer label so detail heroes, directory cards, and avatar rails avoid repeating metadata already shown nearby. `ClubCoverVisualPalette` exposes the deterministic fallback palette for production cards that need matching no-cover accents. |
| `_CoverChip` | `lib/clubs/presentation/shared/club_cover_fallback.dart:98` | Small distance/location chip overlaid on the cover fallback. |
| `CreateClubCoverPicker` | `lib/clubs/presentation/create/widgets/create_club_cover_picker.dart:9` | Cover photo picker for the create/edit club form. |
| `CreateClubContactFields` | `lib/clubs/presentation/create/widgets/create_club_contact_fields.dart:6` | Contact fields (Instagram, WhatsApp, website, email) for the create/edit form. |
| `_DirectoryPhotoCard` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart:43` | Image-backed Explore club directory card. Uses real club imagery through `_ClubImage`, adds a compact member seal/rating badge, keeps the serif identity band below the media, and renders tags plus hosted-by/action affordances without moving join mutation state into display-only card code. |
| `_DirectoryIdentityCard` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart:109` | No-cover Explore club directory card. Uses a circular `ClubCoverFallback` crest and the same deterministic palette as the fallback art, then renders metadata, tags, hosted-by context, and the role-aware action row without generated initials. |
| `_ClubPhotoMedia` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart:239` | Bounded responsive media block for image-backed directory cards. Preserves a 16:9 feel on normal phone widths while capping wide layouts so the list tile does not overflow in tablet/test surfaces. |
| `_ClubImage` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/club_image.dart:3` | Club cover image for list tiles. Selects cover/profile image order by variant and passes explicit fallback chrome flags for directory cards versus avatar rail chips. |
| `_HostAvatar` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/directory_card.dart:721` | Host avatar shown on directory cards, with configurable radius for the newer hosted-by row density. |
| `_AvatarChip` | `lib/clubs/presentation/list/widgets/club_list_tile_parts/avatar_chip.dart:3` | Joined-club rail tile with a rounded image/fallback chip, optional live badge, and truncated club name. |

---

## Events

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventScreen` | `lib/events/presentation/create_event_screen.dart:34` | Multi-step event creation flow for details, location, schedule, event policy, and event-success defaults. Uses shared `FormStepSpec` metadata, seeds policy and event-success defaults from `club.hostDefaults`, supports per-event overrides, manages draft save/restore and local form controllers, and saves optional event-success setup after event creation when enabled. On success renders `CreateEventSuccessScreen`; Manage event routes to canonical Host Manage rather than embedding management in the create flow. |
| `EditHostedEventScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:107` | Host-only published-event edit form for backend-supported operational fields: schedule when unlocked, meeting point, pinned starting point, extra directions, distance, pace, description, capacity, price, admission format, invite code, cohort/age limits, dynamic pricing, and cancellation policy. Schedule and booking-policy edits lock once the event has started or has booking, waitlist, or attendance activity. |
| `EventMapScreen` | `lib/events/presentation/event_map_screen.dart:18` | Compatibility route wrapper for the reusable event map body. It provides the standalone scaffold and floating back controls while delegating map content to `EventMapView`. |
| `EventMapView` | `lib/events/presentation/event_map_screen.dart:37` | Reusable full-screen event map body. Uses a parent-supplied `AsyncValue<EventMapViewModel>` and retry callback when provided, otherwise watches and invalidates `eventMapViewModelProvider` for standalone routes. It centers on device location unless the selected club city was manually overridden or location is unavailable, owns selected-event state, and composes `EventPinsMap`, map empty states, optional overlay controls, and optionally `EventMapSheet`. Standalone map routes keep the built-in sheet enabled; Explore mounts it sheetless behind its own draggable browse surface, supplies the filtered Explore event set, listens for selected pin events, receives camera-center callbacks, and can expose a tappable distance ring. |
| `HostEventManageScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:108` | Canonical per-event host workspace. Keeps the Setup / Live / Report segmented lifecycle control directly under the app bar title and lets the participation panel own roster counts as filter tiles instead of repeating booked, waitlist, and revenue stat cards. Setup leads with participants before event details, event-success setup, and lower-priority admin/destructive actions; Live embeds the editable roster inside the event-success Live now flow so check-in status, current stage, QR check-in, and next-step navigation read as one operational surface; Report leads with the filtered event-report table before the post-event host report. Private-link sharing now uses shared event-invite copy rather than terse admin text. |
| `LocationPickerScreen` | `lib/events/presentation/location_picker_screen.dart:17` | Chromeless map-based location picker. Lets hosts tap or search for a location and returns the selected `LocationCoordinate`; keeps confirm/search controls floating above the map. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EditHostedEventRouteScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:44` | Route-facing edit entry. Loads the host-owned club and event, rejects non-host viewers, and delegates to `EditHostedEventScreen` with optional route-provided event data. |
| `HostEventManageRouteScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:43` | Route-facing host manage entry used from the canonical `/clubs/:clubId/events/:eventId/manage` route plus dashboard, attendance, and event-success aliases. Loads the event and club by id, gates access to the club host, and delegates the loaded state plus optional lifecycle section to `HostEventManageScreen`. |
| `EventDetailScreen` | `lib/events/presentation/event_detail_screen.dart:17` | Route-facing event detail entry. Fetches `EventDetailViewModel`, renders scaffolded loading/error/not-found states, and delegates the loaded screen to `EventDetailBody` without nesting scaffolds. |
| `EventLocationMapRouteScreen` | `lib/events/presentation/event_location_map_screen.dart:20` | Route-facing single-event map entry. Reuses `EventDetailViewModel` by `eventId`, renders chromeless load/error/not-found states with floating back controls, and delegates mapped events to `EventLocationMapScreen`. |
| `EventDetailBody` | `lib/events/presentation/widgets/event_detail_body.dart:33` | Scrollable event detail body. Composes the title-bearing hero app bar, overview, saved/share/calendar actions, optional saved-plan companion entry, booked-attendee invite card, social section, and a non-host bottom CTA. Passes the viewer's `EventParticipation` edge to detail sections so current-viewer state is not inferred from aggregate counts. |
| `EventDetailHeroAppBar` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:10` | Event detail hero app bar. Uses the shared event photo header, keeps title/date/time in the hero, and owns floating back/share/save/calendar actions while the visual header stays activity-coded by event type. |
| `EventPhotoHeader` | `lib/events/presentation/widgets/event_photo_header.dart:5` | Visual-only event hero wrapper. Delegates rendering to `CatchEventThumbnail(preferActivityArtwork: true)` and exposes the stable event-photo Hero tag used by selected Explore map cards; it intentionally does not duplicate event title, location, stats, or activity copy. |
| `EventStatsGrid` | `lib/events/presentation/widgets/event_stats_grid.dart:7` | Event detail stats adapter. Converts event facts into `CatchMetricStrip` items so event stats share the same white rail, dividers, value styling, and responsive truncation as club detail stats. |
| `EventDetailCta` | `lib/events/presentation/widgets/event_detail_cta.dart:22` | Bottom CTA bar for non-host event detail viewers. Owns booking, cancellation, waitlist, eligibility, attended/past, free-booking celebration, and paid booking handoff states from the current viewer's `EventParticipation` edge. |
| `AttendanceSheetViewModel` | `lib/events/presentation/attendance_sheet_view_model.dart:10` | Attendance data seam. Combines the event stream with `eventParticipations` and derives attendee IDs plus checked-in state from participation statuses. |
| `WhoIsGoing` | `lib/events/presentation/widgets/who_is_going.dart:36` | Event detail social roster. Watches `EventParticipationRoster` for booked counts and renders shared blurred `EventHypeAvatarStack` thumbnails using `PublicProfile.primaryPhotoThumbnailUrl`. |
| `EventPinsMap` | `lib/events/presentation/widgets/event_pins_map.dart:10` | Shared Flutter map canvas for event pins. Used by `EventMapScreen`, Explore, and `EventLocationMapScreen`; renders only events with exact coordinates and keeps map centering outside the pin widget. It reports camera-center changes on idle, draws optional user-location and distance-ring circles, clusters dense low-zoom pins with app-rendered count markers, and expands clusters by zooming in. Its no-network placeholder lays markers out spatially and exposes meeting-point selection labels so widget tests can exercise selected-pin flows without network map tiles. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventSuccessScreen` | `lib/events/presentation/create_event_success_screen.dart:9` | Host event-created success screen backed by `CatchCelebrationScreen`. Shows event confirmation details, explicit discoverable-but-invite-gated copy for invite-only events, and Manage event / Back to club actions. |
| `EventJoinedCelebrationScreen` | `lib/events/presentation/event_joined_celebration_screen.dart:8` | User event-signup celebration surface shared by free bookings and post-payment confirmation. Shows event details, optional payment details, haptics, and View event / Back home actions. |
| `EventCheckInCelebrationScreen` | `lib/events/presentation/event_check_in_celebration_screen.dart:7` | Participant self-check-in celebration surface. Used only after user self-check-in from Home succeeds; host attendance remains an operational flow. |
| `EventCheckInLocationService` | `lib/events/presentation/event_check_in_location_service.dart:16` | Provider-backed location seam for self-check-in. Production uses Geolocator with high accuracy and a timeout; tests can inject coordinates without invoking platform plugins. |
| `EventLocationMapScreen` | `lib/events/presentation/event_location_map_screen.dart:63` | Chromeless full-screen single-event map with one pinned exact starting point, floating back controls, and a bottom location summary. Reuses `EventPinsMap`; use only when `Event.hasExactStartingPoint` is true. |
| `CreateEventStepHeader` | `lib/events/presentation/widgets/create_event_step_header.dart:4` | Header for the create-event wizard: back action, step title, club name, step count, and progress bar. |
| `CreateEventFormKeys` | `lib/events/presentation/create_event_form_keys.dart:3` | Stable semantic keys for create-event form fields so widget tests target fields by purpose rather than layout order. |
| `SavedEventsScreen` | `lib/events/presentation/saved_events_screen.dart:15` | Saved-events route. Streams the current user's saved event details, orders future saved events before past saved events, joins club names, and opens saved-event detail routes from shared agenda tiles. |
| `EventTileData` | `lib/events/presentation/widgets/event_tiles/event_tile_data.dart:10` | Shared display model for event tile variants. Wraps an `Event` plus relationship status, optional club name, recommendation reason, and carousel position label. |
| `EventAgendaTile` | `lib/events/presentation/widgets/event_tiles/event_agenda_tile.dart:7` | Agenda/list tile for Calendar, Saved events, and club schedules. It is content-sized, can show global club context, and displays time, meeting point, status, activity metadata, price, and spots. |
| `EventRailTile` | `lib/events/presentation/widgets/event_tiles/event_rail_tile.dart:8` | Horizontal discovery/recommendation tile for dashboard rails. Shows status, activity metadata, price, title, club, date/time, meeting point, signup count, and optional recommendation reason. |
| `EventHeroTile` | `lib/events/presentation/widgets/event_tiles/event_hero_tile.dart:8` | Dashboard hero tile for booked upcoming events. Shows next-event countdown, optional carousel position, title, club, time/location/activity metadata, and `EventHypeAvatarStack` social proof. |
| `EventMapTile` | `lib/events/presentation/widgets/event_tiles/event_map_tile.dart:8` | Map bottom-sheet tile for mixed nearby events. Shows relationship status, no-pin state, club, time, location, activity metadata, price, and signup count; tap selects/recenters the map while the sheet button opens detail. |
| `EventAgendaList` | `lib/events/presentation/widgets/event_agenda_list.dart:9` | Box-facing agenda list for events grouped by day. Sorts by start time by default, with `preserveInputOrder` for callers that precompute semantic order plus optional club-name/status builders. |
| `EventDetailOverviewSection` | `lib/events/presentation/widgets/event_detail_overview_section.dart:10` | Static event facts section for the loaded event detail body below the title-bearing hero: shared stats rail, white when/where and policy surfaces, "What to expect", cancellation/settlement copy, description, and requirements. |
| `EventDetailSocialSection` | `lib/events/presentation/widgets/event_detail_social_section.dart:10` | Social context section for the loaded event detail body: roster, guest lock prompt, divider, and event-scoped reviews for signed-in users. Review writing requires an attended `EventParticipation` and an event end time that has passed. |
| `MapOverlayControls` | `lib/events/presentation/widgets/map_overlay_controls.dart:5` | Floating safe-area controls for chromeless map surfaces. Provides rounded back affordance plus optional trailing/below content for map actions such as create-event confirm/search. |
| `EventMapSheet` | `lib/events/presentation/widgets/event_map_sheet.dart:12` | Overlay sheet for map events. Uses `CatchSurface`, renders horizontal `EventMapTile` items from relationship-aware `EventMapItem` data, and routes the highlighted event to detail from the top-level map surface. |
| `EventPolicyStep` | `lib/events/presentation/widgets/event_policy_step.dart:41` | Create-event policy step for capacity, base price, admission preset, invite code, dynamic pricing, cancellation policy, eligibility bounds, and host payout copy. |
| `EventSuccessStep` | `lib/events/presentation/widgets/event_success_step.dart:9` | Final create-event live-guide step. Wraps `EventSuccessDefaultsPanel`, passing the current event capacity so structure defaults can estimate pods/teams from the booking policy while keeping live-guide setup separate from policy editing. |
| `StepperFooter` | `lib/events/presentation/widgets/stepper_footer.dart:5` | Create-event bottom action footer. Blends into the page background, renders draft as a ghost action, and gives the primary action a full-width lane so long labels scale within available width. |

---

## Event Success

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessManualQaScreen` | `lib/event_success/presentation/event_success_manual_qa_screen.dart:38` | Dev/staging manual QA harness. Uses Catch primitives to switch fixture event format and attendee opt-out states while rendering the canonical `HostEventManageScreen` beside the production attendee companion from one synchronized in-memory fixture store. The host pane overrides the exact Host Manage providers for event, roster, profile, event-success, and attendance-table state so Setup, Live, Report, and participation table changes stay covered without a duplicate host QA fixture. |
| `_FirstHelloCheckInCard` | `lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart:3` | Attendee companion First Hello mission card. Renders a server/manual-QA-provided target, one short question, private answer chips, completion, and a fallback action without leaking broader attendee data. |
| `EventSuccessHostPanel` | `lib/event_success/presentation/event_success_host_screen.dart:249` | Reusable host event-success panel with Setup, Live, and Report bodies. Setup derives recommendations from the event activity profile, keeps the editor visible for QA even when an unsaved started event is locked, and hides unsupported tools behind progressive disclosure. Live mode opens with one Live now console that combines the active stage, progress, attendee-facing state, optional embedded editable roster, current-step controls, and previous/next navigation before lower-priority supporting controls for wingman requests, reveal clues, conversation cues, assignments, and reveal controls. When Host Manage embeds the roster, the arrival control becomes a QR-only card instead of repeating attendance totals already shown by Live now plus the roster. Report mode summarizes signal quality from feedback response, assignment coverage, opt-outs, and wingman requests. Standalone uses can show its own picker; Host Manage passes a fixed lifecycle section and hides the inner picker. |
| `EventSuccessDefaultsPanel` | `lib/event_success/presentation/event_success_defaults_panel.dart:14` | Shared event-success defaults form. Used by club create/edit and create event to toggle setup, normalize activity-specific recommendations against an optional target attendee count, and show a preset-review card before advanced controls. Guide notes, match clue questions, structure, and tools are progressively disclosed; questionnaire ownership is separate from tool switches, and wingman/openers are derived from module selection instead of repeated booleans. |
| `_SetupTab` | `lib/event_success/presentation/host_parts/event_success_host_setup.dart:3` | Event-success setup form for playbook selection, target attendee count, host goal, attendee prompt, structure config, module toggles, reveal-clue opt-in, wingman requests, and setup save/ensure mutations. Essentials render first; advanced structure, tool, and delivery controls are progressively disclosed, with multiline guide-note fields and host-facing group/team/table language. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessCompanionScreen` | `lib/event_success/presentation/event_success_companion_screen.dart:444` | Attendee companion surface that resolves the runtime-selected live moment into a full-screen stage with moment-specific color, motif, privacy copy, keyed transitions, native live effects, optional First Hello arrival missions, reveal-safe assignment display, and a private post-event afterglow recap. Keeps the single-moment runtime model intact rather than restoring a stacked dashboard. |
| `_CompatibilityQuestionnaireSection` | `lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart:3` | Attendee companion quick-question clue ritual for event-scoped reveal clues. Focuses one question at a time, uses selected answer chips and progress, then saves through the stage action dock while preserving questionnaire privacy language. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessHostSection` | `lib/event_success/presentation/event_success_host_screen.dart:42` | Host Manage section loader for event-success data. It resolves the plan first, synthesizes a default plan until setup is saved, and skips roster/report/assignment/preference/wingman streams while no saved guide exists so Live and Report can render unavailable-guide states immediately. Host Manage can pass an embedded live roster so check-in correction remains available inside the Live now flow, including unavailable-guide states. |
| `EventSuccessLiveRevealHostCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart:3` | Host Live-mode reveal console for structured assignment flows. Shows a kinetic countdown, round queue, assignment clues, and host actions to start countdown, reveal now, or reset reveal state. |
| `EventSuccessLiveRevealAttendeeCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart:3` | Companion-side reveal surface for pods and rotations. Hides assignment details until the host reveal state unlocks the round, uses a stronger countdown/waiting/unlocked presentation, then shows partners or podmates with opt-out controls intact. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_PrivateAfterglowRecapCard` | `lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:3` | Private attendee-only post-event recap artifact. Summarizes the event, opener availability, and optional saved feedback while explicitly avoiding public share pressure or host-visible personal details. |
| `EventSuccessPromptCard` | `lib/event_success/presentation/event_success_feature_blocks.dart:616` | Shared prompt card used by event-success preview and attendee companion surfaces. |
| `EventSuccessStructureConfigEditor` | `lib/event_success/presentation/event_success_structure_config_editor.dart:10` | Shared structure editor for host setup and create-event defaults. Keeps internal unit modeling out of copy by exposing flow type, people-per-team/table/pod labels, auto versus fixed counts, and optional cadence/countdown controls supplied by the owning surface. |
| `EventSuccessConversationCueCard` | `lib/event_success/presentation/event_success_feature_blocks.dart:655` | Shared conversation cue card used by host Live mode and preview surfaces for live prompts and post-match opener suggestions. The staged attendee companion uses its own copyable cue rows. |
| `EventSuccessPostEventReport` | `lib/event_success/presentation/event_success_feature_blocks.dart:266` | Shared post-event report surface. Shows report metric pills, `Working well` strengths, and coach recommendation tiles while host-facing report copy stays aggregate and avoids personal attendee intelligence. |
| `_HostReportSignalGrid` | `lib/event_success/presentation/host_parts/event_success_host_report.dart:114` | Host report signal-quality summary using `EventSuccessMetricPill` and `CatchBadge` primitives for feedback response, assignment coverage, opt-outs, and wingman requests. |
| `EventSuccessMetricPill` | `lib/event_success/presentation/event_success_feature_blocks.dart:865` | Shared percentage pill for event-success reports and lab/preview metrics. |
| `EventSuccessRecommendationTile` | `lib/event_success/presentation/event_success_feature_blocks.dart:817` | Shared recommendation tile for post-event reports and the event-success lab coach sample. |
| `EventSuccessDarkPill` | `lib/event_success/presentation/event_success_feature_blocks.dart:894` | Shared dark hero pill for event-success lab and contextual preview heroes. |

---

## Calendar

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:21` | Calendar route for planned events. Merges booked events with future saved events, labels mixed agenda rows as JOINED/SAVED, uses one sliver-native scroll surface, and anchors the header to the next upcoming event or current week. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarHeader` | `lib/calendar/presentation/calendar_screen.dart:183` | Calendar header inside the route's sliver scroll surface: month label, week strip, and `CatchSurface` stats row. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:260` | Horizontal week strip showing 7 days with date indicators. Anchors to the next upcoming event, or to the current week when there is no upcoming event. |
| `_WeekDay` | `lib/calendar/presentation/calendar_screen.dart:303` | Single day cell in the week strip: day name, date number, and active indicator. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:372` | Divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:387` | Calendar empty/error state rendered through `CatchEmptyState`. |
| `_CalendarEventSummary` | `lib/calendar/presentation/calendar_screen.dart:410` | Private view model for calendar display order and header stats. De-duplicates signed-up/saved events, keeps only future saved-only events, puts upcoming events first, uses current week as the fallback anchor, and exposes `nextEvent`. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:22` | Post-payment confirmation route. Loads the event/club context and delegates the success UI to `EventJoinedCelebrationScreen`, adding payment quick actions, heads-up copy, stronger friend-invite sharing, and the stable Back home key. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:55` | Thin payment confirmation adapter that composes `EventJoinedCelebrationScreen` with paid-event supplemental children and router actions. |
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
| `_WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:39` | Bottom sheet for writing, editing, or deleting an event review. Requires a concrete `eventId`, uses `CatchBottomSheetScaffold`, semantic star/action keys, inline mutation errors, and `WriteReviewController` submit/delete mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubReviewsSection` | `lib/reviews/presentation/reviews_section.dart:19` | Read-only club review aggregate. Shows the latest three reviews, uses the compact inline empty state, and never opens the write/edit sheet. |
| `EventReviewsSection` | `lib/reviews/presentation/reviews_section.dart:44` | Event-scoped reviews with write/edit CTA for attended participants. Uses the same compact inline empty-state primitive as club reviews; this is the only page-level review section that should open `WriteReviewSheet`. |
| `ReviewsPreviewSection` | `lib/reviews/presentation/reviews_section.dart:121` | Shared read-only preview list: header, aggregate rating, compact/stacked empty-state configuration, top-N review cards, and optional see-all sheet. Callers supply edit callbacks only when the parent surface is event-scoped. |
| `ReviewsHistoryScreen` | `lib/reviews/presentation/reviews_history_screen.dart:19` | Profile-owned review history screen. Lists the current user's reviews newest-first and opens the shared edit review sheet for event-backed reviews. |
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
status. Move any selected item into `docs/audit_registry/backlog.json` before
implementing it.

### High Signal

| Candidate | Current State | Recommended Direction |
|---|---|---|
| `FieldLabel` | Thin create-event wrapper around `CatchFormFieldLabel(large: true)`. | Delete only if call sites stay clearer with direct `CatchFormFieldLabel`; otherwise keep as a create-event semantic wrapper. |
| `_DashboardLoadingScreen`, `_RouterLoadingScreen`, route-level loading scaffolds | Several screens still create a full-screen loading scaffold by hand. | Consider `CatchLoadingScreen` only if another pass touches two or more route-level loading screens together. |
| `_DashboardMessageScreen`, route-level error/message scaffolds | Message screens are similar but not identical. | Consider `CatchMessageScreen` with optional title/body/action if repeated route-level message screens continue to grow. |
| `ChatsSliverHeader`, `ClubsSliverHeader` | Feature-specific pinned wrappers around `CatchBrowseHeader` still share structure. | Parameterize a shared browse-sliver wrapper only if a third feature needs the same title/search/action pattern. |
| `ProfileInfoChip` | Swipe profile chip overlaps conceptually with `CatchChip`, but has overlay styling needs. | Extend `CatchChip` only if overlay-style info chips recur outside swipes. |

### Watch, Do Not Force

| Candidate | Reason To Wait |
|---|---|
| Feature empty-state wrappers | Most now delegate to `CatchEmptyState`. Keep wrappers when they encode feature-specific copy/content semantics; inline only when the wrapper adds no meaning. |
| `StatColumn`, `RunStatCell`, `HostStatChip` | They share a value-over-label concept, but host/profile/local chips still have different surface ownership. Detail-page metric rails should use `CatchMetricStrip` instead of new one-off stat rows. |
| `StatusChip` and `CatchBadge` | `StatusChip` is enum-driven and semantic; `CatchBadge` is a general label primitive. Rebuild `StatusChip` on `CatchBadge` only if it removes real styling drift. |
| `VibeTag` and `CatchChip` | Different interaction and visual roles. Keep separate unless a broader chip/token audit proves they should converge. |
