"use strict";
const assert = require("node:assert/strict");
const {test} = require("node:test");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const {createHash} = require("node:crypto");
const {createOperatorRuntime, protectedHome, credentialMetadata,
  createSingleAttemptClaimsSetter} = require("../scripts/operations/catch-whatsapp-operator-runtime.cjs");
const {setupHash} = require("../lib/catchMessaging/whatsappOperatorSetup.js");
const {operatorEmailHash} = require("../lib/catchMessaging/whatsappOperatorSetupSources.js");
const {catchEndpointHash} = require("../lib/catchMessaging/whatsappReply.js");
const root = path.resolve(__dirname, "..");
const command = path.join(root, "scripts/operations/setup-catch-whatsapp-reply.cjs");
function fixture() {
  return {schemaVersion: 1, planId: "synthetic-review", scope: {
    projectId: "demo-catch-setup", actorUid: "operator",
    actorEmailSha256: "a".repeat(64), recipientUid: "recipient",
    endpointHash: "b".repeat(64), appId: "10001", wabaId: "10002",
    phoneNumberId: "10003", credentialVersionSha256: "c".repeat(64)},
  sourceSha: "d".repeat(40), createdAtMillis: 1800000000000,
  expiresAtMillis: 1800000600000, actorCreationTimeMillis: 1001,
  recipientCreationTimeMillis: 1002, actorTokensValidAfterMillis: 0,
  recipientTokensValidAfterMillis: 0, googleSubjectSha256: "e".repeat(64),
  beforeClaimsSha256: "f".repeat(64), desiredClaimsSha256: "1".repeat(64),
  recipientClaimsSha256: "2".repeat(64), grantNonce: "3".repeat(64),
  createReviewRef: "review-create", revokeReviewRef: "review-revoke",
  expectedActorRevision: 0, expectedRecipientRevision: 0};
}
test("offline CLI inspects without ADC, networking or exposing operator scope", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-offline-plan-"));
  try {
    const file = path.join(directory, "plan.json");
    const adc = path.join(directory, "forbidden-adc.json");
    const sentinel = path.join(directory, "sentinel.cjs");
    fs.writeFileSync(file, JSON.stringify(fixture()));
    fs.writeFileSync(adc, "synthetic-credential-marker");
    fs.writeFileSync(sentinel, `
      const fs = require('node:fs');
      const read = fs.readFileSync;
      fs.readFileSync = function(file, ...args) {
        if (String(file) === process.env.GOOGLE_APPLICATION_CREDENTIALS)
          throw new Error('ADC read forbidden');
        return read.call(this, file, ...args);
      };
      global.fetch = () => {throw new Error('network forbidden');};
      for (const name of ['node:http', 'node:https', 'node:net']) {
        const module = require(name);
        for (const key of ['request', 'get', 'connect', 'createConnection']) {
          if (typeof module[key] === 'function')
            module[key] = () => {throw new Error('network forbidden');};
        }
      }
    `);
    const result = spawnSync(process.execPath, ["--require", sentinel, command,
      "inspect-plan", "--plan-file", file], {encoding: "utf8", cwd: root,
    env: {...process.env, GOOGLE_APPLICATION_CREDENTIALS: adc}});
    assert.equal(result.status, 0, result.stderr);
    const receipt = JSON.parse(result.stdout);
    assert.equal(receipt.liveApplyAvailable, false);
    assert.match(receipt.planSha256, /^[a-f0-9]{64}$/u);
    for (const privateValue of ["synthetic-credential-marker", "operator",
      "recipient", "10001", "10002", "10003"]) {
      assert.ok(!result.stdout.includes('"' + privateValue + '"'));
    }
  } finally {fs.rmSync(directory, {recursive: true, force: true});}
});
test("live commands and caller facts fail without echoing private input", () => {
  for (const argv of [[], ["apply", "synthetic-private-token"],
    ["inspect-plan", "--plan-file", "/missing", "synthetic-private-token"]]) {
    const result = spawnSync(process.execPath, [command, ...argv],
      {encoding: "utf8", cwd: root});
    assert.equal(result.status, 1);
    assert.ok(!result.stderr.includes("synthetic-private-token"));
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-plan-invalid-"));
  try {
    const file = path.join(directory, "plan.json");
    fs.writeFileSync(file, JSON.stringify({...fixture(), roles: ["adminOwner"]}));
    const result = spawnSync(process.execPath, [command, "inspect-plan",
      "--plan-file", file], {encoding: "utf8"});
    assert.equal(result.status, 1);
    assert.ok(!result.stderr.includes("adminOwner"));
  } finally {fs.rmSync(directory, {recursive: true, force: true});}
});

function runtimeFixture() {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), "catch-protected-operator-"));
  const records = new Map();
  let now = 1800000000000;
  let authTime = now / 1000 - 1;
  let claims = {tenantLabel: "synthetic", nested: {flag: true}};
  let setters = 0;
  let sdkCalls = 0;
  let writes = 0;
  let metadataReads = 0;
  let setterMode = "normal";
  let recipientDeleted = false;
  let restClaims;
  let execution = "e".repeat(64);
  let afterCommit;
  const binding = () => ({sourceSha: "d".repeat(40), executionSha256: execution});
  const scope = {projectId: "demo-catch-setup", actorUid: "operator",
    actorEmailSha256: operatorEmailHash("operator@example.invalid"),
    recipientUid: "recipient", endpointHash: catchEndpointHash("+15555550123"),
    appId: "10001", wabaId: "10002", phoneNumberId: "10003",
    credentialVersionSha256: ""};
  const credentialVersionName = "projects/demo-catch-setup/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/7";
  scope.credentialVersionSha256 = createHash("sha256").update(credentialVersionName).digest("hex");
  const profile = {schemaVersion: 1, scope, ...binding(), credentialVersionName,
    runtimePrincipal: "serviceAccount:runtime@demo-catch-setup.iam.gserviceaccount.com"};
  const file = (name, value, json = true) => {
    fs.mkdirSync(path.dirname(path.join(home, name)), {recursive: true, mode: 0o700});
    fs.writeFileSync(path.join(home, name), json ? JSON.stringify(value) + "\n" : value, {mode: 0o600});
  };
  file("profile.json", profile);
  file("actor-id-token.txt", "synthetic.google.token", false);
  const snapshot = (p) => ({id: p.split("/").at(-1), exists: records.has(p),
    data: () => records.has(p) ? structuredClone(records.get(p)) : undefined});
  const query = (name, filters = [], count = 100) => ({
    where: (key, op, value) => query(name, [...filters, [key, op, value]], count),
    limit: (value) => query(name, filters, value),
    get: async () => {
      const docs = [...records].filter(([p, v]) => p.startsWith(name + "/") &&
        filters.every(([key, op, value]) => op === "array-contains" ? v[key]?.includes(value) : v[key] === value))
        .slice(0, count).map(([p]) => snapshot(p));
      return {docs, empty: docs.length === 0};
    },
  });
  const db = {projectId: scope.projectId, databaseId: "(default)",
    collection: (name) => ({...query(name), doc: (id) => ({path: name + "/" + id,
      get: async () => snapshot(name + "/" + id)})}),
    runTransaction: async (callback, options) => {
      assert.ok(options.readOnly === true || options.maxAttempts === 1);
      const pending = new Map();
      const result = await callback({get: async (ref) => {
        assert.equal(pending.size, 0, "all reads precede writes");
        return ref.get();
      }, create: (ref, value) => {
        assert.notEqual(options.readOnly, true, "read-only reconciliation cannot create");
        assert.ok(!records.has(ref.path) && !pending.has(ref.path));
        pending.set(ref.path, value);
      }, update: (ref, value) => {
        assert.notEqual(options.readOnly, true, "read-only reconciliation cannot update");
        assert.ok(records.has(ref.path));
        pending.set(ref.path, {...records.get(ref.path), ...value});
      }});
      for (const [p, v] of pending) {records.set(p, v); writes++;}
      afterCommit?.(pending);
      return result;
    }};
  const auth = {app: {options: {projectId: scope.projectId}},
    getUser: async (uid) => {
      if (uid === "recipient" && recipientDeleted) throw new Error("private recipient deleted");
      return {uid, disabled: false, customClaims: uid === "operator" ? structuredClone(claims) : {},
        ...(uid === "operator" ? {email: "operator@example.invalid", emailVerified: true,
          providerData: [{providerId: "google.com", uid: "synthetic-google-subject"}]} : {})};
    },
    verifyIdToken: async (token, checkRevoked) => {
      assert.equal(token, "synthetic.google.token"); assert.equal(checkRevoked, true);
      return {uid: "operator", sub: "operator", aud: scope.projectId,
        iss: "https://securetoken.google.com/" + scope.projectId,
        email: "operator@example.invalid", email_verified: true,
        auth_time: authTime, iat: authTime, exp: now / 1000 + 1800,
        firebase: {sign_in_provider: "google.com", identities: {"google.com": ["synthetic-google-subject"]}}};
    },
    listUsers: async () => ({users: [{uid: "operator", customClaims: structuredClone(claims)}]}),
    setCustomUserClaims: async (uid, next) => {
      assert.equal(uid, "operator"); setters++;
      if (setterMode === "before") throw new Error("private Auth uncertainty");
      claims = structuredClone(next);
      if (setterMode === "after") throw new Error("private lost Auth response");
    }};
  const transport = {getProjectId: async () => scope.projectId,
    lookup: async ({body}) => {
      const uid = body.localId[0];
      if (uid === "recipient" && recipientDeleted) return {users: []};
      return {users: [{localId: uid, createdAt: "1001", validSince: "0", disabled: false,
        customAttributes: JSON.stringify(uid === "operator" ? restClaims ?? claims : {}),
        ...(uid === "recipient" ? {phoneNumber: "+15555550123"} : {})}]};
    }};
  const secrets = {getSecretVersion: async ({name}) => {
    metadataReads++; assert.equal(name, credentialVersionName);
    return [{name, state: "ENABLED"}];
  }, getIamPolicy: async ({resource, options}) => {
    metadataReads++; assert.equal(options.requestedPolicyVersion, 3);
    assert.equal(resource, credentialVersionName.split("/versions/")[0]);
    return [{bindings: [{role: "roles/secretmanager.secretAccessor", members: [profile.runtimePrincipal]}]}];
  }, accessSecretVersion: () => assert.fail("no credential payload access")};
  const runtime = () => createOperatorRuntime({home, now: () => now, identity: binding,
    sdkFactory: () => {sdkCalls++; return {db, auth, transport, secrets};}});
  const review = (receipt) => {
    const {plan} = JSON.parse(fs.readFileSync(path.join(home, `pending-plans/${receipt.planId}.json`)));
    const request = JSON.parse(fs.readFileSync(path.join(home, `requests/${receipt.planId}.json`)));
    file(`reviewed-plans/${plan.planId}.json`, plan);
    const approval = {schemaVersion: 1, action: "bootstrap-apply", planSha256: setupHash(plan),
      scopeSha256: setupHash(plan.scope), ...binding(), replaySha256: setupHash(request.replayKey),
      expiresAtMillis: plan.expiresAtMillis};
    file(`approvals/${plan.planId}.json`, approval);
    return {plan, request, approval};
  };
  return {home, runtime, review, file, profile, records,
    counts: () => ({setters, sdkCalls, writes, metadataReads}),
    claims: () => structuredClone(claims),
    failSetter: (mode) => {setterMode = mode;},
    changeClaims: () => {claims = {...claims, unrelatedDrift: true};},
    changeExecution: () => {execution = "f".repeat(64);},
    signIn: () => {now += 2000; authTime = now / 1000;},
    expire: () => {now += 16 * 60 * 1000;},
    deleteRecipient: () => {recipientDeleted = true;},
    revokeObservedRole: () => {restClaims = {...claims, adminOwner: false};},
    restoreOldSession: () => {authTime = 1799999999;},
    onCommit: (callback) => {afterCommit = callback;},
    close: () => fs.rmSync(home, {recursive: true, force: true})};
}

