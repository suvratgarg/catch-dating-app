import assert from "node:assert/strict";
import test from "node:test";
import {
  applyRunAggregateRepairPlan,
  buildRunAggregateRepairPlan,
} from "./recompute_run_aggregate_counts.mjs";

test("buildRunAggregateRepairPlan counts active run participation edges", async () => {
  const firestore = fakeFirestore({
    runs: {
      "run-1": {bookedCount: 0, checkedInCount: 0, waitlistedCount: 0},
      "run-2": {bookedCount: 9, checkedInCount: 9, waitlistedCount: 9},
    },
    runParticipations: {
      "run-1_a": {
        runId: "run-1",
        status: "signedUp",
        genderAtSignup: "man",
      },
      "run-1_b": {
        runId: "run-1",
        status: "attended",
        genderAtSignup: "woman",
      },
      "run-1_c": {runId: "run-1", status: "waitlisted"},
      "run-1_d": {runId: "run-1", status: "cancelled"},
      "missing_a": {runId: "missing", status: "signedUp"},
    },
  });

  const plan = await buildRunAggregateRepairPlan(firestore);

  assert.deepEqual(plan.summary.repairs, [
    {
      path: "runs/run-1",
      runId: "run-1",
      current: {
        bookedCount: 0,
        checkedInCount: 0,
        waitlistedCount: 0,
        genderCounts: {},
      },
      expected: {
        bookedCount: 2,
        checkedInCount: 1,
        waitlistedCount: 1,
        genderCounts: {man: 1, woman: 1},
      },
    },
    {
      path: "runs/run-2",
      runId: "run-2",
      current: {
        bookedCount: 9,
        checkedInCount: 9,
        waitlistedCount: 9,
        genderCounts: {},
      },
      expected: {
        bookedCount: 0,
        checkedInCount: 0,
        waitlistedCount: 0,
        genderCounts: {},
      },
    },
  ]);
  assert.deepEqual(plan.summary.warnings, [
    "runParticipations/missing_a references missing runs/missing.",
  ]);
});

test("applyRunAggregateRepairPlan writes planned run aggregate repairs", async () => {
  const firestore = fakeFirestore({
    runs: {
      "run-1": {bookedCount: 0, meetingPoint: "Park"},
      "run-2": {bookedCount: 7},
    },
    runParticipations: {},
  });

  await applyRunAggregateRepairPlan(firestore, {
    repairs: [
      {
        path: "runs/run-1",
        expected: {
          bookedCount: 2,
          checkedInCount: 1,
          waitlistedCount: 0,
          genderCounts: {man: 2},
        },
      },
    ],
  });

  assert.deepEqual(firestore.data.runs["run-1"], {
    bookedCount: 2,
    checkedInCount: 1,
    waitlistedCount: 0,
    genderCounts: {man: 2},
    meetingPoint: "Park",
  });
  assert.equal(firestore.data.runs["run-2"].bookedCount, 7);
});

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    data,
    collection: (collectionName) => ({
      get: async () => ({
        size: Object.keys(data[collectionName] ?? {}).length,
        docs: Object.entries(data[collectionName] ?? {}).map(([id, value]) =>
          docSnapshot(collectionName, id, value)
        ),
      }),
    }),
    doc: (documentPath) => ({
      path: documentPath,
      update: (patch) => {
        const [collectionName, docId] = documentPath.split("/");
        data[collectionName][docId] = {
          ...data[collectionName][docId],
          ...patch,
        };
      },
    }),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch) => writes.push(() => ref.update(patch)),
        commit: async () => {
          for (const write of writes) write();
        },
      };
    },
  };
}

function docSnapshot(collectionName, id, value) {
  return {
    id,
    ref: {path: `${collectionName}/${id}`},
    data: () => ({...value}),
  };
}
