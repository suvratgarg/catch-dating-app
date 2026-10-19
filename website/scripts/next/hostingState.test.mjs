import assert from "node:assert/strict";
import test from "node:test";
import {readLiveHosting} from "./hostingState.mjs";

const site = "projects/catch-dating-app-64e51/sites/catch-dating-app-64e51";
const version = {name: `${site}/versions/abc123`, status: "FINALIZED", config: {rewrites: [{source: "**", destination: "/index.html"}]}};
const release = {version: {name: version.name}};
const runCommand = (command, args) => {
  assert.equal(command, "gcloud");
  assert.deepEqual(args, ["auth", "print-access-token"]);
  return {status: 0, stdout: "fixture-token\n"};
};

test("Hosting reads work with Hosting access alone and no quota-project permission", async () => {
  const urls = [];
  const result = await readLiveHosting({runCommand, fetchImpl: async (url, {headers, signal}) => {
    urls.push(url);
    assert.equal(headers.Authorization, "Bearer fixture-token");
    assert.ok(signal instanceof AbortSignal);
    // Emulate an identity with Hosting admin but no Service Usage Consumer role.
    if (new Headers(headers).has("x-goog-user-project")) return Response.json({error: {code: 403}}, {status: 403});
    return Response.json(url.includes("/releases?") ? {releases: [release]} : version);
  }});
  assert.deepEqual(urls, [
    `https://firebasehosting.googleapis.com/v1beta1/${site}/channels/live/releases?pageSize=1`,
    `https://firebasehosting.googleapis.com/v1beta1/${version.name}`,
  ]);
  assert.deepEqual(result, {version, release});
});

for (const status of [401, 403, 500]) {
  test(`Hosting HTTP ${status} still prevents promotion without a retry or fallback`, async () => {
    let calls = 0;
    await assert.rejects(readLiveHosting({runCommand, fetchImpl: async () => {
      calls++; return Response.json({error: {code: status}}, {status});
    }}), new RegExp(`Hosting metadata read failed \\(${status}\\)`));
    assert.equal(calls, 1);
  });
}

test("missing credentials prevent any Hosting request", async () => {
  for (const token of [{status: 1, stdout: ""}, {status: 0, stdout: "  "}]) {
    await assert.rejects(readLiveHosting({runCommand: () => token, fetchImpl: () => {
      assert.fail("No request may be made without credentials");
    }}));
  }
});

test("unfinalized Hosting metadata cannot be used for rollback or promotion", async () => {
  await assert.rejects(readLiveHosting({runCommand, fetchImpl: async url => Response.json(
    url.includes("/releases?") ? {releases: [release]} : {...version, status: "CREATED"},
  )}), /not finalized/);
});
