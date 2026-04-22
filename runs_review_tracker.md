# Runs Feature Review Tracker

Last updated: 2026-04-22

## Goal

Review `lib/runs`, raise code quality, fix correctness issues, add strong unit/widget coverage, and leave a checkpoint file that makes the next session easy to resume.

## Completed

- Read `PROJECT_CONTEXT.md` and reviewed the runs feature against the repo architecture and product flow.
- Tightened `RunDetail` state composition so review-stream failures are surfaced instead of silently ignored.
- Simplified booking cancellation by removing the unused user parameter from the cancel path.
- Strengthened create-run validation:
  - eligibility step now validates min/max age together inside a `Form`
  - distance must be greater than zero
  - start time must be in the future
  - schedule error text is shown inline on the when step
- Cleaned up one redundant schedule-error reset path in `CreateRunScreen`.
- Ensured `RunDetailScreen` uses the route `runClubId` it was given.
- Added broad test coverage for:
  - domain helpers and model behavior
  - repository reads/writes and provider wiring
  - booking and create-run controllers
  - run detail controller composition
  - create-run flow, location picker, run detail flow, and shared widgets

## Production Files Touched

- `lib/runs/presentation/create_run_screen.dart`
- `lib/runs/presentation/run_booking_controller.dart`
- `lib/runs/presentation/run_detail_controller.dart`
- `lib/runs/presentation/run_detail_screen.dart`
- `lib/runs/presentation/widgets/eligibility_step.dart`
- `lib/runs/presentation/widgets/run_detail_cta.dart`
- `lib/runs/presentation/widgets/run_details_step.dart`
- `lib/runs/presentation/widgets/when_step.dart`

## Test Files Added Or Expanded

- `test/runs/create_run_controller_test.dart`
- `test/runs/create_run_screen_test.dart`
- `test/runs/location_picker_screen_test.dart`
- `test/runs/run_booking_controller_test.dart`
- `test/runs/run_detail_controller_test.dart`
- `test/runs/run_detail_widgets_test.dart`
- `test/runs/run_domain_test.dart`
- `test/runs/run_repository_test.dart`
- `test/runs/runs_domain_helpers_test.dart`
- `test/runs/runs_test_helpers.dart`
- `test/runs/runs_widgets_test.dart`

## Verification

- `flutter analyze lib/runs test/runs`
- `flutter test test/runs`
- `flutter test --coverage test/runs`

Latest result:

- `test/runs`: `113` tests passed
- Handwritten `lib/runs` coverage: `100.00%` (`1250/1250`)
- Generated files such as `*.g.dart` are still lower, which is expected and not a handwritten-code gap

## Known Caveats

- `LocationPickerScreen` widget tests log expected OpenStreetMap tile `400` warnings under Flutter test because the test HttpClient does not perform real network requests. The tests still pass.
- `RunDetailBody` still has product TODOs for share/bookmark behavior. Those placeholders were pre-existing and were not expanded in this pass.

## Follow-Up / Backlog

- Optional: make the map tile layer injectable or mockable in widget tests to silence tile warnings.
- Optional: implement run share/save behavior once product and storage behavior are decided.
- If the runs models/providers change, rerun the three verification commands above and update this tracker.

## Codex Notes

- No dedicated Flutter skill was available in this session, so this pass used normal repo inspection plus targeted testing.
- Good ways to use Codex on this repo:
  - ask for a feature-scoped audit, fix, and verification pass in one request
  - ask for a tracker file like this at the start of longer sessions
  - ask for explicit coverage targets and whether generated files should be excluded
  - ask for a "findings first" review when you want bug/risk callouts before implementation details
