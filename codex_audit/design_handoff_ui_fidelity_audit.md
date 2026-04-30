# Design Handoff UI Fidelity Audit

Date: 2026-04-29

Status reviewed: 2026-04-30. Earlier progress-log entries are chronological.
Use the screen matrix and recommended fix order for current UI status.

Scope:
- Design reference: `design_handoff_catch_dating_app/`
- Flutter UI: `lib/core`, `lib/theme`, `lib/onboarding`, `lib/dashboard`, `lib/run_clubs`, `lib/runs`, `lib/swipes`, `lib/matches`, `lib/chats`, `lib/profile`, `lib/safety`

## Verdict

The app has a solid design-system foundation and several major surfaces are visibly aligned with the handoff. It is not yet production-ready at the level implied by the 37-screen design bundle. The strongest surfaces are tokens/typography, dashboard empty/full, clubs variant A, run detail, and parts of create run. The weakest surfaces are onboarding welcome polish, catches hub/intro/recap, chat context, profile/self/settings polish, calendar, filters, notifications, and host manage.

Overall fidelity: 6.5/10.

Updated working fidelity after pass 1: 7/10.

Updated working fidelity after pass 2: 7.5/10.

Updated working fidelity after visual QA pass: 7.5/10.

## Progress Log

### 2026-04-29 UI gap pass 1

Addressed:
- Catches hub now has a custom Catch-branded header, 24-hour intro card, open-window countdowns, and a stronger empty state with a "Find a run" CTA.
- Active catch rows now render as production cards instead of generic `ListTile`s.
- Matches list now has a custom "Your catches" header, carded rows, and empty-state copy grounded in the shared-run matching model.
- Chat screen now shows a shared-run context header above the message thread.
- Profile self view now leads with a running identity card using pace, preferred distance, and running reasons.
- Settings now has clearer Payments, Safety, and Account sections, including a Payment history entry.

Verification:
- `flutter analyze lib/swipes/presentation/swipe_hub_screen.dart lib/swipes/presentation/widgets/attended_run_tile.dart lib/chats/presentation/chat_screen.dart lib/matches/presentation/matches_list_screen.dart`
- `flutter analyze lib/profile/presentation/widgets/profile_tab.dart lib/safety/presentation/settings_screen.dart lib/chats/presentation/chat_screen.dart lib/matches/presentation/matches_list_screen.dart lib/swipes/presentation/swipe_hub_screen.dart lib/swipes/presentation/widgets/attended_run_tile.dart`
- `flutter test test/chats/chat_screen_test.dart test/chats/matches_list_screen_test.dart test/profile/profile_widgets_test.dart`

Still open:
- One-time catches intro and run recap as distinct per-run surfaces.
- Create-run advanced controls and routed host manage.
- Calendar, filters, and notifications routes/screens.
- Visual screenshot/golden coverage against the 390 x 844 handoff target.

### 2026-04-29 UI gap pass 2

Addressed:
- Create Run wizard now follows the handoff sequence more closely: Basics -> Route & meet point -> When -> Review & rules.
- Successful run creation now shows a full-screen branded success state instead of immediately popping back.
- Success state includes a Manage run action.
- Added a host manage surface with booked/waitlist/revenue stat trio, full banner support, run summary, roster, and waitlist sections.
- CreateRunController now returns the created `Run`, letting the UI render post-submit surfaces without refetching.

Verification:
- `flutter analyze lib/runs/presentation/create_run_controller.dart lib/runs/presentation/create_run_screen.dart`
- `flutter analyze lib/runs/presentation/create_run_controller.dart lib/runs/presentation/create_run_screen.dart test/runs/create_run_controller_test.dart test/runs/create_run_screen_test.dart`
- `flutter test test/runs/create_run_controller_test.dart test/runs/create_run_screen_test.dart`

Still open:
- Host manage currently uses the just-created run snapshot; a future pass should add a routed, stream-backed manage screen for existing runs.
- Create Run still does not include cover upload, recurring toggle, waitlist toggle, predefined price pills, Razorpay fee math, or follower notification toggle.
- Calendar, filters, notifications, and run recap remain unimplemented.

### 2026-04-29 visual QA pass

Rendered a local visual-review web build for the four most recently changed surfaces:
- Catches hub
- Create-run success
- Host manage
- Profile self

Addressed:
- Added a dedicated `tool/visual_review_app.dart` harness that renders real app widgets with sample domain data in 390 x 844 phone frames.
- Fixed the web splash shell in `web/index.html` so it removes itself on Flutter first frame, with a load-time fallback if that event is missed.

