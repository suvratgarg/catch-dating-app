---
doc_id: release_operations
version: 1.9.1
updated: 2026-07-12
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
native splash image. The native splash mark is generated as transparent output
by `tool/branding/generate_catch_icon.swift` and is a separate asset from the
opaque launcher icon; edit the generator and `pubspec.yaml`, then re-run the
Swift generator and `flutter_native_splash:create`.

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
| `.github/workflows/mobile-internal-release.yml` | Canonical Consumer/Host mobile release matrix: signed iOS uploads to TestFlight and signed Android AABs with guarded Play internal upload. |
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
`staging`, `prod-hosting`, `prod-mobile`, and `prod`. `prod-hosting` is
approval-free and limited to the automatic marketing and admin Firebase
Hosting workflows. `prod-mobile` is approval-free and `main`-only; it contains
only mobile signing, Maps, App Store Connect, and Play-publisher credentials.
The mobile workflow has a matching fail-closed ref guard plus one global
release concurrency group. Keep required reviewers on shared `prod`, which owns
backend production deploys and production data operations. This gives all four
user-facing products merge-driven deployment without broadening approval-free
access to backend/data authority.

During cutover, reviewer-protected `prod` may still hold duplicate mobile
secrets as rollback material. The mobile workflow does not read them. Delete
those duplicates only after both GitHub iOS lanes process and both signed
Android lanes pass from `prod-mobile`.

Each Firebase deployment environment must define these variables:

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

The environment-scoped `Mobile Internal Release` workflow needs these
`prod-mobile` environment secrets for iOS:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

`APP_STORE_CONNECT_API_KEY_BASE64` is the base64-encoded contents of the
downloaded `AuthKey_<key-id>.p8` file. Keep the raw `.p8` out of git; it is
ignored by `.gitignore` and should live only in secure local storage and GitHub
Actions secrets.

Android release jobs require these `prod-mobile` environment secrets:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `GOOGLE_MAPS_ANDROID_API_KEY_PROD`

Play publishing uses the existing GitHub OIDC provider plus the environment
variables `GCP_WORKLOAD_IDENTITY_PROVIDER`,
`GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`, and `GOOGLE_PLAY_UPLOAD_ENABLED`. Keep
`GOOGLE_PLAY_UPLOAD_ENABLED=false` until both Play app records, Play App
Signing, internal tester lists, and app-scoped publisher permissions are
verified. Do not add a long-lived Google Play JSON key.

As of 2026-07-11, `androidpublisher.googleapis.com` is enabled and
`github-actions-play-publisher@catch-dating-app-64e51.iam.gserviceaccount.com`
exists with zero project roles. Its only IAM binding is
`roles/iam.workloadIdentityUser` for the exact GitHub OIDC subject
`repo:suvratgarg/catch-dating-app:environment:prod-mobile`. Play Console must
still invite that identity separately, scoped to the two app records and only
read-app plus testing-track release permissions.

After those grants exist, dispatch `Mobile Internal Release` from `main` with
`app_role=both`, `platform=android`, `probe_play_access=true`, uploads disabled,
and a reason. Each matrix lane creates an edit, reads `qa`, and deletes the edit
without uploading or committing. Set `GOOGLE_PLAY_UPLOAD_ENABLED=true` only
after both probes pass.

## CD Policy

Firebase CD is intentionally asymmetric by environment:

- `dev` deploys automatically from `main` after the required CI/build workflows
  for that exact commit pass.
- `staging` deploys only through the manual `Firebase Deploy` workflow.
- `prod` backend deploys only through the manual `Firebase Deploy` workflow and
  retains required-reviewer approval.

The automatic dev deploy is a backend deploy, not a store release. It deploys
Functions, Firestore indexes, Firestore rules, and Storage rules in the safe
order. Mobile binaries remain separate from backend deployment. App-relevant
pushes to `main` start `.github/workflows/mobile-internal-release.yml` for both
roles. The approval-free, main-only `prod-mobile` environment supplies the
matrix credentials; iOS uploads to
TestFlight, while Android builds and verifies signed AABs and uploads to Play's
`qa` internal track only after `GOOGLE_PLAY_UPLOAD_ENABLED=true`.

