# Build Readiness and Dependency Report - 2026-04-29

This report summarizes the current cross-target build state, remaining build/release issues, dependency posture, and the fixes applied during the build-hardening pass.

Primary tracker: [target_build_audit_2026-04-28.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/target_build_audit_2026-04-28.md)

## Current Build Matrix

| Area | Result | Evidence | Notes |
| --- | --- | --- | --- |
| Flutter SDK | Pass | `flutter --version` -> Flutter `3.41.2`, Dart `3.11.0` | Stable channel. |
| Analyzer | Pass | `flutter analyze` -> `No issues found` | Re-run after dependency/pod changes. |
| Web | Pass with warnings | `flutter build web --dart-define=APP_ENV=dev` -> `build/web` | Warnings are wasm dry-run suggestion and icon tree-shaking output. |
| Android APK | Pass with warnings | `flutter build apk --dart-define=APP_ENV=dev` -> `build/app/outputs/flutter-apk/app-release.apk` at `63.4MB` | Warnings are icon tree-shaking output. |
| iOS simulator | Pass with warnings | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` -> `build/ios/iphonesimulator/Runner.app` | Warnings are dependency-outdated notices from `pub get`. |
| iOS device, no codesign | Pass with warnings | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` -> `build/ios/iphoneos/Runner.app` at `52.9MB` | Proves device compilation. Does not prove deployability. |
| iOS device, signed Profile | Pass with warning | `flutter build ios --profile --dart-define=APP_ENV=dev` -> `build/ios/iphoneos/Runner.app` at `62.6MB` | Automatic signing used team `2HQBK4UMUT`. Strict local `codesign --verify` still warns. |
| iOS physical iPhone Profile run | Partial pass | `flutter run -d 00008120-001A152E3EEB401E --profile --dart-define=APP_ENV=dev` built, installed/launched, and `devicectl` showed `Runner.app/Runner` PID `19774` | Flutter did not discover the Dart VM Service after 60s. Process launch is proven; interactive observability/UI validation is not. |
| macOS | Pass with warnings | `flutter build macos --dart-define=APP_ENV=dev` -> `build/macos/Build/Products/Release/catch_dating_app.app` at `109.7MB` | Warnings are native dependency/plugin warnings and duplicate linker flags. |
| Firebase Functions TypeScript | Pass | `npm run build` | Re-run after Functions dependency update. |
| Firebase Functions tests | Pass | `npm test` -> 18 tests passed | Covers payments and safety/blocking Functions tests. |

## Remaining Issues

### Apple signing, profiles, and certificates

1. `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` still reports `CSSMERR_TP_NOT_TRUSTED`.
   - Severity: Medium before TestFlight/App Store work.
   - Meaning: Xcode can sign and build the app, and `security find-identity -v -p codesigning` reports three valid Apple Development identities, but this Mac's strict trust-chain verification is not clean.
   - Next fix: validate through Xcode Archive/Organizer export, inspect Keychain trust for Apple Worldwide Developer Relations / Apple Development chain, and confirm the exported archive verifies cleanly.

2. Current iOS signed builds are development/Profile builds, not App Store distribution artifacts.
   - Severity: High before release.
   - Evidence: entitlements include `get-task-allow = true`, `aps-environment = development`, and App Attest environment `development`.
   - Next fix: create/reuse the real production bundle ID, configure App Store/TestFlight signing, regenerate profiles after App Attest and Push capability changes, and verify a signed archive/export.

3. Bundle/application ID has been switched locally to `com.catchdates.app`.
   - Severity: High until follow-up capability checks are complete.
   - Meaning: The local Android/iOS/macOS identifiers and dev Firebase native config files now use the final ID, and the Android debug SHA fingerprints are registered. The new Firebase apps still need App Check, Android release SHA fingerprints, APNs status verification, and Apple Developer capability/profile refresh.
   - Verification: `flutter analyze`, Android APK build, direct iOS simulator Xcode build, and macOS build all passed with `com.catchdates.app` in their produced metadata.
   - Next fix: register release SHA fingerprints / APNs / App Check against the new IDs and verify signed iOS provisioning for `com.catchdates.app`.

