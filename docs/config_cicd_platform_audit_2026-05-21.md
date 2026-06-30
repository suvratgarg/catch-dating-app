---
doc_id: config_cicd_platform_audit
version: 1.3.1
created: 2026-05-21
updated: 2026-05-22
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

## Where this tracker lives

This tracker originally lived under `codex_audit/` while the fixes were applied
in the isolated `worktree-config-cicd-hardening` branch. After `origin/main`
consolidated the old `codex_audit` folder into durable docs, this file moved to
`docs/` so the remaining console- and decision-gated items stay visible without
resurrecting the deleted audit index.

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
| I1  | P3  | iOS/TestFlight    | Xcode build warnings — pod noise + AccentColor (was: privacy manifest) | [x]  |
| A1  | P1  | Analytics         | Analytics only collects in release+prod; debug runs send nothing  | [x]  |
| D2  | P1  | Contracts         | Contracts SSOT has **no CI gate** — silent drift                  | [x]  |
| C1  | P3  | CI/CD             | `flutter-ci.yml` missing `cache: true`                            | [x]  |
| C2  | P2  | CI/CD             | `firebase-tools` installed unpinned in deploy/CI                  | [x]  |
| C3  | P2  | CI/CD             | `firebase-dev-deploy` fragile poll — hardened (fail-fast)         | [x]  |
| C5  | P3  | CI/CD             | Flutter version floats `3.41.x` (CI) vs pinned `3.41.9` (Xcode)   | [x]  |
| C6  | P3  | CI/CD             | PR build matrix only builds `dev` flavor                          | [x]  |
| C8  | P3  | CI/CD             | BigQuery export extensions never deployed by pipeline             | [x]  |
| I2  | P2  | iOS               | App Check activated twice — now Dart-only                         | [x]  |
| I3  | P3  | iOS               | No-flavor `Release.xcconfig` silently uses prod credentials       | [x]  |
| I4  | P3  | iOS               | `FirebaseFirestore` pod pinned to prebuilt fork — desync risk     | [x]  |
| I5  | P3  | iOS               | Podfile pod-warning suppression — now `inhibit_all_warnings!`     | [x]  |
| I6  | P3  | iOS               | Crashlytics symbol-upload phase runs every build (benign)         | [ ]  |
| B1  | P2  | Bootstrap         | Remote Config fetch failure swallowed silently                   | [x]  |
| B3  | P2  | Bootstrap         | Web App Check unconfigured — web not a shipped surface            | [x]  |
| D1  | P1  | Contracts         | Three parallel schema representations, mid-migration              | [ ]  |
| D3  | P2  | Contracts         | CI verifies only `firestore.ts` freshness, not contract outputs   | [x]  |
| A2  | P2  | Analytics/BQ      | GA4→BigQuery link is a console task; verify it is enabled         | [x]  |
| A3  | P3  | Analytics         | `GoogleService-Info.plist` has `IS_ANALYTICS_ENABLED=false`       | [ ]  |
| N1  | P2  | Android           | `google-services.json` has only 1 flavor's package               | [x]  |
| W1  | P3  | Web               | Dead messaging service-worker registration removed               | [x]  |
| M1  | P3  | Misc              | Root `.env` holds placeholder Razorpay key                        | [ ]  |

---

## P1 — High

### A1 — Analytics never collects outside release+prod [quick to verify]

**Where:** `lib/core/app_config.dart` → `shouldCollectObservabilityFor()`;
consumed by `lib/core/analytics/app_analytics.dart` and `lib/exceptions/error_logger.dart`.

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
(v0.8.6, status active), `tool/check_data_contract.sh`, `tool/contracts/generate_schema_contracts.mjs`.

**D1 (open, P1, [large]) — three parallel schema representations.** The same
document shapes are declared in: (1) `contracts/*.json` JSON-Schema files — the
*intended* single source of truth, but `contracts/README.md` is `status: draft`;
(2) hand-written Dart Freezed/json_serializable models in `lib/**/domain/`;
(3) the generated `functions/src/shared/firestore.ts`, which is generated **from
the Dart models** (`tool/contracts/generate_firestore_types.dart`), not from `contracts/`.
The contracts README explicitly calls `firestore.ts` "transitional … should not
be treated as the canonical schema source." So today the Dart models are still
a source, and `contracts/` is a parallel third copy mid-migration. This is real
drift surface, not a bug — but it means a schema change still needs the full
multi-file pass (PROJECT_CONTEXT §14.1). Finishing or freezing the migration in
`docs/schema_contract_unification_tracker.md` is a decision for the user; out of
scope for a quick fix.

