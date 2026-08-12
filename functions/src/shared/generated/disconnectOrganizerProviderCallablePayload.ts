/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager request to revoke one organizer provider connection and stop future synchronization.
 */
export interface DisconnectOrganizerProviderCallablePayload {
  organizerId: string;
  eventId: string;
  connectionId: string;
}
