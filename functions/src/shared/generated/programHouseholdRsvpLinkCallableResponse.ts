/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * A freshly minted household RSVP token with its exclusive expiry. The client composes the share URL.
 */
export interface ProgramHouseholdRsvpLinkCallableResponse {
  /**
   * The household document id.
   */
  entityId: string;
  token: string;
  expiresAtMillis: number;
  alreadyApplied: boolean;
}
