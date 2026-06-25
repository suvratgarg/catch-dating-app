---
doc_id: admin_dashboard_user_stories_and_component_catalogue
version: 0.2.0
updated: 2026-06-24
owner: admin_console
status: active
---

# Admin Dashboard User Stories And Component Catalogue

## Read Policy

Read this before adding, removing, renaming, or refactoring an admin dashboard
tab, feature workspace, or shared React admin component. Pair it with
`docs/admin_analytics_dashboard_spec.md`, `docs/controller_patterns.md`, and
`docs/data_contracts.md`.

## Audit Scope

This audit is based on the current React admin implementation under
`admin/src` after the feature-first and controller extraction passes.

Subagent roles used:

- Explorer: mapped every sidebar tab, sub-tab, owner file, data source, and
  obvious naming mismatch.
- Analyzer: wrote prospective user stories and judged current workflow fit.
- Critic: audited hand-rolled UI patterns and proposed primitive families.
- Synthesizer: judged feature-first/controller/repository scalability.

Files inspected:

- `admin/src/app/App.tsx`
- `admin/src/App.tsx`
- `admin/src/main.tsx`
- `admin/src/styles.css`
- `admin/src/shared/api/adminApi.ts`
- `admin/src/shared/api/firebase.ts`
- `admin/src/shared/api/sampleData.ts`
- `admin/src/shared/types/adminTypes.ts`
- `admin/src/shared/contracts/intakeApprovalContracts.ts`
- `admin/src/shared/ui/AdminPrimitives.tsx`
- `admin/src/features/marketing/api/marketingRepository.ts`
- `admin/src/features/marketing/controllers/useMarketingOpsController.ts`
- `admin/src/generated/marketingOpsBridge.json`
- `admin/src/features/marketing/renderers/marketingFeatureDropRenderer.ts`
- `admin/src/features/marketing/ui/MarketingOpsScreen.tsx`
- `admin/src/shared/controllers/marketingReviewDecisionHelpers.ts`
- `admin/src/shared/ui/ReviewDecisionControls.tsx`
- `admin/src/features/intake/events/api/eventIntakeRepository.ts`
- `admin/src/features/intake/events/controllers/useEventIntakeController.ts`
- `admin/src/features/intake/events/ui/EventIntakeWorkspace.tsx`
- `admin/src/features/intake/organizer/api/organizerIntakeRepository.ts`
- `admin/src/features/intake/organizer/controllers/organizerIntakeHelpers.ts`
- `admin/src/features/intake/organizer/controllers/useOrganizerIntakeController.ts`
- `admin/src/features/intake/organizer/generated/organizerIntakeBridge.json`
- `admin/src/features/intake/organizer/types/organizerIntakeTypes.ts`
- `admin/src/features/intake/organizer/ui/OrganizerIntakeScreen.tsx`
- `admin/src/features/safety/api/safetyTriageRepository.ts`
- `admin/src/features/safety/controllers/useSafetyTriageController.ts`
- `admin/src/features/safety/ui/SafetyTriageScreen.tsx`
- `admin/src/features/growth/api/growthKpiRepository.ts`
- `admin/src/features/growth/controllers/useGrowthKpiController.ts`
- `admin/src/features/growth/ui/GrowthKpiScreen.tsx`
- `admin/src/features/finance/api/financeOpsRepository.ts`
- `admin/src/features/finance/controllers/useFinanceOpsController.ts`
- `admin/src/features/finance/ui/FinanceOpsScreen.tsx`
- `admin/src/features/events/api/eventPublishingRepository.ts`
- `admin/src/features/events/controllers/useEventPublishingController.ts`
- `admin/src/features/events/controllers/eventPublishingHelpers.ts`
- `admin/src/features/events/ui/EventPublishingScreen.tsx`
- `admin/src/features/access/api/accessReviewRepository.ts`
- `admin/src/features/access/controllers/useAccessReviewController.ts`
- `admin/src/features/access/ui/AccessReviewScreen.tsx`
- `admin/src/features/users/api/userAnalyticsRepository.ts`
- `admin/src/features/users/controllers/useUserAnalyticsController.ts`
- `admin/src/features/users/ui/UserAnalyticsScreen.tsx`
- `admin/src/features/data-quality/api/dataQualityRepository.ts`
- `admin/src/features/data-quality/controllers/useDataQualityController.ts`
- `admin/src/features/data-quality/ui/DataQualityScreen.tsx`
- `functions/src/admin/**` and `functions/src/clubs/clubClaims.ts` for API
  ownership context
- `docs/admin_analytics_dashboard_spec.md`
- `docs/plans/admin_analytics_dashboard_tracker.md`
- `firebase.json`
- `.github/workflows/admin-website.yml`

## Executive Findings

The folder direction is correct: `app`, `features`, and `shared` now exist, and
Overview, Marketing, Event Intake, and Organizer Intake have feature-owned
controllers. The implementation is still transitional.

The sidebar exposes 11 top-level tabs:

- Overview
- Safety
- Access
- Growth
- Marketing
- Intake
- Organizers
- Events
- Users
- Finance
- Data quality
- Admin roles

Overview, Safety, Access, Growth, Marketing, Intake, Organizers, Events, Users,
Finance, Data quality, and Admin roles now branch to dedicated surfaces. The
remaining roadmap material now lives in this audit document and in concise
topbar copy instead of taking over whole tabs.

