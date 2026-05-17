/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  requestAccountDeletionHandler,
  storagePathFromDownloadUrl,
} from "./accountDeletion";

test(
  "storagePathFromDownloadUrl extracts Firebase Storage object paths",
  () => {
    assert.equal(
      storagePathFromDownloadUrl(
        "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
          "users%2Frunner-1%2Fphotos%2F0_123.jpg?alt=media&token=abc"
      ),
      "users/runner-1/photos/0_123.jpg"
    );
  }
);

test("storagePathFromDownloadUrl returns null for invalid urls", () => {
  assert.equal(storagePathFromDownloadUrl("not a url"), null);
});

test("requestAccountDeletionHandler anonymizes retained user doc", async () => {
  const now = {kind: "serverTimestamp"};
  const harness = createAccountDeletionHarness({
    seed: {
      "users/runner-1": {
        photoUrls: [
          "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "users%2Frunner-1%2Fphotos%2F0_123.jpg?alt=media&token=abc",
        ],
        photoThumbnailUrls: [
          "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "users%2Frunner-1%2Fthumbnails%2F0_123.jpg?alt=media&token=abc",
        ],
        profilePhotos: [{
          id: "grouped-photo",
          url:
            "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "profilePhotos%2Frunner-1%2Fphotos%2Fgrouped.jpg" +
            "?alt=media&token=abc",
          thumbnailUrl:
            "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "profilePhotos%2Frunner-1%2Fphotos%2Fgrouped_thumb.jpg" +
            "?alt=media&token=abc",
          storagePath: "profilePhotos/runner-1/photos/grouped.jpg",
          thumbnailStoragePath:
            "profilePhotos/runner-1/photos/grouped_thumb.jpg",
          position: 0,
        }],
        name: "Asha Runner",
        dateOfBirth: admin.firestore.Timestamp.fromDate(
          new Date("1995-01-01T00:00:00.000Z")
        ),
        phoneNumber: "+919876543210",
        languages: ["english"],
        paceMinSecsPerKm: 300,
        preferredDistances: ["tenK"],
        runningReasons: ["community"],
      },
      "runClubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        role: "member",
        status: "active",
        pushNotificationsEnabled: true,
      },
      "runParticipations/run-1_runner-1": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
        genderAtSignup: "woman",
      },
      "savedRuns/runner-1_run-1": {uid: "runner-1", runId: "run-1"},
      "swipes/runner-1/outgoing/runner-2": {
        swiperId: "runner-1",
        targetId: "runner-2",
      },
      "swipes/runner-2/outgoing/runner-1": {
        swiperId: "runner-2",
        targetId: "runner-1",
      },
      "matches/match-1": {
        participantIds: ["runner-1", "runner-2"],
        user1Id: "runner-1",
        user2Id: "runner-2",
      },
      "reviews/run-1~runner-1": {reviewerUserId: "runner-1"},
      "payments/payment-1": {userId: "runner-1"},
      "notifications/runner-1/items/item-1": {uid: "runner-1"},
      "blocks/runner-1__runner-2": {
        blockerUserId: "runner-1",
        blockedUserId: "runner-2",
      },
      "reports/report-1": {
        reporterUserId: "runner-2",
        reportedUserId: "runner-1",
      },
    },
    now,
  });

  await requestAccountDeletionHandler(
    {auth: {uid: "runner-1"}} as Parameters<
      typeof requestAccountDeletionHandler
    >[0],
    harness.deps
  );

  const retainedUserWrite = harness.setWrites.find(
    (write) => write.path === "users/runner-1"
  );
  assert.ok(retainedUserWrite);
  assert.deepEqual(retainedUserWrite.options, {merge: true});

  const data = retainedUserWrite.data;
  assert.equal(data.deleted, true);
  assert.equal(data.deletedAt, now);
  assert.equal(data.name, "Deleted user");
  assert.equal(data.firstName, "");
  assert.equal(data.lastName, "");
  assert.equal(data.displayName, "Deleted user");
  assert.equal(
    (data.dateOfBirth as FirebaseFirestore.Timestamp).toMillis(),
    0
  );
  assert.equal(data.phoneNumber, "");
  assert.deepEqual(data.photoUrls, []);
  assert.deepEqual(data.photoThumbnailUrls, []);
  assert.deepEqual(data.profilePhotos, []);
  assert.deepEqual(data.preferredDistances, []);
  assert.deepEqual(data.runningReasons, []);
  assert.deepEqual(data.preferredRunTimes, []);
  assert.equal(data.paceMinSecsPerKm, 300);
  assert.equal(data.paceMaxSecsPerKm, 420);

  for (const field of [
    "city",
    "height",
    "occupation",
    "company",
    "education",
    "religion",
    "relationshipGoal",
    "drinking",
    "smoking",
    "workout",
    "diet",
    "children",
    "fcmToken",
  ]) {
    assert.equal(hasOwn(data, field), true);
  }

  assert.ok(harness.deletedPublicDocs.includes("publicProfiles/runner-1"));
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "runClubMemberships/club-1_runner-1" &&
      write.data.status === "deleted"
    )
  );
  assert.ok(
    harness.updateWrites.some((write) =>
      write.path === "runClubs/club-1" &&
      write.data.memberCount !== undefined
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "runParticipations/run-1_runner-1" &&
      write.data.status === "deleted"
    )
  );
  assert.ok(
    harness.updateWrites.some((write) =>
      write.path === "runs/run-1" &&
      write.data.bookedCount !== undefined
    )
  );
  assert.ok(
    harness.deletedPublicDocs.includes("savedRuns/runner-1_run-1")
  );
  assert.ok(
    harness.deletedPublicDocs.includes("swipes/runner-1/outgoing/runner-2")
  );
  assert.ok(
    harness.deletedPublicDocs.includes("swipes/runner-2/outgoing/runner-1")
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "matches/match-1" &&
      write.data.status === "blocked"
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "reviews/run-1~runner-1" &&
      write.data.reviewerDeleted === true
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "payments/payment-1" &&
      write.data.userDeleted === true
    )
  );
  assert.ok(
    harness.deletedPublicDocs.includes("notifications/runner-1/items/item-1")
  );
  assert.ok(
    harness.deletedPublicDocs.includes("blocks/runner-1__runner-2")
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "reports/report-1" &&
      write.data.hasDeletedUser === true
    )
  );
  assert.deepEqual(harness.deletedAuthUsers, ["runner-1"]);
  assert.deepEqual(harness.deletedStorageFiles, [
    "profilePhotos/runner-1/photos/grouped.jpg",
    "profilePhotos/runner-1/photos/grouped_thumb.jpg",
    "users/runner-1/photos/0_123.jpg",
    "users/runner-1/thumbnails/0_123.jpg",
  ]);
  assert.equal(harness.commits, 1);
});

