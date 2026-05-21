# Event Policies

Status: in production migration, wired into create-event and booking while the
lab remains available for product review.

This folder is intentional app code. Do not delete `lib/event_policies/**` or
`test/event_policies/**` as dead code during cleanup passes.

## Current Behavior

- New event creation writes an `EventPolicyBundle` snapshot with admission,
  waitlist, pricing, cancellation, and settlement policy.
- `Event.capacityLimit`, `Event.priceInPaise`, and `EventConstraints` remain
  backward-compatible projections for legacy documents and UI surfaces.
- Booking and payment callables use backend-owned helpers for admission, cohort
  counts, viewer-specific quotes, waitlist movement, and host-cancellation
  refunds.
- `domain/event_policy_preview.dart` owns deterministic host-configuration
  fixtures for product review and tests.
- `presentation/event_policy_lab_screen.dart` renders the dev/staging-only lab
  at `/dev/event-policy-lab` when `AppConfig.enableEventPolicyLab` is true.

## Migration Rules

1. Keep the lab read-only and static. It must not write drafts, Firestore,
   callables, Razorpay, attendance, swipes, reviews, or chat.
2. Keep live migration backward-compatible with legacy event documents that
   only have capacity, price, and `EventConstraints`.
3. Treat policy snapshots as the source for new admission, pricing,
   cancellation, and settlement behavior, with server helpers as backend
   authority.
4. Paid waitlist promotion must use an offer, quote, and payment step before a
   user moves from waitlisted to signed up.
5. Inclusive event formats should use explicit cohort policies rather than
   forcing non-binary, queer, or open-to-multiple-genders users into a binary
   gender-ratio bucket.
6. Cancellation policy is a bounded platform policy axis, not free-form host
   text. Host cancellations always make attendees complete, and host payout is
   held until after event completion.
7. Invite-only/private-link access is a booking gate, not an unlisted-event
   visibility mode. Events remain discoverable by default unless a future
   explicit visibility field is added.

## Preview Fixtures

- `invite_only_private_event`
- `capacity_only_open_run`
- `balanced_ratio_ranked_waitlist`
- `demand_priced_balanced_event`
- `queer_inclusive_affinity_event`

## Proof Points

- `test/event_policies/event_policy_preview_test.dart`
- `test/event_policies/event_policy_lab_screen_test.dart`
- `test/core/app_config_test.dart`
- `test/routing/router_redirect_test.dart`
- `test/safety/settings_screen_test.dart`
- Event creation, event detail, booking/payment, and Functions tests for the
  production migration path.
