# Safety

Safety owns blocking, reporting, and account deletion. The client can hide UI,
but Cloud Functions and Firestore rules own the real enforcement boundaries.

## Ownership

- Block relationships live in top-level `blocks/{blockerUid_blockedUid}` docs.
- Deletion tombstones live in `deletedUsers/{uid}` and are server-owned.
- Reports are callable-owned `reports` documents with no direct client
  reads/writes.
- Account deletion, block, unblock, and report actions should go through
  callable Functions or server-owned triggers, not direct client writes.

## Current Behavior

- Blocking is symmetric for enforcement: if either side has blocked the other,
  discovery, swipes, matches, chats, and event co-attendance should stop.
- Booking/payment callables, waitlist movement, swipe matching, and chat rules
  enforce block state without revealing who blocked whom.
- Existing shared bookings are not silently cancelled when a block is created.
  They become a safety conflict for later support/admin handling.
- `requestAccountDeletion` scrubs personally identifying app data from
  user-facing surfaces while preserving minimum records needed for safety,
  payments, refunds, abuse review, and legal/audit needs.
- Account deletion deletes standard Firebase Storage profile photo objects and
  anonymizes the retained `users/{uid}` document, including date of birth,
  saved events, background fields, running preferences, notification token, and
  profile photo fields.

## Product Rules

- Error messages must stay generic and must not reveal block direction.
- Do not keep profile photos, bio, phone, FCM tokens, or public profile
  documents after deletion.
- Payment, refund, abuse-review, fraud, and legal/audit records may be retained
  only in minimized form.

## Open Decisions

- Admin/moderation tooling for reviewing `reports`.
- Final report categories and policy taxonomy.
- Support workflow for event safety conflicts after an existing shared booking.
- User-visible retention wording for payment and safety records after account
  deletion.