test("requestAccountDeletionHandler rate limits before destructive work",
  async () => {
    const harness = createAccountDeletionHarness({
      seed: {
        "users/runner-1": {
          photoUrls: [
            "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
              "users%2Frunner-1%2Fphotos%2F0_123.jpg?alt=media&token=abc",
          ],
        },
      },
      now: {kind: "serverTimestamp"},
    });

    await assert.rejects(
      requestAccountDeletionHandler(
        {auth: {uid: "runner-1"}} as Parameters<
          typeof requestAccountDeletionHandler
        >[0],
        {
          ...harness.deps,
          checkRateLimit: async (_db, uid, action) => {
            assert.equal(uid, "runner-1");
            assert.equal(action, "requestAccountDeletion");
            throw new HttpsError(
              "resource-exhausted",
              "Too many account deletion requests."
            );
          },
        }
      ),
      (error) => error instanceof HttpsError &&
        error.code === "resource-exhausted"
    );

    assert.deepEqual(harness.setWrites, []);
    assert.deepEqual(harness.deletedPublicDocs, []);
    assert.deepEqual(harness.deletedAuthUsers, []);
    assert.deepEqual(harness.deletedStorageFiles, []);
    assert.equal(harness.commits, 0);
  }
);

type FakeDocumentData = Record<string, unknown>;

interface FakeDocumentReference {
  path: string;
  collectionPath: string;
  docId: string;
  ref: FakeDocumentReference;
  data: () => FakeDocumentData | undefined;
  get: () => Promise<{data: () => FakeDocumentData | undefined}>;
}

interface SetWrite {
  path: string;
  data: FakeDocumentData;
  options?: {merge: boolean};
}

interface UpdateWrite {
  path: string;
  data: FakeDocumentData;
}

