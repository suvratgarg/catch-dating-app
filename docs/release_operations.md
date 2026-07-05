---
doc_id: release_operations
version: 1.7.9
updated: 2026-07-06
owner: recursive_audit_loop
status: active
---

# Release Operations

This is the durable owner for CI gates, Firebase deployment ordering, and
release-readiness evidence. It replaces dated one-off runbooks and should stay
short enough to be read before a deploy.

## Native Splash Assets

The native splash is generated from the `flutter_native_splash:` block in
`pubspec.yaml`; edit that config and run `dart run flutter_native_splash:create`
instead of hand-editing platform drawables/storyboards. Before regenerating,
verify the configured splash image is a transparent mark that composites cleanly
on both `#F4F4F1` and `#0F0E10`; a baked app-icon tile is not an acceptable
native splash image.

## Required PR Checks

Configure GitHub branch protection for `main` to require:

- Flutter analysis and tests.
- Functions lint/build/tests.
- Firestore rules emulator tests.
- Schema contract validation (the `contracts/` source of truth).
- Sizing doctrine check (`tool/check_sizing.sh` exits 0).
- Web build.
- Android debug APK build.
- iOS simulator build.

The current workflows are:

| Workflow | Purpose |
|---|---|
| `.github/workflows/flutter-ci.yml` | Design parity gate, Flutter analysis, unit/widget tests, and UI lint smoke checks. |
| `.github/workflows/functions-ci.yml` | Functions lint/test plus Firestore contract check on Node 24. |
| `.github/workflows/firestore-rules-ci.yml` | Firestore contract check plus emulator-backed rules tests. |
| `.github/workflows/contracts-ci.yml` | Validates the `contracts/` schema source of truth: source validity, generated-output freshness, schema/type boundaries, path literals, and rules semantics. |
| `.github/workflows/app-build-matrix.yml` | Dev web, Android debug APK, and iOS simulator build gates. |
| `.github/workflows/firebase-dev-deploy.yml` | Automatic dev Firebase deploy after `main` is green. |
| `.github/workflows/firebase-deploy.yml` | Manual deploy of selected Firebase targets to dev, staging, or prod. Keep staging/prod explicit. |
| `.github/workflows/data-validation.yml` | Read-only Firestore data validation, nightly and manual. |
| `.github/workflows/admin-website.yml` | Validates and deploys the production Firebase Hosting `admin` target after matching changes land on `main`. |
| `.github/workflows/release-readiness.yml` | Manual staging/prod release gate. |
| `.github/workflows/ios-testflight-release.yml` | Manual prod iOS archive/export gate, plus automatic Host TestFlight upload after app-relevant changes land on `main`. Consumer TestFlight stays Xcode Cloud-first. |
| `.github/workflows/observability-evidence.yml` | Manual Crashlytics and Analytics evidence capture. |

## Git Branch Hygiene

Treat PR branches as single-use. After a PR branch is merged into `main`, do
not keep committing to that same branch for the next slice of work. GitHub adds
a merge commit to `main`, and a reused branch can look locally ahead while still
missing the new `origin/main` merge commit. That produces repeat PR conflicts
and huge compare diffs.

Before staging or opening a PR:

1. Run `git fetch origin main`.
2. Check `git rev-list --left-right --count origin/main...HEAD`.
3. If the first number is not `0`, the current branch is behind `origin/main`;
   start a fresh `codex/<task>` branch from `origin/main` or rebase before new
   work.
4. If the branch already has a merged or conflicted PR, prefer a fresh branch
   from `origin/main` and cherry-pick only the still-needed commits.

Do not trust stale local `main` for this check. Use `origin/main` as the source
of truth, and close any superseded conflicted PR after the replacement branch is
published.

## GitHub Environments And Auth

Firebase deploy and data-validation workflows use GitHub OIDC rather than
long-lived service-account JSON secrets. Use GitHub Environments named `dev`,
`staging`, and `prod`. Require manual reviewers for `prod`.

Each GitHub Environment must define these variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

The corresponding Google Cloud service accounts are:

- `github-actions-deploy@catchdates-dev.iam.gserviceaccount.com`
- `github-actions-deploy@catchdates-staging.iam.gserviceaccount.com`
- `github-actions-deploy@catch-dating-app-64e51.iam.gserviceaccount.com`

Do not add `FIREBASE_SERVICE_ACCOUNT_*` JSON secrets unless the OIDC setup is
intentionally retired.

## Algolia Server-Side Search Secrets

Explore server-side search stores runtime Algolia credentials in Firebase
Secret Manager, not in the client app and not in GitHub Actions. Use one
Algolia application per Firebase environment so data, analytics, write keys,
and emergency rotations stay isolated:

| Firebase project | Algolia app |
|---|---|
| `catchdates-dev` | `Catch Dev` |
| `catchdates-staging` | `Catch Staging` |
| `catch-dating-app-64e51` | `Catch Prod` |

The callable and index sync triggers use:

- `ALGOLIA_APP_ID`
- `ALGOLIA_SEARCH_API_KEY`
- `ALGOLIA_WRITE_API_KEY`

Use a search-only Algolia key for `ALGOLIA_SEARCH_API_KEY`. Do not use the
Algolia Admin API key for runtime search. `ALGOLIA_WRITE_API_KEY` is backend
only; use a write-capable key for Functions triggers and backfills, and keep it
out of the mobile app.

Create or rotate the runtime search secrets per Firebase project. Do not reuse
one app's key material across environments:

```sh
printf "Algolia application ID: "
IFS= read -r ALGOLIA_APP_ID
printf "Algolia search-only API key: "
stty -echo
IFS= read -r ALGOLIA_SEARCH_API_KEY
stty echo
printf "\n"
printf "Algolia write API key: "
stty -echo
IFS= read -r ALGOLIA_WRITE_API_KEY
stty echo
printf "\n"

for project in catchdates-dev catchdates-staging catch-dating-app-64e51; do
  printf "%s" "$ALGOLIA_APP_ID" |
    firebase functions:secrets:set ALGOLIA_APP_ID \
      --project "$project" \
      --data-file -
  printf "%s" "$ALGOLIA_SEARCH_API_KEY" |
    firebase functions:secrets:set ALGOLIA_SEARCH_API_KEY \
      --project "$project" \
      --data-file -
  printf "%s" "$ALGOLIA_WRITE_API_KEY" |
    firebase functions:secrets:set ALGOLIA_WRITE_API_KEY \
      --project "$project" \
      --data-file -
done
```

Verify metadata without printing secret values:

```sh
for project in catchdates-dev catchdates-staging catch-dating-app-64e51; do
  firebase functions:secrets:get ALGOLIA_APP_ID --project "$project"
  firebase functions:secrets:get ALGOLIA_SEARCH_API_KEY --project "$project"
  firebase functions:secrets:get ALGOLIA_WRITE_API_KEY --project "$project"
done
```

Index names default to `clubs` and `events`. Only override them with
`ALGOLIA_CLUBS_INDEX` or `ALGOLIA_EVENTS_INDEX` if an environment needs
different index names. These are not secrets.

Backfill after first setup or after changing searchable data shape:

```sh
ALGOLIA_APP_ID="<env app id>" \
ALGOLIA_WRITE_API_KEY="<env write key>" \
node tool/data/backfill_algolia_explore_search.mjs \
  --env prod \
  --apply \
  --allow-prod
```

For dev or staging, change `--env` and omit `--allow-prod`.

Algolia index settings must allow the function filters:

- Clubs index: make `location` filterable/facetable.
- Events index: make `discoveryCityName` filterable/facetable and store
  `startTimeEpoch` as a numeric attribute.

## Required Secrets

Build workflows need environment-specific Google Maps SDK secrets. Do not rely
on a generic fallback secret, because that can silently mix project keys across
flavors:

- `GOOGLE_MAPS_ANDROID_API_KEY_DEV`
- `GOOGLE_MAPS_ANDROID_API_KEY_STAGING`
- `GOOGLE_MAPS_ANDROID_API_KEY_PROD`
- `GOOGLE_MAPS_IOS_API_KEY_DEV`
- `GOOGLE_MAPS_IOS_API_KEY_STAGING`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

The manual `iOS TestFlight Release` workflow also needs these repository or
`prod` environment secrets:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

`APP_STORE_CONNECT_API_KEY_BASE64` is the base64-encoded contents of the
downloaded `AuthKey_<key-id>.p8` file. Keep the raw `.p8` out of git; it is
ignored by `.gitignore` and should live only in secure local storage and GitHub
Actions secrets.

## CD Policy

Firebase CD is intentionally asymmetric by environment:

- `dev` deploys automatically from `main` after the required CI/build workflows
  for that exact commit pass.
- `staging` deploys only through the manual `Firebase Deploy` workflow.
- `prod` deploys only through the manual `Firebase Deploy` workflow and should
  require GitHub Environment reviewer approval.

The automatic dev deploy is a backend deploy, not a store release. It deploys
Functions, Firestore indexes, Firestore rules, and Storage rules in the safe
order. Mobile app binaries, Play internal testing, Hosting, and observability
evidence remain separate release steps unless explicitly added to the selected
manual deploy targets. Host iOS is the exception: app-relevant pushes to `main`
run `.github/workflows/ios-testflight-release.yml` with `app_role=host` and
upload the exported IPA to TestFlight, because Host Xcode Cloud distribution is
not currently safe to rely on.

Marketing and admin Hosting deploys require explicit Vite Firebase/App Check
environment variables. Firebase Hosting predeploy runs
`tool/env/check_web_hosting_env.mjs` for both targets so a deployment fails
before build if the site would fall back to dev Firebase config, sample admin
mode, or missing App Check.

The production admin Hosting target has its own `Admin Website` workflow. It
validates `npm run web:admin:build`, checks live prod Vite Firebase/App Check
env, then deploys only `hosting:admin` after matching changes land on `main`.

The manual `Firebase Deploy` workflow forwards these GitHub Environment
variables into Firebase Hosting predeploys when `hosting` is selected:
`VITE_FIREBASE_API_KEY`, `VITE_FIREBASE_AUTH_DOMAIN`,
`VITE_FIREBASE_PROJECT_ID`, `VITE_FIREBASE_STORAGE_BUCKET`,
`VITE_FIREBASE_MESSAGING_SENDER_ID`, `VITE_FIREBASE_APP_ID`,
`VITE_FIREBASE_MEASUREMENT_ID`, `VITE_WEBSITE_APPCHECK_SITE_KEY`,
`VITE_ADMIN_DATA_MODE`, `VITE_ADMIN_FIREBASE_ENV`, and
`VITE_ADMIN_APPCHECK_SITE_KEY`. `VITE_GTM_ID` is optional until the production
GTM container exists; paid-acquisition readiness still requires setting it and
validating consent-aware tags. The environment-specific values must match the
selected Firebase alias; for prod, `VITE_FIREBASE_PROJECT_ID` must be
`catch-dating-app-64e51` and `VITE_ADMIN_FIREBASE_ENV` must be `prod`.

If the automatic dev deploy fails, fix the branch with a new PR rather than
rerunning deploys against a stale commit. Use the manual `Firebase Deploy`
workflow for intentional redeploys or environment-specific recovery.

Current note from the 2026-05-20 environment pass: the Cloud Billing API
blocker is resolved in dev, staging, and prod, and the latest automatic
`Firebase Dev Deploy` run on `main` passed. Keep using
`tool/deploy_firebase_targets.sh` so the logical `functions` target expands to
explicit callable names and does not prompt to delete legacy live run/run-club
functions in non-interactive CI.