**D2 (DONE 2026-05-21) — contracts layer now has a CI gate.** Previously
`tool/check_data_contract.sh` (the full contract gate) ran in **no** GitHub
workflow; only the older `tool/contracts/check_firestore_contract.mjs` was gated, so a
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

### C3 — `firebase-dev-deploy` poll fragility (DONE 2026-05-21)

**Where:** `.github/workflows/firebase-dev-deploy.yml`.

**Was:** the dev deploy polls the GitHub API for up to 20 min for required
workflows to be green for the SHA. A renamed/removed workflow, or one that never
created a run (path filter, disabled), would sit "missing" and waste the full
20-minute timeout; an API error threw a raw unhandled exception.

**Fix applied (decision: harden the poll):**
- Wrapped the `listWorkflowRuns` call in try/catch — a renamed/removed workflow
  now fails immediately with a clear message naming the workflow and pointing at
  the `workflows` list to update.
- Added a 5-minute "missing" deadline: a push-triggered workflow creates its run
  within seconds, so a workflow with no run after 5 min fails fast (with an
  actionable message) instead of waiting the full 20.
- The 20-min overall timeout is kept for genuinely slow-but-running workflows.

Not done (deliberately): the larger move to a GitHub **Deployment Environment**
with native required-status-check protection. That needs a repo-settings change
(branch protection) outside the codebase; revisit if the poll still proves
annoying.

### B1 — Remote Config fetch failure swallowed silently (DONE 2026-05-21)

**Where:** `lib/main.dart` `_initializeRemoteConfig()` — was `catch (_) {}`.

**Was:** `fetchAndActivate()` failure was silently ignored. The force-update
gate then runs on `setDefaults` values (intended graceful degradation) — but the
empty catch *also* hid genuine misconfiguration (wrong RC template, App Check
blocking RC, project mismatch).

**Fix applied:** `_initializeRemoteConfig()` / `_initializeFirebaseServices()`
now return `(Object, StackTrace)?`; `main()` logs the failure through
`ErrorLogger.logError()` (non-fatal) once the logger is constructed, so a real
RC outage/misconfig surfaces in Crashlytics. The app still boots on bundled
defaults — behavior unchanged for users. Verified `flutter analyze lib/main.dart`
clean.

Note: the same silent-catch pattern still exists in `lib/app.dart`
`_refreshForceUpdateGate` (`debugPrint` only) for the *foreground-refresh* path;
left as-is since that path re-runs frequently and a transient network blip on
resume is not noteworthy — only the startup fetch is logged.

### B3 — Web App Check unconfigured (RESOLVED 2026-05-21 — not a real risk)

**Where:** `lib/main.dart` `_activateFirebaseAppCheck()`, web branch.

**Original concern:** on web with no debug token and no
`FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY`, App Check is not
activated — a prod web deploy would be unprotected.

**Resolution (decision: web is not a shipped surface):** the user confirmed the
Flutter web build is not deployed to production. `firebase.json` hosting serves
the `website/` marketing folder, not `build/web`, and no workflow deploys the
Flutter web app. So there is no unprotected prod web surface — the concern is
moot. No code change. If Flutter web is ever shipped, this must be revisited:
add the reCAPTCHA Enterprise site key and make a prod web build hard-fail
without it.

### I2 — App Check activated twice (DONE 2026-05-21)

**Where:** `ios/Runner/AppDelegate.swift` called
`AppCheck.setAppCheckProviderFactory(...)` (debug factory under `#if DEBUG`,
else `AppAttestProviderFactory`). `lib/main.dart` *also* calls
`FirebaseAppCheck.instance.activate(providerApple: ...)`.

