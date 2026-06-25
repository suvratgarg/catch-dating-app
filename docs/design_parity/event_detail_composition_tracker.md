---
doc_id: event_detail_composition_tracker
version: 0.1.2
updated: 2026-06-20
owner: product_design_parity
status: active
---

# Event Detail Composition Tracker

## Purpose

This tracker is the first screen-level migration pass for the composition
architecture described in `composition_migration_spec.md`. It maps the Event
Detail screen from current Flutter implementation to Claude Design primitives,
Widgetbook gaps, capture states, and the target screen-as-composer shape.

The machine-readable contract for this pass lives in
`design/screens/catch.screens.json` under `screen.event.detail`.

## Source Inputs

| Source | Role |
|---|---|
| `/Users/suvratgarg/Downloads/Catch Design System (2)/templates/catch-event-detail/EventDetail.dc.html` | Canonical Claude Design screen composition. |
| `/Users/suvratgarg/Downloads/Catch Design System (2)/components/events/*.d.ts` | Claude event primitive prop contracts. |
| `lib/events/presentation/event_detail_screen.dart` | Route-level screen and initial provider state handling. |
| `lib/events/presentation/widgets/event_detail_body.dart` | Current composition shell, mutation listeners, visibility decisions, private host/companion/invite sections, and bottom dock selection. |
| `lib/events/presentation/widgets/event_detail_design_primitives.dart` | Current event-specific primitives that mostly map to Claude event components. |
| `test/ui_captures/catalog/screen_capture_catalog.dart` | Existing Event Detail route captures. |

## Current Organization

`EventDetailScreen` is already close to the target route boundary: it records
invite-link opens, watches `eventDetailViewModelProvider`, handles loading,
fatal error, and not-found states, and delegates populated rendering to
`EventDetailBody`.

`EventDetailBody` is the main migration target. It currently:

- Chooses light, white-ticket, or dark surface style.
- Derives whether consumer actions should show.
- Watches save/share/calendar mutations and external controllers.
- Registers booking/cancel mutation listeners.
- Chooses guest/member/no bottom navigation.
- Builds the hero, ticket band, overview sections, companion prompt, invite
  prompt, hosts, social/reviews, and booking dock.
- Performs route navigation and snackbar side effects from private helpers.

The screen can be migrated incrementally by first creating explicit section
view data and then moving visual sections out of `EventDetailBody`.

## Claude To Flutter Section Map

| Target section | Claude component(s) | Current Flutter source | Current status | Migration note |
|---|---|---|---|---|
| Event hero | `EventHero` | `EventDetailHeroAppBar` | Implemented locally | Register hero states: saved, save pending, calendar available, ticket, spotlight dark. |
| Ticket fact band | `TicketStub` | `EventDetailTicketStubBand` | Implemented locally | Convert from whole-`Event` input to explicit cells. Keep event-derived cells in adapter code. |
| The plan | `Section` | `EventDetailOverviewSection` private description block | Implemented locally | Promote to a section with explicit title/body view data. |
| Why you might click | `HintList` | `EventDetailHintList` | Implemented locally | Convert from event-derived internal hints to explicit hint rows. |
| Itinerary | `Itinerary` | `EventDetailItinerary` | Implemented locally | Convert from event-derived internal steps to explicit step rows. |
| Photo proof strip | `PhotoStrip` | `EventDetailPhotoStrip` | Implemented locally | Convert to explicit cells, caption, and right data line for app, website, and social reuse. |
| Your hosts | `HostCard` | `_EventDetailHostsSection` plus `EventDetailHostCard` | Implemented locally | Move `fetchClubProvider` lookup out of visual section; pass host view data and intents. |
| Who's going | `AvatarStack` | `EventDetailSocialSection`, `WhoIsGoing`, `_GuestWhoIsGoing` | Implemented locally | Split guest-locked and member-visible states. |
| Where | `MapCard` | `EventDetailMapCard` | Implemented locally | Convert event-derived note/pill state into explicit props and define visual-diff masks. |
| How sign-ups work | `MechanismList` | `EventDetailMechanismList` | Implemented locally | Convert mechanism rows to explicit row data. |
| Good to know | `Section` | `_WhatToExpectSection`, `_EventPolicySummary`, `RequirementsRow` | Implemented locally | Keep policy derivation in adapter state, visual rows become lower-level components. |
| Companion/invite prompts | `Section` | `_EventCompanionEntry`, `_EventInviteLoopCard` | Implemented locally | Move event-success plan lookup and invite visibility into screen/controller state. |
| Booking dock | `BookingDock` | `EventDetailCta`, `_GuestBookCta` | Implemented locally | Create a booking-dock view model for price, CTA, note, pending, booked, waitlist, full, cancelled, and past modes. |

