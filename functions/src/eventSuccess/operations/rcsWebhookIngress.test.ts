import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import type {Request, Response} from "express";
import test from "node:test";
import {createRcsWebhookIngress} from "./rcsWebhookIngress";
import {RCS_CALLBACK_MAX_BYTES, VerifiedRcsCallback} from
  "./rcsWebhookProtocol";

function harness() {
  const clientToken = "fixture-only-rcs-client-token-1234567890";
  const agentId = "agent@rbm.goog";
  const data = Buffer.from(JSON.stringify({agentId,
    senderPhoneNumber: "+919999999999",
    eventId: "event-1", eventType: "DELIVERED", messageId: "message-1"}));
  const request = {method: "POST", rawBody: Buffer.from(JSON.stringify({
    message: {data: data.toString("base64")},
  })), headers: {"x-goog-webhook-type": "message_callback",
    "x-goog-signature": createHmac("sha512", clientToken).update(data)
      .digest("base64")}};
  const replies: {status: number; body: unknown}[] = [];
  const headers: Record<string, string> = {};
  const callbacks: VerifiedRcsCallback[] = [];
  const failures: unknown[][] = [];
  let status = 200;
  let credentialReads = 0;
  const response = {
    set: (key: string | Record<string, string>, value?: string) => {
      if (typeof key === "string") headers[key] = value!;
      else Object.assign(headers, key);
      return response;
    },
    status: (code: number) => {
      status = code; return response;
    },
    send: (body: unknown) => {
      replies.push({status, body}); return response;
    },
  };
  const deps = {
    enabled: () => true,
    credentials: async () => {
      credentialReads++; return {agentId, clientToken};
    },
    enqueue: async (callback: VerifiedRcsCallback): Promise<"stored"> => {
      callbacks.push(callback); return "stored";
    },
    clock: () => 1788825600000,
    failed: (...args: unknown[]) => {
      failures.push(args);
    },
  };
  const run = (change = {}, overrides = {}) => createRcsWebhookIngress({
    ...deps, ...overrides,
  })({...request, ...change} as unknown as Request,
  response as unknown as Response);
  return {run, replies, headers, callbacks, failures, request, deps,
    clientToken, credentialReads: () => credentialReads};
}

test("RCS ingress receives only authenticated normalized callbacks",
  async () => {
    const h = harness();
    await h.run({body: {agentId: "forged"}, query: {agentId: "forged"}});
    assert.deepEqual(h.replies, [{status: 200, body: "ok"}]);
    assert.equal(h.callbacks.length, 1);
    assert.equal(h.callbacks[0].evidence.agentId, "agent@rbm.goog");
    assert.match(h.headers["Cache-Control"], /no-store/);
    assert.equal(h.headers["Content-Type"], "text/plain; charset=utf-8");
    assert.equal(h.headers["X-Content-Type-Options"], "nosniff");
    assert.deepEqual(h.failures, []);
  });

test("RCS disabled, non-POST and oversized inputs do not load credentials",
  async () => {
    const disabled = harness();
    await disabled.run({}, {enabled: () => false});
    assert.equal(disabled.replies[0].status, 503);
    assert.equal(disabled.credentialReads(), 0);
    for (const [change, expected] of [
      [{method: "GET"}, 405], [{method: "PUT"}, 405],
      [{rawBody: undefined}, 400], [{rawBody: "{}"}, 400],
      [{rawBody: Buffer.alloc(RCS_CALLBACK_MAX_BYTES + 1)}, 413],
      [{headers: {"x-goog-webhook-type": ["verification", "message_callback"]}},
        400],
      [{headers: {"x-goog-signature": ["first", "second"]}}, 400],
    ] as const) {
      const h = harness();
      await h.run(change);
      assert.equal(h.replies[0].status, expected);
      assert.equal(h.credentialReads(), 0);
      assert.deepEqual(h.callbacks, []);
    }
  });

test("RCS headers cannot replace signature or turn a message into a challenge",
  async () => {
    for (const headers of [
      {"authorization": "provider", "x-forwarded-agent": "agent@rbm.goog"},
      {"x-goog-webhook-type": "verification"},
    ]) {
      const h = harness();
      await h.run({headers});
      assert.equal(h.replies[0].status, 403);
      assert.deepEqual(h.callbacks, []);
    }
    for (const type of [undefined, "agent_callback"]) {
      const h = harness();
      await h.run({headers: {
        ...h.request.headers, "x-goog-webhook-type": type,
      }});
      // The signed payload owns the observation, independent of the header.
      assert.equal(h.callbacks[0].evidence.observation.kind, "delivery");
    }
  });

test("RCS challenge echoes only a matched token's secret as plain text",
  async () => {
    for (const valid of [true, false]) {
      const h = harness();
      await h.run({headers: {"x-goog-webhook-type": "verification"},
        rawBody: Buffer.from(JSON.stringify({clientToken: valid ?
          h.clientToken : "wrong", secret: "<challenge-secret>"}))});
      assert.deepEqual(h.replies, [{status: valid ? 200 : 403,
        body: valid ? "<challenge-secret>" : "Invalid callback"}]);
      assert.deepEqual(h.callbacks, []);
      assert.equal(h.headers["Content-Type"], "text/plain; charset=utf-8");
    }
  });

test("RCS acknowledgement follows durable acceptance, including conflicts",
  async () => {
    for (const outcome of ["stored", "duplicate", "conflict"] as const) {
      const h = harness();
      let release!: (value: typeof outcome) => void;
      let entered!: () => void;
      const started = new Promise<void>((resolve) => {
        entered = resolve;
      });
      const pending = new Promise<typeof outcome>((resolve) => {
        release = resolve;
      });
      const running = h.run({}, {enqueue: () => {
        entered(); return pending;
      }});
      await started;
      assert.deepEqual(h.replies, []);
      release(outcome);
      await running;
      assert.deepEqual(h.replies, [{status: 200, body: "ok"}]);
    }
  });

test("RCS queue or credential errors cannot acknowledge or expose private data",
  async () => {
    const secretError = new Error("private-phone-token-provider-url");
    for (const overrides of [
      {enqueue: async () => {
        throw secretError;
      }},
      {credentials: async () => {
        throw secretError;
      }},
      {enqueue: async () => "not-persisted"},
    ]) {
      const h = harness();
      await h.run({}, overrides);
      assert.deepEqual(h.replies, [{status: 503, body: "Unavailable"}]);
      assert.equal(h.headers["Retry-After"], "30");
      assert.deepEqual(h.failures, [[]]);
      assert.equal(JSON.stringify([h.replies, h.failures])
        .includes("private"), false);
    }
  });
