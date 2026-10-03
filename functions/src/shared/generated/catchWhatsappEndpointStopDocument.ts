/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private permanent Catch sender/endpoint STOP fence, committed atomically with the immutable authenticated inbound STOP receipt. Independent of UID and organizer contact resolution. No raw endpoint, message body, credentials, TTL, reset or automatic re-enrollment. Ingress wiring and historical reconciliation remain required before outbound activation.
 */
export interface CatchWhatsappEndpointStopDocument {
  schemaVersion: 1;
  stopId: string;
  wabaId: string;
  phoneNumberId: string;
  endpointHash: string;
  sourceEventId: string;
  sourceMessageId: string;
  payloadHash: string;
  observedAtMillis: number;
}
