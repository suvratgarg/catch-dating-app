/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable payload accepted by updateRun.
 */
export interface UpdateRunCallablePayload {
  runId: string;
  fields: {
    startTimeMillis?: number;
    endTimeMillis?: number;
    meetingPoint?: string;
    startingPointLat?: (number | null) | null;
    startingPointLng?: (number | null) | null;
    locationDetails?: string | null;
    distanceKm?: number;
    pace?: "easy" | "moderate" | "fast" | "competitive";
    description?: string;
  };
}
