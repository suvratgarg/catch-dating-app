# Current Release Setup Audit - 2026-04-30

Scope:
- Revalidate the current dirty worktree after recent Firebase/Auth/signing changes.
- Capture verbose logs under `codex_audit/release_setup_2026-04-30/logs/`.
- Build and, where available, run the app across web, Android, iOS, and macOS.
- Inspect platform-specific setup for release-readiness and noncanonical configuration.
- Merge the active release/config findings from the edited markdown trackers into
  one current source of truth.

## Single Source Of Truth Snapshot - 2026-05-01

This file is the canonical release setup snapshot for local build, signing,
distribution, Firebase, Firestore, App Check, Apple account, Xcode toolchain,
Gradle/JDK, and trust-chain status. It supersedes older blocker language in:

- `codex_audit/production_release_checklist.md`
- `codex_audit/firebase_environment_current_state.md`
- `codex_audit/firebase_console_audit.md`
- `codex_audit/ios_release_readiness_audit_2026-04-30.md`
- `codex_audit/build_readiness_dependency_report_2026-04-29.md`
- `codex_audit/remaining_config_resolution_tracker_2026-04-29.md`
- `codex_audit/target_build_audit_2026-04-28.md`
- `TESTS.md`
- `codex_audit/lib_feature_completeness_matrix.md`

Verdict: from a setup/build/signing/distribution/config standpoint, the app is
ready to return to feature completeness and business-logic work. There is no
known local build, Firebase, Firestore, App Check, Gradle, Xcode, Apple signing,
Developer ID, notarization, or trust-chain blocker remaining in the current
workspace.

Still outside this setup verdict:

- Android physical-device smoke testing remains hardware-gated because no
  Android phone is connected or authorized.
- macOS phone-auth runtime behavior is intentionally deferred; Firebase Auth
  `verifyPhoneNumber()` is unavailable on macOS and should be guarded/replaced
  if macOS becomes a real auth surface.
- TestFlight, Play internal testing, final store metadata, privacy/data-safety
  forms, screenshots, legal/support URLs, and production Crashlytics/analytics
  dashboard validation are release-management/product tasks, not current local
  setup blockers.
- Play app-signing certificate fingerprints still need to be added to Firebase
  after Play Console enrollment; the local upload-key fingerprints are already
  registered and sufficient for the locally signed AAB/APK verified here.
- Mac App Store distribution has not been validated. Direct Developer ID
  distribution is validated.

## Current Status

- [x] Created audit tracker and log folder.
- [x] Captured initial dirty worktree summary.
- [x] Captured toolchain, device, signing, and license state.
- [x] Ran static analysis/tests relevant to config health.
- [x] Built web target.
- [x] Built Android release/profile targets and verified release signing.
- [x] Built iOS no-codesign, signed profile, and App Store IPA targets.
- [x] Built macOS release target and verified signing state.
- [x] Ran available runtime targets and captured startup logs.
- [x] Reviewed platform/Firebase config files manually.
- [x] Summarized warnings, blockers, and release readiness.
- [x] Verified Firebase App Check provider configs and enforcement through REST APIs.
- [x] Renamed misleading Firebase app registration display names.
- [x] Rechecked physical Android availability.
- [x] Rechecked macOS Developer ID/notarization readiness.
- [x] Created and installed a Developer ID Application identity for macOS direct distribution.
- [x] Rebuilt macOS `Release-prod` with Developer ID signing.
- [x] Stored Apple notarization credentials, submitted the signed macOS app, stapled the ticket, and re-ran Gatekeeper.
- [x] Raised the macOS deployment target to 11.0 after Xcode 26 recommended it.
- [x] Rebuilt, re-notarized, stapled, and Gatekeeper-validated the macOS 11 Developer ID artifact.
- [x] Merged current release/setup findings from the edited markdown trackers into this snapshot.

## Initial Dirty Worktree

Observed before this pass:
- Active Firebase native/web configs are currently switched from dev to production.
- `lib/main.dart` now uses debug App Check providers only for Flutter debug mode or emulator mode.
- `tool/dart_defines/{dev,staging,prod}.json` now include reCAPTCHA Enterprise site keys.
- Several Functions source files have small auth/assertion-related edits.

## Command Log

