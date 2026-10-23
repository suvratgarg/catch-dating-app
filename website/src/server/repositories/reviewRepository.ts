import type {HostListing} from "../../features/organizers/types";
import {projectPublicReview} from "../publicReviewProjection";
import {withinReadDeadline, type PublicReader} from "./publicReader";

const reviewBound = 50;

/** Two bounded reads at most, only for a resolved detail route. Never fan out across discovery. */
export async function withPublicReviews(
  db: PublicReader,
  listing: HostListing,
  eventId?: string
): Promise<HostListing> {
  if (listing.capabilities.publicReviews.readState !== "enabled") return listing;
  try {
    const reviews = db.collection("reviews");
    const snapshots = await withinReadDeadline(Promise.all([
      reviews.where("organizerId", "==", listing.id).orderBy("createdAt", "desc").limit(reviewBound).get(),
      ...(eventId ? [reviews.where("eventId", "==", eventId).orderBy("createdAt", "desc").limit(reviewBound).get()] : []),
    ]));
    const published = snapshots.flatMap((snapshot) => snapshot.docs.flatMap((doc) => {
      const review = projectPublicReview(doc.id, doc.data(), listing.id);
      return review ? [review] : [];
    }));
    return {...listing, reviewReadState: "ready", reviews: [...new Map(published.map((review) => [review.id, review])).values()]
      .sort((a, b) => Date.parse(b.createdAt) - Date.parse(a.createdAt))};
  } catch {
    // A missing index or transient read failure must not erase the event or imply zero reviews.
    return {...listing, reviews: [], reviewReadState: "unavailable"};
  }
}
