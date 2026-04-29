# Production Release Checklist

Created: 2026-04-29

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
- Environments: `APP_ENV` supports `dev`, `staging`, and `prod` through `lib/core/app_config.dart` and `lib/firebase_options_<env>.dart`.
- Firebase: Auth, Firestore, Storage, Functions, Messaging, and App Check are already present.
- App Check: debug providers are used outside production; production uses Play Integrity on Android and App Attest on Apple platforms.
- Push: native Android/iOS push support exists; web requires a VAPID key.
- Error logging: `lib/exceptions/error_logger.dart` currently prints to debug output and explicitly needs Sentry or Crashlytics before production.
- Analytics: no dedicated analytics package or event taxonomy is wired yet.
- Force update: no `upgrader`, Firebase Remote Config, or custom force-update layer is wired yet.
- In-app review: no `in_app_review` package is wired yet.
- Accessibility: no dedicated `accessibility_tools` dependency or release accessibility audit is documented yet.
- Security/privacy: Firestore rules, App Check, account deletion planning, and secret-ignore hardening exist from prior work, but no consolidated release security/privacy audit is documented yet.
- Release verification: web, Android APK, macOS, iOS simulator, generic iOS, and signed iOS builds have recent audit notes in `codex_audit/target_build_audit_2026-04-28.md`.
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
- `ios/Runner/Info.plist` now uses `Catch` for `CFBundleDisplayName` and `CFBundleName`.

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

Status: `blocked`

Why it matters: dev, staging, and production must not accidentally share credentials, Firebase projects, analytics streams, or app identities.

Catch-specific tasks:

- Audit current `APP_ENV` setup against Android package IDs, iOS bundle IDs, app names, and Firebase app IDs.
- Decide whether current Dart-define environments are enough for first release or whether true platform flavors are required now.
- Ensure prod/staging Firebase option files contain real project values before any store submission.
- Make environment selection obvious in local run, build scripts, README, and CI.
- Ensure dev/staging builds cannot pollute production analytics or crash-reporting projects.

Current evidence:

- `lib/core/app_config.dart` resolves `dev`, `staging`, and `prod`.
- `tool/dart_defines/dev.json`, `tool/dart_defines/staging.json`, and `tool/dart_defines/prod.json` exist.
- `FIREBASE_SETUP.md` documents Firebase environment selection.
- Dev Firebase is configured against `catch-dating-app-64e51`.
- Staging and prod Firebase option files intentionally throw `UnsupportedError` until real Firebase projects/apps are created.
- Android, iOS, and macOS now use final local identifier `com.catchdates.app`.
- Dev Firebase now has new Android and iOS app registrations for `com.catchdates.app`, and the active plus `firebase/dev` native config files were regenerated.
- Apple Developer capabilities, Firebase App Check, APNs status, and Android SHA fingerprints still need to be rechecked against the new Firebase/native app identities.

Teaching notes:

- Dart defines choose runtime behavior inside Flutter.
- Platform flavors/product flavors also change native app identity, bundle ID, icons, app name, and store-install coexistence. We should use them only if we need side-by-side installs or separate native app registrations.

Verification:

- `flutter analyze`
- `flutter build apk --dart-define=APP_ENV=dev`
- `flutter build apk --dart-define=APP_ENV=prod`
- iOS build with production define once production Firebase config is real.

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

Status: `todo`

Why it matters: once the app talks to real backend contracts, old clients may become unsafe or incompatible.

Recommended default for Catch:

- Use Firebase Remote Config for minimum supported versions by platform/environment.
- Show a blocking update screen only when the installed version is below the minimum supported version.

Catch-specific tasks:

- Add Remote Config or a small Functions/Firestore-backed version endpoint.
- Define per-platform fields: `ios_min_build`, `android_min_build`, optional `recommended_build`, and store URLs.
- Add startup check after Firebase initialization and before normal app shell use.
- Design a blocking update UI and a non-blocking recommended update UI.
- Ensure dev/staging can override values safely.

Teaching notes:

- Force update is a backend compatibility tool, not a marketing prompt.
- Build numbers are better than semantic versions for comparison because stores require monotonically increasing build codes.

Verification:

- Simulate current build below minimum and confirm app blocks use.
- Simulate current build above minimum and confirm normal startup.
- Widget tests for blocking/recommended/current states.

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

Status: `todo`

Why it matters: production users and store reviewers need a predictable place to find app metadata, legal links, OSS licenses, support, account controls, and preference toggles.

Catch-specific tasks:

- Decide whether this belongs under the existing profile/settings surface or a dedicated about/settings screen.
- Add links to the app website, privacy policy, terms of use, support/contact, and account deletion instructions.
- Add a "Rate Catch" / store listing action after store IDs exist.
- Show open source licenses through Flutter's license page.
- Add user-facing app configuration controls that we genuinely support, such as analytics opt-out, notification settings, or theme mode.
- Ensure settings links open reliably on Android, iOS, and web.

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

- Recent signed iOS build passed after App Attest entitlement work.
- Physical-device profile runtime still needs follow-up validation if device connectivity is available.

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

- Recent Android release APK builds pass for dev.
- `android/key.properties.example` and secret-ignore hardening exist from earlier release-readiness work.

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
- Audited checklist item 2. Dart-level `APP_ENV` exists, staging/prod remain unconfigured, and the final local app identifier is now `com.catchdates.app` for Android/iOS/macOS. Dev Firebase app registrations/configs were created for the new ID; Apple/Play capabilities, App Check, APNs, and SHA fingerprints still need follow-up.
- Started checklist item 3. Added Firebase Crashlytics, kept app code behind `ErrorLogger`/`CrashReporter`, wired Flutter framework and platform dispatcher fatal handlers, preserved Riverpod async error observation, disabled native auto-collection by default, and enabled reporting only for production release builds.
- Added focused error-logger tests and verified `flutter test test/exceptions/error_logger_test.dart`, `flutter analyze`, `flutter build web --dart-define=APP_ENV=dev`, and `flutter build apk --dart-define=APP_ENV=dev`.
- Added the Android Crashlytics Gradle plugin. Official Firebase docs say Flutter Crashlytics setup should include the plugin, and Android Gradle plugin v3 requires Google Services `4.4.1+`; this repo now uses Crashlytics plugin `3.0.6` and Google Services `4.4.4`.

## Open Questions

- Which crash/error provider should we use for first release: Firebase Crashlytics, Sentry, or both?
- Do you want Crashlytics test-crash UI hidden behind a dev-only flag, or should we trigger the first dashboard event through a temporary local debug action that is never committed?
- Which analytics provider should we use for first release: Firebase Analytics, Mixpanel, or both?
- Are final prod/staging Firebase projects and app IDs already created, or should this remain blocked until you set them up?
- Do we want side-by-side dev/staging/prod installs on the same phone? If yes, we should add platform flavors; if no, current Dart-define environments may be enough for now.
- Should first release use `com.catchdates.app` for both dev and production, or should we introduce platform flavors later for side-by-side dev/staging/prod installs?
- Is Shorebird acceptable for this app's release process, or should first release avoid code push?
- Where will privacy policy, terms, account deletion, and support pages live publicly?
- Should first release include a formal accessibility audit before TestFlight/internal testing, or should we run it immediately after observability is wired?