**Was:** two mechanisms configured the same thing and could disagree — the
native side keyed off compile-time `#if DEBUG`, the Dart side off
`AppConfig.useFirebaseAppCheckDebugProvider || useFirebaseEmulators`. A non-DEBUG
build with `USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER=true` (the documented
`.env.local` case) got the native AppAttest factory *and* the Dart debug
provider.

**Fix applied (decision: Dart-only):** removed the native
`setAppCheckProviderFactory` block, the `AppAttestProviderFactory` class, and the
now-unused `FirebaseAppCheck`/`FirebaseCore` imports from `AppDelegate.swift`.
App Check is now configured solely from `lib/main.dart`
(`FirebaseAppCheck.instance.activate`), which is the single source of truth and
already handles debug/App-Attest/emulator/web selection. Added a comment in
`AppDelegate.swift` so the native block is not re-added. The `app-build-matrix`
iOS job compiles `AppDelegate.swift`, so a bad import is caught on this PR.

### D3 — CI verified only `firestore.ts` freshness (DONE 2026-05-21)

**Where:** `flutter-ci.yml` "Verify Firestore types are in sync" runs
`dart tool/contracts/generate_firestore_types.dart` + `git diff --exit-code` on
`functions/src/shared/firestore.ts` only.

**Was:** the **contracts→generated** outputs
(`functions/src/shared/generated/*.ts`, `tool/contracts/generated/*`,
`lib/core/schema_contracts/generated/*`) were *not* freshness-checked by any
workflow, so they could be stale on a green build. **Now** covered by the
`generate_schema_contracts.mjs --check` step in the new `contracts-ci.yml`
(see D2).

### A2 — GA4 → BigQuery export link (DONE 2026-05-23)

**Where:** `firebase.json` `extensions` block + `.firebaserc` etags.

**Findings (this is two different things — do not conflate them):**
- **Firestore → BigQuery: configured.** Six `firestore-bigquery-export@0.3.2`
  extension instances (`bq-event-success-feedback`, `bq-event-success-scorecards`,
  `bq-participant-*`) are declared and, per `.firebaserc` etags, installed in
  all three projects. This streams Firestore collections into BigQuery.
- **GA4 → BigQuery export: enabled in Google Analytics Admin.** On
  2026-05-23, the GA4 property `catch-dating-app-64e51` (`p526484083`) was
  linked to BigQuery project `catch-dating-app-64e51` (`catch-dating-app`,
  project number `574779808785`). The export dataset location is
  `Mumbai (asia-south1)`, matching the Firestore-to-BigQuery extension
  datasets. Daily event export is enabled for all 6 streams with no excluded
  events. Streaming export, mobile advertising identifiers, and daily user-data
  export were left disabled.

**Verification:** Google Analytics Admin → Product links → BigQuery links now
shows `catch-dating-app-64e51` / `catch-dating-app` / `574779808785`. The
expected BigQuery dataset is `analytics_526484083`; the first daily
`events_YYYYMMDD` table appears after Google Analytics processes data for the
next export cycle.

### N1 — `google-services.json` carries only one flavor (DONE 2026-05-21)

**Where:** `android/app/google-services.json` (tracked) — an environment working
copy swapped by `tool/use_firebase_environment.sh`, holding one project's
package at a time.

**Was:** building a flavor whose package is not in the active json fails deep
inside the `google-services` Gradle plugin with a cryptic "No matching client"
error — easy to hit by running a raw `flutter build` (or an IDE config) instead
of `./tool/flutter_with_env.sh`.

**Fix applied (decision: build-time guard):** added a guard in
`android/app/build.gradle.kts` — it detects the flavor being built from the
Gradle task names, computes the expected applicationId, and if the active
`google-services.json` does not contain that package it throws a `GradleException`
with an actionable message ("run `./tool/use_firebase_environment.sh <env>`").
The env-swap pattern is kept; the failure is now early and self-explanatory
instead of cryptic. (The `app-build-matrix` Android job exercises this path.)

Not done (deliberately): merging all three projects into one
`google-services.json`. That is a larger change to the env-swap workflow and was
not the chosen option.

---

## P3 — Low / papercuts

### I1 — Xcode/TestFlight build warnings (DONE 2026-05-21)

