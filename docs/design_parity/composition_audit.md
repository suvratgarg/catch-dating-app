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

Standing doctrine (owner-approved 2026-07-05):

- **Widgetbook exercises real screens and shells, never parallel ones.**
  Parallel widgetbook-only assemblies are how dead shells like
  `DashboardFull` survive and drift. Use-cases compose the production
  screen/body widgets with fixture state. Scanner candidate once the
  current parallel shells are gone: flag widgetbook-only constructors of
  `*Screen`/`*Body`-suffixed widgets that duplicate a production shell.

Screen queue (working order): Dashboard ✅ → Event Detail ✅ → Club Detail ✅
→ Explore → Catches/Swipe Hub → Chats/Inbox → Profile → Host Operations.

---

## Screen 1 — Dashboard (audited 2026-07-05)

Files: `lib/dashboard/presentation/dashboard_screen.dart` (+ 4 part files),
`lib/dashboard/presentation/widgets/*`.

Overall: the state dispatch (`DashboardScreen` → loading/error/empty/full)
and the empty state are composed well. The full state carries one dead
parallel shell, one inheritance wrapper, one loading-language inconsistency,
and a systemic rail-defaults problem that extends beyond this screen.

### D1. `DashboardFull` is a dead parallel screen shell — delete `[done 83b7b146b]`

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

### D2. `DashboardSliverHeader` is subclass-as-configuration — inline `[done 83b7b146b]`

