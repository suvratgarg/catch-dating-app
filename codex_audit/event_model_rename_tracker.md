# Event Model Rename Tracker

Status: local rename complete, verification green, remote data cleanup pending
explicit confirmation.

Target names:

- `Run` -> `Event`
- `RunClub` -> `Club`
- `RunParticipation` -> `EventParticipation`
- `SavedRun` -> `SavedEvent`

Architecture intent:

- A `Club` is the reusable host/member group.
- An `Event` is the scheduled bookable listing.
- The event document should contain the low-churn attendee contract needed for
  cheap listing/detail reads: policy snapshot, cancellation snapshot, success
  listing/what-to-expect snapshot, capacity, pricing, time, place, and status.
- High-churn state should not bloat the event document: attendance, check-ins,
  attendee companion state, private crush submissions, feedback responses, and
  generated reports should live in edge collections/subcollections once built.

Safety boundaries:

- Do not delete remote Firestore data from dev, staging, or prod without a
  separate explicit destructive-action confirmation.
- Preserve user documents and club documents through any remote migration.
- Existing event/event history, participation edges, saved edges, reviews, swipes,
  and generated demo data may be reset only after remote backup/confirmation.

Implementation slices:

1. Done: renamed Dart feature folders, domain classes, repositories, routes,
   and tests from run/run club language to event/club language.
2. Done: renamed Functions source folders, callable exports, generated schema types,
   Firestore rules, indexes, and contract schemas.
3. Done: regenerated Freezed/json_serializable, Riverpod, router, Firestore TS
   types, and schema contract outputs.
4. Done: updated seed, repair, validation, storage, and business-rule tooling.
5. Done: event-focused checks, data-contract checks, Functions checks, and full
   Flutter checks are green.
6. Pending: prepare and run a remote cleanup/migration against dev, staging, and
   prod only after a separate destructive-action confirmation.

Verification:

- `./tool/check_data_contract.sh` passed.
- `dart run build_runner build --delete-conflicting-outputs` completed and
  regenerated the model/router/provider/schema outputs.
- `flutter analyze` passed with no issues.
- `flutter test` passed with all tests green.
- Active source sweeps found no stale `runs`, `run_clubs`, `runClubs`,
  `RunClub`, `SavedRun`, old callable payload, or old generated output paths.
  The remaining `prefsRunStatusUpdates` references are intentionally retained
  because they are user-profile notification preferences and should not be
  renamed without a user-profile schema migration.
- `functions/lib` was rebuilt cleanly with only `clubs` and `events` output
  folders; stale compiled `runs` / `runClubs` tests are gone.

Remote cleanup plan:

- First back up or export existing `users`, `publicProfiles`, and old
  `runClubs` documents for each Firebase environment.
- Copy existing `runClubs` documents into `clubs` if we want to preserve current
  host organizations under the new collection name.
- Reset event-specific collections and edges: old `runs`, `runParticipations`,
  `savedRuns`, event reviews, event schedule locks, event-derived swipes, and
  any generated event/demo documents.
- Re-run seed scripts or host tooling against the new `events` / `clubs`
  collections once the remote reset is complete.
