import assert from "node:assert/strict";
import test from "node:test";
import {createHmac, randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {FakeFirestore} from "../operations/testFirestore";
import {ingestMetaWhatsappWebhook, parseMetaWhatsappWebhook} from
  "./organizerWhatsappWebhook";
import {validateOrganizerMessagingWebhookEventDocument} from
  "../shared/generated/validators/organizerMessagingWebhookEventDocument";
import {WHATSAPP_ENDPOINT_STOPS, parseWhatsappStop} from
  "../shared/organizerWhatsappStops";

test("webhook parsing stores status metadata without message content", () => {
  const events = parseMetaWhatsappWebhook(Buffer.from(JSON.stringify({
    entry: [{changes: [{value: {
      metadata: {phone_number_id: "123456"},
      statuses: [{
        id: "wamid.1",
        status: "delivered",
        timestamp: "1720000000",
        recipient_id: "919999999999",
      }],
    }}]}],
  })));
  assert.equal(events.length, 1);
  assert.equal(events[0].providerMessageId, "wamid.1");
  assert.equal(events[0].deliveryStatus, "delivered");
  assert.equal(events[0].inboundBody, null);
  assert.match(events[0].endpointHash ?? "", /^[a-f0-9]{64}$/);
});

test("webhook parsing recognizes STOP and retains bounded inbound text", () => {
  const rawBody = Buffer.from(JSON.stringify({
    entry: [{changes: [{value: {
      metadata: {phone_number_id: "123456"},
      messages: [{
        id: "wamid.inbound.1",
        from: "919999999999",
        timestamp: "1720000000",
        context: {id: "wamid.outbound.1"},
        type: "text",
        text: {body: " STOP "},
      }],
    }}]}],
  }));
  const events = parseMetaWhatsappWebhook(rawBody);
  assert.equal(events[0].eventKind, "inbound");
  assert.equal(events[0].isStop, true);
  assert.equal(events[0].hasReply, true);
  assert.equal(events[0].contextProviderMessageId, "wamid.outbound.1");
  assert.equal(events[0].inboundBody, "STOP");
});

test("unknown webhook shapes are ignored safely", () => {
  assert.deepEqual(parseMetaWhatsappWebhook(Buffer.from("not-json")), []);
  assert.deepEqual(parseMetaWhatsappWebhook(Buffer.from("{}")), []);
});

const appSecret = "fixture-meta-signing-secret";
function webhook(messages: object[] = [], statuses: object[] = [],
  phoneNumberId = "123456") {
  return Buffer.from(JSON.stringify({object: "whatsapp_business_account",
    entry: [{id: "700123", changes: [{field: "messages", value: {
      messaging_product: "whatsapp", metadata: {phone_number_id: phoneNumberId},
      messages, statuses,
    }}]}]}));
}
function incoming(value: object) {
  return {id: "wamid.inbound.choice", from: "919999999999",
    timestamp: "1720000000", context: {id: "wamid.outbound.event"}, ...value};
}
function signature(rawBody: Buffer) {
  return "sha256=" + createHmac("sha256", appSecret).update(rawBody)
    .digest("hex");
}
function sender() {
  return {provider: "metaCloudApi", phoneNumberId: "123456", wabaId: "700123",
    organizerId: "organizer-one", channel: "whatsapp", status: "active"};
}

test("signed STOP and its queue receipt commit together without a CRM contact",
  async () => {
    const fake = new FakeFirestore();
    fake.write("organizerSenderConnections/connection-one", sender());
    const rawBody = webhook([incoming({type: "text", text: {body: "STOP"}})]);
    const params = {db: fake as unknown as FirebaseFirestore.Firestore,
      rawBody, signatureHeader: signature(rawBody), appSecret,
      now: Timestamp.fromMillis(1720000001000)};
    const before = fake.entries();
    fake.failNextCommit = true;
    await assert.rejects(ingestMetaWhatsappWebhook(params), /interruption/);
    assert.deepEqual(fake.entries(), before);
    assert.equal(await ingestMetaWhatsappWebhook(params), 1);
    assert.equal(await ingestMetaWhatsappWebhook(params), 0);
    const records = fake.entries().filter(([p]) =>
      p.startsWith(WHATSAPP_ENDPOINT_STOPS + "/"));
    assert.equal(records.length, 1);
    const stop = parseWhatsappStop(records[0][1]);
    assert.equal(stop.revision, 1);
    assert.equal(stop.stoppedAt, 1720000000000);
    assert.equal(stop.organizerId, "organizer-one");
    assert.equal(JSON.stringify(stop).includes("919999999999"), false);
    assert.equal(fake.entries().some(([p]) =>
      p.startsWith("organizerContacts/")), false);
  });

test("native labels, unsigned STOP and unmatched senders create no STOP record",
  async () => {
    for (const kind of ["native", "unsigned", "unmatched"]) {
      const fake = new FakeFirestore();
      if (kind !== "unmatched") {
        fake.write("organizerSenderConnections/connection-one", sender());
      }
      const rawBody = webhook([incoming(kind === "native" ? {type: "button",
        button: {payload: "STOP", text: "STOP"}} :
        {type: "text", text: {body: "STOP"}})]);
      const params = {db: fake as unknown as FirebaseFirestore.Firestore,
        rawBody, signatureHeader: kind === "unsigned" ? undefined :
          signature(rawBody), appSecret,
        now: Timestamp.fromMillis(1720000001000)};
      if (kind === "unsigned") {
        await assert.rejects(ingestMetaWhatsappWebhook(params), /signature/);
      } else await ingestMetaWhatsappWebhook(params);
      assert.equal(fake.entries().some(([p]) =>
        p.startsWith(WHATSAPP_ENDPOINT_STOPS + "/")), false, kind);
    }
  });

test("native choices retain their exact discriminator and identifier",
  () => {
    const cases = [
      {input: {type: "button",
        button: {payload: "event-choice:one", text: "Go"}},
      expected: {kind: "templateQuickReply", payload: "event-choice:one",
        label: "Go"}},
      {input: {type: "interactive", interactive: {type: "button_reply",
        button_reply: {id: "event-choice:two", title: "Go"}}},
      expected: {kind: "replyButton", id: "event-choice:two", label: "Go"}},
      {input: {type: "interactive", interactive: {type: "list_reply",
        list_reply: {id: "event-choice:three", title: "Go",
          description: "Meet at the next stop"}}},
      expected: {kind: "listReply", id: "event-choice:three", label: "Go",
        description: "Meet at the next stop"}},
    ];
    for (const {input, expected} of cases) {
      const [event] = parseMetaWhatsappWebhook(webhook([incoming(input)]));
      assert.deepEqual(event.inboundReply, expected);
      assert.equal(event.inboundBody, "Go");
      assert.equal(event.providerAccountId, "700123");
      assert.equal(event.phoneNumberId, "123456");
      assert.equal(event.contextProviderMessageId, "wamid.outbound.event");
      assert.equal(event.isStop, false);
    }
  });

test("native labels and mismatched message shapes cannot become STOP commands",
  () => {
    for (const value of [
      {type: "button", button: {payload: "STOP", text: "STOP"}},
      {type: "interactive", interactive: {type: "button_reply",
        button_reply: {id: "STOP", title: "STOP"}}},
      {type: "image", text: {body: "STOP"}},
    ]) {
      const [event] = parseMetaWhatsappWebhook(webhook([incoming(value)]));
      assert.equal(event.isStop, false);
    }
    const [text] = parseMetaWhatsappWebhook(webhook([
      incoming({type: "text", text: {body: " STOP "}}),
    ]));
    assert.equal(text.isStop, true);
    assert.equal(text.inboundReply, null);
  });

test("malformed native identifiers are never truncated into choices",
  () => {
    for (const value of [
      {type: "button", button: {payload: "x".repeat(1025), text: "On my way"}},
      {type: "button", button: {payload: 12, text: "On my way"}},
      {type: "button", button: {payload: "one", text: ""}},
      {type: "interactive", interactive: {type: "button_reply",
        button_reply: {id: ["one"], title: "On my way"}}},
      {type: "interactive", interactive: {type: "nfm_reply",
        button_reply: {id: "one", title: "On my way"}}},
    ]) {
      const [event] = parseMetaWhatsappWebhook(webhook([incoming(value)]));
      assert.equal(event.inboundReply, null);
      assert.equal(event.inboundBody, null);
    }
  });

test("status correlation is exact, bounded and absent from inbound replies",
  () => {
    const status = {id: "wamid.sent", status: "delivered",
      timestamp: "1720000000", recipient_id: "919999999999"};
    const values = ["event-attempt:one", " x ", "x".repeat(513), {}, null];
    for (const value of values) {
      const [event] = parseMetaWhatsappWebhook(webhook([], [
        {...status, biz_opaque_callback_data: value},
      ]));
      assert.equal(event.callbackData, typeof value === "string" &&
        value.length <= 512 ? value : null);
      assert.equal(event.inboundReply, null);
    }
    const [inbound] = parseMetaWhatsappWebhook(webhook([incoming({
      type: "text", text: {body: "hello"}, biz_opaque_callback_data: "forged",
    })]));
    assert.equal(inbound.callbackData, null);
  });

test("webhook queue retains native evidence and rejects unsigned writes",
  async () => {
    const fake = new FakeFirestore();
    fake.write("organizerSenderConnections/connection-one", sender());
    const db = fake as unknown as FirebaseFirestore.Firestore;
    const rawBody = webhook([incoming({type: "button",
      button: {payload: "event-choice:one", text: "On my way"}})]);
    const params = {db, rawBody, signatureHeader: signature(rawBody),
      appSecret, now: Timestamp.fromMillis(1720000001000)};
    const before = fake.entries();
    for (const bad of [undefined, "sha256=" + "0".repeat(64),
      "sha256=" + "é".repeat(64)]) {
      await assert.rejects(ingestMetaWhatsappWebhook({...params,
        signatureHeader: bad}), /signature/);
      assert.deepEqual(fake.entries(), before);
    }
    const counts = await Promise.all(Array.from({length: 8}, () =>
      ingestMetaWhatsappWebhook(params)));
    assert.equal(counts.reduce((sum, count) => sum + count), 1);
    const entries = fake.entries().filter(([path]) =>
      path.startsWith("organizerMessagingWebhookEvents/"));
    assert.equal(entries.length, 1);
    const queued = entries[0][1];
    assert.ok(validateOrganizerMessagingWebhookEventDocument(queued));
    assert.equal(queued.providerAccountId, "700123");
    assert.equal(queued.providerPhoneNumberId, "123456");
    assert.equal(queued.connectionId, "connection-one");
    assert.deepEqual(queued.inboundReply, {kind: "templateQuickReply",
      payload: "event-choice:one", label: "On my way"});
    assert.equal(queued.callbackData, null);
    const persisted = JSON.stringify(fake.entries());
    assert.equal(persisted.includes(appSecret), false);
    assert.equal(persisted.includes("919999999999"), false);
  });

test("ambiguous sender or mismatched account is retained as unmatched evidence",
  async () => {
    for (const change of ["duplicate", "account", "missing", "noAccount"]) {
      const fake = new FakeFirestore();
      if (change !== "missing") {
        fake.write("organizerSenderConnections/connection-one",
          change === "account" ? {...sender(), wabaId: "700999"} : sender());
      }
      if (change === "duplicate") {
        fake.write("organizerSenderConnections/connection-two", sender());
      }
      const payload = JSON.parse(webhook([incoming({type: "button",
        button: {payload: "event-choice:one", text: "On my way"},
      })]).toString());
      if (change === "noAccount") delete payload.entry[0].id;
      const rawBody = Buffer.from(JSON.stringify(payload));
      await ingestMetaWhatsappWebhook({
        db: fake as unknown as FirebaseFirestore.Firestore,
        rawBody, signatureHeader: signature(rawBody), appSecret,
        now: Timestamp.fromMillis(1720000001000),
      });
      const queue = fake.entries().find(([path]) =>
        path.startsWith("organizerMessagingWebhookEvents/"))![1];
      assert.equal(queue.eventKind, "unmatched", change);
      assert.equal(queue.organizerId, null, change);
      assert.equal(queue.connectionId, null, change);
      assert.equal(queue.providerAccountId,
        change === "noAccount" ? null : "700123");
      assert.ok(queue.inboundReply);
    }
  });

test("Firestore deduplicates competing signed WhatsApp replies", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const id = randomUUID();
  const app = initializeApp({projectId: "demo-catch-rules"}, "wa-hook-" + id);
  const db = getFirestore(app);
  const connectionRef = db.collection("organizerSenderConnections").doc(id);
  const phoneNumberId = BigInt("0x" + id.replace(/-/g, "").slice(0, 16))
    .toString();
  const queueQuery = db.collection("organizerMessagingWebhookEvents")
    .where("providerMessageId", "==", "wamid." + id);
  try {
    await connectionRef.set({...sender(), phoneNumberId});
    const rawBody = webhook([incoming({id: "wamid." + id, type: "button",
      button: {payload: "event-choice:one", text: "On my way"}})], [],
    phoneNumberId);
    const params = {db, rawBody, signatureHeader: signature(rawBody),
      appSecret, now: Timestamp.fromMillis(1720000001000)};
    const counts = await Promise.all(Array.from({length: 8}, () =>
      ingestMetaWhatsappWebhook(params)));
    assert.equal(counts.reduce((sum, count) => sum + count), 1);
    const queued = await queueQuery.get();
    assert.equal(queued.size, 1);
    const event = queued.docs[0].data();
    assert.ok(validateOrganizerMessagingWebhookEventDocument(event));
    assert.equal(event.connectionId, id);
    assert.equal(event.providerAccountId, "700123");
    assert.equal(event.providerPhoneNumberId, phoneNumberId);
    assert.deepEqual(event.inboundReply, {kind: "templateQuickReply",
      payload: "event-choice:one", label: "On my way"});
  } finally {
    const queued = await queueQuery.get();
    const batch = db.batch();
    for (const event of queued.docs) {
      batch.delete(event.ref);
      batch.delete(db.collection("organizerCampaignWebhookReceipts")
        .doc(event.id));
    }
    await batch.commit();
    await connectionRef.delete();
    await deleteApp(app);
  }
});
