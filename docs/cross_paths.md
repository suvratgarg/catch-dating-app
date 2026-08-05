---
doc_id: cross_paths
version: 1.1.0
updated: 2026-08-05
owner: product (approved direction 2026-08-05)
status: ready-for-implementation
---

# Cross Paths — Explore People + Event Invitation Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`

Related owners: `docs/app_architecture.md`, `docs/data_contracts.md`,
`docs/backend_operation_catalog.md`, `docs/design_language.md`,
`docs/action_cardinality_policy.md`, `lib/user_profile/README.md`,
`lib/safety/README.md`, `design/features/explore.feature.json`.

## Decision status

The product direction in this document was approved on 2026-08-05.

The approved defaults are:

- Explore remains events-first while adding a deliberately scarce people
  modality and an occasional organizer modality.
- Events use tickets, people use Polaroids, and organizers use posters.
- Cross Paths means a compatible, explicitly opted-in person connected to a
  specific upcoming Catch event the viewer can attend. It does not mean GPS
  co-location or a public attendee directory.
- Profile completeness and showcase ranking are separate systems. Raw likes or
  a hidden numeric attractiveness score must not become the eligibility rule.
- Visibility requires both a global opt-in and a per-event opt-in. Existing
  users default to off.
- A personal invitation is delivered only after the sender has a confirmed
  booking for the event.
- Acceptance opens a temporary event-planning conversation. It does not create
  a permanent dating match or bypass the post-event Catch flow.
- Cross Paths does not reorder a normal waitlist or bypass event admission.
- Initial supply uses objective showcase-readiness rules plus reviewed human
  curation. Later ranking may use exposure-adjusted behavioral signals.
- Phase 1 excludes full and waitlist-only events. Later paired inventory must be
  an explicit organizer-controlled product, not a hidden ranking privilege.

## Product thesis

Catch sits at the intersection of events and dating. Events are the setting,
people are the emotional reason to attend, and organizers create the trusted
community in which the meeting happens.

Cross Paths makes that relationship visible in Explore:

> Show a small number of compatible people who have explicitly agreed to be
> shown and who are confirmed for a specific upcoming event. Let the viewer
> understand the event first, book it honestly, and then invite one person to
> make a plan to meet there.

This is not a separate swipe deck. The person is attached to an actionable
event, and the event remains the primary marketplace object.

## Product language

### Entity materials

| Entity | Material | User question |
|---|---|---|
| Event | Ticket | What can I attend? |
| Person | Polaroid | Who might I meet? |
| Organizer | Poster | Who is creating this community? |

`CatchPersonPolaroid` represents the person only. Cross Paths composes the
event context around it as an event-ticket stub, adjacent copy, or CTA. It must
not fork a second Polaroid canvas. `CatchOrganizerPoster` remains the organizer
material and must not be reused for people.

### Name and promise

The feature name is **Cross Paths**, not **Crossed Paths**. The promise is
prospective: these two people could meet at an upcoming event. Product copy
must not imply that they have already met, are geographically near one another,
or have accepted a date.

Suggested copy intent, subject to the normal localization and copy-review
workflow:

- Section: `People you could meet`
- Context: `{First name} is going to {event}`
- Unbooked action: `See the event`
- Booked action: `Invite {First name} to meet there`
- Accepted state: `You both agreed to meet at {event}`

## Scope and non-goals

### In scope

- Consent-safe person recommendations inside the default Explore feed.
- A person profile preview tied to one upcoming Catch event.
- Event booking before invitation delivery.
- One event-scoped personal invitation from a sender for an event.
- Accept, decline, cancel, expire, and invalidate invitation states.
- A temporary event-planning conversation after acceptance.
- Exposure-aware ranking, cold-start exploration, safety suppression, and
  conversion measurement.
- A later organizer-controlled paired-inventory extension.

### Explicit non-goals

- GPS proximity or physical crossing detection.
- A public or client-queryable attendee roster.
- A general-purpose people feed or pre-event swipe deck.
- Direct messages before an invitation is accepted.
- Writing a pre-event invitation into `profileDecisions`.
- Creating a permanent dating match before both people attend the event.
- Waitlist priority based on attractiveness, popularity, likes, payment spend,
  or recommendation rank.
