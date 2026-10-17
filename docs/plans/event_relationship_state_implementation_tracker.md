---
doc_id: event_relationship_state_implementation_tracker
version: 1.0.0
updated: 2026-10-17
owner: data_contracts
status: active
---

# Event relationships, state integrity, and read architecture implementation tracker

## Purpose and scope

Make Catch's account, organizer, CRM, forms, applications, membership, event,
registration, payment, attendance, runtime, and review models consistent across
the Host app, consumer app, and website. Make invalid states difficult to
construct and impossible to commit through supported commands. Make page reads
bounded, fast, privacy-safe, and measurable in database cost.

This is the user-requested implementation backlog, not a second architecture
authority or a generated audit ledger. Durable decisions belong in
[data contracts](../data_contracts.md),
[backend operations](../backend_operation_catalog.md),
[app architecture](../app_architecture.md),
[web architecture](../web_surface_architecture.md), and the owning schemas/tests.
Resolve or remove completed items after their decisions and enforcement reach
those owners. Git/PR/CI retain implementation history; do not append run logs or
create another evidence registry.

**Authorization for this pass:** research and write this tracker. Product code,
schemas, data, rules, provider configuration, and production deployment are not
changed by this document. The implementation scope explicitly includes changing
document boundaries, collection layouts, DTOs, composed domain classes, union
types, generators, repositories, providers, and their migrations when justified.
These changes are not automatically out of scope because they exceed the earlier
event-screen work.

**Baseline inspected:** fetched main
`7cf00724c30a02c45b7542883c3ec6370578aa6e`, 2026-10-17.
Findings below are source observations, not claims about deployed rules, live
records, billing, provider activation, or load-test results. Reverify each affected
unit against implementation main before changing it.

**Non-goals:** a new event-page visual redesign; a compulsory database migration;
unrelated feature rewrites; a universal graph abstraction; full event sourcing;
a replacement governance/evidence layer. Neighboring architecture leaks discovered
during this work must be triaged, but may be delivered in a separate bounded PR.
Existing runtime/itinerary plans keep their ownership.

## How to use this tracker

- Every `[ ]` is outstanding work, including verification work. This document
  does not mark a feature implemented merely because a schema or prior PR exists.
- **P0**: authority, security, money, identity, capacity, or contradictory-state
  correctness. **P1**: journey consistency, typing, architecture, and material
  read-cost/latency work. **P2**: measured follow-on optimization or consolidation.
- **F**: confirmed source observation. **D**: agreed direction or recommended
  product/architecture decision to encode. **V**: question requiring measurement
  or deeper implementation tracing; not an asserted defect.
- Item IDs are stable. Each item's **Done** clause is its acceptance condition.
  Phase owner/dependencies and shared proof requirements apply to all its items.
- One PR should close a coherent subset with its migration and tests. Do not
  accumulate all phases into a single unreviewable change.
- Existing protections are constraints to preserve. An implementation may close
  an item by proving the existing behavior already satisfies it; do not rewrite
  functioning code for checkbox uniformity.
- A checkbox can close after its code, tests, owner docs, and required migration
  proof are complete. “Source merged”, “deployed”, “provider enabled”, and “live
  journey accepted” remain separate release facts.

## Agreed baseline and decisions to carry forward

The user accepted the prior business-model direction. This table makes the
implementation interpretation explicit; conditional branches below still require
their named decision.

| Topic | Baseline for implementation | Remaining choice or qualification |
|---|---|---|
| Identity | One verified Catch identity can use web guest tools without a full consumer/dating profile. | Exact minimal profile/display-name requirements per action; account linking and recovery safeguards. |
| Organizer relationships | Follow, community membership, and team permissions are different relationships. | Follow notification defaults and membership expiry only if product requires them. |
| CRM | Organizer-private contact facts remain distinct from global account/profile data. | Approval may explicitly compose contact creation; do not erase current approved-contact behavior accidentally. |
| Forms | Published versions and submitted answer snapshots retain their meaning. Reuse answers only with explicit review/sharing. | Reapplication, edits after submission, and form-version changes need explicit rules. |
| Approval | Eligibility approval is not inventory reservation or payment. | Replace native free-event auto-booking with explicit guest claim by default; retain any desired host auto-enrolment as a named, disclosed command. |
| Membership | Explicit grant/revoke action; optional combined “approve and grant membership” command. | Generic organizer-target approval may support membership; event approval must not grant it accidentally. |
| Review bypass | Active membership skips review only when the event policy says so. | Never bypass capacity, invitation, price, age, required answers, or other applicable restrictions. |
| Waitlists | Application deferral and capacity waitlisting are distinct. | Queue ordering, priority exceptions, re-entry, and offer duration need specific policy values. |
| Offers | A normal invitation is not a seat hold; a reservation-backed promotion offer has explicit inventory and expiry. | Decide which offer types reserve seats; do not give every marketing invitation a hold. |
| Booking | Free and paid registrations converge on one domain meaning of confirmation. | Physical document layout is chosen after authority/read analysis, not assumed to be one giant collection. |
| Revocation | Routine membership revocation does not retroactively erase a confirmed booking. | Safety/host cancellation is a distinct authorized action with explicit consequences. |
| Cancellation | Registration cancellation and financial refund settlement are independent. | Cash-only supported promises until an actual credit ledger and redemption lifecycle exist. |
| Attendance | No check-in is not sufficient evidence of a no-show. | Closeout timing, late attendance correction, and early check-in rules. |
| Runtime | Event detail contains the entry point and lifecycle summary; dedicated runtime owns complex live interaction. | Access gates and the minimal shell shown before/after runtime. |
| Notifications | WhatsApp with SMS fallback, plus independent email delivery, through swappable transport seams. | Delivery requires valid channel permission/configuration; delivery failure cannot undo approval or booking. |
| Database | Keep Firestore while measuring concrete workload limitations. | Compare a coherent PostgreSQL subsystem only if measured complexity/cost warrants it. |

## Source-backed findings and reusable foundations

Links are to authored source. Read the whole affected function/type and its
callers before implementing; search locations alone are not proof of behavior.

