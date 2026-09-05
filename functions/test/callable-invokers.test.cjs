const assert = require("node:assert/strict");
const test = require("node:test");
const {
  cloudRunPolicyPath,
  ensurePublicInvoker,
  listCallableServices,
} = require("../scripts/set-callable-invokers-public.cjs");

test("discovers every live callable service across pages", async () => {
  const paths = [];
  const services = await listCallableServices({
    projectId: "demo-project",
    token: "token",
    request: async ({path}) => {
      paths.push(path);
      if (!path.includes("pageToken=")) {
        return {
          functions: [
            {
              labels: {"deployment-callable": "true"},
              serviceConfig: {
                service:
                  "projects/demo/locations/asia-south1/services/current-callable",
              },
            },
            {
              labels: {"deployment-callable": "false"},
              serviceConfig: {
                service: "projects/demo/locations/asia-south1/services/http",
              },
            },
          ],
          nextPageToken: "next page",
        };
      }
      return {
        functions: [{
          labels: {"deployment-callable": true},
          serviceConfig: {
            service:
              "projects/demo/locations/asia-south1/services/retained-legacy",
          },
        }],
      };
    },
  });

  assert.deepEqual(services, [
    "projects/demo/locations/asia-south1/services/current-callable",
    "projects/demo/locations/asia-south1/services/retained-legacy",
  ]);
  assert.equal(paths.length, 2);
  assert.match(paths[1], /pageToken=next\+page/);
});

test("uses the exact live service resource and is idempotent", async () => {
  const calls = [];
  const service =
    "projects/demo/locations/asia-south1/services/send-event-broadcast";
  const changed = await ensurePublicInvoker({
    service,
    token: "token",
    request: async (request) => {
      calls.push(request);
      if (request.method === "GET") return {bindings: []};
      return {};
    },
  });
  assert.equal(changed, true);
  assert.equal(
    calls[0].path,
    `/v2/${service}:getIamPolicy?options.requestedPolicyVersion=3`,
  );
  assert.equal(
    calls[1].body.policy.bindings[0].members.includes("allUsers"),
    true,
  );

  const noChange = await ensurePublicInvoker({
    service,
    token: "token",
    request: async (request) => {
      assert.equal(request.method, "GET");
      return {
        bindings: [{role: "roles/run.invoker", members: ["allUsers"]}],
      };
    },
  });
  assert.equal(noChange, false);
});

test("rejects noncanonical Cloud Run service names", () => {
  assert.throws(
    () => cloudRunPolicyPath("send-event-broadcast", "getIamPolicy"),
    /Invalid Cloud Run service resource/,
  );
});

test("exact target scope checks only selected callables and permits webhook-only deployments", async () => {
  const {syncProject} = require("../scripts/set-callable-invokers-public.cjs");
  const policyReads = [];
  const request = async (query) => {
    if (query.hostname === "cloudfunctions.googleapis.com") {
      return {functions: ["selected", "unrelated", "webhook"].map((name) => ({
        name: `projects/demo-project/locations/asia-south1/functions/${name}`,
        state: "ACTIVE",
        labels: {"deployment-callable": name !== "webhook"},
        serviceConfig: {service: `projects/demo-project/locations/asia-south1/services/${name}`},
      }))};
    }
    assert.equal(query.method, "GET");
    policyReads.push(query.path);
    return {bindings: [{role: "roles/run.invoker", members: ["allUsers"]}]};
  };
  const result = await syncProject({projectId: "demo-project", token: "token",
    functionTargets: ["functions:selected", "functions:webhook"], request});
  assert.deepEqual(result, {checkedServices: 1, changedServices: 0});
  assert.equal(policyReads.length, 1);
  assert.match(policyReads[0], /services\/selected:/);
  policyReads.length = 0;
  assert.deepEqual(await syncProject({projectId: "demo-project", token: "token",
    functionTargets: ["functions:webhook"], request}), {checkedServices: 0, changedServices: 0});
  assert.deepEqual(policyReads, []);
});

test("unknown, missing and inactive selected targets fail before any IAM request", async () => {
  const {syncProject, parseFunctionTargets} = require("../scripts/set-callable-invokers-public.cjs");
  for (const invalid of ["", "functions", "functions:*", "functions:alpha,", "functions:alpha,functions:alpha", "functions:../alpha"]) {
    assert.throws(() => parseFunctionTargets(invalid), /exact/);
  }
  const fn = {name: "projects/demo-project/locations/asia-south1/functions/selected", state: "ACTIVE",
    labels: {"deployment-callable": "true"},
    serviceConfig: {service: "projects/demo-project/locations/asia-south1/services/selected"}};
  for (const functions of [[], [{...fn, state: "DEPLOYING"}], [{...fn, serviceConfig: {}}],
    [{...fn, name: "projects/foreign-project/locations/asia-south1/functions/selected"}]]) {
    await assert.rejects(syncProject({projectId: "demo-project", token: "token",
      functionTargets: ["functions:selected"], request: async (query) => {
        assert.equal(query.hostname, "cloudfunctions.googleapis.com", "Cannot mutate before full target discovery");
        return {functions};
      }}));
  }
});

test("conditional invoker bindings and policy etags survive an unconditional public grant", async () => {
  const condition = {title: "restricted", expression: "request.path.startsWith('/allowed')"};
  const original = {version: 3, etag: "original-etag", bindings: [
    {role: "roles/run.invoker", members: ["user:reviewer@example.invalid"], condition},
    {role: "roles/run.viewer", members: ["group:ops@example.invalid"]},
  ]};
  const calls = [];
  await ensurePublicInvoker({service: "projects/demo/locations/asia-south1/services/selected", token: "token",
    request: async (query) => {
      calls.push(query);
      return query.method === "GET" ? structuredClone(original) : {};
    }});
  assert.equal(calls.length, 2);
  const updated = calls[1].body.policy;
  assert.equal(updated.etag, original.etag);
  assert.equal(updated.version, original.version);
  assert.deepEqual(updated.bindings.slice(0, 2), original.bindings);
  assert.deepEqual(updated.bindings[2], {role: "roles/run.invoker", members: ["allUsers"]});
});

test("CLI validates target arguments before authentication and keeps help read-only", () => {
  const {spawnSync} = require("node:child_process");
  const script = require.resolve("../scripts/set-callable-invokers-public.cjs");
  const run = (args) => spawnSync(process.execPath, [script, ...args], {encoding: "utf8"});
  const help = run(["--help"]);
  assert.equal(help.status, 0, help.stderr);
  assert.match(help.stdout, /--targets functions:<name>/);
  for (const args of [[], ["--unknown"], ["demo-project", "--targets", "functions"],
    ["demo-project", "--targets"], ["../foreign-project"]]) {
    const result = run(args);
    assert.notEqual(result.status, 0);
    assert.doesNotMatch(result.stderr, /ADC unavailable|Firebase CLI auth/);
  }
});
