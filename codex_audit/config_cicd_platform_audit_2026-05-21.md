---
doc_id: config_cicd_platform_audit
version: 1.1.0
created: 2026-05-21
updated: 2026-05-21
owner: config_cicd_platform_audit
status: active
---

# Config / CI-CD / Platform Audit Tracker

Persistent tracker for fragile, error-prone, or misconfigured surfaces found
in a sweep of the repo's config, CI/CD, deploy, bootstrap, data-contract, and
platform-specific code on 2026-05-21.

The app itself analyzes clean (`flutter analyze` → "No issues found"). Nothing
here is a crash bug; these are **brittleness and drift surfaces** — the kind of
thing that produces intermittent "we keep getting errors", TestFlight warnings,
and "analytics looks empty" symptoms.

## Where this work is happening

Fixes are being applied in an **isolated git worktree**
(`.claude/worktrees/config-cicd-hardening`, branch
`worktree-config-cicd-hardening`, based on `origin/main`). Reason: a parallel
automated session is concurrently editing `lib/event_success/**` on
`codex/event-success-final-pass` in the main checkout, and it wiped an earlier
copy of this tracker + the `contracts-ci.yml` workflow. Working in a worktree
keeps the two efforts from colliding. Merge `worktree-config-cicd-hardening`
into `main` (or cherry-pick) when ready; it touches only CI/config/docs files,
which do not overlap the event_success feature work.

## How to use this tracker

- Each item has a stable ID (`C#`, `I#`, `B#`, `D#`, `A#`, `N#`, `W#`, `M#`).
- Work top-down within a severity band. Tick the checkbox when done.
- Items marked **[quick]** are <30 min and self-contained.
- Items marked **[needs console]** require Firebase / App Store Connect console
  access and cannot be fixed from the repo alone.
- Items marked **[large]** need a design decision or a multi-file change — read
  the linked context first.

## Severity legend

- **P1 — High**: actively causes the reported symptoms (TestFlight warnings,
  analytics-not-working) or removes a safety net entirely.
- **P2 — Medium**: real drift/fragility risk; will bite under a plausible change.
- **P3 — Low**: inconsistency or papercut; fix opportunistically.
- **Info**: intentional / by-design — recorded so it is not "re-discovered" as
  a bug later.

## Status summary

| ID  | Sev | Area              | One-line                                                          | Done |
|-----|-----|-------------------|-------------------------------------------------------------------|------|
| I1  | P1  | iOS/TestFlight    | No app-level `PrivacyInfo.xcprivacy` — likely TestFlight warnings  | [ ]  |
| A1  | P1  | Analytics         | Analytics only collects in release+prod; debug runs send nothing  | [x]  |
| D2  | P1  | Contracts         | Contracts SSOT has **no CI gate** — silent drift                  | [x]  |
| C1  | P3  | CI/CD             | `flutter-ci.yml` missing `cache: true`                            | [x]  |
| C2  | P2  | CI/CD             | `firebase-tools` installed unpinned in deploy/CI                  | [x]  |
| C3  | P2  | CI/CD             | `firebase-dev-deploy` uses fragile `workflow_run` + JS poll        | [ ]  |
| C5  | P3  | CI/CD             | Flutter version floats `3.41.x` (CI) vs pinned `3.41.9` (Xcode)   | [x]  |
| C6  | P3  | CI/CD             | PR build matrix only builds `dev` flavor                          | [ ]  |
| C8  | P3  | CI/CD             | BigQuery export extensions never deployed by pipeline             | [ ]  |
| I2  | P2  | iOS               | App Check activated twice (native AppDelegate + Dart)             | [ ]  |
| I3  | P3  | iOS               | No-flavor `Release.xcconfig` silently uses prod credentials       | [ ]  |
| I4  | P3  | iOS               | `FirebaseFirestore` pod pinned to prebuilt fork — desync risk     | [ ]  |
| I5  | P3  | iOS               | Podfile `SWIFT_SUPPRESS_WARNINGS=YES` hides all pod warnings      | [ ]  |
| B1  | P2  | Bootstrap         | Remote Config fetch failure swallowed silently                   | [ ]  |
| B3  | P2  | Bootstrap         | Web App Check silently disabled when unconfigured                 | [ ]  |
| D1  | P1  | Contracts         | Three parallel schema representations, mid-migration              | [ ]  |
| D3  | P2  | Contracts         | CI verifies only `firestore.ts` freshness, not contract outputs   | [x]  |
| A2  | P2  | Analytics/BQ      | GA4→BigQuery link is a console task; verify it is enabled         | [ ]  |
| A3  | P3  | Analytics         | `GoogleService-Info.plist` has `IS_ANALYTICS_ENABLED=false`       | [ ]  |
| N1  | P2  | Android           | `google-services.json` has only 1 flavor's package               | [ ]  |
| W1  | P3  | Web               | Messaging service worker registered even when push is disabled   | [ ]  |
| M1  | P3  | Misc              | Root `.env` holds placeholder Razorpay key                        | [ ]  |

