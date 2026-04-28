# Catch Full App Audit Tracker

Started: 2026-04-28

Scope:
- Audit every top-level `lib/` feature for implementation completeness, code quality, tests, dead code, and cross-feature dependencies.
- Compare implemented UI against `design_handoff_catch_dating_app/`.
- Build and, where practical, run/inspect Web, macOS, iOS, and Android targets.
- Review Firebase/Firestore setup, rules, indexes, Functions seams, and console-dependent configuration.
- Plan account blocking and account deletion as privacy/safety requirements.

## Current Status

- [x] Created durable audit tracker.
- [x] Read `PROJECT_CONTEXT.md`, feature tree, tests tree, and design handoff inventory.
- [x] Run static analysis.
- [x] Run tests.
- [x] Audit current TODO/FIXME/dead affordances.
- [x] Review each `lib/` feature folder at folder-level completeness.
- [x] Compare route/UI coverage with design handoff screen inventory.
- [x] Build Web target.
- [x] Build Android target.
- [ ] Build macOS target.
- [ ] Build iOS target.
- [x] Inspect Firebase/Firestore configuration and console state.
- [x] Draft blocking/account deletion implementation plan.
- [x] Apply high-confidence fixes and add TODO annotations for missing work.

## Command Log

| Time | Command | Result | Notes |
| --- | --- | --- | --- |
| 2026-04-28 | `git status --short` | pass | Clean worktree at start. |
| 2026-04-28 | `find lib -maxdepth 3 -type f` | pass | Captured current feature surface. |
| 2026-04-28 | `find test -maxdepth 3 -type f` | pass | Captured current test surface. |
| 2026-04-28 | `flutter analyze` | fail | `test/routing/router_widgets_test.dart` had import ordering and invalid const `Stream.value` calls. |
| 2026-04-28 | `flutter analyze` | pass | Fixed routing widget test drift; analyzer green. |
| 2026-04-28 | `flutter test` | fail | Stale auth error expectation and router widget tests stuck on app-shell loading redirect. |
| 2026-04-28 | `flutter test test/routing/router_widgets_test.dart` | pass | Narrowed chat route tests to route contract instead of booting the full auth-gated shell. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer green after test fixes. |
| 2026-04-28 | `flutter test` | pass | 360 tests passed. OSM tile 400 logs remain noisy but non-failing. |
| 2026-04-28 | `flutter build web --dart-define=APP_ENV=dev` | pass | Built `build/web`. |
| 2026-04-28 | `flutter build apk --dart-define=APP_ENV=dev` | pass | Built `build/app/outputs/flutter-apk/app-release.apk` at 60.7MB. |
| 2026-04-28 | `flutter build macos --dart-define=APP_ENV=dev` | fail | Runner entitlements require signing with a development certificate. Pods also warn that PromisesObjC targets macOS 10.11 while supported range starts at 10.13. |
| 2026-04-28 | `flutter build macos --debug --dart-define=APP_ENV=dev` | fail | Same macOS signing entitlement failure. |
| 2026-04-28 | `flutter build ios --simulator --no-codesign --dart-define=APP_ENV=dev` | fail | Xcode reports no eligible generic iOS Simulator destination. |
| 2026-04-28 | `xcrun simctl boot AE02F463-79BD-4EF0-9A01-9C59A4E401FD` | pass | Booted iPhone 17 Pro simulator on iOS 26.4. |
| 2026-04-28 | `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showdestinations` | fail | Runner scheme still exposes only ineligible Any iOS Device; Xcode claims iOS 26.4 is not installed even though `xcodebuild -showsdks` lists it. |
| 2026-04-28 | `flutter build ios --no-codesign --dart-define=APP_ENV=dev` | fail | Same Xcode destination issue for generic iOS device. |
| 2026-04-28 | `npm run build` in `functions/` | pass | TypeScript compiled. |
| 2026-04-28 | `npm run lint` in `functions/` | fail | 58 Google-style lint errors in payments handlers/tests. |
| 2026-04-28 | `npm run lint -- --fix` plus manual cleanup | partial | Fixed auto-fixable lint and added JSDoc/wrapped long lines in payments files. |
| 2026-04-28 | `npm run lint` in `functions/` | pass | Functions lint green. |
| 2026-04-28 | `npm test` in `functions/` | pass | 10 payment tests passed. |
| 2026-04-28 | Firebase console via Computer Use | inspected | Project `catch-dating-app-64e51` showed Cloud Firestore landing page with `Create database`, not an existing Firestore data/rules/indexes view. |
| 2026-04-28 | `rg "TODO|FIXME|coming soon|stub|placeholder|not implemented"` | pass | Confirmed real app TODOs in run detail share/bookmark and run club share; test helper UnimplementedError instances are expected. |
| 2026-04-28 | `flutter analyze` | pass | Rechecked after audit docs and TODO annotations; no issues found. |
| 2026-04-28 | `npm run lint` in `functions/` | pass | Rechecked after safety TODO annotations. |
| 2026-04-28 | `npm run build` in `functions/` | pass | Rechecked TypeScript after safety TODO annotations. |
| 2026-04-28 | `dart run build_runner build --delete-conflicting-outputs` | pass | Regenerated Match and Riverpod providers after safety model/repository changes. |
| 2026-04-28 | `flutter analyze` | pass | Safety implementation analyzer check passed. |
| 2026-04-28 | `flutter test` | pass | 360 tests passed. Existing OpenStreetMap tile 400 noise remains non-failing. |
| 2026-04-28 | `npm run lint` in `functions/` | pass | Safety Functions lint passed. |
| 2026-04-28 | `npm test` in `functions/` | pass | 13 tests passed, including new safety block helper coverage. |
| 2026-04-28 | `firebase firestore:databases:list --project catch-dating-app-64e51` | blocked | Firebase CLI credentials are expired and require `firebase login --reauth`. |
| 2026-04-28 | `node -e ...JSON.parse(...)` | pass | `firebase.json` and `firestore.indexes.json` are valid JSON after Firebase config hardening. |
| 2026-04-28 | `npm run build` in `functions/` | pass | Account deletion Storage cleanup compiled. |
| 2026-04-28 | `npm run lint` in `functions/` | pass | Account deletion Storage cleanup lint passed. |
| 2026-04-28 | `npm test` in `functions/` | pass | 15 tests passed, including Storage URL parsing and block helper tests. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer still green after Firebase config and backend safety updates. |
| 2026-04-28 | Firebase console via Chrome/Computer Use | inspected | Auth, Storage, Firestore, Functions, Messaging, Hosting, App Check, and registered app settings inspected read-only. Detailed notes are in `codex_audit/firebase_console_audit.md`. |
| 2026-04-28 | `dart run build_runner build --delete-conflicting-outputs` | pass | Regenerated route/provider outputs after adding public profile safety route. |
| 2026-04-28 | `npm run build` in `functions/` | pass | `reportUser` callable compiled. |
| 2026-04-28 | `npm run lint` in `functions/` | pass | `reportUser` callable lint passed. |
| 2026-04-28 | `npm test` in `functions/` | pass | 18 tests passed, including new report helper/callable tests. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer clean after public profile/report route. |
| 2026-04-28 | `flutter test` | pass | 360 tests passed. Existing OpenStreetMap tile 400 noise remains non-failing. |
| 2026-04-28 | `flutter test test/runs/location_picker_screen_test.dart test/runs/create_run_screen_test.dart` | pass | Added `loadMapTiles: false` test seam and verified affected map tests without network tile requests. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer clean after map test seam. |
| 2026-04-28 | `flutter test` | pass | 360 tests passed, now without OpenStreetMap tile 400 noise. |
| 2026-04-28 | Firebase region decision | selected | Chose `asia-south1` (Mumbai) for India-first launch and aligned local Firestore/Functions/client callable config. |
| 2026-04-28 | Firebase console via Chrome/Computer Use | pass | Created the default Cloud Firestore database as Standard edition, production mode, in `asia-south1` (Mumbai). |
| 2026-04-28 | `firebase firestore:databases:list --project catch-dating-app-64e51` | blocked | Console creation succeeded, but CLI verification remains blocked by expired Firebase CLI credentials requiring `firebase login --reauth`. |
| 2026-04-28 | `firebase login --reauth` | pass | CLI reauthenticated as `suvrat.garg@gmail.com`. |
| 2026-04-28 | `firebase firestore:databases:list --project catch-dating-app-64e51` | pass | Verified `projects/catch-dating-app-64e51/databases/(default)` exists. |
| 2026-04-28 | `firebase deploy --only firestore:rules,firestore:indexes,storage --project catch-dating-app-64e51` | pass | Deployed Firestore rules, Firestore indexes, and Storage rules. |
| 2026-04-28 | `firebase firestore:indexes --project catch-dating-app-64e51` | pass | Verified deployed composite indexes are visible from CLI. |
| 2026-04-28 | `firebase deploy --only functions --project catch-dating-app-64e51 --dry-run` | blocked | Predeploy lint/build passed, but deploy analysis blocked because Secret Manager API is disabled and Razorpay secrets are required. The dry run enabled Cloud Build, Artifact Registry, and Firebase Extensions APIs while preparing. |
| 2026-04-28 | Chrome/Google Cloud Console | pass | Enabled Secret Manager API for `catch-dating-app-64e51`. Console still shows account verification warning. |
| 2026-04-28 | `firebase functions:secrets:set RAZORPAY_KEY_ID ...` | pass | Created Secret Manager version 1 from `/Users/suvratgarg/Downloads/rzp-key.csv` without printing the value. |
| 2026-04-28 | `firebase functions:secrets:set RAZORPAY_KEY_SECRET ...` | pass | Created Secret Manager version 1 from `/Users/suvratgarg/Downloads/rzp-key.csv` without printing the value. |
| 2026-04-28 | `firebase deploy --only functions --project catch-dating-app-64e51` | partial | First deploy created 8 functions, granted secret access, and enabled runtime APIs; several functions failed due initial 2nd-gen Cloud Run/Eventarc propagation/build errors. |
| 2026-04-28 | `firebase deploy --only functions --project catch-dating-app-64e51` | pass with cleanup warning | Retry created/updated all remaining functions. Command exited nonzero only because Artifact Registry cleanup policy was not configured. |
| 2026-04-28 | `firebase functions:list --project catch-dating-app-64e51` | pass | Verified all 17 expected Functions are live in `asia-south1`. |
| 2026-04-28 | `firebase functions:artifacts:setpolicy --location asia-south1 --days 7 --force --project catch-dating-app-64e51` | pass | Configured cleanup policy for `gcf-artifacts` to delete images older than 7 days. |
| 2026-04-28 | `rm /private/tmp/catch_razorpay_key_id.secret /private/tmp/catch_razorpay_key_secret.secret` | pass | Temporary plaintext Razorpay secret staging files were already absent from `/private/tmp`. |
| 2026-04-28 | `firebase functions:list --project catch-dating-app-64e51` | pass | Reverified all 17 Functions after cleanup policy. |
| 2026-04-28 | `firebase apps:android:sha:create ...` | pass | Registered local Android debug SHA-1 and SHA-256 fingerprints for `com.example.catch_dating_app`. |
| 2026-04-28 | Firebase console App Check | pass | Registered Android App Check with Play Integrity and confirmed iOS App Attest registration. Enforcement remains off intentionally. |
| 2026-04-28 | `flutter pub add firebase_app_check` | pass | Added Flutter App Check SDK dependency. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer green after App Check client initialization. |
| 2026-04-28 | `flutter test` | pass | 360 tests passed after App Check client initialization. |
| 2026-04-28 | `flutter build web` | pass | Web build passed with App Check SDK. |
| 2026-04-28 | `flutter build apk` | pass | Android release APK built at `build/app/outputs/flutter-apk/app-release.apk` after App Check SDK. |
| 2026-04-28 | `flutter pub add share_plus` | pass | Added the cross-platform share-sheet dependency for run and run-club share actions. |
| 2026-04-28 | `dart run build_runner build --delete-conflicting-outputs` | pass | Regenerated `UserProfile` serialization after adding `savedRunIds`. |
| 2026-04-28 | `dart format ...` | pass | Formatted share/bookmark implementation and focused tests. |
| 2026-04-28 | `flutter test test/runs/run_detail_widgets_test.dart test/run_clubs/run_clubs_widgets_test.dart` | pass | Verified run detail sharing, saved-run toggle, and run-club share handler behavior. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer green after run share/bookmark and run-club share implementation. |
| 2026-04-28 | `flutter test` | pass | 361 tests passed after adding share/bookmark coverage. |
| 2026-04-28 | `flutter build web --dart-define=APP_ENV=dev` | pass | Web build passed after adding `share_plus`; Flutter reported only standard wasm dry-run and icon tree-shaking messages. |
| 2026-04-28 | `flutter build apk --dart-define=APP_ENV=dev` | pass | Android release APK built at `build/app/outputs/flutter-apk/app-release.apk` at 60.9MB after adding `share_plus`. |
| 2026-04-28 | `firebase deploy --only firestore:rules --project catch-dating-app-64e51 --dry-run` | pass | Firestore rules compiled after aligning `runClubs` validation with the current Dart model and member-count writes. |
| 2026-04-28 | `flutter test test/run_clubs` | pass | 73 run-club tests passed after the rules-schema fix. |
| 2026-04-28 | `flutter analyze` | pass | Analyzer green after the run-club rules-schema fix. |
| 2026-04-28 | `firebase deploy --only firestore:rules --project catch-dating-app-64e51` | pass | Deployed the corrected `runClubs` rules to Cloud Firestore. |
| 2026-04-28 | `npm install --prefix functions --save-dev @firebase/rules-unit-testing` | pass | Added the Firebase rules unit-test harness. npm reported existing dependency audit findings: 21 vulnerabilities. |
| 2026-04-28 | `npm --prefix functions run lint` | pass | Functions lint clean after adding the `.cjs` rules test and script. |
| 2026-04-28 | `npm --prefix functions run build` | pass | TypeScript build clean after adding the rules-test dependency. |
| 2026-04-28 | `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"` | pass | 10 Firestore rules emulator tests passed for run-club schema/member updates, block/deleted profile denial, reports, tombstones, and blocked matches. |
| 2026-04-28 | `npm --prefix functions test` | pass | 18 existing Functions tests still pass after adding the rules-test harness. |