4. Physical iPhone Profile launch is not fully clean yet.
   - Severity: Medium.
   - Evidence: the Profile app built, installed/launched, and was running on device as PID `19774`; Flutter then failed to discover the Dart VM Service after 60 seconds.
   - Next fix: rerun from Xcode or `flutter run -v --profile` with the phone unlocked and cabled, collect device logs while the process is running, and determine whether the missing VM service is a tooling attach issue or a runtime startup issue.

5. iOS Debug physical run hit native `EXC_BAD_ACCESS` in Flutter embedder/debug tooling.
   - Severity: Low for release, Medium for local debugging.
   - Evidence: direct untethered Debug launch produced Flutter's expected "Cannot create a FlutterEngine instance in debug mode without Flutter tooling or Xcode" message and a crash with `-[VSyncClient initWithTaskRunner:callback:]`.
   - Interpretation: Current evidence points to Flutter Debug launch/tooling behavior, not app Dart/Firebase/Razorpay code. Related upstream issue: https://github.com/flutter/flutter/issues/168582.

### Push notifications, Cloud Messaging, and App Check

1. iOS Push is configured for development, but production push still needs release validation.
   - Current good state: Firebase Cloud Messaging APNs auth keys are uploaded for the new `com.catchdates.app` Firebase iOS app, the iOS target declares the App Attest entitlement, `UIBackgroundModes` includes `remote-notification`, and debug/development signing has previously produced `aps-environment = development`.
   - Remaining release work: verify Apple Developer Push Notifications and App Attest for final bundle ID `com.catchdates.app`, regenerate provisioning profiles, then validate production APNs behavior on TestFlight/App Store profile.

2. Web Push is configured for dev only.
   - Severity: Low if web is only a debugging target; Medium if web notifications are expected in staging/prod.
   - Current state: Firebase has a Web Push certificate key pair and `tool/dart_defines/dev.json` contains the public VAPID key. Staging/prod remain blank because those Firebase environments are not real yet.
   - Next fix: when staging/prod Firebase projects exist, create/import matching Web Push key pairs and pass the public VAPID keys through the matching environment dart-define files.

3. Firebase App Check is configured but not enforced.
   - Current good state: iOS App Attest is enabled in Apple Developer and Firebase; Android is registered with Play Integrity; iOS signed binary includes `com.apple.developer.devicecheck.appattest-environment = development`.
   - Remaining work: register web App Check with reCAPTCHA Enterprise if web remains supported, roll out App Check debug tokens for local testing, then enable enforcement gradually for Firestore/Storage/Auth/Functions after token telemetry looks healthy.

4. macOS push is intentionally disabled.
   - Severity: Low for current product direction.
   - Current state: macOS is a debugging target, and push registration is disabled on macOS to avoid requiring macOS APNs provisioning.
   - Next fix only if needed: create a real macOS App ID, add APNs entitlement/profile, and re-enable macOS push code paths.

### Android toolchain and release signing

1. Android APK builds successfully, but release signing is not production-correct without `android/key.properties`.
   - Severity: High before Play Store release.
   - Current state: local release APK build works, but Gradle falls back to debug signing when a release keystore is absent.
   - Next fix: create a real upload keystore or configure Play App Signing, store secrets outside git, populate `android/key.properties`, and register release SHA-1/SHA-256 fingerprints in Firebase.

2. Android App Check Play Integrity needs production signing fingerprints.
   - Severity: High before enforcing App Check.
   - Meaning: Play Integrity/App Check should be tied to the final app ID and release signing identity, not only debug/dev state.

### Web

1. Web build passes, but web is not production-hardened for push/App Check.
   - Severity: Low if web remains debug-only.
   - Required for real web release: VAPID key, Web App Check provider, hosting config review, and environment-specific Firebase web config validation.

### macOS

1. macOS build passes with third-party native warnings.
   - Severity: Low.
   - Warnings include duplicate `-lc++`, `-lsqlite3`, `-lz`, and Firebase/FlutterFire plugin warnings from `.pub-cache`/Pods source.
   - These are not app-code compile errors. Track upstream package updates rather than patching generated dependency code.

2. macOS is currently a debug/support target, not a distribution target.
   - Severity: Low.
   - If distribution is desired later, add macOS bundle ID, signing, notarization, hardened runtime, APNs decision, and Firebase macOS config validation.

