# Target Build Audit - 2026-04-28

Scope:
- Verify current Web, Android, iOS, and macOS builds from the repo state.
- Inspect platform-specific config for non-standard workarounds, missing setup,
  warnings, and release blockers.
- Fix repo-owned issues directly when the correct fix is clear.
- Separate local/account/toolchain blockers from app-code blockers.

## Status

- [x] Created this tracker.
- [x] Capture Flutter/Xcode/device/toolchain state.
- [x] Inspect platform folders and Firebase/push/App Check config.
- [x] Run `flutter analyze`.
- [x] Build Web.
- [x] Build Android APK.
- [x] Build iOS target.
- [x] Build macOS target.
- [x] Fix repo-owned build/config issues found so far.
- [x] Re-run affected non-iOS target builds.
- [x] Attempt physical iPhone install/run after device was connected.
- [x] Build signed iOS Profile target.
- [x] Produce final findings and remaining-actions report.

## Command Log

| Time | Command | Result | Notes |
| --- | --- | --- | --- |
| 2026-04-28 23:51 IST | `git status --short` | pass | Worktree already has audit/report files from prior session; no platform changes made yet in this pass. |
| 2026-04-28 23:51 IST | `flutter doctor -v` | pass | Flutter 3.41.2, Dart 3.11.0, Xcode 26.4.1, CocoaPods 1.16.2, Android SDK 37.0.0-rc2. No doctor issues. |
| 2026-04-28 23:51 IST | `flutter devices` | pass with warning | Chrome, macOS, and iPhone 17 Pro simulator are available. Flutter also reports an unreachable wireless physical iPhone. |
| 2026-04-28 23:51 IST | `xcodebuild -version` | pass | Xcode 26.4.1, build 17E202. |
| 2026-04-28 23:51 IST | `xcode-select -p` | pass | Selected Xcode path is `/Applications/Xcode.app/Contents/Developer`. |
| 2026-04-28 23:51 IST | `security find-identity -v -p codesigning` | pass | Three valid Apple Development signing identities for Suvrat Garg found. |
| 2026-04-28 23:51 IST | `xcrun simctl list devices available` | pass with warning | iOS 18.6 and iOS 26.4 simulators available; iPhone 17 Pro on iOS 26.4 is booted. Stale unavailable iOS 26.0/26.2 runtimes are present. |
| 2026-04-28 23:55 IST | `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showdestinations` | fail | Runner scheme exposes only ineligible `Any iOS Device`; Xcode says `iOS 26.4 is not installed` despite `simctl` and Flutter seeing a booted iOS 26.4 simulator. |
| 2026-04-28 23:55 IST | `xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -showdestinations` | pass | macOS destinations are available: My Mac and Any Mac. |
| 2026-04-28 23:58 IST | `flutter analyze` | pass | No issues found. |
| 2026-04-29 00:00 IST | `flutter build web --dart-define=APP_ENV=dev` | pass with warnings | Built `build/web`. Flutter reported wasm dry-run success and icon tree-shaking messages only. |
| 2026-04-29 00:01 IST | `flutter build apk --dart-define=APP_ENV=dev` | pass with warnings | Built `build/app/outputs/flutter-apk/app-release.apk` at 60.9MB. Flutter reported icon tree-shaking messages only. |
| 2026-04-29 00:08 IST | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | fail | CocoaPods lockfile was still on Firebase iOS SDK `12.9.0` while current FlutterFire plugins require `12.12.0`; build stopped during `pod install`. |
| 2026-04-29 00:12 IST | `pod update` in `ios/` and `macos/` | pass | Refreshed Firebase pods to SDK `12.12.0` after updating the explicit Firestore binary pod override. |
| 2026-04-29 00:15 IST | `pod install` in `ios/` | pass | CocoaPods base-config warning removed after adding `ios/Flutter/Profile.xcconfig`. |
| 2026-04-29 00:16 IST | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | fail | CocoaPods mismatch fixed; Xcode then failed destination selection with `iOS 26.4 is not installed`. |
| 2026-04-29 00:17 IST | `pod install --clean-install` in `ios/` | pass | Clean install still generated stale `iPhoneOS18.0.sdk` framework paths because `xcodeproj 1.27.0` hard-codes `LAST_KNOWN_IOS_SDK = 18.0`. |
| 2026-04-29 00:18 IST | RubyGems/xcodeproj inspection | pass | RubyGems shows `xcodeproj 1.27.0` is the latest public gem; local gem constants are iOS `18.0` and macOS `15.0`, which lag Xcode 26.4. |
| 2026-04-29 00:19 IST | `pod install` in `ios/` and `macos/` after Podfile hooks | pass with warning | Generated Pods projects now normalize system framework references to unversioned SDK aliases. Manual macOS `pod install` still prints Flutter-generated `DART_DEFINES` parsing warnings. |
| 2026-04-29 00:20 IST | `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showdestinations` | fail | Still failed after SDK-path normalization; same failure also reproduced on a fresh Flutter iOS template, proving this part is an Xcode platform/component issue, not this app's project file. |
| 2026-04-29 00:22 IST | `xcodebuild -runFirstLaunch -checkForNewerComponents` | pass | Xcode reported no newer first-launch updates for build `17E202`. |
| 2026-04-29 00:23 IST | `xcodebuild -downloadPlatform iOS` | running | Xcode started downloading `iOS 26.4.1 Simulator (23E254a)` for arm64, 8.46GB. This is required before rerunning iOS builds. |
| 2026-04-29 00:27 IST | `flutter build macos --dart-define=APP_ENV=dev` | fail | Build reached native macOS but failed because the macOS target had APNs entitlements requiring development signing. |
| 2026-04-29 00:34 IST | `flutter build macos --dart-define=APP_ENV=dev` after disabling macOS push | pass with warnings | Built `build/macos/Build/Products/Release/catch_dating_app.app` at 102.4MB. Remaining warnings are duplicate native linker flags from CocoaPods/Flutter linkage. |
| 2026-04-29 00:35 IST | `flutter analyze` | pass | No issues found after Dart and platform config changes. |
| 2026-04-29 00:37 IST | `flutter build web --dart-define=APP_ENV=dev` | pass with warnings | Built `build/web`. Same informational wasm dry-run and icon tree-shaking messages. |
| 2026-04-29 00:39 IST | `flutter build apk --dart-define=APP_ENV=dev` | pass with warnings | Built `build/app/outputs/flutter-apk/app-release.apk` at 60.9MB. Same informational icon tree-shaking messages. |
| 2026-04-29 00:40 IST | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` | fail | Device build is blocked by the same Xcode platform-component issue: generic iOS destination reports `iOS 26.4 is not installed`. |
| 2026-04-29 01:41 IST | `xcodebuild -downloadPlatform iOS` | pass | Finished installing `iOS 26.4.1 Simulator (23E254a)` for arm64. |
| 2026-04-29 01:42 IST | `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showdestinations` | pass | iOS destinations are now eligible, including generic iOS device, generic iOS simulator, iOS 18.6 simulators, and iOS 26.4/26.4.1 simulators. |
| 2026-04-29 01:46 IST | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | pass with warnings | Built `build/ios/iphonesimulator/Runner.app`. Flutter only reported package-outdated notices during dependency resolution. |
| 2026-04-29 01:46 IST | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` | pass with warnings | Built `build/ios/iphoneos/Runner.app` at 47.4MB. Warning is expected for this verification mode: the app must still be manually code signed before physical-device deployment or distribution. |
| 2026-04-29 01:55 IST | Firebase Console > Project settings > Cloud Messaging | inspected | FCM HTTP v1 is enabled. The iOS app `com.example.catchDatingApp` has both development and production APNs auth keys uploaded in Firebase. Web Push certificates are not configured. |
| 2026-04-29 01:58 IST | Apple Developer > Identifiers > `com.example.catchDatingApp` | inspected | Push Notifications capability is enabled. App Attest capability is not enabled. APNs Certificates count is `0`, which is acceptable because Firebase is configured with APNs auth keys instead of APNs certificates. |
| 2026-04-29 01:59 IST | Firebase Console > App Check > Apps | inspected | Android is registered with Play Integrity; iOS is registered with App Attest; web and the extra Windows web app are not registered. |
| 2026-04-29 01:59 IST | Apple Developer > Identifiers > `com.example.catchDatingApp` | changed | Enabled App Attest on the Apple App ID. Apple warned this invalidates provisioning profiles that include the App ID and requires regeneration/refresh for future use. |
| 2026-04-29 01:59 IST | `flutter build ios --dart-define=APP_ENV=dev` | pass with warnings | Signed iOS device build succeeded with team `2HQBK4UMUT`, producing `build/ios/iphoneos/Runner.app` at 48.2MB. Initial signed binary lacked the App Attest entitlement because the target entitlements file did not declare it. |
| 2026-04-29 01:59 IST | `codesign -d --entitlements - build/ios/iphoneos/Runner.app` | inspected | Confirmed the initial signed binary had APNs but not App Attest. |
| 2026-04-29 01:59 IST | Update `ios/Runner/Runner.entitlements` | pass | Added `com.apple.developer.devicecheck.appattest-environment = development`. |
| 2026-04-29 01:59 IST | `flutter build ios --dart-define=APP_ENV=dev` after App Attest entitlement | pass with warnings | Signed iOS device build succeeded again, producing `build/ios/iphoneos/Runner.app` at 48.2MB. |
| 2026-04-29 01:59 IST | `codesign -d --entitlements - build/ios/iphoneos/Runner.app` | pass | Signed binary now includes `application-identifier`, `aps-environment = development`, `com.apple.developer.devicecheck.appattest-environment = development`, team ID, and `get-task-allow = true`. |
| 2026-04-29 01:59 IST | Decode embedded provisioning profile | pass | Profile `iOS Team Provisioning Profile: com.example.catchDatingApp` includes APNs and App Attest entitlements, Team ID `2HQBK4UMUT`, and expires on 2027-04-28. |
| 2026-04-29 01:59 IST | `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` | warning | Local strict verification reports `CSSMERR_TP_NOT_TRUSTED`. Xcode signed the app successfully and `security find-identity` reports three valid Apple Development identities; keep this as a local trust-chain item to re-check before physical-device install/archive. |
| 2026-04-29 02:00 IST | `flutter devices` | pass with warning | Simulator, macOS, and Chrome are available. No physical iPhone is currently reachable; Flutter reports Suvrat's iPhone must be unlocked, cabled or on the same LAN, and opted into Developer Mode for wireless debugging. |
| 2026-04-29 02:08 IST | `flutter devices` | pass | Physical device became reachable: `Suvrat's iPhone`, UDID `00008120-001A152E3EEB401E`, iOS `26.0.1 (23A355)`, plus simulator/macOS/Chrome. |
| 2026-04-29 02:10 IST | `flutter run -d 00008120-001A152E3EEB401E --dart-define=APP_ENV=dev` | partial fail | Debug app built, signed, installed, and launched on the physical iPhone. Runtime then stopped under lldb with native `EXC_BAD_ACCESS`; no Dart exception was emitted. Console output showed Razorpay native checkout registration, Firebase Messaging integration guidance, and Firebase App Check debug-token output before the stop. |
| 2026-04-29 02:15 IST | `xcrun devicectl device info files --domain-type systemCrashLogs` | pass | No crash report existed while lldb held the Debug app at the fault. This is expected when the debugger catches the exception before iOS writes a crash report. |
| 2026-04-29 02:16 IST | `xcrun devicectl device process launch --terminate-existing --console com.example.catchDatingApp` | expected debug-mode fail | Directly launching the installed Debug app outside Flutter tooling produced `Cannot create a FlutterEngine instance in debug mode without Flutter tooling or Xcode`, then terminated with signal 11. This is not a production launch result; it is a Flutter Debug/untethered launch constraint. |
| 2026-04-29 02:16 IST | Pulled `Runner-2026-04-29-021612.ips` from device crash logs | pass | Crash report is `/private/tmp/catch_runner_021612.ips`. It matches the known Flutter Debug/untethered crash shape: `EXC_BAD_ACCESS` in `-[VSyncClient initWithTaskRunner:callback:]` during `FlutterViewController viewDidLoad`. Related Flutter issue: https://github.com/flutter/flutter/issues/168582. |
| 2026-04-29 02:17 IST | `flutter run -d 00008120-001A152E3EEB401E --profile --dart-define=APP_ENV=dev` | fail before app build/run | Xcode could no longer find the physical device as an eligible destination. Flutter/devicectl connectivity had dropped after the debug run. |
| 2026-04-29 02:18 IST | `flutter devices` and `xcrun devicectl list devices` | fail for physical device | Physical phone disappeared from Flutter's connected devices and CoreDevice listed `Suvrat's iPhone` as `unavailable`. Remaining connected targets were simulator, macOS, and Chrome. |
| 2026-04-29 02:20 IST | `flutter build ios --profile --dart-define=APP_ENV=dev` | pass with warnings | Signed generic iOS Profile build succeeded with automatic signing and team `2HQBK4UMUT`, producing `build/ios/iphoneos/Runner.app` at 57.0MB. Warnings were package-outdated notices only. |
| 2026-04-29 02:20 IST | `codesign -d --entitlements - build/ios/iphoneos/Runner.app` after Profile build | pass | Profile binary includes `application-identifier`, `aps-environment = development`, App Attest entitlement, team ID, and `get-task-allow = true`. |
| 2026-04-29 02:20 IST | `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` after Profile build | warning | Still reports `CSSMERR_TP_NOT_TRUSTED`. Xcode can sign the app and `security find-identity` reports valid development identities, but local strict trust-chain verification is still unresolved. |
| 2026-04-29 13:00 IST | `flutter pub upgrade` | pass | Applied safe in-range Dart/Flutter package updates; later analyzer/builds exposed one Firestore test-helper signature update and one iOS Razorpay pod lock issue. |
| 2026-04-29 13:01 IST | `flutter analyze` | fail then fixed | New `cloud_firestore` API expects `Map<Object, Object?>` for batch updates; updated the chat repository test helper override and re-ran analyzer successfully. |
| 2026-04-29 13:02 IST | `npm update firebase-admin firebase-functions` + `npm audit fix` | pass with remaining audit items | Functions runtime packages updated to `firebase-admin@13.8.0` and `firebase-functions@7.2.5`; remaining audit items require an unsafe/breaking Firebase Admin downgrade, so no `--force` was used. |
| 2026-04-29 13:03 IST | `npm run build` and `npm test` in `functions/` | pass | TypeScript build passed and 18 Functions tests passed. |
| 2026-04-29 13:04 IST | `pod install` in `ios/` and `macos/` | recovered | A transient GitHub 502 and partial concurrent CocoaPods copies caused generated Pods issues; cleaned generated Pods directories and reran pod installs serially. |
| 2026-04-29 13:06 IST | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | fail then fixed | `razorpay_flutter 1.4.4` referenced `RazorpayEventCallback`, but the lockfile held `razorpay-pod 1.5.2`; removed stale local `razorpay-core-pod 1.0.3` override and updated official Razorpay pods to `razorpay-pod 1.5.3` / `razorpay-core-pod 1.0.6`. |
| 2026-04-29 13:07 IST | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` after Razorpay pod fix | pass | Built `build/ios/iphonesimulator/Runner.app`. |
| 2026-04-29 13:08 IST | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` | pass | Built `build/ios/iphoneos/Runner.app` at 52.9MB. |
| 2026-04-29 13:08 IST | `flutter build ios --profile --dart-define=APP_ENV=dev` | pass | Signed Profile build produced `build/ios/iphoneos/Runner.app` at 62.6MB. |
| 2026-04-29 13:08 IST | `codesign -d --entitlements - build/ios/iphoneos/Runner.app` | pass | Confirmed APNs development entitlement and App Attest development entitlement remain present. |
| 2026-04-29 13:08 IST | `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` | warning | Still reports `CSSMERR_TP_NOT_TRUSTED`; this remains an Apple signing trust-chain/release-readiness item. |
| 2026-04-29 13:09 IST | `flutter build macos --dart-define=APP_ENV=dev` | pass with warnings | Built `build/macos/Build/Products/Release/catch_dating_app.app` at 109.7MB. Warnings are native dependency/plugin warnings and duplicate linker flags. |
| 2026-04-29 13:10 IST | `flutter devices` | pass | Physical iPhone is visible over USB: `Suvrat's iPhone`, UDID `00008120-001A152E3EEB401E`, iOS `26.0.1`. |
| 2026-04-29 13:10 IST | `flutter run -d 00008120-001A152E3EEB401E --profile --dart-define=APP_ENV=dev` | partial pass | Built and installed/launched on the physical iPhone; `devicectl` showed `Runner.app/Runner` running as PID `19774`, but Flutter did not discover the Dart VM Service after 60s. |
| 2026-04-29 13:10 IST | `flutter build web --dart-define=APP_ENV=dev` | pass with warnings | Built `build/web`; warnings are wasm dry-run suggestion and icon tree-shaking. |
| 2026-04-29 13:11 IST | `flutter build apk --dart-define=APP_ENV=dev` | pass with warnings | Built `build/app/outputs/flutter-apk/app-release.apk` at 63.4MB; warnings are icon tree-shaking. |
| 2026-04-29 13:12 IST | Create [build_readiness_dependency_report_2026-04-29.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/build_readiness_dependency_report_2026-04-29.md) | pass | Consolidated current build matrix, remaining issues, applied fixes, and dependency posture. |
| 2026-04-29 15:05 IST | Firebase Console > Project settings > Cloud Messaging > `Catch dev iOS` | changed | Uploaded APNs auth key ID `78HUQYZ2ZR`, Team ID `2HQBK4UMUT`, to the new Firebase iOS app `com.catchdates.app` for both development and production after explicit user confirmation. |

