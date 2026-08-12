/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager request to verify a calendar-scoped Luma API key and list manageable events without persisting the key.
 */
export interface ListOrganizerLumaEventsCallablePayload {
  organizerId: string;
  eventId: string;
  apiKey: string;
}
