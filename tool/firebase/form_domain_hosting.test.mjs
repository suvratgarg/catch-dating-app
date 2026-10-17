import assert from "node:assert/strict";
import test from "node:test";
import {evaluateHostingDomain, hostingDomainTarget, provisionHostingDomain,
  readHostingDomain} from "./form_domain_hosting.mjs";

const target = hostingDomainTarget({projectId: "catchdates-dev", projectNumber: "1234567890",
  siteId: "catchdates-forms-dev", hostname: "forms.client.example"});
const observedAt = Date.parse("2026-10-17T16:00:00Z");
const now = () => observedAt;
function readyResource() {
  return {name: target.name, hostState: "HOST_ACTIVE", ownershipState: "OWNERSHIP_ACTIVE",
    cert: {state: "CERT_ACTIVE", expireTime: "2027-01-17T16:00:00.123456789Z"}, etag: "etag-1"};
}
function transport(...responses) {
  const calls = [];
  return {calls, now, request: async (config) => {
    calls.push(config);
    assert.ok(responses.length, "Unexpected extra provider call");
    const response = responses.shift();
    if (response instanceof Error) throw response;
    return response;
  }};
}
const ok = (data = readyResource()) => ({status: 200, data});
const missing = {status: 404};

test("only canonical exact-target segments enter the Hosting URL", () => {
  for (const patch of [
    {projectId: "other/path"}, {projectNumber: 123}, {projectNumber: "00123"},
    {siteId: "../admin"}, {siteId: "site?x=1"}, {siteId: "site%2Fadmin"},
    {hostname: "*.client.example"}, {hostname: "Forms.client.example"},
    {hostname: "https://forms.client.example"}, {hostname: "forms.client.example."},
    {hostname: "forms.client.example:443"}, {hostname: "forms..example"},
    {hostname: "-forms.client.example"}, {hostname: "forms.client.example/"},
    {hostname: "forms.client.example\n"}, {hostname: "localhost"},
  ]) assert.throws(() => hostingDomainTarget({...target, ...patch}), /exact project/);
  assert.equal(Object.isFrozen(target), true);
});

test("ready evidence is exact-project/site/host and has an unexpired active certificate", () => {
  const assessment = evaluateHostingDomain(target, readyResource(), observedAt);
  assert.equal(assessment.ready, true);
  assert.equal(assessment.observedAt, observedAt);
  assert.equal(assessment.certificateExpiresAt, Date.parse("2027-01-17T16:00:00.123Z"));
  assert.equal(assessment.name, target.name);
  assert.equal(evaluateHostingDomain(target, {...readyResource(), name: target.projectIdName}, observedAt).ready, true);
  for (const name of [
    target.name.replace("1234567890", "9999999999"),
    target.name.replace(target.siteId, "another-site"),
    target.name.replace(target.hostname, "other.client.example"),
    `${target.name}/child`, `https://attacker.example/${target.name}`,
  ]) assert.throws(() => evaluateHostingDomain(target, {...readyResource(), name}, observedAt), /different/);
});

test("every unsettled Hosting, ownership, certificate and deletion state blocks activation", () => {
  for (const patch of [
    {hostState: "HOST_UNHOSTED"}, {hostState: "HOST_CONFLICT"}, {hostState: "FUTURE_STATE"},
    {ownershipState: "OWNERSHIP_PENDING"}, {ownershipState: "OWNERSHIP_MISMATCH"},
    {reconciling: true}, {redirectTarget: "other.example"},
    {deleteTime: "2026-10-16T00:00:00Z"}, {expireTime: "2026-11-16T00:00:00Z"},
    {cert: null}, {cert: {state: "CERT_ACTIVE"}},
    {issues: [{code: 9, message: "Unresolved DNS conflict"}]},
  ]) assert.equal(evaluateHostingDomain(target, {...readyResource(), ...patch}, observedAt).ready, false, JSON.stringify(patch));
  for (const state of ["CERT_PREPARING", "CERT_VALIDATING", "CERT_PROPAGATING", "CERT_EXPIRING_SOON", "CERT_EXPIRED", "NEW_STATE"]) {
    const resource = readyResource(); resource.cert.state = state;
    assert.equal(evaluateHostingDomain(target, resource, observedAt).ready, false, state);
  }
  const resource = readyResource(); resource.cert.issues = [{code: 9}];
  assert.equal(evaluateHostingDomain(target, resource, observedAt).ready, false);
});

test("invalid, elapsed and impossible certificate dates fail closed", () => {
  for (const expireTime of [undefined, "", "tomorrow", "2027-02-30T00:00:00Z",
    "2026-10-17T16:00:00Z", "2026-10-17T15:59:59Z", "2027-01-17",
    "2027-01-17T16:00:00+00:00", 9999999999999]) {
    const resource = readyResource(); resource.cert.expireTime = expireTime;
    assert.equal(evaluateHostingDomain(target, resource, observedAt).ready, false, String(expireTime));
  }
  for (const clock of [NaN, Infinity, -1, "2026-10-17", observedAt + 0.5]) {
    assert.throws(() => evaluateHostingDomain(target, readyResource(), clock), /observation/);
  }
});

test("malformed provider objects never become readiness", () => {
  for (const resource of [undefined, [], true, {}, {name: target.name, reconciling: "false"},
    {name: target.name, redirectTarget: []}, {name: target.name, cert: []},
    {name: target.name, issues: {}}, {name: target.name, cert: {issues: {}}}]) {
    assert.throws(() => evaluateHostingDomain(target, resource, observedAt), /malformed/);
  }
});

