---
doc_id: explore_screen_quality_pass_spec
version: 1.1.0
updated: 2026-07-19
owner: app
status: complete
---

# Explore Screen Quality Pass — UX, Data Layer & Visual Craft Spec

## 0. Context

A staff-level review of the Explore discovery surface (`screen.explore.discovery`,
routes `/clubs` + `/clubs/map`) across three layers:

- **Product/UX** — the feed, hero, filtering, search, states, and navigation model
  of `lib/explore/`.
- **Data layer** — every Firestore repository, query, index, and pagination (or
  absence of it) that feeds the app, since the Explore feed exposes the systemic
  problems most visibly. Pull-to-refresh, repository consistency, index parity,
  and pagination are scoped as **one** workstream (§3) because they are the same
  problem: there is no read-path discipline.
- **Visual craft** — pixel-level audit of the shared event ticket
  (`EventDateRailCard`), club polaroid (`CatchPolaroid`), cover story, and the
  explore widgets against the locked design language (`docs/design_language.md`).

Sources: code audit of `lib/explore/**`, `lib/events/shared/event_tiles/**`,
`lib/core/{theme,widgets}/**`, all `lib/**/data/*repository*.dart`,
`firestore.indexes.json`, `docs/design_language.md`, the design baseline
`design/reference_screens/screen.explore.discovery/discovery_feed.png`, and the
rendered captures under `artifacts/ui-captures/` (vintage caveats in §4.4).

Relationship to existing docs: `docs/plans/explore_findings_remediation_spec.md`
covers **architecture-pattern** remediation for the same screen (provider-free
state adapters, controller boundaries) — this spec complements it and does not
repeat it. Product decisions were initially tracked as
`EXPLORE-PRODUCT-DECISIONS-2026-07-10` in `docs/audit_registry/backlog.json`.
The owner authorized the recommended defaults on 2026-07-19; the completion
record below is now the controlling resolution.

---

## 0.1 Concurrency carve-out — parallel stretch-spec thread (added 2026-07-17)

[`catch_system_stretch_spec.md`](catch_system_stretch_spec.md) is being
executed **concurrently in a separate thread**. That thread owns edits to:
`lib/core/widgets/catch_field*`, `catch_section_layout.dart`,
`catch_top_bar.dart`, `catch_async_value_view.dart`, `catch_error_state.dart`,
`catch_chip.dart` (S2 motion), `lib/core/forms/`, plus heavy churn in
`docs/widget_catalog.md` and the primitives Widgetbook stories.

**Hard rule for this thread: do not edit any file in that list.** Everything
else in this spec — including the other core-widget fixes in §4.1
(`catch_count_pill`, `catch_day_section_header`, `catch_cover_story`,
`catch_polaroid`, `catch_skeleton`) — is NOT owned by the stretch thread and
proceeds normally.

### Deferred to the second pass

1. §4.1 row `catch_chip.dart:160` (`_pressedScale` token bypass) — the
   stretch thread's S2 phase is animating chip selection in that file.
2. **§6 in full** (hand-rolled → primitive promotions) including the
   widget-catalog stale-entry fixes at the end of §6 — the stretch thread's
   §9.4 survey covers the same surfaces (`CatchSurface`,
   `CatchBottomSheetScaffold`, `CatchChip`, …) and the catalog line numbers
   cited in §6 will be stale by then.
