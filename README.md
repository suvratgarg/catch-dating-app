# Catch

Flutter app for iOS, Android, web, and macOS.

See [FIREBASE_SETUP.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/FIREBASE_SETUP.md) for the Firebase and FCM runbook.

## Local setup

1. Run `flutter pub get`.
2. Activate the default dev Firebase files:

   ```bash
   ./tool/use_firebase_environment.sh dev
   ```

3. Make sure Firebase config files are present:
   `android/app/google-services.json`
   `ios/Runner/GoogleService-Info.plist`
   `macos/Runner/GoogleService-Info.plist`
   `web/firebase-messaging-sw.js`

   The committed dev copies live under `firebase/dev/`.
   See [`firebase/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md) for the full multi-environment workflow.
4. If you want Android release signing, copy `android/key.properties.example` to `android/key.properties` and fill in your real keystore values. Release APK/App Bundle builds fail fast until this file points at a real upload keystore.

## Secret safety

- `.env` and `.env.*` are ignored.
- `android/key.properties`, `*.jks`, `*.keystore`, and common Apple signing artifacts are ignored.
- `android/key.properties.example` is safe to keep committed as a template.
- The Firebase app config files in this repo are currently tracked, so rotate or replace them if you do not want them stored in git history.

## Useful run flags

Preferred environment-aware app runs:

```bash
./tool/flutter_with_env.sh dev run
./tool/flutter_with_env.sh staging run
./tool/flutter_with_env.sh prod run
```

Android, iOS, and macOS builds use native flavors. The environment wrapper automatically adds the matching flavor for APK, App Bundle, iOS, and macOS builds:

```bash
./tool/flutter_with_env.sh dev build apk --debug
./tool/flutter_with_env.sh prod build appbundle
./tool/flutter_with_env.sh dev build ios --simulator --no-codesign
./tool/flutter_with_env.sh dev build macos
```

Default dev run without the wrapper:

```bash
flutter run
```

Use Firebase emulators in dev:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Enable push messaging:

```bash
flutter run --dart-define=ENABLE_PUSH_MESSAGING=true
```

Enable push messaging on web:

```bash
flutter run -d chrome \
  --dart-define=ENABLE_PUSH_MESSAGING=true \
  --dart-define=FIREBASE_WEB_VAPID_KEY=your_web_push_certificate_key_pair
```

Combine local dev flags:

```bash
flutter run \
  --dart-define=USE_FIREBASE_EMULATORS=true \
  --dart-define=ENABLE_PUSH_MESSAGING=true
```

Switch the active native/web Firebase files:

```bash
./tool/use_firebase_environment.sh dev
./tool/use_firebase_environment.sh staging
./tool/use_firebase_environment.sh prod
```

Run Firebase CLI commands against an environment alias:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore,storage
./tool/firebase_with_env.sh staging deploy --only functions
./tool/firebase_with_env.sh prod deploy --only hosting
```

The `dev`, `staging`, and `prod` Firebase aliases are present in `.firebaserc`.
Do not treat staging/prod as release-ready until their console-side App Check,
APNs, signing, and release fingerprints have been verified.

## Platform notes

- Paid Razorpay booking is enabled on Android and iOS only.
- Web and macOS builds disable paid booking until a supported checkout flow is added for those platforms.
- Push notifications are wired in-repo for Android and iOS.
  Android now has `dev`, `staging`, and `prod` product flavors; the dev flavor uses `com.catchdates.app.dev`, while prod uses `com.catchdates.app`.
  iOS/macOS now have matching `dev`, `staging`, and `prod` schemes/build configurations. Dev builds use `com.catchdates.app.dev`; prod builds use `com.catchdates.app`.
  The production Apple Developer App ID `com.catchdates.app` is registered with Push Notifications and App Attest. Dev/staging Apple App IDs and refreshed provisioning profiles still need to be verified or created before real-device push/App Check can be considered complete for those bundle IDs.
  macOS push is intentionally disabled because macOS is only a debugging target right now.
  Web push has a dev Firebase Web Push VAPID key; staging/prod VAPID keys remain blank until those Firebase projects exist.
- Firebase App Check is registered for the configured native Firebase apps. Web App Check is deferred until we decide whether to enable reCAPTCHA Enterprise for the web debugging target.
- iOS App Attest is declared in `ios/Runner/Runner.entitlements`; Apple Developer profiles still need to be refreshed for the exact bundle IDs used by the active native environment after capability changes.

## Verification

Commands used during this config pass:

```bash
flutter analyze
./tool/flutter_with_env.sh dev build web
./tool/flutter_with_env.sh dev build apk --debug
./tool/flutter_with_env.sh prod build appbundle
./tool/flutter_with_env.sh dev build macos
./tool/flutter_with_env.sh dev build ios --simulator --no-codesign
flutter build ios --no-codesign --dart-define=APP_ENV=dev
flutter build ios --dart-define=APP_ENV=dev
```
