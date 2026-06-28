---
doc_id: design_parity_todo
version: 0.2.85
updated: 2026-06-22
owner: product_design_parity
status: active
---

# Design Parity Todo

This is the working backlog for migrating Catch screens toward the design
contracts. It should stay grounded in:

- `design/screens/screen_coverage.json`
- `design/screens/catch.screens.json`
- `docs/design_parity/state_matrix.json`
- `design/components/catch.components.json`
- `widgetbook/`
- `tool/ui_capture/route_inventory.json`
- `tool/ui_capture/capture_coverage.json`

The canonical execution checklist is now
`docs/design_parity/comprehensive_todo.md`. Keep this file as the detailed
working backlog and historical evidence trail; do not add another duplicated
master todo section here.

## Current Snapshot

- Route inventory: 48 app routes.
- Screen contract coverage: 40 contracted route entries, 2 alias route entries, 0 planned route entries, and 6 excluded route entries.
- Capture coverage: 199 capture entries across 37 captured route entries, 5 alias route entries, 0 planned route entries, and 6 excluded route entries.
- Screen contracts: 35 (`screen.event.detail`, `screen.club.detail`, `screen.explore.discovery`, `screen.dashboard.home`, `screen.event_success.companion`, `screen.catches.hub`, `screen.catches.event`, `screen.matches.list`, `screen.matches.chat`, `screen.profile.self`, `screen.profile.public`, `screen.host.home`, `screen.host.clubs`, `screen.host.club.detail`, `screen.host.event.create`, `screen.host.event.manage`, `screen.host.inbox`, `screen.host.chat`, `screen.start.welcome`, `screen.auth.phone_entry`, `screen.onboarding.flow`, `screen.calendar.home`, `screen.saved_events.list`, `screen.filters.preferences`, `screen.event.recap`, `screen.host.club.create`, `screen.host.club.edit`, `screen.host.event.edit`, `screen.host.settings`, `screen.host.profile`, `screen.event.location_map`, `screen.notifications.list`, `screen.reviews.history`, `screen.settings.account`, `screen.payments.history`).
- Screen contract sections: 240.
- Contracted screen states: 589.
- Design parity matrix: 12 features, 36 screens, 582 states, and 98 open
  matrix gaps: 86 screen-state gaps, 6 lint-candidate gaps, and 6 preview-plan
  gaps.
- Design references: 34 exported references across 26 screens are registered in
  `design/reference_screens/manifest.json`; 9 contracted screens still have no
  canonical exported reference, with additional state variants still open on
  screens that already have a first baseline.
- Key interpretation: every current product route is now contracted, aliased, or explicitly excluded. The remaining work is no longer route inventory; it is moving contracted screens toward adapter-owned state, section composition, Widgetbook previews, deterministic captures, design-reference exports, pixel comparison, and drift prevention.

## How To Work This List

1. Work the Immediate Ordered Backlog first unless a dependency is blocked.
2. Treat screen coverage, capture coverage, Widgetbook coverage, and component contracts as separate ledgers that must eventually agree.
3. Do not mark a screen done because it has a capture; a done screen has a contract, state matrix entries, registered sections, previews/captures, tests, and scanner proof.
4. Keep sections screen-local until reuse is proven by a second screen; promote only the provider-free, data-adapter-driven pieces.
5. Update this file, `docs/widget_catalog.md`, the JSON registries, and audit receipts in the same pass when inventory changes.

## Comprehensive Todo List

This is the control checklist for the design-parity program. The long
screen-by-screen notes below remain the evidence trail; use these ids when
planning and stamping future passes.

### 0. Current Operating Queue

- [x] `DPT-NEXT-001` Finish Dashboard Home first-pass Widgetbook coverage.
  - Include profile loading/error, empty start, full dashboard, booked-events
    loading/error, recommendations loading/error, text scale, reduced motion,
    and light/dark review states.
  - Register `DashboardScreen` preview ids in `catch.screens.json` and
    `state_matrix.json`.
  - Verify with Widgetbook generation, Dashboard tests, design parity gate,
    analyzer, scanner, and audit stamping.
- [x] `DPT-NEXT-002` Fill remaining P1 first-pass Widgetbook screen/route gaps
  before visual refactors.
  - Dashboard Home, Event Success Companion, Catches hub/event deck, Matches
    list/chat, Profile/Public Profile, and Host Operations now have first-pass
    Widgetbook coverage. Remaining Widgetbook work is section-specific,
    provider-free coverage after the relevant adapters exist.
- [ ] `DPT-NEXT-003` Add deterministic captures for the highest-risk P1 states.
  - Cover loading, populated, empty, error, offline, access/permission,
    mutation pending/failure, text scale, reduced motion, and paired theme
    states before layout polishing.
  - Host Operations now has registered baseline captures for Host Home, Host
    Clubs, Host Club Detail, Host Event Manage setup/private access, Host
    Inbox, and Host Chat; remaining host capture work is variant coverage.
  - Dashboard Home now has route captures for booked-events loading, profile
    error, offline, membership error, booked-events error, empty start,
    self-check-in open/pending/error, after-event focus, recommendations
    loading/error, text scale 2.0, and reduced motion.
    DashboardHomeScreenState now owns route loading/error/empty/full branch
    selection, so profile, membership, and booked-event loading waves share one
    captured loading shell.
  - Explore Discovery now has route captures for loading, source-club error,
    feed error, empty city, no-search, active search, active filters, text
    scale 2.0, reduced motion, map loading, and map error. Remaining Explore
    capture work is signed-in joined clubs, filter-empty/no-filter states,
    explicit offline copy, unclaimed host projection, selected-pin/distance-ring
    map variants, and exported design-reference comparison.
  - Catches hub/deck now have route captures for hub uid loading/error,
    signed-out hidden, attended-events loading/error, empty, text scale 2.0,
    reduced motion, deck queue loading/error/offline, empty queue, missing
    event, sign-in required, in-progress, did-not-attend, closed-window, deck
    text scale 2.0, and deck reduced motion. The Catches route widgets now
    accept an optional pinned `now` for deterministic time-sensitive previews
    and captures.
  - Matches List/Chat now have route captures for list loading/error/offline,
    no matches, search open/empty, duplicate collapse, match celebration, text
    scale 2.0, reduced motion, chat message loading/error/offline, empty
    thread, event-context fallback, missing and blocked chat, image thread,
    Suvbot controls/error, share-card sheet, composer states, chat text scale
    2.0, chat reduced motion, and host unread empty. Remaining Matches/Chat
    capture work is interaction-driven send/report/block mutation proof,
    keyboard-open snapshots, additional state references, and pixel comparison.
  - Profile/Public Profile now have route or section captures for self-profile
    loading/error/offline/unavailable, edit tab, preview tab, upload pending,
    text scale 2.0, reduced motion, public-profile loading, initial-profile
    fallback, load error, offline, unavailable, own profile, pending overlay,
    report sheet, block confirmation, public text scale 2.0, and public
    reduced motion. Remaining Profile/Public capture work is upload
    failure/delete/reorder, inline save pending/error drawers, settings
    navigation proof, selected report reason, mutation success/failure snackbar
    proof and advisory pixel comparison.
- [ ] `DPT-NEXT-004` Export canonical Claude/Figma references and wire advisory
  pixel comparison.
  - Dashboard Home now has full and empty Claude references exported under
    `design/reference_screens/screen.dashboard.home` and advisory comparison
    tooling in `tool/design/check_reference_screens.mjs`.
  - Event Detail member, Explore feed, and Club Detail member references are
    exported, masked, registered, and compared against design-phone captures.
  - Profile self edit/preview and Public Profile references are exported,
    masked, and registered for advisory comparison.
  - Matches list/thread, Host Home Today, Host Clubs Organizer, and Host Inbox
    references are exported, masked, manifest-registered, and compared against
    design-phone captures.
  - Host Event Manage setup/private-access, live console, and post-event report
    references are exported, masked, manifest-registered, and compared;
    attendance/guests and private-access edge variants remain.
  - Host Create Event basics, location, schedule, policy, and Event Success
    guide references are exported, masked, manifest-registered, and compared
    against deterministic captures; Host Events tab is still exported on disk
    only because a matching route capture id is not in place.
  - Host Club Create basics, Host Club Edit owner edit, Host Event Edit
    prefilled event, Notifications Activity, and Settings Account references
    are exported, masked, manifest-registered, and wired into advisory
    comparison.
  - Auth Phone, Onboarding Welcome, and Filters default references are exported,
    masked, and manifest-registered; Auth and Onboarding remain partially open
    because OTP/deeper-step references still need export.
  - Start Welcome landed direct reference is exported from the splash/welcome
    handoff, masked, manifest-registered, and wired to `start_welcome`;
    animated reel, reduced-motion, text-scale, and alternate theme variants
    remain.
  - Host Club Detail owner/public-view reference is exported, masked,
    manifest-registered, and wired to `host_club_detail_public`.
  - Catches Event Deck active-profile reference is normalized from the Claude
    website app screenshot asset, masked, manifest-registered, and wired to
    `post_run_catch_window`; mutation, keyboard/comment sheet, empty/offline,
    accessibility, and theme variants remain.
  - Event Success Companion default live guide reference is exported, masked,
    manifest-registered, and wired to `event_success_companion`; stage, reveal,
    afterglow, feedback, accessibility, and theme variants remain.
  - Host Chat populated thread now has a shared Messaging-thread baseline
    reference exported, masked, manifest-registered, and wired to
    `host_chat_inquiry`; dedicated professional host-chat variants remain.
  - Continue with Catches Hub, remaining Catches Event Deck variants, remaining
    Matches/Chat state variants, Host Settings/Profile references, and remaining
    secondary/utility references because they have the broadest remaining design
    surface and state risk. Host Settings now has active, fallback,
    no-profile, profile loading/error, and clubs loading/error route captures;
    Host Profile now has populated, loading, error, and missing-profile route
    captures. Their remaining work is editor/mutation/accessibility/theme
    capture coverage, adapters, Widgetbook states, and design references.
- [ ] `DPT-NEXT-005` Keep the newly covered P3 utility Widgetbook states from
  regressing while shifting effort back to P1/P2 surfaces.

### 1. Source Of Truth And Registry Hygiene

- [x] `DPT-SOT-001` Generate route inventory from app routing.
- [x] `DPT-SOT-002` Require every generated app route to have a coverage
  decision: contracted, alias, planned, or excluded.
- [x] `DPT-SOT-003` Register every current product route in
  `design/screens/screen_coverage.json`.
- [x] `DPT-SOT-004` Register every current product screen contract in
  `design/screens/catch.screens.json`.
- [x] `DPT-SOT-005` Keep `docs/design_parity/state_matrix.json` as the user
  visible state ledger.
- [x] `DPT-SOT-006` Keep `npm run design:parity:check` as the aggregate local
  design gate.
- [x] `DPT-SOT-007` Add a route-coverage review note to the new-route workflow
  so new routes cannot ship without an explicit coverage decision.
- [x] `DPT-SOT-008` Decide whether the router enum/source should gain richer
  design metadata, or whether generated inventory plus coverage JSON remains
  the right boundary.
  - Decision: keep the router as the path inventory source only. Rich design
    metadata belongs in the portable `design/screens` and
    `docs/design_parity` ledgers.
- [ ] `DPT-SOT-009` Keep `catch.screens.json`, `screen_coverage.json`,
  `state_matrix.json`, `capture_coverage.json`, generated Widgetbook ids,
  `docs/widget_catalog.md`, and this tracker synchronized in every parity pass.
- [ ] `DPT-SOT-010` Revisit alias and excluded routes quarterly, or whenever a
  dev/lab/manual QA route becomes product-facing.

### 2. Screen State Contracts

- [ ] `DPT-STATE-001` For every contracted screen, enumerate default,
  populated, loading, empty, error, offline, access/permission, mutation,
  light/dark theme, text-scale, and reduced-motion states where meaningful.
- [ ] `DPT-STATE-002` For every detail route, explicitly record missing route
  params, missing documents, deleted resources, unauthorized access, and
  initial-data fallback states.
- [ ] `DPT-STATE-003` For chat-like surfaces, record keyboard, composer,
  message loading/error, send pending/failure, attachment, blocked, report,
  safety, read-marker, and empty-thread states.
- [ ] `DPT-STATE-004` For create/edit surfaces, record validation,
  disabled-submit, draft, image/file picker, mutation pending/failure, success,
  cancel/exit, and permission states.
- [ ] `DPT-STATE-005` For host/member/guest/owner/private variants, record the
  role-specific state and required copy instead of relying on generic UI.
- [ ] `DPT-STATE-006` Mark each state as planned, implemented, previewed,
  captured, tested, ready, blocked, or intentionally excluded with proof refs.

### 3. Widgetbook Coverage

- [x] `DPT-WB-001` Set up Widgetbook as the review surface for Catch primitives.
- [x] `DPT-WB-002` Add first-pass Widgetbook coverage for the core component
  catalog and generated contract refs.
- [x] `DPT-WB-003` Add first-pass P3 utility Widgetbook coverage for Event
  Location Map, Notifications, Reviews History, Settings, and Payment History.
- [x] `DPT-WB-004` Add explicit interactive P3 utility fixtures for
  `WriteReviewSheet`, `CatchConfirmDialog`, `PaymentReceiptSheet`, and Settings
  mutation pending/error states.
- [x] `DPT-WB-005` Create the shared utility/account design fixture seam under
  `lib/labs/design_fixtures`.
- [x] `DPT-WB-005A` Add first-pass P1 Host Operations Widgetbook route/state
  coverage for Host Home, Host Clubs, Host Club Detail, Host Create Event,
  Host Event Manage, Host Inbox, and Host Chat through shared host fixtures.
- [x] `DPT-WB-006` Represent every reusable primitive in
  `design/components/catch.components.json` with every meaningful contract
  state in Widgetbook.
  - Proof: the formal primitive contract previews cover all 10 component
    contracts, and `tool/design/check_widgetbook_contract_refs.mjs` now
    compares preview state lists against `design/components/catch.components.json`.
- [ ] `DPT-WB-007` Represent every contracted screen section in Widgetbook when
  that section has meaningful visual states.
- [ ] `DPT-WB-008` Reuse fakes and fixture data between Widgetbook and route
  captures wherever practical.
- [ ] `DPT-WB-009` Add reusable fixture states for loading, empty, error,
  offline, permission denied, unauthorized, mutation pending, mutation failure,
  missing route params, missing documents, deleted resources, and partial data.