test("real source planner reads metadata and current identity without writes or automatic approval", async () => {
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan();
    assert.equal(receipt.reviewed, false);
    assert.deepEqual(h.counts(), {setters: 0, sdkCalls: 1, writes: 0, metadataReads: 2});
    assert.equal(h.records.size, 0);
    assert.equal(fs.existsSync(path.join(h.home, "reviewed-plans")), false);
    await assert.rejects(() => h.runtime().apply(receipt.planId));
    assert.equal(h.counts().sdkCalls, 1, "unreviewed apply fails before SDK setup");
    const printed = JSON.stringify(receipt);
    for (const value of ["operator@example.invalid", "synthetic.google.token", "+15555550123", h.profile.runtimePrincipal]) {
      assert.ok(!printed.includes(value));
    }
  } finally {h.close();}
});

test("protected apply reaches fresh-sign-in and resumes the merged authority store without a second setter", async () => {
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan(); h.review(receipt);
    assert.equal((await h.runtime().apply(receipt.planId)).state, "fresh-sign-in-required");
    assert.deepEqual(h.claims(), {adminOwner: true, nested: {flag: true}, tenantLabel: "synthetic"});
    assert.equal(h.counts().setters, 1);
    assert.equal((await h.runtime().reconcile(receipt.planId)).state, "fresh-sign-in-required");
    h.signIn();
    assert.equal((await h.runtime().apply(receipt.planId)).state, "complete");
    const before = h.counts();
    assert.equal((await h.runtime().reconcile(receipt.planId)).state, "bootstrap-complete");
    assert.deepEqual(h.counts(), {...before, sdkCalls: before.sdkCalls + 1});
    assert.equal(h.counts().setters, 1);
    assert.deepEqual(h.records.get("catchWhatsappAppAuthorities/operator").capabilities, ["review", "reply"]);
    assert.deepEqual(h.records.get("catchWhatsappAppAuthorities/recipient").capabilities, ["receive"]);
    h.expire();
    assert.equal((await h.runtime().reconcile(receipt.planId)).planExpired, true);
    await assert.rejects(() => h.runtime().apply(receipt.planId));
    h.deleteRecipient();
    const deleted = await h.runtime().reconcile(receipt.planId);
    assert.equal(deleted.state, "reconciliation-required");
    assert.equal(deleted.recipientAuthState, "unavailable");
    assert.equal(h.counts().setters, 1);
  } finally {h.close();}
});

