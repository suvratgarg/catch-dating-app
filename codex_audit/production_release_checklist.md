# Production Release Checklist

Created: 2026-04-29
Last updated: 2026-05-01

Purpose: track the work needed to make Catch production-ready for store distribution, using Code With Andrea's public "Flutter in Production" curriculum as the learning path and translating each topic into repo-specific implementation tasks.

Important constraint: this document should not copy paid course material verbatim. It records public module topics, our app-specific decisions, implementation notes, and verification evidence. If the course/checklist is opened in the browser, add only short paraphrased takeaways and app-specific actions.

## Source Map

- Code With Andrea, "Flutter in Production" public course page: covers flavors/environments, error monitoring, analytics, release management, CI/CD, and store shipping.
- Code With Andrea, "Intro to the Flutter App Release Checklist": says the course includes module-end checklists and a reusable Notion release checklist.
- Code With Andrea, "Flutter App Release Checklist" Notion page supplied by Suvrat: Version 7, released 30 April 2025. The page was read through Chrome/Computer Use because direct web fetch returned a Notion 404.
- Public curriculum areas used here:
  - Launcher icons and splash screens
  - Flavors and environments
  - Error monitoring with Sentry and Crashlytics
  - Analytics with Mixpanel and Firebase Analytics
  - Force update strategies
  - In-app reviews
  - Landing page, privacy policy, terms, and settings/about links
  - Accessibility
  - App security
  - iOS App Store release
  - Android Play Store release
  - Release automation with Codemagic or GitHub Actions
  - Code push with Shorebird
  - Automated screenshots
  - Feature toggles and A/B testing

## Status Legend

- `todo`: not started
- `in_progress`: partially implemented or under review
- `blocked`: waiting on account, product, legal, store, or credential input
- `done`: implemented and verified
- `defer`: intentionally postponed for first release

## Current Repo Baseline

- App identity: Catch, a Flutter/Firebase run-club dating app focused on India.
- Store listing name: `Catch Dating`, because `Catch` alone is short but not descriptive enough for App Store / Play Store discovery.
- Environments: `APP_ENV` supports `dev`, `staging`, and `prod` through `lib/core/app_config.dart` and `lib/firebase_options_<env>.dart`.
- Firebase: Auth, Firestore, Storage, Functions, Messaging, and App Check are already present.
- App Check: Android uses Play Integrity, iOS/macOS uses App Attest, and web uses reCAPTCHA Enterprise. Firestore, Storage, Auth, and callable Functions now enforce App Check in dev, staging, and prod.
- Push: native Android/iOS push support exists; web public VAPID keys are present in the checked-in dart-define files. macOS push remains intentionally disabled.
- Error logging: Firebase Crashlytics is wired behind `ErrorLogger`; dashboard
  visibility and symbolication still need release-build verification.
- Analytics: Firebase Analytics is wired behind `AppAnalytics` with an event
  taxonomy and route observers. Dashboard/DebugView verification is still
  needed before beta users.
- Force update: a Firestore-backed force-update provider, platform-specific
  minimum build gates, semantic-version fallback, and blocking update screen
  exist. Dev, staging, and prod have `config/app_config` seeded for the current
  `1.0.0+1` build. The startup gate now surfaces loading/error states instead
  of silently allowing startup when the config check fails.
- In-app review: no `in_app_review` package is wired yet.
- Accessibility: no dedicated `accessibility_tools` dependency or release accessibility audit is documented yet.
- Security/privacy: Firestore rules, Storage rules, App Check enforcement, callable App Check guards, blocking/reporting/account deletion, and secret-ignore hardening exist. A final privacy/store-form audit is still needed.
- Release verification: web, Android APK/App Bundle, macOS dev/staging/prod, iOS simulator, signed iOS dev/staging/prod Profile builds, and the prod iOS archive have recent audit notes in the active release setup tracker.
- Apple signing status: iOS App Store IPA export now passes from the active
  release tracker; keep using that tracker for the freshest signing and
  notarization state.
- macOS direct distribution status: Developer ID signing, secure timestamp,
  notarization, stapling, and Gatekeeper validation now pass from the active
  release tracker. macOS minimum deployment target is 11.0.
- Dirty worktree at tracker creation: unrelated UI/audit edits already exist and must be preserved.

## Work Plan

### 1. App Identity, Launcher Icons, And Splash Screens

Status: `in_progress`

Why it matters: store users see the icon before they see the app, and native launch screens affect first-run polish and perceived startup reliability.

Catch-specific tasks:

- Confirm final app name, bundle display name, and app icon artwork for dev/staging/prod. App display name is now `Catch` on Android, iOS, and web; side-by-side dev/staging/prod display names still depend on the flavors decision.
- Add or validate `flutter_launcher_icons` configuration. Done in `pubspec.yaml`.
- Generate Android legacy/adaptive icons, iOS icons, and web icons. Done from `assets/branding/catch_icon.png`.
- Add or validate `flutter_native_splash` configuration. Done in `pubspec.yaml`.
- Confirm splash color/branding against the app theme and design handoff. First pass uses the Sunset palette: light `#FBF3E9`, dark `#120D09`, icon gradient `#FF4E1F` -> `#FF9A5C` -> `#FFC78A`.
- Verify Android/iOS/web startup screens after generation. Web, Android, and iOS simulator build verification passed; visual startup checks are still needed on a simulator/device/browser.

Current evidence:

- `assets/branding/catch_icon.svg` is the editable source icon.
- `assets/branding/catch_icon.png` is the 1024px generator source.
- `flutter_launcher_icons` and `flutter_native_splash` are in `dev_dependencies`.
- Generated resources were written under Android `res/`, iOS asset catalogs/storyboard, and web favicon/icons/splash files.
- `ios/Runner/Info.plist` now uses `$(APP_DISPLAY_NAME)` for `CFBundleDisplayName` and `CFBundleName`; the flavor configs resolve this to `Catch Dev`, `Catch Staging`, or `Catch`.

Teaching notes:

- Launcher icons are installed into platform projects at build time; they are not normal Flutter widgets.
- Splash screens are native startup UI shown before Dart paints the first frame, so they need platform configuration rather than a Flutter-only screen.

Verification:

- `flutter pub add --dev flutter_launcher_icons flutter_native_splash` passed.
- `dart run flutter_launcher_icons` passed.
- `dart run flutter_native_splash:create` passed.
- `flutter analyze` passed.
- `flutter build web --dart-define=APP_ENV=dev` passed.
- `flutter build apk --dart-define=APP_ENV=dev` passed.
- `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` passed on recheck after the parallel build-fix work landed.
- Visual check still needed on a simulator/device/browser.

### 2. Flavors And Runtime Environments

Status: `in_progress`

Why it matters: dev, staging, and production must not accidentally share credentials, Firebase projects, analytics streams, or app identities.

Catch-specific tasks:

- Audit current `APP_ENV` setup against Android package IDs, iOS bundle IDs, app names, and Firebase app IDs.
- Decide whether current Dart-define environments are enough for first release or whether true platform flavors are required now. Decision: use true flavors for scalable side-by-side installs.
- Ensure prod/staging Firebase option files contain real project values before any store submission. Done for Dart options and checked-in native/web config files.
- Make environment selection obvious in local run, build scripts, README, and CI.
- Ensure dev/staging builds cannot pollute production analytics or crash-reporting projects.

Current evidence:

- `lib/core/app_config.dart` resolves `dev`, `staging`, and `prod`.
- `tool/dart_defines/dev.json`, `tool/dart_defines/staging.json`, and `tool/dart_defines/prod.json` exist.
- `firebase/README.md` documents Firebase environment selection.
- Firebase aliases are now `dev` -> `catchdates-dev`, `staging` -> `catchdates-staging`, and `prod` -> `catch-dating-app-64e51`.
- `lib/firebase_options_dev.dart`, `lib/firebase_options_staging.dart`, and `lib/firebase_options_prod.dart` now contain real Firebase options.
- Android product flavors are wired:
  - `dev`: app label `Catch Dev`, package `com.catchdates.app.dev`
  - `staging`: app label `Catch Staging`, package `com.catchdates.app.staging`
  - `prod`: app label `Catch`, package `com.catchdates.app`
- Android flavor-specific Firebase config files live under `android/app/src/<flavor>/google-services.json`.
- Environment source configs live under `firebase/<env>/` for Android, iOS, macOS, and web.
- iOS and macOS flavor schemes/configurations are wired through `tool/configure_apple_flavors.rb`:
  - `dev`: app label `Catch Dev`, bundle ID `com.catchdates.app.dev`, Firebase env `dev`
  - `staging`: app label `Catch Staging`, bundle ID `com.catchdates.app.staging`, Firebase env `staging`
  - `prod`: app label `Catch`, bundle ID `com.catchdates.app`, Firebase env `prod`
- iOS/macOS builds copy the matching `firebase/<env>/<platform>/GoogleService-Info.plist` into the built app bundle through a build phase, so Xcode schemes and Firebase config stay aligned.
- Android debug SHA-256 fingerprints were added to the dev and staging Firebase Android apps.
- Apple Developer App IDs now exist for `com.catchdates.app.dev`, `com.catchdates.app.staging`, and `com.catchdates.app`, with Push Notifications and App Attest enabled.
- Xcode-managed development/Profile provisioning profiles now exist for all three iOS bundle IDs.
- Final Play app-signing fingerprints remain pending until Play Console enrollment.
- iOS App Store IPA export now passes for prod; TestFlight upload/install
  validation is still pending.

Teaching notes:

- Dart defines choose runtime behavior inside Flutter.
- Platform flavors/product flavors also change native app identity, bundle ID, icons, app name, and store-install coexistence. Catch now needs them because dev/staging/prod must not share Firebase data or store identities.

Verification:

- `flutter analyze` passed.
- `flutter build apk --debug --flavor dev --dart-define=APP_ENV=dev` passed.
- `flutter build apk --debug --flavor staging --dart-define=APP_ENV=staging` passed.
- `flutter build apk --debug --flavor prod --dart-define=APP_ENV=prod` passed.
- APK metadata check confirmed `app-dev-debug.apk` package `com.catchdates.app.dev` and label `Catch Dev`.
- APK metadata check confirmed `app-staging-debug.apk` package `com.catchdates.app.staging` and label `Catch Staging`.
- APK metadata check confirmed `app-prod-debug.apk` package `com.catchdates.app` and label `Catch`.
- Prod release APK/App Bundle builds now pass with the locally generated upload keystore. The keystore and `android/key.properties` are intentionally ignored by git.
- `ruby tool/configure_apple_flavors.rb` passed.
- `pod install` passed in `ios/`.
- `pod install` passed in `macos/`.
- `flutter build ios --simulator --no-codesign --flavor dev --dart-define=APP_ENV=dev` passed.
- `flutter build ios --simulator --no-codesign --flavor staging --dart-define=APP_ENV=staging` passed; plist inspection confirmed label `Catch Staging`, bundle ID `com.catchdates.app.staging`, and Firebase project `catchdates-staging`.
- `flutter build ios --simulator --no-codesign --flavor prod --dart-define=APP_ENV=prod` passed.
- `./tool/flutter_with_env.sh dev build ios --profile` passed; signed artifact inspection confirmed explicit profile `iOS Team Provisioning Profile: com.catchdates.app.dev`, APNs development entitlement, App Attest development entitlement, and Firebase project `catchdates-dev`.
- `./tool/flutter_with_env.sh staging build ios --profile` passed; signed artifact inspection confirmed explicit profile `iOS Team Provisioning Profile: com.catchdates.app.staging`, APNs development entitlement, App Attest development entitlement, and Firebase project `catchdates-staging`.
- `./tool/flutter_with_env.sh prod build ios --profile` passed; signed artifact inspection confirmed explicit profile `iOS Team Provisioning Profile: com.catchdates.app`, APNs development entitlement, App Attest development entitlement, and Firebase project `catch-dating-app-64e51`.
- `./tool/flutter_with_env.sh prod build ipa --release` now archives the flavored prod scheme and validates app settings: display name `Catch`, bundle ID `com.catchdates.app`, version `1.0.0`, build `1`, deployment target `15.0`.
- iOS App Store IPA export now passes with `ios/ExportOptions.prod.plist`; the
  exported IPA is App Store signed for `com.catchdates.app` with production APNs,
  production App Attest, and `get-task-allow=false`.
- Xcode Settings > Accounts is signed in as `Suvrat Garg`, role `Admin`, and the iOS/macOS Signing & Capabilities UI is correct for development signing. Historical keychain notes that only Apple Development identities existed are superseded by the active release tracker: Apple Distribution export and Developer ID direct distribution now both validate.
- `flutter build macos --debug --flavor dev --dart-define=APP_ENV=dev` passed; plist inspection confirmed label `Catch Dev`, bundle ID `com.catchdates.app.dev`, and Firebase project `catchdates-dev`.
- `flutter build macos --debug --flavor staging --dart-define=APP_ENV=staging` passed; plist inspection confirmed label `Catch Staging`, bundle ID `com.catchdates.app.staging`, and Firebase project `catchdates-staging`.
- `flutter build macos --debug --flavor prod --dart-define=APP_ENV=prod` passed; plist inspection confirmed label `Catch`, bundle ID `com.catchdates.app`, and Firebase project `catch-dating-app-64e51`.
- `./tool/flutter_with_env.sh dev build macos`, `./tool/flutter_with_env.sh staging build macos`, and `./tool/flutter_with_env.sh prod build macos` all passed. The built release-flavor macOS app bundles also inspect correctly for app name, bundle ID, and embedded Firebase app ID.
- The production macOS build path now targets macOS 11.0 and supports direct
  distribution through Developer ID, hardened runtime, secure timestamp,
  notarization, stapling, and Gatekeeper validation. See the active release
  tracker for the exact artifact and notarization submission IDs.

### 3. Error Monitoring

Status: `in_progress`

Why it matters: after release, user crashes must be visible, grouped, symbolicated, and tied to app version/environment.

Decision to make:

- Choose Sentry, Firebase Crashlytics, or both. First implementation uses Firebase Crashlytics.
- Recommended default for Catch: start with Firebase Crashlytics because the app is already Firebase-heavy, then add Sentry later only if richer issue workflow, breadcrumbs, user feedback, or cross-platform web coverage becomes important.

Catch-specific tasks:

- Add selected monitoring package. Done: `firebase_crashlytics`.
- Replace debug-only `ErrorLogger` behavior with production reporting. Done behind the `CrashReporter` abstraction.
- Attach environment, release version, build number, and platform. Done through Crashlytics custom keys when reporting is enabled.
- Attach signed-in user id where privacy-safe. Not done yet; defer until analytics/privacy consent posture is decided.
- Capture Flutter framework errors, platform dispatcher errors, provider async errors, and explicitly caught important domain failures. Framework/platform/provider unexpected errors are wired; expected `AppException`s are intentionally not reported.
- Configure symbol/debug-file upload for Android and iOS release builds. Android Crashlytics Gradle plugin is configured; iOS dSYM/upload verification is still needed on an archive/TestFlight-style build.
- Add a non-production test crash path guarded from production users. Not done yet.

Current evidence:

- `lib/main.dart` registers global Flutter and platform error handlers and initializes `ErrorLogger`.
- `AsyncErrorLogger` observes Riverpod async errors.
- `lib/exceptions/error_logger.dart` owns the Crashlytics integration and keeps app code vendor-neutral.
- Android applies `com.google.firebase.crashlytics` Gradle plugin `3.0.6`.
- Android and iOS disable native Crashlytics auto-collection by default; `ErrorLogger.initialize()` enables reporting only for production release builds.
- `test/exceptions/error_logger_test.dart` covers collection gating, custom keys, expected app exceptions, and Flutter error forwarding.

Teaching notes:

- Capturing an error is only half the job; readable stack traces in production need mapping files, dSYMs, or equivalent debug artifacts uploaded during release.
- Expected user errors should not be reported like crashes, or the dashboard becomes noisy and expensive.

Verification:

- `flutter test test/exceptions/error_logger_test.dart` passed.
- `flutter analyze` passed.
- `flutter build web --dart-define=APP_ENV=dev` passed after Crashlytics was added; web does not report to Crashlytics.
- `flutter build apk --dart-define=APP_ENV=dev` passed after Crashlytics package, Gradle plugin, and native collection metadata changes.
- Trigger test exceptions in dev/staging. Not done yet.
- Confirm issue appears in the selected dashboard with environment and app version. Not done yet.
- Confirm Android and iOS release stack traces are symbolicated. Android Gradle plugin is present; dashboard verification is still needed. iOS simulator build now passes, but iOS archive/dSYM verification is still pending.

### 4. Analytics

Status: `in_progress`

Why it matters: release decisions need real usage signals, not guesses.

Decision to make:

- Choose Firebase Analytics, Mixpanel, or both. First implementation uses Firebase Analytics.
- Recommended default for Catch: start with Firebase Analytics for lower setup cost and Firebase integration. Keep an internal analytics abstraction so Mixpanel can be added without rewriting feature code.

Catch-specific tasks:

- Define an event taxonomy before adding calls everywhere. First-pass constants now live in `AnalyticsEvents` and `AnalyticsParameters`.
- Track navigation/screen views from GoRouter. Done for the root navigator and all stateful shell branch navigators.
- Track core funnel events:
  - auth started/completed
  - onboarding started/completed/drop-off step
  - run club viewed/joined/left
  - run viewed/booked/payment started/payment completed/payment failed
  - attended run viewed
  - swipe sent
  - match created/viewed
  - chat message sent
  - profile edited
- Add opt-out/consent handling where legally or product-wise required. Not done yet.
- Identify signed-in users only with privacy-safe IDs. API exists through `AppAnalytics.setUserId`; it is not wired to auth yet pending privacy/consent posture.
- Keep PII out of event names and parameters. First-pass event/parameter constants use IDs and lifecycle actions only.

Current evidence:

- `firebase_analytics` is installed.
- `lib/analytics/app_analytics.dart` owns the vendor-neutral analytics facade.
- `FirebaseAnalyticsReporter` is the only class that imports the Firebase Analytics SDK directly.
- `AppAnalytics.initialize()` disables collection outside production release builds by default.
- Product events receive app environment, platform, version, and build number parameters.
- Event names are validated before they hit Firebase so spaces, hyphens, and overlong names fail in tests.
- `AnalyticsRouteObserver` logs route names as screen views from the root GoRouter navigator and each tab branch navigator.
- `lib/main.dart` initializes `AppAnalytics` next to `ErrorLogger` and overrides `appAnalyticsProvider` with that initialized instance.

Teaching notes:

- Good analytics starts with questions: "where do users drop off?" and "which loops create value?" The code should reflect those questions rather than logging every tap.
- Analytics calls should sit behind an app service so product code does not depend directly on a vendor SDK.
- Firebase's Flutter setup recommends adding `firebase_analytics`, then logging app events through the SDK. Firebase's screen-view guidance says single-activity apps should manually log screen views, which is why GoRouter observers are the right integration point for Catch.

Verification:

- `flutter test test/analytics/app_analytics_test.dart` passed.
- `flutter analyze` passed.
- `flutter build web --dart-define=APP_ENV=dev` passed.
- `flutter build apk --dart-define=APP_ENV=dev` passed.
- DebugView or provider dashboard confirms events. Not done yet because collection is intentionally disabled outside production release builds until we have real staging/prod Firebase apps.
- Manual run through auth/onboarding/booking sends expected events in dev or staging only. Not done yet; first pass only wires the analytics foundation and screen tracking.

### 5. Force Update

Status: `in_progress`

Why it matters: once the app talks to real backend contracts, old clients may become unsafe or incompatible.

Recommended default for Catch:

- Keep the current Firestore `config/app_config` version endpoint for minimum
  supported builds. Add Firebase Remote Config later if broader feature toggles
  need console-editable rollout controls.
- Show a blocking update screen only when the installed build is below the
  minimum supported build for that platform.

Catch-specific tasks:

- Add Remote Config or a small Functions/Firestore-backed version endpoint. Done with Firestore `config/app_config`.
- Define per-platform fields and store URLs. Done with `minBuildAndroid`,
  `minBuildIos`, `minBuildWeb`, `minBuildMacos`, `storeUrlAndroid`, and
  `storeUrlIos`; legacy `minVersion` remains as a backward-compatible fallback.
- Add startup check after Firebase initialization and before normal app shell use. Done through `forceUpdateRequiredProvider`.
- Design a blocking update UI and a non-blocking recommended update UI. Blocking `UpdateRequiredScreen` exists; recommended update UI is not implemented.
- Ensure dev/staging can override values safely.

Current evidence:

- `lib/force_update/data/app_version_repository.dart`
- `lib/force_update/data/force_update_provider.dart`
- `lib/force_update/domain/app_version_config.dart`
- `lib/force_update/domain/version.dart`
- `lib/force_update/presentation/update_required_screen.dart`
- `test/force_update/version_test.dart`

Teaching notes:

- Force update is a backend compatibility tool, not a marketing prompt.
- Build numbers are better than semantic versions for comparison because stores require monotonically increasing build codes.