## Findings

- `test/routing/router_widgets_test.dart` had stale analyzer issues. Fixed import ordering and removed invalid `const` from empty stream fakes.
- `test/auth/presentation/auth_screen_test.dart` expected the old `StateError.toString()` output. Updated it to the current user-facing stripped message.
- Full app-shell router widget tests were brittle because auth redirects stayed on `/loading` under test providers. Kept redirect behavior in `router_redirect_test.dart` and narrowed `router_widgets_test.dart` chat cases to route hydration plus FCM path navigation.
- Test infrastructure gap fixed: map widget tests no longer hit live OpenStreetMap tiles. `LocationPickerScreen` keeps network tiles enabled by default, while tests disable them via `loadMapTiles: false`.
- Build gap: macOS cannot build locally until Runner signing/entitlements are configured for a development certificate or debug entitlements are adjusted.
- Build/environment gap: iOS builds are blocked before compilation by Xcode destination discovery. `simctl` and `xcodebuild -showsdks` list iOS 26.4, but the Runner scheme reports iOS 26.4 as not installed. I added `iphonesimulator` to the iOS project supported platforms, but Xcode still does not expose an eligible destination.
- Backend hygiene gap fixed: Functions lint was failing in payments files; lint, build, and payment tests are now green.
- Firebase config gap: only `dev` is fully configured. `staging` and `prod` are scaffolded fail-fast placeholders.
- Firestore gap closed: `firestore.indexes.json` now contains composite indexes for the app's known query shapes and has been deployed.
- Firestore rules gap closed: `runClubs` create/update validation now matches the current Dart model fields, allows host profile edits for current fields, and allows join/leave writes to update both `memberUserIds` and `memberCount` while keeping the count aligned. The corrected rules are deployed and covered by Firestore emulator tests.
- Safety gap: no `blocks`, account deletion tombstone, blocked-user filtering, or block-aware sign-up check exists in rules/functions/client code yet.
- Product/design gap: design handoff includes Notifications, Filters, Calendar, Run recap, Match modal, Create Run success/manage states, and Home feed/map variants that are not represented as current app routes.
- Product gap closed: run detail share/bookmark buttons and run club share action now use `share_plus`, route-backed `catchdates.com` links, and persisted `users/{uid}.savedRunIds`.
- Firebase console blocker closed: the default Cloud Firestore database now exists in `asia-south1` (Mumbai), Standard edition, production mode.
- Firebase region decision: use `asia-south1` (Mumbai) for the default Firestore database and Cloud Functions for India-first launch. If the console reports the default Google Cloud resource location is already locked elsewhere, stop and reassess before creating Firestore.
- Firebase CLI blocker closed: local Firebase CLI was reauthenticated and can now reach the project.
- Firebase Functions blocker closed: all expected Functions are now deployed in `asia-south1`.
- Firebase console security gap closed: hardened local `storage.rules` and `firestore.rules` plus indexes have been deployed.
- Functions secrets configured: `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` are stored in Secret Manager and attached to payment/refund Functions.
- Artifact Registry cleanup warning closed: cleanup policy now deletes function container images older than 7 days in `asia-south1`.
- Google Cloud account warning remains in console: "To avoid losing access to Google Cloud services, an administrator must verify this account."
- Firebase console gap partially closed: iOS App Check is registered with App Attest, Android App Check is registered with Play Integrity, and Flutter initializes the App Check SDK. Web App Check and enforcement remain pending.
- Firebase console gap partially closed: Android debug SHA-1/SHA-256 fingerprints are registered. Release signing fingerprints are still pending.
- Firebase console gap: Web Push certificates appear empty.
- Firebase console state: Hosting is deployed and `catchdates.com` is connected; its `/api/join-waitlist` rewrite now points at the deployed `joinWaitlist` Function in `asia-south1`.
- Firebase deploy config fixed: `firestore.indexes.json` now contains indexes for the repo's compound queries, `storage.rules` is scoped to authenticated user photos and host-owned club covers, and `firebase.json` no longer deploys the empty starter `catch-dating-app/` Functions codebase.
- Documentation added: `codex_audit/lib_feature_completeness_matrix.md` and `codex_audit/safety_blocking_account_deletion_plan.md`.
- Safety implementation added: `blocks` rules/helpers, block/unblock callable Functions, blocked-match closure, block-aware paid order creation, free/paid sign-up, waitlist promotion, server-side waitlist join, swipe match prevention, chat/profile/read denials, Settings/Safety UI, chat/profile block actions, blocked-account list, and account deletion callable/UI.
- Safety gap closed: account deletion now deletes Firebase Storage photo objects when the stored profile URLs are standard Firebase Storage download URLs.
- Reporting implementation added: `reportUser` callable writes server-owned `reports`, Firestore rules deny client report reads/writes, chat can file a contextual report, and the other-user profile route exposes report/block controls.
- TODO hygiene: removed stale sign-up safety TODO after block enforcement was added and closed the remaining run detail share/bookmark plus run club sharing TODOs. Current `lib/` TODO scan only finds the dashboard test that intentionally asserts coming-soon actions.
- Rules emulator coverage added: `functions/test/firestore.rules.test.cjs` covers the highest-risk run-club and safety/privacy rule paths.

## Resume Notes

If this session stops, resume by:
1. Reading `PROJECT_CONTEXT.md`.
2. Reading this file.
3. Reading `codex_audit/firebase_console_audit.md`.
4. Rechecking the remaining launch gaps: Google Cloud account verification, Android SHA fingerprints, App Check, Web Push, and live backend smoke tests.
5. Running a final target build pass after the iOS destination and macOS signing issues are repaired.
