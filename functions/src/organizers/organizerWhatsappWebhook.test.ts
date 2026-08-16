import assert from "node:assert/strict";
import test from "node:test";
import {parseMetaWhatsappWebhook} from "./organizerWhatsappWebhook";

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