- [ ] `DPT-WB-010` Keep generated Widgetbook directories synchronized after
  adding, renaming, or deleting use cases.
- [ ] `DPT-WB-011` Keep contract `previewIds` resolvable in generated
  Widgetbook directories.
- [ ] `DPT-WB-012` Add text-scale, reduced-motion, and light/dark review
  coverage for high-risk primitives, animated surfaces, maps, and all P1
  sections.

### 4. UI Captures And Pixel Comparison

- [x] `DPT-CAP-001` Keep capture coverage separate from screen contract status.
- [x] `DPT-CAP-002` Register the route and capture gate in the aggregate parity
  check.
- [x] `DPT-CAP-003` Keep `tool/ui_capture/capture_coverage.json` exhaustive for
  every generated route.
  - Proof: `node tool/ui_capture/check_capture_coverage.mjs --check --summary`
    validates all 48 generated routes have a capture decision.
- [ ] `DPT-CAP-004` Add deterministic route captures for P1 loading,
  populated, empty, error, offline, access/permission, mutation, text-scale,
  reduced-motion, and paired theme states.
- [ ] `DPT-CAP-005` Add P2/P3 captures when the state is hard to reach manually
  or likely to drift.
- [ ] `DPT-CAP-006` Store canonical design references under
  `design/reference_screens/`.
- [ ] `DPT-CAP-007` Define pixel-diff masks for status bars, safe areas, maps,
  timestamps, remote photos, generated counters, live counts, dynamic
  recommendations, keyboards, snackbars, sheets, dialogs, and animation frames.
- [ ] `DPT-CAP-008` Add advisory pixel comparison between local captures and
  exported references.
- [ ] `DPT-CAP-009` Promote selected pixel checks to blocking only after repeated
  advisory runs prove fixtures, masks, image sources, and thresholds are stable.

### 5. Screen Composition Migration

- [ ] `DPT-COMP-001` For every screen pass, identify route widget, provider
  reads, controller ownership, mutation owners, private widgets, tests,
  captures, Widgetbook entries, and contract gaps before visual edits.
- [ ] `DPT-COMP-002` Add a route-level screen state adapter/view model before
  visual refactors.
- [ ] `DPT-COMP-003` Keep route widgets responsible for routing, provider
  orchestration, state selection, and section composition only.
- [ ] `DPT-COMP-004` Move repository writes, mutation branching, permission
  decisions, product validation, and side effects into controllers or
  feature-owned providers.
- [ ] `DPT-COMP-005` Keep visual sections provider-free where practical; pass
  immutable display data and typed callbacks instead of repositories.
- [ ] `DPT-COMP-006` Keep list/profile/event/club display-only data behind
  batched feature seams instead of per-tile streams or sequential reads.
- [ ] `DPT-COMP-007` Promote private widgets to reusable sections/components
  only after reuse is proven by a second surface or the design language needs a
  stable named role.
- [ ] `DPT-COMP-008` Keep one-screen layout glue private when it is not a design
  primitive.

### 6. Component, Token, And Cross-Surface Design Data

- [x] `DPT-DS-001` Keep reusable component contracts in
  `design/components/catch.components.json`.
- [x] `DPT-DS-002` Keep portable foundation tokens in
  `design/tokens/catch.tokens.json`.
- [x] `DPT-DS-003` Keep Flutter implementation of tokens/theme under
  `lib/core/theme`.
- [ ] `DPT-DS-004` Reconcile every Claude Design primitive against Flutter
  source, component contracts, Widgetbook entries, and
  `docs/design_parity/claude_widgetbook_inventory.md`.
- [ ] `DPT-DS-005` Classify every local Flutter primitive absent from Claude
  Design as keep, rename, deprecate, or needs-design-review.
- [ ] `DPT-DS-006` Replace screen-local hard-coded spacing, color, radius,
  typography, icon sizing, motion, and layout constants with tokens, theme
  roles, or registered component APIs.
- [ ] `DPT-DS-007` Decide website and social-template token export needs before
  adding Flutter-only token categories.
- [ ] `DPT-DS-008` Evaluate DTCG/W3C design-token compatibility before adding a
  parallel token pipeline or generator.
- [ ] `DPT-DS-009` Create `design/sections/catch.sections.json` only if repeated
  cross-screen section contracts outgrow screen-local sections.

### 7. Feature Queues

- [ ] `DPT-P1-001` Dashboard Home: keep first-pass Widgetbook states and
  deterministic captures current, then finish remaining provider-free section
  display-data seams. Baseline full and empty Claude references now live under
  `design/reference_screens/screen.dashboard.home`, and advisory comparison is
  wired through `tool/design/check_reference_screens.mjs`.
  The joined-clubs rail now uses the batched
  `watchClubsByIdsProvider` seam instead of one club stream per tile, and
  QuickActions now receives typed route callbacks from the composing Dashboard
  body instead of owning route pushes. EventFocusRail and
  DashboardStrideSection now receive typed actions and display-only mutation or
  busy state from `DashboardFullSliverBody`.
- [ ] `DPT-P1-002` Event Success Companion: keep first-pass Widgetbook route
  and screen states current, add deterministic captures for every attendee
  stage, keep runtime decisions in `EventSuccessRuntime`, add a route adapter,
  and mask countdowns/animations/profile imagery.
- [ ] `DPT-P1-003` Catches hub/event deck: add Widgetbook/capture states for hub
  windows, deck queue, reactions, comment sheet, access states, mutation
  failures, clocks, and profile imagery.
- [ ] `DPT-P1-004` Matches list/chat: preserve first-pass Widgetbook states,
  then add captures for list filters, unread/new matches, thread
  loading/error, composer, send failures, blocked/report flows, keyboard, and
  chat-specific adapters.
- [ ] `DPT-P1-005` Profile/self and Public Profile: preserve first-pass
  Widgetbook states and deterministic route captures, then add remaining
  interaction captures for upload failure/delete/reorder, inline save
  pending/error drawers, settings navigation, selected report reason, mutation
  success/failure snackbars, profile adapters, and advisory pixel comparison.
- [ ] `DPT-P1-006` Host Home: preserve first-pass Widgetbook route states, then
  add captures, provider-free section previews, host-shell fixtures, and a host
  home adapter.
- [ ] `DPT-P1-007` Host Clubs: preserve first-pass Widgetbook route states, then
  add captures and provider-free section previews for profile editor, inline
  editors, payouts, team management, insights, preview, host roles, mutation
  failures, analytics fixtures, and a host clubs adapter.
- [ ] `DPT-P1-008` Host Club Detail: preserve first-pass Widgetbook public
  preview states, then add captures and adapter seams for hosted schedule, host
  role/access states, missing/error/offline, and host-detail routing.
- [ ] `DPT-P1-009` Host Create Event: preserve first-pass Widgetbook route and
  wizard states, then add captures and provider-free previews for validation,
  drafts, mutations, success, and a create-event adapter.
- [ ] `DPT-P1-010` Host Event Manage: preserve first-pass Widgetbook route and
  section states, then add captures and provider-free previews for setup,
  private access, invite links, roster, live console, Event Success host tools,
  report workspace, cancel/delete mutations, aliases, and a manage adapter.
- [ ] `DPT-P1-011` Host Inbox and Host Chat: preserve first-pass Widgetbook
  host inbox/chat states, then add captures and provider-free previews for host
  inquiry rows, filters/search, duplicate inquiries, event context, composer,
  blocked/report flows, keyboard, offline, and host-mode adapters.
- [ ] `DPT-P2-001` Start/Auth/Onboarding: add Widgetbook/capture states for reel
  variants, phone/OTP flows, validation, resend cooldown, onboarding steps,
  photo gates, upload mutations, flow-entry modes, and design references.
- [ ] `DPT-P2-002` Calendar/Saved Events/Filters/Event Recap: add
  Widgetbook/capture states for provider waves, empty/error/offline states,
  draft/selection state, save mutations, partial lookup failures, and adapters.
- [ ] `DPT-P2-003` Host create/edit club, edit event, host settings, and host
  profile: add Widgetbook/capture states for form validation, image replacement,
  unauthorized/missing resources, payouts/admin placeholders, profile mutation
  flows, and adapters.
- [ ] `DPT-P3-001` Event Location Map: preserve first-pass Widgetbook coverage,
  keep deterministic capture variants current, add exported pixel masks for map
  tiles and coordinate/no-coordinate states, introduce the route-state adapter,
  and keep map failures branded.
- [ ] `DPT-P3-002` Notifications: preserve route/row Widgetbook coverage, add
  deterministic captures for read/unread/deep-link/error states, and reuse
  shared activity fixtures.
- [ ] `DPT-P3-003` Reviews History: preserve route and `WriteReviewSheet`
  Widgetbook coverage, add deterministic captures for list/empty/error/missing
  event/edit states, and keep review sheet provider-free.
- [ ] `DPT-P3-004` Settings: preserve account/preferences/privacy/blocked and
  mutation Widgetbook coverage, add deterministic captures for destructive
  dialogs and pending/error paths, and keep safety/account actions controller
  owned.
- [ ] `DPT-P3-005` Payment History: preserve route and receipt Widgetbook
  coverage, add deterministic captures for status rows, empty/error states,
  failed-signup help, and receipt sheet variants.

### 8. Drift Prevention And CI

- [x] `DPT-DRIFT-001` Validate route inventory, capture coverage, screen
  coverage, screen contracts, state matrix, Widgetbook refs, component
  contracts, and advisory hygiene in one local gate.
- [x] `DPT-DRIFT-002` Add scanners for screen-contract hygiene, Widgetbook ref
  resolution, and component-contract/Widgetbook parity.
- [x] `DPT-DRIFT-003` Fail on new product routes without screen and capture
  coverage decisions.
  - Proof: Flutter CI now runs `npm run design:parity:check`, and the matrix
    validator fails when a screen contract is not represented in the design
    parity matrix.
- [x] `DPT-DRIFT-004` Compare component contracts against generated Widgetbook
  use cases and fail once the baseline is stable.
- [ ] `DPT-DRIFT-005` Add or tighten advisory checks for contracted screens that
  import raw Material controls or add one-off visual constants.
- [ ] `DPT-DRIFT-006` Promote high-signal UI invariants into
  `packages/catch_ui_lints` after known false positives are resolved.
- [ ] `DPT-DRIFT-007` Keep broad scanners advisory until existing violations are
  fixed, intentionally allowed, or documented with stable ids.

### 9. Verification Cadence

- [ ] `DPT-CADENCE-001` Work one feature pair or one host surface per pass.
- [ ] `DPT-CADENCE-002` Update coverage JSON, screen contracts, state matrix,
  Widgetbook/capture entries, docs, tests, and audit receipts together.
- [ ] `DPT-CADENCE-003` Run Widgetbook code generation whenever annotated
  Widgetbook use cases change.
- [ ] `DPT-CADENCE-004` Verify each pass with `npm run design:parity:check`,
  focused Flutter tests, focused analyzer with `--no-fatal-infos`, JSON syntax
  checks where relevant, `git diff --check`, and relevant scanners.
- [ ] `DPT-CADENCE-005` Stamp touched files in the audit registry before
  finalizing the pass.
- [ ] `DPT-CADENCE-006` Keep follow-up gaps in this tracker, not chat history.

### 10. Definition Of Done

A screen is done when all of these are true:

- [ ] Route is present in `design/screens/screen_coverage.json` with the correct
  status, priority, screen id, and reason.
- [ ] Screen is present in `design/screens/catch.screens.json` with routes,
  owner, priority, source, controller/state ownership, states, captures,
  composition sections, dependencies, and open gaps.
- [ ] Screen states cover meaningful loading, populated, empty, error, offline,
  permission/access, mutation pending/failure, theme, text scale, reduced
  motion, and role-specific variants.
- [ ] Route widget owns navigation and state orchestration only.
- [ ] Visual structure is delegated to predefined sections/components.
- [ ] Sections depend on registered primitives/tokens instead of raw Material
  controls or one-off visual values.
- [ ] Widgetbook includes useful primitive/section previews for hard-to-reach
  states and all contract `previewIds` resolve.
- [ ] UI capture catalog includes deterministic full-screen captures for the
  highest-risk states.
- [ ] Tests cover controller/adapters and critical UI state transitions.
- [ ] Pixel comparison is advisory or ready once exported references and masks
  exist.
- [ ] Drift-prevention scanners pass or record stable, intentional advisory
  findings.
- [ ] `docs/widget_catalog.md`, design parity docs, and audit registry receipts
  are updated in the same pass.

## Current Remaining Todo

This is the execution queue from the current registry state.

1. Add Widgetbook coverage for contracted sections and adapters.
   - Prioritize P1 surfaces; the newly contracted P3 utility surfaces now have first-pass Widgetbook coverage registered in contracts and the state matrix.
   - Event Location Map, Notifications, Reviews History, Settings destructive dialogs/mutations, and Payment History now have registered Widgetbook coverage.
   - Cover default, loading, empty, error, permission, mutation, text-scale, light/dark, and reduced-motion states where meaningful.
2. Add deterministic UI captures for high-risk states.
   - Prioritize P1 screens, then P2 states that are hard to reach manually.
   - Share fixture data with Widgetbook where practical.
3. Export canonical Claude/Figma references and wire advisory pixel comparison.
   - Store references under `design/reference_screens/`.
   - Add masks for status bars, maps, timestamps, remote photos, generated counters, live counts, keyboards, and animation frames.
4. Reconcile component and token inventory across Claude Design, Flutter, Widgetbook, and cross-surface design data.
   - Keep portable tokens in `design/tokens/catch.tokens.json`.
   - Keep Flutter implementation in `lib/core/theme`.
   - Track keep/rename/deprecate/design-review decisions for local primitives absent from Claude Design.
5. Tighten drift prevention once baselines are stable.
   - Keep failing on new product routes without coverage decisions through
     Flutter CI's design parity gate.
   - Fail on contract `previewIds` that do not resolve in Widgetbook.
   - Promote high-signal UI invariants into `packages/catch_ui_lints` when false positives are resolved.

## Execution-Ready Todo

Use this as the concrete working order. The lower sections keep the exhaustive
ledger; this list is the queue for the next design-parity passes.

