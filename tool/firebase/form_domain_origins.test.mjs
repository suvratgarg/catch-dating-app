import assert from "node:assert/strict";
import test from "node:test";
import {evaluateFormOrigins, formOriginTarget, readFormOrigins, reconcileFormOrigins} from "./form_domain_origins.mjs";

const target = formOriginTarget({projectId: "catchdates-dev", projectNumber: "1234567890",
  siteId: "catchdates-forms-dev", hostname: "forms.client.example",
  appId: "1:1234567890:web:0123abcd", siteKey: "test_enterprise_public_site_key", bucket: "catchdates-dev.firebasestorage.app"});
const unrelatedCors = {origin: ["https://another.example"], method: ["GET"], responseHeader: ["X-Other"], maxAgeSeconds: 60};
function fixture({ready = false, beforeRequest = () => {}} = {}) {
  const state = {
    auth: {name: `projects/${target.projectNumber}/config`, authorizedDomains: ["catchdates-dev.web.app"], signIn: {allowDuplicateEmails: false}},
    appCheck: {name: `projects/${target.projectNumber}/apps/${target.appId}/recaptchaEnterpriseConfig`, siteKey: target.siteKey},
    key: {name: `projects/${target.projectNumber}/keys/${target.siteKey}`, displayName: "Keep this name", webSettings: {
      allowedDomains: ["catchdates-dev.web.app"], integrationType: "SCORE", allowAllDomains: false, allowAmpTraffic: false,
    }},
    bucket: {name: target.bucket, metageneration: "7", cors: [structuredClone(unrelatedCors)], labels: {keep: "yes"}},
  };
  if (ready) {
    state.auth.authorizedDomains.push(target.hostname);
    state.key.webSettings.allowedDomains.push(target.hostname);
    state.bucket.cors.push({origin: [target.origin], method: ["POST"], responseHeader: ["Content-Type"], maxAgeSeconds: 3600});
  }
  const calls = [];
  let bindingChecks = 0;
  return {state, calls, bindingChecks: () => bindingChecks,
    assertBinding: async () => {bindingChecks++;},
    request: async (config) => {
      const owner = config.url.includes("identitytoolkit") ? "auth" :
        config.url.includes("firebaseappcheck") ? "appCheck" : config.url.includes("recaptchaenterprise") ? "key" : "bucket";
      calls.push(config);
      await beforeRequest({config, owner, state, calls});
      if (config.method === "PATCH") {
        if (owner === "auth") state.auth.authorizedDomains = config.data.authorizedDomains;
        else if (owner === "key") state.key.webSettings.allowedDomains = config.data.webSettings.allowedDomains;
        else {
          const expected = new URL(config.url).searchParams.get("ifMetagenerationMatch");
          if (expected !== state.bucket.metageneration) return {status: 412, data: {}};
          state.bucket.cors = config.data.cors;
          state.bucket.metageneration = String(Number(state.bucket.metageneration) + 1);
        }
      }
      return {status: 200, data: structuredClone(state[owner])};
    }};
}

test("origin identity must bind the exact website app to the selected project", () => {
  for (const patch of [{appId: "1:9999999999:web:abc"}, {appId: `${target.appId}/other`},
    {siteKey: "wrong/key"}, {bucket: "bucket?projection=full"}]) {
    assert.throws(() => formOriginTarget({...target, ...patch}), /Exact website/);
  }
});

test("read-only reports missing origins and performs no mutation", async () => {
  const client = fixture();
  const result = await reconcileFormOrigins(target, client);
  assert.equal(result.applied, false);
  assert.equal(result.ready, false);
  assert.deepEqual(result.missing, ["auth-domain", "enterprise-domain", "upload-cors"]);
  assert.equal(client.calls.length, 4);
  assert.ok(client.calls.every((call) => call.method === "GET" && call.retry === false && call.maxRedirects === 0 && call.timeout === 30000));
});