## Release Setup Evidence Snapshot

Current setup/build/signing/distribution verdict: there is no known local
build, Firebase, Firestore, Gradle, Xcode, Apple signing, Developer ID,
notarization, App Check, or trust-chain blocker remaining in the current
workspace. Host app store distribution still needs product-release evidence:
Xcode Cloud setup for `com.catchdates.host` and a host TestFlight
upload/install/launch proof.

Verified setup state:

- Web builds, Android signed APK/AAB creation, iOS App Store IPA export, and
  macOS release builds have passed in the current release setup evidence.
- Android upload-key SHA-1/SHA-256 fingerprints are registered on Firebase for
  the currently verified consumer and host upload artifacts.
- Firebase App Check provider configs and enforcement are verified for the
  consumer Android, iOS/macOS, and web registrations plus the 2026-06-10 host
  Android, iOS, and web registrations. Host Android uses Play Integrity, host
  iOS uses App Attest, and host web uses reCAPTCHA Enterprise across dev,
  staging, and prod.
- Apple Developer App ID `Catch Host` / `com.catchdates.host` is registered
  under team `2HQBK4UMUT` with App Attest, Associated Domains, HealthKit, and
  Push Notifications enabled. App Store Connect app `Catch Host` exists as app
  id `6778927317`, SKU `catch-host-ios`, primary language English (U.S.), iOS
  platform, and Full Access user access.
- Direct macOS distribution is Developer ID signed, timestamped, notarized,
  stapled, and Gatekeeper accepted.
- Consumer TestFlight upload/install/launch and iOS Maps behavior are confirmed
  through App Store Connect/Xcode Cloud evidence. Host TestFlight still needs a
  real archive/upload/install/launch proof after the Apple-side app record and
  Xcode Cloud workflow are configured.

Still outside this setup verdict:

- Android real-device smoke testing remains hardware-gated until an authorized
  Android phone is connected.
- macOS phone-auth runtime behavior is intentionally deferred because Firebase
  Auth `verifyPhoneNumber()` is unavailable on macOS.
- Play internal testing, store metadata, privacy/data-safety forms,
  screenshots, legal/support URLs, and production Crashlytics/Analytics
  dashboard validation remain release-management/product tasks.
- App Store Connect currently displays an updated Apple Developer Program
  License Agreement notice. The Account Holder should accept it before treating
  host TestFlight uploads or store submissions as release-ready if Apple blocks
  either action.
- Play app-signing certificate fingerprints still need to be added to Firebase
  after Play Console enrollment. Local upload-key fingerprints are already
  registered.
- Mac App Store distribution has not been validated. Direct Developer ID
  distribution is validated.

## App Version And Force-Update Gate

Every store release candidate that may be enforced through Remote Config must
increment the `pubspec.yaml` build number. The marketing version can stay stable
when the release is compatibility or migration focused, but the build number
must still move so Firebase Remote Config can target old binaries precisely.

Current release candidate:

```text
version: 1.0.1+3
```

Flutter maps this to:

- Android `versionCode`: `3`
- iOS `CFBundleVersion`: `3`
- macOS `CFBundleVersion`: `3`

After the compatible binary is available to users, raise only the platform keys
for platforms included in that release:

```text
min_build_ios = 2
min_build_android = 2
min_build_macos = 2
```

Keep `min_version` broad unless the release intentionally changes the public
marketing version. Use the platform build gates for schema/API compatibility
work because they are less ambiguous than semantic version strings.

For storage/API migrations:

1. Deploy backend support that can tolerate both old and new clients.
2. Ship the client release with dual-read/dual-write support.
3. Wait until the released build is actually available through the relevant
   store or distribution channel.
4. Raise the Remote Config `min_build_*` value for released platforms.
5. Rerun the migration-specific parity gate and record the prod evidence before
   cleanup.
6. Cut over backend triggers or remove legacy write support only after the
   parity gate passes with the force-update gate in place.

Remote Config shortens the compatibility window, but it does not eliminate it
at release time. A client can start offline, fetch can fail, and store rollout
timing can lag. Keep legacy-compatible reads/writes until the explicit parity
and force-update cutover step is complete.

The `swipes` to `profileDecisions` migration is already complete: dev, staging,
and prod cleanup finished on 2026-05-26, and the one-time migration tools were
retired on 2026-06-02.

The checked-in baseline template is `firebase/remote_config.template.json`.
Its default values are deliberately non-blocking. Use it to seed a project or
recover missing parameters, then raise `min_build_*` only as a deliberate
release action after the compatible binary is available.

Production release builds throttle Remote Config fetches to a one-hour minimum
interval. Debug builds, emulator builds, and non-production environments keep a
zero interval so config changes are easy to validate during QA.

## Pre-Deploy Checklist

- Review `git diff --stat` and confirm the dirty tree is the intended release
  candidate.
- Run code generation if generated Dart or Firestore TS types are stale.
- Run `./tool/check_data_contract.sh`.
- Run focused Flutter analysis/tests for touched surfaces.
- Run `npm --prefix functions run lint`.
- Run `npm --prefix functions test`.
- Run Firestore rules tests through the emulator:
  `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"`.
- Make the beta data strategy explicit: reset demo data or validate migration
  tooling before production users depend on the new schema.
- Confirm Remote Config force-update values are planned but not raised until a
  compatible app build is available.

## One-Time Environment Setup

Before rules or Functions depend on them, each Firebase/GCP environment needs:

- Cloud Vision API enabled for photo moderation.
- `config/cities` Firestore document with `cityNames` and full city objects.
- Firestore TTL policy on `rateLimits.expiresAt`.
- Firebase Functions secrets for payment, maps/places, and any other
  environment-owned provider keys.
