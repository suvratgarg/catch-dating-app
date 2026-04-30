# Remaining Config Resolution Tracker - 2026-04-29

Status: historical tracker. Many Firebase/App Check items in this file were
resolved after it was written. For current Firebase status, read
[`firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md).
For current build/signing/distribution readiness, read
[`release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md).

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
- Historical note: at the time of this tracker, `tool/dart_defines/staging.json`
  and `tool/dart_defines/prod.json` still had blank Web Push values. This has
  since been superseded; current dart-define files contain environment-specific
  Web Push and web App Check public keys.

Canonical next action:
- Current follow-up: keep only public VAPID keys in repo, and rotate/update them
  through the matching Firebase environment if app domains or projects change.
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

Status: canonical upload keystore created locally; Android release builds now pass.

Evidence:
- `android/app/build.gradle.kts` reads `android/key.properties` when present and uses its `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` values for the release signing config.
- `android/key.properties.example` exists and points at `../keystore/upload-keystore.jks`, which resolves to `android/keystore/upload-keystore.jks` from the app module.
- Root `.gitignore` and `android/.gitignore` ignore `key.properties` and keystore files.
- `android/key.properties` now exists locally and is ignored by git.
- `android/keystore/upload-keystore.jks` now exists locally and is ignored by git.
- The generated upload-key password is also stored in the macOS Keychain under service `catch-dating-app.android-upload-keystore`, account `com.catchdates.app`.
- Android now has native `dev`, `staging`, and `prod` product flavors. The dev flavor package is `com.catchdates.app.dev`; prod remains `com.catchdates.app`.
- `./tool/flutter_with_env.sh dev build apk --debug` now auto-selects the Android dev flavor and builds `build/app/outputs/flutter-apk/app-dev-debug.apk`.
- `./tool/flutter_with_env.sh prod build appbundle` now auto-selects the Android prod flavor and builds `build/app/outputs/bundle/release/app-release.aab`.
- `./tool/flutter_with_env.sh prod build apk --release` now builds `build/app/outputs/flutter-apk/app-prod-release.apk`.
- Upload-key SHA-1: `F3:71:52:37:15:35:E0:2E:4A:F8:C6:A7:D9:E1:DA:BB:B7:AA:56:37`.
- Upload-key SHA-256: `30:88:F7:63:A6:0F:D9:F7:CA:99:20:4D:6A:68:EF:93:A3:02:63:A6:97:E5:63:EF:88:3B:29:DB:BC:7A:E2:3E`.
- Those release SHA-1/SHA-256 fingerprints are registered on the dev, staging, and production Firebase Android apps.

Canonical next action:
- Back up `android/keystore/upload-keystore.jks` securely outside the repo.
- When creating the Play Console app, enroll in Play App Signing and use this keystore as the upload key.
- After Play App Signing is active, register the Play app-signing certificate SHA fingerprints in Firebase as well. The upload-key fingerprints are not a substitute for the final Play app-signing certificate used on user-installed Play builds.

Release key command used:

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
- The keystore is long-lived signing material, so it is intentionally ignored by git. Keep a private backup; losing it after Play enrollment requires a Play upload-key reset process.

### 5. Final app identifiers and Firebase app registrations

Status: native identity split is implemented repo-side; Apple Developer App IDs and Xcode-managed development profiles now exist for all three iOS bundle IDs. App Store IPA export is still blocked on distribution signing.

