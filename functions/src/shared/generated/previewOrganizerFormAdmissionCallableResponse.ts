/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Read-only admission review of the same source, payment, identity and seat checks as commit. Never reserves a seat.
 */
export interface PreviewOrganizerFormAdmissionCallableResponse {
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string;
  offerId: string;
  canCommit: boolean;
  expectedOfferRevision: number | null;
  expectedOfferGeneration: number | null;
  expectedLedgerRevision: number | null;
  seatAlreadyOccupied: boolean | null;
  paymentAuthority: "explicitFree" | "hostAttested" | null;
  blocker: null | {
    code: "unavailable" | "stale" | "conflict";
    message: string;
  };
}
