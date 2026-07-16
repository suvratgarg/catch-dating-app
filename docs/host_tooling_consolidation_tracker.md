---
doc_id: host_tooling_consolidation_tracker
version: 1.0.15
updated: 2026-07-16
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

## Active Codex Handoff: Host Clubs Edit Tab Consolidation

Status: implemented and focused-verified

Work item: `HOST-CLUB-EDIT-CONSOLIDATION-001`

Verified against the live worktree on 2026-07-16. Re-run the inventory and
context pack before editing because this repository may contain concurrent work.

Implementation closed on 2026-07-16. The production Edit tab now has one
canonical owner-only Payouts section, one canonical owner/co-host Host team
section, one Event defaults section, and one top-bar Settings action. The
former organizer payout prompt, team summary, and Manage shell were removed.

Follow-up consolidation closed on 2026-07-16: the organizer Edit tab now also
owns club logo/photos, cohort caps, demand pricing, and activity-aware Event
Success defaults. The standalone Host Edit Club implementation and the
create-wizard edit mode were deleted. `/host/clubs/:clubId/edit` remains only
as a compatibility redirect to `/host/organizer?clubId=:clubId&tab=edit`.

### Requested outcome

Make the Host app's **Clubs > Edit** tab tell each story once:

- one payout status and action section;
- one host-team section for both owners and co-hosts;
- one event-defaults section;
- one settings entry point; and
- no standalone `CatchSectionHeader` + manual gap + untitled `CatchSection`
  shells.

This is a UI ownership/consolidation pass. Do not change Stripe behavior,
payment-account contracts, host-team mutations, club permissions, or event
default persistence.

### Current composition and duplication

```text
HostClubsScaffold / Edit tab
├── HostClubOrganizerOverviewController
│   └── HostClubOrganizerOverview
│       ├── format badges
│       ├── HostOrganizerPayoutPromptController       [payout owner 1]
│       ├── HostOrganizerMetricGrid
│       ├── CatchSectionHeader("Team · count")
│       ├── HostOrganizerTeamCard                     [team owner 1]
│       ├── CatchSectionHeader("Manage") + gapH10     [manual shell]
│       └── untitled CatchSection.contained
│           ├── Payouts -> scroll to editor           [payout owner 2]
│           ├── Event defaults -> scroll to editor    [defaults duplicate]
│           └── Settings -> Host Settings             [unique action]
└── HostClubProfileCard
    ├── CatchSection.fieldRows("Identity")
    ├── CatchSection.fieldRows("Contact")
    ├── CatchSection.fieldRows("Event defaults")      [canonical defaults]
    ├── CatchSection.fieldRows("Public profile")
    ├── CatchSection.divided
    │   └── HostPaymentAccountControllerCard          [payout owner 3]
    │       └── CatchSurface + CatchSectionHeader      [manual card shell]
    └── CatchSection.divided
        └── HostTeamManagementSection                 [team owner 2]
            └── CatchSection.contained("Host team")
```

#### Payout references

| Reference | Current responsibility | Consolidation disposition |
| --- | --- | --- |
| `host_organizer.dart`: `HostOrganizerPayoutPromptController` | Watches the same host payment account and renders loading/error/setup-required callout copy and CTA. | Delete after the canonical payment section owns those states. |
| `host_organizer.dart`: Manage/Payouts `CatchField.nav` | Shows a second Payouts label and scrolls to the generic editor block rather than a payout-specific target. | Delete with the Manage block. |
| `host_club_profile.dart`: `HostPaymentAccountControllerCard` | Full loading/error/setup/pending/restricted/ready presentation plus onboarding and refresh actions. | Keep as the single provider owner and payout entry point. |
| `host_payment_account_card.dart`: content/loading/error cards | Hand-roll `CatchSurface` + `CatchSectionHeader` for section-like content. | Recompose each state through `CatchSection.contained` and keep state-specific body/actions. |

The payment section must remain owner-only unless product policy changes.
Co-hosts currently see a disabled "Payouts / Owner only" summary row; removing
that row is intentional because it advertises an action they cannot use.

#### Host and host-team references

