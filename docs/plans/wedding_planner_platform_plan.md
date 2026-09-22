---
doc_id: wedding_planner_platform_plan
version: 1.0.0
updated: 2026-09-22
owner: product
status: active
---

# Catch Host for Wedding Planners — Product & Architecture Plan

Status: approved plan, not yet implemented. Delivery slices W0–W5 in §8 are the backlog. Companion: `airport_arrivals_prd.md` on branch `codex/airport-arrivals-prd-20260922` owns the arrivals/transport vertical; this document owns the wedding program layer, roles, Moments and monetisation.

---

## 0. TL;DR

- The airport thread has already introduced the right container: a private
  **Program** (`organizerPrograms`) with **Functions** (`programFunctions`),
  **Guests/Households**, and **duty-scoped staff grants**. Build weddings on
  that, not on `events`. The `events` document is a public, social-dating
  object with 30+ required discovery/cohort fields; it must not be the
  wedding root.
- Three things in that worktree need correcting before more UI lands:
  (1) RSVP is stored per **program** but weddings need RSVP per **function**;
  (2) `programFunctions` has no invited-guest subset, dress code, or
  check-in; (3) the duty enum is transport-only, so "door", "RSVP desk",
  "comms" and "family viewer" roles have nowhere to live.
- We now have **three** staff-authority systems (`organizerTeamMemberships`,
  `eventStaffGrants`, `programStaffGrants`). Keep the storage separate, but
  put **one** client-facing concept over them: a `HostWorkAssignment`
  (scope + duties) served by one `listMyHostAssignments` callable and one
  `HostWorkShell`. Migrate `eventStaffGrants.role/permissions` to the same
  duty-union shape so a mixer door person and a wedding door person are the
  same job.
- The "calendar integration" in the consumer app is only an add-to-device-
  calendar method channel. What weddings need is a **server-side schedule
  engine** ("Moments"): rules anchored to `function.startsAt` /
  `travelLeg.curbEta` with offsets, audiences and actions, materialised into
  due-at jobs that re-plan when the function moves. Nothing like this exists;
  `organizerCampaigns.scheduledAt` (absolute, one-shot) and form automations
  (response-triggered) are the closest pieces to reuse for delivery.
- Monetisation: there is **no** billing/entitlement concept anywhere in the
  contracts. Recommend per-program pricing tiered by guest count with
  metered add-ons (transport/flight tracking, WhatsApp volume), gated by a
  new `organizerEntitlements` doc and a capability snapshot on the program.
  Pilot with manual invoicing + admin-flipped entitlements; self-serve later.

---

## 1. Measured starting point

### 1.1 Host app as shipped (main)

| Thing | Fact | Source |
|---|---|---|
| Shell | Fixed 5-branch `StatefulShellRoute.indexedStack`: Today, Events, Audience, Inbox, Organizer. All manager providers (unread count, operable clubs, FCM) mount unconditionally. | `lib/core/presentation/host_app_shell.dart`, `lib/routing/go_router.dart:901` |
| Event time model | `events` requires `startTime`/`endTime` only — one contiguous span. Also requires `meetingPoint`, `startingPointLat/Lng`, `pace`, `distanceKm`, `genderCounts`, `cohortCounts`, 13 `discovery*` fields. | `contracts/firestore/events.schema.json` |
| Event workspace | `HostEventManageSection { setup, guests, live, report }`; lifecycle picks one phase. | `lib/hosts/presentation/host_event_manage_screen_state.dart` |
| Org authority | `organizerTeamMemberships.role ∈ {owner, manager}` — org-wide only. | `contracts/firestore/organizer_team_memberships.schema.json` |
| Event staff | `eventStaffGrants.role ∈ {checkInOperator, eventOperator}`, `permissions ⊆ {viewRoster, setAttendance, reviewRuntimeClaims, publishLiveLocation}`, 14-day expiry, 50/event. Restricted route `/host/operator/:eventId`. | `contracts/firestore/event_staff_grants.schema.json`, `docs/host_product.md:643` |
| Roster | `eventAttendees` is the one operational roster (`status ∈ invited/registered/waitlisted/checkedIn/cancelled`, `source`, `arrivalGroup`, import provenance). Attendance outbox exists for offline check-in. | `contracts/firestore/event_attendees.schema.json`, `lib/hosts/data/host_attendance_outbox.dart` |
| Forms | Versioned forms, responses, reviewed conversion; targets are organizer/event/campaign. | `docs/host_forms.md`, `functions/src/organizers/organizerForms.ts` |
| Messaging | `organizerCampaigns` (WhatsApp/SMS via connected sender, saved-audience recipients, `scheduledAt` absolute one-shot, preview→approve→dispatch). Event-assistance operational notices for plan changes. | `contracts/firestore/organizer_campaigns.schema.json` |
| Automations | `organizer_form_automation_rules/runs` — triggered by form responses, not by time. | `contracts/firestore/organizer_form_automation_rules.schema.json` |
| Calendar | Consumer-only `MethodChannel('catch/calendar').addToCalendar(title, description, location, start, end)`. No scheduling logic. | `lib/events/data/event_calendar_links.dart` |
| Late arrivals | `eventSuccessLateArrivals` is a *pairing* re-slot for Event Success rounds, not a logistics concept. | `contracts/firestore/event_success_late_arrivals.schema.json` |
| Money | Consumer ticket checkout (`payments`, Stripe). No organizer billing, subscription, entitlement or invoice concept. | `contracts/firestore/payments.schema.json` |