- Google Maps SDK/Places APIs enabled and key restrictions configured as
  described in `docs/location_stack_plan.md`.
- Firestore BigQuery export extensions installed where marketplace/event-success
  metrics should be queryable.
- Firebase Analytics linked to the intended Google Analytics property, web
  measurement IDs refreshed, GA4 BigQuery export enabled where needed, and
  DebugView evidence captured for the target app id.

### Payment Provider Setup TODO

Do not treat international paid events as launch-ready until these items are
complete for each target environment (`dev`, `staging`, and `prod`):

- [ ] Create environment-owned Stripe platform credentials. Keep test and live
  mode keys separate, and do not reuse another environment's secret key.
- [ ] Set the Stripe Functions secrets in each Firebase project:
  `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET`.
  As of 2026-05-28, `dev`, `staging`, and `prod` have non-real placeholder
  values for both secrets so unrelated Functions deploys are not blocked by
  missing Stripe bindings. Replace those Secret Manager values with
  environment-owned Stripe credentials before enabling Stripe onboarding,
  checkout, or webhooks.
- [ ] Configure Stripe webhook endpoints per environment for the exported
  `stripeWebhook` HTTPS Function. Subscribe at minimum to Checkout Session
  completion and expiration events used by the backend booking flow, then copy
  the endpoint signing secret into `STRIPE_WEBHOOK_SECRET`.
- [ ] Confirm the Stripe Connect platform responsibilities before enabling
  host onboarding. The current backend creates Accounts v2 connected accounts,
  requests merchant card-payment capability, and uses destination Checkout
  Sessions with `transfer_data.destination` and `on_behalf_of`.
- [ ] Decide and configure the platform fee policy through
  `STRIPE_APPLICATION_FEE_BPS` per environment. Leave it at `0` only when
  Catch is intentionally not taking an application fee.
- [ ] Set production-safe redirect URLs for Stripe onboarding and checkout:
  `STRIPE_CONNECT_RETURN_URL`, `STRIPE_CONNECT_REFRESH_URL`,
  `STRIPE_CHECKOUT_SUCCESS_URL`, and `STRIPE_CHECKOUT_CANCEL_URL`. The checked-in
  code defaults point at `catchdates.com` and exist only so noninteractive
  Functions deploys keep working before Stripe launch. Review and override them
  before staging/prod payment rollout.
- [ ] Create environment-owned Razorpay credentials before live INR payments.
  Current non-prod/prod state has reused test-mode Razorpay secrets; replace
  them with the intended `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` values per
  Firebase project.
- [ ] Replace the temporary `RAZORPAY_WEBHOOK_SECRET` values before enabling
  real Razorpay webhooks. As of 2026-06-26, `dev`, `staging`, and `prod` each
  have an enabled placeholder Secret Manager version so unrelated Functions
  deploys are not blocked while Razorpay account approval is pending.
- [ ] Deploy Functions after secrets and params are present:
  `./tool/deploy_firebase_targets.sh <env> functions`.
- [ ] After callable Functions deploy, run
  `npm --prefix functions run sync:callable-invokers -- <project-id>` for the
  deployed project if callable invoker bindings were not part of the deploy.
- [ ] Smoke test the full paid-event matrix in the target environment:
  free booking, INR Razorpay checkout success/cancel/refund, non-INR Stripe host
  onboarding, non-INR Stripe checkout success/cancel/expiration webhook, payment
  history, booking count projections, waitlist/race-loss refund behavior, and
  host cancellation refund behavior.
- [ ] Record the smoke evidence in the release notes before enabling production
  host-created international paid events.

## Firebase Deploy Order

For backend/schema-affecting releases, deploy in this order per environment:

1. Functions.
2. Firestore indexes.
3. Firestore rules.
4. Storage rules.
5. Hosting or app surfaces, when applicable.

Deploy Functions before tightening rules when a release moves writes behind new
callables. Do not use Remote Config as a schema migration tool; use it only to
block older app builds after the compatible build is available.

`./tool/deploy_firebase_targets.sh` deploys the logical `functions` target by
expanding the current exports from `functions/src/index.ts` into explicit
`functions:<name>` targets. This keeps legacy live Functions, such as old
run/run-club callables, deployed until a deliberate cleanup plan removes them.
Do not use a broad `firebase deploy --only functions --force` unless deleting
legacy Functions is the intended release action.

Typical commands:

```bash
./tool/deploy_firebase_targets.sh dev functions,firestore:indexes,firestore:rules,storage
./tool/deploy_firebase_targets.sh staging functions,firestore:indexes,firestore:rules,storage
./tool/deploy_firebase_targets.sh prod functions,firestore:indexes,firestore:rules,storage
```

Remote Config is intentionally separate from the standard backend deploy:

```bash
./tool/deploy_firebase_targets.sh dev remoteconfig
./tool/deploy_firebase_targets.sh staging remoteconfig
./tool/deploy_firebase_targets.sh prod remoteconfig
```

Firebase Extensions (`firestore-bigquery-export` instances in `firebase.json`)
are **not** part of the standard backend deploy and are not in the
`deploy_firebase_targets.sh` default target set. When extension parameters
change in `firebase.json`, deploy them explicitly and deliberately:

```bash
./tool/firebase_with_env.sh prod deploy --only extensions
```

Otherwise extension config in the repo silently drifts from what is installed.

Host analytics uses BigQuery as the reporting source of truth. Before deploying
or refreshing it, run the local wiring check:

```bash
node tool/run.mjs check analytics:check-host-bigquery
```

Use this production order so the mart is never refreshed before its source
exports exist:

```bash
# 1. Create the analytics dataset and host analytics tables.
tool/analytics/deploy_host_analytics_bigquery.sh prod --skip-refresh

# 2. Install or update the Firestore-to-BigQuery export extensions.
./tool/firebase_with_env.sh prod deploy --only extensions

# 3. Deploy only the callable code that records and reads analytics.
./tool/firebase_with_env.sh prod deploy --only \
  functions:getHostAnalytics,functions:adminGetHostAnalytics,functions:recordOrganizerAnalyticsEvent

# 4. After the bq-host-* backfill/export views exist, refresh and schedule.
tool/analytics/deploy_host_analytics_bigquery.sh prod \
  --refresh-only \
  --create-schedule

# 5. Verify the live backend state.
node tool/analytics/host_analytics_live_status.mjs --env prod
```

Use `--dry-run` first when validating credentials or SQL syntax locally.
`--create-schedule` is idempotent by display name: it updates the existing
scheduled-query transfer config when exactly one matching config exists, creates
it when none exists, and fails if duplicate configs already exist.

Live prod evidence from 2026-06-18 before the first host analytics deploy:
`catch_analytics` did not exist, no `bq-host-*` extension instances were
installed, no matching scheduled query existed, and
`getHostAnalytics` / `adminGetHostAnalytics` /
`recordOrganizerAnalyticsEvent` were not deployed. Do not treat checked-in
analytics code as live until the four-step sequence above has completed and the
post-deploy smoke checks prove it. The live-status command above is expected to
exit nonzero until all required BigQuery tables/views, extension instances,
scheduled refresh, and callable Functions are present.

The required IAM is not optional. The Functions runtime service account needs
`roles/bigquery.jobUser` at project scope plus access to `catch_analytics`
because the public analytics callable inserts into
`catch_analytics.host_analytics_events` and the host/admin callables read
`catch_analytics.mart_host_event_daily`. The deployer or scheduled-query
identity needs `roles/bigquery.jobUser`, write access to `catch_analytics`, and
read access to `catch_marketplace_metrics` for Event Success scorecard joins.
The `bq-host-*` extension service accounts must retain write access to their
own export tables. The host export env files intentionally use
`EXCLUDE_OLD_DATA=no` so first install backfills existing host data.

After production Functions deploys, sync callable invokers if needed:

```bash
npm --prefix functions run sync:callable-invokers -- \
  catchdates-dev catchdates-staging catch-dating-app-64e51
```

### Explore Event Discovery Rollout

When a release depends on direct event discovery, do the safe checks before any
write:

```bash
node tool/data/backfill_event_discovery_fields.mjs --env dev --summary-only
node tool/data/backfill_event_discovery_fields.mjs --env staging --summary-only
node tool/data/backfill_event_discovery_fields.mjs --env prod --summary-only
firebase firestore:indexes --project catchdates-dev --pretty
firebase firestore:indexes --project catchdates-staging --pretty
firebase firestore:indexes --project catch-dating-app-64e51 --pretty
```

Read-only index listings on 2026-05-26 showed dev, staging, and prod still had
only the legacy `events` indexes (`status/startTime` and `clubId/startTime`).
Deploy `firestore:indexes` and wait for every discovery index to become
`READY` before enabling an app build that relies on the direct event query.

Then deploy Functions and indexes before applying any backfill. Apply the
backfill only after reviewing the dry-run counts for that environment:

```bash
./tool/deploy_firebase_targets.sh dev functions,firestore:indexes
node tool/data/backfill_event_discovery_fields.mjs --env dev --apply
```

Repeat for staging, then prod. Production backfill requires `--allow-prod`.
After each environment, smoke test Explore with city, time, activity, distance,
map pin, saved-event, signed-up-event, hosted-event, and club-metadata cases.
In a release-like build with observability enabled, verify
`explore_event_opened` and `explore_map_event_selected` in Analytics DebugView.

When the admin Organizers and Events canonical directories depend on
token-backed search, dry-run and then apply the admin-search projection repairs
after Functions have been built from the matching code:

```bash
npm --prefix functions run build
node tool/data/backfill_organizer_admin_search.mjs --env dev --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env staging --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env prod --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env dev --apply
node tool/data/backfill_event_admin_search.mjs --env dev --summary-only
node tool/data/backfill_event_admin_search.mjs --env staging --summary-only
node tool/data/backfill_event_admin_search.mjs --env prod --summary-only
node tool/data/backfill_event_admin_search.mjs --env dev --apply
```

Repeat for staging, then prod. Production apply requires `--allow-prod`.

## Smoke Tests

After a backend deploy, smoke test:

- Phone sign-in and onboarding continuation.
- Profile edit and public profile projection.
- Create/join/leave club.
- Create event, join free event, paid booking where enabled, waitlist, cancellation.
- Self check-in and host attendance.
- Swipe, match, chat message, unread count, block/report.
- Payment history, review prompt, notifications.
- Demo-data validation for the affected environment when demo tooling changed.

## Verifying Analytics, Crashlytics, And BigQuery

Observability collection is gated, so a normal debug `flutter run` deliberately
sends **nothing** — this is expected, not a bug.

### When collection is on

`AppConfig.shouldCollectObservability` (in `lib/core/app_config.dart`) controls
both Firebase Analytics and Crashlytics. It is true only when:

- the build is release mode **and** the environment is `prod`; or
- a release/profile build passes `--dart-define=ENABLE_OBSERVABILITY_COLLECTION=true`.

In a debug build it is always false: `AppAnalytics.initialize()` calls
`setAnalyticsCollectionEnabled(false)`, so even Firebase **DebugView shows
nothing** (DebugView requires collection to be enabled).

### How to verify Analytics events reach Firebase

1. Run with collection forced on (the env wrapper forwards the flag as a
   dart-define):

   ```bash
   ENABLE_OBSERVABILITY_COLLECTION=true ./tool/flutter_with_env.sh dev run
   ```

2. For iOS DebugView also add the launch argument `-FIRDebugEnabled`
   (Xcode scheme → Run → Arguments), or `adb shell setprop debug.firebase.analytics.app <applicationId>` on Android.