| Reference | Current responsibility | Consolidation disposition |
| --- | --- | --- |
| `host_organizer.dart`: Team header + `HostOrganizerTeamCard` | Shows a count, at most three profiles, owner/host labels, and a Manage scroll action. | Delete after the canonical team section supports read-only and management modes. |
| `host_club_profile.dart`: `HostTeamManagementSection` | Shows the full roster and owner-only add/remove/transfer actions. | Keep as the single team section. Add an explicit `canManage`/owner capability input and render it for owners and co-hosts. |
| Club switcher copy such as `"Club · Host team"` | Identifies the current user's relationship to a club. | Preserve. This is navigation context, not duplicate team content. |
| Row labels `Owner`, `Host`, and `You · role` | Explain individual roles. | Preserve inside the canonical team section. These are semantic data, not duplicate section ownership. |

For non-owners, the canonical team section must remain visible but hide the Add
Host control and mutation menus. Do not infer management permission merely from
the row's `currentUid`; pass the capability explicitly from the resolved club
ownership state.

### Existing design decisions that govern this pass

- `docs/design_parity/widgetbook_compare_decisions.jsonl` records
  `app-team-roster-family` as **merge**, with `HostTeamManagementSection` and
  `HostOrganizerTeamCard` mapped to `catch.team_management`.
- The same ledger records `app-payment-card-family` as **merge**, with
  `HostPaymentAccountCard` and `HostPaymentAccountContentCard` mapped to
  `catch.payment_card`.
- `docs/design_parity/widget_consolidation/decisions.json` later records keep
  outcomes for some of these symbols. The implementing thread must reconcile
  that ledger with this current user-directed consolidation. Do not leave a
  deleted widget recorded as an active keep.
- `docs/widget_catalog.md` says carded section content belongs to
  `CatchSection.contained`, and that `CatchSection` owns title, trailing/count,
  contained chrome, and heading semantics.
- `REG-SECTION-OWNERSHIP-001` and `design:section-headers` own enforcement for
  standalone section-header shells.

### Target ownership

| Concern | Single owner after the pass |
| --- | --- |
| Format badges and club metrics | `HostClubOrganizerOverview` |
| Editable identity/contact/defaults/public profile | `HostClubProfileCard` using direct `CatchSection.fieldRows` instances |
| Payout async state and mutations | `HostPaymentAccountControllerCard` |
| Payout title/chrome/body/actions | Canonical `CatchSection.contained` compositions in the payment-account presentation widgets |
| Team roster and owner actions | `HostTeamManagementSection`, parameterized by explicit management capability |
| Host Settings navigation | A single Host Clubs top-bar settings action using the existing `CatchTopBarIconAction`; do not add a new core top-bar API |

The recommended final Edit-tab order is: summary metrics, Identity, Contact,
Event defaults, Public profile, Payouts (owner only), Host team. Settings moves
to the screen chrome because it is host-account navigation, not selected-club
content. If top-bar action density fails focused visual review, keep one
canonical Settings field section at the end of the Edit tab; do not restore the
multi-purpose Manage shell.

### Implementation sequence

1. **Lock behavior with tests before deleting UI.**
   - Add owner and co-host expectations for exactly one team section.
   - Add owner expectations for exactly one payout section and co-host
     expectations for no payout section.
   - Preserve payment loading, query error, setup-required, pending,
     restricted, ready, onboarding mutation, and refresh mutation behavior.
   - Preserve host-team add/remove/transfer mutation behavior for owners.

2. **Reduce `HostClubOrganizerOverview` to real overview content.**
   - Keep format badges and `HostOrganizerMetricGrid`.
   - Remove `HostOrganizerPayoutPromptController`.
   - Remove the Team header, `HostOrganizerTeamCard`, and
     `HostOrganizerTeamRow`.
   - Remove the Manage header, manual gap, and untitled
     `CatchSection.contained` block.
   - Remove now-dead `currentUid`, `isOwner`, `onOpenEditor`, and
     `onOpenSettings` parameters only after checking every production,
     test-fixture, and Widgetbook caller.

