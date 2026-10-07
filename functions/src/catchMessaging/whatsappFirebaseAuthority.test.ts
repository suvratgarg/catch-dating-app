import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import {UserRecord} from "firebase-admin/auth";
import {createCatchFirebaseAuthority,
  createCatchGoogleFirebaseLookupTransport} from "./whatsappFirebaseAuthority";
import type {CatchFirebaseAuthorityOptions,
  CatchFirebaseLookupRequest} from "./whatsappFirebaseAuthority";
import {authorizeCatchAppCapability} from "./whatsappAppAuthority";
import {catchEndpointHash} from "./whatsappReply";
import {assertPlannedSetupIdentity, planOperatorSetup, setupHash} from
  "./whatsappOperatorSetup";

const projectId = "catchdates-dev";
const uid = "recipient";
const phone = "+919000000001";
const unavailable = {message: "Catch app authority unavailable."};
const currentTime = 1700000100000;
function sdkRecord(wire: object): UserRecord {
  // The published type omits the internal REST constructor argument. Exercise
  // the pinned SDK's decoder without initializing Auth or touching credentials.
  return Reflect.construct(UserRecord, [wire]) as UserRecord;
}
// Projected accounts:lookup wire fixtures; no real identity/session material.
function optionalLookupUsers() {
  return {
    actor: {localId: "google-operator", createdAt: "1700000000123",
      validSince: "1700000010", customAttributes: "{}"},
    recipient: {localId: uid, createdAt: "1700000000456",
      customAttributes: JSON.stringify({admin: true}), phoneNumber: phone},
  };
}
function user() {
  return {localId: uid, createdAt: "1001", validSince: "1", disabled: false,
    customAttributes: JSON.stringify({adminOwner: true, support: true,
      admin: true, finance: true}), phoneNumber: phone};
}
function token() {
  return {uid, sub: uid, aud: projectId,
    iss: "https://securetoken.google.com/" + projectId,
    auth_time: 9, iat: 9, exp: 100, firebase: {sign_in_provider: "password"}};
}
function fixture() {
  const requests: CatchFirebaseLookupRequest[] = [];
  const verifications: unknown[][] = [];
  let time = 10000;
  let runtimeProject = projectId;
  let response: unknown = {users: [user()]};
  let verified: unknown = token();
  const options: CatchFirebaseAuthorityOptions = {
    projectId,
    now: () => time,
    transport: {
      getProjectId: async () => runtimeProject,
      lookup: async (request) => {
        requests.push(request);
        return response;
      },
    },
    auth: {
      app: {options: {projectId}},
      verifyIdToken: async (...args: unknown[]) => {
        verifications.push(args);
        return verified;
      },
    } as unknown as CatchFirebaseAuthorityOptions["auth"],
  };
  return {options, requests, verifications,
    setTime: (value: number) => {
      time = value;
    },
    setProject: (value: string) => {
      runtimeProject = value;
    },
    setResponse: (value: unknown) => {
      response = value;
    },
    setToken: (value: unknown) => {
      verified = value;
    },
    adapter: createCatchFirebaseAuthority(options)};
}

test("construction is lazy and protected lookup projects only required fields",
  async () => {
    const live = createCatchGoogleFirebaseLookupTransport();
    assert.equal(typeof live.lookup, "function");
    const f = fixture();
    assert.equal(f.requests.length, 0);
    const observation = await f.adapter.observe(uid);
    assert.deepEqual(observation, {projectId, uid, creationTimeMillis: 1001,
      observedAtMillis: 10000, disabled: false,
      relevantRoles: ["adminOwner", "support"],
      endpointHash: catchEndpointHash(phone), tokensValidAfterMillis: 1000});
    const request = f.requests[0];
    assert.equal(request.url, "https://identitytoolkit.googleapis.com/v1/" +
      "projects/catchdates-dev/accounts:lookup");
    assert.deepEqual(request.body, {localId: [uid]});
    assert.equal(request.method, "POST");
    assert.equal(request.projectId, projectId);
    assert.equal(request.fields,
      "users(localId,createdAt,validSince,disabled," +
      "customAttributes,phoneNumber,tenantId)");
    assert.equal(request.timeoutMillis, 30000);
    assert.equal(request.redirect, "error");
    assert.equal(request.retry, false);
    assert.equal(request.signal.aborted, false);
    assert.equal(f.verifications.length, 0);
  });