Rows are chronological. Earlier `blocked`, `rejected`, or `invalid` rows are
closed if a later row records the successful fix; the current verdict and
warnings sections below are authoritative.

| Time IST | Command | Result | Notes |
| --- | --- | --- | --- |
| 2026-04-30 | `git status --short`, `git diff --stat`, targeted config diffs | pass | Dirty tree predates this audit. This pass later changed Firestore rules/tests, the env wrapper, and macOS prod signing settings. |
| 2026-04-30 | `flutter doctor -v` | pass | Flutter 3.41.2, Dart 3.11.0, Xcode 26.4.1, CocoaPods 1.16.2, Android licenses accepted. |
| 2026-04-30 | `flutter devices -v` | pass | Physical iPhone, macOS, and Chrome are connected. No Android device is currently connected. |
| 2026-04-30 | `security find-identity -v -p codesigning` | pass | One Apple Development identity and one Apple Distribution identity are available. |
| 2026-04-30 | `flutter analyze` | pass | No issues found. |
| 2026-04-30 | `npm run build` in `functions/` | pass | TypeScript build succeeds with current Functions edits. |
| 2026-04-30 | `xcodebuild -workspace ios/Runner.xcworkspace -scheme prod -configuration Release-prod -showBuildSettings` | pass | Prod iOS resolves to `com.catchdates.app`, team `2HQBK4UMUT`, APNs/App Attest production, deployment target 15.0. |
| 2026-04-30 | `xcodebuild -workspace macos/Runner.xcworkspace -scheme prod -configuration Release-prod -showBuildSettings` | pass with finding | Prod macOS resolves to `com.catchdates.app`; `ENABLE_HARDENED_RUNTIME = NO`. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build web -v` | pass with warnings | Built `build/web`; warnings are Flutter wasm dry-run, icon tree-shaking/system IconData hints, and a Flutter SDK dart2js size hint. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build appbundle -v` | pass with warnings | Built fresh signed flavored AAB at `build/app/outputs/bundle/prodRelease/app-prod-release.aab`; Flutter's final summary pointed at stale generic `build/app/outputs/bundle/release/app-release.aab`. Warnings include upstream Firebase Auth R8 invalid generic-signature info and an `apkanalyzer` shell integer-expression warning after output listing. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build apk --release -v` | pass with warnings | Built signed `build/app/outputs/flutter-apk/app-prod-release.apk`; warnings include upstream Firebase Auth R8 invalid generic-signature info and Gradle 9 deprecation notice. |
| 2026-04-30 | `apksigner verify --print-certs app-prod-release.apk` | pass | APK signer is `CN=Catch, OU=Mobile, O=Catch Dates, L=Mumbai, ST=Maharashtra, C=IN`, SHA-256 `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e`. |
| 2026-04-30 | `jarsigner -verify app-prod-release.aab` | pass with warning | Fresh flavored AAB at `build/app/outputs/bundle/prodRelease/app-prod-release.aab` is signed by Catch upload cert. Stale generic AAB at `build/app/outputs/bundle/release/app-release.aab` is debug-signed from Apr 29. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build ios --no-codesign -v` | pass with expected warning | Built `build/ios/iphoneos/Runner.app` at 53.1MB. Warning is expected: code signing disabled. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build ios --profile -v` | pass with warnings | Built signed `build/ios/iphoneos/Runner.app` at 62.8MB. Profile uses bundle `com.catchdates.app`, APNs development, App Attest production, Xcode-managed profile `iOS Team Provisioning Profile: com.catchdates.app`. |
| 2026-04-30 | `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` | warning | Still reports `CSSMERR_TP_NOT_TRUSTED`. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist -v` | pass | Export succeeded; `build/ios/ipa/Catch.ipa` is App Store signed with production APNs/App Attest and `get-task-allow=false`. |
| 2026-04-30 | IPA payload inspection | pass with local trust warning | Bundle id, version, Firebase plist, profile, and entitlements are production-correct. Strict local `codesign --verify` still reports `CSSMERR_TP_NOT_TRUSTED`. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build macos -v` | pass with release-signing findings | Built `build/macos/Build/Products/Release-prod/Catch.app` at 116.6MB. The app is Apple Development signed, has `get-task-allow=true`, and hardened runtime is off. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod run -d chrome -v` | pass with warning | Chrome launched and exposed a Dart VM service. Warning: Flutter could not clean up one temp directory after the run was killed. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod run -d macos --flavor prod -v` | pass with runtime finding | Debug-prod macOS launched and exposed a Dart VM service. Submitting phone auth on macOS throws `verifyPhoneNumber() is not available on MacOS platforms`. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod run --profile -d 00008120-001A152E3EEB401E --flavor prod -v` | pass with device warning | Physical iPhone profile build launched and exposed a Dart VM service after an initial locked-device launch failure. |
| 2026-04-30 | Android emulator startup and `./tool/flutter_with_env.sh prod run --profile -d emulator-5554 --flavor prod -v` | pass with runtime findings | Android profile build installed and exposed a Dart VM service. Runtime logs repeatedly show Firestore `PERMISSION_DENIED` for `config/app_config`. |
| 2026-04-30 | `firebase apps:list --project catch-dating-app-64e51` | pass with naming finding | Prod project has Android/iOS app IDs matching the checked-in prod config, but their display names are `Catch dev Android` and `Catch dev iOS`; duplicate older Android/iOS apps also exist. |
| 2026-04-30 | `firebase apps:android:sha:list 1:574779808785:android:81edbfa0d4aba7c48ea5b0 --project catch-dating-app-64e51` | pass | Firebase has the release upload SHA-1 `f37152371535e02e4af8c6a7d9e1dabbb7aa5637` and SHA-256 `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e` registered, plus additional debug/profile hashes. |
| 2026-04-30 | `firebase appcheck:apps:list --project catch-dating-app-64e51` | unavailable | This installed Firebase CLI does not include an App Check list command, so App Check registrations/enforcement still need Firebase Console verification. |
| 2026-04-30 | `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"` | pass | Added and passed regression coverage for public unauthenticated read of `config/app_config` and denied reads of other config docs. Expected `PERMISSION_DENIED` log lines come from `assertFails` cases. |
| 2026-04-30 | `firebase deploy --only firestore:rules --project catch-dating-app-64e51` | pass | Released the force-update config rule fix to production Firestore. |
| 2026-04-30 | `./gradlew -version` before/after `~/.gradle/gradle.properties` | pass | Gradle daemon now uses Android Studio JBR 21 via `org.gradle.java.home`; shell launcher remains Homebrew Java 23. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod run -d emulator-5554 --profile -v` after rules deploy | pass with emulator warnings | No `PERMISSION_DENIED` / `[cloud_firestore/permission-denied]` remained for `config/app_config`; emulator later logged Firestore offline timeout despite valid emulator network connectivity. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build macos -v` after signing fixes | pass with distribution-note | `Release-prod` now signs with Apple Distribution, hardened runtime on, no `get-task-allow`, and strict `codesign` passes outside the sandbox. `spctl` still rejects because this is not Developer ID/notarized direct distribution. |
| 2026-04-30 | Fresh `flutter analyze`, Functions build, rules tests | pass | `flutter analyze` no issues; `npm --prefix functions run build` passed; rules tests passed 12/12. |
| 2026-04-30 | Fresh web, Android AAB, iOS no-codesign, iOS IPA, macOS release builds | pass | Current artifacts: `build/web`, `build/app/outputs/bundle/prodRelease/app-prod-release.aab`, `build/ios/iphoneos/Runner.app`, `build/ios/ipa/Catch.ipa`, and `build/macos/Build/Products/Release-prod/Catch.app`. |
| 2026-04-30 | Firebase App Check REST with `GOOGLE_CLOUD_QUOTA_PROJECT=catch-dating-app-64e51` | pass | App Check services list succeeds only when the quota project is set to the target Firebase project. Firestore, Storage, and Firebase Auth are `ENFORCED`. |
| 2026-04-30 | App Check provider config reads | pass | Active Android app has Play Integrity config, active iOS app has App Attest and DeviceCheck configs, and active web app has reCAPTCHA Enterprise and reCAPTCHA v3 configs. |
| 2026-04-30 | Firebase Management REST `patch` for app display names | pass | Renamed active apps to `Catch Prod Android`, `Catch Prod iOS`, and `Catch Prod Web`; renamed old example registrations to `Legacy Android Example` and `Legacy iOS Example`; renamed the Windows web registration to `Catch Windows Web`. |
| 2026-04-30 | `firebase apps:list --project catch-dating-app-64e51` after rename | pass | Verified all Firebase app display-name changes. |
| 2026-04-30 | `firebase apps:android:sha:list 1:574779808785:android:81edbfa0d4aba7c48ea5b0 --project catch-dating-app-64e51` after App Check verification | pass | Active Android app has release upload SHA-256 `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e` registered. |
| 2026-04-30 | `flutter devices` and `adb devices -l` for physical Android | blocked by hardware | No Android device is connected or authorized. Flutter sees macOS, Chrome, and the wireless iPhone only; `adb` lists no devices. |
| 2026-04-30 | `security find-identity -v -p codesigning` for Developer ID | blocked by missing cert | Keychain contains Apple Development and Apple Distribution identities, but no `Developer ID Application` identity. |
| 2026-04-30 | `codesign -dvvv --entitlements :- build/macos/Build/Products/Release-prod/Catch.app` | pass with direct-distribution blocker | Artifact is hardened and signed by `Apple Distribution: Suvrat Garg (2HQBK4UMUT)` with sandbox/network/photo-library entitlements. This is not a Developer ID signature. |
| 2026-04-30 | `codesign --verify --deep --strict --verbose=4 build/macos/Build/Products/Release-prod/Catch.app` | pass | Nested macOS signatures are valid on disk and satisfy designated requirements outside the sandbox. |
| 2026-04-30 | `spctl -a -vv build/macos/Build/Products/Release-prod/Catch.app` | rejected | Gatekeeper rejects direct distribution because the app is Apple Distribution signed and not Developer ID notarized. |
| 2026-04-30 | Apple Developer Certificates portal + CSR upload | pass | Created `Developer ID Application: Suvrat Garg (2HQBK4UMUT)` certificate ID `9F4RHRFUCP` under the G2 Developer ID CA. Certificate expires 2031-05-01 GMT. |
| 2026-04-30 | `security import` / `security add-certificates` / `security find-identity -v -p codesigning` | pass | Imported the Developer ID private key and certificate into the login keychain. Identity hash is `25FEE4C256BB3CB564D3F7A0356AAFBA974FE73C`. |
| 2026-04-30 | `./tool/flutter_with_env.sh prod build macos -v` after Developer ID switch | pass | Built `build/macos/Build/Products/Release-prod/Catch.app` at 116.4MB with `CODE_SIGN_IDENTITY = Developer ID Application`. |
| 2026-04-30 | `codesign -dvvv --entitlements :- build/macos/Build/Products/Release-prod/Catch.app` after Developer ID switch | pass with minor tool warning | Signature authority is `Developer ID Application: Suvrat Garg (2HQBK4UMUT)`, Team ID `2HQBK4UMUT`, hardened runtime flag is set, and entitlements are sandbox, network client, and photos-library. The only warning was Apple's deprecation warning for `--entitlements :-` output syntax. |
| 2026-04-30 | `codesign --verify --deep --strict --verbose=4 build/macos/Build/Products/Release-prod/Catch.app` after Developer ID switch | pass | Nested macOS signatures are valid on disk and satisfy designated requirements outside the sandbox. |
| 2026-04-30 | `spctl -a -vv --type execute build/macos/Build/Products/Release-prod/Catch.app` after Developer ID switch | rejected as expected before notarization | Gatekeeper now reports `source=Unnotarized Developer ID` with origin `Developer ID Application: Suvrat Garg (2HQBK4UMUT)`. This is the expected remaining state before notarization and stapling. |
| 2026-04-30 | `ditto -c -k --keepParent build/macos/Build/Products/Release-prod/Catch.app /private/tmp/catch-developer-id-cert/Catch-DeveloperID.zip` | pass | Created a 38MB notarization upload zip. |
| 2026-04-30 | `xcrun notarytool history --keychain-profile CatchNotary --team-id 2HQBK4UMUT` | blocked by missing credential profile | No `CatchNotary` keychain profile exists yet. A visible Terminal command was opened so the Apple app-specific password can be entered without exposing it in chat/logs. |
| 2026-04-30 | Temporary Developer ID key cleanup | pass | Removed the loose temporary private key and CSR copies after proving the keychain identity with a successful Developer ID build. The notarization zip remains at `/private/tmp/catch-developer-id-cert/Catch-DeveloperID.zip`. |
| 2026-04-30 | Hidden-dialog `notarytool store-credentials CatchNotary` attempt | blocked by Apple credential rejection | The password prompt path works, but Apple returned HTTP 401 invalid credentials. A fresh app-specific password for `suvratgarg2007@gmail.com` is needed before notarization can proceed. |
| 2026-05-01 | Hidden-dialog `notarytool store-credentials CatchNotary` retry | pass | Fresh Apple app-specific password validated successfully and `CatchNotary` was saved to the login keychain. |
| 2026-05-01 | `xcrun notarytool submit /private/tmp/catch-developer-id-cert/Catch-DeveloperID.zip --keychain-profile CatchNotary --team-id 2HQBK4UMUT --wait` | invalid | Apple rejected the first Developer ID submission because the main executable signature did not include a secure timestamp. Submission ID: `f2593b0b-0657-4857-9761-540f6f6e60cc`. |
| 2026-05-01 | `./tool/flutter_with_env.sh prod build macos -v` after adding `OTHER_CODE_SIGN_FLAGS = "--timestamp"` | pass | Rebuilt `build/macos/Build/Products/Release-prod/Catch.app` at 116.5MB. Xcode invoked `codesign --timestamp -o runtime` for the app bundle. |
| 2026-05-01 | `codesign -dvvv --entitlements :- build/macos/Build/Products/Release-prod/Catch.app` after timestamp fix | pass with minor tool warning | Signature now includes `Timestamp=1 May 2026 at 12:34:30 AM`, Developer ID authority, hardened runtime, Team ID `2HQBK4UMUT`, and expected sandbox/network/photos entitlements. |
| 2026-05-01 | `xcrun notarytool submit /private/tmp/catch-developer-id-cert/Catch-DeveloperID-timestamped.zip --keychain-profile CatchNotary --team-id 2HQBK4UMUT --wait` | pass | Apple accepted notarization submission `34d104cc-eae7-4e87-af80-918eb092281d`. |
| 2026-05-01 | `xcrun stapler staple build/macos/Build/Products/Release-prod/Catch.app` and `xcrun stapler validate ...` | pass | Notarization ticket stapled and validated successfully. |
| 2026-05-01 | `spctl -a -vv --type execute build/macos/Build/Products/Release-prod/Catch.app` | pass | Gatekeeper accepts the app: `source=Notarized Developer ID`, origin `Developer ID Application: Suvrat Garg (2HQBK4UMUT)`. |
| 2026-05-01 | `ditto -c -k --keepParent build/macos/Build/Products/Release-prod/Catch.app build/macos/Build/Products/Release-prod/Catch-notarized.zip` | pass | Created the final stapled direct-distribution archive at `build/macos/Build/Products/Release-prod/Catch-notarized.zip`. |
| 2026-05-01 | `pod install` in `macos/` after raising deployment target | pass with known noise | `macos/Podfile` and the macOS Xcode project now use deployment target 11.0. CocoaPods still prints Flutter-generated `DART_DEFINES` parsing noise, but installation succeeds. |
| 2026-05-01 | `./tool/flutter_with_env.sh prod build macos -v` after macOS 11 target | pass with expected warning | Built `build/macos/Build/Products/Release-prod/Catch.app` at 116.3MB. Xcode compiled both architectures for `macos11.0`; App Intents metadata extraction was skipped because the app has no AppIntents dependency. |
| 2026-05-01 | `codesign -dvvv --entitlements :-`, `codesign --verify --deep --strict --verbose=4`, `plutil -p`, `xcrun vtool -show-build` against the macOS 11 app | pass with minor tool warning | Developer ID authority, secure timestamp, hardened runtime, sandbox/network/photos entitlements, deep nested signature validation, `LSMinimumSystemVersion = 11.0`, and Mach-O `minos 11.0` for arm64/x86_64 all verified. Apple's only warning was the `--entitlements :-` syntax deprecation. |
| 2026-05-01 | `xcrun notarytool submit /private/tmp/catch-developer-id-cert/Catch-DeveloperID-macos11.zip --keychain-profile CatchNotary --team-id 2HQBK4UMUT --wait` | pass | Fresh macOS 11 Developer ID package accepted. Submission ID: `c4de9b40-162a-46d9-a2b8-6899f364a824`. |
| 2026-05-01 | `xcrun stapler staple`, `xcrun stapler validate`, `spctl -a -vv --type execute`, and final `ditto` after the macOS 11 notarization | pass | Staple and validation succeeded; Gatekeeper reports `accepted`, `source=Notarized Developer ID`, origin `Developer ID Application: Suvrat Garg (2HQBK4UMUT)`. Final archive is `build/macos/Build/Products/Release-prod/Catch-notarized.zip`, 37MB, SHA-256 `21f517bfbcde9d62cdf0a7370e184942e82aa5b77a742b544f6fe04388ca497c`. |