## Findings

- Toolchain baseline is good: Flutter doctor reports no issues, Xcode 26.4.1 is selected, CocoaPods is installed, and valid Apple Development signing identities exist.
- Environment warning: Flutter sees a wireless physical iPhone but cannot connect to it. This does not block simulator builds, but it is relevant for physical-device testing.
- Environment warning: CoreSimulator still lists unavailable iOS 26.0/26.2 runtimes. This can confuse destination discovery if Xcode project settings reference those runtimes indirectly.
- iOS destination discovery is fixed after installing the Xcode-requested `iOS 26.4.1 Simulator (23E254a)` platform component. Before the install, `xcodebuild -showdestinations` could not list eligible iOS destinations for either this app or a fresh Flutter template, proving the failure was local Xcode component state rather than a Runner project defect.
- macOS destination discovery is normal.
- Web release build succeeds. Current warnings are informational Flutter output: wasm dry-run suggestion and icon tree-shaking reductions.
- Android release APK build succeeds. Current warnings are informational icon tree-shaking output.
- iOS simulator build succeeds. Current warnings are package-outdated notices from `pub get`, not build failures.
- iOS generic device build succeeds with code signing disabled. This proves the native iOS project compiles for device, but it does not prove physical-device install, APNs entitlement validity, or App Store/TestFlight signing.
- iOS signed device build succeeds with Apple team `2HQBK4UMUT`. This is stronger than the earlier no-codesign check because it exercises automatic signing, the bundle ID, provisioning profile, APNs, and App Attest entitlements.
- iOS signed Profile device build also succeeds with Apple team `2HQBK4UMUT`. This exercises the Profile xcconfig, AOT/device build path, automatic signing, APNs entitlement, and App Attest entitlement without requiring a currently connected phone.
- The signed iOS binary now includes `com.apple.developer.devicecheck.appattest-environment = development`.
- Local strict `codesign --verify` still reports `CSSMERR_TP_NOT_TRUSTED`. This needs a physical-device install or Xcode Organizer archive/export check before treating the Apple signing chain as distribution-ready.
- After dependency updates, the signed iOS Profile build still succeeds and the physical iPhone Profile run now reaches installed/launched process state. `devicectl` showed `Runner.app/Runner` running on device, but Flutter did not discover the Dart VM Service after 60 seconds, so interactive Profile observability/UI validation remains incomplete.
- Physical iPhone Debug install/run was partially successful: the app built, signed, installed, and launched on `Suvrat's iPhone`, but the debug session stopped on a native `EXC_BAD_ACCESS` before the Flutter UI could be validated. The first lldb stop did not provide a symbolicated Dart stack.
- A direct launch of the installed Debug app produced a crash report in Flutter's iOS embedder at `-[VSyncClient initWithTaskRunner:callback:]`, but the console also emitted Flutter's explicit message that Debug iOS apps cannot create a FlutterEngine outside Flutter tooling/Xcode. Treat that crash report as evidence of an unsupported Debug launch mode, not as proof that Profile/Release builds crash.
- Flutter has a closed/solved upstream issue with the same VSyncClient crash signature for untethered iOS launches: https://github.com/flutter/flutter/issues/168582. The local app already matches the current Flutter iOS template shape, including `CADisableMinimumFrameDurationOnPhone = true`, `FlutterSceneDelegate`, and `FlutterImplicitEngineDelegate`.
- The physical iPhone became unavailable after the debug run. Flutter now reports only simulator/macOS/Chrome, and `devicectl` lists the phone as `unavailable`; a live Profile/Release launch still needs the phone unlocked, cabled or reachable over LAN, and visible to Xcode as an eligible destination.
- macOS release build succeeds after removing macOS APNs entitlement and disabling push registration on macOS. This matches the current product intent: macOS is a debugging target, not a distributed push target.
- macOS build warnings remain from native dependencies/linking:
  - `Runner: ld: warning: ignoring duplicate libraries: '-lc++', '-lsqlite3', '-lz'`.
  - Several Firebase/FlutterFire macOS plugin warnings are emitted from `.pub-cache` and `Pods` source during full native compilation. They do not block the build.