Findings:
- Catches hub is visually aligned enough for MVP: clear Catch header, strong orange hero card, visible 24-hour window framing, and a usable active-window row.
- Create-run success is visually aligned enough for MVP: full-screen warm gradient, clear success symbol, visible primary action, and no obvious clipping at phone size.
- Host manage is now materially closer to screen 35: status banner, stats, summary rows, roster, and waitlist render coherently. It still needs a routed stream-backed version and richer attendee actions before it is fully production-grade.
- Profile self is improved but still behind the handoff. The running identity card helps, but the lower profile composition still looks less designed than the mockup and should be the next visible-surface refinement.

Verification:
- `flutter analyze tool/visual_review_app.dart --no-fatal-warnings` passed with the expected Riverpod custom-lint warnings for the review-only provider overrides.
- `flutter build web -t tool/visual_review_app.dart`
- Served `build/web` locally on `127.0.0.1:7360` and inspected the rendered surfaces in Chrome through Computer Use.

### 2026-04-29 UI gap pass 3

Addressed:
- Profile self now follows the handoff composition more closely: large photo/identity hero, edit pill, profile stat strip, prompt/bio card, dark running identity card, preview action, and photo/detail sections below.
- Settings now uses the handoff-style grouped structure: Account, Discovery, Notifications, Safety, About, and Delete account. Existing real actions for payment history, blocked users, unblock, and delete confirmation were preserved.
- Added Settings to the visual-review harness alongside Catches, Create success, Host manage, and Profile.

Verification:
- `flutter analyze lib/profile/presentation/widgets/profile_tab.dart lib/safety/presentation/settings_screen.dart test/profile/profile_widgets_test.dart`
- `flutter test test/profile/profile_widgets_test.dart`
- `flutter analyze tool/visual_review_app.dart --no-fatal-warnings`
- `flutter build web -t tool/visual_review_app.dart`

Still open:
- Settings notification/discovery toggles are local UI state only; persistence should wait for a real user-settings model.
- Profile self still depends on whatever photos/user fields exist; richer run/catch stats require backend/user aggregate fields.

## What Matches Well

- Sunset palette, typography helpers, spacing, radii, pill buttons, and card treatment are ported into Flutter.
- Dashboard full and empty states preserve the design's key product idea: catches unlock after runs, with next-run hero, live catch callout, stride card, quick actions, and recommendations.
- Clubs tab ships the intended variant A structure: Your clubs, For you, and Nearby.
- Reusable primitives exist for RunCard, club cards/tiles, PersonAvatar, PersonRow, VibeTag, StatusChip, segmented controls, progress bars, sticky CTAs, and form layout.
- Run detail has the correct broad composition: photo hero, title, stats, when/where, roster, reviews, and sticky join/cancel CTA.
- The app's 5-tab shell matches the handoff: Home, Clubs, Catches, Chats, You.

## Major Gaps

### P0 / P1 Product-Surface Gaps

- Calendar screens 36 and 37 are implemented and routed. They still need
  broader visual QA and live-data smoke testing.
- Filters screen 22 and activity/notifications screen 23 are implemented and
  routed for the supported backend data.
- Catches flow has the hub, deck, match modal, and recap surface. It still needs
  a live post-run smoke test and a decision on whether recap vibe selections
  should persist.
- Host manage screen 35 and create-run success screen 34 are now partially implemented after pass 2. The success and manage surfaces exist, but host manage is not yet routed/stream-backed for existing runs.
- Create run now follows the broad mockup order: basics, route, when, review/rules. It still lacks cover upload, recurring, waitlist, price pills, fee math, and follower notification controls.

### P1 Visual Fidelity Gaps

- Welcome onboarding is much less refined than the mockup. It uses a centered logo block and short copy instead of the full-bleed hero/value-prop composition.
- Catches hub, matches inbox, chat, profile, and settings are improved after pass 1, but still need visual screenshot review against the mockups.
- Chat now includes a shared-run context header, but the header should be visually verified with real run data and may need richer roster/run metadata.
- Profile self view now leads with running identity, but the full profile composition still differs from the mockup.
- Settings is grouped and Activity now exists. Remaining work is persistence for
  real user-settings controls, final legal/support links, and store-facing
  polish.
- The custom design top bar/status bar primitive is not consistently used; many screens rely on Flutter AppBar.

### P2 Polish / Consistency Gaps

- Some shared components have design-system versions but are not consistently reused across older screens.
- Loading and error states are functional but often generic; the handoff asks every list to have polished loading/empty/error variants.
- Dark mode tokens exist, but I did not verify every screen visually in dark mode.
- Visual regression/golden tests are not present for comparing the 390 x 844 handoff target.

## Screen Matrix

