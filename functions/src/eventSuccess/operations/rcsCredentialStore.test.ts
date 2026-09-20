import assert from "node:assert/strict";
import {generateKeyPairSync, verify} from "node:crypto";
import test from "node:test";
import {createRcsOAuthClient, parseRcsServiceAccount, RcsCredentialStore,
  RcsSecretClient, RCS_OAUTH_SCOPE} from "./rcsCredentialStore";
import {rcsTestConfig, rcsTestNow} from "./rcsTestFixtures";

const pair = generateKeyPairSync("rsa", {modulusLength: 2048});
const privateKey = pair.privateKey.export({type: "pkcs8", format: "pem"})
  .toString();
const config = rcsTestConfig();
const envelope = () => ({schema: "catch.event-rcs-credential/v1" as const,
  senderId: config.senderId, agentId: config.agentId, region: config.region,
  clientEmail: "rcs@test-project.iam.gserviceaccount.com", privateKey});
function fixture() {
  const clock = {now: rcsTestNow};
  const state = {value: envelope() as unknown, fail: false};
  const reads: Array<{name: string; options: unknown}> = [];
  const secret = {accessSecretVersion: async (input: {name: string},
    options: unknown) => {
    reads.push({...input, options});
    if (state.fail) throw new Error("private-secret-material");
    return [{payload: {data: Buffer.from(JSON.stringify(state.value))}}];
  }} as unknown as RcsSecretClient;
  return {clock, state, reads, secret};
}

test("RCS service-account envelopes reject ambiguous or foreign authority",
  () => {
    const e = envelope();
    assert.deepEqual(parseRcsServiceAccount(e, config), e);
    const ec = generateKeyPairSync("ec", {namedCurve: "prime256v1"})
      .privateKey.export({type: "pkcs8", format: "pem"}).toString();
    for (const invalid of [null, [], {...e, senderId: "other"},
      {...e, agentId: "other"}, {...e, region: "europe"},
      {...e, token_uri: "https://attacker.invalid"}, {...e, subject: "person"},
      {...e, keyFile: "/private/key"}, {...e, universe_domain: "other"},
      {...e, clientEmail: "person@gmail.com"},
      {...e, clientEmail: e.clientEmail + "\n"},
      {...e, privateKey: "private-secret-material"}, {...e, privateKey: ec}]) {
      assert.throws(() => parseRcsServiceAccount(invalid, config),
        /RCS sender credential unavailable/);
    }
  });

test("Google OAuth signs the exact RCS scope and cannot redirect credentials",
  async () => {
    const h = fixture();
    let exchanges = 0;
    const store = new RcsCredentialStore(h.secret, (account) => {
      const client = createRcsOAuthClient(account);
      client.transporter.defaults.adapter = async (options) => {
        exchanges++;
        assert.equal(options.url.href, "https://oauth2.googleapis.com/token");
        assert.equal(options.method, "POST");
        assert.equal(options.retry, false);
        assert.equal(options.retryConfig?.retry, 0);
        assert.equal(options.maxRedirects, 0);
        assert.equal(options.timeout, 8000);
        const body = new URLSearchParams(String(options.data));
        assert.equal(body.get("grant_type"),
          "urn:ietf:params:oauth:grant-type:jwt-bearer");
        const [header, payload, signature] = body.get("assertion")!.split(".");
        const claims = JSON.parse(Buffer.from(payload, "base64url")
          .toString("utf8"));
        assert.equal(claims.scope, RCS_OAUTH_SCOPE);
        assert.equal(claims.iss, account.clientEmail);
        assert.equal(claims.aud, "https://oauth2.googleapis.com/token");
        assert.equal(claims.sub, undefined);
        assert.equal(verify("RSA-SHA256", Buffer.from(header + "." + payload),
          pair.publicKey, Buffer.from(signature, "base64url")), true);
        return {config: options, status: 200, statusText: "OK",
          headers: new Headers(), data: {access_token: "fixture-access-token",
            expires_in: 3600, token_type: "Bearer"}} as never;
      };
      return client;
    });
    const first = await store.access(config);
    assert.equal(first.accessToken, "fixture-access-token");
    assert.equal(first.senderId, config.senderId);
    assert.equal(first.agentId, config.agentId);
    assert.ok(first.expiresAt > Date.now() + 3_500_000);
    await store.access(config);
    assert.equal(exchanges, 1);
    assert.equal(h.reads.length, 2,
      "secret availability precedes cached OAuth");
    const isolated = createRcsOAuthClient(envelope());
    isolated.transporter.defaults.adapter = async () => {
      assert.fail("Foreign token endpoints cannot reach transport");
    };
    await assert.rejects(isolated.transporter.request({
      url: "https://attacker.invalid/token", method: "POST"}), /unavailable/);
  });

