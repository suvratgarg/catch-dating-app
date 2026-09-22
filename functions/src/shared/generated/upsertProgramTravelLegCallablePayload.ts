/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update one guest journey. Guest and journey kind are immutable; party membership is owned by upsertProgramTravelParty.
 */
export type UpsertProgramTravelLegCallablePayload = {
  [k: string]: unknown;
} & {
  programId: string;
  legId?: string;
  expectedRevision?: number;
  guestId: string;
  kind: "inbound" | "outbound" | "ground";
  flightNumber?: string | null;
  carrierCode?: string | null;
  originIata?: string | null;
  destinationIata?: string | null;
  scheduledArrivalAtMillis?: number | null;
  /**
   * True for international sectors; selects the program's international exit lag.
   */
  international?: boolean | null;
  pickupPointId?: string | null;
  destinationHotelId?: string | null;
  destinationLabel?: string | null;
  passengers: number;
  luggageUnits: number;
  /**
   * @maxItems 12
   */
  requiredCapabilities: (
    | "wheelchairAccessible"
    | "extraLuggage"
    | "childSeat"
  )[];
  dedicatedVehicle: boolean;
};