| Handoff screen group | Flutter status | Fidelity |
| --- | --- | --- |
| 01 Welcome | Implemented, simplified | Low |
| 02 Phone | Implemented, +91 aligned | Good |
| 03 OTP | Implemented | Good |
| 04 Name + DOB | Implemented | Good |
| 05 Gender + Interest | Implemented | Good |
| 06 Photos | Implemented with 6-slot grid | Good |
| 07 Pace + distances | Implemented | Good |
| 08 Home feed | Not clearly present as separate feed | Gap |
| 09 Home map | Implemented after pass 8 as dashboard Map view | Medium |
| 10 Run detail | Implemented | Good |
| 11 Run clubs directory | Implemented through clubs list | Good |
| 12 Club detail | Implemented | Good |
| 13 Catches intro | Partially addressed in Catches hub | Partial |
| 14 Swipe card | Implemented | Medium |
| 15 Match modal | Implemented | Medium |
| 16 Run recap | Implemented after pass 7 from attended run data | Medium |
| 17 Inbox | Improved with custom Catch header/cards | Medium-high |
| 18 Chat | Implemented with shared-run context header | Medium |
| 19 Profile self | Improved with running identity lead | Medium |
| 20 Profile other | Implemented via profile card | Medium |
| 21 Edit profile | Implemented | Medium |
| 22 Filters | Implemented after pass 6 for supported profile preferences | Medium-high |
| 23 Notifications | Implemented after pass 5 as Activity from matches/runs | Medium-high |
| 24 Settings | Improved grouping, still narrower | Medium |
| 25 Dashboard | Implemented | Good |
| 26 Dashboard empty | Implemented | Good |
| 27 Clubs rows | Implemented | Good |
| 28 Clubs feed | Not implemented or feature-flagged | Gap, acceptable if variant A chosen |
| 29 Clubs directory | Component exists, not primary route | Partial |
| 30-33 Create run | Reordered toward handoff, still missing advanced controls | Medium |
| 34 Create success | Implemented after pass 2 | Medium-high |
| 35 Host manage | Implemented after pass 2, not routed/stream-backed | Medium |
| 36 Calendar timeline | Implemented after pass 4 from signed-up runs | Medium-high |
| 37 Calendar agenda | Implemented after pass 4 from signed-up runs | Medium-high |

## 2026-04-29 UI Gap Pass 4

### Calendar quick action and schedule surfaces

- Added `CalendarScreen` at `lib/calendar/presentation/calendar_screen.dart`.
- Wired `Routes.calendarScreen` and the dashboard Calendar quick action to a real route instead of a `Soon` badge.
- Built both handoff modes:
  - agenda view grouped by date, with joined run cards and empty/error/loading states
  - timeline view with time rail and run summary cards
- Reused existing signed-up runs provider and run formatters instead of introducing a mock data layer.
- Updated `test/dashboard/dashboard_screen_test.dart` so QuickActions now verifies Map remains unavailable while Calendar navigates to the new route.

Verification:

- `dart format lib/calendar/presentation/calendar_screen.dart lib/routing/go_router.dart lib/dashboard/presentation/widgets/quick_actions.dart test/dashboard/dashboard_screen_test.dart`
- `flutter analyze lib/calendar/presentation/calendar_screen.dart lib/routing/go_router.dart lib/dashboard/presentation/widgets/quick_actions.dart test/dashboard/dashboard_screen_test.dart`
- `flutter test test/dashboard/dashboard_screen_test.dart`

## 2026-04-29 UI Gap Pass 5

### Activity / notifications

- Added `ActivityScreen` at `lib/activity/presentation/activity_screen.dart`.
- Wired `Routes.activityScreen` plus Profile and Settings entry points.
- Matched the handoff's Activity structure without inventing fake notification storage:
  - unread/new matches are derived from `matchesForUserProvider`
  - upcoming run reminders are derived from `signedUpRunsProvider`
  - Mark all read resets unread counts through `MatchRepository`
- Added loading, empty, and error states so the surface is production-safe even before a dedicated notifications collection exists.

Verification:

- `dart format lib/activity/presentation/activity_screen.dart lib/routing/go_router.dart lib/profile/presentation/profile_screen.dart lib/safety/presentation/settings_screen.dart`
- `flutter analyze lib/activity/presentation/activity_screen.dart lib/routing/go_router.dart lib/profile/presentation/profile_screen.dart lib/safety/presentation/settings_screen.dart`

## 2026-04-29 UI Gap Pass 6

### Filters

- Added `FiltersScreen` at `lib/swipes/presentation/filters_screen.dart`.
- Wired `Routes.filtersScreen` and added the entry point from `SwipeScreen`.
- Implemented real persisted controls for the profile fields already used by matching:
  - interested genders
  - age range
  - pace range
  - preferred run distances
- Kept the mockup's verified-runners row visually present but disabled because the app does not yet have a profile verification field or backend contract.

Verification:

- `dart format lib/swipes/presentation/filters_screen.dart lib/swipes/presentation/swipe_screen.dart lib/routing/go_router.dart`
- `flutter analyze lib/swipes/presentation/filters_screen.dart lib/swipes/presentation/swipe_screen.dart lib/routing/go_router.dart`

