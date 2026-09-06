---
doc_id: event_success
version: 1.23.0
updated: 2026-09-06
owner: recursive_audit_loop
status: active
---

# Event Success

This is the source of truth for the live-wired but still evolving event-success
layer. It replaces the separate event-success completion, hardening, in-
development, runtime, manual-QA, and participant-metrics trackers.

Read this before deleting, moving, auditing, or changing `lib/event_success/**`,
`test/event_success/**`, event-success Firestore collections, event-success
Functions, production review coverage, event-success scorecards, or participant
metrics.

## Current State

Event success is intentional live product code, not dead code. It is wired to
live event routes, host setup/manage surfaces, attendee companion surfaces,
Firestore rules, generated contracts, demo data, and Functions.

The current production loop supports two entry paths:

1. A Consumer member joins/books through Catch, or a Host creates an
   operations-only event and imports/adds its operational attendees.
2. The Host marks attendance; a linked event-scoped or Consumer attendee may
   self-check in when the event policy permits it.
3. Profile-independent Event Success setup can guide the live event through
   structure, run-of-show prompts, attendance and Host controls. Assignment,
   First Hello, compatibility and wingman code is migrating from Consumer
   participation/profile eligibility to the event-runtime identity contract
   below.
4. A phone-verified imported attendee enters the dedicated web runtime without
   installing the Consumer app. Swiping, mutual Catch, cross-event discovery
   and chat remain Consumer/profile pipelines; First Hello, event-scoped
   compatibility, groups, rotations, wingman and feedback do not.

Event success does not own a duplicate post-event interest surface. Private
target identities remain attendee-private unless the attendee explicitly asks
the host for help through the wingman request flow.

### Standalone Host Runtime Boundary

Event Success must no longer infer that every human at an event has an
`eventParticipations/{eventId_uid}` document. The Host runtime consumes the
unified operational roster described in
`docs/host_product.md#host-tooling-decisions`.

- Host-only facilitation, run-of-show, prompts, manual attendance and aggregate
  reporting can address an `eventAttendee` without a linked UID. Existing
  participant QR, feedback and private companion actions remain UID-backed.
- Attendee-private runtime moments require a server-linked event-scoped OTP UID
  or Consumer UID. The target assignment contract will use attendee ids as the
  event identity and keep the optional linked UID only as an authorization
  projection; current assignment documents are still UID-keyed.
- Preference-driven modules may use only explicit event answers and consents.
- Public/dating profile inspection, compatibility derived from a dating
  profile, swiping, catches and chat require the Consumer profile tier.
- A missing identity tier produces a visible capability unlock; it must never
  silently drop the attendee, synthesize profile attributes, or widen roster
  visibility.

During migration, existing UID-keyed Event Success documents remain valid for
Catch-booked participants. UID remains the private authorization key because
phone OTP creates a real Firebase Auth identity, while the new runtime edge
links that UID to the operational attendee and declares its identity version.
Generators resolve the event-runtime participant first instead of treating a
Consumer participation or public profile as the event identity.

The 2026-08-11 Direction 3 bounded reference closes the first Host-only slice
of this boundary. Canonical Host Manage Live derives checked-in and expected
counts from `eventAttendees`, accepts an external-only roster with zero
`eventParticipations` or profiles, and moves attendance work behind Guests.
The roster is still passed separately from the UID-keyed assignment and private
companion data required by optional advanced cards; this does not claim the
general attendee-id assignment migration is complete.

Direction 3's Quiet Command Console is the selected live hierarchy: one dark
current-beat stage, one next beat, flat Guests and recovery destinations,
honest acknowledged/pending/failed persistence, Previous, and one pinned
primary action. Live transitions are revision-fenced backend writes, and reveal
or rotation publication requires an explicit confirmation. The persisted plan
is the restart source of truth, so process death resumes the current beat and
published rounds without a local recovery mode. Revisioned undo and pause are
not part of the shipped control model.

## Typed event assistance

The event-assistance outcome vocabulary is owned by
`contracts/catalogs/event_assistance_workflows.json`. Its 46 definitions map
to correlated policy variants in
`contracts/shared/event_assistance_common.schema.json`. Command variants bind
the command kind, payload and live/rehearsal context. Generated TypeScript
contracts and Dart vocabularies must be regenerated together; the schema check
requires complete catalog/configuration coverage.

`functions/src/eventSuccess/operations/` owns the pure policy evaluators and
command-boundary validation. The late-join evaluator accepts explicit time,
attendance, admission, guidance, participation episode and policy authority.
Reported intention cannot manufacture physical attendance; confirmed presence
resolves an older decline. Throttled material updates retain a next evaluation
time. Effect identities include the execution context and participation episode.
Live and rehearsal adapters must use this policy with mode-scoped effects;
the pure evaluator alone does not establish application integration.

The registered `event-assistance` workflow now evaluates bounded late-join
snapshots through the existing Operations engine. Its manifest exposes plan,
run, resume, queue and status, with zero network/public-write authority. A run
is one event/context and frozen evaluation time; duplicate participation
episodes, schema-invalid facts and changed plan authority fail closed. Its
queue separates evaluating, waiting, host review, proposed effect and terminal
outcomes. Completion means snapshot evaluation finished, not that a guest was
contacted or the event is complete.

`lateJoinPolicy.ts` is the single authored pure implementation. The Operations
runtime generator transpiles it to the checked JavaScript module consumed by
Operations;
the Functions adapter validates the same schemas before invoking it. Changing
the policy therefore requires both generated-output parity and runtime tests.
The local shadow factory does not load live event facts or send messages.
Trusted worker scheduling, complete live policy fact readers, provider adapters,
and the Host/rehearsal application adapters remain integration work.

`contracts/shared/event_assistance_messaging.schema.json` separates immutable
message intent, a channel attempt and a guest response. Joining updates carry
only approved joining choices; operational notices carry scoped acknowledgements
or help requests. A response cannot represent physical check-in. Provider
attempts require a live context and a sender binding correlated with the route;
rehearsal attempts cannot carry that binding. Reserved attempts freeze the
permission revision, validity interval and instruction revision used to select
the route. Opaque provider ids are not restricted to Firestore path syntax.

`messageProtocol.ts` creates late-join message proposals and reservations,
validates wire records, and resolves a scoped submitted choice to its stored
value. An expired grant, changed episode, stale instruction, unknown choice or
duplicate response cannot create a new effect. The trusted adapter must resolve
the bearer grant or provider correlation and atomically persist an accepted
response with the owner domain's revision check; this pure resolver is not an
authenticated endpoint or a persistence implementation.

`messagingPolicy.ts` owns the shared delivery decision. Reserved, accepted and
uncertain attempts require reconciliation, and delivered/read attempts cannot
trigger fallback. Confirmed technical failures permit bounded retries across
freshly eligible routes. Policy rejection, suppression, invalid recipient and
provider-owned fallback create owned exceptions. Event/guest state, current
instruction, expiry, permission freshness and attempt limits are checked before
selection. `deliveryReceipts.ts` preserves delivered/read evidence when delayed
or contradictory provider statuses arrive, and rejects another sender,
connection revision, endpoint or provider message id. Provider signature
verification and callback-to-attempt lookup belong to the upcoming adapters.

`FirestoreMessageOutbox` persists immutable intents and at most six attempts in
the private `eventAssistanceMessages` collection. Re-enqueueing the same scoped
intent returns its existing history; changed content cannot reuse the identity.
Reservation and dispatch claiming each re-read trusted domain and permission
facts in their Firestore transaction. The injected fact reader is a port for
the upcoming event/roster/permission adapters, not client-supplied authority.

Only one transaction can claim a reserved live attempt. It records an uncertain
outcome before returning a short-lived dispatch permit, and the provider runs
after commit. An interrupted claim therefore requires reconciliation; replay
does not grant another send. Provider adapters must check permit expiry and use
the attempt id for provider idempotency when supported. This boundary does not
claim exactly-once delivery by an external provider.

Normalized receipts can update an expired or cancelled message independently
of its workflow run. They cannot reopen sending. Contradictory evidence creates
a persistent conflict that withholds new dispatch, including an already
reserved fallback. Rehearsal reservations cannot obtain a live dispatch permit
or accept a real provider receipt. The outbox is not yet wired to a scheduler,
live sender, Host read model or rehearsal runtime; those remain
separate integration steps. Terminal cleanup must be added before activation,
and must retain deduplication state throughout the provider reconciliation
window.

