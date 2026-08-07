import assert from "node:assert/strict";
import test from "node:test";
import {
  gcloudIndexList,
  indexSignature,
  inspectIndexReadiness,
  runSelfTest,
  waitForIndexes,
} from "./wait_firestore_indexes_ready.mjs";

const desired = {
  indexes: [{
    collectionGroup: "events",
    queryScope: "COLLECTION",
    fields: [
      {fieldPath: "status", mode: "ASCENDING"},
      {fieldPath: "startTime", mode: "DESCENDING"},
    ],
  }],
};

const live = (state = "READY") => [{
  name: "projects/catchdates-dev/databases/(default)/collectionGroups/events/indexes/abc",
  queryScope: "COLLECTION",
  apiScope: "ANY_API",
  fields: [
    {fieldPath: "status", order: "ASCENDING"},
    {fieldPath: "startTime", order: "DESCENDING"},
    {fieldPath: "__name__", order: "DESCENDING"},
  ],
  state,
}];

test("self-test proves a desired index matches READY API metadata", () => {
  const report = runSelfTest();
  assert.equal(report.complete, true);
  assert.equal(report.ready.length, 1);
});

test("desired Firebase modes match the live API shape and implicit name field", () => {
  assert.equal(
    indexSignature(desired.indexes[0], {desired: true}),
    indexSignature(live()[0]),
  );
  const report = inspectIndexReadiness(desired, live());
  assert.equal(report.complete, true);
  assert.equal(report.ready.length, 1);
});

test("missing and building indexes remain pending while failed indexes stop", () => {
  assert.deepEqual(
    inspectIndexReadiness(desired, []).pending,
    [{collectionGroup: "events", state: "MISSING"}],
  );
  assert.equal(inspectIndexReadiness(desired, live("CREATING")).complete, false);
  assert.deepEqual(
    inspectIndexReadiness(desired, live("ERROR")).failed,
    [{collectionGroup: "events", state: "ERROR"}],
  );
});

test("waiter polls metadata until every desired index is ready", async () => {
  const responses = [live("CREATING"), live("READY")];
  let clock = 0;
  const report = await waitForIndexes({
    desiredDocument: desired,
    projectId: "catchdates-dev",
    timeoutMs: 100,
    pollMs: 10,
    listIndexes: () => responses.shift(),
    sleep: async (milliseconds) => { clock += milliseconds; },
    now: () => clock,
  });
  assert.equal(report.complete, true);
  assert.equal(clock, 10);
});

test("waiter fails closed on error, unknown state, and timeout", async () => {
  for (const state of ["ERROR", null]) {
    await assert.rejects(
      waitForIndexes({
        desiredDocument: desired,
        projectId: "catchdates-dev",
        timeoutMs: 100,
        pollMs: 10,
        listIndexes: () => live(state),
      }),
      /failed state/u,
    );
  }
  let clock = 0;
  await assert.rejects(
    waitForIndexes({
      desiredDocument: desired,
      projectId: "catchdates-dev",
      timeoutMs: 20,
      pollMs: 10,
      listIndexes: () => [],
      sleep: async (milliseconds) => { clock += milliseconds; },
      now: () => clock,
    }),
    /Timed out/u,
  );
});

test("gcloud query is metadata-only, project-bound, and quiet", () => {
  let observed;
  const result = gcloudIndexList({
    projectId: "catchdates-dev",
    spawn(command, args, options) {
      observed = {command, args, options};
      return {status: 0, stdout: "[]"};
    },
  });
  assert.deepEqual(result, []);
  assert.equal(observed.command, "gcloud");
  assert.deepEqual(observed.args.slice(0, 4), [
    "firestore",
    "indexes",
    "composite",
    "list",
  ]);
  assert.ok(observed.args.includes("--project=catchdates-dev"));
  assert.ok(observed.args.includes("--database=(default)"));
  assert.ok(observed.args.includes("--format=json"));
  assert.ok(observed.args.includes("--quiet"));
});
