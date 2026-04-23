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

- `dev` is fully configured from the existing Firebase project.
- `staging` and `prod` are scaffolded in code, but their Firebase files and
  FlutterFire option files still need to be generated once those Firebase
  projects exist.

## Runtime source of truth

- App runtime environment comes from `APP_ENV`.
- Checked-in defaults live in `tool/dart_defines/dev.json`,
  `tool/dart_defines/staging.json`, and `tool/dart_defines/prod.json`.
- Native Firebase files are activated by `./tool/use_firebase_environment.sh`.

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

Run Firebase CLI commands against a configured alias:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore,storage
./tool/firebase_with_env.sh staging deploy --only functions
```

## How to add staging or prod

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

Until steps 2-5 are completed, selecting `staging` or `prod` will fail fast
with an explicit Firebase configuration error instead of silently talking to the
wrong backend.