test("unknown Auth responses remain read-only observations and never redispatch", async () => {
  for (const mode of ["before", "after"]) {
    const h = runtimeFixture();
    try {
      const receipt = await h.runtime().plan(); h.review(receipt); h.failSetter(mode);
      assert.equal((await h.runtime().apply(receipt.planId)).state, "reconciliation-required");
      const before = h.counts();
      const result = await h.runtime().reconcile(receipt.planId);
      assert.equal(result.state, "reconciliation-required");
      assert.equal(result.authDispatchConsumed, true);
      assert.equal(result.claimsState, mode === "before" ? "before-observed" : "desired-observed");
      assert.deepEqual(h.counts(), {...before, sdkCalls: before.sdkCalls + 1});
      if (mode === "before") await h.runtime().apply(receipt.planId);
      assert.equal(h.counts().setters, 1);
    } finally {h.close();}
  }
});

test("exact protected action/source/scope/replay/expiry and artifact binding reject before SDK access", async () => {
  const edits = [a => ({...a, action: "readiness-apply"}), a => ({...a, sourceSha: "f".repeat(40)}),
    a => ({...a, scopeSha256: "f".repeat(64)}), a => ({...a, replaySha256: "f".repeat(64)}),
    a => ({...a, planSha256: "f".repeat(64)}), a => ({...a, expiresAtMillis: 1}),
    a => ({...a, executionSha256: "f".repeat(64)})];
  for (const edit of edits) {
    const h = runtimeFixture();
    try {
      const receipt = await h.runtime().plan(); const {approval} = h.review(receipt);
      h.file(`approvals/${receipt.planId}.json`, edit(approval));
      await assert.rejects(() => h.runtime().apply(receipt.planId));
      assert.equal(h.counts().sdkCalls, 1); assert.equal(h.counts().setters, 0);
    } finally {h.close();}
  }
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan(); h.review(receipt);
    const running = h.runtime(); h.changeExecution();
    await assert.rejects(() => running.apply(receipt.planId));
    assert.equal(h.counts().setters, 0);
  } finally {h.close();}
});

