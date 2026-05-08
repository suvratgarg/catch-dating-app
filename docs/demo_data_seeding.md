# Demo Data Seeding

This repo has a repeatable Firebase Admin SDK seeder for filling Catch with
realistic demo data. It is intended for TestFlight/dev/staging testing where
the app needs enough users, clubs, runs, attendance history, swipes, matches,
messages, payments, reviews, and notifications to exercise real flows.

The script is:

```bash
node tool/seed_demo_data.mjs
```

It is deterministic and dry-run-first. Generated documents use stable IDs with a
seed prefix, and every run writes a manifest to `seedRuns/{seedPrefix}_{scenario}`
so the same synthetic world can be deleted and recreated.

## What It Creates

Depending on the scenario, the seeder creates:

- synthetic `users/{uid}` and `publicProfiles/{uid}` documents;
- `runClubs/{clubId}` across supported Indian cities;
- `runClubMemberships/{clubId_uid}` for synthetic users and optional real anchor users;
- `runs/{runId}` with upcoming, full, waitlisted, cancelled, recently completed,
  and older completed states;
- `runParticipations/{runId_uid}` for signed-up, waitlisted, attended, and
  cancelled states;
- `savedRuns/{uid_runId}` for anchor users;
- `swipes/{uid}/outgoing/{targetUid}` and reciprocal likes for anchor-user match flows;
- `matches/{matchId}` and `matches/{matchId}/messages/{messageId}`;
- `payments/{paymentId}` for completed, refunded, and failed/sign-up-failed states;
- `reviews/{runId~reviewerUid}` and derived club rating summaries;
- `notifications/{uid}/items/{notificationId}` for dashboard activity.

Synthetic users do not get Firebase Auth accounts. They exist as public app
data so real TestFlight users can browse, attend seeded runs with them, swipe,
match, and chat.

Seeded matches use deterministic match IDs and write `runIds` instead of the
legacy single `runId`, so the chats list can collapse one visible conversation
per matched person while still preserving the shared-run history.

## Scenarios

List available scenarios:

```bash
node tool/seed_demo_data.mjs --list-scenarios
```

Current scenarios:

- `smoke`: small seed for quick dev/emulator checks.
- `beta-full`: full TestFlight-style world across every supported city.
- `city-dense`: many clubs and runs in one city for list/map/search stress.
- `empty-edge-cases`: sparse data for empty, expired, cancelled, and waitlist states.
- `paid-flow-demo`: paid booking/payment-history focused data.

## Prerequisites

Install Functions dependencies if needed:

```bash
npm --prefix functions install
```

Live Firebase writes use the Admin SDK, so the shell needs Application Default
Credentials or a service account:

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project catchdates-dev
```

Alternatively:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

Emulator runs do not need live credentials.

## Dry Run

Always start with a dry run:

```bash
node tool/seed_demo_data.mjs --env dev --scenario smoke
node tool/seed_demo_data.mjs --env dev --scenario beta-full --json
```

The output shows the target project, scenario, anchor users, document counts, and
manifest path. No documents are written unless `--apply` is present.

## Anchor Real TestFlight Users

Anchor users are the real accounts you and your friends/family log into on
TestFlight. The seeder reads their existing `users/{uid}` docs and creates demo
relationships around them.

Use UIDs:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-users uid1,uid2,uid3 \
  --allow-prod
```

Or use phone numbers exactly as stored in `users.phoneNumber`:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-phones +919999999999,+918888888888 \
  --allow-prod
```

Or use a file:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-file tool/demo_seed/beta_anchors.txt \
  --allow-prod
```

Plain text anchor files can contain one UID or phone number per line:

```text
# beta testers
abcFirebaseUid123
+919999999999
```

JSON anchor files can use either shape:

```json
{
  "uids": ["abcFirebaseUid123"],
  "phones": ["+919999999999"]
}
```

If an anchor user is missing, the script fails before writing. If an anchor user
does not have a `publicProfiles/{uid}` document, the dry run prints a warning.
Fix onboarding/profile sync first if that happens; the seeder intentionally does
not overwrite real user profiles.

Synthetic public identities must be deterministic and visibly distinct. The
chat list, search, and profile flows are too hard to QA when two synthetic
profiles share the same public name and primary photo. The seeder now generates
full display names and offsets repeated photos, and the data validator warns on
duplicate synthetic public name/photo pairs. If an environment was seeded before
this rule, rerun the seed with `--reset-synthetic` to replace the misleading
synthetic profiles.