## State Coverage

| State | Current proof | Gap |
|---|---|---|
| Loading | `EventDetailScreen` loading branch and widget tests | No capture/preview. |
| Not found | `CatchErrorScaffold` branch and widget tests | Needs decision: branded error surface vs dedicated empty event state. |
| Fatal error | `CatchErrorScaffold.fromError` branch and widget tests | Needs preview/capture, including offline-looking errors. |
| Authenticated member | `event_detail_member` capture | Needs section contract mapping before visual edits. |
| Ticket mode | `event_detail_member_ticket` capture | Needs Widgetbook hero/stub states. |
| Spotlight dark | `event_detail_member_spotlight` capture | Needs Claude comparison and dark-state section previews. |
| Guest | Widget tests only | Needs capture and BookingDock/locked social state preview. |
| Host app | Controller/widget tests only | Needs host route capture and explicit host section decision. |
| Booking pending/failed | Widget tests | Needs BookingDock contract states. |
| Waitlist/sold out/cancelled/past | Widget tests | Split into independent dock states after adapter exists. |
| Offline | Not explicit | Define via error surface contract and add capture. |
| Text scale/reduced motion | Not explicit | Add after section adapters reduce layout drift. |

## First Implementation Slice

1. Register event detail screen composition in `design/screens/catch.screens.json`.
2. Validate route ids, captures, Flutter symbols, state ids, section ids, and
   component dependencies with `tool/design/check_screen_contracts.mjs`.
3. Add Widgetbook entries for the event primitives already present in Flutter:
   `EventDetailTicketStubBand`, `EventDetailHintList`, `EventDetailItinerary`,
   `EventDetailMapCard`, `EventDetailMechanismList`, `EventDetailPhotoStrip`,
   `EventDetailHostCard`, `EventDetailHeroAppBar`, and `EventDetailCta`.
4. Refactor `EventDetailBody` by extracting an adapter/view-state layer before
   changing visuals.

## Widgetbook Coverage Added

The first Widgetbook pass added `[Core catalog]/Event detail` entries for:

- `EventDetailHeroAppBar`
- `EventDetailTicketStubBand`
- `EventDetailHintList`
- `EventDetailItinerary`
- `EventDetailPhotoStrip`
- `EventDetailMapCard`
- `EventDetailMechanismList`
- `EventDetailHostCard`
- `EventDetailCta / BookingDock states`

The booking dock entry is deliberately representative: it uses the lower-level
`CatchBottomCta` and public Event Detail leading widgets because production
`EventDetailCta` still watches booking/payment providers directly. A true
provider-free `BookingDock` adapter remains part of the next refactor.

The second Widgetbook pass added `[Event Detail]/Sections` entries for:

- `EventDetailOverviewSection`
- `EventDetailSocialSection` / Claude `AvatarStack` states.
- `EventReviewsSection`
- `EventDetailBody` companion and invite prompt states.
- `EventBookingDock` provider-free booking states.

Remaining Event Detail gaps:

- Move host lookup, companion lookup, visibility derivation, and booking dock
  mode derivation into adapter/controller state.
- Add route captures for guest, host-app, offline, text-scale,
  reduced-motion, and individual booking states.
- Compare stable captures against Claude references before visual refactors.

## Do Not Do Yet

- Do not tune pixels before the section contracts and previews exist.
- Do not move event-derived copy into generic components; generic components
  should receive explicit rows/cells/view data.
- Do not make the screen contract a substitute for component contracts. The
  screen registry tells us what must be composed; component and section
  contracts still own reusable APIs.
