import assert from "node:assert/strict";
import test from "node:test";
import {
  buildProfileDecisionMigrationPlan,
  normalizeForCompare,
} from "./validate_profile_decision_migration.mjs";

const migration = {
  logicalName: "profileDecision",
  currentStoragePath: "swipes/{userId}/outgoing/{targetId}",
  candidatePrimaryStoragePath: "profileDecisions/{userId}/outgoing/{targetId}",
};

test("buildProfileDecisionMigrationPlan reports missing, stale, and extra docs",
  async () => {
    const firestore = fakeFirestore({
      swipes: {
        "user-a": {
          outgoing: {
            "user-b": validDecision("user-a", "user-b"),
            "user-c": validDecision("user-a", "user-c", {direction: "pass"}),
          },
        },
        "user-d": {
          outgoing: {
            "user-e": validDecision("user-d", "user-e"),
          },
        },
      },
      profileDecisions: {
        "user-a": {
          outgoing: {
            "user-b": validDecision("user-a", "user-b"),
            "user-c": validDecision("user-a", "user-c"),
          },
        },
        "user-z": {
          outgoing: {
            "user-y": validDecision("user-z", "user-y"),
          },
        },
      },
    });

    const plan = await buildProfileDecisionMigrationPlan(
      firestore,
      {migration}
    );

    assert.equal(plan.summary.currentDecisionCount, 3);
    assert.equal(plan.summary.futureDecisionCount, 3);
    assert.equal(plan.summary.missingFutureCount, 1);
    assert.equal(plan.summary.staleFutureCount, 1);
    assert.equal(plan.summary.extraFutureCount, 1);
    assert.equal(plan.summary.validationErrorCount, 0);
    assert.equal(plan.summary.readyForBackfill, true);
    assert.equal(plan.summary.readyForPrimaryCutover, false);
    assert.deepEqual(plan.missingFuture.map((item) => item.key), [
      "user-d/user-e",
    ]);
    assert.deepEqual(plan.staleFuture.map((item) => item.key), [
      "user-a/user-c",
    ]);
    assert.deepEqual(plan.extraFuture.map((item) => item.key), [
      "user-z/user-y",
    ]);
  }
);

test("buildProfileDecisionMigrationPlan blocks schema and path-id drift",
  async () => {
    const firestore = fakeFirestore({
      swipes: {
        "user-a": {
          outgoing: {
            "user-b": {
              ...validDecision("wrong-user", "user-c"),
              comment: "x".repeat(241),
            },
          },
        },
      },
    });

    const plan = await buildProfileDecisionMigrationPlan(
      firestore,
      {migration}
    );

    assert.equal(plan.summary.validationErrorCount, 3);
    assert.equal(plan.summary.readyForBackfill, false);
    assert.match(
      plan.validationErrors[0].errors.join(" "),
      /must NOT have more than 240 characters/
    );
    assert.deepEqual(plan.validationErrors.slice(1).map((item) => item.errors), [
      ["/swiperId should match owner id user-a"],
      ["/targetId should match document id user-b"],
    ]);
  }
);

test("normalizeForCompare handles Firestore timestamp-like objects", () => {
  assert.deepEqual(
    normalizeForCompare({
      b: undefined,
      createdAt: {
        seconds: 10,
        nanoseconds: 20,
        toDate: () => new Date(0),
      },
      a: ["value"],
    }),
    {
      a: ["value"],
      createdAt: {_seconds: 10, _nanoseconds: 20},
    }
  );
});

function validDecision(swiperId, targetId, overrides = {}) {
  return {
    swiperId,
    targetId,
    eventId: "event-1",
    direction: "like",
    createdAt: {_seconds: 1, _nanoseconds: 0},
    ...overrides,
  };
}

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    collection: (collectionName) => collectionRef(data, collectionName),
    collectionGroup: (collectionName) => collectionGroupRef(data, collectionName),
  };
}

function collectionRef(data, collectionName) {
  return {
    get: async () => collectionSnapshot(data[collectionName] ?? {}, (id) => ({
      id,
      data: () => structuredClone(data[collectionName]?.[id] ?? {}),
    })),
    doc: (docId) => ({
      collection: (subcollectionName) => ({
        get: async () => collectionSnapshot(
          data[collectionName]?.[docId]?.[subcollectionName] ?? {},
          (id, value) => ({
            id,
            data: () => structuredClone(value),
          })
        ),
      }),
    }),
  };
}

function collectionSnapshot(collection, buildDoc) {
  const docs = Object.entries(collection).map(([id, value]) =>
    buildDoc(id, value)
  );
  return {size: docs.length, docs};
}

function collectionGroupRef(data, collectionName) {
  return {
    get: async () => {
      const docs = [];
      for (const [rootCollection, ownerDocs] of Object.entries(data)) {
        for (const [ownerId, ownerData] of Object.entries(ownerDocs)) {
          const subcollection = ownerData?.[collectionName];
          if (!isRecord(subcollection)) continue;
          for (const [targetId, value] of Object.entries(subcollection)) {
            docs.push({
              id: targetId,
              ref: {
                path: `${rootCollection}/${ownerId}/${collectionName}/${targetId}`,
              },
              data: () => structuredClone(value),
            });
          }
        }
      }
      return {size: docs.length, docs};
    },
  };
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