test("wrong provider identities, unbound keys and allow-all configurations fail closed", async () => {
  for (const mutate of [
    (s) => {s.auth.name = "projects/other/config";},
    (s) => {s.appCheck.siteKey = "other-key";},
    (s) => {s.appCheck.name = s.appCheck.name.replace(target.appId, "other-app");},
    (s) => {s.key.name = "projects/other/keys/key";},
    (s) => {s.key.webSettings.allowAllDomains = true;},
    (s) => {s.key.webSettings.integrationType = "CHECKBOX";},
    (s) => {s.key.webSettings.allowedDomains = "example.com";},
    (s) => {s.bucket.name = "other-bucket";},
    (s) => {s.bucket.metageneration = "7&other=true";},
    (s) => {s.bucket.cors = [{origin: "*", method: ["POST"]}];},
  ]) {
    const client = fixture({ready: true}); mutate(client.state);
    await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true}), /Unexpected website/);
    assert.equal(client.calls.some((call) => call.method === "PATCH"), false);
  }
});

test("apply updates only exact-host fields and preserves unrelated configuration", async () => {
  const client = fixture();
  const result = await reconcileFormOrigins(target, {...client, apply: true});
  assert.equal(result.ready, true);
  const patches = client.calls.filter((call) => call.method === "PATCH");
  assert.equal(patches.length, 3);
  assert.deepEqual(Object.keys(patches[0].data), ["authorizedDomains"]);
  assert.equal(new URL(patches[0].url).searchParams.get("updateMask"), "authorizedDomains");
  assert.equal(new URL(patches[1].url).searchParams.get("updateMask"), "webSettings.allowedDomains");
  assert.deepEqual(patches[1].data.webSettings, {allowedDomains: ["catchdates-dev.web.app", target.hostname]});
  assert.equal(new URL(patches[2].url).searchParams.get("ifMetagenerationMatch"), "7");
  assert.deepEqual(client.state.auth.signIn, {allowDuplicateEmails: false});
  assert.equal(client.state.key.displayName, "Keep this name");
  assert.equal(client.state.key.webSettings.allowAllDomains, false);
  assert.deepEqual(client.state.bucket.labels, {keep: "yes"});
  assert.deepEqual(client.state.bucket.cors[0], unrelatedCors);
  assert.deepEqual(client.state.bucket.cors[1], {origin: [target.origin], method: ["POST"], responseHeader: ["Content-Type"], maxAgeSeconds: 3600});
  assert.ok(client.bindingChecks() >= 8);
  const callsBefore = client.calls.length;
  await reconcileFormOrigins(target, {...client, apply: true});
  assert.equal(client.calls.slice(callsBefore).some((call) => call.method === "PATCH"), false);
});

test("fresh reads preserve independently added entries before each update", async () => {
  let authReads = 0;
  const client = fixture({beforeRequest: ({config, owner, state}) => {
    if (config.method === "GET" && owner === "auth" && ++authReads === 2) state.auth.authorizedDomains.push("added.example");
  }});
  await reconcileFormOrigins(target, {...client, apply: true});
  assert.ok(client.state.auth.authorizedDomains.includes("added.example"));
});

test("a stale bucket metageneration fails instead of overwriting a concurrent edit", async () => {
  const client = fixture({beforeRequest: ({config, owner, state}) => {
    if (config.method === "PATCH" && owner === "bucket") {
      state.bucket.metageneration = "8";
      state.bucket.cors.push({origin: ["https://concurrent.example"], method: ["GET"]});
    }
  }});
  await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true}), /invalid metadata/);
  assert.ok(client.state.bucket.cors.some((rule) => rule.origin.includes("https://concurrent.example")));
  assert.equal(client.state.bucket.cors.some((rule) => rule.origin.includes(target.origin)), false);
});

test("known Enterprise capacity blocks all writes without allowing every domain", async () => {
  const client = fixture();
  client.state.key.webSettings.allowedDomains = Array.from({length: 250}, (_, index) => `host${index}.example`);
  await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true}), /capacity/);
  assert.equal(client.calls.some((call) => call.method === "PATCH"), false);
  assert.equal(client.state.key.webSettings.allowAllDomains, false);
});

test("ownership change between read and write stops before the next provider mutation", async () => {
  const client = fixture(); let guards = 0;
  await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true,
    assertBinding: async () => {if (++guards === 2) throw new Error("Domain generation changed");},
  }), /generation changed/);
  assert.equal(client.calls.some((call) => call.method === "PATCH"), false);
});