test("current true role flags and canonical phone are used",
  async () => {
    const f = fixture();
    f.setResponse({users: [{...user(), customAttributes: JSON.stringify({
      admin: true, adminOwner: "true", support: 1,
      nested: {adminOwner: true}}), phoneNumber: undefined}]});
    const auth = await f.adapter.observe(uid);
    assert.deepEqual(auth.relevantRoles, []);
    assert.equal(auth.endpointHash, null);
    f.setResponse({users: [{...user(), customAttributes: undefined}]});
    assert.deepEqual((await f.adapter.observe(uid)).relevantRoles, []);
    f.setResponse({users: [{...user(), phoneNumber: "+919000000002"}]});
    assert.notEqual((await f.adapter.observe(uid)).endpointHash,
      catchEndpointHash(phone));
  });

test("omitted optional wire fields agree with pinned Admin UserRecord defaults",
  async () => {
    const f = fixture();
    f.setTime(currentTime);
    const raw = optionalLookupUsers();
    for (const response of [raw.actor, raw.recipient,
      {...raw.recipient, disabled: false, validSince: "0"},
      {...raw.actor, disabled: false}]) {
      // JSON round-trip models the actual projected REST body, not SDK getters.
      f.setResponse(JSON.parse(JSON.stringify({users: [response]})));
      const observed = await f.adapter.observe(response.localId);
      const sdk = sdkRecord(response);
      assert.equal(observed.disabled, sdk.disabled);
      assert.equal(observed.creationTimeMillis, Number(response.createdAt));
      assert.equal(observed.tokensValidAfterMillis,
        sdk.tokensValidAfterTime === undefined ? 0 :
          Date.parse(sdk.tokensValidAfterTime));
    }
    f.setResponse({users: [raw.recipient]});
    const recipient = await f.adapter.observe(uid);
    assert.equal(recipient.creationTimeMillis, 1700000000456);
    assert.equal(recipient.tokensValidAfterMillis, 0);
    assert.deepEqual(recipient.relevantRoles, []);
    assert.equal(recipient.endpointHash, catchEndpointHash(phone));
    assert.equal(sdkRecord(raw.recipient).tokensValidAfterTime, undefined);
  });