`GuestAssistanceStore` supplies the trusted publisher and scoped guest-response
boundary. Private guest state records the roster document's exact creation
generation and a participation episode. Each workflow occurrence has its own
thread head, so joining guidance and another operational notice can coexist.
Publishing a replacement atomically supersedes the prior message. A link
resolves the thread's current head; an old button cannot mutate newer guidance.

The worker issues a bounded, revocable grant using a versioned signing key.
Firestore stores only its secret hash. Link redemption rechecks current event,
roster generation, admission, episode, instruction expiry and message purpose.
Cancellation and post-event notices have their own event-phase eligibility.
The public App-Check-protected callables return only the event label, current
instruction and approved response labels, not guest identity or roster data.
A response and its effect commit together: joining intent advances a fenced
private participation revision, acknowledgement records the receipt, and help
creates an owned case. Comfort/safety requests require the restricted safety
owner. None of these responses checks in, cancels or assigns an attendee.

`readEventAssistanceMessageGate` is the concrete transaction-scoped event and
roster gate for all channel adapters. It rejects a replaced episode or thread
head, expired event phase, declined guest or confirmed arrival. Channel-specific
consent, suppression and sender authority must still be read in the same outbox
transaction. The guest webpage at `/event-update/:linkId` uses the public
read/reply boundary and the existing web runtime primitives. Key provisioning,
the live workflow publisher, Host case projection/resolution and rehearsal
response adapter remain separate
integration steps; recording a help case does not yet notify a Host.

The implementation sequence is shared contracts and durable execution, an
SMS/webpage response journey, WhatsApp and RCS adapters, the remaining workflow
families, then verified provider activation. Catalog membership describes an
outcome contract; it does not assert a registered executor or provider readiness.
Applicability, implementation availability, missing facts and host settings must
remain separate. Existing format, attendance, assignment, safety and payment
owners remain authoritative. Ordinary check-in remains an atomic domain command.

The delivery acceptance includes typed/wire-invalid fixtures, duplicate and
reordered signals, revision/context fences, provider ambiguity, current consent,
mode isolation and live/rehearsal parity. Production sends, provider activation,
full layout redesign, autonomous emergency judgement, new payment/tournament
engines and continuous background interception require their own implemented
adapters and acceptance; they are not conferred by these type definitions.

## Format Mapping And Wiring

Event-success setup is driven by the saved `EventFormatSnapshot`, not by raw
event names alone. The intended live path is:

```text
activity kind or custom event name
  -> EventFormatSnapshot interactionModel
  -> EventSuccessActivityProfile and structure defaults
  -> saved eventSuccessPlans/{eventId}
  -> Host Manage setup/live/report UI
  -> attendee companion runtime moment
```

The currently wired pieces are:

- create-event format selection persists `activityKind`, custom label, and
  selected `interactionModel`;
- event-success defaults, structure, Host Manage setup, and preset labels use
  the saved full format snapshot;
- `createEvent` can create the event and initial event-success plan in one
  backend transaction when event-success defaults are enabled;
- Firestore rules allow direct Host setup writes while the event is still
  pre-live, then freeze setup-shaping fields after bookings, waitlist activity,
  check-ins, event start, or live-plan freezing. Live-control fields are
  callable-owned and cannot be changed directly by clients;
- attendee companion routing, event-detail entry, and check-in auto-launch use
  the saved plan/runtime rather than raw event type.

### Founding Organizer Format Packs

The pilot product is one event runtime with format packs, not a collection of
separate quiz, run-club, racket, dinner, or mixer applications. Every pack must
reuse the same operational kernel: event, roster, check-in, saved format,
run-of-show, revision-fenced live controls, manual recovery, and recap. A pack
may change vocabulary, defaults, unit outcomes, and bounded optional modules;
it must not fork routing, attendance, or reporting.

The create-event activity choice is the pack chooser. After selection, the Host
must see a concise `Catch prepares` preview of the resulting operating model
before saving. Custom formats additionally choose an interaction model. The
saved `EventFormatSnapshot` remains the authority; the preview is explanatory
copy, not a second configuration or persistence layer.

The founding packs are:

| Pack | Operating units | Live cadence | Outcome/accountability | Pilot boundary |
|---|---|---|---|---|
| Social run | Pace pods plus a composable route plan | Timed legs | Completion plus finish sweep | Static route operations only; no live GPS tracking |
| Pickleball/padel/racket | Pair assignments and bounded resources | Timed rounds | Ranked outcomes | Existing pair-rotation engine; no bracket/tournament engine |
| Pub quiz | Host/imported teams | Quiz rounds | Numeric points and standings reveal | Not a question authoring, answer validation, or buzzer system |
| Dinner | Tables | Courses | No competitive outcome | True table-seating optimization remains unsupported |
| Mixer/open | Social groups or whole group | Rounds or continuous beats | Optional reveal or no outcome | Uses only saved interaction primitives |

Format-specific language belongs at the edges. The generic Host route remains
`/host/organizers/:clubId/events/:eventId/success`; the runtime derives whether
the primary nouns are team/round/points, pod/leg/sweep, pair/round/rank, or
table/course/prompt. Separate navigation routes per event type would fragment
the operating model and are not part of this contract.

#### Quiz points

Quiz points use the existing `unitOutcome: score` recorder and standings
projection. A scoreable team is resolved in this order:

1. an existing score assignment unit, preserving its stable unit id; then
2. each distinct, non-empty `arrivalGroup` on a currently checked-in
   `eventAttendee`, normalized case-insensitively for duplicate detection.

Roster import and the no-download runtime's required `teamName` field both feed
`arrivalGroup`. Registered but absent teams do not appear in the live recorder.
The Host records one complete numeric score set per round; corrections replace
that round under the existing outcome revision fence and recompute standings.
Attendees see standings only through the existing reveal gate. The first pilot
does not need automatic team balancing to keep score, but it does need every
team to have an arrival group before points can be recorded.

#### Route-based event plan contract

A route plan describes how an event moves, stops, and stays accounted for. It
is not a Flutter navigation route and it is not limited to running. The first
shipped contract is a typed, static Host-authored `RouteEventPlan` persisted at
`EventFormatSnapshot.activityDetails.routePlan`.

The plan composes six independent operational axes:

- movement: run, walk, ride, or mixed;
- route shape: loop, out-and-back, or point-to-point;
- group strategy: together, pace groups, or self-directed;
- stop cadence: continuous, flexible stops, or hosted stops;
- stop modules: water, regroup, venue, photo, viewpoint, hazard, and
  turnaround; and
- route roles: lead, sweep, pacer, stop host, marshal, and photographer.

Activity kind selects only a useful default; it is not the capability gate.
Social runs start with pace groups and a continuous cadence, walks start as one
group with flexible stops, rides add marshal and turnaround operations, and bar
crawls start as hosted point-to-point walks with venue stops. A custom event,
including a photography walk, can opt into the same plan and then compose any
of the axes. This keeps event taxonomy, live interaction model, and route
operations orthogonal.

The initial implementation does not store route names, coordinates, ordered
waypoints, distance, surface, elevation, emergency notes, or attendee map
projections. It must not claim turn-by-turn navigation, live GPS tracking,
off-route alerts, route geocoding, or GPX fidelity. Those are later modules on
top of the route-plan contract, not fields that should be guessed into the
first operational configurator.

#### Pilot activation contract

The first 100 organizers are a concierge cohort, not evidence that onboarding
can remain manual indefinitely. For the first event, Catch should collect the
format, expected headcount, current booking/roster source, team/table/pace data,
venue or course constraints, and the one live failure the organizer fears most.
The operator then imports a realistic roster, runs the saved guide in rehearsal
with synthetic attendees, and reviews the recap after the real event.

Rehearsal is a required next product slice: a read-only or isolated synthetic
roster, explicit `REHEARSAL` chrome, no production attendance/messages/outcome
writes, and a resettable clock. Until that isolation exists, onboarding may use
staging fixtures but the product must not label a production event as safely
rehearsable.

Pilot success is activation and repeated operational use, not account creation:
time to first configured event, roster readiness before doors open, successful
check-in, live-guide use, recoveries/overrides, completed points or sweep when
the format calls for them, recap viewed, and a second event scheduled. Billing,
marketplace demand, a general quiz engine, tournament brackets, live run
tracking, and fully self-serve onboarding are outside this first tranche.