## 2026-04-29 UI Gap Pass 7

### Post-run recap

- Added `RunRecapScreen` at `lib/swipes/presentation/run_recap_screen.dart`.
- Wired `Routes.runRecapScreen` at `/catches/:runId/recap`.
- Added a Recap entry point to attended run tiles.
- Kept recap data honest to the current backend:
  - run distance, pace, date/time, checked-in count, and catch-window status come from `Run`
  - attendee cards resolve through `publicProfileProvider`
  - vibe selection is local only because there is no persisted recap/vibe contract yet
- The primary CTA opens the existing catches deck for the same run.

Verification:

- `dart format lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/widgets/attended_run_tile.dart lib/routing/go_router.dart`
- `flutter analyze lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/widgets/attended_run_tile.dart lib/routing/go_router.dart`

## 2026-04-29 UI Gap Pass 8

### Map view

- Added `RunMapScreen` at `lib/runs/presentation/run_map_screen.dart`.
- Wired `Routes.runMapScreen` and converted the dashboard Map quick action from `Soon` to a real route.
- Used existing `Run.startingPointLat` / `startingPointLng` pins with `flutter_map`.
- Combined signed-up runs and recommended club runs so the map remains useful from the dashboard without a new backend query.
- Added a bottom run sheet with horizontal run selection and a `View run` CTA.
- Added a no-network-tile mode for visual review/tests.

Verification:

- `dart format lib/runs/presentation/run_map_screen.dart lib/routing/go_router.dart lib/dashboard/presentation/widgets/quick_actions.dart test/dashboard/dashboard_screen_test.dart tool/visual_review_app.dart`
- `flutter analyze lib/runs/presentation/run_map_screen.dart lib/routing/go_router.dart lib/dashboard/presentation/widgets/quick_actions.dart test/dashboard/dashboard_screen_test.dart --no-fatal-warnings`
- `flutter test test/dashboard/dashboard_screen_test.dart`

## Recommended Fix Order

1. Visually inspect the expanded `tool/visual_review_app.dart` gallery at 390 x 844 and tune spacing/overflow against the handoff.
2. Add a backend contract if vibe selections from Run Recap should persist and influence swipe ranking.
3. Add a dedicated notifications collection if Activity needs push-notification history beyond matches and run reminders.
4. Add a better all-runs/map query if Map view should show runs outside the user's joined clubs or bookings.
5. Add golden or screenshot tests for the most important 390 x 844 surfaces: dashboard empty, dashboard full, clubs, run detail, swipe card, chat, profile, activity, filters, calendar, recap, map.

## Current Broad Verification

- `flutter analyze lib/activity/presentation/activity_screen.dart lib/calendar/presentation/calendar_screen.dart lib/dashboard/presentation/widgets/quick_actions.dart lib/profile/presentation/profile_screen.dart lib/profile/presentation/widgets/profile_tab.dart lib/routing/go_router.dart lib/runs/presentation/run_map_screen.dart lib/safety/presentation/settings_screen.dart lib/swipes/presentation/filters_screen.dart lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/swipe_hub_screen.dart lib/swipes/presentation/swipe_screen.dart lib/swipes/presentation/widgets/attended_run_tile.dart test/dashboard/dashboard_screen_test.dart test/profile/profile_widgets_test.dart`
- `flutter test test/dashboard/dashboard_screen_test.dart test/profile/profile_widgets_test.dart test/swipes`
- `flutter analyze tool/visual_review_app.dart --no-fatal-warnings`
- `flutter build web -t tool/visual_review_app.dart`
- Browser preview at `http://127.0.0.1:7361/` confirmed the visual harness renders the corrected 390 x 844 phone width without the earlier clipped/narrow text wrapping on the Catches hub frame.
- Temporary preview server on port 7361 was stopped after browser QA.

Note: `tool/visual_review_app.dart` still emits a non-fatal Riverpod lint warning for a preview-only scoped provider override used to seed `FiltersScreen`.

## Files Checked

- `design_handoff_catch_dating_app/README.md`
- `design_handoff_catch_dating_app/tokens.jsx`
- `design_handoff_catch_dating_app/primitives.jsx`
- `design_handoff_catch_dating_app/screens/*.jsx`
- `lib/core/theme/catch_tokens.dart`
- `lib/core/theme/catch_text_styles.dart`
- `lib/theme/app_theme.dart`
- `lib/core/presentation/app_shell.dart`
- `lib/dashboard/presentation/**`
- `lib/onboarding/presentation/**`
- `lib/run_clubs/presentation/**`
- `lib/runs/presentation/**`
- `lib/swipes/presentation/**`
- `lib/matches/presentation/**`
- `lib/chats/presentation/**`
- `lib/profile/presentation/**`
- `lib/safety/presentation/settings_screen.dart`
- `lib/routing/go_router.dart`