function createAccountDeletionHarness(params: {
  seed: Record<string, FakeDocumentData>;
  now: unknown;
}) {
  const setWrites: SetWrite[] = [];
  const updateWrites: UpdateWrite[] = [];
  const deletedPublicDocs: string[] = [];
  const deletedAuthUsers: string[] = [];
  const deletedStorageFiles: string[] = [];
  let commits = 0;
  const seed = params.seed;

  const docFor = (
    collectionPath: string,
    docId: string
  ): FakeDocumentReference => {
    const ref = {
      path: `${collectionPath}/${docId}`,
      collectionPath,
      docId,
      data: () => seed[`${collectionPath}/${docId}`],
      get: async () => ({
        data: () => seed[`${collectionPath}/${docId}`],
      }),
    } as FakeDocumentReference;
    ref.ref = ref;
    return ref;
  };

  const queryFor = (
    collectionPath: string,
    docs: FakeDocumentReference[] = allDocs(collectionPath)
  ) => ({
    where: (field: string, op: string, value: unknown) => {
      assert.ok(op === "==" || op === "array-contains");
      return queryFor(
        collectionPath,
        docs.filter((doc) => {
          const fieldValue = seed[doc.path]?.[field];
          if (op === "array-contains") {
            return Array.isArray(fieldValue) && fieldValue.includes(value);
          }
          return fieldValue === value;
        })
      );
    },
    get: async () => ({
      docs,
      forEach: (callback: (doc: FakeDocumentReference) => void) => {
        docs.forEach(callback);
      },
    }),
  });

  const allDocs = (collectionPath: string): FakeDocumentReference[] =>
    Object.keys(seed)
      .filter((path) => path.startsWith(`${collectionPath}/`))
      .filter((path) => {
        const rest = path.substring(collectionPath.length + 1);
        return !rest.includes("/");
      })
      .map((path) => {
        const segments = path.split("/");
        return docFor(collectionPath, segments[segments.length - 1]);
      });

  const collectionGroupDocs = (collectionId: string): FakeDocumentReference[] =>
    Object.keys(seed)
      .filter((path) => {
        const segments = path.split("/");
        return segments.length >= 2 &&
          segments[segments.length - 2] === collectionId;
      })
      .map((path) => {
        const segments = path.split("/");
        return docFor(
          segments.slice(0, segments.length - 1).join("/"),
          segments[segments.length - 1]
        );
      });

  const firestore = {
    collection: (collectionPath: string) => ({
      doc: (docId: string) => ({
        ...docFor(collectionPath, docId),
        collection: (subcollectionPath: string) => queryFor(
          `${collectionPath}/${docId}/${subcollectionPath}`
        ),
      }),
      where: queryFor(collectionPath).where,
      get: queryFor(collectionPath).get,
    }),
    collectionGroup: (collectionId: string) =>
      queryFor(collectionId, collectionGroupDocs(collectionId)),
    batch: () => ({
      set: (
        ref: FakeDocumentReference,
        data: FakeDocumentData,
        options?: {merge: boolean}
      ) => setWrites.push({path: ref.path, data, options}),
      update: (
        ref: FakeDocumentReference,
        data: FakeDocumentData
      ) => updateWrites.push({path: ref.path, data}),
      delete: (ref: FakeDocumentReference) => deletedPublicDocs.push(ref.path),
      commit: async () => {
        commits += 1;
      },
    }),
  } as unknown as FirebaseFirestore.Firestore;

  const auth = {
    deleteUser: async (uid: string) => {
      deletedAuthUsers.push(uid);
    },
  } as unknown as admin.auth.Auth;

  const storageBucket = {
    file: (path: string) => ({
      delete: async () => {
        deletedStorageFiles.push(path);
      },
    }),
  } as unknown as ReturnType<ReturnType<typeof admin.storage>["bucket"]>;

  return {
    deps: {
      auth: () => auth,
      firestore: () => firestore,
      storageBucket: () => storageBucket,
      serverTimestamp: () => params.now as FirebaseFirestore.FieldValue,
    },
    setWrites,
    updateWrites,
    deletedPublicDocs,
    deletedAuthUsers,
    deletedStorageFiles,
    get commits() {
      return commits;
    },
  };
}

function hasOwn(data: FakeDocumentData, field: string): boolean {
  return Object.prototype.hasOwnProperty.call(data, field);
}
