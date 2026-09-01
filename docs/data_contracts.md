---
doc_id: data_contracts
version: 1.40.0
updated: 2026-09-01
owner: recursive_audit_loop
status: active
---

# Data Contracts

This is the source of truth for Firestore document shape, Cloud Functions write
ownership, schema tooling, relationship documents, migration policy, and rules
test workflow. It replaces the separate Firestore/Functions contract tracker,
relationship-doc migration tracker, and schema-contract unification tracker.

For a human map of every backend operation, use
`docs/backend_operation_catalog.md`. For environment deploy order, use
`docs/release_operations.md`.

## Read Policy

Read this before changing:

- Firestore rules or Storage rules tied to Firestore documents;
- Cloud Functions mutation boundaries;
- Dart/TypeScript model generation;
- JSON schemas under `contracts/`;
- callable request/response validation;
- seed/demo document builders;
- relationship/action documents;
- data migration or repair tools;
- Firestore rules test execution.

## Sources Of Truth

| Surface | Owner |
|---|---|
| Persisted document, callable, and public HTTP schemas plus fixtures and catalogs | `contracts/` |
| Storage path contracts (upload paths, content-type, size limits, owner) | `contracts/storage/` |
| Generated TypeScript interfaces, Ajv validators, and Admin SDK Timestamp types | `functions/src/shared/generated/` |
| Generated website and Admin browser contract types | `website/src/shared/contracts/generated/` and `admin/src/generated/contracts/` |
| Generated Dart schema constants/registry | `lib/core/schema_contracts/generated/` |
| Tool-side schema registry and validators | `tool/contracts/generated/` |
| Firestore operation ownership metadata | `tool/contracts/firestore_contract.json` |
| Human operation map | `docs/backend_operation_catalog.md` |
| Active policy rules | `tool/policy/rules.json` |

Do not hand-edit generated outputs. Change the contract source, run the schema
generator, and commit the generated diff.

### Host Today Attention Contract

`contracts/catalogs/host_attention_policies.json` is the exhaustive policy
inventory for the Host Today queue. Every kind declares one source owner,
trigger and resolution semantics, authorization boundary, consequence,
deadline policy, destination, deduplication policy, delivery mode, and source-
truth readiness. The schema validator requires the catalog to match the closed
kind enum in `contracts/shared/host_attention_common.schema.json` exactly and
in order. Adding an attention kind therefore requires an explicit catalog
decision; it cannot appear as widget-local business logic.

The catalog distinguishes four delivery modes:

| Delivery mode | Meaning |
|---|---|
| `serverProjected` | The backend can derive the item from explicit canonical facts and return it after read-through reconciliation. |
| `clientMerged` | The fact is intentionally device-local and Flutter merges it after the server response. |
| `shortcutOnly` | Today exposes an action, but the product does not claim that every organizer has a mandatory task. |
| `blockedMissingTruth` | A desirable archetype lacks an explicit authoritative workflow field; the callable reports the gap instead of inferring it from a weak proxy. |

`organizerAttentionItems/{attentionId}` is a server-only evaluated projection.
It stores stable source provenance and revision, open/resolved lifecycle,
urgency, consequence, deadline, destination, display-safe context, policy and
resolution versions. Open rows use a null TTL; resolved rows receive bounded
cleanup. It never embeds prose predicates or
becomes the source of the underlying event, application, form, provider, or
payout state. Direct client reads and writes are denied.

`listOrganizerAttentionItems` owns the read-through boundary. Before returning
supported server items it must re-read every declared authoritative source,
derive the desired open set, upsert changed rows, and resolve stale rows. Each
source scan is bounded at 400 records and fails closed when exceeded; the
callable must never label a truncated scan exhaustive. The response also
contains one coverage row per catalog kind so clients and tests can distinguish
complete server coverage, required local merging, shortcuts, and missing truth.

The source-ready server kinds are live-event operations, ordinary waitlist
review, manual join-request review, application review, provider-sync failure,
form-automation failure, and payout setup. Attendance retry/conflict work is
merged from the local Host outbox.
Dress Rehearsal is a Today shortcut. Event Success readiness, room-layout
requirements, staffing requirements, generic form-response review, Inbox reply
obligation, and post-event reconciliation stay blocked until their owning
domains add explicit workflow state. In particular, null optional setup, zero
staff grants, an unread message, a submitted generic form, or aggregate counts
are not sufficient evidence of a mandatory task.

### Event Dress Rehearsal Isolation Contract

Event rehearsal is a separate bounded domain with four callable-owned,
server-only collections:

| Collection | Purpose | Limits and authority |
|---|---|---|
| `eventRehearsals/{sessionId}` | Frozen source snapshot, editable pre-start setup, scenario/seed, virtual clock, lifecycle and revisions | Organizer manager reads through Host callables only; 24-hour expiry; at most five active sessions per owner |
| `eventRehearsalActors/{sessionId_actorId}` | Deterministically generated synthetic people, status, guest moment, Room placement/confirmation, opt-out/help/prompt flags and keep-apart ids | At most 50 actors; no UID, phone, email, booking, payment, match, chat, or production attendee id |
| `eventRehearsalActions/{sessionId_actionKey}` | Idempotent Host/guest controls and deterministic replay history | At most 500 actions; a stable hash of session plus client action id deduplicates delivery |
| `eventRehearsalGuestViews/{sessionId_slotId}` | One browser-instance-to-actor lease with hashed bearer token state | Created only by the public guest bootstrap callable; link rotation invalidates prior slots |

The schemas under `contracts/firestore/event_rehearsal_*.schema.json` and
`contracts/callables/*event_rehearsal*.schema.json` are authoritative.
Functions may read `events/{sourceEventId}` exactly once during creation to
copy a bounded title, location, duration, and supported playbook shape after
verifying organizer authority. No rehearsal handler may write a production
collection. Firestore rules deny every direct client read and write to the four
collections; App-Check-protected callables own all Host access.

Host writes carry the expected setup or runtime revision. Mutating controls and
guest actions carry a bounded client action id, exact replays return the same
projection, and stale revisions fail closed. Setup freezes at start. Reset
regenerates actors from the same seed and clears action count; fork creates a
new session. Room moves, confirmation, and pin release use the same revision
and idempotency boundary and may target only deterministic tables owned by the
rehearsal. The scheduled expiry handler deletes the bounded child set after
24 hours. Advanced latency/failure/disconnect/stale/duplicate/legacy/reduced-
motion/low-bandwidth faults require internal/admin authorization; behavioral
scenarios remain available to an ordinary organizer manager.

The public guest response contains only a practice banner, safe session fields,
one synthetic actor, and a slot token. `clientInstanceId` stabilizes retries in
one browser; the server derives and stores only deterministic hashes. It never
uses Firebase Auth, OTP, attendee claims, or a production roster.

### Event Success Moment Presentation Contract

`contracts/catalogs/event_success_moment_presentations.json` is the authored
cross-runtime choreography source. It exhaustively covers every attendee moment
kind and owns palette and motif ids, phase durations, tempo, idle-pulse period,
particle density, the deterministic seed rule, server-clock reference, and
ambient-bed ids. The schema generator rejects missing, duplicate, or unknown
moments and fails closed when the live-reveal ceremony loses its countdown
clock, positive phase durations, or particle field.

The generator emits typed Dart into
`lib/core/schema_contracts/generated/event_success_moment_presentations.g.dart`
and TypeScript into
`functions/src/shared/generated/eventSuccessMomentPresentations.ts`. Both
outputs implement `fnv1a32-utf8-fields-v1` over event id, moment kind, reveal
round, and server anchor, with an unambiguous byte separator. Both resolve the
same anticipation, climax, settle, and completion boundaries. Live reveal uses
the saved `structureConfig.revealCountdownSeconds`; the catalog's anticipation
duration is only the legacy-document fallback, not a hard-coded client policy.
The guest runtime may consume the ambient-bed id as choreography metadata but
must not play per-attendee web audio.

### Event Success Format Primitives

`contracts/shared/event_common.schema.json` owns the closed
`eventSuccessMatchingObjective` enum (`coverage`, `romantic`, `affinity`,
`novelty`, `balance`, and `spread`) and the optional `matchingObjective` format
primitive. The same source owns the closed `eventSuccessUnitOutcome` enum
(`none`, `completion`, `score`, and `rank`) and its optional `unitOutcome`
primitive, plus `eventSuccessAccountability` (`none`, `rollCall`, `sweep`) and
its optional `accountability` primitive. The schema generator projects those contracts into Functions, Dart,
and tool registries. Runtime resolution, including the profile-free `coverage`
default, format-bound outcome defaults, and explicit unsupported assignment
algorithms, is owned by the Event Success format resolver documented in
`docs/event_success.md`; generated contract files must not encode a separate
fallback.

### Event Success Accountability Boundary

`eventAttendees/{attendeeId}` carries optional Host-owned accountability fields:
the `returned`/`departed` resolution, the exact `checkedInAt` timestamp it was
resolved for, resolver identity, and server resolution time. A resolution is
current only when its stored check-in timestamp exactly matches the row's
current check-in. This includes Host-imported and unlinked operational guests
without synthesizing a Catch UID.

Direct attendee-row writes remain denied. The generated
`setEventSuccessAccountabilityResolution` callable request accepts one current
attendee and `returned`, `departed`, or `unresolved`; the Functions transaction
validates organizer-manager authority, event identity, current check-in, and
`accountability: sweep`. The live completion request separately carries
`accountabilityAcknowledged` so an unresolved sweep warns by default but an
explicit Host choice can still complete the event.

### Event Success Live-Control Boundary

`contracts/firestore/event_success_plans.schema.json` declares the persisted
live revision and monotonic publication cursors. Direct clients serialize only
setup-owned plan fields; `liveControlRevision`, `assignmentDraftRevision`,
`publishedRotationRoundIndex`, and `publishedRevealRoundIndex` are written by
backend live-control transactions. Legacy documents may omit these fields and
resolve to their schema defaults.

Prepared guided rotations use
`eventSuccessAssignmentDrafts/{eventId_moduleId_uid}` and the source schema
`contracts/firestore/event_success_assignment_drafts.schema.json`. Each wrapper
binds the event, organizer, attendee, module, target round, base assignment
revision, and full Host-preview assignment. Rules permit only the event Host to
read drafts and deny every direct client write. Attendee-readable
`eventSuccessAssignments` contain only slots through the rotation round
published by `publishEventSuccessRotationRound`; later precomputed slots remain
inside the Host-only draft.

Live actions, draft preparation, and rotation publication use the generated
callable request schemas under `contracts/callables/`. Every mutating request
carries an expected revision, and reveal or rotation publication also carries
explicit confirmation. The asynchronous draft trigger's bounded retry count is
deployment configuration, not a persisted plan constant.

### Event Success Presence And Late-Arrival Boundary

`contracts/firestore/event_success_presence.schema.json` owns the server-only
heartbeat record at `eventSuccessPresence/{eventId_uid}`. The document stores
event/organizer/attendee identity, runtime surface, and server timestamps; it
does not persist a presence enum. `present`, `idle`, and `likelyDeparted` are
derived from the Functions server clock and the bounded deployment policy.
Direct clients cannot read or write presence documents.

The heartbeat request/response schemas and Host summary response under
`contracts/callables/` and `contracts/callable_responses/` carry the active
policy into Flutter and web. Defaults are a 30-second heartbeat, a 90-second
present window, and a 300-second likely-departed threshold. Unmonitored
attendees remain eligible; absence of a heartbeat is not departure evidence.

`contracts/firestore/event_success_late_arrivals.schema.json` owns the
deterministic Host resolution at `eventSuccessLateArrivals/{eventId_uid}`.
`resolveEventSuccessLateArrival` carries explicit confirmation and an expected
live revision. The transaction can change only the unpublished next-round
assignment draft, increments its draft revision when changed, and records a
bounded attendee-visible reason. It never writes
`eventSuccessAssignments/{eventId_moduleId_uid}`. Rules allow only the subject
attendee or event Host to get a resolution; collection queries and direct
writes are denied.

### Event Success Conversation Graph Boundary

`contracts/firestore/event_success_conversation_graphs.schema.json` owns the
attendee-private post-event response at
`eventSuccessConversationGraphs/{eventId_uid}`. The server accepts a response
only from a checked-in attendee after the event ends, filters the unified roster
through the block boundary, and stores UID edges only in this private source.
Rules allow only the subject attendee to get the deterministic document; Hosts,
other attendees, collection queries, and every direct client write are denied.

