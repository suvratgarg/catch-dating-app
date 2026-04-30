# Build Readiness and Dependency Report - 2026-04-29

Status: historical build snapshot. Use it as evidence for the 2026-04-29 build
hardening pass. Current release status lives in
[`production_release_checklist.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/production_release_checklist.md),
[`firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md),
and the active release setup tracker.
For current build/signing/distribution readiness, use
[`release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md);
older blocker text below is retained as historical evidence only.

This report summarizes the current cross-target build state, remaining build/release issues, dependency posture, and the fixes applied during the build-hardening pass.

Primary tracker: [target_build_audit_2026-04-28.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/target_build_audit_2026-04-28.md)

## Current Build Matrix

| Area | Result | Evidence | Notes |
| --- | --- | --- | --- |
| Flutter SDK | Pass | `flutter --version` -> Flutter `3.41.2`, Dart `3.11.0` | Stable channel. |
| Analyzer | Pass | `flutter analyze` -> `No issues found` | Re-run after Apple flavor/build-script changes. |
| Web | Pass with warning | `./tool/flutter_with_env.sh dev build web` -> `build/web` | Warning is Flutter's wasm dry-run suggestion. |
| Android dev debug APK | Pass with warnings | `./tool/flutter_with_env.sh dev build apk --debug` -> `build/app/outputs/flutter-apk/app-dev-debug.apk` | Wrapper now injects Android flavor `dev`; warnings are dependency-outdated notices. |
| Android prod App Bundle | Pass with warnings | `./tool/flutter_with_env.sh prod build appbundle` -> `build/app/outputs/bundle/release/app-release.aab` | A real local upload keystore now signs the prod release bundle. Warnings are dependency-outdated notices from `pub get`. |
| Android prod release APK | Pass with warnings | `./tool/flutter_with_env.sh prod build apk --release` -> `build/app/outputs/flutter-apk/app-prod-release.apk`; `apksigner verify --print-certs` confirmed SHA-1 `f37152371535e02e4af8c6a7d9e1dabbb7aa5637` and SHA-256 `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e` | Uses the same ignored local upload keystore and prod package `com.catchdates.app`. |
| iOS dev simulator | Pass with warnings | `./tool/flutter_with_env.sh dev build ios --simulator --no-codesign` -> `build/ios/iphonesimulator/Runner.app` | Built as `com.catchdates.app.dev` / `Catch Dev` and embedded the `catchdates-dev` Firebase plist. Warnings are dependency-outdated notices from `pub get`. |
| iOS device, no codesign | Pass with warnings | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` -> `build/ios/iphoneos/Runner.app` at `52.9MB` | Proves device compilation. Does not prove deployability. |
| iOS dev signed Profile | Pass with warnings | `./tool/flutter_with_env.sh dev build ios --profile` -> `build/ios/iphoneos/Runner.app` at `62.8MB` | Explicit Xcode-managed profile `iOS Team Provisioning Profile: com.catchdates.app.dev`; entitlements include `aps-environment=development` and App Attest development. |
| iOS staging signed Profile | Pass with warnings | `./tool/flutter_with_env.sh staging build ios --profile` -> `build/ios/iphoneos/Runner.app` at `62.8MB` | Explicit Xcode-managed profile `iOS Team Provisioning Profile: com.catchdates.app.staging`; embedded Firebase plist points at `catchdates-staging`. |
| iOS prod signed Profile | Pass with warnings | `./tool/flutter_with_env.sh prod build ios --profile` -> `build/ios/iphoneos/Runner.app` at `62.8MB` | Explicit Xcode-managed profile `iOS Team Provisioning Profile: com.catchdates.app`; embedded Firebase plist points at `catch-dating-app-64e51`. |
| iOS prod archive | Archive pass, IPA export blocked | `./tool/flutter_with_env.sh prod build ipa --release` -> `build/ios/archive/Runner.xcarchive` at `250.1MB`, then export failed | Archive metadata is correct: display name `Catch`, bundle `com.catchdates.app`, deployment target `15.0`. IPA export fails because this Mac still has no local `iOS Distribution`/Apple Distribution signing identity and no App Store/export profile for `com.catchdates.app`; Xcode's account UI is signed in for development signing, but CLI export still reports `No Accounts`. |
| iOS physical iPhone Profile run | Partial pass, runtime config issue found | `flutter run -d 00008120-001A152E3EEB401E --profile --flavor dev --dart-define=APP_ENV=dev` built, installed/launched, and exposed the Dart VM Service | Earlier VM-service discovery is now fixed. The app then logged Firebase App Check API `SERVICE_DISABLED` for the dev project and stopped in FirebaseAuth iOS `PhoneAuthProvider.verifyPhoneNumber` while starting phone verification. This is now a Firebase/App Check/APNs/phone-auth config issue, not a build issue. |
| macOS dev | Pass with warnings | `./tool/flutter_with_env.sh dev build macos` -> `build/macos/Build/Products/Release-dev/Catch Dev.app` at `116.5MB` | Built as `com.catchdates.app.dev` / `Catch Dev` and embedded the `catchdates-dev` Firebase plist. Remaining warnings are native dependency/plugin warnings from FlutterFire/CocoaPods. |
| macOS staging | Pass with warnings | `./tool/flutter_with_env.sh staging build macos` -> `build/macos/Build/Products/Release-staging/Catch Staging.app` at `116.7MB` | Built as `com.catchdates.app.staging` / `Catch Staging` and embedded Firebase app ID `1:822303414140:ios:6bae8cc0e1781e890c76f9`. |
| macOS prod | Pass with warnings | `./tool/flutter_with_env.sh prod build macos` -> `build/macos/Build/Products/Release-prod/Catch.app` at `116.7MB` | Built as `com.catchdates.app` / `Catch` and embedded Firebase app ID `1:574779808785:ios:49b1ce51418604b78ea5b0`. Strict local verification still reports `CSSMERR_TP_NOT_TRUSTED`, matching the iOS trust-chain warning. |
| Firebase Functions TypeScript | Pass | `npm run build` | Re-run after Functions dependency update. |
| Firebase Functions tests | Pass | `npm test` -> 18 tests passed | Covers payments and safety/blocking Functions tests. |

## Remaining Issues

### Apple signing, profiles, and certificates

1. App Store/TestFlight IPA export is blocked by distribution signing, not by app compilation.
   - Severity: High before iOS release.
   - Evidence: `./tool/flutter_with_env.sh prod build ipa --release` builds `build/ios/archive/Runner.xcarchive`, then `exportArchive` reports `No Accounts`, no signing certificate `"iOS Distribution"`, and no profiles for `com.catchdates.app`. A direct `xcodebuild -exportArchive -allowProvisioningUpdates` attempt with an export options plist fails the same way.
   - Current account state: Xcode Settings > Accounts is signed in as `Suvrat Garg`, role `Admin`, and development signing/profile creation works. Xcode Manage Certificates shows only Apple Development certificates; the create-certificate menu has Apple Distribution disabled. Chrome is also signed into the Apple Developer portal; the portal Certificates list shows only Development certificates, and the Profiles list is empty.
   - Meaning: Profile/device development signing is healthy, but App Store export needs a local Apple Distribution identity with private key plus an App Store provisioning profile for `com.catchdates.app`.
   - Next fix: sign into Apple Developer in Chrome or otherwise create/import an Apple Distribution signing identity, create/fetch an App Store profile for `com.catchdates.app`, then rerun the prod IPA export.

2. `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` still reports `CSSMERR_TP_NOT_TRUSTED`.
   - Severity: Medium before TestFlight/App Store work.
   - Evidence: strict verification against the signed dev `Runner.app` returns `CSSMERR_TP_NOT_TRUSTED`; `security find-identity -v -p codesigning` reports three valid Apple Development identities and no Apple Distribution identity.
   - Meaning: Xcode can sign and build development/Profile artifacts, but this Mac's strict local trust-chain verification is not clean.
   - Next fix: inspect Keychain trust for Apple Worldwide Developer Relations / Apple Development certificate chain, then confirm the exported App Store IPA verifies cleanly once distribution signing exists.

3. Current iOS signed app builds are development/Profile builds, not App Store distribution artifacts.
   - Severity: High before release.
   - Evidence: dev/staging/prod Profile artifacts include `get-task-allow = true`, `aps-environment = development`, and App Attest environment `development`.
   - Next fix: configure App Store/TestFlight distribution signing, export a production-signed IPA, and verify the exported entitlements switch to production distribution semantics.

4. Native environment identity is now aligned for development signing; Firebase/App Check release enforcement still needs follow-through.
   - Severity: Medium until Firebase capability checks are complete.
   - Meaning: Android, iOS, and macOS now have `dev`, `staging`, and `prod` native flavors/schemes. iOS dev builds use `com.catchdates.app.dev`; staging builds use `com.catchdates.app.staging`; prod builds use `com.catchdates.app`.
   - Verification: signed iOS dev/staging/prod Profile artifacts embed matching bundle IDs, Firebase plists, APNs entitlement, and App Attest entitlement.
   - Next fix: verify Firebase App Check registrations for each exact iOS Firebase app ID before enabling enforcement.

5. Physical iPhone Profile launch is not fully clean yet.
   - Severity: Medium.
   - Evidence: the latest dev Profile run on the physical iPhone built, installed/launched, and exposed the Dart VM Service/DevTools URL. It then logged Firebase App Check API `SERVICE_DISABLED` for `catchdates-dev` and stopped in FirebaseAuth iOS `PhoneAuthProvider.verifyPhoneNumber` during phone verification.
   - Next fix: enable Firebase App Check API for the dev/staging/prod projects, register the local dev-device App Check debug token, verify APNs auth-key setup on the dev/staging iOS Firebase apps, then rerun phone auth on the physical iPhone.

6. iOS Debug physical run hit native `EXC_BAD_ACCESS` in Flutter embedder/debug tooling.
   - Severity: Low for release, Medium for local debugging.
   - Evidence: direct untethered Debug launch produced Flutter's expected "Cannot create a FlutterEngine instance in debug mode without Flutter tooling or Xcode" message and a crash with `-[VSyncClient initWithTaskRunner:callback:]`.
   - Interpretation: Current evidence points to Flutter Debug launch/tooling behavior, not app Dart/Firebase/Razorpay code. Related upstream issue: https://github.com/flutter/flutter/issues/168582.

### Push notifications, Cloud Messaging, and App Check

1. iOS Push is configured for development, but production push still needs release validation.
   - Current good state: Firebase Cloud Messaging APNs auth keys are uploaded for the inspected/original project's `com.catchdates.app` Firebase iOS app, the iOS target declares the App Attest entitlement, `UIBackgroundModes` includes `remote-notification`, and debug/development signing has previously produced `aps-environment = development`.
   - Remaining release work: the Apple Developer App ID `com.catchdates.app` is registered with Push Notifications and App Attest. Dev/test builds still require matching `com.catchdates.app.dev` and `com.catchdates.app.staging` App IDs/profiles if we keep separate installs, and all changed profiles need to be regenerated/refreshed before real-device push validation.

2. Web Push is configured for dev only.
   - Severity: Low if web is only a debugging target; Medium if web notifications are expected in staging/prod.
   - Current state: Firebase has a Web Push certificate key pair and `tool/dart_defines/dev.json` contains the public VAPID key. Staging/prod remain blank because those Firebase environments are not real yet.
   - Next fix: when staging/prod Firebase projects exist, create/import matching Web Push key pairs and pass the public VAPID keys through the matching environment dart-define files.

3. Firebase App Check is configured but not ready for enforcement.
   - Current good state: app code initializes App Check, Android App Check registration exists for the configured native app, and `ios/Runner/Runner.entitlements` declares `com.apple.developer.devicecheck.appattest-environment = development`.
   - Remaining work: verify Firebase App Check and Apple App Attest for the exact iOS bundle IDs we keep, register web App Check with reCAPTCHA Enterprise if web remains supported, roll out App Check debug tokens for local testing, then enable enforcement gradually for Firestore/Storage/Auth/Functions after token telemetry looks healthy.

4. macOS push is intentionally disabled.
   - Severity: Low for current product direction.
   - Current state: macOS is a debugging target, and push registration is disabled on macOS to avoid requiring macOS APNs provisioning.
   - Next fix only if needed: create a real macOS App ID, add APNs entitlement/profile, and re-enable macOS push code paths.

### Android toolchain and release signing

1. Android release signing is configured locally and release builds pass.
   - Severity: High before Play Store release.
   - Current state: `android/keystore/upload-keystore.jks` and `android/key.properties` exist locally, are ignored by git, and sign the prod release APK/App Bundle. The upload-key password is also stored in the macOS Keychain under service `catch-dating-app.android-upload-keystore`.
   - Next fix: back up the keystore securely, enroll the app in Play App Signing, then add the Play app-signing certificate fingerprints to Firebase after Play generates or accepts the app-signing key.

2. Android App Check Play Integrity still needs final Play app-signing fingerprints before enforcement.
   - Severity: High before enforcing App Check.
   - Meaning: the upload-key SHA-1/SHA-256 fingerprints are now registered on the dev, staging, and production Firebase Android apps, but Play-distributed installs are signed by the Play app-signing certificate, not the upload key.

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
   - Current evidence: dev, staging, and prod macOS builds pass and embed the expected flavor Firebase plists. Release-prod uses `Runner/Release.entitlements` and does not declare debug-only entitlements in source, but the built local app is development-signed and includes `get-task-allow=true` because it is signed with Apple Development rather than a distribution identity.
   - If distribution is desired later, add macOS distribution signing, hardened runtime, notarization, an APNs decision, and final Firebase macOS config validation.

3. macOS strict code-sign verification reports `CSSMERR_TP_NOT_TRUSTED`.
   - Severity: Low while macOS is debug-only; Medium if macOS distribution becomes real.
   - Evidence: `codesign --verify --deep --strict --verbose=4 build/macos/Build/Products/Release-prod/Catch.app` reports `CSSMERR_TP_NOT_TRUSTED`.
   - Next fix: resolve the local certificate trust chain or validate a properly distribution-signed/notarized macOS artifact if macOS ever becomes a shipped target.

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
| Added iOS App Attest entitlement and registered final production App ID | Apple Developer + `ios/Runner/Runner.entitlements` | Canonical | The app binary declares the entitlement; Apple Developer now lists `Catch` with bundle ID `com.catchdates.app`, registered after the user approved the account mutation. |
| Verified iOS APNs auth-key setup in Firebase for `com.catchdates.app` | Firebase Cloud Messaging | Canonical for inspected project | APNs auth keys are preferred over per-app APNs certificates; the inspected/original project's Firebase iOS app now has development and production rows using key ID `78HUQYZ2ZR`. Recheck the separate `catchdates-dev` project if dev keeps `com.catchdates.app.dev`. |
| Normalized versioned SDK framework paths in Podfile post-install hooks | `ios/Podfile`, `macos/Podfile` | Compatibility shim, acceptable | Works around `xcodeproj 1.27.0` generating stale versioned SDK paths under Xcode 26. Remove when CocoaPods/xcodeproj catches up. |
| Used precompiled Firestore binary pod override | `ios/Podfile`, `macos/Podfile` | Compatibility shim, acceptable | Common FlutterFire performance/build-stability workaround for Firestore's large native build graph. Monitor upstream and remove if standard pods become reliable enough. |
| Repaired partial CocoaPods installs by deleting generated Pods directories and rerunning pod install serially | `ios/Pods`, `macos/Pods` generated state | Canonical recovery | The failures came from interrupted/concurrent cache copies and a transient GitHub 502, not source code. |
| Removed stale local Razorpay core podspec override | `ios/Podfile`, deleted `ios/PodspecOverrides/razorpay-core-pod.podspec.json` | Canonical | The local override pinned `razorpay-core-pod 1.0.3`, blocking official `razorpay-pod 1.5.3` and causing iOS Swift compile failures. |
| Updated official Razorpay native pods | `ios/Podfile.lock` | Canonical | `razorpay-pod 1.5.3` + `razorpay-core-pod 1.0.6` resolves the `RazorpayEventCallback` compile failure without patching plugin cache. |
| Ran in-range Flutter/Dart dependency upgrades | `pubspec.lock` | Canonical | Kept within declared `pubspec.yaml` constraints and then verified analyzer/builds. |
| Updated Firestore test batch helper type | `test/chats/firestore_repository_test_helpers.dart` | Canonical | Required by the newer `cloud_firestore` API signature: `Map<Object, Object?>`. |
| Updated Functions runtime dependencies | `functions/package-lock.json` | Canonical | `firebase-admin@13.8.0`, `firebase-functions@7.2.5`; build/tests pass. |
| Ran `npm audit fix` without `--force` | `functions/package-lock.json` | Canonical | Accepted safe fixes only; avoided a breaking Firebase Admin downgrade. |
| Removed Android release debug-signing fallback | `android/app/build.gradle.kts` | Canonical | Release/App Bundle builds now require a real upload keystore instead of silently producing debug-signed release artifacts. |
| Generated Android upload keystore and local signing config | `android/keystore/upload-keystore.jks`, `android/key.properties`, macOS Keychain | Canonical, secret local state | The keystore and properties file are ignored by git; the password is stored in the macOS Keychain. Prod release APK/App Bundle builds now pass. |
| Registered Android upload-key SHA fingerprints in Firebase | Firebase Android apps for dev, staging, and prod | Canonical | Upload-key SHA-1 `F3:71:52:37:15:35:E0:2E:4A:F8:C6:A7:D9:E1:DA:BB:B7:AA:56:37` and SHA-256 `30:88:F7:63:A6:0F:D9:F7:CA:99:20:4D:6A:68:EF:93:A3:02:63:A6:97:E5:63:EF:88:3B:29:DB:BC:7A:E2:3E` are registered. Add Play app-signing cert fingerprints after Play enrollment. |
| Auto-selected native environment flavors for APK/App Bundle/iOS/macOS builds | `tool/flutter_with_env.sh` | Canonical | Keeps `APP_ENV`, native Firebase files, Android package IDs, and Apple bundle IDs aligned for common wrapper build commands. |
| Added IPA flavor auto-selection | `tool/flutter_with_env.sh` | Canonical | `flutter build ipa` now uses the prod scheme/configuration instead of silently archiving the unflavored Runner scheme. This fixed the blank `CFBundleDisplayName` in the archive metadata. |
| Registered dev/staging/prod Apple App IDs and refreshed Xcode-managed development profiles | Apple Developer + local Xcode profiles | Canonical | `com.catchdates.app.dev`, `com.catchdates.app.staging`, and `com.catchdates.app` now have explicit development profiles with Push and App Attest for device/Profile builds. |
| Verified Xcode account, iOS signing UI, and macOS signing UI | Xcode Settings + iOS/macOS workspaces | Canonical inspection | Xcode is signed in as `Suvrat Garg` with Admin role. iOS Runner uses automatic signing with team `2HQBK4UMUT`, Push Notifications, Background Modes, and App Attest. macOS Runner uses automatic signing, App Sandbox, network/photo-library entitlements, and no macOS push/App Attest. |
| Added iOS/macOS Firebase copy script inputs and outputs | `tool/configure_apple_flavors.rb`, iOS/macOS Xcode projects | Canonical | Xcode now understands when the copied Firebase plist is stale and no longer warns about an always-running script phase. |
| Added macOS accent color asset | `macos/Runner/Assets.xcassets/AccentColor.colorset/Contents.json` | Canonical | The macOS target references `AccentColor`; adding the colorset removes the asset-catalog warning without changing generated dependency code. |

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

1. Complete iOS App Store distribution signing: sign into the Apple Developer portal in Chrome or otherwise create/import an Apple Distribution identity with private key, create/fetch an App Store profile for `com.catchdates.app`, then rerun `./tool/flutter_with_env.sh prod build ipa --release`.
2. Resolve `CSSMERR_TP_NOT_TRUSTED` or prove it harmless by verifying the final exported IPA with distribution signing.
3. Validate physical iPhone Profile/Release run from Xcode or `flutter run -v --profile`, including UI startup and logs.
4. Verify Firebase App Check registrations for the exact dev/staging/prod iOS app IDs before enabling enforcement.
5. Enroll Android in Play App Signing, back up the upload keystore securely, and add Play app-signing certificate fingerprints to Firebase after Play enrollment.
6. Decide whether web is debug-only. Dev Web Push is configured; Web App Check and future staging/prod Web Push still need environment-specific setup.
7. Enable Firebase App Check enforcement gradually after debug/prod tokens are confirmed.
8. Schedule dependency major-version migrations separately from release signing.
