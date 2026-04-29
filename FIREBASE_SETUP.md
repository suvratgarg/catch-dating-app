# Firebase Setup

Firebase environments:

- `dev` -> configured and backed by `catchdates-dev`
- `staging` -> configured and backed by `catchdates-staging`
- `prod` -> configured against the original `catch-dating-app-64e51` project

Supported Flutter platforms:
- `android`
- `ios`
- `macos`
- `web`

Unsupported platforms:
- `linux`
- `windows`

Firebase services used in-app:
- Authentication
- Cloud Firestore
- Cloud Functions
- Cloud Storage
- Firebase Cloud Messaging

## Files That Matter

- [firebase.json](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase.json)
- [.firebaserc](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/.firebaserc)
- [lib/firebase_options.dart](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options.dart)
- [lib/firebase_options_dev.dart](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_dev.dart)
- [lib/firebase_options_staging.dart](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_staging.dart)
- [lib/firebase_options_prod.dart](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_prod.dart)
- [firebase/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md)
- [tool/use_firebase_environment.sh](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/use_firebase_environment.sh)
- [tool/flutter_with_env.sh](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/flutter_with_env.sh)
- [tool/firebase_with_env.sh](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/firebase_with_env.sh)
- [ios/Runner/Runner.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Runner/Runner.entitlements)
- [ios/Runner/Info.plist](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Runner/Info.plist)
- [macos/Runner/DebugProfile.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Runner/DebugProfile.entitlements)
- [macos/Runner/Release.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Runner/Release.entitlements)
- [web/index.html](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/web/index.html)
- [web/firebase-messaging-sw.js](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/web/firebase-messaging-sw.js)

## Current Platform State

- The active app environment is selected by `APP_ENV` in `tool/dart_defines/<env>.json`.
- Dart Firebase options now route through `lib/firebase_options.dart`, which chooses among `dev`, `staging`, and `prod`.
- Android Firebase still depends on `google-services.json` plus the Google Services Gradle plugin. Android now has `dev`, `staging`, and `prod` product flavors, so Android builds must use the matching flavor.
- iOS Firebase still depends on `GoogleService-Info.plist`, `Runner.entitlements`, and `UIBackgroundModes` (`fetch`, `remote-notification`). iOS has `dev`, `staging`, and `prod` schemes/build configurations, and the build copies the matching `firebase/<env>/ios/GoogleService-Info.plist` into the app bundle.
- macOS Firebase still depends on `GoogleService-Info.plist`. macOS has `dev`, `staging`, and `prod` schemes/build configurations, and the build copies the matching `firebase/<env>/macos/GoogleService-Info.plist` into the app bundle. FCM code is present, but macOS push is intentionally disabled until macOS becomes a supported push target.
- Web Firebase still depends on both the Dart options file and `web/firebase-messaging-sw.js`.
- `./tool/use_firebase_environment.sh <env>` is the switch point for native and web Firebase files.

## Environment Workflow

Activate an environment's native/web files:

```bash
./tool/use_firebase_environment.sh dev
./tool/use_firebase_environment.sh staging
./tool/use_firebase_environment.sh prod
```

Run Flutter with the matching `APP_ENV`:

```bash
./tool/flutter_with_env.sh dev run
./tool/flutter_with_env.sh staging run
./tool/flutter_with_env.sh prod build apk
```

For Android APK/App Bundle, iOS, and macOS builds, `tool/flutter_with_env.sh` automatically adds `--flavor <env>` when you have not supplied a flavor yourself. Example: `./tool/flutter_with_env.sh dev build apk --debug` runs the `dev` Android flavor.

Explicit Apple flavor examples:

```bash
flutter build ios --simulator --no-codesign --flavor dev --dart-define=APP_ENV=dev
flutter build ios --simulator --no-codesign --flavor staging --dart-define=APP_ENV=staging
flutter build ios --simulator --no-codesign --flavor prod --dart-define=APP_ENV=prod

flutter build macos --debug --flavor dev --dart-define=APP_ENV=dev
flutter build macos --debug --flavor staging --dart-define=APP_ENV=staging
flutter build macos --debug --flavor prod --dart-define=APP_ENV=prod
```

Regenerate Apple schemes/configurations after changing app IDs, app names, or Firebase env mappings:

```bash
ruby tool/configure_apple_flavors.rb
```

