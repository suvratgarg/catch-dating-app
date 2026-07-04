---
doc_id: composition_audit
version: 0.1.0
updated: 2026-07-05
owner: design_parity_review
status: active
---

# Screen Composition Audit

Purpose: walk the app one detailed screen at a time and judge whether its
widget composition is intelligent — no redundant wrappers, no layers that
distort the primitives underneath, no parallel shells inflating the widget
count. This is the review-session companion to the consolidation pipeline:
similarity detection finds twins; this audit finds **bad vertical chains**
inside a single screen.

## Method

For each screen: map route → screen states → composition tree down to core
primitives, then give every named layer one verdict:

| Verdict | Meaning | Action |
|---|---|---|
| OWNS | Real content/logic lives here | keep |
| ADAPTS | Provider wiring / state dispatch (the app's controller pattern) | keep |
| CONFIGURES | Passes meaningful, non-default configuration downward | keep |
| PASS-THROUGH | Re-exposes a primitive adding nothing (incl. subclass-as-config) | delete, inline at call sites |
| DISTORTS | Overrides/duplicates the primitive's contract (paddings, titles, chrome) | fix at the seam or the primitive |
| NEUTRALIZES | The *primitive's defaults* fight its context, so every call site zeroes them | fix the primitive's contract |

Findings are written per screen below. Items tagged `[codex]` are fully
specified and mechanical; items tagged `[confirm]` change something visible
and want a one-line owner sign-off before execution. Codex flips each item
to `[done <commit>]` as it lands, following the standard workflow
(AGENTS.md, focused tests, analyzer, relevant scanners, widget_catalog +
passes.jsonl when contracts change, widgetbook kept current, sequential
Flutter runs).

Screen queue (working order): Dashboard ✅ → Explore → Event Detail →
Catches/Swipe Hub → Chats/Inbox → Profile → Club Detail → Host Operations.

---

## Screen 1 — Dashboard (audited 2026-07-05)

Files: `lib/dashboard/presentation/dashboard_screen.dart` (+ 4 part files),
`lib/dashboard/presentation/widgets/*`.

Overall: the state dispatch (`DashboardScreen` → loading/error/empty/full)
and the empty state are composed well. The full state carries one dead
parallel shell, one inheritance wrapper, one loading-language inconsistency,
and a systemic rail-defaults problem that extends beyond this screen.

### D1. `DashboardFull` is a dead parallel screen shell — delete `[codex]`

`widgets/dashboard_full.dart` defines `DashboardFull`, which rebuilds the
entire screen shell (Scaffold + SafeArea + CustomScrollView + sliver header
+ `DashboardFullSliverBody`) and re-derives the header and view model from
providers. Its only constructor call site is
`widgetbook/lib/dashboard/dashboard_use_cases.dart:638` — the real app path
is `DashboardScreen → DashboardHomeScreen`. It has already drifted: it lacks
the `Semantics(label: 'Home')` wrapper and the notifications action that
`DashboardHomeScreen` has.

Fix: delete `DashboardFull` (keep `DashboardFullSliverBody`, which is the
real body). Repoint the widgetbook use case to compose `DashboardHomeScreen`
with a fixture header/model (widgetbook must exercise the real shell, not a
parallel one). Its `greeting`/`dayCity` statics are thin forwards to
`dashboardGreeting`/`dashboardDayCity` — repoint any callers to those
functions directly.

### D2. `DashboardSliverHeader` is subclass-as-configuration — inline `[codex]`

`widgets/dashboard_sliver_header.dart`: the class only pre-fills
`CatchSliverHeader(title: DashboardHeaderContent(...))` via `super`. That is
a PASS-THROUGH by inheritance. Fix: delete the subclass; at both call sites
(`DashboardHomeScreen`, and `DashboardFull` until D1 removes it) construct
`CatchSliverHeader(title: DashboardHeaderContent(eyebrow:, title:, actions:))
.buildSlivers(context)` directly. `DashboardHeaderContent` stays (OWNS the
dashboard title-block chrome; the K5 keep vs Explore's header stands).

### D3. Section-loading language is inconsistent — standardize on skeletons `[confirm]`

The same dashboard sections have two loading treatments:

- Loading screen (`dashboard_screen.dart` parts): skeleton mimics
  (`DashboardFocusLoadingCard`, `DashboardStrideLoadingCard`,
  `DashboardRecommendedLoadingSection`). On-language.
- In-body refresh states: `DashboardSectionStateCard(message: 'Loading
  recommended events...', isLoading: true)` (dashboard_full.dart:345) and
  the stride equivalent (stride_card.dart:54) — a text row card, off-language
  (nothing else in the app announces loading with copy).

Fix (pending confirm): in-body loading states reuse the existing skeleton
cards (`DashboardRecommendedLoadingSection`, `DashboardStrideLoadingCard`);
error states already route through `CatchInlineErrorState` — the stride
error path joins them if it does not already. `DashboardSectionStateCard`
then has zero users and is deleted, along with its widgetbook block.
Visible change: brief text flashes become skeletons on section refresh.

### D4. Rail primitives NEUTRALIZE their context — fix the contract `[confirm]`

`CatchHorizontalRail` and `ClubAvatarRail` default to `showDivider: true` +
their own header/list gutters (`s5`, which is also the screen gutter). Every
section-embedded consumer must zero all three:
`dashboard_full.dart` (3 zeroings), `recommendations.dart` (3),
`host_event_manage_screen.dart` (5), `edit_hosted_event_screen.dart` (1) —
12 knob-zeroings to make the primitive behave. Same disease as the field-row
inset before the flush contract.

Fix (pending confirm of direction): inventory rail call sites that RELY on
the gutter/divider defaults (expected: full-bleed screen placements only).
If ≤3, flip the defaults — rails render chrome-less by default and
full-bleed callers opt in with one `fullBleed: true`-style knob; if more,
make the rails consult the same container-owns-gutter scope the field rows
use (generalizing `CatchFieldInsetScope`; propose the generalized name in
the receipt for review). Either way the 12 zeroings disappear.

### D5. Skeleton drift in `FollowedClubsRailSkeleton` `[codex]`

`dashboard_full.dart:389`: `CatchSkeleton.circle(size: 64)` — raw 64 where
`CatchLayout.avatarIdentityExtent` (64.0) now exists; use it. While there,
check the skeleton's hand-rolled header (`Text('Your clubs', titleL)` + s3
gap) against `ClubAvatarRail`'s real header typography/rhythm and align the
mimic (skeleton mimics must track the widget they imitate).

### D6. Positive calibration — leave these alone

- `NotificationsAction` → `DashboardNotificationBellButton`: ADAPTS →
  CONFIGURES; the provider/display split is the sanctioned pattern.
- `DashboardEmptySliverBody`: role-derived padding (`pageBody.copyWith`),
  `CatchSection.divided` + `CatchJourneySteps` — clean; the model for what
  a section body should look like.
- `Recommendations`: the LayoutBuilder card-width math is real CONFIGURES
  value (its rail zeroings fall away with D4).
- `EventFocusCard` → `EventActionCard`: adapter over a shared primitive, as
  designed.

---

## Screens 2+ — pending

Next: Explore. Audits append here, one section per screen, same format.