test("reconcile rejects audit/receipt tampering and reports observed claims drift without writes", async () => {
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan(); h.review(receipt);
    await h.runtime().apply(receipt.planId);
    const audit = h.records.get("catchWhatsappOperatorSetupAudits/demo-catch-setup_4");
    h.records.set("catchWhatsappOperatorSetupAudits/demo-catch-setup_4", {...audit, afterSha256: "f".repeat(64)});
    const before = h.counts();
    await assert.rejects(() => h.runtime().reconcile(receipt.planId));
    assert.equal(h.counts().writes, before.writes);
    h.records.set("catchWhatsappOperatorSetupAudits/demo-catch-setup_4", audit);
    h.changeClaims();
    assert.equal((await h.runtime().reconcile(receipt.planId)).claimsState, "drift-observed");
    assert.equal(h.counts().setters, 1);
  } finally {h.close();}
});

test("private files reject symlinks, broad modes, duplicate JSON, hardlinks and traversal", () => {
  const h = runtimeFixture();
  try {
    const files = protectedHome(h.home);
    fs.chmodSync(path.join(h.home, "profile.json"), 0o644);
    assert.throws(() => files.read("profile.json"));
    fs.chmodSync(path.join(h.home, "profile.json"), 0o600);
    fs.linkSync(path.join(h.home, "profile.json"), path.join(h.home, "linked.json"));
    assert.throws(() => files.read("profile.json"));
    fs.unlinkSync(path.join(h.home, "linked.json"));
    fs.symlinkSync(path.join(h.home, "profile.json"), path.join(h.home, "symlink.json"));
    assert.throws(() => files.read("symlink.json"));
    assert.throws(() => files.read("../outside.json"));
    h.file("duplicate.json", '{"action":"plan","action":"apply"}', false);
    assert.throws(() => files.read("duplicate.json"));
  } finally {h.close();}
});