Assignment generation is deliberately narrower than the format taxonomy. The
format primitives now resolve a `matchingObjective` independently from
`compatibilityPolicy`: the objective selects the product goal (`coverage`,
`romantic`, `affinity`, `novelty`, `balance`, or `spread`), while the policy is
the sole authority for which profile, questionnaire, or activity signals may
be read. `coverage` is the engine default and remains meaningful with no
profile or questionnaire data. An objective whose permitted inputs are absent
falls back explicitly to `coverage` and records the reason; it must not widen
the policy to obtain a score.

Saved format primitives may override the objective. Otherwise pace pods bind
to `affinity`, pair rotations to `balance`, team rotations to `spread`, seated
tables to `affinity`, mutual-interest mixers to `romantic`, and other mixers or
host/open formats to `coverage`. These bindings are resolved from the saved
interaction model rather than by event-type branches in generators or screens.
The Functions contract owns an exhaustive resolution table for every
assignment-algorithm, compatibility-policy, matching-objective, and topology
combination.

The saved format primitives also resolve `unitOutcome` independently from the
assignment algorithm. `none` records no result, `completion` records done/not
done units, `score` accumulates numeric round totals, and `rank` records a
complete ordering. Pace pods default to `completion`, team rotations to
`score`, pair rotations to `rank`, and dinner/seated-table formats to `none`;
an explicit saved value wins. The Functions resolver enumerates this axis with
the other primitives rather than branching on an event name.

`accountability` is another saved, format-neutral primitive with `none`,
`rollCall`, and `sweep`. `pacePods` defaults to `sweep`; every other interaction
model defaults to `none`, and an explicit event-format value wins. Runtime code
branches on that primitive only, never on `activityKind`. T11 implements the
end-of-event `sweep`; `rollCall` remains a distinct value and does not silently
inherit sweep completion behavior.

`durationShape` gives the existing flat run-of-show list format-owned grouping
and transition vocabulary without creating a second schedule model. The four
values are `continuous`, `rounds`, `courses`, and `segments`; saved format
primitives may override the playbook default. Pace-pod formats default to
segments, paired/team/free-form formats to rounds, seated-table formats to
courses, and host-led/open formats to continuous. The Host control room labels
the same next-step transition as a Beat, Round, course, or Leg from this
primitive. Screens do not branch on `activityKind` to choose that language.

V1 supports set-based pair rotations and generic micro-pods, plus
capacity-aware `sequence` scheduling for pair rotations. Sequence scheduling
uses the saved `resourceCapacity.concurrentUnits` value rather than a
format-specific court constant. Null is unconstrained; a selected organizer
layout still bounds the usable physical units. Each round stores explicit
sit-outs and stable resource-unit ids, prioritizes the T3 cumulative exclusion
ledger when capacity is scarce, and minimizes attendee movement over the T5
derived unit-proximity graph. Host-authored overrides are rejected when a round
exceeds the same configured capacity.

Algorithms without a dedicated engine, including `none`, `teamBalancer`, and
`tableSeating`, resolve to `unsupported` with an honest reason. They never run
an implemented neighbouring behavior or rewrite existing assignments.
`topology: adjacency` likewise remains unsupported, including when table
resource and seat counts are present. True table-seating, team-balancing, and
dance-partner engines remain future backend work.

Operational roster imports now retain an optional `arrivalGroup` from reviewed
provider booking, order, group, or ticket-buyer columns. Provider adapters keep
the attendee-level reference distinct from that shared arrival group, so two
guests on one booking do not collapse into one import identity. The value stays
private on `eventAttendees` and is carried into the server-side Event Success
roster; it is never returned as public roster data.

The assignment engine accepts pairwise `affinityConstraint` values
`mustPair`, `mustSplit`, `avoidRepeat`, and `neutral`, each scoped to
`thisRound` or `pinned`. The engine applies the active constraints it is given;
the live-control owner is responsible for consuming `thisRound` after one
round and retaining `pinned` until explicit release. Safety block edges are
evaluated first and always override `mustPair`.

Assignment fairness also carries a format-neutral exclusion ledger. It tracks
cumulative minutes that each assignment participant is unassigned, starting at
the later of event start or attendee check-in and subtracting merged assignment
intervals. The optimizer minimizes the maximum projected exclusion before
assignment score within the active compatibility and safety tier. The Host
control room raises only an aggregate intervention prompt at the inclusive
threshold; it does not reveal attendee names. Forty minutes is the shared
default, exposed as configuration at both the optimizer input and Host surface
rather than embedded in event-type logic.

## Code Map

| Surface | Path |
|---|---|
| Domain/runtime/playbooks | `lib/event_success/domain/` |
| Repository/providers | `lib/event_success/data/event_success_repository.dart` |
| Host setup/live/report UI | `lib/event_success/presentation/event_success_host_screen.dart` and `host_parts/` |
| Attendee companion UI | `lib/event_success/presentation/event_success_companion_screen.dart` and `companion_parts/` |
| Shared Host/attendee room map | `lib/event_success/presentation/event_success_room_map.dart` |
| Live reveal UI | `lib/event_success/presentation/event_success_live_reveal_card.dart` and `live_reveal_parts/` |
| Backend generators/wingman callables | `functions/src/eventSuccess/` |
| No-download guest runtime | `website/src/features/eventRuntime/` |
| Feedback scorecards/safety mirror | `functions/src/marketplace/eventSuccessScorecards.ts` |
| Tests | `test/event_success/`, `functions/src/eventSuccess/*.test.ts`, `functions/src/marketplace/eventSuccessScorecards.test.ts` |

## Firestore Contracts

| Collection | Owner and visibility |
|---|---|
| `eventSuccessPlans/{eventId}` | Host-owned setup plus backend-owned live state. `liveControlRevision`, draft revision, and published rotation/reveal indexes are callable-owned. Setup fields freeze once participant activity/start/live status begins; active participants can read through event-success rules. |
| `eventSuccessFeedback/{eventId_uid}` | Attendee-owned decomposed post-event feedback. Raw notes and safety details are private to attendee/backend. |
| `eventSuccessConversationGraphs/{eventId_uid}` | Server-written post-event conversation edges. Only the subject attendee may get the deterministic document; Hosts, other attendees, lists, and every direct client write are denied. |
| `eventSafetyReports/{feedbackId}` | Backend-owned Catch-private safety mirror for concerning feedback. |
| `eventSuccessPreferences/{eventId_uid}` | Attendee-owned live-guidance opt-outs. |
| `eventSuccessCompatibilityResponses/{eventId_uid}` | Attendee-owned compatibility answers. Hosts cannot read individual answers. |
| `eventSuccessWingmanRequests/{eventId_uid}` | Attendee consent document for host-visible introduction help. Target is not notified by this surface. |
| `eventSuccessArrivalMissions/{eventId_uid}` | Server-owned First Hello mission. Attendee can read only their own mission; clients cannot create, update, list, or delete. |
| `eventVenueSessions/{sessionId}` | Short-lived server-owned Host venue authority. Direct client reads/writes are denied; TTL uses `expiresAt`. |
| `eventVenueSessionRedemptions/{sha256(eventId_sessionId_uid)}` | Server-only single-use receipt. One live session may admit multiple attendees, but the same authenticated attendee cannot replay it. TTL uses `expiresAt`. |
| `eventSuccessAssignments/{eventId_moduleId_uid}` | Server-owned assignment docs for micro-pods/guided rotations. |
| `eventSuccessAssignmentDrafts/{eventId_moduleId_uid}` | Server-owned, Host-readable next-round rotation drafts. Participants cannot read or write this collection. |
| `eventSuccessPresence/{eventId_uid}` | Server-owned heartbeat timestamps for checked-in Flutter and no-download runtime attendees. Every direct read/write is denied; Host summaries are callable-derived. |
| `eventSuccessLateArrivals/{eventId_uid}` | Server-owned Host resolution for one checked-in late attendee. The attendee and event Host may get the deterministic document; list and every direct write are denied. |
| `eventSuccessUnitOutcomes/{eventId}` | Server-owned complete round facts for completion, score, or rank outcomes. Hosts may get the event document; attendee reads, list access, and every direct write are denied. |
| `eventSuccessStandings/{eventId}` | Server-owned score/rank snapshots through each recorded round. Authorized Hosts, active participants, and ready external runtime identities may get the event document; list and direct writes are denied. |
| `organizerEventSuccessLayouts/{organizerId_layoutId}` | Reusable organizer-owned parametric room-layout assets. Organizer managers may read their assets; all writes use the validated callable. Participants receive only the selected layout's timestamp-free projection through an authorized callable/runtime bootstrap. |
| `eventSuccessScorecards/{eventId}` | Server-owned aggregate coaching scorecard. Host-readable through event-success policy. |

