import assert from "node:assert/strict";
import test from "node:test";
import type {EventAssistanceLateJoinInput} from
  "../../shared/generated/eventAssistanceLateJoinInput";
import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import type {EventAssistanceDeliveryAttempt as Attempt} from
  "../../shared/generated/eventAssistanceDeliveryAttempt";
import type {EventAssistanceGuestResponse as GuestResponse} from
  "../../shared/generated/eventAssistanceGuestResponse";
import {
  buildLateJoinMessageIntent, parseMessageIntent, parseDeliveryAttempt,
  planMessageDelivery, prepareDeliveryAttempt, resolveGuestChoice,
  ResolvedGuestScope,
} from "./messageProtocol";
import type {DeliveryEvaluationInput, RouteReadiness} from "./messagingPolicy";
import {mergeDeliveryReceipt, VerifiedDeliveryReceipt} from
  "./deliveryReceipts";
import {evaluateLateJoin} from "./lateJoin";

function input(): EventAssistanceLateJoinInput {
  return {
    context: {mode: "live", eventId: "event-1", organizerId: "organizer-1"},
    eventId: "event-1",
    eventOpen: true,
    departureConfirmed: true,
    now: 1000000,
    setting: {
      kind: "enabled",
      authority: "executeWithinPolicy",
      policyVersion: "v1",
    },
    policy: {
      destination: {
        kind: "itineraryStop",
        itineraryId: "itinerary-1",
        permittedStopIds: ["stop-1", "stop-2"],
      },
      cutoff: {kind: "time", at: 2000000},
      maxMessagesPerEpisode: 4,
      minimumMinutesBetweenMessages: 5,
      updateOn: "materialGuidanceChange",
      unanswered: "keepUnknownUntilCutoff",
    },
    guest: {
      attendeeId: "guest-1",
      episodeId: "episode-1",
      admission: "admitted",
      attendance: {
        kind: "known",
        value: {checkedIn: false},
        revision: 1,
        observedAt: 900000,
        source: "host",
      },
      intention: {kind: "unknown"},
      deliveryEligibility: "eligible",
    },
    guidance: {
      kind: "known",
      revision: 1,
      observedAt: 900000,
      source: "host",
      value: {
        revision: 1,
        destination: {
          kind: "itineraryStop",
          itineraryId: "itinerary-1",
          stopId: "stop-1",
        },
        materialKey: "stop-1-revision-1",
        text: "Meet us at the first stop.",
        validUntil: 2000000,
      },
    },
    lastMessage: null,
    messagesThisEpisode: 0,
  };
}

function message(): MessageIntent {
  const result = buildLateJoinMessageIntent(input(), {
    occurrenceId: "late-join:episode-1",
    permittedRoutes: ["organizerEventWhatsapp", "catchEventRcs",
      "catchEventSms"],
    deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
      minimumRetrySeconds: 1},
    laterChoices: [{label: "Join at stop two", target: {
      kind: "itineraryStop", itineraryId: "itinerary-1", stopId: "stop-2",
    }}],
  });
  assert.ok(result);
  return result;
}

function delivery(): DeliveryEvaluationInput {
  const intent = message();
  const bindings: Extract<Attempt, {mode: "live"}>["binding"][] = [
    {routeId: "organizerEventWhatsapp", transport: "whatsapp",
      senderIdentity: "organizerManaged", provider: "meta", senderId: "wa-1",
      bindingRevision: 1, recipientEndpointId: "endpoint-1",
      fallbackOwner: "catch"},
    {routeId: "catchEventRcs", transport: "rcs",
      senderIdentity: "catchPlatform",
      provider: "sinch", senderId: "rcs-1", bindingRevision: 1,
      recipientEndpointId: "endpoint-2", fallbackOwner: "catch"},
    {routeId: "catchEventSms", transport: "sms",
      senderIdentity: "catchPlatform",
      provider: "sinch", senderId: "sms-1", bindingRevision: 1,
      recipientEndpointId: "endpoint-3", fallbackOwner: "catch"},
  ];
  const routes: RouteReadiness[] = bindings.map((binding) => ({
    routeId: binding.routeId, state: {kind: "eligible",
      checkedAt: intent.createdAt,
      validUntil: intent.expiresAt, permissionRevision: "permission-1",
      candidate: {mode: "live", binding}},
  }));
  return {intent, lifecycle: "active", attempts: [], routes,
    gate: {kind: "allow", checkedAt: intent.createdAt,
      validUntil: intent.expiresAt, instructionRevision: 1},
    now: intent.createdAt};
}

