# Host App Config And Release Recap

Last updated: 2026-06-11

## Scope

This is a config and release recap for the Catch Host app work. It intentionally
does not cover host product/business logic in detail. It focuses on the
platform, Firebase, App Check, native build, CI, TestFlight, and release steps
that were needed to make Catch Host a separate app product from the consumer
Catch app while still sharing the same Flutter repo and backend.

## Current Architecture In One Sentence

Catch now has a two-axis app matrix:

- Environment: `dev`, `staging`, `prod`
- App role: `consumer`, `host`

The environment decides which Firebase project/config/secrets to use. The app
role decides which product identity, entrypoint, Firebase app registration,
native bundle/application id, launcher icon, and UI shell to use.

This separation matters because `dev/staging/prod` answer "where does this
build point?", while `consumer/host` answers "which app product is this?".
Those two questions are independent and cannot safely be modeled as one axis.

## Major Steps Completed

### 1. Split Runtime Entrypoints

What changed:

- Added a shared app bootstrap in `lib/app_bootstrap.dart`.
- Kept consumer startup in `lib/main_consumer.dart`.
- Added host startup in `lib/main_host.dart`.
- Added role handling through `AppConfig` and `AppRole`.

Why it happened:

Flutter needs a target file for each app product. The host app cannot just be a
route hidden inside the consumer app, because native builds, Firebase App Check,
push tokens, bundle ids, and store records all depend on product identity.

The shared bootstrap keeps Firebase initialization, App Check activation,
Remote Config, Analytics, Crashlytics, emulator wiring, and error handling in
one place. The entrypoint only selects the role.

### 2. Updated The Env-Aware Flutter Wrapper

What changed:

- `tool/flutter_with_env.sh` now accepts `--role consumer|host`.
- It sets `ORG_GRADLE_PROJECT_catchAppRole` for Android.
- It selects `lib/main_consumer.dart` or `lib/main_host.dart`.
- It chooses host Apple flavors such as `host-dev`, `host-staging`, and
  `host-prod` when building/running on iOS or macOS.
- It injects `CATCH_APP_ROLE` as a Dart define.
- It validates required Maps config before mobile builds/runs.
- It blocks mobile debug runs unless a registered Firebase App Check debug token
  is available, unless explicitly allowed for first setup.

Why it happened:

The wrapper is the repo's guardrail against accidentally building the right code
against the wrong Firebase app or native identity. Without it, it is easy to run
`prod` with dev Firebase files, build host with consumer ids, or ship an app
that crashes on maps because the key was not written into the native config.

### 3. Added Host Firebase App Registrations And Config Files

What changed:

- Added host Firebase config files under:
  - `firebase/dev/host/...`
  - `firebase/staging/host/...`
  - `firebase/prod/host/...`
- Each environment now has host Android, host iOS/macOS, and host web config
  files alongside the consumer files.
- Updated `tool/use_firebase_environment.sh` to copy either consumer or host
  configs into the platform working locations.
- Updated `tool/validate_firebase_environment.sh` to validate the selected
  environment and role.

Why it happened:

Firebase treats every app id/package/bundle as a separate app registration.
Since the consumer and host apps must install side by side, they cannot share
the same native application id or bundle id. That means they also need separate
Firebase app registrations and downloaded SDK config files.

The checked-in `firebase/<env>/host/...` files are canonical source configs. The
platform paths such as `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist` are working copies selected by scripts.

### 4. Registered And Enforced App Check For Host Apps

What changed:

- Host Android App Check uses Play Integrity.
- Host iOS App Check uses App Attest.
- Host web App Check uses reCAPTCHA Enterprise.
- Firebase App Check provider configs and enforcement were verified across dev,
  staging, and prod for the host app registrations.
- Debug-token handling was kept explicit for local mobile debug runs.

Why it happened:

Firestore, Storage, Auth, and callable Functions are App Check-protected in this
repo. Creating a new app product without registering App Check would make real
backend calls fail even if Firebase Auth and Firestore rules were correct.

App Check is also why the debug-token setup mattered. Local debug apps do not
produce the same release attestation as App Attest or Play Integrity. A debug
token must be registered in Firebase for local testing, but raw token values
should not be committed.

