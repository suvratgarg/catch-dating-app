# Remaining Config Resolution Tracker - 2026-04-29

Scope: resolve the non-native-build remaining issues from the build readiness report, easiest to hardest, using canonical fixes and avoiding pod/native rebuild churn where possible.

## Order

1. Web Push VAPID key.
2. Web App Check provider key.
3. App Check enforcement readiness.
4. Android release signing readiness.
5. Final app identifiers and Firebase app registrations.
6. Functions npm audit transitive vulnerabilities.
7. Physical iPhone Profile observability.
8. Apple `codesign --verify` trust-chain warning.

## Current Pass

### 1. Web Push VAPID key

Status: complete for dev.

Evidence:
- Firebase Console > Project settings > Cloud Messaging > Web Push certificates has no existing key pair.
- The repo already reads `FIREBASE_WEB_VAPID_KEY` through `AppConfig.firebaseWebVapidKey`.
- `FcmService` already passes the VAPID key to `FirebaseMessaging.instance.getToken(vapidKey: ...)` on web.
- `AppConfig.supportsPushMessagingOnCurrentPlatform` disables web push when the VAPID key is blank, so blank local dev values fail closed.
- Firebase Console generated a Web Push certificate key pair on 2026-04-29.
- The public VAPID key was added to `tool/dart_defines/dev.json`.
- `tool/dart_defines/staging.json` and `tool/dart_defines/prod.json` remain blank because staging/prod Firebase environments are not real yet.

Canonical next action:
- When staging/prod Firebase projects exist, create/import the relevant Web Push key pairs there and fill only the matching public keys into the matching dart-define files.
- Do not store any private key material in the repo.

Risk/confirmation:
- Completed after explicit user approval. Generating the key created persistent web push credentials in Firebase; only the public key is committed to local config.

### 2. Web App Check provider key

Status: repo placeholder added; console registration inspected and blocked on reCAPTCHA Enterprise API/key setup.

Evidence:
- The repo now explicitly carries `FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY` in `tool/dart_defines/dev.json`, `staging.json`, and `prod.json`.
- Production web App Check activation in `main.dart` already uses `ReCaptchaEnterpriseProvider(siteKey)` when the site key is non-empty.
- Dev/staging use `WebDebugProvider`, so local debugging does not require reCAPTCHA Enterprise.
- Firebase Console > App Check > Apps shows Android registered with Play Integrity and iOS registered with App Attest.
- Firebase Console > App Check > Apps shows `catch_dating_app (web)` unregistered and asks for a `reCAPTCHA Enterprise site key`.
- Google Cloud Console redirects to the `reCAPTCHA Enterprise API` product page for project `catch-dating-app-64e51`; the API is not enabled.
- The Cloud Console product page shows usage pricing after the free tier and an account-verification warning.

Canonical next action:
- Confirm whether to enable `recaptchaenterprise.googleapis.com` for the dev Firebase project.
- Create a web reCAPTCHA Enterprise key for the intended domains, then register `catch_dating_app (web)` in Firebase App Check with that public site key.
- Copy the public reCAPTCHA Enterprise site key into the production dart-define source only if web is a real protected target and final domains are known.
- Keep enforcement off until metrics show valid App Check tokens.

Risk/confirmation:
- Paused before enabling the API or creating a site key because that is persistent Google Cloud configuration and may become billable after the free tier.
- The user asked to come back to this later, so Web App Check registration is intentionally deferred.
- Recommended domains for the dev project key: `catch-dating-app-64e51.web.app`, `catch-dating-app-64e51.firebaseapp.com`, `catchdates.com`, and `www.catchdates.com` if the custom domain points at this Firebase project.

### 3. App Check enforcement readiness

Status: inspected; not ready to enforce.

Evidence:
- Android and iOS App Check providers are registered, but web is deferred.
- `main.dart` activates App Check in app code, with web using `WebDebugProvider` outside production and `ReCaptchaEnterpriseProvider` only when a production site key exists.
- Firebase console still shows service enforcement as not enabled.

Canonical next action:
- Do not enable Firebase service enforcement yet.
- First register all client app providers and debug tokens.
- Then enforce one product at a time after observing App Check metrics.

Decision:
- No code or console enforcement change should be made in this pass. Enforcing before all supported clients are issuing valid tokens could break Firestore, Storage, Auth, or Functions traffic.

### 4. Android release signing readiness

Status: inspected; repo scaffolding is present, production signing identity is not created.

Evidence:
- `android/app/build.gradle.kts` reads `android/key.properties` when present and uses its `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` values for the release signing config.
- `android/key.properties.example` exists and points at `../keystore/upload-keystore.jks`, which resolves to `android/keystore/upload-keystore.jks` from the app module.
- Root `.gitignore` and `android/.gitignore` ignore `key.properties` and keystore files.
- `android/key.properties` is absent, so local release APK builds still fall back to debug signing. That is acceptable for local build verification but not acceptable for Play Store release.
- The current Android `applicationId` is now `com.catchdates.app`, and the new Firebase Android config contains a matching `com.catchdates.app` client.

Canonical next action:
- Choose the final production Android application ID.
- Use Play App Signing and create an upload keystore after that ID is finalized.
- Populate ignored `android/key.properties`.
- Register release SHA-1/SHA-256 fingerprints in Firebase.

Recommended release key command, to run only after the final package/application ID is chosen:

```bash
keytool -genkeypair -v \
  -keystore android/keystore/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

Decision:
- I did not generate a keystore in this pass. The upload key is long-lived signing material; creating it before the final app ID/Play setup would add sensitive local state without completing release readiness.

### 5. Final app identifiers and Firebase app registrations

Status: local dev identity switched to `com.catchdates.app`; cloud capability follow-up remains.

Evidence:
- Android namespace/application ID: `com.catchdates.app`.
- Android Firebase config includes new package name: `com.catchdates.app`.
- iOS bundle ID: `com.catchdates.app`.
- iOS Firebase config bundle ID: `com.catchdates.app`.
- macOS Firebase config bundle ID: `com.catchdates.app`.
- Created Firebase dev Android app `Catch dev Android`, app ID `1:574779808785:android:81edbfa0d4aba7c48ea5b0`.
- Created Firebase dev iOS app `Catch dev iOS`, app ID `1:574779808785:ios:49b1ce51418604b78ea5b0`.
- Active dev and `firebase/dev` native config files were regenerated/downloaded for those new Firebase apps.
- Registered the existing Android debug SHA-1 and SHA-256 fingerprints on the new Firebase Android app and verified both hashes with `firebase apps:android:sha:list`.
- `flutter analyze` passed after the identifier change.
- `flutter build apk --dart-define=APP_ENV=dev` passed and produced an APK whose output metadata reports `applicationId = com.catchdates.app`.
- `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator BUILD_DIR=... build` passed and produced an iOS simulator app whose `Info.plist` reports `CFBundleIdentifier = com.catchdates.app`.
- `flutter build macos --dart-define=APP_ENV=dev` passed and produced a macOS app whose `Info.plist` reports `CFBundleIdentifier = com.catchdates.app`.
- Staging/prod Firebase options intentionally fail fast because those Firebase projects do not exist yet.

Canonical next action:
- Firebase App Check is registered for the new Android app with Play Integrity and the new iOS app with App Attest.
- New Firebase iOS app APNs status was rechecked after upload: development and production both use APNs auth key ID `78HUQYZ2ZR`, Team ID `2HQBK4UMUT`.
- The APNs private key file `/Users/suvratgarg/Downloads/AuthKey_78HUQYZ2ZR.p8` was uploaded to Firebase Cloud Messaging for the new `com.catchdates.app` iOS app on 2026-04-29 after explicit user confirmation.
- Register Android release SHA-1/SHA-256 fingerprints for the new Android Firebase app once release signing exists.
- Create/refresh Apple Developer App ID and provisioning for `com.catchdates.app`, with Push Notifications and App Attest enabled.
- Keep staging/prod blocked until those real Firebase projects exist.

### 6. Functions npm audit transitive vulnerabilities

Status: inspected; no canonical non-force fix available today.

Evidence:
- `npm audit` still reports 11 vulnerabilities after the previous safe `npm audit fix`.
- `npm audit fix --dry-run` reports the project is up to date and again suggests only `npm audit fix --force`.
- The force path would install `firebase-admin@10.1.0`, which is a breaking downgrade from the current `firebase-admin@13.8.0`.
- `npm outdated` shows the direct runtime dependencies `firebase-admin`, `firebase-functions`, and `razorpay` are not outdated.
- `npm view firebase-admin version` reports `13.8.0`, matching the installed version.
- The vulnerable chain is transitive through Firebase Admin's optional Google Cloud clients: `@google-cloud/firestore@7.11.6`, `google-gax@4.6.1`, `@google-cloud/storage@7.19.0`, `teeny-request@9.0.0`, `http-proxy-agent@5.0.0`, `@tootallnate/once@2.0.0`, `gaxios@6.7.1`, and older nested `uuid` versions.

Canonical next action:
- Do not run `npm audit fix --force`.
- Keep Firebase Admin and Firebase Functions on the current major versions.
- Monitor Firebase Admin / Google Cloud package releases for an upstream dependency update that moves Firestore to `@google-cloud/firestore@8.x`, Google GAX to `5.x`, Storage to a chain without the flagged `teeny-request`/`http-proxy-agent` versions, and `uuid` to the patched range.

Decision:
- I did not add npm `overrides` in this pass. Overrides may silence the audit but would force transitive packages outside the version ranges tested by Firebase Admin and Google Cloud libraries. That should be treated as a deliberate compatibility experiment with Functions emulator tests and deploy validation, not as a drive-by config fix.

### 7. Physical iPhone Profile observability

Status: checked current connectivity; blocked on physical device availability.

Evidence:
- Earlier Profile run built, installed, launched, and `devicectl` showed `Runner.app/Runner` running on device, but Flutter did not discover the Dart VM Service after 60 seconds.
- Current `flutter devices` sees only the iOS simulator, macOS, and Chrome.
- Current `flutter devices` reports `Suvrat's iPhone` is not reachable and asks for the device to be unlocked, attached with a cable, or reachable on the same LAN with Developer Mode enabled.
- Current `xcrun devicectl list devices` lists `Suvrat's iPhone` as `unavailable`.

Canonical next action:
- When the phone is unlocked and visible in `flutter devices`, rerun `flutter run -v -d <device-id> --profile --dart-define=APP_ENV=dev`.
- Capture Flutter verbose output and device logs during launch.
- Treat this as observability/runtime validation, not a source-code fix, until logs show an app-owned failure.

### 8. Apple `codesign --verify` trust-chain warning

Status: intentionally deferred.

Evidence:
- Earlier signed Profile builds succeeded with automatic signing and team `2HQBK4UMUT`.
- Strict local `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` still reported `CSSMERR_TP_NOT_TRUSTED`.
- The user asked to deal with the code-sign vulnerability later.

Canonical next action:
- Validate through Xcode Archive/Organizer export with the final bundle ID/profile.
- Inspect Keychain trust for Apple Worldwide Developer Relations / Apple Development certificate chain only if the archive/export or App Store/TestFlight path fails.
