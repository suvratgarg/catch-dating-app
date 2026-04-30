# Current Release Setup Audit - 2026-04-30

Scope:
- Revalidate the current dirty worktree after recent Firebase/Auth/signing changes.
- Capture verbose logs under `codex_audit/release_setup_2026-04-30/logs/`.
- Build and, where available, run the app across web, Android, iOS, and macOS.
- Inspect platform-specific setup for release-readiness and noncanonical configuration.

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

## Initial Dirty Worktree

Observed before this pass:
- Active Firebase native/web configs are currently switched from dev to production.
- `lib/main.dart` now uses debug App Check providers only for Flutter debug mode or emulator mode.
- `tool/dart_defines/{dev,staging,prod}.json` now include reCAPTCHA Enterprise site keys.
- Several Functions source files have small auth/assertion-related edits.

## Command Log

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

## Findings So Far

- `android/key.properties` and `android/keystore/upload-keystore.jks` are ignored by git and not tracked.
- Tracked active Firebase files are production copies right now: Android/iOS/macOS/web all point at `catch-dating-app-64e51` / `com.catchdates.app`.
- App Check behavior changed materially: non-debug dev/staging/prod builds now require native App Check providers to be registered and healthy.
- macOS Release-prod now uses Apple Distribution signing, hardened runtime, and no `get-task-allow`; strict `codesign` passes when run outside the Codex sandbox.
- Direct Gradle now runs its daemon on Android Studio JBR 21 through `~/.gradle/gradle.properties`; the shell Java launcher still reports Homebrew JDK 23.
- Android release upload artifact is `build/app/outputs/bundle/prodRelease/app-prod-release.aab`; stale debug-signed `build/app/outputs/bundle/release/app-release.aab` was removed.
- Local Apple strict codesign failures inside the Codex sandbox were false positives caused by restricted keychain/trust access; outside the sandbox, signed iOS and macOS payloads verify.
- Firebase prod Android upload SHA-1/SHA-256 are registered for the active Android app ID.
- Firebase app display names are misleading: the active prod Android/iOS app IDs are named `Catch dev Android` and `Catch dev iOS` in the Firebase project.

## Build Matrix

| Target | Build | Result | Release notes |
| --- | --- | --- | --- |
| Web | `prod build web -v` | Pass | Built `build/web`. Flutter suggested a wasm dry run; not a blocker. |
| Android AAB | `prod build appbundle -v` | Pass | Fresh artifact is `build/app/outputs/bundle/prodRelease/app-prod-release.aab`; it is signed by the Catch upload key. |
| Android APK | `prod build apk --release -v` | Pass | `apksigner verify` passes for `build/app/outputs/flutter-apk/app-prod-release.apk`; signer SHA-256 is `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e`. |
| iOS no-codesign | `prod build ios --no-codesign -v` | Pass | Expected no-codesign warning only. Bundle/Firebase plist are prod. |
| iOS profile | `prod build ios --profile -v` | Pass with trust warning | Xcode-managed development provisioning profile, APNs development, App Attest production. Strict local codesign trust fails with `CSSMERR_TP_NOT_TRUSTED`. |
| iOS App Store IPA | `prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist -v` | Pass with trust warning | `build/ios/ipa/Catch.ipa` exports successfully. IPA payload has production APNs/App Attest and `get-task-allow=false`; strict local trust still reports `CSSMERR_TP_NOT_TRUSTED`. |
| macOS release | `prod build macos -v` | Pass with distribution note | Current `Release-prod` is Apple Distribution signed with hardened runtime and no `get-task-allow`; strict `codesign` passes outside the sandbox. Direct Gatekeeper distribution still needs Developer ID/notarization. |

## Runtime Matrix

| Target | Runtime command | Result | Notes |
| --- | --- | --- | --- |
| Chrome/web | `prod run -d chrome -v` | Pass | Dart VM service available. No Firebase permission-denied error appeared in Flutter's captured log. |
| macOS | `prod run -d macos --flavor prod -v` | Pass with app-platform finding | Debug-prod app launched. Log printed an App Check debug token because this was a debug run. Phone verification is unsupported on macOS and throws if submitted. |
| iOS physical | `prod run --profile -d 00008120-001A152E3EEB401E --flavor prod -v` | Pass with device warning | First launch attempt failed while the device was locked; later launched and exposed a Dart VM service. |
| Android emulator | `prod run --profile -d emulator-5554 --flavor prod -v` | Pass with emulator/backend warning | App installed and Dart VM service was available. After rules deployment, the old `config/app_config` permission denial disappeared; remaining warnings are Play-services emulator noise and a Firestore offline timeout. |

## Warnings And Findings To Resolve

Release blockers:
- No current local build/signing blocker remains for iOS App Store IPA or Android Play upload AAB based on this pass.
- If macOS is a real public distribution target outside the Mac App Store, it still needs a Developer ID Application certificate and notarization flow. The current macOS artifact is Apple Distribution signed, which verifies locally but is rejected by `spctl` for direct Gatekeeper distribution.

Important cleanup / console work:
- Rename the active prod Firebase app registrations in the Firebase Console so their display names match their actual package/bundle IDs and environment. The active prod config IDs are correct, but the console labels still look like dev labels.
- Verify Firebase App Check registrations and enforcement in the Firebase Console. This Firebase CLI version can list apps and Android SHA hashes, but it does not expose App Check app listing.
- Recheck Android runtime on a real Android device before Play release. The emulator produced Google Play services `DEVELOPER_ERROR` / `Unknown calling package name 'com.google.android.gms'` noise and a Firestore offline timeout, while basic emulator DNS/IP connectivity was valid and the original rules denial was gone.
- If macOS remains a supported runtime target, guard or replace phone auth there. Firebase Auth `verifyPhoneNumber()` is not available on macOS.
- Consider raising macOS deployment target from 10.15 to 11.0 in a separate compatibility decision; Xcode 26 reports 11.0 as the recommended macOS deployment target.

Non-blocking warning noise:
- Web build: Flutter wasm dry-run suggestion and Flutter web build-size hints.
- Android build: Firebase Auth R8 invalid generic-signature info, `apkanalyzer` shell `integer expression expected`, and self-signed upload-key warnings from `jarsigner` that are normal for Android upload keys.
- iOS/macOS Xcode builds: duplicate library linker warning (`-lc++`, `-lsqlite3`, `-lz`), App Intents metadata skipped because no AppIntents dependency, and some plugin/Xcode metadata warnings.
- Firestore rules tests intentionally print `PERMISSION_DENIED` from negative `assertFails` cases.
- Emulator startup: Qt signal warnings and emulator gRPC token-auth warnings; not app blockers.

## Release Readiness Verdict

Android and iOS are release-ready from a local configuration/build/signing standpoint after this pass. The current upload artifacts are:
- Android Play upload: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`, signed by the Catch upload key with SHA-256 `30:88:F7:63:A6:0F:D9:F7:CA:99:20:4D:6A:68:EF:93:A3:02:63:A6:97:E5:63:EF:88:3B:29:DB:BC:7A:E2:3E`.
- iOS App Store Connect: `build/ios/ipa/Catch.ipa`, App Store exported with `com.catchdates.app`, production APNs/App Attest, and `get-task-allow=false`.

macOS now has a proper local release signature state, but direct outside-App-Store distribution is not ready until a Developer ID Application certificate and notarization workflow exist. Mac App Store distribution would need its own archive/export validation path.