`eventSuccessPlans.conversationGraphConsentMode` is a closed `optIn` / `optOut`
setup field. Missing and legacy values resolve to the reviewed `optIn` default,
which suggests assigned attendees without selecting them. A Host may configure
`optOut` before setup freezes; it preselects visible assigned attendees and
still lets the attendee remove any or all selections or skip the response.

The generated get/submit callable contracts expose the same roster-chip
mechanism for every format while the backend derives only the prompt from
interaction primitives. Raw edges never enter the Host projection.
`eventSuccessScorecards.conversationGraph` contains numeric counts and
exclusion totals only; no attendee identifier or name-to-name edge is present.

### Event Success Spatial Layout Boundary

`contracts/shared/event_success_layout.schema.json` owns the reusable
parametric layout shape: coarse integer-grid units with bounded capacity,
stable order, and the closed `round`, `rect`, `row`, `court`, and `zone` enum.
`contracts/firestore/organizer_event_success_layouts.schema.json` stores those
assets at `organizerEventSuccessLayouts/{organizerId_layoutId}`. Layouts are
organizer-scoped, not event-scoped, and derived coordinates are never stored.
Organizer managers may query their assets; all direct client writes are denied.

`eventSuccessPlans.layoutId` selects an asset. Assignment documents separately
store `layoutUnitId` and nullable `confirmedLayoutUnitId`; assigned position is
not evidence of Host confirmation. `affinityConstraints` and
`spatialOverrides` retain the explicit T2 `thisRound` / `pinned` consequence.
The spatial callable request/response schemas own authoring, authorized layout
fetch, destination preview, reassignment, confirmation, and release. Mutating
actions carry `expectedRevision` and share `liveControlRevision` with the T4
control path.

`contracts/catalogs/event_success_layout.json` is the cross-runtime fixture for
all five shapes and normalized grid-cell rendering. Unit proximity is a
complete Euclidean graph derived from the stored grid with no cutoff. A
`wholeGroup` structure suppresses layout projection even if a legacy plan or
assignment contains stale spatial fields.

### Event Success Sequence Capacity Boundary

`contracts/shared/event_common.schema.json` owns the closed `topology` values
(`set`, `sequence`, `adjacency`) and the optional `resourceCapacity` object.
`concurrentUnits` is a configurable simultaneous-resource limit; null means
unconstrained. `resourceLabelId` is one of `court`, `table`, `lane`, or `board`.
`seatsPerUnit` may be non-null only for `adjacency` and does not enable the
deferred table-seating engine.

`sequence` is implemented only with `pairRotations`. The server scheduler
produces ordered, capacity-bounded rounds, explicit sit-out slots, and stable
`resourceUnitId` values on rotation slots. It consumes the same cumulative
exclusion totals used by T3 and the derived `unitProximity` graph from T5.
`adjacency`, `tableSeating`, and other sequence-algorithm combinations remain
explicitly unsupported in the exhaustive resolution table; no neighbouring
engine fallback is permitted.

### Event Success Unit Outcomes And Standings

`contracts/firestore/event_success_unit_outcomes.schema.json` owns the
server-written round facts at `eventSuccessUnitOutcomes/{eventId}`. One entry
contains exactly one of `completed`, `score`, or `rank`; duplicate units,
partial rank orders, non-sequential new rounds, and values that do not match the
saved `unitOutcome` fail closed. Outcome facts are Host-readable and never
direct-client writable.

`recordEventSuccessUnitOutcomes` is the organizer-manager-only,
App-Check-protected writer. Its generated request carries `expectedRevision`, one round
index, and a complete unit-entry set. Exact replay is idempotent before revision
checking. A correction replaces that round: score projections are recomputed
as accumulated totals, while rank projections use the latest complete ordering.
`completion` persists source facts without creating a standings projection;
`none` rejects recording.

`contracts/firestore/event_success_standings.schema.json` owns the derived
`eventSuccessStandings/{eventId}` snapshots for `score` and `rank`. Authorized
Hosts, active participants, and ready no-download runtime identities may get
the event-scoped projection; list and every direct write are denied. The
projection stores a snapshot for each recorded round so Flutter and the guest
runtime can select only the latest snapshot at or before the plan's published
reveal round. It reuses `publishedRevealRoundIndex` and the existing
server-anchored reveal state; it does not define a second ceremony or cursor.

### TypeScript Timestamp Projections

Functions code has two generated TS projections for Firestore documents. Both
come from JSON Schema; the boundary is the timestamp representation:

- **`functions/src/shared/generated/*.ts` — JSON Schema-derived.** Timestamps
  appear as serialized `{_seconds: number, _nanoseconds: number}` objects.
  Use for callable payload validation, fixtures, demo seed data, and any code
  that reads or writes the persisted JSON shape directly.
- **`functions/src/shared/generated/firestoreAdminTypes.ts` — Admin SDK
  projection.** Timestamps appear as `FirebaseFirestore.Timestamp` instances.
  Use when Functions code interacts with Admin SDK methods that return live
  Timestamp objects, for example `doc.data()` after a Firestore read.

`tool/contracts/generate_schema_contracts.mjs` emits both projections.
`tool/contracts/check_firestore_contract.mjs` cross-checks that the Admin SDK
projection has the expected fields for every collection with a
`typescriptInterface` entry.

### Public HTTP And Admin Callable Boundaries

The public `/api/join-waitlist` endpoint uses the versioned schemas under
`contracts/http/` for both member waitlist and optional Host application
payloads. The generator emits the same types into website and Functions code;
Functions validates incoming requests and every JSON response, while the
website validates response JSON before treating a submission as successful.

High-risk Admin overview, access-decision, role, safety, and marketing mutation
requests/responses use dedicated schemas under `contracts/callables/` and
`contracts/callable_responses/`. The generator emits Functions and Admin types,
and `admin/scripts/generateCallableValidators.mjs` compiles the same schema
sources into the browser runtime validator registry.

## Organizer Authority

`organizers/{organizerId}` is the canonical organization entity. `club` is an
organizer subtype, never a peer top-level entity. The required
`organizerType` enum is `club`, `community`, `individual`, `eventProducer`,
`venue`, or `brand`; no legacy `entityKind` value is read. Missing
`appVisibility` fails closed as `hidden`. The complete
mapping, rollout, parity, and recovery procedure is owned by
`docs/migrations/clubs_to_organizers.md` and
`contracts/migrations/clubs_to_organizers.json`.

New contracts use `organizerId`, `organizerTeamMemberships`,
`organizerFollows`, `organizerClaimRequests`, `organizerScheduleLocks`, and
`organizers/{organizerId}/posts`. Legacy `clubs`, `clubMemberships`,
`clubClaimRequests`, `clubScheduleLocks`, `clubId`, and club-media projections
are not local contracts, callable aliases, rule paths, or client fallbacks.
Production canonical parity completed on 2026-07-22; because the application
has not launched, the owner approved local compatibility retirement rather than
a released-client support window. Remote synthetic-data reset and deployment
remain separately authorized operations.

Public organizer website content is also owned by the canonical organizer
document. `publicPage` controls publication, indexing, canonical and legacy
paths; `publicProfile`, `publicSources`, `provenance`, `claim`, and `ownership`
provide the owner-safe projection inputs. Production Hosting exports those
fields from Firestore at build time. Repository JSON must not be used as the
editing or approval surface.

Organizer document identity and public routing are separate contracts.
`organizers/{organizerId}` uses an opaque Firestore auto-id. A client may
reserve that auto-id before uploading media, but a name or URL slug is never
accepted as the document id. `publicPage.slug` owns the human-readable route
segment, `publicPage.canonicalPath` owns the website URL, and
`publicRouteReservations` transactionally enforces route uniqueness. Renaming
or rerouting an organizer therefore does not require changing its document id
or relationship references.

### Organizer Supply Capabilities

Every canonical organizer, compatibility club projection, and published
external-event organizer snapshot carries the shared
`organizerSupplyCapabilities` contract. It is an explicit product-policy
projection, not a UI inference:

- unclaimed/programmatic supply is not bookable, payable, waitlistable, or
  host-contactable; it is claimable and becomes reviewable only after the
  event's end time;
- claimed/owner-managed supply may enable the supported capabilities, subject
  to the normal event, payment, and availability checks;
- missing or invalid capabilities fail closed.

Create, claim, draft-scaffolding, and claim-decision callables write the
projection. Existing canonical and compatibility documents were repaired with
`tool/data/backfill_organizer_supply_capabilities.mjs`: the production apply on
2026-07-27 repaired 44 organizers and 42 clubs, found no external events, and a
post-apply dry run reported 86 current documents with zero repairs or invalid
records. The migration contract is
`contracts/migrations/organizer_supply_capabilities.json`.

### Required Event Meeting Location

Every persisted `events/{eventId}` and published external event must have a
named, finite, in-range exact location. The canonical object is
`meetingLocation`; `meetingPoint`, `startingPointLat`, and `startingPointLng`
remain synchronized compatibility mirrors while released clients still use
them. They are not nullable escape hatches.

- Create requires an exact scalar pair and canonicalizes it into
  `meetingLocation`; newer clients may send the structured object directly.
- Update resolves the existing or supplied exact location and always rewrites
  the canonical object plus mirrors. It rejects a truly coordinate-less legacy
  document instead of preserving corruption.
- Dart `Event` and `ExternalEvent` keep exact coordinates nullable on reads
  until the production repair is complete. `Event.effectiveMeetingLocation`
  deterministically promotes a complete legacy pair, while coordinate-less
  records remain readable and fail closed anywhere an exact location is
  required.
- Discovery and proximity check-in fail closed when the invariant is broken;
  they never publish a null geo cell or skip the distance guard.
- `node tool/data/backfill_event_meeting_locations.mjs --env <env>` is the
  dry-run-first repair path. It never invents coordinates or mixes latitude
  and longitude from different sources.

Dev was verified clean on 2026-07-13: 146/146 events have structured exact
locations and the location-market and discovery repair tools report zero
remaining work. The production dry run found 138 deterministic repairs and 9
historical records without recoverable coordinates; production was not
mutated, and strict production rollout remains blocked on resolving those nine.

## Normal Workflow

```bash
node tool/contracts/generate_schema_contracts.mjs
node tool/contracts/generate_schema_contracts.mjs --check
node tool/contracts/validate_schema_contracts.mjs
./tool/check_data_contract.sh
```

Run Firestore and Storage rules tests through emulators unless those emulators
are already running:

```bash
firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"
```

A direct `npm --prefix functions run test:rules` expects Firestore on
`127.0.0.1:8080` and Storage on `127.0.0.1:9199`. `ECONNREFUSED` is an emulator
workflow failure first, not proof the rules are wrong.

Storage rules that call Firestore have a second, live dependency which the
emulators cannot prove. Every environment's Firebase Storage service agent must
hold `roles/firebaserules.firestoreServiceAgent`; the checked preflight and
idempotent provisioner are documented in `docs/release_operations.md`. Keep
each Storage evaluation within Firebase's Firestore document-access limit.
Match chat images therefore authorize from the canonical match document, whose
`status: blocked` projection is owned by the block callable/trigger. Their
contract also requires immutable `uploaderUid` custom object metadata: only
that active-match participant may create or compensate-delete the object, and
client updates are denied. Prove this boundary with both emulator rules tests
and the authenticated live upload/delete canary.

### Host Payment Account Provider Boundary

`hostPaymentAccounts` is a user-and-provider projection owned by payment
callables. New documents use `{uid}_{provider}` ids and must carry the explicit
`provider`, generic `providerAccountId`, and provider-specific identifier
fields from `contracts/firestore/host_payment_accounts.schema.json`. The
provider enum is currently `razorpay | stripe`. Legacy Stripe documents at
`{uid}` remain readable and refreshable; new Stripe and Razorpay writes use the
provider-scoped ids so one host can retain both accounts without overwriting
either state.

Razorpay Route setup accepts legal-business, stakeholder, PAN, and bank details
through the callable payload contract. Those values are transient provider
inputs and must never be written to Catch Firestore or logs. The persisted
projection contains only Razorpay linked-account/product ids, normalized
activation state, and bounded requirements. Each provider-created id is
checkpointed before later provider calls so an exact retry resumes the same
linked account or product.

