---
doc_id: admin_analytics_dashboard_tracker
version: 0.2.0
updated: 2026-06-10
owner: admin_analytics
status: active
---

# Admin Analytics Dashboard Tracker

## Read Policy

Read this tracker before continuing admin console implementation. Pair it with
`docs/admin_analytics_dashboard_spec.md` for the long-form architecture and
`admin/README.md` for local web-app setup.

## Current State

- A separate Vite/React/TypeScript admin app exists under `admin/`.
- The admin app defaults to sample data and can run locally without Firebase
  admin claims.
- `adminGetOverview` exists as the first admin callable overview endpoint.
- `adminGetOverview` has custom-claim authorization and writes
  `adminAuditLogs` for reads.
- The admin overview now includes pending organizer claim requests and can call
  `adminDecideClubClaim` from the dashboard.
- The dashboard UI is still mostly a shell: controls, rich analytics panels, and
  several safety/payment queue actions still need live backend wiring.

## Active Milestone: Functional Live Ops MVP

Goal: make the dashboard useful for day-to-day launch operations before adding
deep BigQuery analytics.

| ID | Task | Status | Notes |
|---|---|---|---|
| ADM-001 | Persistent tracker and handoff state | Done | This file is the source of truth for cross-session admin dashboard work. |
| ADM-002 | Admin web app foundation | Done | Vite React app, sample dashboard, Firebase client wiring, responsive layout. |
| ADM-003 | Admin overview callable | Done | Live Firestore/Auth counts plus queue previews via `adminGetOverview`. |
| ADM-004 | Live local admin mode | Pending | Requires deployed/emulated callable, App Check/dev token setup, and an admin custom claim on the test user. |
| ADM-005 | Access application decision callable | Done | `adminDecideAccessApplication` approves/denies editable applications and writes audit logs. |
| ADM-006 | Access application UI actions | Done | Approve/Deny buttons call the admin API, remove reviewed rows, decrement the pending metric, and show status feedback. |
| ADM-006A | Organizer claim queue actions | Done | `adminGetOverview` lists pending `clubClaimRequests`; dashboard Approve/Reject calls `adminDecideClubClaim`, removes reviewed rows, and decrements pending organizer claims. |
| ADM-007 | Firestore rules for launch access submissions | Pending | App-side `accessApplications` submission path appears scaffolded but not represented in current rules. |
| ADM-008 | Safety report review actions | Pending | Needs status transition model, reviewer notes, and notification policy. |
| ADM-009 | Payment issue queue actions | Pending | Needs refund/retry/reconciliation model and provider-specific constraints. |
| ADM-010 | Admin audit log viewer | Pending | Backend writes logs; no dashboard surface yet. |
| ADM-011 | Admin deployment target | Pending | Firebase Hosting site/subdomain, App Check, protected deploy config. |

## Analytics Milestone

Goal: replace sample analytics panels with server-owned metrics.

| ID | Task | Status | Notes |
|---|---|---|---|
| ANL-001 | Analytics event/data inventory | Pending | Map current Firestore/GA4 facts to required dashboard metrics. |
| ANL-002 | Signup/profile timestamp fix | Pending | `users/{uid}` needs canonical server-owned `createdAt` and `profileCompletedAt`. |
| ANL-003 | Cohort retention API | Pending | BigQuery-backed, with Firestore snapshot fallback only for recent ops metrics. |
| ANL-004 | Host MoM growth API | Pending | Needs host identity lifecycle and host activation definition. |
| ANL-005 | Event performance API | Pending | Event fill, attendance, rating, GMV, revenue/take-rate, safety risk. |
| ANL-006 | User value model | Pending | Spend, referrals, swipes/likes, received-like rate, attendance, moderation risk. |
| ANL-007 | Referral graph | Pending | Durable referral codes, invite opens, attributed signups, activated referrals. |
| ANL-008 | Analytics freshness/status panel | Pending | BigQuery lag, export health, backfill status, stale snapshot warnings. |

## Finance Milestone

Goal: make host money flows auditable before paid launch.

| ID | Task | Status | Notes |
|---|---|---|---|
| FIN-001 | Commission policy model | Pending | Define take-rate per event/host/currency and version it. |
| FIN-002 | Settlement ledger schema | Pending | Provider-confirmed authority for gross, fees, commission, refunds, payouts. |
| FIN-003 | Host payout readiness queue | Pending | Show restricted/incomplete host accounts and required remediation. |
| FIN-004 | Refund/reconciliation operations | Pending | Admin-visible failed payments, signup-failed payments, and retry/refund actions. |
| FIN-005 | Provider routing decision | Pending | Razorpay/Stripe/eSewa marketplace constraints need final provider confirmation. |

## Implementation Log

- 2026-06-01: Added dashboard spec, admin app foundation, sample dashboard, and
  `adminGetOverview`.
- 2026-06-02: Created persistent tracker. Added
  `adminDecideAccessApplication`, role-restricted access review authorization,
  audit logging, unit coverage, and dashboard Approve/Deny actions.
- 2026-06-10: Added pending organizer claim queue data to `adminGetOverview`,
  dashboard Approve/Reject actions for `adminDecideClubClaim`, sample rows, and
  queue normalization coverage.

## Latest Verification

- 2026-06-02:
  - `npm run build` in `admin/`
  - `npm run build` in `functions/`
  - `npm run lint` in `functions/`
  - `node --test lib/admin/*.test.js` in `functions/`
  - `git diff --check -- admin functions/src/admin functions/src/index.ts functions/package.json docs/admin_analytics_dashboard_spec.md docs/README.md docs/plans/admin_analytics_dashboard_tracker.md`
  - Browser check on `http://127.0.0.1:5174/`: Approve removed one sample
    access application and decremented pending applications; Deny cleared the
    queue and left no body-level horizontal overflow.
- 2026-06-10:
  - `npm --prefix admin run typecheck`
  - `npm --prefix functions run build`
  - `npm --prefix functions run lint`
  - `node --test functions/lib/admin/overview.test.js`

## Next Recommended Slice

1. ADM-004: make live local admin mode work against deployed or emulated
   Functions with a real admin custom claim.
2. ADM-007: add Firestore rules/rules tests for app-side launch access
   submissions, because the Flutter launch-access repository is scaffolded but
   `accessApplications` is not currently represented in `firestore.rules`.
3. ADM-011: configure a protected Firebase Hosting admin site/subdomain with
   App Check, then validate live `adminGetOverview` and
   `adminDecideAccessApplication` from the hosted app.
