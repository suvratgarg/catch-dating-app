import assert from "node:assert/strict";
import fs from "node:fs";
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
