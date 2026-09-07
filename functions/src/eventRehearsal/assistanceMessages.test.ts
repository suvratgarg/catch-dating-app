import assert from "node:assert/strict";
import test from "node:test";
import type {EventAssistanceLateJoinInput as LateJoinInput} from
  "../shared/generated/eventAssistanceLateJoinInput";
import {evaluateLateJoin} from "../eventSuccess/operations/lateJoin";
import {canClaimLiveAttempt, MessageRecord, OutboxFacts} from
  "../eventSuccess/operations/messageOutbox";
import {LateJoinMessageOptions, ResolvedGuestScope} from
  "../eventSuccess/operations/messageProtocol";
import {dispatchRehearsalMessage, prepareRehearsalLateJoin,
  recordRehearsalMessageOutcome, respondToRehearsalMessage} from
  "./assistanceMessages";

const context = {mode: "rehearsal" as const, rehearsalId: "practice-1",
  virtualEventId: "virtual-1", clockId: "clock-1"};
const options: LateJoinMessageOptions = {occurrenceId: "late-join",
  permittedRoutes: ["organizerEventWhatsapp", "catchEventSms"],
  deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
    minimumRetrySeconds: 1}};

function input(): LateJoinInput {
  return {context, eventId: context.virtualEventId, eventOpen: true,
    departureConfirmed: true, now: 1000000,
    setting: {kind: "enabled", authority: "executeWithinPolicy",
      policyVersion: "v1"},
    policy: {destination: {kind: "itineraryStop", itineraryId: "itinerary",
      permittedStopIds: ["stop-1", "stop-2"]},
    cutoff: {kind: "eventEnd"}, maxMessagesPerEpisode: 4,
    minimumMinutesBetweenMessages: 5, updateOn: "materialGuidanceChange",
    unanswered: "keepUnknownUntilCutoff"},
    guest: {attendeeId: "actor-1", episodeId: "episode-1",
      admission: "admitted", participation: "active",
      attendance: {kind: "known", value: {checkedIn: false}, revision: 1,
        observedAt: 1000000, source: "host"},
      intention: {kind: "unknown"}, deliveryEligibility: "eligible"},
    guidance: {kind: "known", revision: 1, observedAt: 1000000,
      source: "host", value: {revision: 1, destination: {
        kind: "itineraryStop", itineraryId: "itinerary", stopId: "stop-1"},
      materialKey: "stop-1-v1", text: "Meet the group at stop one.",
      validUntil: 2000000}}, lastMessage: null, messagesThisEpisode: 0};
}

function setup() {
  const result = prepareRehearsalLateJoin(input(), context, options);
  assert.ok(result.message);
  const record = result.message;
  const facts: OutboxFacts = {
    gate: {kind: "allow", checkedAt: 1000000, validUntil: 2000000,
      instructionRevision: 1},
    routes: options.permittedRoutes.map((routeId) => ({routeId, state: {
      kind: "eligible", checkedAt: 1000000, validUntil: 2000000,
      permissionRevision: "practice-permission",
      candidate: {mode: "rehearsal", routeId}}})),
  };
  return {record, context, facts, now: 1000000};
}

test("fixed venues, crawl stops and pace checkpoints reuse live policy", () => {
  const kinds = ["fixedPlace", "itineraryStop", "groupCheckpoint"] as const;
  for (const kind of kinds) {
    const current = input();
    assert.equal(current.guidance.kind, "known");
    if (current.guidance.kind !== "known") throw new Error("Fixture");
    if (kind === "fixedPlace") {
      current.policy.destination = {kind, placeId: "venue",
        lateEntry: "allowed"};
      current.guidance.value.destination = current.policy.destination;
    } else if (kind === "groupCheckpoint") {
      current.policy.destination = {kind, routeId: "route", groupId: "pace-1",
        permittedCheckpointIds: ["checkpoint-1"]};
      current.guidance.value.destination = {kind, routeId: "route",
        groupId: "pace-1", checkpointId: "checkpoint-1"};
    }
    const practice = prepareRehearsalLateJoin(current, context, options);
    const live = evaluateLateJoin({...current,
      context: {mode: "live", eventId: current.eventId, organizerId: "owner"}});
    assert.ok(practice.decision.kind === "update" && live.kind === "update");
    assert.deepEqual({...practice.decision, messageKey: live.messageKey}, live);
    assert.notEqual(practice.decision.messageKey, live.messageKey);
    assert.equal(practice.message?.intent.context.mode, "rehearsal");
  }
});

