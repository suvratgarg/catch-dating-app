import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {AggregateField} from "firebase-admin/firestore";

interface SyncOrganizerReviewStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncOrganizerReviewStatsDeps = {
  firestore: () => admin.firestore(),
};

/**
 * Recomputes the denormalized rating and review counts for one organizer.
 *
 * Trust model: the headline {@code rating} is computed from VERIFIED reviews
 * only (those created after an attended Catch event), so unverified
 * public-listing reviews — which anyone can submit — can never move an
 * organizer's
 * score. {@code reviewCount} still reflects every published review so the
 * listing page count matches what is rendered, and {@code verifiedReviewCount}
 * exposes how many of those actually back the rating.
 *
 * The counts and rating come from Firestore aggregation queries
 * (count()/average()) rather than reading every review document, so the cost
 * of this trigger stays bounded as an organizer accumulates reviews.
 * @param {string} organizerId
 * @param {SyncOrganizerReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshOrganizerReviewStats(
  organizerId: string,
  deps: SyncOrganizerReviewStatsDeps = defaultDeps
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
  await organizerRef.set(projection, {merge: true});
}

/**
 * Recomputes all organizer review aggregates affected by a review write.
 * @param {ReviewDocument | undefined} before Review document before state.
 * @param {ReviewDocument | undefined} after Review document after state.
 * @param {SyncOrganizerReviewStatsDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncOrganizerReviewStatsHandler(
  before: {organizerId?: string} | undefined,
  after: {organizerId?: string} | undefined,
  deps: SyncOrganizerReviewStatsDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();

  if (before?.organizerId) {
    organizerIds.add(before.organizerId);
  }
  if (after?.organizerId) {
    organizerIds.add(after.organizerId);
  }

  await Promise.all(
    Array.from(organizerIds).map(
      (organizerId) => refreshOrganizerReviewStats(organizerId, deps)
    )
  );
}

export const syncOrganizerReviewStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as
      {organizerId?: string} | undefined;
    const after = event.data?.after.data() as
      {organizerId?: string} | undefined;
    await syncOrganizerReviewStatsHandler(before, after);
  }
);
