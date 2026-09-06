import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import type {Firestore} from "firebase-admin/firestore";
import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import {FakeFirestore} from "../../operations/testFirestore";
import {
  EVENT_ASSISTANCE_MESSAGES, FirestoreMessageOutbox, ReadOutboxFacts,
} from "./firestoreMessageOutbox";
import type {OutboxFacts, LiveAttempt, MessageRecord} from "./messageOutbox";
import {assistanceMessageId, parseMessageRecord} from "./messageOutbox";
import type {VerifiedDeliveryReceipt} from "./deliveryReceipts";

function message(): MessageIntent {
  return {schemaVersion: 1, intentId: "notice:1", revision: 1,
    context: {mode: "live", organizerId: "organizer-1", eventId: "event-1"},
    eventId: "event-1", attendeeId: "guest-1", episodeId: "episode-1",
    workflow: {kind: "planChangeCommunication", occurrenceId: "change-1"},
    createdAt: 1000000, expiresAt: 2000000,
    permittedRoutes: ["organizerEventWhatsapp", "catchEventSms"],
    deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
      minimumRetrySeconds: 1},
    kind: "operationalNotice", noticeKind: "planChanged",
    title: "The meeting point has changed", body: "Use the updated entrance.",
    instructionRevision: 1,
    choices: [{choiceId: "ack", label: "Got it", value: {
      kind: "acknowledge", instructionRevision: 1,
    }}]};
}

function facts(): OutboxFacts {
  const bindings: LiveAttempt["binding"][] = [
    {routeId: "organizerEventWhatsapp", transport: "whatsapp",
      provider: "meta", senderIdentity: "organizerManaged", senderId: "wa-1",
      bindingRevision: 1, recipientEndpointId: "endpoint-1",
      fallbackOwner: "catch"},
    {routeId: "catchEventSms", transport: "sms", provider: "sinch",
      senderIdentity: "catchPlatform", senderId: "sms-1",
      bindingRevision: 1, recipientEndpointId: "endpoint-2",
      fallbackOwner: "catch"},
  ];
  return {gate: {kind: "allow", checkedAt: 1000000,
    validUntil: 2000000, instructionRevision: 1},
  routes: bindings.map((binding) => ({routeId: binding.routeId,
    state: {kind: "eligible", checkedAt: 1000000, validUntil: 2000000,
      permissionRevision: "permission-1", candidate: {mode: "live", binding}},
  }))};
}

function harness() {
  const db = new FakeFirestore();
  const clock = {now: 1000000};
  const source = {facts: facts(), delayMs: 0};
  const readFacts: ReadOutboxFacts = async (transaction) => {
    // This dependency participates in the same transaction as the reservation.
    await transaction.get((db as unknown as Firestore)
      .collection("testEventFacts").doc("event-1"));
    clock.now += source.delayMs;
    return structuredClone(source.facts);
  };
  const outbox = new FirestoreMessageOutbox(db as unknown as Firestore,
    readFacts, () => clock.now);
  return {db, clock, source, outbox, readFacts};
}

function receipt(
  record: MessageRecord, state: VerifiedDeliveryReceipt["state"]
): VerifiedDeliveryReceipt {
  const attempt = record.attempts.at(-1);
  assert.ok(attempt?.mode === "live");
  return {attemptId: attempt.attemptId, ...attempt.binding,
    providerEventId: "receipt-" + state.kind, receivedAt: state.at, state};
}

test("outbox enqueue is immutable and context scoped", async () => {
  const {outbox, clock} = harness();
  const intent = message();
  const results = await Promise.all(Array.from({length: 8}, () =>
    outbox.enqueue(intent)));
  assert.ok(results.every((r) => r.revision === 0));
  await assert.rejects(outbox.enqueue({...intent, body: "Changed content"}),
    /other content/);
  const other = message();
  assert.ok(other.context.mode === "live");
  other.context.organizerId = "organizer-2";
  assert.notEqual(assistanceMessageId(other), results[0].messageId);
  const second = await outbox.enqueue(other);
  const firstReserved = await outbox.reserve(results[0].messageId);
  const secondReserved = await outbox.reserve(second.messageId);
  assert.notEqual(firstReserved.record.attempts[0].attemptId,
    secondReserved.record.attempts[0].attemptId);
  clock.now = intent.expiresAt + 1;
  assert.deepEqual(await outbox.enqueue(intent), firstReserved.record);
  await assert.rejects(outbox.enqueue({...intent, intentId: "notice:2"}),
    /expired/);
});

