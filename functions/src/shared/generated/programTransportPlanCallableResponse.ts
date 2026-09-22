/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Deterministic grouping suggestions from the transport policy, recomputed per request. Suggestions are not reservations; dispatch is a separate command.
 */
export interface ProgramTransportPlanCallableResponse {
  programId: string;
  pickupPointId: string | null;
  generatedAtMillis: number;
  /**
   * @maxItems 200
   */
  groups: {
    /**
     * @minItems 1
     * @maxItems 50
     */
    legIds: string[];
    /**
     * @maxItems 50
     */
    partyIds: string[];
    destinationHotelId: string | null;
    destinationLabel: string;
    readiness: "expected" | "ready";
    vehicleClassId: string;
    vehicleClassLabel: string;
    passengers: number;
    luggageUnits: number;
    earliestCurbAtMillis: number;
    latestCurbAtMillis: number;
    dispatchByMillis: number | null;
    waitOverdue: boolean;
  }[];
  /**
   * @maxItems 500
   */
  unassigned: {
    legId: string;
    reason: "missingTime" | "noSuitableVehicle" | "missingScope";
  }[];
}