test("unknown provider outcome is not retried or described as completed", async () => {
  const client = fixture({beforeRequest: ({config}) => {if (config.method === "PATCH") throw new Error("Bearer secret");}});
  await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true}), (error) => {
    assert.match(error.message, /re-read status/); assert.doesNotMatch(error.message, /Bearer|secret/); return true;
  });
  assert.equal(client.calls.filter((call) => call.method === "PATCH").length, 1);
});

test("revoke removes exact entries and preserves shared CORS rules and unrelated origins", async () => {
  const client = fixture({ready: true});
  client.state.bucket.cors[1].origin.push("https://shared.example");
  const result = await reconcileFormOrigins(target, {...client, apply: true, remove: true});
  assert.equal(result.exactRemoved, true);
  assert.equal(result.providerTrustRemoved, true);
  assert.deepEqual(client.state.bucket.cors[1].origin, ["https://shared.example"]);
  assert.deepEqual(client.state.auth.authorizedDomains, ["catchdates-dev.web.app"]);
  assert.deepEqual(client.state.key.webSettings.allowedDomains, ["catchdates-dev.web.app"]);
});

test("revoke exposes inherited Enterprise and wildcard CORS trust rather than deleting other grants", async () => {
  const client = fixture({ready: true});
  client.state.key.webSettings.allowedDomains.push("client.example");
  client.state.bucket.cors.push({origin: ["*"], method: ["GET"]});
  const result = await reconcileFormOrigins(target, {...client, apply: true, remove: true});
  assert.equal(result.exactRemoved, true);
  assert.equal(result.providerTrustRemoved, false);
  assert.deepEqual(result.ancestorGrants, ["client.example"]);
  assert.equal(result.wildcardCors, true);
  assert.ok(client.state.key.webSettings.allowedDomains.includes("client.example"));
  assert.ok(client.state.bucket.cors.some((rule) => rule.origin.includes("*")));
});

test("missing guards and provider metadata never become an apply plan", async () => {
  const client = fixture();
  await assert.rejects(() => reconcileFormOrigins(target, {...client, apply: true, assertBinding: undefined}), /binding check/);
  assert.equal(client.calls.length, 0);
  await assert.rejects(() => readFormOrigins(target, {request: async () => ({status: 200, data: null})}), /invalid metadata/);
  assert.throws(() => evaluateFormOrigins(target, {}), /Unexpected website/);
});

test("Auth-only inherited grants and noncanonical CORS origins remain explicit on revoke", async () => {
  const client = fixture({ready: true});
  client.state.auth.authorizedDomains.push("CLIENT.EXAMPLE");
  const result = await reconcileFormOrigins(target, {...client, apply: true, remove: true});
  assert.equal(result.exactRemoved, true);
  assert.equal(result.providerTrustRemoved, false);
  assert.deepEqual(result.authAncestorGrants, ["CLIENT.EXAMPLE"]);
  assert.deepEqual(result.ancestorGrants, []);
  assert.ok(client.state.auth.authorizedDomains.includes("CLIENT.EXAMPLE"));
  const other = fixture({ready: true});
  other.state.bucket.cors.push({origin: ["http://forms.client.example"], method: ["GET"]});
  const residual = await reconcileFormOrigins(target, {...other, apply: true, remove: true});
  assert.equal(residual.providerTrustRemoved, false);
  assert.deepEqual(residual.remainingHostCors, ["http://forms.client.example"]);
});

test("case variants of the exact domain cannot survive a successful removal claim", async () => {
  const client = fixture({ready: true});
  client.state.auth.authorizedDomains.push("FORMS.CLIENT.EXAMPLE");
  client.state.key.webSettings.allowedDomains.push("FORMS.CLIENT.EXAMPLE");
  const result = await reconcileFormOrigins(target, {...client, apply: true, remove: true});
  assert.equal(result.providerTrustRemoved, true);
  assert.deepEqual(client.state.auth.authorizedDomains, ["catchdates-dev.web.app"]);
  assert.deepEqual(client.state.key.webSettings.allowedDomains, ["catchdates-dev.web.app"]);
});