The strongest current workflows are Marketing, Organizer Intake, Event Intake,
and the new canonical Organizers publishing workspace. Event Intake now owns its
admin read/write callables, generated bridge artifact, and guarded live
dashboard publish path. Organizers is now the first
fully real tab aimed at production supply bootstrapping: list rows come from
canonical `clubs/{id}` documents through `adminListClubDetails`, editing uses
audited partial `adminUpdateClubDetails` patches, and publishing uses
`adminSetClubIndexStatus` with a visible checklist. Its Indore + Mumbai default
is backend filtered through a bounded `citySlugs` payload instead of relying on
client-side filtering after a generic list fetch. Events has moved beyond the
old analytics/intake/marketing registry: the root Events tab is now a canonical
`events/{id}` list/detail/editor for safe app-facing fields, backed by
`adminListEventDetails`, `adminGetEventDetails`, and audited
`adminUpdateEventDetails` writes. It also lists read-only external event supply
from `externalEvents/{id}` through `adminListExternalEventDetails`, keeping
source-backed candidate supply separate from Catch-hosted event documents. It
now also exposes external import-plan and execution-preflight snapshots from
`eventSupplyReadiness/current`, with generated sample fallback, so operators can
see read-only draft counts, blockers, guardrails, and regeneration commands
before any importer exists. Its
Indore + Mumbai default uses the same bounded launch-city pattern.
Safety, Access, Growth, Users, Finance, and Data quality are
partial because some underlying signals/actions exist, but the full dedicated
operator workflows are not built.

## Top-Level Tab Inventory

| Tab | Current owner | Current data | Current actions | Fit |
|---|---|---|---|---|
| Overview | `features/overview` repository, controller, and UI | `loadOverview`, `loadHostAnalytics`, sample fallbacks, queue decision callables | refresh, date/geo scope, focus event, select/inspect queue rows, queue decisions | Good first dashboard; metric drilldown, saved filters, and cross-tab routing remain |
| Safety | `features/safety` | overview safety queues plus `adminGetSafetyTriageDetails` detail reads | filter/select triage rows, inspect normalized detail, assignment/SLA/evidence, assign owner, mark an explicitly selected row reviewed/dismissed with required notes | Partial triage workflow; assignment and status-only decisions are wired, while escalation, restrictions, and resolution actions still need audited callables |
| Access | `features/access` plus Overview quick actions | `adminGetOverview` access queue; `adminGetAccessApplicationDetails`; `adminDecideAccessApplication` | filter/select applications, inspect launch-access source fields and deterministic overlap signals, enter review note/cohort, explicitly approve/deny, track local recent decisions | Real launch-gate review workflow; broad user search, account, safety, payment, and referral-graph actions still need contracts |
| Growth | `features/growth` | overview metrics and host analytics | range-select launch KPIs, filter/select funnel-stage signals, inspect KPI source/detail/status, inspect booking trend and load metadata | Partial read-only KPI workspace; channel, cohort, referral, and campaign actions still need analytics contracts |
| Marketing | `features/marketing` | marketing ops bridge | draft creation, edit, review, export-ready decisions | Strongest product fit; review decisions now require notes and remain marketing-only, with no canonical event creation or auto-posting |
| Intake | `features/intake` | Event Intake reads `adminGetEventIntakeDashboard` and writes `adminRecordEventIntakeReviewDecision`; Organizer Intake reads generated organizer bridge artifacts | review event and organizer intake | Strong but dense |
| Organizers | `features/organizers` | canonical `clubs/{id}` list/detail via admin callables | filter/search canonical organizers, load details, edit, diff, validate, save, publish | First real canonical publishing workflow; route reservations, token search, and app preview are backed by canonical organizer fields |
| Events | `features/events` | canonical `events/{id}` list/detail, read-only `externalEvents/{id}` supply via admin callables, `eventSupplyReadiness/current` import-plan/preflight snapshots | filter/search canonical events from callable snapshot timestamps, select/inspect external supply attribution and duplicate signals, inspect import readiness, load details, edit safe app-facing fields, diff, validate, save | Real canonical cleanup workflow plus external supply visibility; lifecycle, pricing, schedule, cancellation, and import writes remain intentionally separate |
| Users | `features/users` | `adminGetUserAnalytics` aggregate response | jump exact `users/{uid}`/`uid:{uid}` from topbar or tab input, load one user id, inspect user-safe metrics, trend, summaries, data quality | Partial read-only analytics lookup; broad identity search, account, safety, payment, and support actions are not built |
| Finance | `features/finance` | overview payment issue rows, finance metrics, host analytics payment signals | filter/select finance issues, inspect explicitly selected event/payment/payout context, refresh read-only snapshot | Partial read-only issue workspace; provider ledger, reconciliation, refund, and payout actions still need contracts |
| Data quality | `features/data-quality` | overview quality rows, host analytics quality rows, marketing bridge freshness, Event Intake dashboard freshness, event supply readiness freshness/preflight blockers, source crawl run-plan health, event import execution-policy health | filter/search/select quality signals, inspect source/state/owner/runbook/action guidance, refresh read-only snapshot | Partial real operations workspace; stale generated artifacts are now separated from disabled/not-configured run plans, while scheduler last-run telemetry, backfill status, and remediation actions still need backend/source contracts |
| Admin roles | `features/admin-roles` | exact Firebase Auth uid lookups through `adminGetAdminUserRoles`; audited custom-claim writes through `adminSetAdminUserRoles`; `adminRoleAssignments/{uid}` register | load exact uid, inspect current roles, select allowed admin claims, require review note, save role changes | Real owner-only claim assignment workflow; broad admin-user directory/search and App Check diagnostics remain separate |

## Auth And Admin Roles

Current implementation:

- `admin/src/shared/api/firebase.ts` initializes Firebase Auth and signs in with
  Google popup.
- `admin/src/app/App.tsx` subscribes to `onAuthStateChanged` only in live mode.
- `VITE_ADMIN_DATA_MODE=sample` bypasses Auth entirely and now shows a visible
  "Sample mode · auth bypassed" status in the top bar.
