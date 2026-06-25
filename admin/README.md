# Catch Admin

Internal admin and analytics console for Catch operations.

## CI/CD

`.github/workflows/admin-website.yml` validates admin-console changes on pull
requests and deploys the production Firebase Hosting `admin` target after
matching changes land on `main`. The deploy job requires the prod GitHub
Environment Vite Firebase/App Check variables and fails before build if the
dashboard would point at the wrong Firebase project or stay in sample mode.

## Local Development

```bash
npm install
npm run dev
```

The app starts in `sample` data mode by default so the UI can be reviewed before
admin claims and App Check are configured. In sample mode the top bar shows
that Auth is bypassed and no login/logout control is rendered because no
Firebase session is required.
In live mode the shell shows a Google sign-in screen before any callable data
loads, shows the signed-in email/uid and custom admin claims after Auth
resolves, blocks signed-in users with no Catch admin claim before dashboard
data loads, and surfaces sign-in, claim refresh, and sign-out errors in the UI.

For live Firebase calls, create a local `.env.local` from `env.example` and set:

```bash
VITE_ADMIN_DATA_MODE=live
VITE_ADMIN_FIREBASE_ENV=dev
VITE_ADMIN_APPCHECK_SITE_KEY=<dev-web-app-check-site-key>
VITE_ADMIN_PUBLIC_SITE_ORIGIN=https://catchdates.com
VITE_FIREBASE_MEASUREMENT_ID=<dev-web-measurement-id>
```

Live mode calls `adminGetOverview` for dashboard queue data and
`adminGetHostAnalytics` for host/admin analytics. Overview is a triage and
analytics workspace; access decisions, organizer claim decisions, and organizer
indexing decisions are handled in their owning tabs where the operator must
select a row and enter a review note.

The app shell owns shared navigation, auth, role gating, topbar search, and
feature composition. Overview range state, refresh, analytics loading, and queue
triage live in `admin/src/features/overview/controllers`.
The topbar environment indicator is read-only and reflects
`VITE_ADMIN_FIREBASE_ENV` plus the current sample/live data mode; switching
Firebase targets still happens through environment variables and rebuilds.
Admin feature import direction is enforced by
`npm run check:boundaries` and by `npm run build`: app-shell modules may compose
features and shared modules; feature modules may import their own top-level
feature plus shared modules; shared modules must not import app or feature
modules.

The Access tab reads pending access application rows from `adminGetOverview`,
loads selected application detail through `adminGetAccessApplicationDetails`,
and calls `adminDecideAccessApplication` only after an operator explicitly
selects an application and enters a required review note plus an optional cohort
id. The detail panel shows launch-access source fields, referral/invite/social
signals, and bounded deterministic overlap checks. It is the launch-gate review
workspace only; account actions, safety history, payment history, and broad user
search need separate role-scoped contracts before they are exposed here.

The Organizers tab calls `adminListClubDetails` for the canonical
`clubs/{id}` directory, `adminGetClubDetails` for detail hydration,
`adminUpdateClubDetails` for audited partial edits, and
`adminSetClubIndexStatus` for index-ready/noindex publishing decisions.
Organizer save and index decisions require a review note whenever an audited
mutation is sent; unchanged saves short-circuit in the UI without calling the
backend. The organizer list response includes a `generatedAt` snapshot timestamp
shown in the publishing contract panel.
Organizer save and index-ready publishing also reserve
`publicRouteReservations/{routeKey}` so website routes are claimed before
canonical listings become indexable.
Organizer save and index-ready publishing also rebuild the server-owned
`clubs/{id}.adminSearch` projection used by `adminListClubDetails` for
token-backed large-list search. Backend query matching owns token search; the
client table only applies tab filters to the rows returned by the callable.
The default Organizer Indore + Mumbai view sends a bounded `citySlugs` backend
filter so the launch-city directory remains complete as the canonical
organizer collection grows.
Organizer public-page previews use `VITE_ADMIN_PUBLIC_SITE_ORIGIN` plus
`clubs/{id}.publicPage.canonicalPath`; if the env var is omitted, the admin
console falls back to `https://catchdates.com`.
For older organizer documents, dry-run the admin search projection repair
before applying it:

```bash
node tool/data/backfill_organizer_admin_search.mjs --env dev --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env dev --apply
```

