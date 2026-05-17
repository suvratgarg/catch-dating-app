---
doc_id: host_tooling_consolidation_tracker
version: 1.0.1
updated: 2026-05-17
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
- Per-run host actions support zero, one, and many upcoming hosted runs.
- Host-only tools have a consistent palette, density, label system, and route
  pattern.
- Backend-ready host actions are either exposed with a product-safe UI or tracked
  as explicitly blocked by missing policy.
- Shared host widgets live in one feature-owned place instead of being duplicated
  inside Dashboard, Run Clubs, and Runs screens.

## Current Surface Catalog

| Surface | File | Scope | Current actions | Cardinality | Current issues |
| --- | --- | --- | --- | --- | --- |
| Dashboard host tools rail | `lib/dashboard/presentation/widgets/dashboard_full.dart` (`HostToolsRail`) | Per hosted run | Manage run, Attendance when window is open | Unbounded hosted runs | Uses a local horizontal `SingleChildScrollView` card pattern instead of the full-width snapping pattern now used by run focus. Palette is partly host-specific but not centralized. Cards know navigation, attendance labels, and visual treatment directly. |
| Dashboard host tools model | `lib/dashboard/presentation/dashboard_full_view_model.dart` (`DashboardHostRunTool`) | Per hosted run | Derives attendance state and sorts open attendance first | Unbounded hosted runs | Logic is dashboard-owned even though the same availability rules are needed on run detail, club schedule, and possibly host manage. It intentionally suppresses the older host arrival card by passing `hostedRuns: const []` to `selectRunArrivalAction`. |
| Run club detail host panel | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart` (`_HostActionPanel`) | Per club | Edit club, Add run | One hosted club by current product rule | Local panel duplicates the `HOST TOOLS` concept with different density and palette. It has club-level tools only; it does not help hosts browse/manage multiple runs from the club schedule beyond opening run detail. |
| Run club host stats | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart` (`HostStatsBar`) | Club aggregate | Upcoming booked, waitlist, revenue stats | Domain-bounded by upcoming runs | Uses an orange host treatment but through local `Container`/`BoxDecoration` instead of shared host stats primitives and `CatchSurface`. |
| Club schedule section | `lib/run_clubs/presentation/detail/widgets/club_schedule_section.dart` | Per run in hosted club context | Hosted badge and run detail navigation | Unbounded upcoming runs | Resolved for first pass: host-owned runs use the `HOSTED` tile state without turning schedule rows into dense control clusters. Deeper operations remain in run detail / Host Manage. |
| Run detail top actions | `lib/runs/presentation/widgets/run_detail_body.dart` and `run_detail_hero_app_bar.dart` | Per run | Share, save, add to calendar for future signed-up or hosted runs | Singleton per run | Top actions stay generic utilities. Host operations are intentionally in the bottom host CTA and Host Manage destination. |
| Run detail bottom CTA | `lib/runs/presentation/widgets/run_detail_cta.dart` | Per run | Participant booking/waitlist/cancel states or host Manage/Attendance actions | Singleton per viewer/run | Resolved for first pass: hosted runs render shared `HostRunBottomActions` instead of an empty footer. |
| Host run manage route | `lib/routing/go_router.dart` and `lib/runs/presentation/host_run_manage_screen.dart` (`HostRunManageRouteScreen`) | Per run | Host-gated route load and access check | Singleton per run | Route path is dashboard-shaped (`/dashboard/run-clubs/.../manage`) even when future entry points may come from club detail or run detail. |
| Host run manage screen | `lib/runs/presentation/host_run_manage_screen.dart` (`HostRunManageScreen`) | Per run | Stats, run summary, roster, waitlist | Singleton per run | Mostly read-only. Missing edit/cancel/delete actions despite backend seams. Uses local stat cards, summary rows, section headers, and roster layout that should become host primitives if reused. |
| Attendance sheet | `lib/runs/presentation/attendance_sheet_screen.dart` | Per run | Toggle attendance for signed-up/waitlisted attendees | One attendance decision per participant/run, repeatable as correction | Functionally implemented, but visual language is generic and not obviously part of the host tooling system. Access policy is enforced by the callable; route-level host affordance could be clearer. |
| Create-run success handoff | `lib/runs/presentation/create_run_success_screen.dart` and `create_run_screen.dart` | Newly created run | Manage run, Back to club | Singleton immediately after creation | Useful, but not a durable discovery surface. Dashboard host tools partially solved this; run detail and club schedule should also lead hosts back to management. |
| Run tile hosted status | `lib/runs/presentation/widgets/run_tiles/run_tile_data.dart` and `run_tile_atoms.dart` | Per run tile | `RunTileStatus.hosted` badge | Per tile | Existing hosted status can identify owned runs, but it does not unlock host actions. This should feed into the same host action model instead of one-off tile affordances. |

## Backend-Ready Host Actions