test("realistic optional responses create a legacy Admin preserving setup plan",
  async () => {
    const f = fixture();
    f.setTime(currentTime);
    const raw = optionalLookupUsers();
    f.setResponse({users: [raw.actor]});
    const actorAuth = await f.adapter.observe(raw.actor.localId);
    f.setResponse({users: [raw.recipient]});
    const recipientAuth = await f.adapter.observe(uid);
    f.setToken({uid: raw.actor.localId, sub: raw.actor.localId, aud: projectId,
      iss: "https://securetoken.google.com/" + projectId,
      auth_time: 1700000090, iat: 1700000090, exp: 1700003700,
      firebase: {sign_in_provider: "google.com"}});
    const session = await f.adapter.verifySession(raw.actor.localId,
      "synthetic-signed-session");
    const actorClaims = JSON.parse(raw.actor.customAttributes);
    const recipientClaims = JSON.parse(raw.recipient.customAttributes);
    const originalClaims = JSON.stringify(recipientClaims);
    const scope = {projectId, actorUid: raw.actor.localId,
      actorEmailSha256: setupHash("synthetic-operator@example.invalid"),
      recipientUid: uid, endpointHash: catchEndpointHash(phone),
      appId: "123456",
      wabaId: "234567", phoneNumberId: "345678",
      credentialVersionSha256: setupHash("synthetic-existing-version")};
    const snapshot = {
      actor: {auth: actorAuth, session, emailSha256: scope.actorEmailSha256,
        googleSubjectSha256: setupHash("synthetic-google-subject"),
        claims: actorClaims},
      recipient: {auth: recipientAuth, claims: recipientClaims},
      existingOwnerUids: [], authorityExists: false, bootstrapExists: false,
      actorAssignmentExists: false,
    };
    const options = {planId: "synthetic-plan", sourceSha: "a".repeat(40),
      grantNonce: setupHash("synthetic-nonce"),
      createReviewRef: "synthetic-create",
      revokeReviewRef: "synthetic-revoke", now: currentTime};
    const plan = planOperatorSetup(scope, snapshot, options);
    assert.equal(plan.actorCreationTimeMillis, 1700000000123);
    assert.equal(plan.recipientCreationTimeMillis, 1700000000456);
    assert.equal(plan.actorTokensValidAfterMillis, 1700000010000);
    assert.equal(plan.recipientTokensValidAfterMillis, 0);
    assert.equal(plan.recipientClaimsSha256, setupHash({admin: true}));
    assert.equal(JSON.stringify(recipientClaims), originalClaims);
    assert.equal(f.verifications[0][1], true);
    assertPlannedSetupIdentity(plan, snapshot, currentTime);
    for (const drift of [
      {...raw.recipient, createdAt: "1700000000457"},
      {...raw.recipient, validSince: "1700000091"},
      {...raw.recipient, phoneNumber: "+919000000002"},
      {...raw.recipient, customAttributes: "{}"},
      {...raw.recipient, customAttributes:
        JSON.stringify({admin: true, support: true})},
      {...raw.recipient, customAttributes:
        JSON.stringify({admin: true, adminOwner: true})},
    ]) {
      f.setResponse(JSON.parse(JSON.stringify({users: [drift]})));
      const auth = await f.adapter.observe(uid);
      assert.throws(() => assertPlannedSetupIdentity(plan, {...snapshot,
        recipient: {auth, claims: JSON.parse(drift.customAttributes)}},
      currentTime), {message: "Protected Catch operator setup unavailable."});
    }
    f.setResponse({users: [{...raw.recipient, validSince: "1700000091"}]});
    const cutoffSnapshot = {...snapshot, recipient: {
      auth: await f.adapter.observe(uid), claims: recipientClaims}};
    const cutoffPlan = planOperatorSetup(scope, cutoffSnapshot, options);
    // Dropping a previously reviewed cutoff cannot revive the reviewed plan.
    assert.throws(() => assertPlannedSetupIdentity(cutoffPlan, snapshot,
      currentTime), {message: "Protected Catch operator setup unavailable."});
  });

test("missing, disabled, tenant, malformed and future observations deny",
  async () => {
    const malformed: unknown[] = [null, {}, {users: []},
      {users: [user(), user()]}, {users: [null]}];
    for (const [key, values] of Object.entries({
      localId: ["foreign", undefined], createdAt: [undefined, 1001, "1.001",
        "-1", "01001", "9007199254740993", "10001"],
      validSince: [undefined, null, false, 0, 1, "", "-1", "01", "1.1",
        "1suffix", " 1", "9007199254741", "11"],
      disabled: [undefined, null, 0, 1, "", true, "false", {}],
      tenantId: ["tenant", "", null],
      customAttributes: [null, {}, "[]", "null", "{", "x".repeat(1001)],
      phoneNumber: [null, "919000000001", "+0919000000001",
        "+91 9000000001", "+919000000001 "],
    })) {
      for (const value of values) {
        malformed.push({users: [{...user(), [key]: value}]});
      }
    }
    const f = fixture();
    for (const response of malformed) {
      f.setResponse(response);
      await assert.rejects(f.adapter.observe(uid), unavailable);
    }
  });

test("project mismatches and invalid identities deny before a lookup",
  async () => {
    const f = fixture();
    f.setProject("foreign-project");
    await assert.rejects(f.adapter.observe(uid), unavailable);
    assert.equal(f.requests.length, 0);
    f.setProject(projectId);
    for (const invalid of ["", "../recipient", "x".repeat(129)]) {
      await assert.rejects(f.adapter.observe(invalid), unavailable);
    }
    f.options.projectId = "../foreign";
    await assert.rejects(f.adapter.observe(uid), unavailable);
    assert.equal(f.requests.length, 0);
    const other = fixture();
    other.options.auth = {...other.options.auth,
      app: {options: {projectId: "foreign-project"}}} as
      CatchFirebaseAuthorityOptions["auth"];
    await assert.rejects(other.adapter.observe(uid), unavailable);
    other.options.auth = {...other.options.auth, tenantId: "tenant"};
    await assert.rejects(other.adapter.verifySession(uid, "signed"),
      unavailable);
    assert.equal(other.verifications.length, 0);
  });

