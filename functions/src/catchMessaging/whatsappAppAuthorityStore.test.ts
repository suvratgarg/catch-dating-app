import assert from "node:assert/strict";
import {test} from "node:test";
import type {Firestore} from "firebase-admin/firestore";
import {FormPaymentTestStore} from "../payments/formPayments/formPaymentTestStore";
import {createSyntheticCatchAuthority} from "./whatsappAuthorityTestHarness";
import {CATCH_APP_AUTHORITIES, withCatchExternalAuthFence, withCatchFreshAuthContext} from
  "./whatsappAppAuthorityStore";

test("fresh Auth context rejects changed roles before claim and exposes remove/restore limit", async () => {
  const now = 1800000000000;
  let roles: Array<"adminOwner" | "support"> = ["adminOwner"];
  let disabled = false;
  let reads = 0;
  const firebase = {
    observe: async (uid: string) => {
      reads++;
      return {projectId: "demo-catch-authority", uid,
        creationTimeMillis: 1000, observedAtMillis: now, disabled,
        relevantRoles: uid === "owner" ? [...roles] : [],
        endpointHash: null, tokensValidAfterMillis: 0};
    },
    verifySession: async (uid: string, token: string) => {
      assert.equal(uid, "owner"); assert.equal(token, "current-token");
      return {projectId: "demo-catch-authority", uid,
        authTimeSeconds: 100, expiresAtSeconds: now / 1000 + 100};
    },
  };
  const identity = {projectId: "demo-catch-authority", uids: ["owner", "participant"],
    actorUid: "owner", actorIdToken: "current-token"};
  await assert.rejects(withCatchFreshAuthContext(firebase, identity, async (context) => {
    roles = [];
    await context.recheck();
  }, () => now));
  assert.ok(reads >= 4);
  roles = ["adminOwner"];
  await assert.rejects(withCatchFreshAuthContext(firebase, identity, async (context) => {
    disabled = true;
    await context.recheck();
  }, () => now));
  disabled = false;
  // An external remove-and-restore wholly between two observations is not
  // observable by this narrower protocol. Durable app denials still use CAS.
  await withCatchFreshAuthContext(firebase, identity, async (context) => {
    disabled = true;
    disabled = false;
    await context.recheck();
    await assert.rejects(context.readSession("participant"));
  }, () => now);
  await assert.rejects(withCatchFreshAuthContext(firebase, identity,
    async () => undefined, () => NaN));
  let clock = now;
  await assert.rejects(withCatchFreshAuthContext(firebase, identity,
    async (context) => {
      clock++;
      context.assertHeld();
      clock--;
      context.assertHeld();
    }, () => clock));
});

function fixture() {
  let now = 1800000000000;
  const fake = Object.assign(new FormPaymentTestStore(), {
    projectId: "demo-catch-authority", databaseId: "(default)"});
  const db = fake as unknown as Firestore;
  const auth = createSyntheticCatchAuthority(db, () => now, "+919000000001");
  auth.seedInto(fake.records);
  return {fake, auth, tick: (n: number) => {now += n;}, now: () => now};
}
test("external Auth fence rejects missing issuer and lost lease", async () => {
  const f = fixture();
  const identity = {projectId: "demo-catch-authority",
    uids: ["participant", "owner"]};
  let calls = 0;
  await assert.rejects(withCatchExternalAuthFence(null, identity,
    async () => {
      calls++;
    }));
  const issuer = {withExclusiveFence: async <T>(scope: {
    projectId: string; uids: readonly string[]; nonce: string},
    callback: (fence: ReturnType<typeof f.auth.fence> & {
    nonce: string; expiresAtMillis: number}) => Promise<T>) => {
    assert.deepEqual(scope.uids, ["owner", "participant"]);
    return callback({...f.auth.fence(scope.uids, () => undefined),
      nonce: scope.nonce,
      expiresAtMillis: f.now() + 10000});
  }};
  await withCatchExternalAuthFence(issuer, identity, async () => {
    calls++;
  }, f.now);
  assert.equal(calls, 1);
  await assert.rejects(withCatchExternalAuthFence(issuer, identity,
    (fence) => fence.readSession("outsider"), f.now));
  const wrongNonce = {withExclusiveFence: async <T>(scope: {
    projectId: string; uids: readonly string[]; nonce: string},
    callback: (fence: ReturnType<typeof f.auth.fence> & {
    nonce: string; expiresAtMillis: number}) => Promise<T>) =>
    issuer.withExclusiveFence(scope, async (fence) =>
      callback({...fence, nonce: "wrong"}))};
  await assert.rejects(withCatchExternalAuthFence(wrongNonce, identity,
    async () => {
      calls++;
    }, f.now));
  assert.equal(calls, 1);
  await assert.rejects(withCatchExternalAuthFence(issuer, identity,
    async () => {
      calls++;
      f.tick(10001);
    }, f.now));
  assert.equal(calls, 2, "postcallback loss is uncertain");
  await assert.rejects(withCatchExternalAuthFence(issuer, identity,
    async () => {
      calls++;
    }, () => NaN));
  assert.equal(calls, 2);
  let readClock = f.now() + 1;
  await assert.rejects(withCatchExternalAuthFence(issuer, identity,
    async (fence) => {
      calls++;
      readClock--;
      fence.assertHeld();
    }, () => readClock));
});
test("authority CAS denial and grant require exact current issuer and target generation", async () => {
  const f = fixture();
  const denied = await f.auth.store.deny("owner", "participant", 1);
  assert.equal(denied.state, "denied"); assert.equal(denied.revision, 2);
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  const prepared = await f.auth.store.prepare("owner", "synthetic-current-id-token", "participant",
    {expectedRevision: 2, nonce: "b".repeat(64), capabilities: ["receive"],
      endpointHash: f.auth.bindings.recipient.endpointHash, expiresAtMillis: f.now() + 10000});
  assert.equal(prepared.state, "granting"); assert.equal(prepared.capabilities.length, 0);
  await assert.rejects(f.auth.store.finalize("owner", "synthetic-current-id-token", "participant",
    {expectedRevision: 3, nonce: "c".repeat(64)}));
  const active = await f.auth.store.finalize("owner", "synthetic-current-id-token", "participant",
    {expectedRevision: 3, nonce: "b".repeat(64)});
  assert.equal(active.state, "active"); assert.equal(active.revision, 4);
  await assert.rejects(f.auth.store.finalize("owner", "synthetic-current-id-token", "participant",
    {expectedRevision: 3, nonce: "b".repeat(64)}));
  f.tick(2000);
  const bindings = await f.auth.store.runFenced(["owner", "participant"], (tx, fence) =>
    f.auth.store.readinessBindings(tx, fence, {reviewerUid: "owner", recipientUid: "participant",
      endpointHash: active.endpointHash!}));
  assert.equal(bindings.recipient.revision, 4);
});

