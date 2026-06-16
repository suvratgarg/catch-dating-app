import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {AggregateField} from "firebase-admin/firestore";

interface SyncClubReviewStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncClubReviewStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized rating and review counts for one club.
 *
 * Trust model: the headline {@code rating} is computed from VERIFIED reviews
 * only (those created after an attended Catch event), so unverified
 * public-listing reviews — which anyone can submit — can never move a club's
 * score. {@code reviewCount} still reflects every published review so the
 * listing page count matches what is rendered, and {@code verifiedReviewCount}
 * exposes how many of those actually back the rating.
 *
 * The counts and rating come from Firestore aggregation queries
 * (count()/average()) rather than reading every review document, so the cost
 * of this trigger stays bounded as a club accumulates reviews.
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

  const publishedReviews = db
    .collection("reviews")
    .where("clubId", "==", clubId)
    .where("moderationStatus", "==", "published");

  const [publishedAgg, verifiedAgg] = await Promise.all([
    publishedReviews.count().get(),
    publishedReviews
      .where("verificationStatus", "==", "verified")
      .aggregate({
        count: AggregateField.count(),
        averageRating: AggregateField.average("rating"),
      })
      .get(),
  ]);

  const reviewCount = publishedAgg.data().count;
  const verifiedReviewCount = verifiedAgg.data().count;
  const averageRating = verifiedAgg.data().averageRating;

  await clubRef.set({
    rating: verifiedReviewCount === 0 ? 0 : averageRating ?? 0,
    reviewCount,
    verifiedReviewCount,
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
  before: {clubId?: string} | undefined,
  after: {clubId?: string} | undefined,
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
    const before = event.data?.before.data() as {clubId?: string} | undefined;
    const after = event.data?.after.data() as {clubId?: string} | undefined;
    await syncClubReviewStatsHandler(before, after);
  }
);