The Flutter repository returns a list of provider accounts. Country-based
recommendation is presentation policy only: India recommends Razorpay and
other countries recommend Stripe, while both setup paths remain available.
Checkout routing and eventual settlement remain server-authoritative and must
not infer readiness from the recommendation badge alone.

## Contract Architecture

JSON Schema draft-07 is the canonical persisted-shape format. Ajv validates
schemas in Functions/tooling, generated Dart constants support Flutter tests and
selected production validation, and Firestore rules remain behavioral security
checks rather than a generated JSON Schema runtime.

The contract layer owns:

- collection ids and storage paths;
- full document shapes and patch/input payloads;
- enum values and scalar limits;
- field optionality/nullability;
- prompt/catalog ids and limits;
- ownership metadata such as client-writable, callable-owned, trigger-owned,
  server-only, and read-only projection (see "Field Ownership Tags" below);
- migration metadata for path/storage renames;
- valid and invalid fixtures.

### Optional, Nullable, And Patch Fields

Default DTO, view-model, and document fields to plain nullable values when
absence and explicit `null` have the same product meaning. Use required
nullable parameters only when the caller must explicitly confirm that the field
was considered, and prefer avoiding that shape unless it materially improves the
API contract.

Use sentinel-backed parameters only for patch/copy APIs where "leave unchanged"
must be distinguishable from "clear this nullable field." Generated patch
classes use `unsetSentinel` from `lib/core/sentinels.dart` and compare it with
`identical`; callers should pass `null` only when the persisted value should be
cleared. Do not add new ad hoc sentinels outside patch/copy semantics without
first documenting the same clear-versus-omit distinction.

### Field Ownership Tags

Per-field ownership lives next to the property in the Firestore schema as
`x-catch-ownership`. Valid values: `client-writable`, `client-runtime-writable`,
`callable-owned`, `trigger-owned`, `server-only`. Properties without a tag are
unclassified — typically content fields that flow through a callable without
the callable owning their lifecycle.

```json
"hostUserId": {
  "$ref": "../shared/event_common.schema.json#/definitions/documentId",
  "x-catch-ownership": "callable-owned"
}
```

`tool/contracts/firestore_contract.json` deliberately does NOT carry
per-collection field-group arrays (`clientWritableFields`, etc.). Those are
derived from `x-catch-ownership` and validated by
`tool/contracts/check_firestore_contract.mjs`. The contract file still owns
collection-level ownership metadata (paths, rules-match strings, operations,
exported function names, migration notes).

It does not own multi-document business behavior, ranking algorithms,
notification fan-out, dynamic Auth/current-time checks, or full Firestore rules.
Those stay in Functions, repositories, rules, and domain services, consuming
generated constants/validators where useful.

### Generated Dart Callable Request DTOs

`tool/contracts/generate_schema_contracts.mjs` emits typed Dart classes for
every callable payload schema (and the `update_user_profile` patch) into
`lib/core/schema_contracts/generated/callable_request_dtos.g.dart`. Each class
has a named-parameter constructor, typed fields, and a `toJson()` that the
existing `test/core/callable_dto_contracts_test.dart` validates against the
source schema. Generated patch helpers expose `toFieldsJson()` for repository
tests and `toCallableJson()` for the actual callable payload wrapper.

Feature-level `lib/**/data/*_callable_dtos.dart` files remain only when they
own hand-written response parsers, normalization, or other behavior. Pure
re-export barrels should be deleted; callers can import generated request DTOs
directly from `callable_request_dtos.g.dart` with explicit `show` lists.
Hand-written DTO classes remain in feature files only when the JSON Schema
cannot capture the behavior — specifically:

- domain → DTO adapter factories (`CreateEventCallableRequest.fromEvent(Event)`)
  that walk a domain model and convert `DateTime` → `int millis`;
- serialization-time normalization that the generated class does not yet own
  (`EventBookingCallableRequest` and `CreateRazorpayOrderCallableRequest` trim
  `inviteCode` even though dedicated payload schemas exist);
- serialization-time shape transforms (e.g.
  `PlacesAutocompleteCallableRequest` flattens a `LocationCoordinate? bias`
  into top-level `latitude`/`longitude`);
- response decoders (`*CallableResponse` with `fromCallableData` factories)
  and feature-local exceptions.

See backlog item `CONTRACT-DART-GEN-001` for the path to migrating the
remaining cases (custom normalization, generated adapters, and response
decoders).

### Field Constraint Projection

The schema generator also emits
`lib/core/schema_contracts/generated/field_constraints.g.dart`. It projects
UI-relevant requiredness, value and item types, string length, format, pattern,
enum values, collection bounds, uniqueness, numeric bounds, and `multipleOf`
steps from every registered schema into typed
`CatchContractFieldConstraints` constants. The projection includes persisted
documents, callable payloads, and `contracts/forms/mobile_form_state.schema.json`
for editable presentation values that are deterministically transformed before
they are stored.

`CatchContractFieldPolicy` applies those constants at runtime. Text controls
derive validators, counters, and length formatters; choices filter values
through an explicit typed-to-wire serializer; steppers and range sliders derive
bounds and steps. Explicit UI values may narrow a contract for product policy
but cannot relax it. Composite controls bind each independently stored endpoint.

Every editable canonical control and descriptor instance under production
`lib/` is covered by the source scanner. Its optional report is generated at
`build/reports/flutter_form_contract_inventory.json`. The scanner
recognizes `CatchField`, `CatchChipField`, selectable chips, option groups/cards,
range sliders, toggles, OTP entry, direct and top-bar search fields,
`CatchForm*Row`, and the retained self-profile descriptors. It fails when a
control lacks its generated contract, a typed choice lacks its serializer, a
range lacks either endpoint, or an exemption is not explicit. The current two
exemptions are disclosure-only Host analytics controls, not editable form
values.

Run the exhaustive gate with:

```sh
node tool/run.mjs check contracts:flutter-form-inventory
```

`test/core/forms/contract_alignment_test.dart` additionally walks the
consumer-profile and host-club descriptor factories and contains a seeded
over-limit probe, so contradictory limits remain detectable. Run it through
`node tool/run.mjs check contracts:form-alignment`. Contract CI runs both gates
and keeps the generated schema projection deterministic with the generator's
`--check` mode.

## Relationship Documents

Root-level edge/action documents are the source of truth for many-to-many state:

| Relationship | Source document |
|---|---|
| Organizer owner/manager seat | `organizerTeamMemberships/{organizerId_uid}` |
| Organizer follow | `organizerFollows/{organizerId_uid}` |
| Event booking, waitlist, attendance, cancellation | `eventParticipations/{eventId_uid}` |
| Unified Host operational roster row | `eventAttendees/{attendeeId}` |
| Roster import audit and idempotency receipt | `eventAttendeeImports/{importId}` |
| Private no-download Event Success identity | server-owned `eventRuntimeParticipants/{eventId_uid}` |
| Short-lived Host venue authority | server-only `eventVenueSessions/{sessionId}` |
| Per-attendee venue redemption | server-only `eventVenueSessionRedemptions/{sha256(eventId_sessionId_uid)}` |
| Ambiguous or walk-in Event Success claim review | server-owned `eventRuntimeClaimRequests/{eventId_uid}` |
| Organizer-scoped communication permission | server-only `organizerCommunicationPreferences/{organizerId_uid}` |
| Organizer-scoped operational contact | server-only `organizerContacts/{contactId}` |
| Contact-to-event fact | server-only `organizerContactEventEdges/{attendeeId}` |
| Contact identity evidence and verified claim | server-only `organizerContactIdentityLinks/{evidenceId}` and `organizerContactIdentityClaims/{claimId}` |
| Contact merge decision and reversible receipt | server-only `organizerContactMergeReviewDecisions/{decisionId}` and `organizerContactMergeReceipts/{receiptId}` |
| Rebuildable contact traits and organizer summary | server-only `organizerContactTraits/{contactId}` and `organizerAudienceSummaries/{organizerId}` |
| Invitation aggregate and isolated bearer token | host-readable `eventInviteLinks/{inviteLinkId}` and server-only `eventInviteLinkSecrets/{inviteLinkId}` |
| Short-lived invite open/share evidence | server-only `eventInviteTouches/{touchId}` and `eventShareIntents/{intentId}` |
| Verified registration/check-in attribution | server-only immutable `eventInviteAttributions/{attributionId}` credit/reversal fact |
| Organizer campaign and recipient snapshot | server-only `organizerCampaigns/{campaignId}` and `organizerCampaignRecipients/{recipientId}` |
| Organizer Announcement history projection | server-only `organizerBroadcastSummaries/{broadcastId}`; manager clients use `listOrganizerCampaigns` and contact-detail callables |
| Organizer WhatsApp sender/template state | server-only `organizerSenderConnections/{connectionId}`, `organizerMessageTemplates/{templateId}`, and webhook receipts/events |
| Organizer WhatsApp Inbox and reply reservation | server-only TTL-bound `organizerWhatsappThreads/{threadId}`, `organizerWhatsappMessages/{messageId}`, and `organizerWhatsappReplyOperations/{operationId}` |
| External provider connection and event mapping | server-only `organizerProviderConnections/{connectionId}`, `externalEventMappings/{mappingId}`, and `providerSyncRuns/{runId}` |
| Event-scoped staff authority | server-owned `eventStaffGrants/{eventId_uid}` with direct reads denied |
| Cross Paths event visibility | `eventCrossPathsConsents/{eventId_uid}` |
| Cross Paths showcase eligibility | server-only `crossPathsShowcaseEligibility/{uid}` |
| Cross Paths suggestion exposure | server-only `crossPathsSuggestionExposures/{exposureId}` |
| Cross Paths invitation | `crossPathsInvitations/{eventId_senderUid}` |
| Cross Paths companion hold | `crossPathsPairHolds/{holdId}` |
| Cross Paths accepted event plan | `matches/{event_pairHash}` with `conversationType: crossPathsEventPlan` |
| Saved events | `savedEvents/{uid_eventId}` |
| Outgoing profile decisions | `profileDecisions/{uid}/outgoing/{targetId}` |
| Match messages | `matches/{matchId}/messages/{messageId}` |
| Notification timeline | `notifications/{uid}/items/{notificationId}` |
| Organizer follower posts | `organizers/{organizerId}/posts/{postId}` |

Retired relationship arrays must not be reintroduced into Flutter models,
Functions writes, Firestore rules, active tooling, or tests. Parent entity docs
keep only aggregate projections such as `followerCount`, `bookedCount`,
`waitlistedCount`, `checkedInCount`, `genderCounts`, `rating`, `reviewCount`,
and `nextEventAt`.

Direct client writes are still allowed only for narrow owner-owned actions that
rules can prove locally: onboarding drafts, launch access applications, saved
events, outgoing profile decisions, match-scoped chat messages, own unread
reset, own notification `readAt`, and own FCM token. The
`accessApplications/{uid}` rule accepts only the authenticated owner's strict
application shape while its status is editable, increments `submissionCount`,
and preserves Admin-owned status, cohort, reviewer, and activation fields.
Multi-document product writes belong in callables or triggers.

Raw `eventParticipations` reads are equally narrow: a participant may read
their own deterministic edge, and an authorized event host may read the roster
for an event they manage. Consumer discovery surfaces must not query a whole event
roster. Post-event Catch, Event Recap, and identified post-event avatar
enrichment use the App-Check-protected `fetchSwipeCandidates` callable, which
returns only public profile projections after the server verifies the
24-hour window, viewer attendance, reciprocal gender and age preferences,
prior decisions, and blocks in both directions. Anonymous attendee volume is
rendered from callable-owned event aggregates instead of roster enumeration.

### Standalone Host Operational Attendees

`eventAttendees` is the Host operations roster. It complements rather than
replaces `eventParticipations`:

- `eventParticipations` requires a real UID and continues to own Consumer
  booking, waitlist, cancellation, payment linkage and profile/network
  eligibility;
- `eventAttendees` uses an opaque event-scoped attendee id and accepts
  `catchBooking`, `hostImport`, `hostManual`, or `webOtp` as its source. Its
  optional `linkedUid` is a server projection, never a synthetic account;
- raw contact fields are private to an authorized organizer manager and
  callable/Admin support boundaries. Public website, Consumer discovery and
  aggregate analytics cannot enumerate them;