test("missing authority, recycled identity and missing full-span fence deny", async () => {
  const f = fixture();
  f.fake.records.delete(CATCH_APP_AUTHORITIES + "/participant");
  await assert.rejects(f.auth.store.runFenced(["owner", "participant"], (tx, fence) =>
    f.auth.store.readinessBindings(tx, fence, {reviewerUid: "owner", recipientUid: "participant",
      endpointHash: f.auth.bindings.recipient.endpointHash!})));
  f.auth.seedInto(f.fake.records);
  const observe = f.auth.store.deps.firebase.observe;
  f.auth.store.deps.firebase.observe = async (uid) => ({...await observe(uid), creationTimeMillis: 1001});
  await assert.rejects(f.auth.store.runFenced(["owner", "participant"], (tx, fence) =>
    f.auth.store.readinessBindings(tx, fence, {reviewerUid: "owner", recipientUid: "participant",
      endpointHash: f.auth.bindings.recipient.endpointHash!})));
  f.auth.store.deps.withAuditedAuthFence = async () => {throw new Error("Unavailable");};
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  assert.equal(f.fake.records.get(CATCH_APP_AUTHORITIES + "/participant")!.state, "active");
});

test("unknown authority commits and lost fences never trigger a blind retry", async () => {
  const f = fixture(); let calls = 0;
  const run = f.fake.runTransaction.bind(f.fake);
  Object.defineProperty(f.fake, "runTransaction", {configurable: true, value: async (...args: unknown[]) => {
    calls++; return Reflect.apply(run, f.fake, args);
  }});
  f.fake.failNextCommit = true;
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  assert.equal(calls, 1);
  assert.equal(f.fake.records.get(CATCH_APP_AUTHORITIES + "/participant")!.revision, 1);
  let externallyHeld = true;
  f.auth.store.deps.withAuditedAuthFence = async ({uids}, callback) => callback(
    f.auth.fence(uids, () => {
      if (!externallyHeld) throw Object.assign(new Error("Lost fence"), {code: 10});
    }));
  Object.defineProperty(f.fake, "runTransaction", {configurable: true, value: async (...args: unknown[]) => {
    calls++; const result = await Reflect.apply(run, f.fake, args);
    externallyHeld = false; return result;
  }});
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  assert.equal(calls, 2, "Postcommit code10 must not trigger another attempt");
  assert.equal(f.fake.records.get(CATCH_APP_AUTHORITIES + "/participant")!.revision, 2);
});

test("committed but unacknowledged authority change is never retried", async () => {
  const f = fixture(); let attempts = 0;
  const run = f.fake.runTransaction.bind(f.fake);
  Object.defineProperty(f.fake, "runTransaction", {configurable: true,
    value: async (...args: unknown[]) => {
      attempts++;
      await Reflect.apply(run, f.fake, args);
      throw Object.assign(new Error("Commit response lost"), {code: 2});
    }});
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  assert.equal(attempts, 1);
  assert.equal(f.fake.records.get(CATCH_APP_AUTHORITIES + "/participant")!.revision, 2);
  await assert.rejects(f.auth.store.deny("owner", "participant", 1));
  assert.equal(f.fake.records.get(CATCH_APP_AUTHORITIES + "/participant")!.revision, 2);
});