Evidence:
- Android namespace/application ID base: `com.catchdates.app`.
- Android dev flavor package: `com.catchdates.app.dev`.
- Android prod flavor package: `com.catchdates.app`.
- Active dev Android Firebase config package: `com.catchdates.app.dev`.
- iOS dev scheme bundle ID: `com.catchdates.app.dev`.
- iOS staging scheme bundle ID: `com.catchdates.app.staging`.
- iOS prod scheme bundle ID: `com.catchdates.app`.
- Active dev iOS Firebase config bundle ID: `com.catchdates.app.dev`.
- macOS dev scheme bundle ID: `com.catchdates.app.dev`.
- macOS staging scheme bundle ID: `com.catchdates.app.staging`.
- macOS prod scheme bundle ID: `com.catchdates.app`.
- Active dev macOS Firebase config bundle ID: `com.catchdates.app.dev`.
- Created Firebase dev Android app `Catch dev Android`, app ID `1:574779808785:android:81edbfa0d4aba7c48ea5b0`.
- Created Firebase dev iOS app `Catch dev iOS`, app ID `1:574779808785:ios:49b1ce51418604b78ea5b0`.
- Active dev and `firebase/dev` native config files were regenerated/downloaded for those new Firebase apps.
- Registered the existing Android debug SHA-1 and SHA-256 fingerprints on the new Firebase Android app and verified both hashes with `firebase apps:android:sha:list`.
- `flutter analyze` passed after the identifier change.
- `./tool/flutter_with_env.sh dev build apk --debug` passed and produced `app-dev-debug.apk` for the Android dev flavor.
- `./tool/flutter_with_env.sh dev build ios --simulator --no-codesign` passed and produced an iOS simulator app whose `Info.plist` reports `CFBundleIdentifier = com.catchdates.app.dev`, `CFBundleDisplayName = Catch Dev`, and whose embedded Firebase plist reports `PROJECT_ID = catchdates-dev`.
- `./tool/flutter_with_env.sh dev build macos` passed and produced a macOS app whose `Info.plist` reports `CFBundleIdentifier = com.catchdates.app.dev`, `CFBundleName = Catch Dev`, and whose embedded Firebase plist reports `PROJECT_ID = catchdates-dev`.
- `tool/flutter_with_env.sh` now auto-selects the matching native flavor for `build apk`, `build appbundle`, `build ipa`, `build ios`, and `build macos`.
- `tool/configure_apple_flavors.rb` now declares the Firebase plist input and copied output path for the Xcode build phase; the macOS dev rebuild no longer emits the Firebase copy-script or missing AccentColor warnings.
- Current staging/prod Firebase configs are scaffolded in the worktree; verify them before use.

Canonical next action:
- In the inspected/original Firebase project, Firebase App Check is registered for the new Android app with Play Integrity and the new iOS app with App Attest.
- In the inspected/original Firebase project, the `com.catchdates.app` iOS app APNs status was rechecked after upload: development and production both use APNs auth key ID `78HUQYZ2ZR`, Team ID `2HQBK4UMUT`.
- The APNs private key file `/Users/suvratgarg/Downloads/AuthKey_78HUQYZ2ZR.p8` was uploaded to Firebase Cloud Messaging for the inspected/original project's `com.catchdates.app` iOS app on 2026-04-29 after explicit user confirmation.
- Apple Developer now has an explicit App ID for `com.catchdates.app` named `Catch`, with Push Notifications and App Attest selected during registration.
- Apple Developer now also has explicit App IDs for `com.catchdates.app.dev` (`Catch Dev`) and `com.catchdates.app.staging` (`Catch Staging`), with Push Notifications and App Attest selected during registration.
- `security find-identity -v -p codesigning` reports three valid local `Apple Development: Suvrat Garg (2XD79W43F9)` identities.
- Historical blocker now resolved for development/Profile builds: Xcode initially reported `No Accounts` and tried to satisfy `com.catchdates.app.dev` with stale wildcard profile `iOS Team Provisioning Profile: *`; that wildcard profile did not include the Apple Development certificate, App Attest, Push Notifications, `aps-environment`, or `com.apple.developer.devicecheck.appattest-environment`.
- Xcode is now able to create/fetch explicit Xcode-managed development profiles for all three iOS bundle IDs.
- Added canonical Xcode signing metadata to `ios/Runner.xcodeproj/project.pbxproj`: the Runner target now records `DevelopmentTeam = 2HQBK4UMUT`, `ProvisioningStyle = Automatic`, and each Runner app build configuration explicitly has `CODE_SIGN_STYLE = Automatic`.
- Rechecked `xcodebuild -project ios/Runner.xcodeproj -scheme dev -configuration Profile-dev -showBuildSettings`; it now reports `CODE_SIGN_STYLE = Automatic`, `DEVELOPMENT_TEAM = 2HQBK4UMUT`, and `PRODUCT_BUNDLE_IDENTIFIER = com.catchdates.app.dev`.
- The flavor Firebase copy phase is present and uses `$(FIREBASE_ENV)` to copy `firebase/<env>/ios/GoogleService-Info.plist` into the built app product, so manual Xcode builds should use the `dev`, `staging`, or `prod` scheme rather than the default unflavored `Runner` scheme.
- Xcode console from a stale/unflavored physical-device run showed Firebase App Check failing for old Firebase app ID `1:574779808785:ios:ee42e89efaf280f78ea5b0`. Current environment plists point prod to `1:574779808785:ios:49b1ce51418604b78ea5b0`, dev to `1:619661127800:ios:e9456edea3f2427f077d8d`, and staging to `1:822303414140:ios:6bae8cc0e1781e890c76f9`.
- `./tool/flutter_with_env.sh dev build ios --profile` passed and produced `build/ios/iphoneos/Runner.app` at `62.8MB`.
- Dev signed artifact inspection:
  - `CFBundleIdentifier`: `com.catchdates.app.dev`
  - `CFBundleDisplayName`: `Catch Dev`
  - Firebase project: `catchdates-dev`
  - Firebase app ID: `1:619661127800:ios:e9456edea3f2427f077d8d`
  - Profile: `iOS Team Provisioning Profile: com.catchdates.app.dev`
  - Entitlements: `application-identifier = 2HQBK4UMUT.com.catchdates.app.dev`, `aps-environment = development`, `com.apple.developer.devicecheck.appattest-environment = development`, `get-task-allow = true`
