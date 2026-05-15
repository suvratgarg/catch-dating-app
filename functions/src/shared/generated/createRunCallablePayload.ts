/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createRun.
 */
export interface CreateRunCallablePayload {
  runId?: string;
  runClubId: string;
  startTimeMillis: number;
  endTimeMillis: number;
  meetingPoint: string;
  startingPointLat: number;
  startingPointLng: number;
  locationDetails?: string | null;
  distanceKm: number;
  pace: "easy" | "moderate" | "fast" | "competitive";
  capacityLimit: number;
  description: string;
  priceInPaise: number;
  constraints?: {
    minAge?: number;
    maxAge?: number;
    maxMen?: number | null;
    maxWomen?: number | null;
  };
}
