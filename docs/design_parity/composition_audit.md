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

## The detail-screen grammar (target for Event Detail + Club Detail)

Both detail screens should be built from the same five-layer grammar, with
feature-owned content in layers 2 and 4 only:

1. **Route screen** — state dispatch (loading / error / content). Both are
   fine today.
2. **Hero app bar** — pinned SliverAppBar with a feature-owned hero surface
   (event = ticket, club = polaroid module). Stays feature-specific.
3. **Identity band** — the entity's key facts directly under the hero
   (event = ticket-stub band, club = next-run banner + metric strip).
4. **Sections** — ONE `CatchDetailSliverSectionList`, every section a
   `CatchSection` with the kicker title voice, skeleton loading states.
5. **Bottom dock** — `CatchBottomDock` variants.

Cross-cutting decisions (made in this review):

- **G1. One section-title voice: the CatchSection kicker.** Event detail is
  uniform; club detail mixes three systems (kicker sections, `titleL`
  'Schedule', `titleL` 'Reviews' via ClubReviewsSection). Standardize on the
  kicker `[confirm]` — visible change on club Schedule/Reviews headings.
- **G2. Section loading = skeletons, never spinners or copy.** Event
  detail's companion/hosts loading states use centered
  `CatchLoadingIndicator`; replace with skeleton rows (host skeleton already
  exists in the optimistic body). Same doctrine as Dashboard D3.
- **G3. Surface style becomes an ambient scope.** `EventDetailSurfaceStyle`
  is threaded through ~96 references, with cards like `EventDetailHostCard`
  taking seven separate color slots. Introduce an InheritedWidget scope
  (working name `EventDetailSurfaceScope`; propose the final name for
  review) that sections/cards resolve implicitly; constructors keep optional
  overrides but the per-call-site plumbing disappears. This also makes a
  future club spotlight/dark mode nearly free.
- **G4. One body per screen.** Parallel shells (optimistic body, see E1)
  merge into the real body with injected actions and loading section states.

---

## Screen 2 — Event Detail (audited 2026-07-05)

Files: `lib/events/presentation/event_detail_screen.dart`,
`widgets/event_detail_*.dart`. Overall: the DS-blessed slice — sliver
architecture, section list, ticket identity, and dock are all right. The
issues are one parallel shell, in-file twins, spinner loading, and the style
plumbing (G2/G3).

### E1. `EventDetailOptimisticBody` is a second full shell — merge `[codex after G2]`

It rebuilds Scaffold + hero + stub band + section list + overview with
hard-coded disabled actions, and swaps to `EventDetailBody` when the view
model resolves — two assemblies of one screen that must be kept in sync by
hand. Decision (resolves the consolidation escalation on this pair): once
section loading is skeleton-based (G2), the optimistic render IS
`EventDetailBody` with `hostState`/`socialState` in loading, guest-mode
callbacks injected (save → auth redirect, share/calendar hidden), and the
same Scaffold provided by the route screen for both branches. Delete
`EventDetailOptimisticBody`; keep `OptimisticHostsSkeleton` as the shared
hosts loading skeleton (renamed to `EventDetailHostsSkeleton`).

### E2. `EventCompanionCard` / `EventInviteLoopCard` are in-file twins `[codex]`

