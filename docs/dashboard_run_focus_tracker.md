# Dashboard Run Focus Tracker

Last updated: 2026-05-15

## Goal

Consolidate dashboard run-specific actions into a single `Run Focus` module so the dashboard does not show separate cards for the same run state.

The module should cover:

- Upcoming booked runs and run detail navigation.
- One-tap directions for upcoming/check-in runs.
- Self check-in when the check-in window is open.
- Post-run catch/swipe action while the swipe window is open.
- Pending review action for attended runs.

## Current Baseline

- `UpcomingRunsHero` renders upcoming booked runs.
- `RunArrivalActionCard` renders check-in as a separate card above upcoming runs.
- `CatchesCallout` renders active swipe windows separately in the attended section.
- `ReviewPromptCard` renders pending review separately in the attended section.
- `HostToolsRail` is already consolidated separately and should stay separate for now.

## Implementation Checklist

- [x] Create persistent tracker.
- [x] Define the consolidated Run Focus item/action model.
- [x] Build a reusable `RunFocusRail` / `RunFocusCard` dashboard widget.
- [x] Add directions action using the existing run location link infrastructure.
- [x] Replace separate dashboard check-in/upcoming/swipe/review surfaces with Run Focus.
- [x] Update dashboard tests for the consolidated states.
- [x] Convert the Run Focus rail to full-width snapping cards with a page indicator.
- [x] Stack primary and secondary run actions so labels do not truncate.
- [x] Add calendar action for future booked runs in Run Focus.
- [x] Run focused analyzer and dashboard tests.

## Scope Notes

- Keep host tools separate in this pass. Host actions have different density needs when a host has many upcoming runs.
- Keep quick actions separate. Map, Calendar, and Saved Runs are navigation tools, not run-state actions.
- Keep recommendations separate. They are discovery, not committed-run actions.
- Keep destructive actions like cancel booking inside the run detail screen for now.

## Verification Log

- 2026-05-15: `flutter analyze --no-fatal-infos lib/dashboard/presentation/widgets/run_focus_rail.dart lib/dashboard/presentation/widgets/dashboard_full.dart test/dashboard/dashboard_screen_test.dart` passed.
- 2026-05-15: `flutter test test/dashboard/dashboard_screen_test.dart` passed (`22` widget tests).
- 2026-05-15: `flutter analyze --no-fatal-infos lib/dashboard/presentation/widgets/run_focus_rail.dart lib/dashboard/presentation/widgets/dashboard_full.dart test/dashboard/dashboard_screen_test.dart` passed after the full-width snapping card follow-up.
- 2026-05-15: `flutter test test/dashboard/dashboard_screen_test.dart` passed (`23` widget tests).
- 2026-05-15: `flutter analyze --no-fatal-infos lib/runs/presentation/run_calendar_links.dart lib/payments/presentation/payment_confirmation_controller.dart lib/dashboard/presentation/widgets/run_focus_rail.dart lib/runs/presentation/widgets/run_detail_body.dart lib/runs/presentation/widgets/run_detail_hero_app_bar.dart lib/swipes/presentation/swipe_screen.dart test/dashboard/dashboard_screen_test.dart test/runs/run_detail_widgets_test.dart test/payments/payment_confirmation_controller_test.dart` passed after shared add-to-calendar integration.
- 2026-05-15: `flutter test test/dashboard/dashboard_screen_test.dart test/runs/run_detail_widgets_test.dart test/payments/payment_confirmation_controller_test.dart` passed.

## Completed Notes

- Added `RunFocusRail` as the consolidated dashboard module for upcoming, check-in, catching, directions, and review actions.
- Replaced standalone dashboard usage of `RunArrivalActionCard`, `CatchesCallout`, `ReviewPromptCard`, and `UpcomingRunsHero` with the new Run Focus rail.
- Deleted the obsolete standalone dashboard action widgets and their old `NextRunHero` widget test after replacement coverage passed.
- Kept `HostToolsRail`, quick actions, and recommendations separate by design.
- Added regression coverage for directions and for combining catch/review actions on a single attended-run card.
- Reworked Run Focus paging from clipped horizontal cards to one full-width snap card at a time, with dots indicating additional runs.
- Reworked two-action cards so `View run` and `Directions` render on separate full-width lines.
- Added `Add to calendar` as a third committed-run action for upcoming booked runs. The action uses the shared calendar link controller also used by booking confirmation and run detail.