3. **W6** in §8 (it is §6's workstream).

### What the second pass should expect to find

By the time the deferred items run, the stretch thread will have landed some
or all of the following — verify each, don't assume:

- `CatchChip` changed: selection animation added (S2) and possibly the
  pressed-scale bypass already fixed. Re-check §4.1's chip row against the
  then-current file; apply only if still present.
- `CatchAsyncValueView` API narrowed: context-less `data`/`loading`/`error`
  callbacks deleted; `builder`/`loadingBuilder`/`errorBuilder` are the only
  forms. Any explore code written in the first pass must already use the
  builder forms (they exist today) so the migration never touches this
  feature.
- `CatchErrorState.retryLabel` no longer has a hardcoded English default;
  `.fromError` resolves it from l10n.
- Top bar: search parameters consolidated into a `CatchTopBarSearch` config
  object on both bars; `CatchSliverTopBar` deleted. If explore screens use
  top-bar search, their call sites will have been migrated by that thread —
  rebase, don't re-shape.
- `docs/widget_catalog.md` heavily updated (facade census, doctrine links,
  §9 surface entries). The §6 stale-entry fixes must be re-verified against
  the then-current catalog, not the line numbers in this doc.
- **Entry condition for the deferred items**: the stretch spec's §9.4.1
  survey findings table exists (appended to that doc). Reconcile §6's
  promotion list against its dispositions before building anything —
  in particular `CatchSurface.listCard` and the `CatchBottomSheetScaffold`
  adoption, which the survey may have endorsed, reshaped, or superseded.
  If §9.4.1 does not exist yet, the second pass is blocked; do not start it.

---

## 0.2 Completion record — 2026-07-19

All seven workstreams are implemented. The owner authorized the spec's
recommended defaults, and the deferred W6 pass was reconciled against the
landed stretch §9.4.1 widget survey before editing the current widget tree.

| Workstream | Resolution |
|---|---|
| W1 | Added query-limit policy, cursor pagination and freshness ownership, pull refresh/tab re-entry invalidation, missing composite indexes, and index-parity enforcement. |
| W2 | The cover uses a deterministic availability-aware recommendation score, never promotes blocked/ineligible/past supply, keeps the promoted event in chronological results, and describes the next detail action honestly. |
| W3 | Retired the unwired Cross Paths proposal because no consent-safe relationship source exists. Explore event tickets use veiled attendee-count proof without profile reads; club polaroids show host and rating context. |
| W4 | Shipped the seven-day intent strip plus Any, visible applied filters/live result counts, events-only distance copy, ineligible-event demotion, and empty-market recovery. |
| W5 | Closed the token, tap-target, semantics, cover contrast/photo resolution, price-copy, localization, and visual-trust findings. |
| W6 | Adopted the current `CatchSurface.card`, `CatchButton`, `CatchBottomSheetScaffold`, and `CatchMonoLabel` contracts instead of adding superseded aliases. Added governed `CatchIndexRow` and `CatchClubCover` concepts, an `EventTicketStub` event-card member, shared count/distance copy, and the named `CatchDisplayStep` scale with Widgetbook/catalog coverage. |
| W7 | Refreshed the current visual evidence contract and retired stale-vintage assumptions from active Explore parity metadata. |

Product defaults are explicit: cover ranking may reorder the cover only, never
the chronological feed; Cross Paths stays retired until a consent-safe,
relationship-backed provider is designed; the map ring and filter-sheet
distance remain one state; external events remain clearly read-only supply.

---

## 1. Executive summary

The Explore screen is well-built at the component level and weak at the product
level. Design-system discipline is high; the failures are ranking, honesty,
freshness, and curation. The data layer underneath it has **no pagination
anywhere**, ad-hoc limits, and missing indexes — one of which is a live crash
path.

Top findings, in the order a user would feel them:

| # | Finding | Layer | § |
|---|---|---|---|
| 1 | The hero is `items.first` — soonest, not best — and its "Claim a seat" CTA navigates to a detail page regardless of availability | UX | 2.1 |
| 2 | A dating app whose discovery screen contains no people: the only human signal is mono meta text; the cross-paths people card is dead code | UX | 2.2 |
| 3 | The feed is a sealed ≤80-item window: no pull-to-refresh, no pagination, stale availability, and a count line that implies exhaustiveness | UX + data | 2.3, 3 |
| 4 | Events the viewer cannot join render at full visual weight, with "Full for you" copy that doesn't explain itself | UX | 2.4 |
| 5 | Zero pagination infrastructure app-wide; roughly half of all list queries are unbounded (chat history, matches, reviews, payments…) | Data | 3.1 |
| 6 | Two required composite index groups are missing from `firestore.indexes.json`; one (`discoveryAvailability` + `discoveryGeoCell`) is a live `FAILED_PRECONDITION` path | Data | 3.2 |
| 7 | Feed composition is hardcoded: club intermix at positions 2/5, no entity diversification (one club can fill 3 of 5 cards **and** the polaroid) | UX | 2.7 |
| 8 | Dark-mode cover story fails legibility: white kicker/title over a light activity glow, scrim alpha 0.035 is not a contrast floor | Craft | 4.5 |
| 9 | The capture library is multi-vintage: `full-catalog` PNGs still show the retired serif-italic identity and pre-hairline tickets — pixel QA against them is invalid | Craft | 4.4 |
| 10 | Club polaroid never shows rating/review count (which exist and drive ranking) and resolves cover photos via the wrong field | Craft | 5.2 |

---

## 2. Product & UX critique

What works (do not regress): empty-state escalation on the event feed
("Nothing tonight → See weekend", `explore_screen_state.dart:1152-1188`); the
body-state machine degrading to `contentWithoutClubs` when the clubs source
fails (`explore_screen_state.dart:996-1053`); the accessibility baseline
(semantics on chrome, text-scale-2.0 and reduced-motion captures); near-total
Catch*-primitive adoption.

### 2.1 The hero is a slot machine, and its CTA is a lie

- `featuredItem` is literally `items.first` — the chronologically next event
  (`explore_feed_view_model.dart:44`). The most visually dominant element sells
  whatever is soonest, not what is best. A ranking function already exists for
  the "For you" rail (`rankExploreEventRecommendations`) and is not used here.
  This is "pending" as a product decision in the backlog, but the code has
  already decided.
- The featured item is **removed from the day-grouped list below** — the feed
  teaches chronological order and then the soonest event silently isn't in it.
- The cover CTA label is unconditionally "Claim a seat"
  (`explore_screen_state.dart:322`) and the handler only routes to event detail
  (`explore_screen.dart:116-136`). A **Full for you**, **Members only**, or
  age-restricted event can hero with "Claim a seat" on it.

**Recommendations:** rank the hero (availability × attendance × recency, reusing
the recommendations ranker); keep the hero item in the list or accept the
duplication; make the CTA either deep-link into the booking flow or render
availability-aware copy ("View event", "Join waitlist", "Members only").

### 2.2 The people-shaped hole

Everything on Explore is supply: events and clubs. The only signals that other
humans exist — "24 GOING · 6 LEFT", "BALANCED 5:5" — are the strongest
conversion levers a dating product has, rendered as tertiary mono meta. The one
people-surface originally built for this screen,
`catch_cross_paths_card.dart` (316 lines), was unwired. The 2026-07-19
resolution retired it until a consent-safe relationship source exists and
shipped veiled attendee-count proof on event tickets without attendee-profile
reads. Friends-going and saved lanes remain future product/data contracts.

**Resolution:** Cross Paths is retired; the event-ticket people signal uses the
existing privacy veil and aggregate attendance count (§5.1).

### 2.3 The feed is a sealed window

One Firestore query, `limit 80`, ordered by `startTime`
(`event_discovery_repository.dart:46,147`); everything else is in-memory
filtering. **No `RefreshIndicator` exists anywhere in `lib/explore/`** (verified
by grep), no load-more, no revalidation on tab re-entry. Consequences:

- In a dense city, events beyond the 80th soonest silently do not exist, while
  "10 PLANS · JUN 11–17" implies exhaustive supply.
- Availability copy ("6 LEFT") is fetched once per provider lifetime and can go
  arbitrarily stale — a trust bug for a booking product.
- The only refresh path is leaving the tab or toggling a filter.

**Recommendation:** this is the user-visible half of workstream §3: pull-to-
refresh, revalidate-on-re-entry, cursor pagination for "Anytime", and an honest
count ("10+ plans") until the window is honest.

### 2.4 Eligibility noise

The status model knows exactly which events the viewer cannot join —
`fullForViewer`, `inviteRequired`, `membershipRequired`, `ageRestricted` all map
to `EventTileStatus.ineligible` (`explore_feed_view_model.dart:212-237`) — but
they render chronologically interleaved at full visual weight. "Full for you"
means "your gender bucket is full" and reads like a system error; in a dating
product it is the single most common dead end.

**Recommendation:** demote ineligible events visually or collapse them behind a
"N more you can't join" reveal (already a backlog candidate — ship it); rewrite
the "Full for you" copy to name the reason.

### 2.5 Time scopes fight each other

Tonight / Tomorrow / Weekend / This week / Anytime
(`explore_view_model.dart:45-83`) are mutually exclusive buckets that
semantically overlap (Weekend ⊂ This week). Users think "when am I free?", not
"which bucket is this in?". The default is This week, chosen so the rail "reads
as live" (`explore_view_model.dart:85-89`) — a content-availability decision,
not an intent decision. Tonight is the highest-intent scope and sits one tap
away from where the user was parked.

**Recommendation:** replace with a horizontal date strip (Tonight + next 6 days
+ Any) that shows per-day supply density and removes the taxonomy; short of
that, make the default adaptive (Tonight when it has supply before early
evening, else This week).

### 2.6 Filtering is blind

- Active filters vanish when the sheet closes: the tune icon gets a count badge
  (`explore_filter_rail.dart:88-95`) but the rail never shows *what* the filters
  are; no removable applied-filter chips.
- The sheet applies live but shows no result count — "Done" is the only way to
  learn what a filter did.
- The distance filter silently does not apply to clubs (clubs carry no
  coordinates, documented at `explore_view_model.dart:127-137`) with zero
  messaging.
- Missing filter dimensions that the cards themselves advertise: price ("Free"),
  spots left, cohort balance ("5:5"), and any specific date beyond the five
  presets.

**Recommendations:** applied-filter chip row under the rail; live "Show N plans"
footer in the sheet; label distance "events only" or hide the club directory
when it is active; add price and balance filters.

### 2.7 Feed composition is hardcoded and uncurated

- A club polaroid is injected at feed position 2 and a club row at position 5
  (`explore_screen_state.dart:624-635`) regardless of relevance, rating, or
  joined state — while a joined-clubs avatar rail already sits above the feed.
- There is no entity diversification: the current rendered fixture shows 3 of 5
  event cards from one club **and** the polaroid promotes the same club
  (`artifacts/ui-captures/full-catalog/member_event_discovery/light.png`).
- The "This week" rail lifts ≥2 recommended events **out of their day groups**
  (`excludeEventIds`, `explore_screen_state.dart:376-382`), breaking the one
  ordering rule the feed teaches: Saturday's event appears in "This week" while
  Tuesday's sits in the list.

**Recommendations:** exclude joined clubs and clubs already over-represented in
the visible window from intermix slots; make placement ranked rather than
positional; either let ranking reorder the whole feed or stop extracting items
from day groups — pick one ordering contract.

### 2.8 Two counts of "what's out there" disagree

The header says "10 PLANS"; the floating pill says "MAP · n" where n is
*mappable* events (`explore_screen_state.dart:52`) — a different number,
unexplained, on the same screen. Unify or label ("10 on map").

### 2.9 Dead ends and silent state destruction

- "No clubs in {city} yet" has **no action** (`explore_screen.dart:449-499`) —
  the exact surface a new-market user lands on. Add "notify me when we launch
  here" / "start the first club" / "change city".
- Search is a cold text field: no recents, no trending, no grouped results
  (events vs clubs); server search needs ≥2 chars and caps at 20
  (`explore_search_repository.dart:75`).
- Changing city silently wipes the query and local filters
  (`explore_view_model.dart:249-259`) — no snackbar, no undo.

### 2.10 The transactional half of the screen is not localized

Chrome copy goes through l10n, but feed meta is hardcoded English: day labels
"Today · "/"Tomorrow · " (`explore_feed_view_model.dart:111-123`), distance
"x km away"/"m away" (`:155-165`, duplicated at `:199-209`), "Free" (`:170`),
and every availability label ("Open", "1 spot left", "Full for you", "Members
only", "Must be 25+" — `:239-262`). Also: the activity browse grid's *semantic*
label hardcodes English while its visible text is localized
(`explore_event_type_browse_grid.dart:384-390`).

### 2.11 Navigation & IA drift

- The Explore tab's route is `/clubs` (`routing/go_router.dart:89`) — deep links
  and analytics will say "clubs" forever. Add a redirect.
- Profile city beats GPS (`explore_city_controller.dart`): a traveling user sees
  home-city supply with only the tiny "EXPLORE · BANDRA" kicker as a hint. When
  GPS strongly disagrees with the profile city, show a "You're in X — switch?"
  nudge.
- The map is a hard route push — full context loss. Verify the map's distance
  ring and the filter sheet's distance filter are the same state; if they are
  not, that is a state-fork bug.

---

## 3. Data-layer workstream — pull-to-refresh, repositories, indexes, pagination

The "implemented haphazardly" hypothesis is half right: there *is* a consistent
skeleton (one repository per feature, `withBackendErrorContext`/
`withBackendErrorStream` wrappers, `withDocumentIdConverter`, a shared `whereIn`
chunk helper, contract-owned schemas). But **pagination does not exist**,
roughly half of all list queries are **unbounded**, index parity is maintained
by nothing, and two client-side query engines re-do the server's job.

### 3.1 Current state (audit findings)

**No pagination infrastructure anywhere.** Zero uses of `startAfterDocument`/
cursor state in `lib/`; no shared pagination helper; no provider holds a cursor.
Every list is a one-shot `Future<List>` or `Stream<List>` capped by an ad-hoc
limit — or not capped at all. `docs/action_cardinality_policy.md:80-81` already
records chat pagination as known debt.

**The limit zoo:** 80 (event discovery, `event_discovery_repository.dart:46`),
40 (external events, `external_event_repository.dart:29`), 30 (clubs,
`clubs_repository.dart:31`), 50 (activity notifications), 20 (explore search
callable), 10/chunk→take(30) (recommended events, `event_repository.dart:232`),
10 (event payment lookup, `payment_history_repository.dart:80` — a correctness
cliff: it sorts client-side to find the latest and can silently miss it) — and
**no limit at all** on: chat messages (entire history streamed,
`chat_repository.dart:50-52`), matches ×2 unbounded streams merged client-side
(`match_repository.dart:92-107`), reviews ×3, payments history, blocks, saved
events, participations, memberships, hosted/owned clubs, full swipe history
(`swipe_repository.dart:36`), event-success lists.

**Missing indexes** (queries that will fail with `FAILED_PRECONDITION`):

| Query | Needs | Status |
|---|---|---|
| `EventRepository.watchInviteLinks` — `eventId ==` + `orderBy(createdAt)` (`event_repository.dart:111-117`) | `eventInviteLinks (eventId, createdAt)` | **missing** — no `eventInviteLinks` entry at all |
| Discovery with `availabilityFilter=open` **and** distance (`event_discovery_repository.dart:193-220`) | `(discoveryMarketId, status, discoveryAvailability, discoveryGeoCell, startTime)` | **missing** — live crash path |
| Same + single-activity equality | `(…, discoveryAvailability, discoveryActivityKind, discoveryGeoCell, startTime)` | **missing** |

Nothing mechanically keeps queries and indexes in sync — drift is caught at
runtime, in production. Eight dead `runs`/`runClubs`/`runParticipations`
composite indexes (`firestore.indexes.json:561-626`) survive the rename.

**Client-side query engines:** event discovery fetches a capped window then
re-filters by activity, full availability semantics, and Haversine distance
(`event_discovery_repository.dart:149-318`); the Explore feed VM merges up to 6
sources and re-filters/re-sorts in memory
(`explore_feed_view_model.dart:463-631`); swipe candidates do 4 sequential
fetches + set-difference + per-profile fan-out
(`swipe_candidate_repository.dart:33-96`); clubs discovery `limit(30)` then
filters `isAppDiscoverable` client-side so a >30-club city can under-fill
(`clubs_repository.dart:69-101,220-221`).

**Duplicated infrastructure:** `EventDiscoveryRepository` vs
`ExternalEventRepository` are near-identical (query class + window fetch +
post-filter + `==` machinery); three hand-rolled chunked-multi-id realtime merge
implementations (`event_stream_utils.dart` ×2, `clubs_repository.dart:147-218`);
deterministic doc ids (`{uid_eventId}` etc., `docs/data_contracts.md:230-233`)
are used for writes but reads re-query by fields + `limit(1)` in the same class
(`saved_event_repository.dart:81-86` vs `:38-43`).

**Arbitrary realtime-vs-one-shot:** discovery is `get()` while nearly every
other list is `snapshots()`; payments and participations carry identical
`watch…`/`fetch…` twins. Error-handling outliers: raw stream in
`launch_access_repository.dart:37-45`; `city_repository.dart:27-57` swallows all
errors into 9 hardcoded defaults.

### 3.2 Work items

- **D1 — Pagination primitive.** One cursor-based page-state object +
  `startAfterDocument` helper + a provider pattern for page accumulation.
  First adopters: chat messages, matches, reviews, activity notifications (the
  four unbounded histories); then event discovery ("Anytime" scope) so Explore's
  feed stops being a fixed window.
- **D2 — Pull-to-refresh + freshness policy.** `RefreshIndicator` on Explore
  (and a documented rule for every feed surface) wired to provider invalidation;
  revalidate on tab re-entry; availability/attendance must never be older than
  one session. This is the user-visible deliverable of this workstream.
- **D3 — Limit policy.** One documented limit per surface class (feed / roster /
  lookup), constants centralized, and the two cliffs fixed
  (`payment_history_repository.dart:80`, `event_repository.dart:232`).
- **D4 — Index parity.** Add the missing `eventInviteLinks` and
  availability+geoCell composite indexes; add a `tool/` check that derives
  required indexes from repository query builders so drift fails CI, not
  production; prune or formally except the dead `runs*` indexes.
- **D5 — Converge duplicated infra.** Shared window-fetch for the two discovery
  repositories; all chunked watches onto `event_stream_utils.dart`;
  deterministic-id doc gets replace `where+limit(1)` edge reads.
- **D6 — Codify realtime vs one-shot** per surface class in
  `docs/data_contracts.md`; wrap the two error-handling outliers.

### 3.3 Acceptance criteria

- Every growing list query has a limit and a cursor path, or a documented
  exception in `docs/data_contracts.md`.
- Explore: pull-to-refresh works on feed + map pill counts; tab re-entry
  revalidates; "Anytime" paginates; count line is honest.
- The index check runs in CI (`tool/run.mjs check …`) and covers every
  repository query builder; the availability+distance path is covered by a
  repository test.
- `./tool/check_data_contract.sh`, focused repository tests, and
  `flutter analyze --no-fatal-infos` pass; run Flutter checks sequentially.

---

## 4. Visual correctness (pixel-peep)

Canonical values established from `lib/core/theme/`: radii `xs 4 / sm 8 / md 14 /
lg 20 / pill 999` (+ component radii incl. `clubPolaroidRadius 6`,
`clubPolaroidMediaRadius 3`); strokes `hairline 1.0 / underline 1.5 / focusRing
2.0 / selection 3.0`; spacing 4-pt scale with page gutter `s5=20`; motion
`fast 120 / micro 180 / standard 220 / slow 420ms`; type = Archivo @ wdth 78
(voice), platform system (function), IBM Plex Mono (data).

### 4.1 Token bypasses (fix list)

| File:line | Literal | Should be |
|---|---|---|
| `event_date_rail_card.dart:427` | border `strokeWidth = 1` | `CatchStroke.hairline` |
| `event_date_rail_card.dart:450` | `SizedBox(width: 1)` perforation lane | `CatchStroke.hairline` |
| `event_date_rail_card.dart:465-470` | perforation stroke `1.4`, dash geometry `0.5/2.2/7` | `CatchStroke.underline` (1.5) + named geometry consts |
| `catch_polaroid.dart:327` | grid painter `strokeWidth = 1` | `CatchStroke.hairline` |
| `catch_count_pill.dart:92` | `t.surface` @ alpha `0.94` | new `floatingPillFill` token (nearest roles are wrong-owner) |
| `catch_day_section_header.dart:111` | delegate `height = 44` | `CatchSpacing.s11` |
| `catch_chip.dart:160` | `_pressedScale = 0.97` | **DEFERRED to second pass (§0.1)** — file owned by the stretch thread; re-check before applying |
| `explore_filter_rail.dart:174` / `explore_city_picker.dart:208` | sheet maxHeight `0.56` / `0.68` of screen | one shared sheet-fraction token |
| `catch_cover_story.dart:274` | `BoxConstraints(maxWidth: 320)` | named cover-content clamp (existing 320 token is wrong role) |
| `catch_cover_story.dart:83-91,347` | gradient center/radius/stops, scrim stride `18.0` | named consts (glow alpha already tokened) |
| `catch_skeleton.dart:37-143` | fills always `editorialWhite` | verify dark-mode intent — shimmer blocks are pure white on dark |
| `explore_event_type_browse_grid.dart:384-390` | hardcoded English **semantic** labels | l10n (a11y-path localization bug) |

### 4.2 Tap handling & affordances

- `catch_cover_story.dart:200` — the location control is a raw
  `GestureDetector`: Tooltip + Semantics exist but **no ink/pressed feedback**
  and a ~15px-tall target. Route through a shared trigger primitive.
- `explore_city_picker.dart:106-138` — scopeLabel trigger is ~30px tall (< 44).
- Club cards (`explore_club_cards.dart`) — whole-card tap but **no composed
  semantic label**; contrast with `EventDateRailCard`'s exemplary label
  (`event_date_rail_card.dart:267-276`). The passive "View club" badge reads as
  a button but is not a target — affordance/semantics mismatch.
- `ExploreExternalEventRow` — no container-level semantics; screen readers get
  four disjoint nodes.
- Everything else (tab rail, chips, count pill, filter sheet, city option
  tiles) routes through shared primitives with proper feedback — `catch_chip.dart`
  is the reference implementation.

### 4.3 Display-size sprawl

`eventDisplay`/`clubDisplay` sizes across the surface: 22 (ticket title), 25
(external title), 27 (club row), 31 (rail day), 36 (cover title), 38 ("This
week" header) — all through the right API, all chosen per call site. Introduce a
named display-step scale (e.g. `displayS/M/L/XL`) so steps are ratified, not
improvised.

### 4.4 The capture library is multi-vintage (visual QA is currently invalid)

- `artifacts/ui-captures/full-catalog/member_event_discovery/light.png` and
  `club_detail_member/light.png` still render **serif-italic display type** and
  thick-bordered pre-hairline tickets — the identity retired by
  `docs/design_language.md` §5/§9. The dated set
  (`explore-cover-header-20260625/{light,dark}/…`) matches current code (Archivo,
  underline tabs, hairline strips). Anyone pixel-peeping against the
  full-catalog set is critiquing a ghost.
- `docs/design_language.md` §6 still specifies an "**italic serif** name" for
  the club polaroid while §5 says "Archivo is roman-only" and §9 retires serifs
  — the source-of-truth doc contradicts itself; fix the line to the ratified
  `clubDisplay` Archivo treatment.
- **Actions:** regenerate the full-catalog captures against current code,
  archive the stale set, keep the dated set as baseline, and add capture dates
  to `design/screens/catch.screens.json` entries so vintage is visible.

### 4.5 Dark cover legibility failure

`artifacts/ui-captures/explore-cover-header-20260625/dark/member_event_discovery.png`:
the white "EXPLORE · BANDRA" kicker and the Archivo title sit over a light
periwinkle activity glow and are partially illegible. The scrim
(`coverStoryScrim` alpha 0.035) is decorative, not a contrast floor.
**Fix:** a guaranteed-contrast treatment (minimum scrim behind the text block,
or derive glow lightness so paper text always clears WCAG AA at 36px), plus a
worst-case-backdrop capture state for both themes.

---

## 5. Widget reviews — event ticket & club polaroid

### 5.1 `EventDateRailCard` (condensed ticket) — strong bones, thin information

Strengths to keep: notch clipper + perforation + strip merging is genuinely
distinctive craft; the composed `Semantics` label is the best in the audit;
on-fill text colors, token discipline (§4.1's few literals notwithstanding),
Dynamic-Type stacking behavior.

**Information gaps** — the data model has all of this, the card shows none:

- **Cohort/gender balance** (`Event.genderCounts`, `effectiveCohortCounts`,
  `event.dart:96,149-162`) — the single most decision-relevant signal for this
  product; the design reference shows "BALANCED 5:5" but the card doesn't
  render it.
- **Waitlist count** (`Event.waitlistCount`) — "Full" never says "3 on
  waitlist", which is an invitation, not a dead end.
- **Time range** (`EventTileData.timeRangeLabel` exists, unused on the card),
  pace, capacity progress, host identity, and a **save/bookmark affordance**
  (the only save path is the top-bar saved-events action).
- **Who's going** — no avatar strip (the cheapest fix for §2.2).

**Inconsistency:** price renders through three divergent paths —
`EventTileData.priceLabel` (with "From " demand prefix,
`event_tile_data.dart:67-74`), `EventDateRailCard._priceLabel` (no prefix,
`event_date_rail_card.dart:565-570`), `ExploreEventItem.priceLabel` (viewer
quote, no prefix, `explore_feed_view_model.dart:167-175`). One formatter, one
copy rule.

**Beautification:** push the ticket-stub typography per `design_language.md` §6
(serial/time treatment on the rail side); when balance data exists, render it as
a mono data chip in the decision row rather than prose.

### 5.2 `CatchPolaroid` + explore club cards — charming, under-informative, one bug

Strengths: deterministic palette artwork (`ClubCoverVisualPalette.forSeed`),
graded covers, fully tokened radii (6/3), honest "no photo" treatment.

- **Bug:** `ExploreClubCover` resolves only `club.imageUrl`
  (`explore_club_cards.dart:145-165`), ignoring `Club.primaryClubPhotoUrl`
  (`club.dart:89-92`) — clubs whose photo lives in `clubPhotos`/
  `profileImageUrl` render fallback artwork. This suppresses real photography on
  the most editorial surface.
- **Info gaps:** `Club.rating` + `reviewCount` (`club.dart:38-39`) exist and
  drive ranking (`explore_screen_state.dart:724`) but are **never shown**;
  neither is host name, area (shown only when no next event), or distance. The
  "Rated 4.5+" filter implies ratings are visible somewhere — they are not.
- **Affordance:** passive "View club" badge looks tappable (see §4.2).
- **Radius mismatch:** the same cover renders at media-radius 3 in the polaroid
  and `md 14` in the compact row thumb (`explore_club_cards.dart:103`) — one
  metaphor, two geometries. Pick per tier and token it.
- **Beautification:** add a mono caption line pairing rating + review count
  ("4.9 · 61 REVIEWS") next to the member count; the polaroid's quiet frame can
  carry one more data line without noise.

### 5.3 `CatchCoverStory`

Composition and token discipline are good (all alphas tokened). Issues are the
CTA honesty and dark-legibility failures (§2.1, §4.5), the raw-GestureDetector
location control (§4.2), and the literal 320 clamp/gradient geometry (§4.1).

### 5.4 `ExploreExternalEventRow`

Correctly read-only with a labeled outbound CTA, but needs container-level
semantics (§4.2) and a policy decision: if external supply is filler rather than
monetized, mixing it at visual parity with bookable inventory leaks intent —
demote it.

---

## 6. Hand-rolled → primitive promotions

> **DEFERRED to the second pass in full — see §0.1.** Do not build any of
> these promotions (or the catalog stale-entry fixes below) in the first
> pass; reconcile this table against the stretch spec's §9.4.1 survey
> findings first.

The surface is mostly on-system. What is hand-rolled, and the proposed primitive
(each: widget-catalog entry + Widgetbook contract story in the same PR, per
`docs/design_language.md` §7.2):

| Proposed primitive | Configures | Adopting call sites |
|---|---|---|
| `CatchSurface.listCard` (named ctor) | md radius + line2 border + card elevation + content padding | `explore_event_rows.dart:75-79`, `explore_club_cards.dart:89-94` (verbatim duplicate shells) |
| `CatchIndexRow` | hairline-bottom row: leading dot/glyph, title, trailing mono count, min height, selected state | `ActivityTypeRow`, `MoreActivityTypesRow` (`explore_event_type_browse_grid.dart:204-328`) |
| `CatchMonoLabel` kicker variant | kicker vs monoCaps typography in one primitive | all `ExploreMonoLabel` call sites (8+; kill the duplicate at `explore_event_support_widgets.dart:4-19`) |
| `CatchClubCover` (shared resolver) | `Club.primaryClubPhotoUrl` resolution, grading, fallback artwork, compact flag | `explore_club_cards.dart:145-165`, club detail hero |
| `CatchTriggerPill` | icon+label bordered pill trigger with tooltip/semantics/ink | city picker icon mode (`explore_city_picker.dart:149-189`), cover-story location control |
| `CatchBottomSheetScaffold` adoption | sheet shell + header + list | city picker sheet (hand-rolled at `explore_city_picker.dart:210-273`) |
| `CatchDistanceFormatter` (l10n-aware util) | "m away"/"km away" copy | `explore_feed_view_model.dart:155-165,199-209` (verbatim duplicate) |
| `EventTicketStub` (decision row) | "time · capacity · status" + trailing price, stacking rules, demand-prefix rule | `event_date_rail_card.dart:168-216`, agenda tiles |
| `CatchCountCopy` | "N event(s)" pluralization via l10n | browse-grid counts + semantic labels |
| Named display-step scale | ratified display sizes | all `eventDisplay`/`clubDisplay` call sites (§4.3) |

Also fix the stale `docs/widget_catalog.md` entries found in the audit
(`:6998-6999` dead symbols `ExploreFilterGlyphButton`/`CatchSelectChip`,
`:7041-7047` pre-refactor paths, `:7071` and `:7183-7184` wrong paths).

---

## 7. Design-language assessment (subjective)

Verdict: **the language itself is coherent — this is not a multi-vibe mess.**
Paper+ink, hairlines, color-only-meaning-activity, and the Archivo/system/mono
trio are more disciplined than most shipping products, and the ticket/polaroid
metaphors give entities genuine material identity. The taste failures are
specific:

1. **Hierarchy inflation.** One screen carries four shout-scale moments: the
   dark cover story, the 38px Archivo "This week" header, the full-bleed
   polaroid, and the pigment browse grid. Editorial restraint — the language's
   own north star — budgets one hero per screen. The "This week" header is the
   worst offender because it duplicates the tab rail's job at 3× the type size
   of the content above it. Demote it to a kicker-led section or fold it into
   the day groups.
2. **Chroma stacking.** A viewport can hold 4–5 different activity pigments in
   the date-rail column plus club artwork plus the browse grid. "Color =
   activity" survives individually but approaches the candy line in aggregate.
   Keep pigment on rails/stamps/dots; keep it off large fills in browse
   surfaces (the stale browse-grid blobs were over it; verify the current
   hairline index rows stay quiet).
3. **The serif ghost.** Retired serif-italic still defines what "good" looks
   like in half the capture library and in `design_language.md` §6's own
   polaroid description (§4.4). A language is only locked when its artifacts
   agree — right now two identities coexist in the repo's evidence, and any
   reviewer can pick the wrong one.
4. **Separator spam.** "·" carries almost every meta line ("18 going · 6 left",
  "MON 6:30 AM", "MAP · 5"); the count pill even renders its "·" in `buttonSm`.
   Mono-for-data is right; the rule that needs writing is when a line earns a
   separator vs. a stacked second line.
5. **Editorial curation is absent where it matters most.** The feed will
   happily show three near-identical morning runs from one club and then sell
   the same club again in the polaroid (§2.7). An editorial product curates;
   this feed concatenates. This is a product-logic gap, but it reads as a taste
   gap.

Net: keep the language; the work is (a) one-hero-per-screen discipline, (b)
artifact hygiene so the standard is unambiguous, (c) curation logic worthy of
the frame.

---

## 8. Prioritized workstreams

| WS | Scope | Size | Depends on |
|---|---|---|---|
| **W1** | Data layer: D1–D6 (pagination primitive, pull-to-refresh, limit policy, index parity + CI check, infra convergence, realtime policy) | L | — |
| **W2** | Hero honesty: ranked hero, availability-aware CTA copy, hero stays in list | S–M | product sign-off (backlog item) |
| **W3** | People layer: decide cross-paths card; who's-going strip on ticket; rating/host on polaroid | M | W2, product sign-off |
| **W4** | Discovery UX: date strip, applied-filter chips, live sheet count, distance labeling, eligibility demotion + copy, no-clubs empty CTA | M | W1 (count honesty) |
| **W5** | Craft fixes: §4.1 token table, tap targets, semantic labels, dark-cover contrast floor, `ExploreClubCover` photo bug, price-path unification, l10n sweep | S | — |
| **W6** | Primitive promotions (§6) + widget-catalog refresh + display-step scale | M | W5 + **§0.1 second-pass entry condition (stretch §9.4.1 exists)** |
| **W7** | Visual QA hygiene: regenerate captures, archive stale set, fix `design_language.md` §6, capture vintages in screens registry | S | — |

Suggested order: W1 + W5 first (correctness and trust; W5 minus the deferred
chip row per §0.1), W7 immediately after (so all future pixel work has a valid
baseline), then W2 → W4 → W3. **W6 is the second pass** (§0.1) — it runs only
after the stretch thread's §9.4.1 survey lands, as the enforcement layer that
keeps it all ratcheted.

---

## 9. Resolved implementation defaults

1. Booking intent is the implementation metric: eligible/open supply and
   attendance strength drive the cover score.
2. External-platform events remain explicit read-only supply; no Catch booking
   affordance is implied.
3. Freshness and privacy-safe social proof both ship; neither requires exposing
   attendee identities.
4. Ranking reorders only the cover selection. The body remains chronological.
5. Map distance and filter-sheet distance share one filter state.

---

## 10. Evidence index

- UX: `lib/explore/presentation/explore_screen.dart:46-560`,
  `explore_screen_state.dart:38,52,168-184,305-340,360-382,624-635,996-1053,1152-1188`,
  `explore_feed_view_model.dart:44,111-123,155-262,308,463-631,773-824`,
  `explore_view_model.dart:45-137,243-384`, `explore_filter_rail.dart`,
  `explore_search_repository.dart:75`.
- Data: `lib/events/data/event_discovery_repository.dart:46,147-318`,
  `external_event_repository.dart:29,106`, `event_repository.dart:111-246`,
  `chat_repository.dart:50-52`, `match_repository.dart:92-107`,
  `clubs_repository.dart:31,69-221`, `swipe_repository.dart:36`,
  `payment_history_repository.dart:80`, `firestore.indexes.json:561-626`,
  `docs/data_contracts.md:224-243,378-405`, `docs/action_cardinality_policy.md:80-81`.
- Craft: `lib/events/shared/event_tiles/event_date_rail_card.dart:168-276,410-470,559-570`,
  `lib/clubs/shared/catch_polaroid.dart:76-91,187-207,327`,
  `lib/explore/presentation/widgets/explore_club_cards.dart:42-165`,
  `catch_cover_story.dart:83-91,200,274,284-347`, `catch_count_pill.dart:74-97`,
  `catch_day_section_header.dart:111`, `catch_chip.dart:160`,
  `catch_skeleton.dart:37-143`, `explore_city_picker.dart:106-330`,
  `explore_event_type_browse_grid.dart:204-390`.
- Captures: `design/reference_screens/screen.explore.discovery/discovery_feed.png`
  (design baseline); `artifacts/ui-captures/explore-cover-header-20260625/
  {light,dark}/member_event_discovery.png` (current); `artifacts/ui-captures/
  full-catalog/{member_event_discovery,club_detail_member}/light.png` (**stale —
  retired identity, do not use as baseline**).
