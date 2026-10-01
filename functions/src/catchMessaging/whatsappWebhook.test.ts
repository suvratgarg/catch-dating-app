import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import {test} from "node:test";
import * as admin from "firebase-admin";
import {handleCatchWhatsappWebhook, MAX_WEBHOOK_BYTES, MAX_WEBHOOK_EVENTS,
  parseCatchWhatsappWebhook, WEBHOOK_RETENTION_MILLIS} from
  "./whatsappWebhookProtocol";
import type {CatchWebhookConfig, CatchWebhookEvent} from
  "./whatsappWebhookProtocol";
import {CATCH_WEBHOOK_COLLECTION, persistCatchWhatsappWebhookEvents} from
  "./whatsappWebhook";
import {validateCatchWhatsappWebhookEventDocument} from
  "../shared/generated/validators/catchWhatsappWebhookEventDocument";

const config: CatchWebhookConfig = {enabled: true, wabaId: "123",
  phoneNumberId: "456", appSecret: "test-app-secret-keep-private",
  verifyToken: "test-only-verification-token-32-characters"};
const incoming = {id: "wamid.inbound", from: "919000000001",
  timestamp: "1790854245", type: "text", text: {body: "Hello Catch"}};
function payload(messages: object[] = [incoming], statuses: object[] = [],
  wabaId = config.wabaId, phoneNumberId = config.phoneNumberId): Buffer {
  return Buffer.from(JSON.stringify({object: "whatsapp_business_account",
    entry: [{id: wabaId, changes: [{field: "messages", value: {
      messaging_product: "whatsapp", metadata: {phone_number_id: phoneNumberId},
      contacts: [{profile: {name: "Must not be retained"}}], messages, statuses,
    }}]}]}));
}
function signed(rawBody: Buffer, secret = config.appSecret) {
  return {method: "POST", query: {}, rawBody,
    signature: "sha256=" + createHmac("sha256", secret)
      .update(rawBody).digest("hex")};
}
function status(name: string, seconds = "1790854250") {
  return {id: "wamid.outbound", status: name, timestamp: seconds,
    recipient_id: "919000000001"};
}
const mustNotWrite = async () => {
  throw new Error("Unexpected persistence");
};

test("verification echoes the exact challenge without persisting", async () => {
  const result = await handleCatchWhatsappWebhook({method: "GET", query: {
    "hub.mode": "subscribe", "hub.verify_token": config.verifyToken,
    "hub.challenge": "0042143",
  }}, config, mustNotWrite);
  assert.deepEqual(result, {status: 200, body: "0042143"});
});

test("wrong tokens and disabled configuration fail closed",
  async () => {
    for (const token of ["wrong", [config.verifyToken], undefined]) {
      assert.equal((await handleCatchWhatsappWebhook({method: "GET", query: {
        "hub.mode": "subscribe", "hub.verify_token": token,
        "hub.challenge": "challenge",
      }}, config, mustNotWrite)).status, 403);
    }
    for (const patch of [{enabled: false}, {wabaId: ""}, {phoneNumberId: ""},
      {appSecret: ""}, {verifyToken: ""}]) {
      assert.equal((await handleCatchWhatsappWebhook(signed(payload()),
        {...config, ...patch}, mustNotWrite)).status, 503);
    }
  });

test("signature checks exact raw bytes and the configured app secret",
  async () => {
    const raw = payload();
    for (const request of [{...signed(raw), signature: undefined},
      signed(raw, "foreign-app-secret"),
      {...signed(raw), rawBody: Buffer.concat([raw, Buffer.from(" ")])},
      {...signed(raw), signature: "sha256=short"}]) {
      assert.equal((await handleCatchWhatsappWebhook(request, config,
        mustNotWrite)).status, 401);
    }
  });

