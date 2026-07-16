# Host Club Insights Tab Audit & Restructure Spec (for Codex)

Status: ready for implementation · 2026-07-17
Scope: `lib/hosts/presentation/host_operations/` (analytics + insights files), `lib/hosts/data/host_analytics_repository.dart`, `lib/core/widgets/catch_analytics_kit.dart`, `lib/l10n/`, `lib/routing/`, `functions/src/analytics/`, `contracts/`, `design/screens/`, `widgetbook/`, `test/`
Companion: [`host_club_edit_and_live_guide_spec.md`](host_club_edit_and_live_guide_spec.md)
(the "edit spec") — its Phase 0 §4.1 width-constraint item covers the
Insights pane too; do not duplicate that work here.
Origin: 2026-07-17 owner + Claude audit of the organizer screen's Insights
tab. Every finding was verified against the repo; evidence cited inline.

Items marked `⚠ OWNER` need explicit go-ahead. Everything else is ratified.

---

## 0. Background — what the surface is

The organizer workspace (`HostClubsScaffold`) Insights tab renders
[`HostClubInsightsPane`](../../lib/hosts/presentation/host_operations/host_analytics.dart)
(1,083-line part file). Data path:

- `HostClubInsightsState` (range preset, granularity, custom dates, optional
  event scope) → `HostAnalyticsQuery` → `hostAnalyticsProvider` →
  `getHostAnalytics` callable
  ([`functions/src/analytics/hostAnalytics.ts`](../../functions/src/analytics/hostAnalytics.ts),
  1,113 lines) → Firestore authorization scope (≤25 clubs × ≤500 events) +
  BigQuery host-analytics mart rows → aggregated
  `HostAnalyticsCallableResponse`.
- The response carries 10 summary cards (labels/captions baked server-side in
  English), a 14-metric trend (UI renders 2), 25 most-recent event rows (UI
  renders 5), review + discovery summaries, and an ops "data quality" block.
- The pane renders: all-time overview grid (`HostClubOrganizerOverviewController`)
  → range/granularity chip rows → metric card grid → hand-rolled dual-bar
  trend → "Top events" tile list (tap re-scopes the whole report to that
  event) → "Reviews and saves" 2×2 → "Data quality" list.
- A **dedicated** variant exists (`HostInsightsScreen`,
  route `/host/organizer/:clubId/insights`, `dedicated: true` flag switching
  to a pill+bottom-sheet range picker) — but nothing in the app navigates to
  it.
- A **separate per-event analytics surface already exists**: the Manage →
  Report tab (`event_success_host_report.dart`), fed by the event-success
  scorecard pipeline, richer than anything the insights event-scope mode
  shows.

## 1. Product frame (owner-ratified)

The current tab is a BI dashboard shrunk onto a phone: five range presets +
custom date pickers, a three-way granularity toggle, ten metric cards, an
unlabelled two-series chart, eleven badges per event tile, and an
infrastructure health panel. This contradicts the product's own stated
philosophy — the host-recap module copy in the event-success catalog says
*"Show a short post-event brief. Recommend one or two changes, not a
dashboard wall."*

Hosts (India-first, mostly non-professional, running weekly-ish events) come
to Insights with three questions:

1. **Momentum** — "Is my club growing?" (members, demand, repeat attendance,
   trend direction)
2. **Last event** — "How did it go?" (already answered better by the
   per-event Report tab)
3. **Next action** — "What should I change?" (nothing on the screen answers
   this today)

A number without a comparator is noise: no card has a vs-previous-period
delta, a target, or a benchmark. The redesign target is a **narrative
scorecard**: all-time identity strip → range-scoped performance summary with
deltas → honest trend → recent events that LINK to their reports → reviews →
(later) one or two coach recommendations. BI-style slicing (custom dates,
manual granularity, event-scoped re-querying) is removed from the host app;
the admin surface (`adminGetHostAnalytics`, same builder) keeps full
flexibility.

## 2. Findings register (verified 2026-07-17)

Correctness / hazard:

| # | Finding | Evidence |
|---|---------|----------|
| T1 | **Wire keys stored in ARB as visible copy and used as data-map lookups.** `hostsHostAnalyticsVisiblecopyBookings = 'bookings'`, `…Demand = 'demand'`; the trend panel reads `point.metrics[context.l10n.…]`. Works only while the en value equals the backend key — any translation or copy-edit silently zeroes the chart | `app_en.arb`; `host_analytics.dart` ~lines 519–533, 614–622; backend keys in `hostAnalytics.ts` `trendBuckets()` |
| T2 | **Route parameter names/values from l10n.** `pathParameters: {context.l10n.hostsHostInsightsScreenBodyClubid: club.id, …}`, `queryParameters: {…BodySection: …BodyReport}` — navigation breaks if these ARB entries are ever localized | `host_insights_screen.dart` ~lines 83–92 |
| T3 | **Dead dedicated surface.** Route `/host/organizer/:clubId/insights` is registered but nothing pushes `Routes.hostInsightsScreen`; the `dedicated` flag, `HostAnalyticsRangeChip`, `HostAnalyticsRangeSheet`, `HostInsightsScaffold/Header/UnavailableScreen` are unreachable UI carrying a parallel presentation of the same state | `rg hostInsightsScreen lib` → only route registration; `host_analytics.dart` `dedicated` branches |
| T4 | **Backend-baked English display copy.** Card labels ("Listing views"…), captions ("From BigQuery host analytics events and marts."), and data-quality `detail` strings are composed server-side, bypassing l10n entirely | `hostAnalytics.ts` summaryCards ~lines 276–342, `dataQualityRows()` ~lines 780–845 |
| T5 | **Internal ops panel rendered to hosts.** "Data quality" rows carry `owner: "Analytics ops"`, `runbook: docs/…`, `nextAction: "Check GA4/direct event export freshness…"` — BigQuery/GA4/mart/Firestore vocabulary on a host-facing screen | `hostAnalytics.ts` `dataQualityRows()`; rendered via `CatchAnalyticsDataQualityList` in `host_analytics.dart` ~line 487 |
| T6 | **UTC bucketing for an IST market.** Backend buckets days/months in UTC (`timezone: "UTC"`), so a host's "today"/"this month" boundaries are off by 5:30; client date pickers convert local dates to `yyyy-MM-dd` interpreted as UTC | `hostAnalytics.ts` `resolveAnalyticsRange()` (all `Utc` helpers) |
| T7 | **Revenue card formatted without a currency code** (`EventFormatters.priceInPaise(metric.value.round())` — INR assumed) while event rows carry per-event `currency`; server also sums `grossRevenueMinor` across events without a mixed-currency guard | `host_analytics.dart` `_formatMetricValue` ~line 1047; `hostAnalytics.ts` totals |

Cost / performance:

| # | Finding | Evidence |
|---|---------|----------|
| T8 | **No caching anywhere.** Client provider is codegen default autoDispose with no keepAlive — every tab visit, range tap, granularity tap, or event-scope tap discards and refetches. Server has no snapshot/TTL cache (`rg cache|snapshot|ttl hostAnalyticsBigQuery.ts` → none): each call = Firestore scope reads (≤25 clubs × ≤500 events) + a live BigQuery job. Rate limit 30/min/user is the only guard. UX = full skeleton on every toggle | `host_analytics_repository.dart` ~line 382; `rateLimit.ts` ~line 125 |
| T9 | `generatedAt` is parsed but never shown; no pull-to-refresh on the tab | `host_analytics.dart` (no usage) |

Presentation / design-system:

| # | Finding | Evidence |
|---|---------|----------|
| T10 | **Chart is unreadable as a chart**: hand-rolled dual bars (full-width demand behind, half-width bookings in front) with no legend mapping bar style → series, no time labels under bars, no values, fixed height from a *spacing* token (`CatchSpacing.s16`), horizontal scroll with `reverse:` | `host_analytics.dart` `HostAnalyticsTrendPanel` ~lines 563–693 |
| T11 | **Event tile = up to 11 badges + revenue** (demand, booked, waitlisted, attended, matches, chats, repeat, checkouts, drop-off, failed, refunded) with no hierarchy — the literal "dashboard wall" | `HostAnalyticsEventTile` ~lines 816–908 |
| T12 | **"Top events" is a lie**: backend sorts by `startTime` desc and slices 25 (recency, not performance); UI takes 5; no path to the rest | `hostAnalytics.ts` `topEvents` sort ~line 253; `events.take(5)` |
| T13 | **Tap-to-scope conflates filter and navigation**: embedded mode re-scopes the entire report to one event (summary cards, trend, reviews all silently become event-scoped); dedicated mode instead navigates to Manage → Report. Identical tile, two behaviors; the per-event Report tab already answers the event question better | `host_analytics.dart` ~lines 83, 131; `host_insights_screen.dart` ~line 83 |
| T14 | **Mixed time semantics unlabelled**: top overview grid (members/rating/events/upcoming) is all-time; everything below is range-scoped; rating/reviews appear three times (overview, summary card, reviews panel) | `host_organizer.dart`; `host_analytics.dart` |
| T15 | **Duplicated / conditional control UIs**: range + granularity chips outside the report in embedded mode, granularity again inside the trend panel in dedicated mode; `HostAnalyticsRangeSheet` duplicates the same enum a third time with near-duplicate ARB keys (`LabelMonth` vs `LabelMonth5406de`, `LabelCustom` vs `LabelCustoma46c31`) | `host_analytics.dart` ~lines 52–67, 200–248, 365–391, 542–561 |
| T16 | Parsed-but-never-rendered fields: `fillRate`, `checkInRate`, `inviteOpenCount`, `paymentCompletedCount`, per-event `reviewCount`/`averageRating` | `host_analytics_repository.dart` vs tile usage |
| T17 | DS hygiene: `CatchMetricCardData` ships hardcoded `'Partial'`/`'Missing'` badge defaults and the host call site doesn't localize them; metric icons switch on magic string ids in the UI; `_formatCount` duplicates `_compactCount` (`host_organizer.dart`); `_formatAnalyticsDate` hand-rolls `dd/MM/yyyy`; event status labels title-case raw backend strings with tone mapping by string matching | `catch_analytics_kit.dart` ~lines 19–20; `host_analytics.dart` ~lines 929–933, 1004–1016, 1056–1074 |
| T18 | No Widgetbook coverage for any analytics widget (hosts stories = inbox + operations only) | `widgetbook/lib/hosts/` |

## 3. Goals and non-goals

Goals:

1. Remove the translation-fragile identifier-in-ARB hazards (T1, T2) and the
   other correctness items (T6, T7).
2. One insights surface: delete the dead dedicated screen; the tab is the
   surface; event rows navigate to the existing per-event Report.
3. Client-owned copy: the host app stops rendering server-composed English;
   backend keeps sending it for the admin surface.
4. Replace the BI dashboard with the narrative scorecard (§1): fewer
   controls, labelled time scopes, an honest chart, actionable blocks.
5. Stop hammering BigQuery: client-side caching + refresh affordance now;
   optional server snapshot cache later.
6. Deltas (vs previous period) and club-timezone bucketing via additive
   contract changes.

Non-goals:

- No change to the admin analytics dashboard or `adminGetHostAnalytics`
  semantics; server keeps `label`/`caption`/`dataQuality` fields.
- No change to the per-event Report tab or the event-success scorecard
  pipeline.
- No new charting library; the chart stays hand-composed from DS primitives,
  just honest (legend, labels).
- No benchmarks/goals/coach ML — Phase 4 is a small rules table, gated.
- No BigQuery schema/mart changes.

## 4. Cross-cutting rules

Rules 1–8 of the edit spec §3 apply verbatim (branch discipline, copy
pipeline, PATH export, verification gates, registries, Widgetbook). In
addition:

1. Contract changes (Phase 3) go through the `contracts/` schema pipeline:
   edit the JSON schema for `hostAnalyticsQueryCallablePayload` /
   `hostAnalyticsCallableResponse`, regenerate (Dart
   `lib/core/schema_contracts/generated/` + TS
   `functions/src/shared/generated/`), keep changes ADDITIVE (new optional
   fields only), and run `./tool/check_data_contract.sh` +
   `npm --prefix functions test`.
