import {describe, expect, it} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing, HostListingReview} from "../organizers/types";
import {buildListingReviewSummary} from "./reviewModel";

function review(
  id: string,
  rating: number,
  verificationStatus: "verified" | "unverified"
): HostListingReview {
  return {
    id,
    reviewerName: `Reviewer ${id}`,
    rating,
    comment: "Review comment",
    createdAt: "2026-07-13T08:00:00.000Z",
    verificationStatus,
    source: verificationStatus === "verified" ? "catchEvent" : "publicListing",
    isAnonymous: false,
    ownerResponse: null,
  };
}

describe("buildListingReviewSummary", () => {
  it("never lets an unverified public review move the verified headline rating", () => {
    const verifiedReviews = [review("verified-1", 5, "verified"), review("verified-2", 3, "verified")];
    const listing = {
      ...hostListings[0],
      metrics: {rating: 4, reviewCount: 2, verifiedReviewCount: 2},
      reviews: verifiedReviews,
    } as HostListing;

    const summary = buildListingReviewSummary(listing, [
      ...verifiedReviews,
      review("public-1", 1, "unverified"),
    ]);

    expect(summary.displayRating).toBe(4);
    expect(summary.displayReviewCount).toBe(3);
    expect(summary.verifiedCount).toBe(2);
    expect(summary.publicReviews).toHaveLength(1);
  });

  it("does not manufacture a rating from public-only reviews", () => {
    const listing = {
      ...hostListings[0],
      metrics: undefined,
      reviews: [],
    } as HostListing;

    const summary = buildListingReviewSummary(listing, [
      review("public-1", 5, "unverified"),
    ]);

    expect(summary.displayRating).toBe(0);
    expect(summary.displayReviewCount).toBe(1);
    expect(summary.verifiedCount).toBe(0);
  });
});