1. Maintain Widgetbook coverage for the newly contracted P3 utility surfaces while moving to captures/adapters.
   - Event Location Map has registered route/map states for loading, route error, event missing, no coordinate, pinned location, network tiles disabled, and addon-driven text scale, reduced motion, and light/dark review.
   - Notifications has registered ActivityScreen, ActivitySection, and NotificationRow states for loading, empty, error, read/unread rows, mark-all-read, row targets, long copy, and addon-driven text scale, reduced motion, and light/dark review. Route captures now cover uid loading, signed-out, activity loading/error/empty, populated rows, text scale 2.0, reduced motion, and paired light/dark output; mark-all-read pending/error and deep-link failure remain adapter/UI work.
   - Reviews History now has a `ReviewsHistoryState` adapter seam plus deterministic route captures for signed-out, profile loading/error, reviews loading/error, empty, populated rows, missing event-context fallback, text scale, reduced motion, and light/dark; explicit `WriteReviewSheet` write/edit fixtures remain the sheet review surface.
   - Settings now has destructive `CatchConfirmDialog` fixtures and `SettingsScreen` mutation pending/error fixtures beyond the account, preference, privacy, and blocked-account states.
   - Payment History now has explicit route captures for uid loading/error, signed-out, payment loading/error, empty, populated mixed-status rows, missing-title fallback, text scale, reduced motion, and light/dark; receipt-sheet/support-action proof remains open.
2. Create shared Widgetbook/capture fakes for utility and account surfaces.
   - `lib/labs/design_fixtures/utility_surface_fixtures.dart` now owns the shared utility/account fixture seam for Widgetbook and captures.
   - Reuse fixture builders for user profile, event summary, activity notification, review, blocked account, and payment row display data; the notifications route capture now reuses the shared activity-notification list.
   - Add reusable fakes for loading, empty, error, offline, permission denied, mutation pending, mutation failed, and missing resource.
3. Fill the P1 Widgetbook gaps before visual refactors.
   - Dashboard Home, Event Success Companion, Catches hub/event deck, and
     Matches list/chat and Profile/Public Profile now have first-pass
     Widgetbook coverage; prioritize host surfaces next.
   - Include default, loading, empty, error, offline, permission/access, mutation, text-scale, reduced-motion, and light/dark states where each screen supports them.
4. Build deterministic captures for high-risk states.
   - Start with P1 route captures for loading, full/populated, empty, error, offline, permission/access, mutation pending/failure, text scale, reduced motion, and paired theme states.
   - Add P2/P3 captures where states are hard to reach manually or likely to drift.
   - Share fixture data with Widgetbook instead of creating one-off capture-only examples.
5. Export design references and add advisory pixel comparison.
   - Place canonical Claude/Figma PNG references under `design/reference_screens/`.
   - Define masks for status bars, maps, timestamps, remote photos, generated counters, live counts, keyboards, safe areas, and animation frames.
   - Keep pixel diff advisory until fixture stability and thresholds prove reliable.
6. Reconcile Claude Design, Flutter, Widgetbook, and component contracts.
   - Compare every Claude primitive against `design/components/catch.components.json`, Widgetbook, Flutter source, and `docs/design_parity/claude_widgetbook_inventory.md`.
   - Classify local-only Flutter primitives as keep, rename, deprecate, or needs-design-review.
   - Promote only reusable primitives or proven cross-screen sections; keep one-screen layout glue private.
7. Reconcile tokens and cross-surface design data.
   - Keep portable foundation values in `design/tokens/catch.tokens.json`.
   - Keep Flutter implementation in `lib/core/theme`.
   - Decide website and social-template token export needs before adding Flutter-only token categories.
   - Evaluate DTCG/Style Dictionary compatibility before adding a parallel token pipeline.
8. Migrate screens feature by feature toward adapter-owned state and section composition.
   - For each pass, identify provider reads, controller ownership, mutation owners, private widgets, and reusable primitives before changing visuals.
   - Add a route-level state adapter/view model before visual refactors.
   - Keep route widgets responsible for routing, state selection, and section composition only.
   - Move repository writes, permission decisions, mutation branching, and side effects into controllers or feature-owned providers.
   - Replace screen-local spacing, radius, color, typography, icon sizing, and motion values with tokens, theme values, or registered component APIs.
9. Tighten drift prevention after baselines stabilize.
   - Keep failing on new product routes without screen coverage and capture
     coverage decisions through Flutter CI's design parity gate.
   - Fail on contract `previewIds` that do not resolve in generated Widgetbook directories.
   - Add checks for contracted screen sections that import raw Material controls or add one-off visual values.
   - Compare component contracts against generated Widgetbook use cases.
   - Promote high-signal invariants into `packages/catch_ui_lints` once false positives are resolved.
10. Maintain the review cadence on every pass.
    - Update coverage JSON, screen contracts, state matrix, Widgetbook/capture entries, docs, tests, and audit receipts together.
    - Verify with `npm run design:parity:check`, focused Flutter tests, focused analyzer, JSON syntax checks, `git diff --check`, relevant scanners, and audit stamping.
    - Keep all follow-up gaps in this tracker, not in chat history.

## Comprehensive Action Queue

This queue is the stable todo index for the design-parity program. The detailed
route ledger and feature notes below remain the evidence trail; these ids are
the actionable work items to reference in future passes.

### A. Sources Of Truth And Gates

- [x] `DPT-SOT-001` Generate route inventory from app routing.
- [x] `DPT-SOT-002` Require every generated route to have a coverage decision.
- [x] `DPT-SOT-003` Validate contracted routes against `catch.screens.json`.
- [x] `DPT-SOT-004` Validate screen contracts against route inventory, source files, Dart symbols, captures, components, and Widgetbook refs.
- [x] `DPT-SOT-005` Keep `npm run design:parity:check` as the aggregate local gate.
- [x] `DPT-SOT-006` Add the route-coverage review note/check to the new-route workflow.
- [x] `DPT-SOT-007` Decide whether generated route inventory is enough or whether `Routes`/AppRoute needs richer design metadata.
- [ ] `DPT-SOT-008` Keep `state_matrix.json`, `catch.screens.json`, `screen_coverage.json`, Widgetbook refs, and `docs/widget_catalog.md` synchronized in every screen/component pass.

### B. Screen Contracts

- [x] `DPT-SCREEN-001` Contract `profileScreen` as `screen.profile.self`.
- [x] `DPT-SCREEN-002` Contract `publicProfileScreen` as `screen.profile.public`.
- [x] `DPT-SCREEN-003` Contract `hostHomeScreen` as `screen.host.home`.
- [x] `DPT-SCREEN-004` Contract `hostClubsScreen` as `screen.host.clubs`.
- [x] `DPT-SCREEN-005` Contract `hostClubDetailScreen` as `screen.host.club.detail`.
- [x] `DPT-SCREEN-006` Contract `hostCreateEventScreen` as `screen.host.event.create`.
- [x] `DPT-SCREEN-007` Contract `hostAppEventManageScreen` as `screen.host.event.manage`.
- [x] `DPT-SCREEN-008` Contract `hostInboxScreen` as `screen.host.inbox`.
- [x] `DPT-SCREEN-009` Contract `hostChatScreen` as `screen.host.chat`.
- [x] `DPT-SCREEN-010` Promote `startScreen` into `catch.screens.json`.
- [x] `DPT-SCREEN-011` Promote `authScreen` into `catch.screens.json`.
- [x] `DPT-SCREEN-012` Promote `onboardingScreen` into `catch.screens.json`.
- [x] `DPT-SCREEN-013` Contract `calendarScreen` as `screen.calendar.home`.
- [x] `DPT-SCREEN-014` Contract `savedEventsScreen` as `screen.saved_events.list`.
- [x] `DPT-SCREEN-015` Contract `filtersScreen` as `screen.filters.preferences`.
- [x] `DPT-SCREEN-016` Contract `eventRecapScreen` as `screen.event.recap`.
- [x] `DPT-SCREEN-017` Contract `hostCreateClubScreen` as `screen.host.club.create`.
- [x] `DPT-SCREEN-018` Contract `hostEditClubScreen` as `screen.host.club.edit`.
- [x] `DPT-SCREEN-019` Contract `hostAppEditEventScreen` as `screen.host.event.edit`.
- [x] `DPT-SCREEN-020` Contract `hostSettingsScreen` as `screen.host.settings`.
- [x] `DPT-SCREEN-021` Contract `hostProfileScreen` as `screen.host.profile`.
- [x] `DPT-SCREEN-022` Contract `eventLocationMapScreen` as `screen.event.location_map`.
- [x] `DPT-SCREEN-023` Contract `notificationsScreen` as `screen.notifications.list`.
- [x] `DPT-SCREEN-024` Contract `reviewsHistoryScreen` as `screen.reviews.history`.
- [x] `DPT-SCREEN-025` Contract `settingsScreen` as `screen.settings.account`.
- [x] `DPT-SCREEN-026` Contract `paymentHistoryScreen` as `screen.payments.history`.
- [x] `DPT-SCREEN-027` Revisit `hostAppAttendanceSheet` after `screen.host.event.manage` exists.
- [x] `DPT-SCREEN-028` Revisit `hostAppEventSuccessScreen` after `screen.host.event.manage` exists.
- [ ] `DPT-SCREEN-029` Revisit excluded routes quarterly or when a dev/lab/manual QA route becomes product-facing.

### C. State Contracts And Composition

- [ ] `DPT-STATE-001` Enumerate populated, loading, empty, error, offline, access, mutation, theme, text-scale, and reduced-motion states for every contracted screen.
- [ ] `DPT-STATE-002` Record missing params, missing documents, deleted resources, and unauthorized states for every detail route.
- [ ] `DPT-STATE-003` Record keyboard, composer, send failure, attachment, blocked, and safety states for chat-like surfaces.
- [ ] `DPT-STATE-004` Record validation, disabled-submit, mutation pending, mutation failed, and success/exit states for create/edit surfaces.
- [ ] `DPT-STATE-005` Record host/member/guest/owner/private role variants where screen behavior changes by role.
- [ ] `DPT-COMP-001` Define a route-level screen state adapter before visual refactors.
- [ ] `DPT-COMP-002` Keep route widgets responsible for routing, provider orchestration, state selection, and section composition only.
- [ ] `DPT-COMP-003` Move mutation orchestration, permission decisions, repository writes, side effects, and product validation into controllers or feature-owned providers.
- [ ] `DPT-COMP-004` Keep visual sections provider-free where practical.
- [ ] `DPT-COMP-005` Promote private section widgets only after reuse is proven or a stable design-language role is needed.

### D. Widgetbook

- [x] `DPT-WB-001` Represent every reusable primitive in `catch.components.json` in Widgetbook.
- [ ] `DPT-WB-002` Represent every meaningful design-contract state for each primitive and compound component.
- [ ] `DPT-WB-003` Add Widgetbook entries for contracted screen sections with meaningful local states.
- [ ] `DPT-WB-004` Add shared fakes for loading, empty, error, offline, permission denied, mutation pending, mutation failure, and missing-resource states.
- [ ] `DPT-WB-005` Reuse fixture data between Widgetbook and route captures where practical.
- [ ] `DPT-WB-006` Keep generated Widgetbook directories synchronized after adding, renaming, or deleting use cases.
- [ ] `DPT-WB-007` Add text-scale and light/dark preview coverage for high-risk primitives and P1 sections.
- [ ] `DPT-WB-008` Add reduced-motion preview coverage for animated primitives, heroes, maps, route-like transitions, and reveal moments.

### E. Captures And Pixel Comparison

- [x] `DPT-CAP-001` Keep capture coverage exhaustive for every route, separate from screen contract status.
- [ ] `DPT-CAP-002` Add deterministic captures for P1 loading, populated, empty, error, offline, access, mutation, text-scale, reduced-motion, and light/dark states.
- [ ] `DPT-CAP-003` Add deterministic captures for P2/P3 states that are hard to reach manually or likely to drift.
- [ ] `DPT-CAP-004` Export canonical Claude/Figma PNG references into `design/reference_screens/`.
- [ ] `DPT-CAP-005` Define masks for status bars, maps, timestamps, remote photos, generated counters, live counts, animation frames, keyboard, and safe-area variance.
- [ ] `DPT-CAP-006` Add advisory pixel comparison between local captures and exported design references.
- [ ] `DPT-CAP-007` Keep pixel comparison advisory until fixtures, masks, image sources, and thresholds prove stable.
- [ ] `DPT-CAP-008` Promote selected pixel checks to blocking only after repeated advisory runs avoid false positives.

### F. Components, Tokens, And Cross-Surface Design Data

- [ ] `DPT-DS-001` Reconcile every Claude Design primitive against Flutter source, component contracts, Widgetbook, and the Claude/Widgetbook inventory.
- [ ] `DPT-DS-002` Reconcile every local Flutter primitive absent from Claude Design as keep, rename, deprecate, or needs-design-review.
- [ ] `DPT-DS-003` Keep foundation tokens in `design/tokens/catch.tokens.json` and Flutter implementation under `lib/core/theme`.
- [ ] `DPT-DS-004` Keep token names portable for Flutter, website, and social-media templates.
- [ ] `DPT-DS-005` Evaluate DTCG/W3C token compatibility before adding token categories or generators.
- [ ] `DPT-DS-006` Decide the website/social template export path before locking non-Flutter token names.
- [ ] `DPT-DS-007` Replace screen-local hard-coded spacing, color, radius, typography, icon sizing, and motion values with catalogued tokens/theme/component APIs.

### G. Drift Prevention

- [ ] `DPT-DRIFT-001` Add a blocking check for newly introduced routes with no coverage decision.
- [ ] `DPT-DRIFT-002` Tighten advisory hygiene checks for contracted screens that add raw Material controls or one-off visual constants.
- [x] `DPT-DRIFT-003` Compare component contracts against generated Widgetbook use cases.
- [ ] `DPT-DRIFT-004` Promote stable UI invariants into `packages/catch_ui_lints` once baselines are clean.
- [ ] `DPT-DRIFT-005` Keep broad scanners advisory until existing violations are fixed, allowed, or intentionally documented.

### H. Review Cadence

- [ ] `DPT-CADENCE-001` Work one feature pair or one host surface per pass.
- [ ] `DPT-CADENCE-002` Read route source, providers/controllers, tests, captures, Widgetbook entries, design references, and contract gaps before editing visuals.
- [ ] `DPT-CADENCE-003` Update coverage JSON, screen contracts, state matrix, Widgetbook/capture entries, docs, tests, and audit receipts together.
- [ ] `DPT-CADENCE-004` Verify every pass with `npm run design:parity:check`, focused Flutter tests, focused analyzer, JSON syntax checks, `git diff --check`, and audit stamping.
- [ ] `DPT-CADENCE-005` Keep follow-up gaps in this tracker instead of chat history.