- Cross Paths for external events that are not bookable inside Catch.
- Organizer access to invitation identities, private conversations, private
  preferences, or individual recommendation scores.
- A user-visible desirability rating or an admin-visible numeric
  attractiveness score.

## Current source-backed foundation

The implementation should extend these existing contracts rather than build
parallel systems:

1. `CatchPersonPolaroid` and `CatchOrganizerPoster` establish the person and
   organizer materials. Their current migration may land independently of this
   feature; Cross Paths must consume the final shared APIs.
2. `profileQualitySummary` already measures profile completeness, including
   photographs, prompts, relationship goal, background, lifestyle, and legacy
   running detail. It is an owner-coaching score, not a desirability score.
3. `ViewerEventAvailability.canBookNow` already identifies `open`, `saved`, and
   `approvedToBook` states. Cross Paths must reuse this admission decision
   instead of reimplementing event capacity logic.
4. `eventParticipations/{eventId_uid}` is the canonical booking, waitlist,
   attendance, and cancellation edge.
5. Existing profile decisions and dating matches are attendance-gated. Both
   people must have attended the same event. Cross Paths must not weaken that
   contract.
6. The user-profile exposure event schema already establishes impression,
   view, dwell, and photo-denominator concepts. Cross Paths analytics should
   extend that vocabulary instead of calculating popularity from raw totals.
7. Explore already owns a chronological event feed with organizer intermix and
   viewer-specific event availability. The Cross Paths provider should enrich
   this feed through one batched, feature-owned seam.

### Required correction before launch

Current Firestore rules permit any authenticated user to read active
`eventParticipations` documents in `signedUp`, `waitlisted`, or `attended`
states. The current post-event candidate repository also reads a whole event
roster on the client.

`CROSS-PATHS-PRIVACY-001` is a Phase 0 launch blocker:

- move identified attendee resolution for both the existing post-event Catch
  flow and new Cross Paths flow behind server-owned, purpose-specific reads;
- change participation rules so a member can read only their own edge and an
  authorized organizer can read the roster they manage;
- prove that arbitrary authenticated users cannot enumerate event attendees;
- run the Firestore rules suite under the required emulators.

Cross Paths must never launch on top of the current broad roster-read rule.

## Experience contract

### Explore hierarchy

Events remain the majority of the feed. A person Polaroid is a high-impact
interruption, not the beginning of an endless profile stream.

Phase 1 composition rules:

- No identified people for signed-out viewers.
- No Cross Paths cards on the map route or while text search is active.
- Never render two non-event cards consecutively.
- When at least five eligible event tickets exist, the first eight mixed-feed
  cards contain at least five event tickets, no more than two person Polaroids,
  and no more than one organizer poster. Smaller result sets preserve the same
  event-majority principle without manufacturing filler cards.
- Start with one Polaroid after the viewer has seen two or three event tickets.
- A Cross Paths card stays in the date group of its associated event.
- The associated event ticket remains in the chronological feed; the person
  card does not replace or remove it.
- A viewer sees at most two person suggestions in one Explore session.
- Refresh may return a new valid candidate, but it must respect viewer/candidate
  fatigue and exposure caps.

These numbers are launch defaults and should be configuration-owned and
experimentable, not scattered as widget magic numbers.

### Person card

The card contains:

- the canonical person Polaroid;
- first name and age using the public-profile projection;
- one source-backed compatibility reason at most;
- the associated event name and start-time context;
- a compact event-ticket stub or adjacent event affordance;
- a clear next action based on the viewer state.

The card does not contain:

- an attendee count that can be reverse-engineered into a roster;
- the candidate's private preferences, exact location, booking time, payment
  state, or waitlist history;
- a desirability score, popularity count, or number of invitations received;
- a statement that the candidate wants to meet this specific viewer.

Tapping the person opens a Cross Paths profile preview using the existing
public profile surface with event context around it. Tapping the event context
opens Event Detail. The UI must make these targets distinguishable to screen
readers and at text scale 2.0.