test("secret versions remain pinned and failures cannot leak or reuse tokens",
  async () => {
    const h = fixture();
    let created = 0;
    const store = new RcsCredentialStore(h.secret, () => {
      created++;
      return {credentials: {expiry_date: h.clock.now + 3_600_000},
        getAccessToken: async () => ({token: "fixture-token"})};
    }, () => h.clock.now);
    for (const version of ["latest", "0", "01", "1\n"]) {
      await assert.rejects(store.access({...config, credentialVersion:
        config.credentialVersion.replace(/\/1$/, "/" + version)}),
      /RCS sender credential unavailable/);
    }
    assert.equal(h.reads.length, 0);
    await store.access(config);
    assert.equal(h.reads[0].name, config.credentialVersion);
    assert.deepEqual(h.reads[0].options, {timeout: 3000, retry: null});
    await store.access({...config, revision: 2});
    assert.equal(created, 1);
    await store.access({...config, credentialVersion:
      config.credentialVersion.replace(/\/1$/, "/2")});
    assert.equal(created, 2);
    h.state.fail = true;
    await assert.rejects(store.access(config), (error: Error) => {
      assert.equal(error.message, "RCS sender credential unavailable");
      assert.equal(error.cause, undefined);
      return true;
    });
    assert.equal(created, 2);
    h.state.fail = false;
    h.state.value = {...envelope(), extra: "private-secret-material"};
    await assert.rejects(store.access(config), /unavailable/);
  });

test("invalid, stale and backwards-clock token results are never authority",
  async () => {
    for (const invalid of ["missing", "short", "far", "newline", "failure",
      "clock"]) {
      const h = fixture();
      const store = new RcsCredentialStore(h.secret, () => ({credentials: {
        expiry_date: invalid === "missing" ? null : h.clock.now +
          (invalid === "short" ? 30_000 : invalid === "far" ? 7_200_000 :
            3_600_000)}, getAccessToken: async () => {
        if (invalid === "failure") throw new Error("private-provider-token");
        if (invalid === "clock") h.clock.now--;
        return {token: invalid === "newline" ? "token\n" : "fixture-token"};
      }}), () => h.clock.now);
      await assert.rejects(store.access(config), (e: Error) => {
        assert.equal(e.message, "RCS sender credential unavailable", invalid);
        assert.equal(e.cause, undefined);
        return true;
      });
    }
  });

test("OAuth client retention is bounded", async () => {
  const h = fixture();
  let created = 0;
  const store = new RcsCredentialStore(h.secret, () => {
    created++;
    return {credentials: {expiry_date: h.clock.now + 3_600_000},
      getAccessToken: async () => ({token: "fixture-token"})};
  }, () => h.clock.now);
  for (let version = 1; version <= 33; version++) {
    await store.access({...config, credentialVersion:
      config.credentialVersion.replace(/\/1$/, "/" + version)});
  }
  assert.equal(created, 33);
  await store.access(config);
  assert.equal(created, 34, "oldest cached client has been evicted");
});