Schemas live under `contracts/firestore/` and generated outputs under
`functions/src/shared/generated/`, `lib/core/schema_contracts/generated/`, and
`tool/contracts/generated/`.

### Presence and late arrivals

An open checked-in companion sends `heartbeatEventSuccessPresence` from both
Flutter and `website/src/features/eventRuntime/`. The server stores only the
latest timestamp and derives `present`, `idle`, or `likelyDeparted` from its own
clock. Deployment configuration owns the bounded policy:

- `EVENT_SUCCESS_HEARTBEAT_INTERVAL_SECONDS` defaults to 30;
- `EVENT_SUCCESS_PRESENCE_PRESENT_SECONDS` defaults to 90;
- `EVENT_SUCCESS_PRESENCE_LIKELY_DEPARTED_SECONDS` defaults to 300.

Invalid, out-of-order configuration fails back to the reviewed defaults.
Attendees without any monitored heartbeat are not inferred to have departed.
`getEventSuccessPresenceSummary` is Host-only and supplies the liveness prompt
and newly checked-in late-arrival candidates. A Host explicitly regenerates the
next draft after reviewing likely departures; the server never silently edits a
live round.

`resolveEventSuccessLateArrival` is Host-confirmed and shares the live revision
fence. It may replace a `likelyDeparted` draft slot, turn a prepared sit-out into
an open pair, extend an unpublished group up to its declared unit size, or hold
the attendee for the next round with a visible reason. It writes only
`eventSuccessAssignmentDrafts` and `eventSuccessLateArrivals`. Published
`eventSuccessAssignments` are immutable through this operation.

### Accountability sweep

For `accountability: sweep`, the Host control room lists every currently
checked-in `eventAttendees` row, including imported or unlinked guests. A Host
may mark each row `returned` or `departed`. The server stores the exact
`checkedInAt` timestamp beside the resolution; checking in again makes the old
resolution stale and reopens that attendee without requiring a destructive
history rewrite.

Unresolved rows raise a completion warning. `Review sweep` returns to the list;
`Finish anyway` sends an explicit acknowledgement and completes normally. This
is intentionally a safety aid rather than a checkout mandate: guests may leave
quietly, and unresolved state is not evidence of an incident. `none` and
`rollCall` never inherit the sweep warning.

First Hello check-in is modeled as an optional arrival module with server-owned
mission assignment/completion. `startEventSuccessFirstHelloMission` verifies the
attendee is signed up, the check-in window is open, a current signed Host venue
session is redeemed, the module is selected, and a compatible checked-in target
exists. The mission persists that venue proof. `completeEventSuccessFirstHelloMission`
verifies the active mission, unconsumed proof, answer, and block state, records
only the observer's answer on the mission, consumes the proof, and marks
attendance without a second location or QR claim.

### Conversation graph

After the event ends, a checked-in attendee sees one roster-chip prompt in the
no-download runtime. Assigned attendees are shown first and the label is
derived from the saved interaction primitive (running partners, teammates,
tablemates, or opponents/partners); the screen and submission mechanism do not
fork by activity kind. The server excludes the caller and every blocked
relationship before returning candidates.

The per-event `conversationGraphConsentMode` is configurable during Host setup.
The reviewed default is `optIn`: assigned attendees are suggested but no chip
is selected. `optOut` preselects only visible assigned attendees, and the
attendee can remove selections or skip. Missing legacy configuration resolves
to `optIn`.

`getEventSuccessConversationGraph` and
`submitEventSuccessConversationGraph` require an attended unified-roster edge
and an ended event. Submission is idempotent and stores the raw UID edges only
in the attendee-private conversation-graph document. The Host scorecard
receives numeric response, conversation, assignment-opportunity, and exclusion
counts. It never receives who named whom.

### Live Control Robustness

`controlEventSuccessLive` owns step, completion, reveal countdown, reveal
publication, and pre-expiry countdown cancellation. Every non-idempotent write
compares `expectedRevision` with `liveControlRevision`. Reveal publication is
monotonic: an expired countdown is already published according to its persisted
server anchor, and neither cancellation nor a later action can move the
published reveal index backwards.

For a sweep event, completion also reads the bounded operational roster. An
unresolved row requires `accountabilityAcknowledged: true`; acknowledgement is
the warning override, not a hard block. Already-complete actions remain
idempotent.

Guided rotations use a two-stage boundary. `generateEventSuccessRotations` and
Host overrides write only `eventSuccessAssignmentDrafts`; the Firestore trigger
`onEventSuccessPlanLiveControlUpdated` prepares round N+1 asynchronously while
round N is live. `publishEventSuccessRotationRound` transactionally publishes
only the requested prepared round to attendee-readable assignments and is
idempotent for retry. The beat-transition module does not import or invoke the
assignment generator. Trigger preparation retries are bounded by the validated
deployment setting `EVENT_SUCCESS_DRAFT_PREPARATION_ATTEMPTS` (1-10, default
3).

When the plan selects `topology: sequence`, generation runs the deterministic
round-robin scheduler. Every allowed pair meets once before a configured repeat
cycle, safety and must-split edges are never scheduled, odd rosters receive
fair byes, and court/table/lane/board capacity is enforced independently of the
event type. Legacy plans without `topology` continue to resolve to `set`.

### Unit Outcomes And Live Standings

`recordEventSuccessUnitOutcomes` lets an organizer manager replace one complete
round under an outcome revision fence. Exact replay is idempotent. New rounds
must be sequential; score corrections recompute all accumulated snapshots and
rank corrections replace the affected complete ordering. Duplicate units,
partial or non-contiguous rank orders, an entry shape inconsistent with the
saved format, and `unitOutcome: none` fail closed. Completion facts stay in the
Host-only source collection and intentionally produce no standings document.

For `score` and `rank`, the Host recorder appears inside the existing live
reveal card. Flutter companions and the no-download runtime read the same
standings projection and select the latest snapshot no later than
`publishedRevealRoundIndex`. The existing `idle` / `countingDown` / `revealed`
state and server anchor mask the table until publication on every runtime.
There is no second reveal confirmation, countdown, or ceremony implementation;
the existing assignment-reveal slot switches its payload to standings.

### Spatial Layout And Control Room

Host Manage treats the saved live plan as a command workspace, not a generic
dashboard. Below the local 900 px component breakpoint, Live Now remains the
single-column Quiet Command Console with one pinned Previous/Continue region.
At or above that width, the same provider-free state reflows into a dominant
dark current-beat stage and one 360 px supporting-operations lane. Guests,
fallback help, cumulative-exclusion warnings, and current-step controls remain
concurrent there; the roster itself stays the canonical lazy overlay. No
additional mutation, permission, or source of live truth appears on wide
screens, and text scale 1.4 or above uses the compact flow to protect reading
width and semantic order.

An event-success plan may select one reusable organizer layout by `layoutId`.
The layout remains an organizer asset rather than being copied into the event.
Create Event and post-creation Host Setup use the same provider-free room setup
component to select or author this asset, and saving Host Setup persists the
selected `layoutId` with the plan. Its parametric specification is a bounded
list of coarse integer-grid units;
each unit declares one of `round`, `rect`, `row`, `court`, or `zone`, plus a
capacity and stable order. The app authoring sheet exposes unit count, capacity,
column count, and all five shapes. It does not provide a to-scale venue editor.

Normalized rendering rectangles and the complete Euclidean unit-proximity
graph are derived from the parametric grid. Proximity has no hidden cutoff.
Flutter and the React guest runtime prove their render normalization against
the same `contracts/catalogs/event_success_layout.json` fixture.

Non-`wholeGroup` assignments carry an assigned `layoutUnitId` and a separate
nullable `confirmedLayoutUnitId`. An outline means assigned; only explicit Host
confirmation fills the position. The Host can tap an attendee and then any
valid destination on every device. Invalid destinations remain visible with a
capacity, safety, or declared-constraint reason. Drag is an additive large-
surface affordance selected by
`ComponentBreakpoints.eventSuccessSpatialDragBreakpoint`; it is never the only
path. The companion and no-download guest runtime are read-only and receive no
other attendee positions.

`controlEventSuccessSpatial` previews or writes a placement under the same
`liveControlRevision` single-writer fence as T4. Every reassignment persists a
T2 `mustPair` constraint with explicit `thisRound` or `pinned` scope; a pinned
placement survives regeneration until released, while a this-round placement
does not. `upsertEventSuccessLayout` owns reusable organizer asset writes and
`getEventSuccessSpatialLayout` returns only the selected authorized projection.
`wholeGroup` plans return no spatial projection or map.

