# Physical Device UI Audit - 2026-05-01

Scope:
- Run Catch on Suvrat's physical iPhone via Flutter.
- Use iPhone Mirroring / desktop control to exercise real app flows.
- Compare rendered iPhone UI against `design_handoff_catch_dating_app/`.
- Record functionality failures, console/runtime symptoms, likely code causes, and fixes.
- Patch high-confidence UI/UX or bug issues iteratively, preserving unrelated dirty worktree changes.

References:
- `PROJECT_CONTEXT.md`
- `codex_audit/design_handoff_ui_fidelity_audit.md`
- `design_handoff_catch_dating_app/README.md`
- `design_handoff_catch_dating_app/index.html`

Device/build status:
- Flutter sees `Suvrat's iPhone` as device `00008120-001A152E3EEB401E`, iOS 26.0.1.
- App run command to use first: `./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E`.
- App launched successfully through Flutter debug on the physical iPhone.
- Flutter VM service: `http://127.0.0.1:65055/_na85vwnQGw=/`
- Firebase App Check debug token printed during launch: `97E611C8-0BB6-4C7F-B475-B704B2C30DB1`

Initial plan:
- [x] Confirm repo context and prior design-fidelity audit.
- [x] Confirm physical iPhone is visible to Flutter.
- [x] Start the app on the iPhone with the repo environment wrapper.
- [x] Confirm iPhone Mirroring is available through Computer Use.
- [ ] Capture first-launch state and any runtime errors.
- [ ] Walk onboarding and unauthenticated flows.
- [ ] Walk authenticated tab shell: Home, Clubs, Catches, Chats, You.
- [ ] Walk supporting routes: run detail, club detail, create run, calendar, activity, filters, settings, edit profile, payment history, safety/account actions.
- [ ] Compare each reachable screen against the 37 handoff screens.
- [ ] Implement high-confidence fixes and re-run focused verification.

Open notes:
- The worktree was dirty before this pass. Do not revert existing changes unless explicitly asked.
- Some handoff screens depend on backend data/roles. If the current signed-in user cannot reach a route, record the gating reason and inspect code/sample harnesses before deciding whether to seed data or patch UI.

Runtime observations:
- No-bypass debug rerun with `./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E` built and installed the dev flavor, then stopped before first Dart UI with native `EXC_BAD_ACCESS (code=50)` at `ldur x6, [x24, #0x37]` immediately after printing the Firebase App Check debug token.
- This crash matches Flutter issue `flutter/flutter#184254` for physical iOS devices with Xcode 26.4+. The local Flutter SDK is `3.41.2` from 2026-02-18 and does not contain Flutter PR `#184690`, which changed the LLDB JIT breakpoint handling for Xcode 26.4+.
- Until the Flutter SDK includes that LLDB fix, physical-iPhone debug mode is not a reliable hot-restart loop on this machine. Use simulator, Xcode launch, Xcode 26.3, profile mode, or upgrade/patch Flutter tooling before relying on physical-device debug.
- Upgraded the local Flutter SDK from `3.41.2` to `3.41.9` on 2026-05-01. `flutter doctor` is clean, the stable SDK now includes the LLDB debug-mode breakpoint fix, and the same no-bypass physical iPhone debug run reaches the Dart VM Service instead of crashing.
- Hot restart on Suvrat's iPhone completed successfully after the Flutter upgrade (`Restarted application in 1,642ms`).
- After the SDK fix, the remaining runtime log is `[cloud_firestore/permission-denied]` from a Firestore query stream. Treat this as a separate backend/rules/query-shape issue, not the Xcode/Flutter debug crash.
- First rendered state: authenticated empty dashboard with DEV banner, title "Let's find your first run", user avatar, large orange "Your catches unlock after your first run" CTA card, "How Catch works" list, and 5-tab bottom nav.
- Initial visual read: dashboard empty is materially close to handoff screen 26, with good palette/typography and product framing. Need verify scroll/bottom safe area because the second "How Catch works" row is partially under the bottom navigation at first viewport.
- Clubs tab showed a visible Flutter debug overflow stripe: `RenderFlex overflowed by 6.0 pixels on the bottom` in `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/scroll_card.dart`.
- Chats tab failed with a raw `[cloud_firestore/permission-denied]` message. Activity route failed with the same underlying error. Code trace points to the matches stream query and deployed/local rule mismatch around `matches.participantIds` plus blocked/active filtering.
- Profile self screen rendered, but the stat strip truncated the pace range (`5:00-7:00/km`) in the middle cell.
- Create Run opened with the bottom tab bar still visible because the route lived inside the Clubs shell navigator; this is not aligned with the handoff's full-screen host stepper.
- Backend verification: the physical iPhone app is not connected to local emulators. It was launched with `./tool/flutter_with_env.sh dev run ...`, `tool/dart_defines/dev.json` has `USE_FIREBASE_EMULATORS=false`, and `ios/Runner/GoogleService-Info.plist` matches `firebase/dev/ios/GoogleService-Info.plist` for the real Firebase dev project `catchdates-dev`.
- The Firestore emulator was used only as a local rules-test harness. It cannot affect the running iPhone app. The continued Chats permission error on device is expected until the fixed dev Firestore rules/index query shape is deployed to the real dev backend.

Edits made:
- Reduced the horizontal club card image height and constrained the joined-club subtitle to eliminate the 6 px overflow.
- Changed the matches stream to query only `status == active` matches for the current participant.
- Changed the matches stream away from `participantIds arrayContains` to two rules-provable queries: active matches where `user1Id == uid` and active matches where `user2Id == uid`, merged client-side.
- Updated local Firestore rules and indexes for the new `user1Id/user2Id + status + createdAt` matches query shape.
- Moved create-run/create-run-club routes onto the root navigator so the tab bar does not consume the stepper viewport.
- Wrapped profile stat values in a scale-down fitting box so pace ranges do not ellipsize.

Verification:
- `flutter analyze lib/matches/data/match_repository.dart lib/routing/go_router.dart lib/profile/presentation/widgets/profile_tab.dart lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/scroll_card.dart test/chats/firestore_repository_test_helpers.dart test/chats/match_repository_test.dart`
- `flutter test test/chats/match_repository_test.dart test/routing/router_widgets_test.dart test/profile/profile_widgets_test.dart test/run_clubs/run_clubs_widgets_test.dart`
- `firebase emulators:exec --only firestore "npm run test:rules"` from `functions/`
