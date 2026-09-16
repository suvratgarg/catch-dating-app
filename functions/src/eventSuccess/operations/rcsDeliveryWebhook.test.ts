import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import test from "node:test";
import {rcsHttpResponse} from "./rcsDispatchTestHarness";
import type {Request} from "firebase-functions/v2/https";
import type {Firestore} from "firebase-admin/firestore";
import {ProgressFirestore} from "./groupProgressTestFixtures";
import {RcsWebhookKeyStore, parseRcsWebhookEndpoints} from
  "./rcsWebhookKeyStore";
import type {RcsSecretClient} from "./rcsCredentialStore";
import {RcsCallbackStore} from "./rcsCallbackStore";
import {rcsCallbackCollections} from "./rcsCallbackRecords";
import {eventAssistanceRcsWebhookHandler} from "./rcsDeliveryWebhook";

const version =
  "projects/demo/secrets/EVENT_ASSISTANCE_RCS_WEBHOOK_KEYS/versions/1";
const envelope = () => ({schema: "catch.event-rcs-webhooks/v1",
  endpoints: [
    {endpointId: "old", agentId: "old-agent@rbm.goog",
      clientToken: "fixture-old-token-12345678901234567890"},
    {endpointId: "current", agentId: "new-agent@rbm.goog",
      clientToken: "fixture-new-token-12345678901234567890"}]});

function fixture() {
  const fake = new ProgressFirestore();
  const db = fake as unknown as Firestore;
  const state = {name: version, value: envelope() as unknown,
    fail: false, enabled: true};
  const reads: string[] = [];
  const client = {accessSecretVersion: async ({name}: {name: string}) => {
    reads.push(name);
    if (state.fail) throw new Error("private-secret-value");
    return [{payload: {data: Buffer.from(JSON.stringify(state.value))}}];
  }} as unknown as RcsSecretClient;
  const keys = new RcsWebhookKeyStore(() => state.name, client);
  const clock = () => 1788825600000;
  const errors: string[] = [];
  const deps = {enabled: () => state.enabled, keys,
    inbox: new RcsCallbackStore(db, clock), clock,
    failed: () => errors.push("failed")};
  const request = (endpoint = envelope().endpoints[0]) => {
    const body = Buffer.from(JSON.stringify({agentId: endpoint.agentId,
      senderPhoneNumber: "+919999999999", eventType: "DELIVERED",
      eventId: "provider-event", messageId: "provider-message"}));
    return {method: "POST", path: "/" + endpoint.endpointId,
      rawBody: Buffer.from(JSON.stringify({message: {
        data: body.toString("base64")}})), headers: {
        "x-goog-signature": createHmac("sha512", endpoint.clientToken)
          .update(body).digest("base64"),
        "x-goog-webhook-type": "message_callback"}};
  };
  const run = async (input = request()) => {
    const http = rcsHttpResponse();
    await eventAssistanceRcsWebhookHandler(input as unknown as Request,
      http.response, deps);
    return http;
  };
  return {fake, state, keys, reads, errors, request, run};
}

test("webhook keys retain exact endpoints and reject ambiguous configuration",
  async () => {
    const h = fixture();
    for (const endpoint of envelope().endpoints) {
      assert.deepEqual(await h.keys.access(endpoint.endpointId), endpoint);
    }
    const e = envelope();
    for (const invalid of [null, [], {...e, extra: true},
      {...e, endpoints: []},
      {...e, endpoints: [e.endpoints[0], e.endpoints[0]]},
      {...e, endpoints: [{...e.endpoints[0], endpointId: "../old"}]},
      {...e, endpoints: [{...e.endpoints[0], clientToken: "short"}]},
      {...e, endpoints: [{...e.endpoints[0], agentId: "agent\n"}]}]) {
      assert.throws(() => parseRcsWebhookEndpoints(invalid));
    }
    for (const invalid of ["", version.replace("/1", "/latest"),
      version.replace("WEBHOOK_KEYS", "OTHER_KEYS")]) {
      h.state.name = invalid;
      await assert.rejects(h.keys.access("old"), /credential unavailable/);
    }
    assert.equal(h.reads.length, 2);
    h.state.name = version;
    h.state.fail = true;
    await assert.rejects(h.keys.access("old"), (e: Error) =>
      e.message === "RCS webhook credential unavailable" && !e.cause);
  });

test("old and current agent endpoints independently reach the durable inbox",
  async () => {
    const h = fixture();
    for (const endpoint of envelope().endpoints) {
      const http = await h.run(h.request(endpoint));
      assert.deepEqual(http.replies, [{status: 200, body: "ok"}]);
    }
    assert.equal(h.fake.entries().filter(([path]) =>
      path.startsWith(rcsCallbackCollections.callbacks + "/")).length, 2);
    assert.equal((await h.run()).replies[0].status, 200);
    assert.equal(h.fake.entries().filter(([path]) =>
      path.startsWith(rcsCallbackCollections.callbacks + "/")).length, 2);
    assert.equal((await h.run({...h.request(), path: "/current"}))
      .replies[0].status, 403);
    assert.deepEqual(h.errors, []);
  });

test("invalid routing and disabled ingress cannot load secrets or accept work",
  async () => {
    const h = fixture();
    for (const path of ["/", "//old", "/old/", "/../old", "/%6fld"] ) {
      const http = await h.run({...h.request(), path});
      assert.equal(http.replies[0].status, 404);
    }
    assert.equal((await h.run({...h.request(), method: "GET"}))
      .replies[0].status, 405);
    h.state.enabled = false;
    assert.equal((await h.run()).replies[0].status, 503);
    assert.equal(h.reads.length, 0);
    assert.equal(h.fake.entries().length, 0);
    h.state.enabled = true;
    h.state.fail = true;
    assert.deepEqual((await h.run()).replies,
      [{status: 503, body: "Unavailable"}]);
    assert.deepEqual(h.errors, ["failed"]);
  });