## Findings So Far

- `android/key.properties` and `android/keystore/upload-keystore.jks` are ignored by git and not tracked.
- Tracked active Firebase files are production copies right now: Android/iOS/macOS/web all point at `catch-dating-app-64e51` / `com.catchdates.app`.
- App Check behavior changed materially: non-debug dev/staging/prod builds now require native App Check providers to be registered and healthy.
- macOS Release-prod now uses Developer ID Application signing, hardened runtime, and no `get-task-allow`; strict `codesign` passes when run outside the Codex sandbox.
- Direct Gradle now runs its daemon on Android Studio JBR 21 through `~/.gradle/gradle.properties`; the shell Java launcher still reports Homebrew JDK 23.
- Android release upload artifact is `build/app/outputs/bundle/prodRelease/app-prod-release.aab`; stale debug-signed `build/app/outputs/bundle/release/app-release.aab` was removed.
- Local Apple strict codesign failures inside the Codex sandbox were false positives caused by restricted keychain/trust access; outside the sandbox, signed iOS and macOS payloads verify.
- Firebase prod Android upload SHA-1/SHA-256 are registered for the active Android app ID.
- Firebase App Check is configured for active production app IDs and enforced for Firestore, Storage, and Firebase Auth.
- Firebase app display names are now environment-correct: active production registrations are `Catch Prod Android`, `Catch Prod iOS`, and `Catch Prod Web`; legacy example registrations are explicitly labeled as legacy.
- Physical Android runtime verification is still blocked because no Android device is connected or authorized.
- Direct macOS distribution signing is now complete: Developer ID identity is installed, the app is timestamped, notarized, stapled, and accepted by Gatekeeper.
- macOS deployment target is now 11.0 across `macos/Podfile` and the macOS Xcode project. The built app reports `LSMinimumSystemVersion = 11.0` and Mach-O `minos 11.0`.