- a Catch booking may use the Firebase Auth verified phone only to converge
  with an event row whose contact data the organizer already supplied. It
  never copies `users/{uid}.phoneNumber` or `users/{uid}.email` into a new
  attendee row, organizer event edge, or CRM contact;
- the production website snapshot uses Firestore `count()` aggregation queries
  for registered, checked-in, and waitlisted totals. Only free,
  open-admission events with an explicit Host publication switch qualify; paid,
  invite, membership, approval, and profile-balanced events fail closed. The build identity never
  downloads attendee documents or contact fields;
- direct writes are denied. Host bulk import/manual entry, attendance changes,
  Catch-booking projection, OTP linking and public registration are
  server-owned operations;
- deterministic contact/source keys make retry and re-import idempotent inside
  one event. A phone/email match may converge rows inside that event only; it
  does not build a cross-event identity graph;
- `arrivalGroup` retains an optional provider booking/order/group or
  ticket-buyer key shared by guests expected to arrive together. Adapters keep
  it separate from attendee-level external references, imports include it in
  their canonical payload hash, and it remains private roster data;
- optional attendee revenue fields retain organizer-reported CSV amounts,
  explicit organizer-entered per-guest estimates, or financially complete
  provider facts with their currency and allocation provenance. Repeated equal
  imported totals in one `arrivalGroup` are treated as one shared order and
  allocated across its guest rows exactly once. These facts never become
  verified Catch payments by inference;
- `eventAttendeeImports` records actor, event, client idempotency key, format,
  canonical payload hash, counts, bounded row errors and terminal state. It is
  not a copy of the uploaded file.

Hosts may list operational attendees and import receipts only for events they
manage. An attendee does not gain roster-list access when their UID is linked;
attendee-facing code receives only its own sanitized event state through a
server-owned lookup/registration boundary.

Phone-OTP public registration creates or reuses a private Firebase Auth UID; it
does not create `users/{uid}`, `publicProfiles/{uid}`, or a Consumer
`eventParticipations` edge. On first registration, the callable may create a
private `onboarding_drafts/{uid}` seed using only the attendee-supplied display
name and verified phone. That seed is a continuation convenience for a later,
intentional Consumer onboarding flow, not a profile or advertising permission.
The person must review/edit the draft before any public or dating-profile
projection is created.

### External Booking Event Success Runtime

An event may carry optional server-owned `eventOrigin` and `runtimeAccess`
objects. Their absence preserves legacy behavior. `eventOrigin.mode` records
whether Catch owns the booking (`catchNative`) or overlays an event booked on
another provider (`externalCompanion`); its provider/source identifiers are
provenance, not a claim that Catch owns or has synchronized the source event.
`runtimeAccess.publicRuntimeId` is an opaque join identifier, never the event
document id or a bearer authorization credential. The runtime bootstrap
callable resolves it and returns only a bounded public event projection. That
projection includes non-negative aggregate `checkedInCount` for the anonymous
co-presence visual; it does not include a roster, attendee identifiers, or
per-attendee attendance state.

`eventRuntimeParticipants/{eventId_uid}` is the private bridge between a
Firebase phone-auth identity and an event-scoped operational attendee. It owns
the claim method, optional `eventAttendeeId`, minimum runtime-profile fields,
explicit terms versions, and readiness state. It does not create or imply a
Consumer `users/{uid}`, `publicProfiles/{uid}`, `eventParticipations/{eventId_uid}`,
dating match, or marketing grant. Clients may get only their own deterministic
edge; list and direct writes are denied. Event Success modules authorize a
`ready` runtime edge independently of the Consumer booking/network edge.

Attendance authority is separate from runtime identity and joinability.
`eventVenueSessions/{sessionId}` backs a short-lived signed token issued only to
an organizer manager during the check-in window. The Host screen refreshes it
before expiry. `eventVenueSessionRedemptions/{sha256(eventId_sessionId_uid)}`
atomically binds one authenticated attendee to one displayed session and rejects
replay by that attendee; different attendees may redeem the same live display.
Both collections deny all direct client access and use `expiresAt` TTL. A static
`publicRuntimeId` URL, printable event QR, or latitude/longitude claim carries no
attendance authority.

When the verified phone cannot be matched unambiguously, or when the event's
walk-in policy requires review, the server writes
`eventRuntimeClaimRequests/{eventId_uid}` with only the last four phone digits
and bounded candidate attendee ids. Authorized organizer managers may review
that request through a callable. A rejection cannot expose alternative roster
identities to the claimant.

The minimum event-scoped questionnaire is plan-derived. Display name is always
required; sensitive or compatibility fields are requested only when an enabled
module needs them. Saving the answers as a later Catch onboarding prefill is a
separate explicit consent. A prefill remains private and must never overwrite a
completed Consumer profile or create a public projection.

### Organizer Communication Preferences And CRM

`organizerCommunicationPreferences/{organizerId_uid}` is a server-only,
organizer-scoped permission ledger. WhatsApp and SMS each have independent
`unknown`, `optedIn`, or `optedOut` state, terms version, source event, source,
and timestamp. Public registration writes only an explicit checked opt-in. An
unchecked box does not grant permission and cannot revoke a prior grant;
withdrawal belongs to the future self-service/STOP callable. Host imports and
manual roster entry never create channel permission.

Each non-unknown channel preference carries a permission receipt sufficient to
explain the decision without reading private response content: source kind,
nullable source event/form/response ids as applicable, terms version, consent
copy hash, grant timestamp, and nullable revocation timestamp/source. A legacy
row without complete evidence remains explicitly incomplete or unknown; a
backfill must never infer or promote permission from a phone number, contact
source, roster membership, form answer not bound to the reviewed consent copy,
or prior send.

`tool/data/backfill_organizer_crm_authority_v2.mjs` is the dry-run-first
additive migration. It creates contact origins only when a canonical attendee
edge names both current and original contact identity. Existing non-unknown
preference state without a complete referenced receipt becomes an immutable
`legacyIncomplete` receipt and remains ineligible for managed delivery. The
tool reports, rather than guesses, attendee rows whose canonical edge is
missing. The migration is available in source but has not been applied to any
environment.

`organizerContactOrigins/{originId}` is the immutable multi-source provenance
ledger for organizer CRM contacts. Each deterministic row records organizer,
current contact, origin contact, source kind, source entity kind/id, nullable
form/event/response ids, actor class and bounded actor uid where appropriate,
observed time, and creation time without copying raw response or message bodies.
Merges may move the current contact id while retaining the origin contact id;
unmerge uses receipt-named origin facts and never guesses later ownership.
`organizerContacts.primarySource` remains a compatibility summary during the
additive migration and is not a complete history.

Every canonical `eventAttendees` write projects into an organizer-scoped
contact plus one event fact edge. A contact is operational memory for one
organizer, not a Consumer profile. An imported normalized phone/email creates
only proposed identity evidence; it never silently merges two people. A UID or
person-verified OTP phone may own a singleton identity claim. Conflicting
verified claims stop automatic convergence and require an immutable,
reversible manager merge receipt. Name alone is never merge evidence.

Manager merges are optimistic and receipt-backed. The client supplies the
current survivor and source revisions; the transaction also verifies every
source-origin fact has the same Firestore version observed during planning.
Conflicting UID, phone, or email facts require explicit confirmation. Unmerge
restores only the exact source-origin edge, evidence, claim, and contact-origin
identifiers in the original receipt and creates one deterministic reversal
receipt. Facts
created after a merge remain with the survivor instead of being guessed back.
The manager review boundary lists conflicted verified UID/phone claims plus
exact proposed phone/email hashes. It derives shared events, source kinds and
confidence at read time, never proposes name-only matches, and stores a
`organizerContactMergeReviewDecisions` row when a manager chooses Different
people. Only that manager may reopen the decision. Contact detail returns the
newest active merge receipts for the survivor so each receipt can be reversed
individually.

Account deletion is the only erasure exception to receipt and origin retention:
it deletes permission receipts carrying the participant UID and redacts that
UID from retained contact-origin facts while preserving non-PII source
classification.

`organizerContactTraits` are rebuilt from event edges and verified invite
attribution facts and contain only
attendance, reliability, source and channel-reachability facts. Compatibility
answers, gender, sexual orientation, relationship state, wingman targets,
safety reports and inferred social desirability are prohibited CRM inputs.
An `advocate` has at least one verified referred registration or check-in. A
`high_impact_advocate` has at least three referred verified check-ins in the
trailing 365 days; raw link opens and share-button taps never qualify.
`past_attendee` is the canonical broad attendance segment for at least one
checked-in event; `repeat_attendee` begins at two. New definition-v3 trait rows
store both the broad and applicable narrower segment. Directory, export, and
saved-audience evaluation still resolve `past_attendee` from
`attendedEventCount > 0`, so older trait rows remain correct before they are
recomputed and clients never union independently paginated segment results.
Trait and summary writes use exactly-once TTL receipts, so retries cannot
double-count an organizer. The dry-run-first organizer-audience backfill uses
the same production projector and marks a summary `exact` only after every
current attendee row has completed. Its discovery set is the union of attendee,
contact, and incomplete-summary organizers, so a manual-only organizer with
zero attendees can still be completed. Newer live rows always win over stale
backfill snapshots. A missing or partial summary is also effectively `exact`
when a bounded canonical-history check proves that the organizer has no
`eventAttendees`; absence of projection state alone is not treated as an
incomplete migration.

`getOrganizerCrmSummary` reads `organizerAudienceSummaries` only when its
coverage is `exact` and returns only privacy-bounded counts for contacts, past
and repeat attendees,
linked accounts, imports, and explicit WhatsApp/SMS reachability. During the
dual-write migration it falls back to the legacy bounded attendee/preference
scan for organizers without exact coverage. Partial summaries remain migration
diagnostics and never replace the legacy cards. It never returns attendee
identity or contact fields. `listOrganizerContacts` and
`getOrganizerContactDetail` are separate manager-authorized, server-paginated
boundaries. They return only organizer-owned endpoints plus explainable
attendance/reachability facts; no Event Success private input is a CRM field.
The directory accepts `lastSeen`, `mostAttended`, or `name`; every opaque cursor
is versioned and bound to its query plan, filters, and ordering. Filtered sorts
are computed over a bounded complete candidate set rather than sorting one
already-paginated page, and an over-limit candidate set fails explicitly.
`createOrganizerContact` requires a contact name plus at least one
organizer-entered phone/email evidence value, may add an optional first private
note, and creates its zero-history
trait. Organizer-entered endpoints remain `proposed`, organizer-scoped evidence:
they create no attendee, verified identity, UID, Consumer profile, opt-in, or
messaging grant. Only unlinked contacts whose primary source is `hostManual`
may later edit those endpoints but cannot remove its last endpoint. Legacy and
system-derived name-only records remain readable and can still rename without
being forced through a migration. Customer detail unifies event-scoped
revenue from completed, non-refunded Catch payments, financially complete
provider orders, organizer-imported amounts, and explicit organizer estimates.
Every amount retains its source; reported and estimated values are never
presented as verified payments. A Catch payment takes precedence over a
reported fact for the same customer event so the sale is not counted twice.
Imported and estimated revenue does not require a linked Catch UID. Event rows
hydrate the bounded canonical event set so legacy edges immediately receive an
event label and Catch-native, external-companion, or unknown origin; new edge
projections also retain that snapshot. Revenue reports partial coverage when
the bounded event timeline or an eligible linked-UID payment scan truncates.
Hosts currently retain event-scoped roster access through the existing
authorized roster boundary. The Host Audience client consumes the directory,
detail, export and contact-mutation callables; it never reads these collections
directly. Organizer-authored CRM memory remains structurally separate from
computed traits: `organizerContacts.manualTagIds` references a maximum of five
entries from the organizer's server-owned
`organizerContactTagVocabularies/{organizerId}` document, whose vocabulary is
capped at twenty. `organizerContactNotes` stores author-stamped note records;
new notes append, edits use optimistic revisions, contact detail returns the
newest bounded window, and exports never include note content. Existing contact
documents may omit `manualTagIds` and read as an empty assignment, so neither
feature requires a backfill.