## Master Todo List

This is the control list for the full design-parity program. The sections below
contain the route-by-route and component-by-component detail; this list is the
working order of operations.

### 1. Keep The Sources Of Truth Exhaustive

- [x] Generate route inventory from the app router instead of maintaining a hand-written route list.
- [x] Require every generated route to appear in `design/screens/screen_coverage.json`.
- [x] Validate that every contracted route points at a screen in `design/screens/catch.screens.json`.
- [x] Validate that every contracted screen references real routes, source files, Dart symbols, captures, and component dependencies.
- [x] Add a small route-coverage review note after every new app route is added, moved, aliased, or excluded.
- [x] Decide whether the route source should eventually be promoted into richer `Routes`/AppRoute metadata, or whether generated inventory plus coverage JSON is enough.
- [ ] Keep `docs/design_parity/state_matrix.json` synchronized with every new contracted screen and every screen-state coverage decision.
- [ ] Keep `docs/widget_catalog.md` synchronized when component ownership, naming, or reusable roles change.

### 2. Contract Every Product Screen

- [x] Contract Event Detail.
- [x] Contract Explore Discovery.
- [x] Contract Club Detail.
- [x] Contract Dashboard Home.
- [x] Contract Event Success Companion.
- [x] Contract Catches hub and Catches event deck.
- [x] Contract Matches list and chat.
- [x] Contract self profile and public profile.
- [x] Contract all P1 host screen routes.
- [x] Promote Start, Auth, and Onboarding from matrix-only coverage into screen contracts.
- [x] Contract remaining P2 consumer screens: Calendar, Saved Events, Filters, and Event Recap.
- [x] Contract remaining P2 host screens: create/edit club, edit event, settings, and profile.
- [x] Contract P3 utility screens after P1/P2 patterns stabilize: map, notifications, reviews history, settings, and payments.
- [ ] Revisit alias routes once their canonical screens are contracted and decide whether they stay aliases or split into their own contracts.
- [ ] Revisit excluded routes quarterly or when a dev/lab/manual QA route graduates into a user-facing product surface.

### 3. Define The State Contract For Every Screen

- [ ] For every contracted screen, enumerate populated, loading, empty, error, offline, permission/access, mutation, theme, text-scale, and reduced-motion states.
- [ ] Record missing route params, missing documents, deleted resources, and unauthorized access states for every detail route.
- [ ] Record keyboard, composer, send-failure, blocked/safety, and attachment states for chat-like surfaces.
- [ ] Record form validation, disabled-submit, mutation-pending, mutation-failed, and success/exit states for create/edit surfaces.
- [ ] Record host/member/guest/owner/private role differences anywhere a screen changes behavior by account role.
- [ ] Mark each state as planned, implemented, captured, tested, ready, or blocked with proof references.
- [ ] Keep open gaps stable and specific enough that a future pass can close them without rediscovery.

### 4. Move Screens Toward Pure Composition

- [ ] For each screen pass, identify the current route widget, provider reads, controller ownership, mutation owners, private widgets, and reusable primitives before editing visuals.
- [ ] Define a screen state adapter or view model that converts providers/repositories into immutable display data and typed callbacks.
- [ ] Keep route widgets responsible for navigation, provider orchestration, state selection, and section composition only.
- [ ] Move repository writes, mutation branching, permission decisions, side effects, and product validation into controllers or feature-owned providers.
- [ ] Keep visual sections provider-free where practical.
- [ ] Promote a private section into a registered section/component only after reuse is proven or the design language requires a named primitive.
- [ ] Replace screen-local hard-coded spacing, color, radius, typography, icon sizing, and motion values with tokens, theme values, or registered component APIs.

### 5. Bring Widgetbook Into Parity

- [ ] Ensure every component in `design/components/catch.components.json` has Widgetbook representation for every meaningful design-contract state.
- [ ] Add Widgetbook entries for every contracted screen section with meaningful local visual states.
- [ ] Reuse the same fixture data and fakes across Widgetbook and route captures wherever practical.
- [ ] Add reusable fakes for offline, backend error, loading, empty, permission denied, mutation pending, mutation failure, and missing resource states.
- [ ] Validate that every contract `previewIds` reference resolves to an existing generated Widgetbook use case.
- [ ] Add text-scale and light/dark preview coverage for high-risk primitives and P1 sections.
- [ ] Add reduced-motion preview coverage for animated primitives, heroes, maps, reveal moments, and route-transition-like states.

### 6. Build The Capture And Pixel-Diff Pipeline

- [x] Keep capture coverage exhaustive for every route, separate from screen contract status.
- [ ] Add deterministic captures for every P1 screen's highest-risk states before visual refactors.
- [ ] Add deterministic captures for P2/P3 screens when the state is hard to reach manually or likely to drift.
- [ ] Export canonical Claude/Figma references into `design/reference_screens/`.
- [ ] Create masks for unstable regions: status bars, maps, timestamps, remote photos, live counts, generated recommendations, animation frames, and keyboard/safe-area variance.
- [ ] Add advisory pixel comparison between local captures and design references.
- [ ] Keep pixel diff advisory until fixtures, masks, image sources, and thresholds are stable enough to avoid false positives.
- [ ] Promote selected pixel checks to blocking only after repeated advisory runs prove them reliable.

### 7. Reconcile Components, Tokens, And Cross-Surface Design Data

- [ ] Reconcile every Claude Design primitive against Flutter source, component contracts, Widgetbook entries, and `docs/design_parity/claude_widgetbook_inventory.md`.
- [ ] Reconcile every local Flutter primitive absent from Claude Design as keep, rename, deprecate, or needs-design-review.
- [ ] Keep foundation tokens in `design/tokens/catch.tokens.json`, with Flutter implementation under `lib/core/theme`.
- [ ] Keep token naming portable for Flutter, website, and social-media template use.
- [ ] Evaluate DTCG/W3C design-token compatibility before adding new token categories or generators.
- [ ] Decide the export path for website and social templates before locking new token names that are not Flutter-specific.
- [ ] Avoid adding parallel theme/token sources outside the design-token and Flutter-theme ownership boundaries.

### 8. Add Drift Prevention

- [x] Keep `npm run design:parity:check` as the aggregate local design gate.
- [x] Validate route inventory, capture coverage, screen coverage, screen contracts, state matrix, Widgetbook refs, component contracts, and advisory hygiene in one gate.
- [x] Add a blocking check for newly introduced routes with no coverage decision.
- [ ] Add or tighten advisory checks for contracted screens that import raw Material controls or add new one-off visual constants.
- [x] Add a drift check that compares component contracts against generated Widgetbook use cases.
- [ ] Promote stable UI invariants into `packages/catch_ui_lints` once scanner baselines are clean enough.
- [ ] Keep broad scanners advisory until known baseline violations are fixed, allowed, or intentionally documented.

### 9. Run Feature Passes In A Reviewable Cadence

- [ ] Work one feature pair or one host surface at a time.
- [ ] Before each pass, read the route source, providers/controllers, tests, capture fixtures, Widgetbook entries, design references, and current contract gaps.
- [ ] During each pass, update coverage JSON, screen contracts, state matrix, Widgetbook/capture entries, docs, tests, and audit receipts together.
- [ ] After each pass, run `npm run design:parity:check`, focused Flutter tests, focused analyzer, JSON syntax checks, `git diff --check`, and audit stamping.
- [ ] Keep follow-up gaps in this tracker instead of leaving them in chat history.
- [ ] Do visual layout refactors only after the screen's states, fixtures, previews/captures, and adapter boundaries are known.

## Definition Of Done

This program is done when every product route is either contracted, aliased, or
explicitly excluded; every contracted screen is composed from registered
sections/components and controller-owned state; every reusable primitive is
represented in both the component registry and Widgetbook; and every supported
state has useful preview, capture, test, or documented-gap proof.

Each completed screen should satisfy all of these checks:

- [ ] Route is present in `design/screens/screen_coverage.json` with the correct status, priority, screen id, and reason.
- [ ] Screen is present in `design/screens/catch.screens.json` with routes, owner, priority, controller/state ownership, states, captures, composition sections, dependencies, and open gaps.
- [ ] Screen states cover populated, loading, empty, error, offline, permission/access, mutation pending/failure, theme, text scale, reduced motion, and role-specific variants where applicable.
- [ ] Route widget owns navigation and state orchestration only; visual structure is delegated to predefined sections/components.
- [ ] Sections depend on registered primitives/tokens instead of raw Material controls, hard-coded colors, spacing, radius, typography, or one-off local styles.
- [ ] Widgetbook includes useful primitive/section previews for hard-to-reach states and maps preview ids referenced by contracts.
- [ ] UI capture catalog includes deterministic full-screen captures for the highest-risk states.
- [ ] Tests cover controller/adapters and critical UI state transitions.
- [ ] Pixel comparison is advisory or ready for the screen once exported design references and masks exist.
- [ ] Drift-prevention scanners pass or record stable, intentional advisory findings.
- [ ] `docs/widget_catalog.md`, design parity docs, and audit registry receipts are updated in the same pass.

## Comprehensive Workstreams

### Inventory And Contracts

- [ ] Keep `tool/ui_capture/route_inventory.json` generated from routing as the route source of truth.
- [ ] Keep `design/screens/screen_coverage.json` exhaustive for every route: contracted, alias, planned, or excluded.
- [ ] Keep `design/screens/catch.screens.json` exhaustive for contracted screens only.
- [ ] Keep `docs/design_parity/state_matrix.json` focused on user-visible state coverage and open gaps.
- [ ] Keep `docs/design_parity/claude_widgetbook_inventory.md` updated when Claude Design, Widgetbook, or local component inventory changes.
- [ ] Keep `design/components/catch.components.json` focused on reusable primitive and compound components, not one-screen sections.
- [ ] Create `design/sections/catch.sections.json` only when multiple screens prove a reusable section layer is needed.
- [ ] Record aliases explicitly instead of duplicating screen contracts for the same surface.
- [ ] Keep exclusions narrow, route-specific, and reversible.

### Screen Composition

- [ ] For each route, choose the canonical screen id and owning product area before refactoring UI.
- [ ] For each contracted screen, define a route-level state adapter that owns data derivation, permissions, mutation modes, and retry intents.
- [ ] Keep route widgets responsible for routing, state selection, and section composition only.
- [ ] Keep visual sections provider-free where possible; pass view data and callbacks instead of reading repositories in sections.
- [ ] Keep mutation orchestration in controllers or feature-owned providers.
- [ ] Keep list/profile/event/club display data behind batched feature seams rather than per-tile repository reads.
- [ ] Split host and consumer contracts only when the UI behavior or section ownership materially diverges.

### State Coverage

- [ ] Cover populated/default state for every screen.
- [ ] Cover loading state for every async screen.
- [ ] Cover genuinely-empty success state for every list or route that can have no data.
- [ ] Cover data-load error state with a branded retry surface.
- [ ] Cover offline/network-looking failure behavior where applicable.
- [ ] Cover permission/access states: guest, unauthenticated, unauthorized, host, member, owner, blocked, or private.
- [ ] Cover mutation pending and mutation failed states for every user-visible action.
- [ ] Cover text scale, reduced motion, and light/dark theme where the screen has custom layout, animation, or high visual risk.
- [ ] Cover missing route params, missing documents, and deleted resources for detail screens.

### Widgetbook

- [ ] Represent every reusable primitive in Widgetbook with default, dense/compact, disabled, loading, error, empty, selected, long-copy, text-scale, and theme states where meaningful.
- [ ] Represent every registered compound component in Widgetbook with its design-contract states.
- [ ] Represent every contracted screen section in Widgetbook when the section has meaningful local visual states.
- [ ] Reuse the same fakes and fixture data shape across Widgetbook and UI captures where practical.
- [ ] Keep generated Widgetbook directories in sync after adding, renaming, or deleting use cases.
- [ ] Ensure every `previewIds` reference in contracts resolves to a generated Widgetbook use case.

### UI Captures And Pixel Comparison

- [x] Keep `tool/ui_capture/capture_coverage.json` exhaustive for every route.
- [ ] Add deterministic captures for high-risk states before visual refactors.
- [ ] Disable or replace dynamic map/network surfaces in capture fixtures.
- [ ] Export canonical Claude/Figma PNG references into `design/reference_screens/`.
- [ ] Define masks for status bars, maps, timestamps, remote photos, generated counters, live participant counts, and other unstable regions.
- [ ] Add advisory pixel comparison between local captures and exported design references.
- [ ] Keep pixel comparison advisory until fixtures, masks, and thresholds are stable.

### Tokens, Primitives, And Cross-Surface Design Data

- [ ] Keep foundation tokens in `design/tokens/catch.tokens.json`.
- [ ] Keep Flutter theme implementation in `lib/core/theme`.
- [ ] Keep token names portable enough for Flutter, website, and social template generation.
- [ ] Evaluate DTCG/Style Dictionary compatibility before adding a parallel token pipeline.
- [ ] Replace screen-local hard-coded spacing, radius, color, type, icon sizing, and motion constants with catalogued values.
- [ ] Promote missing Claude primitives only when they are reusable outside one screen or needed as stable design language.
- [ ] Decide whether every local primitive absent from Claude is intentional, deprecated, or awaiting design-system reconciliation.

### Drift Prevention

- [ ] Keep `npm run design:parity:check` as the local aggregate gate.
- [ ] Add or tighten checks when a deterministic invariant appears repeatedly.
- [ ] Promote high-signal scanners into `packages/catch_ui_lints` analyzer plugin rules when the baseline is clean enough.
- [x] Fail on new product routes without screen coverage and capture coverage decisions.
- [ ] Fail on contract `previewIds` that do not resolve in generated Widgetbook directories.
- [ ] Fail or warn on contracted screen sections that import raw Material controls or add one-off visual values outside approved token/theme files.
- [ ] Fail or warn when component contracts and Widgetbook primitive coverage drift.
- [ ] Keep CI enforcement staged: advisory first, then blocking after false positives are resolved.

## Execution Phases

### P0: Contract Infrastructure

- [x] Keep one canonical route inventory generated from app routing.
- [x] Keep one canonical screen coverage ledger for all routes.
- [x] Keep one canonical screen composition registry for contracted screens.
- [x] Keep one canonical component registry for reusable primitives.
- [x] Keep Widgetbook generated directories synchronized with registered primitives and screen/section preview ids.
- [x] Wire screen coverage, screen contracts, component contracts, route inventory, capture coverage, design matrix, Widgetbook refs, and advisory hygiene checks into one local design gate.
- [x] Add the design gate to `package.json` and `tool/tools_manifest.json`.
- [x] Decide where section contracts live long term: screen-local sections stay in `catch.screens.json`, reused product sections promote to `design/sections/catch.sections.json`, and `catch.components.json` remains primitive/compound focused.
- [x] Document exact pass workflow in `docs/design_parity/README.md`.

