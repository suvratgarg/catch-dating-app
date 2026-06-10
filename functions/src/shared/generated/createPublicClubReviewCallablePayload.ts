/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createPublicClubReview for unverified public organizer listing reviews.
 */
export interface CreatePublicClubReviewCallablePayload {
  clubId: string;
  rating: number;
  comment: string;
  reviewerName: string;
  isAnonymous: boolean;
  submittedFromPath?: string | null;
}
