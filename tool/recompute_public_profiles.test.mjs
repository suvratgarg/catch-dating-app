import assert from "node:assert/strict";
import test from "node:test";
import {
  applyPublicProfileRepairPlan,
  buildPublicProfileRepairPlan,
} from "./recompute_public_profiles.mjs";

const projection = {
  publicProfileFromUserProfileDoc: (user) =>
    validPublicProfile({name: user.displayName, age: user.age ?? 30}),
};

test("buildPublicProfileRepairPlan finds stale, missing, and deleted profiles",
  async () => {
    const firestore = fakeFirestore({
      users: {
        "runner-1": {
          profileComplete: true,
          displayName: "Runner One",
          age: 30,
        },
        "runner-2": {
          profileComplete: true,
          displayName: "Runner Two",
          age: 31,
        },
        "runner-3": {
          profileComplete: true,
          deleted: true,
          displayName: "Runner Three",
        },
        "runner-4": {
          profileComplete: false,
          displayName: "Runner Four",
        },
      },
      publicProfiles: {
        "runner-1": {
          ...validPublicProfile({name: "Old Runner One", age: 30}),
          bio: "legacy field",
        },
        "runner-3": validPublicProfile({name: "Runner Three", age: 30}),
        "runner-4": validPublicProfile({name: "Runner Four", age: 30}),
        orphan: validPublicProfile({name: "Orphan", age: 30}),
      },
    });

    const plan = await buildPublicProfileRepairPlan(firestore, projection);

    assert.deepEqual(
      plan.repairs.map((repair) => ({
        path: repair.path,
        op: repair.op,
        reason: repair.reason,
      })),
      [
        {
          path: "publicProfiles/runner-1",
          op: "set",
          reason: "staleProjection",
        },
        {
          path: "publicProfiles/runner-2",
          op: "set",
          reason: "missingProjection",
        },
        {
          path: "publicProfiles/runner-3",
          op: "delete",
          reason: "deletedUser",
        },
      ]
    );
    assert.equal(plan.summary.repairsNeeded, 3);
    assert.deepEqual(plan.summary.warnings, [
      "publicProfiles/runner-4 exists but users/runner-4 is incomplete.",
      "publicProfiles/orphan has no matching users/orphan.",
    ]);
  }
);

test("applyPublicProfileRepairPlan writes set and delete repairs", async () => {
  const firestore = fakeFirestore({
    publicProfiles: {
      "runner-1": validPublicProfile({name: "Old Runner One", age: 30}),
      "runner-2": validPublicProfile({name: "Runner Two", age: 31}),
    },
  });
  const expected = validPublicProfile({name: "Runner One", age: 30});

  await applyPublicProfileRepairPlan(firestore, {
    repairs: [
      {
        path: "publicProfiles/runner-1",
        op: "set",
        expected,
      },
      {
        path: "publicProfiles/runner-2",
        op: "delete",
      },
    ],
  });

  assert.deepEqual(firestore.get("publicProfiles/runner-1"), expected);
  assert.equal(firestore.get("publicProfiles/runner-2"), undefined);
});

test("buildPublicProfileRepairPlan warns and skips invalid projections",
  async () => {
    const firestore = fakeFirestore({
      users: {
        "runner-1": {
          profileComplete: true,
          displayName: "Runner One",
          age: 30,
        },
      },
    });
    const badProjection = {
      publicProfileFromUserProfileDoc: () => ({
        ...validPublicProfile({name: "Runner One", age: 30}),
        photoThumbnailUrls: ["not a url"],
      }),
    };

    const plan = await buildPublicProfileRepairPlan(firestore, badProjection);

    assert.deepEqual(plan.repairs, []);
    assert.deepEqual(plan.summary.warnings, [
      "users/runner-1 projected an invalid public profile: " +
      "publicProfiles/runner-1 failed schema validation: " +
      "/photoThumbnailUrls/0 must match format \"uri\"",
    ]);
  }
);

function validPublicProfile({name, age}) {
  return {
    name,
    age,
    gender: "woman",
    profilePrompts: [{
      promptId: "perfectRun",
      prompt: "A perfect run with me looks like...",
      answer: "Easy kilometres.",
    }],
    photoUrls: ["https://example.test/full.jpg"],
    photoThumbnailUrls: ["https://example.test/thumb.jpg"],
    photoPrompts: [{
      photoIndex: 0,
      promptId: "proofIRun",
      prompt: "Proof I actually run",
      caption: "Race morning.",
    }],
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: ["fiveK"],
    runningReasons: ["fitness"],
    preferredRunTimes: ["morning"],
  };
}

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    collection: (collectionName) => ({
      get: async () => {
        const collection = data[collectionName] ?? {};
        const docs = Object.entries(collection).map(([id, value]) => ({
          id,
          ref: {path: `${collectionName}/${id}`},
          data: () => structuredClone(value),
        }));
        return {size: docs.length, docs};
      },
    }),
    doc: (docPath) => ({
      path: docPath,
    }),
    batch: () => {
      const writes = [];
      return {
        set: (ref, value) => {
          writes.push(() => setDoc(data, ref.path, value));
        },
        delete: (ref) => {
          writes.push(() => deleteDoc(data, ref.path));
        },
        commit: async () => {
          for (const write of writes) write();
        },
      };
    },
    get: (docPath) => getDoc(data, docPath),
  };
}

function setDoc(data, docPath, value) {
  const [collectionName, docId] = docPath.split("/");
  data[collectionName] ??= {};
  data[collectionName][docId] = structuredClone(value);
}

function deleteDoc(data, docPath) {
  const [collectionName, docId] = docPath.split("/");
  if (data[collectionName]) delete data[collectionName][docId];
}

function getDoc(data, docPath) {
  const [collectionName, docId] = docPath.split("/");
  const value = data[collectionName]?.[docId];
  return value === undefined ? undefined : structuredClone(value);
}