Verification:

- `flutter test test/force_update/version_test.dart` passed for semantic
  version fallback, per-platform build selection, and build-number comparison.
- Live Firestore `config/app_config` was created and read back in dev, staging,
  and prod on 2026-05-01 with `minVersion: 1.0.0` and all platform
  `minBuild*` values set to `1`.
- Local dev web runtime verification passed on 2026-05-01: raising dev
  `minBuildWeb`/`minVersion` above the current build showed the blocking
  update-required screen, and resetting them to `minBuildWeb: 1` and
  `minVersion: 1.0.0` restored normal onboarding startup.
- Dev and staging Firestore rules were deployed on 2026-05-01 after verifying
  their live rulesets were stale and missing the public `config/app_config`
  read rule. Dev, staging, and prod active rulesets now all include the
  checked-in force-update config rule.
- Widget tests for blocking/recommended/current states.

Backend verification on 2026-05-01:

- `flutter test --concurrency=1` passed across the repo.
- `npm --prefix functions run lint` passed.
- `npm --prefix functions test` passed.
- `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"` passed.
- `firebase deploy --only functions` completed for `catchdates-dev`,
  `catchdates-staging`, and `catch-dating-app-64e51`.
- `firebase functions:list` verified the same 17 deployed v2 Node.js 24
  functions in `asia-south1` for dev, staging, and prod.

### 6. In-App Reviews

Status: `todo`

Why it matters: asking at the right moment increases reviews without interrupting core workflows.

Catch-specific tasks:

- Add `in_app_review`.
- Choose review triggers that correlate with success:
  - after a user attends a run and completes a positive flow
  - after a match/chat milestone
  - after multiple successful bookings
- Add local or remote throttling so the prompt is not spammy.
- Add fallback "Rate Catch" link in settings/profile.

Teaching notes:

- The OS decides whether the review dialog appears. Our job is to ask sparingly at high-satisfaction moments and provide a store-link fallback.

Verification:

- Unit tests for eligibility/throttle logic.
- Manual trigger on Android/iOS test builds.

### 7. Landing Page, Privacy Policy, And Terms

Status: `in_progress`

Why it matters: stores require privacy disclosures, and users need accessible support/legal links.

Catch-specific tasks:

- Audit existing `website/` and Firebase Hosting setup.
- Confirm public URLs for:
  - marketing/landing page
  - privacy policy
  - terms of use
  - support/contact
  - account deletion instructions
- Add links inside app settings/profile.
- Align app-store privacy answers with actual data collection, analytics, crash reporting, payments, location/map usage, push notifications, and account deletion.

Teaching notes:

- Legal/privacy pages must describe the actual app behavior. They should be updated whenever telemetry, payments, account deletion, or data retention changes.

Verification:

- Open each public URL.
- Tap each in-app link.
- Cross-check App Store Connect and Play Console privacy forms against implementation.

### 8. About And Settings Page

Status: `in_progress`

Why it matters: production users and store reviewers need a predictable place to find app metadata, legal links, OSS licenses, support, account controls, and preference toggles.

Catch-specific tasks:

- Decide whether this belongs under the existing profile/settings surface or a dedicated about/settings screen. Done: settings live under the profile/You surface.
- Add links to the app website, privacy policy, terms of use, support/contact, and account deletion instructions. Partially done; final public legal/support URLs still need confirmation.
- Add a "Rate Catch" / store listing action after store IDs exist.
- Show open source licenses through Flutter's license page.
- Add user-facing app configuration controls that we genuinely support, such as analytics opt-out, notification settings, or theme mode.
- Ensure settings links open reliably on Android, iOS, and web.

Current evidence:

- `lib/safety/presentation/settings_screen.dart`
- `lib/activity/presentation/activity_screen.dart`
- safety/account-deletion flows are implemented in the app and Functions

Teaching notes:

- Store reviewers often use the settings/about page to verify privacy policy, account deletion, support, and licenses. A missing link can become a review blocker even if the feature code works.

Verification:

- Widget test for settings rows and URL-launch intent where practical.
- Manual tap-through on Android/iOS/web.
- Confirm OSS license page opens.

### 9. Accessibility

Status: `todo`

Why it matters: accessibility is a release-quality requirement, not only a compliance checkbox. It catches real usability bugs such as unreadable contrast, clipped large text, missing labels, and tiny hit targets.

Catch-specific tasks:

- Decide whether to add `accessibility_tools` for debug-time checks.
- Audit major flows with text scaling:
  - auth
  - onboarding
  - dashboard
  - club discovery/detail
  - run booking/payment
  - swiping
  - matches/chat
  - profile/settings
- Add semantic labels for icon-only controls, images, swipe controls, map controls, and tab navigation.
- Check color contrast against the Catch palette.
- Check touch target sizes and keyboard/screen-reader traversal order.
- Test VoiceOver on iOS and TalkBack on Android before release.

Teaching notes:

- Flutter gives us many accessibility semantics automatically for standard widgets, but custom controls, images, map surfaces, and gesture-heavy screens still need explicit work.

Verification:

- Run the app with large text settings.
- Manual VoiceOver/TalkBack pass on the core release flows.
- Add targeted widget tests for important semantic labels where stable.

### 10. App Security And Privacy

Status: `in_progress`

Why it matters: Catch handles identity, photos, chat, attendance, dating preferences, payments, and location-adjacent data. Release readiness needs a clear trust-boundary pass, not just a green build.