`organizerSavedAudiences/{audienceId}` owns reusable Customers-authored CRM
audiences. A definition contains one to eight predicates joined by `all` or
`any` over the reviewed computed-segment, organizer-tag, attendance-count,
last-seen recency, and named-intent reach vocabulary. Arbitrary collection
paths and raw Firestore queries are forbidden. The server canonicalizes and
hashes definitions, validates organizer-owned tags, and applies optimistic
revisions. Preview returns exact coverage or an explicit incomplete/over-limit
failure; the bounded evaluator refuses organizers above 2,500 active contacts
instead of truncating. Event-scoped Booked/Prospective audiences remain event
authority and
are referenced directly by event-announcement sends rather than copied into a
CRM audience. Campaign approval freezes resolved recipient ids and revisions;
the selected saved audience id, revision, and definition hash remain on the
campaign. A changed or archived definition blocks draft preview/approval but
does not rewrite an already approved send. Campaign preview also persists an
exact audience-state hash; approval requires the current resolution to match it
before freezing recipients, so a count-preserving membership change cannot
silently pass.

`organizerManualSendTasks/{taskId}` is the server-only durable external-handoff
queue. One task represents one organizer, contact, originating send, intent,
route, permission/capability snapshot, idempotency key, endpoint snapshot/hash,
bounded prefill content with TTL, and progress state. Its only progress states
are `queued`, `handoffOpened`, `hostMarkedSent`, `skipped`, `cancelled`,
`superseded`, and `expired`; it has no delivered/read state. Opening an external
application records only `handoffOpened`. The prepare callable persists or
returns the idempotent queued task only after current manager, contact, endpoint,
permission, and route checks; the client performs the external launch and then
acknowledges the accepted launch against the current revision. An exact prepare
retry revalidates the existing task rather than bypassing those checks. Tasks
opened again from the durable queue first pass a revision-bound, read-only
callable that rechecks the current contact, endpoint, permission, suppression,
and route and returns the already-bounded task payload. The open acknowledgement
repeats those checks after device acceptance; neither check mutates or sends.
Existing tasks never auto-dispatch after a capability change. An explicit host
re-plan rechecks
current authority and returns advice only; it does not write, supersede, remove,
complete, or dispatch any task. A separate explicit host action is required to
close manual work. Active queue reads apply the server-time expiry bound in the
indexed query rather than waiting for asynchronous TTL deletion to hide stale
work.

`organizerContactActivity` is a callable-composed bounded cursor projection,
not a client-readable master collection. It joins sanitized origin, form or
application, attendance, note, permission, send/reply and merge facts for one
active organizer contact. Each row has a typed kind, stable source id,
occurred-at time, safe display payload, and coverage metadata. It never copies
private Consumer profile, compatibility, safety, wingman, raw provider receipt,
or unrelated organizer content.

Contact detail also reads the bounded newest campaign-recipient window from
`organizerCampaignRecipients` and joins safe campaign labels and delivery
state. `sendEventBroadcast` also writes one organizer-scoped
`organizerBroadcastSummaries/{broadcastId}` projection after it finalizes the
server-only operational receipt. Contact detail joins only summaries whose
bounded `recipientContactIds` contains the contact and returns the sanitized
Announcement label, audience, time and available/failed delivery state. It
never exposes message bodies, raw receipt evidence or cross-organizer history.
Campaign approval freezes a server-owned recipient snapshot and
dispatch rechecks current permission, contact suppression, sender/template
health and event state before each attempt. Meta provider tokens live in Secret
Manager. Every environment pre-provisions one
`ORGANIZER_WHATSAPP_ACCESS_TOKENS` vault; each organizer connection is stored
as a distinct immutable secret version containing its organizer and connection
binding, and retired versions are disabled. The Functions runtime receives
secret-level accessor and version-manager roles on that vault only; it may not
create secrets or access unrelated application secrets. Existing raw-token
versions remain readable only for migration compatibility. Meta integration is
reported configured only when `META_WHATSAPP_ENABLED=true` and the real Meta
app/config credentials are present. Webhook receipts are signature-verified,
deduplicated and monotonic;
STOP updates the same organizer-scoped preference/suppression boundary without
creating analytics content. For one unambiguously resolved organizer contact,
the bounded inbound body is also copied into
`organizerWhatsappMessages/{messageId}` and summarized by
`organizerWhatsappThreads/{threadId}`. Both are server-only and carry a rolling
12-month `expiresAt`; the queue copy expires after 30 days. Manager callables
list and open these threads in the existing Inbox scopes. Free-form replies
require the current sender connection, unsuppressed contact state, an unchanged
latest-inbound timestamp, and an open 24-hour customer-service window; the
server rechecks all of those conditions even when the client composer appears
enabled. `organizerWhatsappReplyOperations` reserves each idempotency key before
the provider call, preventing concurrent duplicate sends and preserving an
unknown-outcome state when Meta acceptance cannot be confirmed. Account
deletion removes the onboarding draft, organizer communication grants, UID
identity evidence and verified UID claims. Retained operational attendee,
contact and event-edge history is unlinked from the deleted Catch UID.
Retained organizer roster history is unlinked by setting `linkedUid` and
`linkedAt` to null; any separately retained operational contact field remains
subject to the organizer's stated booking/records purpose rather than Catch
account or marketing permission.

### Person Data Lenses And Canonical Fields

Catch does not have one client-readable master person document. A verified
Firebase Auth identity, the participant's private profile, the dating feed
projection, portable application intake, organizer-submitted answers, and an
organizer's CRM history are separate authority and visibility lenses. A phone
match is an identity-resolution input only; it never grants an organizer access
to private-profile fields or another organizer's records.

| Lens | Canonical storage | Authority and visibility |
|---|---|---|
| Verified account identity | Firebase Auth plus the verified `users/{uid}.phoneNumber` mirror | Firebase Auth is authoritative for phone ownership. The private mirror is not a Host projection. |
| Private Catch/dating profile | `users/{uid}` | Participant-authored source used to build Catch experiences. Its presence does not authorize Host access. |
| Public dating projection | `publicProfiles/{uid}` | Server-derived, redacted feed shape only. A person-field mapping describes where a published value would land; it is not publication consent. |
| Portable application prefill | `participantIntakeProfiles/{uid}` | Participant-private, reviewed values for lower-friction future applications. It neither overwrites `users` nor becomes organizer-visible merely by existing. |
| Organizer application snapshot | `organizerApplicationResponses/{responseId}` plus `participantOrganizerDataGrants/{grantId}` | Exact questions answered for one application and the exact question/field grant receipt. This is the only application-field slice available to that organizer. |
| Organizer CRM/customer history | `organizerContacts` and its organizer-scoped event, note, trait, campaign, and commerce projections | Facts the organizer acquired through its own events and workflows. It must not be hydrated from private `users` fields merely because an identity link exists. |
| Platform reconciliation | Server-side joins across the preceding stores | Catch may resolve the same authenticated person across organizers, but employee-facing reads must remain purpose-scoped, role-gated, masked where possible, and audited. There is no universal raw-PII client projection. |

`contracts/catalogs/person_fields.json` is the single semantic registry for
portable person fields. It owns stable ids, normalized provider-header aliases,
native question kinds, import transforms, privacy classes, prefill review
requirements, Host presentation intent, authority, and structural private/public
profile mappings. The validator requires the organizer-application enum and
real profile paths to match the catalog. Generated Dart, Functions, and tool
registries consume it so Google Forms, Typeform, Fillout, CSV/XLSX, and future
native forms cannot maintain divergent alias maps.

The catalog is classification metadata, not permission. Its organizer policy
is `submittedQuestionGrantOnly`: a Host sees a field only when that organizer's
form asked the question and the response/grant records it. Its public-profile
mapping is also structural metadata only. Choice-shaped fields imported from a
table remain text until the source options are explicitly mapped, preventing a
provider export from silently inventing Catch choice semantics.

Age is derived from date of birth rather than a second mutable profile value.
Phone authority belongs to Firebase Auth even though `users.phoneNumber` keeps
a verified mirror. Provider-specific questions remain organizer-custom answers;
they are not added to this catalog merely because one provider or organizer
uses them.

Historical rows created before this boundary can be assessed with
`node tool/data/audit_legacy_host_contact_projection.mjs --env <environment>`.
The command is permanently read-only, omits raw phone/email values, and splits
exact unprovenanced private-profile matches from rows needing human
reconciliation. It also counts affected CRM edges and contacts. Any repair must
be a separate approval-gated operation because stale identity evidence and
organizer-supplied contact history must be reconciled together; age or source
labels alone are never deletion proof.

After an explicit repair approval, the only supported mutation path is
`node tool/data/repair_legacy_host_contact_projection.mjs`. It requires one
organizer, exact expected high-confidence and reconciliation counts, and both
production confirmation flags. Each row is reclassified transactionally before
phone/email are set to null. The current deployed attendee trigger must then
rebuild the event edge, contact, traits, identity evidence and audience summary;
the repair verifies that postcondition and removes only orphaned phone claims.
It never deletes an attendee, event, organizer contact, or organizer-supplied
contact fact, and never prints raw contact values.

### Generic Organizer Forms

`organizerForms/{formId}` owns generic Host form identity, target, lifecycle,
response counters, stable opaque `publicFormId`, and pointers to editable and
published content. `organizerFormDrafts/{formId}` owns the mutable definition
under an optimistic revision. Publishing copies that definition into immutable
`organizerFormVersions/{formId_vN}` and records `sourceDraftRevision`; an exact
retry reuses the active version instead of incrementing publication history.

`organizerFormResponseDrafts/{draftId}` stores a version-bound, expiring
respondent session with optimistic answer revisions. A submitted session
becomes one immutable `organizerFormResponses/{responseId}` snapshot containing
the published question identities, validated answers, submission consent, and
source-link attribution. An exact submit retry replays the same response;
withdrawal stamps that response instead of deleting the audit record.
`organizerFormShareLinks/{linkId}` owns organizer-created source tokens and
bounded attribution counters. A source token changes measurement only; it
never grants form-management, response, or Firestore authority.

All six collections are server-only. Organizer managers create, update,
validate, publish, pause, resume, archive, duplicate, delete eligible drafts,
and list bounded projections through App-Check-protected callables. Form lists
use the `organizerId + updatedAt desc + __name__ desc` index and opaque cursors;
archived forms are excluded by default. A `publicFormId` is a routing token,
not permission to read Firestore. The public `/f/:publicFormId/` route uses
callables for a safe active-version projection, anonymous or verified identity
bootstrap, autosave, submit, and withdrawal. Public reads never return draft
content, organizer-only metadata, other respondents, or response counters.

`contracts/catalogs/organizer_form_templates.json` is versioned source data.
Creating from a template copies it into organizer-owned draft state with new
section, question, and option identities, so catalog changes never mutate an
existing form. Duplicating a form remaps all nested identities and logic
references. The shared semantic validator permits invalid work-in-progress
drafts but blocks publication on identity collisions, invalid field/validation
combinations, stale logic references, backward section routes, target errors,
and purpose-specific requirements.

Generic Forms is the source for application, registration, intake, waiver,
feedback, and survey definitions. The existing application collections below
remain the application-review projection and import compatibility boundary;
they are not the generic response store.

### Organizer Application Intake

Organizer applications are a provider-neutral intake domain. A Google Form,
Typeform, Fillout form, spreadsheet, or future native Catch form is a source
edge; none of those providers owns the application model. The immutable
`organizerApplicationFormVersions/{versionId}` snapshot defines ordered
questions, canonical field mappings, participant-prefill eligibility, consent
copy, and retention copy. `organizerApplicationForms/{formId}` owns only the
mutable draft/published pointer and target kind. Publishing creates a new
version rather than changing the meaning of answers already collected.

`organizerApplications/{applicationId}` is the organizer-scoped workflow row:
source provenance, event/campaign target, applicant display projection, status,
review revision, and private reviewer note. The corresponding immutable
`organizerApplicationResponses/{responseId}` preserves the exact answer
snapshot and per-question consent evidence. Canonical contact fields and
organizer-only custom answers remain distinct even when they arrived in the
same spreadsheet row. An application is not the Consumer launch-access
`accessApplications/{uid}` document, a CRM contact, an event booking, or a
public dating profile. Review status alone creates none of those entities.