3. Exercise flows that call `AppAnalytics.logEvent` (auth, club view, booking,
   swipe, chat).
4. Confirm the events in Firebase Console → Analytics → **DebugView** for the
   matching environment's project.
5. Record the proof through the `observability-evidence.yml` workflow.

A smoke build can also emit a single canary event with
`--dart-define=EMIT_OBSERVABILITY_SMOKE_EVENT=true` (event name
`observability_smoke`).

### BigQuery — two separate exports, do not conflate them

- **Firestore → BigQuery**: configured in-repo. `firebase.json` declares the
  Event Success, participant metric, and host analytics operational export
  instances. Existing `bq-event-success-*` and `bq-participant-*` instances are
  installed in all three projects; newly declared `bq-host-*` instances must be
  deployed explicitly before host analytics marts can refresh from live data.
  Extension parameter changes are **not** part of the normal
  `deploy_firebase_targets.sh` target set — push them with an explicit
  `firebase deploy --only extensions` when changed.
- **GA4 → BigQuery**: a Google Analytics Admin product link, not repo config.
  Production is linked as of 2026-05-23: GA4 property `catch-dating-app-64e51`
  (`p526484083`) exports daily event data to BigQuery project
  `catch-dating-app-64e51` (`catch-dating-app`, project number
  `574779808785`) in `Mumbai (asia-south1)`. The expected dataset is
  `analytics_526484083`. All 6 streams are included, no events are excluded,
  and streaming export, mobile advertising identifiers, and daily user-data
  export are disabled. GA4→BigQuery only exports from the day it is enabled.
  Capture the dataset link/table proof in the `ga4_bigquery_evidence` input of
  `observability-evidence.yml` after the first daily table lands.
- **Host analytics marts**: source-controlled DDL and refresh SQL live under
  `analytics/sql/**`. `getHostAnalytics` and `adminGetHostAnalytics` read
  `catch_analytics.mart_host_event_daily`; `recordOrganizerAnalyticsEvent`
  writes aggregate-safe discovery events to
  `catch_analytics.host_analytics_events`. The mart also reads
  `analytics_526484083.events_*` for `organizer_<eventName>` GA4 exports when
  the dataset/tables exist, using the larger direct-vs-GA4 daily count per
  club/event/event-name key to avoid double-counting mirrored browser events.
  Apply the warehouse layer with
  `tool/analytics/deploy_host_analytics_bigquery.sh <env>` after deploying the
  `bq-host-*` extension instances.

## Automated Integration Test Backlog

Feature-flow integration tests should cover the same user journeys as the
manual smoke checklist, with Firebase, payment, notification, location, and
image-picker side effects replaced unless the test is explicitly device or
emulator backed.

- Auth and onboarding: phone entry, OTP continuation, profile-step resume,
  required-field validation, photo/running preference completion, and redirect
  to the authenticated shell.
- Routing and app shell: unauthenticated redirects, authenticated redirects,
  five-tab navigation, top-level route back behavior, FCM/deep-link chat routes,
  and inactive-tab stream gating.
- Dashboard: empty state, booked-event state, activity tab, next-event CTA,
  swipe-window CTA, and recommended-event navigation.
- Clubs: city selection, search, joined/discover partitioning, club detail,
  create club, edit club, join, leave, and host-only affordances.
- Events: create event, event detail, free booking, paid booking handoff, waitlist,
  cancellation, self check-in, host attendance, map view, and location picker.
- Catches and swipes: eligible attended-event list, swipe deck, empty candidate
  states, like/pass decisions, match creation result, and event recap.
- Chats: matches list, search, chat route hydration, message send, unread reset,
  block/report, and push/FCM route handling.
- Payments and reviews: payment confirmation, payment history, review prompt,
  create/update/delete review, and post-event review visibility.
- Profile and settings: inline profile edits, photo upload replacement,
  public-profile projection, notification preferences, sign out, and account
  deletion/anonymization entry points.
- Platform/device flows: App Check, real phone auth, push permission/token
  registration, image upload, real map rendering, Razorpay checkout, analytics
  DebugView, and Crashlytics visibility.

### Current Pending Integration Tests

Last updated: 2026-06-04.

The deterministic app-shell integration architecture is folded into this
release runbook. Run the split local suite with:

```bash
node tool/run.mjs run test:app-shell-integration
```

The split suite covers app-shell launch/routing plus focused club, event,
dashboard, Catches, chat, settings, review, and regression flows with service
side effects faked at repository/provider boundaries. Keep the pending
live-service tests below out of the default local suite unless they are made
emulator-backed or gated behind an explicit device/live-service test target.