### Viewer states

| Viewer state | Card state | Primary action |
|---|---|---|
| Signed out | Hidden | None |
| Signed in, event bookable, not booked | Discovery | See event / begin booking |
| Signed in, event not bookable | Hidden in Phase 1 | None |
| Signed in, already booked | Invitation-ready | Invite to meet there |
| Invitation pending | Pending | View or cancel invitation |
| Invitation accepted | Plan ready | Open event plan |
| Invitation declined/expired | Terminal | Show terminal state; do not solicit another recipient for this event |
| Either participation cancelled | Invalidated | Explain that the plan is no longer active |
| Event cancelled | Invalidated | Remove discovery and disable the plan |
| Event started | Discovery/pending invite expires; accepted plan remains active | Keep the accepted plan available through its post-event grace window |

## Eligibility

Eligibility is server-resolved. The client must not fetch a roster and then
filter it.

### Event eligibility

An event is eligible only when all are true:

- It is a first-party Catch event with a supported booking path.
- It is published/active, upcoming, and not cancelled.
- It appears in the viewer's current Explore discovery result set.
- The candidate has a `signedUp` participation, not `waitlisted` or merely
  saved.
- The viewer either has a `signedUp` participation or
  `ViewerEventAvailability.canBookNow` is true.
- The event begins after the configured minimum invitation-response lead time.
- It is not full, waitlist-only, invite-only without viewer entitlement,
  membership-blocked, cohort-blocked, age-blocked, or otherwise ineligible for
  that viewer.

Recommended launch tunables:

- minimum invitation-response lead time: 6 hours;
- maximum recommendation horizon: the current Explore discovery window, capped
  at 14 days;
- no external-event or waitlist-only exceptions.

### Candidate eligibility

A candidate is eligible only when all are true:

- global Cross Paths visibility is enabled;
- per-event Cross Paths visibility is enabled for this event;
- the candidate has a confirmed `signedUp` event participation;
- the public profile exists and passes showcase readiness;
- both people pass reciprocal age and gender preference checks, resolved on the
  server without returning either person's private preference values;
- neither person has blocked or reported the other in a suppressing state;
- neither account is deleted, suspended, or moderation-ineligible;
- the pair does not already have an active dating match or accepted Cross Paths
  plan for this event;
- candidate, pair, viewer-session, and event exposure caps are not exhausted;
- the candidate has not withdrawn consent or cancelled the event booking.

Organizers cannot nominate a person, pay to raise a person, or override the
mutual-compatibility and safety filters.

## Showcase readiness and ranking

### Do not reuse the current score blindly

The current profile-completeness score assigns material weight to running
preferences. Catch is now a broader events product, so a non-running user can
have an excellent dating profile without completing running-specific fields.

Before Cross Paths eligibility depends on `ProfileQualitySummary.isStrong`,
profile quality must be made activity-neutral or Cross Paths must use a separate
showcase-readiness predicate.

Launch showcase readiness should use objective, explainable checks such as:

- at least three usable profile photos;
- a clear primary portrait;
- the required profile prompts are complete;
- relationship goal is present;
- public profile is complete and current;
- required photo/profile moderation has passed;
- no broken media or placeholder-only profile;
- reviewed launch eligibility when the automated signal is uncertain.

The member-facing experience may tell someone how to become showcase-ready. It
must not tell them they are unattractive or low value.

### Ranking stages

Ranking has three explicit stages:

1. **Hard eligibility** — consent, event, booking, reciprocal preferences,
   safety, moderation, and showcase readiness.
2. **Viewer relevance** — event relevance, compatibility reasons, profile
   freshness, prior pair history, and current session context.
3. **Marketplace balancing** — exposure fatigue, cold-start exploration,
   concentration limits, and tie-breaking.

V1 may use reviewed human curation to establish the eligible pool, but the
final ordering for a viewer must remain server-owned and deterministic for a
given ranking version and request context.

### Behavioral ranking guardrails

Raw incoming likes, views, or dwell must never be compared without their
exposure denominator. When behavioral ranking is introduced:

- normalize positive actions by qualified impressions;
- apply time decay;
- separate model training data from user-visible analytics;
- reserve a configurable exploration share for newly eligible profiles;
- cap repeated exposure to the same viewer and across the market;
- do not use payment spend, organizer relationship, or waitlist rank;
- do not expose rank or score to the candidate, viewer, or organizer;
- log ranking version and coarse reason codes, not a user-facing rating;
- evaluate exposure concentration and outcome quality before increasing model
  weight.

Recommended initial exploration share: 20 percent of otherwise eligible
placements. This is a configuration default, not a permanent policy constant.

## Consent and privacy

### Global consent

Add a private user preference equivalent to
`prefsShowInCrossPaths: boolean`.

- Existing users and users missing the field resolve to `false`.
- Add the field through an optional-on-read, default-false migration and
  backfill before making it contract-required; it must never default to true.
- The setting lives under Settings → Privacy & Safety.
- Turning it off immediately suppresses all future discovery.
- Turning it on does not itself opt the user into any event.
- The field must not be projected into `publicProfiles/{uid}`.

### Per-event consent

Consent for a specific event is stored as a deterministic relationship edge,
proposed as `eventCrossPathsConsents/{eventId_uid}`. It is not an array on the
user, event, or participation document.

Proposed fields:

| Field | Meaning |
|---|---|
| `eventId`, `uid` | Deterministic scope |
| `enabled` | Current per-event choice |
| `termsVersion` | Copy/policy version the member accepted |
| `consentedAt` | First affirmative consent time |
| `updatedAt` | Latest choice time |
| `revokedAt` | Latest revocation time, nullable |
| `source` | `booking_success`, `event_detail`, or `settings` |

The per-event control is offered after a confirmed booking and on the member's
event detail/booking management surface. Consent may be revoked without
cancelling the event booking.

Effective visibility is:

`global opt-in AND event opt-in AND current eligibility`.

Revoking visibility invalidates pending invitations and removes future
recommendations. It does not silently cancel an already accepted plan; the
member receives a separate, explicit action for that.

### Disclosure

Consent copy must say that:

- the member's public profile may be shown to compatible Catch members;
- the associated event name and attendance intention will be shown;
- this is not a public attendee list;
- the member may receive a limited number of private event invitations;
- they can withdraw before the event;
- blocking, reporting, and cancellation controls remain available.

The privacy policy and in-app privacy explanation must be updated before the
feature flag is enabled outside internal/demo environments.

Invitation state is always visible in-app while the member remains opted in.
Phase 2 should add a dedicated Cross Paths invitation push preference rather
than silently reusing the existing new-Catches or messages preference. Missing
values resolve to off until the member has explicitly enabled Cross Paths.

## Invitation contract

The invitation expresses event-scoped romantic/social interest. It is not a
post-event Catch and must not create `profileDecisions` data.

### Cardinality

| Action | Scope | Cardinality | Resulting UI state |
|---|---|---|---|
| Toggle global visibility | user | Singleton toggle | On/off master state |
| Toggle event visibility | user + event | Singleton edge, repeatedly updateable | Shown/hidden for that event |
| Open profile/event | viewer + suggestion | Repeated read | Detail/preview |
| Join/book event | viewer + event | Existing singleton booking contract | Confirmed participation |
| Send invitation | sender + event | Domain-bounded: one recipient for the event | Pending |
| Respond | invitation + recipient | Singleton terminal decision | Accepted or declined |
| Accept an invitation | recipient + event | Domain-bounded: one accepted plan | Event plan created; competing pending invites invalidated |
| Cancel pending invitation | invitation + sender | Singleton inverse before response | Cancelled |
| Cancel accepted plan | participant + event plan | Singleton inverse | Plan cancelled/read-only |
| Send event-plan message | participant + active plan | Unbounded until plan expiry, abuse-rate-limited | Message timeline |

At launch, sending an invitation consumes the sender's one invitation for that
event even if it is later declined, cancelled, or expires. This makes the
action intentional and prevents profile shopping around one event.

