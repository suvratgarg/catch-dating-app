/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Updated organizer application review identity and revision.
 */
export interface ReviewOrganizerApplicationCallableResponse {
  organizerId: string;
  applicationId: string;
  reviewStatus: "inReview" | "approved" | "waitlisted" | "declined";
  reviewedAtMillis: number;
  revision: number;
  contactId?: string | null;
}
