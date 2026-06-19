# Analytics Warehouse

Host/admin analytics are served from BigQuery marts. Firestore remains the
operational database; Firestore documents are exported to BigQuery and joined
with GA4/direct behavioral events here.

## Host Inputs

- `catch_analytics.host_analytics_events`: aggregate-safe public organizer
  discovery events written by `recordOrganizerAnalyticsEvent`.
- `analytics_526484083.events_*`: GA4 daily export for organizer behavior
  events emitted through GTM/dataLayer as `organizer_<eventName>`. The mart
  uses GA4 as a backup/source for behavioral counts when those export tables
  exist, and de-duplicates against direct callable events by taking the larger
  daily count for the same club/event/event-name key.
- `catch_analytics.*_raw_latest`: Firestore-to-BigQuery export views for
  `clubs`, `events`, `eventParticipations`, `payments`, `reviews`,
  `savedEvents`, `eventInviteLinks`, and `matches`.
- `catch_marketplace_metrics.event_success_scorecards_raw_latest`: existing
  Event Success export, used for post-event connection/chat/repeat metrics.

## Host Outputs

- `catch_analytics.mart_host_event_daily`: host-safe daily grain used by
  `getHostAnalytics` and `adminGetHostAnalytics`. It includes discovery,
  demand, booking, checkout-start/drop-off, payment, attendance, review,
  connection, and chat metrics at club/event/date grain.

Deploy order:

1. Run `node tool/run.mjs check analytics:check-host-bigquery`.
2. Run `ddl/host_analytics_events.sql` and `ddl/mart_host_event_daily.sql`.
3. Deploy the Firestore-to-BigQuery extension instances in `firebase.json`.
4. Deploy the Functions callables that write/read host analytics.
5. Refresh and schedule `marts/refresh_mart_host_event_daily.sql` after the
   extension backfill has created the `*_raw_latest` export views.

`extensions/bq-host-*.env` uses `EXCLUDE_OLD_DATA=no` on purpose. The first
install should backfill existing clubs, events, payments, reviews, saves,
invite links, participations, and matches so host analytics does not start from
an empty cutover day.

IAM ownership:

- Functions runtime: BigQuery job user on the project plus access to
  `catch_analytics` for raw event inserts and mart reads.
- Mart deployer / scheduled query identity: BigQuery job user, editor access to
  `catch_analytics`, and viewer access to `catch_marketplace_metrics`.
- Firestore-to-BigQuery extension service accounts: write access to the export
  tables owned by their extension instances.

## User Inputs

- `catch_marketplace_metrics.participant_signal_facts_raw_latest`: existing
  signal facts for likes, private interest, matches, chats, attendance, and
  feedback.
- `catch_analytics.event_participations_raw_latest`: roster edges for booked
  and attended event counts.
- `catch_user_analytics.user_profile_exposure_events`: aggregate-safe profile
  impression, dwell, and photo performance events. This table is the long-term
  denominator for profile/photo performance and internal composition models.
- `analytics_526484083.events_*`: optional GA4 export used for aggregate app
  active-minute counts when Firebase user IDs are present.

## User Outputs

- `catch_user_analytics.mart_user_analytics_daily`: user daily grain used by
  `getUserAnalytics` and `adminGetUserAnalytics`. It includes user-safe profile
  attention, interest, match, chat, attendance, and app engagement metrics.
  It also stores internal-only composition/scoring columns such as
  `profile_pull_score` and `internal_desirability_percentile`; those fields are
  not returned by the user-facing callable response.

Deploy order:

1. Run `node tool/run.mjs check analytics:check-user-bigquery`.
2. Run `ddl/user_profile_exposure_events.sql` and
   `ddl/mart_user_analytics_daily.sql`.
3. Deploy the Functions callables that read user analytics.
4. Refresh and schedule `marts/refresh_mart_user_analytics_daily.sql`.

IAM ownership:

- Functions runtime: BigQuery job user on the project plus read access to
  `catch_user_analytics.mart_user_analytics_daily`.
- Mart deployer / scheduled query identity: BigQuery job user, editor access to
  `catch_user_analytics`, and viewer access to `catch_analytics`,
  `catch_marketplace_metrics`, and GA4 export datasets.
