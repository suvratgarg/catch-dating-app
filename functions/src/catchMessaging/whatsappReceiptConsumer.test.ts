import assert from "node:assert/strict";
import {test} from "node:test";
import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {FormPaymentTestStore} from
  "../payments/formPayments/formPaymentTestStore";
import {parseCatchWhatsappWebhook, WEBHOOK_RETENTION_MILLIS} from
  "./whatsappWebhookProtocol";
import {catchEndpointHash, catchReplyHash, catchReplyId,
  CATCH_SUPPORT_WINDOW_MS} from
  "./whatsappReply";
import {CATCH_RECEIPTS, CATCH_REPLY_OPERATIONS, readCatchOperation} from
  "./whatsappReplyStore";
import {consumeCatchReplyStatus, advanceCatchDelivery,
  processCatchWhatsappReceipt, reconcileCatchReplyStatuses} from
  "./whatsappReceiptConsumer";

const time = 1800000000000;
const scope = {wabaId: "123", phoneNumberId: "456"};
function fixture() {
  const fake = new FormPaymentTestStore();
  const db = fake as unknown as Firestore;
  const operationId = catchReplyId(scope, "wamid.inbound");
  const operation = readCatchOperation({schemaVersion: 1, operationId,
    purpose: "serviceSupport", source: "reviewedInboundSupportRequest",
    ...scope, recipientUid: "participant", actorUid: "agent",
    endpointHash: catchEndpointHash("+919000000001"),
    inboundEventId: "cwhe_" + "a".repeat(64), inboundMessageId: "wamid.inbound",
    inboundTextHash: "a".repeat(64), bodyHash: "b".repeat(64),
    materialHash: "c".repeat(64), reviewedAtMillis: time,
    deadlineMillis: time + CATCH_SUPPORT_WINDOW_MS, state: "completed",
    providerMessageId: "wamid.outbound", deliveryStatus: "accepted",
    deliveryEventId: null, deliveryAtMillis: null,
    createdAtMillis: time, updatedAtMillis: time});
  const key = CATCH_REPLY_OPERATIONS + "/" + operationId;
  fake.records.set(key, {...operation});
  function receipt(status: string, patch: Record<string, unknown> = {}) {
    const raw = Buffer.from(JSON.stringify({object: "whatsapp_business_account",
      entry: [{id: scope.wabaId, changes: [{field: "messages", value: {
        messaging_product: "whatsapp", metadata: {phone_number_id: "456"},
        statuses: [{id: "wamid.outbound", status, timestamp:
          String(time / 1000 + 1), recipient_id: "919000000001"}],
      }}]}]}));
    const event = parseCatchWhatsappWebhook(raw, scope)[0];
    const record = {...event, receivedAtMillis: time + 2000,
      expiresAt: Timestamp.fromMillis(time + WEBHOOK_RETENTION_MILLIS),
      ...patch};
    fake.records.set(CATCH_RECEIPTS + "/" + event.eventId, record);
    return event.eventId;
  }
  return {fake, db, key, operation, operationId, receipt};
}

test("delivery projection advances without mutating immutable status receipts",
  async () => {
    const f = fixture();
    const delivered = f.receipt("delivered");
    const original = {...f.fake.records.get(CATCH_RECEIPTS + "/" + delivered)!};
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId, delivered,
      time + 3000), "applied");
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId, delivered,
      time + 3000), "unchanged");
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
      f.receipt("sent"), time + 3000), "unchanged");
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
      f.receipt("failed"), time + 3000), "unchanged");
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
      f.receipt("read"), time + 3000), "applied");
    assert.equal(f.fake.records.get(f.key)?.deliveryStatus, "read");
    assert.deepEqual(f.fake.records.get(CATCH_RECEIPTS + "/" + delivered),
      original);
    assert.ok([...f.fake.records.keys()].every((key) =>
      key.startsWith(CATCH_RECEIPTS + "/") ||
      key.startsWith(CATCH_REPLY_OPERATIONS + "/")));
  });

