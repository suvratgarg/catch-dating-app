# Catch

Flutter app for iOS, Android, web, and macOS.

Current docs:

- [PROJECT_CONTEXT.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/PROJECT_CONTEXT.md) is the architecture and product map.
- [lib/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/README.md) is the feature code map and points to feature-level READMEs.
- [docs/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/docs/README.md) is the docs index and source-of-truth map.
- [firebase/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md) is the Firebase environment runbook.
- [functions/README.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/README.md) is the Cloud Functions runbook.
- [TESTS.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md) is the current test-suite inventory.
- [docs/release_operations.md](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/docs/release_operations.md) is the current setup/build/signing/distribution and release-operations verdict.

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

## Mobile internal releases

`.github/workflows/mobile-internal-release.yml` is the canonical merge-driven
internal release path for both Consumer and Host:

- iOS archives each role independently, uploads to TestFlight, and waits for
  App Store Connect processing.
- Android builds and verifies the signed role/Firebase/Maps/certificate identity
  of each AAB; Play upload is limited
  to the `qa` internal-testing track and stays disabled until Play enrollment
  and publisher access are proven.

The six product/environment identities come from `tool/app_targets.json`; do
not reproduce bundle ids, package names, flavors, schemes, or release ownership
inside ad hoc scripts.

## Secret safety

- `.env` and `.env.*` are ignored.
- `android/key.properties`, `*.jks`, `*.keystore`, and common Apple signing artifacts are ignored.
- `android/key.properties.example` is safe to keep committed as a template.
- The Firebase app config files in this repo are currently tracked, so rotate or replace them if you do not want them stored in git history.

## Useful run flags

Preferred environment-aware app runs:

```bash
./tool/flutter_with_env.sh dev --platform ios run -d <ios-device-id>
./tool/flutter_with_env.sh staging --platform android run -d <android-device-id>
./tool/flutter_with_env.sh prod --platform web run -d chrome
```

`run` requires one device and, when its id does not identify the platform,
`--platform`. This keeps Android app-target flavors from being confused with
Apple scheme names.

## Interactive Phone Debugging Loop

Use this workflow when debugging UI/layout/runtime issues while one person
interacts with a connected physical phone and another watches logs:

1. Start with an interactive terminal, not a fire-and-forget run:

   ```bash
   ./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E
   ```

   Wait for Flutter to print the run key commands and VM Service URL before
   testing. In Codex, the run command must be launched with an interactive TTY
   so `r`, `R`, `d`, and `q` keep working.

2. Use App Check debug-token output as setup evidence, not as a code issue. If
   Firebase rejects App Check, register the printed debug token in Firebase
   Console and restart the app. Do not commit debug tokens.

3. Have the device user reproduce one concrete interaction at a time. Poll the
   terminal logs immediately after each interaction and work from the exact
   stack trace: widget name, file path, line number, and error class.

4. For sliver/sticky-header/layout bugs, diagnose the layout contract first:
   `minExtent`/`maxExtent`, child height, padding, input control height, and
   whether a sliver body is incorrectly embedding another vertical scrollable.
   Avoid trial-and-error height bumps unless the calculation proves the declared
   extent is actually too small.

5. Make a narrow fix, then run focused verification before returning to the
   phone:

   ```bash
   flutter analyze <touched files and focused tests>
   flutter test <focused widget/unit tests>
   ```

6. Use Flutter's interactive commands intentionally:

   - `r` hot reloads pure visual changes.
   - `R` hot restarts when constructors, providers, controllers, lifecycle, or
     state initialization changed.
   - `d` detaches from `flutter run` while leaving the app running on the phone.
   - `q` quits the app/run session.

7. After hot restart, treat only logs printed after `Restarted application` as
   fresh evidence. Old buffered `[FATAL]` lines can be stale.

8. Repeat the same user interaction on the phone and require a clean log window
   before calling the issue fixed. When finished, detach or quit the session so
   there is no orphaned `flutter run` process.

Physical iPhone debug runs use the real Apple App Attest provider by default.
That avoids repeated Firebase debug-token registration during normal phone
debug loops. Do not commit raw debug tokens. Keep a debug token only as an
ignored `.env.local` fallback for simulator/CI runs or explicit debug-provider
testing.

