/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  refreshClubReviewStats,
  syncClubReviewStatsHandler,
} from "./syncClubReviewStats";

test("refreshClubReviewStats recomputes rating and count", async () => {
  const firestore = fakeFirestore({
    "clubs/club-1": {rating: 0, reviewCount: 0},
    "reviews/review-1": {clubId: "club-1", rating: 5},
    "reviews/review-2": {clubId: "club-1", rating: 3},
    "reviews/review-3": {clubId: "club-2", rating: 1},
  });

  await refreshClubReviewStats("club-1", {
    firestore: () => firestore as never,
  });

  assert.deepEqual(firestore.get("clubs/club-1"), {
    rating: 4,
    reviewCount: 2,
  });
});

test("refreshClubReviewStats resets aggregate after last review deletion",
  async () => {
    const firestore = fakeFirestore({
      "clubs/club-1": {rating: 4.5, reviewCount: 2},
    });

    await refreshClubReviewStats("club-1", {
      firestore: () => firestore as never,
    });

    assert.deepEqual(firestore.get("clubs/club-1"), {
      rating: 0,
      reviewCount: 0,
    });
  }
);

test("syncClubReviewStatsHandler refreshes moved review clubs", async () => {
  const refreshed: string[] = [];
  const firestore = fakeFirestore({
    "clubs/club-1": {rating: 0, reviewCount: 0},
    "clubs/club-2": {rating: 0, reviewCount: 0},
  });

  const deps = {
    firestore: () => ({
      ...firestore,
      collection: (path: string) => {
        if (path === "clubs") {
          return {
            doc: (id: string) => {
              refreshed.push(id);
              return firestore.collection(path).doc(id);
            },
          };
        }
        return firestore.collection(path);
      },
    }) as never,
  };

  await syncClubReviewStatsHandler(
    {clubId: "club-1"} as never,
    {clubId: "club-2"} as never,
    deps
  );

  assert.deepEqual(refreshed.sort(), ["club-1", "club-2"]);
});

function fakeFirestore(initialDocs: Record<string, Record<string, unknown>>) {
  const docs = structuredClone(initialDocs);
  return {
    get: (path: string) => docs[path],
    collection: (collectionPath: string) => ({
      doc: (docId: string) => docRef(`${collectionPath}/${docId}`),
      where: (field: string, operator: string, value: unknown) => {
        assert.equal(operator, "==");
        return {
          get: async () => ({
            docs: Object.entries(docs)
              .filter(([path]) => path.startsWith(`${collectionPath}/`))
              .filter(([, data]) => data[field] === value)
              .map(([, data]) => ({data: () => ({...data})})),
          }),
        };
      },
    }),
  };

  function docRef(path: string) {
    return {
      get: async () => ({
        exists: docs[path] !== undefined,
        data: () => docs[path],
      }),
      set: async (
        patch: Record<string, unknown>,
        options: {merge: boolean}
      ) => {
        docs[path] = options.merge ? {...docs[path], ...patch} : patch;
      },
    };
  }
}