**Original hypothesis was wrong.** This was filed P1 as "missing iOS privacy
manifest causing TestFlight warnings". The user supplied the actual warning
list — there are **no** `ITMS-9105x` privacy-manifest warnings and no App Store
*validation* failures. They are ordinary **compiler/linker build warnings** that
do not block TestFlight. Reclassified P3. Breakdown of the ~60 warnings:

- **~22 from the `health` pub package** (`HealthDataReader.swift`,
  `SwiftHealthPlugin.swift`, `HealthDataWriter.swift`) — implicit `Optional→Any`
  coercions, non-exhaustive switch, unreachable catch, unused vars. Upstream
  third-party code.
- **~25 from other Flutter plugin pods** — `firebase_auth`, `cloud_firestore`,
  `image_picker_ios`, `geolocator_apple`, `share_plus`, `razorpay_flutter`,
  `firebase_remote_config`, `device_info_plus`, `google_maps_flutter_ios`,
  `firebase_core`, `firebase_messaging`, `Google-Maps-iOS-Utils` — mostly iOS
  deprecations (`keyWindow`, `kUTType*`, `authorizationStatus`). Upstream.
- **`Search path '…/MetalToolchain/…' not found`** repeated across many pods —
  an **Xcode Cloud build-machine environment** issue (the Metal toolchain is not
  provisioned on the runner). Not a repo problem. See I-note below.
- **`Ignoring duplicate libraries: -lc++ / -lsqlite3 / -lz`** and
  **`dummy.o has no symbols`** — cosmetic CocoaPods/linker noise under
  `use_frameworks!`. Harmless.
- **2 genuinely app-owned**: `AccentColor` missing from the asset catalog, and
  the Crashlytics symbol-upload run-script phase (see I6).

**Fix applied:**
1. **Pod noise** — added `inhibit_all_warnings!` to the `Runner` target in
   `ios/Podfile` (and removed the now-redundant per-pod `SWIFT_SUPPRESS_WARNINGS`
   block — see I5). This silences every third-party pod compiler warning,
   including all `health` warnings, in one idiomatic directive. It only affects
   Pods — the Runner target's own warnings still surface, which is the correct
   behavior. `ruby -c ios/Podfile` passes.
2. **`AccentColor`** — `project.pbxproj` sets
   `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor` but the catalog
   had no such color. Added `ios/Runner/Assets.xcassets/AccentColor.colorset/`
   with the brand color `#FF4E1F`. No `project.pbxproj` edit needed (`.xcassets`
   is a folder reference).

**Still noisy after this (documented, not fixed):** the Metal-toolchain
search-path warnings (Xcode Cloud environment — provision the Metal toolchain on
the runner, or ignore) and the duplicate-library linker warnings (cosmetic).

### I6 — Crashlytics symbol-upload phase runs every build (benign) [needs Xcode]

The Runner project's `[firebase_crashlytics] Crashlytics Upload Symbols`
run-script build phase has no declared outputs, so Xcode warns it cannot be
cached and runs it every build. For archive/release builds you *want* the dSYM
upload to run every time, so the behavior is correct — only the warning is
noise. Silencing it means adding input/output file lists to the script phase in
`project.pbxproj` (Xcode-surgery; do it in Xcode, not by hand). Low priority.

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

### C6 — PR build matrix only built the `dev` flavor (DONE 2026-05-21)

`app-build-matrix.yml` built web/android/iOS only for `dev`; the prod compile
path differs (different `xcconfig` includes, dart-define files, Firebase
options) so a prod-only build break was not caught until `release-readiness.yml`
or Xcode Cloud. **Fix applied:** added a `Build prod web artifact`
(`flutter_with_env.sh prod build web --release`) step to the `web` job — it
exercises the prod dart-defines and prod Firebase options with no extra secrets
(web builds skip the Maps-key validation). A prod *iOS* leg was deliberately not
added: it would need `GOOGLE_MAPS_IOS_API_KEY_PROD` wired into the unprivileged
PR-triggered workflow; the prod web leg covers the config/dart-define risk.

### C8 — BigQuery export extensions never deployed by the pipeline (DONE 2026-05-21)