**If you intentionally force the debug provider** and the app prints a new
debug token:

1. Register the token in Firebase Console under
   **App Check > Catch Dev iOS > Manage debug tokens**
2. Save it locally before running the app:

The shell wrapper automatically loads `.env.local` and respects an already
exported `FIREBASE_APP_CHECK_DEBUG_TOKEN` env var:

```bash
printf 'FIREBASE_APP_CHECK_DEBUG_TOKEN=%s\n' 'some_other_token' > .env.local
USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER=true ./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E
```

Mobile debug-provider runs now fail fast when no token is configured. If you
are intentionally minting a first-time token to register in Firebase Console,
opt in explicitly for that one run:

```bash
ALLOW_RANDOM_APP_CHECK_DEBUG_TOKEN=1 USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER=true ./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E
```

For auth-specific phone debugging, opt into verbose masked OTP-flow logs only
for that run:

```bash
export VERBOSE_AUTH_DEBUG_LOGS=true
./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E
```

For simulator-only Firebase test phone numbers, bypass Firebase Auth app
verification explicitly for that run. This is rejected in production/release
builds and should not be used for real phone-number verification:

```bash
DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING=true ./tool/flutter_with_env.sh dev run -d "iPhone 17"
```

For the Catch Host dev simulator loop, use the host wrapper. It loads the same
local App Check debug token from `.env.local`, selects the host Firebase app, and
keeps the normal Firebase Auth app-verification flow enabled for real phone
numbers:

```bash
node tool/firebase/register_app_check_debug_token.mjs \
  --env dev \
  --role host \
  --platform ios \
  --display-name "Suvrat host dev iOS simulator"

./tool/run_host_dev_simulator.sh "iPhone 17 Pro"
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
./tool/flutter_with_env.sh dev --platform ios run -d <ios-device-id> --dart-define=USE_FIREBASE_EMULATORS=true
```

Enable push messaging:

```bash
./tool/flutter_with_env.sh dev --platform ios run -d <ios-device-id> --dart-define=ENABLE_PUSH_MESSAGING=true
```

Enable push messaging on web:

```bash
./tool/flutter_with_env.sh dev --platform web run -d chrome \
  --dart-define=ENABLE_PUSH_MESSAGING=true \
  --dart-define=FIREBASE_WEB_VAPID_KEY=your_web_push_certificate_key_pair
```

Combine local dev flags:

```bash
./tool/flutter_with_env.sh dev --platform ios run -d <ios-device-id> \
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
  Android has six explicit role/environment flavors: `consumerDev`, `consumerStaging`, `consumerProd`, `hostDev`, `hostStaging`, and `hostProd`.
  iOS/macOS now have matching consumer `dev`, `staging`, and `prod` schemes/build configurations plus host `host-dev`, `host-staging`, and `host-prod` schemes. Host iOS bundle IDs use `com.catchdates.host.dev`, `com.catchdates.host.staging`, and `com.catchdates.host`.
  Host builds use generated host-specific launcher icons (`AppIcon-host-*` on Apple platforms and `host*` Android launcher resources). App-relevant `main` pushes use the same approval-free GitHub role matrix for Consumer and Host; iOS targets TestFlight and Android targets signed AAB/Play-internal readiness.
  App Check is registered and enforced for consumer and host Android, iOS/macOS, and web apps in all three Firebase environments.
  macOS push is intentionally disabled; direct Developer ID distribution is
  validated, but phone auth runtime behavior on macOS is intentionally deferred.
  Web push has Firebase Web Push VAPID keys in the checked-in Dart define files for the configured environments.
- Callable Cloud Functions enforce Firebase App Check. See `functions/README.md` before adding new callable endpoints or changing Razorpay secrets.
- iOS App Attest and Push are declared in role-specific `ios/Runner/RunnerConsumer.entitlements` and `ios/Runner/RunnerHost.entitlements`; Consumer additionally owns HealthKit and Associated Domains. Real-device App Check, phone auth, push, and upload flows should be smoke-tested in dev/staging after any Firebase or Apple capability change.

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
