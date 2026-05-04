# Firebase Environments

This repo now has a three-environment Firebase workflow:

- `dev`
- `staging`
- `prod`

Two layers need to stay in sync for each environment:

1. Dart Firebase options in `lib/firebase_options_<env>.dart`
2. Native and web Firebase config files under `firebase/<env>/`

## Directory layout

Each environment needs these files:

```text
firebase/<env>/android/google-services.json
firebase/<env>/ios/GoogleService-Info.plist
firebase/<env>/macos/GoogleService-Info.plist
firebase/<env>/web/firebase-messaging-sw.js
```

Current state:

- `dev` is configured from Firebase project `catchdates-dev`.
- `staging` is configured from Firebase project `catchdates-staging`.
- `prod` is configured from the existing Firebase project `catch-dating-app-64e51`.
- Android product flavors are wired for `dev`, `staging`, and `prod`.
- Android upload-key SHA-1/SHA-256 fingerprints are registered on the dev,
  staging, and production Firebase Android apps. Add Play app-signing
  certificate fingerprints after Play App Signing enrollment.
- iOS/macOS schemes and build configurations are wired for `dev`, `staging`,
  and `prod` through `tool/configure_apple_flavors.rb`.
- Apple builds copy the matching `firebase/<env>/<platform>/GoogleService-Info.plist`
  into the app bundle at build time.
- App Check is registered for Android, iOS/macOS, and web in all three Firebase
  projects. Firestore, Storage, Auth, and callable Functions enforce App Check.
- Local web debug App Check follows Firebase's documented debug-provider flow:
  `web/index.html` sets `self.FIREBASE_APPCHECK_DEBUG_TOKEN = true` only on
  localhost/loopback origins, and the generated local browser token is
  registered on the dev web app. Do not commit raw debug tokens.
- Firestore rules are deployed and aligned across dev, staging, and prod. All
  client access is governed by the normal auth/ownership rules. A predeploy hook
  in `firebase.json` runs the rules test suite (`npm test`) before every
  `firebase deploy --only firestore:rules`, so broken rules cannot ship from
  the CLI. A GitHub Actions workflow (`.github/workflows/firestore-rules-ci.yml`)
  runs the same tests on every PR that touches `firestore.rules`.
- Production now has only the current app registrations active:
  `Catch Prod Android`, `Catch Prod iOS`, and `Catch Prod Web`. The old
  `com.example.*` Android/iOS registrations and the old Windows web
  registration were removed on 2026-04-30 and are pending Firebase's normal
  30-day permanent deletion window.
- Dev and staging Functions reuse the current prod Razorpay test-mode secrets.
  Replace this with environment-owned secrets before live Razorpay payments.
- **Firestore config document `config/cities` is required in every environment.**
  The `isValidCity()` rules function reads from it. Deploying Firestore rules
  without this document will reject all profile edits and club creations.
  See [`docs/deploy_runbook_2026_05_04.md`](../docs/deploy_runbook_2026_05_04.md)
  for the exact document contents.
- **TTL policy on `rateLimits.expiresAt` is required in every environment.**
  Create it in Firebase Console → Firestore → TTL Policies. Without it,
  rate-limit counter documents accumulate indefinitely.
- **Cloud Vision API must be enabled on every GCP project.**
  `gcloud services enable vision.googleapis.com --project=<project-id>`.
  The `moderatePhotoOnUpload` Storage trigger depends on it.

## Runtime source of truth

- App runtime environment comes from `APP_ENV`.
- Checked-in defaults live in `tool/dart_defines/dev.json`,
  `tool/dart_defines/staging.json`, and `tool/dart_defines/prod.json`.
- Native Firebase files are activated by `./tool/use_firebase_environment.sh`.
- The active root Firebase files are mutable working copies. Validate them with
  `./tool/validate_firebase_environment.sh <env>` before debugging runtime
  Firebase issues.

## Common commands

Switch the active native/web Firebase config:

```bash
./tool/use_firebase_environment.sh dev
```

Run Flutter with the matching `APP_ENV` define file:

```bash
./tool/flutter_with_env.sh dev run
./tool/flutter_with_env.sh staging run -d chrome
./tool/flutter_with_env.sh prod build apk
```

Android, iOS, and macOS use native flavors. For `build apk`,
`build appbundle`, `build ipa`, `build ios`, and `build macos`,
`tool/flutter_with_env.sh` automatically supplies the matching
`--flavor <env>` argument when one is not already present. Web builds do not get
a flavor argument.
For `flutter run`, the wrapper also supplies the matching flavor unless the
target device is a web target.

Explicit Apple examples:

```bash
flutter build ios --simulator --no-codesign --flavor dev --dart-define=APP_ENV=dev
flutter build ios --simulator --no-codesign --flavor staging --dart-define=APP_ENV=staging
flutter build ios --simulator --no-codesign --flavor prod --dart-define=APP_ENV=prod

flutter build macos --debug --flavor dev --dart-define=APP_ENV=dev
flutter build macos --debug --flavor staging --dart-define=APP_ENV=staging
flutter build macos --debug --flavor prod --dart-define=APP_ENV=prod
```

Regenerate Apple flavor project files after changing app IDs, labels, or
Firebase environment mappings:

```bash
ruby tool/configure_apple_flavors.rb
```

Run Firebase CLI commands against a configured alias:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore,storage
./tool/firebase_with_env.sh staging deploy --only functions
```

## How to refresh an environment

1. Create the Firebase project and app registrations for Android, iOS, macOS,
   and web.
2. Download the native config files into the matching `firebase/<env>/...`
   paths listed above.
3. Generate the Dart options file for that environment:

```bash
flutterfire configure --project=<firebase-project-id> --out=lib/firebase_options_staging.dart
flutterfire configure --project=<firebase-project-id> --out=lib/firebase_options_prod.dart
```

4. Update `firebase/<env>/web/firebase-messaging-sw.js` with the web app config
   from the same Firebase project.
5. Add the Firebase CLI alias with `firebase use --add` and map it to
   `staging` or `prod` in `.firebaserc`.
6. Re-run `./tool/use_firebase_environment.sh dev` if you want to restore the
   default dev files in the workspace after generating another environment.

Do not copy one environment's config into another environment. If a Firebase app
is recreated, refresh both the Dart options file and the native/web config file
from the same Firebase project.
