# Participant Success Metrics Tracker

Status: in progress
Owner: Codex architecture pass
Started: 2026-05-18

## Product Goal

Build the private measurement foundation for Catch's recursive participant loop:
participation should improve future dating outcomes, while admin tooling can
understand marketplace health on an absolute/cohort basis.

User-facing surfaces must stay relative to the user's own baseline. Admin
surfaces may use absolute percentiles, but those scores must remain
multidimensional: demand, conversion, reliability, contribution, growth, and
safety.

## Architecture Decision

- Firestore remains the operational source of truth.
- Cloud Functions own sensitive metric facts, counters, and scorecard rollups.
- Firebase Analytics/BigQuery should become the warehouse layer for profile
  impressions, exposure-normalized percentiles, cohort trends, and long-window
  admin analysis.
- App clients should not calculate marketplace score, desirability percentile,
  or event success scorecards locally.

## Initial Scope

- Add server-owned append-only participant signal facts.
- Materialize idempotent participant counters for admin/scoring jobs.
- Capture facts from existing trusted flows:
  - outgoing/incoming likes
  - private interest
  - matches
  - chat starts/messages
  - attendance
  - post-event feedback
- Add event-success scorecard rollups from event feedback, matches, chat starts,
  and attendance/booked event fields.
- Add Firestore rules that deny client access to raw/admin metrics and allow
  event scorecard reads only through the existing event-success read policy.

## Deferred Scope

- Client-side profile impression batching.
- Scheduled cohort percentile jobs.
- Admin dashboard UI.
- User-facing participant momentum UI.
- Privacy split for any future questionnaire/free-text answers that should not
  be host-readable.
- Schema-contract generation for the new metric collections after the active
  event schema WIP stabilizes.

## Metric Taxonomy

Participant dimensions:

- Demand: inbound likes, private interest, exposure-normalized interest rate.
- Conversion: reciprocal matches, chat starts, downstream follow-through.
- Reliability: bookings, attendance, no-shows, late cancellations.
- Contribution: repeat attendance, event quality lift, cohort scarcity, host
  trust.
- Growth: improvement relative to the user's own historical baseline.
- Safety: reports, blocks, moderation, safety flags. This is a gate, not a
  normal weighted score.

Event dimensions:

- Fill rate.
- Check-in rate.
- Intro coverage.
- Private interest rate.
- Mutual match rate.
- Chat start rate.
- Repeat signup rate.
- Feedback ratings.
- Safety incident count.

## Implementation Notes

- Raw facts live in `participantSignalFacts/{factId}`.
- Incremental counters live in `participantMetricCounters/{uid}`.
- Future user-facing summaries should live in `participantMomentum/{uid}`.
- Future admin summaries should live in `participantMarketplaceMetrics/{uid}`.
- Event scorecards live in `eventSuccessScorecards/{eventId}`.
- Client writes to all metric summary collections are denied.

## Progress

- [x] Tracker created.
- [x] Participant signal writer added.
- [x] Event-success scorecard rollup added.
- [x] Existing triggers/callables hooked.
- [x] Firestore rules boundaries added.
- [x] Focused verification run.
- [x] Firebase Extensions manifest added for dev/staging Firestore-to-BigQuery
  exports.
- [x] Deploy Functions/rules to `catchdates-dev`.
- [x] Deploy Functions/rules to `catchdates-staging`.
- [x] Deploy Firestore-to-BigQuery extensions to `catchdates-dev`.
- [x] Deploy Firestore-to-BigQuery extensions to `catchdates-staging`.
- [x] Confirm BigQuery datasets/tables/views in dev and staging.
- [x] Confirm INR 25 monthly budget alerts for dev and staging.
- [ ] Enable Firebase Analytics BigQuery export in dev/staging console.
- [ ] Add client-side profile impression batching.

## Verification Log

- `npm --prefix functions run build` - pass.
- `npm --prefix functions run lint` - pass.
- `npm --prefix functions test` - 149 tests pass.
- `node --test functions/lib/marketplace/*.test.js functions/lib/matching/*.test.js` - 16 tests pass.
- `firebase emulators:exec --only firestore,storage 'npm --prefix functions run test:rules'` - 66 rules tests pass.
- `./tool/check_data_contract.sh` - pass.
- `firebase deploy --only extensions --project catchdates-dev --dry-run` - pass; six
  extension instances would be created.
- `firebase deploy --only extensions --project catchdates-staging --dry-run` -
  pass; six extension instances would be created.
- `firebase deploy --only functions,firestore --project catchdates-dev` - pass;
  preserved remote-only indexes and legacy `Run` functions when prompted.
- `firebase deploy --only functions,firestore --project catchdates-staging` -
  pass; preserved remote-only indexes and legacy `Run` functions when prompted.
- `firebase ext:list --project catchdates-dev` - no extensions installed yet.
- `firebase ext:list --project catchdates-staging` - no extensions installed yet.
- `firebase deploy --only extensions --project catchdates-dev` - pass; accepted
  Firebase Extensions User Terms and created six Firestore-to-BigQuery export
  instances.
- `firebase deploy --only extensions --project catchdates-staging` - pass;
  accepted Firebase Extensions User Terms and created six Firestore-to-BigQuery
  export instances.
- `firebase ext:list --project catchdates-dev` - six
  `firebase/firestore-bigquery-export@0.3.2` instances active.
- `firebase ext:list --project catchdates-staging` - six
  `firebase/firestore-bigquery-export@0.3.2` instances active.
- `bq ls --project_id catchdates-dev catch_marketplace_metrics` - six daily
  partitioned raw changelog tables and six latest views present.
- `bq ls --project_id catchdates-staging catch_marketplace_metrics` - six daily
  partitioned raw changelog tables and six latest views present after extension
  setup settled.
- `gcloud billing budgets list --billing-account 01B6F7-037D77-F5B2E6 --billing-project catchdates-dev`
  - dev and staging both have INR 25 monthly budgets with 50%, 90%, and 100%
    spend thresholds.

## Dev/Staging Warehouse Setup

Configured Firebase Extensions manifest instances for:

- `eventSuccessFeedback` -> `catch_marketplace_metrics.event_success_feedback`
- `eventSuccessScorecards` -> `catch_marketplace_metrics.event_success_scorecards`
- `participantMarketplaceMetrics` -> `catch_marketplace_metrics.participant_marketplace_metrics`
- `participantMetricCounters` -> `catch_marketplace_metrics.participant_metric_counters`
- `participantMomentum` -> `catch_marketplace_metrics.participant_momentum`
- `participantSignalFacts` -> `catch_marketplace_metrics.participant_signal_facts`

Shared defaults:

- Firestore database: `(default)`
- Firestore/BigQuery location: `asia-south1`
- View type: regular view
- Raw changelog partitioning: daily ingestion partition
- Old update payloads excluded to reduce warehouse volume
- Failed exports backed up to `bigQueryExportFailures`

Remaining setup gates:

- Firebase Analytics BigQuery export still needs to be enabled from Firebase
  console for both `catchdates-dev` and `catchdates-staging`.
