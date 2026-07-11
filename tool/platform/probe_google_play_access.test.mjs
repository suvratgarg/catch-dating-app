import assert from "node:assert/strict";
import test from "node:test";
import {probeGooglePlayAccess} from "./probe_google_play_access.mjs";

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
  const responses = [response({id: "edit-1"}), response({track: "qa"}), response(null, 204)];
  const result = await probeGooglePlayAccess({
    packageName: "com.catchdates.host",
    accessToken: "token",
    fetchImpl: async (url, options) => {
      requests.push({url, options});
      return responses.shift();
    },
  });
  assert.equal(result.accessVerified, true);
  assert.equal(result.committed, false);
  assert.equal(requests[2].options.method, "DELETE");
  assert.ok(requests.every((request) => !request.url.includes(":commit")));
});

test("Play probe deletes its edit when qa access is denied", async () => {
  const requests = [];
  const responses = [response({id: "edit-1"}), response({error: {message: "denied"}}, 403), response(null, 204)];
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
