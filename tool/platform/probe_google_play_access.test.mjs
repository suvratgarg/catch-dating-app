import assert from "node:assert/strict";
import test from "node:test";
import {
  probeGooglePlayAccess,
  probeGooglePlayFleetReadiness,
} from "./probe_google_play_access.mjs";

function response(payload, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? "OK" : "Failure",
    text: async () => payload == null ? "" : JSON.stringify(payload),
  };
}

test("Play probe reads qa access and deletes the uncommitted edit", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-1"}),
    response({track: "qa"}),
    response({googleGroups: ["catch-qa@example.com"]}),
    response(null, 204),
  ];
  const result = await probeGooglePlayAccess({
    packageName: "com.catchdates.host",
    accessToken: "token",
    fetchImpl: async (url, options) => {
      requests.push({url, options});
      return responses.shift();
    },
  });
  assert.equal(result.appRecordVerified, true);
  assert.equal(result.editAccessVerified, true);
  assert.equal(result.trackAccessVerified, true);
  assert.equal(result.testerAccessVerified, true);
  assert.equal(result.googleGroupTesterCount, 1);
  assert.equal(result.committed, false);
  assert.match(requests[2].url, /testers\/qa$/u);
  assert.equal(requests[3].options.method, "DELETE");
  assert.ok(requests.every((request) => !request.url.includes(":commit")));
});

test("Play probe deletes its edit when qa access is denied", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-1"}),
    response({error: {message: "denied"}}, 403),
    response(null, 204),
  ];
  await assert.rejects(
    probeGooglePlayAccess({
      packageName: "com.catchdates.host",
      accessToken: "token",
      fetchImpl: async (url, options) => {
        requests.push({url, options});
        return responses.shift();
      },
    }),
    /denied/u,
  );
  assert.equal(requests[2].options.method, "DELETE");
});

test("Play probe fails closed without machine-verifiable qa testers and deletes its edit", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-1"}),
    response({track: "qa"}),
    response({googleGroups: []}),
    response(null, 204),
  ];
  await assert.rejects(
    probeGooglePlayAccess({
      packageName: "com.catchdates.host",
      accessToken: "token",
      requireGoogleGroupTesters: true,
      fetchImpl: async (url, options) => {
        requests.push({url, options});
        return responses.shift();
      },
    }),
    /no machine-verifiable Google Group testers/u,
  );
  assert.equal(requests.at(-1).options.method, "DELETE");
});

test("fleet readiness requires both unique Catch apps and leaves no committed edit", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-consumer"}), response({track: "qa"}),
    response({googleGroups: ["catch-qa@example.com"]}), response(null, 204),
    response({id: "edit-host"}), response({track: "qa"}),
    response({googleGroups: ["catch-qa@example.com"]}), response(null, 204),
  ];
  const result = await probeGooglePlayFleetReadiness({
    packageNames: ["com.catchdates.app", "com.catchdates.host"],
    accessToken: "token",
    fetchImpl: async (url, options) => {
      requests.push({url, options});
      return responses.shift();
    },
  });
  assert.equal(result.ready, true);
  assert.deepEqual(result.packages.map((entry) => entry.packageName), [
    "com.catchdates.app",
    "com.catchdates.host",
  ]);
  assert.equal(requests.filter((request) => request.options?.method === "DELETE").length, 2);
  assert.ok(requests.every((request) => !request.url.includes(":commit")));
  await assert.rejects(probeGooglePlayFleetReadiness({
    packageNames: ["com.catchdates.app", "com.catchdates.app"],
    accessToken: "token",
  }), /must be unique/u);
});

test("fleet readiness deletes both edits when the second app is not ready", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-consumer"}), response({track: "qa"}),
    response({googleGroups: ["catch-qa@example.com"]}), response(null, 204),
    response({id: "edit-host"}), response({track: "qa"}),
    response({googleGroups: []}), response(null, 204),
  ];
  await assert.rejects(probeGooglePlayFleetReadiness({
    packageNames: ["com.catchdates.app", "com.catchdates.host"],
    accessToken: "token",
    fetchImpl: async (url, options) => {
      requests.push({url, options});
      return responses.shift();
    },
  }), /com\.catchdates\.host has no machine-verifiable Google Group testers/u);
  assert.equal(requests.filter((request) => request.options?.method === "DELETE").length, 2);
});