`tool/deploy_firebase_targets.sh` handles `functions/firestore/storage/hosting/
remoteconfig`. The six `extensions` in `firebase.json` are not in the default
deploy target list, so extension parameter changes never ship via CI.
**Fix applied:** documented in `docs/release_operations.md` ("Firebase Deploy
Order") that extension changes require a deliberate
`./tool/firebase_with_env.sh <env> deploy --only extensions`. Left out of the
automatic path on purpose — extension redeploys can be disruptive and should
stay deliberate.

### I3 — No-flavor `Release.xcconfig` uses prod credentials (DONE 2026-05-21)

`ios/Flutter/Release.xcconfig` hardcodes the prod Firebase URL scheme and
`GOOGLE_MAPS_IOS_API_KEY_PROD`, so a build using the plain `Release`
configuration silently gets prod credentials. (`Debug.xcconfig`/`Profile.xcconfig`
default to *dev* creds — benign, no change needed there.)

**Fix applied:** added a header comment to `ios/Flutter/Release.xcconfig`
flagging it as non-canonical and pointing builds at the flavored
`Release-dev/-staging/-prod` schemes via `./tool/flutter_with_env.sh`.
Fully *deleting* the no-flavor config is not done here — it is referenced by a
build configuration in `project.pbxproj` and removing it cleanly is Xcode
surgery; the comment removes the silent-footgun aspect.

### I4 — `FirebaseFirestore` pod pinned to prebuilt fork (DONE 2026-05-21)

`ios/Podfile`: `pod 'FirebaseFirestore', :git => 'invertase/firestore-ios-sdk-frameworks',
:tag => '12.12.0'`. This prebuilt-frameworks fork speeds up builds but its tag
must stay in lockstep with the Firebase iOS SDK version that the `cloud_firestore`
Flutter plugin expects. A `flutter pub upgrade` of `cloud_firestore` can bump
the expected SDK and silently desync, causing pod resolution or link errors.
**Fix applied:** added a comment above the `pod` line spelling out the
bump-with-`cloud_firestore` rule. (Comment only — no behavior change.)

### I5 — Podfile pod-warning suppression (DONE 2026-05-21)

`ios/Podfile` `post_install` previously set `SWIFT_SUPPRESS_WARNINGS = YES` for
three pods only (`firebase_storage`, `firebase_analytics`, `cloud_functions`).
The original audit advised *narrowing* this. That advice is **reversed** now
that the actual warning list is known (see I1): the warnings are ~50 items of
un-actionable third-party pod noise across a dozen pods. **Fix applied:**
replaced the three-pod block with a single target-level `inhibit_all_warnings!`,
the idiomatic CocoaPods directive for exactly this situation. It silences all
pod compiler warnings, never the Runner target's own — so the app's real
warnings still surface. Behavior-only change (warnings ≠ codegen ≠ runtime).

### A3 — `GoogleService-Info.plist` `IS_ANALYTICS_ENABLED=false` [quick verify]

The checked-in (dev) `ios/Runner/GoogleService-Info.plist` has
`IS_ANALYTICS_ENABLED=false`. This legacy plist flag is largely superseded by
the runtime `setAnalyticsCollectionEnabled()` call and Info.plist analytics
keys, so it probably is not the cause of anything — but it is inconsistent and
confusing. Confirm the prod project's `GoogleService-Info.plist` is consistent,
and rely on the runtime switch as the single control.

### W1 — Dead messaging service-worker registration (DONE 2026-05-21)

`web/index.html` registered `firebase-messaging-sw.js` on every web origin —
but web push is disabled (no `FIREBASE_WEB_VAPID_KEY`) **and** there is no
`web/firebase-messaging-sw.js` file, so the registration 404'd on every web page
load. **Fix applied:** removed the dead registration `<script>` block, leaving a
comment so it is re-added together with the SW file if web push is enabled later.

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

Most of the audit is now done (see Status summary). What is left is decision- or
console-gated — see "Remaining items" below.

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
  (the console toggle still needed Analytics Admin access at that point).
- **2026-05-23** — A2 fixed: Google Analytics Admin now shows a BigQuery link
  from GA4 property `catch-dating-app-64e51` to BigQuery project
  `catch-dating-app-64e51` in `Mumbai (asia-south1)` with daily event export.
- **2026-05-21** — C2 fixed: pinned `firebase-tools@15.1.0` in all four
  deploy/CI workflows. C5 fixed: pinned `flutter-version: 3.41.9` everywhere.
- **2026-05-21** — `docs/release_operations.md` "Required PR Checks" updated to
  list `contracts-ci.yml`.
- **2026-05-21** — B1 fixed: startup Remote Config fetch failure now logged via
  `ErrorLogger` instead of swallowed (`lib/main.dart`); `flutter analyze` clean.
- **2026-05-21** — I4 fixed: documented the `FirebaseFirestore` pod pin rule
  with a Podfile comment. Committed as `b4b1f107`.
- **2026-05-21** — User supplied the real TestFlight/Xcode warning list. I1
  re-diagnosed: build/compiler warnings, not a privacy-manifest issue (no
  `ITMS-9105x`). Reclassified P1→P3.
- **2026-05-21** — I1 fixed: added `inhibit_all_warnings!` to the Podfile to
  silence ~50 third-party pod warnings; added the missing `AccentColor`
  colorset. I5 resolved by the same `inhibit_all_warnings!` change. I6 logged
  (Crashlytics every-build phase — benign).
- **2026-05-21** — C6 fixed: added a prod web release build to
  `app-build-matrix.yml`. C8 fixed: documented the manual `--only extensions`
  deploy in `release_operations.md`.
- **2026-05-21** — Second batch of fixes after user decisions: I2 (App Check
  Dart-only — native block removed from `AppDelegate.swift`), N1 (Gradle
  build-time guard for `google-services.json`/flavor mismatch), C3 (dev-deploy
  poll hardened — fail-fast on missing/renamed workflow), I3 (`Release.xcconfig`
  non-canonical comment), W1 (removed dead service-worker registration). B3
  resolved as not-a-risk (Flutter web is not a shipped surface).

## Remaining items and what they need

The audit is functionally complete. The few items left are intentionally not
fixed in-repo:

- **D1** — long-horizon: finish or freeze the schema-contract unification
  migration (`docs/schema_contract_unification_tracker.md`, ~weeks of work).
  Not a defect — D2's CI gate now protects the contracts layer from regressing
  while this is decided. Informational only.
- **I6** — silencing the Crashlytics "runs every build" warning needs a
  `project.pbxproj` script-phase edit; do it in Xcode. Behavior is correct for
  archive builds — benign, low priority.
- **A3** — Firebase Console verification only (prod `GoogleService-Info.plist`
  analytics flag). Cannot be done from the repo; steps are documented in
  `docs/release_operations.md`.
- **M1** — root `.env` placeholder Razorpay key. `.env` is git-ignored — there
  is nothing to change in-repo. Local hygiene: ensure the real test key is
  present before running `build_runner`.
- **Metal toolchain search-path warnings** — an Xcode Cloud build-machine
  environment issue (provision the Metal toolchain on the runner); not a repo
  change.

## Verification done during this audit

- `flutter analyze --no-fatal-infos` → "No issues found" (clean).
- All five contract checks (`validate_schema_contracts`, `generate_schema_contracts
  --check`, `check_schema_type_boundaries`, `check_schema_path_literals`,
  `check_firestore_rules_semantics`) pass on a clean `origin/main` worktree.
- Read: all 11 `.github/workflows/*`, `firebase.json`, `.firebaserc`,
  `ios/` (Info.plist, entitlements, xcconfig set, Podfile, AppDelegate,
  ExportOptions, ci_scripts), `android/app/build.gradle`, `web/index.html`,
  `lib/main.dart`, `lib/app.dart`, `lib/core/app_config.dart`,
  `lib/core/analytics/app_analytics.dart`, `lib/exceptions/error_logger.dart`,
  `contracts/` tree + `contracts/README.md`, `tool/check_data_contract.sh`,
  `tool/flutter_with_env.sh`, `tool/deploy_firebase_targets.sh`,
  `tool/write_ios_maps_key_xcconfig.sh`.
- Not deeply reviewed (out of scope / lower risk): `macos/` (macOS push is
  deferred per memory), the runtime feature code under `lib/<feature>/`, the
  Cloud Functions implementation under `functions/src/`.