### Firebase backend and Functions

1. Functions dependencies build and tests pass, but production `npm audit` still reports 11 transitive vulnerabilities.
   - Severity: Medium.
   - Cause: Firebase Admin / Google Cloud transitive chain (`@google-cloud/storage`, `google-gax`, `teeny-request`, `uuid`, `@tootallnate/once`).
   - Important: `npm audit fix --force` would install `firebase-admin@10.1.0`, a breaking downgrade. Do not force it.
   - Current recheck: `npm audit fix --dry-run` reports no safe non-force fix; `firebase-admin@13.8.0` is already the latest direct Firebase Admin release.
   - Next fix: monitor Firebase Admin / Google Cloud releases and update when a safe upstream patch exists. Avoid npm `overrides` unless we intentionally test the forced transitive dependency set through Functions build, unit tests, emulator tests, and deploy validation.

2. Functions App Check enforcement is still a backend policy decision.
   - Severity: Medium before production hardening.
   - Next fix: add/enforce App Check checks in callable/HTTP Functions where appropriate, then deploy after client App Check is stable.

## Applied Fixes and Quality Rating

| Fix | Files/area | Rating | Why |
| --- | --- | --- | --- |
| Installed missing Xcode iOS platform component `iOS 26.4.1 Simulator (23E254a)` | Local Xcode toolchain | Canonical | Fixed iOS destination discovery for this app and a fresh Flutter template. |
| Aligned Firebase iOS/macOS pods to SDK `12.12.0` | `ios/Podfile.lock`, `macos/Podfile.lock` | Canonical | Required by current FlutterFire packages. |
| Added/fixed iOS Profile xcconfig wiring | `ios/Flutter/Profile.xcconfig`, Xcode project config | Canonical | Profile builds now include the generated Pods config like Debug/Release. |
| Fixed macOS CocoaPods xcconfig integration | macOS Xcode project/AppInfo xcconfigs | Canonical | Keeps app metadata and Pods config composed cleanly without editing generated Flutter configs. |
| Disabled macOS push registration and APNs entitlement | macOS target + FCM app code | Canonical for current scope | macOS is debug-only; avoiding APNs entitlement is the correct buildable state until macOS push is a real product requirement. |
| Enabled iOS App Attest and added App Attest entitlement | Apple Developer + `ios/Runner/Runner.entitlements` | Canonical | Required for App Check with App Attest on iOS. |
| Verified iOS APNs auth-key setup in Firebase for `com.catchdates.app` | Firebase Cloud Messaging | Canonical | APNs auth keys are preferred over per-app APNs certificates; the new Firebase iOS app now has development and production rows using key ID `78HUQYZ2ZR`. |
| Normalized versioned SDK framework paths in Podfile post-install hooks | `ios/Podfile`, `macos/Podfile` | Compatibility shim, acceptable | Works around `xcodeproj 1.27.0` generating stale versioned SDK paths under Xcode 26. Remove when CocoaPods/xcodeproj catches up. |
| Used precompiled Firestore binary pod override | `ios/Podfile`, `macos/Podfile` | Compatibility shim, acceptable | Common FlutterFire performance/build-stability workaround for Firestore's large native build graph. Monitor upstream and remove if standard pods become reliable enough. |
| Repaired partial CocoaPods installs by deleting generated Pods directories and rerunning pod install serially | `ios/Pods`, `macos/Pods` generated state | Canonical recovery | The failures came from interrupted/concurrent cache copies and a transient GitHub 502, not source code. |
| Removed stale local Razorpay core podspec override | `ios/Podfile`, deleted `ios/PodspecOverrides/razorpay-core-pod.podspec.json` | Canonical | The local override pinned `razorpay-core-pod 1.0.3`, blocking official `razorpay-pod 1.5.3` and causing iOS Swift compile failures. |
| Updated official Razorpay native pods | `ios/Podfile.lock` | Canonical | `razorpay-pod 1.5.3` + `razorpay-core-pod 1.0.6` resolves the `RazorpayEventCallback` compile failure without patching plugin cache. |
| Ran in-range Flutter/Dart dependency upgrades | `pubspec.lock` | Canonical | Kept within declared `pubspec.yaml` constraints and then verified analyzer/builds. |
| Updated Firestore test batch helper type | `test/chats/firestore_repository_test_helpers.dart` | Canonical | Required by the newer `cloud_firestore` API signature: `Map<Object, Object?>`. |
| Updated Functions runtime dependencies | `functions/package-lock.json` | Canonical | `firebase-admin@13.8.0`, `firebase-functions@7.2.5`; build/tests pass. |
| Ran `npm audit fix` without `--force` | `functions/package-lock.json` | Canonical | Accepted safe fixes only; avoided a breaking Firebase Admin downgrade. |

