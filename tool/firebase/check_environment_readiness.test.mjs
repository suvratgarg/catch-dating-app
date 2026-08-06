import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {
  assertMetadataOnlyCommand,
  buildProjectIdentityCommand,
  buildRequirementCommand,
  classifyProjectIdentity,
  classifyRequirementResult,
  discoverDefineSecretNames,
  executeReadinessCli,
  exitCodeForResults,
  parseArgs,
  parseFirebaseProjectAliases,
  resolveFirebaseProjectId,
  runEnvironmentReadiness,
  selectReadinessRequirements,
  validateEnvironmentReadinessManifest,
} from "./check_environment_readiness.mjs";

const testDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(testDir, "../..");
const manifest = JSON.parse(fs.readFileSync(
  path.join(testDir, "environment_readiness.json"),
  "utf8",
));
const aliases = parseFirebaseProjectAliases(fs.readFileSync(
  path.join(repoRoot, ".firebaserc"),
  "utf8",
));

test("checked manifest validates offline without invoking gcloud", () => {
  let commandCalls = 0;
  const execution = executeReadinessCli(
    ["--manifest-only", "--json"],
    {
      repoRoot,
      runCommand: () => {
        commandCalls += 1;
        throw new Error("manifest-only must stay offline");
      },
    },
  );

  assert.equal(execution.exitCode, 0);
  assert.equal(execution.report.secretCount, 10);
  assert.equal(execution.report.requirementCount, 11);
  assert.equal(commandCalls, 0);
});

test("manifest completeness catches missing and dynamic defineSecret declarations", () => {
  const discoveries = discoverDefineSecretNames([
    {
      contents: `
        const first = defineSecret(
          "FIRST_SECRET"
        );
        const second = defineSecret(secretName);
      `,
      path: "functions/src/example.ts",
    },
  ]);
  assert.deepEqual([...discoveries.names], ["FIRST_SECRET"]);
  assert.deepEqual(discoveries.unsupported, ["functions/src/example.ts"]);

  const reduced = structuredClone(manifest);
  reduced.requirements = reduced.requirements.filter(
    (entry) => entry.name !== "ALGOLIA_APP_ID",
  );
  assert.throws(
    () => executeReadinessCli(["--manifest-only"], {manifest: reduced, repoRoot}),
    (error) => error.exitCode === 64 &&
      /defineSecret is missing from the manifest: ALGOLIA_APP_ID/u.test(
        error.message,
      ),
  );
});

test("usage is explicit and unsafe project/apply overrides are rejected", () => {
  for (const argv of [
    ["--project", "wrong-project", "--targets", "functions"],
    ["--env", "dev", "--targets", "functions", "--apply"],
    ["--env", "dev"],
    ["--all", "--env", "dev", "--targets", "functions"],
  ]) {
    assert.throws(
      () => parseArgs(argv),
      (error) => error.exitCode === 64,
    );
  }

  assert.deepEqual(
    parseArgs([
      "--env",
      "dev",
      "--targets",
      "functions:exploreSearch,storage",
      "--capabilities",
      "cross-paths",
    ]),
    {
      all: false,
      capabilities: ["cross-paths"],
      environment: "dev",
      help: false,
      json: false,
      manifestOnly: false,
      targets: ["functions:exploreSearch", "storage"],
    },
  );
});

test("Firebase environments resolve only through .firebaserc aliases", () => {
  assert.equal(
    resolveFirebaseProjectId({environment: "dev", aliases}),
    "catchdates-dev",
  );
  assert.equal(
    resolveFirebaseProjectId({environment: "staging", aliases}),
    "catchdates-staging",
  );
  assert.equal(
    resolveFirebaseProjectId({environment: "prod", aliases}),
    "catch-dating-app-64e51",
  );
  assert.throws(
    () => resolveFirebaseProjectId({environment: "preview", aliases}),
    (error) => error.exitCode === 64,
  );
});

