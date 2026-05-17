import assert from "node:assert/strict";
import test from "node:test";
import {
  applyProfilePhotoBackfillPlan,
  buildProfilePhotoBackfillPlan,
  normalizeProfilePhotosForBackfill,
} from "./backfill_profile_photos.mjs";

const timestampFromMillis = (millis) => fakeTimestamp(millis);
const projection = {
  publicProfileFromUserProfileDoc: (user) => ({
    name: user.displayName,
    age: 30,
    gender: user.gender,
    profilePrompts: user.profilePrompts,
    photoUrls: user.photoUrls,
    photoThumbnailUrls: user.photoThumbnailUrls,
    photoPrompts: user.photoPrompts,
    profilePhotos: user.profilePhotos,
    paceMinSecsPerKm: user.paceMinSecsPerKm,
    paceMaxSecsPerKm: user.paceMaxSecsPerKm,
    preferredDistances: user.preferredDistances,
    runningReasons: user.runningReasons,
    preferredRunTimes: user.preferredRunTimes,
  }),
};

test("normalizeProfilePhotosForBackfill groups legacy photo arrays", () => {
  const photos = normalizeProfilePhotosForBackfill(
    {
      photoUrls: ["https://example.test/full.jpg"],
      photoThumbnailUrls: ["https://example.test/thumb.jpg"],
      photoPrompts: [photoPrompt()],
    },
    {uid: "runner-1", timestampFromMillis}
  );

  assert.deepEqual(photos.map((photo) => ({
    id: photo.id,
    url: photo.url,
    thumbnailUrl: photo.thumbnailUrl,
    storagePath: photo.storagePath,
    thumbnailStoragePath: photo.thumbnailStoragePath,
    prompt: photo.prompt,
    position: photo.position,
  })), [{
    id: "legacy_0",
    url: "https://example.test/full.jpg",
    thumbnailUrl: "https://example.test/thumb.jpg",
    storagePath: "users/runner-1/photos/legacy_0.jpg",
    thumbnailStoragePath: "users/runner-1/photoThumbnails/legacy_0.jpg",
    prompt: photoPrompt(),
    position: 0,
  }]);
});

test("buildProfilePhotoBackfillPlan repairs user and public profile photos",
  async () => {
    const user = validUserProfile({
      profilePhotos: undefined,
      photoUrls: ["https://example.test/full.jpg"],
      photoThumbnailUrls: ["https://example.test/thumb.jpg"],
      photoPrompts: [photoPrompt()],
    });
    const firestore = fakeFirestore({
      users: {"runner-1": user},
      publicProfiles: {},
    });

    const plan = await buildProfilePhotoBackfillPlan(firestore, {
      timestampFromMillis,
      projection,
    });

    assert.equal(plan.summary.repairsNeeded, 2);
    assert.deepEqual(
      plan.repairs.map((repair) => ({path: repair.path, op: repair.op})),
      [
        {path: "users/runner-1", op: "update"},
        {path: "publicProfiles/runner-1", op: "set"},
      ]
    );

    await applyProfilePhotoBackfillPlan(firestore, plan);
    assert.equal(
      firestore.get("users/runner-1").profilePhotos[0].storagePath,
      "users/runner-1/photos/legacy_0.jpg"
    );
    assert.equal(
      firestore.get("publicProfiles/runner-1").profilePhotos[0].thumbnailUrl,
      "https://example.test/thumb.jpg"
    );

    const followUpPlan = await buildProfilePhotoBackfillPlan(firestore, {
      timestampFromMillis,
      projection,
    });
    assert.equal(followUpPlan.summary.repairsNeeded, 0);
  }
);

function validUserProfile(overrides = {}) {
  return {
    displayName: "Runner One",
    gender: "woman",
    profileComplete: true,
    profilePrompts: [],
    photoUrls: [],
    photoThumbnailUrls: [],
    photoPrompts: [],
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: ["fiveK"],
    runningReasons: ["fitness"],
    preferredRunTimes: ["morning"],
    ...overrides,
  };
}

function photoPrompt() {
  return {
    photoIndex: 0,
    promptId: "proofIRun",
    prompt: "Proof I actually run",
    caption: "Race morning.",
  };
}

function fakeTimestamp(millis) {
  return {
    seconds: Math.floor(millis / 1000),
    nanoseconds: (millis % 1000) * 1000000,
    toDate: () => new Date(millis),
    toMillis: () => millis,
  };
}

function fakeFirestore(initial) {
  const state = new Map(
    Object.entries(initial).flatMap(([collectionId, docs]) =>
      Object.entries(docs).map(([docId, data]) => [
        `${collectionId}/${docId}`,
        clone(data),
      ])
    )
  );
  return {
    collection: (collectionId) => ({
      get: async () => ({
        size: [...state.keys()].filter((key) =>
          key.startsWith(`${collectionId}/`)
        ).length,
        docs: [...state.entries()]
          .filter(([key]) => key.startsWith(`${collectionId}/`))
          .map(([key, data]) => ({
            id: key.split("/")[1],
            data: () => clone(data),
          })),
      }),
    }),
    doc: (docPath) => ({path: docPath}),
    batch: () => {
      const writes = [];
      return {
        set: (ref, data) => writes.push(["set", ref.path, data]),
        update: (ref, fields) => writes.push(["update", ref.path, fields]),
        commit: async () => {
          for (const [op, docPath, data] of writes) {
            if (op === "set") state.set(docPath, clone(data));
            else state.set(docPath, {...state.get(docPath), ...data});
          }
        },
      };
    },
    get: (docPath) => state.get(docPath),
  };
}

function clone(value) {
  if (Array.isArray(value)) return value.map(clone);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, child]) => [key, clone(child)])
    );
  }
  return value;
}
