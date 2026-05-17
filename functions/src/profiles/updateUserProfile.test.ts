/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {updateUserProfileHandler} from "./updateUserProfile";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : {...this.value};
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return {
      doc: (docId: string) => new FakeDocRef(
        this,
        `${collectionPath}/${docId}`
      ),
    };
  }

  async runTransaction<T>(
    callback: (tx: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : {...data};
  }

  set(path: string, data: FakeData) {
    this.docs[path] = data;
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (current === undefined) {
        throw new Error(`Missing doc for update: ${ref.path}`);
      }
      this.firestore.set(ref.path, {...current, ...patch});
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  return {
    firestore,
    deps: {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      timestampFromMillis: (millis: number) =>
        ({kind: "timestamp", millis}) as unknown as
          FirebaseFirestore.Timestamp,
    },
  };
}

function request(
  uid: string | null,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token: {}} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("updateUserProfileHandler validates and applies profile patches",
  async () => {
    const h = harness({
      "users/runner-1": {name: "Runner One", profileComplete: false},
    });

    await updateUserProfileHandler(
      request("runner-1", {
        fields: {
          name: " Runner Updated ",
          displayName: " Runner R. ",
          email: " runner@example.com ",
          instagramHandle: " @runner.one ",
          dateOfBirth: 946684800000,
          gender: "woman",
          profilePrompts: [{
            promptId: " perfectRun ",
            prompt: " A perfect run with me looks like... ",
            answer: "first\n\n\nsecond",
          }],
          photoPrompts: [{
            photoIndex: 0,
            promptId: " proofIRun ",
            prompt: " Proof I actually run ",
            caption: "finish\n\n\nline",
          }],
          photoUrls: ["https://example.test/profile.jpg"],
          city: " indore ",
          occupation: " Runner ",
          company: " Catch ",
          languages: [" english "],
          paceMinSecsPerKm: 300,
          height: 120,
          preferredDistances: [" tenK "],
          runningReasons: [" community "],
          preferredRunTimes: [" morning "],
          prefsWeeklyDigest: true,
        },
      }),
      h.deps
    );

    assert.deepEqual(h.firestore.get("users/runner-1"), {
      name: "Runner Updated",
      displayName: "Runner R.",
      email: "runner@example.com",
      instagramHandle: "runner.one",
      profileComplete: false,
      dateOfBirth: {kind: "timestamp", millis: 946684800000},
      gender: "woman",
      profilePrompts: [{
        promptId: "perfectRun",
        prompt: "A perfect run with me looks like...",
        answer: "first\n\nsecond",
      }],
      photoPrompts: [{
        photoIndex: 0,
        promptId: "proofIRun",
        prompt: "Proof I actually run",
        caption: "finish\n\nline",
      }],
      photoUrls: ["https://example.test/profile.jpg"],
      city: "indore",
      occupation: "Runner",
      company: "Catch",
      languages: ["english"],
      paceMinSecsPerKm: 300,
      height: 120,
      preferredDistances: ["tenK"],
      runningReasons: ["community"],
      preferredRunTimes: ["morning"],
      prefsWeeklyDigest: true,
    });
  }
);

test("updateUserProfileHandler rejects invalid payloads", async () => {
  const h = harness({"users/runner-1": {name: "Runner One"}});

  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {dateOfBirth: "1998-01-01"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {unknownField: true}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {sexualOrientation: "straight"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {displayName: "   "}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {
        fields: {
          profilePrompts: [{
            promptId: "perfectRun",
            prompt: "A perfect run with me looks like...",
            answer: "x".repeat(301),
          }],
        },
      }),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {interestedInGenders: []}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {instagramHandle: "runner!"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {email: "not-an-email"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {languages: ["klingon"]}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {preferredDistances: ["ultra"]}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {runningReasons: ["chaos"]}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {height: 119}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {height: 221}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(request("runner-1", {fields: {}}), h.deps),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request(null, {fields: {name: "Runner Updated"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
});

test("updateUserProfileHandler rejects unsafe account states", async () => {
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {name: "Runner Updated"}}),
      harness({}).deps
    ),
    (error) => assertHttpsCode(error, "not-found")
  );

  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {name: "Runner Updated"}}),
      harness({
        "users/runner-1": {name: "Runner One"},
        "deletedUsers/runner-1": {uid: "runner-1"},
      }).deps
    ),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("updateUserProfileHandler enforces the completed profile photo floor",
  async () => {
    const h = harness({
      "users/runner-1": {
        name: "Runner One",
        profileComplete: false,
        photoUrls: ["https://example.test/one.jpg"],
      },
    });

    await assert.rejects(
      updateUserProfileHandler(
        request("runner-1", {fields: {profileComplete: true}}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );

    assert.equal(h.firestore.get("users/runner-1")?.profileComplete, false);
  }
);

test("updateUserProfileHandler deletes removed grouped photo storage objects",
  async () => {
    const removedStoragePaths: string[] = [];
    const h = harness({
      "users/runner-1": {
        name: "Runner One",
        profileComplete: false,
        profilePhotos: [
          {
            id: "old",
            url: "https://example.test/old.jpg",
            thumbnailUrl: "https://example.test/old-thumb.jpg",
            storagePath: "users/runner-1/photos/0_old.jpg",
            thumbnailStoragePath:
              "users/runner-1/photoThumbnails/0_old.jpg",
            position: 0,
          },
          {
            id: "keep",
            url: "https://example.test/keep.jpg",
            thumbnailUrl: "https://example.test/keep-thumb.jpg",
            storagePath: "users/runner-1/photos/1_keep.jpg",
            thumbnailStoragePath:
              "users/runner-1/photoThumbnails/1_keep.jpg",
            position: 1,
          },
        ],
      },
    });

    await updateUserProfileHandler(
      request("runner-1", {
        fields: {
          profilePhotos: [{
            id: "keep",
            url: "https://example.test/keep.jpg",
            thumbnailUrl: "https://example.test/keep-thumb.jpg",
            storagePath: "users/runner-1/photos/1_keep.jpg",
            thumbnailStoragePath:
              "users/runner-1/photoThumbnails/1_keep.jpg",
            position: 0,
            createdAt: 0,
            updatedAt: 0,
          }],
          photoUrls: ["https://example.test/keep.jpg"],
          photoThumbnailUrls: ["https://example.test/keep-thumb.jpg"],
          photoPrompts: [],
        },
      }),
      {
        ...h.deps,
        deleteStoragePaths: async (paths) => {
          removedStoragePaths.push(...paths);
        },
      }
    );

    assert.deepEqual(removedStoragePaths.sort(), [
      "users/runner-1/photoThumbnails/0_old.jpg",
      "users/runner-1/photos/0_old.jpg",
    ]);
  }
);

test("updateUserProfileHandler rate limits before profile writes", async () => {
  const h = harness({"users/runner-1": {name: "Runner One"}});

  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {displayName: "Runner"}}),
      {
        ...h.deps,
        checkRateLimit: async (_db, uid, action) => {
          assert.equal(uid, "runner-1");
          assert.equal(action, "updateUserProfile");
          throw new HttpsError(
            "resource-exhausted",
            "Too many profile edits."
          );
        },
      }
    ),
    (error) => assertHttpsCode(error, "resource-exhausted")
  );

  assert.deepEqual(h.firestore.get("users/runner-1"), {name: "Runner One"});
});