- `VITE_ADMIN_DATA_MODE=live` shows the sign-in screen when no Firebase user is
  present. After sign-in, the shell reads custom admin roles from the ID token
  before any dashboard data loads.
- Signed-in users with no Catch admin custom claim are blocked on an
  unauthorized screen with Refresh claims and Sign out actions instead of seeing
  the full admin shell and waiting for callable failures.
- After at least one admin claim is present, the sidebar filters tabs by the
  live callable role allowlists. Overview remains available to every admin
  claim; host analytics are replaced with a restricted empty response when the
  current role cannot call `adminGetHostAnalytics`.
- Sign-in, claim refresh, and sign-out actions now expose pending state and
  visible errors instead of silently swallowing popup or Firebase Auth failures.
- Backend authorization is enforced by callable functions, not by the React
  shell. `functions/src/admin/adminAuth.ts` accepts these custom claims:
  `admin`, `adminOwner`, `safetyReviewer`, `support`, `finance`,
  `analyticsViewer`.
- `adminOwner` users can open Admin roles to load an exact Firebase Auth uid,
  inspect current Catch admin claims, set/remove allowed claims with a required
  audit note, and write the `adminRoleAssignments/{uid}` register. The backend
  blocks admin owners from removing their own `adminOwner` claim.

Role intent:

| Role | Intended scope |
|---|---|
| `adminOwner` | Full admin ownership, all dashboards/actions |
| `admin` | Broad internal operations |
| `support` | Access, organizer claim, and non-finance support actions |
| `safetyReviewer` | Safety queues and limited user/event safety context |
| `finance` | Payment, refund, payout, settlement, and finance exports |
| `analyticsViewer` | Read-only aggregate analytics |

Open auth gaps:

- The client role map is a convenience layer only; per-action enforcement still
  happens when callables are invoked.
- Admin roles is exact-uid based; it does not provide broad auth-user search,
  email/name lookup, or a complete historical directory for roles assigned
  manually before the register existed.
- There is no visible App Check/auth environment diagnostic beyond the current
  data-mode/auth-status display.

## Top-Level User Stories

### Overview

As an ops lead, I need a daily command center so I can spot launch health, open
queues, and risky marketplace signals before they become incidents.

Acceptance criteria:

- Shows fresh key metrics with source timestamp and loading/error state.
- Shows safety, access, claim, index, moderation, and payment queues.
- Lets me scope by date, organizer, or event.
- Lets me drill from a queue row or metric into the owning workflow.
- Separates data quality warnings from product risk warnings.

Current adherence:

- Good: metrics, live queues, host analytics, event table, data quality rows,
  refresh, sample/live mode, and feature-owned Overview repository,
  controller, and UI are present.
- Good: queue rows are selectable, all rows in each queue group are visible,
  and the selected row exposes target path, status, created time, detail, and
  owning workflow guidance.
- Weak: no metric drilldown, pagination, saved filters, or cross-tab row
  routing exists yet.

Recommended next work:

- Route queue rows to the owning feature tab.

### Safety

As a safety reviewer, I need to investigate user and event reports with
evidence, history, policy context, and audited actions so I can resolve,
escalate, restrict, or notify safely.

Acceptance criteria:

- Dedicated safety queue with severity, SLA, status, and assignment.
- Report detail with reporter, subject, event, evidence, previous actions, and
  policy guidance.
- Actions for resolve, escalate, block/restrict, request more info, and note.
- Audit log for every privileged action.
- Clear separation between user safety and event safety reports.

Current adherence:

- Good: safety reports appear in Overview queues and in a dedicated Safety tab.
- Good: detail reads are normalized through `adminGetSafetyTriageDetails`.
- Good: detail reads now include backend-owned assignment, SLA, severity, and
  evidence metadata so operators are not inferring routing from free text.
- Good: detail reads now include bounded prior-history joins and deterministic
  outcome guidance, so reviewers can see repeated-user/event context and which
  outcomes are queue-only, manual, or still blocked on a dedicated contract.
- Good: `adminAssignSafetyTriageItem` supports explicit assignment/unassignment
  with required notes, role gates, partial updates, and audit logs.
- Partial: `adminDecideSafetyTriageItem` supports reviewed/dismissed
  status-only decisions with explicit row selection and required notes.
- Weak: escalation, restrictions, account/content changes, and richer
  resolution actions are still intentionally absent because the current
  `reports`, `moderationFlags`, and `eventSafetyReports` schemas only support
  queue status/assignment fields.

Recommended next work:

- Add audited escalation, restriction, and resolution callables with separate
  role gates.
- Add the corresponding account/content/event safety document contracts before
  enabling destructive safety actions from the admin console.

### Access

As launch/support ops, I need to approve or deny access applications with enough
applicant context so the launch cohort stays controlled.

Acceptance criteria:

- Full application detail, identity signals, source/referral, and history.
- Approve/deny with review note and optional cohort tag.
- Duplicate/provenance check.
- Audited callable write and optimistic UI update.

Current adherence:

- Good: the tab is feature-owned under `features/access`; it loads
  `overview.queues.accessApplications`, supports search/select, requires an
  explicitly selected application and review note, collects optional
  `cohortId`, calls `adminDecideAccessApplication`, removes reviewed rows
  locally, and shows recent session decisions.
- Good: selected rows now load `adminGetAccessApplicationDetails`, exposing
  city, role, event types, availability windows, host interest, invite code,
  Instagram, referral source, Why Catch, submission count, timestamps, and
  bounded deterministic overlap signals before an operator decides.
- Good: Overview still keeps compact approve/deny shortcuts for queue triage.
- Weak: broad identity search, account state, safety history, payment history,
  and referral graph actions are still intentionally outside Access.

Recommended next work:

- Keep account/safety/payment actions out of Access until those workflows have
  audited callables and clear ownership.
