---
doc_id: program_operations_rollout_spec
version: 1.0.0
updated: 2026-09-26
owner: product
status: active
---

# Program Operations Rollout Spec — build state, gaps, decisions

Status: living tracking spec for allocating the remaining wedding/conference
program-platform work. Companion: `wedding_planner_platform_plan.md` owns the
product/architecture rationale; this document owns *what exists, what does
not, and what needs a decision*. Measured against `main` at `ad37379905b5`
(deployed to dev, staging, prod — 449 function exports, deploy parity green).

Legend: **built** = code exists on main and is deployable · **partial** =
backend or model exists, surface/consumer missing · **missing** = nothing on
main · **decision** = needs product-owner input before schema/UI work.

---

## 1. Roles and permissions — measured state

### 1.1 The duty union is fully built

`contracts/shared/program_common.schema.json` defines `programStaffDuty`:

| Person (product language) | Duty | Scoped by | Server enforcement |
|---|---|---|---|
| Planner / organizer | `organizerTeamMemberships.role ∈ {owner, manager}` | organizer | full 5-tab host shell |
| Program ops (all program, no org CRM/payouts/sender admin) | `programCoordinator` | program | `requireProgramAccess` |
| Guests / RSVP desk / imports | `guestRelations` | program | — |
| Program-scoped messaging (arm/pause moments) | `communications` | program | moment callables accept manager or `communications` |
| Venue door — check-in only | `functionCheckIn` | `functionIds[]` | journal write guard |
| Venue lead — now/next, door, late arrivals | `functionLead` | `functionIds[]` | — |
| Greeter at airport/station curb | `airportGreeter` | `pickupPointIds[]` | — |
| Dispatch coordinator at airport/station | `transportDispatcher` | `pickupPointIds[]` | — |
| Hotel welcome desk | `hotelDesk` | `hotelIds[]` | — |
| Reconciliation read | `reconciliationViewer` | program | — |
| Family/stakeholder read-only (counts, no PII/finance) | `stakeholderViewer` | program | — |

Each `programStaffGrants` doc carries up to 8 independently-expiring
`{duty, pickupPointIds, hotelIds, functionIds, expiresAtMillis}` tuples, so one
human can hold greeter + dispatcher at the same station. Staff lifecycle is
phone-based: `inviteProgramStaff` → token deep link → `claimProgramStaffInvite`
→ `grantProgramStaff`/`revokeProgramStaff`/`listProgramStaff`.

**Least privilege is structural, not cosmetic:** `getProgramWorkAccess`
returns only the pickup points / hotels inside the actor's duty scope;
every destination callable re-checks authorization server-side; the staff
shell never mounts manager providers; `communications` reaches moments but
never CRM, saved audiences, sender connections, or payouts.

### 1.2 Permissions gaps

| Gap | Detail |
|---|---|
| Organizer tab is all-or-nothing | `owner`/`manager` both get the full 5-tab shell. No org-level role gives Organizer settings/config without Audience (CRM) or Inbox. If we want "settings-only" or "no-CRM" manager seats, that's a new layer on `organizerTeamMemberships`. |
| `stakeholderViewer` has no backend surface | Duty exists; nothing returns counts-only program data. Needs a read callable + a thin read surface. |
| Duty→destination surfaces incomplete | Only transport duties have client surfaces today (see §3.2). |
| `eventStaffGrants` still separate | Legacy event staff roles remain in their own store/shell; `listMyHostAssignments` projects both but `/host/operator/:eventId` is not yet migrated onto the unified work shell. |

---

## 2. Entry paths — measured