### 5. Wired Android Host Product Identity

What changed:

- `android/app/build.gradle.kts` now reads `catchAppRole`.
- Consumer base id remains `com.catchdates.app`.
- Host base id is `com.catchdates.host`.
- The existing environment flavors still append:
  - dev: `.dev`
  - staging: `.staging`
  - prod: no suffix
- Host app names are distinct, for example `Catch Host`, `Catch Host Dev`, and
  `Catch Host Staging`.
- Host-specific launcher resources live under:
  - `android/app/src/hostDev/res`
  - `android/app/src/hostStaging/res`
  - `android/app/src/hostProd/res`

Why it happened:

Android install identity is the `applicationId`. If host reused the consumer
application id, the phone would treat it as the same app. The host ids allow
side-by-side installs, separate Firebase registrations, separate App Check
attestation, separate push identity, and eventually a separate Play Console
listing.

### 6. Wired Apple Host Schemes And Build Configurations

What changed:

- Added iOS schemes:
  - `host-dev`
  - `host-staging`
  - `host-prod`
- Added matching iOS build configurations:
  - `Debug-host-*`
  - `Profile-host-*`
  - `Release-host-*`
- Added matching macOS schemes/configurations.
- Added host xcconfig files, including `ios/Flutter/Release-host-prod.xcconfig`.
- The host prod iOS bundle id is `com.catchdates.host`.
- The host dev/staging iOS bundle ids are:
  - `com.catchdates.host.dev`
  - `com.catchdates.host.staging`
- The Apple project points host builds at the host launcher icons.

Why it happened:

Apple release identity is driven through schemes, build configurations, bundle
ids, entitlements, signing, and asset catalogs. Xcode Cloud and TestFlight need
a concrete scheme/config pair to archive. For host production, that pair is:

- Scheme: `host-prod`
- Configuration: `Release-host-prod`
- Bundle id: `com.catchdates.host`

### 7. Added Apple App ID And App Store Connect Host App Record

What changed:

- Apple Developer App ID `Catch Host` / `com.catchdates.host` was created.
- Capabilities were enabled for the host App ID:
  - App Attest
  - Associated Domains
  - HealthKit
  - Push Notifications
- App Store Connect app `Catch Host` exists as app id `6778927317`.

Why it happened:

Firebase iOS App Check with App Attest depends on Apple-side app identity and
capabilities. TestFlight also needs an App Store Connect app record tied to the
same bundle id. The repo can define `com.catchdates.host`, but Apple must also
know and sign that id before a real archive can be uploaded.

### 8. Added Host Launcher Icons And Branding Generation

What changed:

- Generated host source icons under `assets/branding/generated/`.
- Generated Android host launcher resources for dev, staging, and prod.
- Generated iOS AppIcon catalogs:
  - `AppIcon-host-dev`
  - `AppIcon-host-staging`
  - `AppIcon-host-prod`
- Generated macOS host AppIcon catalogs.
- Updated the branding generator and manifest so the asset generation is
  reproducible.

Why it happened:

Separate apps need visibly separate launcher assets and native asset catalogs.
The iOS App Store/TestFlight archive also needs a valid 1024x1024 marketing
icon in the app icon set. We verified the host prod 1024 icon exists and is
1024 by 1024 pixels.

### 9. Added Google Maps Key Injection And Validation

What changed:

- Host Apple xcconfigs include `GoogleMapsKeys.xcconfig`.
- `ios/Flutter/Release-host-prod.xcconfig` maps
  `GOOGLE_MAPS_IOS_API_KEY` to `GOOGLE_MAPS_IOS_API_KEY_PROD`.
- `ios/ci_scripts/ci_post_clone.sh` writes the prod iOS Maps key in Xcode
  Cloud.
- `ios/ci_scripts/ci_post_xcodebuild.sh` fails an archive if the built app has
  a missing or placeholder Maps key.
- GitHub TestFlight fallback workflow also verifies the archived/exported Maps
  key.

Why it happened:

`ios/Flutter/GoogleMapsKeys.xcconfig` is intentionally gitignored, so a fresh CI
clone does not have it. If an iOS archive reaches TestFlight with an empty
`GoogleMapsApiKey`, map screens crash at runtime. The release path now writes
and verifies the key instead of assuming it exists on the machine.