Catch-specific tasks:

- Confirm secret API keys remain server-side, especially payment keys and privileged Firebase/Admin credentials.
- Inventory any client-side API keys and decide whether they are public identifiers, obfuscated values, or should be moved server-side.
- Confirm sensitive files are ignored and not tracked.
- Minimize personally identifiable information collected by app flows and analytics.
- Avoid logging sensitive data in Flutter, Functions, crash reports, and analytics.
- Review on-device storage for sensitive values and decide whether encryption is needed.
- Review Firestore rules, Functions authorization checks, App Check enforcement, and Storage access.
- Confirm backups/export strategy for critical Firestore data.
- Review common mobile/web risks: broken authz, insecure direct object references, excessive data exposure, insecure logging, weak rate limits, dependency vulnerabilities.
- Document privacy posture for app-store forms.

Current evidence:

- Firebase App Check exists.
- Prior work hardened secret-ignore patterns and Android signing examples.
- Account deletion has a dedicated plan file in `codex_audit/`.
- Payment server verification has been hardened in earlier work.

Teaching notes:

- Security work starts with ownership: decide which data the client may read/write, which data only backend code may mutate, and which identifiers are safe to expose.

Verification:

- Review `firestore.rules`, Storage rules, and callable Functions authorization.
- Run dependency audit where available.
- Exercise unauthenticated, wrong-user, and cross-resource access attempts in emulator tests where practical.

### 11. iOS App Store Release

Status: `in_progress`

Why it matters: iOS release requires native identifiers, signing, privacy manifests, store metadata, TestFlight, and review readiness.

Catch-specific tasks:

- Confirm Apple Developer team, bundle ID, capabilities, and provisioning.
- Confirm App Attest entitlement is present for production App Check.
- Audit iOS permissions strings in `Info.plist`.
- Add/validate privacy manifest requirements.
- Prepare App Store Connect app record, screenshots, privacy nutrition labels, age rating, support URL, marketing URL, and review notes.
- Produce signed archive/upload path.
- Validate TestFlight distribution before public release.

Current evidence:

- App Store IPA export passes for prod using
  `./tool/flutter_with_env.sh prod build ipa --release --export-options-plist=ios/ExportOptions.prod.plist`.
- Exported IPA artifact: `build/ios/ipa/Catch.ipa`.
- Exported IPA entitlements are production-correct: bundle
  `com.catchdates.app`, production APNs, production App Attest, and
  `get-task-allow=false`.
- Physical-device profile runtime has been verified on the available iPhone in
  this setup pass; broader TestFlight install validation is still pending.

Teaching notes:

- A successful `flutter build ios --no-codesign` proves Dart/native compilation, not distribution readiness. Store release also needs signing, entitlements, metadata, privacy, and review flow.

Verification:

- `flutter build ios --release --dart-define=APP_ENV=prod`
- Xcode archive or CLI upload to App Store Connect.
- TestFlight install on a clean device.

### 12. Android Play Store Release

Status: `in_progress`

Why it matters: Android release requires package identity, signing, Play Console setup, testing tracks, Data Safety, and production artifacts.

Catch-specific tasks:

- Confirm final Android application ID.
- Confirm upload keystore storage and `key.properties` handling.
- Build Android App Bundle for production.
- Configure Play App Signing.
- Prepare Play Console app content, Data Safety, store listing, screenshots, privacy policy, and testing track.
- Verify Play Integrity/App Check production setup.

Current evidence:

- Current prod release APK and App Bundle builds pass with the ignored local
  upload keystore.