### 1.2 Airport thread (worktree `airport-arrivals-prd-20260922`, not merged)

Landed on that branch: PRD + architecture (`docs/plans/airport_arrivals_prd.md`),
pure grouping/timing policy (`functions/src/transport/`), contracts + rules +
generated types for `organizerPrograms`, `programFunctions`, `programGuests`,
`programHouseholds`, `programStaffGrants`, `programPickupPoints`,
`programHotels`, `programTravelLegs`, `programTravelParties`,
`transportVendors`, `transportTrips`, `transportActiveAssignments`,
`transportOperationReceipts`, and a first batch of program/dispatch callables.
No client routes, no shell, no UI.

Shapes that matter for this plan:

```
organizerPrograms: kind ∈ {wedding, corporate, social, other}, title, timezone,
  startsAt, endsAt, status ∈ {draft, active, completed, archived},
  capabilities ⊆ {arrivalsTransport, accommodation, forms, messaging},
  transportSettings{vehicleClasses[], ...}, revision
programFunctions: programId, name, startsAt, endsAt, venueName, venueNotes,
  status ∈ {scheduled, completed, cancelled}, revision
programGuests: displayName, householdId?, contactId?, phone?, email?,
  invitationStatus ∈ {notInvited, invited, delivered, responded},
  rsvpStatus ∈ {pending, attending, declined, maybe}, source
programHouseholds: label, primaryContact*, memberGuestIds[], deliveryPreference
programStaffGrants: duties[] where duty ∈ {programCoordinator, airportGreeter,
  hotelDesk, transportDispatcher, reconciliationViewer} each with scoped ids
```

**Assessment.** The container choice (private Program, not a public Event) is
correct and I would not reopen it. The gaps are all in the *general wedding*
layer the airport thread deliberately deferred (its "A6/A7/A8" slices):

| Gap | Why it blocks the wedding product | Fix |
|---|---|---|
| `rsvpStatus` lives on the guest, program-wide | Guests come to the reception but skip the mehendi. Headcount per function is the planner's #1 number. | Add `programFunctionGuests/{functionId_guestId}` = {invited, rsvp, attendance}. Keep `programGuests.rsvpStatus` as a *derived* rollup (any attending → attending) or drop it. |
| `programFunctions` has no guest subset / dress code / instructions / check-in | The PRD text promises "function-level invitations" and "dress-code/instructions"; the schema doesn't. | Extend the schema: `dressCode`, `instructions`, `venueLocation` (coords via existing `LocationCoordinate`), `invitationMode ∈ {allGuests, selectedGuests}`, `checkInEnabled`, `expectedCount`/`checkedInCount` rollups. |
| Duty enum is transport-only | Door check-in, RSVP desk, comms, venue lead and family read-only view have no duty. | Widen the duty union (section 5). |
| Two staff-grant systems with different shapes | A person working the door of a wedding function and a person working the door of a mixer are the same job with two schemas, two callables, two shells. | One client concept over both (section 5.3). |
| No time-anchored automation | "15 minutes before the sangeet, message attending guests" has no home. | Moments engine (section 4). |
| No billing | Can't sell it. | Entitlements (section 7). |

