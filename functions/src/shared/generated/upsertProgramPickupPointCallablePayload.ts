/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update a program pickup station such as an airport terminal arrivals zone.
 */
export interface UpsertProgramPickupPointCallablePayload {
  programId: string;
  pickupPointId?: string;
  expectedRevision?: number;
  kind: "airport" | "railway" | "venue" | "other";
  label: string;
  iataCode?: string | null;
  terminal?: string | null;
  meetingZone?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  instructions?: string | null;
  active?: boolean;
}