function firstAttempt(): Extract<Attempt, {mode: "live"}> {
  const attempt = prepareDeliveryAttempt(delivery());
  assert.ok(attempt && attempt.mode === "live");
  return attempt;
}

function receipt(state: VerifiedDeliveryReceipt[
  "state"]): VerifiedDeliveryReceipt {
  const attempt = firstAttempt();
  return {attemptId: attempt.attemptId, senderId: attempt.binding.senderId,
    bindingRevision: attempt.binding.bindingRevision,
    recipientEndpointId: attempt.binding.recipientEndpointId,
    routeId: attempt.binding.routeId, providerEventId: "provider-event:1",
    receivedAt: state.at, state};
}

function guestSubmission() {
  const intent = message();
  const scope: ResolvedGuestScope = {context: intent.context,
    eventId: intent.eventId, attendeeId: intent.attendeeId,
    episodeId: intent.episodeId, validUntil: intent.expiresAt,
    source: {kind: "guestWeb", linkId: "link-1"}};
  return {intent, lifecycle: "active" as const,
    submission: {intentId: intent.intentId, intentRevision: intent.revision,
      choiceId: "on-my-way", requestId: "submission-1"}, scope,
    gate: {kind: "allow" as const, checkedAt: intent.createdAt,
      validUntil: intent.expiresAt, instructionRevision: 1},
    now: intent.createdAt};
}

test("late-join choices preserve the approved plan and attendance boundary",
  () => {
    const intent = message();
    assert.equal(intent.choices.length, 4);
    const received = resolveGuestChoice(guestSubmission());
    assert.equal(received.kind, "accepted");
    if (received.kind !== "accepted") return;
    assert.equal(received.response.value.kind, "joinIntent");
    const facts = input();
    if (received.response.value.kind === "joinIntent") {
      facts.guest.intention = received.response.value.intention;
    }
    assert.equal(facts.guest.attendance.kind, "known");
    assert.equal(evaluateLateJoin(facts).kind, "update");
    const rejectedFacts = input();
    rejectedFacts.guest.intention = {kind: "notComing"};
    assert.equal(buildLateJoinMessageIntent(rejectedFacts, {
      occurrenceId: "late-join:episode-1", permittedRoutes: ["catchEventSms"],
      deliveryPolicy: intent.deliveryPolicy,
    }), null);
    assert.throws(() => buildLateJoinMessageIntent(input(), {
      occurrenceId: "late-join:episode-1", permittedRoutes: ["catchEventSms"],
      deliveryPolicy: intent.deliveryPolicy,
      laterChoices: [{label: "Unapproved venue", target: {
        kind: "itineraryStop", itineraryId: "itinerary-1", stopId: "stop-99",
      }}],
    }), /outside the approved plan/);
  });

test("uncertain attempts cannot start another channel", () => {
  const attempt = firstAttempt();
  const states: Attempt["state"][] = [attempt.state,
    {kind: "accepted", at: attempt.createdAt, providerMessageId: "wamid.abc="},
    {kind: "unknown", at: attempt.createdAt, providerMessageId: null,
      reason: "timeout", reconcileAfter: attempt.createdAt + 120_000}];
  for (const state of states) {
    const result = planMessageDelivery({...delivery(), attempts: [{
      ...attempt, state}]});
    assert.equal(result.kind, "reconcile");
    assert.equal(prepareDeliveryAttempt({...delivery(), attempts: [{
      ...attempt, state}]}), null);
  }
});