### P1: Consumer And Host Product Screens

- [x] Contract all P1 consumer screens.
- [x] Contract all P1 host screen routes.
- [ ] Add Widgetbook states for P1 registered sections and important screen adapters.
- [ ] Add deterministic captures for P1 populated/loading/empty/error/offline/permission/mutation/accessibility states.
- [ ] Start advisory pixel comparison for Event Detail, Explore, Club Detail, Dashboard, and host management surfaces.

### P2: Secondary Product Screens

- [x] Promote existing matrix-only screens into `catch.screens.json`.
- [x] Contract all P2 consumer screens.
- [x] Contract all P2 host screens.
- [ ] Reuse P1 section contracts rather than creating local copies.
- [ ] Add captures/previews where the state is hard to reach manually or likely to drift.

### P3: Settings, History, Map, And Utility Screens

- [x] Contract P3 product screens after P1/P2 patterns stabilize.
- [ ] Keep exclusions narrow and documented.
- [x] Promote utility routes into contracted status only when they become product-facing parity surfaces.

## Comprehensive Route Ledger

This ledger mirrors `design/screens/screen_coverage.json`. Every app route
should remain visible here until it is contracted, explicitly aliased, or
excluded with a narrow reason.

### Contracted Routes

- [x] `startScreen` -> `screen.start.welcome`
- [x] `authScreen` -> `screen.auth.phone_entry`
- [x] `onboardingScreen` -> `screen.onboarding.flow`
- [x] `calendarScreen` -> `screen.calendar.home`
- [x] `calendarEventDetailScreen` -> `screen.event.detail`
- [x] `savedEventDetailScreen` -> `screen.event.detail`
- [x] `savedEventsScreen` -> `screen.saved_events.list`
- [x] `filtersScreen` -> `screen.filters.preferences`
- [x] `dashboardEventDetailScreen` -> `screen.event.detail`
- [x] `exploreScreen` -> `screen.explore.discovery`
- [x] `exploreMapScreen` -> `screen.explore.discovery`
- [x] `clubDetailScreen` -> `screen.club.detail`
- [x] `eventDetailScreen` -> `screen.event.detail`
- [x] `hostAppEventDetailScreen` -> `screen.event.detail`
- [x] `dashboardScreen` -> `screen.dashboard.home`
- [x] `eventSuccessCompanionScreen` -> `screen.event_success.companion`
- [x] `swipeHubScreen` -> `screen.catches.hub`
- [x] `swipeEventScreen` -> `screen.catches.event`
- [x] `matchesListScreen` -> `screen.matches.list`
- [x] `chatScreen` -> `screen.matches.chat`
- [x] `profileScreen` -> `screen.profile.self`
- [x] `publicProfileScreen` -> `screen.profile.public`
- [x] `hostHomeScreen` -> `screen.host.home`
- [x] `hostClubsScreen` -> `screen.host.clubs`
- [x] `hostClubDetailScreen` -> `screen.host.club.detail`
- [x] `hostCreateEventScreen` -> `screen.host.event.create`
- [x] `hostAppEventManageScreen` -> `screen.host.event.manage`
- [x] `hostInboxScreen` -> `screen.host.inbox`
- [x] `hostChatScreen` -> `screen.host.chat`
- [x] `hostCreateClubScreen` -> `screen.host.club.create`
- [x] `hostEditClubScreen` -> `screen.host.club.edit`
- [x] `hostAppEditEventScreen` -> `screen.host.event.edit`
- [x] `hostSettingsScreen` -> `screen.host.settings`
- [x] `hostProfileScreen` -> `screen.host.profile`
- [x] `eventRecapScreen` -> `screen.event.recap`

### Alias Routes

- [x] `hostAppAttendanceSheet` -> `hostAppEventManageScreen`; keep as an alias covered by `screen.host.event.manage` because it enters the canonical Live roster section.
- [x] `hostAppEventSuccessScreen` -> `hostAppEventManageScreen`; keep as an alias covered by `screen.host.event.manage` because it enters the canonical host Event Success workspace.

### P1 Consumer Route Todos

- [x] No open P1 consumer route contracts remain. Continue P1 consumer work through Widgetbook states, deterministic captures, adapters, and visual comparison follow-ups.

### P1 Host Route Todos

- [x] `hostAppEventManageScreen` -> create `screen.host.event.manage`; include live console, attendance, post-event report, cancellation/delete actions, empty states, mutation errors, text scale, and reduced motion.
- [x] `hostInboxScreen` -> create `screen.host.inbox`; include host conversation list, empty, unread, loading, error, search/filter, text scale, and reduced motion.
- [x] `hostChatScreen` -> create `screen.host.chat`; include professional conversation thread, composer, send failure, empty, blocked, safety/report, keyboard, text scale, and reduced motion.

### P2 Consumer Route Todos

- [x] `startScreen` -> promote current matrix entry into `catch.screens.json`; include animated reel, landed direct, reduced motion, text scale, and light/dark.
- [x] `authScreen` -> promote current matrix entry into `catch.screens.json`; include phone entry, OTP, validation, submit mutation, error, text scale, and reduced motion.
- [x] `onboardingScreen` -> promote current matrix entry into `catch.screens.json`; include each onboarding step, validation, photo gate, disabled CTA, upload errors, text scale, and reduced motion.
- [x] `calendarScreen` -> create `screen.calendar.home`; include planned events, empty, loading, error, offline, event-card states, text scale, and reduced motion.
- [x] `savedEventsScreen` -> create `screen.saved_events.list`; include saved events, empty, loading, error, offline, removed/sold-out states, text scale, and reduced motion.
- [x] `filtersScreen` -> create `screen.filters.preferences`; include default filters, active filters, validation, clear/reset, loading/error for profile-backed defaults, text scale, and reduced motion.
- [x] `eventRecapScreen` -> create `screen.event.recap`; include attendee recap, empty/missing event, loading, error, permission, text scale, and reduced motion.

### P2 Host Route Todos

- [x] `hostCreateClubScreen` -> create `screen.host.club.create`; include basics, image picker, validation, mutation pending/error, success pop, text scale, and reduced motion.
- [x] `hostEditClubScreen` -> create `screen.host.club.edit`; include prefilled state, optional contact clearing, image replacement, validation, unauthorized/missing club, text scale, and reduced motion.
- [x] `hostAppEditEventScreen` -> create `screen.host.event.edit`; include prefilled event, schedule/location changes, validation, mutation pending/error, cancelled-event restriction, text scale, and reduced motion.
- [x] `hostSettingsScreen` -> create `screen.host.settings`; include account, profile, notification, payout/admin placeholders, loading/error, text scale, and reduced motion.
- [x] `hostProfileScreen` -> create `screen.host.profile`; include profile editing, photo/avatar, validation, mutation pending/error, text scale, and reduced motion.

### P3 Route Todos

- [x] `eventLocationMapScreen` -> create `screen.event.location_map`; include pin ready, no coordinate, network-tile disabled capture, error/retry, map masking, text scale, and reduced motion.
- [x] `notificationsScreen` -> create `screen.notifications.list`; include activity list, empty, loading, error, read/unread, deep-link failures, text scale, and reduced motion.
- [x] `reviewsHistoryScreen` -> create `screen.reviews.history`; include review list, empty, loading, error, event context missing, text scale, and reduced motion.
- [x] `settingsScreen` -> create `screen.settings.account`; include account, safety, payment, notifications, logout/delete flows, mutation errors, text scale, and reduced motion.
- [x] `paymentHistoryScreen` -> create `screen.payments.history`; include empty, populated, refund/pending statuses, loading, error, text scale, and reduced motion.

### Excluded Routes

- [x] `loadingScreen` remains excluded unless launch UX becomes an explicit parity surface.
- [x] `paymentConfirmationScreen` remains excluded until deterministic transaction extras exist.
- [x] `eventPolicyLabScreen` remains excluded as a dev-gated lab route.
- [x] `eventSuccessLabScreen` remains excluded as a dev-gated lab route.
- [x] `eventSuccessManualQaScreen` remains excluded as a manual QA surface.
- [x] `eventSuccessPreviewScreen` remains excluded as a dev-gated preview route.

## Immediate Ordered Backlog

Work this list from top to bottom unless a screen-specific blocker requires
moving to the next route.

1. [x] Finish the Club Detail proof pass: run design parity validators, focused Club Detail tests, JSON syntax checks, `git diff --check`, and audit registry stamping.
2. [x] Add Club Detail Widgetbook states for hero, stats, host section, overview, photos, contact, schedule, reviews, membership dock, loading, missing, fatal error, pending mutation, failed mutation, text scale, and reduced motion.
3. [x] Add deterministic Club Detail captures for member, visitor, guest, host public view, missing club, fatal error, pending mutation, failed mutation, offline, text scale, and reduced motion.
4. [x] Register or promote reused Club Detail sections only after confirming reuse outside the screen; keep screen-local sections inside `screen.club.detail` until then.
5. [x] Add Event Detail section Widgetbook states for the remaining high-risk compounds before visual refactors.
6. [x] Add Explore section Widgetbook states for browse chrome, filter rail/sheet, mixed feed cards, empty/error states, and map route.
7. [x] Add deterministic Explore map capture with network tiles disabled and map dynamic regions removed from the capture fixture.
8. [x] Add Event Detail guest, host-app, offline, text-scale, reduced-motion, and booking-state captures.
9. [x] Contract `dashboardScreen` as `screen.dashboard.home`.
10. [x] Contract `eventSuccessCompanionScreen` as `screen.event_success.companion`.
11. [x] Contract `swipeHubScreen` and `swipeEventScreen`.
12. [x] Contract `matchesListScreen` and `chatScreen`.
13. [x] Contract `profileScreen` and `publicProfileScreen`.
14. [x] Finish the Host Chat proof pass: sync widget catalog docs, run focused Chat tests/analyzer, run JSON/diff scanners, and stamp the audit registry.
15. [x] Promote existing P2 matrix screens into `catch.screens.json`: `startScreen`, `authScreen`, and `onboardingScreen`.
16. [x] Contract remaining P2 consumer routes, reusing P1 section contracts wherever possible.
17. [x] Contract remaining P2 host routes, reusing P1 section contracts wherever possible.
18. [x] Contract P3 settings/history/map/payment utility routes after P1/P2 patterns stabilize.
19. [ ] Export canonical Claude/Figma PNG references and wire advisory pixel comparison.
20. [ ] Move repeated visual values and private repeated section widgets into token, component, or section contracts only when reuse is proven.
21. [ ] Promote advisory hygiene checks to blocking only after the existing violations are resolved or intentionally allowed.

## Per-Screen Pass Checklist

Use this checklist for every screen pass before editing visuals:

- [ ] Confirm route id, route path, priority, owner, and target screen id.
- [ ] Confirm current screen coverage status and capture coverage status separately.
- [ ] Read current Flutter source, provider/controller files, tests, captures, and relevant Widgetbook entries.
- [ ] List every screen state and role variant before refactoring.
- [ ] Identify current private widgets and decide which remain local, become sections, or become reusable components.
- [ ] Define the adapter/state object that feeds the visual sections.
- [ ] Register composition sections and dependencies.
- [ ] Register state matrix entries, open gaps, preview ids, capture ids, and tests.
- [ ] Add or update Widgetbook use cases for the sections/components.
- [ ] Add or update deterministic UI capture catalog entries.
- [ ] Add or update Claude/Figma reference ids, even if canonical PNG export is still pending.
- [ ] Move data derivation and mutation orchestration out of visual widgets.
- [ ] Replace raw values with tokens/theme/catalog primitives.
- [ ] Add focused controller/widget tests.
- [ ] Run design validators, focused Flutter analyzer/tests, Widgetbook generation when needed, JSON syntax checks, `git diff --check`, and audit registry stamping.

## Always-On Checks

- [x] Add `node tool/design/check_screen_coverage.mjs --check` to the standard local/CI design gate.
- [x] Add `node tool/design/check_screen_contracts.mjs --check` to the standard local/CI design gate.
- [x] Keep `node tool/design/check_design_parity_matrix.mjs --check` in the design gate.
- [x] Keep `node tool/ui_capture/check_route_inventory.mjs --check` in the route/capture gate.
- [x] Keep `node tool/ui_capture/check_capture_coverage.mjs --summary` in the route/capture gate.
- [x] Add an `npm run design:parity:check` script that executes the standard gate.
- [x] Register every design parity gate/scanner in `tool/tools_manifest.json`.
- [x] Add an advisory check that P1 planned routes cannot remain uncontracted once a screen contract exists.
- [x] Add a scanner that verifies Widgetbook use-case ids referenced by contracts exist in generated Widgetbook directories.
- [x] Add a scanner for route/screen contracts that import raw Material controls or hand-roll visual values outside registered sections/components.
- [x] Add a component-contract/Widgetbook parity scanner so new shared primitives cannot appear without a contract and preview state.
- [x] Add the gate to CI once local false positives are resolved.

## Contracted Screen Work

### Event Detail

- [ ] Register event detail compounds and sections in the component or section registry: TicketStub, BookingDock, EventHero, HintList, Itinerary, MapCard, MechanismList, PhotoStrip, HostCard, AvatarStack.
- [x] Finish Widgetbook coverage for WhoIsGoing/AvatarStack, reviews, companion/invite prompts, and a provider-free BookingDock adapter.
- [ ] Move host lookup, companion lookup, visibility derivation, and booking dock mode derivation out of visual sections into adapter/controller state.
- [x] Add deterministic Widgetbook or route capture coverage for the loading state.
- [ ] Decide whether not-found remains a branded error surface or needs a dedicated empty Event Detail state.
- [x] Add preview/capture coverage for fatal error retry and offline-looking failures.
- [x] Add guest route capture and Widgetbook state for guest booking dock, locked social proof, and auth redirect.
- [x] Add host-app route capture and decide whether host-only actions stay in the Event Detail contract or split into a host Event Detail contract: keep host app Event Detail in the Event Detail read-only contract; host management actions belong to the future host event management contract.
- [x] Register BookingDock mutation states and align pending/failed copy with the Claude BookingDock contract.
- [ ] Split waitlist, sold-out, cancelled, and past-event booking states after the BookingDock adapter exists.
- [ ] Define explicit offline copy and retry behavior, then add an offline route capture.
- [x] Add generic offline-looking route capture through the branded event error surface.
- [x] Add tall-device text-scale capture after section adapters reduce layout drift.
- [x] Add reduced-motion capture/preview for hero modes and route transition.
- [x] Compare Event Detail member capture against the Claude reference and record baseline divergence: `event_detail_member` is above threshold at 31.45% mismatch / 45.20 mean delta, with divergence concentrated in hero media/chrome, ticket facts, and below-fold itinerary/body composition.