- Add a broader user/referral lookup only after deciding whether it belongs in
  Users, Growth, or a launch-access-specific contract.

### Growth

As a growth lead, I need cohort, funnel, referral, waitlist, claim, and
activation reporting so I can decide where acquisition is working.

Acceptance criteria:

- Signup, onboarding, referral, waitlist, booking, claim, and activation funnels.
- Channel, city, date, and cohort filters.
- Retention and conversion breakouts.
- Links from growth anomalies to users, events, organizers, or campaigns.

Current adherence:

- Good: Growth is feature-owned under `features/growth` and has a dedicated
  read-only KPI workspace.
- Good: it combines overview metrics and host analytics into acquisition,
  supply, conversion, and marketplace stages with range and stage filters plus
  booking trend buckets, and labels the combined dashboard timestamp as load
  time rather than source-generated attribution.
- Good: the KPI table now has explicit signal selection and a detail panel for
  metric value, stage, status, source, and source-specific detail.
- Weak: no channel attribution, referral graph, cohort analysis, campaign
  action workflow, export workflow, or linked anomaly drilldown exists yet.

Recommended next work:

- Add channel/cohort/referral dimensions to the analytics contracts and
  BigQuery marts before adding campaign workflows.
- Keep campaign tasking and export actions out of Growth until attribution
  contracts exist.

### Marketing

As a content operator, I need to turn verified event and product inputs into
reviewed Instagram-ready content without implying Catch hosts third-party
events.

Acceptance criteria:

- Verified event/product input pool.
- Draft creation for event highlights and feature explainers.
- Editable slides, captions, compliance notes, and export settings.
- Step-by-step composer that shows one decision stage at a time.
- Review decisions with notes, blocked approval reasons, and audit trail.
- Manual export-ready state and PNG export.

Current adherence:

- Good: Posts board, New post flow, Composer, Event library, Media library,
  Activity, feature-drop renderer, review footer, and draft creation exist.
- Good: event inputs are labeled as reviewed marketing leads and candidate
  pools, not canonical `events/{id}` records. Canonical imports and app-event
  cleanup remain in Intake, Events, and Organizers.
- Good: the tab now shows a top-level action-boundary panel clarifying that
  Marketing writes review decisions and content drafts only, while canonical
  supply writes, booking, payments, waitlists, and direct Instagram posting stay
  outside this workspace. The composer event-pick step also labels event
  selection as read-only source visibility for the current draft.
- Weak: event selection is still partly display-only, some draft mutations are
  local until review, and direct Instagram publishing is intentionally not
  implemented.

Recommended next work:

- Keep Marketing focused on content packaging and manual export.
- Keep review-decision controls in shared admin UI because Marketing and Event
  Intake share the same button/card interaction pattern, even though their
  decision writes now use separate callables and collections.
- Split visual regions out of the large screen file.

### Intake

As an intake operator, I need one place to review event and organizer inputs
before they become canonical, public, or available to Marketing.

Acceptance criteria:

- Separate but adjacent event and organizer intake workspaces.
- Explicit status gates for source evidence, duplication, location, policy,
  publication, and claim handoff.
- Review decisions with notes and audit trail.
- Clear boundary between approved intake records and canonical app/website
  consumable records.

Current adherence:

- Good: Intake now covers Event Intake and Organizer Intake.
- Good: Organizer Intake exposes the deterministic discovery search plan,
  launch-city search terms, source config files, and operator commands, so
  search-term iteration is visible even though edits still happen in repo-owned
  JSON rather than a live web form.
- Good: Event Intake now uses event-owned read and review-decision callables.
- Good: Event Intake source and candidate cards now expose deterministic
  provenance from the bridge, including source profile ids, query template ids,
  observed timestamps, and linked source-result ids.
- Good: `tool/marketing/event_guide/publish_event_intake_dashboard.mjs` gives
  ops a guarded dry-run/apply path to publish the generated Event Intake bridge
  to `eventIntakeDashboards/current` without writing Marketing dashboards,
  canonical events, or `externalEvents/{id}`.
- Good: the Intake entry point now shows a publication-boundary panel for both
  Event leads and Organizers, making the active read model, permitted decision
  writes, blocked canonical/app-facing writes, and required review gates visible
  before an operator enters the dense generated workspaces.
- Weak: organizer intake is operationally dense and mostly driven by generated
  bridge JSON.
- Weak: Event Intake approvals remain decision records only; canonical import
  and external event promotion still need a dedicated reviewed write path.

Recommended next work:

- Add a safe admin edit/publish path for discovery search config only after
  the repo-file workflow is stable enough to replace with audited mutations.
- Keep organizer publication, app visibility, and public website listing output
  aligned with shared contracts to avoid schema drift.

### Organizers

As organizer support/ops, I need to load, clean, verify, and publish organizer
listing fields before claim, indexing, or app visibility changes.

Acceptance criteria:

- Search by name, slug, URL, Instagram, or document ID.
- Safe editable fields with validation and before/after diff.
- Public preview and app preview.
- Evidence links and route reservation checks.
- Audited save.

Current adherence:

- Good: the tab is feature-owned under `features/organizers`; it starts from a
  searchable/filterable canonical organizer directory backed by
  `adminListClubDetails`; selecting a row loads `clubs/{id}` through
  `adminGetClubDetails`; editing builds minimal audited partial patches for
  `adminUpdateClubDetails`; the UI shows before/after diff, validation,
  publish checklist, and public preview link; publish state goes through
  `adminSetClubIndexStatus`.
- Good: save checks and publishing checks are separated in the side panel. The
  UI only asks for a review note when there are pending save changes or a
  publishing decision, and both organizer edit/index callables now enforce
  review notes server-side before writing audit-logged mutations.
- Good: the organizer directory exposes the callable `generatedAt` snapshot
  timestamp in the publishing contract panel, matching the canonical Events
  tab's operator snapshot pattern.
