import assert from "node:assert/strict";
import {createHash, createHmac} from "node:crypto";
import test from "node:test";
import {RCS_CALLBACK_MAX_BYTES, rcsNativeReplyId, VerifiedRcsCallback,
  verifyRcsWebhookChallenge} from "./rcsWebhookProtocol";

const clientToken = "fixture-only-rcs-client-token-1234567890";
const expectedAgentId = "test-agent@rbm.goog";
const receivedAt = 1788825600000;
const attemptId = "attempt:" + "a".repeat(64);
const phone = "+919876543210";
const event = () => ({agentId: expectedAgentId, senderPhoneNumber: phone,
  eventType: "DELIVERED", eventId: "event-1", messageId: "message-1",
  sendTime: "2026-09-08T00:00:00.123456789Z"});

function signed(value: unknown) {
  const bytes = Buffer.isBuffer(value) ? value :
    Buffer.from(JSON.stringify(value));
  return {rawBody: Buffer.from(JSON.stringify({message: {
    data: bytes.toString("base64"), messageId: "unsigned-envelope-id",
    attributes: {agentId: "untrusted-agent"},
  }, futureWrapperField: true})), signature:
    createHmac("sha512", clientToken).update(bytes).digest("base64"),
  clientToken, expectedAgentId, receivedAt};
}

function evidence(value: unknown) {
  const result = VerifiedRcsCallback.receive(signed(value));
  assert.equal(result.kind, "verified");
  if (result.kind !== "verified") throw new Error("Expected verified fixture");
  return result.callback.evidence;
}

test("RCS verifies decoded payload bytes and redacts private content", () => {
  const result = evidence(event());
  assert.equal(result.agentId, expectedAgentId);
  assert.equal(result.providerOccurredAt, event().sendTime);
  assert.equal(result.receivedAt, receivedAt);
  assert.deepEqual(result.observation, {kind: "delivery", status: "delivered",
    providerMessageId: "message-1"});
  assert.equal(result.endpointHash,
    createHash("sha256").update(phone).digest("hex"));
  const json = JSON.stringify(result);
  assert.equal(json.includes(phone), false);
  assert.equal(json.includes(clientToken), false);
  assert.equal(json.includes("unsigned-envelope"), false);
  assert.ok(Object.isFrozen(result));
  assert.ok(Object.isFrozen(result.observation));
});

test("RCS wrapper mutations cannot replace signed authority or replay identity",
  () => {
    const input = signed(event());
    const first = evidence(event());
    const wrapper = JSON.parse(input.rawBody.toString());
    wrapper.message.messageId = "different-pubsub-retry";
    wrapper.message.publishTime = "2030-01-01T00:00:00Z";
    wrapper.message.attributes = {
      type: "agent_launch_event", agentId: "another",
    };
    const replay = VerifiedRcsCallback.receive({...input,
      rawBody: Buffer.from(JSON.stringify(wrapper)),
      receivedAt: receivedAt + 1});
    assert.equal(replay.kind, "verified");
    if (replay.kind !== "verified") throw new Error("Fixture");
    assert.equal(replay.callback.evidence.receiptKey, first.receiptKey);
    assert.equal(replay.callback.evidence.payloadHash, first.payloadHash);
    assert.equal(evidence({...event(), eventType: "READ"}).receiptKey,
      first.receiptKey);
    assert.notEqual(evidence({...event(), eventType: "READ"}).payloadHash,
      first.payloadHash);
    assert.notEqual(evidence({...event(), senderPhoneNumber: "+919876543211"})
      .receiptKey, first.receiptKey);
  });

