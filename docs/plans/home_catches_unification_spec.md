---
doc_id: home_catches_unification_spec
version: 1.0.0
updated: 2026-07-06
owner: product (approved direction 2026-07-06)
status: ready-for-implementation
depends_on: home_live_layer_product_spec
---

# Home + Catches Unification — Product Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Builds on: `docs/plans/home_live_layer_product_spec.md` (the "home = live
layer" restructure). This spec assumes that work has landed and composes on
its cleaned-up home. Related: `docs/design_parity/composition_audit.md`
(Screen 1 dashboard, Screen 5 catches hub).

## Problem + thesis

Home and Catches are two arbitrary slices of ONE continuous timeline —
`browse → book → upcoming → check-in → companion → CATCH WINDOW → review →
matches`. Home owns the pre/during arc (upcoming, check-in, companion,
review); Catches owns one phase in the middle (the open 24h window where you
catch people you met). The split falls inside a single event's life, so a
user with an open window from last night and an event tomorrow must check
two tabs for two phases of the same cycle.

The code already proves they're the same surface: the home focus rail
(`EventFocusActions` in `event_focus_rail.dart`) already exposes
`onCheckIn`, **`onOpenSwipe`**, `onWriteReview`, `onOpenDirections`,
`onAddToCalendar`, and `DashboardFullViewModel` already carries
`upcomingEvents`, **`activeSwipeEvent`**, `pendingReviewEvent`. Home already
models the whole lifecycle including the catch window — the Catches tab is a
second surface for a phase Home already tracks.

**Thesis: Home becomes the event-lifecycle timeline; the catch window is a
phase of it, not a tab.** The immersive catching interaction stays a
launched destination. The Catches tab is retired.

### The unified lifecycle contract

Every event the user is involved with is ONE phase-aware card. The card
renders the affordance for its current phase; cards sort by urgency so an
open window always floats to the top:

| Phase | Trigger | Card affordance | Treatment |
|---|---|---|---|
| Upcoming | booked, future | directions · add to calendar · invite | standard |
| Today / live | event is today | check in · open companion | standard, elevated sort |
| **Window open** | checked in, 24h window active | **"N to catch · {countdown} left" → launches catch flow** | **hero, top sort, live countdown** |
| Pending review | window closed, no review | write review · see matches | quiet |

A user can have MULTIPLE simultaneous phases (e.g., two open windows + one
upcoming). The timeline shows them all, urgency-ordered. This is the core
view-model change: `activeSwipeEvent` (single) becomes a LIST of windowed
events (what the Catches hub already aggregates).

Goal-mode: loop the checklist to complete; one commit per item (pathspecs);
escalate-and-continue on failed preconditions. Standard workflow (AGENTS.md,
focused tests + analyzer, sequential Flutter runs, widgetbook, catalog/
doc_versions/passes stamps, readiness gate). Never edit
`packages/catch_ui_lints`.

---

## Phase U1 — Unify the view model `[codex]`

Fold the Catches-hub aggregation into the home focus view model so one
provider derives the whole timeline.

- `DashboardFullViewModel.activeSwipeEvent` (`Event?`) → `windowedEvents`
  (`List<CatchWindowItem>`), where each item carries what
  `CatchesHubEventRow` carries today (eventId, title, subtitle,
  attendedCountLabel, remaining-to-catch count, window expiry for the
  countdown). Reuse the existing catch-window aggregation logic from
  `buildCatchesHubScreenState` / the catches-hub view model — MOVE it into
  the home focus derivation, do not duplicate; delete the hub-only builder
  once home consumes it.
- Preserve the existing `upcomingEvents` and `pendingReviewEvent`
  derivations. The home focus view model now emits the full ordered
  timeline: windowed (by soonest expiry) → today → upcoming → pending
  review.
- The catch-window expiry/`swipe_window.dart` domain already imported by the
  view model drives the countdown — reuse it; no new time model.

Acceptance: one provider yields the ordered timeline; multiple open windows
all appear; no reference to a separate catches-hub aggregation remains.

## Phase U2 — The lifecycle card `[codex]`