Run Firebase CLI commands against the matching alias:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore,storage
./tool/firebase_with_env.sh staging deploy --only functions
```

All three aliases are present in `.firebaserc`. Before enabling enforcement or sending test users to staging, finish the remaining console-side App Check, APNs, provisioning, and Play App Signing checks.

## Push Notifications

- Android push is repo-complete for the dev/staging/prod flavors. Runtime permission is requested in-app where needed.
- Android upload-key SHA-1/SHA-256 fingerprints are registered for the dev, staging, and production Firebase Android apps. After Play App Signing is enabled, also register the Play app-signing certificate fingerprints because Play-distributed installs are signed by that certificate.
- iOS push is repo-complete in app code for the flavor bundle IDs. Apple Developer App IDs, Firebase iOS apps, and provisioning profiles must match the exact bundle ID selected for each environment before real-device push can work.
- macOS push is intentionally disabled in app code and entitlements because macOS is only a debugging target right now.
- Web push requires a VAPID key at runtime. Dev has a Firebase Web Push key pair and `tool/dart_defines/dev.json` contains the public VAPID key; staging/prod keys still need to be generated and added.

## App Check / App Attest

- Firebase App Check must be registered per native app ID/package. Verify Android Play Integrity and iOS App Attest for the exact dev/staging/prod identifiers before enabling enforcement.
- The final production Apple App ID `com.catchdates.app` is registered with App Attest and Push Notifications. Enable/register matching App IDs for the separate dev/staging bundle IDs before relying on App Check for those iOS installs.
- `ios/Runner/Runner.entitlements` declares `com.apple.developer.devicecheck.appattest-environment = development` so development-signed iOS builds carry the App Attest entitlement.
- Web App Check is not registered yet. Register the web app with reCAPTCHA Enterprise before enabling App Check enforcement for web clients.
- The Firebase App Check API enforcement screen currently reports "Start using" for Firestore, Storage, Auth, and related APIs; do not turn on enforcement until live clients are known to attach valid App Check tokens in the target environment.

Web push run example:

```bash
flutter run -d chrome \
  --dart-define=ENABLE_PUSH_MESSAGING=true \
  --dart-define=FIREBASE_WEB_VAPID_KEY=your_web_push_certificate_key_pair
```

## Apple FCM Checklist

Current state and remaining checks:

1. Apple Developer Push Notifications and App Attest are enabled for the production App ID `com.catchdates.app`; create/refresh the same capabilities for `com.catchdates.app.dev` and `com.catchdates.app.staging` if those bundle IDs will run on real devices.
2. Accept the latest Apple Developer Program License Agreement for the team account if Xcode reports a PLA update is required.
3. Regenerate or refresh Apple provisioning profiles after changing Apple capabilities such as App Attest.
4. Test on a real iPhone for iOS push. The iOS simulator cannot receive APNs pushes.
5. If macOS ever becomes a supported push target, re-enable the macOS APNs entitlement in `Runner/DebugProfile.entitlements` and `Runner/Release.entitlements`, allow macOS in `AppConfig.supportsPushMessagingOnCurrentPlatform`, then test on a signed macOS build with notification permission granted.

## Emulator / Local Dev Flags

Firebase emulators:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Push messaging can be toggled explicitly:

```bash
flutter run --dart-define=ENABLE_PUSH_MESSAGING=true
```

## Adding Or Refreshing An Environment

1. Create the Firebase project plus Android, iOS, macOS, and web apps.
2. Generate the environment's Dart Firebase options:

```bash
flutterfire configure \
  --project=<firebase-project-id> \
  --platforms=android,ios,macos,web \
  --out=lib/firebase_options_staging.dart
```

3. Save the downloaded native Firebase files into:

```text
firebase/<env>/android/google-services.json
firebase/<env>/ios/GoogleService-Info.plist
firebase/<env>/macos/GoogleService-Info.plist
firebase/<env>/web/firebase-messaging-sw.js
```

4. Add the Firebase CLI alias with `firebase use --add`.
5. Run `./tool/use_firebase_environment.sh <env>` to activate it.

If Firebase app IDs or supported platforms change for the existing dev project,
rerun `flutterfire configure` for dev and then re-check these native
customizations:

- The precompiled Firestore overrides in [ios/Podfile](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Podfile) and [macos/Podfile](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Podfile)
- The iOS Razorpay pods in [ios/Podfile.lock](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Podfile.lock), which should resolve from Razorpay's published CocoaPods specs rather than a local podspec override.

Those Apple-native changes are not part of FlutterFire itself, but they are required for this repo's current build stability.