## Product Guardrails

- Keep high-churn state out of `events/{eventId}`. Use event-success edge docs.
- Setup fields that affect attendee expectations freeze once the event starts
  or participant activity begins unless product explicitly adds a late-change
  path with attendee notice.
- Compatibility tools are conversation context, not a promise of chemistry.
- First Hello check-in is an optional arrival ritual, not a replacement for
  ordinary attendance. The normal check-in path remains available as a host
  fallback, QR scan, or self-check-in fallback.
- Social runs should stay lightweight; structured mixers, racket pairs, dinners,
  and quiz/team formats can carry more live facilitation.
- Safety/comfort feedback is Catch-private first. Hosts see aggregate coaching,
  not raw safety notes or personally identifying safety details.
- Host reports should teach hosts how to run better events, not expose attendee
  intelligence.
- Guided-rotation drafts are Host-only and become attendee-readable only through
  explicit round publication. Already-published assignment documents remain
  attendee-readable; publication is not a reversible secrecy control.
- "Help me meet someone" without a selected attendee is deferred. Launch host
  help is specific-person only.

## Runtime Model

`EventSuccessRuntime` decides host and attendee moments from the saved plan,
participation status, active run-of-show step, reveal state, and event-ended
state. Screens should not infer availability directly from plan booleans.

Booked attendees are in pre-arrival planning. Checked-in attendees see one
step-synced companion moment at a time. Ended attended users see feedback and
post-event follow-up. Do not reintroduce a stacked attendee dashboard that shows
every enabled module at once.

First Hello sits between signed-up arrival and attended state. Runtime shows a
startable First Hello moment when the module is selected, check-in is open, and
the user is still `signedUp`; after the backend assigns a mission, the same
moment renders the target and answer options. If First Hello is unavailable, the
runtime falls back to the normal questionnaire/self-check-in/pre-arrival flow.

Activity recommendations live in
`lib/event_success/domain/event_success_activity_profile.dart`. Do not add
activity-specific toggles directly in screens.

## External Booking Overlay Runtime Implementation Contract

This section is the implementation and handoff contract for Event Success on
events booked through another platform. A lower-context implementation agent
must be able to take one numbered tranche below, inspect only the named owner
files, and prove it with the named tests without re-deciding product scope.

### Durable product boundary

Event Success requires an authenticated event participant, not a Catch
Consumer profile. First Hello, event-specific compatibility, micro-pods,
guided rotations, specific-person wingman requests, synchronized reveals,
ordinary QR/manual attendance, private feedback and Host-safe reporting are
available to an imported attendee after phone verification, roster claim,
required-field completion, disclosure and opt-out. Full public/dating profiles,
mutual Catch, persistent chat, Cross Paths, cross-event discovery and
longitudinal recommendations remain Consumer-network capabilities.

Ordinary check-in is a platform primitive. A Host can check in any operational
attendee. Static join links and QR codes grant no attendance by themselves.
First Hello is an optional arrival ritual and cannot be the only check-in path.

### Event provenance and capability projection

`events/{eventId}` remains the operational aggregate for both Catch-native and
externally booked events. `externalEvents/{eventId}` remains read-only public
supply and is never promoted into an operational authority in place.

Each operational event stores one immutable `eventOrigin`:

```json
{
  "mode": "catchNative | externalCompanion",
  "bookingAuthority": "catch | external",
  "rosterAuthority": "catchProjection | hostImport | providerSync",
  "provider": "catch | generic | luma | eventbrite | partiful | posh | bookmyshow | district | sortmyscene | airbnb",
  "externalEventId": null,
  "externalEventUrl": null,
  "sourceExternalEventId": null,
  "adapterVersion": null,
  "connectedAt": null,
  "connectedBy": null
}
```

Existing events without `eventOrigin` read as `catchNative`. Creation persists
the field for every new event. Origin never changes after creation. Publication,
registration, payments and network access remain independent server-derived
capabilities; do not add a Host-writable `hybrid` mode or infer capability from
price/count fields.

`externalCompanion` invariants: external checkout remains booking authority;
Catch booking/payment/waitlist writes fail closed; roster import/manual entry,
phone-OTP claim and Event Success remain enabled; imported rows do not increment
Consumer booking counters; operational aggregates derive from
`eventAttendees`; conversion to Catch booking is a migration for a future
occurrence, not an in-place flag flip against shared inventory.

### Identity graph

| Collection | Identity and authority |
|---|---|
| `eventAttendees/{attendeeId}` | Host-visible event-scoped operational person, imported contact/source, attendance and optional `linkedUid`. |
| `eventParticipations/{eventId_uid}` | Catch booking, payment, waitlist and Consumer-network lifecycle. It is optional for Event Success. |
| `eventRuntimeParticipants/{eventId_uid}` | Participant-private access, roster claim, disclosures, minimal runtime profile and readiness. |

The deterministic runtime-participant id is `${eventId}_${uid}`. Its required
shape is:

```json
{
  "eventId": "event-id",
  "clubId": "organizer-compatibility-id",
  "organizerId": "organizer-id",
  "uid": "firebase-auth-uid",
  "eventAttendeeId": "opaque-roster-id",
  "identityVersion": 1,
  "claimMethod": "verifiedPhone | signedAttendeeToken | verifiedEmail | hostApproval | catchParticipation",
  "accessStatus": "needsInput | ready | optedOut | revoked",
  "requiredFieldIds": [],
  "completedFieldIds": [],
  "runtimeProfile": {
    "displayName": "Attendee supplied name",
    "gender": null,
    "interestedInGenders": [],
    "relationshipGoal": null,
    "dateOfBirth": null,
    "paceBand": null,
    "skillBand": null,
    "dietaryAndSeatingNotes": null,
    "questionnaireAnswerIds": [],
    "teamName": null
  },
  "consents": {
    "runtimeTermsVersion": "event-runtime-v1",
    "sensitiveDataTermsVersion": null,
    "saveAsCatchPrefill": false
  },
  "claimedAt": "timestamp",
  "readyAt": null,
  "revokedAt": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

The participant can get only their deterministic document. List access is
denied. Hosts do not read this collection. Host UI receives non-sensitive
runtime readiness from a server projection or callable and never receives
gender-interest, relationship-goal or compatibility answers.

### Runtime-profile requirements

`eventSuccessPlans/{eventId}` owns a server-compiled participant-requirements
projection: questionnaire version; required and sensitive field ids from
`displayName`, `gender`, `interestedInGenders`, `relationshipGoal`, and
`dateOfBirth`, plus exactly one resolved pre-event payload when the format
requires it: `paceBand`, `skillBand`, `dietaryAndSeatingNotes`,
`questionnaireAnswerIds`, or `teamName`; whether module opt-out is allowed; and
module disclosure versions. Clients cannot widen or narrow requirements. Do
not collect a sensitive value unless an enabled algorithm consumes it.

The pre-event field is selected from the effective interaction model rather
than `ActivityKind`. It is part of the ordinary required/completed-field state,
so `accessStatus: ready` and `readyAt` remain the countable, non-sensitive Host
readiness source. Pace/skill values are assignment attributes, mixer answers
also update the private compatibility-response edge, and quiz team names update
the existing operational `arrivalGroup`. Dinner constraints remain private and
event-scoped; they do not enable or imitate `tableSeating`, and Host surfaces
must not expose the answer while that engine remains unsupported.

Existing private Consumer values may prefill the event form but must be
confirmed. Event answers never overwrite `users/{uid}`. When the participant
explicitly selects `saveAsCatchPrefill`, the server fills only missing
`onboarding_drafts/{uid}` fields, records field provenance, and never creates
`users`, `publicProfiles`, marketing consent or an `eventParticipation`.

### Runtime access state machine

```text
anonymous -> phoneVerified -> rosterClaimed | hostApprovalPending
  -> needsInput | ready -> checkedIn -> active -> completed

