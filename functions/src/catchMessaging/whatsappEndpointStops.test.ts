import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import {test} from "node:test";
import {initializeApp, deleteApp} from "firebase-admin/app";
import {getFirestore, type Firestore, Timestamp} from
  "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {FormPaymentTestStore} from
  "../payments/formPayments/formPaymentTestStore";
import {handleCatchWhatsappWebhook, parseCatchWhatsappWebhook,
  WEBHOOK_RETENTION_MILLIS} from "./whatsappWebhookProtocol";
import {persistCatchWhatsappWebhookEvents} from "./whatsappWebhook";
import {CATCH_ENDPOINT_STOPS, CATCH_RECEIPTS, isCatchStopReceipt} from
  "./whatsappEndpointStops";
import {CatchWhatsappReplyStore, CATCH_REPLY_OPERATIONS} from
  "./whatsappReplyStore";
import {catchEndpointHash, catchReplyHash, catchReplyId, catchStopId,
  sendCatchWhatsappReply} from "./whatsappReply";
import type {CatchReplyConfig} from "./whatsappReply";

const now = 1800000000000;
const webhook = {enabled: true, wabaId: "123", phoneNumberId: "456",
  appSecret: "mock-app-secret", verifyToken: "t".repeat(32)};
const reply: CatchReplyConfig = {enabled: true, wabaId: "123",
  phoneNumberId: "456", atomicStopIngressReady: true,
  actorUid: "agent", recipientUid: "participant",
  recipientE164: "+919000000001",
  credentialVersionResource:
    "projects/demo-catch/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/1",
  graphVersion: "v23.0"};

function message(id: string, text: string) {
  return {id, from: "919000000001", timestamp: String(now / 1000),
    type: "text", text: {body: text}};
}
function payload(messages: object[], wabaId = "123") {
  return Buffer.from(JSON.stringify({object: "whatsapp_business_account",
    entry: [{id: wabaId, changes: [{field: "messages", value: {
      messaging_product: "whatsapp", metadata: {phone_number_id: "456"},
      messages,
    }}]}]}));
}
async function receive(db: Firestore, rawBody: Buffer, at = now,
  appSecret = webhook.appSecret) {
  return handleCatchWhatsappWebhook({method: "POST", query: {}, rawBody,
    signature: "sha256=" + createHmac("sha256", appSecret)
      .update(rawBody).digest("hex")}, webhook,
  (events) => persistCatchWhatsappWebhookEvents(db, events, at));
}
function fakeDatabase() {
  const fake = new FormPaymentTestStore();
  const db = Object.assign(fake, {
    bulkWriter: () => ({onWriteError: () => {}, close: async () => {},
      create: async (ref: {path: string}, data: Record<string, unknown>) => {
        if (fake.records.has(ref.path)) {
          throw Object.assign(new Error("Already exists"), {code: 6});
        }
        fake.records.set(ref.path, data);
      }}),
  }) as unknown as Firestore;
  return {fake, db};
}
function service(db: Firestore, inbound: ReturnType<
  typeof parseCatchWhatsappWebhook>[number]) {
  let sends = 0;
  const deps = {config: () => ({...reply}), now: () => now + 1000,
    getUser: async (uid: string) => uid === "agent" ?
      {disabled: false, customClaims: {support: true}} :
      {disabled: false, phoneNumber: reply.recipientE164}};
  const request = {auth: {uid: "agent", token: {support: true,
    auth_time: now / 1000}}, data: {purpose: "serviceSupport",
    inboundEventId: inbound.eventId, reviewedInboundTextHash:
      catchReplyHash(inbound.text), confirmSupportRequest: true,
    body: "Here is the requested support."}} as unknown as
    CallableRequest<unknown>;
  const store = new CatchWhatsappReplyStore(db, deps);
  return {sends: () => sends, send: () => sendCatchWhatsappReply(request,
    {...deps, store, prepare: async () => ({send: async () => {
      sends++; return "wamid.mock-provider-result";
    }})})};
}

test("wired ingress commits STOP first and preserves original receipt TTL",
  async () => {
    const {fake, db} = fakeDatabase();
    // Support is deliberately first in provider order.
    const raw = payload([message("wamid.support", "Please help"),
      message("wamid.stop", " STOP ")]);
    const events = parseCatchWhatsappWebhook(raw, webhook);
    fake.failNextCommit = true;
    assert.equal((await receive(db, raw)).status, 503);
    assert.equal(fake.records.size, 0,
      "Failed STOP cannot publish a same-batch support receipt");
    assert.equal((await receive(db, raw)).status, 200);
    const receiptKey = CATCH_RECEIPTS + "/" + events[1].eventId;
    const original = fake.records.get(receiptKey)!;
    assert.equal((await receive(db, raw, now + 5000)).status, 200);
    assert.deepEqual(fake.records.get(CATCH_RECEIPTS + "/" + events[1].eventId),
      original);
    assert.equal((original.expiresAt as Timestamp).toMillis(),
      now + WEBHOOK_RETENTION_MILLIS);
    const sender = service(db, events[0]);
    await assert.rejects(sender.send());
    assert.equal(sender.sends(), 0);
  });

