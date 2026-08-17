/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Optimistic manager review mutation for one organizer application.
 */
export interface ReviewOrganizerApplicationCallablePayload {
  organizerId: string;
  applicationId: string;
  expectedRevision: number;
  reviewStatus: "inReview" | "approved" | "waitlisted" | "declined";
  reviewNote: string | null;
}