test("confirmed failures use bounded fallback", () => {
  const current = delivery();
  const failed: Attempt = {...firstAttempt(), state: {kind: "failed",
    classification: "technical", at: current.now, providerMessageId: null,
    evidenceId: "rejection-1"}};
  const waiting = planMessageDelivery({...current, attempts: [failed]});
  assert.equal(waiting.kind, "wait");
  const rcs = prepareDeliveryAttempt({...current, now: current.now + 1000,
    attempts: [failed]});
  assert.ok(rcs?.mode === "live");
  assert.equal(rcs.binding.routeId, "catchEventRcs");
  const rcsFailed: Attempt = {...rcs, state: {kind: "failed", at: rcs.createdAt,
    providerMessageId: null, classification: "technical",
    evidenceId: "rejection-2"}};
  const sms = prepareDeliveryAttempt({...current, now: current.now + 3000,
    attempts: [failed, rcsFailed]});
  assert.ok(sms?.mode === "live");
  assert.equal(sms.binding.routeId, "catchEventSms");
  const smsFailed: Attempt = {...sms, state: {kind: "failed", at: sms.createdAt,
    providerMessageId: null, classification: "technical",
    evidenceId: "rejection-3"}};
  assert.deepEqual(planMessageDelivery({...current, now: current.now + 7000,
    attempts: [failed, rcsFailed, smsFailed]}),
  {kind: "hostDecision", reason: "attemptLimit"});
});

test("policy and provider fallback retain their authority boundaries", () => {
  const current = delivery();
  for (const classification of ["policy", "suppressed",
    "invalidRecipient"] as const) {
    const attempt: Attempt = {...firstAttempt(), state: {kind: "failed",
      at: current.now, providerMessageId: null, classification,
      evidenceId: "reject-1"}};
    const result = planMessageDelivery({...current, attempts: [attempt]});
    assert.equal(result.kind, "hostDecision");
  }
  const attempt = firstAttempt();
  attempt.binding.fallbackOwner = "provider";
  attempt.state = {kind: "failed", at: current.now, providerMessageId: null,
    classification: "technical", evidenceId: "reject-1"};
  assert.deepEqual(planMessageDelivery({...current, attempts: [attempt]}),
    {kind: "hostDecision", reason: "providerOwnsFallback"});
});

test("dispatch requires fresh need, instruction and permission", () => {
  const current = delivery();
  for (const reason of ["guestPresent", "guestDeclined", "eventClosed",
    "permissionRevoked", "hostStopped", "notAdmitted"] as const) {
    assert.deepEqual(planMessageDelivery({...current, gate: {kind: "stop",
      reason}}),
    {kind: "stop", reason});
  }
  assert.deepEqual(planMessageDelivery({...current, lifecycle: "responded"}),
    {kind: "stop", reason: "responded"});
  assert.equal(planMessageDelivery({...current,
    now: current.intent.expiresAt}).kind, "stop");
  assert.deepEqual(planMessageDelivery({...current, gate: {kind: "allow",
    checkedAt: current.now, validUntil: current.now + 1,
    instructionRevision: 2}}),
  {kind: "stop", reason: "superseded"});
  assert.equal(planMessageDelivery({...current, gate: {kind: "allow",
    checkedAt: current.now, validUntil: current.now, instructionRevision: 1},
  }).kind,
  "refreshFacts");
  const routes = structuredClone(current.routes);
  for (const route of routes) {
    assert.ok(route.state.kind === "eligible");
    route.state.validUntil = current.now;
  }
  assert.deepEqual(planMessageDelivery({...current, routes}),
    {kind: "refreshFacts", reason: "routeFactsStale"});
});

test("delivery evidence cannot regress or alias another message", () => {
  const initial = firstAttempt();
  const delivered = mergeDeliveryReceipt(initial, receipt({kind: "delivered",
    at: initial.createdAt + 100, providerMessageId: "wamid.abc="}));
  const older = mergeDeliveryReceipt(delivered.attempt, receipt({
    kind: "accepted",
    at: initial.createdAt + 200, providerMessageId: "wamid.abc="}));
  assert.equal(older.disposition, "duplicateOrOlder");
  assert.equal(older.attempt.state.kind, "delivered");
  const read = mergeDeliveryReceipt(older.attempt, receipt({kind: "read",
    at: initial.createdAt + 300, providerMessageId: "wamid.abc="}));
  assert.equal(read.attempt.state.kind, "read");
  assert.throws(() => mergeDeliveryReceipt(read.attempt, receipt({kind: "read",
    at: initial.createdAt + 400, providerMessageId: "another-message"})),
  /Provider message identity mismatch/);
  const conflicting = mergeDeliveryReceipt(read.attempt, receipt({
    kind: "failed",
    at: initial.createdAt + 400, providerMessageId: null,
    classification: "technical", evidenceId: "inconsistent-provider"}));
  assert.equal(conflicting.disposition, "conflictingEvidence");
  assert.equal(conflicting.attempt.state.kind, "read");
  assert.equal(planMessageDelivery({...delivery(), now: initial.createdAt + 500,
    attempts: [conflicting.attempt]}).kind, "delivered");
});

