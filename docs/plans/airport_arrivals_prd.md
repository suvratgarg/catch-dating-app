---
doc_id: airport_arrivals_prd
version: 0.1.0
updated: 2026-09-22
owner: product
status: draft
---

# Airport Arrivals Coordination — Product Requirements

Working name: **Arrivals Desk**. Name is provisional; this document owns the
product requirements, not the brand.

## Problem

For Indian destination weddings and corporate events, airport pickup is run
by a person with a clipboard at the arrivals exit. The clipboard holds a
manifest: guest names, flight numbers, arrival times, and hotel assignments.
Everything else is improvised:

- **Flight status is tribal knowledge.** Delays, cancellations, and actual
  landing times are checked by hand on Google or an airline site, per guest,
  repeatedly. Landing time is not curb time — immigration and baggage add a
  lag nobody tracks explicitly.
- **Batching is mental arithmetic.** Guests landing within a similar window
  and going to the same hotel should share a vehicle. Doing this live, on
  paper, across hundreds of guests arriving over 2–4 days means vehicles
  leave half-empty and guests wait at the curb.
- **Vehicles come from multiple subcontractors.** A premium SUV (e.g., an
  Innova) bills differently from a sedan, and hotels sit at different
  distances from the airport. Reconciling each vendor's claimed trips,
  vehicle classes, and routes against what actually happened is a
  multi-day post-event argument.
- **Hotels are blind.** The reception team learns guests have arrived when
  20 people walk in at once. Room blocks can't be sequenced, so guests mill
  around the lobby while keys are sorted.

The planner pays for all of this in staff headcount, idle vehicles, vendor
disputes, and a bad first hour of the guest experience.

## Product thesis

Replace the clipboard with a **shared, live arrivals roster** that runs on
the phones and tablets the team already carries:

1. The manifest lives in the system, enriched automatically with live flight
   status.
2. The system proposes vehicle groups by arrival-window × destination-hotel
   and suggests a vehicle class; humans can override everything.
3. Every dispatch records the actual taxi plate and vendor, producing a
   reconciliation ledger as a byproduct of doing the work.
4. The same live state is visible at the hotel desk, so inbound ETAs and
   room sequencing are known before the vehicle arrives.

Catch already operates events infrastructure: phone-first auth, organizer
roles, Firestore real-time sync, callable-owned mutations, and Google Maps
integration. This feature is a new **organizer vertical** (wedding and
corporate event planners) built on that substrate. It does not depend on the
dating graph, clubs, or consumer booking flows.

## Goals / non-goals

### Goals

- One shared source of truth for "who is arriving, when, and going where,"
  live-synced across planner, greeter, and hotel-desk surfaces.
- Live flight tracking (delays, landed, cancelled, diverted) without manual
  checking.
- A **curb ETA** per guest: estimated/actual landing time plus a
  configurable exit lag, so the roster answers "when do they walk out," not
  "when do wheels touch."
- Assisted grouping: suggested vehicle batches by time band and
  destination, with vehicle-class suggestion — every suggestion manually
  overridable.
- One-tap dispatch capture: taxi plate number, vendor, vehicle class,
  departure time — the act of loading a car produces the reconciliation
  record.
- Hotel-side inbound view with live transit ETAs and room-block sequencing.
- Vendor reconciliation report: trips × route × vehicle class × pax,
  rate-card estimate, export.

### Non-goals (v1)

- Guest-facing app or guest notifications (WhatsApp/SMS updates are a later
  phase; guests are roster entries in v1, not users).
- Driver or vendor self-service portal. Vendors are managed entities, not
  signed-in users.
- Departure leg (hotel → airport drops after the event). Nearly symmetric
  to arrivals and deliberately deferred — see Phasing.
- Payments, vendor billing settlement, or guest payment of any kind.
- Route optimization across multiple stops; vehicles run airport → single
  hotel.
- Multi-event concurrent operations for one planner (v1 assumes one active
  event per planner team at a time).

## Users and surfaces

| Persona | Who | Surface | What they do |
|---|---|---|---|
| Planner admin | Wedding planner / corporate event ops lead | Planner console (web or host app) | Create event, import manifest, configure airports/hotels/vendors/rate cards, watch live ops, reconcile |
| Greeter | Temp staff at arrivals exit ("the clipboard person") | Greeter roster (phone/tablet, outdoor-readable) | Track incoming guests, claim/greet, adjust groups, dispatch vehicles, capture plate numbers |
| Hotel desk | Welcoming-team member at each hotel | Desk view (tablet/phone) | See inbound vehicles/guests with ETAs, sequence room blocks, mark arrivals |
| Vendor | Taxi/coach subcontractor | None in v1 | Configured entity: name, fleet, rate card, contact |
| Guest | Event attendee | None in v1 | Manifest entry; carried through the state machine by staff actions |

