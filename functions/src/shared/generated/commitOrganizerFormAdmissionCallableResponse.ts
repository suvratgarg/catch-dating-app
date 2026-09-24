/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface CommitOrganizerFormAdmissionCallableResponse {
  receiptId: string;
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string;
  offerId: string;
  attendeeId: string;
  canonicalSeatKey: string;
  requestId: string;
  requestHash: string;
  resultingLedgerRevision: number;
  admittedAtMillis: number;
  seatAlreadyOccupied: boolean;
  replayed: boolean;
}
