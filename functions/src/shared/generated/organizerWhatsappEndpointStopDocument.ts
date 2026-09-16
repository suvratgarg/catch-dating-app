/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest authenticated text STOP for an organizer and WhatsApp endpoint, independent of CRM contact resolution. No TTL until suppression and consent retention are reconciled.
 */
export interface OrganizerWhatsappEndpointStopDocument {
  schemaVersion: 1;
  stopId: string;
  organizerId: string;
  endpointHash: string;
  connectionId: string;
  providerAccountId: string;
  providerPhoneNumberId: string;
  providerEventId: string;
  payloadHash: string;
  stoppedAt: number;
  observedAt: number;
  revision: number;
}