## Build Matrix

| Target | Build | Result | Release notes |
| --- | --- | --- | --- |
| Web | `prod build web -v` | Pass | Built `build/web`. Flutter suggested a wasm dry run; not a blocker. |
| Android AAB | `prod build appbundle -v` | Pass | Fresh artifact is `build/app/outputs/bundle/prodRelease/app-prod-release.aab`; it is signed by the Catch upload key. |
| Android APK | `prod build apk --release -v` | Pass | `apksigner verify` passes for `build/app/outputs/flutter-apk/app-prod-release.apk`; signer SHA-256 is `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e`. |
| iOS no-codesign | `prod build ios --no-codesign -v` | Pass | Expected no-codesign warning only. Bundle/Firebase plist are prod. |
| iOS profile | `prod build ios --profile -v` | Pass with characterized trust noise | Xcode-managed development provisioning profile, APNs development, App Attest production. Earlier sandboxed strict codesign checks reported `CSSMERR_TP_NOT_TRUSTED`; outside-sandbox checks characterized that as local trust/keychain noise, not a current release blocker. |
| iOS App Store IPA | `prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist -v` | Pass | `build/ios/ipa/Catch.ipa` exports successfully. IPA payload has production APNs/App Attest and `get-task-allow=false`; earlier sandbox trust output is classified as local trust/keychain noise rather than an export blocker. |
| macOS release | `prod build macos -v` | Pass | Current `Release-prod` targets macOS 11.0, is Developer ID signed, timestamped, notarized, stapled, and accepted by Gatekeeper. Final archive: `build/macos/Build/Products/Release-prod/Catch-notarized.zip`. |

