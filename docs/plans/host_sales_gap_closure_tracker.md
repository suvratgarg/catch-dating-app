---
doc_id: host_sales_gap_closure_tracker
version: 0.1.0
updated: 2026-06-04
owner: host_growth_product
status: completed
priority: P0
---

# Host Sales Gap Closure Tracker

## Goal

Build the product reality required for a compelling host sales page. Marketing
should be able to say that Catch helps hosts fill the event, run it better, help
people connect afterward, and learn what to change next time because those
claims are true in product, data, and host UI.

This tracker closes the gaps found while auditing the WIP host page:

- a unified Event Success assignment engine with concrete primitive support;
- host-visible private-interest / "caught someone" reporting;
- invite-link performance;
- waitlist movement and host-controlled waitlist offers;
- host funnel metrics from demand to attendance to connection;
- fresh scorecards whenever matches, chats, feedback, attendance, or funnel
  events change.

Feedback theme extraction is intentionally out of scope for now.

## Operating Principle

Do not shrink positioning to fit current implementation. Raise implementation to
support the sales story, while keeping host-visible reporting privacy-safe and
auditable.

## Current State Summary

### Already Real

- Admission policies support open, invite-only, request-to-join, fixed cohort
  caps, balanced ratio, membership, waitlists, and paid/free events.
- Host Manage has setup/live/report lifecycle surfaces, request review, roster
  filters, and check-in.
- Event Success has setup/live/report surfaces, First Hello, micro-pods, guided
  rotations, live reveal, wingman requests, compatibility responses, attendee
  feedback, and host coaching.
- Post-event matching is attendance-gated. Private catches create profile
  decisions, reciprocal catches create matches, and messages update match
  metadata.

### Closed In This Tracker

- Invite links are now attributed performance objects with opens, requests,
  bookings, paid completions, check-ins, catches, matches, and chats.
- Waitlist movement now includes host-controlled expiring offers with attendee
  accept/decline paths, paid handoff, reserved-capacity checks, expiry cleanup,
  and report/export visibility.
- Request-to-confirm, payment completion, offer acceptance, invite performance,
  attendance, connection, and repeat-attendee counts now flow into the host
  funnel.
- Event Success now uses a primitive-driven assignment engine for group size,
  rotations, gender/orientation fit, questionnaire signal, blocks, opt-outs,
  host constraints, activity attributes, and richer slot metadata. Remaining
  caveats are listed under Improvement Candidates, not treated as blockers for
  the host sales story.

## Milestone 0 - Scorecard Freshness Foundation

Priority: P0, start immediately.

Status: completed 2026-06-04.

Goal: Scorecards must update when downstream connection signals change, not only
when attendees submit feedback.

Implementation:

- Add shared scorecard refresh calls from match creation/update paths.
- Add shared scorecard refresh calls from first-message paths.
- Keep refresh idempotent by using existing `refreshEventSuccessScorecard`.
- Avoid exposing private profile decision identities to hosts.
- Add unit coverage proving matching and messaging trigger refreshes for every
  event id attached to a match.

Acceptance:

- A reciprocal catch that creates or updates a match refreshes the relevant event
  scorecard.
- A first message or later message refreshes the scorecard for all `eventIds` on
  the match.
- Replayed message triggers remain idempotent.
- Existing matching/chat tests still pass.

Verification:

```bash
cd functions
npm run build
node --test lib/matching/onSwipeCreated.test.js lib/matching/onMessageCreated.test.js lib/marketplace/eventSuccessScorecards.test.js
```

## Milestone 1 - Host-Visible Catch Metrics

Priority: P0.

Status: completed 2026-06-04.

Goal: Hosts can see connection demand without seeing private target identities.

Data contract:

- Extend `eventSuccessScorecards/{eventId}` with aggregate-only fields:
  - `catchSentCount`
  - `attendeesWhoCaughtSomeone`
  - `catchRecipientCount`
  - `catchRate`
  - `mutualMatchCount`
  - `chatStartedCount`
- Keep raw `profileDecisions/{uid}/outgoing/{targetId}` private.
- Compute from profile decisions where:
  - `eventId == eventId`
  - `direction == "like"`
  - swiper and target both attended
  - blocking rules still pass or the decision was not invalidated.

Implementation:

- Add a server helper to load privacy-safe catch aggregates.
- Add catch aggregates to `buildEventSuccessScorecard`.
- Add scorecard refresh on profile-decision writes, or call refresh from
  `onSwipeCreated` before returning when a like is recorded.
- Update generated schema/types.
- Update host report copy/components to show "caught someone" where the metric is
  now real.
