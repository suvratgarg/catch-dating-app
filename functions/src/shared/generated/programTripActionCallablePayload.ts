/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Post-dispatch trip lifecycle payload shared by markProgramTripArrived and voidProgramTrip; the callable name carries the action.
 */
export interface ProgramTripActionCallablePayload {
  programId: string;
  tripId: string;
  /**
   * Required for voidProgramTrip; recorded on the trip for reconciliation review.
   */
  reason?: string | null;
  expectedRevision: number;
  clientOperationId: string;
}
