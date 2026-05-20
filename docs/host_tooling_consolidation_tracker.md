---
doc_id: host_tooling_consolidation_tracker
version: 1.0.9
updated: 2026-05-20
owner: host_tooling
status: active
---

# Host Tooling Consolidation Tracker

Started: 2026-05-15

## Goal

Build one coherent host tooling system across Catch instead of letting host actions
proliferate as separate dashboard cards, club panels, route-only screens, and
ad hoc buttons.

The target state is:

- Hosts can always find the right operational action from the surface they are on.
- Per-event host actions support zero, one, and many upcoming hosted events.
- Host-only tools have a consistent palette, density, label system, and route
  pattern.
- Backend-ready host actions are either exposed with a product-safe UI or tracked
  as explicitly blocked by missing policy.
- Shared host widgets live in one feature-owned `hosts` feature instead of being
  duplicated inside Dashboard, Clubs, and Events screens.

## Current Surface Catalog

| Surface | File | Scope | Current actions | Cardinality | Current issues |
| --- | --- | --- | --- | --- | --- |
| Dashboard host tools rail | `lib/dashboard/presentation/widgets/dashboard_full.dart` (`HostToolsRail`) | Per hosted event | Manage event, Attendance when window is open | Unbounded hosted events | Uses shared `HostEventToolsCarousel`; Dashboard owns route navigation only and remains the primary host operations entry point. |
| Dashboard host tools model | `lib/dashboard/presentation/dashboard_full_view_model.dart` (`DashboardHostEventTool`) | Per hosted event | Uses `HostEventAttendanceState`, keeps non-cancelled past hosted events, and separates active from past operations | Unbounded hosted events | Dashboard owns composition and routing only. Attendance-window rules now live in `lib/hosts/domain/host_attendance_window.dart`. |
| Club detail host management panel | `lib/clubs/presentation/detail/widgets/club_detail_body.dart` (`HostClubManagementPanel`) | Per club | Add event, Edit club, upcoming booked/waitlist/revenue stats | One hosted club by current product rule | Club detail now renders one host-only management section instead of separate tools and stats widgets. Club create/edit owns host defaults for event policy and event-success setup. |
| Club schedule section | `lib/clubs/presentation/detail/widgets/club_schedule_section.dart` | Per event in hosted club context | Hosted badge and event detail navigation | Unbounded upcoming events | Resolved for first pass: host-owned events use the `HOSTED` tile state without turning schedule rows into dense control clusters. Deeper operations remain in Dashboard / Host Manage. |
| Event detail top actions | `lib/events/presentation/widgets/event_detail_body.dart` and detail app bar widgets | Per event | Share, save, add to calendar for future signed-up or hosted events | Singleton per event | Top actions stay generic utilities. Host operations intentionally route through Dashboard and Host Manage instead of adding another detail-page host section. |
| Event detail bottom CTA | `lib/events/presentation/widgets/event_detail_cta.dart` | Per event | Participant booking/waitlist/cancel states for non-host viewers | Singleton per viewer/event | Hosts no longer render this bottom footer. This keeps event detail from duplicating host tools that already exist on Dashboard and Host Manage. |
| Host event manage route | `lib/routing/go_router.dart` and `lib/hosts/presentation/host_event_manage_screen.dart` (`HostEventManageRouteScreen`) | Per event | Host-gated route load and access check, optional lifecycle section | Singleton per event | Canonical route is `/clubs/:clubId/events/:eventId/manage`. Dashboard, event-success, and attendance paths are aliases into the same workspace with the relevant lifecycle section selected. |
| Host event manage screen | `lib/hosts/presentation/host_event_manage_screen.dart` (`HostEventManageScreen`) | Per event | Setup, Live, Report sections, Edit event action | Singleton per event | Lifecycle workspace with a full-width segmented switcher. Setup combines event details/admin, event-success setup, and the read-only participant roster; Live combines check-in mutation with event-success live mode; Report combines attendance summary with the post-event host report. |
| Host edit event route | `lib/hosts/presentation/edit_hosted_event_screen.dart` (`EditHostedEventRouteScreen`) | Per event | Host-gated published-event edit form | Singleton per event | Edits backend-supported operational fields from one place. Schedule and booking-policy controls lock once the event starts or has booking/waitlist/attendance activity. |
| Create-event success handoff | `lib/events/presentation/create_event_success_screen.dart` and `create_event_screen.dart` | Newly created event | Manage event, Back to club | Singleton immediately after creation | Manage event now routes to canonical Host Manage instead of embedding a second management screen inside the create flow. |
| Event tile hosted status | `lib/events/presentation/widgets/event_tiles/event_tile_data.dart` and event tile atoms | Per event tile | `EventTileStatus.hosted` badge | Per tile | Existing hosted status can identify owned events, but it does not unlock host actions. This should feed into the same host action model instead of one-off tile affordances. |

