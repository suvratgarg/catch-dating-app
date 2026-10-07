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
  parseSelectedFunctionTargets,
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
  assert.equal(report.parityScope, "full");
  assert.equal(report.checkedFunctionCount, 2);
});

test("selected parity ignores absent unselected exports without weakening full parity", () => {
  const input = {
    repoFunctionNames: new Set(["selectedCallable", "unselectedTrigger"]),
    deployedFunctionNames: new Set(["selectedCallable"]),
    declaredSecretNames: new Set(["REQUIRED_SECRET"]),
    liveSecretNames: new Set(["REQUIRED_SECRET"]),
  };

  const selected = compareDeployParity({
    ...input,
    selectedFunctionNames: new Set(["selectedCallable"]),
  });
  const full = compareDeployParity(input);

  assert.equal(selected.ok, true);
  assert.equal(selected.parityScope, "selected");
  assert.equal(selected.checkedFunctionCount, 1);
  assert.deepEqual(selected.missingFunctions, []);
  const missingSecret = compareDeployParity({
    ...input,
    liveSecretNames: new Set(),
    selectedFunctionNames: new Set(["selectedCallable"]),
  });
  assert.equal(missingSecret.ok, false);
  assert.deepEqual(missingSecret.missingSecrets, ["REQUIRED_SECRET"]);
  assert.equal(full.ok, false);
  assert.deepEqual(full.missingFunctions, ["unselectedTrigger"]);
});

test("selected parity fails closed for a missing or ineligible selected export", () => {
  const input = {
    repoFunctionNames: new Set(["selectedCallable", "unselectedTrigger"]),
    deployedFunctionNames: new Set(["unselectedTrigger"]),
    declaredSecretNames: new Set(),
    liveSecretNames: new Set(),
  };

  const missing = compareDeployParity({
    ...input,
    selectedFunctionNames: new Set(["selectedCallable"]),
  });
  assert.equal(missing.ok, false);
  assert.deepEqual(missing.missingFunctions, ["selectedCallable"]);
  assert.throws(
    () => compareDeployParity({
      ...input,
      selectedFunctionNames: new Set(["notInSource"]),
    }),
    /not deployment-eligible source exports/u,
  );
  for (const selectedFunctionNames of [new Set(), []]) {
    assert.throws(
      () => compareDeployParity({...input, selectedFunctionNames}),
      /non-empty Set/u,
    );
  }
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
  assert.deepEqual(
    parseArgs([
      "--env", "prod", "--targets", "functions:first,functions:second",
    ]).selectedFunctionTargets,
    ["functions:first", "functions:second"],
  );
  assert.deepEqual(
    parseSelectedFunctionTargets("functions:first,functions:second"),
    ["functions:first", "functions:second"],
  );
  for (const targets of [
    "functions", "functions:", "functions:first,", "firestore:rules",
    "functions:first,functions:first", "functions:first\nfunctions:second",
  ]) {
    assert.throws(() => parseSelectedFunctionTargets(targets));
  }
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

test("runDeployParity binds selected parity to deployment-eligible source", () => {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "deploy-parity-"));
  fs.mkdirSync(path.join(repoRoot, "functions/src"), {recursive: true});
  fs.writeFileSync(
    path.join(repoRoot, ".firebaserc"),
    JSON.stringify({projects: {prod: "catchdates-prod"}}),
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    'export {selectedCallable, unselectedTrigger} from "./callable";\n',
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/callable.ts"),
    "export const selectedCallable = true;\n" +
      "export const unselectedTrigger = true;\n",
  );
  const runCommand = ({command}) => command === "firebase" ? {
    status: 0,
    stdout: JSON.stringify({
      status: "success",
      result: [{id: "selectedCallable", callableTrigger: {}}],
    }),
    stderr: "",
  } : {
    status: 0,
    stdout: "[]",
    stderr: "",
  };

  const selected = runDeployParity({
    environment: "prod",
    repoRoot,
    runCommand,
    selectedFunctionTargets: ["functions:selectedCallable"],
  });
  const full = runDeployParity({environment: "prod", repoRoot, runCommand});

  assert.equal(selected.ok, true);
  assert.equal(selected.repoFunctionCount, 2);
  assert.equal(selected.checkedFunctionCount, 1);
  assert.equal(full.ok, false);
  assert.deepEqual(full.missingFunctions, ["unselectedTrigger"]);
  assert.throws(() => runDeployParity({
    environment: "prod",
    repoRoot,
    runCommand,
    selectedFunctionTargets: ["functions:notInSource"],
  }), /not deployment-eligible source exports/u);
});

test("repository parity excludes source-exported dormant scheduled Functions", () => {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "deploy-parity-"));
  fs.mkdirSync(path.join(repoRoot, "functions/src"), {recursive: true});
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    [
      'export {callable} from "./callable";',
      'export {expireEventWaitlistOffers} from "./expireEventWaitlistOffers";',
      "",
    ].join("\n"),
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/callable.ts"),
    "export const callable = true;\n",
  );
  fs.writeFileSync(
    path.join(repoRoot, "functions/src/expireEventWaitlistOffers.ts"),
    "export const expireEventWaitlistOffers = true;\n",
  );

  const inventory = loadRepositoryInventory(repoRoot);
  assert.deepEqual([...inventory.functionNames], ["callable"]);
});