test("a signed foreign WABA or phone cannot enter Catch storage", async () => {
  let writes = 0;
  for (const raw of [payload([incoming], [], "999"),
    payload([incoming], [], config.wabaId, "999")]) {
    const result = await handleCatchWhatsappWebhook(signed(raw), config,
      async () => {
        writes += 1;
      });
    assert.equal(result.status, 403);
  }
  // A valid first entry must not be persisted when a later entry is foreign.
  const mixed = JSON.parse(payload().toString());
  mixed.entry.push(JSON.parse(payload([incoming], [], "999").toString())
    .entry[0]);
  assert.equal((await handleCatchWhatsappWebhook(signed(Buffer.from(
    JSON.stringify(mixed))), config, async () => {
    writes += 1;
  })).status, 403);
  assert.equal(writes, 0);
});

test("accepted messages and statuses are private receipts", async () => {
  const raw = payload([{...incoming, text: {body: "x".repeat(5000)}}],
    [{...status("failed"), errors: [{code: 131026,
      message: "Do not retain error details"}]}]);
  let saved: CatchWebhookEvent[] = [];
  const result = await handleCatchWhatsappWebhook(signed(raw), config,
    async (events) => {
      saved = events;
    });
  assert.equal(result.status, 200);
  assert.equal(saved.length, 2);
  assert.equal(saved[0].text?.length, 4096);
  assert.equal(saved[0].textTruncated, true);
  assert.deepEqual(saved[1].errorCodes, [131026]);
  assert.equal(saved[1].text, null);
  assert.equal(JSON.stringify(saved).includes("Must not be retained"), false);
  assert.equal(JSON.stringify(saved).includes("Do not retain"), false);
  assert.equal(JSON.stringify(saved).includes(config.appSecret), false);
});

test("status receipts preserve out-of-order observations and stable replay ids",
  () => {
    const statuses = [status("read", "1790854260"),
      status("sent", "1790854245"), status("delivered", "1790854250")];
    const first = parseCatchWhatsappWebhook(payload([], statuses), config);
    const reversed = parseCatchWhatsappWebhook(payload([], [...statuses]
      .reverse()), config);
    assert.deepEqual(new Set(first.map((event) => event.eventId)),
      new Set(reversed.map((event) => event.eventId)));
    assert.deepEqual(first.map((event) => event.deliveryStatus),
      ["read", "sent", "delivered"]);
    assert.equal(new Set(first.map((event) => event.eventId)).size, 3);
  });

test("Meta receives a retryable failure if persistence is unavailable",
  async () => {
    const result = await handleCatchWhatsappWebhook(signed(payload()), config,
      async () => {
        throw new Error("private database detail");
      });
    assert.equal(result.status, 503);
    assert.equal(result.body.includes("private database detail"), false);
  });

test("success is returned only after persistence completes", async () => {
  let release: () => void = () => {
    throw new Error("Not initialized");
  };
  const gate = new Promise<void>((resolve) => {
    release = resolve;
  });
  let finished = false;
  const result = handleCatchWhatsappWebhook(signed(payload()), config,
    () => gate).then((response) => {
    finished = true; return response;
  });
  await Promise.resolve();
  assert.equal(finished, false);
  release();
  assert.equal((await result).status, 200);
});

test("invalid or excessive signed payloads cannot be acknowledged or truncated",
  async () => {
    const raws = [Buffer.from("not-json"), Buffer.from("{}"),
      payload([{...incoming, timestamp: "bad"}]),
      payload([{...incoming, id: "x".repeat(241)}]),
      payload(Array.from({length: MAX_WEBHOOK_EVENTS + 1}, (_, index) =>
        ({...incoming, id: "wamid." + index}))),
      payload([], [status("made-up-status")])];
    for (const raw of raws) {
      assert.equal((await handleCatchWhatsappWebhook(signed(raw), config,
        mustNotWrite)).status, 400);
    }
    assert.equal((await handleCatchWhatsappWebhook(signed(Buffer.alloc(
      MAX_WEBHOOK_BYTES + 1)), config, mustNotWrite)).status, 413);
    assert.equal((await handleCatchWhatsappWebhook({method: "DELETE",
      query: {}},
    config, mustNotWrite)).status, 405);
  });

test("unsubscribed fields are ignored without storing their private payload",
  async () => {
    const raw = Buffer.from(JSON.stringify({object: "whatsapp_business_account",
      entry: [{id: config.wabaId, changes: [{field: "account_update",
        value: {privateField: "ignored"}}]}]}));
    let saved: CatchWebhookEvent[] | undefined;
    assert.equal((await handleCatchWhatsappWebhook(signed(raw), config,
      async (events) => {
        saved = events;
      })).status, 200);
    assert.deepEqual(saved, []);
  });

