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
  daily count for the same organizer/event/event-name key. Canonical
  `organizer_id` takes precedence over historical `club_id` GA4 parameters.
- `catch_analytics.*_raw_latest`: Firestore-to-BigQuery export views for
  `organizers`, `events`, `eventParticipations`, `payments`, `reviews`,
  `savedEvents`, `eventInviteLinks`, and `matches`. The retained
  `clubs_raw_latest` view supplies names for historical IDs absent from the
  canonical organizer export; it has no second active exporter.
- `catch_marketplace_metrics.event_success_scorecards_raw_latest`: existing
  Event Success export, used for post-event connection/chat/repeat metrics.

## Host Outputs

- `catch_analytics.mart_host_event_daily`: host-safe daily grain used by
  `getHostAnalytics` and `adminGetHostAnalytics`. It includes discovery,
  demand, booking, checkout-start/drop-off, payment, attendance, review,
  connection, and chat metrics at organizer/event/date grain. The physical
  `club_id` and `club_name` column names remain stable for deployed readers;
  they do not make the legacy Firestore collection authoritative. Event/review
  JSON prefers nonempty `organizerId` and falls back to historical `clubId`.

Deploy order:

1. Run `node tool/run.mjs check analytics:check-host-bigquery`.
2. Run `ddl/host_analytics_events.sql` and `ddl/mart_host_event_daily.sql`.
3. For a new warehouse, deploy its planned Firestore-to-BigQuery instances.
   Existing club exports require the bounded organizer cutover below before
   running the current host refresh; do not deploy all extensions as a shortcut.
4. Deploy the Functions callables that write/read host analytics.
5. Explicitly import existing documents for each exported collection, then
   verify source/export document IDs and latest values before refreshing and
   scheduling `marts/refresh_mart_host_event_daily.sql`. A view's existence or
   a successful scheduled run is not proof that the export is complete.

`EXCLUDE_OLD_DATA=no` retains the **before-update payload** in changelog rows;
it does not import documents that predate extension installation. Existing
documents require the extension's external import script **after** installation
and table creation. See the official [parameter definition](https://github.com/firebase/extensions/blob/next/firestore-bigquery-export/README.md)
and [import procedure](https://github.com/firebase/extensions/blob/next/firestore-bigquery-export/PREINSTALL.md#import-existing-documents).
Read the import tool version's current flags before running it, target the same
project/database/collection/dataset/table as the installed instance, and retain
the run output outside tracked source. Do not infer completion from this flag.

IAM ownership:

- Functions runtime: BigQuery job user on the project plus access to
  `catch_analytics` for raw event inserts and mart reads.
- Mart deployer / scheduled query identity: BigQuery job user, editor access to
  `catch_analytics`, and viewer access to `catch_marketplace_metrics`.
- Firestore-to-BigQuery extension service accounts: write access to the export
  tables owned by their extension instances.

## Organizer Export Cutover

The checked-in `bq-host-clubs` instance now targets `organizers` with
`TABLE_ID=organizers`. Its historical instance ID is intentionally retained:
reconfigure that existing deployment instead of adding a paid parallel exporter.
The host mart prefers canonical names and uses `clubs_raw_latest` only for IDs
absent from the canonical export. The union is deduplicated by document ID before
joining metrics. Canonical null/empty names do not resurrect a stale legacy name.
The physical mart column names remain compatible with existing readers.

These are desired source settings, not evidence of completed live migration.
Extension configuration is validation-only in the delivery planner; merging this
source does not reconfigure an extension or update a BigQuery schedule. The host
refresh now requires both raw views and must not be published before canonical
import/parity succeeds. Keep the currently deployed schedule during the cutover;
if first installing the atomic refresh with its old dimension for rollback,
preserve that exact reviewed SQL separately before updating to the canonical query.

1. Read back the existing instance parameters, installed source version, trigger,
   function locations, table schemas, and schedule. Save the exact prior
   configuration and query for recovery. Confirm collection/table parameters are
   mutable in that installed version. Check its task queues in the functions'
   actual region, which can differ from the BigQuery dataset location.
2. Reconfigure only `bq-host-clubs` to `COLLECTION_PATH=organizers` and
   `TABLE_ID=organizers`, preserving other parameters, version, instance ID and
   both old table/view resources. Drain/reconcile in-flight old-collection work
   first. A new prefix avoids mixing collection-qualified paths into a latest
   view that could otherwise contain two rows for one organizer ID.
3. Once the canonical trigger and tables are ready, explicitly import the whole
   organizers collection with the official importer. Reconcile latest document
   IDs, collection-qualified paths, and relevant field values against a fresh
   Firestore read, including updates/deletions during the reconfiguration gap.
   Require no duplicate latest IDs or failed batches. Import reconstructs current
   state; it cannot recreate every missed historical change. Firebase documents
   [post-update import and temporary parallel-instance alternatives](https://github.com/firebase/extensions/blob/next/firestore-bigquery-export/PREINSTALL.md#mitigating-data-loss-during-extension-updates).
   Prefer the existing-instance approach here, without adding paid dev analytics
   infrastructure solely for rehearsal.
4. Compare the host SELECT before/after the dimension change. Require identical
   metric keys/totals and historical-window retention. Only current canonical
   names and name availability for canonical-only IDs should differ. Preserve
   canonical follower counters; frozen legacy counters are not repair authority.
5. Update the one existing host schedule to this reviewed source SQL, preserving
   its identity, credentials and cadence. Read back the exact query, run one
   refresh, and verify the next scheduled run plus host/admin results. On failure,
   restore the saved prior query; preserve both table families for diagnosis.
   Table or extension deletion is outside this cutover.

`host_analytics_contract.mjs` owns the shared export inventory used by the source
checker and live-status tool. The live check verifies structured extension
parameters/version, both dimension views, and a unique enabled schedule whose
SQL exactly matches this checkout. It intentionally reports incomplete against
an older deployed configuration. It does not replace source/export content
parity or prove a refresh is recent merely because rows exist.

## Refresh Safety And Verification

Both marts build the complete replacement window in a temporary table before
changing the published table. Deletion and insertion then run in one
transaction; the exception handler rolls back and rethrows. Readers retain the
previous successful refresh if computation or publication fails. Rows older
than the refresh window remain untouched. This follows BigQuery's
[transaction semantics](https://docs.cloud.google.com/bigquery/docs/transactions).

Run the normal offline checks with:

```sh
node tool/run.mjs check analytics:check-host-bigquery analytics:check-user-bigquery
node --test tool/analytics/mart_refresh.test.mjs tool/analytics/host_analytics_contract.test.mjs
```

The same test file can validate the actual SQL in BigQuery using only tiny
synthetic temporary tables, including failures during computation and insertion,
canonical/legacy dimension overlap, missing historical IDs, and full metric-row
parity against the old dimension:

```sh
CATCH_ANALYTICS_BQ_TEST_PROJECT=<project-id> node --test tool/analytics/mart_refresh.test.mjs
```

It never uses application source tables or changes schedules/extensions. The
optional test requires BigQuery credentials and is not part of ordinary offline
CI. A script-level `bq --dry_run` does not execute or fully validate
[dynamic statements](https://docs.cloud.google.com/bigquery/docs/multi-statement-queries#dry-run), so it is not a substitute for these fixtures or
source/export parity checks before a live cutover.

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