| Area | Local code-side coverage now present | Pending test/evidence | Required environment |
| --- | --- | --- | --- |
| App Check | Backend errors map App Check failures; app bootstrap activates App Check in `main.dart`. | Prove enforced App Check accepts the app's token and rejects missing/invalid tokens for Auth, Firestore, Storage, and callable Functions. | Firebase dev/staging project with App Check enforcement enabled plus registered debug token or release attestation. |
| Real phone auth | App-shell integration covers phone entry, OTP continuation, and repository calls with a fake auth repository. | Complete a real OTP send and sign-in against Firebase Auth. | Physical iOS/Android device or Firebase Auth emulator; use a Firebase test phone number for repeatability. |
| Push permission and token registration | App-shell integration verifies authenticated shell invokes FCM initialization; routing tests cover FCM chat route handling; backend notification producers are covered separately. | Grant/deny notification permission, save a real FCM token to `users/{uid}.fcmToken`, receive a push, and tap it into the intended route. | iOS/Android device or simulator with push support and Firebase Messaging configured for the target app id. |
| Image picker and Storage upload | App-shell integration covers picking a club cover through the full routed UI and passing uploaded URL into create-club submission with a fake upload repository. | Pick media through the native picker and upload to Firebase Storage under enforced Storage/App Check rules. | iOS/Android simulator/device with photo-library permission and Firebase Storage in dev/staging. |
| Real map rendering | Create-event integration opens the map picker and selects a map coordinate through the `GoogleMap` widget callback. TestFlight iOS Maps behavior is verified through App Store Connect/Xcode Cloud TestFlight proof as of 2026-05-21. | Repeat real map tile/marker proof when Maps key injection, bundle IDs, or store distribution settings change; verify Android separately before Play release. | iOS/Android simulator/device with configured Google Maps/Places keys and network access. |
| Razorpay checkout UI | App-shell integration covers paid booking handoff and confirmation with a fake payment repository; payment repository tests cover typed Razorpay success/error callbacks and callable verification contract. | Open the native Razorpay checkout sheet, complete/cancel a test payment, and verify post-payment booking state. | iOS/Android device or simulator supported by `razorpay_flutter`, with Razorpay test keys and callable Functions. |
| Analytics DebugView | App-shell integration verifies route screen views reach `AppAnalytics`; unit tests cover event sanitization and collection gating. Dev/staging/prod Firebase projects are linked to GA4 properties under Analytics account `365970973`. Prod GA4 BigQuery export is linked to `catch-dating-app-64e51` in `asia-south1` with expected dataset `analytics_526484083`. | See expected auth/routing/booking/review events in Firebase Analytics DebugView for a real build, then record first BigQuery `events_YYYYMMDD` table proof once the daily export lands. | Debug or release-like app build connected to Firebase Analytics DebugView for the target app id. |
| Crashlytics visibility | App-shell integration verifies the authenticated uid is attached to the crash reporter on cold launch; unit tests cover fatal/error reporting paths. | Trigger a non-production test crash/non-fatal error and confirm it appears with expected custom keys and symbolication. | Release-like iOS/Android build with Crashlytics collection enabled for dev/staging and dSYM/mapping upload configured. |

Do not make these live-service tests block every PR until they have stable
fixtures, reset/cleanup steps, and documented credentials. Prefer a separate
manual or scheduled workflow that records release evidence.

For observability smoke proof, use a profile or release-like non-production
build with collection explicitly enabled:

```bash
ENABLE_OBSERVABILITY_COLLECTION=true \
EMIT_OBSERVABILITY_SMOKE_EVENT=true \
./tool/flutter_with_env.sh staging run --profile -d <device-id>
```

The smoke define emits one nonfatal Crashlytics event with reason
`Observability smoke event` and one Analytics event named
`observability_smoke`. Use it only for dev/staging evidence or a deliberate
prod release smoke. After the dashboard rows appear, run the manual
`Observability Evidence` workflow and record the app build, Crashlytics proof,
Analytics proof, and GA4 BigQuery export status.

## iOS TestFlight Ownership

Decision as of 2026-05-21: Xcode Cloud is the canonical TestFlight uploader.
GitHub Actions owns PR checks, Firebase deploys, release-readiness validation,
and a manual iOS archive/export fallback.

Routine TestFlight distribution must come from Xcode Cloud. The GitHub
`iOS TestFlight Release` workflow should normally run with
`upload_to_testflight=false`; its TestFlight upload input is break-glass only
and requires a reason explaining why Xcode Cloud is not being used.

The workflow uses App Store Connect API key authentication for
`xcodebuild -allowProvisioningUpdates`, exports with
`ios/ExportOptions.prod.plist`, and stores the IPA as a short-lived GitHub
Actions artifact. It defaults to the consumer `prod` scheme with `Release-prod`;
selecting `app_role=host` archives `host-prod` with `Release-host-prod` and
expects bundle ID `com.catchdates.host`. Both paths verify the archived and
exported app contain the prod iOS Maps key, verify the exported bundle ID,
verify the exported profile contains HealthKit, and check the signed app
contains HealthKit and Associated Domains.

## Host TestFlight Status

The host app now has local/native build identity, Firebase identity, distinct
launcher icons, an Apple Developer App ID, an App Store Connect app record, and
GitHub break-glass archive/export support for `com.catchdates.host.dev`,
`com.catchdates.host.staging`, and `com.catchdates.host`, but routine
TestFlight distribution is not proven yet. Before external host beta
distribution:

1. Add or update the Xcode Cloud workflow to archive `host-prod` with
   `Release-host-prod`. Set `CATCH_APP_ROLE=host` on the workflow if Xcode Cloud
   does not expose the `host-prod` scheme through `CI_XCODE_SCHEME`.
   App Store Connect web for app id `6778927317` currently says to create the
   workflow in Xcode.
2. Add the required Xcode Cloud secret `GOOGLE_MAPS_IOS_API_KEY_PROD`.
3. Confirm provisioning, Associated Domains, HealthKit, Maps key injection,
   App Attest, and Firebase host config are present in the exported host IPA.
4. Upload one host build to TestFlight and verify install, launch, App Check,
   maps rendering, phone auth, push registration, and host event-management
   entrypoints.
5. Record Play internal-testing proof separately after Play Console enrollment;
   Play app-signing certificate fingerprints still need to be added to Firebase
   before Android release evidence is complete.

Current host icon status: host builds use generated `AppIcon-host-dev`,
`AppIcon-host-staging`, and `AppIcon-host-prod` catalogs on iOS/macOS, plus
Android `hostDev`, `hostStaging`, and `hostProd` launcher resources. Regenerate
them with `dart run tool/branding/generate_native_brand_assets.dart` after
native brand-token or base-icon changes.

## Xcode Cloud Start Conditions

The old 12 a.m. scheduled Xcode Cloud build was retired live in App Store
Connect on 2026-05-21. The `Default` Xcode Cloud workflow now starts from
branch changes on `main`, has auto-cancel enabled, and uses custom file/folder
rules so docs-only commits do not produce a new TestFlight build.

