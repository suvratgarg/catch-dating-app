/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Staff-recorded RSVP for one guest on one program function. The server derives the program-level guest rollup and function counters; last response wins per join key.
 */
export interface RecordProgramFunctionRsvpCallablePayload {
  programId: string;
  functionId: string;
  guestId: string;
  rsvpStatus: "pending" | "attending" | "declined" | "maybe";
  /**
   * Attending party size; null reads as 1.
   */
  partySize?: number | null;
  responseNote?: string | null;
  /**
   * Record a response for a selectedGuests function the guest was not invited to; the row lands invited:true.
   */
  allowUninvited?: boolean;
}
