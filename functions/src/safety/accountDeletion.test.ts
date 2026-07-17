import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {eventBroadcastDeliveryKey} from "../shared/eventBroadcasts";
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
  const runnerDeliveryKey = eventBroadcastDeliveryKey("runner-1");
  const otherDeliveryKey = eventBroadcastDeliveryKey("runner-2");
  const harness = createAccountDeletionHarness({
    seed: {
      "users/runner-1": {
        profilePhotos: [{
          id: "grouped-photo",
          url:
            "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "users%2Frunner-1%2Fphotos%2Fgrouped.jpg" +
            "?alt=media&token=abc",
          thumbnailUrl:
            "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
            "users%2Frunner-1%2FphotoThumbnails%2Fgrouped.jpg" +
            "?alt=media&token=abc",
          storagePath: "users/runner-1/photos/grouped.jpg",
          thumbnailStoragePath:
            "users/runner-1/photoThumbnails/grouped.jpg",
          position: 0,
        }],
        name: "Asha Runner",
        dateOfBirth: admin.firestore.Timestamp.fromDate(
          new Date("1995-01-01T00:00:00.000Z")
        ),
        phoneNumber: "+919876543210",
        languages: ["english"],
        activityPreferences: {
          running: {
            paceMinSecsPerKm: 300,
            paceMaxSecsPerKm: 420,
            preferredDistances: ["tenK"],
            runningReasons: ["community"],
            preferredRunTimes: ["morning"],
            version: 1,
          },
        },
      },
      "clubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        role: "member",
        status: "active",
        pushNotificationsEnabled: true,
      },
      "eventParticipations/event-1_runner-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
        genderAtSignup: "woman",
      },
      "savedEvents/runner-1_run-1": {uid: "runner-1", eventId: "event-1"},
      "profileDecisions/runner-1/outgoing/runner-2": {
        swiperId: "runner-1",
        targetId: "runner-2",
      },
      "profileDecisions/runner-2/outgoing/runner-1": {
        swiperId: "runner-2",
        targetId: "runner-1",
      },
      "matches/match-1": {
        participantIds: ["runner-1", "runner-2"],
        user1Id: "runner-1",
        user2Id: "runner-2",
      },
      "reviews/event-1~runner-1": {reviewerUserId: "runner-1"},
      "payments/payment-1": {userId: "runner-1"},
      "notifications/runner-1/items/item-1": {uid: "runner-1"},
      "eventBroadcasts/authored": {
        actorUid: "runner-1",
        targetUids: ["runner-2"],
        deliveries: {},
      },
      "eventBroadcasts/targeted": {
        actorUid: "host-1",
        targetUids: ["runner-1", "runner-2"],
        deliveries: {
          [runnerDeliveryKey]: {
            activityStatus: "created",
            pushStatus: "accepted",
          },
          [otherDeliveryKey]: {
            activityStatus: "created",
            pushStatus: "ineligible",
          },
        },
      },
      "hostAnalyticsSnapshots/runner-1_cached": {
        uid: "runner-1",
        scopeHash: "cached",
      },
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
  assert.deepEqual(data.profilePhotos, []);
  assert.deepEqual(data.activityPreferences, {
    running: {
      paceMinSecsPerKm: 300,
      paceMaxSecsPerKm: 420,
      preferredDistances: [],
      runningReasons: [],
      preferredRunTimes: [],
      version: 1,
    },
  });

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
    "paceMinSecsPerKm",
    "paceMaxSecsPerKm",
    "preferredDistances",
    "runningReasons",
    "preferredRunTimes",
    "runPreferencesVersion",
    "fcmToken",
  ]) {
    assert.equal(hasOwn(data, field), true);
  }

  assert.ok(harness.deletedPublicDocs.includes("publicProfiles/runner-1"));
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "clubMemberships/club-1_runner-1" &&
      write.data.status === "deleted"
    )
  );
  assert.ok(
    harness.updateWrites.some((write) =>
      write.path === "clubs/club-1" &&
      write.data.memberCount !== undefined
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "eventParticipations/event-1_runner-1" &&
      write.data.status === "deleted"
    )
  );
  assert.ok(
    harness.updateWrites.some((write) =>
      write.path === "events/event-1" &&
      write.data.bookedCount !== undefined
    )
  );
  assert.ok(
    harness.deletedPublicDocs.includes("savedEvents/runner-1_run-1")
  );
  assert.ok(
    harness.deletedPublicDocs.includes(
      "profileDecisions/runner-1/outgoing/runner-2"
    )
  );
  assert.ok(
    harness.deletedPublicDocs.includes(
      "profileDecisions/runner-2/outgoing/runner-1"
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "matches/match-1" &&
      write.data.status === "blocked"
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "reviews/event-1~runner-1" &&
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
  assert.ok(harness.deletedPublicDocs.includes("eventBroadcasts/authored"));
  assert.ok(
    harness.deletedPublicDocs.includes(
      "hostAnalyticsSnapshots/runner-1_cached"
    )
  );
  const targetedBroadcastUpdate = harness.updateWrites.find(
    (write) => write.path === "eventBroadcasts/targeted"
  );
  assert.ok(targetedBroadcastUpdate);
  assert.deepEqual(targetedBroadcastUpdate.data.targetUids, ["runner-2"]);
  assert.equal(
    hasOwn(
      targetedBroadcastUpdate.data.deliveries as FakeDocumentData,
      runnerDeliveryKey
    ),
    false
  );
  assert.equal(targetedBroadcastUpdate.data.recipientCount, 1);
  assert.equal(targetedBroadcastUpdate.data.activityAvailableCount, 1);
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
    "users/runner-1/photos/grouped.jpg",
    "users/runner-1/photoThumbnails/grouped.jpg",
  ]);
  assert.equal(harness.commits, 1);
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "deletedUsers/runner-1" &&
      write.data.status === "processing"
    )
  );
  assert.ok(
    harness.setWrites.some((write) =>
      write.path === "deletedUsers/runner-1" &&
      write.data.status === "completed"
    )
  );
});