| Action | Backend status | Current UI status | Proposed UI treatment |
| --- | --- | --- | --- |
| Create run | Implemented through `createRun` | Exposed from run club host panel and create-run flow | Keep as club-level primary action. Move into shared club host panel. |
| Edit club | Implemented through `updateRunClub` | Exposed from run club host panel | Keep as club-level secondary action. Move into shared club host panel. |
| Manage run | Operational screen implemented | Exposed from Dashboard, create success, run detail, and hosted club schedule | Keep as the per-run host operations destination for roster, waitlist, stats, cancellation, and unused-run deletion. |
| Take attendance | Implemented through `markRunAttendance` | Exposed from Dashboard only when window is open | Expose consistently anywhere a host-owned run is in focus. Disabled state should explain open/closed windows. |
| Edit run | `RunRepository.updateRunDetails` calls `updateRun` | No obvious host edit UI | Add to host manage after deciding which fields can be edited post-publish. Use a dedicated form route, not inline table edits. |
| Cancel run | `cancelRun` implemented | Exposed from Host Manage | Host Manage shows destructive confirmation and history-retention copy. The callable cancels the run, releases schedule locks, attempts completed attendee refunds, refreshes club next-run projections, and notifies signed-up/waitlisted participants. |
| Delete unused run | `deleteRun` implemented | Exposed from Host Manage when no visible activity exists | Destructive secondary action on Host Manage only, guarded by backend rejection and confirmation copy. Runs with bookings, waitlist, attendance, payments, or reviews should be cancelled instead. |
| Archive club | `archiveRunClub` backend-ready | UI queued | Club settings/host panel action after browse/search archived filtering is confirmed. |
| Delete unused club | `deleteRunClub` backend-ready | UI queued | Destructive club settings action only for never-used clubs, with backend rejection surfaced clearly. |
| Add to calendar | Implemented platform seam | Exposed on run focus and run detail | Keep as runner/host utility action. It should not be styled as a host tool unless the surrounding card is host-specific. |
| Directions | Implemented through map/location utility surfaces | Exposed on run focus | Useful for hosts too, but operationally generic. Keep out of host-only palette unless bundled in run focus. |

## Consolidation Direction

### Shared Concepts

- `HostRunTool`: feature-level model containing `run`, attendance availability,
  host ownership, and available actions.
- `HostToolAction`: typed actions for manage, attendance, edit run, cancel run,
  delete run, edit club, create run, archive club, and delete club.
- `HostToolAvailability`: enabled, disabled with reason, hidden, destructive.
- `HostToolPalette`: central helper that maps host states to token-backed colors:
  default host panel, attendance open, upcoming/disabled, warning, destructive.
- `HostToolSection`: reusable labeled section with `HOST TOOLS` treatment,
  optional count badge, and consistent spacing.
- `HostRunToolCard`: full-width snapping per-run operational card for
  unbounded hosted runs. Actions should stack on their own lines when labels are
  long.
- `HostStatsStrip`: shared booked/waitlist/revenue stats component usable by
  club detail and host manage.

### Surface-Specific Target State

- Dashboard: replace the current clipped horizontal rail with full-width
  snapping host run cards and page indicators, parallel to `RunFocusRail` but
  visually host-specific.
- Run club detail: replace `_HostActionPanel` and `HostStatsBar` with shared
  host section/stats primitives; keep club-level tools separate from per-run
  operational cards.
- Club schedule: for hosts, surface hosted run state and at least a Manage
  affordance without turning every schedule tile into a control cluster.
- Run detail: hosts should see a compact host tools strip or bottom CTA with
  Manage and Attendance availability instead of a blank bottom area.
- Host manage: make it the destination for deeper per-run operations. Keep roster
  and waitlist there, add edit/cancel/delete only when the product rules are
  ready.
- Attendance sheet: keep the dedicated workflow but update visual treatment so
  it reads as part of host tools.

## Implementation Checklist

- [x] Catalog current host tooling surfaces.
- [x] Inventory backend-ready host actions and UI gaps.
- [x] Add shared host tooling models/palette/widgets in a feature-owned module.
- [x] Refactor Dashboard host tools onto the shared full-width card pattern.
- [x] Refactor run club host panel and host stats onto shared primitives.
- [x] Add host tools entry points to run detail for Manage and Attendance.
- [x] Add hosted-run affordance to club schedule without overloading run tiles.
- [x] Align Attendance Sheet visual treatment with the host palette.
- [x] Expose Cancel run and Delete unused run from Host Manage with guardrails.
- [ ] Decide or explicitly block Edit run UX.
- [ ] Decide or explicitly block Archive club and Delete club UX.
- [x] Update `docs/widget_catalog.md` after widget ownership changes.
- [x] Add/adjust focused widget tests for dashboard, run detail, run club detail,
  host manage, and attendance.
- [x] Run focused analyze/tests.
- [x] Stamp audit registry pass proof.

## Open Product Decisions

- What exact fields can hosts edit on a published run, and should that use the
  existing create-run form, a dedicated edit route, or a tighter host-manage
  form?
- Should club archive/delete actions be visible to hosts, or should those
  backend callables remain admin/maintenance-only until archived-club browse and
  search filtering is fully product-approved?
- Should a hosted run tile in non-host contexts expose host actions only after
  opening detail, or should host-owned tiles have inline Manage shortcuts?
- Should the host manage route remain dashboard-shaped for deep links, or should
  we add a neutral canonical route for management while keeping old paths as
  aliases?

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
- 2026-05-17: Verified Host Manage now exposes Cancel run and Delete run with
  focused widget coverage in `test/runs/create_run_screen_test.dart`. Remaining
  open host-tooling product decisions are Edit run and club archive/delete UX.

## Resume Notes

Do not restart the dashboard/shared-widget consolidation; that work is already
done. Resume from the remaining product decisions:

1. Decide the published-run edit route and editable fields.
2. Decide whether host-visible club archive/delete belongs in club settings.
3. If those actions ship, update `docs/backend_operation_catalog.md`, focused
   host widget tests, and the audit registry in the same pass.