| Actor | Path |
|---|---|
| Organizer manager | 5-tab host shell → Events → event → Manage → Moments field → `/host/organizers/:clubId/events/:eventId/moments` (PR #443) |
| Program staff | `/host/work/:programId` (+ `?invite=` token claim) → `getProgramWorkAccess` resolves duty-scoped destinations → `/arrivals/:pickupPointId`, `/dispatch/:pickupPointId`, `/hotel/:hotelId`, `/trips` |
| Program staff (unified) | `listMyHostAssignments` callable deployed — **no Flutter assignment-picker shell yet** |
| Guest (RSVP) | Web `/rsvp/:householdToken` (HMAC link via `issueProgramHouseholdRsvpLink`); `.ics` feed via `programHouseholdItineraryIcs` (`onRequest`) |
| Organizer program workspace | **Does not exist** — no Flutter route/screen for program schedule/guests/team |

---

## 3. Feature inventory — built / partial / missing

### 3.1 Guest, invitation, RSVP

| Feature | State | Where |
|---|---|---|
| Per-function invitations (not everyone to everything) | **built** | `programFunctionGuests.invited` + `programFunctions.invitationMode` + `applyProgramFunctionInvitations` |
| Per-function RSVP + attendance | **built** | `programFunctionGuests.rsvpStatus/attendanceStatus/partySize`, `recordProgramFunctionRsvp` |
| Household link RSVP page | **built** | `website/src/features/householdRsvp/` — per-member × per-function drafts, party size, notes, explicit messaging consent |
| Guest identity + households | **built** | `programGuests` (contact link optional — CRM never auto-created), `programHouseholds` |
| Side tagging (partnerA/partnerB/mutual, configurable labels) | **partial** | `programHouseholds.side` only — household level, three-value enum |
| **Guest groups/tags — arbitrary dimensions** | **missing + decision** | Nothing for groom's-dad-side / friends-vs-family / company / country / delegation. Needs a group model (§5.1) |
| Guest notes | **partial** | `responseNote` on function-guest responses only; no free-form note on `programGuests` |
| Import with household mapping | **partial** | `importProgramManifest` callable exists; no Flutter import UI or column-mapping surface |
| Travel details collected on RSVP page | **missing** | `submitProgramHouseholdRsvp` contract = rsvp/partySize/note/consent only; legs come via `upsertProgramTravelLeg` or manifest import |

### 3.2 Staff surfaces (duty → destination client side)

| Duty destination (plan §5.4) | State |
|---|---|
| `airportGreeter` → Arrivals | **built** — `/host/work/:programId/arrivals/:pickupPointId` |
| `transportDispatcher` → Arrivals · Dispatch | **built** — dispatch screen on same prefix |
| `hotelDesk` → Inbound · Rooms | **partial** — `/hotel/:hotelId` inbound desk exists; **Rooms has no stays/room-block model** (§3.3) |
| `functionCheckIn` → Door · Walk-ins | **missing UI** — `recordProgramDoorJournal` durable journal is deployed; no door screen |
| `functionLead` → Now/Next · Door · Attention | **missing UI** — staff-attention projection into `organizerAttentionItems` is deployed |
| `guestRelations` → Guests · RSVP inbox · Imports | **missing UI** — all callables deployed |
| `communications` → program Inbox · Moments | **partial** — program-scope moments accepted server-side; program Moments screen route not wired (needs program workspace); program Inbox not built |
| `reconciliationViewer` → Trips · Exceptions · Export | **partial** — `/trips` ledger exists; exceptions/export missing |
| `stakeholderViewer` → counts-only overview | **missing** — no API or screen |
| `programCoordinator` → program workspace | **missing** — no organizer program workspace exists |
| Unified `HostWorkShell` + assignment picker | **missing** — `listMyHostAssignments` deployed, no Flutter consumer; `/host/operator/:eventId` redirect pending |

### 3.3 Logistics

| Feature | State | Where |
|---|---|---|
| Flight details + enrichment | **built** | `programTravelLegs` (number, carrier, IATA, sched/est/actual, status, alert subscription via `flightAlertWebhook`, terminal, readiness, pax/luggage, party, destination hotel) |
| Venue details | **built** | `programFunctions.venueName/venueNotes/venueLocation` (coords); `programPickupPoints` carry airport/terminal/station kind |
| Hotels | **partial** | `programHotels` (name/address/lat/lng/reception contact); `programStays` + `programRoomBlocks` schemas **not on main** (airport branch A7) |
| Room allocation | **missing** | no stays/room-block model, no allocation UI, no group-aware assignment |
| Taxi/transport tracking | **built backend + staff UI** | `transportTrips` (vehicle class, vendor, plate, parties/legs, depart/arrive, rate snapshot), dispatch + hotel-inbound + trips-ledger screens. **How it's exposed:** dispatcher creates trip at `/dispatch/:pickupPointId`; hotel desk sees inbound at `/hotel/:hotelId`; ledger at `/trips`. No guest-facing tracking. |
| Vendors / rate cards | **partial** | `transportVendors` + `rateSnapshot` on trips; no rate-card management UI |
| Distance-aware reminder lead times | **missing + decision** | Moments use fixed `offsetMinutes`. Hotels and functions both carry coordinates — a planner-side Routes call could compute per-recipient offsets (hotel→venue travel time). Not built. |

### 3.4 Messaging / Moments

| Feature | State |
|---|---|
| Unified Moments engine (6 callables, sweep, travel-leg trigger, send journal, staff-attention projection) | **built + deployed** |
| Organizer Moments Flutter surface (list/editor/lifecycle/run, event scope) | **PR #443** — program scope in the shared model; route not wired until a program workspace exists |
| Campaign `recipientSource: programSelection` | **partial** — schema exists; campaign upsert cannot set it, `organizerCampaigns` dispatcher does not materialize program recipients |
| `organizerFormAutomations` → `triggered` moments migration | **missing** — decision 9 approved; form automations still own pipeline |
| WhatsApp program templates | **runbook, not code** — `program_function_starting`, `program_get_ready`, `program_transport_ready`, `program_rsvp_deadline_reminder` each need an approved Meta template per sender connection |

### 3.5 Organizer-facing program management

| Feature | State |
|---|---|
| Program CRUD + wedding preset + function upsert + staff grant/invite + guest/household upsert + manifest import | **callables built + deployed** |
| Program workspace UI (schedule day-rail, household×function RSVP grid, Team & duties, headcount dashboard) | **missing — largest organizer-facing hole** (plan W1) |
| Programs under Events tab + Organizer → Plan screen | **missing** (W5) |
| Entitlements (`organizerEntitlements`, SKU catalog, limits enforcement) | **unmerged branch** `codex/organizer-entitlements-20260922` — needs re-verify + merge |
| Attendance report / export per function | **missing** |
| Retention / anonymization on archive | **missing** |

---

## 4. Known platform defect (from this deploy cycle)

`tool/ci/package_firebase_delivery.mjs`: `verifyFirebaseDelivery` recomputes
the delivery target set with the **control plane's** dormant-functions list
instead of the **source SHA's**. Any dormant-list change while a packaged
delivery is pending makes it permanently unverifiable → ordered-queue
head-of-line deadlock (observed with `sendEventReminders` removal, source
`99ba008d1`). Escaped via `backend-rebaseline.yml`. Fix: replay the source
SHA's dormant list at verify time.

---

## 5. Open decisions (block schema/UI work)

1. **Guest group model.** Single concept feeding room allocation, headcount
   cuts, and group-targeted moments ("groom's side staying at the Trident").
   Options: (a) `groupIds[]` on `programGuests` + a `programGuestGroups`
   collection with configurable dimensions (side/lineage/relation for
   weddings; company/delegation/country for conferences) — dimensions
   declared per program kind, labels organizer-defined; (b) flat `tags[]`
   strings — cheaper, no structure. Recommend (a): queryable, importable,
   and audience-selectable.
2. **Distance-aware reminders.** New initiation or planner option? Suggest:
   moment keeps `anchored`/`scheduled` initiation; planner computes
   per-recipient `dueAt` from hotel→function travel time (Routes API,
   cached) when a `travelTimeLead` flag is set on the audience.
3. **Organizer-level role split.** Do we need seats inside the Organizer tab
   (e.g., finance-viewer, settings-editor) before v1, or does
   program-scoped staffing cover it? Recommend deferring unless a pilot
   asks for it.
4. **Travel capture on household RSVP page.** Extend
   `submitProgramHouseholdRsvp` with optional per-member travel blocks, or
   keep legs planner/import-only for v1? Collecting at RSVP is the planner
   UX win; it widens the web surface's write surface.
5. **Staff identity.** Phone-auth account required today — correct for temp
   wedding staff? A claimable invite without a pre-existing account is
   smoother; confirm acceptable friction.
6. **`stakeholderViewer` shape.** Counts-only overview: which numbers are
   "safe" (headcounts yes, per-hotel occupancy yes?, names never). Needs a
   field-level contract before the API exists.
7. **Room blocks schema.** Confirm `programStays`/`programRoomBlocks` from
   the airport branch's deferred slice still match hotel-desk reality before
   pulling them onto main.

---

## 6. Suggested sequencing

| # | Slice | Unblocks | Depends on |
|---|---|---|---|
| R1 | Program workspace UI (schedule, guests grid, team & duties, import mapping) | everything organizer-facing; program-scope Moments route; communications/guestRelations surfaces | callables already deployed |
| R2 | Guest groups schema decision + contract correction | room allocation, grouped moments, headcount cuts | decision 5.1 |
| R3 | `HostWorkShell` + assignment picker + door check-in screen on the durable journal | venue staff get live runtime modules; `/host/operator` migration | `listMyHostAssignments` deployed |
| R4 | Program-scope Moments route + program Inbox scope chip | communications duty surface; anchored program moments | R1 |
| R5 | Stays/room blocks + group-informed allocation | hotelDesk "Rooms" destination | R2, airport-branch A7 review |
| R6 | Travel capture on household RSVP | planner leg-entry toil | decision 5.4 |
| R7 | Distance-aware moment lead times | venue-distance reminders | R2 (hotel per group), coords already present |
| R8 | `stakeholderViewer` counts API + read surface | family view | decision 5.6 |
| R9 | Entitlements merge + Plan screen + limits in callables | billing gate for pilot | unmerged branch re-verify |
| R10 | `recipientSource: programSelection` dispatcher wiring + form-automation → triggered-moment migration | campaign engine consolidation | W0 schema (done) |
| R11 | Reconciliation/export, per-function attendance report, retention | close-out | R5 trips data |
| R12 | `verifyFirebaseDelivery` dormant-list fix | future deploy lane safety | — |

Merge-ready now (no ordering dependency): R9's entitlements branch.
```