The Events tab calls `adminListEventDetails` for the canonical `events/{id}`
directory, `adminGetEventDetails` for detail hydration, and
`adminUpdateEventDetails` for audited safe app-facing edits. Event saves rebuild
the server-owned `events/{id}.adminSearch` projection and event discovery
projection. The default Indore + Mumbai view sends a bounded `citySlugs`
backend filter plus `status: "active"` and `timeWindow: "upcoming"` so the
launch-city list remains complete and chronologically ordered as the event
collection grows. The client-side launch-city, upcoming, and full filters use
the callable response `generatedAt` timestamp as their snapshot clock so visible
rows stay aligned with the server-side time window. Backend query matching owns
admin-search/source-token search; the canonical table and external supply table
now have separate search and filter state so canonical cleanup states such as
Full or Search issues do not hide the source-backed supply review queue, and a
canonical search does not silently constrain external candidates. The external
supply default is the open Indore + Mumbai review queue. Schedule, cancellation,
capacity, pricing, payments,
attendance, and policy fields are intentionally read-only in this first
canonical editor. The same Events workspace also calls
`adminListExternalEventDetails` for read-only `externalEvents/{id}` supply:
reviewed external candidates stay outbound-only, do not use Catch booking,
payments, reservations, or waitlists, and remain separate from canonical
Catch-hosted `events/{id}` documents until a policy-owned importer exists.
External supply rows are selectable so operators can inspect source attribution,
candidate ids, normalized duplicate keys, review batch state, and owner-safe
copy/import-policy checks without opening raw artifacts. The selected row also
joins against the current import plan and execution preflight, when present, so
operators can see whether that external event is already published supply,
preflight-ready but write-disabled, blocked, waiting for review, rejected,
merged as a duplicate link, or absent from the current readiness snapshot. The
Events workspace also reads `eventSupplyReadiness/current` through
`adminGetEventSupplyReadiness` in live mode, with generated
`admin/src/generated/` snapshots as sample fallback. Operators publish that
read-only dashboard document from reviewed generated artifacts with:

```bash
node tool/organizer_intake/publish_event_supply_readiness.mjs --env dev
node tool/organizer_intake/publish_event_supply_readiness.mjs --env dev --apply
```

This exposes read-only draft counts, blockers, guardrails, source files, and
regeneration commands without enabling Firestore import writes. The readiness
panel includes a searchable/filterable import action directory capped to the
first 50 visible rows, with Needs action, Write-ready, Blocked, Waiting,
Rejected, and All filters so large generated plans are operable without turning
the Events tab into a bulk importer. When the readiness policy explicitly sets
`writeEnabled: true` and `authorityModel: admin_import_service`, operators can
publish one preflight-ready row at a time through `adminPublishExternalEvent`.
The UI requires a review note plus preflight, outbound-link, no-Catch-booking,
and owner-safe-copy checklist gates before the per-row Publish action enables.
The callable creates only `externalEvents/{id}` read-only outbound supply and
refuses canonical `events/{id}` writes, blocked actions, invalid projections, or
existing target documents.
Sample mode uses explicit canonical Indore and Mumbai event records rather than
host analytics rows, plus read-only external event rows, so the default Events
tab exercises the same launch-city workflow as live mode.
For older event documents, dry-run the admin search projection repair before
applying it:

```bash
node tool/data/backfill_event_admin_search.mjs --env dev --summary-only
node tool/data/backfill_event_admin_search.mjs --env dev --apply
```

The Users tab calls `adminGetUserAnalytics` for a selected `users/{uid}` and
renders the user-safe aggregate analytics response: summary cards, trend
buckets, connection/profile aggregates, coaching refs, and data-quality rows.
It is intentionally read-only. The global topbar and Users tab input normalize
exact `users/{uid}`, `uid:{uid}`, or raw uid values into one callable scope.
The tab also shows the lookup contract, normalized target path, allowed
aggregate sources, unavailable domains, and blocked actions so this exact UID
analytics lookup is not mistaken for identity search or support tooling. User
identity search by email, phone, or name, account state, safety history, payment
history, and support actions need separate role-scoped admin contracts before
they are exposed here.

The Data quality tab is a read-only operations workspace over
`adminGetOverview`, `adminGetHostAnalytics`, `adminGetMarketingOpsDashboard`,
`adminGetEventIntakeDashboard`, and `adminGetEventSupplyReadiness`.
It groups quality rows by source, owner, runbook, state, and next action, and
checks generated marketing bridge freshness, Event Intake dashboard freshness,
external event import readiness freshness/preflight blockers, source crawl run
plan health, and external event import execution-policy health. It does not
trigger backfills, inspect scheduler last-run telemetry, or acknowledge
incidents until each source has a safe backend tool and audit contract.

The Safety tab is a triage workspace over `adminGetOverview` safety queues plus
`adminGetSafetyTriageDetails` detail reads. It groups user reports, moderation
flags, and event safety reports with priority, route-owner guidance, normalized
detail fields, assignment/SLA/evidence metadata, bounded prior-history joins,
policy outcome guidance, and next actions. Assignment changes use
`adminAssignSafetyTriageItem`; review and dismiss decisions use
`adminDecideSafetyTriageItem`. Both require an explicit selected queue row plus
a reviewer note and only update the queue document status/assignment fields.
Restriction, escalation, and account-level safety actions are intentionally
absent until their audited mutation callables and document contracts exist.

The Growth tab is a read-only KPI workspace over `adminGetOverview` and
`adminGetHostAnalytics`. It groups launch signals by acquisition, supply,
conversion, and marketplace stages, supports range selection, shows booking
trend buckets, and labels the combined dashboard timestamp as client load time.
Channel, cohort, referral, campaign tasking, and export actions need explicit
analytics contracts before they are exposed here.