3. **Make payout presentation a canonical section.**
   - Have content/loading/error variants instantiate `CatchSection.contained`
     directly with `title: Payouts`.
   - Put the status badge or loading skeleton in the section's `trailing` slot.
   - Keep the presentation title/body, country/currency badges, error banner,
     onboarding sheet, setup/continue CTA, and refresh action unchanged.
   - Remove the outer `CatchSection.divided` around
     `HostPaymentAccountControllerCard`; nesting a titled contained section in
     an untitled divided section creates two section owners.
   - Do not merge the provider controller into the display widget. The desired
     merge is visual/section ownership, not a loss of controller separation.

4. **Make team presentation one canonical section.**
   - Add `canManage` (or a more precise capability value) to
     `HostTeamManagementSection`.
   - Render `HostTeamManagementSection` for owners and co-hosts.
   - Show Add Host, remove, and transfer actions only when `canManage` is true;
     keep the roster and role labels visible otherwise.
   - Remove the outer `CatchSection.divided`; the child already owns a titled
     `CatchSection.contained`.
   - Decide an explicit empty-roster body inside the canonical section instead
     of retaining `HostOrganizerTeamCard` solely for its empty copy.

5. **Preserve the unique Settings action.**
   - Add one settings icon action to `HostClubsScaffold` and route it through
     the existing `Routes.hostSettingsScreen` path.
   - Add tooltip/semantics and navigation coverage.
   - Remove `_openEditorSections` if it has no remaining caller. Keep
     `_profileSectionsKey` and initial-field reveal behavior if they are still
     required for deep-linked inline editing.

6. **Delete dead payout/team artifacts and copy.**
   - Delete `host_organizer_payout_prompt.dart` and
     `host_organizer_payout_prompt_controller.dart` if production references
     reach zero.
   - Remove obsolete Host Organizer payout-prompt, Manage, team-summary, and
     owner/host-row localization messages only when no remaining semantic use
     exists.
   - Regenerate Flutter localizations; never edit generated localization files
     by hand.
   - Remove obsolete Widgetbook use cases and generated directory entries.
   - Refresh widget classification, similarity, definition, coverage, provider
     graph, and consolidation receipts required by the removed public symbols.
   - Update `docs/widget_catalog.md` so it no longer catalogs deleted prompt or
     summary widgets.

7. **Close the scanner gap without broad false positives.**
   - Keep `SECTION-HEADER-004` and its known-bad/known-good fixtures for
     `CatchSectionHeader` + vertical spacing + untitled `CatchSection`.
   - Add a known-bad fixture for a feature-local `*Card` that returns
     `CatchSurface` containing `CatchSectionHeader` and section-like body/action
     content, using `HostPaymentAccountContentCard` as the motivating shape.
   - Start this broader card-shell rule as a medium advisory unless its
     structural confidence excludes legitimate content cards. Inventory and
     triage live findings before promoting it to high/fail-on-high.
   - Update `tool/tools_manifest.json` vacuity proof and the relevant regression
     ledger entry in the same change.

8. **Reconcile durable registries and stamp proof.**
   - Update/supersede the conflicting widget-consolidation keep records for
     removed symbols.
   - Refresh generated registries after source and Widgetbook changes.
   - Record a cleanup pass receipt only after focused UI/tests/scanners pass.

### Primary file scope

Expected production scope:

- `lib/hosts/presentation/host_operations/host_clubs_scaffold.dart`
- `lib/hosts/presentation/host_operations/host_organizer.dart`
- `lib/hosts/presentation/host_operations/host_club_profile.dart`
- `lib/hosts/presentation/payments/host_payment_account_card.dart`
- `lib/hosts/presentation/payments/host_payment_account_controller_card.dart`
- `lib/hosts/presentation/widgets/host_team_management_section.dart`
- `lib/hosts/presentation/widgets/host_organizer_payout_prompt.dart` (delete)
- `lib/hosts/presentation/widgets/host_organizer_payout_prompt_controller.dart`
  (delete)
- `lib/l10n/app_en.arb` plus generated localization output

Expected proof/registry scope:

- `test/hosts/host_operations_screen_test.dart`
- `test/hosts/host_team_management_section_test.dart`
- `test/ui_captures/catalog/screen_capture_catalog.dart`
- `widgetbook/lib/hosts/host_operations_use_cases.dart`
- `widgetbook/lib/main.directories.g.dart`
- `tool/design/check_section_headers.mjs`
- `tool/design/check_section_headers.test.mjs`
- `tool/tools_manifest.json`
- `docs/widget_catalog.md`
- `docs/agent_regression_ledger.json`
- relevant `docs/design_parity/widget_consolidation/**` and generated audit
  registries

Explicitly out of scope:

- Stripe backend/API behavior and Firestore payment-account contracts;
- host-team repository/controller mutation semantics;
- event creation/default persistence behavior;
- Host Event Manage, Insights, and Preview tab redesigns;
- the unrelated `CatchAnalyticsSection` scanner finding; and
- broad renaming of the Host app or the domain term `host`.

### Acceptance criteria

- The Edit tab renders one visible Payouts heading for owners and none for
  co-hosts.
- The Edit tab renders one visible Host team heading for both owners and
  co-hosts.
- Owners can still set up/continue/refresh payouts and add/remove/transfer team
  members.
- Co-hosts can read the full team roster but cannot see or invoke owner-only
  team mutations.
- Event defaults appears once and retains inline editing.
- Settings remains reachable once and has tooltip/semantics coverage.
- `HostOrganizerPayoutPrompt`, `HostOrganizerTeamCard`, and
  `HostOrganizerTeamRow` have zero active production references and are removed
  from Widgetbook/catalog/generated registries if deleted.
- Payment content/loading/error states use `CatchSection.contained` directly;
  no titled section is wrapped in another untitled section.
- `SECTION-HEADER-004` no longer reports
  `host_operations/host_organizer.dart`.
- The section-header scan may still report inherited `CatchAnalyticsSection`
  debt; this pass must not claim a globally clean scanner unless that separate
  finding is also resolved in scope.
- No dead localization messages or manually edited generated localization
  output remain.
- Focused captures or Widgetbook states confirm owner/co-host plus payout
  loading/error/setup/ready layouts in light and dark themes.

### Verification commands

Run Flutter processes sequentially:

```sh
node tool/agent/context_pack.mjs --task host-club-edit-consolidation --paths lib/hosts/presentation/host_operations/host_clubs_scaffold.dart,lib/hosts/presentation/host_operations/host_organizer.dart,lib/hosts/presentation/host_operations/host_club_profile.dart,lib/hosts/presentation/payments,lib/hosts/presentation/widgets/host_team_management_section.dart,test/hosts,widgetbook/lib/hosts,tool/design/check_section_headers.mjs,docs/widget_catalog.md
dart format <changed Dart files>
flutter gen-l10n
flutter analyze --no-fatal-infos <changed Dart files and focused tests>
flutter test --concurrency=1 test/hosts/host_operations_screen_test.dart test/hosts/host_team_management_section_test.dart
node --test tool/design/check_section_headers.test.mjs
node tool/design/check_section_headers.mjs --summary --max 100 --include-low
node tool/run.mjs check --manifest-only
node tool/check_enforcement_integrity.mjs
bash tool/widget_cleanup_scan.sh --summary
node tool/agent/check_agent_readiness.mjs
git diff --check
```

Also run the repo's required widget classification/Widgetbook/capture refresh
commands for every deleted public widget. Use the commands referenced by
`docs/design_parity/widget_consolidation/codex_worklog.md`; do not hand-edit
generated registry JSON to make checks pass.

### Current scanner baseline

At handoff creation, `design:section-headers` scans 1,043 Dart files and reports:

- high: `CatchAnalyticsSection` parallel kicker shell (inherited/out of scope);
- high: Host Organizer Manage standalone header + untitled contained section;
- medium: zero; and
- low: six `showHeader`/`showTitle` inventory items.

The scanner unit suite has ten passing tests, including the known-bad Manage
fixture. The aggregate `node tool/run.mjs check design:section-headers` command
is expected to remain non-zero until all high findings are resolved; the focused
Host pass should prove that the Host finding disappears without hiding the
analytics finding.

### Implementation receipt

- `HostClubOrganizerOverview` now owns only format badges and club metrics.
- `HostPaymentAccountControllerCard` remains the single payout provider owner;
  loading, error, setup, pending, restricted, and ready presentations each own
  one direct titled `CatchSection.contained` composition.