Any linked state -> revoked
needsInput -> optedOut (for optional private modules only)
```

Phone verification is Firebase Auth, not proof of one roster row. Claim
resolution uses: one unique normalized-phone row; one valid attendee-specific
signed token plus OTP; one verified email row plus OTP; explicit Host approval;
or Host-enabled walk-in creation followed by link. Names are never credentials.
Ambiguous matches do not merge automatically. One buyer phone may own multiple
provider tickets, so multiple active matches enter approval unless a single-use
attendee token disambiguates them.

### Public runtime operations

All writes are App-Check-protected authenticated callables that validate event
window, capability, hidden safety state and deterministic ids.

| Operation | Required behavior |
|---|---|
| `getEventRuntimeBootstrap` | Accept opaque public runtime id; return sanitized event, required fields, auth/claim/readiness state and current moment. Never return roster or raw contacts. |
| `claimEventRuntimeAccess` | Link/reuse exactly one attendee row, create/update runtime participant, and return `ready`, `needsInput` or `hostApprovalPending`. |
| `submitEventRuntimeProfile` | Accept only required fields, validate consent/version, recompute completeness and optionally fill missing onboarding draft fields. |
| `heartbeatEventSuccessPresence` | Accept only a checked-in caller and record a server-timestamped liveness heartbeat. Return the active configurable cadence and thresholds. |
| `setEventSuccessAccountabilityResolution` | Organizer-manager-only returned/departed/unresolved write for one currently checked-in operational attendee on a `sweep` event. Bind the result to that exact check-in timestamp. |
| `setEventRuntimeModuleOptOut` | Purpose-scoped opt-out that does not cancel attendance or identity. |
| `checkInEventRuntime` | Redeem a current signed Host venue session after identity/profile readiness and apply absolute attendance; never a blind toggle. |
| `approveEventRuntimeClaim` | Host approves one pending UID-to-attendee claim or rejects it with a bounded reason. |

Static join URLs use opaque `publicRuntimeId`, never event id plus phone. An
attendee token is random, single-purpose, revocable and hashed at rest. A venue
check-in QR uses a configurable, bounded short-lived signed session and refreshes
automatically on the Host screen. The token travels in the guest URL fragment,
is cleared after route intake, and is verified against a server-owned session
row inside the attendance transaction. A printable or shared join QR has no
token and cannot prove physical attendance. Location fields are rejected by all
three attendee attendance schemas.

### Unified Event Success participant resolver

Functions under `functions/src/eventSuccess/` consume one shared module:

```ts
resolveEventRuntimeParticipant(db, eventId, uid)
listEligibleEventRuntimeParticipants(db, eventId, requirements)
resolveEventRuntimeCandidateProjection(db, eventId, viewerUid)
```

For Catch-native participants the resolver may project from Consumer edges and
profiles. For imported participants it uses the linked attendee and runtime
profile. All generators filter revoked, opted-out, unready and inappropriate
attendance states here. Candidate projections contain only event-scoped safe
fields. `publicProfiles` is not required. Consumer blocks still apply; separate
event-scoped keep-apart/hide/report edges protect OTP-only participants.

### Dedicated web runtime

The guest surface is the React + TypeScript route owned by
`website/src/features/eventRuntime/` and shipped in the existing `website/`
workspace on the `marketing` Firebase Hosting target. There is no `runtime/`
workspace or `runtime` Hosting target. It shares generated callable types,
Firebase Auth, App Check, and website primitives; it does not share the
Consumer Flutter router.

```text
/e/:publicRuntimeId -> bootstrap -> phone -> OTP -> claim/approval
  -> name + one format-bound pre-event answer
  -> event moment -> completed/feedback
