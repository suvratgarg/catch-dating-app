import assert from "node:assert/strict";
import test from "node:test";
import {
  conversationPushTokens, resolveConversationPushTokens,
} from "./conversationPushTargets";

const installations = [
  {appRole: "consumer", token: "consumer-a"},
  {appRole: "consumer", token: "consumer-b"},
  {appRole: "consumer", token: "consumer-a"},
  {appRole: "host", token: "host-a"},
  {appRole: "host", token: ""},
  {appRole: "unknown", token: "invalid"},
];

test("Consumer uses unique Consumer installations and legacy fallback", () => {
  assert.deepEqual(
    conversationPushTokens(installations, "consumer", "consumer-a"),
    ["consumer-a", "consumer-b"]);
  assert.deepEqual(
    conversationPushTokens([], "consumer", "legacy"), ["legacy"]);
});

test("Host never falls back to the Consumer token", () => {
  assert.deepEqual(
    conversationPushTokens(installations, "host", "consumer-a"), ["host-a"]);
  assert.deepEqual(conversationPushTokens([], "host", "legacy"), []);
});

test("known Host addresses cannot receive legacy dating pushes", () => {
  assert.deepEqual(conversationPushTokens(installations, "consumer", "host-a"),
    ["consumer-a", "consumer-b"]);
});

test("resolver reads installations for a Host-only account", async () => {
  const paths: string[] = [];
  const db = {collection: (path: string) => {
    paths.push(path);
    return {doc: (uid: string) => {
      paths.push(uid);
      return {collection: (collection: string) => {
        paths.push(collection);
        return {get: async () => ({
          docs: installations.map((value) => ({data: () => value})),
        })};
      }};
    }};
  }};
  assert.deepEqual(await resolveConversationPushTokens(
    db as unknown as FirebaseFirestore.Firestore, "host-uid", "host", undefined
  ), ["host-a"]);
  assert.deepEqual(paths, ["users", "host-uid", "pushInstallations"]);
});