- `HostTeamManagementSection` now receives explicit `canManage` capability,
  renders the full roster for owners and co-hosts, and hides add/remove/transfer
  controls for co-hosts.
- Host Settings is reachable from one semantic, tooltip-backed top-bar action.
- `HostOrganizerPayoutPrompt`, `HostOrganizerTeamCard`, and
  `HostOrganizerTeamRow` have zero active Dart references; the prompt source
  files, obsolete localization messages, catalog entries, and Widgetbook use
  cases were removed.
- The widget-consolidation decision ledger now records the removed prompt/team
  summaries as executed deletions while retaining controller/display separation
  for the canonical payout section.
- `SECTION-HEADER-005` adds the requested medium-advisory card-shell guard and
  known-bad/known-good fixtures. The Host organizer finding is gone; the one
  remaining high finding is the explicitly out-of-scope inherited
  `CatchAnalyticsSection` finding.
- Focused Host tests pass (52 tests), focused root analysis has no errors or
  warnings, scanner fixtures pass (12 tests), mobile copy and tool-manifest
  checks pass, and widget similarity/dedupe checks pass.
- Generated Widgetbook directory output contains the new owner/co-host and
  payout-state use cases and no removed-symbol references. A repository-wide
  Widgetbook rebuild/analyzer remains blocked by unrelated existing drift in
  `widgetbook/lib/primitives/core_catalog_use_cases.dart` and broader Host
  Operations preview APIs.
- Repository-wide enforcement and provider-graph checks retain unrelated
  pre-existing doc-anchor/reverse-binding findings and four Explore provider
  review candidates; none reference this Host consolidation.
- A fresh `host-prod` Simulator build launched in the existing logged-in
  session. Live inspection confirmed one Event defaults group, one Payouts
  section, one Host team section, and a single semantic Settings action that
  opens the Host Settings workspace.

## Current Surface Catalog

| Surface | File | Scope | Current actions | Cardinality | Current issues |
| --- | --- | --- | --- | --- | --- |
| Dashboard host tools rail | `lib/dashboard/presentation/widgets/dashboard_full.dart` (`HostToolsRail`) | Per hosted event | Manage event, Take attendance, View report | Unbounded hosted events | Uses shared `HostEventToolsCarousel`; Dashboard owns route navigation only. The host card is self-contained, with in-card identity, lifecycle state, bounded progress, and a contextual CTA. |
| Dashboard host tools model | `lib/dashboard/presentation/dashboard_full_view_model.dart` (`DashboardHostEventTool`) | Per hosted event | Uses `HostEventAttendanceState`, keeps non-cancelled past hosted events, and separates active from past operations | Unbounded hosted events | Dashboard owns composition and routing only. Attendance-window rules now live in `lib/hosts/domain/host_attendance_window.dart`. |
| Host app club management panel | `lib/hosts/presentation/host_operations_screen.dart` and `lib/hosts/presentation/widgets/host_club_tools.dart` | Per club | Add event, Edit club profile, payouts, host team | One owned club by current product rule; co-hosted clubs are separate rows | Public club detail is presentation-only. Host app Clubs owns profile edits, payouts, and host-team management; Host app Events owns event creation. |
| Club schedule section | `lib/clubs/presentation/detail/widgets/club_schedule_section.dart` | Per event in hosted club context | Hosted badge and event detail navigation | Unbounded upcoming events | Resolved for first pass: host-owned events use the `HOSTED` tile state without turning schedule rows into dense control clusters. Deeper operations remain in Dashboard / Host Manage. |
| Event detail top actions | `lib/events/presentation/widgets/event_detail_body.dart` and detail app bar widgets | Per event | Share, save, add to calendar for future signed-up or hosted events | Singleton per event | Top actions stay generic utilities. Host operations intentionally route through Dashboard and Host Manage instead of adding another detail-page host section. |
| Event detail bottom CTA | `lib/events/presentation/widgets/event_detail_cta.dart` | Per event | Participant booking/waitlist/cancel states for non-host viewers | Singleton per viewer/event | Hosts no longer render this bottom footer. This keeps event detail from duplicating host tools that already exist on Dashboard and Host Manage. |
| Host event manage route | `lib/routing/go_router.dart` and `lib/hosts/presentation/host_event_manage_screen.dart` (`HostEventManageRouteScreen`) | Per event | Host-gated route load and access check, optional lifecycle section | Singleton per event | Canonical route is `/clubs/:clubId/events/:eventId/manage`. Dashboard, event-success, and attendance paths are aliases into the same workspace with the relevant lifecycle section selected. |
| Host event manage screen | `lib/hosts/presentation/host_event_manage_screen.dart` (`HostEventManageScreen`) | Per event | Setup, Live, Report sections, Edit event action | Singleton per event | Lifecycle workspace with a full-width segmented switcher. Setup combines event details/admin, event-success setup, and the read-only participant roster; Live combines check-in mutation with event-success live mode; Report combines attendance summary with the post-event host report. |
| Host edit event route | `lib/hosts/presentation/edit_hosted_event_screen.dart` (`EditHostedEventRouteScreen`) | Per event | Host-gated published-event edit form | Singleton per event | Edits backend-supported operational fields from one place. Schedule and booking-policy controls lock once the event starts or has booking/waitlist/attendance activity. |
| Create-event success handoff | `lib/hosts/presentation/event_management/create/create_event_success_screen.dart` and `create_event_screen.dart` | Newly created event | Manage event, Back to club | Singleton immediately after creation | Manage event now routes to canonical Host Manage instead of embedding a second management screen inside the create flow. |
| Event tile hosted status | `lib/events/presentation/widgets/event_tiles/event_tile_data.dart` and event tile atoms | Per event tile | `EventTileStatus.hosted` badge | Per tile | Existing hosted status can identify owned events, but it does not unlock host actions. This should feed into the same host action model instead of one-off tile affordances. |