- Add tests for one-way catches, mutual catches, blocked pairs, and non-attended
  users being excluded.

Acceptance:

- Host report can truthfully show "X caught someone" or "Y% caught someone."
- Host never sees who caught whom unless the attendee explicitly submitted a
  wingman request.
- Aggregate fields are stable across duplicate trigger delivery.

Verification:

```bash
node tool/contracts/generate_schema_contracts.mjs
cd functions && npm run build && npm run lint -- --quiet
cd functions && node --test lib/marketplace/eventSuccessScorecards.test.js lib/matching/onSwipeCreated.test.js lib/matching/onMessageCreated.test.js lib/shared/schemaContracts.test.js
flutter analyze --no-fatal-infos lib/event_success/domain/event_success_models.dart lib/event_success/data/event_success_repository/providers.dart lib/event_success/presentation/host_parts/event_success_host_report.dart lib/event_success/presentation/event_success_feature_blocks.dart lib/event_success/presentation/event_success_lab_screen.dart lib/event_success/domain/event_success_coach.dart lib/event_success/domain/event_success_event_preview.dart lib/event_success/presentation/event_success_manual_qa_screen.dart test/ui_captures/catalog/screen_capture_catalog.dart test/event_success/event_success_live_screens_test.dart lib/core/schema_contracts/generated/schemas/event_success_scorecard_document.g.dart
flutter test test/event_success/event_success_live_screens_test.dart test/event_success/event_success_playbooks_test.dart test/event_success/event_success_event_preview_test.dart test/event_success/event_success_repository_test.dart
flutter test test/event_success/event_success_manual_qa_screen_test.dart --name "manual QA screen renders host and attendee panes"
git diff --check
./tool/check_data_contract.sh
```

## Milestone 2 - Invite Link Performance

Priority: P0.

Status: completed 2026-06-04.

Goal: Hosts can tell which invite links and channels create demand, bookings,
attendance, and connection.

Data contract:

- Add `eventInviteLinks/{linkId}`:
  - `eventId`, `clubId`, `hostUid`
  - `label`, `source`, `tokenHash`
  - `createdAt`, `disabledAt`
  - aggregate counters: `openCount`, `requestCount`, `confirmedCount`,
    `paidCount`, `checkedInCount`, `catcherCount`, `matchCount`,
    `chatStartedCount`
- Add attribution fields to `eventParticipations/{eventId_uid}`:
  - `inviteLinkId`
  - `inviteSource`
  - `inviteCapturedAt`
- Add attribution fields to payment/session metadata where provider constraints
  allow it.

Implementation:

- Host Manage setup: create/copy named invite links.
- App/web deep link: accept `inviteLinkId` or token and preserve it through login,
  profile completion, request, waitlist, signup, and payment.
- Backend callable: `recordEventInviteLinkOpen`.
- Booking and waitlist callables: attach invite attribution to participation.
- Scorecard/funnel builder: aggregate attributed demand and conversion.

Acceptance:

- A host can create "Instagram bio", "WhatsApp alumni", or "Venue partner"
  links.
- The report shows opens -> requests -> confirmed -> checked in -> matches/chats
  by link.
- Disabled links stop accepting new attribution but do not erase historical
  reporting.

Completion note:

- Milestone 2 now covers server-owned `eventInviteLinks/{linkId}` contracts,
  create/disable/open callables, Firestore read rules, generated Functions/Dart
  schema bindings, host create/copy/disable UI, deep-link preservation through
  event detail, request/waitlist/signup/payment attribution, payment metadata,
  ops/revenue CSV attribution columns, and per-link connection counters refreshed
  from canonical swipes/matches/messages during scorecard rebuilds. Live
  counters now cover opens, requests, confirmed bookings, paid completions,
  check-ins, caught-someone count, mutual matches, and chats started.
- Verification passed: `flutter analyze --no-fatal-infos` on the touched
  invite/payment/host files; focused Flutter tests for event repository, booking
  controller, event detail/share, payment repository, and host report export;
  Functions `npm run build`; Functions `npm run lint -- --quiet`; and focused
  Node tests for signup, waitlist offers, attendance, Razorpay/Stripe payment
  paths, scorecards, swipes, and messages.

## Milestone 3 - Waitlist Movement And Offers

Priority: P0.

Status: completed 2026-06-04.

Goal: Waitlist is not just passive overflow. Hosts can create controlled offers
that protect event balance and give attendees a clear next step.

Data contract:

- Add `eventWaitlistOffers/{eventId_uid}`:
  - `eventId`, `clubId`, `uid`, `cohortAtOffer`
  - `status`: `active`, `accepted`, `declined`, `expired`, `cancelled`
  - `source`: `host`, `autoPromotion`, `ratioBalancing`, `cancellation`
  - `offeredBy`, `offeredAt`, `expiresAt`, `decidedAt`
  - `inviteLinkId` copied from participation when available
- Extend participation with:
  - `waitlistOfferStatus`
  - `waitlistOfferedAt`
  - `waitlistOfferExpiresAt`
  - `waitlistOfferAcceptedAt`

Implementation:

- Callable: `createEventWaitlistOffers`.
- Callable: `acceptEventWaitlistOffer`.
- Callable: `declineEventWaitlistOffer`.
- Scheduled/triggered expiry cleanup.
- Host Manage setup/live: "Offer spot" and "Offer next N" actions with cohort
  balance warnings.
- Attendee CTA: active offer state with countdown, payment handoff if paid, and
  decline option.
- Notifications for offer issued, expiring, accepted, expired.

Acceptance:

- Hosts can fill cancellations without breaking ratio/cohort rules.
- Paid events can issue an offer without immediately booking unpaid attendees.
- Funnel reports distinguish waitlisted, offered, accepted, expired, and booked.

Completion note:

- Milestone 3 now covers the waitlist-offer lifecycle, host roster controls,
  attendee CTA/payment handoff, server-owned expiry, notifications, reserved
  capacity, report-row labels, and ops CSV offer-state columns. Full funnel
  rollups and conversion charts remain Milestone 4.

## Milestone 4 - Host Funnel Metrics

Priority: P0.

Status: completed 2026-06-04.

Goal: The host report should show the whole event operating funnel.

Metrics:

- demand: invite opens, requests, direct signups, waitlist joins;
- curation: approved, declined, offered, offer accepted, offer expired;
- commerce: checkout started, payment completed, payment failed/refunded;
- attendance: booked, checked in, no-show;
- connection: attendees who caught someone, mutual matches, chats started;
- retention: repeat attendees and repeat hosts by club/event format.

Implementation:

- Create a server-owned `eventHostFunnelSnapshots/{eventId}` or embed a
  `funnel` object in scorecards if size stays small.
- Prefer rebuilding from canonical documents over increment-only counters.
- Add host report UI blocks: Fill, Curation, Attendance, Connection, Next move.
- Add demo seed fixtures and marketing screenshots once the UI is wired.

Acceptance:

- The host can answer: "Where did demand come from, where did people drop off,
  and did this event create follow-up?"
- Metrics have definitions in code and docs.
- Host-visible counters never leak private target identities.

Completion note:

- Milestone 4 embeds a server-owned `funnel` object in
  `eventSuccessScorecards/{eventId}` and rebuilds it from canonical invite
  links, participations, waitlist offers, payments, scorecard connection
  aggregates, and prior club attendance. The host report now shows demand,
  curation, commerce, attendance, connection, and repeat-attendee metrics, and
  the coach can use funnel signal for next-step recommendations.
- Scorecard freshness now includes participation, payment, waitlist-offer, and
  invite-link writes. Invite-link scorecard refreshes ignore connection-counter
  only updates so the link-level catch/match/chat refresh does not create a
  self-triggered loop.
- Verification passed: Functions build/lint; focused backend signup,
  waitlist-offer, attendance, payment, scorecard, swipe, and message tests;
  focused Flutter analysis for scorecard parsing/report/coach/manual QA
  surfaces; focused Flutter Event Success tests; and `git diff --check`.

## Milestone 5 - Unified Primitive Assignment Engine

Priority: P0, highest product priority.

Goal: Event Success assignments should be concretely better because the engine
understands the event primitives that matter: group size/count, rotations,
participant gender/orientation, questionnaire responses, blocks, opt-outs, and
host constraints. The engine should not branch on whether the event is called a
dinner, run club, pub quiz, or pickleball game.

Current seam:

- `EventFormatSnapshot.interactionModel` and `eventSuccessPrimitives` already
  choose sensible defaults and UI language from format.
- `EventSuccessStructureConfig` already supports `wholeGroup`, `pods`, `pairs`,
  `teams`, and `tables`.
- Backend optimizer already handles pairs, group units, and group rotations with
  safety/compatibility constraints.

Required upgrade:

Make the shared assignment engine the canonical backend path. Add richer
primitive inputs over time while keeping safety, opt-out, blocked-pair,
orientation, questionnaire, and repeat-exposure guardrails in one place.
Event type can set defaults, labels, screenshots, copy, and stats rails
upstream; it should not own separate optimizer behavior.

