---
doc_id: widget_catalog
version: 2.5.532
updated: 2026-07-02
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

### 2.5.532

- Cataloged the Explore cover and control leaf renderers directly:
  `CoverStoryChrome`, `CoverStoryContent`, `CityTrigger`,
  `ExploreRailLabel`, and `ExploreFilterGlyphButton`. These remain
  provider-free display pieces; route/provider ownership stays in
  `ExploreCityPicker`, `CatchCoverStory`, and `ExploreFilterRail`.

### 2.5.531

- Cataloged the Dashboard activity/home leaf renderers directly: grouped
  notification rows, notification row skeleton, followed-clubs rail skeleton,
  header content, empty hero content, event-focus card, and event-focus page
  indicator. `EventFocusCard` now accepts public display state so the public
  card can be reviewed outside its rail.

### 2.5.530

- Cataloged the Club detail and discovery leaf renderers directly: dock count
  and bell, next-run/activity detail sections, hero module, share artwork/meta
  rows, avatar chips, and club image states. Also replaced stale private
  `_AvatarChip`/`_ClubImage` catalog names with the current public widgets.

### 2.5.529

- Cataloged the Profile edit-tab skeleton leaf renderers directly: photo grid
  skeleton section, info skeleton section, and individual info skeleton row.
  This keeps loading-state geometry reviewable below the full sliver skeleton
  dispatcher.

### 2.5.528

- Cataloged the Explore map peek-rail leaf renderers directly: collapsed map
  summary, selected/rail ticket card, and rail loading skeleton. This keeps the
  map sheet's exact public widget surface reviewable below the lead sliver
  dispatcher.

### 2.5.527

- Cataloged the Profile header leaf renderers directly: title row, tab bar,
  and settings action. Widgetbook's header preview now uses the same 3-tab
  controller length as production so the Insights tab remains scaffold-safe.

### 2.5.526

- Cataloged the Explore list empty and loading renderers directly: list empty
  state, directory skeleton stack, and single directory skeleton card. This
  keeps the club-directory fallback states reviewable below the provider-backed
  `ExploreList` sliver dispatcher.

### 2.5.525

- Cataloged the Event Detail companion/invite leaf cards directly: booked-user
  invite loop, Event Success companion entry card, and guest sign-in booking
  dock. This keeps the event-detail action surfaces reviewable below the full
  `EventDetailBody` composition.

### 2.5.524

- Cataloged the Who's Going render leaves directly: provider-free roster
  content, empty roster message, and swipe-window banner states. This keeps the
  event-detail roster section reviewable below the provider-backed
  `WhoIsGoing` wrapper.

### 2.5.523

- Cataloged the Event Success private-feedback row primitives directly:
  ratings, people-met counter, and icon actions. This keeps the attendee
  afterglow feedback form reviewable below the full form shell without changing
  companion runtime behavior.

### 2.5.522

- Cataloged the public Welcome splash visual leaves directly: scene layout, reel
  band, reel row, and reveal entrance. This keeps the animated logged-out start
  surface reviewable below the `WelcomePage` route wrapper.

### 2.5.521

- Cataloged the `CatchCrossPathsCard` inventory row and its public leaf
  renderers: surface chrome, graded portrait, polaroid rail, and CTA row. The
  formal composite contract remains in Widgetbook, while Explore now also has
  direct states for the pieces used by postcard/photo-row variants.

### 2.5.520

- Cataloged the `ProfileSurfaceSkeleton` leaf renderers directly: hero, generic
  section, running block, photo block, facts rows, and section rule. This keeps
  loading-state review possible below the full shared profile skeleton shell.

### 2.5.519

- Cataloged the Event Detail design primitive leaves directly: photo strip
  tile, ticket stub cell, hairline list, itinerary row, map pill, and host
  avatar. `TicketStubCell` and `ItineraryRow` now accept public display-data
  objects so their public widget APIs can be instantiated from Widgetbook and
  tests without private-library access.

### 2.5.518

- Cataloged the Explore event-type browse grid subparts directly: content,
  responsive row layout, slot router, activity row, overflow row, activity dot,
  and skeleton. This keeps Browse by activity reviewable below the provider
  wrapper and clears the `explore_event_type_browse_grid.dart` coverage cluster.

### 2.5.517

- Cataloged the `CatchCelebrationScreen` subpart family directly: immersive and
  paper detail rows/cards, icons, note surface, and the paper scaffold. This
  keeps high-emotion confirmation moments reviewable below the full-screen
  composition and clears the celebration Widgetbook coverage cluster.

### 2.5.516

- Cataloged the public Explore mixed-feed renderer family directly: event rows,
  external read-only supply rows, weekly recommendation strips, club polaroids,
  compact club rows, club media/tags, mono labels, dark pills, and the loading
  sliver. This clears the `explore_events_section.dart` Widgetbook coverage
  cluster without changing production Explore behavior.

### 2.5.515

- Cataloged the public `CatchProfileView` renderer family directly:
  hero/photo/scrim, section dispatcher, compatibility, prompt, running, facts,
  standalone photo, caption, rule, kicker, and running-stat components. This
  makes the flagship profile surface reviewable below the `ProfileSurface`
  adapter and clears the profile-redesign Widgetbook coverage cluster.

### 2.5.514

- Cataloged the `UserAnalyticsPanel` child renderers with exact Widgetbook
  coverage: report view, empty state, loading skeleton, metric grid/tile, trend
  panel/bar, tips panel/row, data-quality panel/row, section shell, and inline
  stat. The panel catalog row now matches the current implementation instead of
  older metric-strip guidance.

### 2.5.513

- Cataloged the public Club Discovery directory-card renderers
  (`DirectoryCard`, `DirectoryPhotoCard`, `DirectoryIdentityCard`,
  `ClubPhotoMediaOverlay`, `ClubPhotoChrome`, `ClubPhotoScrim`,
  `ClubLogoCrest`, `ClubLogoFallback`, `ClubDirectoryFooter`,
  `ClubHostActionRow`, `MembershipTrailing`, and `ClubRule`) with exact
  Widgetbook coverage. The catalog now uses the current public names instead of
  stale underscored directory-card entries.

### 2.5.512

- Cataloged the Club Detail loading body subparts (`ClubHeroLoadingSkeleton`,
  `ClubStatsLoadingSkeleton`, `ClubStatLoadingSkeleton`,
  `ClubStatsDividerSkeleton`, `ClubHostLoadingSkeleton`,
  `ClubTextLoadingSkeleton`, `ClubTagLoadingSkeleton`, and
  `ClubScheduleLoadingSkeleton`) with exact Widgetbook coverage so no-fallback
  Club Detail route loads can be reviewed at both screen and atom level.

### 2.5.511

- Registered `CatchControlShell` and `CatchMiniBarChart` as formal component
  contracts, and registered `EventHeroSurface` plus `EventActivityStamp` as
  `catch.event_card` members with exact Widgetbook contract previews. This
  clears the remaining `review-promote-or-consolidate` core widget items.

### 2.5.510

- Promoted `CatchFieldRow`, `CatchFieldTrailing`, and
  `CatchSectionFocusSurface` as public members of the existing `catch.field` and
  `catch.section` contracts, with exact Widgetbook contract previews. This
  clears the remaining private widget review items without creating new
  standalone primitive families.

### 2.5.509

- Promoted `LegacyEventHeroSurface`, `EventDetailTicketHeroSurface`,
  `EventDetailTicketSurface`, `HeroActivityBadge`, and `HeroTimeChip` as public
  cataloged renderers used by `EventDetailHeroAppBar`, with exact Widgetbook
  coverage. The classification scanner's private widget review count drops by
  five without changing event-detail hero behavior.

### 2.5.508

- Promoted `OnboardingTopBar` as the public cataloged progress/header adapter
  used by `OnboardingScreen`, with exact Widgetbook coverage. The classification
  scanner's private widget review count drops by one without changing
  onboarding flow ownership.

### 2.5.507

- Promoted `TimestampedMessageText` and `MediaMessageBody` as public cataloged
  renderers used by `MessageBubble`, with exact Widgetbook coverage. The
  classification scanner's private widget review count drops by two without
  changing chat bubble text/media behavior.

### 2.5.506

- Promoted `ShareCardHeader` and `ShareCardBubble` as public cataloged visual
  atoms used by `ChatShareCard`, with exact Widgetbook coverage. Also added the
  missing `ChatShareCard` and `ChatShareCardSheet` rows to close markdown
  catalog drift against the existing Widgetbook components.

### 2.5.505

- Promoted `OptimisticHostsSkeleton` and `OptimisticSocialSkeleton` as public
  cataloged loading sections used by `EventDetailOptimisticBody`, with exact
  Widgetbook coverage. The classification scanner's private widget review count
  drops by two without changing optimistic event-detail rendering.

### 2.5.504

- Promoted `GuestWhoIsGoing` as the public cataloged guest roster prompt used by
  `EventDetailSocialSection`, with exact Widgetbook coverage. The
  classification scanner's private widget review count drops by one without
  changing signed-out event-detail social behavior.

### 2.5.503

- Promoted `EventDescription` and `WhatToExpectSection` as public cataloged
  display blocks used by `EventDetailOverviewSection`, with exact Widgetbook
  coverage. The classification scanner's private widget review count drops by
  two without changing event-detail overview composition.

### 2.5.502

- Promoted `DateRail` and `PerforationLine` as public cataloged renderers used
  by `EventDateRailCard`, with exact Widgetbook coverage. Private clipper and
  painter helpers remain private implementation details, while the
  classification scanner's private widget review count drops by two.

### 2.5.501

- Promoted `EventShareMetaRow` and `EventSharePill` as public cataloged visual
  atoms used by `EventShareCard`, with exact Widgetbook coverage. The
  classification scanner's private widget review count drops by two without
  changing share-card rendering or invite-copy behavior.

### 2.5.500

- Promoted `EventActionCardHeader` and `EventActionCardActions` as public
  cataloged renderers for `EventActionCard`, with exact Widgetbook coverage.
  The classification scanner's private widget review count drops by two without
  changing event action card composition.

### 2.5.499

- Promoted `AgendaDayGroup` and `EventAgendaTileSkeleton` as public cataloged
  renderers used by the agenda list/sliver skeleton, with exact Widgetbook
  coverage. The classification scanner's private widget review count drops by
  two without changing agenda grouping or skeleton behavior.

### 2.5.498

- Promoted `BookingConflictEventRow` as the public cataloged row renderer used
  inside `BookingConflictSheet`, including exact Widgetbook coverage for
  activity-colored and fallback visual states. The classification scanner's
  private widget review count drops without changing booking-conflict behavior.

### 2.5.497

- Promoted `EventCompactDatePill` as the public cataloged date renderer used by
  `EventCompactRow`, with exact Widgetbook coverage. The classification
  scanner's private widget review count drops without changing compact event row
  behavior.

### 2.5.496

- Promoted `WeekMarker` and `MonthMarker` as public cataloged
  `EventDateMarker` variant renderers with exact Widgetbook coverage. The
  classification scanner's private widget review count drops by two more
  without changing Calendar marker behavior.

### 2.5.495

- Promoted the Profile Edit direct-text and prompt row adapters to public
  cataloged widgets. `ProfileDirectTextEntry` and `ProfilePromptEntry` now have
  exact Widgetbook coverage, reducing the classification scanner's private
  widget review count for `profile_tab.dart`.

### 2.5.494

- Added exact Widgetbook and catalog coverage for Event Recap's provider-free
  ready body and vibe grid. `EventRecapReadyBody` now has direct ready,
  selected, and empty-roster review states, while `VibeGrid` covers profile,
  selected, and fallback guest tile rows.

### 2.5.493

- Added exact Widgetbook and catalog coverage for
  `CalendarAgendaSliverSection`, including ready, club-name loading,
  club-name error, and empty agenda states. Calendar's new public section
  widget is no longer unresolved inventory debt.

### 2.5.492

- Added exact Widgetbook and catalog coverage for Saved Events route-section
  widgets: `SavedEventsHeaderSliver`, `SavedEventsAgendaSliver`,
  `SavedEventsError`, and `SavedEventsClubNamesErrorSliver`. The new-entry
  inventory now treats the Saved Events cluster as covered public surface
  instead of unresolved widget debt.

### 2.5.491

- Cataloged `HostParticipationLifecycleBoard` as the provider-free Host Manage
  participant roster board. Widgetbook already covers the exact public widget
  states, so the new-entry inventory now treats it as documented coverage
  instead of unresolved catalog debt.

### 2.5.490

- Added Host Manage invite-link row edge coverage. The
  `HostEventManageRouteScreen/Route and section states` preview and
  deterministic captures now exercise disabled named invite-link rows and long
  label/source layout through the real row display state.

### 2.5.489

- Added Host Manage private-access missing-code coverage. The
  `HostEventManageRouteScreen/Route and section states` preview and
  deterministic capture now exercise the invite-only branch where a
  private-access document exists but no host-readable invite code is available.

### 2.5.488

- Added Host Manage Event Success direct live-section coverage for check-in
  QR, conversation cues, revealed partner round, and host-edited micro-pod
  override states. The `HostEventManageRouteScreen/Route and section states`
  preview now includes the new live substates, while deterministic captures use
  the non-compact Event Success host section so the rich cards are visible.

### 2.5.487

- Added Host Manage Event Success live-rich coverage for active wingman
  requests, assigned micro-pods, and assigned guided rotations. The
  `HostEventManageRouteScreen/Route and section states` preview and
  deterministic captures now pass assignment, preference, wingman, and peer
  profile fixtures through the route-level provider helpers without production
  architecture changes.

### 2.5.486

- Added Host Manage Event Success section-level offline coverage. The
  `HostEventManageRouteScreen/Route and section states` preview and
  deterministic captures now distinguish live plan offline and report scorecard
  offline failures from generic Event Success provider errors while keeping both
  on the shared branded inline error surface.

### 2.5.485

- Added Host Manage section-level offline coverage for private access and named
  invite links. `HostEventManageRouteScreen/Route and section states`,
  deterministic captures, and the screen contract now distinguish generic
  private-access/invite-link failures from offline-mapped failures while
  keeping both on the shared branded inline error surface.

### 2.5.484

- Registered the Event Success host-section provider-wave adapter and Host
  Manage substates. `EventSuccessHostSectionState` now maps Event Success
  plan, roster, assignment, preference, wingman, profile, and scorecard provider
  waves into loading/error/ready state plus typed retry intent before
  `EventSuccessHostSection` composes the provider-free host panel. Host Manage
  Widgetbook/capture coverage now includes live plan loading/error and report
  scorecard loading/error.

### 2.5.483

- Registered the Host Event Manage participant lifecycle callback adapter and
  the Match Chat interaction-capture closure. `HostParticipantLifecycleActions`
  now feeds profile, approval, decline, attendance, waitlist-offer, ops-export,
  and revenue-export callbacks into the provider-free roster board while
  `HostEventParticipantsList` owns provider/navigation side effects. Match Chat
  now has deterministic captures for keyboard-open multiline composer,
  send-failure snackbar, report-failure snackbar, and block confirmation.

### 2.5.482

- Registered the Host Event Manage attendee profile lookup adapter.
  `HostParticipantProfilesLookupState` now owns empty-id, loading, ready, error,
  and retry-target policy for the batched attendee profile lookup while
  `HostEventParticipantsPanel` keeps the provider watch and invalidation at the
  panel edge.

### 2.5.481

- Registered the Host Event Manage report summary adapter.
  `HostReportSummaryDisplayState` now owns report gross-estimate math,
  attended/no-show/waitlist counts, currency formatting, and summary copy for
  the report panel.

### 2.5.480

- Registered the Host Event Manage participants mutation display adapter.
  `HostParticipantsMutationDisplayState` now owns attendance,
  approval/decline, waitlist-offer, ops-export, and revenue-export pending/error
  display policy while `HostEventParticipantsPanel` watches the mutations at the
  panel edge and feeds the lifecycle board.

### 2.5.479

- Made the Host Event Manage action section provider-free for private-link
  sharing. `HostEventActionsSection` now receives
  `HostPrivateLinkActionState` and a typed share callback from
  `HostEventManageScreen` instead of watching private access, invite-link, and
  share mutation providers directly.

### 2.5.478

- Registered the Host Event Manage action-effect adapter.
  `HostEventManageActionEffect` now owns edit/cancel/delete action
  destinations, edit route parameters, and event payload while
  `HostEventManageScreen` executes Navigator/dialog/controller side effects.

### 2.5.477

- Registered the Host Create Event draft side-effect state adapter.
  `CreateEventDraftSideEffectState` now owns draft-check, picker visibility,
  picker delete, and post-submit delete intent policy. The remaining Host Create
  design work is blocked on draft/validation/submit reference exports and masks.

### 2.5.476

- Registered the Host Create Event validation-plan adapter.
  `CreateEventWizardValidationPlan` now owns current form-key selection and
  current-step schedule validation policy while `CreateEventScreen` executes
  Flutter form validation.

### 2.5.475

- Registered the Host Create Event success-navigation effect adapter.
  `CreateEventSuccessNavigationEffect` now owns success destination, manage
  route parameters, and route extra payload while `CreateEventScreen` executes
  the Navigator/context side effect.

### 2.5.474

- Registered the Host Create Event wizard-step metadata adapter.
  `CreateEventWizardStep` now owns the canonical step order, titles, form-key
  spec construction, and schedule-validation metadata used by
  `CreateEventScreen`.

### 2.5.473

- Registered the Host Create Event draft-restore adapter. `CreateEventScreen`
  now delegates `EventDraft` restore mapping, stale enum fallbacks, restored
  schedule text, location state, policy state, and Event Success defaults to
  `CreateEventDraftRestoreState`.

### 2.5.472

- Registered the Host Create Event map-picker offline search state.
  `LocationPickerScreen` now maps Places autocomplete/detail network failures
  through shared app error copy, exposes an explicit non-platform map shell for
  deterministic captures, and the capture catalog includes
  `host_create_map_picker_offline`.

### 2.5.471

- Promoted `PublicProfileScreenBody` and `SelfProfileTabBody` as public,
  Widgetbook-covered route-branch widgets so new profile work no longer lands as
  private widget classes or widget-returning helpers. `PublicProfileScreenBody`
  receives retry as an explicit callback; `SelfProfileTabBody` receives route
  tab/preview controllers and callbacks from `ProfileScreen`.

### 2.5.465

- Completed the Event Success companion action-section adapter pass.
  `SelfCheckInCard`, `PaperSelfCheckInBar`, `WingmanRequestSection`, and
  `EventSuccessFeedbackForm` now receive explicit action state and callbacks
  from the companion screen instead of reading mutation providers directly.

### 2.5.464

- Registered the provider-free Event Success companion action sections with
  exact public widget names. `FirstHelloCheckInCard`,
  `CompatibilityQuestionnaireSection`, `MicroPodCard`, and
  `RotationScheduleCard` now receive explicit action state and callbacks from
  the companion screen instead of owning mutation provider reads.

### 2.5.463

- Added explicit Catches Event mutation display states. `SwipeScreen` now owns a
  route-local `CatchesProfileReviewActionState`; `CatchesProfileReview` passes
  pending state into `ProfileSurface`, `CatchesPassButton`, and
  `ProfileReactionControls`. Widgetbook now covers pass pending/disabled,
  reaction disabled/pending, and empty/filled reaction comment-sheet states.

### 2.5.462

- Promoted Club Detail host, contact, and photo sections into provider-free
  public section widgets with direct Widgetbook coverage:
  `ClubHostSection`, `ClubHostRow`, `ClubContactSection`, and
  `ClubPhotoStrip`.

### 2.5.461

- Registered Explore route/feed empty-state wrappers in Widgetbook and the
  catalog: `ExploreScreenEmptyState`, `ExploreClearAction`, and
  `ExploreEventsEmptySliver` now have exact-name review surfaces.

### 2.5.460

- Lifted Event Detail's remaining body-section providers and route effects into
  `EventDetailScreen`. `EventDetailBody` now receives explicit companion state,
  host state, location/companion/club/message callbacks, and retry callbacks
  instead of watching Event Success or club providers or pushing routes itself.

### 2.5.459

- Hardened `EventDetailBody` as explicit-input composition. Save/share/calendar
  display state and callbacks are now required inputs from `EventDetailScreen`
  or body-only fixtures; the body no longer falls back to route-level
  share/calendar/save providers when callbacks are omitted.

### 2.5.458

- Removed direct scaffold compatibility from `EventDetailBody` and
  `EventLocationMapScreen`. Event Detail route chrome, bottom navigation,
  mutation listeners, and snackbar feedback now stay in `EventDetailScreen`;
  Event Location Map back controls and loading/error/not-found shells stay in
  `EventLocationMapRouteScreen`. Direct body Widgetbook/test states are
  body-only states and must not imply route ownership.

### 2.5.457

- Defined `ARCH-SCREEN-001C` for `HostEventManageRouteScreen` as the host
  workspace route-boundary variant. Host Manage keeps canonical route aliases,
  uid/club/event loading, missing/error/access branches, and initial-section
  inputs in the route shell; the remaining migration is a loaded-workspace
  state/adapters pass for selected section, roster/private access/invite links,
  Event Success, report, host actions, mutation display state, retry intents,
  and typed callbacks.

### 2.5.456

- Promoted `SavedEventsScreen` as an aligned `ARCH-SCREEN-001` adopter.
  `SavedEventsListState` now owns saved-event ordering, saved/past labels, tile
  statuses, today, and club-id lookup input while the route keeps provider
  waves, retry, club lookup, and navigation callbacks at the screen boundary.

### 2.5.455

- Promoted `CalendarScreen` as an aligned `ARCH-SCREEN-001` adopter.
  `CalendarHomeState` now wraps the existing event summary with selected-date,
  expanded-header, and club-id lookup input so the route composes provider-free
  calendar sections from named state.

### 2.5.454

- Promoted `EventLocationMapRouteScreen` as the first aligned
  `ARCH-SCREEN-001` adopter outside Event Detail. The route now owns the
  chromeless `Scaffold`, loading/error/not-found branches, coordinate gate,
  retry invalidation, and external directions side effect before delegating to
  a provider-free map body.
- Added `EventLocationMapState` as the display-state adapter for pinned
  coordinate availability, map fixture mode, location copy, and directions URI.
  `EventLocationMapScreen` now receives explicit state plus
  `onGetDirections`; route chrome is owned by `EventLocationMapRouteScreen`.

### 2.5.453

- Promoted `EventDetailScreen` as the first `ARCH-SCREEN-001` reference
  screen. The loaded route path now owns the `Scaffold`, bottom navigation,
  route-level mutation listeners, share/calendar/save callbacks, and invite
  attribution controller seam before delegating an embedded body.
- `EventDetailBody` is the embedded scroll body for the reference screen path.
  Earlier direct-scaffold fixture mode has since been removed; mount
  `EventDetailScreen` for route-dock and mutation-listener states.

### 2.5.452

- Updated catalog paths after the feature-boundary cleanup that moved chat
  inbox UI to `lib/chats/presentation/inbox`, calendar to
  `lib/events/presentation/calendar`, shared event/activity visual primitives
  to `lib/core/widgets`, and event non-UI helpers/services to `events/domain`
  or `events/data`.

### 2.5.451

- Added `tool/design/check_new_widget_inventory.mjs` plus
  `npm run design:widgets:new` to compare the working tree against `HEAD^`
  and report newly introduced widget classes, private widget classes,
  widget-returning helpers, and Widgetbook/catalog coverage gaps.
- First scanner pass over the 2026-06-30 widget-architecture commit found
  297 added widget classes, 42 new private widget classes, and 9 new
  widget-returning helpers. This pass pruned the most obvious wrapper/helper
  redundancies in `ChatInputBar`, `SuvbotActionBar`, `ChatMessageList`,
  `CatchMiniBarChart`, `CatchField`, club image/activity chips, profile
  dividers, and Event Detail optimistic/host sections.
- Current generated delta after pruning: 283 added widget classes, 254 public
  added widget classes, 9 exact-name Widgetbook matches, 29 private
  widget-class blockers, 0 widget-returning helper blockers, 245 added widgets
  still missing exact-name Widgetbook coverage, and 244 added widgets still
  missing catalog mentions. The next focused pruning targets are Event Detail
  hero/tile private wrappers, chat share/media bubble fragments, and
  feature-local public section widgets that should either merge into existing
  primitives or get explicit Widgetbook/catalog ownership.

### 2.5.450

- Profile Insights now renders its summary, trend, empty, loading, tips, and
  data-coverage surfaces through shared primitives. `CatchMiniBarChart` is the
  shared compact trend primitive for the tiny bar chart case that previously
  required feature-local chart chrome.
- Profile edit cleanup removed stale inline-editor API surface: prompt answer
  counters stay owned by `ProfileInlinePromptEntryEditor`, range editors no
  longer accept unused field-name identifiers, and `ProfileInfoEntry` now has a
  single row-composition model instead of a dormant inline editor branch.
- `ProfileDirectTextEntryField` keeps the canonical `CatchField.input`
  empty-first contract: empty rows render collapsed until focus, keep the
  `EditableText` mounted offstage, and expand without paging flicker on first
  focus.

### 2.5.449

- `ChatInputBar` now renders one contained dialogue pill: the image upload
  action is the leading slot, the bare message input is the center slot, and
  the filled send action is the trailing slot inside the same field outline.

### 2.5.448

- `UserAnalyticsPanel` now composes the Suggestions and Data coverage blocks
  through `CatchSection` and `CatchField.read` rows instead of feature-local
  card/row chrome. Data coverage ids map to stable field labels while the
  backend-provided coverage detail remains the row body.

### 2.5.447

- `CatchField.nav` now supports a shared `chevronOpen` state so expandable rows
  can rotate the canonical right chevron without profile-local trailing chrome.
  Icon-only trailing controls stay fixed at the right edge, while `valueText`
  metadata rows keep their bounded flexible value lane on narrow widths.
- Edit Profile info sections can opt into full-bleed row frames: row
  backgrounds, tap/focus highlights, and chevrons extend to the viewport edge
  while dividers keep the same light section-line color and symmetric insets.

### 2.5.446

- Removed the temporary `CatchField.input` `collapseEmptyInput` API. Empty
  row-style text entries keep the canonical collapsed label-only state until
  focus, value, or error requires the editor body.
- Active row-style `CatchField.input` editors now skip `AnimatedSize`, so the
  first focused frame lays out at full editor height instead of mounting focused
  text into a clipped collapsed row.

### 2.5.445

- Superseded by 2.5.446 before publish: the temporary `collapseEmptyInput`
  API overcorrected first-focus geometry and made empty Edit Profile text rows
  render as label/value stacks while unfocused.

### 2.5.444

- Edit Profile simple free-text rows now use direct editable
  `CatchField.input` rows via `ProfileDirectTextEntryField`: Display name,
  Email, Instagram, Job title, and Company. These rows no longer open inline
  disclosure drawers or trailing `Cancel`/`Done` actions; they keep keyboard,
  autofill, validation, trim/normalization, blur, and submit behavior on the
  shared field primitive.
- Removed the now-unused `ProfileInlineTextEntryEditor` wrapper. Prompt answer
  editing still uses `ProfileInlineTextValue` inside
  `ProfileInlinePromptEntryEditor`, because prompt rows also own prompt-picker
  selection and slot uniqueness.

### 2.5.443

- Made the platform function/body font auditable at runtime: `CatchFonts.sans`
  now resolves the DTCG `system-ui` concept to Flutter's concrete platform
  family names (`CupertinoSystemText`/`CupertinoSystemDisplay`, `Roboto`,
  `.AppleSystemUIFont`, or `Segoe UI`) before emitting `TextStyle`s.
- Updated the UI lint font-family contract and Widgetbook typography summaries
  so app/body styles no longer hide behind a null `fontFamily` labeled as
  `platform`.

### 2.5.442

- Tightened the typography role split: Archivo is now reserved for brand/display
  and deliberate poster identity styles, while user-authored content, names,
  prose, section/card titles, controls, and body text use the platform font
  through `CatchFonts.sans`.
- Expanded `FoundationTypographyTokens` so Widgetbook renders all 54 public
  `CatchTextStyles` helpers with family, size, weight, height, and tracking
  metadata for manual review.

### 2.5.441

- Consolidated event cards into `CatchEventCard` with `ticket`, `spotlight`,
  and `compact` variants. Removed the separate ticket/spotlight public classes
  from app, tests, Widgetbook, and compare-tool definitions.
- Folded the sticky CTA footer into `CatchBottomDock.cta`, so bottom chrome now
  has one public primitive with custom-content and CTA modes.
- Flattened chat inbox rows into `CatchPersonRow` chat-preview configuration.
  `CatchPersonRowData` now owns avatar shape, divider, timestamp, unread, and
  new-match dot state without a feature adapter.
- Added `docs/audit_registry/widget_variant_inventory.json` plus
  `npm run design:widgets:variants` / `design:widgets:variants:check` to rank
  large Widgetbook state matrices for variant pruning. Current generated counts:
  671 public widget classes, 771 classified widget/state entries, 6 public
  review items, 0 private widget-class blockers, and 41 variant review
  candidates.

### 2.5.440

- Absorbed the remaining private chat browse-header chrome into
  `CatchTopBar`. `CatchTopBar` now supports safe-area opt-out for pinned sliver
  slots, custom content padding, controlled expanding-search state, search
  autofocus/submission/focus hooks, custom search labels, and custom collapsed
  search extent. `ChatsBrowseHeader` now remains only as the public feature
  adapter for provider wiring plus host filters; the private `_ChatsHeaderChrome`
  and `_ChatsHeaderTitle` widget classes are no longer part of the inventory.
- Regenerated widget classification and strict Widgetbook coverage. The
  generated registry now reports 774 classified entries, 674 widget classes,
  9 public `review-promote-or-consolidate` candidates, 0 private widget-class
  blockers, and 0 Widgetbook coverage decisions.

### 2.5.439

- Added the next component-contract consolidation batch. Error surfaces,
  loading/skeletons, feedback banners, notices, sheets, section grouping,
  typography roles, small controls, network images, form dialogs, and metric
  metadata now resolve through canonical contract families instead of separate
  unresolved catalog widgets.
- Removed the redundant `CatchStepFlowHeader` compatibility wrapper. Existing
  zero-based flow call sites now convert to `CatchStepHeader(step:, total:)`
  at the boundary. Removed the redundant `CatchDetailRow` wrapper and migrated
  payment detail rows to `CatchField` read rows.
- Regenerated Widgetbook directories and widget classification. The generated
  registry now reports 777 widget entries with 10 public
  `review-promote-or-consolidate` candidates remaining plus 2 private chat
  header widgets that need a public-catalog decision.

### 2.5.438

- Added contract-member governance so public sub-widgets can belong to one
  canonical component family without creating redundant top-level contracts.
  The first batch assigns top-bar actions/tabs/collapsed titles to
  `catch.top_bar`, badge dots/icon badges/sashes to `catch.badge`, field labels
  and control chrome to `catch.field`, OTP input to `catch.code_input`,
  select chips to `catch.chip`, screen/section placement wrappers to
  `catch.screen_body` and `catch.section_stack`, avatar stacks to
  `catch.person_avatar`, step progress to `catch.step_header`, and inline
  message chrome to `catch.surface`.
- Updated the widget classification generator/checker so contract members are
  tracked as `keep-canonical-contract` with their parent as `canonicalFamily`.
  This reduced `review-promote-or-consolidate` from 69 to 50 without runtime
  widget changes or private-helper remediation.

### 2.5.437

- Added formal governance metadata to every component contract. Each contract
  now declares its role, ownership boundaries, dependency level, public API
  policy, and review policy so primitives, compositions, patterns, and screen
  contracts can be checked consistently.
- Added the generated widget classification registry at
  `docs/audit_registry/widget_classification.json`. It classifies every Dart
  widget class against contract, Widgetbook, role, ownership, catalog, and
  remediation rules while separating `State<T>` classes from render widgets.
- Added `npm run design:widgets:classify` and `npm run design:widgets:check`.
  The checker rejects private-helper remediation paths; private widget classes
  must be promoted, merged into a canonical public widget, or inlined/deleted.

### 2.5.436

- Auto-merged the remaining safe catalog-vs-contract Widgetbook duplicates.
  `CatchActivityArt`, `CatchActivityChip`, `CatchClubDock`, `CatchCodeInput`,
  `CatchCoverStory`, `CatchCrossPathsCard`, and `CatchStatusBar` now review
  only through their formal contract pages. Feature/catalog pages that repeated
  those same primitive states were removed from Widgetbook registration.
- Pruned duplicate compare-tool queue rows for bottom-sheet and empty-state
  review, leaving the broader app-family candidates as the single place for
  those decisions.

### 2.5.435

- Removed the retired shared browse-header wrapper and Home personal-club rail
  wrapper from the active catalog. Chats, Explore, and Home now compose the
  relevant core primitives directly at their feature boundary: search chrome
  through `CatchSearchField` expanding mode and followed-club rails through
  `ClubAvatarRail` inside `DashboardFullSliverBody`.
- Pruned duplicate Widgetbook catalog registrations for contract-backed
  primitives including search fields, range sliders, toggles, tab docks, step
  headers, option groups, avatars, count pills, distance rings, confirm dialogs,
  notification rows, chat list tiles, and quick actions. The formal contract
  states are the canonical review surface for those primitives.
- Folded the latest reviewer decisions into the catalog: Explore search now
  uses `CatchSearchField` directly, policy-lab metric tiles use surfaced
  `CatchStatColumn`, Host Today content lives inside
  `HostTodayDashboardSection`, and profile/host inline field rows compose the
  `CatchField`-backed profile info tile through a helper instead of a public
  scaffold widget class.

### 2.5.434

- Closed the strict Widgetbook coverage pass for `swipes`, `user_profile`,
  `onboarding`, and `core/celebration`. Local screen skeleton/layout chunks in
  those areas are now folded into helper functions, while reusable surfaces such
  as `ProfileTabContent` and `ProfileReactionCommentSheet` are public,
  composable, and cataloged by exact-name Widgetbook use cases. Owned coverage
  reports zero private or uncataloged public widget classes.

### 2.5.433

- Closed the messaging Widgetbook strict-coverage pass for `chats` and
  `matches`. `ChatScreen` now owns the former private chat content and mutation
  listener chunks directly, local message/share/Suvbot/list skeleton fragments
  are helper functions instead of private widget classes, and
  `ChatsBrowseHeader` is the cataloged public host/consumer browse-header
  adapter. Added exact Widgetbook use cases for the remaining messaging public
  surfaces; the generated Widgetbook directories are intentionally left for the
  main regeneration thread.

### 2.5.432

- Pruned the remaining contract-backed duplicate Widgetbook catalog pages for
  `CatchField`, `CatchBadge`, and `CatchScreenBody`. The canonical review
  surface for those primitives is now the formal contract-state page only.
- Added the second-pass comparison queue for still-open primitive boundaries:
  settings/detail rows versus `CatchField`, search/header/menu/select
  compositions, section labels/headers, bottom chrome, avatar stack grammar,
  selection affordances, and feature empty-state wrappers.

### 2.5.431

- Consolidated the section system around `CatchSection`. The section primitive
  now owns divided hairline groups, contained rounded groups, and plain titled
  blocks through `CatchSection.divided`, `CatchSection.contained`, and
  `CatchSection.plain`, while fields remain the information atom and surfaces
  remain low-level chrome. The former field-group,
  design-section, and section-surface APIs are no longer part of the inventory.

### 2.5.430

- Consolidated the surface system around `CatchSurface`. Card, tinted-note,
  and inline-message presentations now live as `CatchSurface.card`,
  `CatchSurface.tinted`, and `CatchSurface.message` modes under the
  `catch.surface` contract. Redundant surface wrapper classes and catalog-only
  Widgetbook pages are no longer part of the inventory.

### 2.5.429

- Consolidated the conversation top bar into `CatchTopBar.identity`.
  Conversation avatar/name title chrome now lives under the canonical
  `catch.top_bar` contract as the `conversation-title` state. Chat screens now
  build typed share/report/block menu values directly through
  `CatchTopBarMenuAction`, with no chat-specific top-bar wrapper or standalone
  Widgetbook primitive page.

### 2.5.428

- Consolidated the metric/stat rail into `CatchMetricStrip`. Club detail stats,
  foundation data-pair specimens, core primitive tests, and Widgetbook review now
  use the canonical `catch.metric_strip` contract with no separate stat-strip
  primitive or Widgetbook page.

### 2.5.427

- Consolidated Widgetbook review surfaces for primitives that already have
  formal contracts. `CatchSection`, `CatchRosterTiles`, `CatchRosterRow`,
  `CatchRosterTable`, `CatchPrivacyBadge`, and `CatchJourneySteps` now use
  their contract-state pages as the canonical Widgetbook review surfaces rather
  than maintaining duplicate catalog-only pages.

### 2.5.426

- Consolidated the field system around `CatchField` and `CatchSection`.
  `CatchField` now owns row, input, navigation, toggle, expanded-control, add,
  validation, helper, clearable, and suffix-action states through the canonical
  `title` / `body` / `action` / `placeholder` API. `CatchSection` owns both
  boxed and divided section chrome; deleted field adapters are no longer part of
  the inventory.

### 2.5.425

- Added the Host Chat route-state adapter pass. `ChatRouteState` now performs
  the route-level uid, match, messages, host-inquiry club, public profile,
  event, Suvbot action, mutation-pending, and share-controller provider
  watches before `_ChatContent` renders the top bar, event header, message
  list, Suvbot controls, and composer. `HostChatScreenState` moved to its own
  pure decision file; focused tests now cover the `ChatRouteState` provider
  seam in addition to the existing screen behavior.

### 2.5.424

- Added the Host Inbox broadcast-card parity pass. `ChatsListBody` now leads
  host populated states with `HostInboxBroadcastCard`, while `ChatsListScreen`
  owns the route-scoped disabled broadcast review sheet and passes a typed
  host-broadcast callback through `ChatsList`. The `host_inbox_queries`
  reference-safe-area capture now compares within advisory threshold at
  `8.64%` mismatch / `14.81` meanDelta; backend send wiring remains future
  product work.

### 2.5.423

- Added the Host Club Detail follow-up parity pass. `ClubHeroAppBar` now uses
  the floating top-bar icon treatment for club hero chrome, the club detail
  stat rail scales long values down inside fixed stat cells instead of
  ellipsizing, and `ClubDetailBody` uses regular-weight About copy plus a split wrap for
  generic descriptive tags after activity chips. The registered
  `host_club_detail_public` advisory comparison improved from `19.56% / 20.67`
  to `17.87% / 19.52`; mismatch now passes, while mean delta remains above
  threshold pending typography/font metric review and mask calibration.

### 2.5.422

- Added the Host Edit Club grouped-field/media parity pass. Owner edit now uses
  a Sunday sea-face reference fixture, compact logo/photo-strip variants from
  `CreateClubProfileImagePicker` / `CreateClubPhotosPicker`, grouped
  `CatchField` identity/contact rows, and a fixed `CatchField` edit-label
  offset for multiline/edit rows. The registered owner-edit reference now
  compares within threshold at `7.92% / 8.64`.

### 2.5.421

- Added the Host Home Today dashboard parity pass. `HostOperationsHomeScreen`
  now defaults to `HostHomeTab.today` while explicit Events states use
  `HostHomeTab.events`; `HostHomeTodayDashboardState` maps selected-club event
  data into a next-event hero plus needs-you task rows; and
  `HostTodayDashboardCard` / `HostTodayDashboardSection` keep Today rendering
  provider-free below a narrow event-stream adapter. The deterministic Host
  Home Today fixture now matches the Bandra Social trivia reference, and both
  registered Host Home references are within advisory thresholds: Today
  `17.48% / 15.54`, Events `6.76% / 12.26`.

### 2.5.420

- Finished the Host Event Manage registered-reference parity pass. Host Manage
  now renders Setup / Guests / Live / Report with the shared
  `CatchSegmentedControl`; setup leads with capacity metrics and compact action
  rows before deeper private-access/details/Event Success content; the Guests
  section owns the participant roster; and the full/waitlist banner can reflect
  cohort waitlist pressure even when total capacity still reads below the
  headline limit. The deterministic Host Manage fixture now matches the Claude
  Bandra Social state, and all five registered references are within advisory
  thresholds: setup `13.35% / 13.30`, full/waitlist `14.49% / 15.54`, guests
  roster `12.68% / 15.43`, live `10.05% / 4.69`, and report `12.61% / 15.52`.

### 2.5.419

- Finished the Host Create Event success/manage paper celebration parity pass.
  The shared `CatchCelebrationScreen.paper` appearance now uses tokenized top
  and bottom insets, taller detail-row rhythm, lighter separators, and a
  tokenized action gap so the event-created success screen matches the Claude
  confirmation surface. The full Host Create Event reference set is now within
  advisory thresholds; `host_create_success_manage` improved from 27.13%
  mismatch / 42.68 meanDelta to 11.40% mismatch / 13.70 meanDelta.

### 2.5.418

- Added the Host Club Detail public-view alignment pass: the shared club detail
  body now follows the Claude section order with next-run banner, four-up
  member/rating/review/established stats, activity chips, next-event address in
  the hero, and the reference portrait fixture in deterministic captures.
  `CatchNetworkImage` now supports bundled asset paths, `CatchGradedImage`
  uses alpha-aware photo tints, and UI captures load the platform body fallback for
  platform text plus prewarm the club portrait asset. The
  `host_club_detail_public` advisory comparison improved from 28.94% mismatch /
  44.44 meanDelta to 19.56% mismatch / 20.67 meanDelta, while remaining above
  threshold pending body/chip typography, vertical rhythm, and mask calibration.

### 2.5.417

- Tightened the paper `CatchCelebrationScreen` rhythm used by Host Create Event
  success/manage: the message column uses a smaller body role, detail rows use
  denser vertical padding, and the event-created surface now uses a celebration
  icon, optional event display name, compact when/activity labels, and a
  deterministic Sundowner 5K fixture. The `host_create_success_manage`
  advisory comparison improved from 32.49% mismatch / 55.05 meanDelta to
  27.13% mismatch / 42.68 meanDelta, while remaining above threshold pending
  status chrome, top placement, and exact title/message rhythm alignment.

### 2.5.416

- Added the Host Event Manage compact live workspace pass: Host Manage now uses
  club-name header metadata, a compact non-distance event title, Event Success
  compact live controls, team-rotation round copy, previous/next controls, and
  a check-in summary strip instead of embedding the editable roster in the
  first live viewport. The `host_live_console` advisory comparison improved
  from 39.61% mismatch / 52.59 meanDelta to 25.36% mismatch / 46.71 meanDelta,
  while remaining above threshold pending compact step-count/playbook semantics,
  status chrome, and vertical rhythm alignment.

### 2.5.415

- Added deterministic public-profile reference fixture support: `PublicProfileScreen`
  can accept shared-event context for profile insight rendering, `ProfileSurface`
  can render asset-backed profile photos through the shared profile mapper, and
  the `public_profile_member` capture now uses a bundled portrait fixture. The
  advisory comparison improved from 40.49% mismatch / 44.89 meanDelta to
  36.62% mismatch / 32.76 meanDelta, while remaining above threshold pending
  top chrome, insight-copy, confidence badge, and below-fold profile-section
  alignment.

### 2.5.414

- Added the full-bleed Dashboard Home empty-start hero-shell composition and
  moved the first-run dashboard away from the standard title bar plus rounded
  card layout. The advisory comparison improved from 58.50% mismatch / 76.91
  meanDelta to 54.05% mismatch / 59.13 meanDelta, while remaining above
  threshold pending deterministic text rendering, bottom dock/app-shell, and
  journey-step rhythm alignment.

### 2.5.413

- Added the production Explore Discovery cover-story header and aligned the
  `member_event_discovery` capture fixture to the Claude Bandra/Khar pub-quiz
  reference scenario. The advisory comparison improved from 61.62% mismatch /
  90.26 meanDelta to 41.87% mismatch / 36.74 meanDelta, while remaining above
  threshold pending feed section decomposition, generated title treatment, map
  interleave, status chrome, and bottom dock alignment.

### 2.5.412

- Added the production paper ticket shell for Event Success Companion
  pre-arrival and self-check-in moments. The default-live-guide advisory
  comparison improved from 75.47% mismatch / 117.85 meanDelta to 22.94%
  mismatch / 33.16 meanDelta, while remaining above threshold pending
  activity palette/content fixture alignment and stage-specific references.

### 2.5.411

- Added the paper `CatchCelebrationScreen` state to the core Widgetbook
  celebration use case so the Claude-style confirmation surface can be reviewed
  alongside the existing immersive celebration state.

### 2.5.410

- Added a paper `CatchCelebrationScreen` appearance and migrated Host Create
  Event success to it, matching the Claude Celebration component structure more
  closely without changing the existing immersive celebration default. The
  `host_create_success_manage` advisory baseline remains above threshold but
  improved from 87.23% to 32.49% mismatch, with Manage/Back actions now visible
  in the first viewport.

### 2.5.409

- Refreshed advisory pixel baselines for 18 registered non-host references and
  wrote the current comparison numbers into `design/reference_screens/manifest.json`.
  Within-threshold non-host baselines are Profile Self edit tab, Auth Phone
  Entry, and Filters Preferences; the remaining compared non-host references
  stay above advisory threshold and should drive the next visual-edit batches.

### 2.5.408

- Refreshed the host reference advisory batch for 17 registered host
  references and wrote the current comparison numbers into
  `design/reference_screens/manifest.json`. Within-threshold host baselines are
  Host Home events list, Host Create Event schedule/guide, and Host Create
  Club basics; the remaining above-threshold host baselines now have explicit
  mismatch, meanDelta, maxDelta, and masked-pixel receipts in the manifest.

### 2.5.407

- Ran advisory pixel baselines for the existing Host Inbox and Host Chat
  references. At that time Host Inbox still needed attendee-query row-density
  and header-treatment visual work; the later 2.5.424 pass supersedes that
  baseline with the broadcast-card lead-in metric. Host Chat is
  within threshold against `host_chat_inquiry` (`12.71%` mismatch, meanDelta
  `5.28`), with dedicated keyboard/safety/mutation/accessibility/theme
  references still pending.

### 2.5.406

- Exported and manifest-registered the Host Create Event success/manage design
  reference, corrected the deterministic capture fixture to represent the open
  success state instead of invite-code success, and recorded the advisory
  baseline as above threshold at 87.23% mismatch and meanDelta 149.27. The
  gap is now explicit: Flutter uses the dark celebration surface and pushes
  Manage/Back actions below the first viewport while the Claude reference is a
  light, action-forward success screen.

### 2.5.405

- Exported and manifest-registered the Host Event Manage full/waitlist apron
  design reference, adding masks for fixture-specific counts while leaving the
  full-capacity apron visible for advisory comparison. Baseline comparison
  against `host_manage_full_waitlist_apron` is above threshold at 25.37%
  mismatch and meanDelta 45.40.

### 2.5.404

- Routed Host Settings and Host Profile create/save success feedback through
  `showCatchSnackBar`, clearing the screen-contract hygiene advisory to 0
  files and 0 raw Material/control findings.

### 2.5.403

- Routed Host Event Manage cancel/delete and named invite-link copy/disable
  feedback through `showCatchSnackBar`, replaced the New invite link
  `AlertDialog` with shared `CatchFormDialog`, and reduced the
  screen-contract hygiene advisory to 1 file and 3 raw Material/control
  findings.

### 2.5.402

- Routed Event Detail booking/cancel, saved-event toggle, and calendar-open
  fallback feedback through `showCatchSnackBar`, reducing the screen-contract
  hygiene advisory to 2 files and 9 raw Material/control findings.

### 2.5.401

- Replaced Event Success companion live-card raw opt-in switches with
  `CatchToggle` and routed copied cue/opener feedback through
  `showCatchSnackBar`, reducing the screen-contract hygiene advisory to 3 files
  and 14 raw Material/control findings.

### 2.5.400

- Routed Host Create/Edit Club draft restore/save feedback and Host Edit Event
  missing-location/save feedback through `showCatchSnackBar`, reducing the
  screen-contract hygiene advisory to 4 files and 16 raw Material/control
  findings.

### 2.5.399

- Routed Public Profile report/block success, Settings unblock success,
  Onboarding Photos upload failure, and Payment History help feedback through
  `showCatchSnackBar`, reducing the screen-contract hygiene advisory to 6 files
  and 20 raw Material/control findings.

### 2.5.398

- Routed Host Create Event save-draft success feedback through
  `showCatchSnackBar`, so draft saved/updated messages share the same tokenized
  transient feedback primitive as other host flows. The unsaved-changes Save
  draft path now has focused widget-test coverage.

### 2.5.397

- Added `showCatchSnackBar` for shared tokenized transient success/validation
  feedback and routed Host Chat report success, empty Share card feedback, and
  share-card sheet export failures through it. `showCatchErrorSnackBar` now
  composes the same helper for error snackbars.

### 2.5.396

- Added `HostChatActionIntent` so `HostChatScreenState` owns top-bar menu
  dispatch policy for Share card, Report, and Block. `_ChatContent` now
  executes typed intents instead of re-deriving target ids and disabled/no-op
  action behavior inline.

### 2.5.395

- Added `ChatThreadLookupState` as the provider-free lookup-key seam for shared
  chat threads. `_ChatContent` now asks it for host-inquiry club, host profile,
  public-profile, event, and Suvbot lookup decisions before performing the
  Riverpod watches.

### 2.5.394

- Added `ChatReadMarkerState` as the provider-free read-marker decision seam
  for `ChatScreen`. `_ChatContent` now delegates duplicate/forced/incoming
  latest-message mark-read policy to it before executing the
  `ConversationReadMarker` side effect.

### 2.5.393

- Added disabled overflow-action support to `CatchTopBar.identity` and wired Host Chat
  report/block pending state through `HostChatScreenState`. `_ChatMutationListeners`
  now uses the shared multi-listener boundary with chat error context, and
  focused tests cover report/block failure feedback.

### 2.5.392

- Added `HostChatRetryIntent` / `HostChatRouteError` to `HostChatScreenState`.
  Host Chat match-stream failures now render the shared branded chat error
  state with a typed reload target, while message-list and Suvbot-control
  errors expose typed retry intents before `_ChatContent` invalidates the
  corresponding providers.

### 2.5.391

- Added `ChatsListRetryIntent` to the chat list display-state adapter. Host
  Inbox match-stream failures now carry a typed reload target before
  `ChatsList` invalidates `chatsListViewModelProvider`, and
  `collapseMatchesByOtherUser` has host-inquiry grouping proof for the
  club-plus-attendee duplicate policy.

### 2.5.390

- Added `HostClubDetailRetryIntent` to the Host Club Detail route adapter.
  `HostClubDetailError` now carries a typed retry target, and
  `ClubDetailScreen` executes that intent through `_retryHostClubDetail`
  instead of hardcoding provider invalidation directly in the error-render
  branch.

### 2.5.389

- Added `HostHomeRouteState` and `HostHomeEventsSectionState` so Host Home
  auth/loading/error/empty/loaded route selection and selected-club event
  loading/error/empty/populated selection are explicit state seams.
  `HostEventsClubCard` is now a narrow provider adapter, while
  `HostEventsClubSection` renders provider-free metadata, event rows, Add
  event, empty copy, and typed retry/create/manage callbacks.

### 2.5.388

- Tightened the Host Clubs Organizer overview against the Claude reference:
  compacted the header to logo/meta/formats, moved the payout CTA inside the
  callout-shaped surface, and changed the metric grid to two joined stat rows.
  The canonical `host_clubs_management` reference comparison now runs within
  advisory threshold after mask calibration.

### 2.5.387

- Added the Host Clubs Organizer overview as the default Clubs tab surface.
  `_HostClubOrganizerOverview` composes the Claude Organizer structure from
  the selected-club header, payout callout, metric grid, public page row, team
  summary, trend strip, and manage rows, while Edit / Insights / Preview remain
  reachable through existing typed tab callbacks.

### 2.5.386

- Moved Host Clubs public-preview routing into typed
  `HostClubPreviewCallback` owned by `_HostClubsScaffold`. The edit-tab public
  profile row and preview-tab action now receive callbacks instead of calling
  the router directly, with widget-test coverage for the preview route.

### 2.5.385

- Added `HostClubInsightsState` for Host Clubs analytics query ownership. The
  Insights tab now derives `hostAnalyticsProvider` keys and retry invalidation
  targets from this state, clears event scope on club switches, and has a
  focused state test for range, granularity, custom dates, and event scope.

### 2.5.384

- Added public `HostTeamHostActionDialog` and typed
  `HostTeamHostActionConfirmation` copy/actions for Host Clubs remove-host and
  transfer-ownership confirmations. `HostTeamManagementSection` now uses one
  shared confirm/mutate path, and Widgetbook covers both confirmation dialogs.

### 2.5.383

- Promoted the Host Clubs add-host sheet to public `HostTeamAddHostSheet`.
  `HostTeamManagementSection` now opens that source-backed sheet, and
  Widgetbook covers ready, add pending, add error, and add offline states for
  the sheet itself.

### 2.5.382

- Promoted Host Home section helpers to public source components:
  `HostOperationsTopBar`, `HostEventsClubCard`, `HostMetaRow`, and
  `HostEventRow`. Widgetbook now has section-level states for the host
  operations top bar, club metadata row, event row, and selected-club event
  section, including loading, error, offline, empty, and cancelled-filtered
  event-list states.

### 2.5.381

- Made `CatchTopBar.identity` router/provider-free. Host Chat now passes an identity tap
  callback plus typed `ChatThreadAction` menu values, while `_ChatContent`
  owns profile navigation, share-card presentation, and report/block mutation
  dispatch. Focused chat tests cover typed top-bar callbacks and host
  report/block success behavior.

### 2.5.380

- Moved Host Inbox chat-row route selection out of `ChatConversationsList`.
  `ChatsListScreen` now owns the typed host/consumer chat callback and passes
  it through `ChatsList` / `ChatsListBody`; `ChatConversationsList` only
  renders provider/router-free rows.

### 2.5.379

- Added `HostHomeEventRowsState` for Host Home event-row derivation. The
  selected-club scaffold now owns Add event and Manage event route callbacks,
  `HostEventsClubCard` receives typed callbacks, and `HostEventRow` renders
  provider/router-free row data.

### 2.5.378

- Moved Host Event Manage host-action side effects out of
  `_HostEventActionsCard`: `HostEventManageScreen` now owns edit routing,
  cancel/delete confirmation dialogs, mutation state, success snackbars, and
  delete return behavior while the action card renders provider-free callbacks,
  loading state, and error banners.

### 2.5.377

- Moved Club Detail route side effects out of `ClubDetailBody`: the shared body
  now receives typed callbacks for schedule taps, host profile/message actions,
  contact links, and share. Host Club Detail remains public-preview-only for
  the current contract; management controls stay in Host Home and Host Clubs.

### 2.5.376

- Added `HostClubEditController` and `HostPaymentAccountController` as Host
  Clubs action seams. Host Clubs Widgetbook and captures now cover expanded
  inline editor pending/error/offline, payout setup/refresh
  pending/error/offline, and host-team mutation pending/error/offline states.

### 2.5.375

- Added Host Clubs signed-out, insights loading/error/offline, and payout
  provider loading/ready/restricted/error/offline Widgetbook and capture
  coverage. `HostPaymentAccountCard` now uses the shared async/error boundary
  for provider states while payout action mutation/offline remains a separate
  controller-seam follow-up.

### 2.5.374

- Moved Host Manage report CSV export into `HostEventManageController`
  mutations and added report export pending/error Widgetbook and capture
  coverage.

### 2.5.373

- Added Host Manage private-link share pending/error Widgetbook and capture
  coverage for the invite-only private access card.

### 2.5.372

- Added Host Manage cancel/delete action pending/error Widgetbook and capture
  coverage. Delete uses an unused-event fixture with empty participations so
  the real activity-based delete suppression rule stays intact.

### 2.5.371

- Added Host Manage edit-event action Widgetbook/capture coverage with a tall
  route capture that reaches the Host actions card.

### 2.5.370

- Added Host Manage initial-event fallback Widgetbook/capture coverage so route
  loading with an initial event extra renders loaded UI instead of a cold
  skeleton.

### 2.5.369

- Added Host Manage filtered roster empty Widgetbook/capture coverage through
  an initial participant search seam on Host Manage and Host participant panels.

### 2.5.368

- Added `HostEventManageController` as the Host Manage action seam for private
  invite-link create/copy/disable/share work plus cancel/delete writes and
  invalidation. Host Manage Widgetbook and captures now cover invite-link
  mutation pending/error states.

### 2.5.367

- Added Host Event Manage attendance mutation pending/error Widgetbook and
  capture coverage. The Live console now mirrors embedded roster mutation
  failures at console level so hosts see attendance failures without scrolling
  into the roster.

### 2.5.366

- Added Host Event Manage full/waitlist apron and live Event Success
  unavailable Widgetbook/capture coverage. The route preview scope can now
  swap deterministic club/event fixtures and Event Success plan state while
  preserving the normal host manage provider graph.

### 2.5.365

- Added Host Event Manage section-state Widgetbook/capture coverage for
  attendance loading/empty, attendee-profile loading/error, private-access
  loading, and invite-link loading/error/empty. Private-access and invite-link
  captures use the tall review device so the target section is visible.

### 2.5.364

- Added Host Event Manage route loading/error/offline/not-found, unauthorized,
  attendance error, private-access error, cancelled-event, text-scale,
  reduced-motion, and light/dark Widgetbook/capture coverage. The Host Manage
  header now collapses supplemental title copy at high text scale and gives the
  section picker a taller slot.

### 2.5.363

- Added Host Create Event route loading/error/offline/not-found plus text-scale,
  reduced-motion, and light/dark Widgetbook/capture coverage. Route club
  loading now uses a content-shaped create-event form skeleton, and the capture
  provider overrides are shared across baseline wizard captures.

### 2.5.362

- Added Host Edit Club validation, media replacement, and submit pending/error
  preview/capture coverage to the existing route/mode use case.

### 2.5.361

- Added Host Create Club validation and picked-media preview/capture coverage.
  `CreateClubScreen` now exposes default-off deterministic hooks for form
  autovalidation and initially picked club/profile media.

### 2.5.360

- Added Host Create Club mutation preview and capture coverage for save-draft
  pending/error, submit pending/error, and offline submit failure using the
  route's static Riverpod mutations.

### 2.5.359

- Added Host Edit Club route-offline coverage to the existing Widgetbook
  route/mode use case and deterministic capture registry so generic fetch
  errors and retryable connection failures are reviewed separately.

### 2.5.358

- Added Host Home hosted-event offline coverage to the existing Widgetbook
  route-state use case. `_HostShellScope` now accepts preview-only
  `clubEventStreams` so nested event-provider loading/error/offline states can
  be reviewed while the host club chrome stays loaded.

### 2.5.357

- Added Host Edit Event offline, validation, and selected-location review
  states to the existing Widgetbook route/form use case.
  `EditHostedEventScreen` now exposes a default-disabled
  `formAutovalidateMode` so deterministic captures can show validation errors
  without changing production form timing.

### 2.5.356

- Made `HostProfileEditorSheet` a public source-backed host component so
  Host Settings captures and future previews can render the real account
  editor sheet instead of duplicating a private route-local implementation.
  `HostSettingsProfileSection` now accepts `creatingProfile` and shows a
  pending row affordance while `HostProfileController.ensureProfileMutation`
  is running. Host Account sign-out failures now use the shared
  `CatchMutationErrorListener` boundary so sign-out error/offline captures can
  exercise the real mutation state.

### 2.5.355

- Added `HostProfileController` as the shared host profile action controller.
  Host Account profile creation, Host Account editor-sheet saves, and direct
  Host Profile create/save now run through `ensureProfileMutation` and
  `saveProfileMutation` instead of route-local repository writes. The routes
  still own form controller sync, navigation, and success snackbars.

### 2.5.354

- Added `HostSettingsState`, `HostSettingsProfileState`,
  `HostSettingsClubsState`, and `HostProfileEditState` as host display-state
  adapters for Account and direct Host Profile routes. Host Settings profile
  and club sections now receive typed display states instead of raw profile
  data or ad hoc loading/error props, and Widgetbook uses those same state
  classes for loading, error, missing, fallback, empty, and content previews.
- `HostProfileScreen` now renders through `HostProfileEditState` before
  composing `HostProfileForm` and `HostProfileMissingState`; the follow-up
  `HostProfileController` pass moves create/save mutations out of the routes.

### 2.5.353

- Completed the broad app-wide loading audit for `GOAL-DS-001`. Safety blocked
  accounts, User Analytics, Launch Access, Payment Confirmation, and
  profile-photo editor preview loading now use content-shaped skeletons instead
  of route/body spinners or generic async screen loaders.
- Documented the remaining direct loader usages as bounded inline
  mutation/media/search/action progress, startup loading, or core async
  primitive defaults rather than full-content loading states.

### 2.5.352

- Added shared host loading skeleton helpers in
  `lib/hosts/presentation/widgets/host_loading_skeletons.dart` and replaced
  host route, profile/settings, hosted-event list, analytics, attendance, and
  draft-picker inline loading spinners with host-operations-shaped skeletons.
- Replaced remaining targeted Dashboard inline progress and Event Success
  manual-QA loading spinners with compact skeleton placeholders.
- Tightened `CatchButton` height ownership so footer buttons keep the token
  height in unconstrained bottom bars instead of consuming the screen body.

### 2.5.351

- Replaced Dashboard route-level loading with a dashboard-shaped skeleton shell
  that preserves the home header silhouette, notification affordance, focus
  card, stride card, quick actions, and recommendation rows.
- Replaced Event Success host-section and companion route loading spinners with
  tab-aware setup/live/report skeletons and companion stage/action/peer
  skeletons. The dev/staging event-success preview route now keeps its preview
  app bar and renders hero, notes, setup, live, companion, and report skeleton
  sections while event data loads.

### 2.5.350

- Replaced Club Detail no-fallback loading with `ClubDetailLoadingBody`,
  preserving credible `initialClub` fallback rendering while using hero,
  stats, host, about, tag, and upcoming-section skeletons when no fallback data
  exists.
- Added `EventMapLoadingBody` and `EventLocationMapLoadingBody` so map loading
  states use a map-shaped silhouette; the location-map route now preserves
  floating map controls and a bottom directions-card placeholder while loading.

### 2.5.349

- Replaced remaining swipes consumer loading spinners for Filters, Catches
  event deck, and Event Recap with content-shaped skeletons. Filters now shows
  age-slider, gender-chip, and apply-dock placeholders; the Catches deck reuses
  `ProfileSurfaceSkeleton` with overlay/pass affordance placeholders; Event
  Recap now shows recap hero, attendee-grid, and CTA placeholders.

### 2.5.348

- Replaced Calendar route-level and club-name enrichment loading spinners with
  content-shaped skeletons. Route loading now preserves the top bar, pinned
  date-header silhouette, stats strip, and agenda rows; club-name enrichment
  loading keeps resolved header/stats chrome visible and skeletonizes only the
  agenda rows through `EventAgendaSliverSkeleton`.

### 2.5.347

- Replaced Profile and Public Profile data-loading spinners with
  content-shaped skeletons. `ProfileScreen` keeps its `TabBarView` active while
  loading, showing an Edit-tab skeleton by default and a preview-surface
  skeleton after tab selection. `PublicProfileScreen` now shows the shared
  `ProfileSurfaceSkeleton` when no credible `initialProfile` exists, while an
  initial profile still renders the real profile body ahead of stream data.
- Added `ProfileSurfaceSkeleton` and `ProfileTabSkeletonSliverBody` as reusable
  profile-shaped loading surfaces, reusing the loaded profile hero aspect
  ratio, photo-grid geometry, `CatchSection` rhythm, and profile info-row
  spacing.

### 2.5.346

- Replaced Matches/Chat generic loading placeholders with content-shaped
  skeletons. `ChatsList` now renders a section label plus contiguous inbox-row
  skeletons, and `ChatMessageList` now renders date and alternating message
  bubble skeletons through `CatchAsyncValueView`.
- Replaced the Event Detail route's bare loading spinner with a token-driven
  skeleton composed from the same detail hero, ticket-stub, section, map, social
  row, and bottom CTA rhythm as the loaded screen. Credible `initialEvent`
  fallback data still renders the real `EventDetailBody` ahead of any skeleton.
- Extended `CatchSkeleton.box` with an optional `borderColor` so bordered
  placeholders can stay in the shared primitive instead of feature-local
  decorated shells.

### 2.5.345

- Codified the async UI policy in `ASYNC-UI-001`: presentation widgets use
  shared async boundaries or typed display-state adapters, view-models may use
  `AsyncValue.when` for non-widget display state, empty states remain in data
  callbacks, credible fallback data renders ahead of blocking skeletons, and
  data-load errors use retryable Catch error primitives unless retry is
  impossible or unsafe.
- Added `CatchSkeleton.box` for fixed-size rounded skeleton pieces such as
  icon blocks, badges, and pills without creating feature-local decorated
  containers.
- Replaced the first batch of generic async loading placeholders with
  content-shaped skeletons: Payment History now loads as payment rows,
  Review History as context labels plus review cards, Activity as notification
  rows through `ActivitySectionSkeleton`, and Saved Events as agenda/date-rail
  ticket cards through the new `EventAgendaSliverSkeleton`.

### 2.5.344

- Completed the host async UI consolidation pass. Host Operations and Host
  Clubs route gates, Host Account profile/club sections, the Host Profile
  editor sheet, hosted-club event lists, Host Event Manage route state, private
  access/invite-link sections, Host analytics, and
  `HostEventParticipantsPanel` attendance/profile provider waves now render
  through `CatchAsyncValueView` with branded loading/error boundaries. Hosted
  event stream failures now show retryable event errors instead of falling
  through to empty-event copy.

### 2.5.343

- Extended `CatchAsyncValueView` and `CatchAsyncValueSliver` with
  context-aware builders, explicit loading/error builder hooks, and Riverpod
  skip-flag passthrough while preserving the legacy one-argument `data`,
  `loading`, and `error` callbacks.
- Added `CatchAsyncScreenLoading` and `CatchAsyncSliverLoading` as shared
  skeleton loading placement helpers, with Widgetbook coverage under
  `[Core catalog]/Loading`.
- Migrated Payment History, Review History, Activity, Payment Confirmation,
  Saved Events, Event Map, Event Location Map, host create/edit club/event route
  gates, and `WhoIsGoing` loading/error provider waves onto the shared async
  primitive; Settings now uses `CatchScreenBody` for its route-level gutter
  instead of local `EdgeInsets.fromLTRB(...)`.

### 2.5.342

- Promoted `CatchSection`, `CatchJourneySteps`, `CatchPrivacyBadge`,
  `CatchScreenBody`, and `CatchSectionStack` into formal component contracts.
  Widgetbook now exposes matching contract-state previews for those composition
  primitives under `[Core primitives]/Inputs`, `[Core primitives]/Status`, and
  `[Core primitives]/Sections`.
- Added standalone Widgetbook review entries for dashboard primitives
  (`QuickActions`, `DashboardStrideSection`, `RecommendCard`), messaging
  primitives (`CatchTopBar.identity`, `ChatEventContextHeader`, `MessageBubble`,
  `ChatInputBar`, `CatchPersonRow`), and `BookingConflictSheet`.

### 2.5.341

- Promoted the host roster primitives into the formal component contract
  registry: `catch.roster_tiles`, `catch.roster_row`, and
  `catch.roster_table`. Widgetbook now exposes matching contract-state previews
  for those three contracts under `[Core primitives]/Host operations`.

### 2.5.340

- Added standalone Widgetbook core-catalog entries for source-backed host roster
  primitives: `CatchRosterTiles`, `CatchRosterRow`, and `CatchRosterTable`.
  These now appear under `[Core catalog]/Host operations` for selected filter
  tiles, row action-cell variants, populated tables, and empty roster states.

### 2.5.339

- Added standalone Widgetbook core-catalog entries for source-backed Claude
  primitive aliases: `CatchSection`, `CatchJourneySteps`,
  `CatchPrivacyBadge`, `CatchScreenBody`, and `CatchSectionStack`. These now
  appear as generated Widgetbook components instead of only incidental children
  inside broader examples.

### 2.5.338

- Added `FoundationBrandTokens` under `[Foundation tokens]/Core` to represent
  the Claude wordmark specimen. The brand specimen renders the Archivo
  typographic `Catch` wordmark in plain, dotted, and dark treatments; the
  Widgetbook contract-ref gate now requires eight foundation specimens.

### 2.5.337

- Promoted foundation-token specimen presence to the Widgetbook contract-ref
  gate. `check_widgetbook_contract_refs.mjs` now requires all seven
  `[Foundation tokens]/Core` review components to remain present in generated
  Widgetbook output.

### 2.5.336

- Added two more Widgetbook foundation-token specimens under
  `[Foundation tokens]/Core`: `FoundationStrokeMotionTokens` and
  `FoundationDataPhotoTokens`. These review live `CatchStroke`, `CatchMotion`,
  `CatchMetricStrip`, `CatchGrade`, and `CatchPhotoGradeColors` behavior for
  stroke widths, motion durations/curves, data-pair typography, and
  display-time photo grading without adding a second token source.

### 2.5.335

- Added dedicated Widgetbook foundation-token specimens under
  `[Foundation tokens]/Core`: `FoundationColorTokens`,
  `FoundationSpacingTokens`, `FoundationShapeTokens`,
  `FoundationTypographyTokens`, and `FoundationIconMediaTokens`. These review
  live runtime token values for color roles, activity pigments/glyphs,
  spacing/gaps/insets, radius, elevation, opacity, typography roles, icon scale,
  and aspect ratios without creating a second token source.

### 2.5.334

- Extracted Host Settings account sections into provider-free source
  components. `HostAccountScreen` resolves uid/profile/club provider waves into
  `HostSettingsState`, while profile create/save mutations go through
  `HostProfileController` and navigation/sign-out side effects remain
  route-owned. It composes `HostSettingsProfileSection`,
  `HostSettingsClubsSection`, `HostSettingsTabRail`, and shared
  `HostSettingsSection` rows. Widgetbook now exposes
  `HostAccountScreen/Route states`,
  `HostSettingsProfileSection/Profile summary states`,
  `HostSettingsClubsSection/Clubs states`, and `HostSettingsTabRail/Tab states`
  under the P2 Host Settings surface.

### 2.5.333

- Extracted the direct Host Profile editor into source-backed provider-free
  sections. `HostProfileScreen` resolves uid/profile provider waves through
  `HostProfileEditState`, while create/save mutations go through
  `HostProfileController` and controller sync/snackbar side effects remain
  route-owned. It composes `HostProfileForm` and
  `HostProfileMissingState`; the Host Settings editor sheet reuses
  `HostProfileFields`. Widgetbook now exposes
  `HostProfileScreen/Route states`, `HostProfileForm/Form states`,
  `HostProfileFields/Field states`, and
  `HostProfileMissingState/Missing states` under the P2 Host Profile surface.

### 2.5.332

- Extracted `FiltersContent`, `FiltersSection`, `FiltersValue`, and
  `filtersAgeRangeValues` from `FiltersScreen` so `screen.filters.preferences`
  keeps provider, reset, mutation, and navigation ownership at the route edge
  while Widgetbook can review provider-free filter body states. Added
  `FiltersScreen/Route states` and `FiltersContent/Content states` under the
  P2 consumer Widgetbook surface for loading, profile error/offline, missing
  profile, default preferences, dirty edits, reset-restored content, save
  pending, text scale, and reduced motion.

### 2.5.331

- Promoted the Catches hub/deck section widgets to public provider-free
  components and added source-backed Widgetbook section coverage for
  `CatchesHubContent`, `CatchesHubHeader`, `CatchesIntroCard`,
  `AttendedEventTile`, `CatchesHubEmptyState`, `CatchesProfileReview`,
  `ProfileSurface`, `CatchesTopOverlay`, `CatchesBottomScrim`,
  `CatchesPassButton`, `ProfileReactionControls`, and `SwipeEmptyState`.
  `screen.catches.hub` and `screen.catches.event` now link their composition
  sections to these previews while route-state coverage remains intact.

### 2.5.330

- Synced Event Success Companion Widgetbook coverage with the captured screen
  contract states by adding explicit default live-guide, self-check-in, and
  offline plan-error review cards. `screen.event_success.companion` now links
  those captured states back to `EventSuccessCompanionScreen/Screen states` or
  `EventSuccessCompanionRouteScreen/Route states`.

### 2.5.329

- `CatchTopBar` compact headers now collapse visual subtitle/stacked title
  ornamentation at large text scale while preserving the title semantics.
  `HostProfileScreen` follows the same rule for its custom compact title so
  design-phone accessibility captures do not overflow the fixed app-bar frame.

### 2.5.328

- Added `CatchesHubScreenState` as the route adapter for
  `screen.catches.hub`. `SwipeHubScreen` now keeps provider watches and route
  pushes at the route edge, while `CatchesHubScreenState` owns uid/event
  provider waves, active catch-window filtering, injected countdown labels, and
  catch/recap route intents. `AttendedEventTile` now renders
  `CatchesHubEventRow` display data with callbacks supplied by the parent.

### 2.5.327

- Added `NotificationsListState` as the route adapter for
  `screen.notifications.list`. `ActivityScreen` now keeps provider watches,
  mark-all-read mutation orchestration, and row navigation side effects at the
  route edge while composing `ActivitySection.fromState` from provider-free
  grouped row display data.

### 2.5.326

- Updated the Notifications route mutation/error contract:
  `ActivityScreen` now drives the top-bar `Mark all read` action through
  `ActivityController.markAllReadMutation` pending/error state, and
  notification row navigation failures surface branded snackbar feedback
  instead of failing silently.

### 2.5.323

- Added deterministic Reviews History route captures for signed-out, profile
  loading/error, reviews loading/error, empty, populated rows, missing
  event-context fallback, text-scale 2.0, reduced-motion, and paired light/dark
  review. The capture fixture now uses `watchEventsByIdsProvider` to match the
  route adapter instead of per-event provider overrides.

### 2.5.322

- Added the Reviews History route adapter seam: `ReviewsHistoryState` now owns
  access/provider waves, review rows, event-context fallback labels, edit
  availability, and retry targets. `ReviewsHistoryScreen` keeps provider reads
  at the route edge, then composes provider-free body/list/row widgets with
  typed edit callbacks.
- Added deterministic Payment History route captures for uid loading/error,
  signed-out, payment loading/error, empty, populated mixed-status rows,
  missing event-title fallback, text-scale 2.0, reduced-motion, and paired
  light/dark review.

### 2.5.321

- Added the Payment History route adapter seam:
  `paymentHistoryViewModelProvider` now joins payment records with the batched
  `watchEventsByIdsProvider` lookup, feeds `PaymentHistoryRow` display data to
  provider-free payment tiles, and preserves the `Event booking` fallback for
  missing event context.
- Added deterministic Notifications route captures for uid loading,
  signed-out, activity loading/error/empty, text-scale 2.0, reduced-motion,
  and paired light/dark review. `CatchTopBar` now constrains trailing text
  actions so labels like "Mark all read" ellipsize at compact phone width and
  large text scale instead of overflowing the app bar.

### 2.5.320

- Updated `DashboardStrideSection` to receive typed
  `DashboardStrideSectionActions` and display-only
  `DashboardStrideActionState`. The visual section no longer imports Riverpod,
  weekly activity providers, or `DashboardStrideActions`; `DashboardFullSliverBody`
  owns retry invalidation, permission/install side effects, weekly activity
  refresh, denied-permission snackbar, and connecting/installing busy flags.

### 2.5.319

- Updated `EventFocusRail` to render from typed `EventFocusActions` and
  `EventFocusCheckInState` instead of importing Dashboard routes, Riverpod
  providers, external links, calendar launchers, self-check-in controllers,
  event-success launchers, or review sheets directly. `DashboardFullSliverBody`
  now owns those product effects and maps the self-check-in mutation into
  display-only pending/error state for the rail.

### 2.5.318

- Updated `QuickActions` to render typed `DashboardQuickAction` models instead
  of owning Dashboard route pushes internally. `DashboardFullSliverBody` now
  supplies Calendar and Saved Events callbacks from the composing layer, keeping
  the quick-action grid provider-free and easier to preview with disabled or
  future action states.

### 2.5.317

- Updated the Home followed-clubs rail path to use the batched
  `watchClubsByIdsProvider(ClubsByIdQuery(...))` seam instead of one
  `watchClubProvider` read per joined-club tile. The populated Dashboard body
  owns the optional loading skeleton and `ClubAvatarRail` composition.

### 2.5.316

- Added `dashboardHomeScreenStateProvider` and `DashboardHomeScreenState` as the
  Dashboard Home route adapter. `DashboardScreen` now switches over
  loading/error/empty/full route state, while the adapter owns user,
  membership, booked-event, typed retry-target, header-copy, followed-club id,
  and empty/full selection. Dashboard header copy now uses the injected
  `dashboardNowProvider` in route and legacy `DashboardFull` paths.

### 2.5.315

- Added deterministic Dashboard route captures for
  `dashboard_home_self_check_in_pending` and
  `dashboard_home_self_check_in_error`. `EventFocusRail` now surfaces
  self-check-in mutation failures through `CatchMutationErrorBanner` with
  `AppErrorContext.dashboard` instead of only consuming pending state.

### 2.5.314

- Added deterministic Dashboard route captures for `dashboard_home_self_check_in`
  and `dashboard_home_after_event_focus`. `DashboardFullViewModel` now reads a
  Dashboard-local `dashboardNowProvider` so capture fixtures can pin
  self-check-in and after-event timing without relying on wall-clock dates.

### 2.5.313

- Added the `dashboard_home_offline` route capture. Dashboard route-level
  `AppException` failures now render through `CatchErrorScaffold.fromError`
  with `AppErrorContext.dashboard`, so typed offline failures use the shared
  Connection issue copy/icon/retry behavior while generic provider failures
  keep the existing Dashboard fallback messages.

### 2.5.312

- Added deterministic Profile/Public Profile route and section captures for
  self-profile loading/error/offline/unavailable, edit tab, preview tab, upload
  pending, text scale 2.0, reduced motion, public-profile loading,
  initial-profile fallback, load error, offline, unavailable, own profile,
  pending overlay, report sheet, block confirmation, public text scale 2.0, and
  public reduced motion. Profile-surface capture fixtures use no-network photo
  variants so widget tests do not depend on remote image fetches.
- Added narrow provider-free seams for profile design review:
  `ProfileScreen.initialTabIndex` lets captures open the Preview route
  deterministically, `PublicProfileBody` exposes the public-profile body and
  pending overlay, and `PublicProfileReportSheet` gives the report reason sheet
  a reusable section widget while production behavior remains unchanged.

### 2.5.311

- Added deterministic Matches List and Match Chat route captures for list
  loading/error/offline, no matches, search open/empty, duplicate collapse,
  match celebration, text scale 2.0, reduced motion, chat message
  loading/error/offline, empty thread, event-context fallback, missing and
  blocked chat, image thread, Suvbot controls/error, share-card sheet,
  composer states, chat text scale 2.0, chat reduced motion, and host unread
  empty. The capture fixtures reuse the shared Matches/Chat design-review
  repositories and seed chat search state without simulator setup.
- Hardened fixed-format review surfaces found by the capture pass: browse
  header title/search chrome now keeps its pinned header text scale within the
  fixed sliver height contract, and chat share cards now cap visible quote
  bubbles to three messages so the 4:5 share-card artifact cannot overflow
  with normal chat copy.

### 2.5.310

- Added deterministic Catches hub and event-deck route captures for uid
  loading/error, signed-out hidden, attended-events loading/error, empty hub,
  hub text scale 2.0, hub reduced motion, deck queue loading/error/offline,
  empty queue, missing event, sign-in required, event in progress, did not
  attend, closed window, deck text scale 2.0, and deck reduced motion.
  `SwipeHubScreen`, `SwipeScreen`, `AttendedEventTile`, and
  `buildSwipeEmptyContent` now accept an optional pinned `now` so Catches
  review states can be deterministic while production routes keep current-time
  behavior.

### 2.5.309

- Added deterministic Explore Discovery route captures for loading, source-club
  error, feed error, empty city, no-search, active search, active filters, text
  scale 2.0, reduced motion, map loading, and map error. The capture catalog
  now shares an Explore provider/state seeding helper so route captures can
  exercise search, filter, and map states without simulator setup.

### 2.5.308

- Added deterministic Dashboard Home route captures for booked-events loading,
  profile error, membership error, booked-events error, empty start,
  recommendations loading/error, text scale 2.0, and reduced motion. The
  Dashboard capture fixture now has a reusable provider override helper so
  Widgetbook-like route states share one fixture shape. `ClubAvatarRail` now
  lets the avatar rail use intrinsic item height, fixing the text-scale 2.0
  overflow in `ClubListTile` avatar chips.

### 2.5.307

- Added deterministic baseline Host Operations route captures for Host Home,
  Host Clubs, Host Club Detail, Host Event Manage setup/private access, Host
  Inbox, and Host Chat. The Host Event Manage fixture now keeps private access,
  named invite-link, roster, and waitlist data in the capture. The source
  widgets now avoid narrow-device overflow in the private-access loading row,
  invite-link header/rows, waitlist bulk offer action, event summary rows,
  Event Success target-attendee control, recommendation toggles, and full-width
  `CatchButton` labels.

### 2.5.306

- Added first-pass Host Operations Widgetbook route/state coverage under the
  `P1 product surfaces` category. `HostOperationsHomeScreen/Route states`,
  `HostClubsScreen/Route states`, `ClubDetailScreen/Public preview states`,
  `HostCreateEventRouteScreen/Route and wizard states`, and
  `HostEventManageRouteScreen/Route and section states` cover the first host
  loading/error/empty/access, role, text-scale, reduced-motion, and theme review
  states. `ChatsListScreen/Host inbox states` remains the host inbox preview,
  and `ChatScreen/Host chat states` now covers host inquiry identity, match
  loading/error/missing, message loading/error/offline, empty, event fallback,
  blocked, composer, text-scale, reduced-motion, and light/dark states. Shared
  Host Operations design-review fixtures now live under
  `lib/labs/design_fixtures`.

### 2.5.305

- Added first-pass Profile and Public Profile Widgetbook coverage under the
  `P1 product surfaces` category. `ProfileScreen/Self route states` covers
  profile loading/error/offline, unavailable, edit-tab, upload-pending,
  text-scale, reduced-motion, and dark-theme route states.
  `ProfileScreen/Self section states` covers the header/tab switcher, complete
  and incomplete edit tabs, photo-grid loading/delete-disabled, inline editor
  variants, preview tab, long content, and large-text review. `PublicProfileScreen/Route
  states` covers cold loading, initial-profile fallback, load/offline errors,
  unavailable, loaded viewer context, own-profile context, mutation overlay,
  text-scale, reduced-motion, and dark theme. `PublicProfileScreen/Safety
  action states` covers route overflow actions, report sheet, block dialog, and
  report/block mutation failures. Shared Profile design-review fixtures now
  live under `lib/labs/design_fixtures`.

### 2.5.304

- Added first-pass Matches List and Match Chat Widgetbook coverage under the
  `P1 product surfaces` category. `ChatsListScreen/Consumer route states`
  covers loading/error/offline, populated rows, new/unread/own-latest row
  treatment, search empty, no matches, match celebration, text-scale,
  reduced-motion, and addon-driven light/dark review. `ChatsListScreen/Host
  inbox states` covers attendee-query framing, host filters, loading, and
  unread-empty states. `ChatScreen/Route states` covers message
  loading/error/offline, empty/populated/image threads, missing and blocked
  chats, host inquiry identity, Suvbot states, share card sheet, composer
  variants, text-scale, reduced-motion, and addon-driven light/dark review.
  Shared Matches/chat design-review fixtures now live under
  `lib/labs/design_fixtures`.

### 2.5.305

- Added first-pass Catches Widgetbook coverage under the `P1 product surfaces`
  category. `SwipeHubScreen/Hub route states` covers uid loading/error,
  signed-out shell-hidden, attended-event loading/error/offline, empty hub,
  active catch windows, text-scale, reduced-motion, and addon-driven
  light/dark review. `SwipeScreen/Event deck route states` covers queue
  loading/error/offline, active profile deck, vibe-prioritized queue,
  empty/access branches, interactive mutation failure, text-scale,
  reduced-motion, and addon-driven light/dark review. Shared Catches
  design-review fixtures now live under `lib/labs/design_fixtures`.

### 2.5.304

- Added first-pass Event Success Companion Widgetbook coverage under the
  `P1 product surfaces` category. `EventSuccessCompanionRouteScreen/Route
  states` covers route loading, event error/not-found, sign-in required,
  profile/participation/plan provider failures, no booking, and missing plan
  states. `EventSuccessCompanionScreen/Screen states` covers First Hello,
  pre-arrival, questionnaire, live step context, social prompt, conversation
  cues, assignments, peer loading, opt-outs, rotation schedule, live reveal,
  wingman request, afterglow, feedback, text-scale, reduced-motion, and
  addon-driven light/dark review states. Shared Event Success companion
  design-review fixtures now live under `lib/labs/design_fixtures`.

### 2.5.301

- Added first-pass `DashboardScreen/Screen states` Widgetbook coverage under
  the `P1 product surfaces` category. The Dashboard preview renders the real
  route through provider overrides for profile loading/error, empty start,
  membership loading/error, booked-event loading/error, full dashboard,
  notification badge, activity permission/loading, recommendation
  loading/error, text-scale, reduced-motion, and addon-driven light/dark review
  states. Shared Dashboard design-review fixtures now live under
  `lib/labs/design_fixtures`.

### 2.5.300

- Added `SettingsScreen/Mutation states` to the P3 utility Widgetbook category
  so Settings now previews preference-save, delete-account, sign-out, and
  unblock mutation pending/error paths through the real Riverpod mutation
  listeners. Shared utility/account design-review fixtures now live under
  `lib/labs/design_fixtures`.

### 2.5.299

- Promoted the review edit sheet and payment receipt sheet into public,
  provider-free preview targets: `WriteReviewSheet` now backs the review
  write/edit Widgetbook states, and `PaymentReceiptSheet` now backs receipt and
  failed-signup help states. The P3 utility Widgetbook category also includes
  Settings destructive confirmation dialog states through `CatchConfirmDialog`.

### 2.5.298

- Added Widgetbook coverage for the P3 utility surfaces under the
  `P3 utility surfaces` category: Event Location Map route/map states,
  ActivityScreen/ActivitySection/NotificationRow states, Reviews History route
  states, Settings route states, and Payment History route states. Screen
  contracts and the state matrix now reference those preview ids; remaining
  P3 Widgetbook gaps are narrowed to interactive edit sheet, destructive
  dialog, mutation pending/error, receipt sheet, and help-action fixtures.

### 2.5.297

- Registered the remaining P3 utility routes as screen contracts:
  `EventLocationMapRouteScreen` as `screen.event.location_map`,
  `ActivityScreen` as `screen.notifications.list`, `ReviewsHistoryScreen` as
  `screen.reviews.history`, `SettingsScreen` as `screen.settings.account`, and
  `PaymentHistoryScreen` as `screen.payments.history`. The catalog now treats
  map, notifications, reviews, settings, and payment history as adapter and
  section-composition targets with follow-up Widgetbook, deterministic capture,
  and pixel-reference work.

### 2.5.296

- Registered the remaining P2 host routes as screen contracts:
  `HostCreateClubScreen` as `screen.host.club.create`,
  `HostEditClubRouteScreen` as `screen.host.club.edit`,
  `EditHostedEventRouteScreen` as `screen.host.event.edit`,
  `HostAccountScreen` as `screen.host.settings`, and `HostProfileScreen` as
  `screen.host.profile`. The catalog now treats the shared create/edit club
  form, host edit-event form, and professional host profile/settings surfaces as
  adapter/composition targets with follow-up Widgetbook and capture states.
- Kept public Club Detail empty schedule copy neutral for host app viewers:
  `ClubScheduleSection` still marks host-owned event rows with hosted treatment,
  but operational publish prompts remain in Host Operations rather than leaking
  into the public club profile shell.

### 2.5.295

- Registered the remaining P2 consumer routes as screen contracts:
  `CalendarScreen` as `screen.calendar.home`, `SavedEventsScreen` as
  `screen.saved_events.list`, `FiltersScreen` as
  `screen.filters.preferences`, and `EventRecapScreen` as
  `screen.event.recap`. Their catalog rows now point at route-adapter follow-up
  work for provider waves, local draft/selection state, captures, and
  Widgetbook section states.

### 2.5.294

- Registered the matrix-only logged-out flow screens as screen contracts:
  `WelcomePage` as `screen.start.welcome`, `AuthScreen` as
  `screen.auth.phone_entry`, and `OnboardingScreen` as
  `screen.onboarding.flow`. The catalog now treats those route shells as
  adapter/composition surfaces with follow-up Widgetbook, capture, and adapter
  work instead of loose matrix-only coverage.

### 2.5.293

- Registered `ChatScreen` as the shared implementation for both
  `screen.matches.chat` and `screen.host.chat`. Host inquiry mode now has an
  explicit catalog entry: it disables profile-title navigation and share-card
  actions, derives host/attendee identity from club/public-profile data, and
  keeps report/block safety actions routed through `ChatController`.
  `HostChatScreenState` now owns those identity/action/composer decisions while
  provider waves and route effects remain in `_ChatContent`.

### 2.5.287

- `ExploreFilterSheet` is now a public Explore section widget so Widgetbook can
  render the same filter-sheet content opened by `ExploreFilterRail`.

### 2.5.285

- Streamlined the source implementation of the `CatchErrorState` family.
  `CatchErrorState`, `CatchErrorScaffold`, `CatchSliverErrorState`, and
  `CatchInlineErrorState` now share one internal resolved spec and one body
  renderer; the latter three remain as placement adapters for call-site clarity.

### 2.5.284

- Consolidated Widgetbook's error section from separate visual entries for each
  placement adapter into four conceptual review points: error surfaces, mutation
  error banner, action error snackbar/listener, and framework fallback.
- Added a shared inline-message shell for `CatchSurface.message` and `CatchErrorBanner`
  so tinted inline message rows cannot visually drift.
- Added `CatchMutationErrorBanner` and `CatchMutationErrorListeners` helpers for
  repeated persistent inline mutation errors and multi-mutation snackbar
  boundaries.

### 2.5.283

- Broadened the local `widgetbook/` workspace from the 10 formal component
  contracts to the full Core Design System catalog. `core_catalog_use_cases.dart`
  now adds 90 use cases for the broader primitive surface, bringing Widgetbook
  to 100 annotated primitive use cases.
- Updated the active Core catalog table to use current live Dart symbols
  (`CatchSurface.tinted`, `CatchField`, `CatchShareCardSheet`, etc.) instead of older
  handoff aliases, so future Widgetbook and design-parity passes can map catalog
  rows directly to code.

### 2.5.282

- Added the local `widgetbook/` workspace for design-system review. The initial
  Widgetbook catalog maps every registered core `Catch*` component contract to
  a use case with the required state set from `design/components/catch.components.json`.
- `CatchField` now accepts `initiallyExpanded` so its `expanded-control`
  contract state can be rendered deterministically in Widgetbook and focused
  widget tests without reaching into private state.

### 2.5.281

- Updated `WelcomePage` from the old static run-club welcome hero to the
  Splash -> Welcome reel handoff: fixed `Catch`, deterministic object reel
  landing on "someone real", tap/reduced-motion skip, and bottom welcome CTAs.

### 2.5.280

- Added the component contract registry under `design/components/`. The initial
  registry covers 10 high-traffic `Catch*` primitives/composites (`CatchButton`,
  `CatchIconButton`, `CatchSurface`, `CatchChip`, `CatchBadge`,
  `CatchField`, `CatchField`, `CatchSegmentedControl`, `CatchOptionCard`,
  and `CatchTopBar`) with props, states, slots, DTCG token refs, Dart roles, and
  handoff names.
- Added `node tool/design/check_component_contracts.mjs` as the local validator
  and wired the registry into `design_context_pack/design_system/components.json`
  so Claude/Figma handoffs can consume the same allowed primitive contracts.

### 2.5.279

- Retired Explore's **wrist-lift map reveal** (changelog 2.5.141 / 2.5.142). With
  the Explore map-as-canvas → feed-primary rewrite, `lib/core/device_motion.dart`
  (`DeviceMotionSource`), `ExploreMapMotionRevealRecognizer`, and the `sensors_plus`
  dependency were deleted; the map now opens only via the bottom-left Map pill →
  `ExploreMapScreen` route.
- Explore's featured-event spotlight renders only in
  `ExploreDiscoveryCoverHeader` when the header has a featured event. The body
  `ExploreEventsSection` no longer renders a duplicate `CatchCoverStory`; the
  map-sheet selected-lead path still uses `CatchEventCard.spotlight`.

### 2.5.278

- Added `CatchErrorIcon` as the shared branded error medallion primitive.
  `CatchErrorState` and `CatchFrameworkErrorView` now compose it instead of
  carrying duplicate private `_ErrorIcon` helpers.
- Added `CatchMonoLabel` as the shared one-line mono metadata primitive for
  ticket/event-card chrome, replacing duplicate private `_MonoLabel` helpers.
- Moved the remaining core widget color literals for photo grading and floating
  icon chrome into token-owned static color roles.

### 2.5.277

- `BottomCTA` now forwards an optional `buttonAccentColor` into its underlying
  primary `CatchButton`, allowing event booking docks to use activity pigment
  without per-screen button styling.
- `EventDetailCta` now resolves the current event activity and applies that
  accent to booking, request-to-join, and accept-spot actions while preserving
  neutral treatment for waitlist, cancel, past, and ineligible states.

### 2.5.276

- `EventDetailPhotoStrip` now renders the handoff three-tile strip for
  non-empty event photo sets: uploaded photos fill leading slots, remaining
  slots render activity-soft placeholders, and all tiles use the 108px strip
  height with the caption/data row below.

### 2.5.275

- `PersonAvatarStack` now matches the handoff `AvatarStack` contract more
  closely: photo-less people render initials over the existing activity-derived
  avatar gradient, stacks can render activity-tinted veiled placeholder circles,
  and the overflow `+N` circle uses the quiet raised surface treatment.
- `EventHypeAvatarStack` now uses veiled activity placeholders for obscured
  event-detail attendee rows instead of fetching and blurring profile photos;
  revealed stacks keep the public-profile thumbnail provider path.

### 2.5.274

- `CatchButton` now exposes the handoff primary activity accent shortcut through
  `accentColor`, pairing pigment fills with white ink while preserving explicit
  `backgroundColor` / `foregroundColor` overrides for legacy custom buttons.

### 2.5.273

- `CatchChip` selected state now follows the handoff rule: transparent fill
  with the 1.5px ink selection outline. Resting chips keep the surface fill,
  and activity-tinted chips still use their supplied activity soft/deep colors.

### 2.5.272

- `CatchField` now carries more of the handoff `TextField` contract:
  `CatchFieldVariant.underline`, centered text alignment, tabular numeric
  figures through `mono`, forced focus styling for static/mock compositions,
  and a quiet trailing widget slot. Existing boxed editable fields keep their
  default shell, sizing, validation, and clear-button behavior.

### 2.5.271

- `CatchScreenBody` now maps the handoff `ScreenBody` composition directly:
  it owns the vertical scroll region, app-wide horizontal gutter, top/bottom
  padding overrides, full-bleed gutter opt-out, and a non-scroll escape hatch
  for screens whose parent already owns scrolling.

### 2.5.270

- Added `CatchStepHeader`, the Flutter port of the handoff `StepHeader`: large
  `CatchTopBar` anatomy with inline back/close-compatible leading behavior,
  optional kicker/subtitle, top-right `STEP n OF m` mono counter or custom
  trailing status, gutter ownership, and a 2px ink progress hairline.
  `CatchStepFlowHeader` remains as the existing zero-based compatibility
  wrapper for onboarding/create flows.

### 2.5.269

- Added `CatchTabDock`, the Flutter port of the handoff `TabDock`: translucent
  blur surface, top hairline, 10/12/18 padding, 22px active filled glyphs,
  uppercase mono 8.5px labels, selected/idle ink roles, and badge support.
  `AppShellNavigationBar` now uses it for non-iOS authenticated bottom
  navigation while keeping the existing native `CupertinoTabBar` branch on iOS.

### 2.5.268

- `CatchTopBar` now carries the handoff `AppBar` API: compact and large
  editorial headers, `kicker` / `subtitle` text roles, back / close / none
  leading modes, surface/divider/gutter ownership, text/icon/trailing action
  shortcuts, and declarative `CatchSearchField` expanding mode composition that hides the
  title while search is open. Existing `actions`, custom `leading`,
  `showBackButton`, and tab-bottom behavior remain supported.

### 2.5.267

- `IconBtn` now matches the handoff `IconButton` primitive: 44px default
  circular target, bordered / float / plain variants, surface + line2 bordered
  chrome, translucent floating photo/map chrome with soft shadow, active accent
  tinting through `IconTheme`, disabled opacity, and a 40px `navSize` constant
  for app-bar back/actions.

### 2.5.266

- Added `CatchCodeInput`, the Flutter port of the handoff `CodeInput`: 6-cell
  default row, controlled `value`, optional active cell override, 64px cell
  height, 10px gap, surface fill, interactive-tile radius, ink active rule, and
  optional caret. `CatchOtpCodeField` now composes the same visual primitive
  over one hidden platform `TextField` for SMS autofill, paste, digit filtering,
  length limiting, and auth form tests.

### 2.5.265

- Added `CatchStatusBar`, the Flutter port of the handoff `StatusBar` for
  phone-frame/mock surfaces: 14px bold mono time, Phosphor fill signal/wifi/
  battery glyphs, light/dark tone support, and optional surface band fill.

### 2.5.264

- `CatchSectionStack` now matches the handoff `SectionStack` ownership model:
  it owns only the 24/20/20 page gutter and no longer inserts an extra
  inter-section gap by default. `CatchSection` remains the single owner
  of the 24px hairline delimiter rhythm and 12px kicker/body gap.
- `CatchDetailSliverSectionList` now also defaults to no inserted gap so
  sliver-native detail pages can use the same section-owned rhythm.

### 2.5.263

- `CatchBottomSheetScaffold` now matches the handoff `Sheet` scaffold: surface
  panel with overlay shadow, `26px/30px` bottom-sheet radii, 10/22/26 padding,
  optional grabber, plain title/subtitle header, branded glyph-tile header,
  and badge/trailing right-side header slots.

### 2.5.262

- `CatchEmptyState` now defaults to the handoff `EmptyState` presentation:
  cardless centered content, optional quiet 34px ink3 glyph, section-title
  headline, body-small message, 24px horizontal padding, and optional action
  slot. Explicit `surface`, `bubble`, and `inline` modes remain for embedded
  legacy contexts that need them.

### 2.5.261

- Added `CatchSearchField` expanding mode, the Flutter port of the handoff
  `ExpandingSearch`: collapsed magnifier affordance, controlled animated growth
  into the shared raised-pill `CatchSearchField`, and clear-first-then-close
  trailing behavior.
- Browse headers now compose `CatchSearchField` expanding mode directly and
  accept controlled search value/change callbacks, so feature tabs bind
  provider query state through the shared app-bar search primitive.

### 2.5.260

- Added `CatchMenu`, the Flutter port of the handoff `Menu`: overlay surface,
  line2 border, radius-md corners, row hairlines, optional icon/sublabel,
  selected check mark, and danger row tone.
- `CatchActionMenu` now anchors the shared `CatchMenu` panel instead of native
  `MenuItemButton` rows, and supports sublabels plus selected rows for club
  pickers and overflow actions.

### 2.5.259

- Added `CatchSearchField`, the Flutter port of the handoff `SearchField`:
  raised pill input, 15px magnifier, quiet x-circle clear target, controlled
  value sync, and submit/focus callbacks for browse headers.
- Chats and Explore search wrappers now bind their query providers to
  `CatchSearchField` instead of configuring the heavier form-oriented
  `CatchField` for browse search.

### 2.5.258

- Added `CatchSurface.card`, the Flutter port of the handoff `Panel`: bounded
  `surface` card, hairline border, `radius-md`, 20px default padding, and soft
  card shadow for self-contained groups and flow stages.
- `CatchSection` now composes `CatchSurface.card` instead of restating the card
  surface contract directly.

### 2.5.257

- Reintroduced `CatchKicker` as the handoff `Kicker` leaf primitive, replacing
  the old legacy helper with the current contract: uppercase mono eyebrow,
  optional color override, and `md` / `lg` sizes.
- `FieldGroup` and `CatchSection` now compose the shared kicker primitive
  instead of rendering local uppercase kicker `Text` directly.

### 2.5.256

- Promoted the Material confirm-card implementation to public
  `CatchConfirmDialog<T>` and added `showCatchConfirmDialog` for the handoff
  two-action confirm API with default Cancel/Confirm labels and danger-filled
  destructive commits.
- Confirm dialogs now use centralized handoff tokens for the 46% ink scrim,
  320px max card width, 28px overlay inset, and `24px 22px 18px` card padding
  while preserving Cupertino alert chrome on iOS.

### 2.5.255

- Added shared `FieldRow` and `FieldGroup`, Flutter ports of the handoff
  on-surface row/group grammar. They cover inline and stacked rows, add and
  danger affordances, chevrons, toggles, and injected quiet dividers inside
  kicker-delimited groups.

### 2.5.254

- Added the earlier shared flat hairline-bordered stat row for club detail
  metrics. This path has since converged on the canonical `CatchMetricStrip`
  primitive.

### 2.5.253

- Added shared `ActivityArt`, the Flutter port of the handoff generated
  activity-art surface with activity pigment, screen-print texture, faint glyph
  motif, optional dim layer, radius/height controls, and overlay child slot.

### 2.5.252

- Added shared `DistanceRing`, the Flutter port of the handoff map radius ring:
  default 170px ring, 1.2px ink stroke, and optional tappable mono label for
  static map canvases and previews.

### 2.5.251

- Added shared `ActivityMapPin`, the Flutter port of the handoff `MapPin`.
  Event-detail map cards now use the activity-pigment pin mark instead of a
  local rounded activity-glyph badge, with optional selected flag support for
  map surfaces.

### 2.5.250

- Added shared `ActivityAvatar`, the Flutter port of the handoff activity
  avatar. It resolves activity pigment through `ActivityPalette`, supports
  initials, explicit size, selected/live ring, dim veil, and the screen-print
  texture used by activity-register people surfaces.

### 2.5.249

- Added shared `ActivityChip`, the Flutter port of the handoff activity tag.
  It resolves `ActivityKind` through `ActivityPalette`, supports soft and
  primary registers, optional label override/tap behavior, and replaces the
  host-only activity-chip helper in `HostOperationsHomeScreen`.

### 2.5.248

- `CatchBadge` now matches the handoff `Badge` API more closely with
  `CatchBadgeSize.action` for 33px button-aligned outcome pills, explicit
  leading-icon coverage, a `gold` functional tone, and activity-accent tinting
  via `accentColor`. Existing compact/live badge behavior is unchanged.

### 2.5.247

- `CatchFrameworkErrorView` debug details now use a tokenized `CatchSurface`
  disclosure row with animated chevron/content instead of Material
  `ExpansionTile`, leaving the framework-error fallback dependency-light while
  aligning with the handoff disclosure pattern.

### 2.5.246

- `EventSuccessSetupBody` setup disclosure sections now use a handoff-style
  tokenized `CatchSurface` row with animated chevron and `AnimatedSize` content
  instead of Material `ExpansionTile`. Existing Guide notes / Advanced
  expansion behavior, module toggles, and draft updates are unchanged.

### 2.5.245

- Retired the unused `ListTileMaterial` compatibility wrapper now that app
  surfaces no longer need native `ListTile` rows inside custom sheet/surface
  chrome. Use shared row/surface primitives such as `CatchField`,
  `CatchSection`, `CatchSurface`, `PersonRow`, or feature-specific rows
  instead.

### 2.5.244

- `SuvbotActionBar` is now cataloged, and its reset-demo sheet uses
  `CatchBottomSheetScaffold` plus tokenized `CatchSurface` action rows instead
  of raw Material `ListTile` rows. Existing demo action routing, pending
  disablement, and text-action behavior are unchanged.

### 2.5.243

- `LocationPickerScreen` autocomplete suggestions now render with a tokenized
  local suggestion row inside the existing `CatchSurface` overlay instead of a
  raw Material `ListTile`. Search, selection, and map-confirm behavior are
  unchanged.

### 2.5.242

- `PublicProfileScreen` now uses branded `CatchErrorState` and
  `CatchEmptyState` surfaces for profile load failures and unavailable profiles
  instead of raw centered text, and the report reason sheet now uses shared
  `CatchField` action rows. The shared `ProfileSurface` body and report/block
  mutations are unchanged.

### 2.5.241

- `CatchChip` now matches the handoff `Chip` selection rule: active chips keep a
  surface fill with a 1.5px inset ink rule instead of an inverted ink fill. The
  primitive also exposes optional tint/ink colors for activity-tagged fact
  pills while preserving tap and remove behavior.

### 2.5.240

- `ProfileSurface` / `CatchProfileView` now renders passive compatibility and
  running-identity labels with `CatchBadge` instead of generic `CatchChip`.
  Editable chip fields remain on `ChipField`, and reaction controls are
  unchanged.

### 2.5.239

- `LaunchAccessApplicationScreen` now uses handoff `CatchToggle` row
  composition for the `I might host` binary setting instead of an adaptive
  Material switch tile. The Remote Config gate, signed-in guard, editable
  application draft, and submit mutation behavior are unchanged.

### 2.5.238

- `EventSuccessFeedbackForm` now uses handoff `CatchToggle` row composition for
  the private safety/comfort review flag instead of a Material checkbox tile.
  Feedback ratings, private note copy, and repository submission semantics are
  unchanged.

### 2.5.237

- `EventSuccessLabScreen` playbook module metadata now uses shared
  `CatchBadge` labels instead of generic `CatchChip` tags. The dev/staging WIP
  route, preview-only guardrails, and feature-block composition are unchanged.

### 2.5.236

- `EventSuccessDefaultsPanel` and `EventSuccessSetupBody` setup switches now
  use handoff `CatchToggle` row composition instead of adaptive Material switch
  tiles. Existing draft/default update callbacks and progressive disclosure are
  unchanged.

### 2.5.235

- `EventSuccessManualQaScreen` fixture controls now use handoff `SelectChip`
  choices for the scenario selector and `CatchToggle` rows for attendee opt-out
  settings. The existing side-by-side host/attendee fixture wiring and
  `CatchTopBar` chrome are unchanged.

### 2.5.234

- `EventSuccessHostPanel` now uses the handoff `CatchOptionGroup` primitive for
  its standalone Setup / Live / Report lifecycle picker instead of generic
  chips. Host Manage already supplies its fixed lifecycle section externally.

### 2.5.233

- `EventSuccessHostSetupFlow` is now cataloged and uses the handoff
  `SelectChip` primitive for the playbook/format selector. The setup draft,
  structure editor, module switches, and readiness issue behavior are
  unchanged.

### 2.5.232

- `EventSuccessSetupBody` is now cataloged and uses the handoff `SelectChip`
  primitive for rotation cadence, reveal countdown, and match-clue mode
  choices. Stage cards, recommendation toggles, guide-note fields, and draft
  update semantics are unchanged.

### 2.5.231

- `EventSuccessQuestionnaireConfigEditor` is now cataloged and uses the handoff
  `SelectChip` primitive for reusable/custom questionnaire template choices.
  Preview badges, custom-question editing, and bottom-sheet custom editing stay
  unchanged.

### 2.5.230

- `EventSuccessStructureConfigEditor` now uses the handoff `SelectChip`
  primitive for flow type, auto/fixed count, repeat policy, and assignment-goal
  choices. Badge summaries and numeric steppers remain unchanged.

### 2.5.229

- Explore filter-sheet distance and joined-club choices now use the handoff
  `SelectChip` primitive for choosy filters. The visible time-scope
  `CatchOptionGroup`, trailing `CatchCountPill`, active-count badge, and filter
  controller wiring are unchanged.

### 2.5.228

- Swipe Filters interested-in choices now use the handoff `SelectChip`
  primitive for choosy filters instead of the generic `CatchChip`. Age range,
  reset/apply actions, save payload mapping, and pop-on-success behavior are
  unchanged.

### 2.5.227

- Host Edit Event policy toggles now use the handoff `CatchToggle` row
  composition for cohort caps and demand pricing instead of adaptive
  `SwitchListTile` rows. Existing lock rules, validators, and save payload
  mapping are unchanged.

### 2.5.226

- Host Edit Event selectors now use the handoff `SelectChip` for pace,
  admission format, and cancellation policy choices. Schedule/location fields,
  policy-lock behavior, cohort-cap and demand-pricing toggles, and save payload
  mapping are unchanged.

### 2.5.225

- Host Create Club host-default selectors now use the handoff `SelectChip` for
  default activity, admission format, and cancellation policy. Default activity
  choices carry their own activity pigment; cohort-cap and demand-pricing
  switches remain on `CatchToggle`.

### 2.5.224

- Host Create Event policy selectors now use the handoff `SelectChip` for
  admission format and cancellation policy choices. Capacity, invite-code,
  cohort-cap, demand-pricing, age, and payout controls keep their existing
  field/toggle composition.

### 2.5.223

- Host Create Event basics now uses the handoff `SelectChip` for activity type,
  custom format structure, and pace choices. Activity chips carry their own
  activity pigment, while format/pace choices inherit the selected activity
  accent.

### 2.5.222

- Added `SelectChip`, the Flutter port of the handoff tactile selectable pill
  for questionnaire answers, mission choices, and choosy filters. It uses an
  accent selected fill, active glow/scale, pressed scale-down, selected
  semantics, and shared `CatchSurface` pill chrome.

### 2.5.221

- Added `SectionLabel`, the Flutter port of the handoff activity-accent
  eyebrow. It keeps the optional leading glyph and mono kicker label on the same
  accent color, with bounded ellipsis behavior for panel and section headers.

### 2.5.220

- Added `SoftBand`, the Flutter port of the handoff quiet tinted inset row for
  privacy notes, tips, and secondary details. It delegates primary-soft fill,
  small radius, and no-elevation surface behavior to `CatchSurface` instead of
  creating a parallel decoration primitive.

### 2.5.219

- Added `PrivacyBadge`, the Flutter port of the handoff privacy pill for
  `PRIVATE TO YOU`, `CATCH PRIVATE`, and `HOST CAN SEE` visibility hints. It
  uses shared surface, icon, spacing, and mono badge text primitives instead of
  local outlined-pill styling.

### 2.5.218

- Added `BookingConflictSheet`, the Flutter counterpart to the Booking
  handoff's `ConflictSheet`: warning sheet chrome, activity-colored existing /
  incoming event rows, and replace / keep-both / keep-existing action slots.
  The component is presentation-ready for a future booking-overlap flow without
  inventing backend replacement behavior in this pass.

### 2.5.217

- Host Account profile rows now open `HostProfileEditorSheet` with
  `CatchBottomSheetScaffold` on the Account route instead of navigating to
  `HostProfileScreen`, matching the handoff's no-nested-editor composition
  while preserving the full-screen route for direct entry.

### 2.5.216

- Host Clubs now uses the handoff selected-club shell instead of rendering all
  operated clubs in grouped sections. The top bar title is the selected club,
  the shared top-bar menu switches clubs when needed, and a handoff
  `OptionGroup` exposes Edit / Preview. Edit mode now shows Identity,
  Contact, Event defaults, Public profile, Payouts, and Host team sections
  using on-surface `CatchSection`/`CatchField` composition.

### 2.5.215

- Notifications day groups now use a compact handoff screen wrapper instead of
  `CatchSection`: first group starts flush under the Activity AppBar,
  later groups get an 8px section offset, top hairline, and 18px inset before
  the kicker and `NotificationRow` stack.

### 2.5.214

- Host Events now matches the handoff's single-club operations shell: owned
  clubs sort before co-hosted clubs, the top bar title is the selected club,
  the shared top-bar menu switches clubs only when multiple clubs are present,
  and the body shows that club's meta row, Upcoming rows, and Add event row.

### 2.5.213

- Host Inbox now exposes the handoff `All` / `Unread · n` `OptionGroup` below
  the pinned chats browse header. `ChatsListScreen` owns only the transient
  host filter state, while `ChatsList` applies the unread filter to the
  existing `ChatsListViewModel` and shows the host-specific no-unread empty
  state when needed.

### 2.5.212

- `profileViewFromCardContent` now follows the Profile handoff body sequence:
  compatibility, prompts, running rhythm, all inset photos, `Details`, then
  `Lifestyle`. Relationship intent is preserved as the first `Details` fact
  instead of creating a standalone `Looking for` section, keeping the public
  profile surface on the template's `FactList` composition.

### 2.5.211

- `AppShellNavigationBar` is now a shared destination-driven bottom navigation
  primitive. The consumer shell keeps its default Home / Explore / Catches /
  Chats / Profile destinations, while `HostAppShell` supplies Events / Clubs /
  Inbox / Account through the same Material/Cupertino chrome and fixed unread
  badge treatment.

### 2.5.210

- `CatchPolaroid` now uses named DS polaroid defaults for the tighter club-card
  material: 6px outer radius, 3px media radius, 24px upright Archivo title, and
  a title-row arrow affordance. Footer-heavy Explore/directory club cards can
  suppress the arrow to avoid duplicating their footer action row.

### 2.5.209

- `PhotoGrid` now matches the handoff core component contract more closely:
  filled profile photos render through the shared display-time `GradedImage`,
  pending upload slots use striped photo-placeholder material, empty slots draw
  dashed hairline targets with the plus glyph, and the leading filled slot gets
  a hideable mono `MAIN` badge.

### 2.5.208

- `OrderedPhotoPicker` is now cataloged and covered as the shared ordered media
  picker for host club/event forms. Photo and add tiles render through
  `CatchSurface`, keep stable add/remove keys, preserve semantic labels and
  tooltips, and show the shared broken-image affordance for failed network
  previews.

### 2.5.207

- `EventHypeAvatarStack` is now cataloged as the event-detail attendee-hype
  composition. It keeps the handoff path on shared `PersonAvatarStack` chrome,
  derives eligible signed-up/attended participants from the participation edge,
  joins public profile names/thumbnails, and uses deterministic obscured
  fallback avatars while async profile data loads.
- Riverpod generated companions for `EventHypeAvatarStack` and `WhoIsGoing`
  were reviewed as generated output paired to their source providers.

### 2.5.206

- Removed unused dashboard visual helpers `DashedAvatar` and `StaticMapDark`.
  Empty-dashboard composition now stays on the active `DashboardEmptySliverBody`,
  `EmptyHeroCard`, and `CatchSection` path instead of retaining legacy
  standalone placeholder art widgets.

### 2.5.205

- Previously unreviewed core display atoms are now covered in
  `catch_primitives_test.dart`: `CatchCornerSash`, `CatchMetaDotRow`,
  `DetailRow`, `StatColumn`, `GradedImage`, and `CatchStartupLoadingScreen`.
- Core catalog rows now document the remaining compact atom roles, including
  startup loading, corner sashes, inline dot metadata, non-destructive photo
  grading, and dense metadata rows.

### 2.5.204

- `CatchTextStyles` now follows the handoff zero-tracking typography rule across
  display, condensed head, kicker, mono-label, and badge roles; style docs and
  active design-language docs now describe zero tracking instead of the previous
  negative/tracked rule.
- Design-system and profile golden baselines were regenerated for the intended
  central typography visual change.
- The cleanup scan now reports no app-facing design-system buckets for
  positional widget finders, raw controls, raw text styles, token prop-drilling,
  raw surfaces, low-level typography roles, or nonzero letter spacing. Remaining
  timing matches are the known manual QA/golden/capture helpers.

### 2.5.203

- `EventPinsMap` no-network placeholder now resolves token-derived colors in
  the widget and passes concrete `Color` values into its `CustomPainter`
  instead of prop-drilling `CatchTokens` through the painter boundary.
- The cleanup scan now reports no feature-widget `CatchTokens` prop-drilling
  candidates.

### 2.5.202

- `RichShareCardSheet` now exposes stable preview and share-action keys while
  keeping the shared sheet composition unchanged: grabber, captured card,
  footnote, and full-width platform share `CatchButton`.
- Club, event-detail, standalone event, and payment confirmation share-card
  coverage now targets `RichShareCardSheetKeys` and the shared pump helper, so
  the cleanup scan no longer reports share-card raw timing waits or positional
  `CatchButton.last` finders.

### 2.5.201

- Empty match threads now use the Messaging handoff's event-grounded prompt
  copy: when the latest shared event is loaded, `ChatMessageList` says what both
  people did at that event before the `Say hi` prompt; null event contexts keep
  the previous neutral fallback.
- `chat_event_context_copy.dart` now owns chat thread stamps, share-card titles,
  and empty-thread event-context copy so `ChatEventContextHeader`,
  `ChatShareCard`, and `ChatMessageList` stay aligned.

### 2.5.200

- `showBlockUserDialog` is now documented and covered as a thin safety dialog
  adapter over the shared handoff `showConfirmDangerDialog` /
  `showCatchAdaptiveDialog` confirm-card stack.
- Core adaptive-dialog tests now open the block-user helper directly and assert
  the Material `Dialog` + `CatchButton` destructive action composition.

### 2.5.199

- Removed unused legacy core widgets `AppFormLayout`, `CatchKicker`, and
  `StatusChip`. Active form/auth/onboarding surfaces now use the handoff
  `CatchScreenBody`, `CatchBottomDock`, `CatchStepFlowHeader`, and
  feature-owned layout functions, while badge/status metadata routes through
  `CatchBadge`.
- `PersonRow` documentation now points trailing status examples at the active
  badge primitive instead of the deleted `StatusChip` wrapper.

### 2.5.198

- Event requirements chips now render directly through `CatchBadge` instead of
  the one-line `VibeTag` wrapper, keeping event-detail requirement metadata on
  the shared badge primitive used elsewhere in the handoff.
- Removed the unused `VibeTag` component after the final production call site
  migrated to `CatchBadge`.

### 2.5.197

- Auth entry has been audited against the Onboarding v2 handoff. `AuthScreen`
  remains a state-only shell, while `PhonePage` and `OtpPage` own the visible
  `CatchScreenBody` / `CatchStepHeader` composition, sticky
  `CatchButton` footers, country/phone row, OTP code field, and resend/change
  actions.
- Auth widget coverage now asserts the shared onboarding frame/header
  composition on the initial phone step in addition to the existing controller
  transition and Firebase auth behavior.

### 2.5.196

- Explore feed now renders the handoff result-count cue above the content
  stream (`1 PLAN` / `10 PLANS · JUN 11-17`) using the same filtered
  `ExploreFeedViewModel` items as the list and map.
- The count/date cue is skipped for club-only fallback content, preserving
  honest event counts while keeping the existing mixed club recommendation
  fallback intact.

### 2.5.195

- Host Create Club host-defaults now uses shared `CatchChip` primitives for
  admission, cancellation, and default-activity choices instead of local
  `VibeTag` wrappers.
- Club default cohort caps and demand pricing now render with the handoff
  `CatchToggle` control inside the existing policy card instead of adaptive
  `SwitchListTile` chrome.
- Create-club coverage now asserts the visible host-defaults chip/toggle
  composition in the successful create flow and verifies the embedded edit-mode
  defaults section still renders.

### 2.5.194

- Host Create Event now uses shared `CatchChip` primitives for activity,
  custom-format structure, pace, admission, and cancellation selections instead
  of local `VibeTag` wrappers.
- Event policy cohort caps and demand pricing now render with the handoff
  `CatchToggle` control inside the existing policy surfaces instead of adaptive
  `SwitchListTile` chrome.
- Create-event widget coverage now asserts the shared chip/toggle composition
  across the primary wizard path and keeps the custom activity-format path
  stable with chip-level taps.

### 2.5.193

- Host Create Event Success now explicitly uses the handoff's seal-check
  celebration mark via `CatchIcons.verifiedRounded`, while retaining the shared
  full-screen `CatchCelebrationScreen` composition for `StatusBar`,
  `ScreenBody`, details, note, and actions.
- Invite-only success coverage now asserts the handoff detail grid (`When`,
  `Where`, `Event`, `Capacity`, `Invite code`, `Private link`), the
  bookings/waitlist/attendance note, and Manage event / Back to club actions.

### 2.5.192

- `showCatchAdaptiveDialog` now renders a handoff-style Material confirm card:
  token scrim, centered overlay `CatchSurface`, title/supporting copy, and
  paired `CatchButton` actions with danger-filled destructive commits, while
  preserving native Cupertino alerts on iOS.
- Host cancel-event and create-event unsaved-changes dialogs now match the
  host-dialogs handoff copy and action labels (`Cancel this event?`, `Cancel
  event`, `Save draft`).
- Dialog coverage now asserts the Material confirm card composition and the
  host manage cancel/delete dialog flows through the new action buttons.

### 2.5.191

- Host Add Host is now covered as a handoff sheet flow: the test opens the
  host-team bottom sheet, verifies `CatchBottomSheetScaffold`,
  `CatchField`, and `CatchButton` composition plus the template copy, then
  submits a phone number through the repository-backed mutation.
- The existing `_AddHostSheet` implementation remains on the shared sheet,
  text-field, error-banner, and button primitives, so no production code change
  was needed for this template beyond coverage.

### 2.5.190

- Host Edit Event now uses shared `CatchChip` primitives for pace, admission,
  and cancellation selections in the flattened edit form instead of local
  `VibeTag` tap wrappers.
- The edit-event save action now sits in a handoff-style persistent footer with
  a top hairline, matching the Host Edit Event template's save chrome while
  keeping the existing update and locked-state behavior.
- Host Edit Event tests now assert the visible handoff structure and shared
  chip primitive in addition to update-event persistence and schedule locking.

### 2.5.189

- Host Edit Club now follows the handoff's flattened edit composition instead
  of reusing the create wizard: `CatchTopBar`, logo/photos, Identity, Contact,
  Event defaults, inline mutation errors, and a persistent full-width `Save
  changes` footer.
- Club defaults steps can now render embedded non-scrollable content for edit
  mode while preserving the existing scrollable create-flow behavior.
- `CreateClubContactFields` can suppress its internal optional section label
  when a parent handoff section already provides the `Contact` kicker.

### 2.5.188

- Host Draft Picker now matches the handoff sheet copy and composition:
  `Resume a draft?`, `Start a fresh event`, a single bordered draft row group,
  file icon, saved-time mono meta, delete `IconBtn`, and chevron affordance.
- Draft row taps now go through `CatchSurface.onTap` so the sheet keeps shared
  semantics and avoids feature-local raw tappables.

### 2.5.187

- Host payout setup now opens a handoff bottom sheet before Stripe: shared
  `CatchBottomSheetScaffold`, status badge, Stripe explanation, country and
  default-currency rows, return-here note, and a full-width `Continue to
  Stripe` action.
- `HostPaymentAccountCard` keeps the existing card entry point and refresh
  behavior while moving external onboarding behind the handoff sheet described
  by the host-payouts template.

### 2.5.186

- Host Inbox copy started following the handoff's attendee-query framing:
  header subtitle, search labels, empty state, and new-query rail no longer use
  consumer match/chat language in host mode. The later 2.5.424 pass supersedes
  the populated-section label with a broadcast-card lead-in.
- Added host-mode chat-list coverage so the inbox keeps host-specific title,
  subtitle, and filter copy while hiding consumer match copy.

### 2.5.185

- Shared async error copy and event activity card supporting copy now use the
  semantic `supporting` text role, clearing the remaining low-level typography
  scanner candidates from shared core widgets.

### 2.5.184

- Host Account now follows the handoff composition: `CatchTopBar` with sign-out
  action, an Edit / Preview `CatchOptionGroup`, and flat Profile / Bio / Clubs
  info-row sections instead of the previous card stack.
- `CatchField` now supports opt-in multi-line values so handoff-style taller
  FieldRows such as the host bio can stay on the shared row primitive without
  affecting existing one-line field rows.

### 2.5.183

- Event Detail design primitives now route bounded map pins, map pills, hint
  dots, and itinerary dots through `CatchSurface` instead of feature-local
  decorated boxes or containers.
- Event Detail mechanism and itinerary rows now use semantic text roles
  (`fieldRowTitle`, `supporting`, `monoLabelS`) so the screen's DS primitives no
  longer show up in low-level typography or non-token letter-spacing scanner
  buckets.

### 2.5.182

- Create/Edit Club contact fields now use the shared `CatchFormFieldLabel`
  optional badge for the Contact form section instead of a local low-level
  title style, aligning the club form stack with existing field semantics and
  clearing the host form typography scanner hit.

### 2.5.181

- Host Event Manage now mounts the event title and Setup / Live / Report switch
  in shared `CatchTopBar` chrome, with the mode switch rendered through
  `CatchOptionGroup` instead of the older segmented surface control.
- The full-event apron now uses the handoff copy (`FULL - CAPACITY REACHED` and
  `WAITLIST OPEN`) inside a compact ink panel under the top bar.
- The New invite link dialog title now uses `CatchTextStyles.sectionTitle`,
  clearing the scanner's remaining raw app-facing `Text` candidate.
- The New invite link form later moved to `CatchFormDialog` so Host Event
  Manage no longer owns a raw Material `AlertDialog` shell.

### 2.5.180

- Host Events now follows the handoff's flatter operations grammar: shared
  `CatchTopBar`, club meta row with role badge and activity chip, Upcoming
  kicker, `CatchField` event rows, and an Add event row instead of a card-heavy
  club panel.
- Host Clubs now uses the same host meta/activity row and on-surface Edit /
  Preview action rows while keeping payouts and host-team management in their
  existing functional sections.
- Added host-local `HostOperationsTopBar` and `HostMetaRow` helpers so host
  tabs pull role presentation from shared Catch tokens. Activity presentation
  now routes through the shared `ActivityChip` primitive.

### 2.5.179

- Onboarding v2 composition is now reflected in Flutter: the welcome screen uses
  the dark editorial handoff register, auth/profile steps share
  `CatchScreenBody` plus `CatchBottomDock`, and primary actions sit in sticky footers rather than
  inside long scroll bodies.
- Phone and OTP entry now use the handoff layout stack: `CatchStepHeader`,
  compact country/phone row, OTP resend/change actions, and a bottom `Verify`
  button while preserving existing auto-submit and controller behavior.
- Name/DOB, gender, Instagram, photos, prompts, and running preferences now use
  handoff-aligned labels, spacing, footer actions, prompt cards, photo tip band,
  and the raised pace-range panel backed by existing Catch primitives.

### 2.5.178

- Payment pending external checkout now ports the booking `CheckoutSheet`
  handoff: dimmed activity event backdrop, bottom sheet with grabber,
  receipt/warning medallion, event/price summary with Pending/Failed badge, and
  checkout / payment history / back-to-event actions.
- Added `CatchOpacity.paymentCheckoutScrim` for the Booking handoff's dimmed
  event backdrop instead of reusing unrelated scrim or border opacities.
- Added a pending Stripe checkout widget test so the Booking handoff state is
  covered separately from the confirmed "You're in." celebration path. The
  designed `ConflictSheet` had no repository flow for booking-overlap
  replacement at that point; the presentation component was added in 2.5.218
  and remains unmounted until a real overlap signal exists.

### 2.5.177

- Messaging thread composition now follows the handoff `ConversationTopBar` /
  `ChatThreadHeader` / `ChatBubble` / `ChatComposer` stack: surface top bar with
  hairline, activity-grounded context band, centered day separators, mono
  message timestamps, and Catch-owned composer icon controls.
- Added `CatchTextStyles.chatThreadContext` so the event-context band can use a
  semantic thread title role instead of a feature-local low-level body style.
- `ChatMessageList` now inserts day separators and splits same-sender bubble
  runs across day boundaries while preserving variable-height bubble rendering.
- `ChatInputBar` replaces raw Material icon buttons with a local composer action
  that keeps quiet image, filled send, disabled opacity, loading color, and
  tooltips consistent with the handoff.

### 2.5.176

- Added `CatchCountPill`, the handoff CountPill control for floating Explore
  map/filter affordances: raised surface, optional icon/mono label, optional
  count badge, and explicit semantics.
- `CatchOptionGroup<T>` now protects tight mobile rails by flexing labels while
  keeping the selected underline and trailing action pinned.
- `ExploreFilterRail` now matches the Explore handoff composition: visible time
  scopes for Tonight / Weekend / This week / Anytime, a right-aligned tune glyph
  with an active-count badge, and secondary filters in a bottom sheet instead of
  chip-heavy chrome.
- Explore's sheet exclusion now uses the rendered handoff filter rail height so
  the closed feed starts below the status/header/filter chrome on compact
  devices.

### 2.5.175

- Added `CatchToggle`, the Flutter port of the handoff settings switch: primary
  pill track when on, quiet line track when off, and a surface knob.
- `CatchField` now matches the handoff `FieldRow` shape for settings: on-surface
  rows, optional inset hairline divider, 20px icon lane, `fieldRowTitle` labels,
  mono right-hand values, chevrons only for navigational rows, and `danger`
  mapped to the functional danger tone.
- `SettingsScreen` now uses the handoff Settings/Filters composition: compact
  `CatchTopBar`, page gutters, Account / Notifications / Privacy & safety /
  About / Log out sections on the page surface, `CatchToggle` notification rows,
  and the existing `CatchRangeSlider`/chip/apply dock filter sheet behavior.

### 2.5.174

- Added `PersonAvatarShape` support so shared avatars can render the handoff's
  circular person treatment and rounded-square host treatment through one
  primitive.
- Added `CatchTextStyles.chatPreview` for `CatchPersonRow` secondary inbox copy,
  keeping unread/new color changes on a semantic text role.
- Chat inbox composition now follows the handoff list model: new matches and
  conversations are folded into one `CONVERSATIONS` section, rows sit directly
  on the page surface with inset hairline dividers, unread/new state is carried
  by avatar rings, text color, timestamp color, and the trailing unread/new
  indicator rather than by card fills.

### 2.5.173

- Added `CatchOptionGroup<T>`, the Flutter port of the handoff `OptionGroup`
  underline selector. Profile now uses it for the pinned Edit/Preview row
  instead of adaptive Material/Cupertino tab chrome.
- Added `CatchTextStyles.fieldRowTitle` for the handoff `FieldRow` primary row
  value (`.t-title-s`) so edit rows can use a semantic typography role without
  low-level style leakage.
- Profile edit now follows the handoff section composition: Photos, Prompts,
  About you, Running, and Lifestyle as on-surface `CatchSection` /
  `CatchField` groups. The old Profile strength card and split Location /
  Background / Intentions buckets are no longer part of this screen.
- Profile preview now renders the shared `ProfileSurface` full-bleed under the
  option group, with the profile renderer owning the body gutter. The shared
  public/profile/catches renderer applies the social-run activity pigment to the
  hero fallback and Running Rhythm block.

### 2.5.172

- The Notifications route now follows the handoff Activity composition:
  `CatchTopBar(title: 'Activity')`, manual top-bar "Mark all read", page-body
  gutters, and day-grouped notification rows.
- `ActivitySection` is notification-only on this route. It groups backend-owned
  notifications by Today, Yesterday, This week, and Earlier through the compact
  notifications day-group wrapper, and no longer prepends signed-up event rows.
- `NotificationRow` ports the handoff row contract directly: on-surface row,
  type-colored glyph, inset hairline dividers, relative time, and unread state
  through title/time color instead of card fills, icon chips, and badges.

### 2.5.171

- Dashboard full-state content now composes through `CatchSectionStack` in the
  handoff order: Event Focus, weekly stride, QuickActions, the personal clubs
  rail when available, and the recommendation rail.
- Dashboard recommendations now use the handoff heading "Recommended for you"
  while keeping the shared activity-art ticket cards and recommendation reasons.
- Dashboard empty-state body now narrows to the cover-story hero plus a
  `CatchSection` "How Catch works" journey. The first-run hero copy
  matches the handoff and no longer carries the old decorative glyph.

### 2.5.170

- Club detail's pre-schedule body now composes through `CatchSection`:
  Your hosts, About, What we do, From the club, Get in touch, Membership, and
  Join Catch. The route keeps the existing hero, stats apron, schedule sliver,
  read-only reviews, membership mutations, and host-message behavior.
- Club detail now renders club tags and optional club photo strips inside the
  handoff section rhythm while preserving the current public-profile behavior
  for host-app viewers.

### 2.5.169

- Added `CatchSection`, the Flutter counterpart to the handoff `Section`
  primitive: it owns the kicker/count row, the 12 px kicker-to-body gap, and the
  24 px hairline section rhythm. Lead sections can pull their one accent from
  `ActivityPalette.resolve`.
- Event detail now seats `EventDetailTicketStubBand` directly under the hero and
  composes the body as handoff-style sections: The plan, Why you might click,
  Itinerary, Photos when available, Where, How sign-ups work, Good to know,
  Who's going, and Reviews. Existing booking, invite, companion, map, and review
  ownership stays in the current controllers/routes.
- Added Flutter event-detail design primitives for the stub band, hint list,
  itinerary, map preview, sign-up mechanism list, and photo strip, all sourced
  from the existing `Event` model plus the centralized activity resolver.

### 2.5.168

- Ported the Flutter foundation toward the implementation handoff: Archivo is
  now the voice/head face, the platform system font is the function/body face,
  and IBM Plex Mono remains the data face. `CatchFonts.serifFamily` and
  `CatchFonts.sansFamily` remain as compatibility aliases while feature code
  moves to the voice/function/data vocabulary.
- Added `CatchScreenBody` and `CatchSectionStack` as design-system aliases over
  the audited page-body and section-list primitives, so new screen migrations can
  compose with the handoff names without forking layout behavior.
- Added a centralized activity resolver in `ActivityPalette`: `CatchActivity`
  carries kind, label, regular Phosphor glyph, and accent/deep/soft swatch. The
  legacy event-activity glyph helper now reads from that registry.

### 2.5.167

- Host create/edit club and create-event implementation files now live under
  `lib/hosts/presentation/...`; consumer club/event feature folders no longer
  own host form screens, wizard controllers, or payout UI.
- Public club host messaging is split into `ClubHostContactController`, while
  add/remove/transfer host-team mutations live in `HostTeamManagementController`.

### 2.5.166

- Host app tab ownership is now explicit: Events owns event creation and event
  management rows, while Clubs owns club profile, payout, and host-team
  management. The Host Events header no longer exposes create-club chrome once a
  host is operating inside the app.
- Club detail is presentation-only again for host-app viewers. Host management
  controls such as Add event, Edit club, payouts, and host-team editing live in
  Host Operations surfaces instead of the public club profile.
- Professional host identity management stays separate from dating profile
  editing; Host Account owns the current profile-row edit entry point.

### 2.5.165

- Added the semantic spacing contracts `CatchGaps` and `CatchInsets`.
  Feature screens should use these role names, or a layout primitive that embeds
  them, instead of composing repeated `EdgeInsets` from primitive
  `CatchSpacing` values.
- Expanded `CatchInsets` with content, tile, list, pill/control, and one-axis
  roles, plus page body/header variants for repeated `fromLTRB(...)` shapes.
  Repeated presentation-level `EdgeInsets.all(...)`, one-axis
  `EdgeInsets.symmetric(...)`, and high-confidence page/header
  `EdgeInsets.fromLTRB(...)` shapes now use those roles.
- Added `CatchPageBody`, `CatchFormStepBody`, and `CatchSliverPageBody` as
  reusable body-padding primitives. `CatchSectionList` now defaults to the
  semantic `CatchGaps.section` value, preserving the existing 24 px detail
  section rhythm while naming the relationship directly.
- Added `CatchIconBadge` so feature UI can show notification/count overlays
  without using Material's raw `Badge` directly.
- Added chat bubble inset contracts so live message bubbles and generated share
  cards keep identical internal padding and sender-group rhythm.
- `catch_prefer_semantic_insets` now surfaces inline feature-level
  `EdgeInsets.*(CatchSpacing...)` at info severity while allowing named local
  inset contracts, so the remaining direct inset debt can be reviewed and
  migrated role-by-role.

### 2.5.164

- Catch UI lints now run across handwritten `lib/**` instead of only the first
  audited detail screens. The lint package exempts theme-token definitions and
  generated code, permits core widget primitives to wrap raw platform controls,
  and otherwise requires feature UI to use named spacing/layout constants plus
  Catch control primitives.
- The first wide pass cleared all surfaced diagnostics by moving inline token
  arithmetic into semantic `CatchLayout` constants, replacing feature-level raw
  Material controls with `CatchActionMenu`/`CatchButton`, and converting raw
  form/list insets to `CatchSpacing` values.

### 2.5.163

- `CatchSectionList` and `CatchDetailSliverSectionList` centralize audited
  detail-screen section composition so adjacent semantic sections use one named
  gap contract instead of hand-inserted `SizedBox` rows. Event detail now uses
  these primitives for the page body and overview section.
- Catch UI lints now live in `packages/catch_ui_lints` as an
  `analysis_server_plugin` package loaded by `analysis_options.yaml`, with
  CI smoke checks for both Catch UI diagnostics and Riverpod diagnostics.

### 2.5.162

- Event detail now shares the `CatchLayout.detailScreen*` rhythm used by club
  detail for sliver body padding, content gaps, section gaps, supporting-copy
  gaps, and dense card rows. Standard event heroes use semantic responsive
  height constants, while ticket/spotlight detail heroes use named ticket
  height/visual/title constants instead of local magic numbers.
- Event detail heroes now prefer uploaded event photos when a `photoUrl` is
  present and fall back to activity artwork only for no-photo or failed-photo
  states, including ticket and spotlight presentation modes. UI capture
  coverage includes standard, ticket, and spotlight event detail variants.

### 2.5.161

- Club detail layout now routes hero, body, and agenda rhythm through semantic
  `CatchLayout.detailScreen*`, `agenda*`, and `clubDetailHero*` constants.
  `ClubHeroAppBar` keeps the viewport-curve clipping on media only, with the
  title/location caption on the page surface so long names cannot crop the
  location row.
- `EventAgendaSliverList` exposes padding plus day/item/group gap parameters
  and no longer emits trailing per-card/per-group spacers. `EventDateRailCard`
  paints its ticket shadow explicitly with `CatchElevation.physicalShadow`
  behind the clipped ticket shape.

### 2.5.160

- Typography is now **bundled + optically sized**: `CatchFonts` drives the variable
  `Archivo` / platform system / `IBM Plex Mono` via `FontVariation('wdth'/'wght')` (auto
  optical size from point size) instead of runtime `google_fonts`. Build text through
  `CatchFonts.serif/sans/mono` (or a named `CatchTextStyles.*`); never raw `TextStyle(`
  or `GoogleFonts` in production — enforced by the Catch UI analyzer lints.
- `CatchTextStyles` consolidated **59 → ~33** named styles onto one principled scale.
  Removed names (`heroImpact`, `displayXL/L/M/S`, `screenHeadline`, `heroHeadline`,
  `cardTitle`, `formQuestion`, `titleM`, `kickerCaps`/`kickerCapsLg`, `ticketMeta`,
  `arrivalMissionTitle`, …) are gone — use the canonical set: serif
  `display`/`headline`/`headlineS`/`titleL`/`profileAnswer`/`proseL`/`proseM`, sans
  `sectionTitle`/`titleS`/`fieldRowTitle`/`chatPreview`/`body*`/`label*`/`supporting`/`button*`, mono
  `kicker`/`kickerLg`/`monoLabel`/`monoLabelS`/`numeric*`/`mono`.
- `GradedImage` / `CatchGrade` is now a tunable, brightness-aware **matte duotone**
  (desaturate + black-lift + warm shadow/highlight split-tone, optional grain).
- **Flagship profile:** `CatchProfileView`
  (`lib/swipes/presentation/profile_redesign/`) renders a section-based `ProfileView`
  in the editorial language with per-section reaction controls;
  `profileViewFromCardContent` maps the existing `ProfileCardContent`, and
  `ProfileSurface` routes Catches + preview + public profile through it. The legacy
  `ScrollableProfile` + section widgets are superseded.
- New anti-drift analyzer rules (`catch_no_raw_color`, `catch_no_raw_text_style`,
  `catch_no_raw_font_drift`) join `check_sizing.sh` +
  `check_ui_local_constant_wrappers.sh` in CI.

### 2.5.159

- Event detail routes now carry a source-aware presentation mode. Explore
  date-rail/ticket cards open the detail screen in a light ticket presentation,
  while featured/spotlight event cards open a dark spotlight presentation that
  preserves the black lower-card body after navigation.
- Added shared event-ticket transition primitives in
  `event_ticket_surface.dart`: full-card Hero wrapping, ticket clipping
  constants, and the reusable perforated divider. `CatchEventCard.ticket`,
  `CatchEventCard.spotlight`, and `EventDateRailCard` can now participate in
  full-surface card-to-detail transitions.
- Event detail sections now accept an `EventDetailSurfaceStyle` so the same
  overview, stats, when/where, invite, and roster widgets can render on the
  standard light page or the spotlight-dark page without inverting the global
  app theme.

### 2.5.158

- Added the missing event depiction primitives: `EventActionCard` for booked
  event and host-operation lifecycle cards, `EventCompactRow` for dense
  tappable event rows, and `EventDateMarker` for calendar day/week event
  markers.
- `EventFocusRail`, `HostEventToolCard`, `ActivitySection` upcoming-event rows,
  and the Calendar date header now render through those shared primitives
  instead of private one-off card/date-cell widgets.
- Retired `EventHeroTile`, `EventTileStatusBadge`, and `EventTileFactWrap`.
  Spotlight events stay on `CatchEventCard.spotlight`, ticket surfaces stay on
  `CatchEventCard.ticket`, and agenda/list rows stay on `EventDateRailCard`.

### 2.5.157

- Retired `CatchEventCardHero`. The full-bleed photo hero card was a
  pre-spotlight Explore refactor artifact with no remaining production callers;
  featured events now use `CatchEventCard.spotlight` and map/rail events use
  `CatchEventCard.ticket`.

### 2.5.156

- Retired `CatchEventCardPeek`. The Explore map sheet now uses
  `CatchEventCard.ticket` for the nearby rail and for selected non-spotlight
  pins, while preserving `CatchEventCard.spotlight` only when the selected pin
  is the feed's actual featured event.

### 2.5.155

- Removed the obsolete standalone `/map` nearby-events route and deleted
  `EventMapSheet`. Event detail directions continue through
  `EventLocationMapScreen`, while Explore keeps using `EventMapView` as a
  sheetless map canvas behind its own draggable browse sheet.

### 2.5.154

- Consolidated the shared atoms behind club and event card variants. Club list,
  Explore mixed-feed clubs, and club-detail host rows now reuse
  `club_identity_atoms.dart`; event cards and agenda rows share
  `EventCapacityPresenter`, `EventActivityStamp`, `EventClockMark`,
  `EventCapacityProgress`, and `EventStatusPill` instead of duplicating
  member labels, host rows, status pills, going/left copy, clocks, and progress
  bars.

### 2.5.153

- Retired the redundant event-card variants `CatchEventCardCompact`,
  `EventRailTile`, and `EventMapTile`. Agenda and Explore list rows now use
  `EventDateRailCard`; the map bottom sheet dropped its separate `EventMapTile`
  and `EventRailTile` family before the later ticket-card rail consolidation.

### 2.5.152

- Extracted the Explore mixed-feed event row into `EventDateRailCard`.
  `EventAgendaTile` now renders Calendar, Saved Events, and club schedules
  through the same date-rail card instead of the older agenda-only layout.

### 2.5.151

- Consolidated the agenda-card wrapper. `EventAgendaSliverList` now renders
  `EventAgendaTile` directly from `EventTileData.fromEvent(...)`; there is no
  separate `EventAgendaCard` variation to catalog or modernize.

### 2.5.150

- Event detail's hero app bar is now title-only in the expanded state. Date,
  time, location, and current-viewer booking state stay in the overview cards
  and bottom CTA instead of being repeated over the activity artwork.

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
  lives inside the Home dashboard body.

### 2.5.147

- Dashboard recommended events now use the production `CatchEventCard.ticket`
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
  `CatchPolaroid`, `ClubPolaroidArtwork`, and `ClubCoverVisualPalette`,
  keeping the no-cover colors and fallback imagery in one iterable schema.

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
  keeps the thresholds testable, and `ExploreScreen` listens only while the
  full/list sheet state is active.

### 2.5.140

- Production Explore now uses the activity-coded event-card direction from the
  concept lab. `EventActivityVisualSpec` centralizes the mutable `ActivityKind`
  palette/backdrop/icon mapping, `CatchEventCard.ticket` and
  `CatchEventCard.spotlight` render the production feed and selected-pin cards,
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
- `ExploreBrowseHeaderContent` and `ExploreFilterRail` now accept
  parent-supplied background colors so Explore can fade the outer chrome away
  while keeping the city, search, and filter controls floating over the map.

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

- Explore's production provider seam is now `ExploreFeedViewModel`, with
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
  to the half-open sheet and shows a selected-event lead. The lowest peek snap
  now stays map-first with only aggregate result summary copy instead of a
  horizontal card rail.
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
  old static nearby-events sheet inside the Explore surface.
- Historical note, superseded by 2.5.155: `EventMapView` briefly had an
  optional built-in nearby-events sheet for the standalone map route. That
  route/sheet pair has now been retired.

### 2.5.118

- Explore filters now model time as an explicit `ExploreTimeFilter` instead of
  a single club-era `thisWeekOnly` flag. Tonight, Tomorrow, Weekend, and This
  week chips share one provider state across the event feed and club directory.
- `ExploreFilterRail` has a stable scroll key so widget tests and future UI
  automation can target the horizontal filter rail without positional finders.

### 2.5.117

- The bottom navigation and Explore browse header now present the branch as
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

- Explore now owns the list/map mode switch. List mode remains a club
  directory with quick filters, while map mode embeds the reusable event map so
  pins represent upcoming events rather than clubs.
- Historical note, superseded by 2.5.155: the old standalone map route once
  delegated its body to reusable `EventMapView`, before that route was retired.
- Dashboard quick actions no longer expose Map view; dashboard keeps Calendar
  and Saved events while spatial discovery lives under Explore.

### 2.5.107

- Notifications now separate signed-up upcoming events from durable recent
  notification history. `ActivitySection` renders upcoming event tiles first,
  then groups backend-owned notification updates with typed badges and compact
  icon chips.
- The old vertical Activity timeline connector has been removed from the
  Notifications screen; rows now use `CatchSurface` and `CatchBadge` so the
  route matches the current Catch design primitives.

### 2.5.106

- Explore browse now keeps search reachable even when the selected city has no
  clubs, adds a sliver-native quick-filter rail for upcoming, rating, joined,
  hosted, activity, and neighborhood filters, and clears city-local filters
  when the city changes.
- Club directory cards now surface next-event and review-count context in the
  card body, and the Explore list loading state uses card-shaped skeletons that
  match the loaded directory layout.
- Explore empty states now distinguish empty city, no-search-result, and
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

- Explore `ExploreCityPicker` closed state is now an icon-only circular control. The
  full city name stays in tooltip, semantics, and the selection sheet so long
  city labels cannot push the browse title across the header.
- Browse search chrome now morphs the circular search action into the full
  search field from the same right-aligned control. It no longer renders an
  in-app keyboard-hide button; search dismissal uses the field's platform Done
  action, clear button, and focus loss.
- Explore and Chats search fields both request `TextInputAction.done`, so the
  platform keyboard owns the dismissal affordance while the pinned browse row
  stays visually consistent across tabs.

### 2.5.100

- Chats now composes the shared browse-search behavior in the pinned sliver
  slot. The header owns title/subtitle plus a top-right search action; search
  expands into the full row with the same animated behavior as Explore.
- Removed the chat-count badge from the Chats header. Conversation counts stay
  in list/body context instead of competing with the primary header action.

### 2.5.99

- Explore keeps the consolidated browse header in the pinned sliver slot so the
  city picker, title/subtitle, search action, and expanded search field remain
  sticky while the club list scrolls.

### 2.5.98

- Explore browse now uses a compact city-code picker (`IDR`, `HYD`, etc.) with a
  location icon so short and long city names reserve the same header width.
- Browse-header search opens with a shared motion transition and uses a
  same-height keyboard-dismiss control instead of a back button beside the
  search field.
- `CatchField` now defaults to a platform done action and unfocuses on
  submit/tap-outside so app keyboards have a shared dismissal path.
- `ClubPolaroidArtwork` no longer renders generated initials artwork. No-photo
  club tiles use a quieter map-style fallback with a location mark.

### 2.5.97

- Added a shared self-contained browse-tab header path for title, scope picker,
  search expansion, and actions in one module.
- Explore now uses the browse header instead of a separate title row plus pinned
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
- The now-retired profile inline text-entry wrapper requested focus after the
  expansion frame instead of using immediate `EditableText.autofocus`,
  preventing first-tap keyboard/focus flicker while the row opened.
- Edit Profile row icons stay on the muted field-icon color even when the row
  is an add affordance; only the add value text uses primary color.

### 2.5.88

- Club detail now supports multi-host presentation. `ClubDetailBody` renders
  every `ClubHostProfile` and exposes host-message actions for signed-in
  non-host viewers; owner-only add/remove/transfer controls backed by
  `HostTeamManagementController` now live in the Host app Clubs tab.
- Club create/edit now separates event-success defaults into
  `ClubEventSuccessDefaultsStep`, making the club wizard four steps for owners
  while co-host edit mode narrows to media updates only.
- Added `FormStepSpec` helpers in `form_step_flow.dart` so create-club and
  create-event flows share step title/key lookup instead of hand-written
  switch statements.

### 2.5.87

- Added `CatchSection` as the shared polished content-section wrapper:
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
  `HostClubToolsPanel`, and `host metric` wrappers. Screens now import the
  host widgets they use directly.
- Host attendance-window state now lives in
  `lib/hosts/domain/host_attendance_window.dart`, and Dashboard host tools split
  active and past hosted events into a segmented Host operations rail.

### 2.5.81

- `HostEventManageScreen` is now the canonical per-event host workspace with
  lifecycle sections: Setup, Live, and Report. The old event-success and
  attendance route paths remain as aliases that open Host Manage with the
  relevant lifecycle section selected.
- Club detail no longer owns host-operation CTAs. Host app Events owns Add
  event and event management rows, while Host app Clubs owns profile, payouts,
  and host-team management. The old `HostStatsBar` compatibility wrapper was
  removed.
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
  `HostTeamManagementSection`, `HostEventAttendancePanel`, `HostStatChip`, and
  `HostToolPalette`.
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

- Event card architecture now uses a small tile catalog under
  `lib/events/presentation/widgets/event_tiles/`: `EventTileData`,
  `EventDateRailCard`, `EventAgendaTile`, `EventActionCard`,
  `EventCompactRow`, and `EventDateMarker`.
- Calendar, Saved events, club schedules, Explore list rows, and Map browse
  cards now render through shared card primitives while their providers/view
  models own club-name and relationship-state lookup.
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

- `CatchField` keeps one fixed-width chevron slot across collapsed and
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

- `CatchField.select` separates trigger radius from popup radius. Pill triggers
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

- `ProfileInlineTextValue` supports multiline row-owned editing through
  `CatchField.input`; the inline drawer below the row is reserved for
  validation/save feedback and `Cancel`/`Done`, not a second boxed text field.
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
- `CatchPersonRow` unread state is row-level and conversation-level: warm surface
  tint, primary border, avatar ring, stronger text, and a visible unread chat
  pill by the timestamp. Do not show per-message counts or mark the user's own
  latest message as unread.

### 2.5.49

- Edit Profile bio now used the same row-owned inline disclosure contract as
  other profile fields. The now-retired profile inline text-entry wrapper
  supported multiline row-owned editing for long text such as Bio.
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
  `startingPointLat` and `startingPointLng`. `EventDetailItinerary` and
  `EventDetailMapCard` own the conditional chevron/tappable rows, while
  `EventDetailScreen` owns navigation to the neutral
  `/events/:eventId/location` route-backed `EventLocationMapRouteScreen`; do
  not show chevrons for address-only events.

### 2.5.44

- `DashboardFull` header avatar now uses the current user's
  `primaryPhotoThumbnailUrl` with full-photo fallback and is an explicit button
  to the Profile tab. Tiny avatar-scale surfaces should prefer thumbnail URLs;
  backend thumbnail generation/backfill landed in 2.5.48.

### 2.5.43

- `ChatsListScreen` remains a `CustomScrollView` with a shared
  `CatchSliverHeader`, but the populated body is now sliver-native too:
  `ChatsListBody` returns a `SliverMainAxisGroup`, new matches are folded into
  `ChatConversationsList`, and `ChatConversationsList` owns a real `SliverList`.
  Do not reintroduce a shrink-wrapped vertical `ListView` for the inbox.
- `CatchPersonRow` is a full-width `CatchSurface` row using `PersonAvatar` and
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

- Added `ProfileInlineTextValue` for row-owned Profile text editing. It renders
  the collapsed value directly and delegates active text entry to
  `CatchField.input` so cursor, underline chrome, focus, validation, and
  formatter behavior stay in the shared field primitive.
- The now-retired profile inline text-entry wrapper used that inline value
  wrapper instead of embedding feature-local text-field chrome. Long text row
  variants such as Bio used the same row-owned editable value contract.
- The scroll-away Profile title header now owns only the Settings action. Review
  history, payment history, and sign out moved to `SettingsScreen` Account rows.

### 2.5.38

- Profile inline editor bodies now keep collapsed and expanded drawers
  full-width and uses fade-only body content transitions while `AnimatedSize`
  owns the vertical reveal. This prevents profile inline action rows from
  sliding sideways during text/chip drawer open/close.
- Profile inline editors now share one internal panel for save errors,
  vertical padding, and `Cancel`/`Done` actions. Field-specific editors should
  provide only their controls and draft-state logic.
- Bio editing uses the shared profile inline editor body too, so edits follow the same
  drawer motion contract as grouped profile rows.
- Removed stale catalog references to the deleted profile bottom-sheet editor
  classes. Normal profile field editing is inline; future exceptions should be
  explicit route/dialog flows, not a resurrected generic field sheet.

### 2.5.37

- Added shared profile inline editor shell helpers for Edit Profile drawers.
  Text and enum row editors now route through that shell, so height/range
  drawers use the same open/close motion.
- `CatchField`-backed profile rows now animate row-height changes, row value swaps, and
  chevron rotation with `CatchMotion.base`, which covers text-field entry,
  selected chip wrapping, and dynamic chip list changes without custom
  animation controllers.

### 2.5.36

- `CatchField` value text now gets a real right-hand value lane when no custom
  trailing widget is supplied. Label/value rows therefore keep the primary
  label pinned left and the secondary value pinned right, while switch/trailing
  rows keep their existing trailing-widget behavior.

### 2.5.35

- Added `ProfileInlineSingleChoiceEntryEditor` and
  `ProfileInlineMultiChoiceEntryEditor` for Profile enum rows. These editors
  render selected `CatchChip` values inside the `CatchField` value editor
  slot, exclude selected values from the option list below the row, and keep
  `Cancel`/`Done` as the commit boundary.
- `ProfileInlineSingleChoiceEditor` and `ProfileInlineMultiChoiceEditor` were
  removed from Profile row usage so chip fields follow the same in-row editing
  model as text fields.

### 2.5.34

- `CatchField` now supports an optional value editor slot for in-row
  editing. When present, the tile replaces its value text with the supplied
  control and shows a small collapse icon button instead of wrapping the whole
  row in an `InkWell`, so the embedded field can receive focus.
- Added the now-retired profile inline text-entry wrapper, which rendered text
  Profile rows with a compact label-less `CatchField` in the value position and
  kept error/actions below the row. This was superseded by 2.5.49 for long text,
  which used the same row contract with a multiline body editor.

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

### 2.5.32

- `CreateClubScreen` now exposes deterministic preview knobs for
  `initialDraft`, `initialStep`, and saved-draft restoration. These are used by
  Widgetbook and UI captures to render each create-club wizard state without a
  simulator route loop.
- Added `HostClubCreateState` as the create/edit club display adapter for step
  title, subtitle, progress, edit-scaffold selection, save-draft availability,
  footer label, and loading state. Draft/media/validation callbacks remain the
  next adapter migration target.
- Added `HostClubEditState` to the edit-club route so owner, co-host media-only,
  identity-loading, and forbidden identity modes are resolved before the editor
  renders. Non-host deep links now see explicit host-access copy instead of the
  owner edit form.
- `CatchFormFieldLabel`, `OrderedPhotoPicker`, and
  `CreateClubPhotosPicker` now degrade visible helper labels/badges in tight or
  high text-scale layouts while retaining semantic labels/tooltips.
- Added `HostEventEditState` for `screen.host.event.edit` route provider waves,
  host access, and schedule/policy lock rules. Widgetbook and captures now cover
  route loading/error/not-found/unauthorized, editable form, locked form,
  cancelled form, text scale, reduced motion, and dark theme.

### 2.5.31

- `ChipField` now supports `showLabel`, defaulting to `true` for standalone
  form usage. Expanded Profile inline editors opt out because the parent
  `CatchField` already provides the visible field label.

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
  `CatchSection`/`CatchField` composition can host an expanded editor below a
  row, and `CatchField` shows expanded state instead of always implying a
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

- Edit Profile exposes `Display name` as the first About field. It is the
  editable public-facing name used by profile preview/public profile surfaces,
  initializes from onboarding first name, trims on save, and rejects blank or
  whitespace-only values. Legal identity fields from onboarding remain separate:
  date of birth and gender stay readonly, and last name is private. As of
  2.5.444, Display name and the other simple text fields render directly as
  editable `CatchField.input` rows, not disclosure drawers.

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
- `AppShell` no longer prewarms the Explore stream. Explore, Catches, Chats,
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
   primitives include `CatchSurface`, `CatchButton`, `CatchField`,
   `CatchTopBar`, `CatchBottomSheetScaffold`, `CatchEmptyState`,
   `CatchHorizontalRail`, `CatchVerticalSection`, `PersonRow`, `PersonAvatar`,
   event tile variants, `CatchField`, `CatchSection`, `CatchSkeleton`, `CatchBadge`,
   `CatchFormFieldLabel`, `ChipField`, `EventAgendaList`,
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
  tile variant, `CatchField`, `CatchSection`, `PersonRow`, or another existing
  primitive fits.
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
  under `lib/core/theme`; brand/display and club identity treatments route through
  `CatchFonts`/`CatchTextStyles` instead of local `GoogleFonts.getFont` calls.
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

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ForceUpdateCheckErrorScreen` | `lib/app.dart:150` | Error screen shown when the force-update check fails. Displays a "Could not verify app version" message with a retry button and optional diagnostic info. |

---

## Core — Presentation (AppShell & Routing)

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShell` | `lib/core/presentation/app_shell.dart:34` | Main tab shell with adaptive bottom navigation (Home, Explore, Catches, Chats, You): native `CupertinoTabBar` on iOS and Material 3 `NavigationBar`-backed `CatchTabDock` elsewhere. Watches provider-backed connectivity for the offline app notice, initializes FCM through `appShellFcmInitializationProvider`, exposes active-tab state through `AppShellActiveTab`, and keeps Crashlytics/Analytics user IDs synced with auth state. Shell-level streams stay limited to shell-wide UI such as auth, connectivity, FCM, and unread badges. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShellActiveTab` | `lib/core/presentation/app_shell_active_tab.dart:9` | Inherited lifecycle signal for indexed-stack tabs. Lets retained tab branches detect whether they are currently selected without coupling feature screens directly to `StatefulNavigationShell`. |
| `AppShellNavigationBar` / `AppShellNavigationItem` | `lib/core/presentation/app_shell.dart:210` | Shared adaptive bottom-navigation primitive with stable key, destination-driven labels/icons, and unread badge handling. Consumer shell uses the default Home / Explore / Catches / Chats / Profile set; `HostAppShell` supplies Events / Clubs / Inbox / Account through the same native iOS `CupertinoTabBar` chrome and Material 3 `NavigationBar`-backed chrome elsewhere. |
| `AppShellNavigationBadge` | `lib/core/presentation/app_shell.dart:333` | Shell unread badge. Reserves a fixed icon box and positions the pill inside it so Cupertino and Material bottom nav containers cannot clip the count. |
| `CatchStartupLoadingScreen` | `lib/core/widgets/catch_startup_loading_screen.dart:5` | Shared route/startup loading surface used during role, route, and force-update async resolution. |

---

## Core — Design System Widgets

### Widgetbook-only foundation review surfaces

| Widget | File | Purpose |
|---|---|---|
| `FoundationColorTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:87` | Widgetbook-only foundation specimen for semantic light/dark color roles and generated activity pigments. Reads `CatchTokens` and `ActivityPalette` directly so designers can review color roles without duplicating token values. |
| `FoundationSpacingTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:135` | Widgetbook-only foundation specimen for spacing scale, semantic gaps, and inset roles. Renders live `CatchSpacing`, `CatchGaps`, and `CatchInsets` values. |
| `FoundationShapeTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:209` | Widgetbook-only foundation specimen for radius, elevation, and opacity roles. Renders live `CatchRadius`, `CatchElevation`, and `CatchOpacity` values. |
| `FoundationTypographyTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:266` | Widgetbook-only foundation specimen for all 54 public `CatchTextStyles` helpers. Renders live samples with concrete family, size, weight, height, and tracking metadata so Archivo brand/display, platform app/body, mono data, and technical roles can be reviewed directly. |
| `FoundationIconMediaTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:376` | Widgetbook-only foundation specimen for icon sizing, media aspect ratios, and activity glyph mapping. Renders live `CatchIcon`, `CatchAspectRatio`, and `ActivityPalette` values. |
| `FoundationStrokeMotionTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:435` | Widgetbook-only foundation specimen for stroke widths, motion durations, and shared motion curves. Renders live `CatchStroke` and `CatchMotion` values. |
| `FoundationDataPhotoTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:490` | Widgetbook-only foundation specimen for data-pair layout and display-time photo grading. Renders `CatchMetricStrip`, `CatchGrade`, and `CatchPhotoGradeColors` without duplicating photo-grade constants. |
| `FoundationBrandTokens` | `widgetbook/lib/foundation/foundation_token_use_cases.dart:513` | Widgetbook-only foundation specimen for the typographic brand wordmark. Renders Archivo `Catch`, dotted `Catch.`, and dark-surface treatments from live `CatchTextStyles`/`CatchTokens` values rather than a separate image asset. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchField` | `lib/core/widgets/catch_field.dart:27` | Canonical flat field primitive for row, text-entry, navigation, toggle, expanded-control, add, validation, helper, clearable, and suffix-action states. Use the named constructors (`read`, `nav`, `toggle`, `input`, `select`, `expanding`, `add`) so call sites choose one field family explicitly; the shared implementation constructor is private. The field owns the stable anatomy of optional leading icon, label/value column, optional right value/action/chevron/toggle trailing slot, and field-owned helper/error text. `CatchField.nav` accepts `chevronOpen` for shared expanded-state right-chevron rotation; icon-only trailing slots stay pinned to the row edge, while `valueText` metadata keeps a bounded flexible lane on narrow widths. Rounded section, focus, and error container chrome belongs to `CatchSection`, not the field itself. Registered as formal component contract `catch.field`; Widgetbook contract states are the canonical review surface. |
| `CatchFieldRow` | `lib/core/widgets/catch_field.dart:1844` | Public `catch.field` member for the shared field-row anatomy: optional leading slot, content slot, optional trailing slot, add-row padding, and row tap handling. Use through `CatchField` in product UI unless a primitive contract preview or a new field-family member needs the raw row shell. |
| `CatchFieldTrailing` | `lib/core/widgets/catch_field.dart:1920` | Public `catch.field` trailing-slot member for bounded value text, fixed/rotating chevrons, toggles, clear actions, valid-state icons, and custom trailing content. Product call sites should prefer `CatchField` modes; this member exists so the field anatomy has exact contract coverage. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, `danger`, and `light` variants; activity-accent primary fills via `accentColor`; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; optional leading icons; and `isInteractive: false` for button-looking labels inside an already tappable parent. Button height is fixed to the selected token size so full-width footer buttons do not expand in unconstrained bottom bars. Use `light` for solid-white pill CTAs so foreground/background colors stay paired across light and dark themes. |
| `CatchActionMenu<T>` | `lib/core/widgets/catch_action_menu.dart:24` | Anchored overflow trigger for action menus. Opens the shared handoff `CatchMenu` panel from an `IconBtn`, supports icons, sublabels, selected rows, disabled rows, destructive rows, and typed selected values. |
| `CatchField.select<T>` | `lib/core/widgets/catch_field.dart` | Canonical select-mode factory on `CatchField`. Supports token-driven flat trigger/menu composition, compact/md heights, optional prefix icons, disabled/error states, controlled value syncing, and validation messaging without a separate dropdown/select primitive. |
| `CatchSearchField` | `lib/core/widgets/catch_search_field.dart:8` | Handoff `SearchField`: raised pill browse input with search glyph, controlled value sync, quiet clear target when non-empty, optional empty-state trailing action for composed search chrome, platform Done submit, focus callbacks, and semantic labeling. Use instead of `CatchField` for label-less browse/search affordances. |

### SingleChildRenderObjectWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchPagerFocusBoundary` | `lib/core/widgets/catch_pager_focus_boundary.dart:5` | Shared focus boundary for pages inside horizontal pagers. Lets inner vertical scrollables satisfy text caret and focus `showOnScreen` requests while preventing those requests from bubbling into `PageView`/`TabBarView` shells and exposing adjacent pages. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical low-level surface primitive. Supports base `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `card`, `raised`, and `overlay` elevations; optional border, gradient background, radius, clip, and tap handling via `InkWell`. Named modes cover bounded cards (`.card`), quiet tinted inset notes (`.tinted`), and inline icon/title/message notes (`.message`); section-card content chrome belongs to `CatchSection.contained`. |
| `CatchMenu<T>` | `lib/core/widgets/catch_menu.dart:27` | Handoff `Menu`: anchored dropdown panel with overlay surface, line2 border, radius-md corners, row hairlines, optional leading icon, mono sublabel, selected check mark, danger tone, and typed selection callbacks. |
| `CatchSearchField` expanding mode | `lib/core/widgets/catch_search_field.dart` | Handoff `ExpandingSearch`: app-bar search primitive that starts as a single magnifier target, expands to fill the available header width, composes `CatchSearchField`, clears non-empty queries first, and exposes a close target for empty expanded search. Used by feature browse headers such as Chats and Explore. |
| `CatchKicker` | `lib/core/widgets/catch_kicker.dart:5` | Handoff `Kicker` leaf: uppercase mono eyebrow for section starts and editorial labels, with optional color override and `md` / `lg` sizes. Used by shared section and info-group composition. |
| `CatchMonoLabel` | `lib/core/widgets/catch_mono_label.dart:5` | Single-line mono text leaf for compact metadata in dense cards and rails. Use when a small metadata string needs the shared mono label style and ellipsis behavior without restating local `Text` setup. |
| `CatchSectionLabel` | `lib/core/widgets/catch_section_label.dart:7` | Handoff activity-accent eyebrow for section starts inside panels. Carries one accent color through an optional leading glyph and mono kicker label, with bounded ellipsis behavior for long labels. |
| `CatchJourneySteps` | `lib/core/widgets/catch_journey_steps.dart:20` | Handoff `JourneySteps`: numbered, line-traced sequence for ordered onboarding, dashboard, and event-flow guidance. Renders mono auto-numbered indices, an accent node rail, function-font titles, optional body copy, and source-owned spacing. Registered as formal component contract `catch.journey_steps`; Widgetbook contract states are the canonical review surface for numbered trace, titles-only, accented, and long-copy sequences. |
| `CatchDetailHeroBackdrop` | `lib/core/widgets/catch_detail_hero_backdrop.dart:4` | Shared photo-or-branded-fallback backdrop for detail-page heroes. Used by club and event detail headers so no-photo states share the same dark branded gradient and scrim treatment. |
| `CatchMetricStrip` | `lib/core/widgets/catch_metric_strip.dart:21` | Canonical metric rail for compact value-over-label stats. Owns the surface, border, spacing, hairline dividers, mono value styling, optional unit styling, label truncation, and surface/color overrides so club and event detail stats cannot drift. Registered as formal component contract `catch.metric_strip`; Widgetbook contract states are the canonical review surface. |
| `CatchMiniBarChart` | `lib/core/widgets/catch_mini_bar_chart.dart:5` | Compact mini bar-chart primitive for trend summaries inside dense metric panels. Owns the surface, border, content padding, bar spacing, zero-value treatment, tokenized fill/empty colors, and semantic label wrapper so insights and dashboard panels do not hand-roll tiny chart chrome. Registered as formal component contract `catch.mini_bar_chart`; Widgetbook contract states cover default, empty, zero-value, color-override, and semantic-label states. |
| `CatchTextButton` | `lib/core/widgets/catch_text_button.dart:6` | Canonical text-only action primitive for inline actions, dialog actions, retry links, and top-bar text actions. Uses Catch tokens and text styles while preserving Material `TextButton` semantics. Use `CatchButton` for pill CTAs. |
| `CatchCodeInput` | `lib/core/widgets/catch_otp_code_field.dart:9` | Handoff `CodeInput`: static controlled verification-code row with 6-cell default, mono digits, 64px surface cells, 10px gaps, interactive-tile radius, ink active rule, and optional caret. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:50` | Canonical OTP input primitive. Composes `CatchCodeInput` visuals over one hidden platform `TextField` so SMS autofill, paste, keyboard input, tests, digit-only filtering, and length limiting stay centralized. |
| `CatchNumberStepper` | `lib/core/widgets/catch_number_stepper.dart:6` | Canonical numeric +/- stepper. Renders the shared raised `CatchControlShell`, compact add/remove buttons, centered mono value, optional min/max/step clamping, and feature-specific value formatting. Used by event duration and profile height controls. |
| `CatchRangeSlider` | `lib/core/widgets/catch_range_slider.dart:7` | Canonical range slider. Wraps `RangeSlider` in the shared tickless slider theme so age/pace sliders keep discrete values without rendering dashed tick marks. Supports optional min/max endpoint labels for fixed slider bounds. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:23` | Handoff `AppBar`: compact or large screen header with shared title/subtitle/kicker text roles, `CatchTopBar.identity` conversation/profile title rows with avatar and optional identity tap, back/close/none leading modes, surface/divider/gutter ownership, configurable content padding and safe-area ownership for app bars or pinned sliver slots, constrained text/icon/trailing actions, optional tab bottom, and controlled or uncontrolled `CatchSearchField` expanding mode composition. Implements `PreferredSizeWidget` for use as a Flutter `appBar`; `catch.top_bar` contract states are the canonical review surface for top-bar chrome. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:427` | Adaptive top-tab primitive for use inside `CatchTopBar.bottom` or sticky sliver headers. Uses Material `TabBar` with primary indicator on Android/non-iOS platforms and `CupertinoSlidingSegmentedControl` on iOS. Implements `PreferredSizeWidget` and accepts an optional explicit `TabController` for sliver-native tab rows that are not inside a `DefaultTabController`. |
| `showCatchAdaptiveDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:24` | Shared platform-adaptive confirmation/dialog helper. Renders `CupertinoAlertDialog` on iOS and the handoff `CatchConfirmDialog` card on Material platforms, with typed action values plus default/destructive action metadata. |
| `showCatchConfirmDialog` / `CatchConfirmDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:62` | Handoff confirm-dialog API and Material card primitive. Provides default Cancel/Confirm labels, optional danger-filled commit action, centered `CatchSurface` card, 46% ink scrim, 320px max width, and tokenized card padding. |
| `CatchFormDialog` | `lib/core/widgets/catch_adaptive_dialog.dart:138` | Shared Catch modal shell for short form dialogs that need custom content plus tokenized dialog actions. Uses the same `CatchSurface`, scrim, max width, title role, and card padding as confirm dialogs; screens provide canonical inputs/actions such as `CatchField` and `CatchTextButton` rather than raw Material dialog chrome. |
| `showCatchDatePicker` / `showCatchTimePicker` | `lib/core/widgets/catch_adaptive_picker.dart:7` | Shared platform-adaptive date/time picker helpers. iOS renders bottom-wheel `CupertinoDatePicker` sheets with Cancel/Done toolbar; Android/non-iOS platforms keep Flutter's Material calendar and clock pickers. |
| `CatchSliverHeader` | `lib/core/widgets/catch_top_bar.dart:290` | Shared sliver header primitive. Builds a scroll-away title and optional pinned bottom row; the title translates upward as it collapses so sticky search/filter/tab rows do not visually cover it. Use `twoLineTitleHeight` for short title/subtitle headers, `wrappedTitleHeight` only when long titles need the extra space, and the shared search-row spacing constants before adding feature-local search/list gap math. Used by Run Clubs, Chats, and Profile. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:560` | Overflow menu action for `CatchTopBar`. Delegates to `CatchActionMenu`, so top-bar overflow actions open the shared handoff `CatchMenu` panel from an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:593` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`; accepts an optional explicit size for overlay rows that must align with floating controls without changing the default app-bar button size. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:632` | Text action button for `CatchTopBar` (e.g., "Save", "Done", "Mark all read"). Delegates to `CatchTextButton` inside the constrained top-bar trailing region so long labels ellipsize at compact width and large text scale. |
| `CatchStepHeader` | `lib/core/widgets/catch_step_flow_header.dart:8` | Handoff `StepHeader`: wizard scaffold header composed from large `CatchTopBar`, optional kicker/subtitle, top-right mono step counter or custom trailing status, and a 2px progress hairline. |
| `CatchStepFlowHeader` | `lib/core/widgets/catch_step_flow_header.dart:85` | Backward-compatible zero-based wrapper over `CatchStepHeader` for existing onboarding, create-club, and create-event flows. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:48` | Pill-style segmented control. Supports compact or full-width expanded layouts, icon-only, label-only, or icon+label segments, and filled or raised-surface selected styles. Used for lifecycle/workspace switching where tapping a segment changes the content below. |
| `CatchOptionGroup<T>` | `lib/core/widgets/catch_option_group.dart:16` | Design-system `OptionGroup` port: an underline selection row for tabs, lenses, and inline scope controls. Supports label or mono typography variants, optional selected-rule accent, optional trailing content, semantic selected state, tokenized gap/underline spacing, and tight-width label flex/ellipsis so floating rails do not overflow. Use when the handoff calls for `OptionGroup`; use `CatchSegmentedControl` only for pill-style segmented controls. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.box()` with optional border color, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchHorizontalRail` | `lib/core/widgets/catch_horizontal_rail.dart:12` | Section with a `CatchSectionHeader` title and a horizontally-scrolling `ListView.separated` of items. Supports optional trailing content and custom header/list padding for embedded layouts. |
| `CatchVerticalSection` | `lib/core/widgets/catch_vertical_section.dart:25` | Section with a `CatchSectionHeader` title and a vertical `ListView.separated` of items (non-scrollable, meant for embedding in a parent scroll view). |
| `CatchLoadingIndicator` | `lib/core/widgets/catch_loading_indicator.dart:3` | Simple centered `CircularProgressIndicator` for use during async loading states. |
| `CatchStartupLoadingScreen` | `lib/core/widgets/catch_startup_loading_screen.dart:6` | Branded startup/loading scaffold used before router or host-create route data is ready. Centers the Catch icon asset on the primary fill and uses a bounded `CatchLoadingIndicator` so launch/loading states share one composition. |
| `CatchFrameworkErrorView` | `lib/core/widgets/catch_framework_error_view.dart:11` | Branded fallback view used by `ErrorWidget.builder` for Flutter framework/build errors. Shows user-safe recovery copy and keeps debug exception details behind a tokenized `CatchSurface` disclosure in debug builds rather than Material expansion chrome. Keep separate from app-facing error surfaces because the normal widget tree may already be unstable. |
| `CatchErrorIcon` | `lib/core/widgets/catch_error_icon.dart:7` | Shared branded error medallion used by framework and app-facing error surfaces. Treat as an atom composed by error surfaces, not a separate product component to review in Widgetbook. |
| `CatchErrorState` | `lib/core/widgets/catch_error_state.dart:13` | Canonical branded app-facing error content. Supports full-screen, inline, and compact modes, mapped title/message copy, optional retry, and optional secondary action. Owns the shared internal resolved spec and body renderer used by the placement adapters. Widgetbook groups this family as the single "Error surfaces" review point. |
| `CatchErrorScaffold` | `lib/core/widgets/catch_error_state.dart:203` | Full-screen/root-tab placement adapter for load failures. Keeps framework crashes separate from app data-load failures while reusing the shared `CatchErrorState` body implementation. |
| `CatchSliverErrorState` | `lib/core/widgets/catch_error_state.dart:269` | Sliver-native placement adapter for branded load failures. Uses `SliverFillRemaining` by default and supports retry callbacks for provider invalidation while reusing the shared `CatchErrorState` body implementation. |
| `CatchInlineErrorState` | `lib/core/widgets/catch_error_state.dart:340` | Section/card placement adapter for branded load failures. Reuses the shared `CatchErrorState` body in inline or compact mode when the rest of the screen remains usable. |
| `CatchAsyncValueView<T>` | `lib/core/widgets/catch_async_value_view.dart:26` | Generic widget handling `AsyncValue` states for route and section bodies. Supports legacy `data/loading/error` callbacks, context-aware `builder/loadingBuilder/errorBuilder` callbacks, Riverpod skip flags, branded `CatchErrorState.fromError` defaults, and retry callbacks for provider invalidation. Empty success states stay in the data callback. |
| `CatchAsyncValueSliver<T>` | `lib/core/widgets/catch_async_value_view.dart:83` | Sliver equivalent of `CatchAsyncValueView`. Supports sliver-native data, loading, and error builders plus branded `CatchSliverErrorState.fromError` defaults for scroll-owned surfaces. |
| `CatchAsyncScreenLoading` | `lib/core/widgets/catch_async_value_view.dart:159` | Route/body loading placement helper that wraps `CatchSkeletonList` in `CatchScreenBody` so async screen loading states use the shared gutter and scroll safely on compact surfaces. |
| `CatchAsyncSliverLoading` | `lib/core/widgets/catch_async_value_view.dart:183` | Sliver loading placement helper that wraps `CatchSkeletonList` in `CatchSliverPageBody` for `CustomScrollView` screens. |
| `CatchFormFieldLabel` | `lib/core/widgets/catch_form_field_label.dart:5` | Styled form field label with an optional badge (e.g., "Optional"). The semantic label always includes optional status; the visible optional badge collapses at large text scale so narrow forms can ellipsize the label without overflow. |
| `CatchControlShell` | `lib/core/widgets/catch_control_shell.dart:50` | Shared single-line control shell for fields, select triggers, picker tiles, map pin tiles, and steppers. Owns the fill, border, focus ring, radius, and size metrics. Use `floating` for overlay chrome, `compact` for dense header/search controls, and `md` for regular form controls. Registered as formal component contract `catch.control_shell`; product UI should still prefer higher-level field, search, select, or stepper APIs. |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Handoff `Chip` fact/filter pill. Supports resting surface fill, selected transparent fill with a 1.5px ink rule, optional activity tint/ink colors, tap behavior, and an optional remove button. Used in `ChipField` and independently for static or interactive fact tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `CatchSelectChip` | `lib/core/widgets/catch_select_chip.dart:8` | Handoff tactile selectable pill for questionnaire answers, mission choices, and choosy filters. Supports accent selected fill, active glow/scale, pressed scale-down, selected semantics, and tokenized pill surface chrome. |
| `CatchActivityArt` | `lib/core/widgets/catch_activity_art.dart:10` | Handoff generated activity-art surface. Resolves activity pigment and glyph through `ActivityPalette`, renders the gradient, screen-print texture, faint motif glyph, optional dim layer, radius/height controls, and overlay child slot. |
| `CatchPersonAvatar` activity variant | `lib/core/widgets/catch_person_avatar.dart` | Handoff activity-register avatar for people shown in activity-grounded surfaces. Resolves activity pigment through `ActivityPalette`, renders mono initials over an activity gradient with screen-print texture, and supports explicit size, selected/live ring, and dim veil states. |
| `CatchActivityChip` | `lib/core/widgets/catch_activity_chip.dart:8` | Handoff activity tag for typed `ActivityKind` values. Resolves label/glyph/pigment through `ActivityPalette`, supports soft and primary registers, optional label override, and optional tap semantics. Use for registry-backed activity labels instead of feature-local colored chip helpers. |
| `CatchActivityMapPin` | `lib/core/widgets/catch_activity_map_pin.dart:8` | Handoff map pin for activity-colored map marks. Resolves pigment through `ActivityPalette`, supports resting/selected sizing, optional selected flag text, and the subtle pin shadow used on map canvases. |
| `CatchDistanceRing` | `lib/core/widgets/catch_distance_ring.dart:7` | Handoff map radius ring for static map canvases and previews. Renders a 170px default circular ink ring with 1.2px stroke and an optional tappable mono label pill anchored to the top edge. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Handoff `Badge` status pill used for spots-left indicators, distance/pace pills, event requirement chips, status labels, compact metadata, and action-column outcomes. Supports functional tones including `gold`, `size.action` 33px alignment, optional leading icons, optional uppercase labels, and activity-accent tinting. |
| `CatchPrivacyBadge` | `lib/core/widgets/catch_privacy_badge.dart:10` | Quiet outlined handoff privacy pill for visibility hints. Supports `Private to you`, `Catch private`, and `Host can see` modes with lock/eye glyphs, transparent `CatchSurface` chrome, and the shared mono badge text role. Registered as formal component contract `catch.privacy_badge`; Widgetbook contract states are the canonical review surface for private-to-you, Catch-private, and host-visible modes. |
| `CatchCornerSash` | `lib/core/widgets/catch_corner_sash.dart:10` | Single status sash for event/club hero cards when one dominant state should read before supporting metadata. Uses token palettes, optional icon, and asymmetric pill corners instead of competing chip clusters. |
| `CatchCountPill` | `lib/core/widgets/catch_count_pill.dart:12` | Handoff CountPill control for floating Explore affordances. Renders a raised pill with optional icon, optional mono label, optional active-count badge, shared surface/border tokens, and explicit semantic labels. Use for map/list toggles and compact filter entry points instead of feature-local floating pill decorations. |
| `CatchTabDock<T>` | `lib/core/widgets/catch_tab_dock.dart:25` | Handoff `TabDock`: typed bottom-navigation adapter backed by Flutter's Material 3 `NavigationBar` metrics, stable safe-area handling, selected glyphs, typed tab IDs, and optional per-tab `Badge.count` unread indicators. Used by non-iOS `AppShellNavigationBar`. |
| `CatchMetaDotRow` | `lib/core/widgets/catch_meta_row.dart:13` | Inline dot-separated metadata row for event/club cards. Keeps icon/text entries and optional strong trailing meta in one line with ellipsis behavior, so cards can show time, place, distance, and status without bolting on multiple badges. |
| `CatchIconButton` | `lib/core/widgets/catch_icon_button.dart:5` | Handoff `IconButton`: circular glyph target with 44px default, 40px top-bar `navSize`, bordered / float / plain variants, active accent tinting, disabled opacity, and legacy child/custom-background escape hatches for existing app surfaces. |
| `CatchBottomDock.cta` | `lib/core/widgets/catch_bottom_dock.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content, optional activity button accent, optional dark/custom footer colors, and bottom safe-area padding. |
| `CatchBottomDock` | `lib/core/widgets/catch_bottom_dock.dart:6` | Anchored bottom utility surface for chat inputs, compact action strips, filters, and other controls that sit above the device safe area without becoming a full CTA footer. |
| `CatchBottomSheetScaffold` | `lib/core/widgets/catch_bottom_sheet.dart:8` | Handoff `Sheet`: surface bottom-sheet panel with overlay shadow, grabber toggle, plain title/subtitle header, branded glyph-tile header, optional badge/trailing slot, keyboard-safe body padding, content, and optional action slot. |
| `CatchShareCardSheet` | `lib/core/widgets/catch_share_card_sheet.dart:20` | Shared visual-card share sheet. Renders a keyboard-safe bottom sheet with `CatchBottomSheetGrabber`, a bounded `RepaintBoundary` card preview, footnote copy, and a full-width platform-share `CatchButton` that exports the captured card through `ExternalShareController`. `RichShareCardSheetKeys.cardPreview` and `.shareButton` are the stable hooks for tests and future automation. |
| `CatchDraggableSheetShell` | `lib/core/widgets/catch_draggable_sheet_shell.dart:6` | Shared shell for persistent `DraggableScrollableSheet` surfaces. Owns the rounded top edge, border, optional raised shadow, and grabber slot while leaving snap state and scroll content to feature screens. Callers can tune handle opacity and top radius for sheet reveal animations without forking the shell. |
| `CatchCelebrationScreen` | `lib/core/celebration/catch_celebration_screen.dart:37` | Shared full-screen celebration surface for high-emotion completion moments. Feature screens provide moment kind, copy, details, optional supplemental children, and primary/secondary actions; the primitive dispatches celebration effects once after first frame. The default immersive appearance owns the orange full-screen celebration, while the paper appearance provides the Claude-style host confirmation surface with tokenized paper insets, message spacing, detail-row rhythm, lighter separators, and action gap. Solid-white primary actions use `CatchButtonVariant.light` instead of per-screen white/foreground overrides. |
| `PaperCelebrationScaffold` | `lib/core/celebration/catch_celebration_screen.dart:244` | Paper-style celebration layout used by host confirmations. Renders centered icon/title/message content, optional close affordance, tokenized paper insets, `PaperCelebrationDetailsCard`, supporting note text, supplemental children, and primary/secondary actions without playing effects itself. |
| `PaperCelebrationIcon` | `lib/core/celebration/catch_celebration_screen.dart:374` | Circular token-colored icon mark for paper celebration moments. Keeps paper confirmations distinct from the immersive orange celebration icon treatment. |
| `PaperCelebrationDetailsCard` | `lib/core/celebration/catch_celebration_screen.dart:392` | Tokenized white detail card for paper celebrations. Owns row dividers and horizontal padding while delegating each entry to `PaperCelebrationDetailRow`. |
| `PaperCelebrationDetailRow` | `lib/core/celebration/catch_celebration_screen.dart:423` | Paper celebration detail row with optional icon, fixed-width uppercase label, and right-aligned value. Used for event-created confirmation metadata. |
| `CelebrationIcon` | `lib/core/celebration/catch_celebration_screen.dart:461` | Immersive orange celebration icon mark. Uses translucent cream fill/border and dark celebration ink so it remains legible over the hero gradient. |
| `CelebrationDetailsCard` | `lib/core/celebration/catch_celebration_screen.dart:481` | Immersive celebration detail card. Groups `CelebrationDetailRow` entries inside a translucent cream surface with darker separators for full-screen orange moments. |
| `CelebrationDetailRow` | `lib/core/celebration/catch_celebration_screen.dart:513` | Immersive celebration detail row with optional icon, label, and lead-value copy tuned for the orange celebration surface. |
| `CelebrationNote` | `lib/core/celebration/catch_celebration_screen.dart:553` | Immersive celebration note surface. Shows a bolt mark and supporting copy inside a translucent cream bordered panel below the detail card. |
| `CelebrationEffectsController` | `lib/core/celebration/celebration_effects_controller.dart:10` | Central haptic/sound boundary for celebration moments. Currently dispatches haptics by `CelebrationMomentKind`; future sound work should be added here instead of directly in feature widgets. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Handoff `EmptyState`: centered cardless placeholder with optional quiet 34px ink3 glyph, section-title headline, body-small message, 24px horizontal padding, and optional action. It still supports explicit surface/bubble presentation and compact inline layout for embedded contexts, and expands to bounded parent widths before centering content. |
| `CatchDaySectionHeader` | `lib/core/widgets/catch_day_section_header.dart:11` | Sticky day-section header for chronological feeds. Use `CatchDaySectionHeaderDelegate` when the parent owns a flat `CustomScrollView` and pinned day headers are needed; the delegate binds the child height to its sliver extent so pinned geometry stays valid under constrained sheets. |
| `CatchStatusBar` | `lib/core/widgets/catch_status_bar.dart:8` | Handoff `StatusBar`: phone-frame iOS status row with bold mono time, Phosphor fill signal/wifi/battery glyphs, light/dark tone support, and optional surface fill for mock frames and design previews. |
| `CatchEventCard.ticket` | `lib/core/widgets/catch_event_activity_cards.dart:17` | Ticket-style production event card backed by `EventActivityVisualSpec`. Used by Dashboard recommendations, Explore selected non-spotlight map pins, and the Explore nearby map rail so each event type shares the same activity-coded backdrop, shared `EventClockMark`, shared `EventStatusPill`, centralized capacity copy, and optional full-card Hero transition into event detail. |
| `CatchEventCard.spotlight` | `lib/core/widgets/catch_event_activity_cards.dart:133` | Large activity-art production event card for featured Explore items and selected map pins only when the selected pin is the feed's actual featured event. Reuses `EventActivityBackdrop`, supports optional visual or full-card Hero tags for card-to-detail transitions, and keeps non-open states in the kicker slot. |
| `CatchEventThumbnail` | `lib/core/widgets/catch_event_thumbnail.dart:10` | Shared event image primitive. Renders uploaded photos by default, falls back to `EventActivityBackdrop`, supports `preferActivityArtwork` for surfaces that should stay color-coded by event type even when a photo exists, and exposes fallback icon/pattern tuning for large hero bands. |
| `CatchGradedImage` / `CatchGrade` | `lib/core/widgets/catch_graded_image.dart:21` | Non-destructive display-time photo grade. Applies the shared brightness-aware matte duotone through color filters at render time, leaving uploaded images untouched while keeping mixed UGC and generated activity art inside one editorial visual family. Split-tone colors are alpha-aware: multiply and screen tints are derived by lerping from each blend mode's no-op color so low-alpha token values do not wash light-mode photos to white in deterministic captures. |
| `CatchNetworkImage` | `lib/core/widgets/catch_network_image.dart:19` | Canonical remote/bundled image primitive. Keeps the existing decode-size capped `Image.network` path for remote photos, renders `assets/` and `packages/` paths through `Image.asset` for deterministic fixture/capture use, and preserves caller-owned framing, fitting, semantics, loading, and branded fallback behavior. |
| `CatchPageBody` / `CatchScreenBody` / `CatchSectionStack` / `CatchSectionList` / `CatchSection` / `CatchDetailSliverSectionList` | `lib/core/widgets/catch_section_layout.dart:9` | Semantic body and section composition primitives. `CatchScreenBody` maps the handoff scrolling body with `screenPx` gutter, `pt`/`pb` overrides, full-bleed gutter opt-out, and optional non-scroll mode; `CatchSectionStack` maps the handoff `SectionStack` gutter and defaults to no inserted section gap; `CatchSection` is the canonical information-grouping primitive with named constructors for divided hairline groups, contained rounded groups, and plain titled blocks, plus optional count/trailing content and optional lead activity accent; `CatchDetailSliverSectionList` provides sliver-native page gutters with the same section-owned rhythm by default. `CatchSection`, `CatchScreenBody`, and `CatchSectionStack` are registered as formal component contracts (`catch.section`, `catch.screen_body`, `catch.section_stack`); Widgetbook exposes contract states for section, scrolling/non-scroll body modes, and stack rhythm. |
| `CatchSectionFocusSurface` | `lib/core/widgets/catch_section_layout.dart:509` | Public `catch.section` member for contained-section focus and error chrome. It wraps `CatchSurface.card`, watches descendant focus, and applies the section focus ring or danger border while `CatchSection.contained` remains the product-facing API. |
| `EventActivityVisualSpec` / `EventActivityBackdrop` | `lib/core/widgets/event_activity_visuals.dart:17` | Mutable presentation schema for `ActivityKind` imagery. Centralizes activity label, icon, gradient palette, pattern, and browse-order choices so Explore cards, spotlight cards, thumbnails, browse tiles, and event detail headers do not fork color decisions. |
| `EventHeroSurface` / `EventTicketPerforatedDivider` / `EventTicketShapeClipper` | `lib/core/widgets/event_ticket_surface.dart:11` | Shared event-ticket transition primitives. `EventHeroSurface` is the named full-card wrapper around the shared ticket Hero flight and is registered as `catch.event_card.hero_surface`; the divider and clipper own horizontal perforation, ticket notch constants, and ticket shape geometry used by ticket cards, spotlight cards, date-rail cards, and ticket-mode event detail headers. |
| `EventCapacityPresenter` | `lib/events/presentation/widgets/event_tiles/event_capacity_presenter.dart:4` | Shared event-capacity display helper. Owns signed-up/spots/progress values plus "going · left/full", activity summary, attendee-confirmed, and join-CTA availability copy so cards and CTAs do not fork booking language. |
| `EventActivityStamp` / `EventClockMark` / `EventCapacityProgress` / `EventStatusPill` | `lib/core/widgets/event_visual_atoms.dart:8` | Shared visual atoms for activity-coded event rows and tickets. Use these for circular activity marks, analog time marks, capacity progress bars, and compact status pills before adding card-local painters or badges. `EventActivityStamp` is registered as `catch.event_card.activity_stamp`; clock and status atoms remain `catch.event_card` members. |
| `CatchChipField<T>` | `lib/core/widgets/catch_chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, keeps the parent-owned `selected` set, supports disabled state for pending mutation sheets, and shows a leading check icon on selected chips only in multi-select mode. |
| `CatchDetailRow` | `lib/core/widgets/catch_detail_row.dart:5` | Compact label/value row for detail and payment-history sheets. Uses supporting text roles, fixed label lane, and expanded value copy so dense read-only metadata aligns without a new local table layout. |
| `CatchErrorBanner` | `lib/core/widgets/catch_error_banner.dart:12` | Styled inline error banner for persistent mutation/form errors within page content. Shares the internal inline-message shell with `CatchSurface.message` so danger banners and neutral/tinted notes keep one row grammar. Optionally includes a "Try again" button. |
| `CatchMutationErrorBanner` | `lib/core/widgets/catch_error_banner.dart:79` | Riverpod `MutationState` adapter for persistent inline mutation failures. Renders nothing while idle/pending/successful and delegates errors to `CatchErrorBanner.fromError`. |
| `showCatchSnackBar` / `showCatchErrorSnackBar` | `lib/core/widgets/catch_error_snackbar.dart:5` | Snackbar helpers for transient action feedback. `showCatchSnackBar` applies shared Catch typography/color styling to success or validation copy; `showCatchErrorSnackBar` maps errors through `appErrorMessage` and composes the same helper with optional retry action. |
| `CatchMutationErrorListener` / `CatchMutationErrorListeners` | `lib/core/widgets/catch_mutation_error_listener.dart:15` | Snackbar boundary for Riverpod mutation failures. Use the singular wrapper for one mutation and the plural wrapper when a screen has several independent mutations that should share one transient error channel. |
| `CatchNoticeHost` | `lib/core/widgets/catch_notice.dart:84` | App-wide overlay host for ambient notices. Renders persistent notices such as offline state below the safe area and queues ephemeral event notices through `appNoticeControllerProvider`. |
| `CatchNotice` | `lib/core/widgets/catch_notice.dart:184` | Reusable floating notice primitive with tone, icon, optional message, optional action, and optional dismiss control. Use for ambient app status/events, not inline form errors. |
| `CatchSectionHeader` | `lib/core/widgets/catch_section_header.dart:4` | Lightweight section header with sentence-case styling by default, optional heavy weight, and opt-in uppercase for intentional metadata/eyebrow labels. Prefer `CatchSection` for carded content sections. |
| `CatchStatColumn` | `lib/core/widgets/catch_stat_column.dart:5` | Vertical stat display: value on top, label below. Used by profile and host surfaces that need local surface ownership; detail-page rails should use `CatchMetricStrip`. |
| `CatchBottomSheetGrabber` | `lib/core/widgets/catch_bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets and draggable sheet shells. Supports caller-owned width/height while keeping tokenized color and radius. |
| `CatchPersonRow` | `lib/core/widgets/catch_person_row.dart:77` | Multipurpose person row. In chat-thread mode (when `lastMessage` is non-null), renders name, timestamp, context line, last message, and unread badge. In roster mode, renders name, meta line, context line, and an optional trailing widget. Used in chat inbox, rosters, waitlists, and catches previews. |
| `_ChatLayout` | `lib/core/widgets/catch_person_row.dart:136` | Internal chat-thread layout for `CatchPersonRow` — name + timestamp row, run-context row, last-message + unread-badge row. |
| `_RosterLayout` | `lib/core/widgets/catch_person_row.dart:228` | Internal roster layout for `CatchPersonRow` — name + meta line + context line (run icon). |
| `CatchPersonAvatar` | `lib/core/widgets/catch_person_avatar.dart:49` | Shared person/host avatar with deterministic gradient fallback derived from name hash. Supports image URL, colored border ring (for match state or stacking), online status dot, obscured/blurred rendering for privacy-preserving hype avatars, and `CatchPersonAvatarShape.circle` / `.square` so inbox host inquiries can use the handoff's rounded-square treatment without forking the avatar widget. Named constructor `CatchPersonAvatar.count` shows a "+N" overflow bubble. |
| `CatchPersonAvatarStack` | `lib/core/widgets/catch_person_avatar.dart:218` | Shared handoff `AvatarStack`: overlapping avatars with photo or initials fallback, optional activity-tinted veiled placeholders for hidden rosters, quiet raised `+N` overflow count, configurable size/overlap/ring, and optional obscured photo rendering for legacy surfaces. Use this instead of feature-local stacked circular-avatar widgets. |
| `_GradientPlaceholder` | `lib/core/widgets/catch_person_avatar.dart:162` | Deterministic gradient placeholder for avatars without a photo. Picks from 12 palettes based on a hash of the name. |
| `ResponsiveBuilder` | `lib/core/responsive/responsive_builder.dart:22` | Thin wrapper around `LayoutBuilder` that maps available width to `ScreenSize` (compact/medium/expanded) and calls the appropriate builder. Falls back gracefully when tablet/desktop builders are absent. |
| `_ButtonLabel` | `lib/core/widgets/catch_button.dart:141` | Internal label+icon row for `CatchButton`. |
| `_LoadingDots` | `lib/core/widgets/catch_button.dart:193` | Three animated dots shown during `CatchButton`'s loading state. |
| `CatchToggle` | `lib/core/widgets/catch_toggle.dart:8` | Low-level handoff switch leaf. Renders a 46x28 pill track, primary fill when on, line2 fill when off, a surface knob, semantics toggled state, disabled opacity, and emits the next boolean value on tap. Row-shaped settings/policy controls should use `CatchField.toggle`; use `CatchToggle` directly only inside `CatchField` or standalone non-field controls. |

---

## Dashboard

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:24` | Home tab. Watches the user's profile, active club memberships, signed-up events, and Home unread notification count only while Home is active. Renders one `CustomScrollView` with a scroll-away greeting/empty header, top-right Notifications bell, red unread badge, and dashboard sliver body; it no longer owns a route-local tab controller or Dashboard/Activity tab row. Route-level loading uses a dashboard-shaped skeleton shell for the header, notification affordance, focus card, stride card, quick actions, and recommendations; typed `AppException` failures use the shared Catch error descriptor so offline states show consistent Connection issue copy. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:21` | Standalone full-dashboard wrapper used by focused tests/non-tab embedding. Takes explicit `followedClubIds` from the membership-edge seam and renders the full dashboard header plus `DashboardFullSliverBody`. The header avatar is a Profile-tab button and must use thumbnail-scale profile imagery through `UserProfile.primaryPhotoThumbnailUrl`. |
| `DashboardFullSliverBody` | `lib/dashboard/presentation/widgets/dashboard_full.dart:84` | Sliver body for the populated Home dashboard. Uses `CatchSectionStack` for the handoff rhythm and orders the body as `EventFocusRail`, `StrideCard`, `QuickActions`, the personal followed-clubs `ClubAvatarRail` when available, and the "Recommended for you" rail. It joins club names for committed events through `clubNameLookupProvider`, resolves followed clubs through `watchClubsByIdsProvider`, supplies typed Calendar/Saved Events callbacks to `QuickActions`, maps self-check-in mutation state into `EventFocusCheckInState`, supplies typed `EventFocusActions` for route/controller/external effects, supplies typed stride actions/busy state to `DashboardStrideSection`, and leaves notifications on the dedicated Notifications screen. |
| `FollowedClubsRailSkeleton` | `lib/dashboard/presentation/widgets/dashboard_full.dart:378` | Loading placeholder for the personal followed-clubs rail. Reserves the "Your clubs" header plus three avatar/text skeleton chips so the populated dashboard does not collapse while followed club documents resolve. |
| `EventFocusRail` | `lib/dashboard/presentation/widgets/event_focus_rail.dart:53` | Consolidated Home rail for attendee committed-event actions. Builds full-width snapping `EventActionCard` pages for upcoming, check-in, catch-window, and review states; stacks actions such as View event, Check in, Directions, Add to calendar, Start catching, and Write review so labels do not clip on narrow screens. The rail is a provider-free visual section that receives typed `EventFocusActions` plus display-only `EventFocusCheckInState`; the composing Dashboard body owns navigation, calendar, directions, self-check-in, event-success, and review-sheet effects. |
| `EventFocusPageIndicator` | `lib/dashboard/presentation/widgets/event_focus_rail.dart:306` | Centered page-dot indicator for the dashboard event-focus carousel. Receives selected index and item count directly and supplies an accessible "Event n of m" semantic label through `CatchPageDots`. |
| `EventFocusCard` | `lib/dashboard/presentation/widgets/event_focus_rail.dart:328` | Single dashboard event-focus card. Receives public `EventFocusItem` display state, card position, check-in pending state, and action callback; maps upcoming/check-in/after-event flags into `EventActionCard` badges, metadata rows, primary/secondary actions, accent colors, and pending check-in button disablement without reading route providers. |
| `ActivityScreen` | `lib/dashboard/presentation/activity_screen.dart:19` | Route-level Activity screen registered as `screen.notifications.list` and opened from the Home header bell. Uses `CatchTopBar(title: 'Activity')`, keeps the bottom nav visible by living under the Home shell branch, watches uid/activity providers at the route edge, resolves `NotificationsListState`, owns `ActivityController.markAllReadMutation` feedback, and owns row navigation side effects. |
| `NotificationsListState` | `lib/dashboard/presentation/notifications_list_state.dart:6` | Provider-free adapter state for the Notifications route. Converts uid/activity provider waves into loading, signed-out, loading-row, error, empty, and populated states; derives visible rows, read/unread state, route intents, relative times, and Today/Yesterday/This week/Earlier groups from an injected clock; exposes mark-all-read label/action availability for the top bar. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:33` | Reusable notification body for `screen.notifications.list`. The route uses `ActivitySection.fromState` with `NotificationsListState` so loading/empty/error/content rendering is provider-free; the legacy `uid` constructor remains for existing Widgetbook/lab call sites. It groups visible notifications by Today, Yesterday, This week, and Earlier through compact top-hairline day groups; signed-up event rows are intentionally not part of this handoff screen. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Intrinsic-height "Recommended for you" horizontal rail of `RecommendCard` widgets for recommended events from the user's followed clubs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:8` | Dashboard recommended-event adapter around `CatchEventCard.ticket`. It uses the shared activity-art ticket shape, keeps the recommender reason in the media label, and preserves price, title, club, date/time, meeting point, distance/pace, booked count, and remaining spots. Widgetbook exposes standalone dashboard primitive states for ranked recommendations, free/paid events, fallback factory output, and long venue/reason copy. |
| `DashboardStrideSection` / `DashboardStrideSectionActions` | `lib/dashboard/presentation/widgets/stride_card.dart:15` | Provider-free weekly activity section that renders loading/error states and `StrideCard` from `DashboardSectionModel<WeeklyActivitySnapshot>`. It receives typed retry/connect/install callbacks plus display-only `DashboardStrideActionState`; the composing Dashboard body owns provider invalidation, Health permission/install side effects, snackbar feedback, refresh, and busy flags. Widgetbook exposes standalone states for connected, loading, retry error, permission, connect-pending, Health Connect install, install-pending, empty week, and unsupported long-copy variants. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:76` | Dashboard card showing stride weekly activity stats with bar columns, source copy, and optional connect/install action buttons driven by injected callbacks and busy flags. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` / `DashboardQuickAction` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Responsive dashboard quick-action grid for Calendar and Saved events. The visual widget receives typed action models and callbacks from the composing screen instead of importing routes or owning navigation. Spatial discovery lives under Clubs, so the dashboard no longer exposes Map view. Avoids hardcoded tile heights so labels can wrap without clipping on narrow screens. Widgetbook exposes standalone states for normal, disabled, four-action, long-copy, and empty action lists. |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Standalone empty-dashboard wrapper used by focused tests/non-tab embedding. Renders the empty dashboard header plus `DashboardEmptySliverBody`. |
| `DashboardEmptySliverBody` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:56` | Sliver body for the empty Home dashboard. Uses `CatchSectionStack` with the cover-story `EmptyHeroCard` followed by a `CatchSection` journey for "How Catch works"; weekly activity, quick actions, and personal clubs stay out of the first-run composition. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Cover-story hero shown on the empty dashboard prompting the user to book their first event. Its copy matches the handoff first-run story, omits the old decorative glyph, and uses `CatchButtonVariant.light` so the CTA stays legible in dark mode. |
| `EmptyHeroContent` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:57` | Provider-free content block inside `EmptyHeroCard`. Owns the optional welcome eyebrow, no-events kicker, first-event headline, supporting copy, and light CTA while the surrounding card decides full-bleed versus inset hero chrome and routing callback. |

### Sliver Helpers

| Helper | File | Purpose |
|---|---|---|
| `DashboardSliverHeader` | `lib/dashboard/presentation/widgets/dashboard_sliver_header.dart:7` | Dashboard-specific wrapper around `CatchSliverHeader`. Keeps the home greeting/onboarding header visually consistent while allowing it to scroll away with the dashboard content, and exposes trailing action slots such as the Notifications bell. |
| `DashboardHeaderContent` | `lib/dashboard/presentation/widgets/dashboard_sliver_header.dart:15` | Dashboard header title content used by `DashboardSliverHeader`. Receives eyebrow, title, and trailing actions explicitly, keeps the compact screen-title block padding, and truncates header copy before rendering optional action slots. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:220` | Loading scaffold for Home while profile/booked-run data resolves. |
| `_DashboardErrorScreen` | `lib/dashboard/presentation/dashboard_screen.dart:229` | Branded error scaffold for Home profile/booked-run load failures. |
| `DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_section_state_card.dart:9` | Inline loading/error card for dashboard sections such as recommendations and weekly activity. Renders shared skeleton or message copy in a compact `CatchSurface` so section-level empty/loading states stay visually consistent. |
| `NotificationDayGroups` | `lib/dashboard/presentation/widgets/activity_section.dart:133` | Notifications screen day-group wrapper. Matches the handoff's tight Activity composition with first group flush, later groups separated by an 8px offset, top hairline, 18px inset, uppercase kicker, then grouped notification rows. |
| `NotificationRowSkeleton` | `lib/dashboard/presentation/widgets/activity_section.dart:206` | Loading row placeholder for activity notifications. Reserves icon, title/time, and two-line body skeletons, with optional inset divider matching the loaded notification row stack. |
| `NotificationRow` | `lib/dashboard/presentation/widgets/activity_section.dart:158` | Handoff-style row for backend-owned activity notifications. It exposes the design contract (`type`, `title`, `time`, `body`, `unread`, `divider`, optional tap), renders on-surface with a type-colored glyph, optional inset divider, relative time, unread title/time color, and optional route navigation with branded failure feedback from the parent group, and deliberately does not render card fills, badges, or icon chips. |
| `NotificationGroupWidget` | `lib/dashboard/presentation/widgets/activity_section.dart:314` | Small adapter that renders a group of `NotificationRowDisplay` entries and injects row dividers after the first item. Optional route callbacks let the Activity route own navigation while Widgetbook can render display rows provider-free. |

---

## Host Tools

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `HostEventToolsCarousel` | `lib/hosts/presentation/widgets/host_event_tools.dart:22` | Shared full-width host-event carousel for unbounded hosted events, including closed past hosted events retained for host operations. It renders self-contained cards with swipe snapping and no external section header, event-count badge, or footer chrome. |
| `_HostEventsScaffold` | `lib/hosts/presentation/host_operations_screen.dart:1568` | Host Home selected-club shell. Composes from `HostHomeScreenState`, defaults to `HostHomeTab.today`, can render the explicit Events branch for reference/callback states, owns Add event and Manage event route callbacks, and supplies selected club plus typed callbacks to Today and Events provider adapters. |
| `_HostClubsScaffold` | `lib/hosts/presentation/host_operations_screen.dart:1532` | Host Clubs selected-club operations shell. Composes from `HostClubsScreenState`, defaults to the Organizer overview, hides the AppBar in organizer mode, preserves Edit / Insights / Preview tabs, owns public-preview/settings/tab callbacks, and keeps owner-only edit/payout/team mutations out of co-host selections. |

### State Adapters

| Adapter | File | Purpose |
|---|---|---|
| `HostSettingsState` | `lib/hosts/presentation/host_settings_state.dart:5` | Account-tab display seam for `screen.host.settings`. Adapts the uid/profile/clubs provider wave into profile and clubs display states before the route composes sections. |
| `HostSettingsProfileState` | `lib/hosts/presentation/host_settings_state.dart:27` | Profile-summary display state for Host Settings. Covers loading, error, missing, loaded profile, and club-backed fallback profile branches so fallback identity is not derived inline in the screen. |
| `HostSettingsClubsState` | `lib/hosts/presentation/host_settings_state.dart:82` | Clubs-section display state for Host Settings. Covers loading, error, empty, and content branches before `HostSettingsClubsSection` renders rows. |
| `HostProfileEditState` | `lib/hosts/presentation/host_settings_state.dart:117` | Direct Host Profile route display state. Covers auth-required, loading, error, missing, and content before the route composes `HostProfileForm` or `HostProfileMissingState`. |
| `HostHomeRouteState` | `lib/hosts/presentation/host_operations_screen.dart:168` | Host Home route adapter seam. Maps `uidProvider` plus the combined host-club async state into auth-required, loading, error, empty, or loaded branches before `HostOperationsHomeScreen` composes the shell or route-level error/loading surfaces. |
| `HostHomeScreenState` | `lib/hosts/presentation/host_operations_screen.dart:237` | Host Home selected-club and selected-tab display seam. Resolves an optional initial club id, clamps selected indexes as club streams change, exposes title/switcher visibility, tracks `HostHomeTab.today` versus `HostHomeTab.events`, and centralizes owner/co-host role capability before the scaffold composes Today or Events sections. |
| `HostHomeEventRowsState` / `HostHomeEventRowData` | `lib/hosts/presentation/host_operations_screen.dart:297` | Host Home Events-list display seam. Sorts selected-club events by start time, filters cancelled events, limits visible rows, and provides title/time/divider row data so `HostEventRow` does not own filtering or routing. |
| `HostHomeEventsSectionState` | `lib/hosts/presentation/host_operations_screen.dart:334` | Host Home Events-list display seam. Maps `watchEventsForClubProvider` output into loading, error, empty, or populated states and delegates row filtering/sorting/limiting to `HostHomeEventRowsState` before `HostEventsClubSection` renders. |
| `HostHomeTodayDashboardState` / `HostHomeTodayTaskData` | `lib/hosts/presentation/host_operations_screen.dart:376` | Host Home Today display seam. Maps the selected club event async branch into loading, error, empty, or content states; chooses the next active event; and derives needs-you task rows so Today widgets do not own event filtering, task copy, or retry state. |
| `HostClubsScreenState` | `lib/hosts/presentation/host_operations_screen.dart:350` | Host Clubs selected-club display seam. Resolves an optional initial club id, clamps selected indexes as club streams change, owns the selected `HostClubTab`, exposes title/switcher visibility, and centralizes owner/co-host role capability for the scaffold and deterministic captures. |
| `HostClubDetailScreenState` / `HostClubDetailRetryIntent` | `lib/clubs/presentation/detail/club_detail_screen.dart:255` | Host Club Detail route adapter over the shared club detail screen. Maps async loading/error/not-found branches, `initialClub` fallback, signed-in host ownership, public-preview mode, membership state, consumer dock suppression, and load-error retry intent typing before `ClubDetailScreen` composes the shared public profile body. The screen wires typed callbacks for retry, schedule route actions, host profile/message actions, contact launches, and share. |
| `HostInboxScreenState` | `lib/chats/presentation/inbox/chat_inbox_screen.dart:74` | Host Inbox route adapter over the shared `ChatsListScreen`. Reads the uid/view-model/query/provider wave at the route edge, owns selected host filter, unread count, search-action visibility, and delegates loading/error/content/empty mapping to `ChatsListDisplayState` before the route composes `ChatsSliverHeader` and `ChatsList`. Host/consumer chat route callbacks are owned by `ChatsListScreen`; duplicate host-inquiry grouping is covered by the shared match collapse policy. |
| `ChatsListDisplayState` / `ChatsListRetryIntent` | `lib/chats/presentation/inbox/widgets/chats_list.dart:95` | Shared chat-list body adapter. Converts `AsyncValue<ChatsListViewModel>` into loading, error, content, or explicit empty states; applies Host Inbox unread filtering; selects no-threads, no-search-results, or no-unread empty copy; and attaches a typed reload intent to display errors before `ChatsList` renders shared sliver sections. |
| `ChatRouteState` / `ChatRouteStateArgs` | `lib/chats/presentation/chat_route_state.dart:93` | Host/consumer chat route provider seam. Performs the route-level uid, match, message, host-inquiry club, public-profile, event, Suvbot action, mutation-pending, and share-controller watches once, then returns the composed lookup state, `HostChatScreenState`, public-profile async state, event, messages, pending flags, and visibility booleans that `ChatScreen` renders, including whether a consumer match can expose the embedded Chat/Profile tab shell. |
| `HostChatScreenState` / `HostChatRetryIntent` / `HostChatActionIntent` | `lib/chats/presentation/host_chat_screen_state.dart:9` | Provider-free Host Chat decision seam over the shared `ChatScreen`. Centralizes host inquiry identity, typed profile/share/safety action availability, route/message/Suvbot retry intents, report/block pending action disabling, action intent policy, safety target copy, message peer name, and composer disabled reason before `ChatRouteState` passes render-ready state to `ChatScreen`. Match-stream errors become `HostChatRouteError` with `HostChatRetryIntent.reloadMatch`, while message-list and Suvbot-control errors expose typed retry targets. `ChatScreen` renders the canonical `CatchTopBar.identity` for single-pane host/Suvbot states, switches regular match chats to a `CatchTopBarTabBar` Chat/Profile shell, and owns the `CatchTopBarMenuAction` wiring. |
| `ChatReadMarkerState` | `lib/chats/presentation/chat_read_marker_state.dart:3` | Provider-free chat read-marker decision seam. Tracks the last known and last marked uid, suppresses duplicate marks unless forced, marks only incoming latest messages, and exposes the dispose-time uid before `ChatScreen` executes the `ConversationReadMarker.markRead` side effect. |
| `ChatThreadLookupState` | `lib/chats/presentation/chat_thread_lookup_state.dart:6` | Provider-free chat thread lookup-key seam. Derives other participant identity, Suvbot suppression, host-inquiry club id, host profile, public-profile uid, initial routed profile, and latest event id before `ChatRouteState` performs the Riverpod provider watches. |

### Action Controllers

| Controller | File | Purpose |
|---|---|---|
| `HostClubEditController` | `lib/hosts/presentation/club_management/host_club_edit_controller.dart:18` | Host Clubs inline edit action controller. Owns `updateClubMutation`, validates signed-in host context, delegates `UpdateClubPatch` writes to `ClubsRepository.updateClub`, and lets Widgetbook/captures seed pending, generic error, and offline save states against the real expanded editor UI. |
| `HostEventManageController` | `lib/hosts/presentation/host_event_manage_controller.dart:62` | Host Manage action controller for private invite-link, report export, and destructive host operations. Owns create/copy/disable/share/export mutation state, delegates named-link writes to `EventRepository`, routes clipboard writes through `ClipboardController`, launches private-link sharing and report CSV export through `ExternalShareController`, delegates cancel/delete to `EventBookingController`, and invalidates event, roster, and invite-link streams after mutations. |
| `HostPaymentAccountController` | `lib/hosts/presentation/payments/host_payment_account_controller.dart:22` | Host Clubs payout action controller. Owns Stripe onboarding and refresh mutations, validates signed-in host context, delegates account link/status work to `HostPaymentAccountRepository`, opens Stripe through `ExternalLinkController`, and invalidates payout account state after refresh. |
| `HostProfileController` | `lib/hosts/presentation/host_profile_controller.dart:9` | Shared host profile action controller for Account and direct Host Profile routes. Owns `ensureProfileMutation` and `saveProfileMutation`, reads the signed-in uid at the controller boundary, and delegates profile create/save writes to `HostProfileRepository`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_HostClubTabRail` | `lib/hosts/presentation/host_operations_screen.dart:1394` | Host Clubs Organizer / Edit / Insights / Preview rail. Reuses `CatchOptionGroup` in the AppBar bottom slot for non-organizer tabs so the host clubs screen follows the handoff tab composition without custom segmented chrome. |
| `HostOperationsTopBar` | `lib/hosts/presentation/host_operations_screen.dart:1921` | Host app top bar used by the explicit Events branch and Host Clubs. Wraps `CatchTopBar` with a mono kicker, title, optional shared action slots, and optional bottom content so host tabs can expose club pickers and tab rails without custom chrome. Widgetbook exposes standalone top-bar states under Host operations sections. |
| `HostTodayDashboardCard` | `lib/hosts/presentation/host_operations_screen.dart:1990` | Narrow Host Home Today provider adapter. Watches the selected club event stream, maps it through `HostHomeTodayDashboardState`, supplies typed retry/create/manage callbacks and club-switching data, then delegates rendering to provider-free `HostTodayDashboardSection`. |
| `HostTodayDashboardSection` | `lib/hosts/presentation/host_operations_screen.dart:2032` | Provider-free Host Home Today section. Renders the greeting/club pill, next-event hero, needs-you task cards, loading/error/empty branches, and typed callbacks from `HostHomeTodayDashboardState` without repository or router reads. |
| `HostEventsClubCard` | `lib/hosts/presentation/host_operations_screen.dart:2696` | Host Home Events provider adapter. Watches the selected club event stream, maps it through `HostHomeEventsSectionState`, supplies typed retry/create/manage callbacks, and delegates rendering to provider-free `HostEventsClubSection`. Widgetbook exposes content, loading, error, offline, empty, and cancelled-filtered event-list states through this adapter. |
| `HostEventsClubSection` | `lib/hosts/presentation/host_operations_screen.dart:2728` | Provider-free Host Home Events section. Renders `HostMetaRow`, upcoming-event loading/error/empty/populated states, Add event, empty copy, and `HostEventRow` children from `HostHomeEventsSectionState` plus typed retry/create/manage callbacks. |
| `HostMetaRow` | `lib/hosts/presentation/host_operations_screen.dart:2827` | Host club metadata row: uppercase area/location, role badge, and activity chip. Keeps host tab color usage tied to activity meaning and has Widgetbook states for owner, host-team, and missing-area variants. |
| `_HostClubOrganizerOverview` | `lib/hosts/presentation/host_operations_screen.dart:1782` | Host Clubs default Organizer overview. Composes the compact selected-club logo/meta/formats header, owner payout callout with inline CTA, joined metric rows, public page row, host-team summary, trend strip, and manage rows from catalog primitives while routing public preview, payouts/edit, insights, settings, and club switching through callbacks supplied by `_HostClubsScaffold`. |
| `_HostClubProfileCard` | `lib/hosts/presentation/host_operations_screen.dart:1733` | Host Clubs Edit tab body. Shows selected club metadata plus Identity, Contact, Event defaults, Public profile, Payouts, and Host team sections using `CatchSection`/`CatchField` rows, `HostPaymentAccountCard`, and `HostTeamManagementSection`; owner-only rows expand inline editors, payout setup, and team management in place. The route can seed an initial expanded edit field for deterministic Widgetbook/capture states, and the public profile row receives a typed preview callback from `_HostClubsScaffold` instead of routing directly. |
| `_HostClubPreviewPane` | `lib/hosts/presentation/host_operations_screen.dart:3575` | Host Clubs Preview tab body. Shows the selected club description and receives a typed public-preview route callback from `_HostClubsScaffold` until the public club preview components are made embeddable inside the host tab. |
| `HostEventRow` | `lib/hosts/presentation/host_operations_screen.dart:5551` | Provider-free Host Home Events row. Uses `CatchField.nav` with date icon, event title, time value, divider, and chevron tap target from `HostHomeEventRowData`, and delegates tap handling to the parent-supplied manage callback. Widgetbook exposes first-row and divided-row variants. |
| `HostEventToolsPageIndicator` | `lib/hosts/presentation/widgets/host_event_tools.dart:164` | In-card hosted-event position indicator. Shows `N of total` plus a bounded progress rail so unbounded hosted-event counts do not grow the rendered indicator. |
| `HostEventToolCard` | `lib/hosts/presentation/widgets/host_event_tools.dart:208` | Shared operational card for one hosted event. Adapts host event lifecycle, bounded in-card progress, date/time, meet point, booked/waitlist counts, and one contextual CTA into `EventActionCard` using the host palette. |
| `HostToolPalette` | `lib/hosts/presentation/widgets/host_event_tools.dart:304` | Token-backed host-tool color helper for default host panels and attendance states. Use this instead of local orange-tinted containers for host chrome. |
| `HostRouteLoadingBody` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:8` | Host app route loading body. Mirrors the selected-club summary, optional tab rail, event rows, analytics card, and settings rows used across Host Events, Host Clubs, Host Manage, and Host Edit route gates. |
| `HostSummarySkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:34` | Host summary-card skeleton for selected club/event identity, role badges, metadata, and a primary host action placeholder. |
| `HostTabRailSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:70` | Token-sized segmented/tab rail skeleton used when Host Clubs or Host Manage preserve tab chrome while data resolves. |
| `HostSettingsRowsSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:93` | Settings/profile row skeleton for Host Account, Host Profile, and Host Clubs field-row waves. |
| `HostEventRowsSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:140` | Hosted-event list skeleton that mirrors `CatchField` event rows with icon, title, secondary metadata, value lane, and chevron placeholder. |
| `HostAnalyticsReportSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:187` | Host analytics loading body with metric-grid, chart, and row-summary placeholders for the Insights tab. |
| `HostChartSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:205` | Reusable host chart placeholder used inside analytics/report loading states. |
| `HostRosterSkeleton` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:227` | Attendance/participants roster skeleton with filter chips and participant rows for Setup, Live, and Report provider waves. |
| `HostInlineSkeletonIcon` | `lib/hosts/presentation/widgets/host_loading_skeletons.dart:269` | Compact square skeleton for tiny host inline pending states such as draft-picker delete and private-link metadata loading. |
| `CatchRosterTiles` | `lib/hosts/presentation/widgets/catch_roster_board.dart:39` | Handoff `RosterTiles` filter row for host roster boards. Renders selectable count tiles in functional tones, flips the selected tile to the ink fill, and keeps filter selection provider-free through an optional `onSelect` callback. Registered as formal component contract `catch.roster_tiles`; Widgetbook contract states are the canonical review surface for default, selected, read-only, warning, and danger. |
| `CatchRosterRow` | `lib/hosts/presentation/widgets/catch_roster_board.dart:199` | Handoff `RosterRow` participant row. Uses a fixed 5/3/3 identity/signal/action grid with `CatchPersonAvatar`, condensed name/meta copy, `CatchBadge` signal, and typed action-cell variants for button, approve/decline, badge, and text outcomes. Registered as formal component contract `catch.roster_row`; Widgetbook contract states are the canonical review surface for button, decision, badge, text, empty-signal, disabled-action, and truncation. |
| `CatchRosterTable` | `lib/hosts/presentation/widgets/catch_roster_board.dart:416` | Handoff `RosterTable` shell for host roster boards. Owns the hairline table surface, mono three-column header, fixed row proportions matching `CatchRosterRow`, row composition, and built-in empty state. Registered as formal component contract `catch.roster_table`; Widgetbook contract states are the canonical review surface for populated, empty, partial-column, and long-copy tables. |
| `HostClubManagementPanel` | `lib/hosts/presentation/widgets/host_club_tools.dart:15` | Reusable combined host-club tools panel for surfaces that intentionally need Add event, Edit club, and upcoming booked/waitlist/base-revenue stats in one section. Public `ClubDetailBody` no longer embeds this panel; Host app tab surfaces own those actions. |
| `HostStatChip` | `lib/hosts/presentation/widgets/host_club_tools.dart:161` | Single reusable host stat chip used by the consolidated club host management panel and host event management stats. |
| `HostSettingsTabRail` | `lib/hosts/presentation/host_operations_screen.dart:411` | Provider-free Host Settings Edit / Preview rail used in the Account app bar and rendered directly in Widgetbook. The route owns selected tab state; the rail only receives the current `HostSettingsMode` and change callback. |
| `HostSettingsSection` | `lib/hosts/presentation/host_operations_screen.dart:449` | Shared host settings section wrapper for Account and Host Clubs row groups. Owns section kicker, top divider spacing, and row grouping while callers supply provider-free `CatchField` children. |
| `HostSettingsProfileSection` | `lib/hosts/presentation/host_operations_screen.dart:483` | Provider-free profile summary section for `screen.host.settings`. Renders loading, error, missing, create-pending, club-backed fallback, loaded, edit, preview, and status rows from explicit `HostSettingsProfileState` plus create/edit/retry callbacks. |
| `HostSettingsClubsSection` | `lib/hosts/presentation/host_operations_screen.dart:609` | Provider-free hosted-clubs section for `screen.host.settings`. Renders loading, error, empty, edit-mode, and preview-mode club rows from `HostSettingsClubsState`, retry callback, and route callback so Widgetbook can cover section states without Riverpod reads. |
| `HostProfileForm` | `lib/hosts/presentation/host_operations_screen.dart:962` | Provider-free professional profile form for `screen.host.profile`. Renders status-aware profile fields and the save action from explicit controllers, save state, profile status, and callback so Widgetbook can cover active/pending/suspended, validation, pending, text-scale, reduced-motion, and theme states without live providers. |
| `HostProfileFields` | `lib/hosts/presentation/host_operations_screen.dart:1014` | Shared host professional profile field stack for the full-screen Host Profile route and Host Settings editor sheet. It owns display name validation and status label rendering while keeping persistence and controller ownership outside the field section. |
| `HostProfileMissingState` | `lib/hosts/presentation/host_operations_screen.dart:1076` | Provider-free missing-profile section for the direct Host Profile route. Receives create and pending state from the route/adapter boundary so Widgetbook can review missing and create-pending states without repository side effects. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `HostOperationsHomeScreen` | `lib/hosts/presentation/host_operations_screen.dart:60` | Host app Home route. Watches uid and clubs the signed-in host can operate, maps them through `HostHomeRouteState`, and delegates selected-club Today/Events composition to `_HostEventsScaffold` through `HostHomeScreenState`. The route now defaults to `HostHomeTab.today`; explicit Events captures/tests use `HostHomeTab.events`. Selected club, selected tab, title, switcher visibility, owner/co-host role capability, route branch selection, Today/event async branch selection, event row/task derivation, retry intents, and create/manage route callbacks are typed. |
| `HostClubsScreen` | `lib/hosts/presentation/host_operations_screen.dart:100` | Host app Clubs tab. Watches clubs the signed-in host can operate and delegates selected-club Organizer / Edit / Insights / Preview composition to `_HostClubsScaffold` through `HostClubsScreenState` instead of rendering every operated club in one grouped scroll. The design contract treats it as `screen.host.clubs`; Widgetbook/captures now cover the default organizer overview, signed-out, route loading/error/offline/empty, co-host edit, expanded inline editor pending/error/offline, insights loading/error/offline/report, payout provider loading/ready/restricted/error/offline, payout setup/refresh pending/error/offline, host-team mutation pending/error/offline, preview, text-scale, reduced-motion, and theme states. The canonical Host Organizer advisory comparison is within threshold; future pixel variants depend on additional Claude exports. |
| `HostAccountScreen` | `lib/hosts/presentation/host_operations_screen.dart:257` | Host app Account tab registered as `screen.host.settings`. It resolves host profile and club provider waves into `HostSettingsState`, owns Edit / Preview tab state, opens `HostProfileEditorSheet` for inline profile edits, routes profile create/save through `HostProfileController`, shows create/save success feedback through `showCatchSnackBar`, keeps sign-out/account actions in the route, and composes provider-free `HostSettingsProfileSection`, `HostSettingsClubsSection`, and `HostSettingsTabRail`. |
| `HostTeamManagementSection` | `lib/hosts/presentation/widgets/host_team_management_section.dart:25` | Host-owned club-team editor rendered from the Host app Clubs tab. It lists host profiles, opens the public `HostTeamAddHostSheet`, uses `HostTeamHostActionConfirmation` for remove/transfer dialog copy, and runs add, remove, and transfer mutations through `HostTeamManagementController`; section-level mutation failures render a persistent `CatchErrorBanner` while the add-host sheet keeps inline add errors in the sheet. |
| `HostTeamAddHostSheet` | `lib/hosts/presentation/widgets/host_team_management_section.dart:328` | Source-backed Host Clubs add-host bottom sheet. It uses `CatchBottomSheetScaffold`, `CatchField`, `HostTeamManagementController.addHostMutation`, inline `CatchErrorBanner`, and keyboard-safe sheet layout; Widgetbook covers ready, add pending, add error, and add offline states. |
| `HostTeamHostActionDialog` | `lib/hosts/presentation/widgets/host_team_management_section.dart:248` | Source-backed Host Clubs remove-host and transfer-ownership confirmation dialog. It renders typed `HostTeamHostActionConfirmation` copy/actions through `CatchConfirmDialog`; Widgetbook covers remove host and transfer ownership variants. |
| `HostEventAttendancePanel` | `lib/hosts/presentation/widgets/host_event_attendance_panel.dart:33` | Shared host attendance panel. Watches `AttendanceSheetViewModel`, renders `HostRosterSkeleton` for loading, branded inline errors/event-not-found states, and delegates zero-participant, filtered-empty, profile-backed roster rows, and attendance toggle mutations to the lifecycle-specific Host Manage board/table surfaces. Host Manage can seed an initial participant search query for deterministic filtered-empty states without manual text entry. Lifecycle participation counts are compact filter tiles, not a separate stat strip, so Setup, Live, and Report each expose the statuses hosts need without repeating top-level metrics. Report mode exports Revenue and Ops CSV files through `HostEventManageController` mutations and shared external sharing; revenue uses roster-visible payment ids plus event-price estimates until a backend host payment-report callable exposes actual settled/refunded amounts. |
| `HostCreateClubScreen` | `lib/hosts/presentation/club_management/host_create_club_screen.dart:10` | Host route-facing create-club entry registered as `screen.host.club.create`. Delegates to `CreateClubScreen` while the contract tracks draft restore/save, basics/details/defaults steps, media picking, validation, mutation pending/error, success pop, text-scale, reduced-motion, and capture follow-ups. Draft restore/save feedback uses `showCatchSnackBar`. Widgetbook now covers route entry, validation, picked media, restored draft, all wizard steps, save-draft pending/error, submit pending/error, offline submit failure, text scale, reduced motion, and dark theme. |
| `HostEditClubRouteScreen` | `lib/hosts/presentation/club_management/host_create_club_screen.dart:17` | Host route-facing edit-club entry registered as `screen.host.club.edit`. Resolves a club by id, handles loading/not-found/error states, delegates loaded identity/mode resolution to `HostClubEditState`, blocks non-host deep links, then renders `CreateClubScreen(initialClub:)` for owner long-form or co-host media-only editing. Widgetbook now covers route loading/error/offline/not-found, owner edit, validation, media replacement, submit pending/error, co-host media-only, forbidden identity, text scale, reduced motion, and dark theme. |
| `HostClubEditState` | `lib/hosts/presentation/club_management/host_create_club_screen.dart:51` | Route adapter for host edit-club access mode. Resolves signed-in uid provider state plus club ownership into loading identity, owner full edit, co-host media-only edit, or forbidden states before the screen composes editor/error UI. Field/media/mutation callbacks remain the next migration target. |
| `HostCreateEventRouteScreen` | `lib/hosts/presentation/event_management/host_create_event_screen.dart:10` | Host route-facing create-event entry registered as `screen.host.event.create`. Resolves the host-owned club from route id or route extra, renders a content-shaped create-event skeleton for route loading, handles error/offline/not-found route states, and delegates to the host-owned create-event wizard. `CreateEventScreen` now exposes opt-in autovalidation and seeded picked-event-photo previews for deterministic Widgetbook/capture states, surfaces both submit and save-draft mutation errors through the shared banner, and uses `showCatchSnackBar` for draft saved/updated feedback. Widgetbook/captures cover route loading/error/offline/missing, validation, custom activity, picked event photos, selected location, map-picker offline search, draft picker/restored, save-draft pending/error/offline, submit pending/error/offline, photo-upload offline, success, baseline wizard steps, schedule/policy variants, draft delete, unsaved changes, unauthorized, text-scale, reduced-motion, and dark theme; reference-specific variants remain follow-up coverage. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `HostProfileEditorSheet` | `lib/hosts/presentation/host_operations_screen.dart:692` | Source-backed Host Account editor sheet. Reuses `HostProfileFields`, watches save pending state, and saves display name, role title, and bio through `HostProfileController` without pushing the full-screen editor route. |
| `HostProfileScreen` | `lib/hosts/presentation/host_operations_screen.dart:775` | Direct professional host profile editor route registered as `screen.host.profile`. It resolves uid/profile loading through `HostProfileEditState`, renders `HostSettingsRowsSkeleton` for loading, handles error and missing states, syncs display name, role title, bio, and status into controllers, composes provider-free `HostProfileForm` and `HostProfileMissingState`, routes create/save through `HostProfileController`, exposes a default-disabled `formAutovalidateMode` for deterministic validation captures, and shows save success feedback through `showCatchSnackBar` while keeping navigation behavior at the route edge until a broader route-action adapter exists. |
| `HostClubInsightsState` | `lib/hosts/presentation/host_operations_screen.dart:284` | Immutable Host Clubs analytics state. Owns range, granularity, custom date bounds, selected event scope, provider query derivation, and club-switch event-scope clearing so retry invalidation uses the same `HostAnalyticsQuery` key as the current UI. |
| `_HostClubInsightsPane` | `lib/hosts/presentation/host_operations_screen.dart:2142` | Host Clubs Insights tab body. Owns local date-picker presentation while delegating analytics range, granularity, custom-date, event-scope, and `hostAnalyticsProvider` query derivation to `HostClubInsightsState`; loading renders `HostAnalyticsReportSkeleton`. A future migration can still split the private analytics sections into a provider-free public section adapter if the design reference requires deeper review states. |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:32` | Catches decision screen. Watches the swipe queue provider, renders queue loading through `CatchesProfileReviewSkeleton`, renders the first candidate as a full `ProfileSurface`, submits section likes/comments through `SwipeQueueNotifier.swipe`, owns route-local `CatchesProfileReviewActionState` for write-pending/failure behavior, and exposes a floating lower-left pass X instead of deck gestures. Empty-state attendance copy uses the viewer's `EventParticipation` edge instead of compatibility arrays, and stuck queue loads now surface a retryable `Catches unavailable` error instead of spinning forever. |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:23` | Swipe filters screen registered as `screen.filters.preferences`. Owns profile provider waves, local age/interested-in draft initialization, reset, `FiltersController.saveFiltersMutation`, mutation-error listening, and pop-on-success at the route edge, renders `FiltersContentSkeleton` while profile defaults load, then composes provider-free `FiltersContent`. Pace range and event type are intentionally not exposed as filters. |
| `EventRecapScreen` | `lib/swipes/presentation/event_recap_screen.dart:29` | Post-event recap screen registered as `screen.event.recap`. Shows `EventRecapLoadingBody` while `EventRecapViewModel` resolves, then shows event details and a checked-in attendee vibe grid, watches batched public profile lookups, uses keyed vibe tiles, `CatchSurface` for the recap hero, and `CatchEmptyState` for an empty attendee roster pending an adapter for view-model/profile/selection state. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchesHubScreenState` | `lib/swipes/presentation/catches_hub_screen_state.dart:7` | Route adapter for the "Catches" tab. Maps uid and attended-event provider waves into loading/error/signed-out/empty/ready states, filters attended events through the open swipe-window predicate with an injected clock, formats hero and row countdown labels, and exposes catch/recap route paths through `CatchesHubEventRow`. |
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:23` | "Catches" tab. Keeps uid and attended-event provider watches plus route pushes at the screen edge, builds `CatchesHubScreenState`, and composes provider-free local sections for the header, active-window intro card, attended-event rows, and empty state. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:19` | Full-length scrollable profile body used inside `ProfileSurface`. Keeps the shared rendering path identical across Catches, Profile Preview, and Public Profile, renders the hero photo first, then contextual profile insights, profile prompts, one canonical `RUN PROFILE` running identity card, detail chips, inset photos, and lifestyle. Its internal vertical scroll view is non-primary, can accept an explicit controller and route-provided physics when embedded in a sliver route, and can report leading overscroll to a parent route for collapsible-header coordination. |
| `ProfileSurface` | `lib/swipes/presentation/profile_surface.dart:18` | Shared cardless public profile renderer. Maps `ProfileCardContent` into the handoff-aligned `CatchProfileView`, passes optional viewer/event context for compatibility insights, renders passive compatibility and running-identity labels as `CatchBadge` metadata, applies the social-run activity pigment to the hero fallback and Running Rhythm block, and mode-gates reaction controls so Catches can show, disable, or mark section like/comment affordances pending while Preview/Public Profile remain passive. |
| `ProfileSurfaceSkeleton` | `lib/swipes/presentation/profile_surface.dart:85` | Shared profile-surface loading skeleton for Public Profile, Profile Preview, and Catches deck loading. Mirrors `CatchProfileView` with a portrait hero placeholder, body gutter, section rules, running-stat cards, inset photo block, and fact rows while preserving optional scroll controller, physics, leading-overscroll callback, and bottom-padding hooks. |
| `ProfileSurfaceHeroSkeleton` | `lib/swipes/presentation/profile_surface.dart:149` | Leaf hero loading block for `ProfileSurfaceSkeleton`. Preserves the profile hero 4:5 ratio, rounded lower corners, and bottom-aligned name/meta text placeholders. |
| `ProfileSurfaceSectionSkeleton` | `lib/swipes/presentation/profile_surface.dart:191` | Generic profile body-section loading block with title, configurable text-line count, and three chip placeholders for prompt/detail-style profile sections. |
| `ProfileSurfaceRunningSkeleton` | `lib/swipes/presentation/profile_surface.dart:225` | Running-rhythm loading block used by `ProfileSurfaceSkeleton`, including title, two stat-card placeholders, and a supporting text placeholder. |
| `ProfileSurfacePhotoSkeleton` | `lib/swipes/presentation/profile_surface.dart:260` | Inset portrait photo loading block for the shared profile skeleton, preserving the same rounded 4:5 media geometry as loaded profile photos. |
| `ProfileSurfaceFactsSkeleton` | `lib/swipes/presentation/profile_surface.dart:282` | Fact-row loading block for the shared profile skeleton, rendering a title placeholder and four icon/text skeleton rows. |
| `ProfileSurfaceRule` | `lib/swipes/presentation/profile_surface.dart:314` | Profile skeleton section divider. Uses the current token line color and shared content-vertical padding so loading-state section rhythm matches loaded `CatchProfileView` sections. |
| `CatchProfileView` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:24` | Flagship cardless profile surface over a pure `ProfileView` display model. Renders the dark editorial hero, activity-pigmented kicker, ordered body sections, optional section reaction controls for Catches, and leading-overscroll/bottom-padding hooks for Profile Preview/Public Profile embedding. |
| `EventRecapViewModel` | `lib/swipes/presentation/event_recap_view_model.dart:11` | Recap data seam. Combines the event, current uid, and `eventParticipations` to derive checked-in count and the attendee IDs shown in the vibe grid without reading compatibility arrays. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:84` | Provider-free content body for the Catches hub: header, intro card for the featured adapter row, and active catch-window rows. Receives typed catch/recap callbacks from the route instead of pushing navigation itself. |
| `CatchesHubHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:153` | Header row for the Catches hub: "CATCHES" section header, "After the event" title, and heart icon treatment. |
| `CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:184` | Gradient hero card promoting the 24-hour catch window from `CatchesHubEventRow` display data: intro copy, countdown label, roster count, and "Start catching" CTA. The parent `CatchSurface` owns tap handling; the solid-white CTA is a non-interactive `CatchButtonVariant.light` display label so accessibility and color pairing stay correct. |
| `ProfileHeroWidget` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:123` | Dark editorial profile hero. Composes graded/fallback profile media, hero scrim, activity-colored kicker, display name/age, meta line, and optional overlay reaction controls. |
| `ProfileHeroScrim` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:209` | Non-interactive dark vertical gradient used over profile hero media so name/meta/reaction chrome remain legible. |
| `ProfilePhoto` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:237` | Profile media renderer. Shows a graded real photo when present, otherwise falls back to the activity artwork for the profile's kicker activity. |
| `ProfileSectionView` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:266` | Public section dispatcher for `ProfileSection` display models. Routes compatibility, prompt, running, facts, and photo sections to their named renderers, and adds section reaction controls only when the parent Catches surface supplies `onReact`. |
| `ProfileSectionKicker` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:326` | Uppercase mono section label used by profile compatibility, prompt, running, and fact sections, with optional activity accent color. |
| `ProfileCompatibility` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:344` | Compatibility block for "why you might click" content. Renders checked reasons plus confidence badges from the pure `ProfileCompatibilitySection` display model. |
| `ProfilePrompt` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:401` | Profile prompt renderer. Shows the prompt question as a kicker and the answer in the profile-answer text role. |
| `ProfileRunning` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:425` | Running identity section. Presents pace and distance through `RunningStat`, then supporting reasons/times and optional tags. |
| `RunningStat` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:471` | Compact profile running metric with uppercase label and large numeric value. |
| `ProfileFacts` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:496` | Titled icon/text facts block for profile details and lifestyle sections. |
| `ProfilePhotoBlock` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:540` | Standalone profile photo section. Uses the same `ProfilePhoto` media renderer, optional caption, and optional overlay reaction controls for photo-specific reactions. |
| `PhotoCaption` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:591` | Dark translucent caption pill used over standalone profile photos. |
| `ProfileRule` | `lib/swipes/presentation/profile_redesign/catch_profile_view.dart:614` | Hairline divider inserted between profile body sections. |
| `CatchesHubEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:299` | Provider-free empty state when no active catch windows exist. Receives the "Find an event" callback from `SwipeHubScreen` so Widgetbook and tests can render it without router side effects. |
| `CatchesProfileReviewSkeleton` | `lib/swipes/presentation/swipe_screen.dart:178` | Profile-shaped Catches deck loading shell. Reuses `ProfileSurfaceSkeleton`, preserves the top overlay geometry with circular/pill placeholders, keeps the bottom scrim, and shows a pass-button placeholder while the queue loads. |
| `CatchesProfileReview` | `lib/swipes/presentation/swipe_screen.dart:224` | Provider-free Catches deck composition. Layers the reactable `ProfileSurface`, `CatchesTopOverlay`, `CatchesBottomScrim`, and floating `CatchesPassButton` while receiving back/filter/pass/reaction callbacks plus immutable action-state display data from `SwipeScreen`. |
| `CatchesTopOverlay` | `lib/swipes/presentation/swipe_screen.dart:363` | Floating deck top overlay with back and filter controls plus the remaining-candidate pill. Intended to stay callback-driven by the route adapter. |
| `CatchesBottomScrim` | `lib/swipes/presentation/swipe_screen.dart:472` | Bottom gradient scrim that keeps the floating pass action legible over the full-screen profile surface. |
| `FiltersContent` | `lib/swipes/presentation/filters_screen.dart:157` | Provider-free body for Filters preferences. Renders age range, interested-in chips, and apply dock from explicit draft values, saving state, and typed callbacks so Widgetbook can review default, dirty, reset, pending, text-scale, and reduced-motion states without live providers. |
| `FiltersContentSkeleton` | `lib/swipes/presentation/filters_screen.dart:250` | Control-shaped Filters loading body. Mirrors the loaded age section, interested-in chips, and bottom apply dock while profile defaults resolve. |
| `FiltersSection` | `lib/swipes/presentation/filters_screen.dart:354` | Shared section wrapper for Filters rows. Keeps uppercase kicker labels, tokenized vertical padding, and bottom hairline treatment consistent across the age and interested-in sections. |
| `FiltersValue` | `lib/swipes/presentation/filters_screen.dart:383` | Display value text for the current Filters range, using the shared title role and the storage/display age formatter boundary from `filtersAgeRangeValues`. |
| `EventRecapLoadingBody` | `lib/swipes/presentation/event_recap_screen.dart:172` | Recap-shaped loading body with hero/stat placeholders, supporting copy skeleton, attendee-grid placeholders, and a primary CTA placeholder. |
| `EventRecapReadyBody` | `lib/swipes/presentation/event_recap_screen.dart:129` | Provider-free Event Recap loaded body. Receives `EventRecapReady`, vibe-toggle callback, and open-deck callback from `EventRecapScreen`, renders the recap hero, attendee selection prompt, empty-roster fallback or `VibeGrid`, and the open-catches CTA without reading providers or owning route navigation. |
| `VibeGrid` | `lib/swipes/presentation/event_recap_screen.dart:193` | Provider-free Event Recap attendee grid. Receives `EventRecapAttendeeRow` display rows and a typed vibe-toggle callback, lays tiles out through the responsive grid count, keys each tile with `SwipeKeys.vibeTile`, and delegates selected/fallback profile rendering to `VibeTile`. |
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
| `CatchesPassButton` | `lib/swipes/presentation/widgets/catches_pass_button.dart:6` | Floating lower-left pass button used on the Catches decision screen after removing generic deck action buttons. Uses the shared pass key, tooltip, semantic label, disabled opacity, and pending spinner state supplied by the route-owned action state. |
| `ProfileReactionControls` | `lib/swipes/presentation/widgets/profile_reaction_controls.dart:22` | Shared like/comment controls for reactable profile sections. Catches uses surface, overlay, vertical, disabled, and pending variants; the comment action opens the shared reaction comment sheet. |
| `ProfileReactionCommentSheet` | `lib/swipes/presentation/widgets/profile_reaction_controls.dart:100` | Shared reaction-comment bottom sheet used by `ProfileReactionControls`. Keeps comment entry provider-free, uses canonical `CatchBottomSheetScaffold`/`CatchField` chrome, supports empty and prefilled draft review states, and is cataloged directly for exact Widgetbook review. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Provider-free deck empty/access state. Renders copy from `buildSwipeEmptyContent` for empty queue, event missing, sign-in required, event in progress, did-not-attend, and closed-window branches. |
| `AttendedEventTile` | `lib/swipes/presentation/widgets/attended_event_tile.dart:11` | Provider-free row tile for an attended event in the catches hub list. Renders `CatchesHubEventRow` title, date/attendance label, countdown label, recap CTA, and catch badge; catch and recap navigation callbacks are supplied by `SwipeHubScreen`. |

---

## Matches / Chats

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/chats/presentation/inbox/chat_inbox_screen.dart:16` | "Chats" / Host "Inbox" tab shell registered as `screen.host.inbox` for the host route. Builds `HostInboxScreenState` from uid, `ChatsListViewModel`, search query, and host filter state; owns typed host/consumer chat route callbacks plus the route-scoped host broadcast review sheet; then renders the pinned composable browse header and chat body from explicit display state. |
| `ChatsBrowseHeader` | `lib/chats/presentation/inbox/widgets/chats_sliver_header.dart:34` | Stateful chats browse-header adapter that removes the old count badge, composes pinned title/search chrome through `CatchTopBar`, binds `chatSearchQueryProvider`, and renders the host inbox `All` / `Unread · n` option row when supplied. It owns provider and filter wiring only; reusable top-bar/search visuals stay in the canonical primitive. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsList` | `lib/chats/presentation/inbox/widgets/chats_list.dart:18` | Sliver body for chat conversations fed from `ChatsListDisplayState` or, for legacy callers, `chatsListViewModelProvider`. Uses a section-labeled inbox-row skeleton loading sliver, branded error state, explicit empty states, host unread filtering, and delegates populated data plus optional row-selection and host-broadcast callbacks to `ChatsListBody`. |
| `MatchCelebrationDialog` | `lib/matches/presentation/widgets/match_celebration_dialog.dart:46` | Compatibility-named full-screen match celebration route. Uses `CatchCelebrationScreen` with match haptics, then routes the primary action into `ChatScreen` or dismisses back to swiping. |
| `CatchPersonRow` | `lib/core/widgets/catch_person_row.dart:77` | Canonical inbox and roster row. Receives `CatchPersonRowData`, renders directly on the page surface with an optional inset hairline divider, `CatchPersonAvatar` (rounded square for host inquiries), display name, semantic `chatPreview` secondary text, timestamp, and row-level unread/new treatment through avatar ring, text color, timestamp color, unread badge, or a trailing new-match dot. Routes to `ChatScreen` or `hostChatScreen` through the parent row-list section. Widgetbook exposes standalone states for read, unread, new match, own latest, host inquiry, roster, and long preview rows. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Chats query adapter over `CatchSearchField` for standalone chat search placements. `ChatsSliverHeader` binds `chatSearchQueryProvider` directly through the shared `CatchSearchField` expanding mode primitive. |
| `ChatConversationsList` | `lib/chats/presentation/inbox/widgets/chat_conversations_list.dart:8` | Headerless, provider/router-free `SliverList` of chat previews driven by `ChatsListViewModel`. Renders contiguous on-surface `CatchPersonRow` rows with row dividers instead of spacing between card surfaces; callers decide whether the input list includes new matches, conversations, or both and supply the row-selection callback. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/chats/presentation/inbox/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations, no search results, or no unread host queries. |
| `ChatsListBody` | `lib/chats/presentation/inbox/widgets/chats_list_body.dart:10` | Body wrapper for the chats list. Folds `viewModel.newMatches` and `viewModel.conversations` into one contiguous row list, renders `HostInboxBroadcastCard` as the host populated-state lead-in, keeps the consumer `CONVERSATIONS` section label, and delegates row rendering plus parent-supplied callbacks to `ChatConversationsList` without rendering the old new-match rail. |
| `HostInboxBroadcastCard` | `lib/chats/presentation/inbox/widgets/chats_list_body.dart:72` | Provider-free dark host broadcast lead-in card for populated Host Inbox states. Shows the broadcast affordance, attendee-count copy, short template hint, and a parent-owned tap callback so route-level send/review behavior stays outside the row-list primitive. |
| `HostBroadcastComposerSheet` | `lib/chats/presentation/inbox/chat_inbox_screen.dart:136` | Route-scoped Host Inbox broadcast review sheet. Shows the disabled future-send action plus template preview rows with tokenized `CatchSurface` composition while actual broadcast sending remains unconnected and owned outside the shared list body. |
| `ChatsSliverHeader` | `lib/chats/presentation/inbox/widgets/chats_sliver_header.dart:12` | Chats-specific pinned sliver header. It expands its fixed bottom height for the host `OptionGroup`, delegates title/search chrome to `ChatsBrowseHeader` and `CatchTopBar`, and keeps query state in `chatSearchQueryProvider`. |
| `ChatsListSkeleton` | `lib/chats/presentation/inbox/widgets/chats_list.dart:205` | Sliver-native loading body for the inbox list. Preserves the section label and contiguous `CatchPersonRow` skeleton geometry so loading states do not collapse to a spinner or card stack. |
| `ChatPersonRowSkeleton` | `lib/chats/presentation/inbox/widgets/chats_list.dart:249` | Loading atom for a single inbox row. Mirrors `CatchPersonRow` avatar, title, preview, timestamp, unread-pill, optional divider, and host square-avatar geometry for both consumer matches and host inquiries. |

---

## Chat Screen

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatScreen` | `lib/chats/presentation/chat_screen.dart:34` | Stateful host/consumer chat thread screen registered as `screen.matches.chat` and `screen.host.chat`. Owns local text/scroll/tab controllers, mounted lifecycle effects, `ConversationReadMarker.markRead` side-effect calls, retry invalidation dispatch through `HostChatRetryIntent`, embedded Chat/Profile tab rendering for regular match chats, share-card presentation, mutation snackbar listening, and send/image/report/block/Suvbot action execution through controller mutations. The Chat tab keeps event context, messages, Suvbot controls, keyboard-safe multiline composer, send-failure feedback, report-failure feedback, and block confirmation; the Profile tab renders the shared public `ProfileSurface` with content-shaped loading, error retry, and unavailable states. Route provider waves and mutation-pending flags come from `ChatRouteState`; read-marker decision policy comes from `ChatReadMarkerState`; host inquiry identity, top-bar action availability, action intents, route error selection, message/Suvbot retry targets, safety-action pending disabled state, message peer name, and composer disabled copy come from `HostChatScreenState`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatEventContextHeader` | `lib/chats/presentation/widgets/chat_event_context_header.dart:20` | Handoff `ChatThreadHeader` event-context band. Grounds the thread in the latest shared event with activity soft fill, accent hairline/glyph, mono activity stamp, and event title/date copy; falls back to the neutral "MATCHED THROUGH CATCH" state while event context loads. Widgetbook exposes standalone states for social run, no event, dinner, and long custom event context. |
| `chat_event_context_copy` helpers | `lib/chats/presentation/widgets/chat_event_context_copy.dart:3` | Shared Messaging copy source for event-context stamps, chat share-card titles, and empty-thread prompts. Keeps thread header, share card, and empty state language aligned with the latest shared event and preserves neutral fallbacks while event context is unavailable. |
| `ChatShareCardSheet` | `lib/chats/presentation/widgets/chat_share_card.dart:47` | Share-card export bottom sheet for chat excerpts. Captures the anonymized `ChatShareCard` as PNG, hides names/photos/timestamps, owns share-button pending/error state, and delegates platform sharing through `ExternalShareController`. |
| `ChatShareCard` | `lib/chats/presentation/widgets/chat_share_card.dart:159` | Anonymized visual chat excerpt card. Selects the latest shareable messages, grounds the card in optional event context, renders the header, grouped quote bubbles, and Catch/event stamp, and keeps export details in `ChatShareCardSheet`. |
| `ShareCardHeader` | `lib/chats/presentation/widgets/chat_share_card.dart:232` | Public header renderer used by `ChatShareCard`. Displays the event-context stamp, title, and activity/chat icon with caller-provided accent and optional activity visual spec. |
| `ShareCardBubble` | `lib/chats/presentation/widgets/chat_share_card.dart:288` | Public anonymized quote-bubble renderer used by `ChatShareCard`. Applies sender alignment, grouped-corner geometry, width limits, and self/other fills without exposing identities or timestamps. |
| `ChatMessageList` | `lib/chats/presentation/widgets/chat_message_list.dart:14` | Message-list renderer for loading, error, empty, and populated states. Loading uses date plus alternating message-bubble skeletons through `CatchAsyncValueView`; populated data inserts centered day separators, splits same-sender bubble runs across day boundaries, and uses `CatchEmptyState` for empty threads. It receives the latest shared event so the empty prompt can match the Messaging handoff's event-grounded copy before the `Say hi` CTA, and it keeps variable-height `MessageBubble` rows for individual messages; do not add `prototypeItem`/fixed item extents because chat bubbles can wrap or contain images. |
| `ChatInputBar` | `lib/chats/presentation/widgets/chat_input_bar.dart:10` | Handoff `ChatComposer`: bottom dock with one contained dialogue pill. The image upload action is the leading slot, the bare message `CatchField.input` is the center slot, and the filled send action is the trailing slot inside the same field outline; disabled opacity, loading indicators, text-only mode, and real send/image callbacks stay owned by the composer. Widgetbook exposes standalone states for ready, sending text, sending image, disabled, and text-only modes. |
| `SuvbotActionBar` | `lib/chats/presentation/widgets/suvbot_action_bar.dart:27` | Demo-only chat bottom dock for Suvbot conversations. Groups check/refresh, warm-state, reset, help, and match-tester actions without rendering the normal chat composer. Reset actions open a handoff `CatchBottomSheetScaffold` with tokenized `CatchSurface` action rows instead of raw Material list tiles; text-required match tester actions keep their focused input sheet. |
| `MessageBubble` | `lib/chats/presentation/widgets/message_bubble.dart:10` | Handoff `ChatBubble`: end/start alignment by sender, primary vs surface fills, fused corners inside sender groups, quiet mono timestamps, pending timestamp state, and optional image attachment. Widgetbook exposes standalone states for self/other, long copy, grouped/sending, and image attachment bubbles. |
| `TimestampedMessageText` | `lib/chats/presentation/widgets/message_bubble.dart:110` | Public inline/stacked text timestamp renderer used by `MessageBubble`. Measures message and timestamp text with the current text scaler so short messages can place the timestamp inline and long messages stack it without overlap. |
| `MediaMessageBody` | `lib/chats/presentation/widgets/message_bubble.dart:210` | Public media/text body renderer used by `MessageBubble`. Renders optional image attachment, optional caption text, and trailing timestamp with caller-provided styles. |

---

## Public Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreen` | `lib/public_profile/presentation/public_profile_screen.dart:18` | Full-screen public profile view. Fetches `PublicProfile` by UID, passes the current viewer profile into the shared `ProfileSurface` when viewing someone else, accepts optional shared-event context for event-aware profile insight rendering, routes report/block actions through `PublicProfileController` mutations, and composes loading/error/unavailable/ready branches through provider-free `PublicProfileScreenBody`. Report reasons render through `PublicProfileReportSheet`; report/block success feedback uses `showCatchSnackBar`, while mutation pending remains an overlay spinner over already-rendered content. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreenBody` | `lib/public_profile/presentation/public_profile_screen.dart:161` | Provider-free route body for public profile loading, error, unavailable, and ready states. Receives retry as an explicit callback from `PublicProfileScreen`, renders `ProfileSurfaceSkeleton` while loading without fallback data, preserves initial-profile fallback by rendering `PublicProfileBody` ahead of stream data, and keeps branded `CatchErrorState` / `CatchEmptyState` fallbacks out of route-owned provider code. Widgetbook covers route-body states directly. |
| `PublicProfileBody` | `lib/public_profile/presentation/public_profile_screen.dart:197` | Provider-free body of the public profile with a shared cardless profile surface, optional shared-event context, and pending-action overlay. Used by the route and deterministic capture catalog. |
| `PublicProfileReportSheet` | `lib/public_profile/presentation/public_profile_screen.dart:239` | Provider-free report reason sheet built from `CatchBottomSheetScaffold` and shared `CatchField` reason choices. Used by the route report action and deterministic capture catalog. |
| `PublicProfileReportReasonTile` | `lib/public_profile/presentation/public_profile_screen.dart:288` | Single selectable public-profile report reason row. Widgetbook covers the row directly so safety action styling does not drift from the shared `CatchField` reason choice contract. |

---

## User Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileScreen` | `lib/user_profile/presentation/profile_screen.dart:16` | Profile tab destination. Gates screen-owned streams while the retained tab branch is inactive, owns the route-level top safe area, uses `NestedScrollView` for a scroll-away "Your profile" title plus a pinned handoff `CatchOptionGroup` Edit/Preview row, keeps native `TabBarView` paging for smooth horizontal tab swipes, and composes route branches through `SelfProfileTabBody`. Owns the `TabController` locally because tab selection is route UI state; `initialTabIndex` exists for deterministic Preview route captures while production keeps the Edit default. Preview renders full-bleed below the option row, with the shared `ProfileSurface` owning the inner body gutter. |
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:19` | Standalone signed-in edit tab content. Wraps the edit form in a `ListView` for isolated/non-sliver usage and renders the handoff sections Photos, Prompts, About you, Running, and Lifestyle through `CatchSection`/`ProfileInfoSection` on-surface groups. `ProfileInfoSection` stretches every `CatchField` row to the viewport edge so tap/focus highlights and row trailing controls run full-bleed instead of stopping at the section gutter. Simple text rows, including Display name, Email, Instagram, Job title, and Company, render as direct editable `CatchField.input` rows through `ProfileDirectTextEntryField`; they do not open inline disclosure drawers. `Display name` is the first editable About field and is the only public-facing profile name. Onboarding identity fields such as date of birth and gender are readonly, and last name is not shown publicly. Profile prompt rows use catalog-backed pickers that hide prompt IDs already selected in other rows. Optional/profile-detail fields, including Instagram, remain editable. Running is always visible and owns pace, distances, reasons, and favorite run times. Discovery-only preferences such as interested-in genders and match age range live in Filters, not Edit Profile. Optional single-choice edit sheets open unselected when the underlying field is empty. |
| `ProfileTabContent` | `lib/user_profile/presentation/widgets/profile_tab.dart:41` | Shared provider-free Profile Edit body used by both the standalone `ProfileTab` list and sliver-native `ProfileTabSliverBody`. It owns the handoff section ordering and receives the scroll/content wrapper as a builder so route and isolated review contexts stay canonical without duplicate adapters. |
| `ProfileFieldRow` | `lib/user_profile/presentation/widgets/profile_tab.dart:252` | Public descriptor-backed renderer for Edit Profile field rows. Maps `SelfProfileFieldRowDescriptor` variants to the canonical read-only, direct text, height, single-choice, multi-choice, and range row primitives while the parent route owns only expansion state and save/cancel collapse callbacks. Widgetbook covers mixed descriptor rows directly so future descriptor variants do not reintroduce private widget-returning helpers. |
| `ProfileDirectTextEntry` | `lib/user_profile/presentation/widgets/profile_tab.dart:358` | Public Profile Edit direct-text descriptor adapter. Normalizes descriptor defaults for current value/current field value and delegates rendering, validation, save behavior, keyboard/autofill, and patch conversion to `ProfileDirectTextEntryField` so simple text rows remain cataloged without private wrapper drift. |
| `ProfilePromptEntry` | `lib/user_profile/presentation/widgets/profile_tab.dart:512` | Public Profile Edit prompt-slot adapter. Converts `SelfProfilePromptSlotState` into `ProfileInlinePromptEntryEditor` inputs, including prompt title, placeholder, selected prompt id, duplicate-filtered prompt ids, expansion state, and save/cancel callbacks supplied by `ProfileTabContent`. |
| `ProfileTabSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:69` | Sliver-native profile edit body. Reuses the same handoff sections as `ProfileTab` but contributes a padded sliver adapter for parent `CustomScrollView` usage. Uses `profileTabBodyPadding` for the edit body; Preview is full-bleed and no longer shares this inset. |
| `ProfileTabSkeletonSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:92` | Sliver-native Edit-tab loading skeleton. Reuses `profileTabBodyPadding`, `CatchSection`, the 3x2 profile-photo grid geometry, and profile info-row spacing to mimic Photos, Profile strength, Prompts, About you, Running, and Lifestyle while the signed-in profile stream resolves. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `UserAnalyticsPanel` | `lib/user_analytics/presentation/user_analytics_panel.dart:17` | Profile insights panel embedded from the profile Insights tab. Watches the user analytics repository at the route edge, owns the range preset selector, and composes loading, error, empty, summary metrics, trend, coaching tips, and data-quality states through public child renderers. Widgetbook catalogs the panel for loaded, empty, loading, and error states, and catalogs the child renderers directly for deterministic visual review. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `UserAnalyticsReportView` | `lib/user_analytics/presentation/user_analytics_panel.dart:84` | Provider-free report renderer for loaded user analytics. Routes all-missing summaries to `UserAnalyticsEmptyState`; otherwise composes metric grid, trend panel, optional coaching tips, and data-quality panel in the profile Insights order. |
| `UserAnalyticsEmptyState` | `lib/user_analytics/presentation/user_analytics_panel.dart:114` | Profile Insights empty-state surface for reports with no measurable summary cards. Uses shared icon, supporting copy, and `CatchSurface` chrome instead of a feature-local empty card. |
| `UserAnalyticsReportSkeleton` | `lib/user_analytics/presentation/user_analytics_panel.dart:150` | Report-shaped loading skeleton for profile analytics. Reserves summary cards, trend bars, coaching tips, and data-quality rows while the selected analytics range is loading. |
| `UserAnalyticsMetricGrid` | `lib/user_analytics/presentation/user_analytics_panel.dart:309` | Responsive two-column summary metric grid. Receives precomputed metric cards and delegates card copy/status rendering to `UserAnalyticsMetricTile`. |
| `UserAnalyticsMetricTile` | `lib/user_analytics/presentation/user_analytics_panel.dart:335` | Single profile analytics summary card. Maps metric id/unit/status to icon, value formatting, status badge, canonical label/caption copy, and missing-data warning fill. |
| `UserAnalyticsTrendPanel` | `lib/user_analytics/presentation/user_analytics_panel.dart:399` | Profile analytics trend section. Summarizes caught-you and mutual-catch totals, then renders the caught-you time series through `UserAnalyticsBar` columns. |
| `UserAnalyticsBar` | `lib/user_analytics/presentation/user_analytics_panel.dart:469` | Single trend bar used by `UserAnalyticsTrendPanel`. Normalizes the value against the maximum and keeps zero-value bars visible with muted styling. |
| `UserAnalyticsTipsPanel` | `lib/user_analytics/presentation/user_analytics_panel.dart:498` | Coaching-tip section for profile analytics. Wraps ordered tip refs in the shared section/surface chrome and delegates row copy to `UserAnalyticsTipRow`. |
| `UserAnalyticsTipRow` | `lib/user_analytics/presentation/user_analytics_panel.dart:523` | Single coaching-tip row. Resolves copy from `UserAnalyticsCopy`, then renders the sparkle icon, title, and supporting body without provider access. |
| `UserAnalyticsDataQualityPanel` | `lib/user_analytics/presentation/user_analytics_panel.dart:558` | Data-quality section for profile analytics. Presents quality rows inside shared section/surface chrome with dividers between rows. |
| `UserAnalyticsDataQualityRow` | `lib/user_analytics/presentation/user_analytics_panel.dart:583` | Single data-quality row. Maps quality state to icon and renders the repository-provided detail text in supporting copy style. |
| `UserAnalyticsSection` | `lib/user_analytics/presentation/user_analytics_panel.dart:607` | Small labeled section shell used by analytics trend, tips, data-quality, and skeleton sections. Keeps the label/child spacing consistent across Insights blocks. |
| `UserAnalyticsInlineStat` | `lib/user_analytics/presentation/user_analytics_panel.dart:630` | Inline numeric stat used by the trend panel. Renders a large numeric value with a supporting label below it. |
| `SelfProfileTabBody` | `lib/user_profile/presentation/profile_screen.dart:161` | Provider-free self-profile branch renderer for loading, error, unavailable, and ready states inside `ProfileScreen`'s `NestedScrollView.body`. Receives the route-owned `TabController`, preview scroll controller, preview bridge callbacks, and retry callback explicitly. Loading preserves the tab shell with Edit skeleton, Preview skeleton, and Insights body; ready renders Edit, Preview, and Insights through sliver-aware tab scroll views. Widgetbook mounts it inside a `NestedScrollView` preview so the `SliverOverlapInjector` contract is exercised. |
| `ProfileTabScrollView` | `lib/user_profile/presentation/profile_screen.dart:250` | Shared tab scroll wrapper used by `SelfProfileTabBody`. Installs `CatchPagerFocusBoundary`, starts each tab with the `NestedScrollView` overlap injector, and then appends the tab slivers. |
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared handoff `ProfileSurface`, with owner-provided scroll controller, physics, bottom padding, and leading-overscroll callback when mounted inside ProfileScreen. |
| `ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:24` | Self-profile scroll-away title row. Renders the `Your profile` heading, screen-title spacing, page background, and settings action while the surrounding `ProfileSliverHeader` owns sliver placement. |
| `ProfileTabBar` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:51` | Self-profile pinned tab selector. Receives the route-owned 3-tab `TabController` and maps Edit, Preview, and Insights to the shared `CatchOptionGroup` with bottom hairline chrome. |
| `ProfileSettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:84` | Self-profile settings icon action. Uses `CatchTopBarIconAction` with the settings glyph and routes to `screen.settings.account` through the surrounding `GoRouter` context. |
| `ProfilePhotosSkeletonSection` | `lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:60` | Edit Profile loading photo section. Reuses `CatchSection.divided`, the production maximum profile-photo count, and the 3-column portrait grid geometry so the Photos section reserves the same slot rhythm while uploads/profile data resolve. |
| `ProfileInfoSkeletonSection` | `lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:89` | Edit Profile loading info section. Receives title and row count from `ProfileTabSkeletonSliverBody`, renders section chrome through `CatchSection.divided`, and inserts the same muted dividers between `ProfileInfoSkeletonTile` rows as the ready profile sections. |
| `ProfileInfoSkeletonTile` | `lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:129` | Single Edit Profile loading row placeholder. Preserves the profile field-row icon, two-line text, and trailing affordance geometry with tokenized `CatchSkeleton` blocks. |
| `ProfileInlineTextValue` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:299` | Prompt row value wrapper that renders the collapsed display value directly and composes active prompt-answer editing through `CatchField.input`. Supports multiline prompt editing, length limiting, blank-line normalization, autofocus, and shared underline input chrome without profile-local text-field implementation. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileDirectTextEntryField` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:77` | Direct editable profile text row built on `CatchField.input`. Owns the text controller, validation/save error display, blur/submit save behavior, keyboard/autofill settings, trimming, and field patch conversion for simple Edit Profile text rows. Empty rows keep the shared collapsed field contract until focus, with the offstage editable retained so first focus expands without triggering the horizontal pager. |
| `ProfileInlinePromptEntryEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:385` | Row-owned profile-prompt editor. Combines the inline prompt answer text primitive with a `CatchField.select` catalog picker, filters out prompt IDs used by sibling prompt rows, and saves ordered `profilePrompts` patches so prompt slots stay unique. |
| `ProfileInlineHeightEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:642` | Inline bounded height editor using bounded plus-minus controls and the shared inline editor panel. |
| `ProfileInlineSingleChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:533` | Row-owned nullable single-choice editor. Selected value renders in the row slot, available alternatives render below, and `Cancel`/`Done` owns commit/discard. |
| `ProfileInlineMultiChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:656` | Row-owned multi-choice editor. Selected chips stay in the row slot with check icons, available alternatives render below, and optional fields allow deselecting row chips. |
| `ProfileInlineRangeEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:912` | Inline range editor using `CatchRangeSlider`, local draft range state, endpoint labels for slider bounds, and the shared inline editor panel. The row owns the selected range display, so the editor does not repeat it above the slider. |

---

## Onboarding

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OnboardingScreen` | `lib/onboarding/presentation/onboarding_screen.dart:17` | Multi-step onboarding shell registered as `screen.onboarding.flow`. Initializes the correct entry point for full, profile-completion-only, and run-preferences-only flows, owns back-step boundaries, renders the shared top bar, and delegates body composition to step pages pending an `OnboardingFlowState` adapter. |
| `OnboardingTopBar` | `lib/onboarding/presentation/onboarding_screen.dart:143` | Public onboarding progress/header adapter used by `OnboardingScreen`. Converts `OnboardingStep` plus profile-completion/run-preference flow flags into `CatchStepHeader` copy and progress state while the route owns navigation. |
| `NameDobPage` | `lib/onboarding/presentation/pages/name_dob_page.dart:13` | Handoff Name + DOB step: headline/subtitle, FIRST NAME / LAST NAME / DATE OF BIRTH / verified PHONE fields, date picker, private-last-name and birth-year helper copy, and sticky Continue footer through `CatchBottomDock`. |
| `GenderInterestPage` | `lib/onboarding/presentation/pages/gender_interest_page.dart:13` | Handoff Gender step using uppercase section labels, `ChipField` selections, validation, stable semantic chip keys, and sticky Continue footer. |
| `InstagramPage` | `lib/onboarding/presentation/pages/instagram_page.dart:10` | Handoff Instagram step with verification/privacy copy, HANDLE field, sticky Continue action, and secondary Skip for now action that advances without saving a handle. |
| `ProfilePromptsPage` | `lib/onboarding/presentation/pages/profile_prompts_page.dart:20` | Handoff Prompts step: three prompt cards, duplicate-prompt filtering through `CatchField.select`, inline answer fields, footer progress label, and disabled Continue until all prompt slots are answered. |
| `RunningPrefsPage` | `lib/onboarding/presentation/pages/running_prefs_page.dart:19` | Handoff Running prefs step: TYPICAL PACE range panel on `CatchSurface`, `CatchRangeSlider`, favorite distance/reason/time chip groups, and sticky Save/Continue booking footer. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomePage` | `lib/onboarding/presentation/pages/welcome_page.dart:11` | Animated logged-out start/welcome screen registered as `screen.start.welcome` and reused by `screen.onboarding.flow` welcome entry. It follows the Splash -> Welcome handoff with fixed `Catch`, deterministic object reel landing on `someone real`, tap/reduced-motion skip, body copy, primary Continue with phone CTA, and secondary See what's on CTA. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotosPage` | `lib/onboarding/presentation/pages/photos_page.dart:19` | Handoff Photos step with header copy, `PhotoGrid`, divider-backed photo tip band, disabled-state continue hint, and sticky Continue footer. Upload failure clears prior snackbar feedback and then uses `showCatchSnackBar` for the shared transient message styling. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomeScene` | `lib/onboarding/presentation/pages/welcome_page.dart:225` | Provider-free Welcome splash scene. Positions the object reel, fixed `Catch` wordmark, landed body copy, and Continue / See what's on CTA stack from explicit viewport height, media padding, spin, landing, and landed values. |
| `ReelBand` | `lib/onboarding/presentation/pages/welcome_page.dart:356` | Masked vertical object reel used by `WelcomeScene`. Converts spin/landing progress into a doubled phrase track, fade mask, and repeated `ReelRow` sequence landing deterministically on `someone real`. |
| `ReelRow` | `lib/onboarding/presentation/pages/welcome_page.dart:429` | Single Welcome reel phrase row. Uses `WelcomePhrase` activity pigment, distance from the reel focus line, landing fade/cool progress, and focus underline/period styling to render each spinning or landed phrase. |
| `RevealEntrance` | `lib/onboarding/presentation/pages/welcome_page.dart:525` | Welcome landing reveal wrapper. Converts shared landing progress plus reveal order into opacity and vertical offset for body copy and CTA entrances. |
| `OnboardingFormKeys` | `lib/onboarding/presentation/onboarding_form_keys.dart:4` | Stable semantic keys for onboarding form controls whose visible labels repeat across sections. |

---

## Auth

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthScreen` | `lib/auth/presentation/auth_screen.dart:7` | Phone-auth flow shell registered as `screen.auth.phone_entry`. Watches `AuthController.step` and switches between phone entry and OTP entry without owning visible handoff layout state; `PhonePage` and `OtpPage` provide the shared onboarding frame/header and sticky footer composition pending an auth display adapter for fixtures/previews. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `PhonePage` | `lib/auth/presentation/phone_page.dart:24` | Handoff phone entry step. Uses `CatchScreenBody`, `CatchStepHeader`, country selector + phone input row, sticky Send code footer, and stable auth form keys while keeping `AuthController.sendOtpMutation` behavior. |
| `OtpPage` | `lib/auth/presentation/otp_page.dart:19` | Handoff OTP entry step. Uses `CatchOtpCodeField`, resend countdown, Resend/Change number actions, sticky Verify footer, and existing auto-submit plus auth mutation behavior. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthFormKeys` | `lib/auth/presentation/auth_form_keys.dart:3` | Stable semantic keys for auth form controls and actions. |
| `_CountryCodeSelector` | `lib/auth/presentation/phone_page.dart:143` | Country-code picker shell used by `PhonePage`; keeps the flag selector in the handoff's fixed-width control lane and applies Catch dialog/search styling. |
| `CatchCodeInput` | `lib/core/widgets/catch_otp_code_field.dart:9` | Shared handoff `CodeInput` visual row used by `CatchOtpCodeField` and static OTP/code mocks. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:50` | Shared OTP primitive used by `OtpPage`; owns hidden platform input and delegates six visual cells to `CatchCodeInput` styling. |

---

## Launch Access

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `LaunchAccessApplicationScreen` | `lib/launch_access/presentation/launch_access_application_screen.dart:25` | Remote-Config-gated access application route. Shows disabled, signed-out, locked-status, or editable application states; the editable form collects city, role, event types, availability, host interest, invite/referral details, and reason copy before submitting through `LaunchAccessController.submitMutation`. uid/application loading renders `_LaunchAccessLoadingBody`, a form-shaped skeleton with header, field, choice-chip, host-toggle, text-area, and submit-button placeholders. Host-interest uses `CatchField.toggle`, while choice groups stay on `ChipField`. |

---

## Image Uploads

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfilePhotoEditorScreen` | `lib/image_uploads/presentation/profile_photo_editor_screen.dart:14` | Add/edit profile-photo flow opened by onboarding and Edit Profile. It picks or replaces the image, shows a crop preview, lets the user choose an optional catalog photo prompt that is not already used by another profile photo, supports guarded deletion, and saves through `PhotoUploadController.savePhoto` so grouped `profilePhotos` stay synchronized and duplicate prompts are cleared. The image-preview loading branch keeps the bounded crop frame and renders a `CatchSkeleton.custom` placeholder instead of an unshaped progress spinner. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OrderedPhotoPicker` | `lib/image_uploads/presentation/widgets/ordered_photo_picker.dart:32` | Shared ordered media picker for host club/event forms. Filters to previews with image data, renders add/photo tiles on `CatchSurface`, preserves semantic labels/tooltips, exposes stable add/remove keys, supports optional removal and reorder callbacks, optional first-photo cover badge, optional reorder-handle visibility, and keeps callers responsible for upload/persistence state. Add-tile visible labels collapse in short/high text-scale tiles while semantic labels and tooltips remain. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotoGrid` | `lib/image_uploads/presentation/photo_grid.dart:10` | Dense 3x2 profile photo grid over normalized `ProfilePhoto` objects. Uses `maximumProfilePhotoCount`, keyed slots, guarded delete callbacks, optional reorder, and a hideable leading `MAIN` label; callers own opening `ProfilePhotoEditorScreen` and enforcing the completed-profile minimum. |
| `PhotoSlot` | `lib/image_uploads/presentation/widgets/photo_slot.dart:6` | Single keyed profile-photo slot. Renders through `CatchSurface`, grades filled photos with `GradedImage`, shows DS striped material for pending uploads, dashed hairline targets for empty slots, semantic labels/tooltips for add/edit/delete/uploading/unavailable states, optional prompt and main-label overlays, reorder target affordance, and blocked taps while inactive or loading. |

---

## Run Clubs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateClubScreen` | `lib/hosts/presentation/club_management/create/create_club_screen.dart:36` | Host-owned create/edit club form shared by `screen.host.club.create` and `screen.host.club.edit`. Uses shared `CatchFormStepSpec` metadata with `CatchStepFlowHeader`, `StepperFooter`, create-only local drafts, cover/profile photo picking, host defaults, a dedicated event-success defaults step, and submit mutation feedback. Draft restore/save feedback uses `showCatchSnackBar`. `initialDraft`, `initialStep`, `restoreSavedDraft`, `formAutovalidateMode`, initial picked media hooks, and static mutation harnesses make wizard plus create-route validation/media/mutation states deterministic for Widgetbook/captures. Owner edit uses compact edit media variants plus grouped `CatchField` identity/contact rows in a single long form; co-host edit narrows to media-only updates. |
| `HostClubCreateState` | `lib/hosts/presentation/club_management/create/create_club_screen.dart:52` | Display adapter for create/edit club header and footer state. Resolves active step title, subtitle, total steps, owner edit scaffold mode, save-draft availability, last-step label, and pending loading state from immutable inputs before the screen composes form sections. |
| `ClubBasicsStep` | `lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart:11` | First club form step. Keeps cover/profile media, club name, city, and area fields in one fully mounted scroll body so validation sees all required fields. In co-host media edit mode, non-media fields render disabled. |
| `ClubDetailsStep` | `lib/hosts/presentation/club_management/create/widgets/club_details_step.dart:7` | Second club form step. Holds required description plus optional contact fields. |
| `ClubHostDefaultsStep` | `lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart:17` | Third club form step. Configures club-level host defaults for admission, cohort caps, dynamic pricing, age range, cancellation policy, and default activity inherited by new events. Uses handoff `SelectChip` selectors and `CatchField.toggle` switches in both create-flow and embedded edit-mode layouts. |
| `ClubEventSuccessDefaultsStep` | `lib/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart:6` | Fourth club form step. Wraps `EventSuccessDefaultsPanel` for the club's primary activity so event-success run-of-show defaults are edited separately from booking policy defaults. |
| `ExploreCityPicker` | `lib/explore/presentation/widgets/explore_city_picker.dart:12` | Compact city scope picker for the Explore browse header. The closed trigger is a fixed-size circular `CatchControlShell` with a location icon only, while the full city label stays in tooltip/semantics and the token-styled bottom sheet. It updates `selectedExploreCityProvider`, clears Explore search on city changes through the provider seam, listens for GPS/profile auto-selection, and keeps the selected city while the remote city list is loading or unavailable. |
| `CityTrigger` | `lib/explore/presentation/widgets/explore_city_picker.dart:120` | Provider-free closed state for the Explore city picker. Receives the selected `CityData`, focus/enabled state, presentation mode, optional foreground color, and tap callback, then renders either the compact icon pill or scope-label text control with shared tooltip and semantics copy. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubDetailScreen` | `lib/clubs/presentation/detail/club_detail_screen.dart:34` | Club detail screen shared by consumer Club Detail and the host `screen.host.club.detail` route. Fetches the club, current user profile, active membership edge, upcoming events, and reviews, then resolves `HostClubDetailScreenState` before composing loading, error, not-found, initial fallback, or public-preview content. Join/leave mutations stay in `ClubMembershipController`; host app role suppresses the consumer membership dock through explicit adapter state. The screen owns retry execution, share, contact, host profile/message, and schedule route side effects before passing callbacks into the shared body. |
| `ExploreList` | `lib/explore/presentation/widgets/explore_list.dart:14` | Sliver state-dispatch widget for the Explore tab's club directory state. Renders directory-card skeletons, error, city-empty, search-empty, filter-empty, and data slivers from `ExploreViewModel`, which partitions joined/discover clubs from active membership edges, and owns join-mutation feedback. |
| `ExploreListEmptyState` | `lib/explore/presentation/widgets/explore_list.dart:70` | Provider-aware Explore list empty-state adapter. Selects city-empty, search-empty, filter-empty, or combined search/filter-empty copy from explicit city/search/filter inputs, while clear actions still route through the Explore provider seam. |
| `ClubDirectorySkeletonList` | `lib/explore/presentation/widgets/explore_list.dart:125` | Explore club-directory loading stack. Renders three stable `ClubDirectorySkeletonCard` rows with shared vertical spacing so the provider-backed `ExploreList` loading branch keeps directory page rhythm. |
| `ClubDirectorySkeletonCard` | `lib/explore/presentation/widgets/explore_list.dart:142` | Single Explore club-directory skeleton card. Uses `CatchSurface`, `CatchSkeleton`, and named `CatchLayout` skeleton dimensions for image, title, subtitle, chips, divider, footer avatar, and action placeholders. |
| `ExploreFilterRail` | `lib/explore/presentation/widgets/explore_filter_rail.dart:18` | Handoff Explore scope/filter rail. Renders the visible time scopes (Tonight, Weekend, This week, Anytime) as whole text labels in a horizontally safe lane, keeps the filter glyph pinned to the right with an active-count badge, and never ellipsizes the labels. Secondary distance/joined filters stay in a tokenized `CatchBottomSheetScaffold` with handoff `SelectChip` choices. The rail stays backed by `exploreFiltersProvider` and can receive transparent/opaque background colors from the floating map chrome. |
| `ExploreRailLabel` | `lib/explore/presentation/widgets/explore_filter_rail.dart:89` | Provider-free time-scope label used inside `ExploreFilterRail`. Receives label, selected state, and tap callback, then renders the animated underline/tab text with button and selected semantics while the rail owns filter mutation. |
| `ExploreFilterGlyphButton` | `lib/explore/presentation/widgets/explore_filter_rail.dart:138` | Pinned filter glyph button used inside `ExploreFilterRail`. Receives active-count copy, semantic label, and tap callback, then renders the tune icon with `CatchIconBadge` so filter state stays visible without giving the leaf provider access. |
| `ExploreFilterSheet` | `lib/explore/presentation/widgets/explore_filter_rail.dart:179` | Public Explore filter-sheet content opened by `ExploreFilterRail` and rendered directly in Widgetbook. It keeps distance and joined-club controls on the same `exploreFiltersProvider` seam as the rail and uses `CatchBottomSheetScaffold`, `CatchButton`, and `CatchSelectChip` instead of a feature-local sheet shell. |
| `ClubMembershipDock` | `lib/clubs/presentation/detail/widgets/catch_club_dock.dart:270` | Consumer club detail membership dock. Calls `ClubMembershipController` for join/leave/notification actions and renders through the canonical `CatchClubDock` primitive. |
| `DockCount` | `lib/clubs/presentation/detail/widgets/catch_club_dock.dart:191` | Compact numeric count block used inside the club dock. Renders the member/going number with the shared numeric text style and quiet uppercase label while the parent dock decides whether counts apply to the current membership state. |
| `DockBell` | `lib/clubs/presentation/detail/widgets/catch_club_dock.dart:225` | Club notification bell action used by the member dock state. Receives active/loading/accent inputs explicitly, renders active and inactive notification glyphs through `CatchIconButton`, and swaps to `CatchLoadingIndicator` during push-notification mutation work. |
| `MutationErrorSnackbarListener` | `lib/core/widgets/mutation_error_snackbar_listener.dart:13` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used for transient mutation errors such as join/leave club failures. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubDetailLoadingBody` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:9` | Club-profile-shaped loading body for no-fallback Club Detail route loads. Mirrors the loaded hero, stats strip, host card, about copy, tag chips, and upcoming event sections while `initialClub` fallback still renders real content when available. |
| `ClubHeroLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:62` | Club Detail loading hero. Reserves the no-cover hero height and bottom-aligned title/location/summary placeholders so loading route transitions do not collapse the visual identity area. |
| `ClubStatsLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:98` | Club Detail loading metric strip. Uses the same compact `CatchSurface` padding and four-column/divider rhythm as the loaded club stats row. |
| `ClubStatLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:123` | Single Club Detail loading metric cell with value and label placeholders. Used only inside `ClubStatsLoadingSkeleton` so metric spacing remains centralized. |
| `ClubStatsDividerSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:139` | Hairline divider used between Club Detail loading metric cells. Keeps the loading strip aligned with the loaded metric rail divider treatment. |
| `ClubHostLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:155` | Club Detail loading host row. Reserves avatar, host name, and subtitle slots inside the same compact surface treatment as the loaded host card. |
| `ClubTextLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:185` | Configurable Club Detail loading text block used for About-style sections. Callers choose the line count while the shared skeleton primitive owns shimmer rendering. |
| `ClubTagLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:196` | Club Detail loading chip wrap for activity/tag sections. Uses pill-radius skeleton boxes with stable spacing so the section height matches loaded tag wraps. |
| `ClubScheduleLoadingSkeleton` | `lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart:225` | Club Detail loading schedule stack. Reserves two compact event-card slots in the Upcoming section while agenda data is loading. |
| `ExploreScreen` | `lib/explore/presentation/explore_screen.dart:31` | Explore tab route. Owns the persistent sheet-over-map browse surface: `EventMapView` stays mounted behind a draggable sheet and receives its map view model from the same filtered event discovery feed used by the list. The Explore chrome/header/filter rail are part of the primary `CustomScrollView`, so the cover header scrolls away with the feed instead of sitting outside the scroll owner. The screen no longer wraps the scroll view in a top `SafeArea`; the Explore header owns top-inset padding so the hero/background can paint to the viewport edge while row content stays below the status area. The floating `Map` control uses shared `CatchCountPill` and appears only in this full/list state; after opening, users close or resize by dragging the handle. Programmatic map open lands on a higher detent just under the filter strip, fades the top lid/header/filter backgrounds transparent, and keeps the city/search/filter controls floating over the map while the sheet edge rounds and selected map pins render a full-width ticket card unless the selected pin is the feed's actual featured event, in which case the spotlight card remains. User drags use soft settling zones: releases near the shorter bottom extent, map detent, or full/list state animate into those anchors, while the middle range can rest naturally. The peek state renders only aggregate result summary copy. Selecting a map pin stores the selected event id and snaps to the map selected-card state. The screen also listens for map camera-center changes so nearby event ordering can remain spatial, and a distance-ring tap cycles the active distance filter. |
| `ExploreBody` | `lib/explore/presentation/widgets/explore_body.dart:10` | Sliver-native data body for the Explore tab. Production `ExploreScreen` disables the old personal rail and directory stack, then composes the mixed `ExploreEventsSection` with the bottom-of-page `ExploreEventTypeBrowseGrid` without embedding a vertical `ListView` inside the parent `CustomScrollView`. Legacy callers can still opt into the joined-club rail or club directory through explicit flags. |
| `ExploreEventsSection` | `lib/explore/presentation/widgets/explore_events_section.dart:132` | Mixed Explore discovery section. Watches the event discovery feed, accepts candidate clubs from `ExploreBody`, removes the feed's featured item from the body list, and renders a handoff result-count line from the remaining visible items (`1 PLAN` / `10 PLANS · JUN 11-17`), skipping that cue for club-only fallback content. It leads the default This week filter with a no-gap ticket strip only when there are at least five day-level `EventDateRailCard` recommendations. Weekly-strip events are excluded from the remaining mixed feed, which interleaves leftover compact event rows, an Instax-like club spotlight, and compact club rows. Event taps route to `Routes.eventDetailScreen`, club taps route to `Routes.clubDetailScreen`, club cards use shared club identity atoms, and event rows use `EventCapacityPresenter` for going/left copy. Skeleton/error/empty states still belong to the event discovery feed; debug builds can opt into non-tappable synthetic visual fill with `ENABLE_EXPLORE_SYNTHETIC_VISUAL_FILL`. |
| `CoverStoryChrome` | `lib/explore/presentation/widgets/catch_cover_story.dart:134` | Top chrome row inside `CatchCoverStory`. Receives paper color plus the parent story display model, renders optional location scope and search affordance, and keeps change-location/search callbacks as injected side effects owned by the containing Explore header. |
| `CoverStoryContent` | `lib/explore/presentation/widgets/catch_cover_story.dart:218` | Main copy/action block inside `CatchCoverStory`. Receives paper/accent colors plus the parent story display model, then renders kicker, headline, body, CTA, and one or two mono data lines while preserving CTA/data wrapping on narrow widths. |
| `CatchCrossPathsCard` | `lib/explore/presentation/widgets/catch_cross_paths_card.dart:21` | Explore cross-paths person card. Renders the postcard invitation variant or compact photo-row variant from activity pigment, quote/name/meta copy, optional graded portrait, join CTA, and optional like action while keeping navigation/mutations outside the card. |
| `CrossPathsSurface` | `lib/explore/presentation/widgets/catch_cross_paths_card.dart:193` | Shared Cross Paths card shell. Wraps caller content in tokenized `CatchSurface` chrome, border/radius, optional clipping, and card/raised shadow selection for postcard and photo-row variants. |
| `CrossPathsPortrait` | `lib/explore/presentation/widgets/catch_cross_paths_card.dart:225` | Graded Cross Paths portrait renderer. Paints the activity gradient fallback and overlays a graded network image when a profile photo URL is available. |
| `CrossPathsPolaroidRail` | `lib/explore/presentation/widgets/catch_cross_paths_card.dart:250` | Postcard-side visual rail with tilted white polaroid, embedded `CrossPathsPortrait`, `TO: YOU` postal copy, and hairline address rules. |
| `CrossPathsCtaRow` | `lib/explore/presentation/widgets/catch_cross_paths_card.dart:318` | Compact Cross Paths action row with primary join CTA and hairline favorite icon button. The parent card supplies callbacks so routing and like mutations stay outside the renderer. |
| `ExploreEventTypeBrowseGrid` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:17` | Bottom-of-page Browse by event type surface. Reads the current Explore feed and `exploreFiltersProvider`, renders `primaryBrowseActivityKinds` with the shared activity palette and visible-feed counts, and toggles `activityTag` filters from each tile. |
| `EventTypeBrowseContent` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:49` | Provider-free Browse by activity content renderer. Ranks visible feed items into activity slots, applies collapsed/expanded preview limits, and delegates responsive row layout to `ActivityTypeRows`. |
| `ActivityTypeRows` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:98` | Responsive row layout for Browse by activity. Uses one column below the event-type breakpoint and two columns above it while preserving `ActivitySlotView` routing and row spacing. |
| `ActivitySlotView` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:170` | Slot router for Browse by activity rows. Chooses `ActivityTypeRow` for activity entries and `MoreActivityTypesRow` for collapsed overflow slots. |
| `ActivityTypeRow` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:201` | Tappable activity filter row with activity accent dot, label, count, selected semantics, and active foreground color. Emits the activity kind through an injected callback instead of reading providers directly. |
| `MoreActivityTypesRow` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:261` | Collapsed overflow row for Browse by activity. Shows `+ n MORE TYPES`, forward affordance, and semantic expand label. |
| `ActivityDot` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:309` | Fixed-size pill-radius activity accent dot rendered through `CatchSurface` so Browse by activity rows use tokenized shape and sizing. |
| `EventTypeBrowseSkeleton` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:327` | Loading placeholder for the Browse by activity grid with kicker text skeleton plus two stable row skeletons. |
| `ExplorePeekRail` | `lib/explore/presentation/widgets/explore_peek_rail.dart:13` | Lead sliver builder for the Explore map sheet. `buildExploreMapSheetLeadSlivers` renders aggregate count/scope copy in collapsed mode, a selected-pin lead that branches between `CatchEventCard.ticket` and `CatchEventCard.spotlight` based on the feed's featured event id, and the nearby horizontal rail with `CatchEventCard.ticket` items, spatial reordering, and a semantic "See all" action in unselected half/full mode. |
| `CollapsedMapSummary` | `lib/explore/presentation/widgets/explore_peek_rail.dart:192` | Collapsed Explore map sheet summary. Receives count, scope label, and active filters, derives concise title/scope copy through `ExploreCollapsedMapSummaryState`, and renders centered one-line text inside the sheet lead padding. |
| `ExploreEventTicketCard` | `lib/explore/presentation/widgets/explore_peek_rail.dart:297` | Ticket-style Explore map event card used for selected pins and the nearby peek rail. Converts an `ExploreEventItem` into `ExploreMapEventTicketState`, then delegates title, time, countdown, price, capacity, status, hero tag, width, and tap handling to `CatchEventCard.ticket`. |
| `PeekRailSkeleton` | `lib/explore/presentation/widgets/explore_peek_rail.dart:540` | Loading skeleton for the Explore map nearby rail. Reserves the lead title and two horizontal ticket-card placeholders with the same rail height/spacing as the loaded peek rail. |
| `ClubDiscoverList` | `lib/clubs/presentation/discovery/widgets/club_discover_list.dart:8` | Club directory section of Explore with a real `SliverList` of directory cards. Passes joined and hosted club IDs separately so host-owned clubs are not mislabeled as ordinary joined clubs. |
| `ClubIdentityAtoms` | `lib/clubs/presentation/shared/club_identity_atoms.dart:11` | Shared club-card identity helpers and widgets: member-count label, tag filtering, member seal, tag wrap, hosted-by line, host avatar, host role badge, and rating pill. Use this before adding club-card-local member labels, tag wraps, host rows, or rating chips. |
| `ClubListTile` | `lib/clubs/presentation/discovery/widgets/club_list_tile.dart:33` | Club tile rendered as directory card or avatar chip. Directory cards now use the productionized concept-lab club language and shared club identity atoms: image-backed clubs get a bounded photo card with member seal, centrally themed `CatchTextStyles.clubDisplay` title, tags, host row, and role sash; no-image clubs get an identity card that reuses the shared fallback palette. Display-only tile rendering does not watch provider state; only the join button owns the mutation provider. |
| `ExploreEmptyState` | `lib/explore/presentation/widgets/explore_empty_state.dart:4` | Empty state for empty-city, search-empty, filter-empty, and combined search/filter-empty cases. Uses `CatchEmptyState` with recovery copy and optional clear actions owned by `ExploreList`. |
| `ExploreScreenEmptyState` | `lib/explore/presentation/explore_screen.dart:164` | Route-level Explore empty-state adapter. Receives provider-free `ExploreDiscoveryEmptyState` plus clear-search/filter callbacks from `ExploreScreen`, then delegates visual copy to `ExploreEmptyState` and action rendering to `ExploreClearAction`. |
| `ExploreClearAction` | `lib/explore/presentation/explore_screen.dart:204` | Provider-free secondary clear action used by Explore route/list empty states. Encodes clear-search, clear-filters, and combined clear behavior without reading providers or routing. |
| `ExploreFeedEventRow` | `lib/explore/presentation/widgets/explore_events_section.dart:243` | Compact mixed-feed event row. Converts `ExploreEventItem` into `EventDateRailCard` copy/status through `ExploreEventRowState`, applies the analytics-source hero tag, and keeps navigation/analytics as a tap callback owned by the Explore feed. |
| `ExploreExternalEventRow` | `lib/explore/presentation/widgets/explore_events_section.dart:278` | Read-only external supply row for imported organizer/source events. Shows source platform, activity stamp, event time/price, external-link action availability, and the no-Catch-booking disclosure while outbound opening stays behind the external-link controller. |
| `ThisWeekRecommendationsSection` | `lib/explore/presentation/widgets/explore_events_section.dart:369` | Weekly recommendation strip for the This week filter. Renders a count kicker, shared `CatchSectionHeader`, and a no-gap sequence of `ExploreFeedEventRow` cards with first/middle/last strip positions. |
| `ExploreClubPolaroidCard` | `lib/explore/presentation/widgets/explore_events_section.dart:414` | Instax-style club spotlight for the mixed Explore feed. Reuses `CatchPolaroid`, `ExploreClubCover`, shared club tags, member-count/action dark pills, and the club interaction hero tag while synthetic preview clubs stay non-tappable. |
| `ExploreFeedClubRow` | `lib/explore/presentation/widgets/explore_events_section.dart:455` | Compact club row for lower-priority mixed-feed club recommendations. Uses a fixed thumbnail cover, deterministic club accent, row kicker, title/supporting copy, and a muted affordance for synthetic preview rows. |
| `ExploreClubCover` | `lib/explore/presentation/widgets/explore_events_section.dart:522` | Shared Explore club media renderer. Grades real club imagery through `CatchGradedImage`/`CatchNetworkImage` and falls back to `ClubPolaroidArtwork`, with a compact mode for row thumbnails. |
| `ExploreClubTags` | `lib/explore/presentation/widgets/explore_events_section.dart:544` | Club tag footer for Explore mixed-feed cards. Renders shared `ClubTagWrap` tags when available and falls back to the uppercase member-count mono label when tag data is empty. |
| `ExploreDarkPill` | `lib/explore/presentation/widgets/explore_events_section.dart:562` | Dark pill label used on Explore club spotlight overlays and compact actions, with compact padding for footer actions. |
| `ExploreMonoLabel` | `lib/explore/presentation/widgets/explore_events_section.dart:591` | Single-line mono/kicker text atom used for Explore result counts, source labels, read-only supply labels, and club row kickers. |
| `ExploreEventsLoadingSliver` | `lib/explore/presentation/widgets/explore_events_section.dart:616` | Sliver-native mixed-feed loading state. Reserves the Explore feed skeleton height inside a tokenized `CatchSurface` so the parent scroll extent stays stable while event discovery loads. |
| `ExploreEventsEmptySliver` | `lib/explore/presentation/widgets/explore_events_section.dart:643` | Sliver-native empty feed state for the event discovery section. Receives provider-free `ExploreEventsEmptyState` plus clear-search/filter or time-window callbacks from `ExploreEventsSection`, then renders the inline `CatchEmptyState` recovery action. |
| `ClubAvatarRail` | `lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart:12` | Horizontal rail of the user's joined clubs plus an optional create-club tile. Uses larger rounded image chips so no-photo fallback marks and live badges remain legible, and exposes padding/divider controls so Home can reuse the rail without Explore-specific chrome. |
| `_CreateClubButton` | `lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart:36` | Rounded-square create tile at the end of the avatar rail to create a new club. |
| `ExploreBrowseHeaderContent` | `lib/explore/presentation/widgets/explore_header.dart:23` | Explore-specific browse header. It can render in the pinned sliver slot or inside Explore's floating chrome layer, owns temporary search-open state, wires city picker and search actions through shared primitives, accepts an optional background color, and keeps query state in `exploreSearchQueryProvider` for event and club search. |
| `ClubHeroAppBar` | `lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:21` | Club detail identity hero with cover-photo support, shared branded fallback, name, optional location-label override, back, and share. The hero uses `clubInteractionHeroTag` and the same base `clubInteractionMediaPadding` as the Explore Polaroid club card, and owns the device-derived top viewport curve that clips its media frame. Hero back/share actions use the shared floating `CatchIconButton` chrome. The caption sits outside that clipped frame on the page surface, uses tighter `CatchLayout.clubDetailHero*` sizing so the Claude reference title fits one line, shows an area/city kicker, and can receive the next event address from `ClubDetailBody`. Expanded and collapsed titles use the central `CatchTextStyles.clubDisplay` treatment. Rating and host-only ownership cues stay out of the hero, and no-photo headers use a shorter height. |
| `ClubHeroModule` | `lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:230` | Provider-free Club Detail hero module used inside `ClubHeroAppBar`'s flexible space. Receives computed media height, kicker, and location copy, owns the curved media frame, `CatchDetailHeroBackdrop`, expanded club title, and location row without route actions or provider reads. |
| `ClubContactAction` | `lib/clubs/presentation/detail/club_detail_screen_state.dart:14` | Typed contact-row intent emitted by `ClubDetailBodyState`. Encodes Instagram, phone, and email labels/URIs plus whether the link should open externally so `ClubDetailScreen` can own the platform link side effect. |
| `ClubDetailBody` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:74` | Scrollable public club detail body on a white page surface: hero, optional next-run banner, stats apron, then handoff-style `CatchSection`s for About, What we do, From the club, Your hosts, Get in touch, schedule, and read-only club review aggregate. The body is a reusable renderer: it receives typed callbacks for share, schedule taps, host profile/message actions, and contact links instead of reading GoRouter or external link/share providers itself. For Host Club Detail parity, it passes the next event address into `ClubHeroAppBar`, renders activity-kind chips before generic tags, uses regular-weight About copy, splits additional generic tags onto a follow-up wrap row, keeps the current public-preview contract, and leaves operational Add event, Edit club, payouts, and host-team editing in Host Operations unless a future design contract moves them here. |
| `ClubNextRunBanner` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:205` | Optional next-run banner shown near the top of Club Detail when the club has an upcoming event. Uses activity pigment, event date/time copy from `EventFormatters`, tap semantics, and a forward affordance while navigation remains an injected callback. |
| `ClubActivitySection` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:275` | Activity/tag renderer for the Club Detail "What we do" section. Promotes supported activity kinds into `CatchActivityChip`s, keeps the primary activity highlighted, and renders remaining generic tags through neutral `ClubTagWrap` rows. |
| `ClubHostSection` | `lib/clubs/presentation/detail/widgets/club_host_section.dart:17` | Provider-free Club Detail hosts section. Receives the club, profile-view affordance, pending message flag, and precomputed messageable host ids from `ClubDetailBodyState`; renders owner/host rows without reading providers or deciding app-role policy. |
| `ClubHostRow` | `lib/clubs/presentation/detail/widgets/club_host_section.dart:72` | Provider-free host row used by `ClubHostSection`. Renders avatar/name/owner badge, public-profile or view-profile meta, optional message icon, and optional chevron from explicit display inputs. |
| `ClubContactSection` | `lib/clubs/presentation/detail/widgets/club_contact_section.dart:15` | Provider-free Club Detail contact section. Receives typed `ClubContactAction`s from `ClubDetailBodyState` and delegates link launching to an injected callback. |
| `ClubPhotoStrip` | `lib/clubs/presentation/detail/widgets/club_photo_strip.dart:9` | Provider-free Club Detail photo strip for up to three club photos with thumbnail fallback, count label, and design-token spacing. The parent decides whether the section should render. |
| `ClubShareCard` | `lib/clubs/presentation/detail/widgets/club_share_card.dart:46` | Shareable club card rendered inside `RichShareCardSheet`. Uses `CatchSurface`, bounded rich-card aspect ratio constants, cover-photo or `ClubPolaroidArtwork`, shared club identity atoms for member/tag copy, and `clubShareText` for the public club deep link. |
| `ClubShareArtwork` | `lib/clubs/presentation/detail/widgets/club_share_card.dart:134` | Media block used by `ClubShareCard`. Chooses the primary club photo for `CatchDetailHeroBackdrop` when present and falls back to `ClubPolaroidArtwork` so share cards remain branded for no-photo clubs. |
| `ClubShareMetaRow` | `lib/clubs/presentation/detail/widgets/club_share_card.dart:153` | One-line icon/text metadata row used inside the club share card for location and member count facts. Receives the icon and label explicitly so the share card owns the row order while the row owns shared spacing, primary icon color, and ellipsis behavior. |
| `ClubScheduleSection` | `lib/clubs/presentation/detail/widgets/club_schedule_section.dart:10` | Sliver-native agenda section for a club's upcoming events. Reuses `EventAgendaSliverList` with detail-screen padding and agenda gap constants, shows compact inline empty states with public-profile copy, emits selected events through an injected callback, and marks host-owned event rows with the `HOSTED` event-tile status. Operational publish prompts stay in Host Operations unless the Host Club Detail design contract intentionally moves them here. |
| `CatchPolaroid` | `lib/clubs/presentation/shared/catch_polaroid.dart:12` | Shared club polaroid primitive: tight white framed media, mono caption, upright Archivo club title, optional title-row arrow, editorial supporting copy, and optional footer/actions. Used by Explore club cards and directory club cards so image-backed and no-cover states share one named metaphor. |
| `ClubPolaroidArtwork` | `lib/clubs/presentation/shared/catch_polaroid.dart:115` | Map-style no-photo artwork for club polaroids and compact club crests. It avoids generated initials, uses a quiet location mark, and derives deterministic accents from `ClubCoverVisualPalette`. |
| `ClubCoverVisualPalette` | `lib/clubs/presentation/shared/catch_polaroid.dart:175` | Deterministic club visual palette derived from `ActivityPalette` and tokens for production cards that need matching no-cover accents. |
| `CreateClubPhotosPicker` | `lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:16` | Ordered photo picker for the host create/edit club form. Standard mode keeps the create-flow grid/empty add affordance; `editStrip` mode renders the compact four-up Host Edit Club photo strip with count, cover badge, removable tiles, and reorder helper copy while reusing `OrderedPhotoPicker`. |
| `CreateClubProfileImagePicker` | `lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:84` | Profile/logo image picker for host create/edit club forms. Standard mode keeps the create-flow square add/change tile; `editLogo` mode renders the compact Host Edit Club logo row with kicker, square tile, camera/edit affordance, and supporting copy. |
| `CreateClubContactFields` | `lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart:6` | Contact fields (Instagram, WhatsApp, website, email) for the host create/edit club form. |
| `DirectoryCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:3` | Directory-style club card router for Explore. Chooses the photo card when cover imagery exists and the no-cover identity card otherwise, wraps both in button semantics when tappable, and centralizes joined-state sash selection before delegating to the display cards. |
| `DirectoryPhotoCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:40` | Image-backed Explore club directory card. Uses `CatchPolaroid` with real club imagery through `ClubPhotoMediaOverlay`, overlays `ClubPhotoChrome`, keeps the Archivo club identity band below the media, and renders tags plus hosted-by/action affordances without moving join mutation state into display-only card code. |
| `DirectoryIdentityCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:82` | No-cover Explore club directory card. Uses `CatchPolaroid` with `ClubPolaroidArtwork`, the same `ClubPhotoChrome` overlay, metadata, tags, hosted-by context, and role-aware membership action row without generated initials. |
| `ClubPhotoMediaOverlay` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:125` | Directory-card media slot that renders `ClubImage` in cover-first mode with the full-size fallback treatment expected by photo-backed club cards. |
| `ClubPhotoChrome` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:136` | Directory-card media chrome. Layers the gradient scrim, logo crest, optional joined sash, and compact member seal over card media while using the deterministic `ClubCoverVisualPalette` accent. |
| `ClubPhotoScrim` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:189` | Non-interactive vertical gradient overlay for directory-card media. Protects crest, sash, and member-seal legibility without taking gestures from the card. |
| `ClubLogoCrest` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:217` | Circular club logo mark used by directory media chrome. Renders the club profile image when present, otherwise falls back to `ClubLogoFallback`, with caller-supplied palette, border, size, and elevation. |
| `ClubLogoFallback` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:257` | Empty logo fallback used inside the accent-colored `ClubLogoCrest` shell when the club has no profile image or the network image fails. |
| `ClubDirectoryFooter` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:266` | Directory-card footer stack for rating, host/action row, separator rule, and visible club tags. Keeps card metadata layout separate from the media and title band. |
| `ClubRule` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:304` | Single-pixel directory-card separator used between host/action metadata and tag chips. |
| `ClubHostActionRow` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:318` | Directory-card hosted-by row. Reuses `ClubHostIdentityLine` and delegates joined/joinable trailing state to `MembershipTrailing`. |
| `MembershipTrailing` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:373` | Directory-card membership action adapter. Hides redundant joined controls because the card sash carries that state, and keys join mutation state by `clubId` so one pending Join button does not disable every visible club card. |
| `ClubImage` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/club_image.dart:3` | Club media renderer for list tiles and avatar chips. Selects cover/profile image order by explicit flags, grades network imagery through `CatchGradedImage`, and falls back to `ClubPolaroidArtwork` with compact or full fallback chrome chosen by the caller. |
| `AvatarChip` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart:6` | Joined-club rail tile with a rounded image/fallback chip, optional live-badge border/copy, semantic open-club label, and truncated club name. |

---

## Events

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventScreen` | `lib/hosts/presentation/event_management/create/create_event_screen.dart:47` | Host-owned multi-step event creation flow for details, location, schedule, event policy, and event-success defaults. Uses `CreateEventWizardStep` / `CatchFormStepSpec` metadata, `CreateEventStepHeader`, handoff-aligned step bodies, `StepperFooter`, and shared `SelectChip` / `CatchField.toggle` controls for selections and switches. It seeds policy and event-success defaults from `club.hostDefaults`, owns local form controllers, PageController step changes, picker side effects, controller mutation triggers, and Navigator/context side effects, submits through `CreateEventController`, persists drafts through `CreateEventDraftController`, and routes Manage event to canonical Host Manage after success. Route, wizard-step, validation-plan, wizard display, success navigation, draft action, draft restore, draft side-effect, schedule, location, photo, and policy decisions are now fed through typed state helpers; the picked-photo state no longer imports the image picker plugin, and upload image files are extracted only at submit time. The current Widgetbook/capture set covers route loading/error/offline/missing, validation, custom activity, picked photos, selected location, draft picker/restored/delete/unsaved dialogs, save-draft pending/error/offline, submit pending/error/offline, photo-upload offline, success, baseline wizard steps, text-scale, reduced-motion, and theme review. Remaining reference-specific draft/validation/submit variants are blocked on exported designs and masks. |
| `CreateEventUnsavedChangesDialog` | `lib/hosts/presentation/event_management/create/create_event_screen.dart:58` | Provider-free confirmation dialog shown when a host backs out of the first create-event step with unsaved changes. Reuses the shared adaptive dialog action contract for Discard and Save draft, and is cataloged separately so deterministic captures do not depend on a widget-returning helper. |
| `EditHostedEventScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:113` | Host-only published-event edit form used by `screen.host.event.edit`. It edits backend-supported operational fields: schedule when unlocked, meeting point, pinned starting point, extra directions, distance, pace, description, capacity, price, admission format, invite code, cohort/age limits, dynamic pricing, and cancellation policy. Schedule and booking-policy edits now use `HostEventEditState` lock helpers and lock once the event has started or has booking, waitlist, attendance activity, or cancellation. Missing-location and save-success feedback use `showCatchSnackBar`. The screen exposes a default-disabled `formAutovalidateMode` for deterministic validation captures. Widgetbook/captures cover editable, locked, cancelled, private-access loading, validation, selected-location, submit pending/error, text-scale, reduced-motion, and theme states; offline and reference-specific variants remain migration targets. |
| `EventMapView` | `lib/events/presentation/event_map_screen.dart:18` | Reusable full-screen event map body. Uses a parent-supplied `AsyncValue<EventMapViewModel>` and retry callback when provided, otherwise can watch and invalidate `eventMapViewModelProvider` for tests/dev callers. It renders `EventMapLoadingBody` while loading, centers on device location unless the selected club city was manually overridden or location is unavailable, owns selected-event state, and composes `EventPinsMap`, map empty states, optional overlay controls, camera-center callbacks, and optional distance-ring taps. Explore mounts it behind its own draggable browse sheet; event-detail directions use `EventLocationMapScreen` instead. |
| `HostEventManageScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:151` | Canonical loaded per-event host workspace registered as `screen.host.event.manage` through `ARCH-SCREEN-001C`. Mounts club-name kicker copy, compact event title, metadata row, and Setup / Guests / Live / Report `CatchSegmentedControl` in shared `CatchTopBar` chrome; at high text scale it collapses supplemental kicker copy into the title semantics, keeps the visible title to one line, and gives the section picker a taller bottom slot. Setup leads with capacity metrics, compact host action rows, and optional full/cohort-waitlist banner before deeper private-access, event summary, and Event Success setup content. Guests owns the participant roster through `HostEventParticipantsPanel`; Live uses Event Success compact live controls with team-rotation round copy, previous/next controls, and a check-in summary strip; Report leads with the filtered event-report table before the post-event host report. Private-link sharing, named invite-link create/copy/disable actions, report CSV export, and cancel/delete writes route through controller seams. `HostEventManageScreenState` owns selected-section and header display state, `HostEventManageActionEffect` owns edit/cancel/delete destinations and edit route parameters, `HostPrivateLinkActionState` feeds the provider-free `HostEventActionsSection`, `HostParticipantsMutationDisplayState` owns participant/report mutation pending and error display policy, `HostParticipantLifecycleActions` feeds provider-free roster profile/approval/decline/attendance/waitlist/report callbacks, `HostReportSummaryDisplayState` owns gross-estimate and attendance summary copy, `HostParticipantProfilesLookupState` owns attendee-profile lookup display branches, and the screen/list adapters execute Navigator/dialog/controller side effects, `CatchFormDialog` invite-link creation, shared Catch snackbar success feedback, action mutation state, private-link share execution, participant mutations, report exports, and delete return behavior. Remaining loaded-workspace adapters are for Event Success callback growth rather than basic edit/cancel/delete/private-link/participant action routing. |
| `LocationPickerScreen` | `lib/events/presentation/location_picker_screen.dart:16` | Chromeless map-based location picker. Lets hosts tap or search for a location and returns the selected `LocationCoordinate`; keeps confirm/search controls floating above the map. Autocomplete results render in a `CatchSurface` overlay with tokenized local suggestion rows rather than raw Material list tiles. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EditHostedEventRouteScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:50` | Route-facing edit entry registered as `screen.host.event.edit`. Loads uid, host-owned club, and event through `HostEventEditState`, rejects non-host viewers, renders `HostRouteLoadingBody(showTabRail: true)` for blocking route loading, handles error/not-found states, and delegates to `EditHostedEventScreen` with optional route-provided event data. Widgetbook covers route loading/error/not-found/unauthorized plus the main form variants. |
| `HostCreateEventRouteStateView` | `lib/hosts/presentation/event_management/host_create_event_screen.dart:39` | Provider-backed renderer for `HostCreateEventRouteState`. It switches loading/error/not-found/forbidden/ready branches into the loading shell, branded error scaffolds, or `CreateEventScreen`, while the route screen owns provider reads and retry invalidation. Extracted from the route screen so state rendering is cataloged and no widget-returning helper is needed. |
| `HostEventEditState` | `lib/hosts/presentation/edit_hosted_event_screen.dart:113` | Route and display adapter for Host Event Edit. Resolves uid/club/event provider waves plus optional initial route event into loading, error, not-found, unauthorized, or ready states, and centralizes event editability plus schedule/policy lock predicates. Private-access loading, field validation, selected-location, and submit mutation states now have deterministic capture coverage; moving those callbacks plus close navigation into the adapter remains the next architecture target. |
| `HostEventManageRouteScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:49` | Route-facing host manage entry and defined `ARCH-SCREEN-001C` host workspace variant used from the canonical `/clubs/:clubId/events/:eventId/manage` route plus attendance and event-success aliases. Loads uid, event, and club by id, gates access to the club host, renders `HostRouteLoadingBody(showTabRail: true)` for blocking route loading, handles error/offline/not-found/unauthorized route states, and delegates the loaded state plus optional lifecycle section to `HostEventManageScreen`; the route contract keeps `hostAppAttendanceSheet` and `hostAppEventSuccessScreen` as aliases to `screen.host.event.manage`, not separate screen contracts. Widgetbook/captures cover route loading/error/offline/not-found, initial-event fallback, unauthorized, setup/private access, attendance loading/error/empty, attendee-profile loading/error, filtered roster empty, attendance mutation pending/error, full/waitlist apron, live, live unavailable, live Event Success plan loading/error/offline, live wingman requests, live assigned micro-pods, live assigned guided rotations, live check-in QR, live conversation cues, live revealed partner round, live host-edited override, report, report scorecard loading/error/offline, report export pending/error, private-access loading/error/offline/missing-code, private-link share pending/error, invite-link loading/error/offline/empty/disabled-row/long-label-source, invite-link mutation pending/error, edit/cancel/delete host action states, cancelled event, text-scale, reduced-motion, and light/dark states; remaining follow-up coverage is compact step-count semantics if product keeps them, modal Event Success override editor sheets if contractual, and reference-specific variants. |
| `HostParticipationLifecycleBoard` | `lib/hosts/presentation/widgets/host_event_attendance_panel.dart:386` | Provider-free Host Manage participant roster board. Receives resolved attendance view model, participant-profile display map, setup/live/report mode, request-approval policy, mutation display state, search/filter inputs, and `HostParticipantLifecycleActions` from `HostEventParticipantsPanel` / `HostEventParticipantsList`; renders lifecycle-specific roster sections with `CatchRosterTiles`, `CatchRosterTable`, setup approval/decline/waitlist controls, live check-in controls, report export actions, and typed profile/action callbacks without watching providers or owning navigation. Widgetbook covers the exact public widget states through `HostParticipationLifecycleBoard/Catalog states`. |
| `HostEventActionsSection` | `lib/hosts/presentation/host_event_manage_screen.dart:1372` | Provider-free compact Host Manage action section. Receives `HostPrivateLinkActionState`, typed private-link share callback, destructive-action display state, mutation errors, and edit/cancel/delete callbacks from `HostEventManageScreen`; renders edit/share/cancel/delete as flat tokenized action rows matching the Claude setup workspace instead of the former bulky action card. |
| `_HostManageSectionPicker` | `lib/hosts/presentation/host_event_manage_screen.dart:532` | Setup / Guests / Live / Report mode picker for Host Event Manage. Reuses the shared pill-style `CatchSegmentedControl` in surface style, expands across the top-bar bottom slot, and calls back into the screen's local section state. |
| `EventDetailScreen` | `lib/events/presentation/event_detail_screen.dart:40` | Route-facing event detail entry and `ARCH-SCREEN-001` reference screen. Watches `EventDetailViewModel`, records invite-link opens through `EventDetailController`, renders scaffolded loading/error/not-found states, preserves optional route-provided fallback event data plus source presentation mode/Hero tag, and owns the loaded `Scaffold`, bottom navigation, route-level mutation listeners, share/calendar/save callbacks, Event Success companion state, host club state, location/companion/club/message navigation, guest sign-in navigation, and retry invalidation before delegating embedded scroll content to `EventDetailBody`. Widgetbook exposes route-level Screen states for loading, not-found, fatal error, member, guest, host app, offline, text-scale, reduced-motion, ticket, and spotlight review. |
| `EventLocationMapRouteScreen` | `lib/events/presentation/event_location_map_screen.dart:26` | Route-facing single-event map entry registered as `screen.event.location_map` and aligned `ARCH-SCREEN-001` adopter. Reuses `EventDetailViewModel` by `eventId`, owns the chromeless route `Scaffold`, floating back controls, load/error/not-found states, exact-coordinate gate, retry invalidation, `EventLocationMapState` creation, and external directions side effect before delegating provider-free map content to `EventLocationMapScreen`. |
| `EventDetailBody` | `lib/events/presentation/widgets/event_detail_body.dart:107` | Scrollable event detail composition. It receives shell state plus explicit save/share/calendar/back callbacks, companion state, host state, location/companion/club/message callbacks, and retry callbacks from `EventDetailScreen`, then composes the source-aware hero app bar, flush ticket-stub band, handoff-ordered overview stack, optional saved-plan companion entry, booked-attendee invite card, hosts, and social sections. It no longer owns a direct `Scaffold`, bottom navigation, route-level booking/cancel mutation listeners, provider reads, or route side effects; direct Widgetbook/test states are body-only review states with explicit no-op or assertion callbacks. |
| `EventCompanionEntry` | `lib/events/presentation/widgets/event_detail_body.dart:343` | Provider-free Event Detail companion section adapter. Switches explicit `EventDetailCompanionState` into hidden/loading/error/available rendering, delegates retry and open-companion effects to route callbacks, and keeps the Event Success provider watch in `EventDetailScreen`. Widgetbook covers hidden, loading, available, and error states. |
| `EventInviteLoopCard` | `lib/events/presentation/widgets/event_detail_body.dart:302` | Provider-free booked-attendee invite card for Event Detail. Receives the event, share callback, and `EventDetailSurfaceStyle`, then renders the friend-invite prompt and full-width invite action without reading route/controller state directly. |
| `EventCompanionCard` | `lib/events/presentation/widgets/event_detail_body.dart:404` | Leaf Event Detail companion card rendered by `EventCompanionEntry` when Event Success setup is available. Uses explicit surface styling and open callback props to present the companion explanation and action without owning provider or navigation state. |
| `GuestBookCta` | `lib/events/presentation/widgets/event_detail_body.dart:462` | Guest-only Event Detail booking dock CTA. Renders the sign-in-to-book action inside the light or dark footer surface while the route/body owner supplies the navigation callback. |
| `EventDetailHostsSection` | `lib/events/presentation/widgets/event_detail_body.dart:472` | Provider-free Event Detail host section adapter. Switches explicit `EventDetailHostState` into hidden/loading/error/content rendering, renders `EventDetailHostCard` from preformatted display data, and delegates View club, Message host, and retry effects to route callbacks. Widgetbook covers hidden, loading, content, and error states. |
| `EventDetailHeroAppBar` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:10` | Event detail hero app bar. Uses the shared event photo header for standard routes and a full-bleed ticket-mode visual band for card-opened routes; both paths prefer uploaded photos and fall back to activity artwork. Standard and ticket/spotlight expanded heights resolve through named `CatchLayout.eventDetailHero*` constants; ticket mode keeps the perforated ticket seam, shares the event display font with cards, and owns floating back/share/save/calendar actions without adding the club-detail viewport-curve inset. |
| `LegacyEventHeroSurface` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:171` | Standard event-detail hero surface used by `EventDetailHeroAppBar` for non-ticket routes. Composes the uploaded-photo header with the activity badge and display-title overlay while keeping route actions in the sliver app bar. Widgetbook covers the exact surface state directly. |
| `EventDetailTicketHeroSurface` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:217` | Ticket-mode hero transition adapter used by `EventDetailHeroAppBar`. Wraps `EventDetailTicketSurface` in the shared `EventHeroSurface` only when a route-provided hero tag exists, so direct ticket rendering and card-to-detail Hero flights stay separated. Widgetbook covers ticket and spotlight transition-target states. |
| `EventDetailTicketSurface` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:241` | Full-bleed ticket hero body for ticket and spotlight event-detail presentations. Owns the activity thumbnail/scrim band, perforated divider, event display title, subtitle, compact-flight layout, and dark/light body colors. Widgetbook covers ticket and spotlight body states directly. |
| `HeroActivityBadge` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:410` | Frosted activity badge used by both standard and ticket event-detail heroes. Receives a resolved `EventActivityVisualSpec` so activity icon/label mapping remains centralized in `event_activity_visuals.dart`. Widgetbook covers run, dinner, and pickleball badge states. |
| `HeroTimeChip` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:440` | Compact weekday/time chip used by the expanded ticket hero visual band. Formats event start time through `EventFormatters` and keeps the dark hero chrome tokenized. Widgetbook covers morning and evening event states. |
| `EventDetailTicketStubBand` / `EventDetailHintList` / `EventDetailItinerary` / `EventDetailMapCard` / `EventDetailMechanismList` / `EventDetailPhotoStrip` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:10` | Flutter event-detail counterparts to the handoff primitives: ticket counter-foil, why-click hints, timed itinerary rail, activity-pigmented map preview, sign-up mechanics, and the canonical three-tile photo strip with activity-soft placeholders. They resolve pigment/glyph through `ActivityPalette` and derive copy from the current `Event` model. |
| `EventDetailPhotoStripTile` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:332` | Leaf tile for the Event Detail photo strip. Renders uploaded event media through `CatchNetworkImage`, falls back to the activity glyph on the activity-soft background, and keeps fixed strip sizing plus stable tile keys for review/tests. |
| `TicketStubCell` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:389` | Leaf ticket counter-foil cell used by `EventDetailTicketStubBand`. Receives public `TicketStubCellData`, renders mono label/value/detail text, optional trailing icon, and the perforated vertical divider state. |
| `HairlineList` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:463` | Minimal Event Detail list shell for hint/mechanism rows. It owns only the hairline dividers and delegates row bodies to an indexed builder, keeping section copy and icons outside the shell. |
| `ItineraryRow` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:506` | Leaf itinerary timeline row used by `EventDetailItinerary`. Receives public `ItineraryStep` display data plus accent/rail colors, renders the fixed time column, dot, connecting rail, title, and supporting detail. |
| `MapPill` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:604` | Compact translucent map label pill used inside `EventDetailMapCard` for location and pin-status labels, with caller-provided text color and ellipsis-safe mono labeling. |
| `HostAvatar` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:1126` | Event Detail host avatar leaf. Renders the activity gradient fallback and optional graded host photo while keeping the 46px circular host mark independent of the larger host card. |
| `EventPhotoHeader` | `lib/events/presentation/widgets/event_photo_header.dart:5` | Visual-only standard event hero wrapper. Delegates rendering to `CatchEventThumbnail` so uploaded event photos lead when present and activity artwork remains the no-photo/failure fallback; exposes the stable event-photo Hero tag for standard photo-header transitions and intentionally does not duplicate event title, location, stats, or activity copy. |
| `EventStatsGrid` | `lib/events/presentation/widgets/event_stats_grid.dart:7` | Event detail stats adapter. Converts event facts into `CatchMetricStrip` items so event stats share the same rail, dividers, value styling, and responsive truncation as club detail stats, with optional dark surface colors for spotlight detail. |
| `EventDetailCta` | `lib/events/presentation/widgets/event_detail_cta.dart:60` | Controller-backed bottom CTA adapter for non-host event detail viewers. Owns booking, cancellation, waitlist, eligibility, attended/past, free-booking celebration, and paid booking handoff actions from the current viewer's `EventParticipation` edge, then delegates provider-free rendering to `EventBookingDock`. |
| `EventBookingDock` | `lib/events/presentation/widgets/event_detail_cta.dart:32` | Provider-free Event Detail booking dock renderer. Composes the branded mutation/error banner and `CatchBottomDock.cta` for guest, bookable, pending, failed, booked, waitlist, offer, full, past, attended, and host-hidden Widgetbook states. |
| `AttendanceSheetViewModel` | `lib/events/presentation/attendance_sheet_view_model.dart:10` | Attendance data seam. Combines the event stream with `eventParticipations` and derives attendee IDs plus checked-in state from participation statuses. |
| `EventHypeAvatarStack` | `lib/events/presentation/widgets/event_hype_avatar_stack.dart:68` | Shared attendee-hype avatar stack for event detail and roster surfaces. Obscured mode renders local activity-tinted veiled placeholders without fetching profile photos; revealed mode derives eligible signed-up/attended participants through `eventHypeAvatarsProvider`, applies the viewer gender-preference filter, joins public profile names/thumbnails, and renders `PersonAvatarStack`. |
| `WhoIsGoing` | `lib/events/presentation/widgets/who_is_going.dart:36` | Event detail social roster. Watches `EventParticipationRoster` for booked counts and renders activity-tinted veiled `EventHypeAvatarStack` placeholders until roster visibility is allowed, using `event.activityKind` for the handoff tint. Standalone callers keep the local title/count header; `EventDetailSocialSection` suppresses it so the design-system section owns the label. |
| `WhoIsGoingContent` | `lib/events/presentation/widgets/who_is_going.dart:87` | Provider-free Event Detail roster renderer. Receives the event, roster, viewer profile, optional fallback count, surface style, and header visibility, then composes the attendee count, hype avatar stack, empty roster copy, and swipe-window status without reading providers directly. |
| `EmptyRosterMessage` | `lib/events/presentation/widgets/who_is_going.dart:182` | Event Detail empty roster surface. Renders the no-attendees title/message with optional event-detail surface colors so upcoming and past roster-empty states can be reviewed without the provider wrapper. |
| `SwipeWindowBanner` | `lib/events/presentation/widgets/who_is_going.dart:239` | Compact Event Detail roster status banner for locked, open, and closed post-event catch windows. Uses explicit icon/message props and optional event-detail surface colors while preserving the shared `CatchSurface` treatment. |
| `EventMapLoadingBody` | `lib/events/presentation/event_map_screen.dart:115` | Map-shaped skeleton body shared by general event-map loading and the location-map route. Shows a full-bleed map shimmer, centered pin, filter/distance pill placeholder, and floating control placeholder. |
| `EventPinsMap` | `lib/events/presentation/widgets/event_pins_map.dart:10` | Shared Flutter map canvas for event pins. Used by Explore and `EventLocationMapScreen`; renders only events with exact coordinates and keeps map centering outside the pin widget. It reports camera-center changes on idle, draws optional user-location and distance-ring circles, clusters dense low-zoom pins with app-rendered count markers, and expands clusters by zooming in. Its no-network placeholder lays markers out spatially, exposes meeting-point selection labels so widget tests can exercise selected-pin flows without network map tiles, and keeps the painter boundary to concrete token-derived colors rather than prop-drilling `CatchTokens`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventSuccessScreen` | `lib/hosts/presentation/event_management/create/create_event_success_screen.dart:10` | Host event-created success screen backed by the paper `CatchCelebrationScreen`. Matches the handoff celebration composition with a `CatchIcons.celebration` mark, optional reference/display event name for success copy, compact when/activity labels, event confirmation details, invite-only code/private-link rows, the Manage event tracking note, and Manage event / Back to club actions. The registered `host_create_success_manage` reference is within advisory threshold after the paper inset/detail-row pass. |
| `_HostFullCapacityApron` | `lib/hosts/presentation/host_event_manage_screen.dart:1131` | Host Manage setup metric apron. Renders booked/capacity, waitlist, estimated revenue, and refund policy tiles from merged event-document and roster counts so deterministic captures and production denormalized counts do not hide known activity. |
| `_HostFullCapacityBanner` | `lib/hosts/presentation/host_event_manage_screen.dart:1198` | Compact ink full/waitlist notice shown when total capacity is full or cohort waitlist pressure is present. Keeps the handoff `FULL - CAPACITY REACHED` / `WAITLIST OPEN` copy above the setup metric apron. |
| `_HostActionRow` | `lib/hosts/presentation/host_event_manage_screen.dart:1439` | Flat tappable Host Manage action row for edit/share/cancel/delete actions. Uses tokenized label/detail typography, responsive stacking under tight widths, optional destructive color, and divider control so setup actions can match the Claude row rhythm without bespoke buttons. |
| `EventJoinedCelebrationScreen` | `lib/events/presentation/event_joined_celebration_screen.dart:8` | User event-signup celebration surface shared by free bookings and post-payment confirmation. Shows event details, optional payment details, haptics, and View event / Back home actions. |
| `EventCheckInCelebrationScreen` | `lib/events/presentation/event_check_in_celebration_screen.dart:7` | Participant self-check-in celebration surface. Used only after user self-check-in from Home succeeds; host attendance remains an operational flow. |
| `BookingConflictSheet` | `lib/events/presentation/widgets/booking_conflict_sheet.dart:32` | Booking handoff conflict-warning sheet. Renders the already-booked and incoming events as activity-colored rows, keeps warning copy and sheet chrome on Catch primitives, and exposes replace / keep-both / keep-existing callbacks for a future overlap-resolution flow. Widgetbook exposes standalone states for default conflict, replacement decision, long event names, and fallback activity visuals; sold-out/full-capacity remains outside this primitive API. |
| `BookingConflictEventRow` | `lib/events/presentation/widgets/booking_conflict_sheet.dart:151` | Public row renderer for a single event inside `BookingConflictSheet`. Displays the row tag, event title, time copy, and either an activity-colored glyph tile or fallback calendar glyph without owning sheet actions or booking decisions. |
| `EventCheckInLocationService` | `lib/events/data/event_check_in_location_service.dart:16` | Provider-backed location seam for self-check-in. Production uses Geolocator with high accuracy and a timeout; tests can inject coordinates without invoking platform plugins. |
| `EventLocationMapLoadingBody` | `lib/events/presentation/event_location_map_screen.dart:70` | Location-map route loading body. Composes `EventMapLoadingBody` with bottom location summary and directions-button placeholders while `_ChromelessMapScaffold` keeps the floating map controls visible. |
| `EventLocationMapScreen` | `lib/events/presentation/event_location_map_screen.dart:156` | Provider-free single-event map body for `screen.event.location_map`. Receives `EventLocationMapState` plus an explicit `onGetDirections` callback, renders one pinned exact starting point through `EventPinsMap`, and composes the bottom location summary/directions card. It no longer owns a direct `Scaffold` or floating route controls; route/capture states that need chrome mount `EventLocationMapRouteScreen`. |
| `EventShareCard` | `lib/events/presentation/widgets/event_share_card.dart:42` | Shareable event invite card rendered inside `RichShareCardSheet`. Uses the activity visual palette, `EventActivityBackdrop`, tokenized field rows, price/spots pills, and `EventInviteShareCopy` so event detail, payment confirmation, and referral invite surfaces share the same visual card and link payload. |
| `EventShareMetaRow` | `lib/events/presentation/widgets/event_share_card.dart:222` | Public metadata row renderer used by `EventShareCard`. Shows one icon/label pair with caller-provided accent color and owns only one-line visual truncation. |
| `EventSharePill` | `lib/events/presentation/widgets/event_share_card.dart:255` | Public compact pill renderer used by `EventShareCard` for price and spots labels. Uses Catch surface/token styling and owns no event or share-copy logic. |
| `CreateEventStepHeader` | `lib/hosts/presentation/event_management/widgets/create_event_step_header.dart:4` | Header for the host create-event wizard: back action, step title, club name, step count, and progress bar. |
| `CreateEventFormKeys` | `lib/hosts/presentation/event_management/create/create_event_form_keys.dart:3` | Stable semantic keys for host create/edit event form fields so widget tests target fields by purpose rather than layout order. |
| `DraftDeleteConfirmationDialog` | `lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart:54` | Provider-free destructive confirmation dialog for deleting a saved create-event draft from the draft picker sheet. It owns only the confirmation copy and action layout; draft deletion remains in `CreateEventDraftController`. |
| `SavedEventsScreen` | `lib/events/presentation/saved_events_screen.dart:19` | Saved-events route registered as `screen.saved_events.list` and aligned `ARCH-SCREEN-001` adopter. Watches uid and saved-event provider waves, owns the route `Scaffold`, loading/error/empty states, retry invalidation, club-name lookup, and saved-event detail navigation, then resolves `SavedEventsListState` before rendering shared agenda tiles. |
| `SavedEventsHeaderSliver` | `lib/events/presentation/saved_events_screen.dart:101` | Provider-free Saved Events page header sliver. Owns only the compact page-header padding and `Events you saved` headline so route and Widgetbook states can reuse the same sliver geometry. |
| `SavedEventsAgendaSliver` | `lib/events/presentation/saved_events_screen.dart:118` | Provider-free Saved Events agenda section. Receives `SavedEventsListState`, resolved club-name lookup data, and event-selection callback from `SavedEventsScreen`, then delegates saved/past badge and tile status policy to the state while rendering shared `EventAgendaSliverList` rows. |
| `SavedEventsError` | `lib/events/presentation/saved_events_screen.dart:166` | Route-body Saved Events error renderer. Maps saved-event provider failures through `CatchErrorState.fromError` with event context and optional retry callback supplied by the route. |
| `SavedEventsClubNamesErrorSliver` | `lib/events/presentation/saved_events_screen.dart:182` | Sliver-shaped club-name lookup error renderer for Saved Events. Keeps club-name provider failures inside the agenda scroll surface through `CatchSliverErrorState.fromError` while the route owns provider invalidation. |
| `EventTileData` | `lib/events/presentation/widgets/event_tiles/event_tile_data.dart:19` | Shared display model for event tile variants. Wraps an `Event` plus relationship status, optional club name, recommendation reason, and carousel position label, and exposes `EventCapacityPresenter`-backed copy for capacity labels. |
| `EventActionCard` | `lib/events/presentation/widgets/event_tiles/event_action_card.dart:11` | Shared full-width lifecycle/action event card. Renders status badges, optional carousel position/accessory, title/subtitle, structured `CatchMetaDotRow` lines, and full-width action buttons for attendee focus and host-operation cards without owning routing or mutations. |
| `EventActionCardHeader` | `lib/events/presentation/widgets/event_tiles/event_action_card.dart:170` | Public header renderer used by `EventActionCard`. Lays out action-card badges plus optional index label without owning event state or actions. |
| `EventActionCardActions` | `lib/events/presentation/widgets/event_tiles/event_action_card.dart:209` | Public action-stack renderer used by `EventActionCard`. Maps typed `EventActionCardAction` inputs into full-width Catch buttons, preserving loading, semantics, variant, accent, key, and callback behavior. |
| `EventCompactRow` | `lib/events/presentation/widgets/event_tiles/event_compact_row.dart:14` | Dense tappable event row with date pill, event title, location subtitle, shared meta row, optional status badge, and chevron. Used where an event needs to be represented inside compact activity/notification surfaces. |
| `EventCompactDatePill` | `lib/events/presentation/widgets/event_tiles/event_compact_row.dart:122` | Public fixed-size month/day pill renderer used by `EventCompactRow`. Receives a caller-provided accent color, applies the shared compact date-pill dimensions, and owns only the visual month/day treatment. |
| `EventDateMarker` | `lib/events/presentation/widgets/event_tiles/event_date_marker.dart:9` | Shared calendar week/month day marker with selected, today, disabled, and has-event-dot states. Calendar date cells use this instead of local one-off day widgets. |
| `WeekMarker` | `lib/events/presentation/widgets/event_tiles/event_date_marker.dart:56` | Public week-strip renderer used by `EventDateMarker`. Renders weekday/day labels, active ink fill, event dot, tappable semantics, and optional label override for calendar week rows without owning date selection. |
| `MonthMarker` | `lib/events/presentation/widgets/event_tiles/event_date_marker.dart:126` | Public month-grid renderer used by `EventDateMarker`. Renders selected/today/disabled month-cell states, preserves disabled-cell geometry with invisible text, and exposes tappable semantics only when enabled. |
| `EventDateRailCard` | `lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart:18` | Shared date-rail event card extracted from the Explore mixed-feed row. Renders a clipped ticket silhouette with seam cutouts, activity-colored weekday/day/month tear-off stub, subtle perforation seam, compact activity stamp, optional supporting label, themed event-display title, time/price line, single capacity copy line, optional full-card Hero transition, and optional shared status pill for non-full states across Explore event rows plus agenda surfaces. `stripPosition` lets This week rows join into a continuous ticket strip while preserving the outer notches only on the first/last card, and single tickets paint a custom `CatchElevation.physicalShadow` behind an elevation-zero `PhysicalShape` so debug/golden rendering stays aligned with the intended soft lift rather than showing Flutter's shadow-debug outline. |
| `PerforationLine` | `lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart:373` | Public perforation renderer used by `EventDateRailCard`. Draws the vertical dashed ticket divider with caller-provided color while the private painter remains an implementation detail. |
| `DateRail` | `lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart:410` | Public date-rail renderer used by `EventDateRailCard`. Displays weekday, day, and month on a caller-provided activity color with token-derived on-fill text colors. |
| `EventAgendaTile` | `lib/events/presentation/widgets/event_tiles/event_agenda_tile.dart:6` | Agenda/list adapter for Calendar, Saved events, and club schedules. It maps `EventTileData` into `EventDateRailCard`, preferring club name in global contexts and meeting point in club-local schedules, while suppressing the old redundant `VIEW` and `OPEN` badge language through `eventTileCardStatusLabel`. |
| `EventAgendaList` | `lib/events/presentation/widgets/event_agenda_list.dart:9` | Box-facing agenda list for events grouped by day. Sorts by start time by default, with `preserveInputOrder` for callers that precompute semantic order plus optional club-name/status builders, and renders `EventAgendaTile` directly. |
| `EventAgendaTileSkeleton` | `lib/events/presentation/widgets/event_agenda_list.dart:200` | Public placeholder row renderer used by `EventAgendaSliverSkeleton`. Mirrors the date rail plus body layout of agenda event tiles with shared skeleton primitives and owns no loading state. |
| `AgendaDayGroup` | `lib/events/presentation/widgets/event_agenda_list.dart:292` | Public day-group renderer used by `EventAgendaSliverList`. Renders the day label, maps grouped events into `EventAgendaTile`, and applies caller-provided badge, club-name, status, selection, and gap policies without owning sorting or grouping. |
| `EventDetailOverviewSection` | `lib/events/presentation/widgets/event_detail_overview_section.dart:10` | Handoff-ordered event-detail body stack: The plan, Why you might click, Itinerary, Photos when available, Where, How sign-ups work, and Good to know. Uses `CatchSection` plus event-detail primitives while retaining requirements, expectation, cancellation, and settlement policy copy from the existing event policy model. |
| `OptimisticHostsSkeleton` | `lib/events/presentation/widgets/event_detail_optimistic_body.dart:112` | Public optimistic-loading host section used by `EventDetailOptimisticBody` while the full event-detail view model resolves. Renders a divided host section with avatar/text skeletons. |
| `OptimisticSocialSkeleton` | `lib/events/presentation/widgets/event_detail_optimistic_body.dart:139` | Public optimistic-loading social section used by `EventDetailOptimisticBody` while the full event-detail view model resolves. Renders the Who's going section with avatar and copy skeletons. |
| `EventDescription` | `lib/events/presentation/widgets/event_detail_overview_section.dart:130` | Public description block used by `EventDetailOverviewSection` for the plan copy. Renders the local heading and body text with optional event-detail surface colors. |
| `WhatToExpectSection` | `lib/events/presentation/widgets/event_detail_overview_section.dart:174` | Public expectation-summary block used by `EventDetailOverviewSection`. Maps an event into policy summary lines inside a tokenized surface without owning section ordering. |
| `EventDetailSocialSection` | `lib/events/presentation/widgets/event_detail_social_section.dart:10` | Social context sections for the loaded event detail body: Who's going and Reviews, both composed with `CatchSection`. The roster supports a guest lock prompt and signed-in roster view; review writing requires an attended `EventParticipation` and an event end time that has passed. |
| `GuestWhoIsGoing` | `lib/events/presentation/widgets/event_detail_social_section.dart:107` | Public signed-out roster prompt used by `EventDetailSocialSection`. Renders the optional local header and sign-in visibility copy with optional event-detail surface colors. |
| `MapOverlayControls` | `lib/events/presentation/widgets/map_overlay_controls.dart:5` | Floating safe-area controls for chromeless map surfaces. Provides rounded back affordance plus optional trailing/below content for map actions such as create-event confirm/search. |
| `EventDetailsStep` | `lib/hosts/presentation/event_management/widgets/event_details_step.dart:16` | First host create-event step. Renders event photos, activity type, optional custom format/structure, distance, pace, and description with handoff `SelectChip` choices and `CatchField` inputs. Activity type choices carry their own activity pigment; format and pace choices inherit the selected activity accent. |
| `EventPolicyStep` | `lib/hosts/presentation/event_management/widgets/event_policy_step.dart:50` | Host create/edit event policy step for capacity, base price, admission preset, invite code, dynamic pricing, cancellation policy, eligibility bounds, and host payout copy. Uses handoff `SelectChip` selectors for admission/cancellation and `CatchField.toggle` for cohort caps and demand pricing. |
| `EventSuccessStep` | `lib/hosts/presentation/event_management/widgets/event_success_step.dart:9` | Final host create-event live-guide step. Wraps `EventSuccessDefaultsPanel`, passing the current event capacity so structure defaults can estimate pods/teams from the booking policy while keeping live-guide setup separate from policy editing. |
| `StepperFooter` | `lib/hosts/presentation/widgets/stepper_footer.dart:7` | Shared host form bottom action footer used by create-event and create-club flows. Blends into the page background, renders draft as a ghost action when supplied, and gives the primary action a full-width lane so long labels scale within available width. |
| `HostPaymentAccountCard` | `lib/hosts/presentation/payments/host_payment_account_card.dart:29` | Host-only payout readiness card for the Host app Clubs tab. Wraps the signed-in host payment-account stream in `CatchAsyncValueView`, renders a content-shaped skeleton for provider loading, uses compact `CatchErrorState` with retry for provider failures/offline, and runs setup/refresh actions through `HostPaymentAccountController` mutations so pending, generic error, and offline action states can be reviewed in Widgetbook and captures. It stays out of public club detail. |

### Presentation state

| Type | File | Purpose |
|---|---|---|
| `SavedEventsListState` | `lib/events/presentation/saved_events_state.dart:5` | Provider-free Saved Events display adapter. Orders upcoming saved events before recent past events, exposes today and club-id lookup input, and derives SAVED/PAST badge labels plus `EventTileStatus` values for agenda rows. |

---

## Event Success

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessManualQaScreen` | `lib/event_success/presentation/event_success_manual_qa_screen.dart:38` | Dev/staging manual QA harness. Uses handoff `SelectChip` choices for the fixture event-format selector and `CatchField.toggle` rows for attendee opt-out settings while rendering the canonical `HostEventManageScreen` beside the production attendee companion from one synchronized in-memory fixture store. The host pane overrides the exact Host Manage providers for event, roster, profile, event-success, and attendance-table state so Setup, Live, Report, and participation table changes stay covered without a duplicate host QA fixture. |
| `FirstHelloCheckInCard` | `lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart:14` | Provider-free attendee companion First Hello mission card. Renders a server/manual-QA-provided target, one short question, private answer chips, completion, and fallback check-in action from explicit `FirstHelloActionState` and typed callbacks without leaking broader attendee data. |
| `CompatibilityQuestionnaireSection` | `lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart:14` | Provider-free attendee companion quick-question clue ritual for event-scoped reveal clues. Focuses one question at a time, uses selected answer chips and progress, then saves through the stage action dock from explicit `CompatibilityQuestionnaireActionState` and a typed save callback while preserving questionnaire privacy language. |
| `SelfCheckInCard` | `lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:489` | Provider-free attendee companion arrival card. Owns the QR scanner sheet presentation and calls a typed self-check-in callback from explicit `SelfCheckInActionState`; the actual attendance write and live-entry effect stay at the companion screen edge. |
| `WingmanRequestSection` | `lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart:15` | Provider-free attendee companion host-help request section. Keeps local note editing and optimistic requested-target display, while save/withdraw writes flow through explicit `WingmanRequestActionState` and typed callbacks supplied by the companion screen. |
| `EventSuccessHostPanel` | `lib/event_success/presentation/event_success_host_screen.dart:595` | Reusable host event-success panel with Setup, Live, and Report bodies. Setup derives recommendations from the event activity profile, keeps the editor visible for QA even when an unsaved started event is locked, and hides unsupported tools behind progressive disclosure. Live mode opens with one Live now console that combines the active stage, progress, attendee-facing state, optional embedded editable roster, current-step controls, and previous/next navigation before lower-priority supporting controls for wingman requests, reveal clues, conversation cues, assignments, and reveal controls. Host Manage can request compact live controls, which suppress lower-priority live cards, use compact team-rotation copy, and add the check-in summary strip to the first viewport; standalone panels keep the full control stack. Report mode summarizes signal quality from feedback response, assignment coverage, opt-outs, and wingman requests. Standalone uses `CatchOptionGroup` for its Setup / Live / Report picker; Host Manage passes a fixed lifecycle section and hides the inner picker. |
| `EventSuccessDefaultsPanel` | `lib/event_success/presentation/event_success_defaults_panel.dart:14` | Shared event-success defaults form. Used by club create/edit and create event to toggle setup with `CatchField.toggle`, normalize activity-specific recommendations against an optional target attendee count, and show a preset-review card before advanced controls. Guide notes, match clue questions, structure, and tools are progressively disclosed; questionnaire ownership is separate from tool switches, and wingman/openers are derived from module selection instead of repeated booleans. |
| `EventSuccessHostSetupFlow` | `lib/event_success/presentation/event_success_feature_blocks.dart:36` | Event-success concept-lab setup flow. Lets product iterate across playbooks, shows the selected playbook summary, embeds `EventSuccessStructureConfigEditor`, and toggles modules/readiness issues from an in-memory draft. Uses handoff `SelectChip` choices for the format selector. |
| `EventSuccessSetupBody` | `lib/event_success/presentation/event_success_setup_body.dart:52` | Shared event-success setup body used by create-event defaults and Host Manage setup. Renders preset review, guide notes, lifecycle stage cards, structure, advanced match-clue questions, and safety footer while emitting draft changes to its owner. Uses `CatchField.toggle` rows for module recommendations, `SelectChip` choices for rotation cadence / reveal countdown / match-clue mode, and tokenized `CatchSurface` disclosure rows for Guide notes and Advanced sections instead of Material `ExpansionTile`. |
| `EventSuccessFeedbackForm` | `lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:11` | Provider-free attendee companion post-event feedback form. Captures private welcome/structure ratings, people-met count, private note, and a Catch-private safety/comfort review flag from local draft state, while submit pending and persistence flow through explicit `EventSuccessFeedbackActionState` and a typed feedback callback. |
| `RatingRow` | `lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:184` | Event Success feedback rating row. Renders one labeled 1-5 star selector from explicit value and callback props so the feedback form can keep draft state local while the row remains provider-free and directly reviewable. |
| `CounterRow` | `lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:218` | Event Success people-met counter row. Renders decrement/increment icon actions around a numeric value, disables decrement at zero, and delegates all value changes through the supplied callback. |
| `FeedbackIconAction` | `lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:253` | Event Success feedback icon action wrapper. Applies tooltip, icon sizing, token color, and disabled tap behavior through the shared `CatchIconButton` primitive for compact rating and counter controls. |
| `_SetupTab` | `lib/event_success/presentation/host_parts/event_success_host_setup.dart:3` | Event-success setup form for playbook selection, target attendee count, host goal, attendee prompt, structure config, module toggles, reveal-clue opt-in, wingman requests, and setup save/ensure mutations. Essentials render first; advanced structure, tool, and delivery controls are progressively disclosed, with multiline guide-note fields and host-facing group/team/table language. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessCompanionScreen` | `lib/event_success/presentation/event_success_companion_screen.dart:722` | Attendee companion surface that resolves the runtime-selected live moment into a full-screen stage with moment-specific color, motif, privacy copy, keyed transitions, native live effects, optional First Hello arrival missions, reveal-safe assignment display, and a private post-event afterglow recap. Live assignment opt-in controls use `CatchToggle`, and copied cue/opener feedback uses `showCatchSnackBar`. Keeps the single-moment runtime model intact rather than restoring a stacked dashboard. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessHostSectionState` | `lib/event_success/presentation/event_success_host_screen.dart:89` | Provider-wave adapter for the host Event Success section. Resolves saved-plan presence, fallback default plan, roster, assignments, assignment profiles, rotation assignments, rotation profiles, preferences, wingman requests, wingman profiles, and scorecard into loading/error/ready state plus `EventSuccessHostRetryIntent` before the section composes the provider-free host panel. |
| `EventSuccessHostSection` | `lib/event_success/presentation/event_success_host_screen.dart:241` | Host Manage section loader for event-success data. It watches the required Event Success provider waves at the route edge, delegates branch selection to `EventSuccessHostSectionState`, synthesizes a default plan until setup is saved, skips roster/report/assignment/preference/wingman streams while no saved guide exists, renders tab-shaped skeletons for loading, and maps typed retry intents back to the failing provider. Host Manage can pass an embedded live roster when needed, or request compact live controls so the route-level Live workspace prioritizes the live console, navigation, and check-in summary strip while attendance correction remains covered by dedicated roster states. Widgetbook and deterministic captures may mount the non-compact section directly for rich live-card substates such as QR, cues, reveal, and host-edited overrides without changing the production compact Live workspace. |
| `EventSuccessEventPreviewRouteScreen` | `lib/event_success/presentation/event_success_event_preview_screen.dart:27` | Dev/staging route that previews the future Event Success layer against current event data without creating live event-success documents. It keeps the preview app bar visible and renders `EventSuccessEventPreviewLoadingScreen` while event data loads. |
| `EventSuccessLiveRevealHostCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart:3` | Host Live-mode reveal console for structured assignment flows. Shows a kinetic countdown, round queue, assignment clues, and host actions to start countdown, reveal now, or reset reveal state. |
| `EventSuccessLiveRevealAttendeeCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart:3` | Companion-side reveal surface for pods and rotations. Hides assignment details until the host reveal state unlocks the round, uses a stronger countdown/waiting/unlocked presentation, then shows partners or podmates with opt-out controls intact. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessLabScreen` | `lib/event_success/presentation/event_success_lab_screen.dart:34` | Dev/staging-only event-success product lab. Labels the route as preview-only WIP, renders playbook cards, the module grid, actual feature blocks, and host-coach samples without Firestore writes or booking changes. Playbook module metadata uses shared `CatchBadge` labels while interactive setup choices remain on their own handoff controls. |
| `CompanionPaperScaffold` | `lib/event_success/presentation/companion_parts/event_success_companion_shared.dart:121` | Provider-free paper-ticket companion shell for pre-arrival and self-check-in moments. Receives moment presentation, self-check-in state, and a typed self-check-in callback from `EventSuccessCompanionScreen` while keeping the paper ticket layout stable. |
| `EventSuccessHostSectionSkeleton` | `lib/event_success/presentation/event_success_host_screen.dart:452` | Tab-aware Event Success host-section loading body. Mirrors Setup with configuration controls, Live with roster/assignment surfaces, and Report with metric/report cards, while respecting fixed Host Manage sections that hide the inner tab picker. |
| `EventSuccessCompanionLoadingBody` | `lib/event_success/presentation/event_success_companion_screen.dart:114` | Companion route loading body rendered inside stable companion chrome. Shows stage, primary action, and peer-list skeletons so event/profile/plan/mission/assignment provider waves do not collapse back to a centered spinner. |
| `EventSuccessEventPreviewLoadingScreen` | `lib/event_success/presentation/event_success_event_preview_screen.dart:78` | Preview-route loading scaffold with the real preview app bar and a body of hero, notes, setup, live, companion, and report skeleton sections. |
| `EventSuccessEventPreviewLoadingBody` | `lib/event_success/presentation/event_success_event_preview_screen.dart:93` | Scrollable preview-section skeleton body shared by the preview loading scaffold. Mirrors the loaded preview page structure without requiring event, club, roster, or viewer data. |
| `EventSuccessEventPreviewScreen` | `lib/event_success/presentation/event_success_event_preview_screen.dart:300` | Loaded dev/staging Event Success preview page composed from real event, optional club, optional roster, and optional viewer data. Renders preview hero, integration notes, host setup, live host mode, attendee companion preview, and post-event report blocks. |
| `MicroPodCard` | `lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:32` | Provider-free attendee companion starter-group card. Renders opted-in, opted-out, peer-loading, and assigned group/table rows from explicit assignment input plus `AssignmentOptOutActionState`, and emits include/exclude changes through a typed callback supplied by the companion screen. |
| `RotationScheduleCard` | `lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:192` | Provider-free attendee companion timed-rotation card. Renders opted-in, opted-out, peer-loading, and assigned rotation rows from explicit assignment input plus `AssignmentOptOutActionState`, and emits include/exclude changes through a typed callback supplied by the companion screen. |
| `PaperSelfCheckInBar` | `lib/event_success/presentation/companion_parts/event_success_companion_shared.dart:728` | Provider-free large paper-ticket check-in action. Renders pending state from `SelfCheckInActionState` and delegates the attendance write to the companion screen through a typed callback. |
| `_PrivateAfterglowRecapCard` | `lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:3` | Private attendee-only post-event recap artifact. Summarizes the event, opener availability, and optional saved feedback while explicitly avoiding public share pressure or host-visible personal details. |
| `EventSuccessPromptCard` | `lib/event_success/presentation/event_success_feature_blocks.dart:616` | Shared prompt card used by event-success preview and attendee companion surfaces. |
| `EventSuccessQuestionnaireConfigEditor` | `lib/event_success/presentation/event_success_questionnaire_config_editor.dart:15` | Shared questionnaire-template editor for host setup and create-event defaults. Lets hosts choose reusable question packs or switch to custom questions with handoff `SelectChip` choices, then previews the active pack with badges and question rows. Can open the custom-question builder inline or in a bottom sheet depending on the owning surface. |
| `EventSuccessStructureConfigEditor` | `lib/event_success/presentation/event_success_structure_config_editor.dart:10` | Shared structure editor for host setup and create-event defaults. Keeps internal unit modeling out of copy by exposing flow type, people-per-team/table/pod labels, auto versus fixed counts, and optional cadence/countdown controls supplied by the owning surface. Uses handoff `SelectChip` choices for flow type, count mode, repeat policy, and assignment goals. |
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
| `CalendarScreen` | `lib/events/presentation/calendar/calendar_screen.dart:27` | Calendar route registered as `screen.calendar.home` and aligned `ARCH-SCREEN-001` adopter. Watches uid, signed-up events, saved event details, and club-name lookup at the route edge; owns the route `Scaffold`, loading/error branches, retry invalidation, selected-date and expanded-header inputs, scroll-to-day behavior, and event-detail navigation; resolves `CalendarHomeState` before rendering one sliver-native scroll surface with provider-free date header, stats, agenda rows, loading skeletons, branded errors, and empty-state messaging. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CalendarAgendaSliverSection` | `lib/events/presentation/calendar/calendar_screen.dart:284` | Provider-free Calendar agenda branch renderer. Receives `CalendarAgendaSectionState`, day-key builder, event-selection callback, and club-name retry callback from `CalendarScreen`, then switches empty, club-name loading/error, and ready states into sliver-native message, skeleton, error, or `EventAgendaSliverList` rows without reading providers or owning navigation. |
| `CalendarLoadingScreen` | `lib/events/presentation/calendar/calendar_screen.dart:286` | Route-shaped loading body for Calendar. Keeps the pinned date-header skeleton, stats skeleton, and agenda skeleton inside the same `CustomScrollView` geometry used by loaded content. |
| `CalendarDateHeader` | `lib/events/presentation/calendar/calendar_screen.dart:345` | Pinned calendar header that owns the draggable week/month switch, title row, selected date, event markers, today action, and date-selection callback while consuming `CalendarEventSummary` display data. |
| `CalendarDateHeaderSkeleton` | `lib/events/presentation/calendar/calendar_screen.dart:407` | Loading version of the pinned date header, preserving title-row and week-strip shape while event data resolves. |
| `CalendarWeekStripSkeleton` | `lib/events/presentation/calendar/calendar_screen.dart:436` | Seven-column loading strip used by `CalendarDateHeaderSkeleton`, including the selected-day border placeholder. |
| `CalendarTitleRow` | `lib/events/presentation/calendar/calendar_screen.dart:458` | Month title plus compact Today action for the calendar header. Keeps long month labels bounded and delegates action handling to the owning screen. |
| `CalendarStatsHeader` | `lib/events/presentation/calendar/calendar_screen.dart:535` | Calendar summary card for planned event count, total non-cancelled distance, and next-event time. Consumes `CalendarEventSummary` instead of re-reading providers. |
| `CalendarStatsHeaderSkeleton` | `lib/events/presentation/calendar/calendar_screen.dart:596` | Loading version of the stats card with three stat placeholders and canonical dividers. |
| `CalendarStatSkeleton` | `lib/events/presentation/calendar/calendar_screen.dart:635` | Single loading stat atom used by `CalendarStatsHeaderSkeleton`. |
| `CalendarWeekStrip` | `lib/events/presentation/calendar/calendar_screen.dart:651` | Week selector row anchored to the selected date. Marks days that have calendar events and emits selected date changes without reading providers. |
| `CalendarMonthGrid` | `lib/events/presentation/calendar/calendar_screen.dart:695` | Six-week month selector grid. Shows weekday labels, disables out-of-month dates, highlights today and selected date, and marks days that have events from `CalendarEventSummary`. |
| `CalendarStatDivider` | `lib/events/presentation/calendar/calendar_screen.dart:773` | Tokenized vertical hairline divider between stats in the Calendar summary card. |
| `CalendarMessage` | `lib/events/presentation/calendar/calendar_screen.dart:792` | Calendar empty-message body backed by `CatchEmptyState`, used when there are no joined or saved planned events. |

### Presentation state

| Type | File | Purpose |
|---|---|---|
| `CalendarHomeState` | `lib/events/presentation/calendar/calendar_screen_state.dart:4` | Provider-free Calendar route display adapter. Wraps `CalendarEventSummary` with selected date, expanded-header mode, event presence, and club-id lookup input so `CalendarScreen` can keep provider waves, retry, scroll, and navigation at the route edge. |
| `CalendarEventSummary` | `lib/events/presentation/calendar/calendar_screen_state.dart:38` | Provider-free calendar event summary. De-duplicates signed-up and saved events, keeps only future saved-only rows, preserves cancelled joined events as agenda rows, excludes cancelled rows from distance/next-event stats, orders upcoming active rows before cancelled and past rows, and exposes the anchor date for header selection. |

### Internal helpers

| Helper | File | Purpose |
|---|---|---|
| `_CalendarDateHeaderDelegate` | `lib/events/presentation/calendar/calendar_screen.dart:496` | Fixed-height sliver delegate that pins the calendar date header and adds a bottom divider while content overlaps. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:32` | Post-payment route for the Booking handoff. Loads event context, branches pending external checkout into the handoff checkout sheet, and delegates completed payments to `EventJoinedCelebrationScreen` with payment quick actions, heads-up copy, stronger friend-invite sharing, and the stable Back home key. Event-context loading renders `_PaymentConfirmationLoadingScreen`, a confirmation-shaped skeleton with medallion, title/body, receipt card, quick-action tiles, and primary CTA placeholders. |
| `_PendingCheckoutBody` | `lib/payments/presentation/payment_confirmation_screen.dart:68` | Pending external-checkout adapter. Watches the payment record so a completed provider return auto-promotes into confirmation; otherwise renders the dimmed event backdrop plus `_CheckoutSheet` pending/failed state with checkout, payment-history, and back-to-event actions. |
| `_CheckoutEventBackdrop` | `lib/payments/presentation/payment_confirmation_screen.dart:146` | Booking checkout backdrop behind the pending sheet. Uses the event activity pigment gradient, event title, basic date/location/price summary, and `CatchOpacity.paymentCheckoutScrim` overlay from the route. |
| `_CheckoutSheet` | `lib/payments/presentation/payment_confirmation_screen.dart:203` | Flutter counterpart to the handoff `CheckoutSheet`: bottom-sheet surface with grabber, receipt/warning medallion, headline/body copy, event + price summary, Pending/Failed `CatchBadge`, provider checkout CTA when available, payment-history action, and back-to-event ghost action. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:371` | Thin payment confirmation adapter that composes `EventJoinedCelebrationScreen` with paid-event supplemental children and router actions. |
| `PaymentConfirmationKeys` | `lib/payments/presentation/payment_confirmation_keys.dart:3` | Stable semantic keys for confirmation quick actions, referral share, and sticky back-home CTA. |
| `PaymentHistoryScreen` | `lib/payments/presentation/payment_history_screen.dart:24` | Payment receipt history route registered as `screen.payments.history`. Watches `uidProvider`, delegates payment/event-title display rows to `paymentHistoryViewModelProvider`, renders empty/loading/error states plus `_PaymentTile` rows, and opens `PaymentReceiptSheet`. Receipt help feedback uses `showCatchSnackBar` after dismissing the sheet. |
| `PaymentHistoryViewModel` | `lib/payments/presentation/payment_history_state.dart:9` | Payment History display seam. Joins `watchPaymentsForUserProvider` records with the batched `watchEventsByIdsProvider` lookup, returns `PaymentHistoryRow` values, and centralizes the `Event booking` fallback for missing event context. |
| `_PaymentList` | `lib/payments/presentation/payment_history_screen.dart:57` | The list view of payment tiles fed by `paymentHistoryViewModelProvider`. |
| `_PaymentTile` | `lib/payments/presentation/payment_history_screen.dart:110` | Provider-free semantic payment transaction row — amount, date, event title, and status. Tapping opens the detail bottom sheet. |
| `PaymentHistoryKeys` | `lib/payments/presentation/payment_history_keys.dart:3` | Stable semantic payment-history tile keys for tests and future automation. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_QuickActions` | `lib/payments/presentation/payment_confirmation_screen.dart:86` | Row of quick-action tiles (add to calendar, directions, invite a friend) shown inside the run-joined celebration. |
| `_ActionTile` | `lib/payments/presentation/payment_confirmation_screen.dart:124` | Private icon-based `CatchSurface` quick-action tile. Keep private until this semantic component has a second concrete use. |
| `_HeadsUp` | `lib/payments/presentation/payment_confirmation_screen.dart:166` | `CatchSurface` info box about arrival/run-day expectations. |
| `_ReferralBanner` | `lib/payments/presentation/payment_confirmation_screen.dart:197` | Tappable `CatchSurface` referral banner shown inside the run-joined celebration. |
| `PaymentReceiptSheet` | `lib/payments/presentation/payment_history_screen.dart:227` | Provider-free receipt/detail bottom sheet for `screen.payments.history`. Renders status badge, amount, payment/order/event/date rows, refund or sign-up failure detail copy, and the failed-signup help CTA while `_PaymentTile` owns presentation and support snackbar wiring. |

---

## Safety / Settings

### State / Adapter

| Widget | File | Purpose |
|---|---|---|
| `SettingsAccountState` | `lib/safety/presentation/settings_account_state.dart:8` | Provider-edge display adapter for `screen.settings.account`. Maps profile loading/error/missing/content, optimistic preference draft values, blocked-account loading/error/empty/list rows, and mutation pending flags into provider-free data for the Settings route sections. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SettingsScreen` | `lib/safety/presentation/settings_screen.dart:32` | Consumer account settings route registered as `screen.settings.account`. Reads profile, blocked-account, and mutation providers at the route edge, seeds optimistic preference draft state from the loaded profile, delegates preference/deletion/unblock writes to `SettingsController`, owns sign out through `AuthSessionController`, and composes Account / Notifications / Privacy & safety / About / Log out sections from `SettingsAccountState`. Unblock success feedback uses `showCatchSnackBar`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_SettingsSection` | `lib/safety/presentation/settings_screen.dart:529` | Private Settings template section helper. Injects the first-row/no-divider and subsequent-row/inset-divider contract into `CatchField` rows, draws section hairlines directly on the page surface, and optionally renders a footer for account or blocked-account state content. |
| `_AccountProfileStatus` | `lib/safety/presentation/settings_screen.dart:570` | Provider-free account-section footer that renders profile provider error/missing copy from `SettingsProfileState` while leaving loaded/loading rows to `CatchField` values. |
| `_BlockedAccountsSection` | `lib/safety/presentation/settings_screen.dart:604` | Provider-free Privacy & safety footer listing blocked accounts under the handoff `Blocked users` row. Uses `_BlockedAccountsSkeleton` for row-shaped loading, `CatchEmptyState` for the empty state, `CatchInlineErrorState` for retryable errors, and renders `_BlockedAccountTile` rows from `SettingsBlockedAccountsState`. |
| `_BlockedAccountTile` | `lib/safety/presentation/settings_screen.dart:671` | Single provider-free blocked account row. Renders a `CatchPersonRow` from `SettingsBlockedAccountRow` display data and delegates the semantic unblock action back to the route callback. |
| `SettingsKeys` | `lib/safety/presentation/settings_keys.dart:3` | Stable semantic keys for account action rows, settings switches, delete-account row, and blocked-user unblock buttons. |
| `showConfirmDangerDialog` | `lib/core/widgets/confirm_danger_dialog.dart:4` | Shared destructive confirmation dialog helper used by safety/account actions such as block and delete-account confirmations. Delegates to `showCatchAdaptiveDialog` so iOS gets Cupertino alert chrome and Android/non-iOS platforms keep Material alert chrome. |
| `showBlockUserDialog` | `lib/core/widgets/block_user_dialog.dart:4` | Safety-specific block confirmation helper. Supplies block copy and delegates to `showConfirmDangerDialog`, so public profile and chat block actions share the handoff confirm-card composition and platform-adaptive destructive action behavior. |

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
| `WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:40` | Public bottom sheet for writing, editing, or deleting an event review. Requires a concrete `eventId`, uses `CatchBottomSheetScaffold`, semantic star/action keys, inline mutation errors, and `WriteReviewController` submit/delete mutations while Widgetbook can render write/edit fixtures directly. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubReviewsSection` | `lib/reviews/presentation/reviews_section.dart:19` | Read-only club review aggregate. Shows the latest three reviews, uses the compact inline empty state, and never opens the write/edit sheet. |
| `EventReviewsSection` | `lib/reviews/presentation/reviews_section.dart:44` | Event-scoped reviews with write/edit CTA for attended participants. Uses the same compact inline empty-state primitive as club reviews; this is the only page-level review section that should open `WriteReviewSheet`. |
| `ReviewsPreviewSection` | `lib/reviews/presentation/reviews_section.dart:121` | Shared read-only preview list: header, aggregate rating, compact/stacked empty-state configuration, top-N review cards, and optional see-all sheet. Callers supply edit callbacks only when the parent surface is event-scoped. |
| `ReviewsHistoryState` | `lib/reviews/presentation/reviews_history_state.dart:7` | Reviews History display seam. Owns signed-out/loading/error/empty/content selection, event-context labels, edit availability, retry targets, and provider-free `ReviewsHistoryRow` data. |
| `ReviewsHistoryScreen` | `lib/reviews/presentation/reviews_history_screen.dart:21` | Profile-owned review history route registered as `screen.reviews.history`. Watches uid/profile/review/event providers at the route edge, builds `ReviewsHistoryState`, composes provider-free body/list/row widgets, and opens the shared edit review sheet through typed row callbacks. |
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
| `_DashboardLoadingScreen`, route-level loading scaffolds | Several screens still create a full-screen loading scaffold by hand. | Consider `CatchLoadingScreen` only if another pass touches two or more route-level loading screens together. |
| `_DashboardMessageScreen`, route-level error/message scaffolds | Message screens are similar but not identical. | Consider `CatchMessageScreen` with optional title/body/action if repeated route-level message screens continue to grow. |
| `ChatsSliverHeader`, `ExploreSliverHeader` | Feature-specific pinned browse headers still share some title/search structure. | Parameterize a shared browse-sliver wrapper only if a third feature needs the same title/search/action pattern. |
| `ProfileInfoChip` | Swipe profile chip overlaps conceptually with `CatchChip`, but has overlay styling needs. | Extend `CatchChip` only if overlay-style info chips recur outside swipes. |

### Watch, Do Not Force

| Candidate | Reason To Wait |
|---|---|
| Feature empty-state wrappers | Most now delegate to `CatchEmptyState`. Keep wrappers when they encode feature-specific copy/content semantics; inline only when the wrapper adds no meaning. |
| `StatColumn`, `RunStatCell`, `HostStatChip` | They share a value-over-label concept, but host/profile/local chips still have different surface ownership. Detail-page metric rails should use `CatchMetricStrip` instead of new one-off stat rows. |