| ID | Kind | Observation and implication | Source |
|---|---|---|---|
| F01 | F / preserve | Follow is already an organizer/account edge with active/inactive state and timestamps. Do not embed all follower IDs in the organizer. | [follow schema](../../contracts/firestore/organizer_follows.schema.json) |
| F02 | F / preserve | Community membership and its decisions are distinct server-owned records; current rules deny direct access. A cheap self-read needs a safe projection or explicitly revised rule boundary, not access to decision evidence. | [membership schema](../../contracts/firestore/organizer_community_memberships.schema.json), [authority](../../functions/src/memberships/communityMembershipAuthority.ts), [rules](../../firestore.rules) |
| F03 | F / preserve | Event policies are embedded composed values. Serialization writes version/admission/pricing/cancellation/settlement; a Dart class does not require a collection. | [event schema](../../contracts/firestore/events.schema.json), [bundle](../../lib/event_policies/domain/event_policy/bundle.dart) |
| F04 | F / rectify | Native join approval checks availability and automatically books a free request after its review transaction; paid approval leaves the participation waitlisted. This differs from an approval-only eligibility decision. | [native review command](../../functions/src/events/decideEventJoinRequest.ts) |
| F05 | F / rectify | Application approval creates/links a private CRM contact. The data-contract owner also contains a later contradictory statement that approval does not create a customer. | [reviewOrganizerApplicationHandler](../../functions/src/organizers/organizerApplications.ts), [application intake owner](../data_contracts.md#organizer-application-intake) |
| F06 | F / reconcile | Consumer participation requires a UID; operational attendees include imports/manual/web OTP identities. These intentionally differ and must not be merged blindly. Web OTP registration need not create a consumer profile or participation. | [participation schema](../../contracts/firestore/event_participations.schema.json), [attendee schema](../../contracts/firestore/event_attendees.schema.json), [roster owner](../data_contracts.md#standalone-host-operational-attendees) |
| F07 | F / rectify | Following requires a complete consumer profile. This conflicts with the intended minimal web-account journey. | [assertCanFollow](../../functions/src/organizers/follows.ts) |
| F08 | F / rectify | Event review eligibility requires a user profile and an attended native participation. A checked-in operational web attendee alone does not satisfy that path. | [assertCanWriteReview](../../functions/src/reviews/mutateReview.ts) |
| F09 | F / reconcile | Generic forms/responses coexist with older application forms/responses; applications are review projections. Preserve source provenance while selecting the forward authority. | [form response schema](../../contracts/firestore/organizer_form_responses.schema.json), [application schema](../../contracts/firestore/organizer_applications.schema.json), [application access](../../functions/src/organizers/organizerApplicationAccess.ts) |
| F10 | F / preserve and extend | Native viewer source already separates several facts and uses shared policy/seat checks; Dart parsing already rejects some route/price/allowed contradictions. The broader model still uses independent fields and repeated enum declarations. | [viewer source](../../functions/src/events/eventViewerStateSource.ts), [Dart viewer model](../../lib/events/domain/event_viewer_state.dart), [response contract](../../contracts/callable_responses/get_event_viewer_state_response.schema.json) |
| F11 | F / cost candidate | Native viewer starts with five point reads and may read up to 101 peer participations, blocking relationships, offer holds, membership evidence, schedule and seat authority. One callable is not one document read. More than 100 peers closes future booking in this source. | [native viewer source](../../functions/src/events/eventViewerStateSource.ts) |
| F12 | F / cost candidate | Guest viewer fans out across attendee, public payment, application, offer-recipient, form, native participation and offer-payment sources, with further authority reads. Its queries include up to 21 recipient grants; ambiguous/oversized results fail closed. | [guest viewer source](../../functions/src/events/guestEventViewerState.ts) |
| F13 | F / cost candidate | Signed-in web guest status uses a 15-second refetch interval, focus refresh, and a 30-second server expiry. Measure actual visible/hidden-tab behavior and overlapping requests before replacing it. | [guest controller](../../website/src/features/events/useGuestEventController.ts), [guest source](../../functions/src/events/guestEventViewerState.ts) |
| F14 | F / cost candidate | Public web feed subscribes to published events with limit 401, then groups rows into organizer listings. It is bounded but broad; inspect route ownership and overflow handling before replacing it with scoped reads. | [subscribePublicCatchEvents](../../website/src/firebase.ts), [listing controller](../../website/src/features/organizers/usePublicEventListingsController.ts) |
| F15 | F / architecture debt | Host timeline constructs a Firestore-backed repository in presentation and exposes DocumentSnapshot cursors. Explore's presentation state also exposes SDK cursors. This is SDK/construction leakage, not evidence that these controllers issue raw database writes. | [Host timeline](../../lib/hosts/events/presentation/host_events_timeline_controller.dart), [Explore window](../../lib/explore/presentation/explore_discovery_window_controller.dart) |
| F16 | F / preserve | Host summary reader already performs rules-authorized SDK server reads, scope-bound cursors and account-change checks. Summary rules deny writes. Concurrent directory-marker reads are shared; there is deliberately no persistent private-data cache. | [Host reader](../../lib/hosts/data/read_models/host_summary_reader.dart), [rules](../../firestore.rules) |
| F17 | F / reconcile | Shared policy exposes a platform-credit remedy, while shared checkout cancellation promises cash-only terms. Do not display unsupported credits as a delivered refund feature. | [policy](../../functions/src/events/eventPolicy.ts), [checkout cancellation](../../functions/src/payments/eventCheckout/eventCancellationPolicy.ts) |
| F18 | F / preserve | Approval notifications already have separate delivery lanes and a TransactionalEmailProvider seam with a Resend implementation. This is not evidence of live credentials or successful delivery. | [notification model](../../functions/src/events/approvalNotifications/model.ts), [transports](../../functions/src/events/approvalNotifications/transports.ts) |
| F19 | F / coverage limitation | Text scan of lib presentation/controller paths found the SDK cases in F15, not obvious raw collection reads/writes in the event/organizer/Host UI. CatchSection.collection matches are UI false positives; core Firebase provider construction is legitimate. A full alias/call-graph audit remains open. | [architecture owner](../app_architecture.md#dependency-direction), [dependency scanner](../../tool/architecture/check_dependency_direction.mjs) |
| F20 | F / shared dependency | Existing run-of-show/movement and runtime-parity plans already own itinerary/live movement design. Their historical observations must be reverified, not copied as current defects. | [movement plan](event_run_of_show_and_movement_runtime_spec.md), [runtime variable plan](event_success_variable_model_and_runtime_parity_spec.md) |

## Delivery order and ownership

Owners below are implementation responsibilities, not assignments to named people.

| Phase | Priority | Accountable role | Depends on | Reviewable result |
|---|---|---|---|---|
| A: authority and workload baseline | P0/P1 | Domain/backend lead with app/web leads | None | Current ownership map, agreed transition contract, reproducible read traces |
| B: contracts and types | P0 | Contracts lead | A authority decisions | One end-to-end typed reference slice and safe compatibility adapter |
| C: identity, forms, relationships | P0/P1 | Identity/Forms lead | A, B conventions | Explicit membership/review/CRM boundaries across entry paths |
| D: admission, inventory, money | P0 | Events/Payments lead | A, B; C identity | Retry-safe registration and payment transitions |
| E: read architecture and client boundaries | P1 | App/Web/Data leads | A measurement; B/C/D authority | Rules-tested SDK projections and measured cost/latency improvements |
| F: attendance, runtime, reviews, messages | P0/P1 | Event operations lead | C/D authority | Complete pre/live/post-event lifecycle |
| G: migration and rollout | P0 | Release/backend lead | Each affected slice; not postponed until all phases finish | Safe production-compatible cutover and rollback |
| H: final parity and database decision | P1/P2 | Integration lead | All relevant slices | Proven journeys and workload-based storage decision |

Migration design begins with the first schema change. Phase G is a per-slice gate,
not permission to defer migration safety until the end.

## A. Authority, cardinality, and workload baseline

Proof: source-to-command tracing, synthetic fixtures, query/rules instrumentation.
No production writes. Durable outputs go into existing owner documents.

- [ ] **A01 — P0 / D: Assign one owner to each fact.** Cover identity, field provenance, follow, membership, team access, response, review, invitation, queue, hold, registration, payment, attendance, runtime eligibility, review publication and notification permission. **Done:** each has a canonical record, authorized writer, cardinality, read audience, lifetime, and repair owner.
- [ ] **A02 — P0 / F: Reconcile registration/roster authority (F06).** Trace native, web OTP, free, paid, offer, host-manual and provider-import paths. **Done:** an explicit mapping explains what proves registration, what is operational attendance, and how linked records converge without duplicate seats.
- [ ] **A03 — P0 / D: Define relationship cardinality.** Specify one current follow and community membership per organizer/account, application attempts per target, registrations per person/event, ticket-level identities, and multiple payment attempts per registration. **Done:** deterministic IDs or transactional uniqueness enforce each rule without treating a shared phone/email as a unique human.
- [ ] **A04 — P0 / D: Specify every command transition.** Record actor, from-state, trigger, guard, target state, atomic writes, idempotency identity, side effects, error, and recovery. Include automatic expiry and operator correction commands. **Done:** transition tables cover all reachable variants, not only the happy path.
- [ ] **A05 — P0 / F: Resolve native versus form approval (F04/F05).** Preserve intentional CRM conversion while separating eligibility and seat claim. **Done:** one documented product rule applies to free/paid native/web entry, with any auto-enrolment named explicitly and tested.
- [ ] **A06 — P1 / F: Correct contradictory owner prose (F05).** Reconcile the two approval/contact descriptions and stale journey restrictions against actual handlers. **Done:** owner docs, command labels and tests describe the same behavior; legacy notes are clearly historical.
- [ ] **A07 — P1 / V: Inventory physical data ownership.** For relevant collections list entity/edge/value/history/projection/receipt, ID, references, embedded values, writer, queries, indexes and deletion rules. **Done:** existing contracts carry durable metadata; a disposable generated inventory identifies uncovered paths without creating another registry.
- [ ] **A08 — P1 / V: Baseline page reads.** Trace every page in the workload table below, including backend/rule reads and listener reconnects. **Done:** synthetic reproducible traces report initial, repeat, idle and mutation-refresh reads, writes, bytes, latency and retries separately.
- [ ] **A09 — P1 / V: Inspect live prerequisites when authorized.** Establish deployed database edition/location, Functions region/runtime, rules/index revision, gates and relevant collection size distributions. **Done:** no production-cost or scale claim rests only on checked-in configuration; unknowns remain explicit until measured.
- [ ] **A10 — P0 / D: Separate truth from projections.** Classify counters, current CTA, summaries and policy-derived labels. **Done:** each projection declares source/version/freshness/repair semantics and cannot authorize money, a seat or private access by itself.

## B. Contracts, DTOs, composition, and impossible states

Proof: generated-output parity, schema fixtures, codec tests, compiler exhaustiveness,
transition tests and known-invalid examples. Reuse existing generators/checks.

- [ ] **B01 — P0 / D: Make contracts the shape authority.** Consolidate repeated IDs, money, timestamps, policy components, status values and relationship references through shared schema definitions. **Done:** Dart/TS/browser/server projections agree, and generated output is reproducible without hand edits.
- [ ] **B02 — P0 / D: Separate persisted/read/create/patch/command shapes.** A create DTO must not accept server-owned status, financial evidence, actor identity or derived counts. **Done:** allowlists and negative tests reject forged fields while legitimate response projections can combine multiple records.
- [ ] **B03 — P0 / D: Distinguish absent, null, empty, false and zero.** Include patch omit versus clear, draft versus published validity and old-document compatibility. **Done:** round-trip tests and create/edit/detail fixtures cover each distinction; optional content is neither required nor rendered as fabricated data.
- [ ] **B04 — P0 / D: Replace contradictory boolean bundles with tagged variants.** Candidate examples: booking eligibility, price mode, admission route, refundable entitlement, mutation outcome and review state. **Done:** discriminated unions/sealed classes require the fields appropriate to each variant and reject incompatible combinations.
- [ ] **B05 — P0 / D: Enforce transitions beyond type validity.** Types cannot stop concurrent approval/revocation or payment/cancellation races. **Done:** backend transition guards enforce allowed source states and expected revisions in the transaction that commits the facts.
- [ ] **B06 — P1 / F: Generate repeated viewer enums/shapes (F10).** Retain useful domain getters and strict boundary validation; avoid hand-maintained copies of schema enumerations. **Done:** adding a variant makes affected Dart/TS mappings fail compilation or a deterministic coverage test until handled.
- [ ] **B07 — P0 / D: Separate unknown from negative.** Model not-loaded/unavailable/malformed/stale distinctly from no membership, declined application, no payment or no attendance. **Done:** missing evidence fails sensitive operations closed without fabricating a negative historical fact.
- [ ] **B08 — P1 / D: Derive display state from facts once.** Derive hasAdmission, remaining balance, booking CTA, policy labels and review prompts through named pure selectors. **Done:** no separately writable flags contradict the facts; stored projections, if retained for cost, have explicit maintenance rules.
- [ ] **B09 — P0 / D: Treat time-dependent state carefully.** Expiry and event phase use a trusted clock/boundary, timezone-aware display and explicit closeout where needed. **Done:** passing a deadline changes eligibility even if a cleanup worker is late; missing end time does not invent completion.
- [ ] **B10 — P1 / D: Compose domain values without proliferating documents.** Keep bounded policy/value objects embedded when lifecycle/access align; separate independently growing/private/hot records. **Done:** each proposed split/merge records its read/write/privacy tradeoff and avoids subclass hierarchies that encode every status combination.
- [ ] **B11 — P0 / D: Preserve historical terms.** Snapshot/version accepted price, currency, refund terms, form version and approval basis as appropriate. **Done:** changing organizer defaults or event configuration does not silently rewrite existing financial or consent commitments.
- [ ] **B12 — P0 / D: Type identifiers, currency and units.** Prevent event/organizer/contact IDs and paise/other minor units from being interchanged; validate integer ranges and currency. **Done:** wrong-scope IDs, non-finite numbers, mixed currencies and fractional minor units fail at the boundary.
- [ ] **B13 — P1 / D: Confine raw maps to codecs and genuinely dynamic answers.** Use typed adapters and catalog-driven answer variants, not raw map mutation in controllers. **Done:** repositories return typed models and dynamic form answers retain question/version/type validation.
- [ ] **B14 — P0 / D: Define forward/legacy decoding policy.** Unknown enum/schema versions cannot silently map to an allowed action. **Done:** old supported documents normalize once; unsupported new variants render safe unavailable/read-only states and preserve recoverability.
- [ ] **B15 — P1 / D: Cover exhaustive switches across surfaces.** Use Dart sealed/enum exhaustiveness and TS never checks; avoid default branches that hide new known variants. **Done:** domain, CTA, localization, analytics and fixtures are covered, while external unknown input still gets runtime validation.
- [ ] **B16 — P0 / D: Enforce cross-field invariants in schemas and constructors.** Examples: active hold requires expiry/identity; successful refund requires settlement evidence; an allowed checkout requires a valid quote. **Done:** schema-valid but semantically contradictory records are rejected by a named validator, not only by a widget.

## C. Identity, relationships, forms, approval, and CRM

Proof: cross-account/organizer denial tests, current-source review tests, schema
fixtures, account-link races and consent/withdrawal scenarios.

- [ ] **C01 — P1 / F: Permit minimal verified web identity where appropriate (F07/F08).** Specify action-specific identity readiness instead of reusing full consumer onboarding. **Done:** following, approved registration and eligible reviewing work without generating a dating/public profile.
- [ ] **C02 — P0 / D: Make account/contact/attendee linking explicit.** Use verified ownership and provenance; retain imported attendees without fabricated UIDs. **Done:** recycled phone numbers, shared phones, changed emails and account merges cannot silently transfer membership, tickets or private answers.
- [ ] **C03 — P1 / D: Keep follow independent of membership and team role.** Preserve active/inactive follow and channel settings with idempotent toggles. **Done:** following does not grant admission/team access, joining a community does not silently subscribe marketing, and retry does not double-count.
- [ ] **C04 — P0 / D: Keep membership commands explicit.** Support grant/revoke and a clearly named combined approval/grant operation where authorized. **Done:** exact organizer/UID/source/revision is checked; an event application cannot accidentally grant organizer-wide membership.
- [ ] **C05 — P0 / D: Define membership bypass and revocation.** Bypass review only under event policy; recheck before new admission; preserve existing booking unless separately cancelled. **Done:** revoked, stale, unknown and conflicting membership evidence cannot bypass constraints.
- [ ] **C06 — P1 / F: Choose forward forms authority (F09).** Generic form versions/responses are candidates; preserve imported/provider legacy provenance through adapters. **Done:** one current write path per concept and an explicit migration/retirement boundary; no bulk relabeling of history.
- [ ] **C07 — P0 / D: Separate response lifecycle from application review.** A response can be submitted/withdrawn while its review has its own decision history. **Done:** withdrawal makes review actions unavailable and follows the documented post-booking policy without silently cancelling a valid registration.
- [ ] **C08 — P0 / D: Scope application targets.** Distinguish organizer membership application from event eligibility and other supported form purposes. **Done:** target-kind unions require matching IDs and prevent one target's approval from being used for another.
- [ ] **C09 — P1 / D: Distinguish deferred review from seat waitlist.** Migrate or explicitly label application “waitlisted” semantics; do not equate it with a reserved position in an event queue. **Done:** Host/web/app show distinct statuses and promotion commands.
- [ ] **C10 — P0 / D: Define reapplication and review revision rules.** Decide resubmission after decline/withdrawal, one active attempt, approved-answer amendments and review invalidation. **Done:** old decisions cannot authorize a new material answer set or form version by accident.
- [ ] **C11 — P0 / D: Preserve reviewed answer snapshots and grants.** Autofill suggestions are participant-private; submission chooses what is shared and why. **Done:** later profile changes do not alter old submissions; withdrawal/revocation redacts views and invalidates relevant caches.
- [ ] **C12 — P0 / F: Make approval/contact conversion semantics explicit (F05).** Preserve deterministic conversion, private provenance and duplicate-review safeguards. **Done:** approval creates/links a contact only through the declared composed command; it does not grant marketing permission or payment evidence.
- [ ] **C13 — P0 / D: Protect organizer isolation.** CRM private notes, response answers, public profiles and reusable intake remain separate access scopes. **Done:** organizer A cannot infer organizer B's answers, memberships, notes or customer status through lists, cursors, errors or summaries.
- [ ] **C14 — P1 / D: Decide conflict and missing-source UX.** Handle duplicate forms, multiple conflicting offers, unavailable response versions and orphaned contacts explicitly. **Done:** no arbitrary newest/first row selection silently grants access; hosts receive a bounded repair action.

## D. Admission, inventory, booking, payments, and refunds

Proof: shared state-transition tests across every entry path, emulator
transactions, duplicate/out-of-order provider events and concurrent contention.
Provider events are external evidence, not part of a Firestore atomic transaction.

- [ ] **D01 — P0 / D: Establish one admission decision service.** Reuse canonical review, membership, invite, profile, age, schedule, safety, capacity and ratio checks across native/web/offers. **Done:** frontend selectors display decisions but cannot authorize a seat; mutations recheck current evidence.
- [ ] **D02 — P0 / F: Remove approval/capacity coupling where inappropriate (F04).** An eligible person may be approved even when full, then queued. **Done:** approval and seat allocation are distinct transitions; free registration is explicitly claimed or explicitly host-enrolled.
- [ ] **D03 — P0 / D: Normalize registration semantics across routes.** Define confirmed/cancelled and active seat identity independently from how payment or approval happened. **Done:** one person/ticket does not consume duplicate capacity through web and native paths; operational imports retain their provenance.
- [ ] **D04 — P0 / D: Model queue eligibility and ordering.** Define FIFO/priority, cohort-specific queues, fairness, re-entry, pauses and expiry. **Done:** a queue position is not approval/payment; promotions select an eligible candidate deterministically with a recorded policy basis.
- [ ] **D05 — P0 / D: Distinguish invitations from reservation-backed offers.** Bind subject, event, generation, expiry and policy/price snapshot. **Done:** ordinary offers do not reserve inventory; seat offers have explicit holds and release/reclaim behavior.
- [ ] **D06 — P0 / D: Protect capacity atomically.** Reuse canonical seat ledgers/reservations and migration fences; include group/pair/cohort holds. **Done:** last-seat races cannot oversell, duplicate callbacks cannot allocate twice, and failure cannot leak a permanent hold.
- [ ] **D07 — P0 / D: Make approval/ratio combinations explicit.** Test open/closed, manual review, member bypass, invites, fixed cohorts, ratio balancing and pair capacity in supported combinations. **Done:** every combination is supported or deliberately unavailable before payment; no unchecked client-only branch.
- [ ] **D08 — P0 / D: Define cohort/ratio policy semantics.** Specify unknown/declined-to-answer values, policy edits, existing bookings, group allocation and temporary imbalance. **Done:** no gender/cohort inference from names or private unrelated profile data; updates use approved provenance and do not silently move booked guests.
- [ ] **D09 — P0 / D: Separate payment attempt from registration.** One registration may have failed/retried/expired attempts; a form fee may not buy event admission. **Done:** cross-purpose and duplicate captures cannot confirm the wrong event or charge/allocate twice.
- [ ] **D10 — P0 / D: Converge payment adapters on shared business semantics.** Retain provider/account provenance and receipt integrity when consolidating route-specific ledgers. **Done:** native, public and offer checkout produce equivalent confirmed/refund behavior without destroying historical identifiers.
- [ ] **D11 — P0 / D: Model provider uncertainty.** Distinguish request sent/order unknown, verification pending, captured, admitted, failed and compensation required. **Done:** a browser callback, screenshot, payment pointer or imported revenue field cannot prove capture.
- [ ] **D12 — P0 / D: Recover late and duplicate captures.** Define capture-after-expiry, cancellation-during-verification, duplicate captures and provider timeout recovery. **Done:** capacity is revalidated before admission or the approved compensating refund is scheduled exactly once.
- [ ] **D13 — P0 / D: Separate cancellation entitlement from refund settlement.** Preserve who cancelled, reason, time, terms and quoted amount; refund requested/processing/failed/succeeded remain financial facts. **Done:** a cancelled registration never implies money returned, and a failed refund does not reactivate a seat.
- [ ] **D14 — P0 / F: Reconcile cash versus credit promises (F17).** Remove unsupported credit promises from eligible surfaces or implement a separately reviewed credit ledger. **Done:** app/web/Host display the same enforceable remedy and retain the terms accepted at purchase.
- [ ] **D15 — P0 / D: Define host/event cancellation and rescheduling.** Include cancellation after a guest's nonrefundable cancellation, timezone changes and materially changed venue/time. **Done:** a documented entitlement rule handles each case without silently changing historical terms or duplicating refunds.
- [ ] **D16 — P0 / D: Handle partial refunds and disputes explicitly.** If unsupported, fail closed and expose support escalation rather than coercing to a full-refund state. **Done:** financial totals reconcile to captured/refunded amounts; payment disputes do not erase attendance history.
- [ ] **D17 — P0 / D: Preserve external booking authority.** Imported tickets and external payment links remain externally sourced; manual attestation is visibly distinct from provider capture. **Done:** internal checkout/admission never claims authority over an unsupported external purchase.
- [ ] **D18 — P0 / D: Keep read methods non-mutating.** Viewer/status/quote reads must not reserve seats, create grants, send OTPs or charge. **Done:** repeated refreshes and retries produce no business mutations; any security rate-limit accounting is explicit and separately measured.

## E. Read architecture, Firestore economics, and client boundaries

Proof: rules emulator, repository/controller tests, route lifecycle tests,
synthetic query traces and load tests. Record before/after results in CI artifacts
or ignored output, not in a tracked measurement ledger.

### Workload worksheet required before choosing document layout

These are measurement requirements, not measured read budgets. Set numerical
budgets after A08 and before approving an optimization. Count initial page data,
SDK/rules reads, Functions reads, transaction retries and trigger fan-out
separately. One API request or one query can read many documents.

| Page/journey | Initial data needed | Current candidate to inspect | Required test conditions |
|---|---|---|---|
| Anonymous event detail | Published event, organizer display, public policy, media | Global published feed F14 versus event-scoped lookup/public projection | Cold/deep link, missing/unpublished event, organizer archive, 0/400/401+ published rows |
| Organizer landing | Organizer, bounded upcoming events, follow state after login | Broad feed grouped on client; summary reuse | Organizer with 0/1/100+ events; next page; follow toggle |
| Authenticated event detail | Own review/membership/registration/payment summary, allowed next action | Native F11 and guest F12/F13 | New/approved/registered/cancelled guest; 10-minute foreground session; hidden tab; account switch |
| Form load/submit/resume | Published definition, permitted prefill, own draft | Version and grant reads; answer payload size | Large bounded form, version change, revoked sharing, resume on another device |
| Host event roster | Event summary, page of attendee rows, role permissions | Per-row enrichment; full roster scans; summary reads | 0/100/1,000 rows, page forward, updates, delegated operator |
| Host application inbox | Page of redacted summaries; selected response detail | Summary directory versus private source callables | Multiple filters, withdrawal, reviewer conflict, rapid page switches |
| CRM contact detail | Contact, bounded linked activity, permitted selected responses | Joined timelines and identity resolution | Unlinked/verified/conflicted contact; many events/forms; revoked role |
| Membership directory | Page of authorized member summaries | Server-only evidence versus safe projection | Grant/revoke, stale cache, different organizer, expired access |
| Checkout/recovery/cancel | Current own attempt, policy quote, atomic seat/payment authority | Repeated full viewer calculation and ledger scans | Duplicate tabs, lost response, delayed capture, refund failure |
| Live event runtime | Own assignment, current beat/location, minimal aggregate | Full event listeners versus hot runtime projection | Quiet period, frequent updates, reconnect, attendee removed |
| Post-event/review | Verified attendance, review eligibility, own review, public aggregates | Native-only participation gate F08 | Web attendee, corrected no-show, moderated review, deleted account |

**Cost model:** distinguish billed document/index-entry reads, writes/deletes,
index/storage overhead, network payload, Functions execution, Auth/provider
lookups, and projection maintenance. Rules-dependent reads and listener
reconnections can add costs. Caching, batching and parallelism affect different
parts of this model; none automatically makes underlying reads free. Query
Explain and SDK traces are useful but are not a complete production invoice.
Verify the actual database edition/region before applying pricing assumptions.
See [Firestore billing](https://firebase.google.com/docs/firestore/pricing).

- [ ] **E01 — P1 / V: Measure every workload above.** Include loading failures, empty queries, denied reads, repeat mounts, refresh, listener updates and transaction retry amplification. **Done:** numerical p50/p95 latency and read/write budgets are chosen per page with a reproducible fixture/workload and accountable owner.
- [ ] **E02 — P1 / F: Reduce guest polling amplification (F12/F13).** Compare event-driven own-status projection, mutation invalidation, focus/manual refresh and adaptive polling. **Done:** stale sensitive actions still fail closed, pending payment recovers promptly, and idle cost falls under the agreed budget without unauthorized cached disclosure.
- [ ] **E03 — P1 / F: Scope public event reads (F14).** Compare a direct event lookup, organizer-scoped bounded feed and purpose-built public summary. **Done:** a single-event deep link does not need the whole public catalog; pagination/overflow cannot hide a valid event as unavailable.
- [ ] **E04 — P1 / F: Bound native eligibility fan-out (F11).** Measure peer/block/schedule/hold reads and the >100-peer closure. Evaluate indexes, transactional conflict summaries or safe partitioning without weakening blocking/privacy checks. **Done:** supported event sizes have bounded eligibility cost and correct safety outcomes.
- [ ] **E05 — P1 / F: Replace discovery queries with stable own-record pointers where justified (F12).** Consider event/account status index, current registration/payment pointers and canonical form assignment. **Done:** fewer queries with transactional pointer maintenance, conflict detection, deletion handling and rebuild support; do not hide multiple valid payment attempts.
- [ ] **E06 — P0 / D: Preserve direct SDK reads for safely readable documents.** Use repository-owned reads and Firestore rules for public, own-user and authorized-host projections. **Done:** source documents containing reviewer notes, secrets or mixed private fields are never exposed just to remove a callable.
- [ ] **E07 — P0 / D: Keep authoritative mutations server-owned.** Admission, approval, membership, capacity, payment/refund, attendance and projection writes use explicit authorized backend commands. **Done:** SDK rules deny forged writes and shared contracts specify field ownership; existing narrow direct-write exceptions are individually reviewed, not blanket-banned.
- [ ] **E08 — P0 / D: Design self-readable status projections if needed.** Include only own sanitized facts and minimal freshness/source revision. **Done:** documents contain no raw CRM answers, private review reasons, contact endpoints, provider secrets or grant tokens; direct get/list behavior is tested separately.
- [ ] **E09 — P0 / D: Account for revocation in SDK projections.** Define whether access is current-source checked, projection-gated, or callable-only. **Done:** stale projection membership never grants privileged access; role loss and account switching clear displayed data and stop subscriptions. Previously downloaded data cannot be “unread” by rules.
- [ ] **E10 — P1 / D: Split hot operational data from stable descriptive data when measured.** Candidate: runtime/check-in counters versus event description/policy/media. **Done:** live updates do not force every event viewer to re-read unrelated content, while added document/rule reads and consistency costs are justified.
- [ ] **E11 — P1 / D: Consolidate bounded same-access values when measured.** Candidate: stable event policy and small display snapshots commonly fetched together. **Done:** consolidation lowers total workload cost without mixing privacy scopes, creating a hot giant document or exceeding size/index limits.
- [ ] **E12 — P0 / D: Make projections versioned, repairable and ordered.** Define atomic versus eventual updates, revision fencing, idempotent trigger behavior, backfill and unavailable states. **Done:** duplicate/out-of-order triggers cannot regress a newer summary, increment twice or permanently leak revoked data.
- [ ] **E13 — P1 / D: Cost projection fan-out before adopting it.** Compare reads saved with writes, dependent reads, index growth and subscriber re-reads added per mutation. **Done:** each new summary has a break-even workload estimate; avoid per-follower copies of every event without evidence.
- [ ] **E14 — P1 / D: Eliminate display-only N+1 reads.** Resolve organizer names, public profile snippets and summary badges through bounded batching/projections. **Done:** list-row count does not create one realtime listener per row; batch limits and missing records are handled honestly.
- [ ] **E15 — P1 / D: Share in-flight reads and scope caches.** Reuse identical repository/provider queries where safe, including Host directory readiness (F16). **Done:** account/organizer/query/version keys prevent cross-scope reuse; cache TTL, revocation and server-only read choices are explicit.
- [ ] **E16 — P1 / D: Own listener lifecycle.** Route-owned listeners dispose; retained tabs pause unless justified; debounce filters and bound first-page listening. **Done:** mount/unmount, background/reconnect and rapid route changes do not leak subscriptions or restart redundant reads.
- [ ] **E17 — P1 / D: Remove avoidable sequential latency.** Parallelize independent reads, lazy-load below-fold/private details, avoid repeated initialization and duplicate auth lookups. **Done:** critical path shortens under trace without pretending parallelism reduces billed reads or moving side effects into retrying transactions.
- [ ] **E18 — P1 / D: Review query/index shape.** Stable ordered cursors with tie-breaker, truthful hasMore, no offset scans, query-compatible security filters and necessary composites. **Done:** representative queries use expected indexes and reject scope-mismatched cursors; no silent first-page truncation.
- [ ] **E19 — P1 / V: Reduce index and payload overhead.** Review unqueried large maps/answers/text, sequential indexed fields, TTL fields and duplicate composites. **Done:** exemptions preserve required queries, reduce measured write/index overhead and are tested against actual index behavior.
- [ ] **E20 — P1 / F: Remove SDK/construction leakage from presentation (F15).** Move repository factories to data/composition providers and expose typed opaque cursors. **Done:** Host/Explore controller signatures contain no DocumentSnapshot/Query types and preserve stable cursor behavior.
- [ ] **E21 — P1 / V: Complete raw-access audit.** Scan imports, injected aliases, Firestore reads/writes, callable invocations and dynamic maps across controllers/widgets/providers in lib and web/admin. **Done:** each real violation has a fix or narrowly owned exception; harmless UI collection helpers and SDK composition roots are not falsely flagged.
- [ ] **E22 — P1 / D: Enforce repository/provider boundaries.** Extend existing scanners with known-bad fixtures for SDK operations/types outside allowed layers. **Done:** CI catches a deliberately introduced leak; controllers/widgets consume typed seams, not raw snapshots/maps.
- [ ] **E23 — P1 / V: Review web adapter ownership.** Inspect the large website Firebase adapter and backend-generated type imports; keep React hooks dependent on feature APIs. **Done:** browser DTOs come from the intended contract projection and transport details remain below page/controller composition; no superficial split that duplicates logic.
- [ ] **E24 — P0 / D: Preserve offline and stale-data distinctions.** Static public content may be cacheable under a declared policy; eligibility/private authority may require current proof. **Done:** offline content is not represented as current permission, prices/holds are revalidated, and silent network failure never means “not registered.”
- [ ] **E25 — P1 / V: Review region and deployment latency.** Measure client-to-database and Functions-to-database paths and cold versus warm calls. **Done:** regional/configuration changes have evidence, migration/risk review and rollback; do not add permanently warm instances or paid services by assumption.
- [ ] **E26 — P1 / D: Add regression budgets.** Use deterministic synthetic read counters and query-shape checks, with periodic realistic latency/load measurements. **Done:** adding a per-row lookup, accidental full scan, duplicate listener or expanded viewer query has a failing test or explicit budget review.

Firestore billing depends on operation/query shape and edition. Index fan-out
affects writes; cursors avoid the work associated with offsets. Splitting a
document may reduce update fan-out but add reads to every page. Evaluate both
sides rather than optimizing document count alone.
[Best practices](https://firebase.google.com/docs/firestore/best-practices).

## F. Attendance, runtime, post-event reviews, and communication

Proof: lifecycle integration tests, scoped runtime/rules tests and fake-provider
delivery recovery. Reuse existing Event Success/movement plans, not a new runtime.

- [ ] **F21 — P0 / D: Unify attendance evidence.** Define operational check-in versus verified attendance and which evidence supports review/runtime/network eligibility. **Done:** web and native guests receive equivalent intended rights, while an imported “registered” row alone proves neither attendance nor payment.
- [ ] **F22 — P0 / D: Model no-show as explicit closeout.** Include attendance unknown, attended, excused/no-show where supported, and correction provenance. **Done:** no-show is never inferred solely from missing check-in; authorized late correction updates downstream eligibility consistently.
- [ ] **F23 — P0 / D: Define check-in/undo semantics.** Include staff scope, offline replay, late arrival, cancelled registrations and repeated scans. **Done:** check-in cannot bypass ticket/admission rules; undo restores the correct prior operational state without losing financial facts.
- [ ] **F24 — P1 / D: Compose pre/live/post-event guest state.** Event detail renders lifecycle and a dedicated runtime entry point. **Done:** no booking CTA after sales closure, no runtime access from a stale public link, and post-event state does not require fabricated end times.
- [ ] **F25 — P0 / D: Preserve runtime-specific authorization.** Check participant identity, current access, assignment visibility and event lifecycle at runtime commands. **Done:** joining a pod/pair or seeing a URL never grants event admission; cancellation/removal revokes future runtime operations.
- [ ] **F26 — P1 / D: Integrate venue/itinerary decisions with existing owner (F20).** Use structured stop values, optional reusable venue IDs and historical location snapshots. **Done:** no string-only stop assumption where coordinates are required; public itinerary does not leak restricted location or live participant position.
- [ ] **F27 — P0 / D: Scope moving-event notifications.** Define destination, current stop/version, who has not checked in, consent, retries and out-of-order movement changes. **Done:** stale movement notifications do not route guests to the wrong stop and no public projection exposes private tracking.
- [ ] **F28 — P1 / F: Extend review eligibility to the agreed web journey (F08).** Resolve canonical attendance across supported origins without synthetic consumer profiles. **Done:** authenticated eligible web guests can review once per declared subject; non-attendees cannot forge eligibility.
- [ ] **F29 — P0 / D: Separate review lifecycle from event attendance.** Define draft/submitted/edited/withdrawn/moderated states, rating aggregation and author deletion behavior. **Done:** moderation changes publication/aggregates without erasing attendance; duplicate retries do not create duplicate reviews.
- [ ] **F30 — P0 / D: Keep notifications as side effects.** Persist delivery intent after a committed decision with event/application revision and deduplication. **Done:** failed notification cannot roll back approval; duplicate triggers or retries cannot send uncontrolled duplicates.
- [ ] **F31 — P1 / F: Preserve WhatsApp/SMS plus email semantics (F18).** WhatsApp primary/SMS fallback is one lane; email is additional, with provider substitution below business logic. **Done:** unsupported destinations, consent, bounces, delivery receipts, retries and fallback timing have tests; secrets/setup/live acceptance remain separate.
- [ ] **F32 — P0 / D: Revalidate delayed messages and links.** Bind offers and approval links to current identity/generation; suppress obsolete or revoked invitations. **Done:** old messages cannot grant a seat or reveal revoked answers; guests can recover status after signing in without keeping secret URLs.
- [ ] **F33 — P1 / D: Expose useful organizer and guest explanations.** Distinguish review deferral, capacity queue, payment recovery, refund processing and unavailable evidence. **Done:** messages are driven by typed reason codes, localized, and do not disclose private safety/reviewer reasoning.

## G. Migration, compatibility, and operational recovery

Proof: checked-in migration contracts, synthetic/emulator rehearsal, read-only
production dry-run when authorized, idempotent checkpoints and rollback tests.
Never “fix” uncertain records by fabricating approval, consent, payment or identity.

- [ ] **G01 — P0 / D: Design each structural migration before writers change.** Include schema versions, old-client readers, new writers, adapters, indexes and rules deployment order. **Done:** supported released clients and web builds work throughout the cutover.
- [ ] **G02 — P0 / D: Measure legacy ambiguity.** Detect contradictory statuses, duplicate identities, missing versions, orphaned references and invalid money/time fields. **Done:** records are classified into deterministic repair versus manual resolution; no invented history fills gaps.
- [ ] **G03 — P0 / D: Normalize at repository/backend boundaries.** Keep fallback logic out of widgets and controllers. **Done:** canonical valid data wins; complete legacy values may promote; partial/conflicting values fail closed with a repair path.
- [ ] **G04 — P0 / D: Control any dual-write period.** Declare one authority, transaction/projection semantics, reader precedence and a retirement condition. **Done:** no two stores independently decide the same status, and retries cannot diverge mirrors.
- [ ] **G05 — P0 / D: Make backfills resumable and bounded.** Use stable checkpoints, idempotent writes, rate limits and per-record conflict handling. **Done:** interruption/restart is safe and does not overwrite concurrent newer state.
- [ ] **G06 — P0 / D: Preserve old identifiers and provenance.** Retain mappings for payment callbacks, offer links, CRM origins and legacy response IDs. **Done:** historical receipts, refunds, bookmarked links and support lookups remain resolvable.
- [ ] **G07 — P0 / D: Define deletion/retention behavior by entity.** Account deletion, organizer archive, response withdrawal and event deletion have different effects. **Done:** private projections and listeners cease appropriately while required financial/audit retention remains purpose-scoped.
- [ ] **G08 — P0 / D: Define rollback per slice.** Include forward-written records and provider callbacks received during deployment. **Done:** rollback does not orphan captured payments, reopen consumed offers or resurrect cancelled registrations.
- [ ] **G09 — P0 / D: Deploy rules/indexes/readers/writers in compatible order.** Run emulator and exact-head CI gates, then controlled rollout. **Done:** indexes are ready before required queries and stricter rules do not break supported reads unexpectedly.
- [ ] **G10 — P0 / D: Reconcile after cutover.** Compare canonical registrations, seat occupancy/holds, payments/refunds, membership decisions and projections. **Done:** invariants hold, conflicts have named repair owners, and legacy reads/writes retire only with measured proof.
- [ ] **G11 — P1 / D: Document operator recovery.** Provide bounded actions for stuck payment, stale projection, ambiguous identity, invalid application source and failed delivery. **Done:** support tools use authorized commands rather than ad hoc Firestore field edits.

## H. Verification, parity, and completion

- [ ] **H01 — P0 / D: Build transition-model tests.** Generate valid command sequences and assert invariants after every step; include invalid transitions and stale revisions. **Done:** model-based/property tests find contradictions independently of UI implementation.
- [ ] **H02 — P0 / D: Test transaction races.** Compete for last seats, review versus withdrawal, membership revoke versus booking, cancellation versus capture and duplicate callbacks. **Done:** exactly the allowed outcomes commit and compensating work is recoverable.
- [ ] **H03 — P0 / D: Prove authorization negative cases.** Anonymous, wrong UID, wrong organizer, revoked staff, expired grant, forged path/body and stale projection. **Done:** SDK rules and backend handlers deny each at the actual boundary.
- [ ] **H04 — P1 / D: Prove native/web/Host parity.** Run the same business fixtures through all supported entry paths and renderers. **Done:** eligibility, financial promises, optional content and reason labels agree without copying policy logic into views.
- [ ] **H05 — P1 / D: Prove lifecycle and cache isolation.** Mount/unmount, account switch, organizer switch, background/reconnect, time expiry and late responses. **Done:** no stale private state, orphaned listener or delayed mutation result overwrites the current session.
- [ ] **H06 — P1 / D: Compare cost and performance with A08.** Use the same fixture scale, edition assumptions and workload duration. **Done:** agreed budgets pass, with any increase explained by a deliberate correctness/product requirement.
- [ ] **H07 — P1 / D: Update durable owners and retire duplicate logic.** Remove superseded adapters only after compatibility gates; update contracts, operation catalog, architecture exhibits and related plans. **Done:** there is one documented authority and no abandoned parallel implementation.
- [ ] **H08 — P2 / V: Revisit database choice using evidence.** Compare remaining CRM join/filter complexity, transactional contention, projection upkeep and total operating cost against PostgreSQL. **Done:** retain Firestore with evidence or propose a bounded subsystem migration with one writer and explicit projection boundaries; no blanket rewrite based on collection count.
- [ ] **H09 — P0 / D: Separate release statuses.** Track source/CI, deploy, migration, feature gate, provider configuration and live acceptance distinctly in the PR/release process. **Done:** “implemented” does not imply a live channel, migrated database or successful real booking.
- [ ] **H10 — P1 / D: Close this tracker cleanly.** Move durable decisions to owners and unresolved work to its appropriate existing backlog. **Done:** no stale duplicate architecture tracker or replacement audit history remains.

## State model and transition coverage checklist

These are semantic dimensions to implement, not mandatory literal enum spellings.
Use variants and references where they enforce invariants; avoid a Cartesian-product
mega-enum. Absence of a relationship can mean “none”; do not create empty documents
for every possible user/organizer/event combination.

| Dimension | Required semantic states | Important transitions and distinctions |
|---|---|---|
| Account readiness | Signed out; verified minimal account; required action-specific details missing; ready; unavailable/deleted | Sign-in does not create public/dating profile or grant organizer permission. |
| Follow | None/inactive; active | Re-follow updates current edge; full toggle history only if needed. |
| Community membership | None; active; revoked; expired only if supported | Grant/reactivate/revoke have decision provenance; unavailable evidence is not “none.” |
| Form publication | Draft; published version; closed/archived | Published answers bind immutable version; closure rules specify draft resume/submit. |
| Response | Draft; submitted; withdrawn | Review state is separate; amendment creates a new version/attempt or an explicit immutable revision. |
| Application review | Submitted; in review; deferred; approved; declined; withdrawn | Approval grants scoped eligibility; explicit revision/reopen rules; no implicit seat. |
| Invitation | Issued; claimed; revoked; expired | Claim proves recipient ownership; it is not necessarily registration or a hold. |
| Capacity queue | Not queued; queued; offered; accepted; left/expired/removed | Deferred application is not this queue; re-entry and priority have policy. |
| Seat reservation | None; active temporary/checkout/offer hold; consumed; released/expired | Bound to subject and expiry; a consumed reservation corresponds to the declared registration authority. |
| Registration | No registration; active confirmed; cancelled | Pending preparation can be an explicit workflow state; payment and attendance do not collapse into registration status. |
| Payment attempt | Not required; creating/unknown; ready; processing; captured; failed; cancelled/expired | Capture may precede admission or compensation; multiple attempts remain distinguishable. |
| Refund | None; entitlement/quote; requested; processing/unknown; settled; failed | Amount/currency and partial/full settlement explicit; refund does not rewrite attendance. |
| Attendance | Unrecorded; checked in/attended; explicit no-show/excused; corrected | Define operational versus verified evidence; absence is not no-show. |
| Runtime | Not available; eligible; joined; assigned; active; complete; revoked | Runtime membership never manufactures a ticket, payment or event-level eligibility. |
| Review | Not eligible/eligible (derived); draft; published; withdrawn; moderated | Eligibility derives from verified attendance; one current review per declared scope. |
| Delivery | Pending; attempted; accepted; delivered; failed; suppressed | Provider acceptance is not confirmed delivery; separate independent channel lanes. |
| Event lifecycle | Publication state; sales state; occurrence state | Scheduled/live/completed/cancelled are not synonyms for published/open/full. |

### Invariants that need executable protection

- [ ] **INV01:** At most one active seat entitlement per canonical admission subject/event, except an explicitly modeled multi-ticket/group purchase whose ticket identities are distinct.
- [ ] **INV02:** Occupied capacity plus applicable live holds never exceeds allowed capacity/cohort rules; release/expiry applies at most once.
- [ ] **INV03:** Approval, follow, contact existence and membership are not interchangeable proof; none alone proves payment or a seat.
- [ ] **INV04:** A confirmed paid registration has the declared verified financial authority or explicit permitted external/manual provenance; a payment ID alone is insufficient.
- [ ] **INV05:** Refund totals never exceed captured refundable money under the supported model; currency never changes through arithmetic or formatting.
- [ ] **INV06:** Withdrawn/revoked/unavailable source evidence cannot support a new approval or grant; existing-booking effects follow an explicit separate policy.
- [ ] **INV07:** Current eligibility is recomputed at commit; a cached allowed action, quote or revision is an observation, not authority.
- [ ] **INV08:** Every active grant, hold, offer and registration belongs to the exact organizer/event/subject expected by the command.
- [ ] **INV09:** No-show, verified attendance, consent, identity and provider capture are never inferred from absence, display names or unrelated private data.
- [ ] **INV10:** Optional fields retain absence; a renderer cannot manufacture itinerary, location, policy, capacity or pricing facts.
- [ ] **INV11:** Expired authority cannot remain usable because a timer/TTL worker has not deleted a document.
- [ ] **INV12:** A mutation retry with the same idempotency identity and payload replays safely; the same identity with a different payload is rejected.
- [ ] **INV13:** Projection updates cannot resurrect removed access or regress newer revisions; reconciliation can rebuild every non-authoritative summary.
- [ ] **INV14:** Controllers/widgets cannot bypass typed repositories or apply server-owned mutations through raw SDK access.
- [ ] **INV15:** Reads return only authorized projections; query shape, pagination and caching cannot broaden tenant or participant visibility.
- [ ] **INV16:** Event cancellation, membership revocation, account deletion and refund settlement preserve distinct historical facts even when they trigger related actions.

## Edge-case acceptance matrix

Each row must map to tests in its owning slice. “Not supported” is an acceptable
product decision only when surfaced before commitment/payment and backed by a
safe, explicit result.

| Case | Expected outcome | Primary items |
|---|---|---|
| Approve an applicant while event is full | Approved eligibility; separate capacity queue or unavailable claim, no oversell | A05, D02–D06 |
| Free request approved in native versus web | Same default claim semantics; explicit host auto-enrolment only if intentionally retained | A05, D02 |
| Member applies to review-required event | Bypass only if configured; fresh answers may still be required | C05, D07 |
| Membership revoked during checkout | Transaction checks current pre-admission entitlement; existing registration policy handled separately | C05, D01, D12 |
| Follow/unfollow/re-follow retries | One current edge and correct count/preferences, no membership changes | C03 |
| Two reviewers act simultaneously | Revision conflict or idempotent replay; no split decisions | C10, H02 |
| Withdraw response during approval | One valid ordering; withdrawn evidence cannot authorize new approval | C07, H02 |
| Withdraw after paid registration | Sharing/redaction and booking/refund rules remain separate | C07, D13 |
| Form edited after response submitted | Original version preserved; new required answers handled explicitly | B11, C10 |
| Multiple published event application forms | Explicit selected authority or repair state; no random form link | C14, E05 |
| Multiple offers or newest failed payment over older success | Inspect canonical authority; do not hide a valid booking based on newest-row heuristic | C14, D09, E05 |
| Last two guests claim one seat | One confirmation; other receives truthful capacity outcome | D06 |
| Pair/group straddles cohort capacity | Atomic group policy or clear unsupported outcome; no half-confirmed hidden state | D07, D08 |
| Unknown cohort or declined demographic answer | Explicit policy outcome; never infer from name/photo | D08 |
| Host reduces capacity below booked count | Explicit conflict/remediation; no silent removal of existing guests | D06, D15 |
| Offer expires during payment | Revalidation or compensation; expired hold cannot authorize oversell | D05, D12 |
| Payment capture after timeout or cancellation | Recover provider truth, then admit safely or refund; never charge again blindly | D11–D13 |
| Duplicate/out-of-order payment or refund webhook | Deduplicated monotonic result with reconciled amounts | D09–D16 |
| Cancellation request response lost | Same command identity returns same result; no duplicate refund or seat release | D13, G11 |
| Host cancels after guest cancellation | Explicit entitlement policy; no accidental double/no refund | D15 |
| Event rescheduled after purchase | Accepted terms retained; any new consent/refund rights handled explicitly | B11, D15 |
| Two people share imported buyer phone | Distinct ticket identities or reviewed conflict; no automatic merge | A03, C02 |
| Account phone changed/recycled or accounts linked | Verify current identity and prior ownership; no accidental ticket/CRM transfer | C02 |
| Web attendee later completes consumer onboarding | Link to existing entitlement; do not allocate a second seat/profile-history fiction | A02, C02, D03 |
| Account deleted while refund pending | No new access; financial recovery remains possible under retention policy | G07 |
| Event has no valid end time | No invented completed/no-show state; explicit repair/closeout | B09, F22 |
| Staff checks in then undoes/offline replays | Deterministic authorized correction; preserve canonical registration/payment | F21–F23 |
| No-show corrected to attended | Recompute intended review/runtime/post-event rights with audit provenance | F22, F28 |
| Event venue/stop changes while guest is en route | Current version wins; only scoped eligible recipients notified | F26, F27 |
| Quiet live-event stream | Remains valid; no artificial idle timeout | E16, F24 |
| Role revoked during cached Host session | Stop private refresh/subscription and clear view; mutations reauthorize | E09, H05 |
| User A signs out while viewer request completes | Late result cannot populate user B's screen/cache | E15, H05 |
| Public/private field added to event schema | Ownership/projection tests prevent accidental public exposure | B02, E06 |
| New enum shipped before old app updates | Safe compatibility behavior; no default-to-allowed action | B14, B15 |
| Public event feed exceeds its bound | Honest pagination/scoped lookup, not false unavailable | E03 |
| Native event exceeds viewer peer bound | Supported scalable check or explicit diagnosed limitation, never bypass safety | E04 |
| Listener reconnect/focus/poll overlap | Bounded refresh, no duplicate mutation, measured billing | E01, E02, E16 |
| Trigger delayed/duplicated/out of order | Versioned projection and repair; stale display never authorizes a seat | E12 |
| WhatsApp fails while email succeeds | Channel-specific result; SMS fallback policy applied once; booking unchanged | F30–F32 |
| Provider config missing or feature gated off | Truthful unavailable delivery/checkout state, separate from merged source | H09 |

## Validation routing and definition of done

For each implementation slice derive checks from its actual diff; do not treat
this planning list as a frozen CI gate list:

```sh
node tool/harness.mjs plan --base origin/main --head HEAD --json
node tool/harness/verify_local.mjs --base origin/main --list
```

Existing relevant checks include `docs:metadata`,
`contracts:firestore-contract`, `contracts:firestore-query-indexes`,
`contracts:firestore-read-limits`, `audit:dependency-direction`,
`audit:provider-graph`, and `web:react-architecture-boundaries`.
Run registered checks through `node tool/run.mjs check <id...>` when applicable.
Behavioral contract changes also follow `./tool/check_data_contract.sh`.
Use the actual generator commands in the owning contract runbook. Do not run
multiple Flutter analyzer/test processes concurrently.

A slice is ready only when:

1. Its canonical facts, transitions, DTOs and physical-document decisions agree.
2. Relevant invariants, adversarial cases and authorization denials are tested.
3. Generated outputs are current and architecture boundaries pass.
4. Optional data renders truthfully across create/detail/app/web.
5. Read/write/latency impact is measured or an explicitly scoped measurement
   blocker prevents the performance claim.
6. Migration, compatibility, repair and rollback are reviewable.
7. Exact-head required CI passes before merge; deployment/live verification is
   reported separately and performed only within its authorization.
8. Durable owner docs are updated and duplicate implementations retired safely.

## External technical references

These inform measurement and design; they do not replace Catch source or live
verification.

- [Firestore data model](https://firebase.google.com/docs/firestore/data-model):
  documents, embedded maps, collections and references.
- [Firestore structure guidance](https://firebase.google.com/docs/firestore/manage-data/structure-data):
  bounded embedded data versus independently growing records.
- [Field-level access limits](https://firebase.google.com/docs/firestore/security/rules-fields):
  direct document reads cannot hide selected private fields.
- [Transactions](https://firebase.google.com/docs/firestore/manage-data/transactions):
  atomic database operations and retry considerations; external payment I/O is
  not made atomic by a Firestore transaction.
- [Firestore billing](https://firebase.google.com/docs/firestore/pricing) and
  [best practices](https://firebase.google.com/docs/firestore/best-practices):
  workload-dependent cost, listener/index/rules reads and latency.
- [Firestore Enterprise joins](https://firebase.google.com/docs/firestore/pipelines/perform-joins-with-sub-pipelines):
  do not base database selection on a blanket assertion that Firestore has no
  joins; verify Catch's actual edition and APIs.
- [PostgreSQL constraints](https://www.postgresql.org/docs/18/ddl-constraints.html):
  relational enforcement is a potential alternative, not a reason to skip
  domain invariants, authorization or idempotency.