### 5A - Primitive Engine Interface

Add an internal backend abstraction:

- `AssignmentEngineContext`
  - resolved topology: unit kind, unit size, group count, rotation interval
  - eligible attendees with profile/activity attributes
  - participant gender, interested-in genders, and questionnaire answers
  - block graph
  - opt-outs already applied by caller
  - optional host constraints
- `AssignmentEngineResult`
  - assignments
  - explainable metrics: target group size/count, requested/generated rounds,
    mutual/plausible dyads, repeat-pair count, orientation fallbacks,
    unassigned attendees, group size skew, and constraint relaxations

Acceptance:

- Existing pods and rotations run through this interface.
- Tests can assert primitive-specific reasons, not only final group membership.
- The engine does not inspect event format names; format-level modeling remains
  upstream.

### 5B - Group Composition And Dyad Balance

Use for any grouped event where the host wants balanced tables, pods, teams, or
activity groups.

Inputs:

- target group size or group count;
- gender and interested-in genders;
- compatibility questionnaire answers;
- sparse-cohort and imbalance detection;
- optional host locks: keep together, keep apart, anchor attendee.

Behavior:

- distribute compatible dyads across groups instead of creating all-men/all-women
  or otherwise low-opportunity groups when better alternatives exist;
- group sparse compatible cohorts together where that creates real opportunity;
- avoid blocked pairs and explicit keep-apart pairs;
- explain unavoidable imbalances as constraint relaxations.

Acceptance:

- Straight 3-and-3 tables should not become one table of men and one table of
  women when balanced alternatives exist.
- Gay, bi, and sparse-orientation cohorts should get best-effort compatible
  placements without requiring event-type-specific code.

### 5C - Rotation Repeat Minimization

Use for any event with one-to-one rotations, table/course rotations, partner
reshuffles, or team reshuffles.

Inputs:

- requested rotation count or rotation cadence plus event duration;
- target unit size;
- prior pair/co-membership exposures inside generated rounds;
- explicit attendee opt-outs or host overrides.

Behavior:

- prefer new compatible pairs/groups before repeats;
- keep sit-outs/breaks fair when counts are odd or capacity is constrained;
- stop or mark relaxations when requested rotations exceed feasible unique
  pairings;
- support host-requested repeats later as explicit overrides, not silent engine
  drift.

Acceptance:

- Rotation outputs include requested versus generated round counts and repeat
  counts.
- Repeated pair/co-membership is zero when enough alternatives exist.

### 5D - Activity Attributes As Primitive Inputs

Use when the product has privacy-safe attributes that genuinely matter to the
assignment, regardless of the event label.

Inputs:

- pace/comfort band for runs and walks;
- skill/role bands for quizzes, courts, workshops, and team events;
- court/table/station capacity;
- partner/opponent repeat limits;
- host-authored locks and overrides.

Behavior:

- treat these as weighted constraints in the same engine;
- preserve social opportunity as a secondary constraint where appropriate;
- surface missing data and relaxed constraints to the host;
- keep defaults lightweight so setup does not become heavy.

Acceptance:

- A fast runner is not placed in a beginner pace group unless required by cohort
  safety or insufficient data.
- Strong/experienced participants are distributed across teams when that
  attribute is present.
- Attendee copy can say table, team, court, partner, or pace group because the
  topology/slot metadata says so, not because the optimizer branched on format.

### 5E - Rich Slot Metadata

Add output metadata for richer activities without fragmenting the optimizer:

- table/course labels;
- court/station labels;
- partner/opponent assignments;
- sit-out slots and fairness counts;
- "why this grouping" summaries for host trust.

### 5F - Host UI And Override Model

Status: completed 2026-06-04.

- Add setup controls for relevant primitive constraints only when the selected
  event defaults make them useful.
- Keep simple defaults for fast host setup.
- Show "why this grouping" summaries to build host trust.
- Preserve current host override sheets, but add validation for new constraints.

## Milestone 6 - Reporting And Website Proof

Priority: P1 after backend/UI truth exists.

Status: completed 2026-06-04.

Goal: Sales materials should use real screenshots and truthful metrics from demo
fixtures.

Implementation:

- Add seed scenarios covering:
  - invite-link conversion;
  - waitlist offers;
  - caught-someone rate;
  - table seating;
  - team balancing;
  - court rotations;
  - pace pods.
- Regenerate marketing screenshots after the product UI exists.
- Restore the stronger marketing claims that were temporarily softened in the WIP
  host page.

Acceptance:

- Every host-page claim has a screenshot, fixture, or production-data source.
- The website does not need caveats for core claims.

Completion note:

- The host demo scenario now carries sales-grade scorecard funnel metrics plus a
  `proofCoverage` ledger for invite-link conversion, waitlist offers,
  aggregate private-interest outcomes, and Event Success primitive coverage.
  The scenario catalog validates proof coverage so these claims do not drift as
  unchecked JSON.
- The host page now explains the complete host loop: booking/admission controls,
  live Event Success modules, private post-event catching, aggregate funnel
  reporting, and the evidence path from invite opens to chats. It also removes
  the broad "room" metaphor in favor of concrete events, formats, attendance,
  and follow-up.
- Marketing capture captions, refreshed PNG assets, and the generated
  website/design manifests now point at deterministic app-sourced setup,
  live-console, and post-event report screenshots. Host capture widget tests
  pass for all three host slots.
- Verification passed: host marketing screenshot regeneration; website
  typecheck/build; marketing media sync check; app screenshot export check;
  scenario proof-coverage tests; seed schema tests; focused Flutter capture
  analysis; focused host capture widget tests; full
  `./tool/check_data_contract.sh`; and `git diff --check`.

## Implementation Order

1. Milestone 0: scorecard freshness. Completed 2026-06-04.
2. Milestone 5A: assignment-engine interface and engine proof tests. Completed
   2026-06-04.
3. Milestone 5B-5F: richer primitive constraints, one capability at a time.
   Completed 2026-06-04.
4. Milestone 1: catch metrics in scorecard/report. Completed 2026-06-04.
5. Milestone 3: waitlist offers. Completed 2026-06-04.
6. Milestone 2: invite-link attribution. Completed 2026-06-04.
7. Milestone 4: unified host funnel metrics. Completed 2026-06-04.
8. Milestone 6: demo fixtures, screenshots, and restored marketing copy.
   Completed 2026-06-04.

The ordering starts with freshness because it is the smallest correctness bug,
then moves immediately to the highest-priority Event Success assignment engine.

## Deferred Product Decisions

- Invite-link click tracking before app install/open should stay off the
  sales page as a caveat. Current app/callable attribution is sufficient for
  early host reporting, and stricter web-level click tracking should remain a
  later analytics upgrade if hosts ask for pre-install click counts.
- Pace, skill, and role attributes should not block host sales work. Runs should
  be treated as pacing-subgroup use cases rather than balanced-dyad optimization
  by default. Revisit sport skill bands, quiz/team roles, and other optional
  activity attributes later when the relevant formats need stronger assignment
  inputs.
- Production or anonymized host case studies are intentionally deferred.
  Synthetic demo metrics are the right near-term proof layer for the host page
  and sales walkthroughs; revisit real-world case studies after founding hosts
  have enough repeat events and connection volume.
- Remaining low-risk "room" language in app/product copy is not part of this
  website proof pass. Treat it as a separate future copy cleanup if the brand
  fully standardizes on events, formats, attendance, and follow-up language.
- Per-link and per-offer drilldowns are nice-to-have reporting surfaces, not
  immediate sales-page requirements. Most underlying data is already recorded
  through invite links, participations, waitlist offers, payments, attendance,
  catches, matches, and chats. The main unobserved case is a pre-install/pre-app
  invite click that never reaches Catch-controlled app or web infrastructure.

## Verification Baseline

For each slice, run focused tests first, then expand only when shared contracts
or generated schema change.

Common checks:

```bash
./tool/check_data_contract.sh
flutter analyze --no-fatal-infos
cd functions && npm run build && npm run lint
git diff --check
```

## Implementation Log

- 2026-06-04: Created tracker from host-page claim audit. Implemented Milestone
  0 scorecard freshness hooks from reciprocal catch/match writes and chat message
  writes. Focused Functions build and tests passed.
- 2026-06-04: Reframed Milestone 5 from event-type-specific engines to a single
  primitive-driven assignment engine. Milestone 5A now requires explicit engine
  inputs/results, explainability metrics, and proof that event format names stay
  upstream.
- 2026-06-04: Implemented Milestone 5A backend interface. Added
  `runAssignmentEngine`, explainability metrics, direct pod/rotation generator
  usage, table-composition proof tests, and rotation-capacity tie-breaking so
  no-repeat mutual rounds stay full when feasible.
- 2026-06-04: Started Milestone 5B backend constraint layer. Added typed
  constraint categories/evaluations, host keep-together, keep-apart, and anchor
  inputs, hard keep-apart filtering, host placement/pairing score adjustments,
  and explicit satisfied/relaxed/violated constraint counts in engine
  explainability.
