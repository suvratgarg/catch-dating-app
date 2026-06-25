/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by listPublicClubReviews for public organizer listing review hydration.
 */
export interface ListPublicClubReviewsCallableResponse {
  /**
   * @maxItems 50
   */
  reviews: {
    id: string;
    reviewerName: string;
    rating: number;
    comment: string;
    createdAt: string;
    verificationStatus: "verified" | "unverified";
    source: "catchEvent" | "publicListing";
    isAnonymous: boolean;
    ownerResponse: {
      hostName: string;
      hostAvatarUrl: string | null;
      message: string;
      updatedAt: string;
    } | null;
  }[];
}
