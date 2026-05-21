# Event Success Layer In Development

Status: live migration in progress. Host setup, event structure config, live
reveal, live mode, attendee companion, wingman requests, event detail expectation
copy, activity-format snapshots, and feedback/report surfaces are now wired to
live event routes and Firestore state; the lab remains available for product
iteration.

Owner intent:

- Keep `lib/event_success/**` and `test/event_success/**` even while the feature
  continues to evolve. It now owns live `eventSuccessPlans/{eventId}` host setup
  state and `eventSuccessFeedback/{eventId_uid}` attendee feedback state.
- Do not delete this code as dead code during cleanup/audit passes.
- The current production loop remains event-club discovery, event booking, host
  attendance, attendee companion, post-event swiping/matching, mutual matches,
  chat, and reviews. Event-success no longer owns a duplicate post-event
  interest surface.
- `ActivityKind`, `EventInteractionModel`, and `EventFormatSnapshot` in
  `lib/activity/domain/activity_taxonomy.dart` are the shared taxonomy for event
  creation defaults, event-success playbooks, and health activity imports. Do
  not reintroduce event-success-only activity enums or run-only health models.
- This layer is the proving ground for the future middle of the platform:
  event structure, roster/attendance, assignments, compatibility, live reveals,
  conversation prompts, post-event matching, host coaching, and safety.

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
7. Event-interest target identities must remain attendee-private. Host reports
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
- `test/event_success/event_success_manual_qa_screen_test.dart` covers the
  dev/staging manual QA harness that renders host and attendee production
  surfaces side by side from fixture state.
- `test/event_success/event_success_repository_test.dart` covers live plan
  creation/update, attendee feedback writes, micro-pod and guided-rotation
  preferences, wingman request save/withdraw, assignment watches, host rotation
  override payloads, host-help candidate filtering, and separation from the
  existing swipe/profile-decision path.
- `test/event_success/event_success_live_screens_test.dart` covers the live host
  setup/live/report surface, host micro-pod and rotation summaries, host
  rotation editing entry point, host wingman request summary, host conversation
  cues, host live reveal console, host report signal quality, attendee
  pod/rotation cards, attendee live reveal gating, and attendee
  companion/conversation/wingman request/feedback surface.
- `functions/test/firestore.rules.test.cjs` covers host-only plan writes,
  active participant reads, attended attendee feedback writes after event end,
  and host feedback queries.
- Live wiring now uses `eventSuccessPlans/{eventId}` for host-owned setup and
  active run-of-show state, plus `eventSuccessFeedback/{eventId_uid}` for
  attendee-owned post-event feedback.
- Production host setup now exposes target attendance, event structure
  (`structureConfig` unit type, unit size, optional unit count, rotation cadence,
  and reveal countdown), host goal, attendee prompt, product-layer tool
  selection, wingman requests, and post-match opener controls; setup is visibly
  frozen once the event has started.
- Production live reveal now persists host-controlled reveal state on
  `eventSuccessPlans/{eventId}` and uses it in both host Live mode and attendee
  companion cards. Hosts can start the saved countdown, reveal the active
  pod/rotation round immediately, or reset the reveal flow. Attendees see
  countdown/clue states and only see the current assignment details after that
  round is revealed.
- Production wingman requests now persist attendee-owned, host-readable
  `eventSuccessWingmanRequests/{eventId_uid}` docs. This is the host-assisted
  private-crush loop: the requester explicitly consents to host visibility,
  the target is not notified by this surface, and Firestore rules require both
  attendees to be checked in and unblocked.
- Production conversation cues now compress social missions and contextual
  openers into one UI layer. The cue deck is derived from the saved playbook,
  active run-of-show step, and event format, and appears in host Live mode,
  attendee live companion state, and attendee post-event opener suggestions.
- Production compatibility questionnaire answers now live in
  `eventSuccessCompatibilityResponses/{eventId_uid}` and remain hidden from
  hosts at the Firestore rules layer. The host can choose whether answers stay
  clues-only or optionally boost generated guided-rotation ranking through
  `EventSuccessPlan.compatibilityAffectsRanking`.
- Production host reports now include a signal-quality summary from already
  loaded live data: feedback response, assignment coverage, assignment opt-outs,
  and active wingman requests. Host coach strengths and recommendations use the
  same aggregates so this remains a report/coaching layer, not a parallel
  analytics store.
- Dev/staging manual QA now has `/dev/event-success-manual-qa` and a Settings
  development row. The harness renders the production host panel and attendee
  companion side by side across social run, racket pair, quiz team, and mixer
  reveal fixture states. Use it for visual and state QA; use a real dev/staging
  event for write-path and permissions QA.
- Production attendee companion is gated on a persisted host setup document.
  Event detail hides the companion entry until `eventSuccessPlans/{eventId}`
  exists, and the direct companion route shows an unavailable state instead of
  synthesizing a default plan.
- Current tools are pilot-live surfaces, not complete automation engines. V1
  micro-pod assignment and guided rotations are server-owned, block-aware, and
  attendee opt-out aware. Guided rotations use saved structure cadence when
  present, fall back to 15-minute slots for legacy plans, and prioritize
  mutual/one-way interested-in pairings before stopping at the
  participant/preference limit. The scheduler tracks exposure and rotating
  breaks so compatible underexposed attendees are pulled back in before
  already-served attendees consume all remaining mutual-interest pairs. Host
  overrides can edit generated rounds, but blocked pairs, opted-out attendees,
  ineligible attendees, duplicate attendees, and out-of-duration rounds are
  still rejected on the server.
- Live reveal V1 is a synchronized app experience, not a hard secrecy boundary:
  generated assignment docs remain readable to their assigned attendee under
  the current event-success rules. If this needs stronger reveal secrecy, add a
  host-only draft assignment store and publish per-round attendee assignments
  just in time.
- Production event detail now shows "What to expect" before booking,
  cancellation, and settlement policy copy without adding another Firestore
  read.
- Host-visible wingman requests are explicit in-event help requests. Post-event
  interest target identities remain owned by the normal swipe/match pipeline.
- Created events now write `events/{eventId}.eventFormat`; the create-event
  wizard exposes activity type defaults, event detail surfaces branch "What to
  expect" copy by interaction model, and the dashboard weekly activity card
  counts non-run physical activities by active minutes.
- `test/core/catch_primitives_test.dart` remains in the focused proof set
  because the preview exposed a narrow-width status-badge layout edge case.
- `codex_audit/event_success_completion_tracker.md` tracks the current
  completion pass and remaining watch items for future cleanup loops.
