---
doc_id: event_success
version: 1.0.1
updated: 2026-05-22
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
| `eventSuccessPlans/{eventId}` | Host-owned setup/live state. Active participants can read through event-success rules. |
| `eventSuccessFeedback/{eventId_uid}` | Attendee-owned decomposed post-event feedback. Raw notes and safety details are private to attendee/backend. |
| `eventSafetyReports/{feedbackId}` | Backend-owned Catch-private safety mirror for concerning feedback. |
| `eventSuccessPreferences/{eventId_uid}` | Attendee-owned live-guidance opt-outs. |
| `eventSuccessCompatibilityResponses/{eventId_uid}` | Attendee-owned compatibility answers. Hosts cannot read individual answers. |
| `eventSuccessWingmanRequests/{eventId_uid}` | Attendee consent document for host-visible introduction help. Target is not notified by this surface. |
| `eventSuccessAssignments/{eventId_moduleId_uid}` | Server-owned assignment docs for micro-pods/guided rotations. |
| `eventSuccessScorecards/{eventId}` | Server-owned aggregate coaching scorecard. Host-readable through event-success policy. |

Schemas live under `contracts/firestore/` and generated outputs under
`functions/src/shared/generated/`, `lib/core/schema_contracts/generated/`, and
`tool/generated/`.

## Product Guardrails

- Keep high-churn state out of `events/{eventId}`. Use event-success edge docs.
- Setup fields that affect attendee expectations should freeze once the event
  starts unless product explicitly allows late changes and attendee notice.
- Compatibility tools are conversation context, not a promise of chemistry.
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

Activity recommendations live in
`lib/event_success/domain/event_success_activity_profile.dart`. Do not add
activity-specific toggles directly in screens.

## Manual QA

Use `/dev/event-success-manual-qa` first for visual and state QA. Settings also
links to it from Development. It renders the production host panel and attendee
companion side by side from one fixture.

Check:

- scenario profiles: social run, racket pairs, quiz teams, singles mixer/live
  reveal;
- host setup/live/report surface switching;
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
- `tool/seed_demo_data_schema.test.mjs`
- `test/core/schema_contracts_generated_test.dart`
- `docs/audit_registry/passes.jsonl`

Do not keep long command transcripts in this doc. Add new proof to
`docs/audit_registry/passes.jsonl` through `dart tool/audit_registry.dart
mark-pass`.
