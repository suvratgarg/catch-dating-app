import assert from "node:assert/strict";
import test from "node:test";
import {buildFutureRunAttendanceRepairPlan} from "./repair_future_run_attendance.mjs";

test("future attended participations are downgraded and aggregates repaired",
  async () => {
    const firestore = fakeFirestore({
      runs: {
        future: {
          startTime: fakeTimestamp("2099-05-14T03:10:00.000Z"),
          bookedCount: 1,
          checkedInCount: 1,
          waitlistedCount: 0,
          genderCounts: {man: 1},
        },
        past: {
          startTime: fakeTimestamp("2020-05-14T03:10:00.000Z"),
          bookedCount: 1,
          checkedInCount: 1,
          waitlistedCount: 0,
          genderCounts: {woman: 1},
        },
      },
      runParticipations: {
        future_runner: {
          runId: "future",
          uid: "runner",
          status: "attended",
          genderAtSignup: "man",
        },
        past_runner: {
          runId: "past",
          uid: "runner",
          status: "attended",
          genderAtSignup: "woman",
        },
      },
      swipes: {
        invalid: {
          runId: "future",
          swiperId: "runner",
          targetId: "target",
        },
        past_kept: {
          runId: "past",
          swiperId: "runner",
          targetId: "target",
        },
      },
    });

    const plan = await buildFutureRunAttendanceRepairPlan(
      firestore,
      new Date("2026-05-13T13:30:00.000Z")
    );

    assert.deepEqual(plan.participationRepairs, [
      {
        path: "runParticipations/future_runner",
        runId: "future",
        uid: "runner",
        update: {status: "signedUp", attendedAt: null},
      },
    ]);
    assert.deepEqual(plan.aggregateRepairs, [
      {
        path: "runs/future",
        runId: "future",
        current: {
          bookedCount: 1,
          checkedInCount: 1,
          waitlistedCount: 0,
          genderCounts: {man: 1},
        },
        expected: {
          bookedCount: 1,
          checkedInCount: 0,
          waitlistedCount: 0,
          genderCounts: {man: 1},
        },
      },
    ]);
    assert.deepEqual(plan.swipeDeletes, [
      {
        path: "swipes/invalid/outgoing/target",
        runId: "future",
        swiperId: "runner",
        targetId: "target",
      },
    ]);
  }
);

function fakeFirestore(initialData) {
  return {
    collection: (collectionName) => ({
      get: async () => ({
        size: Object.keys(initialData[collectionName] ?? {}).length,
        docs: Object.entries(initialData[collectionName] ?? {}).map(
          ([id, data]) => fakeDoc(collectionName, id, data)
        ),
      }),
    }),
    collectionGroup: (collectionName) => ({
      get: async () => ({
        size: collectionName === "outgoing" ?
          Object.keys(initialData.swipes ?? {}).length :
          0,
        docs: collectionName === "outgoing" ?
          Object.entries(initialData.swipes ?? {}).map(
            ([id, data]) => fakeDocAt(`swipes/${id}/outgoing/target`, id, data)
          ) :
          [],
      }),
    }),
  };
}

function fakeDoc(collectionName, id, data) {
  return fakeDocAt(`${collectionName}/${id}`, id, data);
}

function fakeDocAt(path, id, data) {
  return {
    id,
    ref: {path},
    data: () => data,
  };
}

function fakeTimestamp(iso) {
  const date = new Date(iso);
  return {
    toDate: () => date,
    toMillis: () => date.getTime(),
  };
}
