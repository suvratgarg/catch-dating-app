---
doc_id: event_detail_composition_tracker
version: 0.1.3
updated: 2026-07-23
owner: product_design_parity
status: retirement_ready
---

# Event Detail Composition Tracker

## Purpose

This tracker records the Event Detail screen composition, its owner-approved
2026-07-12 visual direction, shared primitive boundaries, Widgetbook coverage,
and deterministic/live verification seams.

The machine-readable contract for this pass lives in
`design/screens/catch.screens.json` under `screen.event.detail`.

## Source Inputs

| Source | Role |
|---|---|
| `design/reference_screens/screen.event.detail/approved-redesign-board-2026-07-12.png` | Owner-approved Event Detail direction for top chrome, map, information rows, host/social content, and iOS action chrome. |
| `claude.catch-event-detail` / `claude.components.events` | Historical handoff identifiers retained in the screen contract; machine-local source paths are not portable. |
| `lib/events/presentation/event_detail_screen.dart` | Route-level screen and initial provider state handling. |
| `lib/events/presentation/event_detail_information_state.dart` | Checked, non-overlapping sign-up and good-to-know fact model. |
| `lib/events/presentation/widgets/event_detail_body.dart` | Explicit-input composition shell for hero, overview, host, social, prompts, and adaptive bottom action. |
| `lib/events/presentation/widgets/event_detail_design_primitives.dart` | Event-specific visual compounds, including the Google-backed map card and flat fact lists. |
| `test/ui_captures/catalog/screen_capture_catalog.dart` | Existing Event Detail route captures. |

## Current Organization

`EventDetailScreen` is the provider and effect boundary. It handles loading,
error, not-found, mutations, navigation, host/companion lookup, and derives
typed section visibility, information, host, social/review, and booking state.

`EventDetailBody` is provider-free composition. It receives explicit state and
callbacks, composes the canonical top-bar action group, real map preview, flat
fact lists, compact host/social rows, and `CatchBottomAction`, and owns no route
side effects.

## Claude To Flutter Section Map

| Target section | Claude component(s) | Current Flutter source | Current status | Migration note |
|---|---|---|---|---|
| Event hero | `EventHero` | `EventDetailHeroAppBar` + `CatchTopBarActionGroup` | Implemented | Back/action geometry and sibling gaps are shared top-bar behavior; hero states remain source-aware. |
| Ticket fact band | `TicketStub` | `EventDetailTicketStubBand` | Implemented locally | Convert from whole-`Event` input to explicit cells. Keep event-derived cells in adapter code. |
| The plan | `Section` | `EventDetailOverviewSection` private description block | Implemented locally | Promote to a section with explicit title/body view data. |
| Why you might click | `HintList` | `EventDetailHintList` | Implemented locally | Convert from event-derived internal hints to explicit hint rows. |
| Itinerary | `Itinerary` | `EventDetailItinerary` | Implemented locally | Convert from event-derived internal steps to explicit step rows. |
| Photo proof strip | `PhotoStrip` | `EventDetailPhotoStrip` | Implemented locally | Convert to explicit cells, caption, and right data line for app, website, and social reuse. |
| Hosted by | `HostRow` | `EventDetailHostsSection` + `CatchHostRow` | Implemented | Route maps club lookup into `EventDetailHostState`; callback presence derives message and navigation affordances. |
| Who's going | `AvatarStack` | `EventDetailSocialSection`, `WhoIsGoing`, `GuestWhoIsGoing` | Implemented | Guest/member states are explicit and the bottom action is the only Event Detail catch-window message owner. |
| Reviews | `Section` | `EventDetailSocialSection` + `EventDetailReviewsState` | Implemented | Non-actionable empty state is hidden; eligible empty state is an inline write prompt; populated actions are capability-derived. |
| Where | `MapCard` | `EventDetailMapCard` + `CatchMapPreview` | Implemented | Production uses exact-coordinate Google tiles; `enableNetworkTiles: false` is the deterministic preview/capture seam. |
| How sign-ups work | `MechanismList` | `EventDetailInformationState` + `EventDetailMechanismList` | Implemented | Admission, waitlist, and pricing facts are explicit, validated, and unique. |
| Good to know | `Section` | `EventDetailInformationState` + `EventDetailGoodToKnowList` | Implemented | Requirements, experience, attendance, and cancellation are flat rows; booking/settlement facts cannot enter this list. |
| Companion/invite prompts | `Section` | `_EventCompanionEntry`, `_EventInviteLoopCard` | Implemented locally | Move event-success plan lookup and invite visibility into screen/controller state. |
| Booking action | `BookingDock` | `EventDetailCta`, `GuestBookCta`, `CatchBottomAction` | Implemented | One action contract floats on iOS and anchors on Android; booking state remains provider-free below the controller adapter. |