- 2026-06-04: Finished Milestone 5B backend group-composition scoring. Added
  low-opportunity group detection, uncovered participant counts, mutual/plausible
  dyad skew metrics, group-opportunity constraint evaluations, placement
  penalties for projected no-opportunity groups, and proof tests for avoidable
  versus unavoidable imbalance.
- 2026-06-04: Implemented Milestone 5C backend rotation-repeat policy. Added
  explicit `avoid` versus `allowWhenExhausted` repeat strategy, bounded
  `maxPairMeetings`, host-requested repeat pairs, repeat-policy explainability,
  pair-rotation repeat generation, and group-rotation repeat-aware placement
  penalties while preserving default no-repeat behavior.
- 2026-06-04: Implemented Milestone 5D backend activity primitives. Added
  privacy-safe activity attributes on assignment participants, balance and
  cluster attribute constraints, group placement costs, pair-rotation score
  adjustments, missing-data explainability, activity constraint evaluations, and
  proof tests for skill-balanced teams, pace-clustered groups, pace-clustered
  pair rotations, and missing activity data relaxations.
- 2026-06-04: Implemented Milestone 5E rich slot metadata. Assignment docs now
  carry unit kind/index/label, reason summaries, reason codes, rotation fairness
  counts, slot ids, slot unit metadata, peer counts, and separate sit-out slots
  for one-to-one rotations. Updated the Firestore assignment contract,
  regenerated Functions/Dart schema outputs, and added proof assertions in
  static group, group-rotation, pair-rotation, and odd-cohort sit-out tests.
- 2026-06-04: Started Milestone 5F host UI/model support. Flutter assignment
  models now decode/write unit metadata, reason summaries/codes, rotation
  fairness counts, and sit-out slots. Host live cards now surface assignment
  notes plus planned-break and repeated-peer badges, while existing override
  sheets keep their per-round duplicate validation.
- 2026-06-04: Finished Milestone 5F persisted host controls and backend
  consumption. `EventSuccessStructureConfig` and generated schemas now persist
  repeat strategy, max pair meetings, and balance/cluster activity attribute
  goals. Host setup exposes those controls, Functions generators map saved
  controls into optimizer rotation policy and activity constraints, and profile
  hydration derives privacy-safe pace bands only from real run-preference
  signal. Verification passed: `npm run build`, `npm run lint -- --quiet`,
  focused Node event-success/matching/schema tests, focused Flutter analysis,
  focused Flutter event-success tests, `git diff --check`, and the full
  `./tool/check_data_contract.sh` gate.
- 2026-06-04: Finished Milestone 1 host-visible catch metrics. Scorecards now
  carry privacy-safe catch aggregates (`catchSentCount`,
  `attendeesWhoCaughtSomeone`, `catchRecipientCount`, `catchRate`), rebuild
  those aggregates from attended like decisions while excluding blocked and
  non-attended edges, refresh on non-blocked like creates, and show "caught
  someone" in host report/lab/demo surfaces without exposing target identities.
  Updated scorecard contracts, generated schema bindings, demo seed fixtures,
  and host-report tests. Verification passed: Functions build/lint, targeted
  Node tests, focused Flutter analysis/tests, manual-QA render smoke,
  `git diff --check`, and full `./tool/check_data_contract.sh`.
- 2026-06-04: Finished Milestone 3 waitlist movement and offers. Added the
  `eventWaitlistOffers/{eventId_uid}` contract, participation offer mirrors,
  callable payloads, notification types, Firestore metadata/rules, and generated
  Functions/Dart bindings. Implemented host callables for creating offers,
  attendee callables for accepting/declining, scheduled expiry cleanup, reserved
  capacity checks across free signup, shared signup, Razorpay, and Stripe, free
  cancellation auto-promotion as accepted offers, and waitlist-offer rate
  limits. Host Manage setup/live now supports row-level `Offer` plus `Offer next
  N`, active/accepted/expired offer badges, and report/ops export offer-state
  visibility. Attendee event detail now shows active offers with expiry copy,
  accept, paid payment handoff, and decline. Verification passed: Functions
  lint/build, targeted Node waitlist/signup/payment tests, focused Flutter
  analysis/tests for repository/controller/detail/attendance, `git diff
  --check`, and full `./tool/check_data_contract.sh`.
