---
status: active
---

# Event Policies

Status: live. The policy engine is wired into Host defaults, event creation and
editing, event detail, booking, payment, cancellation, and settlement.
The former standalone policy lab is gone; review and QA use those production
surfaces and their focused tests.

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

## Migration Rules

1. Keep live behavior backward-compatible with legacy event documents that
   only have capacity, price, and `EventConstraints`.
2. Treat policy snapshots as the source for new admission, pricing,
   cancellation, and settlement behavior, with server helpers as backend
   authority.
3. Paid waitlist promotion must use an offer, quote, and payment step before a
   user moves from waitlisted to signed up.
4. Inclusive event formats should use explicit cohort policies rather than
   forcing non-binary, queer, or open-to-multiple-genders users into a binary
   gender-ratio bucket.
5. Cancellation policy is a bounded platform policy axis, not free-form host
   text. Host cancellations always make attendees complete, and host payout is
   held until after event completion.
6. Invite-only/private-link access is a booking gate, not an unlisted-event
   visibility mode. Events remain discoverable by default unless a future
   explicit visibility field is added.

## Proof Points

- Event creation, event detail, booking/payment, and Functions tests for the
  production path.
