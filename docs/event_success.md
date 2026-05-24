---
doc_id: event_success
version: 1.0.4
updated: 2026-05-24
owner: recursive_audit_loop
status: active
---

# Event Success

This is the source of truth for the live-wired but still evolving event-success
layer. It replaces the separate event-success completion, hardening, in-
development, runtime, manual-QA, and participant-metrics trackers.

Read this before deleting, moving, auditing, or changing `lib/event_success/**`,
`test/event_success/**`, event-success Firestore collections, event-success
Functions, manual QA, event-success scorecards, or participant metrics.

## Current State

Event success is intentional live product code, not dead code. It is wired to
live event routes, host setup/manage surfaces, attendee companion surfaces,
manual QA, Firestore rules, generated contracts, demo data, and Functions.

The current production loop remains:

1. User joins a club and books an event.
2. Host marks or attendee performs attendance/check-in.
3. Event-success setup can guide the live event through structure, prompts,
   assignments, reveal, host help, feedback, and coaching.
4. Post-event swiping/matching/chat/reviews remain in their existing product
   pipelines.

Event success does not own a duplicate post-event interest surface. Private
target identities remain attendee-private unless the attendee explicitly asks
the host for help through the wingman request flow.

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
- Firestore rules allow host setup while the event is still pre-live, then
  freeze setup-shaping fields after bookings, waitlist activity, check-ins,
  event start, or live-plan freezing while still allowing live-control fields;
- attendee companion routing, event-detail entry, and check-in auto-launch use
  the saved plan/runtime rather than raw event type.

Assignment generation is deliberately narrower than the format taxonomy. V1
supports pair rotations and generic micro-pods with topology guards. True
table-seating, team-balancing, doubles/court-aware, and dance-partner engines
remain future backend work unless product narrows them into the existing V1
assignment shapes.

## Code Map

| Surface | Path |
|---|---|
| Domain/runtime/playbooks | `lib/event_success/domain/` |
| Repository/providers | `lib/event_success/data/event_success_repository.dart` |
| Host setup/live/report UI | `lib/event_success/presentation/event_success_host_screen.dart` and `host_parts/` |
| Attendee companion UI | `lib/event_success/presentation/event_success_companion_screen.dart` and `companion_parts/` |
| Live reveal UI | `lib/event_success/presentation/event_success_live_reveal_card.dart` and `live_reveal_parts/` |
| Manual QA harness | `lib/event_success/presentation/event_success_manual_qa_screen.dart` |
| Backend generators/wingman callables | `functions/src/eventSuccess/` |
| Feedback scorecards/safety mirror | `functions/src/marketplace/eventSuccessScorecards.ts` |
| Tests | `test/event_success/`, `functions/src/eventSuccess/*.test.ts`, `functions/src/marketplace/eventSuccessScorecards.test.ts` |

## Firestore Contracts

| Collection | Owner and visibility |
|---|---|
| `eventSuccessPlans/{eventId}` | Host-owned setup/live state. Setup fields freeze once participant activity/start/live status begins; active participants can read through event-success rules. |
| `eventSuccessFeedback/{eventId_uid}` | Attendee-owned decomposed post-event feedback. Raw notes and safety details are private to attendee/backend. |
| `eventSafetyReports/{feedbackId}` | Backend-owned Catch-private safety mirror for concerning feedback. |
| `eventSuccessPreferences/{eventId_uid}` | Attendee-owned live-guidance opt-outs. |
| `eventSuccessCompatibilityResponses/{eventId_uid}` | Attendee-owned compatibility answers. Hosts cannot read individual answers. |
| `eventSuccessWingmanRequests/{eventId_uid}` | Attendee consent document for host-visible introduction help. Target is not notified by this surface. |
| `eventSuccessArrivalMissions/{eventId_uid}` | Server-owned First Hello mission. Attendee can read only their own mission; clients cannot create, update, list, or delete. |
| `eventSuccessAssignments/{eventId_moduleId_uid}` | Server-owned assignment docs for micro-pods/guided rotations. |
| `eventSuccessScorecards/{eventId}` | Server-owned aggregate coaching scorecard. Host-readable through event-success policy. |

Schemas live under `contracts/firestore/` and generated outputs under
`functions/src/shared/generated/`, `lib/core/schema_contracts/generated/`, and
`tool/contracts/generated/`.

