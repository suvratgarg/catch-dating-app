---
doc_id: ui_capture_pipeline_plan
version: 0.2.0
updated: 2026-05-31
owner: ui_capture_pipeline
status: active_draft
---

# UI Capture Pipeline Plan

## Goal

Build one deterministic app UI capture pipeline with two consumers:

- **Visual review:** raw, fast, reproducible PNGs for app screens after UI changes.
- **Marketing media:** curated, polished screenshots that feed
  `tool/marketing/capture_manifest.json` and then the website sync pipeline.

The pipeline should reuse the existing golden-test rendering foundation, but it
should not overload golden baselines with every review image. Goldens remain the
small committed regression contract; UI captures become broader generated
artifacts.

## Rendering Foundation & Fixtures

The renderer is the existing golden harness: `matchCatchGolden`
(`test/goldens/support/golden_pump.dart`) pumps a widget in the real `AppTheme`
(light + dark) on a fixed surface at DPR 1.0 with the bundled fonts loaded, and
writes a deterministic PNG. The capture harness wraps the same path but writes to
generated artifact dirs (not committed golden baselines) and can vary device size,
theme, and text scale. (The Phase 2 `profile_view_test.dart` is the proof of this
path end-to-end.)

The real work is **per-screen fixtures**: screens are `ConsumerWidget`s, so each
catalog entry must supply the Riverpod provider overrides (and any path params)
that make it paint deterministically. Strategy:

- **Review catalog:** reuse the existing test fixtures (`buildUser`,
  `buildPublicProfile`, the `Fake*Repository` doubles, `events_test_helpers`, …) —
  fast, realistic-enough, already maintained.
- **Marketing slots:** use the curated `salesDemo.*` fixture keys named in
  `tool/marketing/capture_manifest.json` (owned by the sales-demo workstream) so
  copy/photos look intentional, plus the optional iphone-15 device frame.
- **Synthetic sales data:** adapt the canonical persona catalog through
  `test/ui_captures/fixtures/sales_demo_synthetic_fixtures.dart` so captures can
  reuse polished demo names, demographics, and prompts while staying offline and
  deterministic. Planned remote photo URLs are intentionally skipped until the
  asset catalog marks them published or provides local committed images.

Both consumers render off **one screen catalog** (`id → build widget + provider
overrides`). Photos must be committed local sample images for determinism (reuse
demo persona images, or fall back to the activity-art placeholder for review).

## Phase 0 Scope

Phase 0 is inventory and drift control. It does not render screens yet.

Deliverables now:

- Route-derived screen inventory generated from `lib/routing/go_router.dart`.
- Human scope decisions for which routed surfaces become captures.
- A drift check that notices router changes before the capture catalog goes stale.
- A coverage check that forces every route to be captured, aliased, planned, or
  explicitly excluded.
- A first-priority list for the Phase 1 vertical slice.

## Automated Router Drift Capture

Route changes should be caught mechanically, not by asking a reviewer to remember
that screenshots exist.

The initial mechanism is:

```sh
node tool/ui_capture/check_route_inventory.mjs --update
node tool/ui_capture/check_route_inventory.mjs --check
```

`--update` reads `lib/routing/go_router.dart` and writes
`tool/ui_capture/route_inventory.json`. The generated inventory includes:

- a normalized file hash for `go_router.dart`;
- a normalized route-contract hash for the `Routes` enum plus the `GoRouter`
  route tree;
- counts for `GoRoute`, shell branch, enum route, and route references;
- each route id, path, path parameters, fixture requirement, and dev-gated flag.

`--check` fails when `go_router.dart` changed but the route inventory was not
regenerated. The tool is registered in `tool/tools_manifest.json` as
`ui-capture:route-inventory`. Once the repo's tool manifest is fully clean, it
can run through:

```sh
node tool/run.mjs check ui-capture:route-inventory
```

This is intentionally stricter than a hand-maintained list. A route path change,
new route, deleted route, route-tree change, or router helper change forces a
small generated diff. The reviewer then updates the capture scope or records an
explicit exclusion.

Phase 1 should extend this check once the Dart capture catalog exists:

- every non-dev, user-facing route must map to at least one capture entry, or
  carry an explicit exclusion reason;
