# Run Clubs Review Tracker

## Goal

Review and harden the `lib/run_clubs` feature starting from `run_clubs_list_screen.dart`, improve code quality and behavior, and raise test coverage across unit and widget tests.

## Findings / Notes

- `joinClub` / `leaveClub` currently update `memberCount` even when the membership array change is a no-op. This can drift counts over time.
- Existing tests cover only a small portion of the list/detail flow. Most widgets and controller branches are still untested.
- `run_clubs` UI uses Riverpod 3 codegen and experimental mutations. Keep changes idiomatic to that stack.

## In Progress

- [x] Review all non-generated files under `lib/run_clubs`
- [x] Fix behavior/data-integrity issues
- [x] Improve widget ergonomics/accessibility where it helps testability and UX
- [x] Add unit tests for state/controllers/helpers
- [x] Add widget tests for list/detail/create flows and presentational widgets
- [x] Add direct repository tests to close the remaining coverage gap
- [x] Run `flutter analyze` and targeted `flutter test --coverage`
- [x] Summarize residual risks / follow-ups

## Change Log

- Created this tracker file to preserve context across sessions.
- Fixed membership count drift by making join/leave idempotent around the
  `memberUserIds` source of truth.
- Moved run-club cover upload ahead of club creation so a failed upload does not
  leave behind a partially-created club.
- Added controller and widget coverage for list, detail, membership, and create
  flows.
- Added repository-focused tests to validate Firestore reads, writes, and
  transactional membership updates.
- Reworked cover-image preview to use `XFile.readAsBytes()` + `Image.memory`,
  removing a platform-specific branch and making the create form easier to
  test across Flutter targets.
- Reached 100% line coverage for all non-generated files under `lib/run_clubs`.
- Split the oversized `run_club_list_tile.dart` widget into focused part files
  so the public API stays stable while the implementation becomes easier to
  navigate and maintain.
- Extracted repeated mutation error snackbar wiring into a shared presentation
  helper to reduce screen-level duplication.
- Reorganized the presentation layer into `create/`, `detail/`, `list/`, and
  `shared/` modules so screens, controllers, state, and widgets now live next
  to the surface they belong to.
- Split the create flow into dedicated create widgets so the screen focuses on
  state and submission orchestration rather than raw form rendering.

## Verification

- `flutter analyze lib/run_clubs test/run_clubs`
- `flutter test test/run_clubs --coverage`
- `flutter test test/run_clubs/run_clubs_repository_test.dart test/run_clubs/run_clubs_controllers_test.dart test/run_clubs/run_clubs_list_controller_test.dart`
- Non-generated `lib/run_clubs` coverage: `951/951` lines, `100.0%`

## Residual Risks / Follow-ups

- `Riverpod` mutations are still marked experimental in the upstream docs, so
  the current pattern is good for this codebase but may need revisiting if the
  package changes its API in a future upgrade.
- `go_router` route extras remain a convenience, not the source of truth. The
  detail flow now continues to rely on the `runClubId` path parameter for
  deep-link safety.
- The feature now has a cleaner internal module shape, but future work could
  still extract a reusable shared async-state scaffold if other feature folders
  converge on the same `loading/error/data` screen pattern.

## Session Resume Prompt

If this session expires, resume by:

1. Reading this file.
2. Reviewing `lib/run_clubs/presentation/list/run_clubs_list_screen.dart` and the sibling `create/`, `detail/`, and `shared/` modules.
3. Continuing from the unchecked items in `In Progress`.
