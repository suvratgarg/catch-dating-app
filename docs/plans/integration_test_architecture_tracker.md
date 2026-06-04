---
doc_id: integration_test_architecture_tracker
version: 0.2.0
updated: 2026-06-04
owner: engineering
status: complete
priority: P0
---

# Integration Test Architecture Tracker

## Purpose

Use this tracker to turn integration-test failures into app and architecture
cleanup. The goal is not a permanently green smoke file; the goal is a feedback
loop where brittle or failing tests reveal missing seams, stale product
contracts, weak route boundaries, and user-visible bugs.

This tracker was created after repairing
`integration_test/app_shell_smoke_test.dart` on 2026-06-04.

## Current State

- `integration_test/app_shell_smoke_test.dart` is now a short shell-health
  suite for launch, auth routing, app-shell initialization, profile-readiness
  entry, and primary tab loading.
- The deterministic feature coverage is split into focused club, event,
  dashboard, Catches, chat/settings/review, and regression suites, all with
  side effects replaced at repository/provider boundaries.
- `bash tool/test_app_shell_integration.sh` runs the split macOS suite and
  passed locally on 2026-06-04.
- The repair surfaced real app issues, not only stale test assertions:
  - Catches swipe deck was nested under shell chrome and could be obscured by
    bottom navigation.
  - Dashboard empty-state logic hid host attendance tools when the user had no
    signed-up events.
  - Club and event detail pages did not preserve route names for analytics
    screen-view reporting.
- Reusable fakes, route helpers, semantic pump helpers, workflow steps, and
  profile-readiness fixtures now live in shared support files instead of one
  integration mega-file.
- Primary action targeting now uses stable keys or semantic contracts for the
  brittle surfaces found during the split: club membership, host club tools,
  event booking CTAs, dashboard event-focus actions, host attendance, Catches
  entry, settings, reviews, payments, and swipe actions.
- Focused regression coverage now protects the app bugs found during the
  repair: detail-route analytics names, the Catches deck root-navigator route,
  and dashboard host tools when the user has no booked events.
- The regression pass also surfaced a test-only time bug: a dashboard event
  focus test used fixed June 4/5 event dates that aged into the past on
  2026-06-04. It now derives future event titles from the fixture events.

## Why The Tests Drifted

1. The integration suite was cold while the app changed quickly. Route names,
   onboarding policy, profile readiness, create-club steps, event flows, and
   settings copy changed without the smoke suite running regularly.
2. The smoke file mixed shell health, feature workflows, repository fakes, user
   fixtures, platform no-ops, and route helpers in one file. That makes it hard
   to update one product area without touching unrelated tests.
3. Test fixtures encoded old domain assumptions. `profileComplete: true` stopped
   being enough once social-readiness began depending on photos, prompts, and
   preference versions.
4. Tests used visible copy and incidental placement as action APIs. Copy checks
   are valuable assertions, but button taps and route entry should prefer stable
   keys, semantics, and helper methods.
5. The app shell grew platform and service dependencies without a canonical fake
   app backend. Each new provider created another reason the full shell could
   fail before the tested feature was reached.
6. Timing was hidden behind broad settle calls. Bounded mutation pumps had to be
   added where animations, streams, or route transitions made `pumpAndSettle`
   the wrong abstraction.

## Completed During The Repair