First Hello check-in is modeled as an optional arrival module with server-owned
mission assignment/completion. `startEventSuccessFirstHelloMission` verifies the
attendee is signed up, the check-in window is open, the caller is within the
tighter First Hello venue radius, the module is selected, and a compatible
checked-in target exists. `completeEventSuccessFirstHelloMission` verifies the
active mission and answer, rechecks location/block state, records only the
observer's answer on the mission, and marks attendance.

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
- Live reveal V1 is synchronized ceremony, not hard secrecy: assigned attendees
  can read their own assignment docs under current rules. Stronger secrecy would
  need host-only draft assignments and just-in-time publication.
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
  server-owned mission assignment/completion, a synchronized manual QA harness,
  and a 100m venue radius;
- QR check-in now has a host QR surface and attendee scanner entry point; the
  existing GPS self-check-in callable remains the attendance write path;
- invite sharing now routes through shared event-invite copy across event
  detail, payment confirmation, and host private-link surfaces;
- post-event companion follow-up now starts with a private in-app afterglow
  recap and keeps host reporting aggregate-safe.

## Manual QA

Use `/dev/event-success-manual-qa` first for visual and state QA. Settings also
links to it from Development. It renders the production host panel and attendee
companion side by side from one synchronized in-memory fixture store.

Check:

- scenario profiles: social run, racket pairs, quiz teams, singles mixer/live
  reveal;
- host setup/live/report surface switching;
- optional First Hello arrival mission from host controls through attendee
  completion and checked-in state;
- host `Previous`/`Next` run-of-show transitions updating both panes;
- countdown, reveal now, and reset;
- pre-arrival attendee state without live prompt/reveal/partner leakage;
- checked-in attendee moment sync;
- questionnaire, opt-out, wingman request, feedback, and report states;
- host-help candidate filtering by attendance and interested-in/cohort
  eligibility.

Use a real dev/staging event for write-path proof:

1. Save event-success setup as host.
2. Book/check in at least two attendee accounts.
3. Generate pods or rotations and edit generated rotations.
4. Drive countdown/reveal/reset from host live mode.
5. Submit questionnaire, opt-out, wingman request, and feedback as attendee.
6. Confirm host report aggregate signal quality.

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

## Recent Setup And Companion Ergonomics Pass

The 2026-05-24 ergonomics pass reshaped both the host setup wizard and the
attendee companion. The work was split into four phases; durable outcomes:

- **Phase 1 — surface unification.** `EventSuccessSetupBody` is the shared
  setup widget consumed by both `EventSuccessDefaultsPanel` (create-event last
  step) and the Host Manage setup tab. The two surfaces stay in sync
  automatically — no copy or behaviour drift.
- **Phase 2 — lifecycle stages and inline pickers.** Setup body groups modules
  into Arrival foundation, During event, and After event stage cards (plus
  Advanced). Rotation cadence and reveal countdown live inline in the During
  card; the questionnaire collapses three controls (module toggle, ranking
  switch, content editor) into one Off / Clues only / Clues + soft pairing
  three-state chooser, with custom prompts in a bottom sheet.
- **Phase 3 — copy and dirty-state polish.** Module titles use host-readable
  names (Synchronized partner reveal, Small starter groups, Timed partner
  rotations, "Help me say hi" requests, Welcome script, Suggested first-message
  openers, After-event attendee feedback, Booking balance preview). Frozen
  state explains exactly what can still be edited. Save button surfaces an
  unsaved-changes pill driven by a `_isDirty` getter that diffs the resolved
  draft against the saved plan.
- **Phase 4 — companion ergonomics.** Hero re-frames around "what now". Live
  cards use Switch-based include/skip toggles instead of buttons. Pre-arrival
  is informational only — no opt-out levers before the event starts. Three-tier
  privacy badges (Private to you / Host can see / Catch private) appear on
  every surface that produces persisted data. The companion build method is a
  flat list-builder pattern, and the dead `if (showLiveReveal) reveal else
  pod/rotation` inner branches inside `showPodAssignment` and
  `showRotationSchedule` are removed (those runtime kinds are mutually
  exclusive with `liveReveal`).

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

Current code verification is distributed across focused tests and audit-registry
pass receipts:

- `test/event_success/*`
- `functions/src/eventSuccess/*.test.ts`
- `functions/src/marketplace/eventSuccessScorecards.test.ts`
- `functions/test/firestore.rules.test.cjs`
- `tool/demo/seed_demo_data_schema.test.mjs`
- `test/core/schema_contracts_generated_test.dart`
- `docs/audit_registry/passes.jsonl`

Do not keep long command transcripts in this doc. Add new proof to
`docs/audit_registry/passes.jsonl` through `dart tool/audit_registry.dart
mark-pass`.
