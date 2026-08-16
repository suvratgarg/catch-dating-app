import assert from "node:assert/strict";
import test from "node:test";
import {
  isWhatsappServiceWindowOpen,
  organizerWhatsappMessageId,
  organizerWhatsappReplyOperationId,
  organizerWhatsappThreadId,
  whatsappServiceWindowMillis,
  whatsappThreadRetentionMillis,
} from "./organizerWhatsappThreads";

test("WhatsApp reply window is open for 24 hours after last inbound", () => {
  const inboundAt = 1_000;
  assert.equal(isWhatsappServiceWindowOpen(inboundAt, inboundAt), true);
  assert.equal(
    isWhatsappServiceWindowOpen(
      inboundAt,
      inboundAt + whatsappServiceWindowMillis - 1
    ),
    true
  );
  assert.equal(
    isWhatsappServiceWindowOpen(
      inboundAt,
      inboundAt + whatsappServiceWindowMillis
    ),
    false
  );
  assert.equal(isWhatsappServiceWindowOpen(inboundAt, inboundAt - 1), false);
});

test("WhatsApp retained bodies use the settled 12-month TTL", () => {
  assert.equal(whatsappThreadRetentionMillis, 365 * 24 * 60 * 60 * 1000);
});

test("WhatsApp thread and message ids are deterministic and scoped", () => {
  const thread = organizerWhatsappThreadId("organizer-1", "contact-1");
  assert.equal(
    thread,
    organizerWhatsappThreadId("organizer-1", "contact-1")
  );
  assert.notEqual(
    thread,
    organizerWhatsappThreadId("organizer-2", "contact-1")
  );
  assert.match(thread, /^owt_[a-f0-9]{48}$/);
  assert.match(
    organizerWhatsappMessageId("organizer-1", "wamid.1"),
    /^owm_[a-f0-9]{48}$/
  );
  const operation = organizerWhatsappReplyOperationId(
    "organizer-1",
    thread,
    "reply-key-1"
  );
  assert.equal(
    operation,
    organizerWhatsappReplyOperationId(
      "organizer-1",
      thread,
      "reply-key-1"
    )
  );
  assert.match(operation, /^owro_[a-f0-9]{48}$/);
});
