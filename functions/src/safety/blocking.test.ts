/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  blockUserHandler,
  blockDocId,
  blockDocIdsForPairs,
  hasBlockingRelationship,
  unblockUserHandler,
} from "./blocking";

test("blockDocId builds directed block ids", () => {
  assert.equal(blockDocId("runner-1", "runner-2"), "runner-1__runner-2");
});

test("blockDocIdsForPairs checks both directions for each unique peer", () => {
  assert.deepEqual(
    blockDocIdsForPairs("runner-1", ["runner-2", "runner-2", "runner-1"]),
    ["runner-1__runner-2", "runner-2__runner-1"]
  );
});

test(
  "hasBlockingRelationship returns true when either edge exists",
  async () => {
    const db = createBlockFirestore(new Set(["runner-2__runner-1"]));

    assert.equal(
      await hasBlockingRelationship(db, "runner-1", ["runner-2"]),
      true
    );
    assert.equal(
      await hasBlockingRelationship(db, "runner-1", ["runner-3"]),
      false
    );
  }
);

test("blockUserHandler rate limits before writing block edges", async () => {
  let collectionUsed = false;

  await assert.rejects(
    blockUserHandler(
      buildRequest("runner-1", {targetUserId: "runner-2"}),
      {
        firestore: () => ({
          collection: () => {
            collectionUsed = true;
            throw new Error("Firestore writes should not be reached.");
          },
        }) as unknown as FirebaseFirestore.Firestore,
        serverTimestamp: () => ({}) as FirebaseFirestore.FieldValue,
        checkRateLimit: async (_db, uid, action) => {
          assert.equal(uid, "runner-1");
          assert.equal(action, "blockUser");
          throw new HttpsError("resource-exhausted", "Too many blocks.");
        },
      }
    ),
    (error) =>
      error instanceof HttpsError && error.code === "resource-exhausted"
  );

  assert.equal(collectionUsed, false);
});

test("unblockUserHandler rate limits before deleting block edges", async () => {
  let collectionUsed = false;

  await assert.rejects(
    unblockUserHandler(
      buildRequest("runner-1", {targetUserId: "runner-2"}),
      {
        firestore: () => ({
          collection: () => {
            collectionUsed = true;
            throw new Error("Firestore deletes should not be reached.");
          },
        }) as unknown as FirebaseFirestore.Firestore,
        serverTimestamp: () => ({}) as FirebaseFirestore.FieldValue,
        checkRateLimit: async (_db, uid, action) => {
          assert.equal(uid, "runner-1");
          assert.equal(action, "unblockUser");
          throw new HttpsError("resource-exhausted", "Too many unblocks.");
        },
      }
    ),
    (error) =>
      error instanceof HttpsError && error.code === "resource-exhausted"
  );

  assert.equal(collectionUsed, false);
});

function createBlockFirestore(
  existingDocIds: Set<string>
): FirebaseFirestore.Firestore {
  return {
    collection: (path: string) => {
      assert.equal(path, "blocks");
      return {
        doc: (id: string) => ({
          get: async () => ({exists: existingDocIds.has(id)}),
        }),
      };
    },
  } as unknown as FirebaseFirestore.Firestore;
}

function buildRequest(
  uid: string,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: {uid, token: {}} as CallableRequest["auth"],
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}