Marketing and admin Hosting deploys require explicit Vite Firebase/App Check
environment variables. Firebase Hosting predeploy runs
`tool/env/check_web_hosting_env.mjs` for both targets so a deployment fails
before build if the site would fall back to dev Firebase config, sample admin
mode, or missing App Check.

Both Hosting workflows use the approval-free `prod-hosting` GitHub Environment
and deploy automatically after their validation job succeeds on a matching
`main` push. Keep only Hosting/OIDC variables in that environment; App Store
Connect and mobile signing secrets are owned by `prod-mobile`; backend
production authority remains in reviewer-protected `prod`. Temporary mobile
rollback duplicates in `prod` follow the cutover cleanup above.

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
workspace. Mobile store distribution still needs external product-release
evidence: current TestFlight group assignment/install proof for both roles and
Play enrollment, processing, tester, signing-fingerprint, install, and launch
proof.

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
  platform, and Full Access user access. The native Host product deliberately
  signs without HealthKit and Associated Domains even if those capabilities
  remain enabled on the Developer portal record.
- Direct macOS distribution is Developer ID signed, timestamped, notarized,
  stapled, and Gatekeeper accepted.
- Consumer TestFlight upload/install/launch and iOS Maps behavior have legacy
  Xcode Cloud proof. GitHub Actions is now the canonical owner for both roles;
  each role still needs current processed-build and tester-group evidence.

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
- [ ] Confirm the Functions phase completed its automatic callable-invoker sync
  before the deploy advanced to indexes or rules.
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

The 2026-07-10 event-scoped Host inquiry change is a concrete two-phase case:
deploy the updated `startClubHostConversation` Function and generated payload
contract before distributing the new client. The client contains a narrow
compatibility retry that removes `eventId` only when the older callable returns
the exact `eventId ... additional properties` validation diagnostic. That
fallback prevents a premature TestFlight build from breaking Message Host, but
it creates a General inquiry and therefore is rollout safety—not event-provenance
closure. Wrong-club and other new-backend validation failures are never retried.

Host event broadcasts use an intentionally stricter backend-first rollout:

1. Merge and deploy `sendEventBroadcast`, its receipt schema, TTL field policy,
   indexes/rules, and callable IAM while
   `ENABLE_HOST_EVENT_BROADCAST=false` in the production Dart defines.
2. Exercise dev, staging, and then production callable reachability. Confirm a
   missing-auth request reaches the Firebase callable adapter and returns a
   callable JSON rejection rather than 404, redirect, HTML/GFE, IAM denial, or
   5xx.
3. Only after that proof, set the production flag true in a later client merge.
   The Host job in `Mobile Internal Release` runs the manifest-driven live dependency check
   before Flutter/Xcode work and refuses to archive if the callable is not
   reachable.

Dev and staging may keep the flag true for integration testing. Production
stays dark in source until the live backend proof exists; a client merge is not
a substitute for the Functions deployment.

`./tool/deploy_firebase_targets.sh` deploys the logical `functions` target by
expanding the current exports from `functions/src/index.ts` into explicit
`functions:<name>` targets. This keeps legacy live Functions, such as old
run/run-club callables, deployed until a deliberate cleanup plan removes them.
Exact `functions:<name>` requests use the same Functions-first phase. Planner
errors and empty or malformed target sets fail before any deploy begins. After
the Functions phase, the helper discovers every live callable-labeled v2
Function and synchronizes `roles/run.invoker` on its exact Cloud Run service
before continuing to indexes or rules. The deploy identity therefore needs
permission to list Cloud Functions and get/set Cloud Run IAM policies.
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

The standard deploy helper performs this sync automatically. Use the direct
command only for IAM recovery or auditing a previously deployed environment:

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

## Mobile Internal Release Ownership

Decision updated 2026-07-11: GitHub Actions is the canonical internal mobile
release owner for both Consumer and Host. `tool/app_targets.json` declares one
workflow and two platform channels:

- iOS: Consumer and Host upload independently to TestFlight.
- Android: Consumer and Host build signed AABs; Play upload targets the `qa`
  internal-testing track only when the Play readiness flag is enabled.