Current App Store Connect file/folder rules:

- Any file from `/lib`
- Any file from `/ios`
- Any file from `/assets`
- Any file from `/contracts`
- File name `pubspec.yaml` from any folder
- File name `pubspec.lock` from any folder
- Any file from `/tool`
- Any file from `/firebase/prod`

These rules live in App Store Connect, not in repository YAML. Re-check the
Xcode Cloud workflow after adding a new release-critical root path.

If a backend-only change intentionally requires a compatible app binary, start
the Xcode Cloud workflow manually after the backend deploy is promoted.

GitHub Actions iOS jobs and Xcode Cloud must all write
`ios/Flutter/GoogleMapsKeys.xcconfig` through
`tool/write_ios_maps_key_xcconfig.sh <env>`. The simulator build matrix uses
`dev`; TestFlight/Xcode Cloud release builds use `prod`. Keep Maps-key
validation in that shared helper instead of duplicating secret preflight logic
in each CI surface.

## Xcode Cloud iOS Builds

Xcode Cloud is a second iOS build path, separate from the GitHub Actions
`iOS TestFlight Release` workflow. The consumer workflow builds the `prod`
flavor with `Release-prod`; the host workflow should build `host-prod` with
`Release-host-prod`. Xcode Cloud can distribute either app to TestFlight
directly from App Store Connect once each app record and workflow is configured.

Two CI scripts drive it:

- `ios/ci_scripts/ci_post_clone.sh` reads the Flutter SDK version from
  `tool/ci/toolchain.env`, installs Flutter and Node, applies the prod Firebase
  environment for `consumer` or `host`, writes the prod iOS Google Maps key, and
  runs `pod install`. It uses `CATCH_APP_ROLE=host` or a `host-*` Xcode scheme to
  prepare `lib/main_host.dart` with the host prod flavor.
- `ios/ci_scripts/ci_post_xcodebuild.sh` verifies the archived app's
  `GoogleMapsApiKey` is a real key before the build can reach TestFlight.

GitHub Actions read the same `tool/ci/toolchain.env` file through local actions
under `.github/actions`. Update that file instead of editing workflow YAML or
Xcode Cloud scripts when changing public tool versions such as Flutter, Node,
Java, or Firebase CLI.

`ios/Flutter/GoogleMapsKeys.xcconfig` is gitignored, so it is never present in a
fresh clone. The Xcode Cloud workflow must define `GOOGLE_MAPS_IOS_API_KEY_PROD`
as a secret environment variable; `ci_post_clone.sh` calls
`tool/write_ios_maps_key_xcconfig.sh prod` to write the xcconfig and fail the
build if the key is missing or malformed. Without the key the archived
`GoogleMapsApiKey` is empty, `GMSServices.provideAPIKey` is skipped in
`AppDelegate`, and every map screen crashes at runtime.

Keep Xcode Cloud and the GitHub Actions archive workflow consistent: both must
inject and verify the environment-specific Maps key.

## Future GitHub-Only Migration

TODO: migrate TestFlight upload from Xcode Cloud to GitHub Actions only if we
want one repo-owned mobile release pipeline.

Migration checklist:

1. Add a change-aware GitHub release trigger, usually a protected
   `release/ios-testflight` branch or signed release tag.
2. Make the GitHub workflow perform the actual TestFlight upload by default for
   that trigger, not through the break-glass input.
3. Prove one full GitHub upload/install/launch/Maps cycle from TestFlight.
4. Disable Xcode Cloud TestFlight distribution and remove any Xcode Cloud
   schedule/start condition that can upload builds.
5. Update this document to mark GitHub Actions as canonical.

The repository can verify that the GitHub `prod` environment has the required
App Store Connect secret names and that the local/Xcode Cloud scripts fail
loudly when required release secrets are missing. It cannot prove App Store
Connect account settings, TestFlight group membership, export-compliance,
privacy, or review metadata state without direct App Store Connect access.

## Human Release Evidence

Already confirmed outside repository checks:

- TestFlight upload, install, launch, and iOS Maps behavior through the App
  Store Connect/Xcode Cloud build process before the nightly schedule was
  retired.

These still require human confirmation outside repository checks:

- Play internal testing evidence.
- Crashlytics visibility and symbolication evidence.
- Analytics DebugView event evidence.
- Store metadata, screenshots, privacy forms, support URL, privacy policy, and
  terms URL.

Run `Release Readiness` before store submission and `Observability Evidence`
after generating Crashlytics/Analytics proof.

## Store Product Backlog

The old production-release checklist was consolidated into this section on
2026-05-21. Keep store/account/product release tasks here instead of creating
another Codex audit checklist.

| Area | Remaining decision or proof |
|---|---|
| In-app reviews | Add `in_app_review`, choose high-satisfaction trigger moments, throttle prompts, and add a settings fallback after store IDs exist. |
| Legal and support links | Confirm public privacy, terms, support/contact, and account-deletion URLs; expose them from the settings surface and store metadata. |
| Accessibility | Run a large-text, VoiceOver/TalkBack, contrast, hit-target, and semantics pass across auth, onboarding, dashboard, clubs, events, catches, chat, and profile/settings. |
| Store metadata | Finalize listing name, screenshots, privacy forms, export-compliance answers, support URL, privacy policy, terms URL, and review notes. |
| Play internal testing | Produce Android internal-testing install/launch/maps evidence before Play release. |
| Observability | Capture Crashlytics visibility/symbolication and Analytics DebugView proof with a release-like dev/staging build. |
| Feature toggles and A/B testing | Defer until there is a concrete rollout problem; do not introduce a toggle framework as release ceremony. |
| Shorebird/code push | Defer for first release. Reconsider only after app-store release operations are stable and rollback policy is explicit. |