The Finance tab is a read-only issue workspace over `adminGetOverview` payment
queues and `adminGetHostAnalytics` event payment signals. It surfaces failed
payments, event payment anomalies, payout restriction counts, and revenue
summary only, with issue detail shown only after an operator explicitly selects
a row. Selected rows include deterministic provider authority, source model,
reconciliation status, required evidence, blocked actions, and mutation
boundary, so operators can tell payment documents apart from event analytics or
payout aggregates before leaving the admin console. Refunds, payout releases,
settlement edits, and provider reconciliation need ledger/read-model contracts
and audited finance callables before they are exposed here.

Production apply requires `--allow-prod`.
The signed-in Firebase user must have at least one admin custom claim
for overview reads: `admin`, `adminOwner`, `safetyReviewer`, `support`,
`finance`, or `analyticsViewer`.
Access application Approve/Deny and organizer claim Approve/Reject require
`admin`, `adminOwner`, or `support`.
User analytics lookup requires `adminOwner` or `analyticsViewer`.
Organizer canonical edits and publishing currently require `admin`,
`adminOwner`, or `support`.
Event canonical safe edits currently require `admin`, `adminOwner`, or
`support`.
Safety assignment and status decisions currently require `admin`, `adminOwner`,
or `safetyReviewer`.
The Admin roles tab is available to `adminOwner` only. It loads an exact
Firebase Auth uid through `adminGetAdminUserRoles`, lists the bounded
`adminRoleAssignments` register through `adminListAdminRoleAssignments`,
assigns/removes the six Catch admin custom claims through
`adminSetAdminUserRoles`, requires an audit note, writes
`adminRoleAssignments/{uid}`, and blocks admin owners from removing their own
`adminOwner` claim. It shows the exact-uid scope contract, normalized assignment
path, source-of-truth records, unsupported lookup inputs/actions, and blocks
no-op saves so unchanged role sets do not create audit noise. The register is
an admin assignment list, not email/name search or an unbounded user directory.
After a claim is assigned, the blocked live-mode screen can force-refresh the
user's ID token with Refresh claims.
The sidebar filters tabs from the same current callable allowlists: support can
see support-owned workflows, safety reviewers can see Safety and Overview,
analytics viewers can see Growth, Users, Finance, and Overview, and Data
quality is currently admin-owner only because it combines host analytics and
marketing dashboard callables. The backend remains the authority for every
read/write.

## Marketing Ops

The Marketing tab is the human review console for the weekly event-guide loop.
Marketing and sample marketing API paths read
`admin/src/generated/marketingOpsBridge.json` in sample mode. Event Intake reads
`admin/src/generated/eventIntakeBridge.json` in sample mode and
`eventIntakeDashboards/current` in live mode through
`adminGetEventIntakeDashboard`. Regenerate both admin bridge files from the
repo-owned loop with:

The Intake tab shows an active publication-boundary panel for Event leads and
Organizers before the dense workspaces render. Event leads write review
decisions only and do not create `events/{id}`, `externalEvents/{id}`, bookings,
payments, or waitlists. Organizer Intake records review, curation, policy, and
location decisions; canonical organizer publication, route indexing, and claim
handoff still pass through promotion tooling and the Organizers workspace.

```bash
node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs \
  --week 2026-06-22 \
  --admin-output admin/src/generated/marketingOpsBridge.json \
  --event-intake-admin-output admin/src/generated/eventIntakeBridge.json
```

Publish the event-owned live Event Intake dashboard after reviewing the
generated bridge:

```bash
node tool/marketing/event_guide/publish_event_intake_dashboard.mjs --env dev
node tool/marketing/event_guide/publish_event_intake_dashboard.mjs --env dev --apply
```

Live mode calls `adminGetMarketingOpsDashboard`,
`adminRecordMarketingReviewDecision`, and `adminCreateMarketingContentDraft`.
These callables record review decisions and append editable draft objects only:
they do not publish Instagram posts, create app events, or run crawlers.
The Marketing screen shows the same action boundary in the UI: reviewed source
leads and content drafts can be packaged for manual export, while canonical
supply writes, booking, payments, waitlists, and direct Instagram posting stay
outside this workspace.
Marketing review decisions require a review note for the audit log.
Marketing Ops actions require `admin`, `adminOwner`, or `support`.

Host analytics live mode reads the shared BigQuery-backed
`adminGetHostAnalytics` callable. Production hosting builds must set
`VITE_ADMIN_DATA_MODE=live`, `VITE_ADMIN_FIREBASE_ENV=prod`, and
`VITE_ADMIN_APPCHECK_SITE_KEY`; otherwise the deployed dashboard remains in
sample mode or fails App Check before it reaches the analytics backend.
Firebase Hosting deploys run `node tool/env/check_web_hosting_env.mjs admin`
before building so missing Firebase/App Check env fails before a dashboard can
be shipped.