test("observation starts before request and denies slow reads",
  async () => {
    const f = fixture();
    f.options.transport.lookup = async (request) => {
      f.requests.push(request);
      f.setTime(39999);
      return {users: [user()]};
    };
    assert.equal((await f.adapter.observe(uid)).observedAtMillis, 10000);
    f.setTime(10000);
    f.options.transport.lookup = async () => {
      f.setTime(40001);
      return {users: [user()]};
    };
    await assert.rejects(f.adapter.observe(uid), unavailable);
    f.setTime(10000);
    f.options.transport.lookup = async () => {
      f.setTime(9999);
      return {users: [user()]};
    };
    await assert.rejects(f.adapter.observe(uid), unavailable);
  });

test("timeout aborts fake transport and hides errors", async (context) => {
  context.mock.timers.enable({apis: ["setTimeout"]});
  const f = fixture();
  let signal: AbortSignal | undefined;
  f.options.transport.lookup = async (request) => {
    signal = request.signal;
    return new Promise(() => undefined);
  };
  const pending = f.adapter.observe(uid);
  await Promise.resolve();
  await Promise.resolve();
  const rejected = assert.rejects(pending, unavailable);
  context.mock.timers.tick(30000);
  await rejected;
  assert.equal(signal?.aborted, true);
  f.options.transport.lookup = async () => {
    throw new Error("private provider error with secret");
  };
  await assert.rejects(f.adapter.observe(uid), unavailable);
});

test("1001 to 1002 creation milliseconds revoke the model incarnation",
  async () => {
    const f = fixture();
    const optional: Record<string, unknown> = {...user()};
    delete optional.disabled;
    delete optional.validSince;
    f.setResponse({users: [optional]});
    const first = await f.adapter.observe(uid);
    const endpointHash = catchEndpointHash(phone);
    const authority = {schemaVersion: 1, projectId, uid, revision: 1,
      incarnation: createHash("sha256").update(JSON.stringify([
        "catch.firebase-creation/v1", projectId, uid, 1001])).digest("hex"),
      state: "active", authNotBeforeSeconds: 0, updatedAtMillis: 9000,
      capabilities: ["receive"], endpointHash, pending: null, grantedBy: null};
    assert.equal(authorizeCatchAppCapability({record: authority, auth: first},
      "receive", 10000, {projectId, uid, endpointHash}).revision, 1);
    f.setResponse({users: [{...optional, createdAt: "1002"}]});
    const second = await f.adapter.observe(uid);
    assert.equal(second.creationTimeMillis, 1002);
    assert.throws(() => authorizeCatchAppCapability({record: authority,
      auth: second}, "receive", 10000, {projectId, uid, endpointHash}),
    unavailable);
    f.setResponse({users: [{...optional, phoneNumber: "+919000000002"}]});
    const endpointChanged = await f.adapter.observe(uid);
    assert.throws(() => authorizeCatchAppCapability({record: authority,
      auth: endpointChanged},
    "receive", 10000, {projectId, uid, endpointHash}), unavailable);
  });

test("session verifies signature and revocation before returning evidence",
  async () => {
    const f = fixture();
    assert.deepEqual(await f.adapter.verifySession(uid, "signed-id-token"),
      {projectId, uid, authTimeSeconds: 9, expiresAtSeconds: 100});
    assert.deepEqual(f.verifications, [["signed-id-token", true]]);
    assert.equal(f.requests.length, 0);
    await assert.rejects(f.adapter.verifySession(uid,
      token() as unknown as string), unavailable);
    assert.equal(f.verifications.length, 1);
    f.options.auth.verifyIdToken = async () => {
      throw new Error("auth/id-token-revoked: sensitive-token");
    };
    await assert.rejects(f.adapter.verifySession(uid, "revoked"), unavailable);
  });

