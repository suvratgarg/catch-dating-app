import assert from "node:assert/strict";
import test from "node:test";
import {
  checkRulesDeploymentDrift,
  executeRulesDeploymentDriftCli,
  fetchRulesApiJson,
  normalizedRulesHash,
  normalizeRulesContent,
  resolveRulesAccessToken,
} from "./check_rules_deployment_drift.mjs";

const projectId = "catchdates-dev";
const firestoreRules = "rules_version = '2';\nservice cloud.firestore {}\n";
const storageRules = "rules_version = '2';\nservice firebase.storage {}\n";

test("normalized hashes ignore only BOM, line endings, trailing whitespace, and final blank lines", () => {
  const equivalent = "\uFEFFrules_version = '2';  \r\nservice cloud.firestore {}\t\r\n\r\n";
  assert.equal(
    normalizeRulesContent(equivalent),
    firestoreRules,
  );
  assert.equal(normalizedRulesHash(equivalent), normalizedRulesHash(firestoreRules));
  assert.notEqual(
    normalizedRulesHash("rules_version = '2';\nservice cloud.firestore { match /x/{id} {} }\n"),
    normalizedRulesHash(firestoreRules),
  );
});

test("active Firestore and every active Storage release match normalized committed content", async () => {
  const requests = [];
  const fetchJson = async (url) => {
    requests.push(url);
    if (url.includes("/releases?")) {
      const token = new URL(url).searchParams.get("pageToken");
      if (token == null) {
        return {
          releases: [{
            name: `projects/${projectId}/releases/unrelated`,
            rulesetName: `projects/${projectId}/rulesets/unrelated`,
          }],
          nextPageToken: "second-page",
        };
      }
      return {
        releases: [
          {
            name: `projects/${projectId}/releases/cloud.firestore`,
            rulesetName: `projects/${projectId}/rulesets/firestore-active`,
          },
          {
            name: `projects/${projectId}/releases/firebase.storage/${projectId}.appspot.com`,
            rulesetName: `projects/${projectId}/rulesets/storage-active`,
          },
        ],
      };
    }
    if (url.endsWith("/rulesets/firestore-active")) {
      return {
        name: `projects/${projectId}/rulesets/firestore-active`,
        source: {files: [{content: firestoreRules.replaceAll("\n", "\r\n"), name: "firestore.rules"}]},
      };
    }
    if (url.endsWith("/rulesets/storage-active")) {
      return {
        name: `projects/${projectId}/rulesets/storage-active`,
        source: {files: [{content: `${storageRules.trimEnd()}  \n\n`, name: "storage.rules"}]},
      };
    }
    throw new Error(`Unexpected URL: ${url}`);
  };

  const report = await checkRulesDeploymentDrift({
    accessToken: "test-token",
    fetchJson,
    projectId,
    targets: [
      {content: firestoreRules, database: "(default)", kind: "firestore", localPath: "firestore.rules"},
      {content: storageRules, kind: "storage", localPath: "storage.rules"},
    ],
  });

  assert.equal(report.status, "match");
  assert.equal(report.drift, false);
  assert.deepEqual(report.results.map((result) => result.status), ["match", "match"]);
  assert.equal(requests.filter((url) => url.includes("/releases?")).length, 2);
});

test("semantic source changes and missing active releases fail closed", async () => {
  const report = await checkRulesDeploymentDrift({
    accessToken: "test-token",
    fetchJson: async (url) => {
      if (url.includes("/releases?")) {
        return {releases: [{
          name: `projects/${projectId}/releases/cloud.firestore`,
          rulesetName: `projects/${projectId}/rulesets/firestore-old`,
        }]};
      }
      return {
        name: `projects/${projectId}/rulesets/firestore-old`,
        source: {files: [{content: "rules_version = '2';\nservice cloud.firestore { match /old/{id} {} }\n", name: "firestore.rules"}]},
      };
    },
    projectId,
    targets: [
      {content: firestoreRules, database: "(default)", kind: "firestore", localPath: "firestore.rules"},
      {content: storageRules, kind: "storage", localPath: "storage.rules"},
    ],
  });

  assert.equal(report.status, "drift");
  assert.deepEqual(report.results.map((result) => result.status), [
    "drift",
    "missing-release",
  ]);
});

test("missing credentials skip clearly without touching the Rules API", async () => {
  let fetchCalls = 0;
  const execution = await executeRulesDeploymentDriftCli(
    ["--project", projectId],
    {
      credentials: null,
      fetchJson: async () => {
        fetchCalls += 1;
        return {};
      },
      repoRoot: "/unused",
    },
  );

  assert.equal(execution.exitCode, 0);
  assert.equal(execution.report.status, "skipped");
  assert.match(execution.output, /^SKIP Firebase rules deployment drift:/u);
  assert.equal(fetchCalls, 0);
});

test("credential resolution prefers explicit tokens and treats unavailable gcloud as no credentials", () => {
  let calls = 0;
  assert.deepEqual(
    resolveRulesAccessToken({
      environment: {FIREBASE_RULES_ACCESS_TOKEN: " explicit-token "},
      runCommand: () => {
        calls += 1;
        return {status: 1, stderr: "should not run", stdout: ""};
      },
    }),
    {source: "FIREBASE_RULES_ACCESS_TOKEN", token: "explicit-token"},
  );
  assert.equal(calls, 0);
  assert.equal(
    resolveRulesAccessToken({
      environment: {},
      runCommand: () => ({status: 1, stderr: "not logged in", stdout: ""}),
    }),
    null,
  );
});

test("user credentials without a quota project retry once against the inspected project", async () => {
  const calls = [];
  const response = (status, payload) => ({
    ok: status === 200,
    status,
    text: async () => JSON.stringify(payload),
  });
  const fetchImpl = async (url, init) => {
    calls.push(init.headers["x-goog-user-project"] ?? null);
    return calls.length === 1 ?
      response(403, {error: {message: "The firebaserules.googleapis.com API requires a quota project, which is not set by default."}}) :
      response(200, {releases: []});
  };
  const url = `https://firebaserules.googleapis.com/v1/projects/${projectId}/releases`;
  assert.deepEqual(await fetchRulesApiJson(url, "token", {fetchImpl}), {releases: []});
  assert.deepEqual(calls, [null, projectId]);

  calls.length = 0;
  const denied = async (_url, init) => {
    calls.push(init.headers["x-goog-user-project"] ?? null);
    return response(403, {error: {message: "Permission denied"}});
  };
  await assert.rejects(fetchRulesApiJson(url, "token", {fetchImpl: denied}), /Permission denied/u);
  assert.deepEqual(calls, [null]);
});