test("metadata uses exact enabled version and pinned direct principal; no secret payload or IAM expansion", async () => {
  const h = runtimeFixture();
  try {
    let binding = {role: "roles/secretmanager.secretAccessor", members: [h.profile.runtimePrincipal]};
    let state = "ENABLED";
    const secrets = {getSecretVersion: async () => [{name: h.profile.credentialVersionName, state}],
      getIamPolicy: async () => [{bindings: [binding]}],
      accessSecretVersion: () => assert.fail("no token payload"),
      setIamPolicy: () => assert.fail("no IAM mutation")};
    assert.equal((await credentialMetadata(h.profile, secrets)).runtimeAccessor, true);
    binding = {...binding, condition: {expression: "true"}};
    assert.equal((await credentialMetadata(h.profile, secrets)).runtimeAccessor, false);
    binding = {role: "roles/secretmanager.secretAccessor", members: ["group:operators@example.invalid"]};
    assert.equal((await credentialMetadata(h.profile, secrets)).runtimeAccessor, false);
    state = "DISABLED";
    assert.equal((await credentialMetadata(h.profile, secrets)).enabled, false);
  } finally {h.close();}
});

test("default SDK rejects emulator redirection before any ADC or network initialization", async () => {
  const h = runtimeFixture();
  const key = "FIRESTORE_EMULATOR_HOST";
  const previous = process.env[key];
  const Module = require("node:module");
  const load = Module._load;
  try {
    Module._load = function(name, ...args) {
      if (name === "firebase-admin/app") assert.fail("SDK initialized before routing rejection");
      return load.call(this, name, ...args);
    };
    process.env[key] = "127.0.0.1:1";
    const runtime = createOperatorRuntime({home: h.home,
      identity: () => ({sourceSha: h.profile.sourceSha, executionSha256: h.profile.executionSha256})});
    await assert.rejects(() => runtime.plan(), /Protected Catch operator setup unavailable/);
    assert.equal(h.counts().writes, 0);
  } finally {
    Module._load = load;
    if (previous === undefined) delete process.env[key]; else process.env[key] = previous;
    h.close();
  }
});