test("outbox contention reserves and claims one provider attempt", async () => {
  const {outbox, db, clock, readFacts} = harness();
  const initial = await outbox.enqueue(message());
  const reserved = await Promise.all(Array.from({length: 12}, () =>
    outbox.reserve(initial.messageId)));
  assert.equal(reserved.filter((r) =>
    r.decision.kind === "dispatch").length, 1);
  const record = await outbox.get(initial.messageId);
  assert.ok(record);
  assert.equal(record.attempts.length, 1);
  const claims = await Promise.all(Array.from({length: 12}, () =>
    outbox.claimLiveDispatch(record.messageId, record.attempts[0].attemptId)));
  assert.equal(claims.filter((r) => r.kind === "claimed").length, 1);
  const restarted = new FirestoreMessageOutbox(db as unknown as Firestore,
    readFacts, () => clock.now);
  assert.equal((await restarted.reserve(record.messageId)).decision.kind,
    "reconcile");
  assert.equal((await restarted.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId)).kind, "withheld");
});

test("failed transaction never hands out a dispatch permit", async () => {
  const {db, outbox} = harness();
  const initial = await outbox.enqueue(message());
  db.failNextCommit = true;
  await assert.rejects(outbox.reserve(initial.messageId), /interruption/);
  assert.equal((await outbox.get(initial.messageId))?.attempts.length, 0);
  const {record} = await outbox.reserve(initial.messageId);
  db.failNextCommit = true;
  await assert.rejects(outbox.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId), /interruption/);
  assert.equal((await outbox.get(record.messageId))?.attempts[0].state.kind,
    "reserved");
  assert.equal((await outbox.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId)).kind, "claimed");
});

test("dispatch re-reads current authority", async () => {
  for (const change of ["permission", "sender", "instruction", "present"]) {
    const {outbox, source} = harness();
    const initial = await outbox.enqueue(message());
    const {record} = await outbox.reserve(initial.messageId);
    const route = source.facts.routes[0];
    assert.ok(route.state.kind === "eligible");
    assert.ok(route.state.candidate.mode === "live");
    assert.ok(source.facts.gate.kind === "allow");
    if (change === "permission") {
      route.state.permissionRevision = "permission-2";
    }
    if (change === "sender") route.state.candidate.binding.bindingRevision++;
    if (change === "instruction") source.facts.gate.instructionRevision++;
    if (change === "present") {
      source.facts.gate = {kind: "stop", reason: "guestPresent"};
    }
    const result = await outbox.claimLiveDispatch(record.messageId,
      record.attempts[0].attemptId);
    assert.ok(result.kind === "withheld");
    assert.equal(result.reason, "authorityChanged", change);
    assert.equal(result.record.revision, record.revision);
  }
});

test("slow reads cannot extend send permission", async () => {
  const {source, outbox} = harness();
  const initial = await outbox.enqueue(message());
  assert.ok(source.facts.gate.kind === "allow");
  source.facts.gate.validUntil = 1000010;
  source.delayMs = 11;
  const result = await outbox.reserve(initial.messageId);
  assert.equal(result.decision.kind, "refreshFacts");
  assert.equal(result.record.attempts.length, 0);
});

test("confirmed failure enables bounded fallback", async () => {
  const {outbox, clock} = harness();
  const initial = await outbox.enqueue(message());
  const {record} = await outbox.reserve(initial.messageId);
  await outbox.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId);
  const evidence = receipt(record, {kind: "failed", at: clock.now,
    providerMessageId: "wa-message-1", classification: "technical",
    evidenceId: "delivery-failed-1"});
  const failed = await outbox.recordReceipt(record.messageId, evidence);
  assert.equal((await outbox.recordReceipt(record.messageId, evidence))
    .record.revision, failed.record.revision);
  assert.equal((await outbox.reserve(record.messageId)).decision.kind, "wait");
  clock.now += 1000;
  const second = await outbox.reserve(record.messageId);
  assert.equal(second.record.attempts.length, 2);
  const attempt = second.record.attempts[1];
  assert.ok(attempt.mode === "live");
  assert.equal(attempt.binding.routeId, "catchEventSms");
});

test("late receipts reconcile closed messages", async () => {
  const {outbox, clock} = harness();
  const initial = await outbox.enqueue(message());
  const {record} = await outbox.reserve(initial.messageId);
  const claimed = await outbox.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId);
  assert.ok(claimed.kind === "claimed");
  await outbox.close(record.messageId, claimed.record.revision, "cancelled");
  clock.now = message().expiresAt + 5000;
  const delivered = await outbox.recordReceipt(record.messageId, receipt(record,
    {kind: "delivered", at: clock.now, providerMessageId: "wa-message-1"}));
  assert.equal(delivered.record.lifecycle, "cancelled");
  assert.equal(delivered.record.attempts[0].state.kind, "delivered");
  const next = await outbox.reserve(record.messageId);
  assert.deepEqual(next.decision, {kind: "stop", reason: "cancelled"});
});

