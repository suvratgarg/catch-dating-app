import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import {authorizeCatchAppCapability, denyCatchAppAuthority,
  prepareCatchAppGrant, finalizeCatchAppGrant, readCatchAppAuthority,
  catchReadinessAuthorityBindings, catchReplyAuthorityBindings,
  assertCatchAuthorityBinding} from "./whatsappAppAuthority";
import type {CatchAppAuthority, CatchAuthorityPrincipal,
  CatchFirebaseObservation, CatchVerifiedSession} from "./whatsappAppAuthority";

const projectId = "catchdates-dev";
const endpointHash = "a".repeat(64);
const nonce = "b".repeat(64);
const now = 10000;
function auth(uid: string): CatchFirebaseObservation {
  return {projectId, uid, creationTimeMillis: 1000, observedAtMillis: now,
    disabled: false, relevantRoles: ["adminOwner", "support"],
    endpointHash, tokensValidAfterMillis: 0};
}
function session(uid: string): CatchVerifiedSession {
  return {projectId, uid, authTimeSeconds: 9, expiresAtSeconds: 100};
}
/** Synthetic pre-existing owner; no production bootstrap is implemented. */
function owner(): CatchAuthorityPrincipal {
  const uid = "owner";
  const incarnation = createHash("sha256").update(JSON.stringify([
    "catch.firebase-creation/v1", projectId, uid, 1000])).digest("hex");
  const record: CatchAppAuthority = {schemaVersion: 1, projectId, uid,
    revision: 1, incarnation, state: "active", authNotBeforeSeconds: 2,
    updatedAtMillis: 2000, capabilities: ["review", "reply"],
    endpointHash: null, pending: null, grantedBy: null};
  return {record, auth: auth(uid), session: session(uid)};
}
function pending() {
  const denied = denyCatchAppAuthority(null,
    {projectId, uid: "recipient"}, 0, 9000);
  return prepareCatchAppGrant(denied, {expectedRevision: denied.revision,
    nonce, capabilities: ["receive"], endpointHash, expiresAtMillis: 20000},
  owner(), auth("recipient"), now);
}
function activeRecipient() {
  const p = pending();
  return finalizeCatchAppGrant(p, p.revision, nonce, owner(),
    auth("recipient"), now);
}

test("new record is denied; preparation grants nothing; finalize is exact CAS",
  () => {
    const p = pending();
    assert.equal(p.state, "granting");
    assert.deepEqual(p.capabilities, []);
    assert.equal(p.endpointHash, null);
    assert.equal(p.revision, 2);
    assert.throws(() => authorizeCatchAppCapability({record: p,
      auth: auth("recipient")}, "receive", now,
    {projectId, uid: "recipient", endpointHash}));
    const active = finalizeCatchAppGrant(p, 2, nonce, owner(),
      auth("recipient"), now);
    assert.equal(active.state, "active");
    assert.equal(active.revision, 3);
    assert.equal(active.grantedBy?.uid, "owner");
    assert.equal(authorizeCatchAppCapability({record: active,
      auth: auth("recipient")}, "receive", now,
    {projectId, uid: "recipient", endpointHash}).revision, 3);
    assert.throws(() => finalizeCatchAppGrant(active, 2, nonce, owner(),
      auth("recipient"), now));
  });

test("revoke wins over stale finalizer, including revoke then new grant",
  () => {
    const p = pending();
    const revoked = denyCatchAppAuthority(p, p, p.revision, now);
    assert.equal(revoked.revision, 3);
    assert.throws(() => finalizeCatchAppGrant(revoked, p.revision,
      nonce, owner(), auth("recipient"), now));
    const newer = prepareCatchAppGrant(revoked, {expectedRevision: 3,
      nonce: "c".repeat(64), capabilities: ["receive"], endpointHash,
      expiresAtMillis: 20000}, owner(), auth("recipient"), now);
    assert.throws(() => finalizeCatchAppGrant(newer, p.revision,
      nonce, owner(), auth("recipient"), now));
    assert.throws(() => finalizeCatchAppGrant(newer, newer.revision,
      nonce, owner(), auth("recipient"), now));
  });

