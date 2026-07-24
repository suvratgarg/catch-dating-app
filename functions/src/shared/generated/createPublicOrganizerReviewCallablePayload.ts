/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createPublicOrganizerReview for unverified public organizer listing reviews.
 */
export interface CreatePublicOrganizerReviewCallablePayload {
  organizerId: string;
  rating: number;
  comment: string;
  reviewerName: string;
  isAnonymous: boolean;
  submittedFromPath: string;
}