Same anatomy (surface → icon → title/body → full-width secondary button),
~80 lines each in event_detail_body.dart. Parameterize into one
`EventDetailCalloutCard({icon, title, body, actionLabel, actionIcon,
onAction, borderColor?})`; the two call sites pass their copy. (Check the
dashboard stride connect card against it in passing — if it matches, note it
for a third-occurrence core promotion, don't do it now.)

### E3. Spinner loading in companion/hosts sections `[codex after G2 confirm]`

`EventCompanionEntry.loading` and `EventDetailHostsSection.loading` render
`Center(CatchLoadingIndicator())`. Replace with skeletons: hosts uses the E1
skeleton; companion gets a one-surface skeleton mimic of its callout card.

### E4. `LegacyEventHeroSurface` `[codex]`

`event_detail_hero_app_bar.dart:172` — anything named Legacy in the blessed
slice needs a verdict. Check usages: if only non-ticket presentation modes
use it and those modes still ship, keep but rename to what it actually is
(e.g. `EventPhotoHeroSurface`); if unreachable, delete.

### E5. Positive calibration

Hero → ticket-stub band → `CatchDetailSliverSectionList` → CatchBottomDock
CTA is the reference composition. Section-state dispatchers
(hidden/loading/error/content) per section are the right pattern; only their
loading rendering (E3) is off-language.

---

## Screen 3 — Club Detail (audited 2026-07-05)

Files: `lib/clubs/presentation/detail/**`. Overall: the content and IA are
good (hero → next-run banner → metric strip → sections → schedule →
reviews), but the screen predates the detail grammar: it hand-rolls the
section scaffolding the core already owns, mixes title systems, and carries
typography drift.

### C1. Adopt `CatchDetailSliverSectionList` `[codex]`

`ClubDetailBody` hand-assembles `SliverPadding(fromLTRB(detailScreen*
tokens))` + nested `CatchSectionStack` + a local `sectionGap` SizedBox + two
more hand-padded slivers for schedule/reviews — three gutter mechanisms for
one screen, plus two file-local padding consts
(`_clubDetailSectionStackPadding`). Restructure to match event detail: one
`CatchDetailSliverSectionList` for the box sections (banner, metric strip,
About → Get in touch, reviews); the schedule's `EventAgendaSliverList` is a
true sliver and stays a sibling sliver, but its title and paddings come from
the same tokens/primitives as everything else (see C2).

### C2. Section-title unification (G1 applied) `[confirm]`

'Schedule' (`ClubScheduleSection`, bare `Text(titleL)`) and 'Reviews'
(`ClubReviewsSection` via titleL header) move to the CatchSection kicker
voice used by the other five sections on this screen. For the schedule this
means a sliver-compatible section header built from the same kicker
primitive (`CatchSection` title chrome), not a bespoke Text.

### C3. `ClubNextRunBanner` raw control + typography drift `[codex]`

Hand-rolls `Material + InkWell + Ink(BoxDecoration)` — replace with
`CatchSurface(onTap:, backgroundColor: activity.soft, radius: md)`. Its
label applies `.copyWith(fontWeight: w700)` to `monoLabelS`; the About
section likewise applies `.copyWith(fontWeight: w400)` to `bodyLead`. Both
are off-token faux weights: use the existing text style whose weight matches
(check `CatchTextStyles` for a strong mono label and a reading-body style);
if none exists, escalate with a proposed style name — do not keep copyWith
weights.

### C4. `CatchClubDock` — wrong shell, wrong name `[codex]`

341 lines hand-rolling its own SafeArea/ColoredBox dock shell while the
event side rides `CatchBottomDock.cta`. Rebuild on `CatchBottomDock` (keep
DockCount/DockBell content). LEXICON: `Catch*` is reserved for core
primitives; this is a clubs feature widget — rename to `ClubDetailDock`
(with the usual deprecated typedef for one release if usages are wide).

### C5. Schedule empty state over-tuning `[codex]`

`ClubScheduleSection`'s `CatchEmptyState` hand-tunes six knobs including raw
`iconContainerSize: 44`. Use the empty-state defaults; if the inline layout
genuinely needs a smaller container, use the nearest token and keep at most
the `layout:` knob. Raw 44 must not survive.

### C6. IA polish `[confirm]`

'Get in touch' (contact rows) currently sits between Hosts and Schedule.
It is footer-type content — propose moving it below Reviews as the last
section, so the mid-page flow reads About → What we do → Photos → Hosts →
Schedule → Reviews → Get in touch. Pure reorder, no widget changes.

### C7. Positive calibration

The next-run banner above the metric strip is a strong identity band —
better than anything event detail has for "when do I show up next"; keep
it. `ClubActivitySection`'s primary/secondary tag split is genuine OWNS
logic. The metric strip (members/rating/reviews/est.) is the right data at
the right altitude.

---

## Screens 4+ — pending

Next: Explore. Audits append here, one section per screen, same format.
