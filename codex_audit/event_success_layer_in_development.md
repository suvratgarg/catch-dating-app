# Event Success Layer In Development

Status: live migration in progress. Host setup, live mode, attendee companion,
private follow-up, event detail expectation copy, activity-format snapshots, and
feedback/report surfaces are now wired to live event routes and Firestore state;
the lab remains available for product iteration.

Owner intent:

- Keep `lib/event_success/**` and `test/event_success/**` even while the feature
  continues to evolve. It now owns live `eventSuccessPlans/{eventId}` host setup
  state and `eventSuccessFeedback/{eventId_uid}` attendee feedback state.
- Do not delete this code as dead code during cleanup/audit passes.
- The current production loop remains event-club discovery, event booking, host
  attendance, attendee companion, private follow-up via the existing swipe/match
  pipeline, mutual matches, chat, and reviews.
- `ActivityKind`, `EventInteractionModel`, and `EventFormatSnapshot` in
  `lib/activity/domain/activity_taxonomy.dart` are the shared taxonomy for event
  creation defaults, event-success playbooks, and health activity imports. Do
  not reintroduce event-success-only activity enums or run-only health models.
- This layer is the proving ground for the future middle of the platform:
  host playbooks, arrival check-in, crowd balance, micro-pods, social prompts,
  rotations, private crushes, contextual openers, decomposed feedback, host
  analytics, and event-quality coaching.

Product guardrails:

1. Keep high-churn state out of `events/{eventId}`. Event-success setup and
   feedback live in edge documents.
2. Reuse live booking, attendance, swipes, matches, reviews, chat, and host tools
   where they already model the behavior.
3. Treat movement-heavy events differently from stationary events. Events should
   use light structure; dinners, quiz nights, pickleball, and mixers can carry
   more live facilitation.
4. Do not imply an algorithm can guarantee chemistry. Compatibility tools are
   conversation context, not a promise of spark.
5. Safety, privacy, block/report behavior, attendee visibility, and opt-outs
   must be defined before any live event module ships.
6. Host coaching should improve events before public ranking suppresses hosts.
7. Private crush target identities must remain attendee-private. Host reports
   can use aggregate/decomposed feedback, not private target lists.

Current proof:

- `test/event_success/event_success_playbooks_test.dart` covers WIP status,
  multi-activity playbook coverage, social-event phone-use guardrails, playbook
  module consistency, module lookup, and coach recommendations.
- `test/event_success/event_success_lab_screen_test.dart` covers the preview
  screen's WIP labels, non-running playbooks, actual feature blocks, host setup
  interactions, missing-gate readiness warnings, and sample host coach output.
- `test/event_success/event_success_event_preview_test.dart` covers the adapter
  from real event data into host setup, live mode, attendee companion, and
  post-event report previews.
- `test/event_success/event_success_repository_test.dart` covers live plan
  creation/update, attendee feedback writes, private-crush candidate filtering,
  and reuse of the existing swipe/profile-decision path.
- `test/event_success/event_success_live_screens_test.dart` covers the live host
  setup/live/report surface and attendee companion/private-follow-up/feedback
  surface.
- `functions/test/firestore.rules.test.cjs` covers host-only plan writes,
  active participant reads, attended attendee feedback writes after event end,
  and host feedback queries.
- Live wiring now uses `eventSuccessPlans/{eventId}` for host-owned setup and
  active run-of-show state, plus `eventSuccessFeedback/{eventId_uid}` for
  attendee-owned post-event feedback.
- Production host setup now exposes target attendance, host goal, attendee
  prompt, module selection, private follow-up, and contextual opener controls;
  setup is visibly frozen once the event has started.
- Production attendee companion is gated on a persisted host setup document.
  Event detail hides the companion entry until `eventSuccessPlans/{eventId}`
  exists, and the direct companion route shows an unavailable state instead of
  synthesizing a default plan.
- Current modules are pilot-live surfaces, not complete automation engines.
  Rotation, pod assignment, and pairing logic still need dedicated product and
  backend passes before being described as fully automated.
- Production event detail now shows "What to expect" before booking,
  cancellation, and settlement policy copy without adding another Firestore
  read.
- Attendee private follow-up now feeds the post-event feedback/report aggregate
  on submit while private-crush target identities remain attendee-private.
- Created events now write `events/{eventId}.eventFormat`; the create-event
  wizard exposes activity type defaults, event detail surfaces branch "What to
  expect" copy by interaction model, and the dashboard weekly activity card
  counts non-run physical activities by active minutes.
- `test/core/catch_primitives_test.dart` remains in the focused proof set
  because the preview exposed a narrow-width status-badge layout edge case.
- `codex_audit/event_success_completion_tracker.md` tracks the current
  completion pass and remaining watch items for future cleanup loops.