Portable participant prefill belongs in private
`participantIntakeProfiles/{uid}` only after an authenticated participant has
explicitly saved eligible fields. Private-profile and verified-Auth suggestions
may be shown to that participant, but every current form question must be
reviewed again before every submission. Authentication proves ownership of the
private suggestions; it grants the organizer nothing. Portable intake is
separate from `users/{uid}` and cannot overwrite an existing Consumer profile.
An organizer receives only the exact
fields and purpose recorded by
`participantOrganizerDataGrants/{grantId}` for that application/response; a
global phone or email
identity never implies cross-organizer visibility. Organizer-proprietary
questions such as a preferred cocktail remain in that organizer's application
response and are never promoted into the portable profile by default.
The native submission callable creates the response and grant atomically.
Revocation stamps only `revokedAt`, withdraws the review row, and immediately
makes manager list/detail projections mask the participant name and return no
answers or outreach actions; the immutable platform audit snapshot is retained.
Imported/connector data remains organizer-acquired and is labeled separately
instead of receiving a fictional participant grant. Field visibility is not
messaging permission: WhatsApp/SMS opt-in remains
exclusively in `organizerCommunicationPreferences`, and an application grant
cannot create or broaden it.

The provider-neutral import runtime accepts locally decoded CSV/XLSX tables, requires an
explicit mapping for every source column, imports at most 200 rows atomically,
and records a hash-bound idempotent receipt in
`organizerApplicationImportReceipts/{receiptId}`. Known identity/profile
headers map to canonical fields; all other columns remain organizer-only
questions. Hosts list, search, sort, inspect, and review only through manager
callables. Direct client access to forms, versions, applications, responses,
assets, source mappings, receipts, private intake profiles, and grants is
denied. Authenticated native form load/submission/revocation now use these same
contracts: suggestions are private and review-required, response snapshots are
server-built from the published question version, and grant-aware Host reads
enforce exact question/canonical-field ids. Provider connectors remain source
adapters over the same model, not provider-specific schemas.

The executable policies in `contracts/catalogs/person_fields.json` also bind
the role projections:

| Consumer | Allowed projection |
|---|---|
| Organizer manager | Exact active application grant, organizer-acquired CRM facts and notes, and event-scoped completed/non-refunded revenue aggregates. No payment instrument, billing address, provider secret, private dating/profile, feedback, safety or cross-organizer data. |
| Delegated event staff | One event's display name, ticket/registration state and attendance controls under an expiring grant. No CRM, application answers, campaigns, provider setup, commerce enrichment or contact endpoints. |
| Support | Masked, purpose-specific operational projections only. Raw PII is not the default support view. |
| Safety / Finance / Admin | Only the role- and workflow-specific projection required for the case; every action remains audited. Raw PII is break-glass only, never a universal employee client projection. |
| Catch backend | May reconcile the consolidated identity across private stores to enforce product, fraud, safety, finance and deletion duties, but must return only the projection authorized for the caller and purpose. |

### Provider Sync, Staff, And Offline Attendance

`organizerProviderConnections` contains safe organizer/provider identifiers,
capability coverage, state, freshness and a secret reference, never an API key.
`externalEventMappings` pins one Catch event to one external event and records
which fields the provider can authoritatively supply. `providerSyncRuns` owns
cursor, counts, state and sanitized errors. The implemented Luma poller imports
registration and provider check-in facts through the canonical attendee
reconciler. It does not invent orders, refunds, revenue, referral coverage or
webhook freshness that Luma has not supplied.

`eventStaffGrants/{eventId_uid}` grants a bounded subset of `viewRoster`,
`setAttendance`, and `reviewRuntimeClaims` for one event. It records organizer,
grantor, role, issue/expiry/revocation and revision; grants expire within 14
days and are capped at 50 active rows per event. Firestore direct access is
denied. Staff operate through callables and the restricted Host operator route,
which never grants CRM, campaign, import, provider, event-edit or organizer-wide
authority. Organizer managers continue to work without a grant.

The Host attendance outbox is local client state, not Firestore authority. It
contains no names, phones or emails: only account/event/attendee ids, absolute
desired attendance, expected revision, client operation id, timestamps and
retry/conflict state. Server authority remains `setEventAttendeeAttendance`
plus its 30-day receipt. Local operations review after seven days, expire after
30, cap at 200 and never turn a revision conflict into a silent toggle replay.

Cross Paths visibility is a two-part, private consent contract. The optional
`users/{uid}.prefsShowInCrossPaths` master preference resolves to false when
missing and is never projected into `publicProfiles`. The deterministic
`eventCrossPathsConsents/{eventId_uid}` edge records the per-event choice,
terms version, source, and consent/revocation timestamps. A caller may read only
their own edge; direct writes are denied. The App-Check-protected
`setCrossPathsEventConsent` callable is the sole writer and allows enablement
only when the private global preference is explicitly true, the event is active
and upcoming, and the caller owns a current `signedUp` participation. Disable
remains available after those preconditions disappear. Effective visibility is
the conjunction of both consent values plus later server-owned eligibility;
neither consent document alone authorizes an Explore identity. The optional
`events/{eventId}.crossPathsDiscoveryEnabled` field is a third, Admin-owned
pilot gate that defaults to false when absent. Enabling it is restricted to an
active upcoming Mumbai event (`discoveryMarketId: in-mh-mumbai`), a minimum
six-hour lead, and at most three selected upcoming events. An event may use its
canonical, bounded, organizer-controlled companion inventory policy; all hold,
capacity, payment, and release invariants remain server-owned. Disabling the
selected-event gate remains available and invalidates pending invitations
without silently closing an accepted event plan.

Cross Paths showcase eligibility is independently owned by the audited
`adminSetCrossPathsShowcaseEligibility` callable. The record contains only
`eligible`, `needsReview`, or `paused`, coarse reason codes, rule/review
versions, a SHA-256 public-profile fingerprint, the neutral human-review
checklist, reviewer identity/note, and timestamps. It never contains a numeric
attractiveness or desirability score. `adminListCrossPathsShowcaseCandidates`
projects bounded public-profile evidence plus effective status to authorized
reviewers; support is read-only. Approval requires objective readiness and the
complete checklist. Profile or rule changes invalidate approval at read time.
Firestore rules deny every client read/write, and account deletion removes the
record.

Pre-event Cross Paths suggestions are owned by the App-Check-protected
`getCrossPathsSuggestions` callable. Its typed request contains only a bounded
set of current Explore event ids and an opaque session id. The server rechecks
event availability, schedule conflicts, confirmed candidate participation,
both consent gates, reciprocal preferences, showcase readiness, safety state,
active matches, synthetic scope, and exposure fatigue. It returns at most two
sanitized person/event projections plus a short-lived signed token; roster
documents and private preference values never cross the callable boundary.
`crossPathsSuggestionExposures/{exposureId}` is a deterministic server-only
receipt used for seven-day fatigue and repeated-session stability. Firestore
rules deny every client read/write, the document carries a 30-day expiry for
the environment-owned Firestore TTL policy, and account deletion removes
receipts where the member was viewer or candidate.

Cross Paths invitations are deterministic event-and-sender documents. Only the
two participant ids may read an invitation; every create or transition is
owned by `sendCrossPathsInvitation`, `respondCrossPathsInvitation`,
`cancelCrossPathsInvitationOrPlan`, or a lifecycle trigger. A signed suggestion
token is not authority by itself: send and accept revalidate the recipient's
confirmed participation and either the sender's confirmed participation or
explicit companion-inventory admission, plus the applicable consent,
reciprocal eligibility, current showcase approval, blocks/reports/moderation,
event availability, and one-invitation/one-plan cardinality rules. Invitation state is `pending`,
`accepted`, `declined`, `cancelled`, `expired`, or `invalidated`; timestamps and
invalidation reasons are server-owned.

When an organizer enables reserved companion inventory, an accepted invitation
from an otherwise admissible unbooked sender may reference one
`crossPathsPairHolds/{holdId}` document. The server-owned hold records the
event, invitation, both participants, independent booking states, frozen price
quotes, expiry, release reason, optional payment, and optional event-plan
conversation. Only the two participants may get it; list and all client writes
are denied. `active` means reserved, not booked. Free or paid booking authority
atomically converts it to `confirmed`, creates the requester participation and
event plan, and moves the event projection from `crossPathsPairHeldCount` to
`crossPathsPairConfirmedCount`. Expiry, cancellation, event/participation or
safety invalidation, payment failure, and account deletion release exactly
once. Reserved companion capacity remains within total event capacity but
outside general admission and never changes waitlist rank.

Acceptance creates one deterministic `matches` document whose
`conversationType` is `crossPathsEventPlan`, whose participants are the invite
pair, and whose event id and invitation id remain explicit. It is not a dating
match and cannot drive match celebrations or Event Success signals. Rules allow
participants to read the plan and create messages only while it is active,
unblocked, and before `expiresAt` (event end plus 24 hours). Cancellation,
participation loss, event cancellation, or a block closes the plan; revoking
discovery consent invalidates pending invitations but does not silently cancel
an already accepted plan. Invitation delivery uses the separate optional
`prefsCrossPathsInvitations` preference, which defaults to false when missing.

Each device push token lives at
`users/{uid}/pushInstallations/{installationId}` with `token`, `appRole`,
`environment`, `platform`, optional app version/build, `locale`, `timeZone`, and
`updatedAt`. The client owns this device metadata and rules restrict writes to
the authenticated user plus the known role/environment/platform vocabulary.
Consumer clients attempt the legacy `fcmToken` and installation document as
independent compatibility writes, so an older deployed rule set cannot prevent
the other representation from being refreshed. Each failure is still logged
with its own non-PII resource context.
Notification producers select reviewed templates by stable message id and use
the installation locale when the delivery path supports per-installation
fan-out. English remains the bundled server fallback; notification prose must
not be stored as an unversioned remote document.

## Organizer Follower Posts

Organizer follower posts live under
`organizers/{organizerId}/posts/{postId}` and are created only by the
`createOrganizerPost` callable. Clients may read authenticated posts, but
direct writes are denied. The callable verifies organizer-manager authority,
validates optional linked events against the same organizer, enforces the
rolling three-posts-per-seven-days quota, writes the canonical post, and fans
out durable `organizerUpdate` activity notifications to active followers.
`createClubPost` and the nested club post are compatibility shadows.
Manager Sends history reads the same organizer-scoped collection through
`listOrganizerCampaigns` and returns post identity, audience, status, optional
linked event and timestamps without returning the message body.

## Event Broadcast Receipts

Host event broadcasts use the operational receipt
`eventBroadcasts/{broadcastId}`. Only `sendEventBroadcast` creates or advances
the receipt; account-deletion cleanup may delete a host-authored receipt or
remove one recipient's identifiers and delivery evidence. Direct client reads
and writes are denied. The Host client receives only the sanitized callable
response counts.

Finalization also upserts the durable, organizer-scoped
`organizerBroadcastSummaries/{broadcastId}` history projection. It contains the
event/activity label, audience, recipient count, send timestamp, partial-failure
flag and bounded contact delivery states, but no message body, UID, endpoint or
raw provider receipt. Direct client reads and writes are denied.
`listOrganizerCampaigns` is the manager-authorized, rate-limited pagination
boundary for the Host Sends workspace: it merges campaign summaries, these
Announcement summaries and organizer follower updates in reverse chronological
order using an opaque stable cursor. The queries are organizer-scoped and never
use a collection-group scan.

The callable verifies current event-host authority and freezes a server-resolved
audience from `eventParticipations`. Booked means `signedUp` plus `attended`;
prospective means `waitlisted`. Inquiry threads are never an audience source,
and the broadcast never creates a match, conversation, or chat message.

Each eligible recipient gets a deterministic `eventUpdated` Activity item.
Push is preference-gated and attempted at most once: durable Activity creation
is the retry boundary, so an uncertain retry reports an unknown push outcome
instead of sending a duplicate. The receipt stores hashed per-recipient
evidence for repair and aggregate delivery counts, remains server-only, and
requires the `eventBroadcasts.expiresAt` Firestore TTL policy for 90-day
retention.

## Host Analytics Snapshots

The host-facing `getHostAnalytics` callable may reuse a server-owned response
from `hostAnalyticsSnapshots/{uid}_{scopeHash}` for at most 15 minutes. The
scope hash includes the authenticated uid through the document id plus the
current authorized club ids, resolved absolute range, derived granularity,
preset, optional event id, and IANA timezone. Authorization is resolved before
the cache lookup, so host-role changes produce a different cache identity.

Clients cannot read or write snapshots. The callable validates a cached
response against `host_analytics_response.schema.json` before serving it,
falls back to a live BigQuery build on missing/expired/invalid cache data, and
keeps the existing rate limit in front of both paths. `expiresAt` has a
Firestore TTL policy; account deletion also removes snapshots owned by the
deleted uid.

