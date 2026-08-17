/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized paginated organizer application review query.
 */
export interface ListOrganizerApplicationsCallablePayload {
  organizerId: string;
  formId?: string | null;
  targetId?: string | null;
  reviewStatus?:
    | null
    | "submitted"
    | "inReview"
    | "approved"
    | "waitlisted"
    | "declined"
    | "withdrawn";
  query?: string | null;
  sort?: "newest" | "oldest" | "name";
  limit?: number;
  cursor?: string | null;
}