Multiple greeters work simultaneously (different terminals/exits); multiple
hotels each run their own desk view. All surfaces share one live event
state.

## Core concepts

### Event

A multi-day organizer event (wedding, offsite, conference) with:

- One or more arrival airports (v1: typically one; model must not assume
  exactly one) and optional per-terminal notes.
- One or more **hotels**, each with: name, address, drive-time distance
  from each airport, room blocks (named block + room count).
- A **staff roster**: planner admins, greeters, hotel-desk members,
  each scoped to the event (hotel-desk scoped per-hotel).
- **Grouping policy**: time-band window (default 45 min), max guest wait
  tolerance, vehicle-class table, exit-lag defaults.

### Guest manifest entry

| Field | Notes |
|---|---|
| Guest name | Required; display name for signage/board lookup |
| Party size | Adults/kids; drives capacity math |
| Family/party ID | Keeps people travelling together in one group |
| Phone | Optional; for staff contact, not guest messaging in v1 |
| Flight number + arrival date | Optional — supports road/train/manual arrivals ("ground entry" with manual ETA) |
| Hotel assignment | Required for batching; "custom destination" allowed via override |
| Room block | Optional; feeds hotel desk sequencing |
| Flags | VIP (dedicated vehicle), elderly/wheelchair assist, extra luggage (capacity bump) |
| Notes | Free text |

Import paths: CSV template upload, paste-from-Excel/WhatsApp table parsing,
and manual entry. Manifests of 100–500 guests must import without staff
needing to retype. Edit and dedupe (same person listed twice, name
variants) happen in the planner console.

### Flight tracking

Each manifest entry with a flight number + date resolves to a tracked
flight:

- Status: `scheduled → departed → landed`, plus `delayed`, `cancelled`,
  `diverted` as overlaying states; scheduled vs estimated vs actual times
  kept distinct.
- Terminal/arrival info where the API provides it.
- **Curb ETA** = max(scheduled, estimated, actual landing) + exit lag.
  Exit lag defaults: domestic ≈ 25 min, international ≈ 60 min;
  planner-adjustable per flight or per event.
- Polling cadence ramps with proximity (e.g., hourly at T-24h, ~15 min at
  T-3h, tightest once airborne), subject to the provider's push/webhook
  capability — see Integrations.
- Cancellation/diversion/reschedule surfaces as an **exception card** on
  the roster and a planner alert, not a silent status change.

### Vehicles, vendors, dispatch

- **Vendor**: subcontractor; has a fleet (vehicle classes, optional plate
  registry) and a **rate card** (price per trip by vehicle class ×
  destination hotel, or per vehicle-day — model must support both).
- **Vehicle class**: ordered table e.g. sedan (≤4 pax) → SUV/Innova (≤6)
  → tempo traveller (≤14) → coach (≤40), planner-editable per event.
- **Dispatch** (the atomic record): guests[], destination, suggested vs
  actual vehicle class, taxi plate number, vendor, driver name/phone
  (optional), departed_at, Maps transit ETA, arrived_at, status.
  Everything except guests[]+destination is overridable at capture time;
  nothing else about the record is required to be "correct" in advance —
  the point is to record reality.

## Guest lifecycle

```text
scheduled ──→ en_route ──→ landed ──→ greeted ──→ grouped ──→ dispatched ──→ arrived ──→ checked_in
                │                                                    
   overlays: delayed · cancelled · diverted · rescheduled
   exceptions: no_show (landed, not found) · self_transport · split_party · wrong_terminal
```

- Transitions `scheduled→landed` are driven by the flight provider.
- `greeted` onward are human actions on the greeter/hotel surfaces.
- Every transition is timestamped and attributed (which staff member) —
  this is what makes downstream reconciliation and post-event reporting
  trustworthy.