test("wrong project, UID, tenant and invalid verified token times deny",
  async () => {
    const f = fixture();
    const malformed: unknown[] = [null, {}, {...token(), firebase: null},
      {...token(), firebase: {tenant: "tenant"}},
      {...token(), tenant_id: "tenant"}];
    for (const [key, values] of Object.entries({
      uid: ["other", undefined], sub: ["other", undefined],
      aud: ["foreign-project", [projectId]],
      iss: ["https://securetoken.google.com/foreign-project", undefined],
      auth_time: [-1, "9", 9.5, 10, Number.MAX_SAFE_INTEGER],
      iat: [-1, "9", 8, 11, Number.MAX_SAFE_INTEGER],
      exp: [0, "100", 9, 10, Number.MAX_SAFE_INTEGER],
    })) {
      for (const value of values) malformed.push({...token(), [key]: value});
    }
    for (const value of malformed) {
      f.setToken(value);
      await assert.rejects(f.adapter.verifySession(uid, "signed"), unavailable);
    }
  });

test("verified sessions still require current Firebase revocation and roles",
  async () => {
    const f = fixture();
    const optional: Record<string, unknown> = {...user()};
    delete optional.disabled;
    delete optional.validSince;
    f.setResponse({users: [optional]});
    const session = await f.adapter.verifySession(uid, "signed");
    const auth = await f.adapter.observe(uid);
    assert.equal(auth.tokensValidAfterMillis, 0);
    const authority = {schemaVersion: 1, projectId, uid, revision: 1,
      incarnation: createHash("sha256").update(JSON.stringify([
        "catch.firebase-creation/v1", projectId, uid, 1001])).digest("hex"),
      state: "active", authNotBeforeSeconds: 0, updatedAtMillis: 9000,
      capabilities: ["review"], endpointHash: null, pending: null,
      grantedBy: null};
    const expected = {projectId, uid};
    assert.equal(authorizeCatchAppCapability({record: authority, auth, session},
      "review", 10000, expected).revision, 1);
    f.setResponse({users: [{...optional, validSince: "10"}]});
    const revoked = await f.adapter.observe(uid);
    assert.throws(() => authorizeCatchAppCapability({record: authority,
      auth: revoked, session}, "review", 10000, expected), unavailable);
    f.setResponse({users: [{...optional, customAttributes: "{}"}]});
    const roleRemoved = await f.adapter.observe(uid);
    assert.throws(() => authorizeCatchAppCapability({record: authority,
      auth: roleRemoved, session}, "review", 10000, expected), unavailable);
  });

test("real lazy transport rejects endpoint substitution before loading ADC",
  async () => {
    const f = fixture();
    await f.adapter.observe(uid);
    const live = createCatchGoogleFirebaseLookupTransport();
    for (const url of ["http://identitytoolkit.googleapis.com/v1/projects/" +
      projectId + "/accounts:lookup", "https://example.com/accounts:lookup",
    "https://identitytoolkit.googleapis.com/v1/projects/" +
      "foreign/accounts:lookup",
    f.requests[0].url + "?key=secret"]) {
      await assert.rejects(live.lookup({...f.requests[0], url}), unavailable);
    }
    await assert.rejects(live.lookup({...f.requests[0],
      body: {localId: [uid, "other"]}}), unavailable);
  });

test("session verification timeout denies even an unresolved fake verifier",
  async (context) => {
    context.mock.timers.enable({apis: ["setTimeout"]});
    const f = fixture();
    f.options.auth.verifyIdToken = async () => new Promise(() => undefined);
    const pending = f.adapter.verifySession(uid, "signed");
    const rejected = assert.rejects(pending, unavailable);
    context.mock.timers.tick(30000);
    await rejected;
  });

