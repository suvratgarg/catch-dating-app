/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Hotel-desk projection for one property: en-route trips and guests still expected. No phone numbers, flight internals or other hotels' data.
 */
export interface ProgramHotelInboundCallableResponse {
  programId: string;
  hotelId: string;
  hotelName: string;
  generatedAtMillis: number;
  /**
   * @maxItems 200
   */
  trips: {
    tripId: string;
    plateDisplay: string;
    vehicleClassId: string;
    vendorName: string | null;
    departedAtMillis: number;
    /**
     * Route ETA once the Maps adapter ships; null until then.
     */
    estimatedArriveAtMillis: number | null;
    passengerCount: number;
    /**
     * @maxItems 50
     */
    guestNames: string[];
    status: "enRoute" | "arrived" | "cancelled" | "voided";
    revision: number;
  }[];
  /**
   * @maxItems 500
   */
  expectedLegs: {
    legId: string;
    guestDisplayName: string;
    partyLabel: string | null;
    passengers: number;
    curbAtMillis: number | null;
    readiness:
      | "expected"
      | "ready"
      | "dispatched"
      | "arrived"
      | "disrupted"
      | "noShow";
  }[];
}
