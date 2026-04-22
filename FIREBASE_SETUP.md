# Firebase Setup

Firebase project: `catch-dating-app-64e51`

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
- [android/app/google-services.json](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/android/app/google-services.json)
- [ios/Runner/GoogleService-Info.plist](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Runner/GoogleService-Info.plist)
- [macos/Runner/GoogleService-Info.plist](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Runner/GoogleService-Info.plist)
- [ios/Runner/Runner.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Runner/Runner.entitlements)
- [ios/Runner/Info.plist](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Runner/Info.plist)
- [macos/Runner/DebugProfile.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Runner/DebugProfile.entitlements)
- [macos/Runner/Release.entitlements](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Runner/Release.entitlements)
- [web/index.html](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/web/index.html)
- [web/firebase-messaging-sw.js](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/web/firebase-messaging-sw.js)

## Current Platform State

- Android Firebase is configured through `google-services.json` and the Google Services Gradle plugin.
- iOS Firebase is configured through `GoogleService-Info.plist`, `Runner.entitlements`, and `UIBackgroundModes` (`fetch`, `remote-notification`).
- macOS Firebase is configured through `GoogleService-Info.plist`. FCM code is present, but APNs signing is still blocked by Apple Developer provisioning on this machine.
- Web Firebase is configured through `firebase_options.dart`; web push also depends on `firebase-messaging-sw.js` and service worker registration in `index.html`.

## Push Notifications

- Android push is repo-complete. Runtime permission is requested in-app where needed.
- iOS push is repo-complete for code/config, but APNs still requires Apple Developer + Firebase Console setup.
- macOS push is not fully activated in-repo yet because the local Apple Developer provisioning profile does not currently include Push Notifications.
- Web push requires a VAPID key at runtime.

Web push run example:

```bash
flutter run -d chrome \
  --dart-define=ENABLE_PUSH_MESSAGING=true \
  --dart-define=FIREBASE_WEB_VAPID_KEY=your_web_push_certificate_key_pair
```

## Apple FCM Checklist

Still required outside the repo:

1. In Apple Developer, enable Push Notifications for bundle ID `com.example.catchDatingApp`.
2. In Firebase Console for project `catch-dating-app-64e51`, upload an APNs auth key in Cloud Messaging.
3. Accept the latest Apple Developer Program License Agreement for the team account if Xcode reports a PLA update is required.
4. Regenerate or refresh the Apple provisioning profiles after Push Notifications is enabled.
5. Test on a real iPhone for iOS push. The iOS simulator cannot receive APNs pushes.
6. Re-enable the macOS APNs entitlement in `Runner/DebugProfile.entitlements` and `Runner/Release.entitlements`, then test on a signed macOS build with notification permission granted.

## Emulator / Local Dev Flags

Firebase emulators:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Push messaging can be toggled explicitly:

```bash
flutter run --dart-define=ENABLE_PUSH_MESSAGING=true
```

## Re-running FlutterFire

If Firebase app IDs or supported platforms change, rerun:

```bash
flutterfire configure \
  --project=catch-dating-app-64e51 \
  --platforms=android,ios,macos,web
```

After re-running, re-check these native customizations:

- The precompiled Firestore overrides in [ios/Podfile](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/Podfile) and [macos/Podfile](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/macos/Podfile)
- The Razorpay iOS podspec override in [ios/PodspecOverrides/razorpay-core-pod.podspec.json](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/ios/PodspecOverrides/razorpay-core-pod.podspec.json)

Those Apple-native changes are not part of FlutterFire itself, but they are required for this repo's current build stability.