## Durable Operations Records

`contracts/operations/` owns the portable JSON schemas for resumable business
workflows. These contracts are deliberately separate from public product
documents: an operations work item is review state and evidence, not an event,
organizer, or authorization to publish one.

The canonical record family is run, work item, action receipt, decision, lease,
publication plan, rule proposal, and rule evaluation. `functions/src/operations/`
owns semantic validation, optimistic revisions, reducers, and Firestore
repositories. All corresponding Firestore collections are server-only.

The reusable work-item contract accepts workflow-owned stage, entity, and
outcome tokens. Supply Intake's workflow manifest, runtime validator, backend
policy, and callable response then narrow that vocabulary to one exclusive
`primaryStage` from `incoming`, `verify`, `resolve`, or `ready`. Dedupe, source
verification, policy review, and human review are overlapping flags or
blockers. `published`, `rejected`, `expired`, `cancelled`, and `taken_down` are
lifecycle outcomes and must never be encoded as extra Supply Intake stages.
Workflow manifests also bind lifecycle semantics: non-empty active statuses
plus disjoint published and expired status groups. The generic local runtime
uses those frozen groups for queues, canonical lifecycle projection, counters,
and reconciliation cleanup; it does not require another workflow to reuse
Supply Intake's literal status names.

The local `operations/` runner validates its admin projection against the same
run and work-item schemas with full draft-07/Ajv conditional semantics before
exporting it. Functions repositories and the importer use generated validators
from those same bundled schemas, so a record rejected by the contract cannot be
accepted by a hand-written semantic subset. Human owner/blocker signals require
the canonical queryable task flag, and published or terminal records cannot
remain in the active human-review lane. The live admin surface reads
those durable records through `adminListIntakeOperations`; it cannot enqueue a
run or mutate workflow state.

Organizer discovery candidates are normalized into the bounded
`normalizedPayload.intake` projection on organizer work items. The payload
contains only the reviewed candidate fields required by the Admin queue; it is
not a canonical `organizers/{id}` document and grants no publication,
ownership, crawl, or app-visibility authority. Organizer-only shadow runs may
omit an Event Intake bridge, but remain subject to the same immutable export,
contract validation, and trusted importer.

An explicitly unattributed external event is represented only as
`normalizedPayload.intake.recordType=orphan_event_candidate`. The work-item
contract requires `entityKind=event`, the
`organizer_not_in_inventory` blocker, a null matched organizer, and
`publicationEligibility=blocked_orphan`; it rejects a published lifecycle for
that record. The event's evidence also projects a regular organizer discovery
candidate rather than creating a second organizer schema. Deterministic
auto-attribution records the reused source-mention scorecard rationale and is
the only path that clears the orphan blocker.

Organizer review decisions store approval and surface exposure independently.
`organizerIntakeReviewDecisions/{entityId}` requires `publishStatus`,
`indexStatus`, and `appVisibility`; `approve_public` may keep all surfaces off
or enable a reviewed subset. `indexed` requires `published`, `hold` is
`draft` + `noindex` + `hidden`, and `suppress` is `suppressed` + `noindex` +
`hidden`. Web exposure additionally requires claim-target, takedown, and
impersonation review; app discovery also requires operating-status,
event-accuracy, and unclaimed-affordance review. The shared Functions policy
derives effective event visibility as the minimum of the event request and
organizer ceiling on every surface and refuses a request above that ceiling.
Before this contract shipped, the guarded visibility-decision backfill repaired
the two production legacy approvals (`afterfly` and `bhag`) to their exact prior
`published` + `indexed` semantics; the post-apply dry run reported two current
documents and zero remaining repairs.

Supply Intake `0.1.1` records exact field provenance for the candidate title,
canonical URL, snippet, market, reviewed formats, review note, and review
timestamp. Each entry binds the projected field to an evidence artifact,
content hash, locator, extraction method, extractor version, and confidence.
This is deterministic extraction metadata; it grants no truth, ownership, or
publication authority.

`adminCreateOrganizerDraftFromCandidate` is the only candidate-to-entity
scaffolder. It validates the exact work item and reviewed evidence, rejects
existing-entity matches and duplicate identity receipts, allocates an opaque
Firestore organizer id, and separately reserves the reviewed public slug. It
creates an unclaimed `organizers/{id}` draft with `appVisibility=hidden`,
`publishStatus=draft`, and `indexStatus=noindex`. It also writes the legacy
`clubs/{id}` compatibility shadow, reserves the canonical route, and records a
deterministic `organizerIntakeCurationDecisions/{id}` receipt. The receipt
contains the source work-item, candidate, normalized identity key, public slug,
and target-field provenance and is returned by `adminListIntakeOperations` as
a bounded draft link. Intake review notes remain audited operator context; they
are never copied into member-facing description or source summary. Unknown
description, locality, and public listing descriptor values remain empty until
an operator supplies verified content. No crawl enablement or owner binding is
part of this contract.

The canonical organizer draft also carries a bounded, server-only
`intakeLearningSource` snapshot for fields actually seeded from the reviewed
work item. It contains the source profile, work-item and candidate ids,
field-level extracted values, and artifact lineage; it never contains a raw
provider payload. The legacy `clubs/{id}` compatibility shadow deliberately
does not receive this learning metadata.

When an audited organizer update first changes a value that still equals its
source-seeded value, Functions writes one immutable
`organizerIntakeFieldCorrections/{correctionId}` record in the same transaction.
The record binds source, field, extracted value, corrected value, operator
context, artifact lineage, and a deterministic `fixtureId`. Subsequent
editorial changes do not masquerade as extraction corrections because the
stored value no longer equals the original extraction. These records are
server-only learning evidence; they do not publish content or activate rules.

The trusted shadow-projection importer validates the export again, resets only
the Firestore persistence revision to zero, and retains each local source
revision plus the whole-export hash under reserved projection metadata. It
creates work items before exposing the run, verifies every expected item on
replay, repairs missing items, rejects changed records, and refuses inventory
above the run's frozen `maxWorkItems` budget. Apply also binds the environment
label to its configured Firebase project id and requires project-aware
production confirmation. This bridge writes no `events`, `externalEvents`,
`clubs`, public website projection, or publication-plan record.

Local completed runs hash-bind their full work-item inventory. Reconciliation
creates a new lineage-bound run and new work-item ids rather than mutating the
source snapshot, preserving immutable importer semantics across expiry and
staleness sweeps.

`adminActionExecutions/{executionId}` is the separate remote monitor record for
one admin CLI invocation. It stores action/callable identity, actor roles,
target label, request/response hashes, timestamps, and a bounded terminal
error—not the request or response body. A role-gated callable creates the
`started` receipt before the business callable runs and advances it to exactly
one immutable `succeeded`, `failed`, or transport-ambiguous `indeterminate`
outcome. Browser clients can inspect the bounded projection only through
`adminListActionExecutions`; direct Firestore reads and writes remain denied.

Runs must budget between 1 and 10,000 work items. Imported run metadata carries
authoritative total, active, terminal, stage, and human-review aggregates; the
admin read fails closed unless those totals reconcile. The canonical human
review filter is backed by the committed `operationWorkItems` composite index.

## Organizer Claim Documents

Public organizer claims use a dedicated review collection instead of overloading
host locks:

| Collection / field | Owner | Notes |
|---|---|---|
| `organizerClaimRequests/{requestId}` | `requestOrganizerClaim`, `adminDecideOrganizerClaim` | Server-owned claim queue. Clients create and decide only through callables; direct Firestore reads/writes are denied. |
| `organizers/{organizerId}.claim` | organizer claim callables and admin index-review callables | Public-page claim state, latest request id, review audit, and owner-facing status. |
| `organizers/{organizerId}.ownership` | organizer claim/create/update callables | `programmatic` before ownership, `claimed` after approval. |
| `organizers/{organizerId}.publicPage.indexReview` | admin organizer indexing | Audit evidence for source quality, media rights, cadence, and owner/contact verification before a page becomes indexable. |
| `reviews/{reviewId}.ownerResponse` | `setReviewResponse` | Server-owned owner response rendered by app and website review surfaces. |

`organizerTeamMemberships` owns active owner and manager seats. Legacy
`clubHostClaims` remains only long enough to support released club callables;
it is not organizer claim authority.

## Event Policy Applicability

`contracts/shared/event_common.schema.json` owns the versioned event-policy
bundle invariant. Bundle version 2 couples pricing and cancellation semantics:

- `pricing.basePriceInPaise == 0` requires
  `cancellation.policyId == notApplicable`;
- a positive base price requires `flexible`, `standard`, or `strict`;
- external-companion events remain price-zero inside Catch because the external
  booking authority owns payments, refunds, and attendee cancellations.

Backend event create/update normalization derives this relationship rather than
trusting a client-supplied cancellation value. Version 1 remains readable for
legacy event documents.

## Event Discovery Projection

Explore queries `events` directly through callable-owned projection fields
instead of resolving a city to clubs first. The projection currently covers
city, activity kind, coarse geo-cell, availability bucket, gate flags, and age
range:

- `discoveryCityName`, `discoveryActivityKind`, `discoveryGeoCell`;
- `discoveryHasOpenSpots`, `discoveryAvailability`;
- `discoveryOpenCohorts`, `discoveryWaitlistCohorts`;
- `discoveryInviteRequired`, `discoveryMembershipRequired`,
  `discoveryManualApprovalRequired`;
- `discoveryMinAge`, `discoveryMaxAge`.

`functions/src/events/eventDiscoveryProjection.ts` owns the write-time
projection. Event create/update/cancel, paid signup, and signup cancellation
must refresh these fields whenever event capacity, policy, status, activity, or
location inputs change. `discoveryOpenCohorts` gives Firestore a coarse
viewer-cohort open-slot filter for the standard event-policy cohorts; gated
events still require viewer-specific post-query resolution for invite,
membership, and manual-approval state. `firestore.indexes.json` owns the
supporting composite indexes for city, time, activity, geo-cell, coarse
availability, and open-cohort filters.

Existing remote event docs created before this projection must be repaired with
`node tool/data/backfill_event_discovery_fields.mjs` before a release depends on
the direct event index. The repair is dry-run by default and requires
`--allow-prod` when applying against prod.

Admin organizer search uses a separate server-owned
`organizers/{organizerId}.adminSearch` projection for the admin Organizers
canonical directory. It is not consumed by the app or website.
`adminListOrganizerDetails`
accepts either a single `citySlug` or a bounded `citySlugs` array for
admin-only launch-city work queues such as Indore + Mumbai. Existing organizer
docs can be repaired with `node tool/data/backfill_organizer_admin_search.mjs`; the
repair is dry-run by default and requires `--allow-prod` when applying against
prod.

Admin event search uses a separate server-owned
`events/{eventId}.adminSearch` projection for the admin Events canonical
directory. It is not consumed by the app. `adminListEventDetails` accepts either
a single `citySlug` or a bounded `citySlugs` array for admin-only launch-city
work queues such as Indore + Mumbai. Existing event docs can be repaired with
`node tool/data/backfill_event_admin_search.mjs`; the repair is dry-run by
default and requires `--allow-prod` when applying against prod.

External event supply uses `externalEvents/{eventId}`. These records are
sourced from reviewed organizer-intake candidates, preserve source/dedupe
attribution, carry a fail-closed organizer capability snapshot, and keep Catch
booking, payments, reservations, waitlists, and host contact disabled.
`adminListExternalEventDetails` lists that collection for admin event-supply
review with the same bounded launch-city and time-window filters.

`adminPublishExternalEvent` is the only publication writer. It requires a
dry-run or apply execution mode, an idempotency key, exact launch-market
identity, the organizer visibility ceiling, accepted per-blocker decisions,
and the reviewed candidate snapshot. Dry-run and apply append immutable
`externalEventPublicationReceipts/{receiptId}` records; a replay with the same
key returns the same result and changed input is rejected. The callable writes
one outbound-only `externalEvents/{id}` record and never creates a canonical
Catch-hosted `events/{id}` record.

The governed blockers are `missing_exact_coordinates`, `missing_end_time`,
`missing_location_detail`, `requires_event_defaults_policy`,
`requires_owner_safe_copy_review`, and `duplicate_normalized_event_key`.
Every blocker must be explicitly resolved or waived. A waiver is accepted only
when it cites an accepted `organizerPolicyGapReviewDecisions/{decisionId}` with
the exact expected policy id; code defaults and generic acknowledgements do not
clear blockers.

