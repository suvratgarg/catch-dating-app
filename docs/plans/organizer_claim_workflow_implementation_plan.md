---
doc_id: organizer_claim_workflow_implementation_plan
version: 0.2.0
updated: 2026-06-10
owner: marketplace_growth
status: complete
---

# Organizer Claim Workflow Implementation Plan

## Objective

Turn programmatically seeded organizer pages into a controlled acquisition loop:
an organizer can find a noindex/index-ready public page, request ownership,
Catch can review the claim, and an approved owner becomes the canonical host for
that `clubs/{clubId}` document without creating a second source of truth.

## Current State

- `clubs/{clubId}` is the canonical organizer document.
- Programmatic organizer docs can be unclaimed with `hostUserId: null`,
  `ownerUserId: null`, `ownership.state: programmatic`, `claim.state:
  unclaimed`, and `appVisibility: hidden`.
- `clubHostClaims/{uid}` already exists, but it is a singleton owner lock used to
  enforce one hosted club per user. It is not a public claim request queue.
- Local discovery data now has candidate batches, source evidence, index
  readiness, and a dry-run Firestore import plan under `tool/host_discovery/`.
- Backend contracts, callable handlers, admin queues, website claim submission,
  owner review responses, index-review promotion, and an admin organizer detail
  editor are implemented. The remaining work is operational review before
  seeded pages become indexable.

## Data Model

Add a separate claim-request collection. Do not overload `clubHostClaims`.

### `clubClaimRequests/{requestId}`

Required fields:

- `requestId`: deterministic or auto id.
- `clubId`: target `clubs/{clubId}`.
- `requesterUid`: signed-in Catch user making the claim.
- `requesterName`: user-entered owner/contact name.
- `requesterRole`: owner, manager, marketer, founder, venue manager, or other.
- `businessEmail`: optional owner-facing business email.
- `businessPhone`: optional business phone.
- `proofUrls`: official website, Instagram, Luma, Linktree, or other public proof.
- `message`: short owner explanation.
- `status`: `pending`, `approved`, `rejected`, `withdrawn`, `superseded`.
- `createdAt`, `updatedAt`.
- `decidedAt`, `decidedByUid`, `decisionReason`.
- `previousRequestId`: optional duplicate/supersession pointer.

Security:

- Clients cannot directly read or write `clubClaimRequests`.
- Authenticated users create requests through `requestClubClaim`.
- Admin/support users decide requests through `adminDecideClubClaim`.
- Server-owned status transitions keep claim review auditable until a dedicated
  admin queue exists.

### Club State Updates

When a request is created:

- `clubs/{clubId}.claim.state = claimPending`
- `clubs/{clubId}.claim.lastClaimRequestId = requestId`
- Keep `ownership.state = programmatic`
- Keep `appVisibility = hidden`

When approved:

- `ownerUserId = requesterUid`
- `hostUserId = requesterUid`
- `hostName` / `hostAvatarUrl` from the user's public profile projection
- `hostUserIds = [requesterUid]`
- `hostProfiles = [{uid, displayName, avatarUrl, role: owner}]`
- `ownership.state = claimed`
- `ownership.ownerUserId = requesterUid`
- `ownership.primaryHostUserId = requesterUid`
- `ownership.hostUserIds = [requesterUid]`
- `ownership.claimedAt = serverTimestamp`
- `ownership.claimedByUid = requesterUid`
- `claim.state = claimed`
- `claim.claimHref = null`
- `clubHostClaims/{requesterUid}` is created with the target club id
- `clubMemberships/{clubId_requesterUid}` is set to owner

When rejected:

- `clubs/{clubId}.claim.state = unclaimed`
- Keep `lastClaimRequestId = requestId`
- Store admin decision on `clubClaimRequests/{requestId}`

## Backend Callables

### `requestClubClaim`

Caller: authenticated user.

Behavior:

1. Validate payload.
2. Rate-limit by uid and club id.
3. Read `clubs/{clubId}`.
4. Reject if club is already claimed or suppressed.
5. Reject if caller already has `clubHostClaims/{uid}` unless this is an admin
   override flow.
6. Create `clubClaimRequests/{requestId}` with status `pending`.
7. Patch `clubs/{clubId}.claim` to `claimPending`.