- Android release signing is still not production-correct if `android/key.properties` is absent: `android/app/build.gradle.kts` falls back to debug signing for release builds. That is acceptable for local build verification but not acceptable for Play Store distribution.
- iOS/macOS CocoaPods dependency state is fixed: both lockfiles now align with Firebase iOS SDK `12.12.0`, matching `firebase_core 4.7.0`.
- CocoaPods/xcodeproj compatibility issue is fixed in source config: `xcodeproj 1.27.0` still emits stale versioned SDK framework paths for Xcode 26. Podfile post-install hooks now normalize generated system framework references to unversioned SDK aliases and raise generated pod deployment targets to the app minimums.
- iOS Profile configuration is fixed: `ios/Flutter/Profile.xcconfig` now includes the generated Profile Pods xcconfig before `Generated.xcconfig`, matching Debug/Release behavior.
- macOS CocoaPods integration is fixed: the Runner target now uses AppInfo wrapper xcconfigs that include the matching Pods generated xcconfig and app metadata, while Flutter generated xcconfigs stay Flutter-owned.
- Push/App Check status:
  - iOS has `aps-environment = development` and `UIBackgroundModes` includes `remote-notification`.
  - Apple Developer Push Notifications and App Attest were verified for the old bundle ID `com.example.catchDatingApp`; the final bundle ID `com.catchdates.app` still needs Apple Developer capability/provisioning verification or refresh before release.
  - Firebase Cloud Messaging has development and production APNs auth keys uploaded for the new Firebase iOS app `com.catchdates.app`.
  - Android has `POST_NOTIFICATIONS` permission and runtime permission is requested through `FirebaseMessaging.requestPermission`.
  - Web push is enabled only for dev when running with `tool/dart_defines/dev.json`; staging/prod dart-define JSON files intentionally leave `FIREBASE_WEB_VAPID_KEY` blank until real Firebase environments exist.
  - macOS push is disabled in app code and entitlements until a real macOS push product decision/provisioning profile exists.
  - Firebase App Check has the new Android app registered with Play Integrity and the new iOS app registered with App Attest.
  - `ios/Runner/Runner.entitlements` declares the App Attest entitlement; a signed physical-device build still needs a fresh `com.catchdates.app` provisioning profile to prove Apple-side capability alignment.
  - Firebase App Check API enforcement is not enabled from the console. The APIs screen currently says "Start using" for Firestore, Storage, Auth, and related APIs; Functions enforcement must be done in Functions code.
  - Web App Check production enforcement should remain off until the web app is registered with a real reCAPTCHA Enterprise provider and `FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY` is configured.