test("conflicting evidence stops fallback dispatch", async () => {
  const {outbox, clock} = harness();
  const initial = await outbox.enqueue(message());
  const {record} = await outbox.reserve(initial.messageId);
  await outbox.recordReceipt(record.messageId, receipt(record, {kind: "failed",
    at: clock.now, classification: "technical", evidenceId: "failed-1",
    providerMessageId: "wa-message-1"}));
  clock.now += 1000;
  const fallback = await outbox.reserve(record.messageId);
  const conflict = await outbox.recordReceipt(record.messageId, receipt(record,
    {kind: "delivered", at: clock.now, providerMessageId: "wa-message-1"}));
  assert.equal(conflict.record.deliveryConflict, true);
  const result = await outbox.claimLiveDispatch(record.messageId,
    fallback.record.attempts[1].attemptId);
  assert.ok(result.kind === "withheld");
  assert.equal(result.reason, "deliveryConflict");
  assert.deepEqual((await outbox.reserve(record.messageId)).decision,
    {kind: "hostDecision", reason: "conflictingDeliveryEvidence"});
});

test("rehearsal cannot claim a live dispatch", async () => {
  const {outbox, source, clock} = harness();
  const intent = message();
  intent.context = {mode: "rehearsal", rehearsalId: "practice-1",
    virtualEventId: intent.eventId, clockId: "clock-1"};
  source.facts.routes = source.facts.routes.map((r) => {
    assert.ok(r.state.kind === "eligible");
    return {...r, state: {...r.state, candidate: {
      mode: "rehearsal", routeId: r.routeId,
    }}};
  });
  const initial = await outbox.enqueue(intent);
  const {record} = await outbox.reserve(initial.messageId);
  const result = await outbox.claimLiveDispatch(record.messageId,
    record.attempts[0].attemptId);
  assert.ok(result.kind === "withheld");
  assert.equal(result.reason, "rehearsal");
  await assert.rejects(outbox.recordReceipt(record.messageId, {
    attemptId: record.attempts[0].attemptId, senderId: "wa-1",
    bindingRevision: 1, recipientEndpointId: "endpoint-1",
    routeId: "organizerEventWhatsapp", providerEventId: "receipt-1",
    receivedAt: clock.now,
    state: {kind: "accepted", at: clock.now, providerMessageId: "wa-1"},
  }), /no live message attempt/);
});

test("outbox rejects identity and revision drift", async () => {
  const {db, outbox} = harness();
  const initial = await outbox.enqueue(message());
  const {record} = await outbox.reserve(initial.messageId);
  await assert.rejects(outbox.close(record.messageId, 0, "cancelled"),
    /revision/);
  assert.throws(() => parseMessageRecord({...record,
    messageId: "outbox:" + "0".repeat(64)}), /identity/);
  db.write(EVENT_ASSISTANCE_MESSAGES + "/" + record.messageId,
    {...record, attempts: [{...record.attempts[0], ordinal: 2}]});
  await assert.rejects(outbox.get(record.messageId), /Incomplete/);
});

test("Firestore transactions arbitrate competing dispatch workers", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
  timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const key = randomUUID();
  const app = initializeApp({projectId: "demo-catch-rules"}, "outbox-" + key);
  const db = getFirestore(app);
  const source = db.collection("testEventFacts").doc(key);
  const intent = {...message(), intentId: "notice:" + key};
  const messageId = assistanceMessageId(intent);
  try {
    await source.set(facts());
    const outbox = new FirestoreMessageOutbox(db, async (transaction) => {
      const snapshot = await transaction.get(source);
      assert.ok(snapshot.exists);
      return snapshot.data() as OutboxFacts;
    }, () => 1000000);
    await outbox.enqueue(intent);
    const reservations = await Promise.all(Array.from({length: 8}, () =>
      outbox.reserve(messageId)));
    assert.equal(reservations.filter((r) =>
      r.decision.kind === "dispatch").length, 1);
    const record = await outbox.get(messageId);
    assert.ok(record);
    assert.equal(record.attempts.length, 1);
    const permits = await Promise.all(Array.from({length: 8}, () =>
      outbox.claimLiveDispatch(messageId, record.attempts[0].attemptId)));
    assert.equal(permits.filter((p) => p.kind === "claimed").length, 1);
    assert.equal((await outbox.reserve(messageId)).decision.kind, "reconcile");
  } finally {
    await db.collection(EVENT_ASSISTANCE_MESSAGES).doc(messageId).delete();
    await source.delete();
    await deleteApp(app);
  }
});
