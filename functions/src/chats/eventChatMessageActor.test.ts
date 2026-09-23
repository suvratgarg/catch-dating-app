import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {updateEventChatAccessHandler} from "./eventChatAccess";
import {sendEventChatMessageHandler, setEventChatReactionHandler,
  setEventChatTypingHandler} from "./eventChatMessages";

const deps = {db: () => {
  throw new Error("A mismatched account must never reach Firestore.");
}, now: () => {
  throw new Error("A mismatched account must never prepare a mutation.");
}, rateLimit: async () => undefined};
const cases = [
  ["send", sendEventChatMessageHandler,
    {requestId: "request", text: "Private draft", replyToMessageId: null}],
  ["reaction", setEventChatReactionHandler, {requestId: "request",
    messageId: "message", reaction: "love", expectedRevision: 0}],
  ["typing", setEventChatTypingHandler,
    {isTyping: true, expectedRevision: 0}],
  ["join", updateEventChatAccessHandler, {action: "join", requestId: "request",
    expectedRevision: 0, termsVersion: "event-chat-v1"}],
] as const;
for (const [name, handler, payload] of cases) {
  test(`${name} cannot apply another account's pending intent`, async () => {
    const request = {auth: {uid: "signed-in-account", token: {}},
      data: {eventId: "event", expectedUid: "reviewed-account", ...payload}} as
      unknown as CallableRequest<unknown>;
    await assert.rejects(handler(request, deps), {code: "permission-denied"});
    const missing = {eventId: "event", ...payload};
    await assert.rejects(handler({...request, data: missing}, deps),
      {code: "invalid-argument"});
  });
}
