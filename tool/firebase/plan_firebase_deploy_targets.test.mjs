import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  planFirebaseDeployGroups,
  planFirebaseDeployTargets,
} from "./plan_firebase_deploy_targets.mjs";

const exportsList = [
  "functions:createEvent",
  "functions:sendEventBroadcast",
  "functions:startClubHostConversation",
];

const cliPath = fileURLToPath(
  new URL("./plan_firebase_deploy_targets.mjs", import.meta.url),
);

test("CLI accepts the first positional target and keeps group mode distinct", () => {
  const direct = spawnSync(
    process.execPath,
    [cliPath, "functions:createEvent", "--json"],
    {encoding: "utf8"},
  );
  assert.equal(direct.status, 0, direct.stderr);
  assert.deepEqual(JSON.parse(direct.stdout), [
    {phase: "functions", deployOnly: "functions:createEvent"},
  ]);

  const grouped = spawnSync(
    process.execPath,
    [cliPath, "--groups", "firestore-rules", "--json"],
    {encoding: "utf8"},
  );
  assert.equal(grouped.status, 0, grouped.stderr);
  assert.deepEqual(JSON.parse(grouped.stdout), [
    {phase: "firestore:rules", deployOnly: "firestore:rules"},
  ]);
});

test("current planner reads an older source export file without executing its tooling", (t) => {
  const sourceRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-firebase-source-"));
  t.after(() => fs.rmSync(sourceRoot, {recursive: true, force: true}));
  fs.mkdirSync(path.join(sourceRoot, "functions/src"), {recursive: true});
  fs.mkdirSync(path.join(sourceRoot, "tool/firebase"), {recursive: true});
  fs.writeFileSync(
    path.join(sourceRoot, "functions/src/index.ts"),
    'export { historicalOnly } from "./historical";\n',
  );
  fs.writeFileSync(
    path.join(sourceRoot, "tool/firebase/list_firebase_function_targets.mjs"),
    'throw new Error("historical tooling must not execute");\n',
  );

  const result = spawnSync(process.execPath, [cliPath, "functions", "--json"], {
    encoding: "utf8",
    env: {...process.env, CATCH_FIREBASE_SOURCE_ROOT: sourceRoot},
  });
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), [
    {phase: "functions", deployOnly: "functions:historicalOnly"},
  ]);
});

test("indexes always precede Functions and rules", () => {
  assert.deepEqual(
    planFirebaseDeployTargets(
      "functions:sendEventBroadcast,firestore:indexes,firestore:rules",
      {functionTargets: exportsList},
    ),
    [
      {phase: "firestore:indexes", deployOnly: "firestore:indexes"},
      {phase: "functions", deployOnly: "functions:sendEventBroadcast"},
      {phase: "firestore:rules", deployOnly: "firestore:rules"},
    ],
  );
});

test("logical functions expands all source exports", () => {
  const [plan] = planFirebaseDeployTargets("functions", {
    functionTargets: exportsList,
  });
  assert.equal(plan.phase, "functions");
  assert.match(plan.deployOnly, /functions:sendEventBroadcast/);
  assert.equal(plan.deployOnly.split(",").length, 3);
});

test("deduplicates whitespace and exact targets", () => {
  assert.deepEqual(
    planFirebaseDeployTargets(
      " functions:sendEventBroadcast, functions:sendEventBroadcast ",
      {functionTargets: exportsList},
    ),
    [{phase: "functions", deployOnly: "functions:sendEventBroadcast"}],
  );
});

test("CI deploy groups expand only explicit bounded backend products", () => {
  assert.deepEqual(
    planFirebaseDeployGroups(
      ["functions", "firestore-indexes", "firestore-rules", "storage-rules"],
      {functionTargets: exportsList},
    ).map((plan) => plan.phase),
    ["firestore:indexes", "functions", "firestore:rules", "storage"],
  );
});

test("rejects validation-only, broad, hosting, remote config, extensions, and unknown groups", () => {
  for (const targets of [
    "all",
    "hosting",
    "remoteconfig",
    "extensions:demo",
    "functions,hosting",
  ]) {
    assert.throws(
      () => planFirebaseDeployTargets(targets, {functionTargets: exportsList}),
      /not allowed/,
    );
  }
  assert.throws(
    () => planFirebaseDeployGroups(["remoteconfig"], {
      functionTargets: exportsList,
    }),
    /deploy group is not allowed/,
  );
  for (const group of ["backend-contracts", "firebase-config", "unknown"]) {
    assert.throws(
      () => planFirebaseDeployGroups([group], {functionTargets: exportsList}),
      /deploy group is not allowed/,
    );
  }
});

test("rejects empty, malformed, and control-character targets", () => {
  for (const targets of ["", " , ", "functions:", "storage\nfirestore"]) {
    assert.throws(
      () => planFirebaseDeployTargets(targets, {functionTargets: exportsList}),
      /No Firebase deploy targets|Invalid Firebase deploy target|not allowed/,
    );
  }
});

test("release guidance routes Remote Config outside the bounded backend helper", () => {
  const releaseGuide = fs.readFileSync(
    new URL("../../docs/release_operations.md", import.meta.url),
    "utf8",
  );
  assert.doesNotMatch(
    releaseGuide,
    /deploy_firebase_targets\.sh[^\n]*remoteconfig/u,
  );
  assert.match(
    releaseGuide,
    /firebase_with_env\.sh[^\n]*deploy --only remoteconfig/u,
  );
});