---

## P1 — High

### I1 — No app-level iOS privacy manifest [needs console-ish] [large]

**Where:** `ios/Runner/` — there is no `PrivacyInfo.xcprivacy`. The only
`*.xcprivacy` files in the project are inside `ios/Pods/**` (third-party SDKs).

**Problem:** Since Apple's privacy-manifest requirement, an app that uses
"required reason" APIs (file timestamps, `UserDefaults`, system boot time, free
disk space) must declare them in an app-target `PrivacyInfo.xcprivacy`, plus
declare collected data types. A missing/incomplete manifest is the single most
common source of **TestFlight upload warnings** (`ITMS-91053` "Missing API
declaration", `ITMS-91054`, privacy-report warnings). This is the most likely
explanation for "we still have some warnings on Xcode when we deploy to
TestFlight".

**Why brittle:** the warning surfaces only at upload time, long after the build
"succeeds" locally — so it is invisible to `flutter analyze`/CI.

**Fix:**
1. Get the **exact** warning text from the most recent TestFlight upload
   (App Store Connect → the build → "General" / the email Apple sends). The
   warning names the specific API category and offending binary.
2. Add `ios/Runner/PrivacyInfo.xcprivacy` with `NSPrivacyAccessedAPITypes`
   (typical Flutter app needs: `UserDefaults` reason `CA92.1`, file timestamp
   `C617.1`, system boot time `35F9.1`, disk space `E174.1` — confirm against
   the actual warning) and `NSPrivacyCollectedDataTypes` for what Catch collects
   (precise/coarse location, photos, phone number, user ID, crash + analytics
   data).
3. Add the file to the **Runner target** in Xcode (Build Phases → Copy Bundle
   Resources). Editing `project.pbxproj` by hand is error-prone — do it in
   Xcode or with a verified script.
4. Re-archive and confirm the warning is gone.

**Effort:** ~1–2 h once the exact warning text is known. **Blocked on** the user
pasting the actual TestFlight warning so the manifest is scoped correctly rather
than guessed.

---

### A1 — Analytics never collects outside release+prod [quick to verify]

**Where:** `lib/core/app_config.dart` → `shouldCollectObservabilityFor()`;
consumed by `lib/analytics/app_analytics.dart` and `lib/exceptions/error_logger.dart`.

**Problem:** Analytics + Crashlytics collection is gated by
`AppConfig.shouldCollectObservability`, which is **true only** when:
`releaseMode && environment.isProduction`, OR a non-prod release/profile build
with `ENABLE_OBSERVABILITY_COLLECTION=true`. In an ordinary `flutter run` (debug
build), `AppAnalytics.initialize()` calls `setAnalyticsCollectionEnabled(false)`
and every `logEvent` early-returns.

**Consequence:** This is almost certainly why "Google Analytics doesn't look
initialized." In a normal dev run **no events are sent at all**, and Firebase
**DebugView shows nothing** because collection is fully disabled (DebugView
needs collection enabled). The integration is fine — it is just deliberately
off in debug.

**Why this matters / fix:** It is correct behavior, but it needs to be
*documented* and there needs to be a known way to verify GA end-to-end:
- To see events in DebugView, run a build with collection forced on:
  `ENABLE_OBSERVABILITY_COLLECTION=true ./tool/flutter_with_env.sh dev run`
  (the wrapper forwards `ENABLE_OBSERVABILITY_COLLECTION` as a dart-define).
- For iOS DebugView also pass the launch arg `-FIRDebugEnabled`.
- Then trigger events and confirm in Firebase Console → Analytics → DebugView.
- The `observability-evidence.yml` workflow is the place to record the proof.

**Action (DONE 2026-05-21):** added a "Verifying Analytics, Crashlytics, And
BigQuery" section to `docs/release_operations.md` documenting the collection
gate, the `ENABLE_OBSERVABILITY_COLLECTION=true` DebugView recipe, the
`-FIRDebugEnabled` launch arg, the `observability_smoke` canary event, and the
Firestore→BigQuery vs GA4→BigQuery distinction. The integration itself was
already correct — this removes the "analytics looks broken" false alarm.

---

### D1 / D2 — Contracts are the intended SSOT but are not enforced

**Where:** `contracts/` (~72 schema files), `docs/schema_contract_unification_tracker.md`
(v0.8.6, status active), `tool/check_data_contract.sh`, `tool/generate_schema_contracts.mjs`.

**D1 (open, P1, [large]) — three parallel schema representations.** The same
document shapes are declared in: (1) `contracts/*.json` JSON-Schema files — the
*intended* single source of truth, but `contracts/README.md` is `status: draft`;
(2) hand-written Dart Freezed/json_serializable models in `lib/**/domain/`;
(3) the generated `functions/src/shared/firestore.ts`, which is generated **from
the Dart models** (`tool/generate_firestore_types.dart`), not from `contracts/`.
The contracts README explicitly calls `firestore.ts` "transitional … should not
be treated as the canonical schema source." So today the Dart models are still
a source, and `contracts/` is a parallel third copy mid-migration. This is real
drift surface, not a bug — but it means a schema change still needs the full
multi-file pass (PROJECT_CONTEXT §14.1). Finishing or freezing the migration in
`docs/schema_contract_unification_tracker.md` is a decision for the user; out of
scope for a quick fix.

**D2 (DONE 2026-05-21) — contracts layer now has a CI gate.** Previously
`tool/check_data_contract.sh` (the full contract gate) ran in **no** GitHub
workflow; only the older `tool/check_firestore_contract.mjs` was gated, so a
contract edited without regeneration, or a Dart model changed without a matching
contract update, passed CI green.

Fix applied — new workflow `.github/workflows/contracts-ci.yml` (PR + push to
main) runs the fast, Node-only contract checks:
`validate_schema_contracts.mjs`, `generate_schema_contracts.mjs --check`
(+ `node --check` on the generated validators), `check_schema_type_boundaries.mjs`,
`check_schema_path_literals.mjs`, `check_firestore_rules_semantics.mjs`. It does
`npm --prefix functions ci` first because `generate_schema_contracts.mjs`
resolves `ajv`/`ajv-formats` from `functions/node_modules` via `createRequire`.
The emulator-heavy parts (functions tests, rules tests) stay in the existing
`functions-ci` / `firestore-rules-ci`. `firebase-dev-deploy.yml`'s required-check
poll list was updated to include `contracts-ci.yml`.

Verification: all five checks pass on a clean `origin/main` worktree; running
the generator in **write** mode produced an empty `git diff`, confirming the
generator is deterministic and `origin/main`'s generated outputs are current.
(Note: during rapid back-to-back diagnostic runs immediately after `npm ci`,
`generate --check` was observed to flap PASS/FAIL a few times; write-mode's
empty diff proves this was environmental noise, not generator non-determinism.
If `contracts-ci` ever flakes on this step in real CI, revisit here first.)

---

## P2 — Medium

### C2 — `firebase-tools` installed unpinned (DONE 2026-05-21)

**Where:** `firebase-deploy.yml`, `firebase-dev-deploy.yml`,
`firestore-rules-ci.yml`, `release-readiness.yml` all ran
`npm install -g firebase-tools` with no version.

**Was:** every CI run picked up whatever `firebase-tools` was latest that day. A
breaking release (or a change in default deploy behavior, rules compiler,
emulator) silently flowed into deploys and the rules emulator — a classic "it
worked yesterday" cause.

**Fix applied:** pinned all four workflows to `firebase-tools@15.1.0` (the
version installed on the dev machine, treated as known-good). Bump deliberately
in future, in all four files together.

### C3 — `firebase-dev-deploy` trigger + poll is fragile [large]

**Where:** `.github/workflows/firebase-dev-deploy.yml`.

**Problem:** the dev deploy fires on `workflow_run` completion of "App Build
Matrix", then runs an in-job `github-script` loop polling the GitHub API for up
to 20 min for the required workflows to be green for the same SHA. Failure
modes:
- `workflow_run` only ever runs the workflow file **as it exists on the default
  branch** — local edits to this file do nothing until merged.
- The poll re-implements branch protection in JavaScript. If any polled
  workflow *filename* is renamed, the poll treats it as permanently "missing"
  and just times out after 20 min.
- The polled-workflow list is hand-maintained (it now includes `contracts-ci.yml`).

**Fix options (pick one):**
- Preferred: drop the JS poll, make `dev` a GitHub **Deployment Environment**
  with required-status-check protection, and deploy on push to `main` directly.
- Or: at minimum, make "missing workflow" fail fast instead of timing out.

### B1 — Remote Config fetch failure swallowed silently [quick]

**Where:** `lib/main.dart` `_initializeRemoteConfig()` — `catch (_) {}`.

**Problem:** `fetchAndActivate()` failure is silently ignored. The force-update
gate then runs on `setDefaults` values, which is the intended graceful
degradation — but the empty catch *also* hides genuine misconfiguration (wrong
RC template, App Check blocking RC, project mismatch). The same silent-catch
pattern is in `lib/app.dart` `_refreshForceUpdateGate` (`debugPrint` only).

**Fix:** keep serving defaults, but log the failure through `ErrorLogger`
(non-fatal) so a real RC outage/misconfig is visible in Crashlytics instead of
invisible. Small change once `ErrorLogger` is reachable at that point in
startup (it is constructed right after).

### B3 — Web App Check silently disabled when unconfigured [quick]

**Where:** `lib/main.dart` `_activateFirebaseAppCheck()`, web branch.

**Problem:** on web, if there is no debug token and no
`FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY`, the code only
`debugPrint`s a warning and returns — App Check is **not activated at all**. For
a production web deploy this means Firestore/Auth/Functions are unprotected by
App Check, with no signal louder than a debug print (which is stripped in
release).

**Fix:** in a prod web build (`environment.isProduction && !kDebugMode`), hard-fail
or surface a visible error if the reCAPTCHA site key is missing, rather than
booting into an unprotected state.

### I2 — App Check activated twice [large]

**Where:** `ios/Runner/AppDelegate.swift` calls
`AppCheck.setAppCheckProviderFactory(...)` (debug factory under `#if DEBUG`,
else `AppAttestProviderFactory`). `lib/main.dart` *also* calls
`FirebaseAppCheck.instance.activate(providerApple: ...)`.

**Problem:** two mechanisms configure the same thing, and they can disagree.
The native side keys off the compile-time `#if DEBUG`; the Dart side keys off
`AppConfig.useFirebaseAppCheckDebugProvider || useFirebaseEmulators`. A build
that is *not* `DEBUG` but sets `USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER=true`
(exactly the `.env.local` case documented for this repo) gets the native
AppAttest factory *and* the Dart debug provider. Behavior is then ambiguous.

**Fix:** pick one source of truth. The FlutterFire-recommended path is to drive
App Check entirely from Dart (`FirebaseAppCheck.instance.activate`) and remove
the native `setAppCheckProviderFactory` block, OR keep native-only and remove
the Dart `activate`. Whichever is chosen, document why in `AppDelegate.swift`.

### D3 — CI verified only `firestore.ts` freshness (DONE 2026-05-21)

**Where:** `flutter-ci.yml` "Verify Firestore types are in sync" runs
`dart tool/generate_firestore_types.dart` + `git diff --exit-code` on
`functions/src/shared/firestore.ts` only.

**Was:** the **contracts→generated** outputs
(`functions/src/shared/generated/*.ts`, `tool/generated/*`,
`lib/core/schema_contracts/generated/*`) were *not* freshness-checked by any
workflow, so they could be stale on a green build. **Now** covered by the
`generate_schema_contracts.mjs --check` step in the new `contracts-ci.yml`
(see D2).

### A2 — GA4 → BigQuery export link [needs console]

**Where:** `firebase.json` `extensions` block + `.firebaserc` etags.

**Findings (this is two different things — do not conflate them):**
- **Firestore → BigQuery: configured.** Six `firestore-bigquery-export@0.3.2`
  extension instances (`bq-event-success-feedback`, `bq-event-success-scorecards`,
  `bq-participant-*`) are declared and, per `.firebaserc` etags, installed in
  all three projects. This streams Firestore collections into BigQuery.
- **GA4 → BigQuery export: not verifiable from the repo.** That is a Firebase
  Console link (Project Settings → Integrations → BigQuery → enable the Google
  Analytics export). It cannot live in repo config. The `observability-evidence.yml`
  workflow input "ga4_bigquery_evidence" exists precisely because the team knows
  this is an open manual step.

**Action [needs console] — still open:** in the Firebase Console for
`catch-dating-app-64e51` (prod), confirm BigQuery linking is on and **"Export
Google Analytics data"** is checked. Note: GA4→BQ only backfills from the day it
is enabled — enable it sooner rather than later. Then GA4 events appear in the
`analytics_<propertyId>` dataset. The repo-side documentation of this step was
added to `docs/release_operations.md` on 2026-05-21; the console toggle itself
cannot be done from the repo and is the user's to verify.

### N1 — `google-services.json` carries only one flavor [large]

**Where:** `android/app/google-services.json` (tracked) — contains only
`project_id: catchdates-dev` and package `com.catchdates.app.dev`.

**Problem:** the app declares three Android product flavors with distinct
applicationIds (`com.catchdates.app.dev` / `.staging` / `com.catchdates.app`).
The `com.google.gms.google-services` Gradle plugin **fails the build** if the
flavor being built has no matching client in `google-services.json`. The repo
works around this by having `tool/use_firebase_environment.sh` swap the whole
file per environment (the "working copy" pattern, PROJECT_CONTEXT §14.8).

**Why brittle:** building a flavor without going through
`./tool/flutter_with_env.sh` (e.g. a raw `flutter build appbundle`, an IDE run
config, or a CI step that forgets the wrapper) builds against the wrong
project's json and fails — or worse, ships pointing at the wrong project.
Standard Android practice is **one** `google-services.json` containing all three
clients so any flavor builds correctly.

**Fix (decision needed):** either (a) merge all three projects' iOS/Android
clients into single `google-services.json` / `GoogleService-Info.plist` files
keyed by package — the plugin picks the right client per flavor automatically —
or (b) keep the swap pattern but add a build-time guard that asserts the json's
package matches the flavor being built.

---

## P3 — Low / papercuts

### C1 — `flutter-ci.yml` missing `cache: true` — FIXED 2026-05-21

`subosito/flutter-action` in `flutter-ci.yml` lacked `cache: true` while the
three other Flutter workflows have it. Added `cache: true`. Pure CI-speed /
consistency change.

### C5 — Flutter version drift between CI and Xcode Cloud (DONE 2026-05-21)

GitHub workflows pinned `flutter-version: '3.41.x'` (floating patch) while Xcode
Cloud's `ios/ci_scripts/ci_post_clone.sh` pins `FLUTTER_VERSION` default
`3.41.9` — so CI and the actual release build could compile on different Flutter
patches. **Fix applied:** pinned `flutter-version` to `3.41.9` in all six
occurrences across `flutter-ci.yml`, `app-build-matrix.yml` (×3),
`release-readiness.yml`, and `ios-testflight-release.yml`, matching Xcode Cloud.
Bump both places together in future.

### C6 — PR build matrix only builds the `dev` flavor [quick-ish]

`app-build-matrix.yml` builds web/android/iOS only for `dev`. The prod/staging
compile paths differ (different `xcconfig` includes, different dart-define
files, different `GoogleService-Info.plist`). A prod-only build break is not
caught until `release-readiness.yml` or Xcode Cloud. Consider adding a prod
config-only iOS build (`flutter build ios --release --config-only --flavor prod`)
to the matrix, or at least a prod web build.

### C8 — BigQuery export extensions never deployed by the pipeline [quick doc]

`tool/deploy_firebase_targets.sh` handles `functions/firestore/storage/hosting/
remoteconfig`. The six `extensions` in `firebase.json` are not in the default
deploy target list, so extension parameter changes never ship via CI (they were
installed manually). `firebase deploy --only extensions` *can* be run on demand
(the script routes unknown targets through). Action: document that extension
changes need a manual `--only extensions` deploy, or add `extensions` to a
deliberate deploy path.

### I3 — No-flavor `Release.xcconfig` uses prod credentials [quick]

`ios/Flutter/Release.xcconfig` (and `Debug.xcconfig`/`Profile.xcconfig`, the
schemes without a `-dev/-staging/-prod` suffix) hardcode the prod Firebase URL
scheme and `GOOGLE_MAPS_IOS_API_KEY_PROD`. Any build using the plain `Release`
configuration silently gets prod credentials. The canonical schemes are the
suffixed ones — consider deleting the unused no-flavor configs, or make them
fail loudly, so a stray plain-`Release` build can't ship prod keys by accident.

### I4 — `FirebaseFirestore` pod pinned to prebuilt fork [quick doc]

`ios/Podfile`: `pod 'FirebaseFirestore', :git => 'invertase/firestore-ios-sdk-frameworks',
:tag => '12.12.0'`. This prebuilt-frameworks fork speeds up builds but its tag
must stay in lockstep with the Firebase iOS SDK version that the `cloud_firestore`
Flutter plugin expects. A `flutter pub upgrade` of `cloud_firestore` can bump
the expected SDK and silently desync, causing pod resolution or link errors.
Action: add a comment in the Podfile pinning the rule "bump this tag whenever
`cloud_firestore` is upgraded; match the version in the plugin's own podspec."

### I5 — Podfile suppresses all warnings for three pods [quick]

`ios/Podfile` `post_install` sets `SWIFT_SUPPRESS_WARNINGS = YES` for
`firebase_storage`, `firebase_analytics`, `cloud_functions` to hide one known
upstream retroactive-conformance warning. This hides **every** future warning in
those pods too. Revisit when FlutterFire fixes the upstream issue, and remove
the suppression then.

### A3 — `GoogleService-Info.plist` `IS_ANALYTICS_ENABLED=false` [quick verify]

The checked-in (dev) `ios/Runner/GoogleService-Info.plist` has
`IS_ANALYTICS_ENABLED=false`. This legacy plist flag is largely superseded by
the runtime `setAnalyticsCollectionEnabled()` call and Info.plist analytics
keys, so it probably is not the cause of anything — but it is inconsistent and
confusing. Confirm the prod project's `GoogleService-Info.plist` is consistent,
and rely on the runtime switch as the single control.

### W1 — Messaging service worker always registered on web [quick]

`web/index.html` registers `firebase-messaging-sw.js` on every web origin, but
web push is disabled unless `FIREBASE_WEB_VAPID_KEY` is set (empty by default,
so `AppConfig.supportsPushMessagingOnCurrentPlatform` is false on web). The SW
registration just fails/no-ops. Harmless, but dead weight — gate it on the VAPID
key being present, or leave a comment explaining it is intentionally inert.

### M1 — Root `.env` holds a placeholder Razorpay key [quick]

Root `.env` contains `RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID_HERE`. `.env` is
gitignored and is read by `envied` at **codegen time**; the committed
`lib/payments/env/*.g.dart` holds whatever key was present the last time
`build_runner` ran. If anyone re-runs codegen now, the placeholder gets baked in
and Razorpay order creation breaks. Action: make sure the local `.env` has the
real Razorpay **test** key id before running `build_runner`, and consider a
codegen-time guard that rejects the `YOUR_KEY_ID_HERE` placeholder.

---

## Info — intentional / by-design (do not "fix")

- **I7 — Firebase auto-collection disabled in Info.plist.** `ios/Runner/Info.plist`
  sets `FirebaseCrashlyticsCollectionEnabled=false` and
  `FirebaseMessagingAutoInitEnabled=false`. This is correct — both are enabled at
  runtime by `ErrorLogger`/the FCM service once consent/observability gates pass.
- **B4 — Provider override pattern.** `AppAnalytics`/`ErrorLogger` are built in
  `main()` and injected via `ProviderScope` overrides; the `@riverpod` providers
  are no-op defaults. Correct.
- **W2 — `FIREBASE_APPCHECK_DEBUG_TOKEN` in `web/index.html`.** It is set only
  behind a `localhost`/`127.0.0.1`/`::1` hostname check. Safe.
- **Working-copy native config.** Root `google-services.json`,
  `GoogleService-Info.plist`, and `ios/Flutter/*.xcconfig` are env-swapped by
  `tool/use_firebase_environment.sh` (PROJECT_CONTEXT §14.8). N1/I3 above note
  the fragility of this pattern, but the pattern itself is deliberate.
- **`firebase.json` `flutter.platforms` block points at prod.** The app picks
  Firebase options at runtime from `lib/firebase_options_<env>.dart` via
  `DefaultFirebaseOptions`, so the `flutter.platforms` block in `firebase.json`
  is essentially vestigial (only used if someone re-runs `flutterfire configure`).
  Not load-bearing today.
- **`firestore-debug.log` and `ios/build/`** are git-ignored — no action.

---

## Suggested order of work

1. **A1 + A2** — fastest path to "analytics works": document the verify recipe
   and confirm the GA4→BigQuery console link. No code risk.
2. **I1** — get the real TestFlight warning text, then add the privacy manifest.
   This is the user's stated pain point.
3. **D2** — DONE. Contracts SSOT now has a CI gate.
4. **C2** — pin `firebase-tools`. One-line-per-file, removes a whole class of
   "deploy broke on its own" incidents.
5. Then the remaining P2s (C3, B1, B3, I2, N1), then P3 papercuts.

## Work log

- **2026-05-21** — Audit completed; tracker created. `flutter analyze` clean.
- **2026-05-21** — C1 fixed (`flutter-ci.yml` `cache: true`).
- **2026-05-21** — Parallel session in the main checkout wiped the first copy
  of this tracker + `contracts-ci.yml`. Re-doing fixes in an isolated worktree
  (`worktree-config-cicd-hardening`, based on `origin/main`).
- **2026-05-21** — D2 + D3 fixed: added `.github/workflows/contracts-ci.yml`;
  added `contracts-ci.yml` to the `firebase-dev-deploy.yml` required-check poll.
  Verified all five contract checks pass on clean `origin/main`; generator
  confirmed deterministic (write-mode → empty diff). Committed as `7833fb18`.
- **2026-05-21** — A1 fixed: added the "Verifying Analytics, Crashlytics, And
  BigQuery" section to `docs/release_operations.md`. A2 documented there too
  (the console toggle remains the user's to verify).
- **2026-05-21** — C2 fixed: pinned `firebase-tools@15.1.0` in all four
  deploy/CI workflows. C5 fixed: pinned `flutter-version: 3.41.9` everywhere.
- **2026-05-21** — `docs/release_operations.md` "Required PR Checks" updated to
  list `contracts-ci.yml`.

## Verification done during this audit

- `flutter analyze --no-fatal-infos` → "No issues found" (clean).
- All five contract checks (`validate_schema_contracts`, `generate_schema_contracts
  --check`, `check_schema_type_boundaries`, `check_schema_path_literals`,
  `check_firestore_rules_semantics`) pass on a clean `origin/main` worktree.
- Read: all 11 `.github/workflows/*`, `firebase.json`, `.firebaserc`,
  `ios/` (Info.plist, entitlements, xcconfig set, Podfile, AppDelegate,
  ExportOptions, ci_scripts), `android/app/build.gradle`, `web/index.html`,
  `lib/main.dart`, `lib/app.dart`, `lib/core/app_config.dart`,
  `lib/analytics/app_analytics.dart`, `lib/exceptions/error_logger.dart`,
  `contracts/` tree + `contracts/README.md`, `tool/check_data_contract.sh`,
  `tool/flutter_with_env.sh`, `tool/deploy_firebase_targets.sh`,
  `tool/write_ios_maps_key_xcconfig.sh`.
- Not deeply reviewed (out of scope / lower risk): `macos/` (macOS push is
  deferred per memory), the runtime feature code under `lib/<feature>/`, the
  Cloud Functions implementation under `functions/src/`.