- Fresh Play upload artifact:
  `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.
- `apksigner verify --print-certs` passes for
  `build/app/outputs/flutter-apk/app-prod-release.apk`; upload-key SHA-256 is
  `3088f763a60fd9f7ca99204d6a68ef93a30263a697e563ef883b29dbbc7ae23e`.
- `android/key.properties.example` and secret-ignore hardening exist from
  earlier release-readiness work.
- Play app-signing fingerprints remain pending until Play Console enrollment.

Teaching notes:

- Play Store submission should use an AAB, not just an APK. APKs are useful for local install testing; AABs are the store distribution artifact.

Verification:

- `flutter build appbundle --release --dart-define=APP_ENV=prod`
- Upload to internal testing.
- Install from Play internal testing on a clean Android device.

### 13. Release Automation

Status: `todo`

Why it matters: manual releases are slow and easy to misconfigure once signing, symbols, tests, and upload steps matter.

Decision to make:

- Codemagic is faster to set up for Flutter mobile signing.
- GitHub Actions gives more control and keeps CI close to the repo.
- Recommended default for Catch: start with GitHub Actions for analyze/test/build checks, then decide whether mobile store upload automation should use Codemagic or Fastlane once credentials are finalized.

Catch-specific tasks:

- Add CI workflow for format/analyze/tests.
- Add build workflow for Android app bundle.
- Add iOS build/archive workflow once signing credentials are settled.
- Add crash symbol upload step if Sentry/Crashlytics requires it.
- Store secrets outside the repo.
- Document release commands and rollback steps.

Teaching notes:

- CI should make the release path boring: same commands, same environment, every time. Secrets and signing are the hard part, not the Flutter build command.

Verification:

- Green CI on pull request.
- Green manual release workflow on a protected branch or tag.
- Artifact generated and retained.

### 14. Code Push With Shorebird

Status: `defer`

Why it matters: code push can speed up small Dart-side fixes after release, but it adds another release channel and operational responsibility.

Catch-specific tasks:

- Decide whether code push is acceptable for first public release.
- If adopted, define which fixes are allowed through code push and which require store review.
- Integrate only after normal store release flow is reliable.

Teaching notes:

- Code push is not a substitute for app-store release discipline. It is an additional patch path with its own tracking and rollback rules.

Verification:

- Deferred until store release process is stable.

### 15. Automated Screenshots

Status: `todo`

Why it matters: app-store screenshots need to stay current as UI changes.

Catch-specific tasks:

- Decide manual screenshots vs automated Maestro/Fastlane flow for first release.
- Identify screenshot journeys:
  - onboarding
  - run club discovery
  - run detail/booking
  - swiping
  - matches/chat
  - profile
- Seed deterministic test data for screenshots.
- Generate screenshots for required iOS and Android device sizes.

Teaching notes:

- Store screenshots are a product artifact, not just QA evidence. Stable test data matters more than pixel-perfect automation at the beginning.

Verification:

- Screenshot set accepted by App Store Connect and Play Console.

### 16. Feature Toggles And A/B Testing

Status: `todo`

Why it matters: production apps need a way to disable risky features or gradually roll out changes.

Recommended default for Catch:

- Start with ops toggles/kill switches via Firebase Remote Config.
- Postpone A/B testing until core analytics is reliable.

Catch-specific tasks:

- Define first toggles:
  - booking enabled
  - paid booking enabled
  - chat enabled
  - push notifications enabled
  - swiping enabled
  - maintenance mode
- Add typed config service with defaults that fail safely.
- Add UI behavior for disabled features.
- Document who can change toggles and how changes are validated.

Teaching notes:

- A kill switch should be boring and explicit. It should protect the backend and user experience when a production issue is found.

Verification:

- Unit tests for config parsing/defaults.
- Manual Remote Config change in dev/staging changes app behavior.

## Suggested Implementation Order

1. Error monitoring
2. Analytics foundation and event taxonomy
3. Force update and Remote Config foundation
4. Feature toggles/kill switches
5. App identity, launcher icons, and splash screens
6. App security/privacy audit
7. Accessibility audit
8. Landing/legal/about/settings links audit
9. In-app reviews
10. iOS/Android store release preparation
11. CI/release automation
12. Automated screenshots
13. Shorebird/code push decision

Rationale: monitoring and analytics should exist before beta users arrive; Remote Config then gives us force updates and kill switches. Security, accessibility, legal links, and store readiness are review blockers, so they should be handled before we spend time on automation and optional code-push workflows.

## Session Log

### 2026-04-29

- Created this tracker.
- Public Code With Andrea course pages were reviewed for the curriculum and release checklist structure.
- Current repo baseline was checked through `PROJECT_CONTEXT.md`, `pubspec.yaml`, `lib/main.dart`, `lib/core/app_config.dart`, and `lib/exceptions/error_logger.dart`.
- Reconciled the tracker against the Notion checklist page supplied by Suvrat. Added missing areas for About/Settings, Accessibility, and App Security, and expanded the release sections with checklist-level tasks.
- Started checklist item 1. Added `assets/branding/catch_icon.svg` and `assets/branding/catch_icon.png`, added `flutter_launcher_icons` and `flutter_native_splash`, configured both generators in `pubspec.yaml`, generated Android/iOS/web icon and splash resources, and changed the iOS visible app name to `Catch`.
- Verification passed for `flutter analyze`, `flutter build web --dart-define=APP_ENV=dev`, and `flutter build apk --dart-define=APP_ENV=dev`.
- iOS simulator verification initially failed outside the icon/splash change path with CocoaPods/Firestore: `leveldb-library/db/dbformat.h:16:9 'util/coding.h' file not found`.
- Rechecked the iOS blocker after parallel build-fix work. `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` now passes and builds `build/ios/iphonesimulator/Runner.app` for `com.catchdates.app`.
- Audited checklist item 2. Dart-level `APP_ENV` exists, Firebase dev/staging/prod projects are now configured, and native identifiers are `com.catchdates.app.dev`, `com.catchdates.app.staging`, and `com.catchdates.app`. Apple/Play capabilities, App Check, APNs, and release SHA fingerprints still need follow-up.
- Started checklist item 3. Added Firebase Crashlytics, kept app code behind `ErrorLogger`/`CrashReporter`, wired Flutter framework and platform dispatcher fatal handlers, preserved Riverpod async error observation, disabled native auto-collection by default, and enabled reporting only for production release builds.
- Added focused error-logger tests and verified `flutter test test/exceptions/error_logger_test.dart`, `flutter analyze`, `flutter build web --dart-define=APP_ENV=dev`, and `flutter build apk --dart-define=APP_ENV=dev`.
- Added the Android Crashlytics Gradle plugin. Official Firebase docs say Flutter Crashlytics setup should include the plugin, and Android Gradle plugin v3 requires Google Services `4.4.1+`; this repo now uses Crashlytics plugin `3.0.6` and Google Services `4.4.4`.
- Clarified naming: product name is `Catch`, domain is `catchdates.com`, production app ID is `com.catchdates.app`, dev app ID is `com.catchdates.app.dev`, and staging app ID is `com.catchdates.app.staging`.
- Store listing name decision: use `Catch Dating`; keep installed app labels as `Catch`, `Catch Dev`, and `Catch Staging`.
- Created Firebase project `catchdates-dev` and Firebase project `catchdates-staging`. Existing project `catch-dating-app-64e51` remains the production candidate.
- Registered dev/staging Android, iOS, and web Firebase apps; updated `.firebaserc`, `lib/firebase_options_<env>.dart`, `firebase/<env>/`, and Android flavor-specific `google-services.json` files.
- Added Android product flavors for `dev`, `staging`, and `prod`; verified debug APKs for all three flavors, and confirmed APK labels/package IDs with `aapt dump badging`.
- Release Android prod builds now pass with the locally generated upload keystore and ignored `android/key.properties`.
- Added Apple flavor generation through `tool/configure_apple_flavors.rb`; generated iOS/macOS schemes and build configurations for `dev`, `staging`, and `prod`.
- Fixed Apple Firebase bundling so the static source plist remains in the repo but the build product receives exactly one flavor-selected plist from `firebase/<env>/ios` or `firebase/<env>/macos`.
- Verified iOS simulator flavor builds and macOS debug flavor builds after the Apple project changes. Local code is ready for side-by-side simulator/dev installs. Apple Developer now has explicit App IDs for `com.catchdates.app`, `com.catchdates.app.dev`, and `com.catchdates.app.staging`, each with Push Notifications and App Attest selected.
- Signed iOS dev/staging/prod Profile builds now pass with explicit Xcode-managed development profiles. The prod archive also passes, and the wrapper now auto-selects the prod flavor for `build ipa`.
- Historical blocker resolved: iOS App Store IPA export no longer fails on
  `No Accounts` / missing distribution signing. The active release tracker is
  now canonical for iOS signing/export status.
- Xcode UI recheck passed for development signing: Xcode is signed in as `Suvrat Garg` with Admin role; iOS Runner has automatic signing, Push Notifications, Background Modes, Photo Library usage, and App Attest across dev/staging/prod; macOS Runner has automatic signing, App Sandbox, and network/photo-library entitlements.
- Historical keychain note superseded: later release setup installed the needed
  Apple distribution identities and verified the current signed artifacts.
- Historical macOS build note superseded: current production macOS now goes
  further than compile/signing inspection and passes Developer ID signing,
  secure timestamp, hardened runtime, notarization, stapling, and Gatekeeper.
- Physical iPhone dev Profile now builds, installs, launches, and exposes the Dart VM Service. The remaining device-run blocker is Firebase runtime configuration: `catchdates-dev` has Firebase App Check API disabled, and phone verification then stops inside FirebaseAuth iOS.
- Re-ran `flutter analyze`; no issues found.

### 2026-04-30

- Firebase/App Check cleanup pass completed: dev, staging, and prod have
  Android, iOS/macOS, and web App Check providers; Firestore, Storage, Auth, and
  callable Functions enforce App Check; Functions are deployed in all three
  environments.
- Removed the legacy prod Firebase app registrations for
  `com.example.catch_dating_app`, `com.example.catchDatingApp`, and the old
  Windows web app. They are in Firebase's normal 30-day restorable removal
  window.
- Consolidated documentation so current Firebase state lives in
  `codex_audit/firebase_environment_current_state.md`, environment workflow
  lives in `firebase/README.md`, Functions defaults live in `functions/README.md`,
  and historical trackers are indexed from `codex_audit/README.md`.

### 2026-05-01

- Seeded live Firestore `config/app_config` in dev, staging, and prod for the
  current `1.0.0+1` build.
- Verified the serialized Flutter test suite, Functions lint/tests, and
  Firestore rules tests.
- Redeployed Functions to dev, staging, and prod, then confirmed each project
  exposes the same 17 v2 Node.js 24 functions in `asia-south1`.
- Registered the Firebase-documented local web App Check debug token generated
  by the dev browser. The raw token is not stored in the repo.
- Deployed Firestore rules to dev and staging to align the live rulesets with
  the checked-in rules. Prod already had the current `config/app_config` rule.
- Verified local dev web with App Check enforcement: elevated force-update
  config showed the update-required screen, then reset config showed normal
  onboarding startup.
- Android physical runtime smoke remains blocked by no connected Android device;
  iPhone, Chrome, and macOS targets are available for the next runtime pass.
- Release setup consolidation pass completed: the active release tracker now
  supersedes older config/signing blocker language across the edited markdown
  files.
- iOS App Store IPA export now passes; the old `No Accounts` / missing
  distribution certificate/profile blocker is resolved for the current local
  setup.
- macOS direct distribution now passes after Developer ID setup, secure
  timestamping, notarization, stapling, Gatekeeper validation, and raising the
  macOS deployment target to 11.0.

## Open Questions

- Which crash/error provider should we use long term if Firebase Crashlytics is not enough: Sentry, or Crashlytics only?
- Do you want Crashlytics test-crash UI hidden behind a dev-only flag, or should we trigger the first dashboard event through a temporary local debug action that is never committed?
- Do we want Firebase Analytics only for first release, or should Mixpanel be added later after the event taxonomy stabilizes?
- Is Shorebird acceptable for this app's release process, or should first release avoid code push?
- Where will privacy policy, terms, account deletion, and support pages live publicly?
- Should first release include a formal accessibility audit before TestFlight/internal testing, or should we run it immediately after observability is wired?