- 2026-06-04: Finished Milestone 2 invite-link performance. Added
  `eventInviteLinks/{linkId}`, create/disable/open callables, Firestore rules,
  attribution fields on participations and payment callables, app deep-link
  preservation, host named-link controls, ops/report CSV attribution columns,
  and per-link connection counters rebuilt from canonical catches, matches, and
  messages. Verification passed: focused Flutter analysis/tests for event,
  booking, share, payment, and host report export paths; Functions build/lint;
  and focused Node signup, waitlist, attendance, payment, scorecard, swipe, and
  message tests.
- 2026-06-04: Finished Milestone 4 host funnel metrics. Scorecards now embed a
  `funnel` object covering invite opens, demand, requests, waitlist movement,
  payment state, bookings, attendance, no-shows, catches, matches, chats, and
  repeat attendees. Added freshness triggers for participation, payment,
  waitlist-offer, and invite-link writes, host report funnel UI, and
  funnel-aware coaching. Verification passed: Functions build/lint, focused
  backend funnel/payment/event tests, focused Flutter analysis/tests for Event
  Success report surfaces, and `git diff --check`.
- 2026-06-04: Finished Milestone 6 reporting and website proof. Added host demo
  funnel fixture values and proof-coverage validation, regenerated host
  marketing screenshots and website/design manifests, revised the host website
  to explain the booking to facilitation to matching to reporting loop with
  concrete evidence, and removed the broad "room" framing from the marketing
  copy. Verification passed: website build, marketing media checks,
  scenario/seed tests, focused Flutter host capture analysis/tests, full
  `./tool/check_data_contract.sh`, and `git diff --check`.

## Improvement Candidates

- Event Success assignment code is now large enough that the next substantial
  optimizer slice should consider extracting group-composition helpers into a
  dedicated `assignmentComposition` module once 5C rotation policy is in place.
- Add exhaustive small-cohort optimizer tests before introducing pace/skill/court
  attributes, because greedy placement can hide edge cases until constraints
  combine.
- Consolidate the durable parts of this tracker back into `docs/event_success.md`
  after Milestone 5C/5D stabilize, so the long-running tracker does not become a
  stale parallel source of truth.
- Group-rotation repeat caps are currently soft placement penalties rather than
  a full backtracking guarantee. If hosts need strict no-repeat guarantees for
  complex table/team rotations, add a small-cohort search/repair pass before UI
  launch.
- Skill and role assignment goals now persist and feed the backend, but current
  attendee profiles do not yet provide `skillBand` or `roleBand`. Add a
  privacy-safe source of truth from event questions, profile fields, or host
  setup before marketing claims imply those attributes are populated today.
- Pace assignment currently derives `paceBand` only from real run-preference
  signal and treats default running values as missing. Decide whether non-run
  events should hide pace goals or collect activity-specific pace/comfort
  answers before using pace in sales screenshots.
- Add a privacy/product review for which activity attributes are safe to use in
  assignment explanations. Hosts should see useful aggregate reasons without
  exposing sensitive attendee-level answers.
- Activity cluster scoring is greedy and weighted. Add a small-cohort
  search/repair pass if hosts need strict "never mix pace bands" guarantees for
  runs, workshops, or court rotations.
- Group rotation fairness now exposes repeat co-membership, and one existing
  table-rotation fixture reports one repeated peer. This is useful evidence for
  hosts, but it also reinforces that strict no-repeat group rotations need the
  search/repair pass noted above.
- Reason summaries are intentionally compact and generic. Before marketing
  screenshots, tune them with product copy so host-facing explanations sound
  confident without revealing sensitive attendee attributes.
- Engine explainability is available in the backend result, but generators do
  not persist a host-readable explainability snapshot yet. Add a server-owned
  generation audit or assignment summary doc before claiming hosts can inspect
  all relaxed constraints and missing-data reasons after generation.
- Host override sheets still validate safety basics like duplicate attendees and
  blocked pairs, but they do not explain when a manual override breaks balance
  or cluster goals. Add override warnings after Milestone 1 if hosts start using
  primitive goals heavily.
- Catch aggregates are rebuilt by querying each attended user's outgoing
  decisions. This is correct and simple for current event sizes; add a
  materialized event-level aggregate or collection-group query plan before very
  large events.
- Catch scorecards refresh on like creates, match updates, messages, and
  feedback. If profile decisions later become editable/deletable, add an
  `onDocumentWritten` refresh path for decision updates/deletes as well.
- `catchRate` uses the event scorecard's checked-in count as denominator. If
  attendance repair can lag behind participation docs, add an internal
  attended-count cross-check before using the number in external proof.
- Full manual-QA test file still has an unrelated questionnaire-state failure in
  `manual QA saves attendee questionnaire through fixture store`; the render
  smoke that loads the updated host scorecard fixture passes.