test("read is bounded and cannot follow response URLs or caller-supplied paths", async () => {
  const resource = {...readyResource(), requiredDnsUpdates: {desired: [{domainName: target.hostname}]}};
  const fixture = transport(ok(resource));
  const result = await readHostingDomain({...target, name: "https://attacker.example"}, fixture);
  assert.equal(result.ready, true);
  assert.deepEqual(result.requiredDnsUpdates, resource.requiredDnsUpdates);
  assert.deepEqual(fixture.calls, [{method: "GET",
    url: `https://firebasehosting.googleapis.com/v1beta1/${target.name}`,
    responseType: "json", timeout: 30000, maxRedirects: 0, retry: false,
    headers: {"Cache-Control": "no-cache"}}]);
});

test("only an HTTP 404 means absent; failures do not become a create plan or expose credentials", async () => {
  for (const response of [missing, Object.assign(new Error("not logged"), {response: {status: 404}})]) {
    assert.equal((await readHostingDomain(target, transport(response))).exists, false);
  }
  for (const response of [{status: 403}, {status: 500}, {status: 302}, {status: "404"},
    new Error("Bearer secret: NOT_FOUND"), {data: readyResource()}]) {
    const fixture = transport(response);
    await assert.rejects(() => provisionHostingDomain(target, {...fixture, apply: true}), (error) => {
      assert.match(error.message, /Hosting read failed/);
      assert.doesNotMatch(error.message, /Bearer|secret/);
      return true;
    });
    assert.equal(fixture.calls.length, 1);
  }
});

test("provision defaults to read-only and leaves all existing domains alone", async () => {
  const absent = transport(missing);
  assert.deepEqual(await provisionHostingDomain(target, absent), {
    action: "create-required", state: {exists: false, ready: false, observedAt,
      name: target.name, blockers: ["hosting-domain-missing"]},
  });
  assert.equal(absent.calls.length, 1);
  for (const patch of [{}, {reconciling: true}, {deleteTime: "2026-10-16T00:00:00Z"},
    {redirectTarget: "existing.example"}, {ownershipState: "OWNERSHIP_MISMATCH"}]) {
    const fixture = transport(ok({...readyResource(), ...patch}));
    const result = await provisionHostingDomain(target, {...fixture, apply: true});
    assert.equal(result.action, "none");
    assert.equal(fixture.calls.length, 1);
  }
});

test("HTTP 200 with no domain body is malformed, never permission to create", async () => {
  for (const data of [null, undefined, [], false]) {
    const fixture = transport({status: 200, data});
    await assert.rejects(() => provisionHostingDomain(target, {...fixture, apply: true}), /malformed/);
    assert.deepEqual(fixture.calls.map((call) => call.method), ["GET"]);
  }
  const fixture = transport();
  await assert.rejects(() => provisionHostingDomain(target, {...fixture, apply: "false"}), /explicitly boolean/);
  assert.equal(fixture.calls.length, 0);
});

test("create sends one empty-body request and reads the exact resource, never the Operation URL", async () => {
  const operation = {name: "https://attacker.example/operations/1", done: true, response: readyResource()};
  const fixture = transport(missing, ok(operation), ok({...readyResource(), reconciling: true}));
  const result = await provisionHostingDomain(target, {...fixture, apply: true});
  assert.equal(result.action, "create");
  assert.equal(result.outcome, "requested");
  assert.equal(result.state.ready, false);
  assert.deepEqual(fixture.calls.map((call) => call.method), ["GET", "POST", "GET"]);
  assert.equal(fixture.calls[1].url,
    `https://firebasehosting.googleapis.com/v1beta1/${target.parent}/customDomains?customDomainId=forms.client.example`);
  assert.deepEqual(fixture.calls[1].data, {});
  assert.equal(fixture.calls[1].retry, false);
  assert.equal(fixture.calls[2].url, fixture.calls[0].url);
});

test("lost create response or conflict reconciles by read without repeating a mutation", async () => {
  for (const response of [new Error("timeout"), {status: 409}, {status: 503}, undefined]) {
    const fixture = transport(missing, response, ok());
    const result = await provisionHostingDomain(target, {...fixture, apply: true});
    assert.equal(result.outcome, "unknown");
    assert.equal(result.state.ready, true);
    assert.equal(fixture.calls.filter((call) => call.method === "POST").length, 1);
  }
});

test("create acknowledgements and failed readback cannot fabricate readiness", async () => {
  for (const response of [missing, {status: 503}, new Error("secret"), ok({name: "wrong-resource"})]) {
    const fixture = transport(missing, ok({done: true, response: readyResource()}), response);
    const result = await provisionHostingDomain(target, {...fixture, apply: true});
    assert.equal(result.outcome, "requested");
    assert.notEqual(result.state?.ready, true);
    if (result.state === null) assert.equal(result.nextAction, "read-status");
    assert.equal(fixture.calls.length, 3);
  }
});

test("definitive create rejections stop without activation or hidden retries", async () => {
  for (const status of [400, 401, 403, 404, 422]) {
    const fixture = transport(missing, {status, data: {message: "secret"}});
    await assert.rejects(() => provisionHostingDomain(target, {...fixture, apply: true}), new RegExp(`rejected.*${status}`));
    assert.equal(fixture.calls.length, 2);
  }
});
