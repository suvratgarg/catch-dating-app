import {websiteCopy} from "@content/generated";
import type {PublicReviewCardModel} from "../../shared/ui/primitives";
import type {HostListing, HostListingReview} from "../organizers/types";

export interface ListingReviewSummary {
  displayRating: number;
  displayReviewCount: number;
  ownerPromptStats: Array<{label: string; value: number}>;
  publicReviews: PublicReviewCardModel[];
  verifiedCount: number;
  verifiedReviews: PublicReviewCardModel[];
}

export function buildListingReviewSummary(
  listing: HostListing,
  reviews: HostListingReview[]
): ListingReviewSummary {
  const seedReviews = listing.reviews ?? [];
  const seedReviewKeys = new Set(seedReviews.map(reviewKey));
  const aggregateReviewCount = listing.metrics?.reviewCount;
  const aggregateRating = listing.metrics?.rating;
  let supplementalReviewCount = 0;
  let visibleVerifiedRatingTotal = 0;
  let visibleVerifiedCount = 0;
  let ownerResponseCount = 0;
  const publicReviews: PublicReviewCardModel[] = [];
  const verifiedReviews: PublicReviewCardModel[] = [];

  for (const review of reviews) {
    const key = reviewKey(review);
    const verified = isVerifiedReview(review);
    if (!seedReviewKeys.has(key)) {
      supplementalReviewCount += 1;
    }
    if (verified) {
      visibleVerifiedCount += 1;
      visibleVerifiedRatingTotal += review.rating;
    }
    if (review.ownerResponse) ownerResponseCount += 1;

    const card = reviewCardForReview(review, verified, key);
    if (verified) {
      verifiedReviews.push(card);
    } else {
      publicReviews.push(card);
    }
  }

  const displayReviewCount = aggregateReviewCount !== undefined ?
    aggregateReviewCount + supplementalReviewCount :
    reviews.length;
  const visibleVerifiedRatingAverage = visibleVerifiedCount ?
    visibleVerifiedRatingTotal / visibleVerifiedCount :
    0;
  // The canonical aggregate is verified-review-only. Public listing reviews
  // may increase the published review count, but never move this score.
  const displayRating = aggregateRating ?? visibleVerifiedRatingAverage;
  const aggregateVerifiedCount = (
    listing.metrics as (HostListing["metrics"] & {verifiedReviewCount?: number}) | undefined
  )?.verifiedReviewCount;
  const verifiedCount = aggregateVerifiedCount ?? visibleVerifiedCount;

  return {
    displayRating,
    displayReviewCount,
    ownerPromptStats: [
      {label: websiteCopy["reviewmodel_0500"], value: ownerResponseCount},
      {label: websiteCopy["reviewmodel_0501"], value: verifiedCount},
      {label: websiteCopy["reviewmodel_0499"], value: publicReviews.length},
    ],
    publicReviews,
    verifiedCount,
    verifiedReviews,
  };
}

export function mergeReviews(
  incoming: HostListingReview[],
  existing: HostListingReview[]
): HostListingReview[] {
  const seen = new Set<string>();
  const merged: HostListingReview[] = [];
  for (const review of [...incoming, ...existing]) {
    const key = reviewKey(review);
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push(review);
  }
  return merged.sort(
    (a, b) => reviewTime(b.createdAt) - reviewTime(a.createdAt)
  );
}

export function reviewKey(review: HostListingReview): string {
  return review.id ?? `${review.reviewerName}-${review.createdAt}`;
}

function reviewTime(value: string): number {
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? 0 : parsed;
}

function reviewDateLabel(value: string): string {
  const parsed = Date.parse(value);
  if (Number.isNaN(parsed)) return value;
  const elapsedMs = Date.now() - parsed;
  if (elapsedMs >= 0 && elapsedMs < 60 * 1000) return "Just now";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(new Date(parsed));
}

function isVerifiedReview(review: HostListingReview) {
  return review.verificationStatus === "verified" ||
    (!review.verificationStatus && review.source !== "publicListing");
}

function reviewCardForReview(
  review: HostListingReview,
  verified: boolean,
  key: string
): PublicReviewCardModel {
  return {
    id: key,
    reviewerName: review.reviewerName,
    createdAtLabel: reviewDateLabel(review.createdAt),
    rating: review.rating,
    comment: review.comment,
    verified,
    verificationLabel: verified ? "Verified Catch attendee" : "Unverified public review",
    sourceLabel: review.source === "catchEvent" ? "Catch event" : "Public web",
    ownerResponse: review.ownerResponse ? {
      hostName: review.ownerResponse.hostName,
      message: review.ownerResponse.message,
      updatedAtLabel: reviewDateLabel(review.ownerResponse.updatedAt),
    } : null,
  };
}