## Runtime Matrix

| Target | Runtime command | Result | Notes |
| --- | --- | --- | --- |
| Chrome/web | `prod run -d chrome -v` | Pass | Dart VM service available. No Firebase permission-denied error appeared in Flutter's captured log. |
| macOS | `prod run -d macos --flavor prod -v` | Pass with app-platform finding | Debug-prod app launched. Log printed an App Check debug token because this was a debug run. Phone verification is unsupported on macOS and throws if submitted. |
| iOS physical | `prod run --profile -d 00008120-001A152E3EEB401E --flavor prod -v` | Pass with device warning | First launch attempt failed while the device was locked; later launched and exposed a Dart VM service. |
| Android emulator | `prod run --profile -d emulator-5554 --flavor prod -v` | Pass with emulator/backend warning | App installed and Dart VM service was available. After rules deployment, the old `config/app_config` permission denial disappeared; remaining warnings are Play-services emulator noise and a Firestore offline timeout. |
| Android physical | `flutter devices`; `adb devices -l` | Blocked by hardware | No Android phone is connected or authorized, so a real-device Android run could not be executed in this pass. |

## Warnings And Findings To Resolve

Current setup blockers:
- None for local iOS App Store IPA export or Android Play upload AAB creation.
- None for direct macOS Developer ID signing/notarization distribution.
- Android physical-device smoke testing remains hardware-gated until an Android
  phone is connected with USB debugging authorized.