- `./tool/flutter_with_env.sh staging build ios --profile` passed and produced `build/ios/iphoneos/Runner.app` at `62.8MB`.
- Staging signed artifact inspection:
  - `CFBundleIdentifier`: `com.catchdates.app.staging`
  - Firebase project: `catchdates-staging`
  - Firebase app ID: `1:822303414140:ios:6bae8cc0e1781e890c76f9`
  - Profile: `iOS Team Provisioning Profile: com.catchdates.app.staging`
  - Entitlements: `application-identifier = 2HQBK4UMUT.com.catchdates.app.staging`, `aps-environment = development`, `com.apple.developer.devicecheck.appattest-environment = development`, `get-task-allow = true`
- `./tool/flutter_with_env.sh prod build ios --profile` passed and produced `build/ios/iphoneos/Runner.app` at `62.8MB`.
- Prod signed artifact inspection:
  - `CFBundleIdentifier`: `com.catchdates.app`
  - Firebase project: `catch-dating-app-64e51`
  - Firebase app ID: `1:574779808785:ios:49b1ce51418604b78ea5b0`
  - Profile: `iOS Team Provisioning Profile: com.catchdates.app`
  - Entitlements: `application-identifier = 2HQBK4UMUT.com.catchdates.app`, `aps-environment = development`, `com.apple.developer.devicecheck.appattest-environment = development`, `get-task-allow = true`