## Backend-Ready Host Actions

| Action | Backend status | Current UI status | Proposed UI treatment |
| --- | --- | --- | --- |
| Create event | Implemented through `createEvent` | Exposed from club host panel and create-event flow | Keep as club-level primary action through shared club host panel. |
| Edit club | Implemented through `updateClub`/club repository update seam | Exposed from club host panel | Keep as club-level secondary action through shared club host panel. |
| Manage event | Operational screen implemented | Exposed from Dashboard and create success | Keep as the per-event host operations destination for roster, waitlist, stats, cancellation, unused-event deletion, and event-success entry. |
| Take attendance | Implemented through `markEventAttendance` | Exposed from Dashboard when the window is open and through attendance/management routes | Keep Dashboard as the discoverable host action surface. Disabled state should explain open/closed windows; missed-attendance correction stays reachable through Host Manage for past events. |
| Edit event | Backend edit seam exists | Exposed from Host Manage through `/clubs/:clubId/events/:eventId/edit` | Dedicated host edit form for backend-supported operational fields. Capacity, price, admission/event policy, invite setup, and cancellation policy are editable only before event activity exists; schedule edits have the same lock. Photo replacement and title edits remain explicit product-policy follow-ups. |
| Cancel event | `cancelEvent` implemented | Exposed from Host Manage | Host Manage shows destructive confirmation and history-retention copy. The callable cancels the event, releases schedule locks, attempts completed attendee refunds, refreshes club next-event projections, and notifies signed-up/waitlisted participants. |
| Delete unused event | `deleteEvent` implemented | Exposed from Host Manage when no visible activity exists | Destructive secondary action on Host Manage only, guarded by backend rejection and confirmation copy. Events with bookings, waitlist, attendance, payments, or reviews should be cancelled instead. |
| Archive club | `archiveRunClub` backend-ready | UI queued | Club settings/host panel action after browse/search archived filtering is confirmed. |
| Delete unused club | `deleteRunClub` backend-ready | UI queued | Destructive club settings action only for never-used clubs, with backend rejection surfaced clearly. |
| Add to calendar | Implemented platform seam | Exposed on event focus and event detail | Keep as participant/host utility action. It should not be styled as a host tool unless the surrounding card is host-specific. |
| Directions | Implemented through map/location utility surfaces | Exposed on event focus | Useful for hosts too, but operationally generic. Keep out of host-only palette unless bundled in event focus. |

## Consolidation Direction

### Shared Concepts

- `HostEventToolItem`: feature-level model containing `event`, attendance availability,
  host ownership, and available actions.
- `HostToolAction`: typed actions for manage, attendance, edit event,
  cancel event, delete event, edit club, create event, archive club, and delete
  club.
- `HostToolAvailability`: enabled, disabled with reason, hidden, destructive.
- `HostToolPalette`: central helper that maps host states to token-backed colors:
  default host panel, attendance open, upcoming/disabled, warning, destructive.
- `HostToolSection`: reusable labeled section with `HOST TOOLS` treatment,
  optional count badge, and consistent spacing.
- `HostEventToolCard`: full-width snapping per-event operational card for
  unbounded hosted events. Actions should stack on their own lines when labels are
  long.
- `HostClubManagementPanel`: club-level host action and aggregate stats section.
- `HostEventAttendanceState` and attendance-window helpers live in
  `lib/hosts/domain/host_attendance_window.dart` so Dashboard, arrival actions,
  and Host Manage use the same open/closed/past-event decision.
