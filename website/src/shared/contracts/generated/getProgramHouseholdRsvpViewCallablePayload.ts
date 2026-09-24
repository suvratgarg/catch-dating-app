/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Token-authenticated read of one household's RSVP surface. The signed token is the credential; no session is required.
 */
export interface GetProgramHouseholdRsvpViewCallablePayload {
  token: string;
}
