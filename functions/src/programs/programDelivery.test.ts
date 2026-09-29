import assert from "node:assert/strict";
import test from "node:test";
import type {Firestore} from "firebase-admin/firestore";
import type {ProgramDeliveryMessageIntent as MessageIntent} from
  "../shared/generated/programDeliveryMessageIntent";
import {FakeFirestore} from "../operations/testFirestore";
import {FirestoreDeliveryOutbox} from
  "../delivery/firestoreDeliveryOutbox";
import type {VerifiedCoreReceipt} from "../delivery/deliveryCore";
import {
  LiveAttempt, MessageRecord, parseProgramDeliveryRecord,
  programDeliveryAdapter, programDeliveryMessageId, ProviderBinding,
} from "./programDelivery";

function reminder(): MessageIntent {
  return {schemaVersion: 1, intentId: "reminder:90day:run-1:guest-1",
    revision: 1,
    context: {mode: "live", programId: "program-1",
      organizerId: "organizer-1"},
    programId: "program-1",
    recipient: {kind: "guest", recipientKey: "guest-1"},
    workflow: {kind: "programMoment", momentId: "moment-1",
      runId: "run-1"},
    createdAt: 1_000_000, expiresAt: 2_000_000,
    permittedRoutes: ["organizerProgramWhatsapp", "catchProgramActivity"],
    deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
      minimumRetrySeconds: 1},
    kind: "programReminder",
    title: "Travel window opens soon",
    body: "Share your arrival details before the program begins.",
    instructionRevision: 7};
}

function facts() {
  const bindings: ProviderBinding[] = [
    {routeId: "organizerProgramWhatsapp", transport: "whatsapp",
      senderIdentity: "organizerManaged", provider: "meta",
      senderId: "wa-1", bindingRevision: 1,
      recipientEndpointId: "endpoint-1", fallbackOwner: "catch"},
    {routeId: "catchProgramActivity", transport: "catchApp",
      senderIdentity: "catchPlatform", provider: "catchActivity",
      senderId: "activity-1", bindingRevision: 1,
      recipientEndpointId: "endpoint-2", fallbackOwner: "catch"},
  ];
  return {gate: {kind: "allow" as const, checkedAt: 1_000_000,
    validUntil: 2_000_000, instructionRevision: 7},
  routes: bindings.map((binding) => ({routeId: binding.routeId,
    state: {kind: "eligible" as const, checkedAt: 1_000_000,
      validUntil: 2_000_000, permissionRevision: "permission-1",
      candidate: {mode: "live" as const, binding}}}))};
}

function harness(sourceFacts = facts()) {
  const db = new FakeFirestore();
  const clock = {now: 1_000_000};
  const source = {facts: sourceFacts};
  const outbox = new FirestoreDeliveryOutbox(db as unknown as Firestore,
    programDeliveryAdapter, async () => structuredClone(source.facts),
    () => clock.now);
  return {db, clock, source, outbox};
}

function receipt(record: MessageRecord,
  state: VerifiedCoreReceipt<ProviderBinding>["state"]
): VerifiedCoreReceipt<ProviderBinding> {
  const attempt = record.attempts.at(-1) as LiveAttempt;
  assert.ok(attempt);
  return {attemptId: attempt.attemptId, ...attempt.binding,
    providerEventId: "receipt-" + state.kind, receivedAt: state.at, state};
}