test("departure, attendance and policy readiness cannot be guessed", () => {
  for (const patch of [
    {departureConfirmed: false},
    {guest: {...input().guest, attendance: {kind: "unknown" as const,
      reason: "notConfirmed" as const}}},
    {guest: {...input().guest, participation: "unknown" as const}},
    {guest: {...input().guest, participation: "departed" as const}},
    {setting: {kind: "enabled" as const, authority: "prepare" as const,
      policyVersion: "v1"}},
    {setting: {kind: "disabled" as const, reason: "hostChoice" as const}},
    {eventOpen: false},
  ]) {
    const value = prepareRehearsalLateJoin({...input(), ...patch},
      context, options);
    assert.equal(value.message, null);
  }
});

test("uncertain WhatsApp waits; confirmed failure permits one SMS fallback",
  () => {
    const base = setup();
    const original = structuredClone(base.record);
    let current = dispatchRehearsalMessage({...base,
      outcome: {kind: "unknown", reason: "timeout"}}).record;
    assert.deepEqual(base.record, original);
    const first = current.attempts[0];
    assert.equal(first.mode, "rehearsal");
    assert.equal("binding" in first, false);
    assert.deepEqual(canClaimLiveAttempt(current, first.attemptId,
      base.facts, base.now), {kind: "withheld", reason: "notReserved"});
    const waiting = dispatchRehearsalMessage({...base, record: current,
      now: 1120000, outcome: {kind: "delivered"}});
    assert.equal(waiting.decision.kind, "reconcile");
    assert.equal(waiting.record, current);
    current = recordRehearsalMessageOutcome({context, record: current,
      attemptId: first.attemptId, now: 1120000,
      outcome: {kind: "failed", classification: "technical"}}).record;
    const backoff = dispatchRehearsalMessage({...base, record: current,
      now: 1120500, outcome: {kind: "delivered"}});
    assert.equal(backoff.decision.kind, "wait");
    const fallback = dispatchRehearsalMessage({...base, record: current,
      now: 1121000, outcome: {kind: "delivered"}});
    assert.ok(fallback.decision.kind === "dispatch");
    assert.deepEqual(fallback.decision.candidate,
      {mode: "rehearsal", routeId: "catchEventSms"});
    assert.equal(fallback.record.attempts.length, 2);
    const replay = dispatchRehearsalMessage({...base, record: fallback.record,
      now: 1122000, outcome: {kind: "delivered"}});
    assert.equal(replay.decision.kind, "delivered");
    assert.equal(replay.record, fallback.record);
  });

test("contradictory and duplicate simulated receipts retain live semantics",
  () => {
    const base = setup();
    const sent = dispatchRehearsalMessage({...base,
      outcome: {kind: "delivered"}}).record;
    const report = {record: sent, context, now: base.now + 1,
      attemptId: sent.attempts[0].attemptId};
    const duplicate = recordRehearsalMessageOutcome({...report,
      outcome: {kind: "delivered"}});
    assert.equal(duplicate.record, sent);
    const conflict = recordRehearsalMessageOutcome({...report,
      outcome: {kind: "failed", classification: "technical"}});
    assert.equal(conflict.record.deliveryConflict, true);
    assert.equal(conflict.record.attempts[0].state.kind, "delivered");
    assert.deepEqual(dispatchRehearsalMessage({...base, now: report.now,
      record: conflict.record, outcome: {kind: "accepted"}}).decision,
    {kind: "hostDecision", reason: "conflictingDeliveryEvidence"});
  });

test("policy rejection and a closed event cannot trigger fallback", () => {
  const base = setup();
  const failures = ["policy", "suppressed", "invalidRecipient"] as const;
  for (const classification of failures) {
    const failed = dispatchRehearsalMessage({...base,
      outcome: {kind: "failed", classification}}).record;
    const next = dispatchRehearsalMessage({...base, record: failed,
      now: base.now + 10000, outcome: {kind: "delivered"}});
    assert.equal(next.decision.kind, "hostDecision");
    assert.equal(next.record.attempts.length, 1);
  }
  const closed = dispatchRehearsalMessage({...base,
    facts: {...base.facts, gate: {kind: "stop", reason: "eventClosed"}},
    outcome: {kind: "delivered"}});
  assert.deepEqual(closed.decision, {kind: "stop", reason: "eventClosed"});
  assert.equal(closed.record, base.record);
});