### Explore Discovery

- [ ] Register Explore compounds in the component or section registry: CoverStory, CountPill, CrossPathsCard, DateTicket/EventTicket mapping, ClubPolaroid, filter rail, and activity grid.
- [x] Add Widgetbook states for browse chrome, filter rail/sheet, mixed feed cards, empty/error states, map count pill, and map route.
- [x] Add deterministic map-route capture with network tiles disabled and map dynamic regions removed from the capture fixture.
- [ ] Add deterministic captures for signed-in joined-club feed, empty city, search empty, filter empty, offline/error, text-scale, and reduced-motion states.
- [ ] Move map label derivation, empty-state selection, feed-card selection, and section view data out of route/widget composition into explicit adapters.
- [x] Add a Widgetbook state for full Explore chrome plus skeleton body.
- [ ] Add an error capture proving retry placement with sticky browse chrome.
- [ ] Decide whether feed-only failures stay inline or promote to the screen-level error contract.
- [ ] Capture the empty city state once city switching has a deterministic fixture.
- [x] Add Widgetbook states for search-only, filter-only, and combined empty results.
- [x] Add a preview for expanded search with long query text and no-results copy.
- [x] Register filter rail and filter sheet states in Widgetbook.
- [ ] Keep unclaimed organizer fixtures in Explore captures before tightening host-card parity.
- [ ] Define offline copy and retry behavior for club-source and event-feed failures.
- [ ] Add tall-device text-scale capture for browse header, filter rail, event rows, and floating map pill.
- [ ] Add reduced-motion review for map opening, pin selection, and cover-story event opening.
- [x] Compare captured Explore feed against the Claude Explore template and record section-level divergence: `explore_search_query` is above threshold at 61.62% mismatch / 90.26 mean delta, with divergence concentrated in the dark CoverStory hero, ticket-strip grouping, club interleave/map pill, and bottom tab dock treatment.

### Dashboard Home

- [x] Register `screen.dashboard.home` with route, state-controller ownership, capture refs, state coverage, section composition, and open gaps.
- [x] Add Dashboard Home Widgetbook states for header, notification action, empty body, event focus, stride/activity, quick actions, joined clubs, recommendations, loading, error, text scale, and reduced motion.
- [x] Close remaining profile/membership loading capture work by normalizing profile, membership, and booked-event loading waves into `DashboardHomeScreenState.loading`; `dashboard_home_loading` is the canonical captured shell unless future branches become visually distinct.
- [x] Introduce `DashboardHomeScreenState` so `DashboardScreen` composes loading/error/empty/full route states from immutable view data and typed retry targets.
- [x] Move `DashboardClubsRail` off per-club `watchClubProvider` reads and onto the batched `watchClubsByIdsProvider` display-data seam before adding more club rail states.
- [x] Move Dashboard quick-action route pushes out of `QuickActions`; the
  visual grid now receives typed `DashboardQuickAction` models and callbacks
  from `DashboardFullSliverBody`.
- [x] Move EventFocusRail navigation, calendar, directions, check-in, swipe,
  and review side effects behind typed route/controller callbacks.
  `EventFocusRail` now receives `EventFocusActions` and
  `EventFocusCheckInState`; `DashboardFullSliverBody` owns the route,
  controller, external-link, calendar, event-success, and review-sheet wiring.
- [x] Move StrideCard connect/install local state and side effects behind a
  controller or adapter so permission, connecting, denied, unsupported, and
  install states are previewable. `DashboardStrideSection` now receives
  `DashboardStrideSectionActions` and `DashboardStrideActionState`;
  `DashboardFullSliverBody` owns the retry, permission, install, refresh,
  snackbar, and busy-state wiring.
- [x] Export canonical Dashboard Home full and empty design references and wire advisory pixel comparison against `dashboard_home` and `dashboard_home_empty_start`.

### Event Success Companion

- [x] Register `screen.event_success.companion` with route, runtime/controller ownership, capture refs, state coverage, section composition, and open gaps.
- [x] Add Event Success Companion Widgetbook states for companion chrome, stage scaffold, First Hello, pre-arrival, questionnaire, live cards, assignments, live reveal, wingman request, afterglow, feedback, loading, access, error, text scale, and reduced motion.
- [x] Export the first canonical Event Success Companion default live-guide reference and define first-pass masks for phone chrome, progress, ticket/event details, guide copy, and bottom CTA/safe-area.
- [ ] Add deterministic Event Success Companion captures for route loading, event missing, signed-out, no booking, no plan, provider errors/offline, First Hello start/assigned, compatibility questionnaire, live step, cues, assignments, reveal countdown/unlocked, wingman request, afterglow/feedback, opt-out states, text scale, reduced motion, and light/dark.
- [ ] Export dedicated Event Success Companion references for runtime stages, reveal, wingman, afterglow, feedback, offline/error, text-scale, reduced-motion, light/dark, and activity-specific variants.
- [ ] Introduce `EventSuccessCompanionScreenState` or equivalent route adapter so the route resolves provider waves once and passes immutable display data plus typed callbacks into sections.
- [ ] Keep `EventSuccessRuntime` as the attendee moment decision engine; do not duplicate runtime branching inside visual sections.
- [ ] Move stage effects, animated motif/reveal behavior, local questionnaire/feedback/wingman drafts, and mutation display state into adapters/controllers that can be previewed.
- [ ] Define explicit offline copy for each provider wave and route all failures through branded retry surfaces.
- [ ] Export canonical attendee companion design references and add masks for countdowns, animation, profile photos, dynamic peer rows, and copied-opener affordances.

### Catches

- [x] Register `screen.catches.hub` and `screen.catches.event` with route, provider/controller ownership, capture refs, state coverage, section composition, and open gaps.
- [x] Add Catches Hub Widgetbook states for hub header, active-window hero, attended-event rows, empty state, loading, auth error, event error, offline, text scale, reduced motion, and light/dark.
- [x] Add Catches Event Widgetbook states for deck chrome, profile surface, top overlay, reaction controls/comment sheet, pass control, empty/access states, queue loading/error, offline, mutation failure, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Catches Hub captures for uid loading/error, attended-events loading/error, signed-out/access behavior, no active windows, offline, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Catches Event captures for queue loading/error, empty queue, missing event, signed-out, event in progress, did-not-attend, closed window, offline, mutation failure, text scale, reduced motion, and light/dark.
- [ ] Introduce `CatchesHubScreenState` or equivalent route adapter so uid/event provider waves, open-window filtering, countdown time, and navigation intents are resolved outside visual sections.
- [ ] Introduce `CatchesEventScreenState` or equivalent route adapter so queue/event/user/participation provider waves are resolved once and deck sections receive immutable display data plus typed callbacks.
- [ ] Inject clock/reference time into hub countdowns and attended-event rows before adding strict visual comparisons.
- [ ] Decide whether signed-out Catches routes should stay shell-hidden or render explicit branded access states.
- [ ] Expose pass/reaction pending and failure state if design requires disabled controls or inline feedback beyond the current snackbar behavior.
- [ ] Export the canonical Catches Hub reference, plus dedicated Catches Event Deck mutation, keyboard/comment sheet, empty/offline, accessibility, and theme references; refine masks for countdowns, dynamic profile imagery, keyboard/sheet regions, queue counts, and live attendee counts.

### Matches And Chat

- [x] Register `screen.matches.list` and `screen.matches.chat` with route, view-model/controller ownership, capture refs, state coverage, section composition, and open gaps.
- [x] Add Matches List Widgetbook states for pinned header/search, host filter, async loading/error, populated rows, new match row treatment, unread rows, own-latest-message rows, no matches, search empty, host unread empty, match celebration, text scale, reduced motion, and light/dark.
- [x] Add Match Chat Widgetbook states for top bar/action menus, event context header, message list, message bubbles, composer, image action, share card/sheet, Suvbot controls, mutation error listeners, text scale, reduced motion, and light/dark.
- [x] Add deterministic Matches List captures for loading, match-load error, no matches, search empty, populated, host filter, unread-only empty, offline, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Match Chat captures for messages loading/error, empty thread, populated thread, missing match, blocked chat, send failure, image send states, report/block, share-card sheet, Suvbot, offline, keyboard open, text scale, reduced motion, and light/dark.
  - Baseline route captures are registered for loading/error/offline, empty,
    populated, missing/blocked, image thread, Suvbot, share-card, composer,
    text-scale, reduced-motion, and paired light/dark. Remaining static capture
    work is interaction-driven send/report/block mutation proof and stricter
    keyboard-open snapshots.
- [ ] Introduce `MatchesListScreenState` or equivalent route adapter so search/filter state, visible threads, host variants, and match-celebration side effects are adapter-owned.
- [ ] Introduce `MatchChatScreenState` or equivalent route adapter so uid/match/messages/event/profile/Suvbot provider waves, read-marker side effects, action availability, and disabled-composer copy are resolved outside visual sections.
- [ ] Resolve `ChatNewMatchesRail`: wire it into the screen, delete it if it is obsolete, or register it as a future section if the design system still wants a separate new-matches rail.
- [ ] Add explicit offline copy and captures for match list and chat provider failures instead of relying only on generic chat error mapping.
- [x] Export canonical populated Matches List and Match Chat design references and define first-pass masks for safe-area, timestamps, remote photos, message times, composer/safe area, and unread counters.
- [ ] Export remaining Matches/Chat references for empty/new-match, keyboard-open, share-card, report/block dialog, generated share-card rasterization, and dynamic message-time variants.

### Profile And Public Profile

- [x] Register `screen.profile.self` and `screen.profile.public` with route, provider/controller ownership, capture refs, state coverage, section composition, and open gaps.
- [x] Add Self Profile Widgetbook states for route adapter, header/tab switcher, edit tab, photo grid, info sections, inline editors, preview tab, unavailable state, loading, error, upload failure, inline save failure, text scale, reduced motion, and light/dark.
- [x] Add Public Profile Widgetbook states for route adapter, top bar/actions, profile surface, report sheet, block dialog, mutation overlay, loading, error, unavailable, offline, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Self Profile full-route captures for edit tab, preview tab, loading, error, unavailable profile, upload pending/failure, inline save pending/failure, offline, text scale, reduced motion, and paired light/dark states.
- [ ] Add deterministic Public Profile route captures for cold loading, initial-profile fallback, load error, unavailable profile, own-profile viewer context, report/block pending and failure, offline, text scale, reduced motion, and paired light/dark states.
- [ ] Introduce `SelfProfileScreenState` or equivalent route adapter so profile provider waves, photo upload state, inline save mutations, public-profile projection, section display rows, retry intents, and route callbacks are resolved outside visual sections.
- [ ] Introduce `PublicProfileScreenState` or equivalent route adapter so target profile, initial-profile fallback, viewer context, safety-action availability, report/block mutation modes, retry intents, and mutation overlay state are resolved outside visual sections.
- [ ] Decide whether `PhotoGrid`, `ProfileInfoSection`, inline profile editors, and `ProfileSurface` should be promoted into reusable component/section contracts after host profile and public profile reuse are compared.
- [ ] Replace or supplement `profile_self` with full-route captures; the current capture is a deterministic `CatchProfileView` fixture tagged to `profileScreen`, not the full edit-tab route chrome.
- [x] Export canonical self-profile edit/preview and public-profile design references and define masks for profile photos and safe-area variance.
- [x] Add baseline advisory pixel comparison notes for self-profile and public-profile captures: `profile_self_edit_tab` is within threshold at 14.80% mismatch / 16.59 mean delta, `profile_self_preview_tab` is above threshold at 19.98% / 26.87, and `public_profile_member` is above threshold at 40.49% / 44.90.
- [ ] Decide whether analytics panels, sheets, snackbars, and selected safety reasons need additional canonical profile references.

### Host Home

- [x] Register `screen.host.home` with route, provider/repository ownership, state coverage, section composition, and open gaps.
- [x] Add first-pass Host Home Widgetbook route states for auth required, host clubs loading/error, empty host account, populated, text scale, reduced motion, and dark theme.
- [ ] Add provider-free Host Home section previews for host operations top bar, club switcher, selected-club metadata, upcoming events section, event row, and empty/access states after `HostHomeScreenState` exists.
- [ ] Add deterministic Host Home captures for signed-out/access, host clubs loading, host clubs error, no host clubs, one owned club, multiple club switcher, co-host role, event-list loading, empty events, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostHomeScreenState` or equivalent route adapter so auth, hosted/owned club merge, selected club, event sorting/filtering, retry intents, and create/manage route callbacks are resolved outside visual sections.
- [ ] Move `_HostEventsClubCard` event sorting/filtering and row action construction into the Host Home adapter before visual parity edits.
- [ ] Decide whether `_HostOperationsTopBar`, `_HostMetaRow`, `_HostEventRow`, and `_HostEmptyState` stay screen-local or promote after Host Clubs, Host Club Detail, and Host Manage prove reuse.
- [x] Export canonical Host Home Today reference and define first-pass masks for dynamic event dates, club names, host role labels, event titles, counts, and host-shell safe areas.
- [ ] Export remaining Host Home references for loading, empty, cohost/role, Host Events tab with matching capture, offline/error, text scale, reduced motion, and light/dark.
- [ ] Create a dedicated host-shell capture fixture; `hostHomeScreen` currently has no deterministic capture entry.

### Host Clubs

- [x] Register `screen.host.clubs` with route, provider/repository ownership, state coverage, section composition, and open gaps.
- [x] Add first-pass Host Clubs Widgetbook route states for loading/error/empty, owner and co-host clubs, text scale, and dark theme.
- [ ] Add provider-free Host Clubs section previews for top bar, club switcher, tab rail, profile editor, inline text editor, inline choice editor, event defaults, payouts, host team, insights, preview, empty, auth required, loading, error, offline, text scale, reduced motion, and light/dark after `HostClubsScreenState` exists.
- [ ] Add deterministic Host Clubs captures for signed-out/access, host clubs loading, host clubs error, no host clubs, owned club edit tab, co-host limited edit tab, multiple club switcher, inline save pending/failure, payouts states, host-team mutation states, insights loading/report/error, preview tab, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostClubsScreenState` or equivalent route adapter so auth, hosted/owned club merge, selected club, selected tab, role capabilities, inline patch display data, payout state, team state, analytics query state, retry intents, and route callbacks are resolved outside visual sections.
- [ ] Move `_HostInlineClubSaveState` repository writes and patch construction out of private inline editor widgets before visual parity edits.
- [ ] Move `HostPaymentAccountCard` Stripe onboarding/refresh mutations into a payment controller or explicit section adapter before broader design-system refactors.
- [ ] Keep `HostTeamManagementController` as the mutation owner, but move sheet/dialog presentation state and section fixtures into reusable fakes for Widgetbook.
- [ ] Add host analytics fixtures for full, sparse, partial, empty, error, event-scoped, custom-range, and data-quality states before comparing pixels.
- [ ] Decide whether `_HostOperationsTopBar`, `_HostMetaRow`, `_HostClubTabRail`, `_HostEmptyState`, inline editors, payout card, and host-team section stay screen-local or promote after Host Club Detail and Host Manage prove reuse.
- [x] Export canonical Host Clubs Organizer reference and define first-pass masks for dynamic analytics values, dates, club names, team names, payout state, and host-shell safe areas.
- [ ] Export remaining Host Clubs references for cohost, empty, loading/error, analytics, payout, inline editor, team mutation, text-scale, reduced-motion, light/dark, sheets, and dialogs.
- [ ] Create a dedicated host-shell capture fixture; `hostClubsScreen` currently has no deterministic capture entry.
- [ ] Resolve or intentionally allow the new hygiene advisory scope for `lib/hosts/presentation/widgets/host_team_management_section.dart` before promoting hygiene checks to blocking.