## Apply To Dev Or Staging

For a real write to dev:

```bash
node tool/seed_demo_data.mjs \
  --env dev \
  --scenario beta-full \
  --anchor-users uid1,uid2 \
  --apply \
  --reset-synthetic
```

Validate the result:

```bash
node tool/validate_firestore_data.mjs --env dev
```

For staging:

```bash
node tool/seed_demo_data.mjs \
  --env staging \
  --scenario beta-full \
  --anchor-file tool/demo_seed/beta_anchors.txt \
  --apply \
  --reset-synthetic

node tool/validate_firestore_data.mjs --env staging
```

## Apply To Current TestFlight/Prod

Production writes require `--allow-prod` as an explicit guard:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-file tool/demo_seed/beta_anchors.txt \
  --apply \
  --allow-prod \
  --reset-synthetic
```

Then validate:

```bash
node tool/validate_firestore_data.mjs --env prod
```

Use this only while the current production database is still a disposable beta
dataset. Before public launch, clear the synthetic seed data and validate again.

## Add New Testers Later

Do not use `--reset-synthetic` when you only want to add newly invited testers.
Resetting deletes and recreates the whole synthetic world, which also recreates
existing testers' seeded notifications and unread state.

Add the new phone number or UID to `tool/demo_seed/beta_anchors.txt`, then dry
run append mode:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-file tool/demo_seed/beta_anchors.txt \
  --append-anchors \
  --allow-prod
```

If the dry run shows the expected new anchor count, apply it:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --anchor-file tool/demo_seed/beta_anchors.txt \
  --append-anchors \
  --apply \
  --allow-prod
```

Append mode reads the existing seed manifest, compares the current anchor file
against `anchorUserIds`, and writes only docs related to newly added anchors plus
run/club aggregate updates. It does not delete or recreate existing testers'
notification docs.

## Reset Without Re-Seeding

The reset behavior uses the prior manifest when present. To delete the current
scenario's synthetic docs and then recreate them, use `--reset-synthetic --apply`
with the same `--seed-prefix` and `--scenario`.

To remove the docs without recreating them:

```bash
node tool/seed_demo_data.mjs \
  --env prod \
  --scenario beta-full \
  --apply \
  --allow-prod \
  --reset-synthetic \
  --delete-only
```

Use the same `--scenario` and `--seed-prefix` that created the data. If the
manifest exists, the script deletes exactly the manifest paths; otherwise it
falls back to the current deterministic generated paths for that scenario.

## Emulator Use

With the Firestore emulator:

```bash
firebase emulators:exec --only firestore \
  "node tool/seed_demo_data.mjs --env dev --scenario smoke --emulator --apply --reset-synthetic"

firebase emulators:exec --only firestore \
  "node tool/validate_firestore_data.mjs --env dev --emulator"
```

This is useful for checking shape and aggregate integrity before touching live
Firebase projects.

## Operational Notes

- Default mode is dry run. `--apply` is required for writes.
- Prod writes require both `--apply` and `--allow-prod`.
- `--reset-synthetic` deletes only documents recorded in the seed manifest, or
  the current deterministic generated paths if no manifest exists.
- `--delete-only` removes the synthetic world and exits without recreating it.
- The script never deletes real anchor `users/{uid}` documents.
- Synthetic docs include `synthetic: true`, `seedPrefix`, and `scenario` fields.
- Run and club aggregate fields are computed from edge documents so the existing
  Firestore validator can catch drift.
- Matches are written directly by Admin SDK for seeded demo state; live app
  behavior still creates real matches from reciprocal swipes through Functions.

## Recommended Beta Workflow

1. Collect the TestFlight users' Firebase Auth UIDs or phone numbers.
2. Put them in `tool/demo_seed/beta_anchors.txt`.
3. Dry-run prod:

   ```bash
   node tool/seed_demo_data.mjs --env prod --scenario beta-full --anchor-file tool/demo_seed/beta_anchors.txt --allow-prod
   ```

4. Apply:

   ```bash
   node tool/seed_demo_data.mjs --env prod --scenario beta-full --anchor-file tool/demo_seed/beta_anchors.txt --apply --allow-prod --reset-synthetic
   ```

5. Validate:

   ```bash
   node tool/validate_firestore_data.mjs --env prod
   ```

6. Have each tester relaunch TestFlight and check:
   dashboard activity, club discovery, club detail, upcoming run detail, saved
   runs, paid/free booking states, attended run recap, swiping, matches, chat,
   payment history, reviews, and notification preferences.
