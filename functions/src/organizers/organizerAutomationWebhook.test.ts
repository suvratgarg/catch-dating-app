import assert from "node:assert/strict";
import test from "node:test";
import {EventEmitter} from "node:events";
import {request} from "node:https";
import {createHmac} from "node:crypto";
import {Timestamp} from "firebase-admin/firestore";
import {OrganizerAutomationEvent} from "./organizerAutomationSource";
import {
  deliverOrganizerAutomationWebhook,
  isPublicWebhookAddress,
  publicWebhookUrl,
  signedWebhookRequest,
} from "./organizerAutomationWebhook";

const params = {
  url: "https://hooks.example.com/catch",
  secret: "s".repeat(32),
  deliveryId: "delivery-1",
  ruleId: "rule",
  ruleRevision: 3,
  timestampMillis: 1800000000000,
  event: {
    kind: "submitted",
    sourceId: "response",
    organizerId: "org",
    formId: "form",
    eventId: null,
    contactId: "ada",
    occurredAt: Timestamp.fromMillis(1700000000000),
    eventEndAt: null,
    response: {answers: {privateAnswer: "should never be sent"}},
  } as unknown as OrganizerAutomationEvent,
};

test("webhooks reject private and reserved network destinations", () => {
  for (const address of [
    "127.0.0.1",
    "10.0.1.2",
    "169.254.169.254",
    "100.64.1.1",
    "172.16.0.1",
    "192.168.1.1",
    "198.18.0.1",
    "224.0.0.1",
    "::1",
    "fc00::1",
    "fe80::1",
    "::ffff:127.0.0.1",
    "2001:db8::1",
    "2002:7f00:1::",
  ]) {
    assert.equal(isPublicWebhookAddress(address), false, address);
  }
  for (const url of [
    "http://example.com",
    "https://2130706433",
    "https://[::1]",
    "https://user:pass@example.com",
    "https://example.com:8443",
    "https://localhost",
  ]) {
    assert.throws(() => publicWebhookUrl(url), {code: "invalid-argument"});
  }
  assert.equal(isPublicWebhookAddress("8.8.8.8"), true);
  assert.equal(isPublicWebhookAddress("2606:4700:4700::1111"), true);
});

test("signatures bind the payload, timestamp and delivery id", () => {
  const {body, headers} = signedWebhookRequest(params);
  assert.equal(body.includes("privateAnswer"), false);
  assert.equal(body.includes("should never be sent"), false);
  assert.equal(headers["Idempotency-Key"], "delivery-1");
  const signature = createHmac("sha256", params.secret)
    .update(`${headers["X-Catch-Timestamp"]}.${body}`)
    .digest("hex");
  assert.equal(headers["X-Catch-Signature"], `v1=${signature}`);
  assert.notEqual(
    signedWebhookRequest({
      ...params,
      timestampMillis: params.timestampMillis + 1000,
    }).headers["X-Catch-Signature"],
    headers["X-Catch-Signature"],
  );
});

test("delivery pins DNS addresses and rejects redirects", async () => {
  let calls = 0;
  let status = 204;
  const deps = {
    lookup: async () => [{address: "8.8.8.8", family: 4}],
    request: ((
      _url: unknown,
      options: Record<string, unknown>,
      callback: (response: EventEmitter) => void,
    ) => {
      calls++;
      const pin = options.lookup as (
        _host: string,
        _options: unknown,
        callback: (...args: unknown[]) => void,
      ) => void;
      pin("hooks.example.com", {}, (error, address, family) => {
        assert.equal(error, null);
        assert.equal(address, "8.8.8.8");
        assert.equal(family, 4);
      });
      const req = new EventEmitter() as EventEmitter & {
        setTimeout: () => void;
        end: () => void;
      };
      req.setTimeout = () => undefined;
      req.end = () => {
        const response = Object.assign(new EventEmitter(), {
          statusCode: status,
        });
        callback(response);
        response.emit("end");
      };
      return req;
    }) as unknown as typeof request,
  };
  await deliverOrganizerAutomationWebhook(params, deps);
  status = 302;
  await assert.rejects(deliverOrganizerAutomationWebhook(params, deps), {
    code: "failed-precondition",
  });
  assert.equal(calls, 2);
  deps.lookup = async () => [
    {address: "8.8.8.8", family: 4},
    {address: "127.0.0.1", family: 4},
  ];
  await assert.rejects(
    deliverOrganizerAutomationWebhook(params, deps),
    /public addresses/,
  );
  assert.equal(calls, 2);
});