### `adminDecideClubClaim`

Caller: admin role `admin`, `adminOwner`, or `support`.

Behavior:

1. Validate payload.
2. Read request, club, requester user, deleted user tombstone, and existing
   `clubHostClaims/{requesterUid}`.
3. Reject approval if the requester is deleted or already owns another club.
4. In one transaction, write the request decision, ownership fields, host
   projections, `clubHostClaims`, and owner membership.
5. Leave `publicPage.indexStatus` unchanged. Claiming a page does not by itself
   make it indexable.

## Website And App Surfaces

### Website Listing Page

- Replace the current generic claim link with a concrete claim CTA.
- If signed out, send the user through auth then return to the claim flow.
- If signed in, open a claim form bound to the canonical `clubId`.
- Keep noindex status visible only as an internal/debug signal, not marketing
  copy.

### Admin Dashboard

Add a claim-review queue:

- list pending claims;
- show club summary, current provenance, source evidence, and requester proof;
- approve, reject, or mark duplicate;
- show irreversible effects before approval.

### Host Onboarding

After approval, send the owner to the existing host surface:

- profile/image completion;
- payment/payout onboarding;
- first event creation;
- Event Success defaults review.

## Review And Analytics Surfaces

Claims unlock owner tools, but owner analytics should be phased:

1. Page analytics summary: page views, claim CTA clicks, outbound clicks.
2. Review response: owner can respond to reviews after claim.
3. Event funnel: only after the organizer creates Catch events.
4. Pixel/tag integrations: defer until there is a clear privacy and consent
   model.

Do not expose raw source-evidence internals to owners. Owners should see a
friendly correction flow, not scraper output.

## Indexing Policy

Indexing remains separate from claim status. A claimed page still needs the
readiness gate:

- verified city/category/source;
- current cadence;
- owner/contact verification;
- media permission or neutral asset;
- useful original page copy;
- no unresolved suppression/safety flags.

Use `tool/host_discovery/check_index_readiness.mjs` as the local gate before an
admin promotes the canonical page state through `adminSetClubIndexStatus`.

## Rollout Order

Done:

1. Add `clubClaimRequests` Firestore contract and callable payload schemas.
2. Generate shared schema contracts.
3. Implement `requestClubClaim` and `adminDecideClubClaim` with tests.
4. Close direct Firestore reads/writes for `clubClaimRequests`; access is
   callable-owned for now.
5. Add the admin overview queue for pending claim requests and dashboard
   Approve/Reject actions.
6. Wire public listing claim CTAs to an in-page auth-backed claim form that
   submits `requestClubClaim` when the marketing Firebase/App Check env is set.
7. Add server-owned review responses through `setReviewResponse`; only claimed
   club hosts can respond to reviews for their own club.
8. Write a deterministic owner-facing `clubUpdate` activity notification after
   claim approval; tapping it opens the claimed organizer profile through the
   existing dashboard activity route.
9. Add app-side owner-response display and host edit UI for event review cards;
   responses render from `reviews/{reviewId}.ownerResponse` and edits call
   `setReviewResponse`.
10. Add public website owner-response rendering support for canonical review
    snapshots emitted by the organizer-listing generator.
11. Promote index readiness into an admin-reviewed action through
    `adminSetClubIndexStatus`, the admin overview index-review queue, and
    `publicPage.indexReview` audit metadata.
12. Add an admin organizer detail editor backed by `adminGetClubDetails` and
    `adminUpdateClubDetails`, so ops can clean canonical `clubs/{clubId}`
    display, category, contact, public-page, provenance, and public-profile
    fields without direct client writes.

Remaining:

- No implementation items remain in this claim workflow slice.
- Operationally, current seeded pages should stay `noindex` until source
  evidence, media rights, cadence, and owner/contact verification are completed
  in review.

## Open Product Decisions

- Whether an organizer can own multiple city profiles under one national brand.
- Whether a venue can claim multiple venue-specific profiles with one account.
- Whether claim approval can be automated from official-domain email in the
  future.
- Whether owner-submitted corrections should directly mutate `publicProfile` or
  create admin-review patches.
- Whether public review responses should be available before the organizer hosts
  a Catch event.
