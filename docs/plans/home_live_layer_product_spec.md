---
doc_id: home_live_layer_product_spec
version: 1.0.2
updated: 2026-07-10
owner: product (approved direction 2026-07-05)
status: implemented-behind-flag
---

# Home = The Live Layer — Product Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Related: `docs/design_parity/composition_audit.md` (Screen 1),
`docs/design_language.md` §7 (surfaces), `docs/data_contracts.md`,
`functions/README.md`.

## Problem + thesis

Catch is an episodic app (browse → book → attend → catch window → chats).
The dashboard was assembled like an engagement app's home — evergreen
shelves — so between event cycles it pads itself with content that fails
its own screen (activity graph, follows shelf, recommendations). The fix:

**Home is the app's time axis.** A module earns home placement only if it
is (1) time-sensitive to the user's current state, (2) new since they last
looked, or (3) the single next-step CTA when idle. Evergreen content lives
in Explore or Profile. This is the home analogue of the containment
doctrine and should be cited in reviews the same way.

### Home state machine (the contract)

| State | Trigger | Modules (in order) |
|---|---|---|
| Idle | no upcoming/booked events, no open window | next-step hero CTA (find an event) + unseen organizer posts (Phase 2) |
| Booked | ≥1 upcoming participation | focus rail (logistics: directions, calendar add, invite), organizer posts from booked/joined clubs |
| Event day | today's event | companion/check-in card takes the hero slot (focus rail already does this — preserve) |
| Window open | active catch window | catch-window card ABOVE everything, countdown visible |

Nothing else renders on home. Every module below is self-contained and
portable by design (see Decision gate).

---

## Phase 1A — Home restructure (app-only)

### 1A.1 Remove the activity graph module `[codex]`

Delete `DashboardStrideSection` usage from `DashboardFullSliverBody`, the
`DashboardStrideActionState`/`DashboardStrideSectionActions` wiring, the
`_connectStride`/`_installHealthConnect` handlers, and
`DashboardStrideLoadingCard`. KEEP the health/data layer
(`health_activity` repository, permissions plumbing) — it feeds run-club
compatibility signals. Inventory remaining consumers of
`weeklyActivityProvider`; if home was the sole consumer, mark the provider
`@Deprecated('Home no longer renders weekly activity; retained for
insights/compatibility')` and record in the receipt — do not delete the
data path. `StrideCard` itself: if orphaned after this, delete widget +
widgetbook block; if Profile Insights wants it later that is a separate
product decision (record as backlog note, do not move it yourself).

### 1A.2 Dissolve QuickActions `[codex]`

Delete the `QuickActions` module from home and
`dashboard/shared/quick_actions.dart` (+ widgetbook). Re-home the two
entry points:
- **Calendar**: home header gains a calendar icon action next to the
  notifications bell (`CatchIconAction`, tooltip 'Calendar', pushes
  `Routes.calendarScreen`) — calendar is time-axis utility and belongs on
  the time-axis screen's chrome, not as a content shelf.
- **Saved events**: Explore browse header gains a bookmark icon action
  (`CatchIconAction`, tooltip 'Saved events', pushes
  `Routes.savedEventsScreen`) — saved is browse-state and belongs to
  Explore. Routes/deep links unchanged.

### 1A.3 Remove the club-membership rail `[codex]`

Delete `_buildFollowedClubsRail` + `FollowedClubsRailSkeleton` from
`dashboard_full.dart`. `ClubAvatarRail` itself stays (Explore's joined
rail uses it). Active club membership remains visible in Explore's joined rail,
recommendations, and truthful row context; a separate follow graph is not
implied by this migration.

### 1A.4 Catch-window priority ordering `[codex]`

`focusEvents` assembly in `DashboardFullSliverBody`: when
`viewModel.activeSwipeEvent` is non-null, it sorts FIRST in the rail (the
countdown badge treatment already exists on `EventFocusCard` — reuse; no
new widget). If the rail would otherwise be empty, the window card renders
alone. Acceptance: with an open window plus upcoming events, the window
card is index 0.

### 1A.5 Idle state `[codex]`

When status is `full` but `focusEvents` is empty (and, pre-Phase-2, there
are no posts to show), render the next-step CTA module: reuse
`EmptyHeroCard` (non-fullBleed card variant, existing R2 keep) directing
to Explore. Do NOT render section headers over an empty body. The true
new-user `DashboardHomeScreenStatus.empty` flow is unchanged.

### 1A.6 Analytics for the decision gate `[codex]`

Instrument now, through the existing analytics service:
`home_opened {state: idle|booked|event_day|window_open}`,
`home_module_impression {module}`, `home_action_tap {module, action}`.
These feed the deprecation gate below. Verify events actually emit (the
2026-06 architecture audit found dead funnel events — add a focused test
that the analytics calls fire from the home controller path).

## Phase 1B — Explore absorbs the evergreen content (app-only)

### 1B.1 Recommendations move to Explore `[codex]`

