/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Committed dispatch result; an exact replay returns the original trip id and revision.
 */
export interface DispatchProgramTripCallableResponse {
  tripId: string;
  revision: number;
  alreadyApplied: boolean;
  passengerCount: number;
}
