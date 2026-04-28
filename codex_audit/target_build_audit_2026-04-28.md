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
- The signed iOS binary now includes `com.apple.developer.devicecheck.appattest-environment = development`.
- Local strict `codesign --verify` still reports `CSSMERR_TP_NOT_TRUSTED`. This needs a physical-device install or Xcode Organizer archive/export check before treating the Apple signing chain as distribution-ready.
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
  - Apple Developer has Push Notifications enabled for `com.example.catchDatingApp`.
  - Apple Developer has App Attest enabled for `com.example.catchDatingApp`.
  - Firebase Cloud Messaging has development and production APNs auth keys uploaded for `com.example.catchDatingApp`.
  - Android has `POST_NOTIFICATIONS` permission and runtime permission is requested through `FirebaseMessaging.requestPermission`.
  - Web push is intentionally disabled unless `FIREBASE_WEB_VAPID_KEY` is provided; the current dev/staging/prod dart-define JSON files leave it blank.
  - macOS push is disabled in app code and entitlements until a real macOS push product decision/provisioning profile exists.
  - Firebase App Check has Android registered with Play Integrity and iOS registered with App Attest.
  - iOS signed builds now include the App Attest entitlement from `ios/Runner/Runner.entitlements`.
  - Firebase App Check API enforcement is not enabled from the console. The APIs screen currently says "Start using" for Firestore, Storage, Auth, and related APIs; Functions enforcement must be done in Functions code.
  - Web App Check production enforcement should remain off until the web app is registered with a real reCAPTCHA Enterprise provider and `FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY` is configured.

## Remaining Work

- Resolve or characterize the local `CSSMERR_TP_NOT_TRUSTED` codesign verification warning before relying on this Mac for signed archive/export validation.
- For Web push debugging, create Firebase Web Push certificates and pass the VAPID key via `FIREBASE_WEB_VAPID_KEY`.
- For Web App Check enforcement, register the web app in Firebase App Check with reCAPTCHA Enterprise and configure `FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY`.
- For Play Store/App Store distribution, replace placeholder bundle/application IDs and configure production signing assets. Local Android APK builds currently fall back to debug signing when `android/key.properties` is absent.
- For a full iOS release readiness check, run a signed archive/export using the real Apple team, bundle ID, APNs-enabled/App-Attest-enabled App ID, and provisioning profiles. The signed device build now proves development signing, but not TestFlight/App Store export.
