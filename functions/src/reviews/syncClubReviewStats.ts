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
  organizerId: string,
  deps: SyncClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const organizerRef = db.collection("organizers").doc(organizerId);
  const organizerSnap = await organizerRef.get();

  if (!organizerSnap.exists) {
    return;
  }

  const publishedReviews = db
    .collection("reviews")
    .where("organizerId", "==", organizerId)
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

  const projection = {
    rating: verifiedReviewCount === 0 ? 0 : averageRating ?? 0,
    reviewCount,
    verifiedReviewCount,
  };
  const batch = db.batch();
  batch.set(organizerRef, projection, {merge: true});
  batch.set(db.collection("clubs").doc(organizerId), projection, {merge: true});
  await batch.commit();
}

/**
 * Recomputes all club review aggregates affected by a review write.
 * @param {ReviewDocument | undefined} before Review document before state.
 * @param {ReviewDocument | undefined} after Review document after state.
 * @param {SyncClubReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncClubReviewStatsHandler(
  before: {organizerId?: string; clubId?: string} | undefined,
  after: {organizerId?: string; clubId?: string} | undefined,
  deps: SyncClubReviewStatsDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();

  if (before?.organizerId ?? before?.clubId) {
    organizerIds.add(before.organizerId ?? before!.clubId!);
  }
  if (after?.organizerId ?? after?.clubId) {
    organizerIds.add(after.organizerId ?? after!.clubId!);
  }

  await Promise.all(
    Array.from(organizerIds).map(
      (organizerId) => refreshClubReviewStats(organizerId, deps)
    )
  );
}

export const syncClubReviewStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as
      {organizerId?: string; clubId?: string} | undefined;
    const after = event.data?.after.data() as
      {organizerId?: string; clubId?: string} | undefined;
    await syncClubReviewStatsHandler(before, after);
  }
);