test("owner revoke/regrant or recreation prevents pending grant completion",
  () => {
    const p = pending();
    const o = owner();
    const original = readCatchAppAuthority(o.record);
    o.record = denyCatchAppAuthority(original, original, 1, now);
    assert.throws(() => finalizeCatchAppGrant(p, p.revision, nonce,
      o, auth("recipient"), now));
    o.record = {...original, revision: 3};
    assert.throws(() => finalizeCatchAppGrant(p, p.revision, nonce,
      o, auth("recipient"), now));
    o.record = original;
    o.auth = {...auth("owner"), creationTimeMillis: 2000};
    assert.throws(() => finalizeCatchAppGrant(p, p.revision, nonce,
      o, auth("recipient"), now));
  });

test("app cutoff excludes same-second tokens and never moves backwards",
  () => {
    const o = owner();
    const target = denyCatchAppAuthority(null,
      {projectId, uid: "actor"}, 0, 9999);
    const p = prepareCatchAppGrant(target, {expectedRevision: 1, nonce,
      capabilities: ["reply"], endpointHash: null, expiresAtMillis: 20000},
    o, auth("actor"), 10000);
    const active = finalizeCatchAppGrant(p, 2, nonce, o, auth("actor"), 10001);
    assert.equal(active.authNotBeforeSeconds, 11);
    const actor = {record: active, auth: auth("actor"),
      session: {...session("actor"), authTimeSeconds: 10}};
    assert.throws(() => authorizeCatchAppCapability(actor, "reply", 11000,
      {projectId, uid: "actor"}));
    actor.session.authTimeSeconds = 11;
    assert.equal(authorizeCatchAppCapability(actor, "reply", 11000,
      {projectId, uid: "actor"}).uid, "actor");
    const revoked = denyCatchAppAuthority(active, active, 3, 11001);
    assert.equal(revoked.authNotBeforeSeconds, 12);
    assert.throws(() => denyCatchAppAuthority(revoked, revoked, 4, 11000));
  });

test("missing, malformed, uncertain and expired Firebase observations deny",
  () => {
    for (const value of [null, {}, {...auth("owner"), disabled: true},
      {...auth("owner"), observedAtMillis: now + 1},
      {...auth("owner"), observedAtMillis: -1},
      {...auth("owner"), observedAtMillis: NaN},
      {...auth("owner"), creationTimeMillis: now + 1},
      {...auth("owner"), relevantRoles: ["support"]},
      {...auth("owner"), unknown: true}]) {
      assert.throws(() => authorizeCatchAppCapability({...owner(), auth: value},
        "review", now, {projectId, uid: "owner"}));
    }
    assert.throws(() => authorizeCatchAppCapability(owner(), "review", 40001,
      {projectId, uid: "owner"}));
    for (const token of [null, {...session("owner"), authTimeSeconds: 11},
      {...session("owner"), authTimeSeconds: 9.5},
      {...session("owner"), expiresAtSeconds: 10},
      {...session("owner"), projectId: "foreign-project"}]) {
      assert.throws(() => authorizeCatchAppCapability(
        {...owner(), session: token},
        "review", now, {projectId, uid: "owner"}));
    }
    assert.throws(() => authorizeCatchAppCapability({...owner(), auth: {
      ...auth("owner"), tokensValidAfterMillis: 9001}}, "review", now,
    {projectId, uid: "owner"}));
  });

test("target incarnation, verified endpoint and exact project cannot change",
  () => {
    const p = pending();
    for (const target of [{...auth("recipient"), creationTimeMillis: 2000},
      {...auth("recipient"), endpointHash: "d".repeat(64)},
      {...auth("recipient"), projectId: "foreign-project"}]) {
      assert.throws(() =>
        finalizeCatchAppGrant(p, 2, nonce, owner(), target, now));
    }
    const active = activeRecipient();
    assert.throws(() => authorizeCatchAppCapability({record: active,
      auth: {...auth("recipient"), endpointHash: "d".repeat(64)}},
    "receive", now, {projectId, uid: "recipient", endpointHash}));
    assert.throws(() => authorizeCatchAppCapability({record: active,
      auth: auth("recipient")}, "receive", now,
    {projectId: "foreign-project", uid: "recipient", endpointHash}));
  });

