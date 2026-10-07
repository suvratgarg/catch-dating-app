"use strict";
const assert = require("node:assert/strict");
const {test} = require("node:test");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const http = require("node:http");
const {createHash, randomBytes, publicEncrypt, createPublicKey, createCipheriv, constants, verify: verifySignature} = require("node:crypto");
const {spawnSync} = require("node:child_process");
const {createSessionHandoff, assertSession, verifyFactory} = require("../scripts/operations/catch-whatsapp-session-handoff.cjs");
const sha = input => createHash("sha256").update(input).digest("hex");
const privateToken = "synthetic.private.signature";
const clientOrigin = "https://console.example.invalid";
function fixtureHelper(options) {
  // The managed test host has its own /tmp/.git. Ignore only that ambient
  // scaffolding during synthetic fixture construction; product checks stay
  // unchanged and nested checkout rejection is exercised separately below.
  const original = fs.lstatSync;
  fs.lstatSync = function(file, ...args) {
    if (file === path.join(os.tmpdir(), ".git")) {
      const error = new Error("synthetic missing ambient Git marker"); error.code = "ENOENT"; throw error;
    }
    return original.call(this, file, ...args);
  };
  try {return createSessionHandoff(options);} finally {fs.lstatSync = original;}
}
function fixture(t, {existing = false, verify} = {}) {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), "catch-session-test-"));
  let now = 1800000000000, calls = 0;
  const binding = {runtime: {sourceSha: "a".repeat(40), executionSha256: "b".repeat(64)}, helperSha256: "c".repeat(64)};
  const credentialVersionName = "projects/demo-catch-setup/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/7";
  const scope = {projectId: "demo-catch-setup", actorUid: "fake-google-actor",
    actorEmailSha256: sha(JSON.stringify("actor@example.invalid")), recipientUid: "fake-phone-recipient",
    endpointHash: "d".repeat(64), appId: "10001", wabaId: "10002", phoneNumberId: "10003",
    credentialVersionSha256: sha(credentialVersionName)};
  const profile = {schemaVersion: 1, scope, ...binding.runtime, credentialVersionName,
    runtimePrincipal: "serviceAccount:runtime@demo-catch-setup.iam.gserviceaccount.com"};
  const decoded = () => ({uid: scope.actorUid, sub: scope.actorUid, aud: scope.projectId,
    iss: "https://securetoken.google.com/" + scope.projectId, email: "actor@example.invalid",
    email_verified: true, firebase: {sign_in_provider: "google.com"},
    auth_time: now / 1000 - 1, iat: now / 1000, exp: now / 1000 + 3600});
  const file = (name, value) => fs.writeFileSync(path.join(home, name), value, {mode: 0o600});
  if (existing) {file("profile.json", JSON.stringify(profile) + "\n"); file("actor-id-token.txt", "old.synthetic.session\n");}
  const helper = fixtureHelper({home, clientOrigin, now: () => now, identity: () => binding,
    verifierFactory: projectId => {
      calls++; assert.equal(projectId, scope.projectId);
      return async token => {assert.equal(token, privateToken); return verify ? verify(decoded()) : decoded();};
    }});
  t.after(() => {helper.close(); fs.rmSync(home, {recursive: true, force: true});});
  let origin, anchor, csrf, transfer;
  async function start() {
    const launch = await helper.start();
    assert.equal(fs.statSync(launch.launchFile).mode & 0o777, 0o600);
    assert.equal(fs.statSync(path.dirname(launch.launchFile)).mode & 0o777, 0o700);
    assert.deepEqual(Object.keys(launch).sort(), ["expiresAtMillis", "launchFile"]);
    const source = fs.readFileSync(launch.launchFile, "utf8");
    assert.match(source, /window.opener = null/u);
    const target = JSON.parse(source.match(/location\.replace\(("[^\n]*")\)/u)[1]);
    assert.equal(new URL(target).origin, clientOrigin);
    anchor = JSON.parse(Buffer.from(new URL(target).hash.slice(1), "base64url").toString("utf8"));
    origin = anchor.localOrigin;
    assert.notEqual(anchor.serverEncryptionKey, anchor.serverSigningKey);
    return launch;
  }
  function request(route, value = {}, headers = {}, method = "POST") {
    return new Promise((resolve, reject) => {
      const req = http.request(origin + route, {method, headers: {Origin: clientOrigin,
        "Sec-Fetch-Site": "cross-site", "Content-Type": "application/json", "X-Catch-Request": randomBytes(32).toString("hex"),
        ...(csrf ? {"X-Catch-CSRF": csrf} : {}), ...headers}}, response => {
        let text = ""; response.setEncoding("utf8"); response.on("data", chunk => text += chunk);
        response.on("end", () => resolve({status: response.statusCode, text, headers: response.headers,
          value: response.headers["content-type"] === "application/json" ? JSON.parse(JSON.parse(text).payload) : null}));
      });
      req.on("error", reject); req.end(method === "GET" ? undefined : JSON.stringify(value));
    });
  }
  async function bootstrap() {
    const encryptedBootstrap = publicEncrypt({key: createPublicKey({key: Buffer.from(anchor.serverEncryptionKey, "base64url"), type: "spki", format: "der"}), oaepHash: "sha256", oaepLabel: Buffer.from("catch-operator-session/bootstrap/" + anchor.challenge)}, Buffer.from(anchor.bootstrapCapability)).toString("base64url");
    const result = await request("/bootstrap", {encryptedBootstrap});
    assert.equal(result.status, 200, result.text);
    csrf = result.value.csrf;
    assert.equal(result.headers["access-control-allow-origin"], clientOrigin);
    assert.equal(result.headers["set-cookie"], undefined);
    return result;
  }
  async function configure(candidate = profile) {
    const result = await request("/configure", candidate);
    if (result.status === 200) transfer = result.value.request;
    return result;
  }
  const seal = (token = privateToken, contextRequest = transfer) => {
    const context = JSON.stringify(Object.keys(contextRequest).sort().map(key => [key, contextRequest[key]]));
    const key = randomBytes(32), iv = randomBytes(12);
    const cipher = createCipheriv("aes-256-gcm", key, iv); cipher.setAAD(Buffer.from(context));
    const ciphertext = Buffer.concat([cipher.update(token), cipher.final(), cipher.getAuthTag()]);
    const wrappedKey = publicEncrypt({key: createPublicKey({key: Buffer.from(anchor.serverEncryptionKey, "base64url"), format: "der", type: "spki"}), oaepHash: "sha256", oaepLabel: Buffer.from("catch-operator-session/token/" + context)}, key);
    return {wrappedKey: wrappedKey.toString("base64url"), iv: iv.toString("base64url"), ciphertext: ciphertext.toString("base64url")};
  };
  const save = () => request("/session", {challenge: transfer.challenge, sealedSession: seal()});
  return {home, helper, binding, profile, scope, decoded, file, start, request, bootstrap, configure, save, seal,
    calls: () => calls, setNow: value => now = value, get transfer() {return transfer;}, get anchor() {return anchor;}};
}