## Dependency Status

### Flutter/Dart

Safe in-range updates were applied through `flutter pub upgrade`. The lockfile now includes newer FlutterFire/Riverpod/navigation/payment packages within current constraints, including:

- `cloud_firestore 6.3.0`
- `cloud_functions 6.2.0`
- `firebase_auth 6.4.0`
- `firebase_messaging 16.2.0`
- `firebase_storage 13.3.0`
- `flutter_riverpod 3.3.1`
- `go_router 17.2.2`
- `image_picker 1.2.2`
- `razorpay_flutter 1.4.4`
- `build_runner 2.14.1`
- `envied 1.3.4`
- `envied_generator 1.3.4`

Remaining direct dependency migrations from `flutter pub outdated`:

| Package | Current | Latest | Recommendation |
| --- | --- | --- | --- |
| `flutter_map` | `7.0.2` | `8.3.0` | Major migration; schedule separately and retest map screens. |
| `google_fonts` | `6.3.3` | `8.1.0` | Major migration; low risk but should be verified visually. |
| `latlong2` | `0.9.1` | `0.10.1` | Constraint-blocked; likely tied to `flutter_map` migration. |
| `package_info_plus` | `9.0.1` | `10.1.0` | Major migration; verify platform metadata on all targets. |
| `share_plus` | `12.0.2` | `13.1.0` | Major migration; verify native share sheets on iOS/Android. |
| `two_dimensional_scrollables` | `0.3.9` | `0.4.2` | `0.x` minor can be breaking; migrate with focused UI tests. |
| `json_serializable` | `6.13.0` | `6.13.1` | Patch update, but current constraint prevents it; low priority. |

Do not run `flutter pub upgrade --major-versions` as a drive-by fix. These package moves should be treated as migration work with focused smoke tests.

### Firebase Functions / npm

Current direct runtime package state:

- `firebase-admin@13.8.0`
- `firebase-functions@7.2.5`
- `razorpay@2.9.6`

Remaining `npm outdated` items are dev-tooling major migrations:

- `@typescript-eslint/eslint-plugin 5.62.0 -> 8.59.1`
- `@typescript-eslint/parser 5.62.0 -> 8.59.1`
- `eslint 8.57.1 -> 10.2.1`
- `typescript 5.9.3 -> 6.0.3`

Recommendation: migrate ESLint/TypeScript tooling in a separate Functions lint modernization pass. Do not mix that with release signing or app build fixes.

## Current Worktree Caveat

The worktree contains many unrelated in-progress app/UI/asset changes in addition to build-readiness changes. I did not revert them. For a clean review or commit, split changes into at least:

1. Build/toolchain/dependency fixes.
2. Branding/icon/splash assets.
3. Crashlytics/error logging/analytics work.
4. UI feature changes and tests.
5. Audit/report documents.

## Recommended Next Order

1. Resolve `CSSMERR_TP_NOT_TRUSTED` or prove it is harmless by creating a real Xcode archive/export.
2. Choose the final iOS bundle ID and Android application ID, then regenerate Firebase apps/config files.
3. Configure production Android signing and register release SHA fingerprints.
4. Validate physical iPhone Profile/Release run from Xcode or `flutter run -v --profile`, including UI startup and logs.
5. Decide whether web is debug-only. Dev Web Push is configured; Web App Check and future staging/prod Web Push still need environment-specific setup.
6. Enable Firebase App Check enforcement gradually after debug/prod tokens are confirmed.
7. Schedule dependency major-version migrations separately from release signing.