2. Backend edits require the functions test suite for
   `hostAnalytics` (`functions/src/analytics/*.test.ts` or the harness —
   locate existing tests with `rg -l hostAnalytics functions` and extend
   them; do not leave new behavior untested).
3. Never key runtime lookups (map keys, route params, query params, wire
   enums) on `context.l10n` output. When this pass removes such a key from
   ARB, delete the ARB entry and let the copy checks confirm no dangling
   getter.

## 5. Phase 0 — Correctness and dead-code removal (mechanical)

### 5.1 Trend wire keys (T1)

- Add to `host_analytics_repository.dart`:

  ```dart
  /// Wire keys for HostAnalyticsTrendPoint.metrics, as emitted by
  /// functions/src/analytics/hostAnalytics.ts trendBuckets().
  abstract final class HostAnalyticsTrendKeys {
    static const bookings = 'bookings';
    static const demand = 'demand';
    static const checkedIn = 'checkedIn';
    static const revenueMinor = 'revenueMinor';
    // add the remaining bucket keys verbatim from trendBuckets()
  }
  ```

- Replace every `context.l10n.hostsHostAnalyticsVisiblecopyBookings` /
  `…Demand` lookup with the constants. Delete both ARB entries (all
  locales). Add a unit test pinning the constants against a fixture callable
  response (so a backend key rename fails a Dart test, not production).

### 5.2 Route params from l10n (T2)

In `host_insights_screen.dart` (or its successor after §5.4): replace the
four l10n-driven keys/values with literals `'clubId'`, `'eventId'`,
`'section'`, `'report'` (match the parameter names declared on
`Routes.hostAppEventManageScreen` in `go_router.dart` — verify before
hardcoding). Delete the four ARB entries.

### 5.3 Copy-sweep guardrail (recommended, small)

T1/T2 are one bug class: the copy migration swept identifier-shaped literals
into ARB as "visible copy". Add a heuristic to the mobile copy check
(`tool/copy/check_mobile_copy_catalog.mjs` or a sibling check wired into the
manifest): flag ARB entries whose key contains `Visiblecopy` and whose value
matches `^[a-z][a-zA-Z0-9_]*$` (identifier-shaped, no spaces). Seed the
allowlist with any legitimate hits. Add a manifest entry per `tool/README.md`
conventions and `node tool/run.mjs check --manifest-only`.

### 5.4 Delete the dead dedicated surface (T3)

- Remove `HostInsightsScreen`, `HostInsightsScaffold`, `HostInsightsHeader`,
  `HostInsightsUnavailableScreen` (`host_insights_screen.dart`), the
  `dedicated` flag and both its branches in `HostClubInsightsPane`,
  `HostAnalyticsRangeChip`, `HostAnalyticsRangeSheet`, and
  `_showRangePicker`.
- Remove route `Routes.hostInsightsScreen`; add a redirect from
  `/host/organizer/:clubId/insights` →
  `/host/clubs?clubId=:clubId&tab=insights` (precedent:
  `hostClubsLegacyRedirect` in `go_router.dart`). The organizer route
  already accepts `clubId` + `tab` query params.
- Event-report navigation moves into the pane: `HostClubInsightsPane` gains
  a default `onOpenEventReport` that pushes
  `Routes.hostAppEventManageScreen` (section=report) — see Phase 2 §7.4.
- Delete orphaned ARB keys (the copy checks will list them; also the
  near-duplicate range labels `LabelMonth5406de` / `LabelCustoma46c31` once
  the sheet dies).
- Update `design/screens/catch.screens.json` +
  `docs/design_parity/state_matrix.json` if the dedicated screen has entries.

### 5.5 Small correctness fixes

- Revenue formatting (T7): thread the club's currency into
  `HostAnalyticsReportView` (`currencyCodeForCityName(club.location)` — the
  pattern the edit tab already uses) and pass it to
  `EventFormatters.priceInPaise`.
- Date formatting (T17): replace `_formatAnalyticsDate` with the
  locale-aware formatter used elsewhere (`EventFormatters.shortDate` or the
  intl-based equivalent).