- `HostEventParticipantsPanel`: single event participants surface with lifecycle
  modes for setup roster/waitlist, live check-in, and report attendance summary.
- `ClubHostDefaults`: club-level defaults for event policy and event-success
  setup that are copied into new event drafts and can be overridden per event.
- `EventSuccessDefaultsPanel`: shared default/toggle form used by club
  create/edit and the create-event policy step.

### Surface-Specific Target State

- Dashboard: use full-width snapping host event cards and page indicators,
  parallel to `EventFocusRail` but
  visually host-specific.
- Club detail: render one club-level host management section with actions and
  aggregate stats; keep per-event operations in Host Manage.
- Club schedule: for hosts, surface hosted event state and at least a Manage
  affordance without turning every schedule tile into a control cluster.
- Event detail: do not render a second host-tool section. Hosts should use
  Dashboard for discovery and Host Manage / attendance routes for operations.
- Host manage: make it the destination for deeper per-event operations. Keep
  setup, live check-in, and report operations there, with participants rendered
  through one lifecycle-aware panel.
- Create/edit club: configure default admission, cancellation, age/cohort,
  dynamic-pricing, and event-success setup behavior once at the club level.
- Create event: start from club defaults, then allow a one-off per-event
  override before the event is published.
- Edit event: allow policy/capacity/price/invite/cancellation corrections only
  while the event has not started and no participant activity exists.
- Attendance route: no standalone screen. The production and legacy route opens
  Host Manage with Attendance selected.

## Implementation Checklist

- [x] Catalog current host tooling surfaces.
- [x] Inventory backend-ready host actions and UI gaps.
- [x] Add shared host tooling models/palette/widgets in a feature-owned module.
- [x] Refactor Dashboard host tools onto the shared full-width card pattern.
- [x] Refactor club host panel and host stats onto shared primitives.
- [x] Remove duplicate event-detail host bottom footer; keep Dashboard as the
  host operations discovery surface.
- [x] Add hosted-event affordance to club schedule without overloading event tiles.
- [x] Align Attendance Sheet visual treatment with the host palette.
- [x] Expose Cancel event and Delete unused event from Host Manage with guardrails.
- [x] Ship a limited Edit event UX for backend-supported operational fields.
- [ ] Decide or explicitly block Archive club and Delete club UX.
- [x] Update `docs/widget_catalog.md` after widget ownership changes.
- [x] Add/adjust focused widget tests for dashboard, event detail, club detail,
  host manage, and attendance.
- [x] Run focused analyze/tests.
- [x] Stamp audit registry pass proof.
- [x] Consolidate Event Success into Host Manage as a section while preserving
  the old success route as an alias.
- [x] Consolidate attendance into Host Manage as a section while preserving the
  old attendance route as an alias.
- [x] Replace separate club-detail host tools/stats blocks with one host
  management panel.
- [x] Route the create-event success handoff into canonical Host Manage.
- [x] Extract repeated event-success lab/preview pills, prompt cards, metrics,
  and recommendation tiles into shared event-success widgets.
- [x] Consolidate Host Manage roster, waitlist, attendance, and report summary
  onto one lifecycle-aware participants panel.
- [x] Keep event-success live mode unavailable when setup was never saved while
  leaving attendance/check-in usable.
- [x] Add club-level host defaults for event policy and event-success setup.
- [x] Apply club host defaults to create-event drafts with per-event override.
- [x] Allow pre-activity published-event policy/capacity/price/invite edits from
  the canonical host edit screen.

## Open Product Decisions

- TODO `HOST-PUBLISHED-EDIT-POLICY-001`: decide whether published-event photo
  replacement and title edits should be host-visible. Before exposing those
  fields, decide attendee notification copy, title-change history, photo
  moderation/storage rules, and whether replacement photos are allowed after any
  participant activity exists.