- Good: route shape, duplicate canonical path checks, and durable
  `publicRouteReservations/{routeKey}` writes run server-side before save or
  index-ready publish. This prevents two `clubs` documents from owning the same
  `publicPage.canonicalPath` and gives website routing an explicit allocation
  record.
- Good: `adminListClubDetails` now uses `clubs/{id}.adminSearch.tokens` for
  token-backed large-list search when an operator enters a query. Admin save and
  index-ready publishing rebuild that projection from canonical organizer
  fields, and the list exposes missing search-index state.
- Good: client-side filters no longer re-run the operator query against the
  visible table row fields, so backend matches from URL, Instagram, or other
  admin-search tokens are not dropped after `adminListClubDetails` returns.
- Good: the launch-city default sends `citySlugs: ["indore", "mumbai"]` to the
  backend, avoiding incomplete client-filtered batches once the organizer
  collection grows.
- Good: existing live organizers created before the admin-search projection can
  be repaired with dry-run-first
  `tool/data/backfill_organizer_admin_search.mjs`.
- Good: the side panel now includes an app listing preview from the same
  `clubs/{id}` fields consumed by Flutter: visibility, location, display
  category, image/logo state, tags/formats, and listing copy.
- Weak: the search token strategy is deterministic and cheap, but it is not
  typo-tolerant or ranked like a dedicated search service.

Recommended next work:

- Dry-run `tool/data/backfill_organizer_admin_search.mjs` in dev/staging/prod
  and apply it after reviewing counts.
- Consider a dedicated search service only if operators need typo tolerance,
  ranking, or cross-field relevance scoring beyond deterministic token match.

### Events

As event ops, I need to inspect canonical app events and safely correct the
display/search fields consumed by the Flutter app without bypassing host event
mutation side effects.

Acceptance criteria:

- Searchable canonical `events/{id}` directory with launch-city filters.
- Read-only external `externalEvents/{id}` supply directory with launch-city
  filters and source attribution.
- Read-only external event import-plan and execution-preflight status so
  operators can see deterministic blockers before enabling any write path.
- Detail view sourced from the same event document the app reads.
- Safe editable fields with validation and before/after diff.
- Read-only visibility into schedule, capacity, price, status, availability,
  and discovery projection.
- Audited save that rebuilds deterministic admin search and event discovery
  projections.
- No lifecycle mutation until schedule locks, participants, policy, payments,
  private access, and notifications are handled through the existing event
  mutation path.

Current adherence:

- Good: the tab is feature-owned under `features/events`; it starts from a
  searchable/filterable canonical event directory backed by
  `adminListEventDetails`; selecting a row loads `events/{id}` through
  `adminGetEventDetails`; editing builds minimal audited partial patches for
  `adminUpdateEventDetails`; the UI shows before/after diff, validation, app
  preview, discovery projection, and search-index state.
- Good: the Events tab now also lists read-only external event supply through
  `adminListExternalEventDetails` against `externalEvents/{id}`. This keeps
  source-backed event candidates visible without merging crawler artifacts into
  canonical Catch-hosted `events/{id}` documents.
- Good: external supply rows are selectable and expose source URL, candidate id,
  normalized duplicate key, review batch, reviewer, publication state, and
  owner-safe copy/import-policy checks before any importer writes documents.
- Good: canonical event cleanup and external supply review now have separate
  search and filter state. The canonical table can focus on Full or Search
  issues without making the external supply queue look empty, while the
  external table defaults to the open Indore + Mumbai review queue.
- Good: the selected external supply row now joins against the current import
  plan and execution preflight snapshot, exposing whether the row is published
  external supply, preflight-ready but write-disabled, blocked, waiting review,
  rejected, merged as a duplicate link, or missing from the current readiness
  snapshot.
- Good: the tab now reads external event import plan and execution preflight
  snapshots through `adminGetEventSupplyReadiness` from
  `eventSupplyReadiness/current` in live mode, with generated sample fallback.
  Read-only draft counts, blockers, guardrails, source files, and operator
  commands are visible next to the external supply table.
- Good: import-plan actions now render as a searchable/filterable directory
  over the readiness snapshot instead of a short fixed slice. Operators can
  focus on Needs action, Write-ready, Blocked, Waiting, Rejected, or All actions
  without enabling Firestore writes.
- Good: `adminPublishExternalEvent` now provides a gated one-row publish path
  from a preflight-approved action into read-only `externalEvents/{id}` supply.
  The UI requires a review note and preflight, outbound-link,
  no-Catch-booking/payment/waitlist, and owner-safe-copy checklist confirmations
  before enabling a row's Publish action. The callable still refuses disabled
  readiness policy, blocked actions, invalid projections, existing documents,
  and canonical `events/{id}` writes.
- Good: `tool/organizer_intake/publish_event_supply_readiness.mjs` gives ops a
  dry-run-first, prod-guarded way to publish the generated plan/preflight
  artifacts into the live Events admin read model without writing
  `externalEvents/{id}`.
- Good: the launch-city default sends `citySlugs: ["indore", "mumbai"]` to the
  backend with `status: "active"` and `timeWindow: "upcoming"`, avoiding
  incomplete client-filtered batches and arbitrary limited result slices once
  the events collection grows.
- Good: sample mode now uses explicit canonical Indore and Mumbai event records
  instead of deriving the Events directory from host analytics rows, so the
  default tab demonstrates the real launch-city workflow.
- Good: `events/{id}.adminSearch.tokens` is server-owned and deterministic, so
  operator search can improve through backfills/saves without changing app
  runtime fields.
- Good: client-side canonical and external event filters no longer re-run the
  operator query against visible row fields, so backend token/source matches are
  preserved after the callable returns.
