/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Short-lived signed venue session returned only to an authorized Host manager.
 */
export interface CreateEventVenueSessionCallableResponse {
  eventId: string;
  venueSessionToken: string;
  expiresAtMillis: number;
  refreshAfterMillis: number;
}
