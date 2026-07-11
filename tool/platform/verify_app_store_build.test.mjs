import assert from "node:assert/strict";
import test from "node:test";
import {
  assertCandidateAboveBuilds,
  compareAppleBuildNumbers,
  waitForProcessedBuild,
} from "./verify_app_store_build.mjs";

function response(payload) {
  return {ok: true, status: 200, statusText: "OK", text: async () => JSON.stringify(payload)};
}

test("Apple build-number comparison handles legacy and dotted namespaces", () => {
  assert.equal(compareAppleBuildNumbers("202607110000002601", "2026071126"), 1);
  assert.equal(compareAppleBuildNumbers("9.2.1", "9.10.1"), -1);
  assert.equal(compareAppleBuildNumbers("4.2", "4.2.0"), 0);
});

test("candidate preflight rejects a non-monotonic build", () => {
  assert.throws(
    () => assertCandidateAboveBuilds("100", [{attributes: {version: "101"}}]),
    /not above/u,
  );
  assert.deepEqual(
    assertCandidateAboveBuilds("102", [{attributes: {version: "101"}}]),
    {candidate: "102", inspectedBuildCount: 1},
  );
});

test("processed-build wait tolerates discovery lag and processing", async () => {
  const responses = [
    response({data: []}),
    response({data: [{id: "build-1", attributes: {version: "102", processingState: "PROCESSING"}}]}),
    response({data: [{id: "build-1", attributes: {version: "102", processingState: "VALID", uploadedDate: "2026-07-11"}}]}),
  ];
  const result = await waitForProcessedBuild({
    appId: "app-1",
    buildNumber: "102",
    token: "jwt",
    fetchImpl: async () => responses.shift(),
    sleepImpl: async () => {},
    timeoutMs: 1000,
    pollMs: 0,
  });
  assert.equal(result.processingState, "VALID");
  assert.equal(result.buildId, "build-1");
  assert.equal(result.$schema, "catch.app-store-build-processing/v1");
});

test("processed-build wait fails closed on invalid processing", async () => {
  await assert.rejects(
    waitForProcessedBuild({
      appId: "app-1",
      buildNumber: "102",
      token: "jwt",
      fetchImpl: async () => response({data: [{id: "build-1", attributes: {processingState: "INVALID"}}]}),
      sleepImpl: async () => {},
      timeoutMs: 1000,
      pollMs: 0,
    }),
    /entered INVALID/u,
  );
});

test("processed-build wait refreshes the App Store token for every poll", async () => {
  let tokenCalls = 0;
  const seenTokens = [];
  const responses = [
    response({data: []}),
    response({data: [{id: "build-1", attributes: {processingState: "VALID"}}]}),
  ];
  await waitForProcessedBuild({
    appId: "app-1",
    buildNumber: "102",
    tokenProvider: async () => `jwt-${++tokenCalls}`,
    fetchImpl: async (_url, options) => {
      seenTokens.push(options.headers.Authorization);
      return responses.shift();
    },
    sleepImpl: async () => {},
    timeoutMs: 1000,
    pollMs: 0,
  });
  assert.deepEqual(seenTokens, ["Bearer jwt-1", "Bearer jwt-2"]);
});