test("provider receipts retain their complete sender scope", () => {
  const initial = firstAttempt();
  const valid = receipt({kind: "accepted", at: initial.createdAt,
    providerMessageId: "wamid.test/+="});
  for (const patch of [{senderId: "other"}, {recipientEndpointId: "other"},
    {bindingRevision: 2}, {attemptId: "other"}]) {
    assert.throws(() => mergeDeliveryReceipt(initial, {...valid, ...patch}),
      /scope or evidence/);
  }
});

test("native and web responses share one outcome", () => {
  const submitted = guestSubmission();
  const result = resolveGuestChoice(submitted);
  assert.ok(result.kind === "accepted");
  assert.equal(resolveGuestChoice({...submitted, lifecycle: "responded",
    existingResponse: result.response}).kind, "replayed");
  const native = resolveGuestChoice({...submitted, lifecycle: "responded",
    existingResponse: result.response, scope: {...submitted.scope,
      source: {kind: "provider", attemptId: firstAttempt().attemptId,
        providerEventId: "event-1"}},
    submission: {...submitted.submission, requestId: "native-1"}});
  assert.deepEqual(native, {kind: "rejected", reason: "alreadyResponded"});
  const response = result.response as GuestResponse;
  assert.ok(!("checkedIn" in response.value));
});

test("invalid guest submissions cannot act", () => {
  const submitted = guestSubmission();
  assert.deepEqual(resolveGuestChoice({...submitted,
    submission: {...submitted.submission, intentRevision: 2}}),
  {kind: "rejected", reason: "staleIntent"});
  assert.deepEqual(resolveGuestChoice({...submitted,
    submission: {...submitted.submission, choiceId: "check-in"}}),
  {kind: "rejected", reason: "invalidChoice"});
  assert.deepEqual(resolveGuestChoice({...submitted,
    scope: {...submitted.scope, attendeeId: "another-guest"}}),
  {kind: "rejected", reason: "scopeMismatch"});
  assert.deepEqual(resolveGuestChoice({...submitted,
    now: submitted.intent.expiresAt}),
  {kind: "rejected", reason: "expired"});
  assert.equal(resolveGuestChoice({...submitted, gate: {...submitted.gate,
    validUntil: NaN}}).kind, "rejected");
});

test("rehearsal dispatch can never acquire a live sender binding", () => {
  const current = delivery();
  current.intent.context = {mode: "rehearsal", rehearsalId: "rehearsal-1",
    virtualEventId: current.intent.eventId, clockId: "clock-1"};
  assert.throws(() => prepareDeliveryAttempt(current),
    /Invalid delivery attempt/);
  current.routes = current.routes.map((route) => ({routeId: route.routeId,
    state: {kind: "eligible", checkedAt: current.now,
      validUntil: current.intent.expiresAt, permissionRevision: "simulated",
      candidate: {mode: "rehearsal", routeId: route.routeId}}}));
  const simulated = prepareDeliveryAttempt(current);
  assert.ok(simulated?.mode === "rehearsal");
  assert.ok(!("binding" in simulated));
  assert.throws(() => parseDeliveryAttempt({...simulated,
    binding: firstAttempt().binding}), /Invalid delivery attempt/);
});

test("wire validation rejects ambiguous or mixed evidence", () => {
  const intent = message();
  assert.throws(() => parseMessageIntent({...intent,
    choices: [intent.choices[0], intent.choices[0]]}),
  /Duplicate response choice/);
  assert.throws(() => parseDeliveryAttempt({...firstAttempt(),
    binding: {...firstAttempt().binding, senderIdentity: "catchPlatform"}}),
  /Invalid delivery attempt/);
  const attempt = firstAttempt();
  attempt.ordinal = 2;
  assert.throws(() => planMessageDelivery({...delivery(), attempts: [attempt]}),
    /Incomplete delivery history/);
  assert.throws(() => parseMessageIntent({...intent,
    expiresAt: intent.createdAt}),
  /scope or expiry/);
});