---

## 2. Domain model

### 2.1 Target hierarchy

```
Organizer (planner firm, or a social host)                    existing
 ├─ organizerTeamMemberships (owner/manager)                  existing, unchanged
 ├─ organizerEntitlements                                     NEW (billing, §7)
 ├─ Event (public/social, single span)                        existing, unchanged
 │    └─ eventAttendees, eventStaffGrants, Event Success…     existing
 └─ Program (private, multi-day)                              airport branch
      ├─ programFunctions (the schedule)                      airport branch, EXTEND
      │    └─ programFunctionGuests (invite/rsvp/attendance)  NEW
      ├─ programGuests / programHouseholds                    airport branch
      ├─ programStaffGrants (duties)                          airport branch, WIDEN
      ├─ programMoments (schedule rules) + programMomentRuns  NEW (§4)
      ├─ travel / hotels / transport / vendors / trips        airport branch
      └─ programStays / programRoomBlocks                     airport branch (deferred A7)
```

Rules that keep it tidy:

1. **A Function is not an Event.** A function is a private schedule item with
   its own invitation subset and attendance. It never creates an `events`
   document. If a specific function later needs Event Success (e.g. a
   singles-mixer sangeet), add an explicit `programFunctions.eventId` bridge
   and a reviewed projection — not the default.