- Dedupe `_formatCount` with `_compactCount` (`host_organizer.dart`) into one
  shared helper next to the pane.
- Localize the metric-status badges: pass
  `partialBadgeLabel`/`missingBadgeLabel` from l10n at the call site
  (`_hostMetricCardData`); keep the DS defaults as fallbacks.

### 5.6 Acceptance

`flutter analyze`; `flutter test test/hosts`; copy checks green with the
deleted keys; router test (or manual deep link) proving the legacy insights
URL redirects into the organizer tab; new trend-key pin test passing.

## 6. Phase 1 — Copy ownership flip (client-owned labels)

The host client stops rendering server-composed strings (T4, T5). No
contract change — the fields keep flowing for admin.

- **Metric cards**: label/caption come from a client-side map keyed on the
  card `id` (ids are already the UI's icon-switch keys: `listingViews`,
  `eventViews`, `bookings`, `attendanceRate`, `revenue`, `checkoutDropoff`,
  `checkoutConversionRate`, `newReviews`, `connections`, `chats`). Add l10n
  entries per id; unknown ids fall back to the server label (forward
  compat). Delete the caption text entirely — "From BigQuery host analytics
  events and marts." must never render for hosts.
- **Data quality panel → sync footnote** (T5): remove
  `HostAnalyticsReviewDiscoveryPanel`'s sibling "Data quality" section and
  `CatchAnalyticsDataQualityList` usage from this screen. Replace with one
  supporting-text line under the report, shown only when any
  `dataQuality.state != ok` OR any card status != ready:
  "Some data is still syncing — numbers may update." (new l10n key). The
  detailed rows remain available to the admin surface.
- **Freshness** (T9): render `generatedAt` as "Updated {relative time}"
  supporting text at the top of the report (reuse the app's relative-time
  formatter if one exists; else short date+time).
- Card statuses (`partial`/`missing`) keep their tile badges — that part is
  honest and useful.
- Event status labels (T17): map the known backend statuses to l10n labels
  (`live/active/open/published/completed/past/draft/pending/scheduled/cancelled`),
  falling back to the current title-casing for unknown values.

Acceptance: no server-composed sentence renders on the tab (assert in widget
tests with a fixture report whose labels/captions/details are sentinel
strings like `"SERVER_LABEL"` — they must not appear).

## 7. Phase 2 — The narrative scorecard (presentation restructure)

Target layout for `HostClubInsightsPane`, top to bottom. Reuse
`CatchSection.divided` stacking; all new copy via l10n.

### 7.1 Header block

1. "Updated {relative}" + sync footnote (from Phase 1).
2. **All-time strip** — keep `HostOrganizerMetricGrid` (members · rating ·
   events hosted · upcoming) but give the section an explicit scope label
   (section `count:` or kicker) "All time" (T14). Drop the duplicate rating
   card from the range-scoped grid below.

### 7.2 Range control (T15)

One segmented control, three presets, no custom dates, no manual
granularity:

| Preset | Wire | Buckets |
|---|---|---|
| "30 days" | `30d` | week |
| "90 days" | `90d` | week |
| "12 months" | `custom` (rolling 365d) until Phase 3 adds a `12m` preset; compute start date client-side | month |

Granularity is derived from the preset (client sends it explicitly — the
payload already supports it). Delete `HostClubInsightsGranularity` from UI
state, the granularity chip row, custom date state/pickers, and
`HostAnalyticsDateButton`. `HostClubInsightsState` shrinks to
`clubId` + `rangePreset` (+ nothing else after §7.4 removes event scope).

### 7.3 Summary cards with hierarchy

Primary grid (6 cards): Views (listingViews + eventViews summed client-side,
label "Profile & event views"), Bookings, Attendance rate, Revenue,
Connections, New reviews.

Secondary metrics (Checkout drop-off, Checkout conversion, Chats started,
Event saves) move behind a "More metrics" disclosure
(`CatchField.expanding` row beneath the grid revealing a second
`CatchAnalyticsMetricGrid`). Once Phase 3 lands, each card shows a delta
caption vs the previous period ("↑ 12% vs previous 30 days"); until then no
caption.

