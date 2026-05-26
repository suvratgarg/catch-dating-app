import assert from "node:assert/strict";
import test from "node:test";
import {
  applyProfileDecisionRetirement,
  buildProfileDecisionRetirementPlan,
} from "./retire_legacy_profile_decisions.mjs";

test("buildProfileDecisionRetirementPlan allows delete when legacy docs match",
  () => {
    const retirement = buildProfileDecisionRetirementPlan({
      current: {
        decisions: [{
          ownerId: "user-a",
          targetId: "user-b",
          path: "swipes/user-a/outgoing/user-b",
        }],
      },
      missingFuture: [],
      staleFuture: [],
      validationErrors: [],
      summary: {
        currentStoragePath: "swipes/{userId}/outgoing/{targetId}",
        candidatePrimaryStoragePath: "profileDecisions/{userId}/outgoing/{targetId}",
        currentDecisionCount: 1,
        futureDecisionCount: 2,
        missingFutureCount: 0,
        staleFutureCount: 0,
        extraFutureCount: 1,
        validationErrorCount: 0,
      },
    });

    assert.equal(retirement.summary.safeToDeleteLegacy, true);
    assert.equal(retirement.summary.deletesNeeded, 1);
    assert.deepEqual(retirement.deleteDocs, [{
      path: "swipes/user-a/outgoing/user-b",
      key: "user-a/user-b",
    }]);
  }
);

test("buildProfileDecisionRetirementPlan blocks delete on parity drift", () => {
  const retirement = buildProfileDecisionRetirementPlan({
    current: {decisions: []},
    missingFuture: [{key: "user-a/user-b"}],
    staleFuture: [],
    validationErrors: [],
    summary: {
      currentStoragePath: "swipes/{userId}/outgoing/{targetId}",
      candidatePrimaryStoragePath: "profileDecisions/{userId}/outgoing/{targetId}",
      currentDecisionCount: 1,
      futureDecisionCount: 0,
      missingFutureCount: 1,
      staleFutureCount: 0,
      extraFutureCount: 0,
      validationErrorCount: 0,
    },
  });

  assert.equal(retirement.summary.safeToDeleteLegacy, false);
});

test("applyProfileDecisionRetirement deletes legacy docs", async () => {
  const firestore = fakeFirestore({
    "swipes/user-a/outgoing/user-b": {swiperId: "user-a"},
  });
  await applyProfileDecisionRetirement(firestore, {
    deleteDocs: [{path: "swipes/user-a/outgoing/user-b"}],
  });

  assert.equal(firestore.get("swipes/user-a/outgoing/user-b"), undefined);
});

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    doc: (path) => ({path}),
    batch: () => {
      const writes = [];
      return {
        delete: (ref) => writes.push(() => {
          delete data[ref.path];
        }),
        commit: async () => writes.forEach((write) => write()),
      };
    },
    get: (path) => data[path],
  };
}
