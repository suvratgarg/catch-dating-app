/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host resolution for one currently checked-in operational attendee during an Event Success sweep.
 */
export interface SetEventSuccessAccountabilityResolutionCallablePayload {
  eventId: string;
  attendeeId: string;
  resolution: "returned" | "departed" | "unresolved";
}