### Host Club Detail

- [x] Register `screen.host.club.detail` with route, shared `ClubDetailScreen` implementation ownership, host role derivation, state coverage, section composition, and open gaps.
- [x] Pass host route state into `ClubScheduleSection` so hosted schedule rows use host-specific badge/copy instead of member-style schedule treatment.
- [x] Add first-pass Host Club Detail Widgetbook public-preview route states for host preview, initial-club loading fallback, load error, not found, non-host preview, and text scale.
- [ ] Add provider-free Host Club Detail section previews for public club profile body, hero, stats, public host identity, overview/tags/photos/contact, hosted schedule, reviews, host action boundary, loading, initial-club fallback, not found, error, unauthorized, offline, text scale, reduced motion, and light/dark after `HostClubDetailScreenState` exists.
- [ ] Add deterministic Host Club Detail captures for public preview, initial-club loading, loading, error, not found, host-not-on-team, signed-out, empty schedule, hosted schedule, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostClubDetailScreenState` or equivalent route adapter so host role, access, initial data, schedule callbacks, dock suppression, contact/share side effects, retry intents, and public-preview mode are explicit.
- [ ] Decide whether Host Club Detail is public-preview-only or should include Edit club, Add event, payouts, and team controls; right now those actions remain in Host Clubs and Host Home.
- [ ] Decide whether `ClubHeroAppBar.isHost` should become visible host-preview language or be removed from the hero contract; it is currently passed through but not rendered by the hero.
- [ ] Keep provider-backed `ClubMembershipDock` consumer-only; Host Club Detail suppresses it, so provider-free `CatchClubDock` promotion only makes sense if another host/member surface proves the same dock contract.
- [ ] Move host/member event-route selection, review visibility, contact launching, host messaging eligibility, and share side effects into adapters before visual parity edits.
- [x] Export canonical Host Club Detail owner/public-view design reference and define first-pass masks for hero images, club identity, dynamic club stats, event dates, and scroll safe areas.
- [ ] Export remaining Host Club Detail variants if host controls move into this public-preview route; otherwise keep operational controls in Host Home/Host Clubs/Host Manage.

### Host Create Event

- [x] Register `screen.host.event.create` with route wrapper, club fetch ownership, create-event wizard ownership, submit/draft mutation ownership, state coverage, section composition, and open gaps.
- [x] Add first-pass Host Create Event Widgetbook route wrapper, route loading/error/missing-club states, wizard steps, and created-success state.
- [ ] Add provider-free Host Create Event previews for wizard shell, step header, basics step, ordered event photos, location step, map handoff, schedule step, event policy step, Event Success guide step, draft picker/save/delete states, submit error banner, offline, text scale, reduced motion, and light/dark after `HostCreateEventScreenState`/`CreateEventWizardState` exists.
- [ ] Add deterministic Host Create Event captures for route loading, route error, missing club, every wizard step, validation errors, submit pending/error, draft restore/save/delete, unsaved changes dialog, success, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostCreateEventScreenState`/`CreateEventWizardState` or equivalent adapters so route club loading, form draft, validation, submit state, draft state, photo picker, map/date/time pickers, Event Success defaults, and navigation callbacks are explicit outside visual sections.
- [ ] Decide whether non-host-team users should see a host-specific unauthorized state before `CreateEventScreen` renders, instead of relying only on repository/security-rule failures.
- [ ] Add or promote shared fakes for route club loading/error, draft lists, map results, picked event photos, submit mutation states, created events, and Event Success defaults.
- [ ] Move draft load timing, active draft signature, save/update/delete feedback, unsaved changes dialog, and snackbar proof into a draft adapter before visual parity edits.
- [ ] Move submit pending/error and success navigation out of the screen body into a create-event adapter before visual parity edits.
- [ ] Export canonical Host Create Event design references and define masks for map tiles, dates/times, generated draft timestamps, picked photo previews, celebration effects, snackbars, and dynamic event ids.
  - Basics, location, schedule, policy, and Event Success guide PNGs are
    exported under `design/reference_screens/screen.host.event.create/`,
    masked in `design/reference_screens/screen.host.event.create/masks.json`,
    and manifest-registered against `host_create_basics`,
    `host_create_location`, `host_create_schedule`, `host_create_policy`, and
    `host_create_guide`.
  - Remaining work: export and register draft, validation, submit, unsaved
    changes, and success states.
- [ ] Resolve or intentionally allow the new hygiene advisory scope for `lib/hosts/presentation/event_management/create/create_event_screen.dart` and `lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart` before promoting hygiene checks to blocking.

### Host Event Manage

- [x] Register `screen.host.event.manage` with route loading/access ownership, Host Manage setup/live/report composition, roster ownership, Event Success host ownership, private invite access, host actions, capture refs, state coverage, and open gaps.
- [x] Decide `hostAppAttendanceSheet` alias ownership: keep it aliased to `hostAppEventManageScreen` because it opens the canonical Live roster section of `screen.host.event.manage`.
- [x] Decide `hostAppEventSuccessScreen` alias ownership: keep it aliased to `hostAppEventManageScreen` because it enters the canonical Host Event Manage/Event Success workspace.
- [x] Add first-pass Host Event Manage Widgetbook route/section states for route loading/error/not-found/unauthorized, setup/private access, live console, report workspace, attendance/private-access/invite-link errors, text scale, and dark theme.
- [ ] Add provider-free Host Event Manage section previews for top bar/section picker, full-event apron, setup participants, summary, private access, invite links, Event Success setup, live console, report workspace, host actions, access/loading/error, offline, text scale, reduced motion, and light/dark after `HostEventManageScreenState` exists.
- [ ] Add deterministic Host Event Manage captures for setup/private access, route loading, route error, missing event/club, unauthorized, attendance loading/error/empty, profile loading/error, private-access loading/error, invite links empty/active/disabled, cancelled event, cancel/delete pending/error, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostEventManageScreenState` or equivalent route adapter so uid, club, event, initial event extra, selected section, roster, private access, Event Success host state, host action availability, retry intents, and typed callbacks are explicit outside visual sections.
- [ ] Move invite-link create/copy/disable/share effects and edit/cancel/delete dialog/mutation orchestration into controllers or explicit adapters before visual parity edits.
- [ ] Keep `HostEventParticipantsPanel` as the roster/report seam for now, but split provider-backed attendance/profile/mutation state from provider-free board/table rendering before adding strict visual comparisons.
- [ ] Add report export states for unavailable, pending, failure, revenue/ops CSV, sparse participation data, and future backend settled-payment report replacement.
- [x] Export canonical Host Event Manage setup/private-access reference and define masks for event title/date, summary counts, invite-link count, and host-shell safe areas.
- [x] Add baseline advisory pixel comparison note for Host Event Manage setup/private-access: `host_manage_setup_private_access` is above threshold at 17.55% mismatch / 31.45 mean delta.
- [x] Export canonical Host Event Manage live console and post-event report references and define masks for live counts, report metrics, export rows, and host-shell safe areas.
- [ ] Export remaining Host Event Manage attendance/guests and private-access edge variants and define masks for roster/profile rows, QR codes, dynamic assignment/report counts, snackbars, dialogs, and host-shell safe areas.
- [ ] Resolve or intentionally allow the new hygiene advisory scope for `lib/hosts/presentation/host_event_manage_screen.dart` and `lib/hosts/presentation/widgets/host_event_attendance_panel.dart` before promoting hygiene checks to blocking.

### Host Inbox

- [x] Register `screen.host.inbox` with shared `ChatsListScreen` ownership, host inquiry filtering, search/filter ownership, async list states, row composition, state coverage, and open gaps.
- [x] Add first-pass Host Inbox Widgetbook states through the shared `ChatsListScreen` host-inbox fixture.
- [ ] Add provider-free Host Inbox section previews for browse header, search collapsed/expanded, All/Unread filter row, async body, attendee-query section, row list, row variants, no queries, no unread queries, search empty, error, offline, text scale, reduced motion, and light/dark after `HostInboxScreenState` exists.
- [ ] Add deterministic Host Inbox captures for loading, empty, populated, unread filter, no unread, search active, search empty, match stream error, mixed host/dating matches, duplicate inquiries, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostInboxScreenState` or equivalent adapter so uid, match provider waves, host inquiry filtering, search/filter state, empty/error selection, row display data, retry intents, and host-chat route callbacks are explicit outside visual sections.
- [ ] Decide whether Host Inbox should group professional inquiries by attendee or by event when one attendee asks about multiple events; current shared chat logic collapses duplicate match docs by other user.
- [ ] Decide whether profile/club loading should remain fallback-only (`Host conversation` / `Unknown`) or expose row skeletons for host inbox parity.
- [ ] Decide whether search-empty copy should say attendee queries instead of chats for host mode.
- [ ] Add a route/navigation test proving Host Inbox rows navigate to `hostChatScreen` and coordinate typed callbacks with `screen.host.chat`.
- [x] Export canonical populated Host Inbox design reference and define first-pass masks for timestamps, unread counts, profile photos, event identity, and host-shell tab chrome.
- [ ] Export remaining Host Inbox references for loading, empty, unread/no-unread, search, offline/error, text scale, reduced motion, light/dark, and keyboard/safe-area variants.

### Host Chat

- [x] Register `screen.host.chat` with shared `ChatScreen` ownership, professional host-inquiry identity, disabled profile/share actions, event context, message list, composer, safety actions, mutation listener, state coverage, and open gaps.
- [x] Finish the Host Chat proof pass: update `docs/widget_catalog.md`, run focused Chat tests, run focused analyzer, run JSON/diff scanners, and stamp the audit registry.
- [x] Add first-pass Host Chat Widgetbook states for host inquiry identity, messages loading/error, empty inquiry thread, blocked host chat, text scale, and reduced motion.
- [ ] Add provider-free Host Chat section previews for top bar, event context, message list, bubbles, composer, safety actions, mutation listeners, access/loading/error, keyboard, offline, text scale, reduced motion, and light/dark after `HostChatScreenState` exists.
- [ ] Add deterministic Host Chat captures for match loading/error, missing match, empty thread, populated thread, event context, message error, send pending/error, image pending/error, blocked chat, report/block, keyboard, offline, text scale, reduced motion, and paired light/dark.
- [ ] Introduce `HostChatScreenState` or equivalent adapter so uid, match, messages, event, club, profile, safety-action availability, read-marker effects, composer state, mutation modes, retry intents, and typed callbacks are explicit outside visual sections.
- [ ] Add host-specific tests for profile navigation disabled, share-card disabled, host inquiry identity fallbacks, Host Inbox row navigation, blocked host chat, and report/block menu behavior.
- [ ] Decide whether host inquiry empty-thread copy should use attendee-query language instead of consumer chat language.
- [ ] Decide whether image attachments belong in professional host conversations.
- [x] Export the first canonical Host Chat baseline reference and define first-pass masks for safe area, host identity, event-context copy, message timestamps/copy, and composer inset.
- [ ] Export dedicated Host Chat design variants for keyboard/safe-area, timestamps, remote photos, generated share-card rasterization if retained, dynamic message times, unread/read markers, host-shell tab chrome, accessibility, mutation, safety, offline, and theme states.

### Start, Auth, And Onboarding

- [x] Register `screen.start.welcome`, `screen.auth.phone_entry`, and `screen.onboarding.flow` with route ownership, controller/mutation ownership, capture refs, state coverage, section composition, and open gaps.
- [ ] Add Start Widgetbook states for animated reel, landed direct, skipped, CTA stack, reduced motion, text scale, and canonical theme treatment.
- [ ] Add Auth Widgetbook states for phone entry, country picker, validation errors, send-code pending/error, OTP entry, verify pending/error, resend cooldown, change-number, text scale, reduced motion, and theme variants.
- [ ] Add Onboarding Widgetbook states for every step, entry mode, validation state, saved draft, photo gate, upload/mutation pending/error, text scale, reduced motion, and theme variants.
- [ ] Add deterministic Start captures for reduced motion, text scale, CTA variants, and decide whether dark welcome is the only canonical theme.
- [ ] Add deterministic Auth captures for OTP entry, send/verify pending and failure, resend cooldown, validation errors, text scale, and reduced motion.
- [ ] Add deterministic Onboarding captures for every step, validation errors, photo upload/gate states, profile-completion-only entry, run-preferences-only entry, text scale, and reduced motion.
- [ ] Introduce `StartWelcomeScreenState`, `AuthScreenState` display adapter, and `OnboardingFlowState` or equivalents so motion mode, phone/OTP state, flow entry mode, progress, draft data, validation, mutations, and typed callbacks can render without live side effects.
- [ ] Export Start animated/reduced-motion/text-scale/theme variants, Auth OTP/mutation variants, and remaining Onboarding design references; define masks for animation frames, keyboard, date picker, country picker, OTP focus, photo picker/upload, prompt copy, safe-area, and sticky footer variance.

