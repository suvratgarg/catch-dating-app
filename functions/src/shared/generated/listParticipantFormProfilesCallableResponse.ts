/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private summary metadata only; invalid or withdrawn response sources are omitted.
 */
export interface ListParticipantFormProfilesCallableResponse {
  /**
   * @maxItems 30
   */
  items: {
    responseId: string;
    organizerId: string;
    organizerName: string | null;
    formTitle: string;
    submittedAtMillis: number;
    claimedAtMillis: number | null;
    cardFieldCount: number;
  }[];
  nextCursor: string | null;
}