```

The shell is mobile-first, noindex, accessible, refresh-safe and low-bandwidth.
It caches only its shell and sanitized latest moment. OTP, claim and sensitive
writes require connectivity. Retryable actions are idempotent.

When `social_missions` is enabled, the generated moment catalog also owns one
three-level prompt sequence per interaction model. The live run-of-show selects
light disclosure at step 0, personal disclosure at step 1, and reflective
disclosure from step 2 onward. Flutter and web resolve the same prompt id and
level; neither samples a stage bucket or branches on `ActivityKind`.

### Roster adapters and ingestion

The authoritative adapter engine is backend-owned so Flutter upload, email,
WhatsApp and later APIs cannot drift. Adapters declare provider/version, header
signatures, confidence, status mapping, default-country requirements,
buyer/guest/ticket behavior, warnings and normalized output.

Launch ids are `generic-v1`, `luma-v1`, `eventbrite-v1`, `partiful-v1`, and
`posh-v1`. BookMyShow, District, SortMyScene and Airbnb stay `sample_required`
until reviewed exports and policy evidence exist. Each adapter needs synthetic
golden fixtures for free, paid, group-ticket, custom-question and missing-phone
cases. A bare ten-digit number is never globally assumed to be Indian.

Large imports use `eventRosterIngestionJobs/{jobId}`, temporary encrypted
Storage, type/size validation, chunked idempotent writes, bounded errors,
progress and a terminal receipt. The 250-row callable remains compatibility
only. Email uses an event-specific revocable address/token, preview and Host
confirmation. WhatsApp Business document ingestion reuses the job pipeline and
is transport, not marketing consent. Credentials, DNS and webhook registration
are release configuration, not source-code acceptance.

The first practical forwarding slice is now implemented without claiming that
an inbound vendor is live:

- `createEventRosterHandoff` verifies organizer management and creates a
  random, SHA-256-addressed, 30-day `eventRosterHandoffs` capability;
- the Host roster sheet shows email and WhatsApp instructions only when
  `ROSTER_INBOUND_EMAIL_DOMAIN` or `ROSTER_INBOUND_WHATSAPP_NUMBER` is set;
- `ingestEventRosterWebhook` accepts a provider-normalized JSON envelope,
  verifies an exact-body HMAC from `ROSTER_INGESTION_WEBHOOK_SECRET`, requires
  provider-confirmed sender identity, and matches that identity to the Host's
  Firebase Auth email or phone;
- the endpoint accepts one CSV up to 4 MiB, maps at most 250 attendees through
  the backend adapter engine, and reuses `importEventAttendeesForHost`; the
  provider message id becomes the retry-safe import key; and
- raw attachment bytes are processed in memory and not retained. XLSX
  forwarding, files above 250 rows, temporary Storage, progress UI and
  conflict-aware undo still belong to the asynchronous job tranche.

An email-routing or WhatsApp Business provider must transform its proprietary
webhook into the normalized envelope and sign it. Deploying the endpoint alone
does not make the displayed mailbox or phone number operational.

### Security and abuse invariants

- Uniform public errors prevent event/phone/roster enumeration.
- Rate limits cover bootstrap, claim, profile submission, check-in and approval.
- URLs/tokens contain no phone, name, roster id or provider reference.
- Imported contacts grant no future communication permission.
- Sensitive fields are event-scoped and absent from Host reads/logs/analytics.
- Phone recycling, duplicates, plus-ones, minors, cancellation and revocation
  have negative tests.
- Public runtime operations never scan an unbounded roster in a transaction.

### Reviewable implementation tranches

1. Contracts/origin, generated outputs and compatibility fixtures.
2. Bootstrap, claim, profile, approval, attendance, rules and backend tests.
3. Shared resolver plus pods, rotations, First Hello, compatibility and wingman.
4. React runtime, Firebase/App Check, route state machine and build/a11y tests.
5. Host external-companion create/edit, source, adapter preview, QR and approval.
6. Async ingestion, email/WhatsApp endpoints and replay/security tests.
7. Organizer-page capability story, adapter availability and beta application.

Each tranche updates its owner docs and checks in the same commit. Generated
files come from contract sources. No tranche claims a vendor or domain is live
without external verification.

### End-to-end acceptance

- External companion events cannot enable Catch booking/payment/waitlist.
- Re-importing a mixed/provider roster does not duplicate attendees.
- A phone guest claims exactly one attendee or enters Host approval.
- Sensitive fields are minimal, private, versioned and skippable when optional.
- First Hello, compatibility, pods, rotations and wingman work for OTP-only
  participants without `eventParticipations`, `users` or `publicProfiles`.
- Manual and venue-QR check-in work independently of First Hello.
- Runtime refresh resumes the participant's safe moment.
- Later Consumer login sees only explicitly saved, reviewable draft prefill.
- Host views expose readiness and aggregates but no private answers.

## Theatrical Experience Workstream

`docs/event_success_theatrical_experience_tracker.md` is the temporary active
tracker for making the live event companion and host live mode feel more like a
playful synchronized ceremony. Keep durable architecture here, but track phase
status, references, acceptance criteria, and resume notes in that tracker until
the live ceremony, invite loop, private afterglow recap, and branded audio
questions close.

Current defaults:

- live ceremony comes first;
- native haptics and `SystemSound` cues come before a branded audio package;
- pre-event invites are the strongest shareability primitive;
- post-event recap artifacts are private-first unless sharing psychology becomes
  clearer.

Current theatrical implementation state:

- the attendee companion stage redesign, invite loop, and private afterglow
  recap are implemented for visual review;
- First Hello check-in is implemented as an optional arrival module with
  server-owned mission assignment/completion and signed venue-session proof;
- the Host check-in QR is live, signed, short-lived, and auto-refreshing;
  printable/static join links grant no attendance, and Consumer plus guest-web
  attendance callables reject GPS/location claims;
- invite sharing now routes through shared event-invite copy across event
  detail, payment confirmation, and host private-link surfaces;
- post-event companion follow-up now starts with a private in-app afterglow
  recap and keeps host reporting aggregate-safe.

## Production Verification

The former dev-only Event Success lab, preview, and manual-QA routes were
removed after the functionality became available through Host event setup and
Manage plus the attendee companion. Review production widgets directly through
their focused tests, Widgetbook coverage, and real dev/staging event flows.

Check:

- activity profiles: social run, racket pairs, quiz teams, singles mixer/live
  reveal;
- host setup/live/report surface switching;
- optional First Hello arrival mission from host controls through attendee
  completion and checked-in state;
- host `Previous`/`Next` run-of-show transitions updating both panes;
- countdown, confirmed reveal-now, pre-expiry cancellation, and irreversible
  post-publication state;
- confirmed, idempotent publication of the next prepared rotation round with no
  future-round assignment leakage;
- process-death restart during a round resumes the persisted current beat;
- pre-arrival attendee state without live prompt/reveal/partner leakage;
- checked-in attendee moment sync;
- questionnaire, opt-out, wingman request, feedback, and report states;
- organizer questionnaire configuration stays compact: reusable packs show a
  one-row title, description, and question count summary, while detailed
  question inputs appear only when the host selects a custom pack;
- organizer structure configuration stays flat: flow fields are direct section
  rows, whole-group mode omits irrelevant size/count controls, and Match clue
  mode has one disclosure owner inside a full-width structural field section;
- host-help candidate filtering by attendance and interested-in/cohort
  eligibility.

Use a real dev/staging event for write-path proof:

1. Save event-success setup as host.
2. Book/check in at least two attendee accounts.
3. Generate pods or prepare rotations, then edit the Host-only rotation draft.
4. Confirm publication of one prepared rotation round and verify no later round
   is attendee-readable.
5. Drive countdown/reveal from host live mode; cancel only before expiry and
   confirm a published reveal has no reset path.
6. Submit questionnaire, opt-out, wingman request, and feedback as attendee.
7. Confirm host report aggregate signal quality.

## Participant Metrics And Warehouse

Participant success metrics are private marketplace infrastructure. Clients
must not calculate marketplace score, desirability percentile, or event success
scorecards locally.

Current implemented foundation:

- raw facts: `participantSignalFacts/{factId}`;
- counters: `participantMetricCounters/{uid}`;
- future user-facing summaries: `participantMomentum/{uid}`;
- future admin summaries: `participantMarketplaceMetrics/{uid}`;
- event scorecards: `eventSuccessScorecards/{eventId}`;
- client access to raw/admin metrics denied by rules;
- dev/staging Firestore-to-BigQuery extension manifests and datasets exist for
  marketplace metrics exports.

Remaining gates:

- Enable Firebase Analytics BigQuery export in dev/staging when
  Analytics-scoped console/API access is available.
- Add client-side profile impression batching only after the product question is
  concrete.
- Decide host analytics anonymity threshold: 3, 5, or dynamic by event size.

These gates are external access or product-decision items, not hidden app
wiring work. Do not mark them complete from code changes alone.

## Recent Technical Closure

The temporary Event Success technical-fixes tracker from 2026-05-23 is folded
into this source-of-truth doc. Durable outcomes from that pass:

- reveal countdowns are server-anchored and derive end time from
  `revealStartedAt + structureConfig.revealCountdownSeconds`;
- the companion route renders one stable scaffold across loading/error/content
  states;
- host reports no longer fabricate negative coaching from an absent scorecard;
- the dead repeat-signup scorecard metric was removed;
- wingman candidate fetching batches block/profile reads;
- custom event formats persist from create-event through defaults, Host Manage,
  and saved plans;
- assignment callables share topology and compatibility policy guards;
- companion auto-open/post-event runtime regressions have focused coverage;
- local simulator phone-auth test bypass is guarded to non-production builds.

## Setup Configuration Contract

The 2026-07-16 modernization replaces the original pre-design-system setup
wizard with a compact shared form. Durable outcomes:

- **Phase 1 — surface unification.** `EventSuccessSetupBody` is the shared
  setup widget consumed by both `EventSuccessDefaultsPanel` (create-event last
  step) and the Host Manage setup tab. The two surfaces stay in sync
  automatically — no copy or behaviour drift.
- **Room setup parity.** `EventSuccessRoomSetupSection` is the shared layout
  selector and authoring entry used by Create Event and post-creation Host
  Setup. Live Operations exposes Now and Room as local workspaces while Guests
  remains the canonical overlay roster; the Room workspace renders explicit
  whole-group, unconfigured, loading, error, waiting-for-placement, and ready
  states instead of making the map disappear.
- **Format-first disclosure.** The saved `EventFormatSnapshot` remains the
  event-format authority and is the first setup row. The host sees the format
  and playbook summary before detailed tools; an explicit `Customize` action
  reveals the module rows. Closing and reopening that disclosure never
  rewrites the draft, so customized module, cadence, reveal, questionnaire, and
  grouping values remain lossless.
- **Stage-based live guide.** The shared body groups selectable tools by their
  domain stage: Before the event, When people arrive, During the event, and
  After the event. Catalog order remains stable inside each stage, and
  recommendation or advanced guidance stays on the relevant toggle row.
- **Contained configuration.** Rotation cadence, reveal countdown, and match
  clue configuration appear directly beneath the tool that enables them in
  `CatchSection.containedFieldRows`. Room grouping appears only when a grouping
  tool or non-whole-group structure makes it relevant. Host goal and attendee
  prompt remain direct editable fields.
- **Inline questions.** Template and custom-question editing stays in the form;
  there is no secondary bottom sheet. Raw text remains editable until save,
  where normalization and validation run once.
- **Immediate switches.** In Organizer defaults, Event Success enablement and
  live-tool switches persist as soon as they change through functional updates
  and the serialized `HostClubDefaultsSaver` queue. Text, numeric, and choice
  fields keep field-local explicit actions so partial input is never saved
  accidentally.
- **Spoke ownership.** Club-level Event Success defaults live on the dedicated
  Live event guide spoke reached from the four-row Club settings section. The
  Edit tab no longer embeds the form alongside profile, payout, and team UI.
- **Platform boundary.** Attendance/check-in, safety controls, crowd balance,
  wingman requests, contextual openers, attendee feedback, and host analytics
  are event-platform primitives. Catalog metadata hides them from host setup;
  effective reads and new defaults/plans include every platform-owned id that
  the active playbook contains, while untouched legacy JSON remains unchanged.
  The two legacy boolean fields stay serialized as `true` until a later schema
  migration. First Hello remains the only Event Success arrival ritual.
- **Phase 4 owner-review prototype.** Widgetbook contains an owner-review-only
  `EventSuccessModuleConsolidationPrototype` under
  `Event Success / Phase 4 owner review`. It demonstrates the proposed single
  How people mix choice, conditional size/count/cadence/repeat row order,
  recommendation copy, and a five-decision visible tool set. Production now
  owns the prerequisite format-first disclosure and lossless Customize path.
  The prototype still has no writer, and its composite grouping control remains
  an owner-review surface until it can preserve the pair-only backend-safe
  interaction honestly.
- **Guarded persistence.** Setup saves are transactionally revision checked,
  reject frozen or stale plans, and update only setup-owned fields. A newer
  remote snapshot never silently replaces local unsaved edits.
- **Topology parity.** Guided rotations normalize to two-person pairs, and
  client structure estimates clamp fixed group counts using the same bound as
  the assignment backend.
- **Companion ergonomics.** Hero re-frames around "what now". Live
  cards use Switch-based include/skip toggles instead of buttons. Pre-arrival
  is informational only — no opt-out levers before the event starts. Three-tier
  privacy badges (Private to you / Host can see / Catch private) appear on
  every surface that produces persisted data. The companion build method is a
  flat list-builder pattern, and the dead `if (showLiveReveal) reveal else
  pod/rotation` inner branches inside `showPodAssignment` and
  `showRotationSchedule` are removed (those runtime kinds are mutually
  exclusive with `liveReveal`).

## Phase 5 — Kinetic Companion Immersion

The 2026-05-24 kinetic pass turned the companion stage from a static gradient
into a perpetually-moving cinematic surface with audio, co-presence, and a
marquee reveal moment. The vibe is moment-keyed: theatrical for arrival,
pulse for live event beats, sunrise for afterglow. The generated presentation
contract now selects the palette and motif ids per beat, while
`_CompanionStageTheme.forMoment` maps those ids into Flutter design tokens.

The durable choreography source is now
`contracts/catalogs/event_success_moment_presentations.json`, generated into
typed Dart and TypeScript. `EventSuccessMomentPresentation.forMoment` continues
to own localized copy and icons, but it resolves palette, accent policy, motif,
phase durations, tempo, idle-pulse period, particle density, deterministic
seed rule, server-clock reference, and ambient bed from that catalog. Flutter
and the no-download runtime both resolve the reveal from the same
`revealStartedAt` server anchor and saved reveal countdown. The shared seed is
derived from event id, moment kind, reveal round, and that anchor. This is one
moment model for every event format; there is no event-type presentation fork.
Web retains the metadata for parity and ships no per-attendee audio.

- **Portable marquee assets.** Three checked-in Lottie vector documents under
  `assets/motion/event_success/` own theatrical, pulse, and sunrise art for the
  Flutter companion and React guest runtime. The generated motif id selects
  one asset, and the catalog's idle-pulse period drives playback. The former
  stage, arrival-ring, and reveal `CustomPainter` implementations are deleted;
  they are not retained as a parallel path.
- **Idle pulse + touch microinteractions.** `_StagePanel` breathes on a 6s
  sine border-glow. `_StageGlyph` runs an entry spring tween then a
  continuous 4s breath modulating scale + accent glow blur. `_StageBouncyPress`
  + `_StageBouncyChip` give chips and tap targets a 220ms scale-down +
  elastic spring-back + glow flare instead of Material's ink ripple.
  Questionnaire and First Hello answer chips now use the kinetic variants.
- **Audio infrastructure.** `audioplayers ^6.6.0` ships a multi-channel
  controller in `event_success_live_effects_controller.dart`. One persistent
  ambient bed player (looped) and one reusable low-latency one-shot player
  (effects). `EventSuccessAmbientBed` enum (theatrical / pulse / sunrise /
  silent) is selected through the generated per-moment presentation contract.
  Per-kind volume tuning — reveal lands at 0.95, taps at 0.48. Missing
  assets are caught + memoized so the UI never blocks on the sound designer.
  Six curated stock sounds to source are documented in
  `assets/audio/event_success/README.md`.
- **Reveal cinematic (the marquee).** `_RevealCinematicOverlay` composes the
  portable vector assets with ordinary Flutter widgets over the full stage:
  anticipation (vignette darkens 0.18→0.6, 14 gold spokes rotate with
  acceleration `pow(anticipation, 1.4) × 2π × 1.8`, and the contracted particle
  field drifts inward), climax (white flash and seeded particle burst), then
  settle (vignette release and sunrise art). A configurable 100ms clock samples
  the generated timeline, so phase entry does not wait for a Firestore status
  transition and remains inside the 250ms cross-runtime gate.
- **Co-presence layer.** Three surfaces wired off the existing
  `Event.checkedInCount` (denormalized + maintained by Cloud Functions — no
  new Firestore listeners): `_LiveArrivalRing` on arrival moments (140×140
  Lottie-backed ring with 24 anonymous dot slots, big tabular numeral in center,
  scale-pulse on increment), `_LiveOthersInRoomLine` on the questionnaire
  progress rail (pill with chip pulse on count climb), and a shared
  anonymous-dot ring inside the reveal cinematic pulsing on the same
  server-derived tick clock so every attendee's screen pulses on the *same* shared
  rhythm during the countdown.
- **First Hello completion celebration.** When the answer submits, the
  card overlays a sunrise gradient sweep (triangle-wave alpha to 0.62 over
  800ms), `guideComplete` haptic + chime fires, and the animation runs in
  parallel with the network call so the gradient never snaps off
  mid-animation when the moment transitions.
- **Afterglow paced reveal.** `_AfterglowBeatGrid` is Stateful: beats slide
  in from below + fade with a 1.4s stagger between rows. Beats can carry an
  optional `countValue` (the "X people remembered" beat uses it) — the
  first run of digits in the value string animates 0→countValue over 600ms
  on an easeOutCubic curve.
- **Test-mode animation gate.** All repeating Tickers (portable motif playback,
  panel pulse, glyph breath, cinematic tick, arrival ring pulse, others-in-
  room pulse) check `_kStageAnimationsEnabled =
  !Platform.environment.containsKey('FLUTTER_TEST')` before `.repeat()`.
  Production runs fully kinetic; widget tests get a static surface and
  `pumpAndSettle` resolves.

## Host Sales And Reporting Closure

The completed host-sales gap tracker is folded into this document. The durable
product truth is that Event Success now supports a credible host story around
turnout, event operations, participant connection, and post-event reporting
without exposing private attendee identities.

Implemented host-facing proof points:

- Invite links are attributed performance objects with opens, requests,
  bookings, paid completions, check-ins, catches, matches, and chats.
- Waitlist movement supports host-created expiring offers, attendee
  accept/decline paths, paid handoff, reserved-capacity checks, expiry cleanup,
  and report/export visibility.
- Scorecards refresh from feedback, attendance, catches, matches, first-message
  activity, payment state, invite-link writes, participation writes, and
  waitlist-offer writes.
- Host reports show a funnel from invite opens and demand through bookings,
  attendance, catches, matches, chats, repeat attendees, and coaching signals.
- Host-visible "caught someone" metrics are aggregate only:
  `catchSentCount`, `attendeesWhoCaughtSomeone`, `catchRecipientCount`, and
  `catchRate`. Hosts never see target identities for private catches.
- The assignment engine is primitive-driven. It accepts group size, rotations,
  gender/orientation fit, questionnaire signal, blocks, opt-outs, host
  keep-together/keep-apart/anchor constraints, scoped pairwise affinity
  constraints, activity attributes, repeat strategy, maximum pair meetings,
  and richer slot metadata.
- Assignment docs carry unit kind/index/label, reason summaries, reason codes,
  rotation fairness counts, slot ids, peer counts, and sit-out slots.
- Host setup persists repeat strategy, max pair meetings, balance/cluster
  activity goals, and activity attribute goals where the event format supplies
  safe inputs.

Marketing and sales caveats:

- Synthetic demo metrics are near-term proof. Do not present them as production
  benchmarks or customer outcomes.
- Pre-install invite-click tracking is intentionally not part of early host
  proof. Current app/callable attribution is sufficient until hosts ask for
  channel-level diagnosis before install/open.
- Pace, skill, role, and activity-specific attributes are optional future
  inputs unless the format has a clear host-facing reason and a privacy-safe
  source of truth.
- Strict no-repeat guarantees for complex table/team rotations require a
  small-cohort search/repair pass. The current group-rotation repeat policy uses
  placement costs and fairness metadata rather than an absolute guarantee.
- Host-readable explainability exists in backend results, but a durable
  host-facing generation audit/summary should be added before claiming hosts can
  inspect every relaxed constraint and missing-data reason.
- Per-link and per-offer drilldowns are deferred reporting surfaces; the
  underlying data is recorded, but product demand should justify the UI.
- Event cancellation should eventually mark active waitlist offers `cancelled`
  instead of relying only on expiry.
- Host screenshots should remain deterministic synthetic states until founding
  host usage creates enough production-data-backed or anonymized proof.

## Open Product Decisions

- Should a safety/comfort concern always create a Catch-private report, or
  should the attendee choose between host feedback and safety report?
- Should hosts ever see free-text attendee notes, or only thresholded summaries?
- Do we need event-level safety reports without a specific target user?
- What should the host analytics anonymity threshold be?
- Once QA coverage is complete, should Host Manage hide the setup editor
  entirely for events that started without a saved live guide and show only the
  locked explanatory state plus attendance/report surfaces?

## Verification

Current code verification is distributed across focused tests:

- `test/event_success/*`
- `functions/src/eventSuccess/*.test.ts`
- `functions/src/marketplace/eventSuccessScorecards.test.ts`
- `functions/test/firestore.rules.test.cjs`
- `tool/demo/seed_demo_data_schema.test.mjs`
- `test/core/schema_contracts_generated_test.dart`

Do not keep long command transcripts in this doc. Git and CI preserve the
exact-SHA test results; update this owner document only when the durable event-
success contract changes.