### 10. Updated CocoaPods And Apple Flavor Generation

What changed:

- Updated iOS and macOS Podfiles/locks for the new host configurations.
- Updated `tool/platform/configure_apple_flavors.rb` so future flavor
  regeneration includes host schemes/configurations.
- Added Apple project references for host xcconfig files, schemes, bundle ids,
  and icon catalogs.

Why it happened:

CocoaPods generates per-configuration support files. Adding Xcode
configurations without corresponding Pods support can break builds later. The
configuration generator keeps the large Xcode project changes reproducible
instead of hand-maintained only.

### 11. Updated GitHub Actions Build Coverage

What changed:

- `.github/workflows/app-build-matrix.yml` now builds:
  - dev consumer web
  - dev host web
  - prod consumer web
  - prod host web
  - dev consumer Android debug APK
  - dev host Android debug APK
  - dev consumer iOS simulator
  - dev host iOS simulator
- The current PR commit `95a71ff9` has green GitHub Actions for:
  - Contracts CI
  - Firestore Rules Tests
  - Functions CI
  - Flutter CI
  - Tools CI
  - App Build Matrix

Why it happened:

Adding a second app product doubles the chance of product-specific build drift.
The app build matrix catches cases where consumer still builds but host does
not, or where prod web config breaks while dev web still passes.

### 12. Added Manual GitHub TestFlight Fallback

What changed:

- `.github/workflows/ios-testflight-release.yml` now accepts `app_role`.
- `consumer` archives `prod` / `Release-prod`.
- `host` archives `host-prod` / `Release-host-prod`.
- Host fallback expects bundle id `com.catchdates.host`.
- The workflow exports a short-lived IPA artifact.
- Actual TestFlight upload is guarded as break-glass only and requires a reason.

Why it happened:

The release decision is that Xcode Cloud remains the canonical TestFlight
uploader. GitHub Actions is a fallback archive/export path, not the normal
mobile distribution path. Keeping GitHub as fallback is useful because it proves
the repo can produce a signed IPA and gives a recovery option if Xcode Cloud is
temporarily unavailable.

### 13. Updated Release Documentation

What changed:

- `README.md` now summarizes the host product identities, host schemes, host
  icons, and App Check state.
- `firebase/README.md` now documents the role-specific Firebase config layout.
- `docs/release_operations.md` now owns the host TestFlight/Xcode Cloud release
  state.
- `docs/plans/host_consumer_app_split_tracker.md` records that store release
  follow-ups live in release operations docs.

Why it happened:

This setup crosses Flutter, Firebase, Android, Apple, GitHub Actions, and App
Store Connect. Without a durable written owner, the next release pass would
require rediscovering which surface owns each requirement.

### 14. Fixed CI Drift After The Host Split

What changed:

- Updated widget tests whose assumptions changed because host tools no longer
  belong in the consumer app.
- Explicitly configured host role in host-specific tests.
- Updated UI route inventory and capture coverage for host routes.
- Refreshed design context manifests after the tools CI check caught drift.

Why it happened:

Once the consumer and host apps are distinct, tests that used to assume host
actions were visible in consumer surfaces became wrong. CI had to encode the new
product boundary: consumer should not show host creation/editing tools; host
tests must run under `AppRole.host`.

## Verification Performed

Local verification included:

- `dart format test/clubs/clubs_widgets_test.dart test/dashboard/dashboard_screen_test.dart`
- `flutter test test/clubs/clubs_widgets_test.dart test/dashboard/dashboard_screen_test.dart --reporter expanded`
- `node tool/ui_capture/check_route_inventory.mjs --check`
- `node tool/run.mjs check --manifest-only`
- `node tool/run.mjs check --category ui-capture`
- `node tool/run.mjs check --category design`
- `flutter test --concurrency=1 --exclude-tags=golden`

Remote verification included GitHub Actions on commit `95a71ff9`, where the
pull-request workflows were all green and the App Build Matrix included host
web, host Android, and host iOS simulator build steps.

Live Apple verification showed:

- App Store Connect Catch Host Xcode Cloud still says to create a workflow in
  Xcode.
