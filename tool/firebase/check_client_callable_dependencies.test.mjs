import assert from "node:assert/strict";
import test from "node:test";
import {
  probeCallable,
  validateClientCallableDependencies,
} from "./check_client_callable_dependencies.mjs";

const manifest = {
  version: 1,
  dependencies: [{
    id: "host-event-broadcast",
    appRole: "host",
    environment: "prod",
    dartDefine: "ENABLE_HOST_EVENT_BROADCAST",
    callable: "sendEventBroadcast",
    region: "asia-south1",
  }],
};

test("validates a disabled production dependency without a live call", () => {
  assert.deepEqual(
    validateClientCallableDependencies({
      manifest,
      appRole: "host",
      environment: "prod",
      envDefines: {ENABLE_HOST_EVENT_BROADCAST: "false"},
      appConfigSource:
        "bool.fromEnvironment('ENABLE_HOST_EVENT_BROADCAST')",
      functionTargets: ["functions:sendEventBroadcast"],
    }),
    [{...manifest.dependencies[0], enabled: false}],
  );
});

test("fails enabled flags whose callable is not exported", () => {
  assert.throws(
    () => validateClientCallableDependencies({
      manifest,
      appRole: "host",
      environment: "prod",
      envDefines: {ENABLE_HOST_EVENT_BROADCAST: "true"},
      appConfigSource:
        "bool.fromEnvironment('ENABLE_HOST_EVENT_BROADCAST')",
      functionTargets: [],
    }),
    /not exported/,
  );
});

test("live probe accepts an unauthenticated callable response", async () => {
  const calls = [];
  const result = await probeCallable({
    projectId: "demo-project",
    region: "asia-south1",
    callable: "sendEventBroadcast",
    fetchImpl: async (url, options) => {
      calls.push({url, options});
      return new Response(
        JSON.stringify({error: {status: "UNAUTHENTICATED"}}),
        {status: 401, headers: {"content-type": "application/json"}},
      );
    },
  });
  assert.equal(result.httpStatus, 401);
  assert.equal(result.callableStatus, "UNAUTHENTICATED");
  assert.match(calls[0].url, /sendEventBroadcast$/);
  assert.equal(calls[0].options.redirect, "manual");
});

test("live probe rejects HTML, redirects, and IAM permission errors", async () => {
  await assert.rejects(
    probeCallable({
      projectId: "demo",
      region: "asia-south1",
      callable: "sendEventBroadcast",
      fetchImpl: async () => new Response("not found", {status: 404}),
    }),
    /did not return.*JSON/,
  );
  await assert.rejects(
    probeCallable({
      projectId: "demo",
      region: "asia-south1",
      callable: "sendEventBroadcast",
      fetchImpl: async () => new Response(null, {
        status: 302,
        headers: {location: "https://example.com"},
      }),
    }),
    /redirect/,
  );
  await assert.rejects(
    probeCallable({
      projectId: "demo",
      region: "asia-south1",
      callable: "sendEventBroadcast",
      fetchImpl: async () => new Response(
        JSON.stringify({error: {status: "PERMISSION_DENIED"}}),
        {status: 403, headers: {"content-type": "application/json"}},
      ),
    }),
    /PERMISSION_DENIED/,
  );
});