- TODO `HOST-EVENT-SUCCESS-SERVER-FREEZE-001`: client UI now freezes
  event-success setup after event start or participant activity, but the server
  still treats event-success plan writes as broad host-owned document updates.
  Decide whether setup writes should move behind a callable or rules diff that
  allows live-step updates while blocking setup rewrites after bookings.
- TODO `HOST-CREATE-EVENT-ATOMIC-SUCCESS-001`: create-event currently creates
  the event first and then saves the optional event-success plan. Decide whether
  event-success setup should be folded into the `createEvent` callable so event
  creation and setup persistence are atomic.
- Should club archive/delete actions be visible to hosts, or should those
  backend callables remain admin/maintenance-only until archived-club browse and
  search filtering is fully product-approved?
- Should a hosted event tile in non-host contexts expose host actions only after
  opening detail, or should host-owned tiles have inline Manage shortcuts?
- How much host history should Dashboard show before past hosted events need a
  dedicated archive/filter route beyond the current Active/Past segmented rail?

## Verification Log

- 2026-05-15: Ran audit registry refresh and active-rule lookup before creating
  this tracker.
- 2026-05-15: Scanned host tooling references across `lib/`, `test/`, and `docs/`.
- 2026-05-15: Compared current UI exposure against
  `docs/backend_operation_catalog.md` backend operation status.
- 2026-05-15: Added shared host-tool widgets in `lib/host_tools/presentation/`.
- 2026-05-15: Refactored Dashboard host run tools to full-width snapping cards.
- 2026-05-15: Refactored run-club host panel/stats, run-detail host bottom
  actions, attendance sheet header, and host manage stat chips onto shared host
  primitives.
- 2026-05-15: Focused analysis and widget tests passed for changed host surfaces.
- 2026-05-15: Stamped audit registry pass proof. New files were stamped after a
  follow-up inventory refresh.
- 2026-05-17: Verified Host Manage now exposes cancel and delete actions with
  focused widget coverage. Remaining open host-tooling product decisions are
  Edit event and club archive/delete UX.
- 2026-05-19: Moved shared host-tool widgets to
  `lib/hosts/presentation/widgets/` and updated screen imports to use the
  feature-owned host widget folder.
- 2026-05-19: Removed the event-detail host bottom footer and changed Dashboard
  host tools to retain closed past hosted events after attendance closes.
- 2026-05-19: Consolidated the first five host cleanup candidates: Host Manage
  now owns overview, attendance, and event-success sections; event-success and
  attendance deep links are aliases into Host Manage; club detail has one host
  management panel; create-event success routes to Host Manage; and event-success
  lab/preview duplicate shells now share reusable widgets.
- 2026-05-19: Moved Host Manage into `lib/hosts/presentation/`, added the
  neutral `/clubs/:clubId/events/:eventId/manage` route plus dashboard alias,
  added `/clubs/:clubId/events/:eventId/edit`, removed standalone attendance and
  event-success host wrappers, and centralized host attendance-window state in
  `lib/hosts/domain/`.
- 2026-05-20: Added `ClubHostDefaults`, `EventPolicyDefaults`, and
  `EventSuccessDefaults`; create/edit club now owns host defaults, create event
  applies those defaults with per-event overrides, and edit hosted event can
  change booking-sensitive policy fields only before event activity exists.
- 2026-05-20: Verified the host-defaults pass with full data-contract checks,
  full Functions tests, full Flutter analysis, callable DTO contract tests, and
  focused host/club/event-success widget tests.

## Resume Notes

Do not restart the dashboard/shared-widget consolidation; that work is already
done. Resume from the remaining product decisions:

1. Decide whether photo replacement, title/capacity/price/policy changes, or
   invite setup belong in the published-event edit policy. Capacity, price,
   policy, cancellation, and invite setup are now implemented for pre-activity
   event edits; photo/title remain undecided.
2. Decide whether host-visible club archive/delete belongs in club settings.
3. Decide how much history Dashboard should show before host operations need a
   dedicated Past hosted events filter or archive view.
4. Decide whether event-success setup persistence should move fully behind
   server-owned callables for atomic create and post-booking freeze enforcement.
5. If those actions ship, update `docs/backend_operation_catalog.md`, focused
   host widget tests, and the audit registry in the same pass.