App-relevant `main` pushes create role matrices on separate runners under the
approval-free `prod-mobile` environment. A workflow-level non-cancelling concurrency
group prevents overlapping store edits, and both the workflow and environment
reject any ref other than `refs/heads/main`. Manual dispatch can select one role/platform,
build without uploading, or explicitly upload with a recorded reason. Public
App Store or Play production promotion is never automatic in this workflow.

The GitHub workflow resolves scheme, configuration, bundle id, and entrypoint
from the six-target manifest, then runs both platform gates before archiving:

```sh
node tool/run.mjs check \
  platform:app-targets \
  platform:mobile-build-number \
  platform:verify-ios-release-identity \
  platform:verify-app-store-build \
  platform:verify-ios-processing-receipts \
  platform:verify-android-release-identity \
  platform:probe-google-play-access
```

It also checks `tool/firebase/client_callable_dependencies.json` immediately
after resolving the target. A disabled production feature reports `disabled`
and skips the live probe. An enabled Host callable dependency must return an
expected Firebase callable JSON rejection to an unauthenticated probe; 404,
redirect, HTML/GFE, IAM denial, unexpected success, and 5xx all block archive
and TestFlight upload.

`verify_ios_release_identity.mjs` checks both the archive and exported app for
the target marker, compiled Flutter entrypoint, bundle/display identity,
version/build, embedded Firebase bundle/app/project identity, Firebase OAuth URL
scheme, and role-specific signed entitlements. Consumer requires HealthKit and
Associated Domains. Host intentionally has neither; both roles require their
Push/App Attest contract. The workflow separately validates the built prod Maps
key and writes JSON identity receipts with the IPA artifact.

Before archive, the workflow checks the proposed Apple build against the latest
200 App Store Connect builds for that app. Canonical GitHub iOS releases use an
18-digit `<UTC YYYYMMDD><8-digit GitHub run><2-digit attempt>` number, which is
above the legacy date/build namespace and monotonic under the serialized
workflow. After upload, the job waits for the exact build to reach App Store
Connect `VALID` and persists a processing receipt.

Android uses `100000 + workflow run number * 100 + attempt`; two reserved retry
digits prevent adjacent-run collisions. The verifier uses checksum-pinned
bundletool `1.18.3`, verifies JAR integrity and the checked upload-certificate
SHA-256, and reads compiled package, target/role, Firebase app/project, Maps,
debuggable, version-name, and version-code identity before any Play edit.

## TestFlight Status

Both roles have checked local/native composition, Firebase identity, distinct
store identity, App Store Connect records, and manifest-resolved GitHub
archive/upload paths. The workflow now proves both upload and App Store
processing, but not TestFlight group assignment, install, or launch. Close
`APP-TARGET-IOS-GITHUB-CUTOVER-001` only after:

The pre-cutover Consumer dispatch `29161431098` successfully signed and archived
`com.catchdates.app`, then stopped before export because Xcode's archive
`Info.plist` contains a root `CreationDate` that cannot be converted wholesale
to JSON. The verifier now extracts `ApplicationProperties` and has a regression
test for that real plist shape. The failed dispatch is diagnostic evidence, not
TestFlight upload proof.

1. Both GitHub role jobs archive, verify, export, and upload successfully.
2. Both builds finish processing in App Store Connect.
3. The Consumer and Host app-scoped workflows whose exact App Store Connect API
   name is `Default` are disabled in Xcode Cloud. GitHub/App Store status
   surfaces may prefix those workflows as `Catch | Default` and
   `Runner | Default`; those display contexts are not API workflow names.
4. Intended internal TestFlight groups are recorded and assigned.
5. Consumer and Host installs launch with App Check, Maps, phone auth, push, and
   their role-specific entrypoints.

Current host icon status: host builds use generated `AppIcon-host-dev`,
`AppIcon-host-staging`, and `AppIcon-host-prod` catalogs on iOS/macOS, plus
Android `hostDev`, `hostStaging`, and `hostProd` launcher resources. Regenerate
them with `dart run tool/branding/generate_native_brand_assets.dart` after
native brand-token or base-icon changes.

## Legacy Xcode Cloud State

