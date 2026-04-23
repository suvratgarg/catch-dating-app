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
4. If you want Android release signing, copy `android/key.properties.example` to `android/key.properties` and fill in your real keystore values.

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

Only the `dev` alias is wired today. Add `staging` and `prod` with
`firebase use --add` once those Firebase projects exist.

## Platform notes

- Paid Razorpay booking is enabled on Android and iOS only.
- Web and macOS builds disable paid booking until a supported checkout flow is added for those platforms.
- Push notifications are wired in-repo for Android, iOS, macOS, and web.
  Apple push still needs APNs setup in Apple Developer and Firebase Console.
  macOS push is additionally blocked until the Apple team provisioning profile includes Push Notifications.
  Web still needs a valid Firebase Web Push VAPID key.

## Verification

Commands used during this config pass:

```bash
flutter analyze
flutter build web --debug
flutter build apk --debug
flutter build macos --debug
flutter build ios --simulator --no-codesign
```