A recipient may have at most three pending invitations for one event. Once one
is accepted, all competing pending invitations for that recipient/event are
invalidated with generic copy that does not identify the accepted sender.

### Preconditions for send

The backend revalidates all of these transactionally:

- authenticated sender;
- valid, unexpired server-issued suggestion token;
- sender and recipient are different;
- both have `signedUp` participation for the same upcoming event;
- recipient still has effective consent;
- reciprocal preferences, showcase eligibility, and safety checks still pass;
- no prior sender invitation for the event;
- recipient pending-invitation cap is not exceeded;
- no active accepted plan for either member where the one-plan-per-event rule
  would be violated;
- event and participation states still support the action.

V1 has no free-text invitation message. The sender chooses only the typed
event-scoped action, which reduces harassment and moderation surface area.

### Invitation lifecycle

Proposed `crossPathsInvitations` states:

`pending → accepted | declined | cancelled | expired | invalidated`

Transitions are callable-owned, idempotent, and recorded with server times.
The client never writes invitation documents directly.

Suggested expiration is the earlier of:

- the event's configured invitation cutoff; or
- event start minus a small operational buffer.

Cancellation, event cancellation, a blocking action, account deletion, or
loss of either confirmed participation invalidates a pending invitation.

### Booking sequence

For an unbooked viewer:

1. Open the event or `Join and invite` intent.
2. Complete the existing booking/payment flow.
3. Confirm that `eventParticipations/{eventId_uid}` is `signedUp`.
4. Revalidate the suggestion.
5. Ask for final invitation confirmation.
6. Send the invitation.

Payment and invitation are separate receipts. A failed or abandoned payment
must never send an invitation. An invitation failure must not roll back a valid
event booking.

## Accepted plan and chat semantics

Acceptance means: “We both agreed to make a plan to meet at this event.” It
does not promise a date, guarantee attendance, or create a permanent match.

The implementation should reuse the existing conversation infrastructure by
adding a distinct conversation type, proposed as
`crossPathsEventPlan`, with a deterministic event-and-pair-scoped id. It must
not use the pair-only dating-match id.

Required boundaries:

- no match celebration;
- no dating-match metric or Event Success match signal;
- no conversion of the event plan into a dating match;
- event context remains visible in the conversation header;
- messaging is disabled after `event.endTime + 24 hours` unless a normal dating
  match has independently formed;
- an expired plan remains available as a truthful, read-only receipt according
  to the chat retention policy;
- blocking immediately disables writes and follows existing symmetric safety
  enforcement;
- report entry points are available from the profile, invitation, and event
  plan.

After attendance, each person may use the normal Catch flow. Reciprocal
attendance-gated profile decisions create the permanent dating match exactly as
they do today; the event plan is not silently upgraded.

## Capacity, waitlists, and later pair inventory

### Phase 1 and Phase 2

- A recommendation may be shown only when the viewer is already `signedUp` or
  can book now.
- A candidate must already be `signedUp`.
- Waitlisted candidates are never presented as attending.
- Waitlist-only viewers do not receive Cross Paths recommendations for that
  event.
- Sending or accepting an invitation does not reserve a seat, change cohort
  capacity, change payment requirements, or alter waitlist order.
- If the final seat disappears before booking, normal Event Detail availability
  wins and the suggestion becomes non-actionable/hidden.

### Phase 3: organizer-controlled pair inventory

Paired inventory is a later, separately gated extension. It may be implemented
only when an organizer explicitly configures a bounded pool of two-person
holds.

The later contract must include:

- organizer-visible reserved pair capacity;
- a short-lived, transactionally created two-seat hold;
- independent eligibility and price quotes for both members;
- both members' payment/confirmation before final admission;
- expiry and automatic inventory release;
- cohort/capacity invariants shared with the canonical event-policy engine;
- transparent UI that distinguishes a hold from a confirmed booking;
- no hidden ranking-based waitlist movement.

Until that contract exists, Cross Paths never changes admission.

## Proposed backend and data ownership

All names in this section are proposed implementation contracts. They do not
exist merely because this spec names them.

### Relationship documents

