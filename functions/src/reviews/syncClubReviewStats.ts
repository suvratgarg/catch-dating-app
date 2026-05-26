import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {
  ReviewDocument,
} from "../shared/generated/firestoreAdminTypes";

interface SyncClubReviewStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncClubReviewStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized rating and review count for one club.
 * @param {string} clubId
 * @param {SyncClubReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshClubReviewStats(
  clubId: string,
  deps: SyncClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("clubs").doc(clubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const reviewsSnap = await db
    .collection("reviews")
    .where("clubId", "==", clubId)
    .get();

  const reviews = reviewsSnap.docs.map((doc) => doc.data() as ReviewDocument);
  const reviewCount = reviews.length;
  const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);

  await clubRef.set({
    rating: reviewCount == 0 ? 0 : totalRating / reviewCount,
    reviewCount,
  }, {merge: true});
}

/**
 * Recomputes all club review aggregates affected by a review write.
 * @param {ReviewDocument | undefined} before Review document before state.
 * @param {ReviewDocument | undefined} after Review document after state.
 * @param {SyncClubReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncClubReviewStatsHandler(
  before: ReviewDocument | undefined,
  after: ReviewDocument | undefined,
  deps: SyncClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const clubIds = new Set<string>();

  if (before?.clubId) {
    clubIds.add(before.clubId);
  }
  if (after?.clubId) {
    clubIds.add(after.clubId);
  }

  await Promise.all(
    Array.from(clubIds).map(
      (clubId) => refreshClubReviewStats(clubId, deps)
    )
  );
}

export const syncClubReviewStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as ReviewDocument | undefined;
    const after = event.data?.after.data() as ReviewDocument | undefined;
    await syncClubReviewStatsHandler(before, after);
  }
);