test("requestAccountDeletionHandler rate limits before destructive work",
  async () => {
    const harness = createAccountDeletionHarness({
      seed: {
        "users/runner-1": {
          profilePhotos: [{
            id: "photo-1",
            url: "https://example.com/photo.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            storagePath: "users/runner-1/photos/0_123.jpg",
            thumbnailStoragePath: "users/runner-1/photoThumbnails/0_123.jpg",
            position: 0,
          }],
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

test("requestAccountDeletionHandler short-circuits when already deleted",
  async () => {
    const harness = createAccountDeletionHarness({
      seed: {
        "deletedUsers/runner-1": {
          uid: "runner-1",
          retainedFor: ["safety", "payments", "fraud"],
        },
        "users/runner-1": {deleted: true},
        // A stale active membership must NOT be re-cleaned / re-decremented.
        "clubMemberships/club-1_runner-1": {
          clubId: "club-1",
          uid: "runner-1",
          status: "active",
        },
      },
      now: {kind: "serverTimestamp"},
    });

    const result = await requestAccountDeletionHandler(
      {auth: {uid: "runner-1"}} as Parameters<
        typeof requestAccountDeletionHandler
      >[0],
      harness.deps
    );

    assert.deepEqual(result, {deleted: true});
    // No cleanup re-ran: no batch commit, no membership/count rewrites.
    assert.equal(harness.commits, 0);
    assert.deepEqual(harness.setWrites, []);
    assert.deepEqual(harness.updateWrites, []);
    assert.deepEqual(harness.deletedPublicDocs, []);
    // The Auth user is still ensured-gone on the retry.
    assert.deepEqual(harness.deletedAuthUsers, ["runner-1"]);
  }
);

test("requestAccountDeletionHandler resumes a processing tombstone",
  async () => {
    const harness = createAccountDeletionHarness({
      seed: {
        "deletedUsers/runner-1": {
          uid: "runner-1",
          status: "processing",
          deletedAt: {kind: "oldTimestamp"},
        },
        "users/runner-1": {name: "Asha"},
      },
      now: {kind: "serverTimestamp"},
    });

    const result = await requestAccountDeletionHandler(
      {auth: {uid: "runner-1"}} as Parameters<
        typeof requestAccountDeletionHandler
      >[0],
      harness.deps
    );

    assert.deepEqual(result, {deleted: true});
    assert.equal(harness.commits, 1);
    assert.ok(
      harness.setWrites.some((write) =>
        write.path === "deletedUsers/runner-1" &&
        write.data.status === "completed"
      )
    );
  }
);

test("requestAccountDeletionHandler tolerates an already-removed Auth user",
  async () => {
    const harness = createAccountDeletionHarness({
      seed: {"users/runner-1": {}},
      now: {kind: "serverTimestamp"},
    });

    const result = await requestAccountDeletionHandler(
      {auth: {uid: "runner-1"}} as Parameters<
        typeof requestAccountDeletionHandler
      >[0],
      {
        ...harness.deps,
        auth: () => ({
          deleteUser: async () => {
            throw Object.assign(new Error("no user"), {
              code: "auth/user-not-found",
            });
          },
        }) as unknown as admin.auth.Auth,
      }
    );

    assert.deepEqual(result, {deleted: true});
    // The tombstone is still written so a later retry short-circuits.
    assert.ok(
      harness.setWrites.some((write) => write.path === "deletedUsers/runner-1")
    );
  }
);

type FakeDocumentData = Record<string, unknown>;

interface FakeDocumentReference {
  path: string;
  collectionPath: string;
  docId: string;
  ref: FakeDocumentReference;
  data: () => FakeDocumentData | undefined;
  get: () => Promise<{
    exists: boolean;
    data: () => FakeDocumentData | undefined;
  }>;
  set: (data: FakeDocumentData, options?: {merge: boolean}) => Promise<void>;
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
    const path = `${collectionPath}/${docId}`;
    const ref = {
      path,
      collectionPath,
      docId,
      data: () => seed[path],
      get: async () => ({
        exists: seed[path] !== undefined,
        data: () => seed[path],
      }),
      set: async (data: FakeDocumentData, options?: {merge: boolean}) => {
        setWrites.push({path, data, options});
        seed[path] = options?.merge ? {...seed[path], ...data} : data;
      },
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