Important cleanup / console work:
- Recheck Android runtime on a real Android device before Play release. The emulator produced Google Play services `DEVELOPER_ERROR` / `Unknown calling package name 'com.google.android.gms'` noise and a Firestore offline timeout, while basic emulator DNS/IP connectivity was valid and the original rules denial was gone.
- If macOS remains a supported runtime target, guard or replace phone auth there. Firebase Auth `verifyPhoneNumber()` is not available on macOS.
- Play app-signing certificate fingerprints still need to be registered in Firebase after Play Console enrollment. The local upload-key SHA-1/SHA-256 are already registered for the currently verified upload AAB/APK.
- TestFlight upload/install, Play internal testing, Crashlytics/Analytics dashboard proof, store privacy/legal forms, screenshots, and app-review metadata remain product/release-management work.

Non-blocking warning noise:
- Web build: Flutter wasm dry-run suggestion and Flutter web build-size hints.
- Android build: Firebase Auth R8 invalid generic-signature info, `apkanalyzer` shell `integer expression expected`, and self-signed upload-key warnings from `jarsigner` that are normal for Android upload keys.
- iOS/macOS Xcode builds: duplicate library linker warning (`-lc++`, `-lsqlite3`, `-lz`), App Intents metadata skipped because no AppIntents dependency, and some plugin/Xcode metadata warnings.
- Firestore rules tests intentionally print `PERMISSION_DENIED` from negative `assertFails` cases.
- Emulator startup: Qt signal warnings and emulator gRPC token-auth warnings; not app blockers.

## Release Readiness Verdict

Android and iOS are release-ready from a local configuration/build/signing standpoint after this pass, with one remaining hardware-gated Android real-device smoke run. Firebase App Check provider configs and enforcement are now verified for the active production registrations. The current upload artifacts are:
- Android Play upload: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`, signed by the Catch upload key with SHA-256 `30:88:F7:63:A6:0F:D9:F7:CA:99:20:4D:6A:68:EF:93:A3:02:63:A6:97:E5:63:EF:88:3B:29:DB:BC:7A:E2:3E`.
- iOS App Store Connect: `build/ios/ipa/Catch.ipa`, App Store exported with `com.catchdates.app`, production APNs/App Attest, and `get-task-allow=false`.

macOS is now ready from a direct outside-App-Store distribution signing/notarization standpoint. `build/macos/Build/Products/Release-prod/Catch.app` targets macOS 11.0, is Developer ID signed, timestamped, notarized, stapled, and accepted by Gatekeeper; the zipped distributable is `build/macos/Build/Products/Release-prod/Catch-notarized.zip`. Mac App Store distribution would still need its own archive/export validation path.