| ID | Improvement | Status | Notes |
|---|---|---|---|
| ITA-000 | Restore deterministic app-shell smoke coverage | Done | `flutter test integration_test/app_shell_smoke_test.dart -d macos` passes with 32 tests. |
| ITA-001 | Make initial app route test-overridable | Done | Added `initialAppLocationProvider` so tests can start at current routes without environment tricks. |
| ITA-002 | Preserve route names on detail pages | Done | Club/event detail pages now pass route names through their page objects for analytics. |
| ITA-003 | Put swipe deck above shell chrome | Done | `Routes.swipeEventScreen` now uses the root navigator. |
| ITA-004 | Keep dashboard host tools visible | Done | Empty-dashboard logic now also checks `hostEventTools.isEmpty`. |
| ITA-005 | Repair incidental compile blockers encountered by the suite | Done | Fixed the event-success style reference and manual-QA `DateTime` const issue hit while compiling. |
| ITA-010 | Extract a shared app integration harness | Done | Added `integration_test/support/app_shell_test_harness.dart` for app pumping, route helpers, mutation pumping, and the fake app backend. |
| ITA-011 | Create canonical profile fixtures by readiness level | Done | Added `test/support/profile_readiness_fixtures.dart` with social-ready and booking-ready incomplete users. |
| ITA-012 | Split the mega smoke file into shell smoke plus feature flows | Done | Moved clubs, events, dashboard, Catches, chat/settings/review, and regression flows into focused integration files; smoke now covers only shell health. |
| ITA-013 | Add regression tests for app bugs found | Done | Added `integration_test/app_shell_regression_test.dart` for analytics route names and the Catches root-navigator route; added a `DashboardScreen` regression for host tools with no booked events. Also removed a fixed-date dashboard test assumption. |
| ITA-014 | Make app-shell provider additions fail centrally | Done | `appShellTestOverrides` documents and owns deterministic fake/no-op defaults for shell-level providers. |
| ITA-015 | Stabilize action targets with keys and semantic contracts | Done | Added durable action keys for club membership/host tools, event CTAs, host attendance, dashboard actions, and Catches entry; tests keep copy assertions where copy is behavior. |
| ITA-016 | Define route-entry helpers instead of UI-list assumptions | Done | Shared helpers open club detail, event detail, app tabs, and the swipe deck through router contracts when list membership is not under test. |
| ITA-017 | Make onboarding/profile readiness policy explicit and test-owned | Done | Routing and integration tests now use named social-ready and booking-ready incomplete fixtures. |
| ITA-018 | Replace broad settle calls with semantic pump helpers | Done | Harness exposes `pumpRoute`, `pumpMutationUi`, `pumpSheet`, and `flushRepositoryCallbacks`; raw duration pumps are centralized. |
| ITA-019 | Reduce widget-owned business logic exposed by test setup | Done | Feature files seed state through the shared app-shell fake backend, view-model/provider overrides, and narrow route helpers instead of recreating unrelated services per test. |
| ITA-020 | Add a local/scheduled integration command to tooling | Done | Added `tool/test_app_shell_integration.sh` and manifest entry `test:app-shell-integration`. |
| ITA-021 | Expand deterministic local coverage only where fakes are honest | Done | Release ops keeps App Check, real OTP, push, picker, maps, Razorpay, Analytics DebugView, and Crashlytics as live-service evidence instead of fake-local assertions. |
| ITA-022 | Add a smoke-suite ownership note to release operations | Done | `docs/release_operations.md` links this tracker and names the `node tool/run.mjs run test:app-shell-integration` command. |

## Active Backlog

No active integration-test architecture tasks remain in this tracker.

## Recommended Cleanup Order

This tracker is closed. Future app-shell integration work should start from a
new tracker item or from the live-service evidence table in
`docs/release_operations.md`.

## Verification Commands

```bash
bash tool/test_app_shell_integration.sh
flutter analyze --no-fatal-infos integration_test/app_shell_smoke_test.dart integration_test/app_shell_club_flows_test.dart integration_test/app_shell_event_flows_test.dart integration_test/app_shell_dashboard_flows_test.dart integration_test/app_shell_catches_flows_test.dart integration_test/app_shell_chat_settings_review_flows_test.dart integration_test/app_shell_regression_test.dart
flutter test test/routing/router_redirect_test.dart test/dashboard/dashboard_screen_test.dart
```

When a cleanup slice touches shared app-shell providers or routing, also run:

```bash
flutter test test/routing test/core/app_shell_test.dart
```

When a cleanup slice touches event, club, dashboard, swipe, settings, or review
flows, run the focused feature tests for that area before the full smoke suite.
The full split suite is the preferred final local check.

## Definition Of Done

This initiative is complete when:

1. The smoke suite is split into maintainable files with shared support helpers.
2. App bugs found by the original repair have focused regression tests.
3. Canonical profile/readiness fixtures replace duplicated old assumptions.
4. App-shell service/provider additions are handled centrally.
5. Product-copy changes no longer break action targeting unless copy is the
   asserted behavior.
6. The macOS integration command has a documented owner and recurring execution
   path.