test("phone observation follows Catch canonical seven-digit minimum",
  async () => {
    const f = fixture();
    f.setResponse({users: [{...user(), phoneNumber: "+1234567"}]});
    assert.equal((await f.adapter.observe(uid)).endpointHash,
      catchEndpointHash("+1234567"));
    f.setResponse({users: [{...user(), phoneNumber: "+123456"}]});
    await assert.rejects(f.adapter.observe(uid), unavailable);
  });

test("lazy GoogleAuth sends a projected request with fake OAuth",
  async (context) => {
    const {GoogleAuth} = await import("google-auth-library");
    const authorizationUrls: (string | URL | undefined)[] = [];
    const fetchCalls: Parameters<typeof fetch>[] = [];
    context.mock.method(GoogleAuth.prototype, "getProjectId",
      async () => projectId);
    context.mock.method(GoogleAuth.prototype, "getRequestHeaders",
      async (url?: string | URL) => {
        authorizationUrls.push(url);
        return new Headers({Authorization: "Bearer fake-oauth-access-token"});
      });
    const fakeFetch = context.mock.method(globalThis, "fetch",
      async (...args: Parameters<typeof fetch>) => {
        fetchCalls.push(args);
        return new Response(JSON.stringify({users: [user()]}), {status: 200,
          headers: {"Content-Type": "application/json"}});
      });
    const f = fixture();
    f.options.transport = createCatchGoogleFirebaseLookupTransport();
    assert.equal(authorizationUrls.length, 0);
    assert.equal(fetchCalls.length, 0);
    assert.equal((await f.adapter.observe(uid)).creationTimeMillis, 1001);
    assert.deepEqual(authorizationUrls,
      ["https://identitytoolkit.googleapis.com" +
      "/v1/projects/catchdates-dev/accounts:lookup"]);
    assert.equal(fetchCalls.length, 1);
    const [input, init] = fetchCalls[0];
    const url = new URL(String(input));
    assert.equal(url.origin, "https://identitytoolkit.googleapis.com");
    assert.equal(url.pathname, "/v1/projects/catchdates-dev/accounts:lookup");
    assert.deepEqual([...url.searchParams], [["fields",
      "users(localId,createdAt,validSince,disabled," +
      "customAttributes,phoneNumber,tenantId)"]]);
    assert.equal(init?.method, "POST");
    assert.deepEqual(JSON.parse(String(init?.body)), {localId: [uid]});
    assert.equal(init?.redirect, "error");
    assert.ok(init?.signal instanceof AbortSignal);
    assert.equal(init.signal.aborted, false);
    const headers = new Headers(init?.headers);
    assert.equal(headers.get("Authorization"),
      "Bearer fake-oauth-access-token");
    assert.equal(headers.get("Content-Type"), "application/json");

    // Native fetch rejects redirects under redirect:error. A 3xx response from
    // any alternate transport is also rejected before parsing a response body.
    for (const status of [403, 302]) {
      fakeFetch.mock.mockImplementation(async () =>
        new Response("private provider body", {status}));
      await assert.rejects(f.adapter.observe(uid), unavailable);
    }
    for (const message of ["redirect mode is set to error",
      "network error: private bearer token"]) {
      fakeFetch.mock.mockImplementation(async () => {
        throw new TypeError(message);
      });
      await assert.rejects(f.adapter.observe(uid), unavailable);
    }
    assert.ok(authorizationUrls.every((url) => String(url) ===
      "https://identitytoolkit.googleapis.com/v1/projects/" + projectId +
        "/accounts:lookup"));
  });


test("successful transport with malformed JSON fails privately without retry",
  async (context) => {
    const {GoogleAuth} = await import("google-auth-library");
    context.mock.method(GoogleAuth.prototype, "getProjectId",
      async () => projectId);
    context.mock.method(GoogleAuth.prototype, "getRequestHeaders",
      async () => new Headers({Authorization: "Bearer fake-token"}));
    const fakeFetch = context.mock.method(globalThis, "fetch", async () =>
      new Response("{private-account-data:", {status: 200}));
    const f = fixture();
    f.options.transport = createCatchGoogleFirebaseLookupTransport();
    await assert.rejects(f.adapter.observe(uid), unavailable);
    assert.equal(fakeFetch.mock.callCount(), 1);
  });