2. **Guest identity is one record per person**; household is invitation/RSVP
   delegation; travel party is ride-together. These are three relationships,
   not one. (Already the airport branch's rule — keep it.)
3. **Attendance is per function; readiness is per travel leg; stay is per
   hotel night.** A landing never checks anyone into anything.
4. **CRM is optional.** `programGuests.contactId` may be null forever. Do not
   auto-create `organizerContacts` from a wedding import; that is the "private
   data is not growth consent" rule from `docs/host_product.md`.
5. **Program capabilities are the feature flags**; entitlements (billing) set
   which capabilities the organizer may enable; grants (duties) set who may act.

### 2.2 Conflicts / duplication found

| Where | Problem | Recommendation |
|---|---|---|
| `programGuests.rsvpStatus` vs per-function RSVP | Two truths once `programFunctionGuests` exists. | Make guest-level a rollup or remove; server writes only the per-function doc. |
| `programFunctions.status ∈ {scheduled, completed, cancelled}` vs `programs.status ∈ {draft, active, completed, archived}` | "completed" for a function should be derived from `endsAt < now` unless manually closed. Don't force staff to click "complete" on 9 functions. | Derive display phase from time like `hostEventWorkspacePhaseFor` does for events; keep stored status for cancellation only. |
| `eventStaffGrants` (role+permissions) vs `programStaffGrants` (duty union) | Same concept, two shapes, two callables, two restricted routes. | One domain type `HostWorkAssignment{scope: event(eventId)|program(programId), duties[]}`; one `listMyHostAssignments`; one `HostWorkShell`. Storage stays as-is; the DTO expresses `checkInOperator` as `functionCheckIn` and `eventOperator` as `eventLead`. |
| `eventAttendees.arrivalGroup` (free string) vs `programTravelParties` | Both mean "arrive together". | Leave `arrivalGroup` for social events; never read it for programs. |
| `host_attendance_outbox.dart` (SharedPreferences, trims overflow) vs required durable dispatch outbox | Airport PRD is right that this storage policy is unsafe for dispatch. | One new durable command journal also used by function check-in for programs; migrate the event attendance outbox onto it later, don't build a third. |
| Campaign recipients require `savedAudienceId` from CRM | Wedding recipients are function invitees, not saved audiences. | Add a `recipientSource` union to campaigns: `savedAudience | programSelection{programId, functionId?, rsvp?, householdDedupe}`. Airport PRD §8 says the same. |
| `events.startTime/endTime` single span | Not a conflict once programs exist — leave events alone. | Do **not** add `programId`/multi-day to `events`. |

---

## 3. Feature inventory (wedding lifecycle)

Legend: **R** reuse as-is · **E** extend existing · **N** new · **branch** = airport worktree

### Stage A — Set up the program (T-6 to T-2 months)
| Feature | Notes | Status |
|---|---|---|
| Create program with wedding preset | kind=wedding; preset seeds typical functions (Mehendi, Haldi, Sangeet, Baraat/Ceremony, Reception), dress codes, RSVP template, save-the-date template. | N (contract on branch) |
| Functions schedule editor | Multi-day timeline; per-function venue (Places lookup), dress code, invitation mode, check-in on/off. | N |
| Guest import (CSV/XLSX/paste) with household detection | Reuse `host_roster_file_parser.dart` + server preview/commit pattern from `eventAttendees` imports; new column semantics (household, side, city, plus-one slots). | E |
| Households & sides | `side ∈ {partnerA, partnerB, mutual}` label configurable; used for counts. | E (add to `programHouseholds`) |
| Team & duties | Assign staff by phone-auth account; duties scoped to functions / pickup points / hotels. | N (grants on branch) |

### Stage B — Invite & collect (T-3 months to T-2 weeks)
| Feature | Notes | Status |
|---|---|---|
| Save-the-date | Campaign with `recipientSource=programSelection`, household de-dupe, template variables. | E |
| Invitation per function or bundle | Same mechanism; "you're invited to Sangeet + Reception". | E |
| Private RSVP page (web) | Household-scoped signed link; respondent ticks attending per person per function; travel details; dietary/accessibility; +1 slots. Not the public form page. | N (website) |
| RSVP review & conversion | Response is evidence; reviewed conversion writes `programFunctionGuests` + `programTravelLegs`. Reuse form conversion receipt pattern. | E |
| RSVP reminders | Moment rule: `anchor=rsvpDeadline, offset=-7d, audience=households pending`. | N (§4) |
| Headcount dashboard | Per function: invited / attending / declined / pending / expected pax incl. kids; per side; per hotel. | N |
| Wardrobe / dress code planner | Per function dress code + optional palette + reference images; delivered as "what to wear" T-1d. Content on the function, not a new aggregate. | E |
| Guest itinerary (.ics + web) | Household page shows only functions they're invited to; server-generated `.ics`/webcal feed. | N |

### Stage C — Logistics (T-2 weeks to T-1 day)
| Feature | Notes | Status |
|---|---|---|
| Travel legs & flight enrichment | | branch A3/A4 |
| Hotels, room blocks, stays | | branch A7 |
| Transport vendors, vehicle classes, rate cards | | branch |
| Staff shift plan | Add optional `shift{startsAt,endsAt}` per duty so the assignment picker shows "your shift". | E |

### Stage D — Run the days (T-0)
| Feature | Notes | Status |
|---|---|---|
| Arrivals desk / dispatch / hotel inbound | Hero. | branch |
| Function door check-in | Roster for that function only; mark arrived; walk-ins as `source=manual` guest + membership; offline via durable journal. | N |
| Moments (time-anchored comms) | "Sangeet starts in 15 min — get dressed"; "Cars to the venue are at the porch". | N (§4) |
| Late-arrival handoff | Guest `hotelArrived` after `function.startsAt` → attention item to `functionCheckIn` duty at that function ("Meet the Mehtas at the gate, 4 pax"). | N (§4) |
| Coordinator live board | Per function now/next, check-in %, open transport exceptions, staff on shift. Reuse Today's attention-item pattern. | E |
| Family stakeholder view | Read-only counts — no phone numbers, no finance. | N duty |

### Stage E — Close out
| Feature | Notes | Status |
|---|---|---|
| Transport reconciliation | | branch A7 |
| Attendance report per function | Export; feeds planner's client report. | N |
| Thank-you / photos message | Program-scoped campaign. | E |
| Retention / anonymisation | Per-class retention; program archive triggers. | N |

### What a single mixer needs (for contrast)
Create event → import/publish → door check-in → run sheet → follow-up. Roles:
owner/manager, event lead, door. All existing. Presets and capability flags
must keep this path exactly as light as it is today.

---

## 4. Scheduling engine — "Moments"

### 4.1 Why a rule engine and not a calendar
A calendar view is a *display* of `programFunctions`. The business logic
("15 min before X, tell attending guests", "taxis are ready", "someone meet
the late family") needs an authority that:
- is anchored to a **mutable** time (functions slip by an hour routinely),
- resolves an **audience at fire time** (RSVPs change until the last minute),
- knows a **channel + consent** (WhatsApp service message vs staff push),
- is **idempotent** across retries and re-planning.

### 4.2 Model

```
programMoments/{momentId}
  programId, organizerId, name
  trigger: oneOf
    timeAnchor { anchorKind: functionStart | functionEnd | programStart
                            | rsvpDeadline | transportPlanDeparture,
                 anchorId: functionId | pickupPointId | null,
                 offsetMinutes: -15 }
    conditionAnchor { kind: lateArrivalAtHotel | flightDisrupted, functionId? }   (v1: only these two)
  audience: oneOf
    functionGuests { functionId, rsvp ⊆ {attending, maybe}, householdDedupe: true }
    households     { rsvpPendingOnly: bool }
    staffDuty      { duty, scopeIds? }
  action: oneOf
    sendTemplate   { connectionId, templateId, variables{}, messageClass: programService }
    staffAttention { duty, severity, titleTemplate }
  status: draft | armed | paused | done, revision, createdBy, timestamps

programMomentRuns/{runId}   (server-owned)
  momentId, programId, dueAt, anchorRevision,
  status: planned | resolving | dispatched | skipped | superseded | failed,
  recipientSnapshotHash, campaignId?, attentionItemIds[], receipts
```

### 4.3 Workflow
1. Manager arms a moment → server plans a run (`dueAt = anchor + offset`).
2. Function time changes (`revision++`) → re-plan every armed moment anchored
   to it: old run `superseded`, new run planned. (`anchorRevision` exists for
   exactly this.)
3. Scheduled Function (per minute; reuse `operations/` lease + idempotency)
   picks `planned` runs due, resolves audience *now*, creates a program-scoped
   `organizerCampaign` (`automationOrigin={kind: programMoment, runId}`) and
   hands it to the existing preview→approve→dispatch worker. Auto-approve only
   when the arming manager holds messaging authority. Staff-attention actions
   write `organizerAttentionItems` scoped to the duty; the work shell renders
   them.
4. Condition anchors: trigger on `programTravelLegs` readiness change evaluates
   `lateArrivalAtHotel` / `flightDisrupted` for that program and creates a run
   immediately.

### 4.4 Guard rails
- Service-purpose only (`messageClass: programService`); no promotion via
  moments. Consent basis = explicit tick on the RSVP page (recommended) —
  `STOP` still honoured by sender machinery.
- Caps: N moments/function, M messages/household/day (reuse the
  `event_whatsapp_budgets` pattern). Kill switch: removing `messaging` from
  program capabilities pauses all runs. Cancelled function → runs `skipped`.

### 4.5 Guest-side calendar
`/rsvp/:householdToken` (website) shows the invited itinerary and offers a
`webcal://` feed / `.ics` download built server-side. No dependency on the
Flutter method channel; app users can additionally use it.

---

## 5. Roles

### 5.1 Two organiser shapes, one model

| Organiser | Typical people | Duties |
|---|---|---|
| Single mixer (today) | Host; a friend at the door | `manager`; `eventLead(eventId)`, `functionCheckIn(eventId)` |
| Wedding planner | Planner + 5–30 temp/venue/vendor staff + family | `manager`; `programCoordinator`; `guestRelations`; `communications`; `functionCheckIn(functionIds)`; `functionLead(functionIds)`; `airportGreeter(pickupIds)`; `transportDispatcher(pickupIds)`; `hotelDesk(hotelIds)`; `reconciliationViewer`; `stakeholderViewer` |

### 5.2 Duty union (widened from the airport branch)

```
programCoordinator()                    all program ops; no org CRM/payouts/sender admin
guestRelations()                        guests, households, RSVP review, imports
communications()                        program-scoped Inbox; arm/pause moments
functionCheckIn(functionIds[])          search + arrive for those functions only
functionLead(functionIds[])             now/next + check-in + late-arrival attention for those functions
airportGreeter(pickupPointIds[])        (branch)
transportDispatcher(pickupPointIds[])   (branch)
hotelDesk(hotelIds[])                   (branch)
reconciliationViewer()                  (branch)
stakeholderViewer()                     read-only counts; no PII, no finance
```
For **events** the same union applies with `eventId` scope: `eventLead` (was
`eventOperator`), `functionCheckIn` (was `checkInOperator`). `permissions[]`
becomes derived from duty, not stored twice.

### 5.3 One client concept: `HostWorkAssignment`

```
listMyHostAssignments() → [
  { scope: program(programId) | event(eventId),
    title, subtitle, organizerName,
    duties: [ {duty, scopeIds[], shift?, expiresAt} ],
    destinations: derived server-side (5.4) } ]
```
- Managers → full 5-tab shell (existing). Anyone with ≥1 assignment and no
  manager membership → `HostWorkShell`. Managers get "View as staff".
- Deep link `/host/work/...` survives OTP; the server decides access.

### 5.4 Duty → destinations

| Duty | Destinations (≤3 + assignment menu) |
|---|---|
| functionCheckIn | Door · Walk-ins |
| functionLead | Now/Next · Door · Attention |
| airportGreeter | Arrivals · (Dispatch if also dispatcher) |
| transportDispatcher | Arrivals · Dispatch |
| hotelDesk | Inbound · Rooms |
| guestRelations | Guests · RSVP inbox · Imports (desk job — lives in manager-like program shell) |
| communications | Inbox (program scope) · Moments |
| reconciliationViewer | Trips · Exceptions · Export |
| stakeholderViewer | Overview (counts only) |
| programCoordinator | Program workspace, program-locked |

One destination → no bottom bar, task screen + assignment menu. Two or three →
bottom bar. Never mount manager providers in the work shell.

---

## 6. UI changes (HTML mockups were reviewed out-of-tree on 2026-09-22; they are illustrative and not tracked)

| # | Screen | Why it is new |
|---|---|---|
| 1 | Program workspace — Schedule | First multi-day surface in Host: day rail, function blocks, Moments pinned to functions, headcount per function. |
| 2 | Guests — household × function RSVP grid | Today's roster is flat with one status. Weddings need households, sides, per-function RSVP, pax incl. kids. |
| 3 | Team & duties | Duty with resource scope + shift. Event staff today is role + checkboxes. |
| 4 | Work shell — assignment picker + Door check-in | Staff-only shell; single-destination variant; the same shell hosts airport/hotel/door. |
| 5 | Moments editor | Anchor, offset, audience, action, computed fire time + recipient count. |
| 6 | Guest RSVP page (web) | Household-scoped, per person per function, travel, add to calendar. |
| 7 | Events tab with Programs + Organizer → Plan | Programs inventory without a sixth tab; entitlement usage meters. |

Unchanged on purpose: the 5 manager tabs, Today's attention model (gains program
items), Inbox (gains a program scope chip), Audience people/CRM.

---

## 7. Monetisation

### 7.1 Facts that shape it
- India-first; destination weddings ₹50L–₹5Cr budgets; planner fee 8–15%. A
  ₹25k–₹1.5L software line per wedding is small next to transport alone
  (200 guests × ₹1,500–3,000 transfers ≈ ₹3–6L).
- Variable costs we carry: flight-status API (per flight-day), Routes calls,
  Meta WhatsApp conversation fees (~₹0.7–0.9 utility), SMS.
- Planners run 10–40 weddings/yr; social hosts run weekly events on tiny
  budgets. One price list won't fit both.

### 7.2 Recommended: per-program tiers + metered add-ons

| | Social (existing) | Wedding Essentials | Wedding Pro | Wedding Signature |
|---|---|---|---|---|
| Price | Free / ticket fee | ₹24,999 / program | ₹59,999 / program | ₹1,49,999 / program |
| Guests | as today | ≤150 | ≤400 | ≤1,000 |
| Functions | 1 | ≤5 | ≤10 | unlimited |
| Staff assignments | 50/event | 10 | 30 | 100 |
| Guests, households, RSVP web, itinerary | — | ✓ | ✓ | ✓ |
| Door check-in per function | event only | ✓ | ✓ | ✓ |
| Moments | — | 3/function | unlimited | unlimited |
| Arrivals desk + dispatch + hotel inbound | — | add-on ₹14,999 | ✓ | ✓ |
| Live flight tracking | — | — | metered | ≤300 flight-days incl. |
| Accommodation / room blocks | — | — | ✓ | ✓ |
| Vendor reconciliation + export | — | — | ✓ | ✓ + finance seat |
| WhatsApp volume | sender's own Meta billing | pass-through +20% | pass-through +20% | 3,000 conversations incl. |
| Stakeholder viewer seats | — | 2 | 6 | unlimited |

- **Planner annual plan** (later): ₹3–6L/yr for 10–20 Pro programs + firm-level
  CRM retention. Only after per-program pricing proves out.
- Do **not** price per guest at v1: it penalises the big weddings whose
  transport pain is our wedge, and makes the import step feel like a meter.

### 7.3 Entitlement data model

```
organizerEntitlements/{organizerId}
  plans: [{ sku, unit: program | organizerYear, quantityRemaining, validUntil,
            source: manualInvoice | checkout | promo, receiptRef }]
  meters: { flightDaysUsed, waConversationsUsed }, revision, updatedAt

organizerPrograms.entitlement   (embedded snapshot at creation)
  { sku, limits{guests, functions, staff, momentsPerFunction},
    capabilitiesAllowed[], grantedAt, receiptRef }
```
- `programCapability` (exists) = *enabled*; `capabilitiesAllowed` = ceiling.
- Limits enforced in owning callables (import commit, grant staff, arm
  moment), not UI. Overage = soft block + attention item; don't hard-fail a
  B2B import at guest 151.
- Pilot: admin console writes entitlements after a manual invoice. Self-serve
  checkout later.

---

## 8. Delivery sequencing (W = wedding; A = airport branch)

| Slice | Deliverable | Depends on |
|---|---|---|
| **W0 contract corrections** | `programFunctionGuests`; function fields; widened duty union; `programHouseholds.side`; campaign `recipientSource`; `organizerEntitlements` + program snapshot. Fixtures, rules, generated types. | A1 contracts |
| **W1 program workspace UI** | Programs under Events; workspace with Schedule / Guests / Team; wedding preset; import with household mapping. | W0, A2 access layer |
| **W2 unified work shell** | `HostWorkAssignment`, `listMyHostAssignments` over both grant stores, `HostWorkShell`, door check-in on the durable journal, `eventStaffGrants` DTO migration. | W0 |
| **W3 RSVP web + conversion** | Household signed-link page, per-function response, `.ics` feed, conversion to `programFunctionGuests`/travel legs, headcount dashboard. | W0, W1 |
| **W4 Moments** | Rules, runs, planner/re-planner, worker → program campaigns, staff attention, two condition anchors. | W0, W3, Inbox program scope |
| **W5 entitlements & pilot billing** | Admin-written entitlements, limits in callables, Organizer → Plan screen. | W0 |
| A3–A7 | Arrivals, flights, offline, hotels, reconciliation. | as on branch |

W0 should land **before** the airport branch adds client code, or per-program
RSVP and transport-only duties get baked into UI.

---

## 9. Decisions (approved by product owner, 2026-09-22)

1. **Function ≠ Event.** A wedding function never creates an `events`
   document or gets Event Success / public booking unless an explicit,
   reviewed `programFunctions.eventId` bridge is added later.
2. **Unify staff authority now (W2).** One `HostWorkAssignment` over
   `eventStaffGrants` and `programStaffGrants`; one `HostWorkShell`;
   `/host/operator/:eventId` is migrated onto it (kept as a redirect).
3. **Pricing anchor: per-program tiers** (§7.2). Planner annual plan is a
   later slice once per-program pricing proves out.
4. **Guest messaging consent: explicit tick** on the household RSVP page.
   RSVP acceptance alone is not a messaging basis.
5. **Family stakeholder view is in v1** as the `stakeholderViewer` duty
   (read-only counts, no PII, no finance).
6. **Flight provider** — remains open on the airport branch; unchanged here.