### 7.4 Recent events (T11, T12, T13)

- Section title: "Recent events" (rename; it never was "top").
- Tile becomes one compact row: title (1 line) · date · meta line
  "{booked} booked · {checkedIn} attended · {matches} matches" · trailing
  revenue. ONE optional warning badge when `paymentFailedCount > 0` or
  `checkoutDropoffCount > 0` ("Payment issues") — everything else lives in
  the per-event report. Delete the 11-badge wrap.
- **Tap navigates** to `Routes.hostAppEventManageScreen`
  (`section=report`) — always. Delete event-scoping: `selectedEventId` from
  state, `selectEvent`/`clearEvent`, the "Event scoped" banner, the
  "Selected event"/"All events" section variants. The callable's `eventId`
  parameter stays (admin uses it).
- Footer nav row "All events" → the host Events workspace tab (reuse the
  navigation the Today dashboard uses to reach it; verify route before
  wiring).

### 7.5 Trend chart, honest version (T10)

Keep the DS-composed dual-bar approach; make it legible:

- Legend row above the bars: two swatches (the exact fill styles of the
  bars) labelled "Demand" and "Bookings" (l10n).
- Per-bucket labels beneath the bars: week buckets → start-date short label
  on every other bucket minimum; month buckets → month abbreviations on all.
- Tap a bar pair → a detail line under the chart: "{period}: {demand}
  demand · {bookings} bookings" (replaces tooltips; no overlay needed).
- Chart height gets its own constant (a `CatchLayout` addition, e.g.
  `analyticsTrendHeight`), not a spacing token (T10). Follow the edit spec's
  §3 rule set for token changes (`lib/core/theme` is exempt from the raw-value
  lints).
- Empty range → keep the existing empty-surface copy.

### 7.6 Reviews block

Keep the 2×2 (New reviews · Average rating · Event saves · Responses) but
retitle "Reviews" and move Event saves into "More metrics" (§7.3), replacing
it with Published reviews (already parsed). No CTA in this phase — there is
no host-facing review-inbox surface today; note it as follow-up product work
in the PR description, do not invent one.

### 7.7 Caching + refresh (T8 client half)

- `hostAnalytics` provider: `ref.keepAlive()` with a timed expiry (e.g.
  restartable 10-minute timer via `ref.onCancel`/`Timer` — follow an
  existing keepAlive pattern in the repo if one exists; otherwise simplest
  correct version: keepAlive + `ref.invalidateSelf()` after 10 min).
- Pull-to-refresh on the tab's scroll view (`RefreshIndicator.adaptive`
  around the tabbed page scroll view for this tab, or the repo's existing
  refresh pattern) → `ref.invalidate(hostAnalyticsProvider(query))`.
- Switching presets hits at most 3 cached queries; returning to the tab
  within the TTL renders instantly.

### 7.8 Acceptance

- Widget tests with fixture reports: section order; 6+disclosure card split;
  event row navigation intent (mock router) instead of state re-scoping;
  legend + bucket labels present; warning badge logic; empty states.
- Update `design/screens/catch.screens.json` + state matrix for the new tab
  states; add Widgetbook stories (`widgetbook/lib/hosts/` —
  insights pane loaded/empty/partial-data cases) (T18).
- `flutter analyze`; `flutter test test/hosts`; design checks per edit spec
  §11.

## 8. Phase 3 — Backend: deltas, timezone, snapshot cache

All contract changes ADDITIVE (new optional fields); regenerate both
codegen targets; `./tool/check_data_contract.sh` + functions tests.

### 8.1 Comparison window (deltas)

- Payload: no change. Response: each summary card gains optional
  `previousValue?: number` (same unit), computed over the immediately
  preceding window of equal length (for `12m`/`month`, the previous
  365d/month). Backend computes by querying the mart for the doubled range
  and splitting rows — one BigQuery query, not two.
- Client: `HostAnalyticsMetricCard.previousValue`; delta caption per §7.3
  (percent change; render nothing when previous is 0/absent).

### 8.2 Club-timezone bucketing (T6)