- marketing fixture keys must map to capture entries when their manifest status
  is `active`;
- capture entries should fail fast if their required path parameters do not have
  deterministic fixture values.

The first extension now lives in:

```sh
node tool/ui_capture/check_capture_coverage.mjs --check
```

It validates `tool/ui_capture/capture_coverage.json` against both
`tool/ui_capture/route_inventory.json` and the Dart capture catalog in
`test/ui_captures/catalog/screen_capture_catalog.dart`. If a route is added to
`go_router.dart`, the route-inventory update makes the coverage check fail until
the new route is classified as `captured`, `alias`, `planned`, or `excluded`.

## Capture Coverage Defaults

Baseline coverage means:

- one happy-path state per included route or screen;
- light and dark captures for review;
- raw unframed review PNGs;
- curated, optionally device-framed PNGs only for marketing slots;
- no full matrix of empty/loading/error/text-scale variants until the baseline
  catalog is stable.

Explicit exclusions for baseline coverage:

- dev and lab routes under `/dev/**`;
- transient loading screens unless they are user-visible for meaningful time;
- sheets/dialogs that are only reachable as states inside a parent route, until
  their parent is captured;
- one-off payment confirmation states that require external transaction context,
  unless we build a deterministic fixture.

## Route Inventory

Generated source of truth:
`tool/ui_capture/route_inventory.json`.

Coverage policy:
`tool/ui_capture/capture_coverage.json`.

| Route | Path | Baseline Decision | Priority | Fixture Notes |
|---|---|---|---|---|
| `loadingScreen` | `/loading` | Exclude initially | P3 | Transient startup state; only capture if launch UX work needs it. |
| `startScreen` | `/start` | Include | P2 | Static welcome fixture. |
| `authScreen` | `/auth` | Include by state | P2 | Split into phone and OTP capture entries once auth internals are cataloged. |
| `onboardingScreen` | `/onboarding` | Include by step | P2 | Capture representative happy-path steps, not every form state in baseline. |
| `calendarScreen` | `/calendar` | Include | P2 | Needs current user and signed-up/hosted event fixtures. |
| `calendarEventDetailScreen` | `/calendar/clubs/:clubId/events/:eventId` | Covered by event detail capture | P2 | Same widget as event detail; catalog can alias to canonical event-detail fixture. |
| `savedEventsScreen` | `/saved-events` | Include | P2 | Needs saved event list fixture. |
| `savedEventDetailScreen` | `/saved-events/clubs/:clubId/events/:eventId` | Covered by event detail capture | P2 | Same canonical detail surface with saved-events entry path. |
| `filtersScreen` | `/filters` | Include | P2 | Needs swipe/event filter defaults. |
| `dashboardEventDetailScreen` | `/dashboard/clubs/:clubId/events/:eventId` | Covered by event detail capture | P1 | Same canonical detail surface with dashboard entry path. |
| `dashboardHostEventManageScreen` | `/dashboard/clubs/:clubId/events/:eventId/manage` | Include | P1 | Marketing-adjacent host live console candidate. |
| `hostEventManageScreen` | `/clubs/:clubId/events/:eventId/manage` | Include | P1 | Canonical host manage route; capture setup/live/report sections. |
| `editHostedEventScreen` | `/clubs/:clubId/events/:eventId/edit` | Include | P2 | Needs hosted event + club fixture. |
| `eventSuccessHostScreen` | `/dashboard/clubs/:clubId/events/:eventId/success` | Covered by host manage setup | P2 | Alias unless a distinct success host view emerges. |
| `eventLocationMapScreen` | `/events/:eventId/location` | Include later | P3 | Map rendering may need a deterministic mock/static fallback. |
| `dashboardScreen` | `/` | Include | P1 | Main review surface; current user, upcoming events, clubs, notifications. |
| `notificationsScreen` | `/notifications` | Include later | P3 | Activity list fixture. |
| `clubsListScreen` | `/clubs` | Include | P1 | Event discovery / club browse review surface. |
| `clubDetailScreen` | `/clubs/:clubId` | Include | P1 | Needs club, event list, host/member state. |
| `editClubScreen` | `/clubs/:clubId/edit` | Include later | P3 | Needs owned club fixture. |
| `eventDetailScreen` | `/clubs/:clubId/events/:eventId` | Include | P1 | Canonical event detail capture. |
| `attendanceSheet` | `/clubs/:clubId/events/:eventId/attendance` | Include via host manage | P2 | Sheet-like route; host live capture should include attendance controls. |
| `eventSuccessCompanionScreen` | `/clubs/:clubId/events/:eventId/companion` | Include | P1 | Post-event catch-window / event-success candidate. |
| `createClubScreen` | `/clubs/create-club` | Include later | P3 | Multi-step form; baseline can capture first valid step. |
| `createEventScreen` | `/clubs/:clubId/create-event` | Include | P1 | Marketing host setup candidate. |
| `swipeHubScreen` | `/catches` | Include | P1 | Main Catches hub. |
| `swipeEventScreen` | `/catches/:eventId` | Include | P1 | Post-event roster/catch window candidate. |
| `eventRecapScreen` | `/catches/:eventId/recap` | Include later | P2 | Needs attended event recap fixture. |
| `matchesListScreen` | `/chats` | Include | P1 | Match list + new matches rail. |
| `chatScreen` | `/chats/:matchId` | Include | P1 | Marketing match chat context candidate. |
| `profileScreen` | `/you` | Include | P1 | Self profile; already close to golden fixture precedent. |
| `reviewsHistoryScreen` | `/you/reviews` | Include later | P3 | Needs review history fixture. |
| `publicProfileScreen` | `/profiles/:uid` | Include | P1 | Public profile and profile-redesign review surface. |
| `settingsScreen` | `/settings` | Include later | P3 | Account/safety settings fixture. |
| `paymentHistoryScreen` | `/payment-history` | Include later | P3 | Needs payment history fixture or empty state. |
| `paymentConfirmationScreen` | `/payment-confirmation` | Exclude initially | P3 | Route requires transaction extra; capture only with deterministic data object. |
| `eventPolicyLabScreen` | `/dev/event-policy-lab` | Exclude | P4 | Dev-gated lab. |
| `eventSuccessLabScreen` | `/dev/event-success-lab` | Exclude | P4 | Dev-gated lab. |
| `eventSuccessManualQaScreen` | `/dev/event-success-manual-qa` | Exclude | P4 | Manual QA surface, not baseline app review. |
| `eventSuccessPreviewScreen` | `/dev/event-success-preview/:clubId/:eventId` | Exclude | P4 | Dev-gated preview. |