test("strict records, commands and safe-integer limits never reset revision",
  () => {
    const p = pending();
    for (const record of [null, {}, {...p, revision: 0},
      {...p, revision: Number.MAX_SAFE_INTEGER + 1},
      {...p, unexpected: "private"}, {...p, capabilities: ["reply"]},
      {...p, pending: {...p.pending, capabilities: ["receive", "receive"]}}]) {
      assert.throws(() => readCatchAppAuthority(record));
    }
    assert.throws(() => denyCatchAppAuthority({}, p, 0, now));
    assert.throws(() => denyCatchAppAuthority(p, p, 0, now));
    assert.throws(() => denyCatchAppAuthority({...p,
      revision: Number.MAX_SAFE_INTEGER}, p, Number.MAX_SAFE_INTEGER, now));
    assert.throws(() => denyCatchAppAuthority(null, p, 0,
      Number.MAX_SAFE_INTEGER));
    const command = {expectedRevision: 2, nonce, capabilities: ["receive"],
      endpointHash, expiresAtMillis: 20000, selfApproved: true};
    assert.throws(() => prepareCatchAppGrant(p,
      command as Parameters<typeof prepareCatchAppGrant>[1],
      owner(), auth("recipient"), now));
    assert.throws(() => finalizeCatchAppGrant(p, 2, nonce, owner(),
      {...auth("recipient"), observedAtMillis: 20000}, 20000));
  });

test("saved readiness and send bindings cannot survive a later own revision",
  () => {
    const recipient = {record: activeRecipient(), auth: auth("recipient")};
    const input = {projectId, reviewerUid: "owner", recipientUid: "recipient",
      endpointHash, reviewer: owner(), recipient};
    const readiness = catchReadinessAuthorityBindings(input, now);
    const operation = catchReplyAuthorityBindings({...input,
      actorUid: "owner", actor: owner()}, now);
    assert.deepEqual(operation.reviewer, readiness.reviewer);
    assert.equal(operation.actor.capability, "reply");
    recipient.record = denyCatchAppAuthority(recipient.record,
      recipient.record, recipient.record.revision, now);
    assert.throws(() => catchReplyAuthorityBindings({...input,
      actorUid: "owner", actor: owner()}, now));
    assert.throws(() => assertCatchAuthorityBinding({
      ...readiness.recipient, revision: readiness.recipient.revision + 1},
    readiness.recipient));
    // Model does not cancel, reset or retry an already committed send.
    assert.equal(operation.recipient.revision, 3);
  });

test("transition outputs do not alias pending commands or owner bindings",
  () => {
    const p = pending();
    const copy = structuredClone(p);
    const active = finalizeCatchAppGrant(p, 2, nonce, owner(),
      auth("recipient"), now);
    active.capabilities.push("reply");
    active.grantedBy!.revision = 999;
    assert.deepEqual(p, copy);
  });


test("same-second Firebase account recreation changes the incarnation",
  () => {
    const initial = denyCatchAppAuthority(null,
      {projectId, uid: "recipient"}, 0, 9000);
    const firstAuth = {...auth("recipient"), creationTimeMillis: 1001};
    const p = prepareCatchAppGrant(initial, {expectedRevision: 1, nonce,
      capabilities: ["receive"], endpointHash, expiresAtMillis: 20000},
    owner(), firstAuth, now);
    const active = finalizeCatchAppGrant(p, 2, nonce, owner(), firstAuth, now);
    const expected = {projectId, uid: "recipient", endpointHash};
    assert.equal(authorizeCatchAppCapability({record: active, auth: firstAuth},
      "receive", now, expected).revision, 3);
    const recreated = {...firstAuth, creationTimeMillis: 1002};
    assert.throws(() => authorizeCatchAppCapability({record: active,
      auth: recreated}, "receive", now, expected));
    assert.throws(() => finalizeCatchAppGrant(p, 2, nonce, owner(),
      recreated, now));
  });