## Backend-Ready Host Actions

| Action | Backend status | Current UI status | Proposed UI treatment |
| --- | --- | --- | --- |
| Create event | Implemented through `createEvent` | Exposed from Host app Events rows and the host create-event flow | Keep as an Events-tab action for the selected club; avoid duplicating it on public club detail. |
| Edit club | Implemented through `updateClub`/club repository update seam | Exposed from Host app Clubs rows | Keep as a Clubs-tab action with payout and host-team management; avoid duplicating it on public club detail. |
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
  unbounded hosted events. The card owns host identity, attendance lifecycle,
  position/progress, and one contextual CTA so Dashboard can compose it without
  separate section header/footer chrome.
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

- Dashboard: use self-contained full-width snapping host event cards with
  in-card bounded progress indicators, parallel to `EventFocusRail` but visually
  host-specific.
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
- [x] Consolidate Host Clubs Edit payout, team, defaults, and Settings ownership
  under `HOST-CLUB-EDIT-CONSOLIDATION-001`.

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
- TODO `HOST-MANAGE-UNSAVED-STARTED-EDITOR-001`: Host Manage currently keeps
  the disabled event-success setup editor visible when an event has started
  without a saved live guide so QA can still inspect the default plan. After
  the setup/live/report states are fully tested, hide the editor in this state
  and show only the explanatory locked notice plus attendance/report surfaces.
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
- 2026-07-16: Implemented `HOST-CLUB-EDIT-CONSOLIDATION-001`, removed duplicate
  payout/team/Manage surfaces and dead copy, added explicit co-host read-only
  team behavior and a single Settings action, regenerated localization and
  design/provider registries, reconciled the widget decision ledger/catalog,
  and added section-shell enforcement.
- 2026-07-16: Verified 52 focused Host tests, focused root analysis with no
  errors or warnings, 12 section-header scanner tests, zero active removed
  symbol references, mobile copy, tool manifest, widget similarity, and widget
  cleanup checks. Unrelated repository-wide Widgetbook, enforcement-integrity,
  provider-review, and audit-queue findings remain recorded rather than being
  misreported as part of this pass.
- 2026-07-16: Built and launched `host-prod` on the booted iPhone 17 Pro Max
  without disturbing the consumer target. The signed-in session persisted;
  live UI inspection confirmed the consolidated section order and the Settings
  action routed to the Host Settings workspace.

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