test("signature and tenant rejection cannot create a suppression record",
  async () => {
    const {fake, db} = fakeDatabase();
    assert.equal((await receive(db, payload([message("wamid.stop", "stop")]),
      now, "foreign-secret")).status, 401);
    assert.equal((await receive(db, payload([message("wamid.stop", "stop")],
      "999"))).status, 403);
    assert.equal(fake.records.size, 0);
  });

test("only untruncated dispatchable text commands enter the STOP path", () => {
  const [event] = parseCatchWhatsappWebhook(payload([
    message("wamid.stop", " UnSubscribe ")]), webhook);
  assert.equal(isCatchStopReceipt(event), true);
  for (const patch of [{textTruncated: true}, {messageType: "button"},
    {text: "Please stop the video"}, {participantId: "invalid"}]) {
    assert.equal(isCatchStopReceipt({...event, ...patch}), false);
  }
});

test("real signed ingress races claims and blocks new reviewed inbound replies",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    assert.match(process.env.FIRESTORE_EMULATOR_HOST!,
      /^(localhost|127\.0\.0\.1):[0-9]+$/u);
    const app = initializeApp({projectId: "demo-catch-cat16-ingress"},
      "cat16-ingress-" + Date.now());
    const db = getFirestore(app);
    const suffix = String(Date.now());
    const support = payload([message("wamid.support" + suffix,
      "Please help")]);
    const stop = payload([message("wamid.stop" + suffix, "stop")]);
    const later = payload([message("wamid.later" + suffix,
      "Please help again")]);
    const [supportEvent] = parseCatchWhatsappWebhook(support, webhook);
    const [stopEvent] = parseCatchWhatsappWebhook(stop, webhook);
    const [laterEvent] = parseCatchWhatsappWebhook(later, webhook);
    const stopKey = CATCH_ENDPOINT_STOPS + "/" + catchStopId(reply,
      catchEndpointHash(reply.recipientE164));
    const claimKey = CATCH_REPLY_OPERATIONS + "/" + catchReplyId(reply,
      supportEvent.messageId);
    const laterClaimKey = CATCH_REPLY_OPERATIONS + "/" + catchReplyId(reply,
      laterEvent.messageId);
    const paths = [stopKey, claimKey, laterClaimKey,
      ...[supportEvent, stopEvent, laterEvent].map((event) =>
        CATCH_RECEIPTS + "/" + event.eventId)];
    try {
      assert.equal((await receive(db, support)).status, 200);
      const sender = service(db, supportEvent);
      const [claim, stopped] = await Promise.allSettled([
        sender.send(), receive(db, stop),
      ]);
      assert.equal(stopped.status, "fulfilled");
      if (stopped.status === "fulfilled") {
        assert.equal(stopped.value.status, 200);
      }
      if (claim.status === "fulfilled") {
        const claimTime = (await db.doc(claimKey).get()).createTime!;
        const stopTime = (await db.doc(stopKey).get()).createTime!;
        assert.ok(claimTime.seconds < stopTime.seconds ||
          (claimTime.seconds === stopTime.seconds &&
            claimTime.nanoseconds <= stopTime.nanoseconds));
        assert.equal(sender.sends(), 1);
      } else assert.equal(sender.sends(), 0);
      const original = (await db.doc(CATCH_RECEIPTS + "/" +
        stopEvent.eventId).get()).data()!;
      const results = await Promise.all(Array.from({length: 5}, () =>
        receive(db, stop, now + 5000)));
      assert.ok(results.every((result) => result.status === 200));
      assert.deepEqual((await db.doc(CATCH_RECEIPTS + "/" + stopEvent.eventId)
        .get()).data(), original);
      assert.equal((await receive(db, later)).status, 200);
      const next = service(db, laterEvent);
      await assert.rejects(next.send());
      assert.equal(next.sends(), 0);
      assert.equal((await db.doc(laterClaimKey).get()).exists, false);
    } finally {
      for (const item of paths) await db.doc(item).delete();
      await deleteApp(app);
    }
  });
