import assert from "node:assert/strict";
import test from "node:test";
import {
  applyReviewAuthorProfileRepairPlan,
  buildReviewAuthorProfileRepairPlan,
} from "./recompute_review_author_profiles.mjs";

const projection = {
  publicDisplayName: (user) =>
    user.displayName?.trim() || user.firstName?.trim() || "Runner",
};

test("buildReviewAuthorProfileRepairPlan finds stale reviewer names",
  async () => {
    const firestore = fakeFirestore({
      users: {
        "reviewer-1": {displayName: "New Reviewer"},
        "reviewer-2": {firstName: "Stable"},
      },
      reviews: {
        "run-1~reviewer-1": {
          reviewerUserId: "reviewer-1",
          reviewerName: "Old Reviewer",
        },
        "run-2~reviewer-2": {
          reviewerUserId: "reviewer-2",
          reviewerName: "Stable",
        },
        "run-3~missing": {
          reviewerUserId: "missing",
          reviewerName: "Missing",
        },
      },
    });

    const plan = await buildReviewAuthorProfileRepairPlan(
      firestore,
      projection
    );

    assert.deepEqual(plan.summary.repairs, [
      {
        path: "reviews/run-1~reviewer-1",
        reviewId: "run-1~reviewer-1",
        reviewerUserId: "reviewer-1",
        current: {reviewerName: "Old Reviewer"},
        expected: {reviewerName: "New Reviewer"},
      },
    ]);
    assert.deepEqual(plan.summary.warnings, [
      "reviews/run-3~missing references missing users/missing.",
    ]);
  }
);

test("applyReviewAuthorProfileRepairPlan writes only reviewer names",
  async () => {
    const firestore = fakeFirestore({
      users: {},
      reviews: {
        "run-1~reviewer-1": {reviewerName: "Old", rating: 5},
        "run-2~reviewer-1": {reviewerName: "Stable", rating: 4},
      },
    });

    await applyReviewAuthorProfileRepairPlan(firestore, {
      repairs: [
        {
          path: "reviews/run-1~reviewer-1",
          expected: {reviewerName: "New"},
        },
      ],
    });

    assert.deepEqual(firestore.data.reviews["run-1~reviewer-1"], {
      reviewerName: "New",
      rating: 5,
    });
    assert.equal(
      firestore.data.reviews["run-2~reviewer-1"].reviewerName,
      "Stable"
    );
  }
);

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    data,
    collection: (collectionName) => ({
      get: async () => ({
        size: Object.keys(data[collectionName] ?? {}).length,
        docs: Object.entries(data[collectionName] ?? {}).map(([id, value]) =>
          docSnapshot(collectionName, id, value)
        ),
      }),
    }),
    doc: (documentPath) => ({
      path: documentPath,
      update: (patch) => {
        const [collectionName, docId] = documentPath.split("/");
        data[collectionName][docId] = {
          ...data[collectionName][docId],
          ...patch,
        };
      },
    }),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch) => writes.push(() => ref.update(patch)),
        commit: async () => {
          for (const write of writes) write();
        },
      };
    },
  };
}

function docSnapshot(collectionName, id, value) {
  return {
    id,
    ref: {path: `${collectionName}/${id}`},
    data: () => ({...value}),
  };
}