Remove the `Recommendations` module from home;
`buildExploreBodySlivers` gains a "For you" cluster (reuse
`Recommendations` + `RecommendCard` + `dashboardRecommendedEventsProvider`
— rename provider/repository to `explore*` naming in the same change,
with the repo's deprecated-alias convention if referenced widely).
Placement: after the first feed cluster, before the club directory.
Loading/error states follow the feed's existing skeleton grammar (G2).

### 1B.2 Joined membership tunes Explore context `[codex]`

The first implementation incorrectly treated active `clubMemberships` as a
distinct follow graph. Corrected 2026-07-10:

- Explore keeps chronological day ordering; it does not fake a followed-club
  first-page boost from membership ids.
- Membership-derived event context renders `FROM ONE OF YOUR CLUBS`.
- The CLUBS filter exposes `Joined clubs` only. The duplicate `Following` lens
  and its unreachable filter state were removed.
- Joined clubs still drive the personal rail, membership-aware availability,
  and the current recommendation query. The legacy provider/recommendation
  names containing `followed` remain cross-feature naming debt, not evidence of
  a separate user action.

Acceptance: membership-backed UI is truthful and non-duplicative. A real
follow graph, its join/leave/notification/privacy semantics, and whether it may
reorder the chronological feed are owner decisions tracked by
`EXPLORE-PRODUCT-DECISIONS-2026-07-10`.

## Phase 2 — Organizer posts (full-stack, behind a flag)

Gate everything on `AppConfig.enableClubPosts`
(`bool.fromEnvironment`, same pattern as `enablePushMessaging`).

Status 2026-07-05: implemented behind `ENABLE_CLUB_POSTS`. Contract schemas,
callable, fanout notification payloads, host composer entry point, home unread
post module, analytics events, Widgetbook coverage, and data-contract checks
are wired. Production rollout remains gated by the compile-time flag.

### 2.1 Data contract `[codex]`

`clubs/{clubId}/posts/{postId}`: `authorUid`, `text` (≤500 chars,
required), `photoPath?`, `eventId?`, `audience` (`followers` — v1 only
value), `createdAt`, `status` (`active|removed`). Update
`docs/data_contracts.md` + schema-contract codegen; writes ONLY via a new
callable `createClubPost` (functions/README conventions): validates host
role on the club, text length, and the **rate limit — max 3 active posts
per club per rolling 7 days** (server-enforced; surface remaining quota to
the composer). Reads: authenticated users. Run
`./tool/check_data_contract.sh`.

### 2.2 Distribution `[codex]`

On post create, the callable fans out `activity_notifications` to the
club's followers using the existing notification pipeline and the existing
`ActivityNotificationType.clubUpdate` (extend its payload with
`clubId`/`postId`/`eventId?` routing). Push respects
`enablePushMessaging` and existing token handling — do NOT build new push
infrastructure; if the stale-token backlog item blocks reliable delivery,
ship in-app-only and note it. Activity screen renders these through the
existing `NotificationRow` (club identity as the visual, post text as
body, tap → event detail when `eventId` present else club detail).

### 2.3 Host composer `[codex]`

Extend the existing broadcast surface rather than forking it:
`HostBroadcastComposerSheet` (chat_inbox_screen.dart:112) gains an
audience step — 'Attendees' (existing chat broadcast) vs 'Followers' (new
post) — or, if the coupling reads badly in code, a sibling
`ClubPostComposerSheet` composing the same field/sheet primitives. Entry
point: host club tools panel. Composer shows remaining weekly quota;
disabled at 0.

### 2.4 Home unseen-posts module `[codex]`

New home module `ClubPostsHomeSection`: renders up to 3 UNREAD
`clubUpdate` notifications as flat post cards (club avatar + name kicker,
post text, optional event link row; containment: R2 whole-tap). Tap marks
the notification read and routes. Zero unread → module absent. Appears in
idle and booked states per the state machine.

### 2.5 Analytics + guardrails `[codex]`

Events: `club_post_created {clubId}`, `club_post_impression
{surface: home|activity}`, `club_post_open`. Guardrail backlog (record,
don't build): reach weighting by club quality signals, report/moderation
tooling beyond `status: removed`.

## Decision gate — home deprecation (explicitly OUT of scope)

After Phase 1+2 have ≥3 weeks of data: if idle-state `home_opened` sessions
show a bounce (tab-switch <3s, no module interaction) above ~60%, fold the
live-layer modules into Explore as a pinned strip and remove the tab. The
modules above are built self-contained so this is a re-parenting, not a
rebuild. No work now beyond the 1A.6 instrumentation.

## Non-goals (v1)

- Deleting the health integration/data layer.
- Tab navigation surgery.
- Post comments, likes, reposts, or follower counts on posts.
- Member-visible follower counts / social-graph mechanics.
- Moderation tooling beyond the rate limit + `status` field.

## Verification + workflow

Standard repo workflow per AGENTS.md. Per phase: focused widget tests
(home state machine states 1A; explore boost/lens 1B; composer quota +
notification rendering 2), analyzer, `bash tool/widget_cleanup_scan.sh`,
gutter/section scanners on touched screens, data-contract check (Phase 2),
`node tool/agent/check_agent_readiness.mjs`, widget catalog + TESTS.md +
passes.jsonl updates. Phase order is 1A+1B together (one release: club
membership remains legible in Explore when its Home rail is removed), then 2.