- Waitlist offer creation returns per-user skipped reasons to Flutter, but Host
  Manage currently uses only mutation success/error state. Surface partial
  outcomes in a snackbar or result sheet before hosts use bulk offers heavily.
- The `Offer next N` UI caps by open slots and skips active/accepted offers, but
  detailed cohort/rule warnings are still backend-only. Add pre-send warnings
  using projected cohort availability if hosts need more trust before tapping.
- Event cancellation currently cancels the event and notifies participants; add
  an explicit sweep that marks active waitlist offers `cancelled` so offer state
  is terminal without waiting for expiry.
- Offer expiry runs on scheduled cleanup and attendee CTA copy shows the expiry
  time, but visible countdown refresh is not timer-driven. Add a local countdown
  ticker if the offer CTA becomes a primary conversion screen.
- `autoPromotion` and `ratioBalancing` are modeled as offer sources, while this
  slice uses `host` and `cancellation`. Wire ratio-aware automatic offers only
  after hosts can inspect/override those moves.
- Ops CSV now exports offer states and timestamps, and the host report now shows
  funnel metrics. Add per-offer or per-cohort drilldowns only if hosts need to
  debug exactly which waitlist moves converted.
- Invite link ids currently double as share tokens, with a stored token hash for
  validation. If public attribution spoofing becomes a real abuse concern,
  split copyable public tokens from document ids before broad launch.
- Disabled invite links stop new attribution at open/booking time, but payment
  metadata captured before disable can still preserve historical attribution.
  Keep this behavior documented so hosts understand disabled links do not rewrite
  history.
- Invite link open recording is intentionally best-effort and invisible to the
  attendee. Do not highlight this as a sales-page deficiency. Add web-edge or
  redirect-style click tracking only if hosts later need pre-install click
  counts that app/callable delivery cannot observe.
- Host Manage now shows compact per-link counters in Private Access. Milestone 4
  now turns those counters into host report funnel metrics; the next UI pass
  can add a per-link trend/detail view if hosts ask which channel to double down
  on. This is mostly a UI/reporting pass over data already recorded, excluding
  pre-install clicks.
- Razorpay checkout-start counts currently rely on canonical payment/session
  documents. If hosts need a stricter "checkout opened but no payment document"
  metric, add an explicit order-start analytics document before broad paid-event
  reporting.
- Repeat-attendee counts are rebuilt by querying prior participations for the
  club and filtering the current attendee set. This is acceptable for current
  club sizes; add a materialized club-attendance index before very large hosts.
- Funnel refreshes are idempotent, but payment writes and invite-link paid-count
  writes can both refresh the same scorecard. Keep this as simple correctness
  until refresh volume justifies a coalescing queue.
- Host-page evidence metrics are demo-fixture examples, not production
  benchmarks. Keep using synthetic demo metrics for near-term sales materials
  and avoid presenting them as real-world customer outcomes.
- Synthetic connection metrics should not assume one match per attendee. Match
  counts are relationship edges, so mutual matches can exceed checked-in guest
  count when attendees catch multiple people.
- `salesDemo.proofCoverage` validates that claims have evidence entries, but it
  does not prove every claim is visible in the first viewport of each screenshot.
  Add a screenshot OCR/DOM metadata check if the marketing process starts
  depending on exact on-image text.
- The website now avoids the broad "room" metaphor, but older product/app and
  demo descriptions still use it in a few low-risk places. Clean those
  separately in a future app-copy pass if the brand direction fully moves to
  "events/formats/attendance" language.
- Host screenshots are deterministic synthetic sales-demo states. Keep
  production-data-backed screenshots or anonymized case studies deferred until
  after founding host usage creates enough evidence.
- Run pacing groups are a different assignment primitive from dating dyad
  optimization. Keep pace-band work deferred and model it as pace-group
  formation unless a future run format explicitly needs balanced romantic dyads.
- Sport skill bands, quiz/team roles, and other non-run activity attributes
  should stay optional future inputs. Add them only when a format has a clear
  host-facing reason, not as a generic onboarding burden.

## Next Recommended Slice

1. Use the completed host page and refreshed screenshots for host outreach
   review.
2. Keep pre-install invite-click tracking, run pace grouping, and skill/role
   attributes on the deferred product list; do not surface them as sales-page
   uncertainty during early outreach.
3. Keep per-link and per-offer drilldowns deferred unless host conversations
   show that channel-level or waitlist-movement diagnosis is needed immediately.
4. Keep the remaining improvement candidates visible, but do not block the host
   sales story on them unless the first buyer conversations demand that extra
   proof.