## Remaining Work

- Resolve or characterize the local `CSSMERR_TP_NOT_TRUSTED` codesign verification warning before relying on this Mac for signed archive/export validation.
- Rerun physical iPhone Profile from Xcode or `flutter run -v -d 00008120-001A152E3EEB401E --profile --dart-define=APP_ENV=dev` and capture device logs. The app now installs and launches to a running process, but Flutter did not discover the Dart VM Service after 60 seconds.
- If the Debug physical-device `EXC_BAD_ACCESS` reproduces while the phone is stably connected, rerun with `flutter run -v -d 00008120-001A152E3EEB401E --dart-define=APP_ENV=dev` and capture the symbolicated lldb stack before changing app code. Current evidence points more toward Flutter Debug/tooling behavior than Dart/Firebase/Razorpay app code.
- For staging/prod Web Push, create/import Firebase Web Push certificates in those future environments and pass their public VAPID keys via `FIREBASE_WEB_VAPID_KEY`.
- For Web App Check enforcement, register the web app in Firebase App Check with reCAPTCHA Enterprise and configure `FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY`.
- For Play Store/App Store distribution, replace placeholder bundle/application IDs and configure production signing assets. Local Android APK builds currently fall back to debug signing when `android/key.properties` is absent.
- For a full iOS release readiness check, run a signed archive/export using the real Apple team, bundle ID, APNs-enabled/App-Attest-enabled App ID, and provisioning profiles. The signed device build now proves development signing, but not TestFlight/App Store export.
- Current consolidated build/dependency status is in [build_readiness_dependency_report_2026-04-29.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/build_readiness_dependency_report_2026-04-29.md).
