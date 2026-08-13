import assert from "node:assert/strict";
import test from "node:test";
import {distributeTestFlightBuild} from "./distribute_testflight_build.mjs";

function response(payload = {}, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 204 ? "No Content" : "OK",
    text: async () => status === 204 ? "" : JSON.stringify(payload),
  };
}

function fixtureFetch({alreadyAssociated = false, noEligibleGroups = false} = {}) {
  let associated = alreadyAssociated;
  const requests = [];
  const fetchImpl = async (url, options = {}) => {
    requests.push({url, options});
    const pathname = new URL(url).pathname;
    if (pathname === "/v1/builds/build-1") {
      return response({
        data: {
          type: "builds",
          id: "build-1",
          attributes: {version: "202608120000035001", processingState: "VALID"},
        },
      });
    }
    if (pathname === "/v1/builds/build-1/relationships/app") {
      return response({data: {type: "apps", id: "6778927317"}});
    }
    if (pathname === "/v1/apps/6778927317/betaGroups") {
      return response({
        data: [
          {
            type: "betaGroups",
            id: "internal-with-testers",
            attributes: {
              name: "Catch Host Internal",
              isInternalGroup: true,
              hasAccessToAllBuilds: false,
            },
          },
          {
            type: "betaGroups",
            id: "internal-empty",
            attributes: {name: "Empty Internal", isInternalGroup: true, hasAccessToAllBuilds: false},
          },
          {
            type: "betaGroups",
            id: "external-testers",
            attributes: {name: "External", isInternalGroup: false, hasAccessToAllBuilds: false},
          },
        ],
      });
    }
    if (pathname.endsWith("/relationships/betaTesters")) {
      const groupId = pathname.split("/")[3];
      const hasTesters = groupId === "internal-with-testers" && !noEligibleGroups;
      return response({data: hasTesters ? [{type: "betaTesters", id: "tester-1"}] : []});
    }
    if (pathname.endsWith("/relationships/builds")) {
      const groupId = pathname.split("/")[3];
      const hasBuild = groupId === "internal-with-testers" && associated;
      return response({data: hasBuild ? [{type: "builds", id: "build-1"}] : []});
    }
    if (pathname === "/v1/builds/build-1/relationships/betaGroups" && options.method === "POST") {
      const body = JSON.parse(options.body);
      assert.deepEqual(body, {
        data: [{type: "betaGroups", id: "internal-with-testers"}],
      });
      associated = true;
      return response({}, 204);
    }
    throw new Error(`Unexpected App Store Connect request: ${options.method ?? "GET"} ${url}`);
  };
  return {fetchImpl, requests};
}

function inputs(fetchImpl, overrides = {}) {
  return {
    appId: "6778927317",
    buildId: "build-1",
    buildNumber: "202608120000035001",
    releaseTarget: "host-ios",
    packageArtifactId: "9162396981",
    signedArtifactSha256: "a".repeat(64),
    promotionRunId: "31650893818",
    promotionRunAttempt: "1",
    token: "jwt-token-with-valid-length",
    fetchImpl,
    now: () => new Date("2026-08-13T10:00:00.000Z"),
    ...overrides,
  };
}

test("assigns a VALID exact build only to existing internal groups with testers", async () => {
  const {fetchImpl, requests} = fixtureFetch();
  const result = await distributeTestFlightBuild(inputs(fetchImpl, {apply: true}));
  assert.equal(result.$schema, "catch.testflight-internal-distribution/v1");
  assert.equal(result.operation, "associated");
  assert.equal(result.applied, true);
  assert.equal(result.selectedGroupCount, 1);
  assert.deepEqual(result.groups, [{
    id: "internal-with-testers",
    name: "Catch Host Internal",
    testerCount: 1,
    hasAccessToAllBuilds: false,
    hadBuildAccess: false,
    hasBuildAccess: true,
  }]);
  assert.equal(requests.filter((request) => request.options.method === "POST").length, 1);
  assert.equal(result.packageArtifactId, "9162396981");
  assert.equal(result.signedArtifactSha256, "a".repeat(64));
});

test("is idempotent when every eligible internal group already has the build", async () => {
  const {fetchImpl, requests} = fixtureFetch({alreadyAssociated: true});
  const result = await distributeTestFlightBuild(inputs(fetchImpl, {apply: true}));
  assert.equal(result.operation, "already-associated");
  assert.equal(result.groups[0].hadBuildAccess, true);
  assert.equal(result.groups[0].hasBuildAccess, true);
  assert.equal(requests.some((request) => request.options.method === "POST"), false);
});

test("dry run reports missing access without mutating App Store Connect", async () => {
  const {fetchImpl, requests} = fixtureFetch();
  const result = await distributeTestFlightBuild(inputs(fetchImpl));
  assert.equal(result.operation, "would-associate");
  assert.equal(result.applied, false);
  assert.equal(result.groups[0].hasBuildAccess, false);
  assert.equal(requests.some((request) => request.options.method === "POST"), false);
});

test("fails closed when the app has no internal group containing testers", async () => {
  const {fetchImpl} = fixtureFetch({noEligibleGroups: true});
  await assert.rejects(
    distributeTestFlightBuild(inputs(fetchImpl, {apply: true})),
    /no existing internal TestFlight group with testers/u,
  );
});

test("fails before group mutation when build identity or processing is not exact", async () => {
  const {fetchImpl} = fixtureFetch();
  await assert.rejects(
    distributeTestFlightBuild(inputs(fetchImpl, {buildNumber: "202608120000035002", apply: true})),
    /build number does not match/u,
  );
});