test("RCS rejects tampering, wrong token, agent, signature and base64 coercion",
  () => {
    const input = signed(event());
    for (const signature of [undefined, "", "x", [input.signature],
      input.signature + "\n", input.signature.slice(0, -1),
      createHmac("sha256", clientToken).update(input.rawBody).digest("base64"),
      createHmac("sha512", clientToken).update(input.rawBody).digest("base64"),
    ]) {
      assert.deepEqual(VerifiedRcsCallback.receive({...input, signature}),
        {kind: "rejected", reason: "authentication"});
    }
    assert.equal(VerifiedRcsCallback.receive({...input,
      clientToken: clientToken + "wrong"}).kind, "rejected");
    assert.deepEqual(VerifiedRcsCallback.receive(
      signed({...event(), agentId: "other"})),
    {kind: "rejected", reason: "agent"});
    const wrapper = JSON.parse(input.rawBody.toString());
    wrapper.message.data += "\n";
    assert.equal(VerifiedRcsCallback.receive({...input,
      rawBody: Buffer.from(JSON.stringify(wrapper))}).kind, "rejected");
    const tampered = signed({...event(), eventType: "READ"}).rawBody;
    assert.equal(VerifiedRcsCallback.receive({...input, rawBody: tampered})
      .kind, "rejected");
  });

test("RCS distinguishes confirmed and inconclusive TTL revocation", () => {
  for (const eventType of ["TTL_EXPIRATION_REVOKED",
    "TTL_EXPIRATION_REVOKE_FAILED"]) {
    const {senderPhoneNumber, ...base} = event();
    const value = {...base, eventType, phoneNumber: senderPhoneNumber};
    assert.deepEqual(evidence(value).observation, {kind: "expiration",
      providerMessageId: base.messageId,
      revocation: eventType.endsWith("REVOKED") ? "confirmed" : "unconfirmed"});
    assert.equal(evidence(value).eventFamily, "serverEvent");
    assert.equal(VerifiedRcsCallback.receive(signed({...value,
      senderPhoneNumber})).kind, "rejected");
  }
  assert.deepEqual(evidence({...event(), eventType: "READ"}).observation,
    {kind: "delivery", providerMessageId: "message-1", status: "read"});
});

test("RCS native choices and page actions retain independent correlation",
  () => {
    const value = {agentId: expectedAgentId, senderPhoneNumber: phone,
      messageId: "reply-1", suggestionResponse: {
        postbackData: rcsNativeReplyId(attemptId, 2), text: "Ignore this label",
        type: "REPLY"}};
    assert.deepEqual(evidence(value).observation, {kind: "suggestion",
      source: "message", suggestionType: "reply",
      correlation: {kind: "choice", attemptId, choiceIndex: 2}});
    assert.equal(JSON.stringify(evidence(value))
      .includes("Ignore this label"), false);
    const action = {agentId: expectedAgentId, senderPhoneNumber: phone,
      eventId: "action-1", suggestionResponse: {
        postbackData: "ce-rcs-web1." + attemptId.slice(8), type: "ACTION"}};
    assert.deepEqual(evidence(action).observation, {kind: "suggestion",
      source: "event", suggestionType: "action",
      correlation: {kind: "guestPage", attemptId}});
    for (const postbackData of ["ce-wa1." + "a".repeat(64) + ".2",
      "ce-rcs1." + "a".repeat(64) + ".10", "foreign-button"]) {
      const observed = evidence({...value, suggestionResponse: {
        ...value.suggestionResponse, postbackData,
      }}).observation;
      assert.ok(observed.kind === "suggestion");
      assert.deepEqual(observed.correlation, {kind: "unrecognized"});
    }
    for (const type of [undefined, "UNKNOWN"]) {
      const observed = evidence({...value,
        suggestionResponse: {...value.suggestionResponse, type}}).observation;
      assert.ok(observed.kind === "suggestion");
      assert.equal(observed.suggestionType, "unspecified");
    }
    for (const index of [-1, 10, 1.5, NaN]) {
      assert.throws(() => rcsNativeReplyId(attemptId, index));
    }
    assert.throws(() => rcsNativeReplyId(attemptId + "\n", 1));
  });

