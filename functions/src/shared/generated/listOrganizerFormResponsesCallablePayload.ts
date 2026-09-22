/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized bounded response inbox query.
 */
export interface ListOrganizerFormResponsesCallablePayload {
  organizerId: string;
  formId: string | null;
  versionId: string | null;
  /**
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  /**
   * @maxItems 4
   */
  identityKinds: (
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount"
  )[];
  sourceLinkId: string | null;
  query: string | null;
  fromMillis: number | null;
  toMillis: number | null;
  cursor: string | null;
  sortDirection?: "asc" | "desc";
  /**
   * @maxItems 5
   */
  answerFilters?: {
    questionId: string;
    /**
     * @minItems 1
     * @maxItems 20
     */
    values: string[];
  }[];
  limit: number;
  /**
   * Opt into the unified response and application review inbox.
   */
  includeApplications?: boolean;
  reviewStatus?:
    | (
        | "submitted"
        | "inReview"
        | "approved"
        | "waitlisted"
        | "declined"
        | "withdrawn"
      )
    | null;
  contactId?: string | null;
}