## State Coverage

| State | Current proof | Gap |
|---|---|---|
| Loading | `EventDetailScreen` loading branch, Widgetbook, capture, and widget tests | Compact host/action skeletons follow the new geometry. |
| Not found | `CatchErrorScaffold` branch and widget tests | Needs decision: branded error surface vs dedicated empty event state. |
| Fatal error | `CatchErrorScaffold.fromError` branch and widget tests | Needs preview/capture, including offline-looking errors. |
| Authenticated member | `event_detail_member` capture, Widgetbook, and focused tests | Live comparison should use the approved 2026-07-12 board. |
| Ticket mode | `event_detail_member_ticket` capture and Widgetbook hero/stub states | Keep source-aware hero treatment. |
| Spotlight dark | `event_detail_member_spotlight` capture and Widgetbook | Recheck contrast after any bottom-action token change. |
| Guest | Capture, Widgetbook social/action states, and widget tests | Guest action inherits the same platform primitive. |
| Host app | Capture plus controller/widget tests | Host suppresses the consumer booking action. |
| Booking pending/failed | Widgetbook and widget tests | Shared action preserves loading/error geometry. |
| Waitlist/sold out/cancelled/past | Independent provider-free action states in Widgetbook/tests | Keep state mapping in `EventDetailBookingDockState`. |
| Offline | Not explicit | Define via error surface contract and add capture. |
| Text scale/reduced motion | Registered captures, Widgetbook addons, and focused tests | Keep top actions flexible and bottom-action motion platform-safe. |

## Implemented Slice

1. `EventDetailScreen` owns provider waves, capability derivation, mutations,
   and navigation effects.
2. `EventDetailBody` composes explicit state and callbacks only.
3. `EventDetailInformationState` validates non-overlapping section facts.
4. `CatchTopBarActionGroup`, `CatchMapPreview`, `CatchHostRow`, and
   `CatchBottomAction` own the repeated UI behavior at shared boundaries.
5. Reviews use explicit hidden/content/empty-write capability modes.

## Widgetbook Coverage Added

Widgetbook covers the Event Detail compounds and shared primitives for:

- `EventDetailHeroAppBar`
- `EventDetailTicketStubBand`
- `EventDetailHintList`
- `EventDetailItinerary`
- `EventDetailPhotoStrip`
- `EventDetailMapCard`
- `EventDetailMechanismList`
- `EventDetailGoodToKnowList`
- `CatchMapPreview` through deterministic map-card fixtures
- `CatchHostRow`
- `CatchBottomAction` on iOS and Android
- `EventDetailOverviewSection`
- `EventDetailSocialSection` / `AvatarStack` states
- `EventReviewsSection`
- `EventDetailBody` companion and invite prompt states.
- `EventBookingDock` provider-free booking states.

Remaining Event Detail gaps:

- Keep real Google tile availability verified on a configured device; fixtures
  deliberately use the deterministic fallback.
- Compare the stable member, policy/map, and host/social scroll positions with
  the owner-approved redesign board after relevant token changes.
- Offline error copy remains a product decision outside this visual slice.

## Non-Regression Constraints

- Do not reintroduce nested policy cards, settlement copy, duplicated facts,
  oversized host cards, or a non-actionable empty review tile.
- Do not branch feature call sites on platform for the primary action.
- Do not draw fake map tiles or put product caption chrome over Google
  attribution.
- Do not make the screen contract a substitute for component contracts. The
  screen registry tells us what must be composed; component and section
  contracts still own reusable APIs.
