# Safety Plan: Blocking and Account Deletion

Date: 2026-04-28

Implementation status: first production slice implemented on 2026-04-28.
Remaining gaps are called out below.

This plan treats blocking and deletion as launch-blocking safety features. The
client can hide UI, but Cloud Functions and Firestore rules must enforce the
real boundaries.

## Goals

- A blocked user cannot join the same dating/run slot as the person who blocked
  them.
- Blocking is symmetric for enforcement: if either side has blocked the other,
  discovery, swipes, matches, chats, and run-slot co-attendance should stop.
- Error messages must not reveal who blocked whom.
- Account deletion removes personally identifying app data from user-facing
  surfaces while preserving the minimum records needed for safety, payments,
  refunds, abuse review, and legal/audit needs.

## Data Model

Add a top-level block edge collection:

```text
blocks/{blockerUid_blockedUid}
  blockerUserId: string
  blockedUserId: string
  createdAt: timestamp
  source: "profile" | "chat" | "match" | "support"
  reasonCode?: string
```

Use deterministic document IDs in both directions checks:

- `blocks/{currentUid_targetUid}` means current user blocked target.
- `blocks/{targetUid_currentUid}` means target user blocked current user.

Optional projections can be added later under `users/{uid}/blockedUsers` for a
blocked-accounts management screen, but the top-level collection is the best
server-side query and rules primitive.

For account deletion, add a tombstone:

```text
deletedUsers/{uid}
  uid: string
  deletedAt: timestamp
  deletionReason?: string
  retainedFor: ["safety", "payments", "fraud"]
```

Do not keep profile photos, bio, phone, FCM tokens, or public profile documents
after deletion.

## Enforcement Points

### Runs and Payments

`functions/src/runs/signUpUserForRun.ts` is the authoritative sign-up gate for
both free and paid runs. Add block reads inside the transaction before capacity
and eligibility writes:

- Gather current participant IDs from `signedUpUserIds` and `attendedUserIds`.
- Check block docs both ways for `requestingUserId` against every participant.
- Deny with a generic `failed-precondition` like "This run is unavailable."
- Keep this check in the transaction so concurrent sign-ups cannot bypass it.

`functions/src/payments/createRazorpayOrder.ts` should also do a cheap pre-flight
block check so the app does not create a Razorpay order for an unavailable run.
The transaction remains the source of truth because participants can change
after the order is created.

`functions/src/runs/cancelRunSignUp.ts` must skip blocked pairs when promoting a
waitlisted user into a freed slot.

### Waitlist

Waitlist writes are currently allowed directly by Firestore rules. Before launch,
move waitlist join/leave behind a callable Function or add rule helpers that
deny blocked co-attendance. A callable is cleaner because it can scan existing
participants and return generic errors without exposing block state.

### Swipes and Matches

Candidate generation starts in
`lib/swipes/data/swipe_candidate_repository.dart`. Filter out users where either
block edge exists. A backend or Cloud Function filter is preferable long term,
because client filtering still downloads candidates that should be invisible.

`functions/src/matching/onSwipeCreated.ts` must reject or no-op match creation
when either block edge exists. Existing matches should be closed by a block
trigger.

### Chats

On block creation, write a server-owned status to any existing match/chat between
the two users, for example:

```text
matches/{matchId}
  status: "blocked"
  blockedBy: blockerUid
  blockedAt: timestamp
```

Firestore chat rules should deny new messages when the match is blocked. The UI
should hide or archive blocked conversations.

### Profiles and Discovery

Rules should prevent direct reads of blocked public profiles where feasible.
Client repositories should also hide blocked users from:

- public profile views
- swipe deck
- match list
- chat list
- roster previews
- "who is running" rows

### Existing Shared Bookings

If two users are already booked into the same run and one blocks the other, do
not silently cancel either user. Mark the pair as a safety conflict and remove
mutual visibility in roster/chat/catches. Add an admin/support workflow later
for refunds or run reassignment.

## UI Work

Add a Settings/Safety surface from the design handoff:

- Settings screen route under the You tab.
- Safety section with "Blocked accounts".
- Block action from other-user profile, chat overflow, and match context menu.
- Confirmation dialog that explains the effect without naming future runs.
- Unblock action from the blocked-accounts screen.

Add account deletion:

- Settings > Account > Delete account.
- Reauthentication before deletion.
- Server callable deletion request.
- Final sign-out and confirmation state.

## Firestore Rules

Rules should allow:

- create block where `request.auth.uid == blockerUserId`
- delete block where `request.auth.uid == blockerUserId`
- read block only when requester is `blockerUserId` or `blockedUserId`
- no client writes to `deletedUsers`
- no public profile read for deleted users
- no chat message create if match status is `blocked`

## Tests

Add TypeScript tests:

- paid order pre-flight denies blocked co-attendance
- free sign-up denies blocked co-attendance
- sign-up denies both blocker-to-blocked and blocked-by-blocker directions
- cancellation waitlist promotion skips blocked candidates
- swipe-created trigger does not create matches for blocked pairs

Add Dart tests:

- swipe candidate repository hides blocked users
- match/chat lists hide or mark blocked matches
- settings safety screen can block/unblock
- account deletion controller calls server flow and signs out

Add rules tests before deploying:

- block create/read/delete ownership
- denied message create on blocked match
- denied profile read for deleted users

## Implementation Order

1. [x] Add Firestore block/deleted-user schema types in Functions and Dart
   models.
2. [x] Add callable Functions for `blockUser`, `unblockUser`, and
   `requestAccountDeletion`.
3. [x] Enforce block checks in `signUpUserForRun`, paid order creation,
   waitlist promotion, swipe matching, and chat rules.
4. [x] Add Settings/Safety UI and chat block entry point.
5. [x] Add account deletion UI and backend scrub flow.
6. [x] Add focused unit/widget coverage and run existing suites.
7. [x] Add Firebase rules emulator tests.
8. [x] Delete Storage photo objects during account deletion when stored URLs are
   standard Firebase Storage download URLs.
9. [x] Add other-profile block/report entry point after the other-user profile
   screen exists.
10. [x] Deploy rules/functions to the intended Firebase project.
11. [x] Anonymize the retained `users/{uid}` document on account deletion,
    including date of birth, saved runs, background fields, running preferences,
    notification token, and profile photo fields.

## Reporting Slice Added

Implemented on 2026-04-28:
- `reportUser` callable creates server-owned `reports` documents.
- Report text is trimmed and bounded before write.
- Firestore rules deny all direct client reads/writes to `reports`.
- Chat overflow can file a contextual report against the match.
- Swipe cards can open an other-user public profile.
- Other-user public profile screen exposes report and block actions.

Remaining reporting work:
- Add moderation/admin tooling for reviewing `reports`.
- Add report categories to product copy/design once the policy taxonomy is
  finalized.
