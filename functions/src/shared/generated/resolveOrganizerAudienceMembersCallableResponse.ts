/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded static selection labels and canonical contact links; unavailable contacts expose no identity.
 */
export interface ResolveOrganizerAudienceMembersCallableResponse {
  /**
   * @maxItems 2500
   */
  members: {
    selectedContactId: string;
    contactId: string | null;
    displayName: string | null;
    available: boolean;
  }[];
}