test("reconcile authenticates no-slot status and rejects REST role disagreement or old active-root session", async () => {
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan(); h.review(receipt);
    fs.unlinkSync(path.join(h.home, "actor-id-token.txt"));
    await assert.rejects(() => h.runtime().reconcile(receipt.planId));
    h.file("actor-id-token.txt", "synthetic.google.token", false);
    assert.equal((await h.runtime().reconcile(receipt.planId)).state, "not-started");
    await h.runtime().apply(receipt.planId); h.signIn(); await h.runtime().apply(receipt.planId);
    const before = h.counts();
    h.restoreOldSession();
    assert.equal((await h.runtime().reconcile(receipt.planId)).state, "fresh-sign-in-required");
    h.signIn(); h.revokeObservedRole();
    const result = await h.runtime().reconcile(receipt.planId);
    assert.equal(result.state, "reconciliation-required");
    assert.equal(result.actorMatches, false);
    assert.equal(h.counts().writes, before.writes);
    assert.equal(h.counts().setters, before.setters);
  } finally {h.close();}
});

test("real HTTP claims transport never retries reset, committed lost response, or 503", async () => {
  const http = require("node:http");
  for (const mode of ["reset", "committed-lost-response", "503", "normal"]) {
    let requests = 0;
    let committed = 0;
    const server = http.createServer((req, res) => {
      requests++;
      let body = "";
      req.on("data", (bytes) => {body += bytes;});
      req.on("end", () => {
        assert.equal(req.method, "POST");
        assert.equal(req.headers.authorization, "Bearer synthetic-test-oauth");
        assert.deepEqual(JSON.parse(body), {localId: "operator",
          customAttributes: '{"adminOwner":true,"preserved":"value"}'});
        if (mode === "committed-lost-response" || mode === "normal") committed++;
        if (mode === "reset" || mode === "committed-lost-response") req.socket.destroy();
        else if (mode === "503") {res.writeHead(503); res.end("unavailable");}
        else {res.writeHead(200, {"Content-Type": "application/json"}); res.end('{"localId":"operator"}');}
      });
    });
    await new Promise((resolve) => server.listen(Number(process.env.CATCH_VALIDATION_LOOPBACK_PORT) || 0, "127.0.0.1", resolve));
    try {
      const setter = createSingleAttemptClaimsSetter({projectId: "demo-catch-setup", actorUid: "operator"}, {
        beforeDispatch: async () => {},
        credentialFactory: () => ({getProjectId: async () => "demo-catch-setup",
          getRequestHeaders: async () => ({Authorization: "Bearer synthetic-test-oauth"})}),
        dispatch: (url, options) => {
          assert.equal(url, "https://identitytoolkit.googleapis.com/v1/projects/demo-catch-setup/accounts:update?fields=localId");
          assert.equal(options.redirect, "error"); assert.ok(options.signal instanceof AbortSignal);
          return fetch(`http://127.0.0.1:${server.address().port}/claims`, options);
        }});
      const operation = setter("operator", {adminOwner: true, preserved: "value"});
      if (mode === "normal") await operation; else await assert.rejects(operation);
      assert.equal(requests, 1);
      assert.equal(committed, ["committed-lost-response", "normal"].includes(mode) ? 1 : 0);
      await assert.rejects(() => setter("other", {}));
      assert.equal(requests, 1);
    } finally {
      server.closeAllConnections();
      await new Promise((resolve) => server.close(resolve));
    }
  }
});

