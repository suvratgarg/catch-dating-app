/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  refreshRunClubReviewStats,
  syncRunClubReviewStatsHandler,
} from "./syncRunClubReviewStats";

test("refreshRunClubReviewStats recomputes rating and count", async () => {
  const firestore = fakeFirestore({
    "runClubs/club-1": {rating: 0, reviewCount: 0},
    "reviews/review-1": {runClubId: "club-1", rating: 5},
    "reviews/review-2": {runClubId: "club-1", rating: 3},
    "reviews/review-3": {runClubId: "club-2", rating: 1},
  });

  await refreshRunClubReviewStats("club-1", {
    firestore: () => firestore as never,
  });

  assert.deepEqual(firestore.get("runClubs/club-1"), {
    rating: 4,
    reviewCount: 2,
  });
});

test("refreshRunClubReviewStats resets aggregate after last review deletion",
  async () => {
    const firestore = fakeFirestore({
      "runClubs/club-1": {rating: 4.5, reviewCount: 2},
    });

    await refreshRunClubReviewStats("club-1", {
      firestore: () => firestore as never,
    });

    assert.deepEqual(firestore.get("runClubs/club-1"), {
      rating: 0,
      reviewCount: 0,
    });
  }
);

test("syncRunClubReviewStatsHandler refreshes moved review clubs", async () => {
  const refreshed: string[] = [];
  const firestore = fakeFirestore({
    "runClubs/club-1": {rating: 0, reviewCount: 0},
    "runClubs/club-2": {rating: 0, reviewCount: 0},
  });

  const deps = {
    firestore: () => ({
      ...firestore,
      collection: (path: string) => {
        if (path === "runClubs") {
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

  await syncRunClubReviewStatsHandler(
    {runClubId: "club-1"} as never,
    {runClubId: "club-2"} as never,
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
