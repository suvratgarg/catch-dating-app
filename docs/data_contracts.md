---
doc_id: data_contracts
version: 1.4.1
updated: 2026-07-21
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
| Persisted document schemas, callable payload schemas, fixtures, catalogs | `contracts/` |
| Storage path contracts (upload paths, content-type, size limits, owner) | `contracts/storage/` |
| Generated TypeScript interfaces, Ajv validators, and Admin SDK Timestamp types | `functions/src/shared/generated/` |
| Generated Dart schema constants/registry | `lib/core/schema_contracts/generated/` |
| Tool-side schema registry and validators | `tool/contracts/generated/` |
| Firestore operation ownership metadata | `tool/contracts/firestore_contract.json` |
| Human operation map | `docs/backend_operation_catalog.md` |
| Active backlog/rules | `docs/audit_registry/backlog.json` and `docs/audit_registry/rules.json` |

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
UI-relevant `minLength`, `maxLength`, `pattern`, enum, and numeric bounds from
patch and Firestore document schemas into typed
`CatchContractFieldConstraints` constants. `CatchForm*Row` descriptors bind
those constants through `contract:`; call sites may narrow a bound explicitly,
but may not relax the contract.

`test/core/forms/contract_alignment_test.dart` walks the consumer-profile and
host-club descriptor factories and contains a seeded over-limit probe, so the
gate proves both missing bindings and contradictory limits are detectable. Run
it through `node tool/run.mjs check contracts:form-alignment`; contract CI also
keeps the generated projection deterministic via the schema generator's
`--check` mode.

## Relationship Documents

Root-level edge/action documents are the source of truth for many-to-many state:

| Relationship | Source document |
|---|---|
| Organizer owner/manager seat | `organizerTeamMemberships/{organizerId_uid}` |
| Organizer follow | `organizerFollows/{organizerId_uid}` |
| Event booking, waitlist, attendance, cancellation | `eventParticipations/{eventId_uid}` |
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
rules can prove locally: onboarding drafts, saved events, outgoing profile decisions,
match-scoped chat messages, own unread reset, own notification `readAt`, and
own FCM token. Multi-document product writes belong in callables or triggers.

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

Read-only external event supply uses `externalEvents/{eventId}`. These records
are sourced from reviewed organizer intake candidates, preserve source/dedupe
attribution, and must keep Catch booking, payments, reservations, and waitlists
disabled. `adminListExternalEventDetails` lists that collection for admin event
supply review with the same bounded launch-city and time-window filters, but it
does not import candidates or mutate Firestore.

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
and verifies each declared ordered field list against `firestore.indexes.json`.
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

Remote organizer backfill and legacy cleanup are intentionally not complete.
Follow `docs/migrations/clubs_to_organizers.md`. Do not delete or reset
Firestore data in dev, staging, or prod without a separate explicit
destructive-action confirmation. Preserve user documents and both canonical
organizer documents and legacy club projections
through any remote migration.

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

Detailed phase logs and proof commands were moved out of active Markdown. Use
`docs/audit_registry/passes.jsonl`, `docs/audit_registry/files.jsonl`, and git
history when exact historical wording or old command output matters.