test("guest replies are typed intentions with exact replay, not attendance",
  () => {
    for (const choiceId of ["on-my-way", "not-coming", "need-help"]) {
      const base = setup();
      const scope: ResolvedGuestScope = {context,
        eventId: context.virtualEventId,
        attendeeId: "actor-1", episodeId: "episode-1", validUntil: 2000000,
        source: {kind: "simulation", actionId: "action-1"}};
      const submission = {intentId: base.record.intent.intentId,
        intentRevision: 1, choiceId, requestId: "request-1"};
      const args = {...base, scope, submission, gate: base.facts.gate};
      const first = respondToRehearsalMessage(args);
      assert.equal(first.result.kind, "accepted");
      assert.equal(first.record.lifecycle, "responded");
      assert.equal(first.record.response?.source.kind, "simulation");
      assert.equal("attendance" in first.record, false);
      assert.equal(first.record.attempts.length, 0);
      const replay = respondToRehearsalMessage({...args, record: first.record});
      assert.equal(replay.result.kind, "replayed");
      assert.equal(replay.record, first.record);
      const other = respondToRehearsalMessage({...args, record: first.record,
        submission: {...submission, requestId: "request-2"}});
      assert.deepEqual(other.result,
        {kind: "rejected", reason: "alreadyResponded"});
    }
  });

test("live bindings, other sessions, rewind and forged outcomes fail closed",
  () => {
    const base = setup();
    const dispatch = {...base, outcome: {kind: "delivered" as const}};
    for (const changed of [{rehearsalId: "other"}, {virtualEventId: "other"},
      {clockId: "other"}, {mode: "live"}]) {
      assert.throws(() => dispatchRehearsalMessage({...dispatch,
        context: {...context, ...changed} as typeof context}));
    }
    assert.throws(() => dispatchRehearsalMessage({...dispatch,
      now: base.now - 1}));
    const routes = structuredClone(base.facts.routes);
    if (routes[0].state.kind !== "eligible") throw new Error("Fixture");
    Object.assign(routes[0].state.candidate, {mode: "live"});
    assert.throws(() => dispatchRehearsalMessage({...dispatch,
      facts: {...base.facts, routes}}), /Live delivery authority/u);
    assert.throws(() => dispatchRehearsalMessage({...dispatch,
      outcome: {kind: "failed", classification: "invented"} as never}));
    const foreign = {...base.record, intent: {...base.record.intent,
      context: {mode: "live", eventId: "virtual-1", organizerId: "owner"}},
    } as MessageRecord;
    assert.throws(() => dispatchRehearsalMessage({
      ...dispatch, record: foreign}));
  });

test("replies need the exact synthetic actor, episode and current guidance",
  () => {
    const base = setup();
    const scope: ResolvedGuestScope = {context,
      eventId: context.virtualEventId, attendeeId: "actor-1",
      episodeId: "episode-1", validUntil: 2000000,
      source: {kind: "simulation", actionId: "action-1"}};
    const submission = {intentId: base.record.intent.intentId,
      intentRevision: 1, choiceId: "on-my-way", requestId: "request-1"};
    const args = {...base, scope, submission, gate: base.facts.gate};
    for (const patch of [{attendeeId: "actor-2"}, {episodeId: "episode-2"}]) {
      const result = respondToRehearsalMessage({...args,
        scope: {...scope, ...patch}});
      assert.deepEqual(result.result,
        {kind: "rejected", reason: "scopeMismatch"});
      assert.equal(result.record, base.record);
    }
    assert.throws(() => respondToRehearsalMessage({...args,
      scope: {...scope, source: {kind: "guestWeb", linkId: "live-link"}}}));
    const stale = respondToRehearsalMessage({...args,
      gate: {kind: "allow", checkedAt: base.now, validUntil: 2000000,
        instructionRevision: 2}});
    assert.deepEqual(stale.result, {kind: "rejected", reason: "staleIntent"});
    const expired = respondToRehearsalMessage({...args, now: 2000000});
    assert.deepEqual(expired.result, {kind: "rejected", reason: "expired"});
  });