- `self_transport` and `no_show` are terminal states that still reconcile
  (vendor claims can't invent trips for guests who never boarded).

## Surface requirements

### 1. Planner console

- **Setup wizard**: event dates, airport(s), hotels (+drive time, room
  blocks), vendors (+fleet, rate cards), staff invites, grouping policy.
- **Manifest management**: import (CSV/paste), review, dedupe, per-guest
  edit, bulk hotel assignment.
- **Live ops board**: event-level summary — guests landed/not-yet/
  dispatched/arrived counts, active dispatches with ETAs, open exceptions,
  per-hotel inbound queue. Same data as greeter view, aggregated.
- **Reconciliation**: per vendor — trips, vehicles used, classes, routes,
  pax carried, rate-card estimate; flag variance vs vendor invoice;
  export CSV/PDF. Available live during the event, final at closeout.
- **Event closeout**: final manifest state, exception list, recon export,
  retention/anonymization policy trigger.

### 2. Greeter roster (primary surface)

Design constraint: used standing up, outdoors, one-handed, on flaky
airport connectivity, by temporary staff who may have installed nothing
before their shift.

- **Live board**: roster sorted by curb ETA, grouped into bands
  ("arriving now", "~20 min", "~45 min", "later"). Each row: guest name,
  party size, flight number, status badge (on time / +35 min delayed /
  landed 12 min ago / cancelled), curb ETA, hotel tag, flags (VIP,
  assist).
- **Search/board lookup**: guest walks up and says a name — fuzzy search
  across the manifest, then "greet" in one tap.
- **Claim**: a greeter marks "I've got them" so a second greeter at
  another exit doesn't duplicate; claims are visible to all staff.
- **Suggested groups**: system proposes batches = same hotel × curb-ETA
  within the time band, capped by vehicle class capacity, party integrity
  preserved, VIPs forced to dedicated vehicles. Each suggestion shows the
  recommended vehicle class and fill (e.g., "Innova · 5/6").
- **Manual overrides at every step**: move guest between groups, merge,
  split, change hotel/destination, change vehicle class, hold a group
  ("waiting on one more"), un-greet. Overrides never block on the
  suggestion engine.
- **Dispatch capture**: when the group physically boards — enter taxi
  plate (fuzzy-matched against vendor fleet registry when available),
  confirm/adjust vendor + vehicle class, optional driver phone, tap
  "departed." The group becomes a live dispatch with a Maps transit ETA
  shared to the hotel desk.
- **Exception actions**: mark no-show (with reason), mark self-transport,
  re-queue a guest whose flight was cancelled/rescheduled, split a party.
- **Offline tolerance**: reads cached; writes (greet, claim, dispatch)
  queued locally and synced with conflict resolution. A greeter must
  never lose a dispatch because the terminal concourse has no signal.

### 3. Hotel desk view

- **Inbound queue per hotel**: live list of dispatched vehicles heading
  to this hotel — plate, vehicle class, pax count, guest names, transit
  ETA (from Maps), departure time.
- **Arrival alerts**: heads-up when a vehicle is ~15 min out.
- **Room sequencing**: guests per inbound vehicle grouped by room block;
  desk marks rooms ready / guests checked-in per dispatch.
- **Expected-not-dispatched**: guests landed but not yet in a vehicle
  ("still at airport"), so the desk doesn't wonder where they are.

## Grouping and vehicle suggestion logic

Deterministic, inspectable, and always overridable:

1. Partition un-dispatched guests by destination (hotel or custom).
2. Within a destination, order by curb ETA and sweep a configurable time
   band (default 45 min, planner-tunable per event — the core trade-off
   between guest wait and vehicle utilization).
3. Within a band, split into vehicles: keep parties together, respect
   capacity (pax + luggage flags), prefer the smallest class that fits,
   prefer fewer vehicles; VIPs always get a dedicated vehicle regardless
   of fill.
4. Emit suggestions with rationale shown inline ("3 guests, same hotel,
   landings within 20 min → 1 sedan"). The greeter accepts, edits, or
   ignores.

The engine never auto-dispatches; it only proposes. Every dispatch is a
human decision that produces a durable record.

## Integrations

- **Flight data provider** (decision pending — see Open Questions):
  requirements are India-first coverage (IndiGo, Air India group, Akasa,
  plus international carriers into Indian airports), flight-number+date
  resolution, estimated/actual landing times, terminal data, cancellation/
  diversion signals, and either webhooks or affordable polling at
  ~hundreds-of-flights scale per event. Candidates to evaluate:
  FlightAware AeroAPI, AeroDataBox, AviationStack, VariFlight.
- **Google Maps / Routes API**: airport→hotel transit ETAs per dispatch
  and per-hotel drive-time config. Catch already integrates Google Maps;
  reuse the existing location stack rather than a second provider.
- **Auth/staff invite**: event-scoped staff access. Open question whether
  temp greeters use phone auth, an event PIN link, or a lightweight PWA
  session — see Open Questions.

## Non-functional requirements

- **Connectivity**: airport-terminal-grade. Roster readable offline;
  writes queued; sync conflicts resolved last-writer-wins for status,
  append-only for dispatch records. Dispatch must be impossible to lose.
- **Concurrency**: N greeters × M hotel desks × planner on one event
  state; claims and dispatch records prevent double-handling.
- **Device/UX**: phone + tablet, sunlight-readable contrast, large type
  and tap targets, minimal typing (search, not forms, at the curb),
  battery-conscious polling, landscape tablet for hotel desk.
- **Privacy**: manifests are PII (names, phones, flights, hotels). Access
  is event-scoped by role; hotel desk sees only its hotel's guests;
  retention and post-event anonymization policy defined before launch.
- **Localization**: English v1; Hindi (and bilingual signage strings) on
  the roadmap.
- **Scale**: single event ≈ hundreds of guests, tens of concurrent staff,
  hundreds of flight-track-days; design should not preclude thousands.

## Success metrics

- Guest curb wait: greeted → dispatched time (target: median < 20 min).
- Vehicle fill rate and empty-dispatch rate vs pre-launch baseline.
- % of groups accepted as-suggested vs manually edited (engine quality).
- Vendor reconciliation effort: days of dispute → a report plus variance
  review; % of vendor-invoiced trips match recorded dispatches.
- Hotel check-in wait for inbound batches.
- Flight status freshness lag (provider → roster) and curb-ETA accuracy.
- Staff effort: actions per guest; greeter onboarding time (<10 min for
  temp staff is the bar).

## Architecture fit

- **Surfaces**: planner console fits the existing React admin/host-web
  pattern or the host app; greeter + hotel desk are new role-scoped
  surfaces — likely a separate lightweight Flutter entrypoint or PWA
  (decision pending) given temp-staff install friction.
- **State**: Firestore real-time listeners are a natural fit for the
  shared roster; dispatch/greet/claim mutations go through callable
  Functions per the existing write-ownership rules.
- **Data**: new event-scoped collections (manifest, flights, dispatches,
  vendors, staff) must go through the contracts pipeline and
  `docs/data_contracts.md` alignment, not ad-hoc client writes.
- **Flight polling**: scheduled Functions + provider webhooks; provider
  credentials via Functions secrets.

## Phasing

- **P0 / MVP**: planner setup + manifest import; greeter roster with live
  flight status and curb ETA; manual grouping with suggestion engine v1;
  dispatch capture (plate, vendor, class); hotel inbound view (read-only
  ETAs); basic reconciliation report. Single airport exercised end-to-end.
- **P1**: fleet registry + plate auto-match; rate-card variance recon;
  room-block allocation at desk; WhatsApp/SMS guest + staff notifications;
  multi-greeter claims hardening; Hindi strings.
- **P2**: **departure leg** (hotel→airport drops — nearly symmetric and
  the obvious next thing a wedding planner asks for); vendor portal or
  driver QR confirmation; multi-airport polish; settlement export to
  accounting.

## Open questions

1. **Surface**: standalone PWA vs role in the Catch host app vs separate
   Flutter entrypoint. Temp greeter install friction argues for PWA;
   offline requirements argue for a real app. Needs a decision before
   build.
2. **Staff auth**: phone auth per staff member vs event PIN + role links.
   PIN links are lower-friction for temp staff but weaker on audit
   attribution.
3. **Flight provider**: coverage/cost/push-capability spike required
   before committing; India domestic coverage is the deciding factor.
4. **Product boundary**: is this Catch-branded (organizer tools) or a
   distinct product surface sharing infrastructure? Affects console
   placement and pricing.
5. **Business model**: per-event flat fee, per-guest, or bundled into an
   organizer subscription — out of scope here but shapes the console.
6. **Guest comms**: do guests get pickup instructions/driver details by
   WhatsApp in P1, and does that require their consent at manifest import?
7. **Retention**: how long is manifest PII kept post-event, and who can
   export it?

## Edge cases to design for

- Guest lands but never exits (met family, wrong terminal, medical) —
  no-show with reason, not a silent drop.
- Same name twice on a manifest; same person twice under variant names.
- Flight rescheduled to next day — guest stays on roster, doesn't fall off
  at midnight.
- Party splits across flights; party members arrive on different days.
- Guests with no flight (road/train) mixed into the same roster.
- Taxi plate doesn't match any registered fleet — still record it, flag
  for recon.
- Two greeters dispatch overlapping groups simultaneously — server-owned
  dispatch records, no double-counted trips.
- Vehicle dispatched but turns back / guest removed at the curb —
  dispatch void with reason, kept in the ledger.
- International guests with no Indian number — no dependency on guest
  phone in v1.