test("target and capability filtering selects only relevant prerequisites", () => {
  const selected = (environment, targets, capabilities = []) =>
    selectReadinessRequirements({
      capabilities,
      environment,
      manifest,
      targets,
    });

  assert.deepEqual(
    selected("dev", ["functions:exploreSearch"]).map((entry) => entry.name),
    ["ALGOLIA_APP_ID", "ALGOLIA_SEARCH_API_KEY"],
  );
  assert.equal(
    selected("dev", ["functions"]).filter(
      (entry) => entry.kind === "secret-version",
    ).length,
    10,
  );
  assert.deepEqual(
    selected("dev", ["functions:getCrossPathsSuggestions"])
      .map((entry) => entry.name),
    ["CROSS_PATHS_SUGGESTION_SIGNING_KEY"],
  );
  assert.deepEqual(
    selected("dev", [], ["cross-paths"]).map((entry) => entry.id),
    ["firestore.ttl.cross-paths-suggestion-exposures"],
  );
  assert.deepEqual(selected("dev", ["hosting"]), []);
});

test("gcloud command construction is metadata-only and forbids secret access", () => {
  const secret = manifest.requirements.find(
    (entry) => entry.name === "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  );
  const ttl = manifest.requirements.find(
    (entry) => entry.kind === "firestore-ttl",
  );
  const commands = [
    buildProjectIdentityCommand("catchdates-dev"),
    buildRequirementCommand({projectId: "catchdates-dev", requirement: secret}),
    buildRequirementCommand({projectId: "catchdates-dev", requirement: ttl}),
  ];

  assert.deepEqual(commands[1].args.slice(0, 4), [
    "secrets",
    "versions",
    "list",
    "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  ]);
  assert.ok(commands[1].args.includes("--filter=state=ENABLED"));
  assert.ok(commands[1].args.includes("--project=catchdates-dev"));
  assert.deepEqual(commands[2].args.slice(0, 4), [
    "firestore",
    "fields",
    "ttls",
    "list",
  ]);
  assert.ok(commands[2].args.includes(
    "--collection-group=crossPathsSuggestionExposures",
  ));
  for (const command of commands) {
    assert.doesNotMatch(command.args.join(" "), /secrets versions access/iu);
  }
  assert.throws(
    () => assertMetadataOnlyCommand({
      args: ["secrets", "versions", "access", "latest"],
      command: "gcloud",
    }),
    /Secret payload access is forbidden/u,
  );
});

test("secret metadata classification never returns payload fields", () => {
  const requirement = manifest.requirements.find(
    (entry) => entry.name === "CROSS_PATHS_SUGGESTION_SIGNING_KEY",
  );
  const ready = classifyRequirementResult({
    requirement,
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify([{
        createTime: "2026-08-06T00:00:00Z",
        name: "projects/demo/secrets/key/versions/7",
        payload: "must-never-escape",
        state: "ENABLED",
      }]),
    },
  });
  assert.equal(ready.status, "ready");
  assert.equal(ready.metadata.versionId, "7");
  assert.doesNotMatch(JSON.stringify(ready), /must-never-escape/u);

  const absent = classifyRequirementResult({
    requirement,
    result: {status: 0, stderr: "", stdout: "[]"},
  });
  assert.equal(absent.status, "not-ready");
  assert.equal(absent.reason, "no-enabled-version");

  const missing = classifyRequirementResult({
    requirement,
    result: {status: 1, stderr: "NOT_FOUND", stdout: ""},
  });
  assert.equal(missing.status, "not-ready");
  assert.equal(missing.reason, "resource-not-found");

  const denied = classifyRequirementResult({
    requirement,
    result: {status: 1, stderr: "PERMISSION_DENIED", stdout: ""},
  });
  assert.equal(denied.status, "unknown");
  assert.equal(denied.reason, "permission-denied");
});

test("TTL metadata distinguishes ACTIVE, missing, and transitional policies", () => {
  const requirement = manifest.requirements.find(
    (entry) => entry.kind === "firestore-ttl",
  );
  const classifyState = (state) => classifyRequirementResult({
    requirement,
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify([{
        name: "projects/demo/databases/(default)/collectionGroups/" +
          "crossPathsSuggestionExposures/fields/expiresAt",
        ttlConfig: {state},
      }]),
    },
  });

  assert.equal(classifyState("ACTIVE").status, "ready");
  assert.equal(classifyState("CREATING").status, "not-ready");
  assert.equal(classifyState("NEEDS_REPAIR").status, "not-ready");
  assert.equal(
    classifyRequirementResult({
      requirement,
      result: {status: 0, stderr: "", stdout: "[]"},
    }).reason,
    "ttl-policy-missing",
  );
});

test("result aggregation preserves confirmed-not-ready versus unknown exits", () => {
  assert.equal(exitCodeForResults([{status: "ready"}]), 0);
  assert.equal(exitCodeForResults([
    {status: "ready"},
    {status: "unknown"},
  ]), 2);
  assert.equal(exitCodeForResults([
    {status: "unknown"},
    {status: "not-ready"},
  ]), 1);
});

test("injected runner receives resolved project and returns a known-missing exit", () => {
  const commands = [];
  const report = runEnvironmentReadiness({
    aliases,
    capabilities: ["cross-paths"],
    environments: ["staging"],
    manifest,
    runCommand: (spec) => {
      commands.push(spec);
      if (spec.args[0] === "projects") {
        return {
          status: 0,
          stderr: "",
          stdout: JSON.stringify({
            lifecycleState: "ACTIVE",
            projectId: "catchdates-staging",
            projectNumber: "123",
          }),
        };
      }
      if (spec.args[0] === "secrets") {
        return {status: 0, stderr: "", stdout: "[]"};
      }
      return {
        status: 0,
        stderr: "",
        stdout: JSON.stringify([{
          name: "projects/demo/databases/(default)/collectionGroups/" +
            "crossPathsSuggestionExposures/fields/expiresAt",
          ttlConfig: {state: "ACTIVE"},
        }]),
      };
    },
    targets: ["functions:getCrossPathsSuggestions"],
  });

  assert.equal(report.exitCode, 1);
  assert.equal(report.status, "not-ready");
  assert.equal(commands.length, 3);
  assert.ok(commands.slice(1).every((spec) =>
    spec.args.includes("--project=catchdates-staging")));
  assert.ok(commands.every((spec) =>
    !spec.args.join(" ").includes("secrets versions access")));
});

test("live CLI distinguishes ready from indeterminate metadata", () => {
  const readyExecution = executeReadinessCli(
    [
      "--env",
      "staging",
      "--targets",
      "functions:exploreSearch",
      "--json",
    ],
    {
      repoRoot,
      runCommand: readyMetadataRunner,
    },
  );
  assert.equal(readyExecution.exitCode, 0);
  assert.equal(readyExecution.report.environments[0].projectId,
    "catchdates-staging");

  const unknownExecution = executeReadinessCli(
    ["--env", "dev", "--targets", "functions:exploreSearch"],
    {
      repoRoot,
      runCommand: (spec) => {
        if (spec.args[0] === "projects") {
          return readyProjectMetadata(spec.args[2]);
        }
        return {status: 1, stderr: "PERMISSION_DENIED", stdout: ""};
      },
    },
  );
  assert.equal(unknownExecution.exitCode, 2);
  assert.equal(unknownExecution.report.status, "unknown");
});

test("project identity mismatch is confirmed not-ready", () => {
  const result = classifyProjectIdentity({
    projectId: "catchdates-dev",
    result: {
      status: 0,
      stderr: "",
      stdout: JSON.stringify({
        lifecycleState: "ACTIVE",
        projectId: "catchdates-staging",
        projectNumber: "123",
      }),
    },
  });
  assert.equal(result.status, "not-ready");
  assert.equal(result.metadata.projectIdMatches, false);
});

test("minimal manifest validation rejects duplicate ids", () => {
  const duplicate = structuredClone(manifest);
  duplicate.requirements.push(structuredClone(duplicate.requirements[0]));
  assert.throws(
    () => validateEnvironmentReadinessManifest(duplicate),
    (error) => error.exitCode === 64 && /duplicate id/u.test(error.message),
  );
});

function readyMetadataRunner(spec) {
  if (spec.args[0] === "projects") {
    return readyProjectMetadata(spec.args[2]);
  }
  return {
    status: 0,
    stderr: "",
    stdout: JSON.stringify([{
      createTime: "2026-08-06T00:00:00Z",
      name: "projects/demo/secrets/key/versions/1",
      state: "ENABLED",
    }]),
  };
}

function readyProjectMetadata(projectId) {
  return {
    status: 0,
    stderr: "",
    stdout: JSON.stringify({
      lifecycleState: "ACTIVE",
      projectId,
      projectNumber: "123",
    }),
  };
}
