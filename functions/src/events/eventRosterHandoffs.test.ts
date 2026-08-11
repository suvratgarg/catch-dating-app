import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import test from "node:test";

import {
  InboundRosterWebhookPayload,
  parseInboundRosterPayload,
  resolveHandoffToken,
  verifyRosterWebhookSignature,
} from "./eventRosterHandoffs";

const payload: InboundRosterWebhookPayload = {
  channel: "email",
  providerMessageId: "message-1",
  senderVerified: true,
  senderEmail: "host@example.com",
  recipient: "roster+abcdefghijklmnopqrstuvwx@inbound.example.com",
  attachment: {
    fileName: "guests.csv",
    contentType: "text/csv",
    contentBase64: Buffer.from("Name\nAsha Shah").toString("base64"),
  },
};

test("verifies only the exact HMAC-authenticated inbound body", () => {
  const raw = Buffer.from(JSON.stringify(payload));
  const signature = createHmac("sha256", "secret")
    .update(raw)
    .digest("hex");

  assert.equal(verifyRosterWebhookSignature(raw, signature, "secret"), true);
  assert.equal(
    verifyRosterWebhookSignature(Buffer.from(`${raw.toString()} `),
      signature, "secret"),
    false
  );
  assert.equal(verifyRosterWebhookSignature(raw, undefined, "secret"), false);
});

test("parses a bounded normalized provider payload", () => {
  const parsed = parseInboundRosterPayload(
    Buffer.from(JSON.stringify(payload))
  );
  assert.equal(parsed.providerMessageId, "message-1");
  assert.equal(parsed.attachment.fileName, "guests.csv");
});

test("extracts capabilities from email and WhatsApp transports", () => {
  assert.equal(resolveHandoffToken(payload), "abcdefghijklmnopqrstuvwx");
  assert.equal(resolveHandoffToken({
    ...payload,
    channel: "whatsapp",
    recipient: undefined,
    messageText: "Please import ROSTER zyxwvutsrqponmlkjihgfedc",
  }), "zyxwvutsrqponmlkjihgfedc");
});

test("rejects payloads without provider verification metadata", () => {
  const invalid = {...payload} as Record<string, unknown>;
  delete invalid.senderVerified;
  assert.throws(
    () => parseInboundRosterPayload(Buffer.from(JSON.stringify(invalid))),
    /invalid_inbound_payload/u
  );
});
