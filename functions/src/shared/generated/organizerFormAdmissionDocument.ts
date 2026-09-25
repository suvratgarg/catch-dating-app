/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned immutable organizer/event/response admission ownership. Created atomically with the seat and request receipt; new request IDs cannot admit this source again.
 */
export interface OrganizerFormAdmissionDocument {
  organizerId: string;
  eventId: string;
  responseId: string;
  receiptId: string;
  attendeeId: string;
  canonicalSeatKey: string;
  offerId: string;
  offerRevision: number;
  offerGeneration: number;
}
