/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
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
    photoUrls: [
      "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
        "users%2Frunner-1%2Fphotos%2F0_123.jpg?alt=media&token=abc",
    ],
    name: "Asha Runner",
    dateOfBirth: admin.firestore.Timestamp.fromDate(
      new Date("1995-01-01T00:00:00.000Z")
    ),
    phoneNumber: "+919876543210",
    savedRunIds: ["run-1"],
    languages: ["english"],
    paceMinSecsPerKm: 300,
    preferredDistances: ["tenK"],
    runningReasons: ["community"],
  }, now);

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
  assert.equal(
    (data.dateOfBirth as FirebaseFirestore.Timestamp).toMillis(),
    0
  );
  assert.equal(data.phoneNumber, "");
  assert.deepEqual(data.photoUrls, []);
  assert.deepEqual(data.savedRunIds, []);
  assert.deepEqual(data.preferredDistances, []);
  assert.deepEqual(data.runningReasons, []);
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

  assert.deepEqual(harness.deletedPublicDocs, ["publicProfiles/runner-1"]);
  assert.deepEqual(harness.deletedAuthUsers, ["runner-1"]);
  assert.deepEqual(harness.deletedStorageFiles, [
    "users/runner-1/photos/0_123.jpg",
  ]);
  assert.equal(harness.commits, 1);
});

type FakeDocumentData = Record<string, unknown>;

interface FakeDocumentReference {
  path: string;
  collectionPath: string;
  docId: string;
  get: () => Promise<{data: () => FakeDocumentData | undefined}>;
}

interface SetWrite {
  path: string;
  data: FakeDocumentData;
  options?: {merge: boolean};
}

function createAccountDeletionHarness(
  userData: FakeDocumentData,
  now: unknown
) {
  const setWrites: SetWrite[] = [];
  const deletedPublicDocs: string[] = [];
  const deletedAuthUsers: string[] = [];
  const deletedStorageFiles: string[] = [];
  let commits = 0;

  const docFor = (
    collectionPath: string,
    docId: string
  ): FakeDocumentReference => ({
    path: `${collectionPath}/${docId}`,
    collectionPath,
    docId,
    get: async () => ({
      data: () =>
        collectionPath === "users" && docId === "runner-1" ?
          userData :
          undefined,
    }),
  });

  const firestore = {
    collection: (collectionPath: string) => ({
      doc: (docId: string) => docFor(collectionPath, docId),
    }),
    batch: () => ({
      set: (
        ref: FakeDocumentReference,
        data: FakeDocumentData,
        options?: {merge: boolean}
      ) => setWrites.push({path: ref.path, data, options}),
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
      serverTimestamp: () => now as FirebaseFirestore.FieldValue,
    },
    setWrites,
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
