# iOS Release Readiness Audit - 2026-04-30

Status: recent iOS evidence snapshot. Keep this for device/signing/runtime
details. The active release setup tracker remains
[`release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md)
and is the current source of truth for the latest signing/export verdict.

## Goal

Run a comprehensive iOS verification pass for the Catch Flutter app: project config, signing, Pods, simulator build/run, no-codesign build, signed build, physical-device availability, runtime logs, notification-related entitlements, and any non-canonical Apple toolchain setup.

## Current Working Tree

- Branch: `main`
- Initial status: dirty before this audit
- Existing modified files observed before audit work:
  - `ios/Podfile`
  - `ios/Podfile.lock`
  - `ios/Runner.xcodeproj/project.pbxproj`
  - `lib/onboarding/presentation/onboarding_controller.dart`
  - `macos/Podfile`
  - `pubspec.yaml`
  - `pubspec.lock`
  - `web/firebase-messaging-sw.js`
- This audit also changed:
  - `lib/core/fcm_service.dart`
  - `test/routing/router_widgets_test.dart`
  - `tool/visual_review_app.dart`
  - `ios/Runner.xcodeproj/project.pbxproj`
  - `ios/Runner/AppDelegate.swift`
  - `ios/Runner/SceneDelegate.swift`
  - `ios/Runner/Info.plist`
  - `ios/Flutter/*.xcconfig`
  - `firebase.json`
  - `firebase/prod/android/google-services.json`
  - `android/app/src/prod/google-services.json`
  - `firebase/*/web/firebase-messaging-sw.js`
  - active Firebase config files copied by `tool/flutter_with_env.sh`

## Verification Matrix

| Area | Command / check | Status | Notes |
| --- | --- | --- | --- |
| Repo discovery | `git status --short --branch` | Done | Dirty tree predates this audit. Active env copy was restored to `prod` at the end. |
| Toolchain | `flutter --version`, `flutter doctor -v`, `xcodebuild -version`, `pod --version` | Passed | Flutter 3.41.2 stable, Dart 3.11.0, Xcode 26.4.1, CocoaPods 1.16.2. |
| Flutter static health | `flutter analyze` | Passed | No issues found after audit fixes. |
| Flutter tests | `flutter test --concurrency=1` | Passed | 369 tests passed. Error text printed by error logger tests is expected test fixture output. Default parallel `flutter test` still exposes a `two_dimensional_scrollables`/TableView test isolation failure in `test/run_clubs/run_clubs_widgets_test.dart`; the file passes by itself. |
| Focused FCM/router tests | `flutter test test/chats/fcm_service_test.dart`, `flutter test test/routing/router_widgets_test.dart` | Passed | Router test was updated for current create-run UI and provider lifecycle. |
| iOS project list | `xcodebuild -workspace ios/Runner.xcworkspace -list` | Passed | Schemes include `Runner`, `dev`, `staging`, `prod`. |
| Build settings | `xcodebuild ... -scheme dev -configuration Debug-dev -showBuildSettings`, prod release equivalent | Passed with findings | Dev bundle `com.catchdates.app.dev`; prod bundle `com.catchdates.app`; APNs/App Attest envs resolve per flavor. |
| Info.plist / entitlements | `plutil -p ios/Runner/Info.plist`, `plutil -p ios/Runner/Runner.entitlements` | Passed | Bundle ID/name are build settings, background remote notification mode present, APNs and App Attest are build-setting driven. |
| Firebase config | `plutil -p firebase/*/ios/GoogleService-Info.plist`, `firebase apps:list`, `firebase apps:sdkconfig`, Auth Admin REST checks, Firebase Console | Passed with caveats | Local plists match Firebase app registrations. Prod Auth had phone enabled already. Dev/staging Auth were initialized in Firebase Console and Phone provider now shows Enabled. Console warns new Spark projects have a 10 SMS/day quota unless billing is added. |
| Pod audit | `pod install`, Podfile/lockfile inspection | Passed with caveat | Pod install succeeded with Firebase 12.12.0 and 54 pods; Firestore binary SDK override and SDK-path normalization are intentional nonstandard workarounds. |
| Raw simulator build | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | Passed with finding | Built default Runner/prod bundle while Dart env was dev. Added default `APP_DISPLAY_NAME=Catch`; canonical builds must use flavor/wrapper. |
| Dev simulator no-codesign build | `./tool/flutter_with_env.sh dev build ios --simulator --no-codesign` | Passed | Produced `com.catchdates.app.dev`, `Catch Dev`, dev Firebase plist. |
| Dev device no-codesign build | `./tool/flutter_with_env.sh dev build ios --no-codesign` | Passed | Produced unsigned device app as expected after the phone-auth URL scheme changes. |
| Dev signed profile build | `./tool/flutter_with_env.sh dev build ios --profile` | Built but not clean | Build completed, but local codesign verification exposed development certificate/team mismatch. |
| Production archive / IPA | `./tool/flutter_with_env.sh prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist` | Passed with caveat | Archive and App Store IPA export completed; IPA has production bundle, production APNs, production App Attest, App Store profile. Local `codesign --verify` reports trust failure. |
| Simulator run/logs | `./tool/flutter_with_env.sh dev run -d <iPhone 17 Pro sim> --flavor dev` | Launched with warning | App reached Dart VM service; no Flutter exception stack; Flutter tooling emitted `Target native_assets required define SdkRoot but it was not provided`. |
| Physical iPhone debug run/logs | `./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E --flavor dev` | Launched, then debug-only crash | Installed and launched on Suvrat's iPhone. The prior App Check `FAILED_PRECONDITION` is gone after provider ordering fix. Debug still later crashes with `EXC_BAD_ACCESS`; profile is the meaningful device signal. |
| Physical iPhone profile run/logs | `./tool/flutter_with_env.sh dev run --profile -d 00008120-001A152E3EEB401E --flavor dev` | Launched; real OTP rate-limited | Initial profile run exposed a FirebaseAuth Swift nil unwrap during phone auth. Added Firebase URL schemes plus AppDelegate/SceneDelegate callback handling; rerun no longer crashed. After enabling dev/staging Phone Auth, the app launched again and App Check `FAILED_PRECONDITION` was removed by forcing App Attest for non-debug iOS builds. Real phone submission later returned `too-many-requests`. |
| Dev fictional OTP | Firebase Console test phone `+91 1234 567 890` / `654321`, physical iPhone | Passed | The app sent the test OTP, accepted the code, signed in, and advanced to the photo onboarding screen. |
| Firebase backend setup | Firestore API/database create, `firebase deploy --only firestore --project catchdates-dev`, staging equivalent | Passed | Dev and staging Firestore rules/indexes deployed. Staging default Firestore database was created in `asia-south1`. |
| Dev APNs setup | Firebase Console Project settings > Cloud Messaging | Passed | Dev iOS `com.catchdates.app.dev` has both Development and Production APNs auth keys configured with key ID `78HUQYZ2ZR` and team ID `2HQBK4UMUT`. |
| Notification readiness | Entitlements, profile, physical runtime | Partially blocked | Entitlements/profiles include APNs and the FCM token wait logic was hardened. Runtime still prints Firebase Messaging integration guidance, and full notification verification still requires Firebase Auth/App Check/backend flow to complete on a real signed-in device. |

## Findings

1. **Physical iPhone phone-auth crash was a real iOS config issue and is fixed locally.**
   - Profile device run initially crashed in `FirebaseAuth PhoneAuthProvider.verifyPhoneNumber(...)` with `Swift runtime failure: Unexpectedly found nil while implicitly unwrapping an Optional value`.
   - Added per-flavor `FIREBASE_IOS_URL_SCHEME` values, `CFBundleURLTypes`, and Firebase Auth URL callback handling in both `AppDelegate` and `SceneDelegate`.
   - Rerunning profile on Suvrat's iPhone no longer crashes at phone auth.

2. **Dev/staging Firebase Auth are now initialized and Phone provider is enabled.**
   - Prod Auth Admin config for `catch-dating-app-64e51` returns phone auth enabled.
   - Dev `catchdates-dev` and staging `catchdates-staging` previously returned `CONFIGURATION_NOT_FOUND`.
   - Used Firebase Console on 2026-04-30 to initialize Authentication and enable the native Phone provider for both dev and staging.
   - Both dev and staging now show Phone as Enabled in Firebase Console.
   - Console warning: new Spark projects currently have a sent SMS daily quota of 10/day unless a billing account is added.

3. **Dev iOS App Check runtime `FAILED_PRECONDITION` is resolved for the profile launch.**
   - Earlier phone logs showed `App not registered: 1:619661127800:ios:e9456edea3f2427f077d8d`.
   - Firebase Console shows dev iOS App Check registered with App Attest, while the profile runtime was falling back to the default DeviceCheck provider.
   - DeviceCheck registration would require an Apple `.p8` private key and key ID, so the local fix is to use a custom App Check provider factory that returns `AppAttestProvider` for non-debug builds and `AppCheckDebugProviderFactory` for debug builds.
   - Rerunning the dev profile app on Suvrat's iPhone no longer emitted the App Check `FAILED_PRECONDITION`.

4. **Physical iPhone startup still emits a Firebase Messaging integration warning.**
   - The log includes the Firebase Messaging method-swizzling documentation URL and "to ensure proper integration."
   - `lib/core/fcm_service.dart` was hardened to wait for an APNs token before calling `getToken()` on iOS, but the warning still appears, so there is likely an iOS/Firebase Messaging integration or provider-ordering issue still to resolve.

5. **Phone OTP is locally proven with a Firebase fictional Indian number; real-number OTP is currently rate-limited.**
   - The app now submits phone auth without a native FirebaseAuth crash.
   - App Check `FAILED_PRECONDITION` no longer appears.
   - Dev Phone provider is enabled and dev APNs auth keys exist in Firebase Console.
   - Added native Firebase Auth APNs hooks: explicit remote-notification registration, `Auth.auth().setAPNSToken(..., type: .unknown)`, and `Auth.auth().canHandleNotification(...)`.
   - `./tool/flutter_with_env.sh dev build ios --no-codesign --flavor dev` passes after these native changes.
   - The Firebase Console fictional Indian test number `+91 1234 567 890` with code `654321` passed end-to-end on Suvrat's iPhone.
   - The real number `+91 9131404263` is currently blocked by Firebase `too-many-requests`, so real SMS delivery needs quota/cooldown validation before it can be called clean.

6. **Local development signing is not fully trustworthy.**
   - Keychain identities:
     - `Apple Development: Suvrat Garg (2XD79W43F9)`
     - `Apple Distribution: Suvrat Garg (2HQBK4UMUT)`
   - Project/profile team is `2HQBK4UMUT`.
   - Dev profile build signed with an Apple Development cert for `2XD79W43F9` while embedding a `2HQBK4UMUT` team/profile. The app still installed during `flutter run`, but the local signing setup is inconsistent.

7. **Local `codesign --verify` reports trust failures.**
   - Dev signed app: `CSSMERR_TP_NOT_TRUSTED`.
   - Exported production IPA payload: `CSSMERR_TP_NOT_TRUSTED`.
   - `xcodebuild -exportArchive` still completed and `DistributionSummary.plist` shows the expected Apple Distribution certificate/profile. This should be resolved in Keychain/Xcode account trust before calling release signing clean.

8. **The raw Flutter command without flavor is foot-gunny.**
   - `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` built the default Runner scheme, which uses the prod bundle ID.
   - The canonical command is `./tool/flutter_with_env.sh dev build ios --simulator --no-codesign` or explicit `--flavor dev`.
   - Fixed the blank default Runner display name by adding `APP_DISPLAY_NAME=Catch`.

9. **Podfile contains intentional nonstandard workarounds.**
   - `FirebaseFirestore` is pinned to Invertase binary Firestore frameworks.
   - Post-install normalizes versioned SDK framework paths.
   - A targeted `SWIFT_SUPPRESS_WARNINGS=YES` suppresses upstream FlutterFire retroactive conformance warnings for `firebase_storage`, `firebase_analytics`, and `cloud_functions`.
   - These are not hacky in the sense of hiding app logic bugs, but they are noncanonical enough to keep documented.

10. **Firebase metadata had stale prod app IDs and is fixed.**
   - `firebase.json` pointed at old generated `com.example.catch_dating_app` prod Android/iOS Firebase apps.
   - Removed the stale Android client block from prod `google-services.json` copies and updated `firebase.json` to the current prod app IDs.
   - Verified no remaining `com.example.catch`, stale Android app ID, or stale iOS app ID references under active config paths.

11. **Tooling/runtime warnings remain.**
   - Simulator and device `flutter run` emit `Target native_assets required define SdkRoot but it was not provided`.
   - Physical device debug launch emits an empty dSYM warning.
   - Physical profile startup still emits Firebase Messaging method-swizzling guidance text.
   - Physical profile startup, while signed out, emitted a Firestore `permission-denied` stream error. This needs a signed-in run to classify as expected rules behavior versus a startup listener issue.
   - Neither blocked launch, but the user's requested "no warnings, no nothing" bar is not met.

12. **Photo upload has one local hardening fix, but the live device error still needs reproduction.**
   - Storage rules allow signed-in owners to write `image/*` files under `users/{uid}/photos` below 8 MB.
   - The client now asks `image_picker` to downscale selected gallery images to at most `1600x2133`, keep JPEG quality at 85, and skip full metadata requests. This reduces common iPhone photo uploads that exceed the Storage rule size limit or trigger unnecessary metadata permission friction.
   - The live iPhone upload repro is blocked until iPhone Mirroring reconnects and a test photo can be selected.

## Resume Notes

- Do not call this pass fully clean until real phone OTP is out of Firebase rate limit, the photo-upload runtime error is reproduced on device, the FCM runtime warning is understood/cleared, local signing trust is repaired, and the default parallel Flutter test run is stable.
- Active native/web Firebase config files were restored to `prod` after the device run.
- If continuing, first verify Apple Developer/Xcode Accounts can create/download an `Apple Development` certificate for team `2HQBK4UMUT`.
- In Firebase Console, Phone provider is enabled for `catchdates-dev` and `catchdates-staging`.
- Re-run physical iPhone `dev` with a real phone number after cooldown/quota reset. Fictional test-number OTP is already verified on device.
- Reconnect iPhone Mirroring and reproduce photo upload with a harmless test photo; if it still fails after client downscaling, inspect Firebase Storage/App Check enforcement and device logs.
- Re-run `codesign --verify --deep --strict` on exported IPA payload after Keychain trust is repaired.