test("encrypted private bootstrap, exact Host/Origin and CSRF precede configuration", async t => {
  const f = fixture(t); await f.start();
  const page = await f.request("/", {}, {}, "GET");
  assert.equal(page.status, 400);
  assert.ok(!page.text.includes(f.scope.actorUid)); assert.ok(!page.text.includes(f.binding.runtime.sourceSha));
  for (const headers of [{Origin: "https://evil.invalid"}, {Host: "evil.invalid"}, {"Sec-Fetch-Site": "same-origin"}]) {
    assert.equal((await f.request("/bootstrap", {}, headers)).status, 400);
  }
  assert.equal(f.calls(), 0); await f.bootstrap();
  assert.equal((await f.request("/bootstrap")).status, 400);
  for (const headers of [{"X-Catch-CSRF": ""}, {"X-Catch-CSRF": "wrong"}, {Origin: "https://evil.invalid"}]) {
    assert.equal((await f.request("/configure", f.profile, headers)).status, 400);
  }
  assert.equal(fs.existsSync(path.join(f.home, "profile.json")), false);
  assert.equal(f.calls(), 0);
});

test("offline profile validation writes nothing; valid confirmed handoff saves only private profile and session", async t => {
  const f = fixture(t); await f.start(); await f.bootstrap();
  for (const candidate of [{...f.profile, unexpected: true}, {...f.profile, sourceSha: "e".repeat(40)},
    {...f.profile, executionSha256: "f".repeat(64)}, {...f.profile, credentialVersionName: "secret-payload"},
    {...f.profile, scope: {...f.scope, actorUid: f.scope.recipientUid}}]) {
    assert.equal((await f.configure(candidate)).status, 400);
    assert.equal(f.calls(), 0); assert.equal(fs.existsSync(path.join(f.home, "profile.json")), false);
  }
  assert.equal((await f.configure()).status, 200);
  assert.equal(f.calls(), 0); assert.equal(fs.existsSync(path.join(f.home, "profile.json")), false);
  const result = await f.save(); assert.equal(result.status, 200, result.text);
  assert.equal(result.value.state, "saved"); assert.ok(!result.text.includes(privateToken));
  assert.deepEqual(fs.readdirSync(f.home).sort(), ["actor-id-token.txt", "profile.json"]);
  for (const name of fs.readdirSync(f.home)) assert.equal(fs.statSync(path.join(f.home, name)).mode & 0o777, 0o600);
  assert.equal(fs.statSync(f.home).mode & 0o777, 0o700);
  assert.equal(fs.readFileSync(path.join(f.home, "actor-id-token.txt"), "utf8"), privateToken + "\n");
  assert.equal(f.calls(), 1);
});