### Secondary Consumer Surfaces

- [x] Register `screen.calendar.home`, `screen.saved_events.list`, `screen.filters.preferences`, and `screen.event.recap` with route ownership, provider/controller ownership, capture refs, state coverage, section composition, and open gaps.
- [ ] Add Calendar Widgetbook states for collapsed/expanded header, stats, agenda rows, loading, empty, event stream error, club-name loading/error, selected day, text scale, reduced motion, and theme variants.
- [ ] Add Saved Events Widgetbook states for populated rows, empty, loading, stream error, club-name loading/error, past/saved row statuses, text scale, and theme variants.
- [ ] Add Filters Widgetbook states for default profile values, dirty edits, reset, loading, profile error, missing profile, save pending/error, text scale, reduced motion, and theme variants.
- [ ] Add Event Recap Widgetbook states for loading, error, missing event, populated attendees, empty roster, partial profile lookup, selected vibe tiles, open/closed catch window, text scale, reduced motion, and theme variants.
- [ ] Add deterministic Calendar captures for loading, empty, event stream error, club-name loading/error, expanded month, selected-day scroll, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Saved Events captures for empty, loading, error, club-name loading/error, past-only, removed/deleted event, text scale, and light/dark.
- [ ] Add deterministic Filters captures for loading, error, missing profile, dirty edit, reset, save pending/error, text scale, reduced motion, and light/dark.
- [ ] Add deterministic Event Recap captures for loading, error, missing event, empty roster, partial profile fallback, selected tiles, text scale, reduced motion, and theme variants.
- [ ] Introduce `CalendarHomeState`, `SavedEventsListState`, `FiltersPreferencesState`, and `EventRecapScreenState` or equivalents so provider waves, derived display rows, local draft/selection state, retry intents, and route callbacks can render without live side effects.
- [ ] Export canonical Calendar/Saved Events/Filters/Event Recap design references and define masks for dates, timestamps, remote photos, maps if introduced, keyboard/safe-area, selection state, and sticky bottom chrome.

### Club Detail

- [x] Finish proof pass for the newly registered `screen.club.detail` contract.
- [x] Add Widgetbook section states for hero, stats, hosts, overview, photos, contact, schedule, reviews, and membership dock.
- [x] Add Widgetbook screen states for loading, missing club, fatal error, member default, visitor, guest join, host public view, pending mutation, failed mutation, offline, text scale, and reduced motion.
- [x] Add deterministic route captures for member, visitor, guest, host public view, missing club, fatal error, pending mutation, failed mutation, offline, text scale, and reduced motion.
- [ ] Move any remaining membership-dock mode derivation, host-contact mutation copy, schedule empty-state copy, and review/photo/contact visibility decisions into adapters or controller-owned state before visual refactors.
- [x] Decide whether `CatchMetricStrip`, `ClubScheduleSection`, `ClubReviewsSection`, and `ClubMembershipDock` are reusable section contracts or stay local to `screen.club.detail`: Host Club Detail proves reuse for the shared public profile body, stats, schedule, host identity, contact, photos, and reviews; keep provider-backed `ClubMembershipDock` consumer-only, and promote provider-free `CatchClubDock` only if another host/member surface proves the same action dock contract.
- [x] Compare Club Detail member capture against `/Users/suvratgarg/Downloads/Catch Design System (2)/templates/catch-club-detail/ClubDetailV2.dc.html`: `club_detail_member` is above threshold at 31.35% mismatch / 49.79 mean delta, with divergence concentrated in hero media/chrome, next-event/stat-strip treatment, and below-fold schedule/dock composition.
- [ ] Record section-level visual divergence before changing layout, spacing, color, type, or hierarchy.

## Next Screen Contracts

### P1 Consumer Screens

- [x] `clubDetailScreen`: create `screen.club.detail`; include public club profile, host identity, schedule, membership actions, reviews, missing club, host-role public view, mutation errors, text scale, reduced motion.
- [x] `dashboardScreen`: create `screen.dashboard.home`; include upcoming event, notifications, recommendations, empty/dashboard-start states, loading, error, offline, and CTA states.
- [x] `eventSuccessCompanionScreen`: create `screen.event_success.companion`; include live guide, privacy/safety, empty/no-plan, loading, error, offline, and attendee-only states.
- [x] `swipeHubScreen`: create `screen.catches.hub`; include active catch window, no active events, loading, error, permission, empty, text scale, reduced motion.
- [x] `swipeEventScreen`: create `screen.catches.event`; include roster, candidate cards, decisions, empty roster, closed window, mutation pending/error, offline.
- [x] `matchesListScreen`: create `screen.matches.list`; include new matches, active conversations, empty, loading, error, offline, unread/notification states.
- [x] `chatScreen`: create `screen.matches.chat`; include message list, composer, typing/loading, send failure, empty thread, blocked/safety states, keyboard/text-scale states.
- [x] `profileScreen`: create `screen.profile.self`; include profile hero, photo grid, prompts, edit affordances, empty/incomplete states, loading, error, text scale.
- [x] `publicProfileScreen`: create `screen.profile.public`; include profile view, shared events/reviews context, private/missing user, loading, error, safety/report actions.

### P1 Host Screens

- [x] `hostHomeScreen`: create `screen.host.home`; include today overview, setup gaps, live events, empty host account, loading, error, offline.
- [x] `hostClubsScreen`: create `screen.host.clubs`; include club profile editor, owner/co-host variants, inline edits, payouts, host team, insights, preview, loading, error, offline, text scale, and reduced motion.
- [x] `hostClubDetailScreen`: create `screen.host.club.detail`; include public preview, shared stats/schedule/reviews, hosted schedule treatment, host-control gap, missing/unauthorized states, text scale, and reduced motion.
- [x] `hostCreateEventScreen`: create `screen.host.event.create`; include route loading, basics, location, schedule, policy, Event Success guide, validation, mutation pending/error, draft state, success, text scale, and reduced motion.
- [x] `hostAppEventManageScreen`: create `screen.host.event.manage`; include live console, attendance, post-event report, cancellation/delete actions, empty states, mutation errors.
- [x] `hostInboxScreen`: create `screen.host.inbox`; include host conversation list, empty, unread, loading, error, search/filter.
- [x] `hostChatScreen`: create `screen.host.chat`; include professional conversation thread, composer, send failure, empty, blocked, safety/report, keyboard/text-scale states.

### P2 Consumer Screens

- [x] `startScreen`: promote current matrix entry into `catch.screens.json`; include animated reel, landed direct, reduced motion, text scale, light/dark.
- [x] `authScreen`: promote current matrix entry into `catch.screens.json`; include phone entry, OTP, validation, submit mutation, error, text scale.
- [x] `onboardingScreen`: promote current matrix entry into `catch.screens.json`; include each onboarding step, validation, photo gate, disabled CTA, upload errors, text scale.
- [x] `calendarScreen`: create `screen.calendar.home`; include planned events, empty, loading, error, offline, event-card states.
- [x] `savedEventsScreen`: create `screen.saved_events.list`; include saved events, empty, loading, error, offline, removed/sold-out states.
- [x] `filtersScreen`: create `screen.filters.preferences`; include default filters, active filters, validation, clear/reset, loading/error for profile-backed defaults.
- [x] `eventRecapScreen`: create `screen.event.recap`; include attendee recap, empty/missing event, loading, error, permission, text scale.

### P2 Host Screens

- [x] `hostCreateClubScreen`: create `screen.host.club.create`; include basics, image picker, validation, mutation pending/error, success pop.
- [x] `hostEditClubScreen`: create `screen.host.club.edit`; include prefilled state, optional contact clearing, image replacement, validation, unauthorized/missing club.
- [x] `hostAppEditEventScreen`: create `screen.host.event.edit`; include prefilled event, schedule/location changes, validation, mutation pending/error, cancelled-event restriction.
- [x] `hostSettingsScreen`: create `screen.host.settings`; include account, profile, notification, payout/admin placeholders, loading/error.
- [x] `hostProfileScreen`: create `screen.host.profile`; include profile editing, photo/avatar, validation, mutation pending/error.

### P3 Screens

- [x] `eventLocationMapScreen`: create `screen.event.location_map`; include pin ready, no coordinate, network-tile disabled capture, error/retry, map masking.
- [x] `notificationsScreen`: create `screen.notifications.list`; include activity list, empty, loading, error, read/unread, deep-link failures.
- [x] `reviewsHistoryScreen`: create `screen.reviews.history`; include review list, empty, loading, error, event context missing.
- [x] `settingsScreen`: create `screen.settings.account`; include account, safety, payment, notifications, logout/delete flows, mutation errors.
- [x] `paymentHistoryScreen`: create `screen.payments.history`; include empty, populated, refund/pending statuses, loading, error.

### Aliases And Exclusions

- [x] Keep `hostAppAttendanceSheet` aliased to `hostAppEventManageScreen`; the host manage contract keeps attendance as the canonical Live roster section.
- [x] Keep `hostAppEventSuccessScreen` aliased to `hostAppEventManageScreen`; the host manage contract keeps Event Success host tools inside the canonical manage surface for now.
- [ ] Keep `loadingScreen` excluded unless launch UX becomes an explicit visual parity pass.
- [ ] Keep `paymentConfirmationScreen` excluded until deterministic transaction extras exist.
- [ ] Keep dev/lab/manual QA routes excluded from baseline parity unless they graduate into product routes.

## Widgetbook Backlog

- [ ] Keep primitive Widgetbook entries aligned with `design/components/catch.components.json`.
- [ ] Keep Widgetbook inventory aligned with `docs/design_parity/claude_widgetbook_inventory.md`.
- [ ] Add missing Widgetbook use cases for any component contract without a generated preview id.
- [ ] Add design-contract state labels to Widgetbook entries so reviewers can map states back to the registry.
- [ ] Add screen-state Widgetbook use cases for Start/Auth/Onboarding.
- [ ] Add section-level Widgetbook use cases for the next P1 contracts as they are created: host surfaces.
- [x] Add Event Detail section states for all registered and planned event detail compounds.
- [x] Add Explore section states for browse chrome, filter rail/sheet, CoverStory, CountPill, CrossPathsCard, mixed feed cards, map route, and empty/error states.
- [x] Add Club Detail section states for the newly registered screen contract.
- [ ] Reuse capture fixtures/fakes where possible so Widgetbook and route captures show the same data shape.
- [ ] Add fake repositories/providers for hard-to-reach states: offline, backend error, mutation pending, mutation failure, missing route params, permission denied.
- [ ] Add text-scale and dark/light preview coverage for P1 screen sections.
- [ ] Add reduced-motion preview coverage for hero, route transition, map, and animated reel states.

## Capture And Pixel Diff Backlog

- [ ] Export canonical Claude/Figma PNG references into `design/reference_screens/`.
- [ ] Define masks for dynamic regions: status bars, maps, timestamps, remote photos, generated counters, and live participant counts.
- [ ] Add advisory pixel comparison between `tool/ui_capture/run_captures.mjs` output and exported design references.
- [ ] Start with advisory thresholds; promote to blocking only after fixture stability is proven.
- [ ] Add captures for all P1 route loading, populated, empty, error, offline, permission, mutation, text-scale, and reduced-motion states.
- [x] Add capture coverage for Event Detail guest, host app, offline, text-scale, reduced motion, and individual booking states.
- [x] Add capture coverage for Explore map with network tiles disabled.
- [ ] Add capture coverage for Explore signed-in joined clubs, empty city, search/filter empty, offline/error, text scale, and reduced motion.
- [x] Add capture coverage for Club Detail member, visitor, guest, host, missing, error, offline, mutation, text-scale, and reduced-motion states.

## Component And Token Backlog

- [ ] Reconcile every Claude primitive against local component contracts, Widgetbook entries, and Flutter source.
- [ ] Reconcile every local primitive absent from Claude Design as keep, rename, deprecate, or needs-design-review.
- [ ] Promote missing Claude primitives into component contracts only when they are reusable outside one screen.
- [ ] Register event detail compounds or section contracts before visual refactors.
- [ ] Register Explore compounds or section contracts before visual refactors.
- [ ] Register future reusable Dashboard, Catches, Matches, Profile, and host compounds only after their second consumer is clear.
- [x] Decide whether section contracts live in `design/components/catch.components.json` as `screen-contract`/`pattern` entries or in a dedicated section registry.
- [ ] Keep foundation values in `design/tokens/catch.tokens.json` and Flutter values in `lib/core/theme`.
- [ ] Avoid adding new hand-rolled spacing, radius, color, typography, or layout constants inside screens.
- [ ] Keep website/social-template token needs in mind before making Flutter-only token names.
- [ ] Evaluate Style Dictionary/DTCG alignment before adding another custom token generator path.
- [ ] Decide the token export path for Flutter, website, and social media templates before adding new token categories.

## Implementation Migration Backlog

- [ ] For each contracted screen, define a small screen state object or adapter boundary before changing visuals.
- [ ] Move route widgets toward controller state plus section composition only.
- [ ] Move section data derivation out of visual widgets and into adapters/providers.
- [ ] Prefer provider-free visual sections that receive immutable view data and typed intent callbacks.
- [ ] Keep navigation intents at the route/screen boundary unless a shared component has an explicit navigation contract.
- [ ] Keep mutation orchestration in controllers, not UI sections.
- [ ] Keep repository reads behind feature-owned provider seams.
- [ ] Convert repeated private section widgets into registered section/component contracts only after confirming reuse.
- [ ] Keep local private widgets when they are only layout glue for one screen and not part of the design language.
- [ ] Preserve existing tests while adding fixtures/previews for every new state.
- [ ] Update `docs/widget_catalog.md` whenever widget ownership or reusable design-system roles change.

## Suggested Next Passes

1. Add Widgetbook states and deterministic captures for the newly contracted P3 utility surfaces.
2. Add Host Club Create/Edit, Host Event Edit, Host Settings, and Host Profile Widgetbook states and deterministic captures.
3. Add Profile/Public Profile Widgetbook states and deterministic captures.
4. Add Catches Hub/Event deterministic captures and start the adapter pass.
5. Add Matches List/Chat and Host Inbox/Host Chat Widgetbook states and deterministic captures.
6. Export canonical Claude/Figma PNG references and wire advisory pixel comparison.
