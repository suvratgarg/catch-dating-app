---
doc_id: event_success
version: 1.3.3
updated: 2026-07-17
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

## Setup Configuration Contract

The 2026-07-16 modernization replaces the original pre-design-system setup
wizard with a compact shared form. Durable outcomes:

- **Phase 1 — surface unification.** `EventSuccessSetupBody` is the shared
  setup widget consumed by both `EventSuccessDefaultsPanel` (create-event last
  step) and the Host Manage setup tab. The two surfaces stay in sync
  automatically — no copy or behaviour drift.
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
- **Gated Phase 4 prototype.** Widgetbook contains an owner-review-only
  `EventSuccessModuleConsolidationPrototype` under
  `Event Success / Phase 4 owner review`. It demonstrates the proposed single
  How people mix choice, conditional size/count/cadence/repeat row order,
  recommendation copy, and a five-decision visible tool set. Its grouping
  derivation exists as an explicit draft projection, but the prototype has no
  writer and production still uses the pair-only backend-safe interaction.
  Wiring the composite control remains blocked on explicit owner approval.
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
pulse for live event beats, sunrise for afterglow. Architecturally, the
existing `_CompanionStageTheme.forMoment` carries the palette + motif per
beat — Phase 5 added motion, audio, and co-presence layers on top of that
foundation.

- **Animated motifs.** `_StageMotifPainter` now takes a `phase` parameter
  driven by a 16s Ticker (gated on `Platform.environment['FLUTTER_TEST']`
  so widget tests don't deadlock `pumpAndSettle`). Orbits rotate, sparks
  drift with independent sine phases + alpha shimmer, rhythm waves swell
  and recede, path filaments scroll diagonally, reveal spokes accelerate,
  afterglow gets a breathing halo.
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
  silent) is mapped per-moment in `EventSuccessMomentPresentation.forMoment`.
  Per-kind volume tuning — reveal lands at 0.95, taps at 0.48. Missing
  assets are caught + memoized so the UI never blocks on the sound designer.
  Six curated stock sounds to source are documented in
  `assets/audio/event_success/README.md`.
- **Reveal cinematic (the marquee).** New `_RevealCinematicOverlay` runs
  three phases over the full stage when the reveal moment is active:
  anticipation (vignette darkens 0.18→0.6, 14 gold spokes rotate with
  acceleration `pow(anticipation, 1.4) × 2π × 1.8`, 72-particle field
  drifts inward), climax 1.5s (white flash, particle field bursts on a
  deterministic seed so every viewer sees the same explosion), settle
  700ms (vignette releases, particles dissipate, sunrise vibe pack takes
  over). All phases server-anchored to the existing countdown clock so
  every attendee sees the same beat.
- **Co-presence layer.** Three surfaces wired off the existing
  `Event.checkedInCount` (denormalized + maintained by Cloud Functions — no
  new Firestore listeners): `_LiveArrivalRing` on arrival moments (140×140
  ring with 24 anonymous dot slots, big tabular numeral in center,
  scale-pulse on increment), `_LiveOthersInRoomLine` on the questionnaire
  progress rail (pill with chip pulse on count climb), and a shared
  anonymous-dot ring inside the reveal cinematic pulsing on the same
  `tickPhase` clock so every attendee's screen pulses on the *same* shared
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
- **Test-mode animation gate.** All repeating Tickers (motif background,
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
  keep-together/keep-apart/anchor constraints, activity attributes, repeat
  strategy, maximum pair meetings, and richer slot metadata.
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