test("status must match sender, endpoint and saved message ID",
  async () => {
    for (const patch of [{wabaId: "999"}, {phoneNumberId: "999"},
      {participantId: "919000000002"}, {messageId: "wamid.foreign"},
      {errorCodes: [131026]},
      {providerTimestampSeconds: String(time / 1000 - 1)},
      {providerTimestampSeconds: String(time / 1000 + 50)},
      {expiresAt: Timestamp.fromMillis(time)}]) {
      const f = fixture();
      assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
        f.receipt("delivered", patch), time + 3000), "unmatched");
      assert.equal(f.fake.records.get(f.key)?.deliveryStatus, "accepted");
    }
  });

test("early status is deferred and can be consumed after saving message ID",
  async () => {
    const f = fixture();
    f.fake.records.set(f.key, {...f.operation, state: "claimed",
      providerMessageId: null, deliveryStatus: "pending"});
    const eventId = f.receipt("delivered");
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
      eventId, time + 3000), "deferred");
    f.fake.records.set(f.key, {...f.operation});
    assert.equal(await consumeCatchReplyStatus(f.db, f.operationId,
      eventId, time + 3000), "applied");
  });

test("arrival order and failure cannot override delivery proof",
  () => {
    assert.equal(advanceCatchDelivery("accepted", "failed"), "failed");
    assert.equal(advanceCatchDelivery("failed", "sent"), "failed");
    assert.equal(advanceCatchDelivery("failed", "delivered"), "delivered");
    assert.equal(advanceCatchDelivery("read", "failed"), "read");
  });

test("receipt dispatcher and saved-operation reconciliation close early race",
  async () => {
    const f = fixture();
    f.fake.records.set(f.key, {...f.operation, state: "claimed",
      providerMessageId: null, deliveryStatus: "pending"});
    const eventId = f.receipt("delivered");
    assert.equal(await processCatchWhatsappReceipt(f.db, eventId, scope,
      time + 3000), "deferred");
    f.fake.records.set(f.key, {...f.operation});
    assert.equal(await reconcileCatchReplyStatuses(f.db, f.operationId,
      scope, time + 3000), 1);
    assert.equal(await processCatchWhatsappReceipt(f.db, eventId, scope,
      time + 3000), "unchanged");
    assert.equal(await reconcileCatchReplyStatuses(f.db, f.operationId,
      scope, time + 3000), 0);
    assert.equal(await processCatchWhatsappReceipt(f.db, f.receipt("read"),
      scope, time + 3000), "applied");
    assert.equal(f.fake.records.get(f.key)?.deliveryStatus, "read");
  });

test("dispatch lookup is scoped and rejects ambiguous ownership",
  async () => {
    const f = fixture(); const eventId = f.receipt("delivered");
    f.fake.records.set(CATCH_REPLY_OPERATIONS + "/foreign-sender", {
      ...f.operation, phoneNumberId: "999",
    });
    f.fake.records.set(CATCH_REPLY_OPERATIONS + "/foreign-endpoint", {
      ...f.operation, endpointHash: catchEndpointHash("+919000000002"),
    });
    assert.equal(await processCatchWhatsappReceipt(f.db, eventId,
      {...scope, phoneNumberId: "999"}, time + 3000), "unmatched");
    assert.equal(await processCatchWhatsappReceipt(f.db, eventId, scope,
      time + 3000), "applied");
    f.fake.records.set(CATCH_REPLY_OPERATIONS + "/ambiguous", {...f.operation});
    await assert.rejects(processCatchWhatsappReceipt(f.db, eventId, scope,
      time + 3000), /Ambiguous/);
  });

test("reconciliation overflow fails before publishing a partial projection",
  async () => {
    const f = fixture(); const eventId = f.receipt("delivered");
    const receipt = f.fake.records.get(CATCH_RECEIPTS + "/" + eventId)!;
    for (let index = 0; index < 50; index++) {
      const id = "cwhe_" + catchReplyHash(index);
      f.fake.records.set(CATCH_RECEIPTS + "/" + id, {...receipt, eventId: id});
    }
    await assert.rejects(reconcileCatchReplyStatuses(f.db, f.operationId,
      scope, time + 3000), /exceeds bounded scope/);
    assert.equal(f.fake.records.get(f.key)?.deliveryStatus, "accepted");
  });