## Phase 1 Vertical Slice

Start with the smallest set that proves the full path from fixture to generated
PNG to marketing sync:

| Capture ID | Route/Surface | Consumer | Why First |
|---|---|---|---|
| `profile_self` | `profileScreen` | Review | Existing profile golden work gives the shortest path to a working capture. |
| `member_event_discovery` | `clubsListScreen` or event discovery subsection | Review + marketing | Maps to `salesDemo.member.eventDiscovery`. |
| `event_detail_member` | `eventDetailScreen` | Review | Reused by calendar/saved/dashboard detail aliases. |
| `post_run_catch_window` | `swipeEventScreen` or companion surface | Review + marketing | Maps to `salesDemo.member.postRunCatchWindow`. |
| `match_chat_context` | `chatScreen` | Review + marketing | Maps to `salesDemo.member.matchChatContext`. |
| `host_event_setup` | `createEventScreen` or host setup section | Review + marketing | Maps to `salesDemo.host.eventSetup`. |
| `host_live_console` | `hostEventManageScreen` live section | Review + marketing | Maps to `salesDemo.host.liveConsole`. |
| `host_post_event_report` | `hostEventManageScreen` report section | Review + marketing | Maps to `salesDemo.host.postEventReport`. |

Exit criteria for Phase 1:

- capture harness writes raw PNGs under `artifacts/ui-captures/review/`;
- at least one marketing capture writes to `artifacts/marketing/app-screenshots/`;
- route inventory check passes;
- marketing media check passes for any activated captures;
- failures are deterministic and actionable when fixtures are missing.

Current implemented captures:

- `profile_self` covers `profileScreen`.
- `event_detail_member` covers the canonical event detail surface and backs the
  calendar, saved-events, and dashboard event-detail route aliases.