- The focus card's **window phase** adopts `AttendedEventTile`'s content
  (title, attended-count, the catch CTA) plus a **live countdown** to window
  expiry (standard motion; `MediaQuery.disableAnimations` → static "Xh
  left"). Tapping the window card launches the catch flow (U3), exactly as
  `onOpenSwipe` does today — the immersive swipe is unchanged, only its
  entry point moves.
- The other phases keep their current `EventFocusCard` affordances.
- `CatchesIntroCard`'s "featured run" richer treatment folds into the
  top-sorted window card (the most urgent window is the hero); the standalone
  intro card is retired.
- Retire the hub-only widgets once absorbed: `CatchesHubContent`,
  `CatchesHubHeader`, `CatchesIntroCard`, `PillStat`, and — if the card
  fully absorbs it — `AttendedEventTile` (verify no other consumer via `rg`;
  ledger any deletion in `decisions.json`, status
  `executed-home-catches-unification`).

Acceptance: window cards show a live countdown + catch count + launch the
flow; no standalone catches-hub widget remains; skeletons follow.

## Phase U3 — Nav shell: retire the Catches tab `[codex]`

In `lib/routing/go_router.dart`:

- Delete the Catches `StatefulShellBranch` (the `swipeHubScreen('/catches')`
  branch, ~line 507). Remove `SwipeHubScreen` (screen widget) once unmounted.
- **Re-parent `swipeEventScreen('/catches/:eventId')`** (the immersive catch
  flow) under the HOME (dashboard) branch so home can push into it. **Keep
  the path `/catches/:eventId` unchanged** — push notifications and deep
  links target it; only the branch parent moves.
- `/catches` (bare hub path) → redirect to `/` (home). Update the tab-match
  helpers that reference `swipeHubScreen.path` (~lines 825, 950) and any
  index-based branch logic.
- In `lib/core/presentation/app_shell.dart`: remove the Catches
  `BottomNavigationBarItem`; the consumer tab set becomes Home · Explore ·
  Chats · Profile. Verify no hardcoded branch indices break (StatefulShell
  uses branch order — re-check every `goBranch`/`currentIndex` site).

Acceptance: four consumer tabs; deep links to `/catches/:eventId` still open
the catch flow (now pushed over home); no dangling route/index references.

## Phase U4 — Merge empty states `[codex]`

`CatchesHubEmpty` and the dashboard idle/empty state collapse into ONE home
empty state: no active events and no open windows → the existing find-an-
event CTA (`EmptyHeroCard` card variant) plus the "how catches work"
explainer that `CatchesHubEmptyState` carried today (fold its copy in, once,
as the idle explainer). Retire `CatchesHubEmptyState`. The true new-user
onboarding empty is unchanged.

Acceptance: one idle home; the catches explainer survives as idle copy; no
duplicate empty-state widget.

## Phase U5 — Analytics + tests `[codex]`

- Extend the home state-machine analytics (from home-live-layer 1A.6) so
  `home_opened {state}` includes `window_open`, and add
  `catch_window_impression {surface: home}` and `catch_window_open` firing
  from the windowed-card path (verify emission with a focused test — the
  2026-06 audit found dead funnel events).
- Tests: the timeline orders windowed → today → upcoming → review; multiple
  open windows all render; window card launches `/catches/:eventId`; the
  countdown reduced-motion path; merged empty state; deep link to a catch
  flow still resolves. Widgetbook: home states incl. one/many open windows;
  delete retired catches-hub use-cases.

Acceptance: all named tests green; analytics emit; widgetbook covers the new
states.

---

## Owner decisions — RESOLVED 2026-07-06 (delegated to review)

- **U-C1 · Multi-window layout → VERTICAL PRIORITY LIST (rail retired)
  `[codex]`.** The focus surface becomes a vertical, urgency-ordered list of
  full-width cards, not a horizontal focus rail. Rationale: the thesis is
  "answer what to do right now at a glance"; a rail shows one card and hides
  every other active phase behind a swipe, so a second open window or a
  closing countdown is invisible until you interact — which defeats the
  purpose for exactly the time-sensitive content that earns home placement.
  Apply the presentation-tier doctrine (`design_language.md` §6): the
  top/urgent phase (an open window) renders as the **hero** card with its
  live countdown; a long low-urgency **upcoming tail** may render in the
  **condensed** tier (compact rows) so the list stays scannable. Degrades
  gracefully to a single card when there is one focus item — no special-case
  rail. This replaces `EventFocusRail`'s horizontal `PageView` treatment;
  update its widgetbook + tests accordingly.
- **U-C2 · Tab identity → KEEP "Home" `[codex]`.** The consumer tabs are
  Home · Explore · Chats · Profile; the anchor tab stays "Home". Rationale:
  (1) it is the default/leftmost anchor tab, where convention matters most
  and where it must survive the empty/idle state gracefully; (2) it must not
  over-index on any single phase — the screen is upcoming + live + windows +
  review, not only catches; (3) a catch-centric label would worsen the
  `Catch*` / `Catches*` namespace collision already flagged for the naming
  lexicon. The screen's identity is carried by its live-timeline content, not
  a clever label. No rename; no code change beyond removing the Catches item
  (U3).

## Sequencing

Lands AFTER `home_live_layer_product_spec.md` Phase 1A (needs the home state
machine + the 1A.4 catch-window priority ordering as its foundation — this
spec generalizes that single-window ordering into the multi-window
timeline). Do NOT start before 1A is merged; U1 directly rewrites the focus
view model 1A touched. Phase 2 (organizer posts) of the home spec is
independent and can interleave.

## Non-goals (v1)

- Changing the catch interaction itself (the swipe flow is re-parented, not
  redesigned).
- Chats tab changes (durable output stays its own tab).
- Push-notification infrastructure changes (reuse existing).
- Multi-window batching/merging into a single "catch everyone" flow.

## Completion checklist (goal mode)

- [ ] U1 view model unified (windowedEvents list; hub aggregation moved, not duplicated)
- [ ] U-C1 focus surface = vertical priority list (rail retired; hero window card + condensed upcoming tail per §6)
- [ ] U2 lifecycle card window phase (countdown + count + launch) + hub widgets retired + ledger
- [ ] U3 nav shell: Catches tab removed, catch flow re-parented, deep links preserved, indices verified (tab stays "Home", U-C2)
- [ ] U4 merged idle/empty state (explainer folded in)
- [ ] U5 analytics + tests + widgetbook states
- [ ] full analyze clean; readiness 100/100; scanners green; catalog/doc_versions/passes stamped
