import assert from "node:assert/strict";
import test from "node:test";
import {
  refreshClubReviewStats,
  syncClubReviewStatsHandler,
} from "./syncClubReviewStats";

test("rating reflects verified published reviews only", async () => {
  const firestore = fakeFirestore({
    "organizers/club-1": {rating: 0, reviewCount: 0},
    "clubs/club-1": {rating: 0, reviewCount: 0},
    // Two verified, published reviews: 5 and 3 -> average 4.
    "reviews/r1": review("club-1", 5, "verified", "published"),
    "reviews/r2": review("club-1", 3, "verified", "published"),
    // Unverified public review with a 1 must NOT drag the score down.
    "reviews/r3": review("club-1", 1, "unverified", "published"),
    // Another club's review is ignored entirely.
    "reviews/r4": review("club-2", 1, "verified", "published"),
  });

  await refreshClubReviewStats("club-1", {firestore: () => firestore as never});

  const organizer = firestore.get("organizers/club-1");
  assert.equal(organizer?.rating, 4);
  assert.equal(organizer?.reviewCount, 3);
  assert.equal(organizer?.verifiedReviewCount, 2);
  assert.deepEqual(firestore.get("clubs/club-1"), organizer);
});

test("rating is zero when no verified reviews back it", async () => {
  const firestore = fakeFirestore({
    "organizers/club-1": {rating: 4.5, reviewCount: 0},
    "reviews/r1": review("club-1", 5, "unverified", "published"),
    "reviews/r2": review("club-1", 4, "unverified", "published"),
  });

  await refreshClubReviewStats("club-1", {firestore: () => firestore as never});

  const organizer = firestore.get("organizers/club-1");
  assert.equal(organizer?.rating, 0);
  assert.equal(organizer?.reviewCount, 2);
  assert.equal(organizer?.verifiedReviewCount, 0);
});

test("pending and rejected reviews are excluded from both counts",
  async () => {
    const firestore = fakeFirestore({
      "organizers/club-1": {rating: 0, reviewCount: 0},
      "reviews/r1": review("club-1", 5, "verified", "published"),
      "reviews/r2": review("club-1", 1, "verified", "pending"),
      "reviews/r3": review("club-1", 1, "verified", "rejected"),
      "reviews/r4": review("club-1", 4, "unverified", "published"),
    });

    await refreshClubReviewStats("club-1", {
      firestore: () => firestore as never,
    });

    const organizer = firestore.get("organizers/club-1");
    assert.equal(organizer?.rating, 5);
    assert.equal(organizer?.reviewCount, 2);
    assert.equal(organizer?.verifiedReviewCount, 1);
  }
);

test("aggregate resets to zero after the last review is removed", async () => {
  const firestore = fakeFirestore({
    "organizers/club-1": {
      rating: 4.5,
      reviewCount: 2,
      verifiedReviewCount: 2,
    },
  });

  await refreshClubReviewStats("club-1", {firestore: () => firestore as never});

  const organizer = firestore.get("organizers/club-1");
  assert.equal(organizer?.rating, 0);
  assert.equal(organizer?.reviewCount, 0);
  assert.equal(organizer?.verifiedReviewCount, 0);
});

test("missing club is a no-op", async () => {
  const firestore = fakeFirestore({
    "reviews/r1": review("club-1", 5, "verified", "published"),
  });

  await refreshClubReviewStats("club-1", {firestore: () => firestore as never});

  assert.equal(firestore.get("organizers/club-1"), undefined);
});

test("syncClubReviewStatsHandler refreshes moved review clubs", async () => {
  const refreshed: string[] = [];
  const firestore = fakeFirestore({
    "organizers/club-1": {rating: 0, reviewCount: 0},
    "organizers/club-2": {rating: 0, reviewCount: 0},
  });

  const deps = {
    firestore: () => ({
      ...firestore,
      collection: (path: string) => {
        if (path === "organizers") {
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
    {organizerId: "club-1"},
    {organizerId: "club-2"},
    deps
  );

  assert.deepEqual(refreshed.sort(), ["club-1", "club-2"]);
});

function review(
  organizerId: string,
  rating: number,
  verificationStatus: string,
  moderationStatus: string
) {
  return {
    organizerId,
    clubId: organizerId,
    rating,
    verificationStatus,
    moderationStatus,
  };
}

function fakeFirestore(initialDocs: Record<string, Record<string, unknown>>) {
  const docs = structuredClone(initialDocs);
  return {
    get: (path: string) => docs[path],
    collection: (collectionPath: string) => queryRef(collectionPath, []),
    batch: () => {
      const writes: Array<{
        ref: ReturnType<typeof docRef>;
        patch: Record<string, unknown>;
        options: {merge: boolean};
      }> = [];
      return {
        set: (
          ref: ReturnType<typeof docRef>,
          patch: Record<string, unknown>,
          options: {merge: boolean}
        ) => writes.push({ref, patch, options}),
        commit: async () => {
          await Promise.all(
            writes.map(({ref, patch, options}) => ref.set(patch, options))
          );
        },
      };
    },
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

  function queryRef(
    collectionPath: string,
    filters: Array<{field: string; value: unknown}>
  ) {
    const matching = () =>
      Object.entries(docs)
        .filter(([path]) => path.startsWith(`${collectionPath}/`))
        .filter(([, data]) =>
          filters.every((filter) => data[filter.field] === filter.value)
        )
        .map(([, data]) => data);

    return {
      doc: (docId: string) => docRef(`${collectionPath}/${docId}`),
      where: (field: string, operator: string, value: unknown) => {
        assert.equal(operator, "==");
        return queryRef(collectionPath, [...filters, {field, value}]);
      },
      count: () => ({
        get: async () => ({data: () => ({count: matching().length})}),
      }),
      aggregate: () => ({
        get: async () => {
          const rows = matching();
          const ratings = rows.map((row) => Number(row.rating ?? 0));
          const averageRating = ratings.length === 0 ?
            null :
            ratings.reduce((sum, value) => sum + value, 0) / ratings.length;
          return {data: () => ({count: rows.length, averageRating})};
        },
      }),
    };
  }
}
