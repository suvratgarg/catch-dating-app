import assert from "node:assert/strict";
import test from "node:test";
import {planFirebaseDeployTargets} from "./plan_firebase_deploy_targets.mjs";

const exportsList = [
  "functions:createEvent",
  "functions:sendEventBroadcast",
  "functions:startClubHostConversation",
];

test("exact Functions deploy before indexes and rules", () => {
  assert.deepEqual(
    planFirebaseDeployTargets(
      "functions:sendEventBroadcast,firestore:indexes,firestore:rules",
      {functionTargets: exportsList},
    ),
    [
      {phase: "functions", deployOnly: "functions:sendEventBroadcast"},
      {phase: "firestore:indexes", deployOnly: "firestore:indexes"},
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

test("all keeps the documented safe order", () => {
  assert.deepEqual(
    planFirebaseDeployTargets("all", {functionTargets: exportsList})
      .map((plan) => plan.phase),
    ["functions", "firestore:indexes", "firestore:rules", "storage", "hosting"],
  );
});

test("arbitrary extras remain last", () => {
  assert.deepEqual(
    planFirebaseDeployTargets("hosting,extensions:demo", {
      functionTargets: exportsList,
    }),
    [
      {phase: "hosting", deployOnly: "hosting"},
      {phase: "extra", deployOnly: "extensions:demo"},
    ],
  );
});

test("rejects empty, malformed, and control-character targets", () => {
  for (const targets of ["", " , ", "functions:", "hosting\nfirestore"]) {
    assert.throws(
      () => planFirebaseDeployTargets(targets, {functionTargets: exportsList}),
      /No Firebase deploy targets|Invalid Firebase deploy target/,
    );
  }
});