- Good: event save also rebuilds `eventDiscoveryProjection`, keeping activity,
  availability, age, and gate projections aligned with safe admin changes.
- Good: existing live events created before this projection can be repaired
  with dry-run-first `tool/data/backfill_event_admin_search.mjs`.
- Weak: schedule, capacity, price, event policy, cancellation, attendance,
  waitlist, safety, and payment actions are deliberately read-only in this tab.
  Those still need dedicated flows because the host event mutation code has
  schedule-lock, participant, private access, policy, payment, and notification
  side effects.
- Weak: bulk or scheduled imports are still not enabled. Admin can publish one
  preflight-ready `externalEvents/{id}` row only after the readiness authority
  policy is explicitly enabled; recurring importer defaults, rollback, and app
  outbound-link behavior still need production review.

Recommended next work:

- Dry-run `tool/data/backfill_event_admin_search.mjs` in dev/staging/prod and
  apply it after reviewing counts.
- Add event lifecycle actions only through a shared admin/host mutation service
  that preserves schedule locks, participant guards, private access sync,
  event policy, and notifications.
- Add linked payment/safety/attendance panels after the owning Finance and
  Safety workspaces exist.
- Add the disabled policy-owned importer that writes reviewed candidates to
  `externalEvents/{id}` after preflight validation and keeps external booking
  outbound-only.

### Users

As support/safety/growth ops, I need a user lookup and risk/value profile so I
can resolve account issues and understand marketplace quality.

Acceptance criteria:

- Working user search.
- Read-only aggregate analytics lookup for a selected user id.
- Profile, account status, reports, payments, attendance, referrals,
  moderation, and audit history.
- Safe role-scoped actions.

Current adherence:

- Good: the tab is feature-owned under `features/users` and calls
  `adminGetUserAnalytics` for one selected `users/{uid}`. It surfaces
  user-safe summary cards, trend buckets, connection/profile aggregates,
  coaching refs, data-quality rows, and the read-only/audit boundary.
- Good: sample mode includes a deterministic `user-1` response, so the tab can
  be reviewed without BigQuery or live admin credentials.
- Good: `adminGetUserAnalytics` now has an explicit rate-limit entry.
- Partial: topbar search and the Users tab input normalize exact `users/{uid}`,
  `uid:{uid}`, or raw uid values into the selected user scope.
- Partial: the Users tab now renders the exact lookup contract, normalized
  target path, allowed aggregate sources, unavailable domains, and blocked
  actions so operators do not confuse UID analytics lookup with identity search
  or account support tooling.
- Weak: there is no user identity lookup by email, phone, or name, account
  status, moderation history, payment history, attendance roster, support
  notes, or audited user mutation path in this tab.

Recommended next work:

- Add a role-scoped admin user lookup callable before exposing email/phone/name
  search or profile details.
- Keep account, safety, and payment mutations out of Users until each action has
  an audited callable and clear owning workflow.

### Finance

As finance ops, I need failed payment, refund, commission, payout, and
settlement workflows that reconcile to provider authority.

Acceptance criteria:

- Payment issue detail and retry/refund review.
- Commission and settlement ledger.
- Payout readiness and restrictions.
- Provider reconciliation status.
- Audited financial actions.

Current adherence:

- Good: Finance is feature-owned under `features/finance` and has a dedicated
  read-only issue workspace.
- Good: it combines overview payment issue rows, host analytics payment
  anomalies, payout restriction counts, search/filter controls, and an
  explicit issue detail panel.
- Good: selected rows now show deterministic provider authority, source model,
  reconciliation status, required evidence, blocked actions, and mutation
  boundary, so operators can distinguish canonical payment rows, event
  analytics aggregates, and payout restriction aggregates before touching
  provider systems.
- Weak: no provider ledger, payout lifecycle, reconciliation detail, refund
  execution, export, or audited finance mutation path exists yet. The tab
  deliberately surfaces the missing evidence instead of offering retry, refund,
  payout, or settlement buttons.

Recommended next work:

- Define provider-led ledger/read-model contracts before adding any money
  movement or reconciliation actions.
- Keep refund, payout release, and settlement edits out of the tab until each
  action has an audited finance callable and role gate.

### Data Quality

As an ops/data owner, I need to know which metrics are reliable and what
pipeline or source is blocking decisions.

Acceptance criteria:

- Data freshness, missing fields, export health, job health, and owner/runbook
  links.
- Clear distinction between "metric unreliable" and "product queue blocked".
- Remediation actions or links to the responsible workflow.

Current adherence:

- Good: Data quality is feature-owned under `features/data-quality` and has a
  dedicated read-only operations workspace.
- Good: it combines overview quality rows, host analytics quality rows,
  generated marketing bridge freshness, Event Intake dashboard freshness, event
  supply readiness freshness/preflight blockers, source crawl run-plan health,
  and external event import execution-policy health.
- Good: disabled/not-configured crawl and import policies are visible as
  separate rows, so stale generated artifacts are not mistaken for failed live
  schedulers.
- Good: the table now supports explicit signal selection and a detail panel for
  source, state, owner, runbook, updated time, detail, and next action.
- Weak: generated bridge/readiness metadata is still partly assembled in the
  frontend; there is still no scheduler last-run/last-error telemetry, backfill
  status, acknowledgement, or remediation workflow.

Recommended next work:

- Move generated bridge/readiness freshness and run-policy rows into
  source-owned admin contracts.
- Add scheduler last-run/backfill metadata and remediation actions only after
  each source has documented safe tooling.

### Admin Roles

As an admin owner, I need to grant, inspect, and revoke Catch admin claims from
the console so live admin access is not dependent on an invisible manual script.

Acceptance criteria:

- Exact Firebase Auth uid lookup with current admin roles.
- Role assignment is limited to the documented Catch admin claim allowlist.
- Every role change requires a note and writes an audit trail.
- Admin owners cannot remove their own last owner-capable claim.
- The UI clearly says this is not a broad user search or support workflow.

Current adherence:

- Good: Admin roles is feature-owned under `features/admin-roles`.
- Good: `adminGetAdminUserRoles` and `adminSetAdminUserRoles` are
  `adminOwner`-only callables, rate-limited, and backend-authorized.
- Good: role changes preserve unrelated custom claims, require notes, write
  `adminRoleAssignments/{uid}`, write `adminAuditLogs/{id}`, and block
  self-removal of `adminOwner`.
- Good: the tab now exposes the exact-uid scope contract, normalized assignment
  path, source-of-truth documents, unsupported lookup inputs/actions, and
  blocks no-op saves so an unchanged role set cannot create audit noise.
- Weak: the tab is exact-uid based. It does not yet list all Firebase Auth
  users, search by email/name, or backfill the assignment register for claims
  that were set manually before this tab existed.

Recommended next work:

- Add a bounded admin-role directory only after deciding whether Auth listing
  or a Firestore-owned assignment register should be the source of truth.
- Add an App Check/auth environment diagnostic panel if live-mode setup becomes
  confusing during operations.

## Sub-Workspace User Stories

### Marketing: Posts

As a content operator, I need a board of post drafts by review stage so I can
prioritize the next item to compose or export.

Current fit: good board shape, but cards should become shared `AdminCard` plus
`StatusChip` composition.

### Marketing: New Post

As a content operator, I need a constrained draft creation flow so I can create
only publishable content types from valid source material.

Current fit: present and controller-backed. The flow should stay progressive,
not a vertically scrollable form.

### Marketing: Composer

As a content operator, I need to step through source selection, copy/layout,
brand compliance, and export one stage at a time so the task is not overloaded.

Current fit: present and step-based. Needs continued design-file comparison and
shared `Stepper` primitive.

### Marketing: Event Library

As a content operator, I need to review event inputs available to content so
Marketing only uses verified, source-backed events.

Current fit: useful. Event Intake review decisions now live in event-owned
contracts; Marketing should continue to treat those records as source-backed
inputs, not canonical event documents.

### Marketing: Media Library

As a content operator, I need screenshots and feature-drop assets organized by
role, device, and status so I can assemble app-feature explainers.

Current fit: useful, including PNG export. Needs shared media-card and file
picker primitives.

### Marketing: Activity

As a content lead, I need recent commands and review decisions so I can audit
what changed and what is ready for manual publishing.

Current fit: present, but should become a standard audit-log component.

### Intake: Events

As an event intake operator, I need source crawling, source inbox, and event
candidate verification before events feed Marketing or canonical event records.

Current fit: useful, with sub-tabs below. Frontend naming, read API, and review
decisions now present this as Event Intake. The read callable consumes native
Event Intake dashboard output from `eventIntakeDashboards/current`; missing
dashboard data renders an explicit empty bridge instead of falling back to
Marketing data.

### Event Intake: Crawl Setup

As an intake operator, I need to inspect crawl source coverage, schedules,
budgets, and source risk before any event leads are trusted.

Current fit: present. Needs clearer run controls and policy gates.

### Event Intake: Source Inbox

As an intake operator, I need to inspect raw source results, edit extracted
fields, and decide whether a lead should advance.

Current fit: present. Needs stronger dedupe/source-confidence treatment.

### Event Intake: Event Candidates

As an intake operator, I need to edit event title/date/location/source evidence
and approve, hold, or reject candidates.

Current fit: present. Actual canonical import remains policy-limited.

### Intake: Organizers

As an organizer intake operator, I need to curate discovered organizers into
canonical listings with evidence, publication, claim handoff, and app visibility
gates.

Current fit: broad and powerful but dense. Needs component extraction, live
bridge refresh strategy, and clearer operator priority.

## Architecture Assessment

What is correct:

- Admin is a separate React/Vite surface, which matches the repo architecture.
- Backend authority remains in Functions/shared contracts, not direct client
  Firestore writes.
- Overview, Marketing, event lead intake, and Organizer Intake now have
  feature-owned controllers.
- Organizers now has a feature-owned repository, controller, helpers, and
  screen for canonical publishing.
- Shared DTO/type reuse is started through `shared/types` and
  `shared/contracts/intakeApprovalContracts.ts`.

What is weak:

- `App.tsx` still owns auth shell, navigation, topbar search, role gating, and
  feature composition. Overview data reads, analytics filters, and queue
  decision orchestration now live under `features/overview`.
- Feature repositories mostly re-export shared API functions instead of owning
  a typed data boundary.
- Event Intake review writes now use `adminRecordEventIntakeReviewDecision` and
  `eventIntakeReviewDecisions/{decisionId}`. The target direction is
  `app -> features -> shared`, never feature-to-feature for domain control flow.
- `MarketingOpsScreen.tsx` and `OrganizerIntakeScreen.tsx` are still very large.
- Event lead intake now has local Event Intake review helpers plus event-owned
  read, callable, Firestore decision contracts, and a guarded
  `eventIntakeDashboards/current` publish tool.
- Generated JSON bridges are useful for sample/admin review workflows, but
  approved event and organizer records must converge into shared contracts
  consumable by the app and public website.
- Organizer route allocation now checks `clubs.publicPage.canonicalPath`
  collisions and writes `publicRouteReservations/{routeKey}` from the admin
  save/index-publish callables before a canonical page becomes indexable.

State management decision:

- Do not introduce Redux/Zustand or another external state library yet.
- The correct next step is feature-owned React hook controllers plus typed
  repositories.
- Add an external client-state dependency only after the admin has cross-feature
  cache invalidation, optimistic concurrency, or server-state deduplication
  problems that hooks cannot handle cleanly.

