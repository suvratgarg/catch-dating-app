---
doc_id: data_contracts
version: 1.14.1
updated: 2026-08-11
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
`venue`, or `brand`; missing legacy values default to `club`. The complete
mapping, rollout, parity, and recovery procedure is owned by
`docs/migrations/clubs_to_organizers.md` and
`contracts/migrations/clubs_to_organizers.json`.

New contracts use `organizerId`, `organizerTeamMemberships`,
`organizerFollows`, `organizerClaimRequests`, `organizerScheduleLocks`, and
`organizers/{organizerId}/posts`. The `clubs`, `clubMemberships`,
`clubClaimRequests`, `clubScheduleLocks`, `clubId`, and club-media contracts are
released-client compatibility projections only. They remain additive during
the migration window and must not become the authority for new behavior.
Production canonical parity completed on 2026-07-22, and current Flutter reads
do not fall back to `clubs`; compatibility writes remain until the separate
released-client retirement gate is approved.

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
firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"
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
| Ambiguous or walk-in Event Success claim review | server-owned `eventRuntimeClaimRequests/{eventId_uid}` |
| Organizer-scoped communication permission | server-only `organizerCommunicationPreferences/{organizerId_uid}` |
| Organizer-scoped operational contact | server-only `organizerContacts/{contactId}` |
| Contact-to-event fact | server-only `organizerContactEventEdges/{attendeeId}` |
| Contact identity evidence and verified claim | server-only `organizerContactIdentityLinks/{evidenceId}` and `organizerContactIdentityClaims/{claimId}` |
| Rebuildable contact traits and organizer summary | server-only `organizerContactTraits/{contactId}` and `organizerAudienceSummaries/{organizerId}` |
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
callable resolves it and returns only a bounded public event projection.

`eventRuntimeParticipants/{eventId_uid}` is the private bridge between a
Firebase phone-auth identity and an event-scoped operational attendee. It owns
the claim method, optional `eventAttendeeId`, minimum runtime-profile fields,
explicit terms versions, and readiness state. It does not create or imply a
Consumer `users/{uid}`, `publicProfiles/{uid}`, `eventParticipations/{eventId_uid}`,
dating match, or marketing grant. Clients may get only their own deterministic
edge; list and direct writes are denied. Event Success modules authorize a
`ready` runtime edge independently of the Consumer booking/network edge.

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
restores only the exact source-origin edge, evidence, and claim identifiers in
the original receipt and creates one deterministic reversal receipt. Facts
created after a merge remain with the survivor instead of being guessed back.

`organizerContactTraits` are rebuilt from event edges and contain only
attendance, reliability, source and channel-reachability facts. Compatibility
answers, gender, sexual orientation, relationship state, wingman targets,
safety reports and inferred social desirability are prohibited CRM inputs.
Trait and summary writes use exactly-once TTL receipts, so retries cannot
double-count an organizer. The dry-run-first organizer-audience backfill uses
the same production projector and marks a summary `exact` only after every
current attendee row has completed. Newer live rows always win over stale
backfill snapshots.

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
Hosts currently retain event-scoped roster access through the existing
authorized roster boundary; campaign delivery is a separate contract. Account
deletion removes the onboarding draft, organizer communication grants, UID
identity evidence and verified UID claims. Retained operational attendee,
contact and event-edge history is unlinked from the deleted Catch UID.
Retained organizer roster history is unlinked by setting `linkedUid` and
`linkedAt` to null; any separately retained operational contact field remains
subject to the organizer's stated booking/records purpose rather than Catch
account or marketing permission.

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

## Event Broadcast Receipts

Host event broadcasts use the operational receipt
`eventBroadcasts/{broadcastId}`. Only `sendEventBroadcast` creates or advances
the receipt; account-deletion cleanup may delete a host-authored receipt or
remove one recipient's identifiers and delivery evidence. Direct client reads
and writes are denied. The Host client receives only the sanitized callable
response counts.

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
and rejects single-field plus `__name__` pseudo-composites that Firestore
refuses to deploy because the built-in single-field index already owns them.
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
messages, active matches, club/event/user reviews, and activity notifications.
Payment history uses the same cursor contract. Their realtime methods now
expose only the bounded first page; their repository page methods advance
opaque document cursors for older or additional supply.
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
