# Catch

Flutter app for iOS, Android, web, and macOS.

Current docs:

- [PROJECT_CONTEXT.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/PROJECT_CONTEXT.md) is the architecture and product map.
- [firebase/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md) is the Firebase environment runbook.
- [functions/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/README.md) is the Cloud Functions runbook.
- [TESTS.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md) is the current test-suite inventory.
- [codex_audit/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/README.md) explains which audit docs are current versus historical.
- [codex_audit/release_setup_2026-04-30/current_release_setup_audit.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md) is the current setup/build/signing/distribution verdict.

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

Physical iPhone debug runs require a Firebase App Check debug token when App
Check enforcement is enabled. The current dev token is baked into
`tool/dart_defines/dev.json` and passed automatically — no export needed.

**If the app prints a new debug token** (e.g. after reinstalling the app or
on a new device), update both places:

1. Register the token in Firebase Console under
   **App Check > Catch Dev iOS > Manage debug tokens**
2. Update the `FIREBASE_APP_CHECK_DEBUG_TOKEN` value in
   `tool/dart_defines/dev.json`

The shell wrapper also respects the `FIREBASE_APP_CHECK_DEBUG_TOKEN` env var
as an override if you need to test with a different token temporarily:

```bash
export FIREBASE_APP_CHECK_DEBUG_TOKEN=some_other_token
./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E
```

Android, iOS, and macOS builds use native flavors. The environment wrapper automatically adds the matching flavor for APK, App Bundle, iOS, and macOS builds:

```bash
./tool/flutter_with_env.sh dev build apk --debug
./tool/flutter_with_env.sh prod build appbundle
./tool/flutter_with_env.sh dev build ios --simulator --no-codesign
./tool/flutter_with_env.sh dev build macos
```

Use Firebase emulators in dev:

```bash
./tool/flutter_with_env.sh dev run --dart-define=USE_FIREBASE_EMULATORS=true
```

Enable push messaging:

```bash
./tool/flutter_with_env.sh dev run --dart-define=ENABLE_PUSH_MESSAGING=true
```

Enable push messaging on web:

```bash
./tool/flutter_with_env.sh dev run -d chrome \
  --dart-define=ENABLE_PUSH_MESSAGING=true \
  --dart-define=FIREBASE_WEB_VAPID_KEY=your_web_push_certificate_key_pair
```

Combine local dev flags:

```bash
./tool/flutter_with_env.sh dev run \
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
Validate the active root Firebase files before diagnosing runtime Firebase
issues. The validator checks the currently active root files against one
environment, so switch first:

```bash
./tool/use_firebase_environment.sh dev
./tool/validate_firebase_environment.sh dev

./tool/use_firebase_environment.sh staging
./tool/validate_firebase_environment.sh staging

./tool/use_firebase_environment.sh prod
./tool/validate_firebase_environment.sh prod
```

## Platform notes

- Paid Razorpay booking is enabled on Android and iOS only.
- Web and macOS builds disable paid booking until a supported checkout flow is added for those platforms.
- Push notifications are wired in-repo for Android and iOS.
  Android now has `dev`, `staging`, and `prod` product flavors; the dev flavor uses `com.catchdates.app.dev`, while prod uses `com.catchdates.app`.
  iOS/macOS now have matching `dev`, `staging`, and `prod` schemes/build configurations. Dev builds use `com.catchdates.app.dev`; prod builds use `com.catchdates.app`.
  App Check is registered and enforced for Android, iOS/macOS, and web in all three Firebase environments.
  macOS push is intentionally disabled; direct Developer ID distribution is
  validated, but phone auth runtime behavior on macOS is intentionally deferred.
  Web push has Firebase Web Push VAPID keys in the checked-in Dart define files for the configured environments.
- Callable Cloud Functions enforce Firebase App Check. See `functions/README.md` before adding new callable endpoints or changing Razorpay secrets.
- iOS App Attest is declared in `ios/Runner/Runner.entitlements`; real-device App Check, phone auth, push, and upload flows should be smoke-tested in dev/staging after any Firebase or Apple capability change.

## Firestore error handling

Firestore write errors (permission-denied, network failures, quota exceeded)
are translated to user-friendly messages via `lib/core/firestore_error_message.dart`.
In debug mode, the Firebase error code is appended to help developers diagnose
rule failures without recompiling.

All Firestore partial updates use `DocumentReference.update()` with specific
field maps rather than reading a full document, modifying it in Dart, and
writing it back. This avoids a `Timestamp -> DateTime -> Timestamp` round-trip
that loses nanosecond precision and causes Firestore rule `diff()` checks to
reject writes.

Key files:
- `lib/core/firestore_error_message.dart` — error code to user message translation
- `lib/core/firestore_error_util.dart` — structured error-context wrapper for repository methods
- `lib/core/widgets/mutation_error_util.dart` — unified mutation error display helper
- `lib/exceptions/app_exception.dart` — typed `FirestoreWriteException` and `DocumentNotFoundException`
- `PROJECT_CONTEXT.md` §18 — full error handling conventions

## Verification

Recent verification commands:

```bash
flutter analyze
npm --prefix functions run lint
npm --prefix functions test
./tool/flutter_with_env.sh dev build web
./tool/flutter_with_env.sh dev build apk --debug
./tool/flutter_with_env.sh prod build appbundle
./tool/flutter_with_env.sh dev build macos
./tool/flutter_with_env.sh prod build macos
./tool/flutter_with_env.sh dev build ios --simulator --no-codesign
./tool/flutter_with_env.sh dev build ios --no-codesign
./tool/flutter_with_env.sh prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist
```

Firestore rules deploy (tests run automatically as a predeploy hook):

```bash
./tool/firebase_with_env.sh dev deploy --only firestore:rules
./tool/firebase_with_env.sh staging deploy --only firestore:rules
./tool/firebase_with_env.sh prod deploy --only firestore:rules
```
