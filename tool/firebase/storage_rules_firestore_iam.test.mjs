import assert from "node:assert/strict";
import test from "node:test";
import {
  ensureStorageRulesBinding,
  parseArgs,
  parseFirebaseWebConfig,
  policyHasStorageRulesBinding,
  reconcileTarget,
  storageRulesFirestoreRole,
  storageServiceAgentMember,
} from "./storage_rules_firestore_iam.mjs";

const member = storageServiceAgentMember("123456789");

test("known-bad missing binding is detected", () => {
  const policy = {
    etag: "etag-1",
    bindings: [{role: "roles/viewer", members: ["user:a@example.com"]}],
  };
  assert.equal(policyHasStorageRulesBinding(policy, member), false);
  assert.equal(ensureStorageRulesBinding(policy, member).changed, true);
});

test("existing unconditional binding is idempotent", () => {
  const policy = {
    etag: "etag-1",
    version: 3,
    bindings: [{role: storageRulesFirestoreRole, members: [member]}],
  };
  const result = ensureStorageRulesBinding(policy, member);
  assert.equal(result.changed, false);
  assert.equal(result.policy, policy);
});

test("apply preserves etag, conditions, roles, and unrelated members", () => {
  const policy = {
    etag: "etag-1",
    version: 3,
    bindings: [
      {role: "roles/viewer", members: ["user:a@example.com"]},
      {
        role: storageRulesFirestoreRole,
        members: ["serviceAccount:conditioned@example.com"],
        condition: {title: "temporary", expression: "request.time < timestamp('2030-01-01T00:00:00Z')"},
      },
      {
        role: storageRulesFirestoreRole,
        members: ["serviceAccount:existing@example.com"],
      },
    ],
  };
  const result = ensureStorageRulesBinding(policy, member);
  assert.equal(result.changed, true);
  assert.equal(result.policy.etag, "etag-1");
  assert.deepEqual(result.policy.bindings[0], policy.bindings[0]);
  assert.deepEqual(result.policy.bindings[1], policy.bindings[1]);
  assert.deepEqual(result.policy.bindings[2].members, [
    "serviceAccount:existing@example.com",
    member,
  ].sort());
});

test("reconcile writes once and verifies the resulting policy", async () => {
  const calls = [];
  const missing = {etag: "etag-1", bindings: []};
  const ready = {
    etag: "etag-2",
    bindings: [{role: storageRulesFirestoreRole, members: [member]}],
  };
  const responses = [missing, ready, ready];
  const request = async (options) => {
    calls.push(options);
    return {data: responses.shift()};
  };
  const result = await reconcileTarget({
    target: {env: "dev", projectId: "demo", member},
    request,
    apply: true,
  });
  assert.deepEqual(result, {changed: true, ready: true, applied: true});
  assert.equal(calls.length, 3);
  assert.match(calls[1].url, /:setIamPolicy$/u);
  assert.equal(calls[1].data.policy.etag, "etag-1");
});

test("prod apply requires explicit allow-prod", () => {
  assert.throws(
    () => parseArgs(["--env", "prod", "--apply"]),
    /requires --allow-prod/u
  );
  assert.equal(
    parseArgs(["--env", "prod", "--apply", "--allow-prod"]).apply,
    true
  );
});

test("Firebase config parser returns checked project identity", () => {
  const config = parseFirebaseWebConfig(`
    apiKey: 'public-key',
    appId: '1:123456789:web:abc',
    messagingSenderId: '123456789',
    projectId: 'catchdates-dev',
    storageBucket: 'catchdates-dev.firebasestorage.app'
  `);
  assert.equal(config.projectId, "catchdates-dev");
  assert.equal(config.projectNumber, "123456789");
});