## Base Component Catalogue

Implemented or started in `admin/src/shared/ui/AdminPrimitives.tsx`:

- `AdminButton`
- `AdminIconButton`
- `AdminLinkButton`
- `AdminNavButton`
- `SearchField`
- `SegmentedControl`
- `StatusBanner`
- `EmptyState`
- `PageHeader`
- `AdminCard`
- `SelectableCardButton`
- `CardHeader`
- `StatusChip`
- `AdminTag`
- `TagList`
- `AlertRow`
- `DataTable`
- `TableActionButton`
- `RiskBadge`
- `FilePickerButton`
- `AdminPanel`
- `Panel`
- `AdminStateRow`
- `StateRow`
- `AdminTextField`
- `TextField`
- `AdminTextareaField`
- `TextareaField`
- `SelectField`

Migration already started:

- App shell nav, search, topbar range control, refresh/sign-out buttons, and
  banners now compose shared primitives. Feature workspaces own empty states,
  panels, and state rows through shared primitives.
- Marketing screen-level refresh/new-post buttons and marketing tabs now compose
  shared primitives.
- Event lead intake refresh button and event tabs now compose shared primitives.
- Organizer Intake workspace tabs now compose shared primitives.
- Shared Marketing/Event review footer actions now compose `AdminButton`.
- Deep Marketing composer back/next/export buttons, icon remove button, source
  links, and download links now compose `AdminButton`, `AdminIconButton`, or
  `AdminLinkButton`.
- Event lead intake external source icon links now compose `AdminLinkButton`.
- Marketing image upload now composes `FilePickerButton`.
- Marketing and event lead intake screen headers now compose `PageHeader`.
- Marketing composer review state now starts using `StatusChip`.
- `AdminPanel` and `Panel` now share the same header composition instead of
  divergent `panel-icon` markup.
- Event lead intake source profiles, source inbox cards, candidate cards, source
  policy tags, candidate status notices, and external links now compose shared
  card/header/tag/chip/alert/link primitives.
- Organizers canonical directory, editor, checklist, validation, diff, and
  preview panels compose shared admin table, button, field, tag, state-row, and
  panel primitives.
- Overview event performance table now composes `DataTable`,
  `TableActionButton`, and `RiskBadge`.
- Overview queue decision actions now compose `AdminButton`.
- Marketing post cards, compliance checklist rows, next-action warning, and
  recommendation set cards now compose shared selectable-card, card, chip, and
  alert primitives.

Required next primitives:

| Primitive | Why it exists | First migration targets |
|---|---|---|
| `AdminCard` | Extends card primitive usage across remaining repeated article shells | remaining Marketing cards, Organizer Intake cards |
| `CardHeader` | Extends repeated card header/title/badge layouts | remaining marketing and organizer intake cards |
| `StatusChip` | Replaces remaining badges and risk pills | remaining `.intake-badge`, `.risk` |
| `AdminTag` / `TagList` | Replaces remaining tag rows | remaining `.intake-tag`, `.marketing-tag-row` |
| `AlertRow` | Replaces remaining quality/warning/success rows | remaining `.quality-row` |
| `DecisionActionGroup` | Generalizes approve/hold/reject/export-ready sets | Marketing footer, queue rows, organizer decisions |
| `DataTable` | Extends table wrap, empty state, actions | future users/events/finance tables |
| `Stepper` | Standardizes progressive disclosure flow | Marketing composer steps |
| `FormSection` | Standardizes fieldsets and dense edit sections | Organizer editor, curation forms, location resolution |
| `PageHeader` | Extends the implemented header primitive to Organizer Intake | `.intake-workspace-header` |

Remaining raw component baseline from `rg` after the first migration:

- `table-wrap`: `admin/src/app/App.tsx`
- `marketing-ops-header`: Marketing and Event Intake
- `intake-workspace-header`: Organizer Intake
- Basic button/link/tab classes: no remaining direct `className` usage for
  `ghost-button`, `primary-button`, `icon-button`, or `segmented` in
  `admin/src/app`, `admin/src/features`, or `admin/src/shared`
- `marketing-card`, `marketing-card-list`, `marketing-card-header`: Marketing
  and Event Intake
- `search-candidate-card`: Organizer Intake
- `intake-card`: Organizer Intake
- `intake-badge`: Marketing, Event Intake, Organizer Intake
- `quality-row`: Marketing, Event Intake, Organizer Intake

Component rule:

New admin UI should not add raw `button`, `article`, `header`, badge, table, or
field markup when an admin primitive exists. If the needed primitive does not
exist, add it to `AdminPrimitives.tsx` or a focused shared admin component file
first, then build the feature screen through composition.
Admin import direction is enforced by
`node tool/admin/check_import_boundaries.mjs`: app shell may compose features
and shared modules; features may depend on their own top-level feature and
shared modules; shared modules must not import app or feature modules.

## Prioritized Improvements

1. Add an organizer search-index backfill action if imported production data
   predates `clubs/{id}.adminSearch`.
2. Build the next high-risk Safety mutation set: audited escalation,
   restriction, and resolution actions. The current tab is intentionally
   limited to explicit assignment plus status-only review/dismiss decisions
   over read-only assignment/SLA/evidence metadata.
3. Add source-owned scheduler last-run/last-error and backfill metadata so Data
   quality can distinguish stale generated artifacts from failed live jobs.
4. Keep event lifecycle mutations out of the safe display-field editor until
   side effects are shared with host flows.
5. Continue primitive migration with `PageHeader`, `AdminCard`, `StatusChip`,
   `AlertRow`, and `Stepper`.
6. Add controller/helper tests for review decisions and draft creation.
7. Keep approved event and organizer output aligned with shared contracts so
   app and public website consumers do not drift.