| Relationship | Proposed source |
|---|---|
| Global visibility master | private `users/{uid}.prefsShowInCrossPaths` |
| Per-event consent | `eventCrossPathsConsents/{eventId_uid}` |
| Human/automated showcase eligibility | server-only `crossPathsShowcaseEligibility/{uid}` |
| Event invitation | `crossPathsInvitations/{eventId_senderUid}` |
| Accepted event plan | event-and-pair-scoped conversation with `conversationType: crossPathsEventPlan` |
| Exposure/fatigue state | server-only projection or analytics store, never a public user field |

`crossPathsShowcaseEligibility` stores only operational status and reason codes
such as `eligible`, `needsReview`, or `paused`, plus rule/review version and
timestamps. It must not store a numeric attractiveness label.

### Callable/API seams

1. `getCrossPathsSuggestions`
   - accepts a bounded set of Explore event ids and an opaque session id;
   - revalidates event discoverability and viewer availability;
   - resolves rosters, consent, reciprocal preferences, safety, readiness,
     ranking, and fatigue on the server;
   - returns at most the configured session limit;
   - returns a sanitized person/event projection, reason codes, ranking version,
     and short-lived signed suggestion token;
   - never returns a roster or private preference values.
2. `setCrossPathsEventConsent`
   - acts only for the caller;
   - validates a current confirmed participation when enabling;
   - records terms version and source;
   - invalidates pending invitations on disable.
3. `sendCrossPathsInvitation`
   - validates the suggestion token and all send preconditions;
   - creates the deterministic invitation transactionally;
   - creates one recipient notification.
4. `respondCrossPathsInvitation`
   - acts only for the recipient;
   - revalidates both participations, safety, event time, and caps;
   - on acceptance creates the event-plan conversation and invalidates
     competing pending invitations atomically.
5. `cancelCrossPathsInvitationOrPlan`
   - acts only for a participant;
   - preserves a server-owned terminal receipt and disables further writes.

Every callable requires App Check, explicit rate limits, typed request/response
schemas, idempotent deterministic writes, generic safety errors, and focused
Functions tests.

### Firestore rules

- `eventParticipations`: self read or authorized organizer read only.
- `eventCrossPathsConsents`: caller may read their own state; writes are
  callable-owned.
- `crossPathsShowcaseEligibility`: no consumer client reads/writes.
- `crossPathsInvitations`: sender and recipient may read; no direct writes.
- event-plan conversation/messages: participants may read; messages may be
  created only while the plan is active, unexpired, and unblocked.
- suggestion inputs, ranking state, private preference data, and roster joins
  remain server-only.

Rules tests must cover collection queries as well as single-document reads so
the roster cannot be reconstructed by changing query predicates.

### Flutter ownership

Create a feature root such as `lib/cross_paths/` with normal domain, data, and
presentation boundaries:

- domain models: sanitized suggestion, consent state, invitation state, event
  plan state, ranking reason enum;
- data repository: callable requests and caller-owned invitation/plan streams;
- providers/controllers: batched Explore enrichment, consent mutations,
  invitation mutations, and frozen pending-request snapshots;
- presentation: feature-specific composition around `CatchPersonPolaroid`;
- Explore remains the route/provider boundary and receives provider-free mixed
  feed card state;
- shared person and event materials stay in their existing owners.

The current `SwipeCandidateRepository` is not a reusable pre-event source. It
assumes an open post-event Catch window and client roster access. Shared
preference and safety predicates may be extracted into canonical domain/server
helpers, but the repositories and lifecycle semantics remain separate.

## Safety and abuse controls

- Apply existing block suppression in both directions before suggestion, send,
  accept, plan read, and message write.
- Suppress accounts with unresolved moderation restrictions.
- Do not reveal whether a block, report, consent change, or competing accepted
  invitation caused generic unavailability.
- Rate-limit suggestion refreshes, invitation sends, responses, and plan
  messages independently.
- Do not expose received-invitation counts, candidate popularity, or organizer
  roster membership.
- Do not allow free text before mutual acceptance.
- Invalidate pending invitations after either member cancels, the event is
  cancelled, the cutoff passes, or safety state changes.
