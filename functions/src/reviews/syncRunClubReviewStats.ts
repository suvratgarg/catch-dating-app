import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {ReviewDoc} from "../shared/firestore";

interface SyncRunClubReviewStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncRunClubReviewStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized rating and review count for one run club.
 * @param {string} runClubId
 * @param {SyncRunClubReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshRunClubReviewStats(
  runClubId: string,
  deps: SyncRunClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("runClubs").doc(runClubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const reviewsSnap = await db
    .collection("reviews")
    .where("runClubId", "==", runClubId)
    .get();

  const reviews = reviewsSnap.docs.map((doc) => doc.data() as ReviewDoc);
  const reviewCount = reviews.length;
  const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);

  await clubRef.set({
    rating: reviewCount == 0 ? 0 : totalRating / reviewCount,
    reviewCount,
  }, {merge: true});
}

/**
 * Recomputes all run-club review aggregates affected by a review write.
 * @param {ReviewDoc | undefined} before Review document before state.
 * @param {ReviewDoc | undefined} after Review document after state.
 * @param {SyncRunClubReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncRunClubReviewStatsHandler(
  before: ReviewDoc | undefined,
  after: ReviewDoc | undefined,
  deps: SyncRunClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const runClubIds = new Set<string>();

  if (before?.runClubId) {
    runClubIds.add(before.runClubId);
  }
  if (after?.runClubId) {
    runClubIds.add(after.runClubId);
  }

  await Promise.all(
    Array.from(runClubIds).map(
      (runClubId) => refreshRunClubReviewStats(runClubId, deps)
    )
  );
}

export const syncRunClubReviewStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as ReviewDoc | undefined;
    const after = event.data?.after.data() as ReviewDoc | undefined;
    await syncRunClubReviewStatsHandler(before, after);
  }
);