- `./tool/flutter_with_env.sh prod build ipa --release` builds `build/ios/archive/Runner.xcarchive` at `250.1MB`; archive validation reports display name `Catch`, build number `1`, version `1.0.0`, deployment target `15.0`, and bundle ID `com.catchdates.app`.
- The first IPA attempt exposed a wrapper bug: `tool/flutter_with_env.sh` did not auto-select native flavors for `build ipa`, causing Flutter to archive the default `Runner` scheme with a blank display name. The script now includes `ipa` in the flavor auto-selection list, and the rerun archive metadata is correct.
- Xcode Settings > Accounts now shows a signed-in Apple account for `Suvrat Garg`, role `Admin`, with Certificates, Identifiers & Profiles checked and three provisioned devices available for development.
- Xcode Manage Certificates shows local Apple Development certificates only. `security find-identity -v -p codesigning` also reports valid Apple Development identities and no Apple Distribution identity.
- Apple Developer portal > Certificates shows four Development certificates and no Distribution certificate.
- Apple Developer portal > Profiles shows no provisioning profiles.
- In Xcode's iOS Runner Signing & Capabilities UI, dev/staging/prod bundle IDs are mapped to `com.catchdates.app.dev`, `com.catchdates.app.staging`, and `com.catchdates.app`; automatic signing is checked; team is `Suvrat Garg`; Push Notifications, Background Modes, Photo Library usage, and App Attest are present.
- In Xcode's macOS Runner Signing & Capabilities UI, dev/staging/prod bundle IDs are mapped to the same three identifiers; automatic signing is checked; App Sandbox and network/photo-library entitlements are present; macOS push/App Attest are not present, matching the current debug/support-target decision.
- IPA export remains blocked by distribution signing. `flutter build ipa` and a direct `xcodebuild -exportArchive -allowProvisioningUpdates` export both report `No Accounts`, no signing certificate `"iOS Distribution"`, and no profiles for `com.catchdates.app`.
- Chrome is currently signed into the Apple Developer portal. Creating an Apple Distribution certificate/profile is still paused for explicit action-time confirmation because it creates persistent signing material.
- `security find-identity -v -p codesigning` currently reports three valid `Apple Development: Suvrat Garg (2XD79W43F9)` identities and no Apple Distribution identity.
- Verify Firebase App Check registrations for the exact dev/staging/prod iOS Firebase app IDs before enabling App Check enforcement.
- Verify staging before treating it as a real Firebase environment.

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

Status: reachable; Profile attach works; app stops on Firebase/Auth runtime config.

Evidence:
- Earlier Profile run built, installed, launched, and `devicectl` showed `Runner.app/Runner` running on device, but Flutter did not discover the Dart VM Service after 60 seconds.
- Current `flutter devices` sees `Suvrat's iPhone` over USB, iOS `26.0.1`.
- `flutter run -d 00008120-001A152E3EEB401E --profile --flavor dev --dart-define=APP_ENV=dev` built, installed, launched, and exposed a Dart VM Service / DevTools URL.
- The run logs Firebase App Check API `SERVICE_DISABLED` for project `catchdates-dev` / project number `619661127800`.
- After the App Check failures, the process stopped in FirebaseAuth iOS `PhoneAuthProvider.verifyPhoneNumber` with a Swift runtime nil-unwrap while starting phone verification. Treat this as a Firebase project/App Check/APNs/phone-auth setup issue until logs prove otherwise.
- `gcloud` is not installed or not on this shell's PATH, so the Firebase App Check API could not be enabled via CLI in this pass.

Canonical next action:
- Enable Firebase App Check API for `catchdates-dev`, `catchdates-staging`, and `catch-dating-app-64e51`.
- Register the printed dev-device App Check debug token in the dev Firebase project's App Check settings.
- Verify or upload the APNs auth key for the dev and staging Firebase iOS apps, because iOS phone auth depends on APNs/reCAPTCHA fallback being correctly configured.
- Rerun physical iPhone Profile after those Firebase config changes.

### 8. Apple `codesign --verify` trust-chain warning

Status: still open after Apple UI and artifact inspection.

Evidence:
- Current signed dev/staging/prod Profile builds succeed with automatic signing and team `2HQBK4UMUT`.
- Strict local `codesign --verify --deep --strict --verbose=4 build/ios/iphoneos/Runner.app` still reported `CSSMERR_TP_NOT_TRUSTED`.
- Prod archive creation succeeds, but App Store IPA export is blocked on missing Apple Distribution signing identity/profile.
- macOS dev/staging/prod builds also succeed. Strict local `codesign --verify --deep --strict --verbose=4 build/macos/Build/Products/Release-prod/Catch.app` reports the same `CSSMERR_TP_NOT_TRUSTED` trust-chain error.
- The source macOS `Runner/Release.entitlements` file contains only sandbox, network client, and photo-library entitlements. The built local macOS prod app includes `get-task-allow=true` because it is development-signed, not distribution-signed.

Canonical next action:
- First complete App Store distribution signing and IPA export for iOS.
- Then verify the exported IPA. Inspect Keychain trust for Apple Worldwide Developer Relations / Apple Development / Apple Distribution certificate chains if strict verification still fails.
- For macOS, defer distribution-grade signing/hardened runtime/notarization unless macOS stops being debug-only.
