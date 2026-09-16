import assert from "node:assert/strict";
import test from "node:test";
import * as crypto from "node:crypto";
import {
  hashCanonical,
  isWhatsappStopCommand,
  nextCampaignRecipientStatus,
  organizerCampaignId,
  organizerCampaignRecipientId,
  organizerContactChannelStateId,
  organizerMessageTemplateId,
  organizerSenderConnectionId,
  verifyMetaWebhookSignature,
} from "./organizerCampaignModel";

test("campaign ids are opaque, deterministic and scoped", () => {
  const first = organizerCampaignId("organizer-1", "actor-1", "request-1");
  assert.equal(first, organizerCampaignId(
    "organizer-1", "actor-1", "request-1"
  ));
  assert.notEqual(first, organizerCampaignId(
    "organizer-1", "actor-2", "request-1"
  ));
  assert.match(first, /^ocamp_[a-f0-9]{48}$/);
  assert.match(organizerCampaignRecipientId(first, "contact-1"),
    /^ocrec_[a-f0-9]{48}$/);
  assert.match(organizerSenderConnectionId("organizer-1", "12345"),
    /^osc_[a-f0-9]{48}$/);
  assert.match(organizerMessageTemplateId("connection-1", "1", "en_US"),
    /^omtpl_[a-f0-9]{48}$/);
  assert.match(organizerContactChannelStateId("organizer-1", "contact-1"),
    /^occs_[a-f0-9]{48}$/);
});

test("canonical hashes ignore key order and preserve array order", () => {
  assert.equal(hashCanonical({b: 2, a: 1}), hashCanonical({a: 1, b: 2}));
  assert.notEqual(hashCanonical([1, 2]), hashCanonical([2, 1]));
});

test("delivery status cannot regress on late provider receipts", () => {
  assert.equal(nextCampaignRecipientStatus("delivered", "sent"), "delivered");
  assert.equal(nextCampaignRecipientStatus("sent", "read"), "read");
  assert.equal(nextCampaignRecipientStatus("optedOut", "read"), "optedOut");
  assert.equal(nextCampaignRecipientStatus("delivered", "replied"), "replied");
  assert.equal(nextCampaignRecipientStatus("failed", "delivered"), "failed");
});

test("only an exact supported command is treated as a WhatsApp stop", () => {
  assert.equal(isWhatsappStopCommand(" STOP "), true);
  assert.equal(isWhatsappStopCommand("unsubscribe"), true);
  assert.equal(isWhatsappStopCommand("please stop"), false);
  assert.equal(isWhatsappStopCommand("stopping by later"), false);
});

test("Meta webhook signature verification is timing-safe and exact", () => {
  const rawBody = Buffer.from("{\"object\":\"whatsapp_business_account\"}");
  const appSecret = "test-secret";
  const signatureHeader = `sha256=${crypto.createHmac("sha256", appSecret)
    .update(rawBody).digest("hex")}`;
  assert.equal(verifyMetaWebhookSignature({
    rawBody,
    signatureHeader,
    appSecret,
  }), true);
  assert.equal(verifyMetaWebhookSignature({
    rawBody: Buffer.from("tampered"),
    signatureHeader,
    appSecret,
  }), false);
  for (const malformed of [undefined, "", "sha256=" + "0".repeat(63),
    "sha256=" + "0".repeat(65), "sha256=" + "g".repeat(64),
    "sha256=" + "é".repeat(64), signatureHeader + "\n"]) {
    assert.equal(verifyMetaWebhookSignature({
      rawBody, signatureHeader: malformed, appSecret,
    }), false);
  }
  assert.equal(verifyMetaWebhookSignature({
    rawBody, signatureHeader, appSecret: "",
  }), false);
});