test("approval revoked at consumed Auth permit blocks dispatch and preserves reconciliation", async () => {
  const h = runtimeFixture();
  try {
    const receipt = await h.runtime().plan(); h.review(receipt);
    h.onCommit((writes) => {
      if (writes.has("catchWhatsappOperatorSetupAudits/demo-catch-setup_auth_dispatch")) {
        fs.unlinkSync(path.join(h.home, `approvals/${receipt.planId}.json`));
      }
    });
    assert.equal((await h.runtime().apply(receipt.planId)).state, "reconciliation-required");
    assert.equal(h.counts().setters, 0);
    const result = await h.runtime().reconcile(receipt.planId);
    assert.equal(result.authDispatchConsumed, true);
    assert.equal(result.claimsState, "before-observed");
    assert.equal(result.state, "reconciliation-required");
  } finally {h.close();}
});

test("single-attempt transport rereads approval after headers and bounds hung credential reads", async () => {
  let dispatches = 0;
  let approved = true;
  const options = {dispatch: async () => {dispatches++; assert.fail("unapproved dispatch");},
    beforeDispatch: async () => {assert.equal(approved, true);},
    credentialFactory: () => ({getProjectId: async () => "demo-catch-setup",
      getRequestHeaders: async () => {approved = false; return {};}})};
  const scope = {projectId: "demo-catch-setup", actorUid: "operator"};
  await assert.rejects(() => createSingleAttemptClaimsSetter(scope, options)("operator", {adminOwner: true}));
  assert.equal(dispatches, 0);
  const timeout = { ...options, deadline: () => AbortSignal.timeout(20),
    credentialFactory: () => ({getProjectId: async () => "demo-catch-setup",
      getRequestHeaders: () => new Promise(() => {})})};
  // Keep the synthetic process alive while AbortSignal's unref timer expires.
  const keepAlive = setTimeout(() => {}, 1000);
  try {
    await assert.rejects(() => createSingleAttemptClaimsSetter(scope, timeout)("operator", {adminOwner: true}), /deadline/);
    assert.equal(dispatches, 0);
  } finally {clearTimeout(keepAlive);}
});

test("reentrant different-plan apply cannot replace the in-flight final approval binding", async () => {
  const h = runtimeFixture();
  try {
    const running = h.runtime();
    const first = await running.plan(); h.review(first);
    const other = await running.plan(); h.review(other);
    let competing;
    h.onCommit((writes) => {
      if (writes.has("catchWhatsappOperatorSetupAudits/demo-catch-setup_auth_dispatch")) {
        competing = running.apply(other.planId).then(() => null, error => error);
        fs.unlinkSync(path.join(h.home, `approvals/${first.planId}.json`));
      }
    });
    assert.equal((await running.apply(first.planId)).state, "reconciliation-required");
    assert.match((await competing).message, /Protected Catch operator setup unavailable/);
    assert.equal(h.counts().setters, 0);
    const observed = await running.reconcile(first.planId);
    assert.equal(observed.authDispatchConsumed, true);
    assert.equal(observed.claimsState, "before-observed");
    h.review(first); h.onCommit(undefined);
    assert.equal((await running.apply(first.planId)).state, "reconciliation-required");
    assert.equal(h.counts().setters, 0, "same exact replay keeps the consumed dispatch receipt");
  } finally {h.close();}
});