test("existing profile is byte-preserved; only the verified actor session is replaced", async t => {
  const f = fixture(t, {existing: true}); const before = fs.readFileSync(path.join(f.home, "profile.json"));
  await f.start(); await f.bootstrap();
  assert.equal((await f.configure({...f.profile, scope: {...f.scope, endpointHash: "e".repeat(64)}})).status, 400);
  assert.equal((await f.configure()).status, 200); assert.equal((await f.save()).status, 200);
  assert.deepEqual(fs.readFileSync(path.join(f.home, "profile.json")), before);
});

test("replay is consumed before verification and cannot start another verification", async t => {
  let resolve, entered;
  const ready = new Promise(r => entered = r);
  const waiting = new Promise(r => resolve = r);
  const f = fixture(t, {verify: async decoded => {entered(); await waiting; return decoded;}});
  await f.start(); await f.bootstrap(); await f.configure();
  const first = f.save(); await ready;
  assert.equal((await f.save()).status, 400); assert.equal(f.calls(), 1);
  resolve(); assert.equal((await first).status, 200);
});

for (const drift of ["cancel", "expiry", "source", "helper", "profile", "session", "permissions", "home"]) {
  test(`${drift} during verification prevents save and preserves existing files`, async t => {
    let resolve, entered;
    const ready = new Promise(r => entered = r), waiting = new Promise(r => resolve = r);
    const f = fixture(t, {existing: true, verify: async decoded => {entered(); await waiting; return decoded;}});
    await f.start(); await f.bootstrap(); await f.configure();
    const beforeProfile = fs.readFileSync(path.join(f.home, "profile.json"));
    const first = f.save(); await ready;
    if (drift === "cancel") assert.equal((await f.request("/cancel")).status, 200);
    if (drift === "expiry") f.setNow(1800000300000);
    if (drift === "source") f.binding.runtime.sourceSha = "e".repeat(40);
    if (drift === "helper") f.binding.helperSha256 = "e".repeat(64);
    if (drift === "profile") f.file("profile.json", JSON.stringify({...f.profile, runtimePrincipal: "serviceAccount:other@demo-catch-setup.iam.gserviceaccount.com"}) + "\n");
    if (drift === "session") f.file("actor-id-token.txt", "changed.synthetic.session\n");
    if (drift === "permissions") fs.chmodSync(f.home, 0o755);
    if (drift === "home") {fs.renameSync(f.home, f.home + "-old"); fs.mkdirSync(f.home, {mode: 0o700}); t.after(() => fs.rmSync(f.home + "-old", {recursive: true, force: true}));}
    resolve(); const result = await first; assert.equal(result.status, 400); assert.ok(!result.text.includes(privateToken));
    if (drift !== "home") {
      assert.equal(fs.readFileSync(path.join(f.home, "actor-id-token.txt"), "utf8"), drift === "session" ? "changed.synthetic.session\n" : "old.synthetic.session\n");
      if (drift !== "profile") assert.deepEqual(fs.readFileSync(path.join(f.home, "profile.json")), beforeProfile);
    } else assert.deepEqual(fs.readdirSync(f.home), []);
  });
}

test("signed session must match exact account, project, Google provider and fresh auth_time", t => {
  const f = fixture(t); const valid = f.decoded(); assert.doesNotThrow(() => assertSession(valid, f.scope, 1800000000000));
  for (const mutation of [{uid: "other"}, {sub: "other"}, {aud: "other-project"}, {iss: "wrong"},
    {firebase: {sign_in_provider: "phone"}}, {firebase: {sign_in_provider: "google.com", tenant: "tenant"}},
    {tenant_id: "tenant"}, {email: "other@example.invalid"}, {email_verified: false},
    {auth_time: valid.auth_time - 301}, {auth_time: valid.iat + 1}, {iat: valid.iat + 1},
    {exp: valid.iat}, {exp: valid.exp + 1}, {auth_time: -1}, {iat: Number.MAX_SAFE_INTEGER}, {exp: NaN}]) {
    assert.throws(() => assertSession({...valid, ...mutation}, f.scope, 1800000000000), /Protected session handoff unavailable/u);
  }
});

test("verification rejection and malformed token are redacted, one-shot and write nothing", async t => {
  for (const malformed of [false, true]) {
    const f = fixture(t, {verify: async () => {throw new Error(privateToken + " revoked or invalid");}});
    await f.start(); await f.bootstrap(); await f.configure();
    const response = malformed ? await f.request("/session", {challenge: f.transfer.challenge, sealedSession: f.seal("sensitive-invalid-token")}) : await f.save();
    assert.equal(response.status, 400); assert.deepEqual(response.value, {state: "unavailable"});
    assert.equal((await f.save()).status, 400); assert.equal(f.calls(), malformed ? 0 : 1);
    assert.equal(fs.existsSync(path.join(f.home, "profile.json")), false);
    assert.equal(fs.existsSync(path.join(f.home, "actor-id-token.txt")), false);
  }
});

