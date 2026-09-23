/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager/dispatcher/reconciliation trip ledger: the dispatch record that drives vendor reconciliation.
 */
export interface ProgramTripListCallableResponse {
  programId: string;
  /**
   * @maxItems 50
   */
  trips: {
    tripId: string;
    pickupPointId: string;
    destinationHotelId: string | null;
    destinationLabel: string;
    vehicleClassId: string;
    plateDisplay: string;
    vendorId: string | null;
    vendorName?: string | null;
    kind: "guestTransfer" | "repositioning";
    status: "enRoute" | "arrived" | "cancelled" | "voided";
    passengerCount: number;
    departedAtMillis: number;
    arrivedAtMillis: number | null;
    voidReason: string | null;
    /**
     * @maxItems 50
     */
    guestNames: string[];
    revision: number;
  }[];
  /**
   * Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active.
   */
  accessExpiresAtMillis: number | null;
  nextCursor: string | null;
}