function store() {
  const docs = new Map<string, Record<string, unknown>>();
  let errorCode: number | undefined;
  const fake = {
    collection: (name: string) => ({
      doc: (id: string) => ({key: name + "/" + id}),
    }),
    bulkWriter: () => ({onWriteError: () => {}, close: async () => {},
      create: async (ref: {key: string}, document: Record<string, unknown>) => {
        if (errorCode !== undefined) {
          throw Object.assign(new Error("Injected failure"), {code: errorCode});
        }
        if (docs.has(ref.key)) {
          throw Object.assign(new Error("Already exists"), {code: 6});
        }
        docs.set(ref.key, document);
      }}),
  };
  return {docs, db: fake as unknown as FirebaseFirestore.Firestore,
    fail: (code: number) => {
      errorCode = code;
    }};
}

test("concurrent retries preserve one receipt and its original TTL",
  async () => {
    const db = store();
    const events = parseCatchWhatsappWebhook(payload(), config);
    const now = 1790854245000;
    await Promise.all([persistCatchWhatsappWebhookEvents(db.db, events, now),
      persistCatchWhatsappWebhookEvents(db.db, events, now + 1000)]);
    assert.equal(db.docs.size, 1);
    const [key, document] = [...db.docs][0];
    assert.ok(key.startsWith(CATCH_WEBHOOK_COLLECTION + "/cwhe_"));
    assert.equal(document.receivedAtMillis, now);
    const expiresAt = document.expiresAt as FirebaseFirestore.Timestamp;
    assert.equal(expiresAt.toMillis(), now + WEBHOOK_RETENTION_MILLIS);
    assert.ok(validateCatchWhatsappWebhookEventDocument({...document,
      expiresAt: {_seconds: expiresAt.seconds,
        _nanoseconds: expiresAt.nanoseconds}}));
  });

test("only existing receipts count as successful persistence retries",
  async () => {
    const events = parseCatchWhatsappWebhook(payload(), config);
    const duplicate = store(); duplicate.fail(6);
    await persistCatchWhatsappWebhookEvents(duplicate.db, events);
    for (const code of [7, 14]) {
      const db = store(); db.fail(code);
      await assert.rejects(persistCatchWhatsappWebhookEvents(db.db, events));
    }
  });

test("invalid internal receipts cannot reach the writer", async () => {
  const db = store();
  const [event] = parseCatchWhatsappWebhook(payload(), config);
  await assert.rejects(persistCatchWhatsappWebhookEvents(db.db,
    [{...event, text: "x".repeat(4097)}]));
  assert.equal(db.docs.size, 0);
});


test("Firestore deduplicates Catch callbacks atomically",
  {skip: !process.env.FIRESTORE_EMULATOR_HOST}, async () => {
    const host = process.env.FIRESTORE_EMULATOR_HOST!;
    assert.match(host, /^(127\.0\.0\.1|localhost):[0-9]+$/);
    const app = admin.initializeApp({projectId: "demo-catch-rules"},
      "catch-webhook-test-" + Date.now());
    const db = admin.firestore(app);
    const events = parseCatchWhatsappWebhook(payload([{...incoming,
      id: "wamid.emulator." + Date.now()}]), config);
    const ref = db.collection(CATCH_WEBHOOK_COLLECTION).doc(events[0].eventId);
    const now = 1790854245000;
    try {
      await persistCatchWhatsappWebhookEvents(db, events, now);
      await Promise.all(Array.from({length: 5}, () =>
        persistCatchWhatsappWebhookEvents(db, events, now + 1000)));
      const receipt = (await ref.get()).data()!;
      assert.equal(receipt.messageId, events[0].messageId);
      assert.equal(receipt.receivedAtMillis, now);
      assert.equal(receipt.expiresAt.toMillis(),
        now + WEBHOOK_RETENTION_MILLIS);
      assert.equal(receipt.organizerId, undefined);
    } finally {
      await ref.delete();
      await app.delete();
    }
  });