test("program reminder traverses reserve/claim/receipt on the shared core",
  async () => {
    const h = harness();
    const record = await h.outbox.enqueue(reminder());
    assert.equal(record.lifecycle, "active");
    assert.equal(record.messageId, programDeliveryMessageId(reminder()));
    // Concurrent reservers contend on one reservation.
    const reserved = await Promise.all(Array.from({length: 8}, () =>
      h.outbox.reserve(record.messageId)));
    assert.equal(reserved.filter((r) =>
      r.decision.kind === "dispatch").length, 1);
    const withAttempt = await h.outbox.get(record.messageId);
    assert.ok(withAttempt);
    assert.equal(withAttempt.attempts.length, 1);
    const attempt = withAttempt.attempts[0];
    assert.equal(attempt.binding.routeId, "organizerProgramWhatsapp");
    assert.equal(attempt.authorization.instructionRevision, 7);
    // Concurrent claimants get exactly one permit.
    const claims = await Promise.all(Array.from({length: 8}, () =>
      h.outbox.claimLiveDispatch(record.messageId, attempt.attemptId)));
    assert.equal(claims.filter((c) => c.kind === "claimed").length, 1);
    // The claimed attempt is reconcilable until a receipt lands.
    const claimed = await h.outbox.get(record.messageId);
    assert.ok(claimed);
    assert.equal(claimed.attempts[0].state.kind, "unknown");
    h.clock.now += 1;
    const applied = await h.outbox.recordReceipt(record.messageId,
      receipt(claimed, {kind: "accepted", at: h.clock.now,
        providerMessageId: "wamid-1"}));
    assert.equal(applied.disposition, "applied");
    h.clock.now += 1;
    const delivered = await h.outbox.recordReceipt(record.messageId,
      receipt(applied.record, {kind: "delivered", at: h.clock.now,
        providerMessageId: "wamid-1"}));
    assert.equal(delivered.disposition, "applied");
    assert.equal(delivered.record.attempts[0].state.kind, "delivered");
  });

test("program reminder enforces authority revision and late-receipt conflicts",
  async () => {
    const h = harness();
    const record = await h.outbox.enqueue(reminder());
    // Facts moved past the intent's instruction revision before reserve.
    h.source.facts = {...facts(),
      gate: {kind: "allow", checkedAt: 1_000_000, validUntil: 2_000_000,
        instructionRevision: 8}};
    const stale = await h.outbox.reserve(record.messageId);
    assert.deepEqual(stale.decision,
      {kind: "stop", reason: "superseded"});
    assert.equal(stale.record.attempts.length, 0);

    // Conflicting provider evidence blocks fallback and flags the record.
    const h2 = harness();
    const r2 = await h2.outbox.enqueue(reminder());
    await h2.outbox.reserve(r2.messageId);
    const a = (await h2.outbox.get(r2.messageId))!.attempts[0];
    await h2.outbox.claimLiveDispatch(r2.messageId, a.attemptId);
    h2.clock.now += 1;
    const afterDelivered = await h2.outbox.recordReceipt(r2.messageId,
      receipt((await h2.outbox.get(r2.messageId))!, {
        kind: "delivered", at: h2.clock.now,
        providerMessageId: "wamid-1"}));
    h2.clock.now += 1;
    const conflicting = await h2.outbox.recordReceipt(r2.messageId,
      receipt(afterDelivered.record, {
        kind: "failed", at: h2.clock.now,
        providerMessageId: "wamid-1", classification: "technical",
        evidenceId: "evidence-1"}));
    assert.equal(conflicting.disposition, "conflictingEvidence");
    assert.equal(conflicting.record.deliveryConflict, true);
    const blocked = await h2.outbox.claimLiveDispatch(r2.messageId,
      "attempt:anything");
    assert.equal(blocked.kind, "withheld");
    const decided = await h2.outbox.reserve(r2.messageId);
    assert.deepEqual(decided.decision,
      {kind: "hostDecision", reason: "conflictingDeliveryEvidence"});
  });

test("program reminder records validate identity and revision fences",
  async () => {
    const h = harness();
    const record = await h.outbox.enqueue(reminder());
    assert.throws(() => parseProgramDeliveryRecord({...record,
      messageId: "outbox:" + "0".repeat(64)}), /identity|Invalid/);
    assert.throws(() => parseProgramDeliveryRecord({...record,
      intent: {...record.intent, context: {mode: "live",
        programId: "program-2", organizerId: "organizer-1"}}}),
    /identity|Invalid/);
    // A moved program date surfaces as a supersede close, not a new record.
    const closed = await h.outbox.close(record.messageId, record.revision,
      "superseded");
    assert.equal(closed.lifecycle, "superseded");
    await assert.rejects(
      h.outbox.close(record.messageId, record.revision, "cancelled"),
      /revision|lifecycle/);
    const stopped = await h.outbox.reserve(record.messageId);
    assert.deepEqual(stopped.decision,
      {kind: "stop", reason: "superseded"});
  });
