# Design Handoff UI Fidelity Audit

Date: 2026-04-29

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

## What Matches Well

- Sunset palette, typography helpers, spacing, radii, pill buttons, and card treatment are ported into Flutter.
- Dashboard full and empty states preserve the design's key product idea: catches unlock after runs, with next-run hero, live catch callout, stride card, quick actions, and recommendations.
- Clubs tab ships the intended variant A structure: Your clubs, For you, and Nearby.
- Reusable primitives exist for RunCard, club cards/tiles, PersonAvatar, PersonRow, VibeTag, StatusChip, segmented controls, progress bars, sticky CTAs, and form layout.
- Run detail has the correct broad composition: photo hero, title, stats, when/where, roster, reviews, and sticky join/cancel CTA.
- The app's 5-tab shell matches the handoff: Home, Clubs, Catches, Chats, You.

## Major Gaps

### P0 / P1 Product-Surface Gaps

- Calendar screens 36 and 37 are not implemented or routed. The design expects a timeline and agenda; the app only shows a disabled "Calendar Soon" quick action.
- Filters screen 22 and notifications/activity screen 23 are not implemented or routed.
- Catches flow is still incomplete compared with screens 13 to 16. The tab now has an intentional hub and active-window intro card, but a distinct one-time per-run intro and run recap are still missing.
- Host manage screen 35 and create-run success screen 34 are now partially implemented after pass 2. The success and manage surfaces exist, but host manage is not yet routed/stream-backed for existing runs.
- Create run now follows the broad mockup order: basics, route, when, review/rules. It still lacks cover upload, recurring, waitlist, price pills, fee math, and follower notification controls.

### P1 Visual Fidelity Gaps

- Welcome onboarding is much less refined than the mockup. It uses a centered logo block and short copy instead of the full-bleed hero/value-prop composition.
- Catches hub, matches inbox, chat, profile, and settings are improved after pass 1, but still need visual screenshot review against the mockups.
- Chat now includes a shared-run context header, but the header should be visually verified with real run data and may need richer roster/run metadata.
- Profile self view now leads with running identity, but the full profile composition still differs from the mockup.
- Settings is more grouped after pass 1, but notifications remain a placeholder and the full settings/activity surface is not complete.
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
| 09 Home map | Not implemented | Gap |
| 10 Run detail | Implemented | Good |
| 11 Run clubs directory | Implemented through clubs list | Good |
| 12 Club detail | Implemented | Good |
| 13 Catches intro | Partially addressed in Catches hub | Partial |
| 14 Swipe card | Implemented | Medium |
| 15 Match modal | Implemented | Medium |
| 16 Run recap | Not implemented | Gap |
| 17 Inbox | Improved with custom Catch header/cards | Medium-high |
| 18 Chat | Implemented with shared-run context header | Medium |
| 19 Profile self | Improved with running identity lead | Medium |
| 20 Profile other | Implemented via profile card | Medium |
| 21 Edit profile | Implemented | Medium |
| 22 Filters | Not implemented | Gap |
| 23 Notifications | Not implemented | Gap |
| 24 Settings | Improved grouping, still narrower | Medium |
| 25 Dashboard | Implemented | Good |
| 26 Dashboard empty | Implemented | Good |
| 27 Clubs rows | Implemented | Good |
| 28 Clubs feed | Not implemented or feature-flagged | Gap, acceptable if variant A chosen |
| 29 Clubs directory | Component exists, not primary route | Partial |
| 30-33 Create run | Reordered toward handoff, still missing advanced controls | Medium |
| 34 Create success | Implemented after pass 2 | Medium-high |
| 35 Host manage | Implemented after pass 2, not routed/stream-backed | Medium |
| 36 Calendar timeline | Not implemented | Gap |
| 37 Calendar agenda | Not implemented | Gap |

## Recommended Fix Order

1. Bring the visible tab surfaces to a consistent production standard: Catches hub, Matches inbox, Chat header/context, Profile self, Settings.
2. Add the missing post-run flow: catches intro, run recap, and a more intentional empty/ended state.
3. Rework create run toward the handoff: basics first, route/map second, when/capacity/price third, review fourth, then success.
4. Decide whether calendar/filters/notifications are in MVP. If not, remove "Soon" affordances or hide them behind a clear internal flag.
5. Add golden or screenshot tests for the most important 390 x 844 surfaces: dashboard empty, dashboard full, clubs, run detail, swipe card, chat, profile.

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
