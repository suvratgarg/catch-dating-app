/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  blockDocId,
  blockDocIdsForPairs,
  hasBlockingRelationship,
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
