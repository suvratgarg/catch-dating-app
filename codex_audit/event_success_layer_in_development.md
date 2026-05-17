# Event Success Layer In Development

Status: in development, parallel implementation, not wired to live event flows.

Owner intent:

- Keep `lib/event_success/**` and `test/event_success/**` even though the
  feature is not reachable from the current app UI, GoRouter, Firestore,
  Cloud Functions, booking, attendance, swipe, review, or chat flows.
- Do not delete this code as dead code during cleanup/audit passes.
- The current production loop remains run-club discovery, run booking, host
  attendance, 24-hour attendee swiping, mutual matches, chat, and reviews.
- This layer is the proving ground for the future middle of the platform:
  host playbooks, arrival check-in, crowd balance, micro-pods, social prompts,
  rotations, private crushes, contextual openers, decomposed feedback, host
  analytics, and event-quality coaching.

Product guardrails:

1. Keep the layer isolated until the product model is approved.
2. Do not change live booking, attendance, swipes, matches, reviews, chat, or
   host tools just to satisfy this WIP model.
3. Treat movement-heavy events differently from stationary events. Runs should
   use light structure; dinners, quiz nights, pickleball, and mixers can carry
   more live facilitation.
4. Do not imply an algorithm can guarantee chemistry. Compatibility tools are
   conversation context, not a promise of spark.
5. Safety, privacy, block/report behavior, attendee visibility, and opt-outs
   must be defined before any live event module ships.
6. Host coaching should improve events before public ranking suppresses hosts.

Current proof:

- `test/event_success/event_success_playbooks_test.dart` covers WIP status,
  multi-activity playbook coverage, social-run phone-use guardrails, playbook
  module consistency, module lookup, and coach recommendations.
- `test/event_success/event_success_lab_screen_test.dart` covers the preview
  screen's WIP labels, non-running playbooks, actual feature blocks, host setup
  interactions, missing-gate readiness warnings, and sample host coach output.
- `test/core/catch_primitives_test.dart` remains in the focused proof set
  because the preview exposed a narrow-width status-badge layout edge case.