test("RCS native and keyword subscription requests cannot grant consent",
  () => {
    for (const eventType of ["UNSUBSCRIBE", "SUBSCRIBE"]) {
      const value = {agentId: expectedAgentId, senderPhoneNumber: phone,
        eventId: "subscription-1", eventType};
      assert.deepEqual(evidence(value).observation, {kind: "subscription",
        source: "event", requested: eventType === "SUBSCRIBE" ?
          "subscribe" : "unsubscribe"});
      assert.equal(evidence(value).providerOccurredAt, null);
    }
    for (const [text, requested] of [
      [" STOP ", "unsubscribe"], ["baja", "unsubscribe"],
      ["parar", "unsubscribe"],
      ["START", "subscribe"], ["alta", "subscribe"], ["Démarrer", "subscribe"],
      ["começar", "subscribe"],
    ]) {
      assert.deepEqual(evidence({agentId: expectedAgentId,
        senderPhoneNumber: phone,
        messageId: "keyword-1", text}).observation,
      {kind: "subscription", source: "keyword", requested});
    }
    assert.deepEqual(evidence({agentId: expectedAgentId,
      senderPhoneNumber: phone,
      messageId: "keyword-1", text: "don't STOP yet"}).observation,
    {kind: "unstructuredMessage", content: "text"});
  });

test("RCS location and files cannot manufacture presence or trigger downloads",
  () => {
    for (const content of [
      {location: {latitude: 12, longitude: 77}},
      {userFile: {payload: {fileUri: "https://untrusted.example/private"}}},
      {text: "Meet me at my private address"},
    ]) {
      const value = evidence({agentId: expectedAgentId,
        senderPhoneNumber: phone,
        messageId: "freeform-1", ...content});
      assert.equal(value.observation.kind, "unstructuredMessage");
      const json = JSON.stringify(value);
      assert.equal(json.includes("private"), false);
      assert.equal(json.includes("latitude"), false);
      assert.equal(json.includes("checkedIn"), false);
    }
  });

test("RCS malformed, oversized and unsupported callbacks are bounded", () => {
  const {sendTime, ...withoutTime} = event();
  assert.equal(evidence(withoutTime).providerOccurredAt, null);
  for (const value of [null, [], "text", Buffer.from([0xc0, 0x80]),
    {...event(), senderPhoneNumber: phone + "\n"},
    {...event(), senderPhoneNumber: "919876543210"},
    {...event(), messageId: ""}, {...event(), eventId: ""},
    {...event(), sendTime: "2026-02-30T01:00:00Z"},
    {...event(), sendTime: sendTime + "\n"},
    {...event(), sendTime: "2026-09-08T25:00:00Z"},
    {...event(), suggestionResponse: {postbackData: "conflicting-content"}},
    {...withoutTime, eventType: undefined, text: "x", location: {}},
  ]) assert.equal(VerifiedRcsCallback.receive(signed(value)).kind, "rejected");
  assert.equal(VerifiedRcsCallback.receive({...signed(event()),
    rawBody: Buffer.alloc(RCS_CALLBACK_MAX_BYTES + 1)}).kind, "rejected");
  assert.equal(VerifiedRcsCallback.receive(signed({padding: "a".repeat(42000)}))
    .kind, "rejected");
  assert.equal(VerifiedRcsCallback.receive(signed({...event(),
    eventType: "FUTURE_STATUS"})).kind, "ignored");
  assert.equal(VerifiedRcsCallback.receive(signed({agentId: expectedAgentId,
    eventId: "launch-1", newLaunchState: "LAUNCHED"})).kind, "ignored");
  assert.throws(() => VerifiedRcsCallback.receive({...signed(event()),
    clientToken: "weak"}));
  assert.throws(() => VerifiedRcsCallback.receive({...signed(event()),
    receivedAt: NaN}));
});

test("RCS challenge checks its token before returning a bounded raw secret",
  () => {
    const body = (patch = {}) => Buffer.from(JSON.stringify({clientToken,
      secret: "challenge-secret", ...patch}));
    assert.equal(verifyRcsWebhookChallenge(body(), clientToken),
      "challenge-secret");
    for (const patch of [{clientToken: "wrong"},
      {secret: "secret\r\nheader"}, {secret: "x".repeat(1025)}, {extra: true},
    ]) {
      assert.equal(verifyRcsWebhookChallenge(body(patch), clientToken), null);
    }
    assert.equal(verifyRcsWebhookChallenge(signed(event()).rawBody,
      clientToken), null);
  });
