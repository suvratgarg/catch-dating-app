/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Resolves the explicitly selected organizer contact ids for a static audience editor.
 */
export interface ResolveOrganizerAudienceMembersCallablePayload {
  organizerId: string;
  /**
   * @minItems 0
   * @maxItems 2500
   */
  contactIds: string[];
}
