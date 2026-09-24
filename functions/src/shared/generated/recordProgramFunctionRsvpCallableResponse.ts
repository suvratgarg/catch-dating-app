/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Acknowledgement for a recorded function RSVP: the join-key row id, its revision, and the guest's derived program-level RSVP rollup.
 */
export interface RecordProgramFunctionRsvpCallableResponse {
  /**
   * The programFunctionGuests join-key document id.
   */
  entityId: string;
  revision: number;
  /**
   * Derived programGuests.rsvpStatus rollup after this response.
   */
  guestRsvpStatus: "pending" | "attending" | "declined" | "maybe";
  /**
   * True when an exact replay returned the original result.
   */
  alreadyApplied: boolean;
}
