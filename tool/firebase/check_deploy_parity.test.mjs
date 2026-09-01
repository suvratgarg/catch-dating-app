import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  buildFunctionsListCommand,
  buildSecretsListCommand,
  compareDeployParity,
  loadRepositoryInventory,
  parseArgs,
  parseDeployedFunctionNames,
  parseLiveSecretNames,
  runDeployParity,
} from "./check_deploy_parity.mjs";

test("fails when a repo export is absent while ignoring deployed extension extras", () => {
  const report = compareDeployParity({
    repoFunctionNames: new Set(["presentCallable", "missingTrigger"]),
    deployedFunctionNames: new Set([
      "presentCallable",
      "ext-bq-example-syncBigQuery",
    ]),
    declaredSecretNames: new Set(),
    liveSecretNames: new Set(),
  });

  assert.equal(report.ok, false);
  assert.deepEqual(report.missingFunctions, ["missingTrigger"]);
  assert.equal(report.environmentOnlyFunctionCount, 1);
});

test("fails when a declared defineSecret name is absent from the target project", () => {
  const report = compareDeployParity({
    repoFunctionNames: new Set(["callable"]),
    deployedFunctionNames: new Set(["callable"]),
    declaredSecretNames: new Set(["PRESENT_SECRET", "MISSING_SECRET"]),
    liveSecretNames: new Set(["PRESENT_SECRET"]),
  });

  assert.equal(report.ok, false);
  assert.deepEqual(report.missingSecrets, ["MISSING_SECRET"]);
});

test("live inventory commands are metadata-only and project-bound", () => {
  assert.deepEqual(buildFunctionsListCommand("catchdates-prod"), {
    command: "firebase",
    args: ["functions:list", "--project", "catchdates-prod", "--json"],
  });
  assert.deepEqual(buildSecretsListCommand("catchdates-prod"), {
    command: "gcloud",
    args: [
      "secrets",
      "list",
      "--project=catchdates-prod",
      "--format=json(name)",
      "--quiet",
    ],
  });
  assert.equal(
    buildSecretsListCommand("catchdates-prod").args.includes("versions"),
    false,
  );
});

test("parses Firebase and Secret Manager inventories without reading payloads", () => {
  assert.deepEqual(
    [...parseDeployedFunctionNames(JSON.stringify({
      status: "success",
      result: [
        {id: "callable", callableTrigger: {}},
        {id: "trigger", eventTrigger: {}},
      ],
    }))],
    ["callable", "trigger"],
  );
  assert.deepEqual(
    [...parseLiveSecretNames(JSON.stringify([
      {name: "projects/123/secrets/FIRST_SECRET"},
      {name: "projects/123/secrets/SECOND_SECRET"},
    ]))],
    ["FIRST_SECRET", "SECOND_SECRET"],
  );
});

test("environment aliases are required and direct project overrides are rejected", () => {
  assert.equal(parseArgs(["--env", "prod"]).environment, "prod");
  assert.throws(
    () => parseArgs(["--project", "catch-dating-app-64e51"]),
    (error) => error.exitCode === 64,
  );
  assert.throws(
    () => parseArgs([]),
    (error) => error.exitCode === 64,
  );
});

test("live metadata failures fail closed instead of reporting parity", () => {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "deploy-parity-"));
  fs.mkdirSync(path.join(repoRoot, "functions/src"), {recursive: true});
  fs.writeFileSync(
    path.join(repoRoot, ".firebaserc"),
    JSON.stringify({projects: {prod: "catchdates-prod"}}),
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    'export {callable} from "./callable";\n',
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/callable.ts"),
    'const secret = defineSecret("EXAMPLE_SECRET");\n',
  );

  assert.throws(
    () => runDeployParity({
      environment: "prod",
      repoRoot,
      runCommand: ({command}) => command === "firebase" ? {
        status: 1,
        stdout: "",
        stderr: "authentication required\n",
      } : {
        status: 0,
        stdout: "[]",
        stderr: "",
      },
    }),
    (error) => error.exitCode === 2 &&
      /authentication required/u.test(error.message),
  );
});

test("Functions deployment checks live parity against the exact source checkout", () => {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "deploy-parity-"));
  fs.mkdirSync(path.join(repoRoot, "functions/src"), {recursive: true});
  fs.writeFileSync(
    path.join(repoRoot, ".firebaserc"),
    JSON.stringify({projects: {prod: "catchdates-prod"}}),
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    'export {sourceCheckoutCallable} from "./callable";\n',
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/callable.ts"),
    "export const sourceCheckoutCallable = true;\n",
  );

  const report = runDeployParity({
    environment: "prod",
    repoRoot,
    runCommand: ({command}) => command === "firebase" ? {
      status: 0,
      stdout: JSON.stringify({
        status: "success",
        result: [{id: "sourceCheckoutCallable", callableTrigger: {}}],
      }),
      stderr: "",
    } : {
      status: 0,
      stdout: "[]",
      stderr: "",
    },
  });

  assert.equal(report.ok, true);
  assert.equal(report.repoFunctionCount, 1);
  assert.equal(report.projectId, "catchdates-prod");
});

test("repository parity excludes source-exported dormant scheduled Functions", () => {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "deploy-parity-"));
  fs.mkdirSync(path.join(repoRoot, "functions/src"), {recursive: true});
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    [
      'export {callable} from "./callable";',
      'export {sendEventReminders} from "./sendEventReminders";',
      "",
    ].join("\n"),
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/callable.ts"),
    "export const callable = true;\n",
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/sendEventReminders.ts"),
    "export const sendEventReminders = true;\n",
  );

  const inventory = loadRepositoryInventory(repoRoot);
  assert.deepEqual([...inventory.functionNames], ["callable"]);
});