- Keep organizers outside the invitation and plan audience. Provide only
  aggregate, privacy-thresholded conversion data if host analytics later needs
  it.
- Account deletion removes or anonymizes consent, invitation, suggestion, and
  plan identifiers using the existing deletion/tombstone workflow.
- Demo/synthetic profiles must be clearly scoped to demo environments and must
  not leak into production recommendations.

## Analytics and experimentation

### Funnel events

Instrument at minimum:

- `cross_paths_impression`
- `cross_paths_profile_open`
- `cross_paths_event_open`
- `cross_paths_booking_started`
- `cross_paths_booking_completed`
- `cross_paths_invitation_sent`
- `cross_paths_invitation_accepted`
- `cross_paths_invitation_declined`
- `cross_paths_invitation_expired`
- `cross_paths_plan_opened`
- `cross_paths_plan_message_sent`
- `cross_paths_both_attended`
- `cross_paths_post_event_catch`
- `cross_paths_post_event_match`
- `cross_paths_visibility_enabled`
- `cross_paths_visibility_disabled`

Events should carry event id, suggestion id, surface, position, ranking version,
coarse reason codes, and experiment assignment where appropriate. Do not put
private preference values, exact score, report reason, or block direction into
analytics payloads.

### Success metric

Primary outcome:

> A Cross Paths-qualified Explore impression leads to a confirmed booking, and
> both the viewer and featured candidate attend the associated event.

Secondary outcomes:

- profile → event-detail conversion;
- event-detail → confirmed-booking conversion;
- invitation send and acceptance rate;
- accepted-plan co-attendance;
- post-event reciprocal Catch and permanent match;
- time from impression to booking.

### Guardrails

- consent opt-out and revocation rate;
- block/report rate after exposure or invitation;
- invitation concentration per candidate;
- exposure concentration across eligible candidates;
- event cancellations, refunds, and no-shows following Cross Paths conversion;
- candidate cancellation after being featured;
- unread or unanswered invitation burden;
- organizer safety/support complaints;
- ranking lift by exposure-adjusted cohort, not raw totals.

Use a persistent randomized holdout among eligible sessions before attributing
booking lift to Cross Paths. Strong events and strong profiles would otherwise
create selection bias.

## Delivery phases

### Phase 0 — Privacy and eligibility foundation

Implementation receipt (2026-08-05): the first privacy slice is implemented.
The existing post-event swipe deck, Event Recap, and identified post-event
avatar enrichment now resolve candidates through the server-owned
`fetchSwipeCandidates` callable. Consumer roster reads are restricted to the
member's own edge, organizer roster access remains intact, and the callable
enforces the Catch window, viewer attendance, reciprocal preferences, prior
decisions, and blocks in both directions. This does not complete Phase 0:
feature flags, Cross Paths consent, showcase eligibility, the Explore
suggestion contract, and synthetic seed policy remain outstanding.

- Land/reuse the person-Polaroid and organizer-poster migration.
- Introduce the feature flag with fail-closed defaults.
- Generalize showcase readiness away from running-only completeness.
- Add global and per-event consent contracts and Settings/event controls.
- Add reviewed showcase-eligibility operations for launch supply.
- Build the server-owned batched suggestion callable.
- Migrate post-event Catch candidate resolution off client roster reads.
- Restrict Firestore participation reads and prove rules under emulators.
- Seed consent/eligibility only for synthetic internal/demo profiles.

Exit gate: arbitrary authenticated users cannot enumerate event rosters, and a
suggestion cannot be returned without effective consent and reciprocal
eligibility.

### Phase 1 — Discovery and booking

- Add Cross Paths mixed-feed card and profile preview.
- Enforce the Explore modality budget and no-search/no-map constraints.
- Link every Polaroid to one still-actionable event.
- Route unbooked viewers through the existing Event Detail/booking flow.
- Instrument exposure, profile-open, event-open, and booking conversion.
- Launch to a small market/flag cohort with manual showcase curation.

No invitation is delivered in this phase.

