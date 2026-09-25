/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Mint a signed RSVP link token for one household. The token carries only ids and an exclusive expiry; default expiry is the program end.
 */
export interface IssueProgramHouseholdRsvpLinkCallablePayload {
  programId: string;
  householdId: string;
  /**
   * Exclusive token expiry in epoch milliseconds; defaults to the program's endsAt.
   */
  expiresAtMillis?: number;
}
