import assert from "node:assert/strict";
import test from "node:test";
import {
  applyProfileDecisionBackfill,
  buildProfileDecisionBackfillPlan,
} from "./backfill_profile_decisions.mjs";

test("buildProfileDecisionBackfillPlan copies missing and stale future docs",
  () => {
    const sourceA = {
      ownerId: "user-a",
      targetId: "user-b",
      path: "swipes/user-a/outgoing/user-b",
      data: {swiperId: "user-a", targetId: "user-b"},
    };
    const sourceB = {
      ownerId: "user-a",
      targetId: "user-c",
      path: "swipes/user-a/outgoing/user-c",
      data: {swiperId: "user-a", targetId: "user-c"},
    };
    const backfill = buildProfileDecisionBackfillPlan({
      current: {decisions: [sourceA, sourceB]},
      missingFuture: [{
        key: "user-a/user-b",
        futurePath: "profileDecisions/user-a/outgoing/user-b",
      }],
      staleFuture: [{
        key: "user-a/user-c",
        futurePath: "profileDecisions/user-a/outgoing/user-c",
      }],
      extraFuture: [{key: "user-x/user-y"}],
      validationErrors: [],
      summary: {
        currentDecisionCount: 2,
        futureDecisionCount: 2,
        missingFutureCount: 1,
        staleFutureCount: 1,
        extraFutureCount: 1,
        validationErrorCount: 0,
      },
    });

    assert.deepEqual(
      backfill.writes.map((write) => ({
        key: write.key,
        futurePath: write.futurePath,
        data: write.data,
      })),
      [
        {
          key: "user-a/user-b",
          futurePath: "profileDecisions/user-a/outgoing/user-b",
          data: sourceA.data,
        },
        {
          key: "user-a/user-c",
          futurePath: "profileDecisions/user-a/outgoing/user-c",
          data: sourceB.data,
        },
      ]
    );
    assert.equal(backfill.summary.writesNeeded, 2);
    assert.equal(backfill.summary.readyToApply, true);
    assert.equal(backfill.summary.extraFutureCount, 1);
  }
);

test("applyProfileDecisionBackfill writes future docs", async () => {
  const firestore = fakeFirestore();
  await applyProfileDecisionBackfill(firestore, {
    writes: [{
      futurePath: "profileDecisions/user-a/outgoing/user-b",
      data: {swiperId: "user-a", targetId: "user-b"},
    }],
  });

  assert.deepEqual(
    firestore.get("profileDecisions/user-a/outgoing/user-b"),
    {swiperId: "user-a", targetId: "user-b"}
  );
});

function fakeFirestore() {
  const data = {};
  return {
    doc: (path) => ({path}),
    batch: () => {
      const writes = [];
      return {
        set: (ref, value) => writes.push(() => {
          data[ref.path] = structuredClone(value);
        }),
        commit: async () => writes.forEach((write) => write()),
      };
    },
    get: (path) => data[path],
  };
}