`adminTakedownExternalEvent` is the only takedown writer. Its dry-run/apply
contract is also idempotent and receipt-backed. Apply preserves the source and
audit record, changes publication state to taken down, and records takedown
metadata rather than deleting the document.

Read-only dry-runs on 2026-05-26 found:

| Environment | Events scanned | Repairs needed | Cityless repairs |
|---|---:|---:|---:|
| `dev` | 146 | 146 | 0 |
| `staging` | 0 | 0 | 0 |
| `prod` | 166 | 166 | 0 |

## Read Path Discipline

Firestore reads use an explicit surface policy instead of ad-hoc unbounded
queries:

- **Feed and history surfaces** are growing collections. They require a
  reviewed page size, a stable ordered cursor, refresh behavior, and an honest
  `hasMore` state. Realtime first-page listeners are allowed when freshness is
  product-critical, but older history still loads through a cursor.
- **Rosters and bounded working sets** require a reviewed limit based on the
  product's real domain bound. If the domain is not actually bounded, they use
  the feed/history policy.
- **Point lookups** use deterministic document ids whenever the schema owns
  one. A `where(...).limit(1)` query is not a substitute for a known document
  id.
- **Realtime vs one-shot:** route-visible state that must reflect concurrent
  mutations may use `snapshots()` and follows the lifecycle policy in
  `docs/app_architecture.md#realtime-stream-lifecycle`. Discovery/search pages
  may use one-shot pages when they expose pull-to-refresh and revalidate on
  route or tab re-entry. Administrative reports and explicit exports are
  one-shot unless the workflow contract says otherwise.

Repository-owned composite query builders declare adjacent contracts using:

```dart
// firestore-index: events (marketId:ASCENDING,startTime:ASCENDING)
```

`node tool/run.mjs check contracts:firestore-query-indexes` scans every
handwritten repository source, rejects composite builders with no contract,
verifies each declared ordered field list against `firestore.indexes.json`,
and rejects non-vector one-field composites, with or without an explicit
`__name__`, that Firestore refuses to deploy because built-in single-field
indexes already own those query shapes.
The check also runs inside `./tool/check_data_contract.sh` and Tools CI whenever
repository data code or the index file changes.

### Canonical read limits and cursors

`lib/core/data/read_limit_policy.dart` owns the numeric policy and
`lib/core/data/cursor_page.dart` owns the shared `limit + 1`,
`startAfterDocument`, honest-`hasMore` contract. Repository call sites must not
introduce numeric limits directly. `node tool/run.mjs check
contracts:firestore-read-limits` enforces that boundary and runs in Tools CI
and `./tool/check_data_contract.sh`.

| Surface class | Page size | Notes |
|---|---:|---|
| Explore internal discovery | 80 | Primary mixed-feed supply. |
| Explore external discovery | 40 | Secondary outbound supply. |
| General feed/history | 40 / 50 | Feed page / chronological history page. |
| Directory | 30 | Clubs and other entity directories. |
| Bounded operational set | 1,000 | Contract ceiling for rosters and reviewed exceptions; never a browse-page substitute. |
| Search | 20 | Interactive callable result window. |
| Recommendation rail | 10 | Ranked, explicitly non-exhaustive rail. |
| Deterministic lookup | 1 | Prefer direct document reads; use only where no deterministic id exists. |

The first cursor adopters are Explore internal/external discovery, chat
messages, active matches, club/event/user reviews, activity notifications,
Host Customers, and the Host Events timeline. Payment history uses the same
cursor contract. Their realtime methods now expose only the bounded first
page; their repository page methods advance opaque document cursors for older
or additional supply. Host Customers uses the directory page size. Host Events
holds one session boundary and pages active/future events forward and history
backward independently, so time advancing while the screen is mounted cannot
create cursor gaps or re-read the full archive.
Explore accumulates both discovery cursors, shows `N+` while either has more,
and exposes a load-more action. Its map count includes only records with a
complete coordinate pair.

### Feed freshness policy

Every route-visible feed must provide one explicit manual refresh path and
revalidate on a new route/tab session. Realtime first-page subscriptions count
as continuous revalidation while mounted; they still need manual recovery for
offline/reconnect and older-page failures. Explore invalidates its discovery
window, club source, composed feed, and recommendation providers on pull and on
inactive-to-active tab re-entry. Availability and attendance are recomposed in
that same session refresh.

### Reviewed bounded-set exceptions

The following reads are intentionally not cursor-paged because they are
working sets rather than user-browsed histories. Reclassify them and add a
cursor before expanding their product surface:

| Exception id | Reads | Bound / review trigger |
|---|---|---|
| `READ-EXCEPTION-ACTIVE-EDGES` | active memberships, saved events, blocks, event participations | At most one active edge per deterministic entity pair; paginate if inactive/history states join the query. |
| `READ-EXCEPTION-EVENT-ROSTER` | active event roster and host event report | Bounded by the event admission capacity; exports remain explicit one-shot operations. |
| `READ-EXCEPTION-HOST-CLUBS` | hosted/owned clubs for one user | Small authorization working set; paginate if surfaced as an organization history. |
| `READ-EXCEPTION-CLUB-EVENT-SCHEDULE` | one club's event schedule and invite-link set | Operational club/event working sets; history/archive experiences require cursor pages. |
| `READ-EXCEPTION-RECENT-CLUB-POSTS` | seven-day club post quota window | Server-enforced three-active-post quota; the bounded read exists only to calculate remaining quota. |
| `READ-EXCEPTION-EVENT-SUCCESS` | active event-success module/check-in lists | Bounded to one event's configured workflow; archive/history surfaces require cursor pages. |
| `READ-EXCEPTION-RETIRED-SWIPES` | legacy swipe/profile-decision history | No active `swipes/` product read may be added; migration tooling remains dry-run only. |

Every exception above is still capped with
`ReadLimitPolicy.boundedWorkingSet`; the exception waives cursor UX only, not
the Firestore read ceiling.

`CityRepository` is a deliberate availability exception: it logs normalized
backend errors and falls back to the checked-in launched-city catalog so global
city selection remains usable. Launch-access realtime reads, by contrast, fail
through the standard backend error wrapper and never silently downgrade.

## Current Health

Verified in this consolidation pass from current code and registry state:

- Relationship arrays have already been retired from active app surfaces.
- `tool/data/validate_firestore_data.mjs` validates edge documents and parent
  aggregate drift instead of reconstructing from arrays.
- `createEvent`, `updateEvent`, `cancelEvent`, `deleteEvent`, organizer mutations,
  booking/waitlist/attendance, payments, reviews, safety actions, profile
  updates, Places, and event-success write paths are callable/trigger owned as
  documented in `docs/backend_operation_catalog.md`.
- Contract schemas now cover private/public profiles, events, organizers and
  their explicit legacy club projections,
  relationship docs, social/payment/safety/operational docs, event-success
  documents, callable request payloads, selected responses, direct-write
  payloads, prompt catalogs, seed fixtures, and migration contracts.
- Event discovery projection fields are schema-owned, callable-owned, and have
  dry-run-first backfill tooling for older events.
- `tool/check_data_contract.sh` is the main local gate for generated drift,
  schema validation, Functions checks, rules tests, and focused Flutter
  contract tests.

## Historical Event Rename And Organizer Cutover

The older run/run-club rename is complete. The current authority cutover moves
the organization entity from `Club` to `Organizer`, with `club` retained as an
`organizerType` value:

| Old name | Current name |
|---|---|
| `Run` | `Event` |
| `RunClub` | `Organizer` with `organizerType: club` |
| `RunParticipation` | `EventParticipation` |
| `SavedRun` | `SavedEvent` |

Organizer-named contracts, runtime collections, callables, routes, media paths,
and product-facing copy are the current local authority. `Club`-named Dart
types/folders and callable wrappers are compatibility adapters until the remote
backfill and supported-client window are proven. They must not be used to
introduce new club-only behavior.

### Host media galleries

Organizer and event galleries are ordered `UploadedPhoto` arrays with no
product-level item cap. `position` is a non-negative sequence, the first item is
the explicit cover projection (`imageUrl` for organizers and `photoUrl` for
events), and the organizer `logoPhoto` / `profileImageUrl` remains a separate
optional asset that is never inserted into the gallery. Callable and Firestore
schemas intentionally do not declare `maxItems`; they remain bounded by the
underlying callable and Firestore document-size limits, so clients must render
and edit them through a virtualized/scrolling manager rather than an expanding
inline grid. Consumer dating-profile media retains its independent six-photo
policy and grouped `profilePhotos` contract.

Firebase Storage owns immutable image bytes by stable media identity; Firestore
owns presentation order, cover selection, captions, and the active references.
The canonical object layout is:

```text
organizers/{organizerId}/media/{mediaId}/original.jpg
organizers/{organizerId}/media/{mediaId}/thumbnail.jpg
organizers/{organizerId}/logo/{mediaId}/original.jpg
organizers/{organizerId}/logo/{mediaId}/thumbnail.jpg
events/{eventId}/media/{mediaId}/original.jpg
events/{eventId}/media/{mediaId}/thumbnail.jpg
```

Clients may create and compensation-delete only `original` objects for an
organizer owner or active manager. Replacing an object in place is denied;
editing media creates a new stable `mediaId`. Backend Firestore triggers create
the responsive thumbnails only after the URL is attached to the canonical
document, and organizer/event update and delete operations remove originals and
derived thumbnails after the Firestore commit. This separates unordered object
storage from the ordered gallery contract and prevents gallery reordering from
renaming or re-uploading bytes.

Released-client paths such as `organizers/{organizerId}/photos/{position}_{time}.jpg`,
`organizers/{organizerId}/logo/{time}.jpg`, and the equivalent `clubs` and
`events/{eventId}/photos` paths stay accepted during the compatibility window;
their six-slot filename bound is not the canonical gallery policy. Private form
assets remain separate: `organizerForms/...` and `organizer-form-exports/...`
deny direct SDK access and are exposed only through short-lived backend-signed
requests.

Remote organizer backfill is complete in staging and production; legacy
cleanup is intentionally not complete. Follow
`docs/migrations/clubs_to_organizers.md`. Do not delete or reset Firestore data
in dev, staging, or prod without a separate explicit destructive-action
confirmation. Preserve user documents and both canonical organizer documents
and legacy club projections through any remote migration.

If remote cleanup is approved, first export or back up existing `users`,
`publicProfiles`, and old `runClubs` documents for each Firebase environment.
Then copy any host organizations worth preserving into `organizers`, reset
event-specific legacy collections and edges such as old `runs`,
`runParticipations`, `savedRuns`, reviews, event schedule locks, event-derived
profile decisions, and generated demo event documents, and re-run seed/host tooling against
the canonical `events` and `organizers` collections.

## Open Watch Items

- `RELATIONSHIP-DOC-MIGRATION`: watch only. Do not re-add retired arrays.
- `FIRESTORE-RULES-SIMPLIFICATION-001`: keep `users/{uid}` owner-readable only,
  decide the active club-membership read posture for member-list product needs,
  and keep the final direct writes intentionally narrow.
- `MIGRATION-VALIDATION-001`: before applying legacy migration scripts to
  shared beta data, add or keep seeded fixture tests for duplicates, missing
  docs, deleted users, legacy chats, and count mismatches.
- `DELETE-METHODOLOGY-QUEUE`: core account/event/organizer deletion is
  relationship-doc aware; broader historical event/organizer deletion still needs
  product policy before expanding beyond cancel/archive/delete-unused.
- Retired storage rename from `swipes` to `profileDecisions`: keep legacy
  migration/backfill tooling available for validation and cleanup, but do not
  reintroduce production reads or writes to `swipes/`.
- Retired grouped `ProfilePhoto` migration: profilePhotos is the canonical
  profile photo field after the 1.0.1 app-version floor. Keep legacy-array
  cleanup dry-run-first and do not reintroduce `photoUrls`,
  `photoThumbnailUrls`, or `photoPrompts` as canonical contract fields.
- Nested profile activity preferences: `activityPreferences.running` is the
  canonical home for pace, distance, reason, and run-time preferences. Domain
  decoders can tolerate legacy root fields until remote cleanup completes.

## Historical Evidence

Detailed phase logs and old proof commands were removed from active Markdown.
Use Git history when exact historical wording or retired command output
matters.