- Catch Host TestFlight currently has no builds.

## What Is Still Pending

### Required Before Host TestFlight Is Real

1. Create the Xcode Cloud workflow for Catch Host from Xcode.
   - App Store Connect app: `6778927317`
   - Bundle id: `com.catchdates.host`
   - Scheme: `host-prod`
   - Configuration: `Release-host-prod`

2. Add the required Xcode Cloud secret:
   - `GOOGLE_MAPS_IOS_API_KEY_PROD`

3. Set `CATCH_APP_ROLE=host` in the workflow if Xcode Cloud does not infer host
   mode from the `host-prod` scheme through `CI_XCODE_SCHEME`.

4. Run one Xcode Cloud archive and upload it to TestFlight.

5. Install the host TestFlight build and smoke test:
   - launch
   - App Check acceptance
   - maps rendering
   - phone auth
   - push registration
   - host club/event entrypoints

### Store And Device Work Still Pending

- Android real-device smoke testing is still hardware-gated until an authorized
  Android phone is connected.
- Play internal testing is not proven yet.
- Play app-signing certificate fingerprints still need to be added to Firebase
  after Play Console enrollment.
- Store metadata, privacy/data-safety forms, screenshots, legal/support URLs,
  and production Crashlytics/Analytics dashboard proof remain release-management
  work.
- macOS phone-auth runtime behavior remains intentionally deferred because
  Firebase Auth `verifyPhoneNumber()` is unavailable on macOS.

## How To Add Another App Product In This Repo

Use this as the repeatable checklist:

1. Decide whether the change is a new environment or a new app role.
   - New environment means another Firebase project/config set.
   - New app role means another installable product identity.

2. Add or reuse a Flutter entrypoint.
   - Keep shared startup in `app_bootstrap.dart`.
   - Make the entrypoint select only the app role.

3. Extend `AppConfig` and `tool/flutter_with_env.sh`.
   - Add role validation.
   - Set Dart defines.
   - Select the correct target file.
   - Select the correct native flavor/scheme.

4. Create Firebase app registrations per environment and platform.
   - Android package ids.
   - iOS bundle ids.
   - Web app registration.
   - macOS config if needed.

5. Download SDK configs into `firebase/<env>/<role>/...`.

6. Update `tool/use_firebase_environment.sh` and
   `tool/validate_firebase_environment.sh` if the layout changes.

7. Configure App Check for every Firebase app registration.
   - Android: Play Integrity for release.
   - iOS: App Attest for release.
   - Web: reCAPTCHA Enterprise.
   - Register debug tokens only for local debug and never commit raw values.

8. Add Android identity.
   - Application id.
   - App names.
   - Launcher resources.
   - Google Services config validation.
   - Signing assumptions.

9. Add Apple identity.
   - Schemes.
   - Build configurations.
   - xcconfig files.
   - Bundle ids.
   - Entitlements/capabilities.
   - App icons.
   - CocoaPods configuration support.

10. Add Apple Developer and App Store Connect records.
    - App ID.
    - Capabilities.
    - App Store Connect app.
    - TestFlight workflow.

11. Add CI coverage.
    - Build at least one host/debug path per platform.
    - Build prod web if prod-only defines can break.
    - Add archive/export fallback if needed.

12. Document the result in `README.md`, `firebase/README.md`, and
    `docs/release_operations.md`.

## Mental Model For Future Reviews

If a build fails, ask which layer is wrong:

- Dart role/config layer: wrong entrypoint, wrong Dart define, wrong app shell.
- Firebase config layer: wrong `google-services.json`,
  `GoogleService-Info.plist`, web service worker, or Firebase options.
- App Check layer: Firebase knows the app, but rejects the attestation/debug
  token.
- Native identity layer: bundle id/application id/icon/scheme/signing mismatch.
- Secret injection layer: Maps key or App Store Connect credentials missing.
- CI/release layer: the repo can build locally, but the release runner does not
  have the same env/secrets/provisioning.
- Store layer: the archive exists, but Apple/Play records or workflows are not
  ready.

This is why the host app work touched many small config files: each platform has
its own definition of "which app is this?", and all of them must agree.
