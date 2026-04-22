import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {ReviewDoc} from "../types/firestore";

/**
 * Recomputes the denormalized rating and review count for one run club.
 * @param {string} runClubId
 * @return {Promise<void>}
 */
async function refreshRunClubReviewStats(runClubId: string): Promise<void> {
  const db = admin.firestore();
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

export const syncRunClubReviewStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as ReviewDoc | undefined;
    const after = event.data?.after.data() as ReviewDoc | undefined;
    const runClubIds = new Set<string>();

    if (before?.runClubId) {
      runClubIds.add(before.runClubId);
    }
    if (after?.runClubId) {
      runClubIds.add(after.runClubId);
    }

    await Promise.all(
      Array.from(runClubIds).map(
        (runClubId) => refreshRunClubReviewStats(runClubId)
      )
    );
  }
);