`widgets/dashboard_sliver_header.dart`: the class only pre-fills
`CatchSliverHeader(title: DashboardHeaderContent(...))` via `super`. That is
a PASS-THROUGH by inheritance. Fix: delete the subclass; at both call sites
(`DashboardHomeScreen`, and `DashboardFull` until D1 removes it) construct
`CatchSliverHeader(title: DashboardHeaderContent(eyebrow:, title:, actions:))
.buildSlivers(context)` directly. `DashboardHeaderContent` stays (OWNS the
dashboard title-block chrome; the K5 keep vs Explore's header stands).

### D3. Section-loading language is inconsistent — standardize on skeletons `[done 83b7b146b]` (approved 2026-07-05 via G2)

The same dashboard sections have two loading treatments:

- Loading screen (`dashboard_screen.dart` parts): skeleton mimics
  (`DashboardFocusLoadingCard`, `DashboardStrideLoadingCard`,
  `DashboardRecommendedLoadingSection`). On-language.
- In-body refresh states: `DashboardSectionStateCard(message: 'Loading
  recommended events...', isLoading: true)` (dashboard_full.dart:345) and
  the stride equivalent (stride_card.dart:54) — a text row card, off-language
  (nothing else in the app announces loading with copy).

Fix (approved): in-body loading states reuse the existing skeleton
cards (`DashboardRecommendedLoadingSection`, `DashboardStrideLoadingCard`);
error states already route through `CatchInlineErrorState` — the stride
error path joins them if it does not already. `DashboardSectionStateCard`
then has zero users and is deleted, along with its widgetbook block.
Visible change: brief text flashes become skeletons on section refresh.

### D4. Rail primitives NEUTRALIZE their context — fix the contract `[done 83b7b146b]` (approved 2026-07-05)

`CatchHorizontalRail` and `ClubAvatarRail` default to `showDivider: true` +
their own header/list gutters (`s5`, which is also the screen gutter). Every
section-embedded consumer must zero all three:
`dashboard_full.dart` (3 zeroings), `recommendations.dart` (3),
`host_event_manage_screen.dart` (5), `edit_hosted_event_screen.dart` (1) —
12 knob-zeroings to make the primitive behave. Same disease as the field-row
inset before the flush contract.

Fix (approved; direction decided by inventory): count rail call sites that
RELY on the gutter/divider defaults (expected: full-bleed screen placements
only). If ≤3, flip the defaults — rails render chrome-less by default and
full-bleed callers opt in with one `fullBleed: true`-style knob; if more,
make the rails consult the same container-owns-gutter scope the field rows
use (generalizing `CatchFieldInsetScope`; propose the generalized name in
the receipt for review). Either way the 12 zeroings disappear; record the
inventory count and chosen branch in the receipt.

Receipt: chose the default-flip branch. The scanner now reports 3 production
rail calls, 1 full-bleed opt-in, and 0 high/medium legacy zeroing findings.
`design:rail-contracts` is manifest-owned and bound back to
`DESIGN-PRIMITIVES-001`, `SCREEN-GUTTER-001`, and `UI-LINT-001`.

### D5. Skeleton drift in `FollowedClubsRailSkeleton` `[done 83b7b146b]`

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
  kicker (owner-approved 2026-07-05) — visible change on club
  Schedule/Reviews headings.
- **G2. Section loading = skeletons, never spinners or copy
  (owner-approved 2026-07-05).** Event
  detail's companion/hosts loading states used centered
  `CatchLoadingIndicator`; fixed in `fca49f467` with shared skeleton rows.
  Same doctrine as Dashboard D3.
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

### E1. `EventDetailOptimisticBody` is a second full shell — merge `[done 76269027c]`

Fixed in `76269027c`: `EventDetailOptimisticBody` was deleted. The
initial-event loading branch now uses the route-owned `Scaffold` plus
`EventDetailBody` with `EventDetailHostState.loading` and
`EventDetailSocialState.loading`, guest-mode callbacks injected, share/calendar
hidden, save routed through the existing auth redirect, and the source
presentation mode/Hero tag preserved. `EventDetailHostsSkeleton` remains the
shared host-loading section, and the new `EventDetailSocialState.loading`
renders the shared `EventDetailSocialSkeleton`.

### E2. `EventCompanionCard` / `EventInviteLoopCard` are in-file twins `[done f2ce30b49]`

Same anatomy (surface → icon → title/body → full-width secondary button),
~80 lines each in event_detail_body.dart. Fixed in `f2ce30b49`: both local
cards were collapsed into `EventDetailCalloutCard`, and the invite-loop and
companion call sites now pass copy, icons, action behavior, surface style, and
the invite light-surface border override into that single primitive. Dashboard
stride connect card was not promoted in this pass; it remains a possible
third-occurrence review point if another callout shape converges.

### E3. Spinner loading in companion/hosts sections `[done fca49f467]` (G2 approved)

`EventCompanionEntry.loading` and `EventDetailHostsSection.loading` rendered
`Center(CatchLoadingIndicator())`. They now use content-shaped skeletons:
hosts uses `EventDetailHostsSkeleton`, and companion uses
`EventDetailCompanionSkeleton`.

### E4. `LegacyEventHeroSurface` `[done 6e1199a92]`

Fixed in `6e1199a92`: the surface is still the live non-ticket presentation
path, so it was kept and renamed to `EventPhotoHeroSurface`. Widgetbook and
the widget catalog now use the photo-surface name; no behavior changed.

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

### C2. Section-title unification (G1 applied) `[codex]` (approved 2026-07-05)

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

### C6. IA polish `[codex]` (approved 2026-07-05)

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

## Cross-screen finding — sliver-header wrappers (supersedes D2's scope)

Four features wrap `CatchSliverHeader` construction in a do-nothing layer:
`DashboardSliverHeader`, `ExploreSliverHeader`, `ChatsSliverHeader` (all
`extends CatchSliverHeader` pre-filling `super(title: ...)`), and
`ProfileSliverHeader` (a non-widget helper class whose `buildSlivers` just
constructs one). **Fix all four the same way `[done 33597504f]`**: delete the
wrapper, construct `CatchSliverHeader(title: <FeatureHeaderContent>, ...)`
directly at the call sites. The feature `*HeaderContent` widgets stay. While
in ProfileSliverHeader, its raw `bottomHeight: 48` becomes the nearest
CatchLayout token (escalate per D1 if none is exact).

Watch item (no action yet): the hand-rolled screen-title blocks —
`DashboardHeaderContent`, `ExploreBrowseHeaderContent`, `CatchesHubHeader`,
`ProfileTitle` — are now a four-occurrence pattern (eyebrow/kicker +
headline + trailing action). A core screen-title-block primitive is a
naming-lexicon-ratification candidate; do not force it in this pass.

---

## Screen 4 — Explore (audited 2026-07-05)

Files: `lib/explore/presentation/explore_screen.dart`, `widgets/*`. Overall:
the sliver-function pattern (`buildExploreBodySlivers`) is the right answer
to Flutter's nested-sliver constraints and the feed composition is sound;
the debt is two wrappers and a parallel surface system.

### X1. `ExploreBody` — self-documented compatibility wrapper `[codex]`

Its own doc comment says it exists "for call sites that still expect one
sliver." One production caller remains (`explore_list.dart:63`) plus
widgetbook. Migrate that caller to spread `buildExploreBodySlivers(...)`
(moving the `CatchMutationErrorListener` to wrap the enclosing scroll view),
repoint widgetbook, delete the class.

### X2. `ExploreChrome` — 16-parameter pass-through `[codex]`

Forwards every one of its 16 params to exactly two children
(`ExploreDiscoveryCoverHeader`, `ExploreFilterRail`) with zero logic. Inline
the two children as two `SliverToBoxAdapter`s in `ExploreScreen`, delete the
class.

### X3. `CrossPathsSurface` + `CatchSurfaceShadow` — parallel surface system `[codex]`

`catch_cross_paths_card.dart` defines its own surface widget AND its own
elevation enum (`CatchSurfaceShadow { card, raised }`) — a feature-local
duplicate of `CatchSurfaceElevation { …, card, raised, … }`. Replace
`CrossPathsSurface` usages with `CatchSurface` + the matching elevation
role; delete both the widget and the enum. If any visual delta beyond
shadow-token rounding appears, stop and record it in the receipt instead of
forcing.

### X4. Lexicon notes (ratification input, no code now)

`CatchCoverStory` and `CatchCrossPathsCard` are feature widgets on the core
`Catch*` prefix — but CoverStory's doc claims design-system handoff lineage
(`components/explore/CoverStory`), so the prefix rule needs a ratified
carve-out or a rename. Also `Catches*` (the feature noun) colliding with
`Catch*` (the core prefix) makes prefix-based scanning noisy — note for the
lexicon.

### X5. Positive calibration

`buildExploreBodySlivers` as a function returning a flat sliver list —
documented against nested-group pathologies — is the correct pattern; do
not widget-ify it. The synthetic visual fill is debug-gated and harmless.

---

## Screen 5 — Catches Hub (audited 2026-07-05)

File: `lib/swipes/presentation/swipe_hub_screen.dart`. Overall: clean state
dispatch and token usage; findings are title-voice drift.

### H1. 'Open catch windows' hand-rolled section header `[codex]`

`CatchesHubContent` builds `Row(Text('Open catch windows', titleL), Text
('$count', mono))` by hand while the same screen uses `CatchSectionHeader`
above it. Replace with the section primitive that owns a title + count
(`CatchSectionHeader` with its count/trailing slot, or `CatchSection`'s
kicker+count chrome — match whichever the G1 voice dictates for in-body
list headers). The manual `for (...) gapH12` interleave below it becomes
`CatchSectionList(gap: CatchSpacing.s3, ...)`.

### H2. `PillStat` — lexicon note

Another `Pill`-named widget to sweep into the ratified pill definition; no
code now.

### H3. Positive calibration

`CatchesHubStateView` dispatch, the intro card, and the empty state are
composed correctly; `CatchesHubHeader` is covered by the cross-screen
title-block watch item.

---

## Screen 6 — Chats Inbox (audited 2026-07-05)

Files: `lib/chats/presentation/inbox/**`. Overall: the cleanest feature in
the audit — small files, primitives used directly.

### T1. `ChatsEmptyState` decides host copy by comparing a default string `[codex]`

`isHostApp && title == 'No catches yet'` substitutes host copy only when the
title still equals the guest default — a string-sentinel that silently
breaks the moment the default copy is edited. Replace with an explicit
variant: a `ChatsEmptyState.hostInbox()` named constructor (or an enum
role) chosen by the caller that knows `AppConfig.appRole`; the build method
stops inspecting copy.

### T2. Positive calibration

`ChatConversationsList` is the model CONFIGURES layer: rich, meaningful
mapping onto `CatchPersonRow` with chat-role tokens, no chrome of its own.
The Chats sliver-header wrapper is handled by the cross-screen sliver-header
finding.

---

## Screen 7 — Profile (audited 2026-07-05)

Files: `lib/user_profile/presentation/profile_screen.dart`,
`widgets/profile_sliver_header.dart`. The edit tab was rebuilt during the
gutter/section work and is the flush-contract reference; the shell holds
the remaining items.

### P1. `ProfileSliverHeader` wrapper + raw 48 `[done 33597504f]`

Covered by the cross-screen sliver-header finding (it is the helper-class
variant); the raw `bottomHeight: 48` goes to a token in the same change.

### P2. Positive calibration

The NestedScrollView + overlap-absorber tab architecture is correct and
`ProfileTabScrollView` earns its place (per-tab scroll wiring).
`ProfileTabBar` staying distinct from `CatchTopBarTabBar` was already
ratified in the consolidation ledger.

---

## Screen 8 — Host Operations (audited 2026-07-05, structural pass)

File: `lib/hosts/presentation/host_operations_screen.dart` — **54 classes,
~4,500 lines, three route screens** (HostProfileScreen, HostEventsScaffold,
HostClubsScaffold) plus the today-dashboard, organizer, insights, and
analytics surfaces in one file. Widget-level composition inside it is
largely sound after the WO-018/020/021 absorptions (spot-checked: the
organizer metric grid/row chain, team card/row, analytics panels).

### O1. Split the module `[codex]`

This is a module, not a screen file. Split by surface into
`lib/hosts/presentation/host_operations/` (e.g. `host_profile_screen.dart`,
`host_events_scaffold.dart`, `host_clubs_scaffold.dart`,
`host_today/*.dart`, `host_organizer/*.dart`, `host_insights/*.dart`,
`host_analytics/*.dart`) with pure file moves — no widget changes, imports
and part-file wiring only, tests/widgetbook repointed. Do this as its own
commit so review diffs stay readable.

### O2. `HostSectionLabel` is dead — delete `[codex]`

Zero constructions anywhere (WO-018 marked it delete-if-orphaned; the
orphaning happened, the deletion did not). Remove the class and any
widgetbook block.

---

## Screens 9+ — pending

Remaining candidates: Event Success companion/host surfaces, Calendar,
Saved Events, Payments/Reviews history. Audits append here, same format.