- `member_event_discovery` covers `clubsListScreen` and maps to
  `salesDemo.member.eventDiscovery`.
- `post_run_catch_window` covers `swipeEventScreen` and maps to
  `salesDemo.member.postRunCatchWindow`.
- `match_chat_context` covers `chatScreen` and maps to
  `salesDemo.member.matchChatContext` with profile copy adapted from the
  synthetic sales persona catalog.
- `dashboard_home` covers `dashboardScreen` with current-user, event,
  notification, hosted-club, and recommendation fixtures.
- `club_detail_member` covers `clubDetailScreen` with member-state club detail,
  upcoming event, and review fixtures.
- `host_event_setup` covers `createEventScreen` and maps to
  `salesDemo.host.eventSetup`.
- `host_live_console` covers `hostEventManageScreen` and maps to
  `salesDemo.host.liveConsole`.
- `host_post_event_report` covers the `hostEventManageScreen` report section
  and maps to `salesDemo.host.postEventReport`.
- `swipe_hub_active` covers `swipeHubScreen` with an active catch window.
- `event_success_companion` covers `eventSuccessCompanionScreen` with a
  deterministic attendee companion guide fixture.
- `matches_list_context` covers `matchesListScreen` with synthetic persona
  matches and conversations.
- `public_profile_member` covers `publicProfileScreen` with a synthetic sales
  persona.
- `start_welcome` covers `startScreen`.
- `auth_phone_entry` covers `authScreen` in the phone-entry state.
- `onboarding_welcome` covers `onboardingScreen` in the welcome state.
- `calendar_planned_events` covers `calendarScreen` with booked and saved
  events.
- `saved_events_list` covers `savedEventsScreen`.
- `filters_preferences` covers `filtersScreen`.
- `edit_hosted_event` covers `editHostedEventScreen`.
- `event_location_map` covers `eventLocationMapScreen` with network map tiles
  disabled.
- `notifications_activity` covers `notificationsScreen`.
- `create_club_basics` covers `createClubScreen`.
- `edit_club_basics` covers `editClubScreen`.
- `event_recap_attendees` covers `eventRecapScreen`.
- `reviews_history_list` covers `reviewsHistoryScreen`.
- `settings_account` covers `settingsScreen`.
- `payment_history_empty` covers `paymentHistoryScreen`.

## Marketing Export

Active marketing slots are rendered through:

```sh
node tool/ui_capture/run_captures.mjs --all
node tool/marketing/export_app_screenshots.mjs --update
node tool/marketing/sync_website_media.mjs --update
```

The review capture runner reads every `ScreenCaptureEntry` from the catalog when
called with `--all`. The marketing exporter reads
`tool/marketing/capture_manifest.json`, resolves each active `fixtureKey` to a
capture catalog entry, renders the raw app surface through the Flutter capture
harness, and wraps the light-mode PNG in a device frame. The current marketing
device is `iphone-17-pro`, modeled as a 402 x 874 logical viewport with
top/bottom safe-area padding and a Dynamic Island frame overlay.

The first active marketing captures are:

- `member-event-discovery` from `salesDemo.member.eventDiscovery`.
- `post-run-catch-window` from `salesDemo.member.postRunCatchWindow`.
- `match-chat-context` from `salesDemo.member.matchChatContext`.
- `host-event-setup` from `salesDemo.host.eventSetup`.
- `host-live-console` from `salesDemo.host.liveConsole`.
- `host-post-event-report` from `salesDemo.host.postEventReport`.

Visual readiness is tracked separately in
`docs/plans/ui_capture_visual_qa.md`. Route coverage can be complete while a
capture remains fixture-thin or review-only.

## CI Placement

Initial CI-safe gate:

```sh
node --check tool/ui_capture/check_route_inventory.mjs
node tool/ui_capture/check_route_inventory.mjs --check
node --check tool/ui_capture/check_capture_coverage.mjs
node tool/ui_capture/check_capture_coverage.mjs --check
```

Recommended later gates:

- PRs: route inventory check plus small capture smoke catalog.
- Main: full active marketing capture generation plus
  `node tool/marketing/sync_website_media.mjs --check`.
- Manual review: full review catalog artifact upload; do not commit every review
  PNG unless it is a curated golden or marketing screenshot.