The old 12 a.m. scheduled Consumer Xcode Cloud build was retired live in App
Store Connect on 2026-05-21. The later Consumer and Host app-scoped `Default`
workflows are legacy cutover surfaces. They may appear in status contexts as
`Catch | Default` and `Runner | Default`, but the App Store Connect API returns
the exact workflow name `Default` for each distinct app. They must be disabled
after GitHub upload proof so the same commit cannot produce duplicate builds.
The manual `retire_xcode_cloud` input is a separate, retire-only operation. It
requires exact processed Consumer and Host GitHub build numbers, re-verifies
both as `VALID`, downloads the matching processing receipts from the declared
`Mobile Internal Release` run, rejects non-canonical or cross-run evidence,
resolves both named Xcode Cloud workflows read-only before any
mutation, verifies each PATCH response, and rolls back workflows changed by
that operation if the second mutation fails.

Current App Store Connect file/folder rules:

- Any file from `/lib`
- Any file from `/ios`
- Any file from `/assets`
- Any file from `/contracts`
- File name `pubspec.yaml` from any folder
- File name `pubspec.lock` from any folder
- Any file from `/tool`
- Any file from `/firebase/prod`

These historical rules live in App Store Connect, not repository YAML. They are
retained only for audit traceability; do not reactivate them as routine upload
triggers.

If a backend-only change intentionally requires a compatible app binary,
dispatch `Mobile Internal Release` after the backend deploy is promoted.

GitHub Actions iOS jobs and Xcode Cloud must all write
`ios/Flutter/GoogleMapsKeys.xcconfig` through
`tool/write_ios_maps_key_xcconfig.sh <env>`. The simulator build matrix uses
`dev`; TestFlight/Xcode Cloud release builds use `prod`. Keep Maps-key
validation in that shared helper instead of duplicating secret preflight logic
in each CI surface.

## Legacy Xcode Cloud Build Scripts

The checked Xcode Cloud scripts remain as rollback and audit support while
`APP-TARGET-IOS-GITHUB-CUTOVER-001` is active. They are not the routine release
owner.

Two CI scripts drive it:

- `ios/ci_scripts/ci_post_clone.sh` reads the Flutter SDK version from
  `tool/ci/toolchain.env`, installs Flutter and Node, applies the prod Firebase
  environment for `consumer` or `host`, writes the prod iOS Google Maps key, and
  runs `pod install`. It uses `CATCH_APP_ROLE=host` or a `host-*` Xcode scheme to
  prepare the manifest-resolved `lib/main_host_prod.dart` composition.
- `ios/ci_scripts/ci_post_xcodebuild.sh` runs the release-identity verifier
  against the archive, writes `build/ios/release-evidence/<role>-xcode-cloud-archive.json`, and verifies the archived
  `GoogleMapsApiKey` before the build can reach TestFlight.

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

If a legacy Xcode Cloud build is deliberately re-enabled for recovery, it must
inject and verify the environment-specific Maps key. The GitHub candidate-floor
check will reject any later build number that is not above the resulting build.

## GitHub-Only Migration Status

The repo migration is implemented: one Actions workflow owns both roles, both
iOS uploads, both signed Android bundles, and guarded Play internal uploads.

Cutover is not externally complete until `APP-TARGET-IOS-GITHUB-CUTOVER-001`
and `APP-TARGET-ANDROID-PLAY-001` have their remote processing and tester proof.

Cutover checklist:

1. Prove Consumer and Host GitHub uploads and App Store processing.
2. Disable both legacy Xcode Cloud workflows.
3. Record TestFlight group assignment plus install/launch proof.
4. Complete Play enrollment and publisher access, then enable the Play flag.
5. Record both Play internal processing/install/launch proofs and signing
   fingerprints.

The repository can verify that the GitHub `prod` environment has the required
App Store Connect secret names and that the local/Xcode Cloud scripts fail
loudly when required release secrets are missing. It cannot prove App Store
Connect account settings, TestFlight group membership, export-compliance,
privacy, or review metadata state without direct App Store Connect access.

## Human Release Evidence

Already confirmed outside repository checks for Consumer:

- TestFlight upload, install, launch, and iOS Maps behavior through the App
  Store Connect/Xcode Cloud build process before the nightly schedule was
  retired.

These still require human confirmation outside repository checks:

- Current Consumer and Host TestFlight processing, intended-group assignment,
  install, and launch through the GitHub-owned pipeline.
- Consumer and Host Play internal-testing evidence.
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
