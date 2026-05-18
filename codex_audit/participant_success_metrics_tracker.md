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
- Firebase Analytics/BigQuery export setup and scheduled cohort percentile jobs.
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

## Verification Log

- `npm --prefix functions run build` - pass.
- `npm --prefix functions run lint` - pass.
- `npm --prefix functions test` - 149 tests pass.
- `node --test functions/lib/marketplace/*.test.js functions/lib/matching/*.test.js` - 16 tests pass.
- `firebase emulators:exec --only firestore,storage 'npm --prefix functions run test:rules'` - 66 rules tests pass.
- `./tool/check_data_contract.sh` - pass.