- Payload gains optional `timezone?: string` (IANA). Backend resolves
  bucket boundaries and presets ("30 days ago", month starts) in that zone,
  defaulting to UTC when absent (existing behavior preserved for admin).
  Response `timezone` echoes the resolved zone.
- Client sends the device timezone name. Add functions tests around IST
  midnight boundaries (a booking at 01:00 IST lands in the IST day, not the
  previous UTC day).
- Add a `12m` range preset to the payload enum while the schema is open,
  and move the client off the custom-range workaround from §7.2.

### 8.3 Server snapshot cache (recommended; ⚠ OWNER for the TTL/cost call)

Cache the built response in Firestore
(`hostAnalyticsSnapshots/{uid}_{scopeHash}`) with a 15-minute TTL; serve the
snapshot when fresh, else rebuild and overwrite. The data-quality copy
already anticipated "optional snapshots". Keep the rate limit. Skip if the
owner prefers client-only caching for now — Phase 2 §7.7 alone removes most
redundant load.

## 9. Phase 4 — Coach recommendations (⚠ OWNER gated)

Do not build without explicit go-ahead on rules and copy. Direction: a
"Coach" block above Recent events showing at most TWO suggestion rows,
computed client-side from the report (no backend change), each with a plain
sentence and a deep link. Starting rules table for the owner to edit:

| Signal (report fields) | Suggestion | Link |
|---|---|---|
| attendanceRate < 60% over range with ≥2 events | "Almost half your bookings didn't show. Reminders and check-in help — see how your last event ran." | last event's Report |
| checkoutDropoff ≥ 30% of checkoutStarted | "Lots of people started paying and stopped. Review your price or enable demand pricing." | event defaults spoke (edit spec §7.1) |
| demand ≥ 2× bookings on any event | "Demand outran capacity on {event}. Consider a bigger venue or a second date." | that event |
| repeatAttendeeCount == 0 across range with ≥3 events | "No repeat attendees this period. Club posts and follows help people come back." | (none yet) |

Copy through l10n; thresholds as consts beside the rules; unit-test each
rule on fixture reports; the block renders nothing when no rule fires (most
of the time — that is correct behavior, not a bug).

## 10. Sequencing

```
Phase 0 → Phase 1 → Phase 2 → Phase 3 (8.1/8.2 parallel-safe; 8.3 last)
                                   Phase 4 ⚠ gated, any time after 2
```

Phase 0 is safe to land immediately and independently (pure correctness +
dead code). Phases 1–2 are client-only. Nothing here conflicts with the edit
spec except both touch `host_operations_screen.dart` parts — coordinate
branches if run concurrently; prefer landing the edit spec's Phase 0 width
constraint first.

## 11. Verification gates

Edit spec §11 gates apply (analyze, hosts/event_success tests, design
checks, copy checks, readiness, passes stamp), plus:

```sh
npm --prefix functions test                 # Phases 3 (and 0 if TS touched)
./tool/check_data_contract.sh               # Phase 3
node tool/run.mjs check --manifest-only     # Phase 0 §5.3 guardrail entry
```

## 12. Confirmed healthy — do NOT "fix"

- The BigQuery mart pipeline itself and `hostAnalyticsBigQuery.ts` — the
  warehouse is real and correct-by-audit (2026-06 architecture audit);
  this spec changes presentation and the callable's shaping, not the marts.
- Auth/scoping in the callable (host club authorization, admin role +
  audit log, rate limiting, Ajv payload/response validation) — solid; keep.
- The per-event Manage → Report tab and the event-success scorecard
  pipeline — the event-level story lives there by design.
- `CatchAsyncValueView` + skeleton + `CatchErrorState.fromError` loading
  discipline on the pane.
- The metric-status (`ready/partial/missing`) concept and tile badges —
  honest data honesty; only the ops-detail PANEL leaves the host surface.
- The repository's defensive parsing helpers (`_numberMap`, `_mapList`,
  fallbacks) — keep the tolerant reads.
- `adminGetHostAnalytics` and everything the admin dashboard consumes,
  including `label`/`caption`/`dataQuality` fields on the wire.