Exit gate: the card measurably improves qualified event-detail or booking
conversion without unacceptable consent, safety, cancellation, or exposure
concentration guardrails.

### Phase 2 — Invitation and event plan

- Add invitation contracts, callables, notifications, and inbox states.
- Require confirmed sender and recipient participation.
- Enforce one sender invitation and one accepted recipient plan per event.
- Add accept/decline/cancel/expire/invalidate transitions.
- Add the `crossPathsEventPlan` conversation type and expiry behavior.
- Exclude event plans from permanent-match and Event Success metrics.
- Measure acceptance, co-attendance, plan usage, and post-event Catch outcomes.

Exit gate: invitation abuse remains within guardrails and accepted invitations
increase co-attendance or post-event mutual interest without confusing the
permanent-match promise.

### Phase 3 — Explicit paired inventory

- Write a separate event-policy/payment contract for organizer-controlled
  two-seat inventory.
- Add two-seat hold, payment, expiry, release, and cohort invariants.
- Pilot only with organizers who explicitly enable and understand the product.

This phase is not implied by Phase 1 or Phase 2 and requires its own owner
approval before implementation.

## Verification and evidence

Implementation is incomplete until the changed phase has all relevant proof:

- JSON schemas for every new document and callable payload/response;
- generated Dart/TypeScript/admin validators refreshed from source schemas;
- `docs/data_contracts.md` and `docs/backend_operation_catalog.md` updated;
- `design/features/explore.feature.json`, screen contract, component contract,
  and feature coverage updated only when the surface is actually implemented;
- Firestore rules emulator tests for roster denial, own/host reads, consent,
  invitation, and event-plan access;
- Functions tests for eligibility, reciprocal preferences, idempotence,
  capacity drift, consent revocation, invitation caps, blocks, cancellation,
  expiry, and competing acceptance;
- Flutter repository/controller/state/widget tests for every viewer and
  invitation state;
- Widgetbook states for ready, book-first, pending, accepted, declined,
  expired, invalidated, long copy, missing media, dark mode, text scale 2.0,
  and reduced motion;
- analytics emission tests and holdout assignment tests;
- account-deletion cleanup coverage;
- `./tool/check_data_contract.sh` when contracts/rules change;
- relevant feature-contract, component, copy, design, analyzer, and readiness
  gates from `AGENTS.md` and the generated context pack.

## Launch checklist

- [ ] Feature flag is off by default in production.
- [ ] Existing and missing global preferences resolve to off.
- [ ] Per-event consent copy and privacy policy are approved.
- [ ] No consumer query can enumerate an event roster.
- [ ] Only signed-up candidates and bookable/already-booked viewers qualify.
- [ ] Reciprocal preferences and blocks are server-enforced.
- [ ] Showcase readiness is activity-neutral and moderation-aware.
- [ ] No raw attractiveness or popularity score is stored or exposed.
- [ ] Explore modality budget and session caps are enforced.
- [ ] Full, waitlist-only, cancelled, external, and ineligible events suppress
      suggestions.
- [ ] Booking succeeds before any invitation is sent.
- [ ] Invitations cannot alter event capacity or waitlist order.
- [ ] Accepted plans remain separate from permanent dating matches.
- [ ] Organizer analytics are aggregate and privacy-thresholded.
- [ ] Experiment holdout and all guardrail dashboards are live.
- [ ] Internal/demo, staged-market, rollback, and support runbooks are tested.

## Implementation-time tunables

These are configuration/calibration values, not unresolved product decisions:

- first Polaroid insertion position;
- session suggestion limit up to the approved maximum of two;
- exploration share, initially 20 percent;
- per-candidate and per-pair exposure/fatigue windows;
- minimum invitation lead time, initially 6 hours;
- maximum event horizon, capped at 14 days;
- recipient pending-invitation cap, initially three;
- event-plan write window, initially through event end plus 24 hours;
- experiment allocation and staged-market percentage.

Changing the underlying semantics—public rosters, pre-booking messages,
permanent pre-event matches, hidden waitlist priority, or non-consensual
visibility—is not a tuning change and requires new owner approval.