test("private files reject permissive modes, hardlinks, symlinks and dangling symlinks", async t => {
  for (const kind of ["mode", "link", "symlink", "dangling"]) {
    const f = fixture(t, {existing: true}); await f.start(); await f.bootstrap(); await f.configure();
    const tokenPath = path.join(f.home, "actor-id-token.txt");
    if (kind === "mode") fs.chmodSync(tokenPath, 0o644);
    if (kind === "link") fs.linkSync(tokenPath, path.join(f.home, "linked"));
    if (kind === "symlink" || kind === "dangling") {fs.unlinkSync(tokenPath); fs.symlinkSync(path.join(f.home, kind === "symlink" ? "profile.json" : "missing"), tokenPath);}
    assert.equal((await f.save()).status, 400); assert.equal(f.calls(), 0);
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-reject-home-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  fs.chmodSync(directory, 0o755);
  assert.throws(() => fixtureHelper({home: directory, clientOrigin}));
  fs.chmodSync(directory, 0o700); fs.mkdirSync(path.join(directory, ".git"));
  assert.throws(() => fixtureHelper({home: directory, clientOrigin}));
  for (const invalid of ["http://console.example.invalid", clientOrigin + "/path", clientOrigin + "#fragment", "https://user:pass@console.example.invalid"]) {
    assert.throws(() => createSessionHandoff({home: directory, clientOrigin: invalid}));
  }
});

test("cancel before transfer leaves no new profile/session and cleans only helper-owned launch files", async t => {
  const f = fixture(t); const launch = await f.start(); await f.bootstrap(); await f.configure();
  const extra = path.join(path.dirname(launch.launchFile), "unexpected"); fs.writeFileSync(extra, "preserve", {mode: 0o600});
  assert.equal((await f.request("/cancel")).status, 200);
  assert.equal(fs.existsSync(launch.launchFile), false); assert.equal(fs.readFileSync(extra, "utf8"), "preserve");
  assert.equal(fs.existsSync(path.join(f.home, "profile.json")), false); assert.equal(f.calls(), 0);
});

test("public Admin SDK verifier requires revocation checks without custom-token or setter APIs", () => {
  const Module = require("node:module"), original = Module._load;
  let call;
  Module._load = function(name, ...args) {
    if (name === "firebase-admin/app") return {initializeApp: options => {assert.deepEqual(options, {projectId: "demo-catch-setup"}); return {};}};
    if (name === "firebase-admin/auth") return {getAuth: () => ({verifyIdToken: (...value) => {call = value; return {};}})};
    return original.call(this, name, ...args);
  };
  try {verifyFactory("demo-catch-setup")(privateToken); assert.deepEqual(call, [privateToken, true]);}
  finally {Module._load = original;}
});

test("CLI rejects unapproved argument forms without exposing credential-shaped inputs", () => {
  const command = path.resolve(__dirname, "../scripts/operations/catch-whatsapp-session-handoff.cjs");
  for (const args of [[], ["--token", privateToken], ["--home", privateToken, "--client-origin", clientOrigin]]) {
    const result = spawnSync(process.execPath, [command, ...args], {encoding: "utf8"});
    assert.equal(result.status, 1); assert.equal(result.stdout, "");
    assert.equal(result.stderr, "Protected session handoff unavailable.\n");
  }
});


test("raw tokens and tampered or differently bound ciphertext never reach SDK verification", async t => {
  for (const mode of ["raw", "ciphertext", "scope", "source", "expiry", "challenge"]) {
    const f = fixture(t); await f.start(); await f.bootstrap(); await f.configure();
    const context = {...f.transfer};
    if (mode === "scope") context.scopeSha256 = "e".repeat(64);
    if (mode === "source") context.sourceSha = "e".repeat(40);
    if (mode === "expiry") context.expiresAtMillis -= 1;
    if (mode === "challenge") context.challenge = "e".repeat(64);
    const sealedSession = f.seal(privateToken, context);
    if (mode === "ciphertext") {
      const bytes = Buffer.from(sealedSession.ciphertext, "base64url"); bytes[0] ^= 1;
      sealedSession.ciphertext = bytes.toString("base64url");
    }
    const input = mode === "raw" ? {challenge: f.transfer.challenge, idToken: privateToken} : {challenge: f.transfer.challenge, sealedSession};
    const result = await f.request("/session", input);
    assert.equal(result.status, 400); assert.equal(f.calls(), 0); assert.ok(!result.text.includes(privateToken));
    assert.equal(fs.existsSync(path.join(f.home, "actor-id-token.txt")), false);
  }
});
