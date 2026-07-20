/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by createPublicOrganizerReview after a public organizer review is accepted.
 */
export interface CreatePublicOrganizerReviewCallableResponse {
  reviewId: string;
  review: {
    id: string;
    reviewerName: string;
    rating: number;
    comment: string;
    createdAt: string;
    verificationStatus: "verified" | "unverified";
    source: "catchEvent" | "publicListing";
    moderationStatus: "published" | "pending";
    isAnonymous: boolean;
    ownerResponse: {
      hostName: string;
      hostAvatarUrl: string | null;
      message: string;
      updatedAt: string;
    } | null;
  };
}
